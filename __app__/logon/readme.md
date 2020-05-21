# logon

logon checks the websites logon page is working.
It does this by GETting the websiteUrl and then POSTing the first form back, with the username and password completed.
It is ran on a `TimerTrigger` so will periodically check according to the schedule you set.
You should set the timer in the function.json

## How it works

Provide a schedule in the form of a [cron expression](https://en.wikipedia.org/wiki/Cron#CRON_expression)(See the link for full details).
A cron expression is a string with 6 separate expressions which represent a given schedule via patterns.
The pattern we use to represent every 5 minutes is `0 */5 * * * *`.
This, in plain text, means: "When seconds is equal to 0, minutes is divisible by 5, for any hour, day of the month, month, day of the week, or year".

The GET and POST are done within a session so any cookies and other session data is maintained.
Any form item with a value already set, often hidden, are included in the post value.

If a confirmationElement (CSS selector) is configured it find this element on the page and log the text.
This can be used to manually verify the page is loading correctly.

If a signoutUrl is configured then this URL will be used to sign out.

## Configuration

The function expects additional configuration to be set within the configuration table in the storage account.
It should have an entity with the following:

```json
{
    "PartitionKey": "websitemon_func",
    "RowKey": "ping",
    "websiteUrl": "https://example.com/logon",
    "usernameField": "name of input field used for username",
    "passwordField": "name of input field used for password",
    "signoutUrl": "https://example.com/signOut", // optional
    "confirmationElement": "p#name" // optional
}
```

In addition, it expects `LOGON_USERNAME` and `LOGON_PASSWORD` app settings to contain the username and password to submit.
As these are sensitive, they should be stored in a key vault, see [these details](https://docs.microsoft.com/en-us/azure/app-service/app-service-key-vault-references) for more info.