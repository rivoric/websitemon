import logging, os, requests, json

import azure.functions as func

def main(req: func.HttpRequest, website_config) -> func.HttpResponse:
    configuration = json.loads(website_config)
    response = requests.get(configuration["WebsiteUrl"])
    return func.HttpResponse(
        "%s -> %s" % (response.url, response.reason),
#        ", ".join(os.environ.keys()),
        status_code=response.status_code
    )
