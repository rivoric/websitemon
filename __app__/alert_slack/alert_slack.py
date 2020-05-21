import logging
import json
import requests
import azure.functions as func

def main(queue: func.QueueMessage, config: str) -> None:
    configuration = json.loads(config)
    slack_payload = {
        'text': msg.get_body().decode('utf-8'),
        'channel': configuration["channel"]
    }
    logging.info('JSON to POST to Slack: %s',json.dumps(slack_payload))

    response = requests.post(configuration['WebsiteUrl'],json=slack_payload)
    if response.status_code == 200:
        logging.info("Message posted in Slack")
    else:
        logging.error("Failed to post message in Slack: %d - %s", response.status_code,response.reason)