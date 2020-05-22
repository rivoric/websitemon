<#
.SYNOPSIS
Completes configuration for the Azure function to run

.DESCRIPTION
Script to finish off what cannot be achieved with the ARM template.
Connect-AzAccount and Select-AzSubscription should be ran before running the script.
Will prompt for any parameters missing that do not have a default value.

.PARAMETER ResourceGroupName
Name of the resource group all the resources reside in

.PARAMETER StorageAccountName
Name of the storage account

.PARAMETER KeyVaultName
Name of the key vault where the logon username and password will be stored

.PARAMETER FunctionAppName
Name of the key vault where the logon username and password will be stored

.PARAMETER LogonUsername
Username to log on to the website with; value is stored in the key vault and referenced via an app setting

.PARAMETER LogonPassword
Password to log on to the website with; value is stored in the key vault and referenced via an app setting

.EXAMPLE
$pass = ConvertTo-SecureString -String 'Password' -AsPlainText -Force
azuredeploy -StorageAccountName foostr -KeyVaultName barkv -FunctionAppName webmon -LogonUsername Username -LogonPassword $pass
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string] $ResourceGroupName = $ENV:ResourceGroup,
    [Parameter(Mandatory=$false)]
    [string] $StorageAccountName,
    [Parameter(Mandatory=$false)]
    [string] $QueueName = "alerts",
    [Parameter(Mandatory=$false)]
    [string] $ConfigurationTableName = "configuration",
    [Parameter(Mandatory=$false)]
    [string] $KeyVaultName,
    [Parameter(Mandatory=$false)]
    [string] $FunctionAppName,
    [Parameter(Mandatory=$false)]
    [string] $LogonUsername,
    [Parameter(Mandatory=$false)]
    [SecureString] $LogonPassword,
    [Parameter(Mandatory=$false)]
    [string] $SecretNameUser = "username",
    [Parameter(Mandatory=$false)]
    [string] $SecretNamePass = "password"
)

if (!$ResourceGroupName) {
    $ResourceGroupName = Read-Host -Prompt 'Input name of the resource group all the resources reside in'
}
Write-Verbose "Using resourece group $ResourceGroupName"

if (!$StorageAccountName) {
    $StorageAccountName = Read-Host -Prompt 'Input name of the storage account'
}
Write-Verbose "Using storage account $StorageAccountName"

$stracc = Get-AzStorageAccount -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName
if (!$stracc) {
    throw "No such storage account $StorageAccountName in resource group $ResourceGroupName"
}

$key = $stracc | Get-AzStorageAccountKey | Where-Object {$_.KeyName -eq "key1"}
$context = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $key.Value

if ($null -eq (Get-AzStorageQueue -Context $context -Name $QueueName -ErrorAction SilentlyContinue)) {
    # storage queue does not exist
    Write-Output "Creating storage queue: $QueueName"
    New-AzStorageQueue -Context $context -Queue $QueueName
}
else {
    Write-Verbose "Storage queue $QueueName already exists"
}

if ($null -eq (Get-AzStorageTable -Context $context -Name $ConfigurationTableName -ErrorAction SilentlyContinue)) {
    # storage queue does not exist
    Write-Output "Creating storage table: $ConfigurationTableName"
    New-AzStorageTable -Context $context -Name $ConfigurationTableName
}
else {
    Write-Verbose "Storage table $ConfigurationTableName already exists"
}

if (!$KeyVaultName) {
    $KeyVaultName = Read-Host -Prompt 'Input name of the key vault'
}
Write-Verbose "Using key vault $KeyVaultName"

$kv = Get-AzKeyVault -VaultName $KeyVaultName -ResourceGroupName $ResourceGroupName
if (!$kv) {
    throw "No such key vault $KeyVaultName in resource group $ResourceGroupName"
}

if (!$FunctionAppName) {
    $FunctionAppName = Read-Host -Prompt 'Input name of the function app'
}
Write-Verbose "Checking app settings in $FunctionAppName"

