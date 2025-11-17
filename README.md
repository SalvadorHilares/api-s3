# api-s3

API REST para operaciones con Amazon S3 usando AWS Lambda y Serverless Framework.

## Funciones Lambda

1. **lista_buckets** - Lista todos los buckets S3
2. **lista_objetos_bucket** - Lista los objetos de un bucket específico
3. **crear_bucket** - Crea un nuevo bucket S3 ⚠️ **Limitado por permisos IAM**
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

⚠️ **Nota:** Este endpoint requiere permisos `s3:CreateBucket` y `s3:HeadBucket` en el rol IAM. Si el rol no tiene estos permisos, retornará un error 403.

```bash
curl -X POST https://[api-id].execute-api.[region].amazonaws.com/[stage]/s3/crear-bucket \
  -H "Content-Type: application/json" \
  -d '{"bucket": "mi-bucket-prueba"}'
```

**Respuesta de error cuando faltan permisos:**
```json
{
  "statusCode": 403,
  "body": "{\"error\": \"Permisos insuficientes. El rol IAM necesita los permisos: s3:CreateBucket y s3:HeadBucket\", \"detalle\": \"...\"}"
}
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

## Limitaciones

### Permisos IAM

El endpoint `crear_bucket` requiere permisos específicos en el rol IAM asociado a las funciones Lambda:
- `s3:CreateBucket` - Para crear nuevos buckets
- `s3:HeadBucket` - Para verificar si un bucket ya existe

**Si el rol IAM no tiene estos permisos**, el endpoint retornará un error HTTP 403 con un mensaje indicando los permisos faltantes. En este caso, **no es posible crear buckets desde este endpoint** debido a las restricciones del rol IAM asignado.