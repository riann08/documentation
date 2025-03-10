#!/bin/sh
# Make sure you replace the <DD_API_KEY> and <DD_APP_KEY> key below
# with the ones for your account

api_key=<DD_API_KEY>
app_key=<DD_APP_KEY>

curl -X POST -H "Content-type: application/json" \
-d '{
        "tenant_name": "<AZURE_TENANT_NAME>",
        "client_id": "<AZURE_CLIENT_ID>",
        "client_secret": "<AZURE_CLIENT_SECRET>",
        "host_filters": "<KEY_1>:<VALUE_1>,<KEY_2>:<VALUE_2>"
    }' \
"https://api.datadoghq.com/api/v1/integration/azure/host_filters?api_key=${api_key}&application_key=${app_key}"