$as = Get-AzWebApp -Name $FunctionAppName -ResourceGroupName $ResourceGroupName
if (!$as) {
    throw "No such function app (app service) $FunctionAppName in resource group $ResourceGroupName"
}

$ashash = @{}
foreach ($appsetting in $as.SiteConfig.AppSettings) {
    $ashash[$appsetting.Name] = $appsetting.Value
}
$updateappsettings = $false

# function to check secret, compare with passed in value and update
function SecretCheck {
    param(
        [parameter (Mandatory=$true)]
        [string] $KeyVaultName,
        [parameter (Mandatory=$true)]
        [string] $SecretName,
        [parameter (Mandatory=$true)]
        [string] $SecretValue,
        [parameter (Mandatory=$true)]
        [hashtable] $AppSettingsHash,
        [parameter (Mandatory=$true)]
        [string] $AppSettingName
    )

    Write-Verbose "Checking secret $SecretName in key vault $KeyVaultName and app $($WebApp.Name)"

    $secret = Get-AzKeyVaultSecret -VaultName $KeyVaultName -SecretName $SecretName
    $updatesecret = $false
    if (!$secret) {
        # secret does not exist, so create it
        Write-Output "Creating secret $SecretName"
        $updatesecret = $true
    }
    else {
        # ensure value is set correctly
        $currentsecret = (Get-AzKeyVaultSecret -VaultName $KeyVaultName -SecretName $SecretName).SecretValueText
        if ($currentsecret -eq $SecretValue) {
            Write-Verbose "Secret $SecretName already set"
        }
        else {
            # secret has changed
            Write-Output "Updating secret $SecretName"
            $updatesecret = $true
        }
    }

    if ($updatesecret) {
        # update the secret in the key vault
        $newsecret = ConvertTo-SecureString -String $SecretValue -AsPlainText -Force
        $secret = Set-AzKeyVaultSecret -VaultName $KeyVaultName -SecretName $SecretName -SecretValue $newsecret
    }

    $secretreference = "@Microsoft.KeyVault(SecretUri=$($secret.Id))"

    if ($AppSettingsHash.ContainsKey($AppSettingName)) {
        # ensure app setting 
        if ($AppSettingsHash[$AppSettingName] -eq $secretreference) {
            Write-Verbose "App setting $AppSettingName set correctly"
            $AppSettingsHash[$AppSettingName] = $secretreference
            $false
        }
        else {
            # update app setting key vault reference
            Write-Output "Updating app setting $AppSettingName"
            $true
        }
    }
    else {
        # app setting does not exist
        Write-Output "Creating app setting $AppSettingName"
        $AppSettingsHash[$AppSettingName] = $secretreference
        $true
    }
}

if (!$LogonUsername) {
    $LogonUsername = Read-Host -Prompt 'Input the username to log on to the website with'
}
$updateappsettings = (SecretCheck -KeyVaultName $kv.VaultName -SecretName $SecretNameUser -SecretValue $LogonUsername -AppSettingsHash $ashash -AppSettingName "LOGON_USERNAME") -or $updateappsettings

if (!$LogonPassword) {
    $plaintextpassword = Read-Host -Prompt 'Input the username to log on to the website with'
}
else {
    # decrypt password
    $plaintextpassword = ConvertFrom-SecureString -SecureString $LogonPassword -AsPlainText
}
$updateappsettings = (SecretCheck -KeyVaultName $kv.VaultName -SecretName $SecretNamePass -SecretValue $plaintextpassword -AppSettingsHash $ashash -AppSettingName "LOGON_PASSWORD") -or $updateappsettings

if ($updateappsettings) {
    # update the reference in the app setting
    Write-Output "Updating App Settings"
    Set-AzWebApp -Name $as.Name -ResourceGroupName $as.ResourceGroup -AppSettings $ashash
}
