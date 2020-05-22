# Website Monitor scripts

Additional scripts to automate configuration of the function app

## azuredeploy.ps1

PowerShell script to finish off what cannot be achieved with the ARM template.
Connect-AzAccount and Select-AzSubscription should be ran before running the script to ensure connection to the correct Azure subscription.
If ran without an parameters it will prompt for all values.

This script is idempotent so can be ran as often as required.
The user account the script it ran under requires the necessary permissions to the key vault.
The adminKeyvaultObjectId parameter passed into the ARM template can be used for it.
Either pass the Object ID of the AAD user the script is ran under or and the user to an AAD Group and pass that group object ID in.

## configuration.py

Python script to update the configuration tables in the storage account.
A sample config is included called configuration.json