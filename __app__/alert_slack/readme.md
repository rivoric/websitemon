# alert_slack

Takes any messages put on the storage account queue and posts them to Slack.

## How it works

Each message in the queue is POSTed to the Slack webhook specified in websiteUrl

## Configuration

The function expects additional configuration to be set within the configuration table in the storage account.
It should have an entity with the following:

```json
{
    "PartitionKey": "websitemon_func",
    "RowKey": "ping",
    "websiteUrl": "https://hooks.slack.com/services/abc/12345678",
    "channel": "slack-channel"
}
```
