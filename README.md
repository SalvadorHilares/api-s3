# api-s3

API REST para operaciones con Amazon S3 usando AWS Lambda y Serverless Framework.

## Funciones Lambda

1. **lista_buckets** - Lista todos los buckets S3
2. **lista_objetos_bucket** - Lista los objetos de un bucket específico
3. **crear_bucket** - Crea un nuevo bucket S3
4. **crear_directorio** - Crea un directorio en un bucket existente
5. **subir_archivo** - Sube un archivo a un directorio en un bucket existente

## Despliegue

### Desplegar en diferentes stages

```bash
# Desplegar en dev
serverless deploy --stage dev

# Desplegar en test
serverless deploy --stage test

# Desplegar en prod
serverless deploy --stage prod
```

## Pruebas con curl

Después del despliegue, obtendrás las URLs de los endpoints. Ejemplo de uso:

### 1. Crear un bucket

```bash
curl -X POST https://[api-id].execute-api.[region].amazonaws.com/[stage]/s3/crear-bucket \
  -H "Content-Type: application/json" \
  -d '{"bucket": "mi-bucket-prueba"}'
```

### 2. Crear un directorio en un bucket

```bash
curl -X POST https://[api-id].execute-api.[region].amazonaws.com/[stage]/s3/crear-directorio \
  -H "Content-Type: application/json" \
  -d '{"bucket": "mi-bucket-prueba", "directorio": "mis-documentos"}'
```

### 3. Subir un archivo

```bash
# El contenido puede ser texto plano o base64
curl -X POST https://[api-id].execute-api.[region].amazonaws.com/[stage]/s3/subir-archivo \
  -H "Content-Type: application/json" \
  -d '{
    "bucket": "mi-bucket-prueba",
    "directorio": "mis-documentos",
    "archivo": "test.txt",
    "contenido": "Hola, este es un archivo de prueba"
  }'
```

### 4. Listar buckets

```bash
curl -X GET https://[api-id].execute-api.[region].amazonaws.com/[stage]/s3/lista-buckets
```

### 5. Listar objetos de un bucket

```bash
curl -X POST https://[api-id].execute-api.[region].amazonaws.com/[stage]/s3/bucket/lista-objetos \
  -H "Content-Type: application/json" \
  -d '{"bucket": "mi-bucket-prueba"}'
```

## Notas

- Reemplaza `[api-id]`, `[region]` y `[stage]` con los valores reales después del despliegue
- Para archivos binarios, codifica el contenido en base64 antes de enviarlo
- Los directorios en S3 son prefijos, no objetos reales