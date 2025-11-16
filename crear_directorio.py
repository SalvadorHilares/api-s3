import boto3
import json

def lambda_handler(event, context):
    # Entrada (json)
    try:
        if isinstance(event.get('body'), str):
            body = json.loads(event['body'])
        else:
            body = event.get('body', {})
        
        nombre_bucket = body.get('bucket')
        nombre_directorio = body.get('directorio')
        
        if not nombre_bucket:
            return {
                'statusCode': 400,
                'body': json.dumps({
                    'error': 'El parámetro "bucket" es requerido'
                })
            }
        
        if not nombre_directorio:
            return {
                'statusCode': 400,
                'body': json.dumps({
                    'error': 'El parámetro "directorio" es requerido'
                })
            }
        
        # Asegurar que el directorio termine con /
        if not nombre_directorio.endswith('/'):
            nombre_directorio += '/'
        
        # Proceso
        s3 = boto3.client('s3')
        
        # Verificar que el bucket existe
        try:
            s3.head_bucket(Bucket=nombre_bucket)
        except s3.exceptions.ClientError as e:
            error_code = e.response['Error']['Code']
            if error_code == '404':
                return {
                    'statusCode': 404,
                    'body': json.dumps({
                        'error': f'El bucket "{nombre_bucket}" no existe'
                    })
                }
            raise
        
        # En S3, los directorios son solo prefijos. Crear un objeto vacío con el prefijo del directorio
        s3.put_object(Bucket=nombre_bucket, Key=nombre_directorio)
        
        # Salida
        return {
            'statusCode': 200,
            'body': json.dumps({
                'mensaje': f'Directorio "{nombre_directorio}" creado exitosamente en el bucket "{nombre_bucket}"',
                'bucket': nombre_bucket,
                'directorio': nombre_directorio
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e)
            })
        }

