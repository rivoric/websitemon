import logging
import requests
import json
import azure.functions as func

def main(req: func.HttpRequest, config: str) -> func.HttpResponse:
    configuration = json.loads(config)
    response = requests.get(configuration["websiteUrl"])
    logging.info("%s -> %s" % (response.url, response.reason))
    return func.HttpResponse(
        "%s -> %s" % (response.url, response.reason),
        status_code=response.status_code
    )
