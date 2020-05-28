# alert_webhook

Takes any messages put on the storage account queue and posts them to any app supporting a webhook that accepts a JSON formatted body.
Common apps would be Slack or Microsoft Teams.

## How it works

Each message placed the queue is POSTed to the webhook specified in websiteUrl
The body will be JSON formatted with a minimum of a `text` field which is the text / body in the queue.
Additional fields can be added in the configuration.

## Configuration

The function expects additional configuration to be set within the configuration table in the storage account.
It should have an entity with the following:

```json
{
    "PartitionKey": "websitemon_func",
    "RowKey": "alert_webhook",
    "websiteUrl": "https://hooks.slack.com/services/abc/12345678",
    "title": "Alert", // optional, specify a title for the message
    "channel": "slack-channel" // optional, specify the (Slack) channel
}
```
