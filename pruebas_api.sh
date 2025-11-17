#!/bin/bash

# Script de pruebas para API S3
# Reemplaza las URLs base según tu despliegue

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# URLs base - Configuradas con las URLs reales del despliegue
BASE_URL_DEV="https://ilcb7hv8z5.execute-api.us-east-1.amazonaws.com/dev"
BASE_URL_TEST="https://dzym3izui3.execute-api.us-east-1.amazonaws.com/test"
BASE_URL_PROD="https://yko0sfyfn4.execute-api.us-east-1.amazonaws.com/prod"

# Nombre del bucket para pruebas (ajusta según necesites)
BUCKET_PRUEBA="bucket-prueba-$(date +%s)"
DIRECTORIO_PRUEBA="documentos-prueba"
ARCHIVO_PRUEBA="test-$(date +%s).txt"
CONTENIDO_ARCHIVO="Este es un archivo de prueba creado el $(date)"

# Función para imprimir encabezados
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

# Función para imprimir resultados
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ Éxito${NC}"
    else
        echo -e "${RED}✗ Error${NC}"
    fi
}

# Función para probar un endpoint
test_endpoint() {
    local method=$1
    local url=$2
    local data=$3
    local description=$4
    
    echo -e "${YELLOW}Probando: $description${NC}"
    echo -e "URL: $url"
    if [ -n "$data" ]; then
        echo -e "Data: $data"
    fi
    echo ""
    
    if [ -n "$data" ]; then
        response=$(curl -s -w "\n%{http_code}" -X $method "$url" \
            -H "Content-Type: application/json" \
            -d "$data")
    else
        response=$(curl -s -w "\n%{http_code}" -X $method "$url")
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    echo -e "HTTP Code: $http_code"
    echo -e "Response:"
    echo "$body" | jq '.' 2>/dev/null || echo "$body"
    echo ""
    
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        return 0
    else
        return 1
    fi
}

# Función para probar todos los endpoints en un entorno
test_environment() {
    local env=$1
    local base_url=$2
    
    print_header "PRUEBAS EN ENTORNO: $env"
    
    # 1. Listar buckets
    print_header "1. Listar Buckets"
    test_endpoint "GET" "$base_url/s3/lista-buckets" "" "Listar todos los buckets"
    print_result $?
    
    # Obtener un bucket existente de la lista (si hay)
    BUCKET_EXISTENTE=$(curl -s "$base_url/s3/lista-buckets" | jq -r '.lista_buckets[0]' 2>/dev/null)
    if [ -z "$BUCKET_EXISTENTE" ] || [ "$BUCKET_EXISTENTE" = "null" ]; then
        BUCKET_EXISTENTE="tu-bucket-existente"
        echo -e "${YELLOW}⚠ No se encontraron buckets. Usa un bucket existente para las siguientes pruebas.${NC}\n"
    else
        echo -e "${GREEN}✓ Usando bucket existente: $BUCKET_EXISTENTE${NC}\n"
    fi
    
    # 2. Crear bucket (puede fallar por permisos)
    print_header "2. Crear Bucket"
    test_endpoint "POST" "$base_url/s3/crear-bucket" \
        "{\"bucket\": \"$BUCKET_PRUEBA\"}" \
        "Crear nuevo bucket: $BUCKET_PRUEBA"
    print_result $?
    
    # 3. Crear directorio
    print_header "3. Crear Directorio"
    test_endpoint "POST" "$base_url/s3/crear-directorio" \
        "{\"bucket\": \"$BUCKET_EXISTENTE\", \"directorio\": \"$DIRECTORIO_PRUEBA\"}" \
        "Crear directorio '$DIRECTORIO_PRUEBA' en bucket '$BUCKET_EXISTENTE'"
    print_result $?
    
    # 4. Subir archivo
    print_header "4. Subir Archivo"
    CONTENIDO_B64=$(echo -n "$CONTENIDO_ARCHIVO" | base64 -w 0 2>/dev/null || echo -n "$CONTENIDO_ARCHIVO" | base64)
    test_endpoint "POST" "$base_url/s3/subir-archivo" \
        "{\"bucket\": \"$BUCKET_EXISTENTE\", \"directorio\": \"$DIRECTORIO_PRUEBA\", \"archivo\": \"$ARCHIVO_PRUEBA\", \"contenido\": \"$CONTENIDO_ARCHIVO\"}" \
        "Subir archivo '$ARCHIVO_PRUEBA' al directorio '$DIRECTORIO_PRUEBA'"
    print_result $?
    
    # 5. Listar objetos del bucket
    print_header "5. Listar Objetos del Bucket"
    test_endpoint "POST" "$base_url/s3/bucket/lista-objetos" \
        "{\"bucket\": \"$BUCKET_EXISTENTE\"}" \
        "Listar objetos del bucket '$BUCKET_EXISTENTE'"
    print_result $?
    
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}Pruebas completadas para $env${NC}"
    echo -e "${GREEN}========================================${NC}\n"
}

# Menú principal
echo -e "${BLUE}"
echo "╔════════════════════════════════════════╗"
echo "║   SCRIPT DE PRUEBAS API S3            ║"
echo "╚════════════════════════════════════════╝"
echo -e "${NC}"

# Verificar si se pasó un argumento
if [ $# -eq 0 ]; then
    echo -e "${YELLOW}Uso: $0 [dev|test|prod|all]${NC}"
    echo ""
    echo "Ejemplos:"
    echo "  $0 dev    - Probar solo entorno dev"
    echo "  $0 test   - Probar solo entorno test"
    echo "  $0 prod   - Probar solo entorno prod"
    echo "  $0 all    - Probar todos los entornos"
    echo ""
    echo -e "${GREEN}✓ URLs configuradas para dev, test y prod${NC}"
    exit 1
fi

ENV=$1

case $ENV in
    dev)
        test_environment "DEV" "$BASE_URL_DEV"
        ;;
    test)
        test_environment "TEST" "$BASE_URL_TEST"
        ;;
    prod)
        test_environment "PROD" "$BASE_URL_PROD"
        ;;
    all)
        test_environment "DEV" "$BASE_URL_DEV"
        test_environment "TEST" "$BASE_URL_TEST"
        test_environment "PROD" "$BASE_URL_PROD"
        ;;
    *)
        echo -e "${RED}Entorno no válido: $ENV${NC}"
        echo "Usa: dev, test, prod o all"
        exit 1
        ;;
esac

