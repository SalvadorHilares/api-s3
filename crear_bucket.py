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
        
        if not nombre_bucket:
            return {
                'statusCode': 400,
                'body': json.dumps({
                    'error': 'El parámetro "bucket" es requerido'
                })
            }
        
        # Proceso
        s3 = boto3.client('s3')
        
        # Verificar si el bucket ya existe
        try:
            s3.head_bucket(Bucket=nombre_bucket)
            return {
                'statusCode': 409,
                'body': json.dumps({
                    'mensaje': f'El bucket "{nombre_bucket}" ya existe',
                    'bucket': nombre_bucket
                })
            }
        except s3.exceptions.ClientError as e:
            error_code = e.response['Error']['Code']
            if error_code != '404':
                raise
        
        # Crear el bucket
        s3.create_bucket(Bucket=nombre_bucket)
        
        # Salida
        return {
            'statusCode': 200,
            'body': json.dumps({
                'mensaje': f'Bucket "{nombre_bucket}" creado exitosamente',
                'bucket': nombre_bucket
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e)
            })
        }

