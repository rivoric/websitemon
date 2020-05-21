# ping

ping is a simple healthcheck endpoint.
It attempts to do a HTTP ping on the website.
This confirms not only is the function app running but also it can reach the website it is monitoring.

## How it works

Issue a get request to `/api/ping` (eg. https://websitemon.azurewebsites.net/api/ping)
When called is will attempt to load the websiteUrl and return the resulting status code.

## Configuration

The function expects additional configuration to be set within the configuration table in the storage account.
It should have an entity with the following:

```json
{
    "PartitionKey": "websitemon_func",
    "RowKey": "ping",
    "websiteUrl": "https://example.com"
}
```