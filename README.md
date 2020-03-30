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

## Configuration Values

Several configuration values must be set for proper confguration of each application. Keys and Values must be set (automatically by deployment or manually after) within each Azure Web App as properties.

### Token Server

| Key | Description | Example |
| ------------- | ------------- | ------------- |
| AccessTokenValidation:Authority | Authority to validate token, <br> base uri of token service | https://your-sts-instance.azurewebsites.net |
| Portal:DefaultUrl | Base URI of Web App | https://your-webapp-instance.azurewebsites.net |
| ApplicationInsights:InstrumentationKey | Instrumentation key of Application Insights | `00000000-0000-0000-0000-000000000000` |
| **Connection Strings** | |
| ConnectionStrings:StsDatabase | Connection to Token Server _MsSQL Database_ | `data source=server.database.windows.net;initial catalog=database;User ID=user@server;Password=***;Trusted_Connection=False;Encrypt=True;Connection Timeout=30` |
| **Directory related configuration** | |
| Directory:ApiBaseUrl | Base URI of Backend API | https://your-api-instance.azurewebsites.net |
| Directory:Links:ConfirmInvitation | Template of invitation confirmation link, <br> points to Web App | https://your-webapp-instance.azurewebsites.net/public/{0}/invitation/{1}?token={2} |
| Directory:Links:ConfirmRegistration | Templat of registration confirmation link, <br> point to Web App | https://your-webapp-instance.azurewebsites.net/public/{0}/register/confirm/{1}?token={2} |
| **Mail Notification configuration** | |
| Notification:Smtp:Credentials:Password | SMTP Password | *** |
| Notification:Smtp:Credentials:Username | SMTP Username | *** |
| Notification:Smtp:EnableSsl | Defines whether to use ssl or not | `true` |
| Notification:Smtp:Host | SMTP Host | smtp.sendgrid.net |
| Notification:Smtp:Port | SMTP Port | 587 |
| **Recaptcha configuration** | |
| Recaptcha:Enabled | Google Recaptcha enabled | `true` |
| Recaptcha:Secret | Secret (private key) of recaptcha | *** |
| **Token Server configuration** | |
| STS:AccessTokenValidation:ApiName| API Name | https://your-sts-instance.azurewebsites.net/resources |
| STS:AccessTokenValidation:ApiSecret| API Secret | *** |
| STS:AccessTokenValidation:Authority| API Authority | https://your-sts-instance.azurewebsites.net |
| STS:AccessTokenValidation:Management:ApiName| Management API Name | aiala.sts |
| STS:AccessTokenValidation:Management:ApiSecret| Management API Secret | *** |
| STS:AccessTokenValidation:Management:Authority| Management API Authority | https://your-sts-instance.azurewebsites.net |
| STS:AccessTokenValidation:SelfManagement:ApiName| Self-management API Name | aiala.portal.api |
| STS:AccessTokenValidation:SelfManagement:ApiSecret| Self-management API Secret | Ach! Hans, Run! It's the Portal API! |
| STS:AccessTokenValidation:SelfManagement:Authority| Self-management API Authority | https://your-sts-instance.azurewebsites.net |
| STS:CertificateThumbprint| Thumbprint of token sign certificate |  |
| STS:IdentityServer:IssuerUri| Issuer of token | https://your-sts-instance.azurewebsites.net |
| STS:ManagementClient:Authority| Management Client Authority | https://your-sts-instance.azurewebsites.net |
| STS:ManagementClient:ClientId| Management Client ID | sts.management |
| STS:ManagementClient:ClientSecret| Management Client Secret | *** |
| STS:RegisterAccountUrl| Template of registration uri, <br> points to Web App | https://your-webapp-instance.azurewebsites.net/public/{culture} |
| STS:ResetPasswordUrl| Template of password reset uri, <br> points to Web App | https://your-webapp-instance.azurewebsites.net/public/{culture}/password-reset |


### Backend API

