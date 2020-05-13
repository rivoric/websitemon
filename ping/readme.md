# ping

ping is a simple healthcheck endpoint.
It attempts to do a HTTP ping on the website.
This confirms not only is the function app running but also it can reach the website it is monitoring.

## How it works

Issue a get request to `/api/ping` (eg. https://websitemon.azurewebsites.net/api/ping)
When called is will attempt to load the default page from the website and return the resulting status code.
