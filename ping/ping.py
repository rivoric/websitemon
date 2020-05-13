import logging, os, requests

import azure.functions as func

def main(req: func.HttpRequest) -> func.HttpResponse:
    response = requests.get(os.environ["WebsiteUrl"])
    return func.HttpResponse(
        "%s -> %s : " % (response.url, response.reason),
#        ", ".join(os.environ.keys()),
        status_code=response.status_code
    )
