# Comandos de Prueba Manuales - API S3

## Configuración

**URLs configuradas:**
- **DEV:** `https://ilcb7hv8z5.execute-api.us-east-1.amazonaws.com/dev`
- **TEST:** `https://dzym3izui3.execute-api.us-east-1.amazonaws.com/test`
- **PROD:** `https://yko0sfyfn4.execute-api.us-east-1.amazonaws.com/prod`

**Nota:** Reemplaza `[bucket-existente]` con el nombre de un bucket que ya existe en tu cuenta S3.

## Entorno DEV

### 1. Listar Buckets
```bash
curl -X GET https://ilcb7hv8z5.execute-api.us-east-1.amazonaws.com/dev/s3/lista-buckets
```

### 2. Crear Bucket (puede retornar 403 por permisos)
```bash
curl -X POST https://ilcb7hv8z5.execute-api.us-east-1.amazonaws.com/dev/s3/crear-bucket \
  -H "Content-Type: application/json" \
  -d '{"bucket": "mi-bucket-prueba-dev"}'
```

### 3. Crear Directorio
```bash
curl -X POST https://ilcb7hv8z5.execute-api.us-east-1.amazonaws.com/dev/s3/crear-directorio \
  -H "Content-Type: application/json" \
  -d '{
    "bucket": "[bucket-existente]",
    "directorio": "mis-documentos"
  }'
```

### 4. Subir Archivo
```bash
curl -X POST https://ilcb7hv8z5.execute-api.us-east-1.amazonaws.com/dev/s3/subir-archivo \
  -H "Content-Type: application/json" \
  -d '{
    "bucket": "[bucket-existente]",
    "directorio": "mis-documentos",
    "archivo": "test.txt",
    "contenido": "Hola, este es un archivo de prueba desde dev"
  }'
```

### 5. Listar Objetos de un Bucket
```bash
curl -X POST https://ilcb7hv8z5.execute-api.us-east-1.amazonaws.com/dev/s3/bucket/lista-objetos \
  -H "Content-Type: application/json" \
  -d '{"bucket": "[bucket-existente]"}'
```

## Entorno TEST

### 1. Listar Buckets
```bash
curl -X GET https://dzym3izui3.execute-api.us-east-1.amazonaws.com/test/s3/lista-buckets
```

### 2. Crear Bucket (puede retornar 403 por permisos)
```bash
curl -X POST https://dzym3izui3.execute-api.us-east-1.amazonaws.com/test/s3/crear-bucket \
  -H "Content-Type: application/json" \
  -d '{"bucket": "mi-bucket-prueba-test"}'
```

### 3. Crear Directorio
```bash
curl -X POST https://dzym3izui3.execute-api.us-east-1.amazonaws.com/test/s3/crear-directorio \
  -H "Content-Type: application/json" \
  -d '{
    "bucket": "[bucket-existente]",
    "directorio": "mis-documentos"
  }'
```

### 4. Subir Archivo
```bash
curl -X POST https://dzym3izui3.execute-api.us-east-1.amazonaws.com/test/s3/subir-archivo \
  -H "Content-Type: application/json" \
  -d '{
    "bucket": "[bucket-existente]",
    "directorio": "mis-documentos",
    "archivo": "test.txt",
    "contenido": "Hola, este es un archivo de prueba desde test"
  }'
```

### 5. Listar Objetos de un Bucket
```bash
curl -X POST https://dzym3izui3.execute-api.us-east-1.amazonaws.com/test/s3/bucket/lista-objetos \
  -H "Content-Type: application/json" \
  -d '{"bucket": "[bucket-existente]"}'
```

## Entorno PROD

### 1. Listar Buckets
```bash
curl -X GET https://yko0sfyfn4.execute-api.us-east-1.amazonaws.com/prod/s3/lista-buckets
```

