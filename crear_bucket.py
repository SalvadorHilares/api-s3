import boto3
import json
import os

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
        
        # Obtener la región de la variable de entorno o usar us-east-1 por defecto
        region = os.environ.get('AWS_REGION', 'us-east-1')
        
        # Proceso
        s3 = boto3.client('s3', region_name=region)
        
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
            if error_code == '403':
                return {
                    'statusCode': 403,
                    'body': json.dumps({
                        'error': 'Permisos insuficientes. El rol IAM necesita los permisos: s3:CreateBucket y s3:HeadBucket',
                        'detalle': str(e)
                    })
                }
            elif error_code != '404':
                return {
                    'statusCode': 500,
                    'body': json.dumps({
                        'error': f'Error al verificar el bucket: {str(e)}',
                        'codigo_error': error_code
                    })
                }
        
        # Crear el bucket
        # Para us-east-1 no se especifica LocationConstraint, para otras regiones sí
        try:
            if region == 'us-east-1':
                s3.create_bucket(Bucket=nombre_bucket)
            else:
                s3.create_bucket(
                    Bucket=nombre_bucket,
                    CreateBucketConfiguration={'LocationConstraint': region}
                )
        except s3.exceptions.ClientError as e:
            error_code = e.response['Error']['Code']
            if error_code == 'BucketAlreadyExists':
                return {
                    'statusCode': 409,
                    'body': json.dumps({
                        'mensaje': f'El bucket "{nombre_bucket}" ya existe',
                        'bucket': nombre_bucket
                    })
                }
            elif error_code == '403':
                return {
                    'statusCode': 403,
                    'body': json.dumps({
                        'error': 'Permisos insuficientes. El rol IAM necesita el permiso: s3:CreateBucket',
                        'detalle': str(e)
                    })
                }
            else:
                raise
        
        # Salida
        return {
            'statusCode': 200,
            'body': json.dumps({
                'mensaje': f'Bucket "{nombre_bucket}" creado exitosamente',
                'bucket': nombre_bucket,
                'region': region
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': f'Error inesperado: {str(e)}'
            })
        }

