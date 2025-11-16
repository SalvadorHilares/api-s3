import boto3
import json
import base64

def lambda_handler(event, context):
    # Entrada (json)
    try:
        if isinstance(event.get('body'), str):
            body = json.loads(event['body'])
        else:
            body = event.get('body', {})
        
        nombre_bucket = body.get('bucket')
        nombre_directorio = body.get('directorio', '')
        nombre_archivo = body.get('archivo')
        contenido = body.get('contenido')
        
        if not nombre_bucket:
            return {
                'statusCode': 400,
                'body': json.dumps({
                    'error': 'El parámetro "bucket" es requerido'
                })
            }
        
        if not nombre_archivo:
            return {
                'statusCode': 400,
                'body': json.dumps({
                    'error': 'El parámetro "archivo" es requerido'
                })
            }
        
        if not contenido:
            return {
                'statusCode': 400,
                'body': json.dumps({
                    'error': 'El parámetro "contenido" es requerido'
                })
            }
        
        # Construir la ruta completa del archivo
        if nombre_directorio:
            if not nombre_directorio.endswith('/'):
                nombre_directorio += '/'
            ruta_completa = nombre_directorio + nombre_archivo
        else:
            ruta_completa = nombre_archivo
        
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
        
        # Decodificar el contenido si viene en base64
        try:
            if isinstance(contenido, str):
                # Intentar decodificar base64
                try:
                    contenido_bytes = base64.b64decode(contenido)
                except:
                    # Si no es base64, usar como texto
                    contenido_bytes = contenido.encode('utf-8')
            else:
                contenido_bytes = contenido
        
        except Exception as e:
            return {
                'statusCode': 400,
                'body': json.dumps({
                    'error': f'Error al procesar el contenido: {str(e)}'
                })
            }
        
        # Subir el archivo
        s3.put_object(
            Bucket=nombre_bucket,
            Key=ruta_completa,
            Body=contenido_bytes
        )
        
        # Salida
        return {
            'statusCode': 200,
            'body': json.dumps({
                'mensaje': f'Archivo "{nombre_archivo}" subido exitosamente',
                'bucket': nombre_bucket,
                'directorio': nombre_directorio if nombre_directorio else '/',
                'archivo': nombre_archivo,
                'ruta_completa': ruta_completa
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e)
            })
        }

