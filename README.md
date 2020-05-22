# Website Monitor

Azure function app written in Python for monitoring a website is functionally working (rather than just up).
It does this by having the following timer functions

* [logon](logon/readme.md) - logs on to the website

There are also the following support functions

* [ping](ping/readme.md) - does a simple get on a page (usually the homepage)
* [alert_slack](alert_slack/readme.md) - responsible for sending any alert failures to a Slack channel

## Getting started

Deploy the ARM template to Azure to create the infrastructure

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Frivoric%2Fwebsitemon%2Fmaster%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Frivoric%2Fwebsitemon%2Fmaster%2Fazuredeploy.json)

Run the [scripts](scripts/readme.md) to complete configuration.

The code can be deployed using VS Code.

## Configuration

Each function gets its configuration from a storage table where the rowkey is the same as the function name.
The readme for each function contains the configuration details.
There is also a [configuration.json](scripts/configuration.json) sample file in which can be used configuration.py script