### 2. Crear Bucket (puede retornar 403 por permisos)
```bash
curl -X POST https://yko0sfyfn4.execute-api.us-east-1.amazonaws.com/prod/s3/crear-bucket \
  -H "Content-Type: application/json" \
  -d '{"bucket": "mi-bucket-prueba-prod"}'
```

### 3. Crear Directorio
```bash
curl -X POST https://yko0sfyfn4.execute-api.us-east-1.amazonaws.com/prod/s3/crear-directorio \
  -H "Content-Type: application/json" \
  -d '{
    "bucket": "[bucket-existente]",
    "directorio": "mis-documentos"
  }'
```

### 4. Subir Archivo
```bash
curl -X POST https://yko0sfyfn4.execute-api.us-east-1.amazonaws.com/prod/s3/subir-archivo \
  -H "Content-Type: application/json" \
  -d '{
    "bucket": "[bucket-existente]",
    "directorio": "mis-documentos",
    "archivo": "test.txt",
    "contenido": "Hola, este es un archivo de prueba desde prod"
  }'
```

### 5. Listar Objetos de un Bucket
```bash
curl -X POST https://yko0sfyfn4.execute-api.us-east-1.amazonaws.com/prod/s3/bucket/lista-objetos \
  -H "Content-Type: application/json" \
  -d '{"bucket": "[bucket-existente]"}'
```

## Ejemplos con Respuestas Esperadas

### Listar Buckets (Éxito)
```bash
curl -X GET https://ilcb7hv8z5.execute-api.us-east-1.amazonaws.com/dev/s3/lista-buckets
```
**Respuesta esperada:**
```json
{
  "statusCode": 200,
  "lista_buckets": ["bucket1", "bucket2", "bucket3"]
}
```

### Crear Bucket (Error 403 - Sin permisos)
```bash
curl -X POST https://ilcb7hv8z5.execute-api.us-east-1.amazonaws.com/dev/s3/crear-bucket \
  -H "Content-Type: application/json" \
  -d '{"bucket": "mi-bucket-prueba"}'
```
**Respuesta esperada:**
```json
{
  "statusCode": 403,
  "body": "{\"error\": \"Permisos insuficientes. El rol IAM necesita los permisos: s3:CreateBucket y s3:HeadBucket\", \"detalle\": \"...\"}"
}
```

### Crear Directorio (Éxito)
```bash
curl -X POST https://ilcb7hv8z5.execute-api.us-east-1.amazonaws.com/dev/s3/crear-directorio \
  -H "Content-Type: application/json" \
  -d '{"bucket": "mi-bucket-existente", "directorio": "mis-documentos"}'
```
**Respuesta esperada:**
```json
{
  "statusCode": 200,
  "body": "{\"mensaje\": \"Directorio \\\"mis-documentos/\\\" creado exitosamente en el bucket \\\"mi-bucket-existente\\\"\", \"bucket\": \"mi-bucket-existente\", \"directorio\": \"mis-documentos/\"}"
}
```

### Subir Archivo (Éxito)
```bash
curl -X POST https://ilcb7hv8z5.execute-api.us-east-1.amazonaws.com/dev/s3/subir-archivo \
  -H "Content-Type: application/json" \
  -d '{
    "bucket": "mi-bucket-existente",
    "directorio": "mis-documentos",
    "archivo": "test.txt",
    "contenido": "Contenido del archivo"
  }'
```
**Respuesta esperada:**
```json
{
  "statusCode": 200,
  "body": "{\"mensaje\": \"Archivo \\\"test.txt\\\" subido exitosamente\", \"bucket\": \"mi-bucket-existente\", \"directorio\": \"mis-documentos/\", \"archivo\": \"test.txt\", \"ruta_completa\": \"mis-documentos/test.txt\"}"
}
```

## URLs de los Endpoints

Las URLs ya están configuradas en este documento. Si necesitas verificar las URLs actuales, ejecuta:

```bash
# Para dev
serverless info --stage dev

# Para test
serverless info --stage test

# Para prod
serverless info --stage prod
```

