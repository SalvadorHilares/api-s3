#!/bin/bash

# ============================================
# COMANDOS DE PRUEBA LISTOS PARA USAR
# ============================================
# Reemplaza [bucket-existente] con un bucket que ya existe en tu cuenta
# ============================================

# URLs base configuradas con las URLs reales del despliegue
BASE_DEV="https://ilcb7hv8z5.execute-api.us-east-1.amazonaws.com/dev"
BASE_TEST="https://dzym3izui3.execute-api.us-east-1.amazonaws.com/test"
BASE_PROD="https://yko0sfyfn4.execute-api.us-east-1.amazonaws.com/prod"

# Bucket existente para pruebas (REEMPLAZA ESTO)
BUCKET_EXISTENTE="[bucket-existente]"

# Función para probar un entorno
test_env() {
    local env=$1
    local base=$2
    
    echo "=========================================="
    echo "PRUEBAS API S3 - ENTORNO $env"
    echo "=========================================="
    echo ""
    
    # 1. LISTAR BUCKETS
    echo "1. Listando buckets..."
    curl -X GET "$base/s3/lista-buckets"
    echo -e "\n\n"
    
    # 2. CREAR BUCKET (puede fallar por permisos)
    echo "2. Intentando crear bucket (puede retornar 403)..."
    curl -X POST "$base/s3/crear-bucket" \
      -H "Content-Type: application/json" \
      -d '{"bucket": "bucket-prueba-'$env'-'$(date +%s)'"}'
    echo -e "\n\n"
    
    # 3. CREAR DIRECTORIO
    echo "3. Creando directorio..."
    curl -X POST "$base/s3/crear-directorio" \
      -H "Content-Type: application/json" \
      -d "{\"bucket\": \"$BUCKET_EXISTENTE\", \"directorio\": \"documentos-prueba\"}"
    echo -e "\n\n"
    
    # 4. SUBIR ARCHIVO
    echo "4. Subiendo archivo..."
    curl -X POST "$base/s3/subir-archivo" \
      -H "Content-Type: application/json" \
      -d "{
        \"bucket\": \"$BUCKET_EXISTENTE\",
        \"directorio\": \"documentos-prueba\",
        \"archivo\": \"test-$(date +%s).txt\",
        \"contenido\": \"Archivo de prueba creado el $(date) en $env\"
      }"
    echo -e "\n\n"
    
    # 5. LISTAR OBJETOS DEL BUCKET
    echo "5. Listando objetos del bucket..."
    curl -X POST "$base/s3/bucket/lista-objetos" \
      -H "Content-Type: application/json" \
      -d "{\"bucket\": \"$BUCKET_EXISTENTE\"}"
    echo -e "\n\n"
    
    echo "=========================================="
    echo "Pruebas completadas para $env"
    echo "=========================================="
    echo ""
}

# Ejecutar pruebas según argumento
if [ $# -eq 0 ]; then
    echo "Uso: $0 [dev|test|prod|all]"
    echo ""
    echo "Ejemplos:"
    echo "  $0 dev    - Probar solo entorno dev"
    echo "  $0 test   - Probar solo entorno test"
    echo "  $0 prod   - Probar solo entorno prod"
    echo "  $0 all    - Probar todos los entornos"
    exit 1
fi

ENV_ARG=$1

case $ENV_ARG in
    dev)
        test_env "DEV" "$BASE_DEV"
        ;;
    test)
        test_env "TEST" "$BASE_TEST"
        ;;
    prod)
        test_env "PROD" "$BASE_PROD"
        ;;
    all)
        test_env "DEV" "$BASE_DEV"
        test_env "TEST" "$BASE_TEST"
        test_env "PROD" "$BASE_PROD"
        ;;
    *)
        echo "Entorno no válido: $ENV_ARG"
        echo "Usa: dev, test, prod o all"
        exit 1
        ;;
esac

