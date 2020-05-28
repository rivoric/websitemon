import logging
import json
import requests
import azure.functions as func

def main(queue: func.QueueMessage, config: str) -> None:
    configuration = json.loads(config)
    payload = {
        'text': queue.get_body().decode('utf-8')
    }

    if 'title' in configuration:
        payload['title'] = configuration["title"]

    if 'channel' in configuration:
        payload['channel'] = configuration["channel"]

    logging.info('JSON to POST to webhook: %s',json.dumps(payload))

    response = requests.post(configuration['WebsiteUrl'],json=payload)
    if response.status_code == 200:
        logging.info("Message posted")
    else:
        logging.error("Failed to post message: %d - %s", response.status_code,response.reason)