| Key | Description | Example |
| ------------- | ------------- | ------------- |
| ApplicationInsights:InstrumentationKey | Instrumentation key of Application Insights | `00000000-0000-0000-0000-000000000000` |
| **Mail Notification configuration** | |
| Notification:Smtp:Credentials:Password | SMTP Password | *** |
| Notification:Smtp:Credentials:Username | SMTP Username | *** |
| Notification:Smtp:EnableSsl | Defines whether to use ssl or not | `true` |
| Notification:Smtp:Host | SMTP Host | smtp.sendgrid.net |
| Notification:Smtp:Port | SMTP Port | 587 |
| **Recaptcha configuration** | |
| Recaptcha:Enabled | Google Recaptcha enabled | `true` |
| Recaptcha:Secret | Secret (private key) of recaptcha | *** |
| **Connection Strings** | |
| ConnectionStrings:PortalDatabase | Connection to Portal _MsSQL Database_ | `data source=server.database.windows.net;initial catalog=database;User ID=user@server;Password=***;Trusted_Connection=False;Encrypt=True;Connection Timeout=30` |
| ConnectionStrings:PortalStorage | Connection to Portal _Azure Storage_ | `DefaultEndpointsProtocol=https;AccountName=accountname;AccountKey=***;EndpointSuffix=core.windows.net` |
| **Directory related configuration** | |
| Directory:ApiBaseUrl | Base URI of Backend API | https://your-api-instance.azurewebsites.net |
| Directory:Links:ConfirmInvitation | Template of invitation confirmation link, <br> points to Web App | https://your-webapp-instance.azurewebsites.net/public/{0}/invitation/{1}?token={2} |
| Directory:Links:ConfirmRegistration | Template of registration confirmation link, <br> point to Web App | https://your-webapp-instance.azurewebsites.net/public/{0}/register/confirm/{1}?token={2} |
| Directory:Links:ResetPassword | Template of password reset uri, <br> points to Web App | https://your-webapp-instance.azurewebsites.net/public/{culture}/password-reset |
| **Token Server configuration** | |
| STS:AccessTokenValidation:ApiName| API Name | aiala.portal.api |
| STS:AccessTokenValidation:ApiSecret| API Secret | *** |
| STS:AccessTokenValidation:Authority| API Authority | https://your-sts-instance.azurewebsites.net |
| STS:ManagementClient:Authority| Management Client Authority | https://your-sts-instance.azurewebsites.net |
| STS:ManagementClient:ClientId| Management Client ID | sts.management |
| STS:ManagementClient:ClientSecret| Management Client Secret | *** |
| **Azure Vision** | |
| AzureVision:Key | Azure Vision Access Key | *** |
| AzureVision:TagsConfidenceThreshold | Threshold for tag confidence (optional) | 0.1 |
| AzureVision:CaptionConfidenceThreshold | Threshold for caption confidence (optional) | 0.1 |
| AzureVision:TagBlacklist | Vision tag blacklist | `["indoor","outdoor"]` |

### Frontend Web App

| Key | Description | Example |
| ------------- | ------------- | ------------- |
| ApplicationInsights:InstrumentationKey | Instrumentation key of Application Insights | `00000000-0000-0000-0000-000000000000` |
| AzureClientConfig:DefaultRoute | default to portal web app | /portal/{culture} | 
| AzureClientConfig:RootPath | default root path | wwwroot |
| **Portal Web App configuration** | |
| ClientConfig:portal:api:basePath | Base API URI | https://your-api-instance.azurewebsites.net/api | 
| ClientConfig:portal:authSettings:client_id | Portal Client Id | aiala.webapp |
| ClientConfig:portal:authSettings:post_logout_redirect_uri | Portal after-logout redirect URI | https://your-webapp-instanceazurewebsites.net/portal/{culture} |
| ClientConfig:portal:authSettings:redirect_url | Portal after-login redirect URI | https://your-webapp-instance.azurewebsites.net/portal/{culture} |
| ClientConfig:portal:authSettings:response_type | Requested token types | id_token token | 
| ClientConfig:portal:authSettings:scope | Requested scopes | openid profile directory | 
| ClientConfig:portal:authSettings:stsServer | Token Server URI | https://your-sts-instance.azurewebsites.net"| 
| ClientConfig:portal:external:azureApiKey | Azure api key | *** |
| ClientConfig:portal:external:googleApiKey | google (re-captcha) api key |  *** | 
| ClientConfig:portal:signalR:url | signalr / websocked base URI | https://your-api-instance.azurewebsites.net/hubs |
| **Public Web App configuration** | |
| ClientConfig:public:api:basePath | Base API Uri | https://your-api-instance.azurewebsites.net/api |
| ClientConfig:public:invitation:redirectUrl | Invitation redirect URI template | 
https://ayour-webapp-instance.azurewebsites.net/portal/{culture} |
| ClientConfig:public:registration:redirectUrl | Registration URI template | https://your-webapp-instance.azurewebsites.net/portal/{culture} |
| ClientConfig:public:recaptcha:publicKey | Google recaptcha key (public key) | *** |