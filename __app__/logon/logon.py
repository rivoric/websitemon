import logging
import json
import os
import requests
import azure.functions as func
from bs4 import BeautifulSoup
from urllib.parse import urlparse, urljoin

def main(mytimer: func.TimerRequest, config: str, message: func.Out[func.QueueMessage]) -> None:
    configuration = json.loads(config)

    session = requests.Session()
    login_page = session.get(configuration["websiteUrl"])
    if login_page.status_code == 200:
        page_parser = BeautifulSoup(login_page.text, 'html.parser')

        # find the first form and build the input selector from it (required the form to have an id) and the post URL
        form = page_parser.find('form')
        input_selector = "form#%s input" % form['id']
        if form.has_attr('action'):
            # this will work regardless of whether action is a absolute or relative URL
            form_url = urljoin(login_page.url, form['action'])
        else:
            form_url = login_page.url

        # create the post payload
        payload = dict()
        for input in page_parser.select(input_selector):
            if input['name'] == configuration["usernameField"]:
                # Return username
                payload[input['name']] = os.environ['LOGON_USERNAME']
            elif input['name'] == configuration["passwordField"]:
                # Return password
                payload[input['name']] = os.environ['LOGON_PASSWORD']
            elif input.has_attr("value"):
                payload[input['name']] = input['value']

        final_page = session.post(form_url,data=payload)
        if login_page.status_code == 200:
            logging.info("Successful check %s -> %s", final_page.url, final_page.reason))
            # TODO: log off
        else:
            logging.error("Failed check %s -> %s", final_page.url, final_page.reason)
            message.set(f"Attempt to logon to {final_page.url} failed with {final_page.reason}")
    else:
        logging.error("Unable to contact site %s -> %s", login_page.url, login_page.reason)