import json


def lambda_handler(event, context):
    print(json.dumps(event))
    request = event['Records'][0]['cf']['request']
    request_uri = request['uri'].lstrip('/')
    redirect_uri = ""
    if ${use_existing_url}:
        if request_uri != '${default_uri}'.lstrip('/'):
            redirect_uri = request_uri
        if request['querystring'] != "":
            redirect_uri += "?{}".format(request['querystring'])
    else:
        redirect_uri = '${redirect_path}'.lstrip('/')
    protocol = request['headers']['cloudfront-forwarded-proto'][0]['value']
    response = {
        'status': '${redirect_code}',
        'statusDescription': '${redirect_description}',
        'headers': {
            'location': [{
                'key': 'Location',
                'value': protocol + '://${redirect_domain}/' + redirect_uri
            }]
        }
    }
    return response
