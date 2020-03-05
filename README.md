# AIALA infrastructure

This repo provides a Terraform script to deploy AIALA necessary infrasctructure resources in Azure.

## Deployed resources

Running the Terraform script will deploy the resources below in your Azure subscription:
- [x] 1 resource group
- [x] 1 SQL Server
- [x] 2 SQL Databases
- [x] 1 Storage account
- [x] 1 App Service Plan
- [x] 3 App Services  
- [x] 1 App Insights
- [x] 1 Computer Vision API
- [x] 1 Azure Maps API

The [monthly estimated cost](https://azure.com/e/e027e7c1ecb149fb94c336fef32c369b) for the overall solution at *low use* is **$20**.

## Terraform requirements:
- An [Azure](https://azure.microsoft.com/en-us/free/?ref=microsoft.com&utm_source=microsoft.com&utm_medium=docs&utm_campaign=visualstudio) subscription
- Terraform configured with access to Azure
    1. Download [Terraform distribution package](https://www.terraform.io/downloads.html)
    2. Unzip the binary called `terraform`
    3. Update your path to add the path to the Terraform binary
- An Azure service principal 
```
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${SUBSCRIPTION_ID}"
```
- Update your environment variables with your subscription ID, client ID, client secret and tenant ID
``` 
export ARM_SUBSCRIPTION_ID=xxxxxxxx
export ARM_CLIENT_ID=xxxxxxx
export ARM_CLIENT_SECRET=xxxxxxx
export ARM_TENANT_ID=xxxxxxxx 
```
- Verify the installation by executing the `terraform` command in your console. If terraform can't be found, please check your Path environment variable set-up

## Getting started

Update the default variables defined in [variables.tf](./terraform/variables.tf). The storage name has to be unique, that is why an id has to be add to the original name. It should be lower case, without any special characters.

Run the `terraform init` command to fetch the Azure provider's configuration and set-up the Azure storage backend.

Check which Terraform will perform before applying the script by running `terraform plan`.

Apply your plan with : `terraform apply`

You can check in Azure if your resources where correctly deployed. For the next step, get the correct configuration values for the web application and mobile application variables.
