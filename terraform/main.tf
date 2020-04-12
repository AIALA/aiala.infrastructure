# Configure the Azure provider
provider "azurerm" {
    version = "~>1.5"
}

resource "azurerm_resource_group" "aiala" {
  name     = "rg-aiala-${var.environment}"
  location = var.location
}

# Blob storage and containers for pictures data
resource "azurerm_storage_account" "aiala" {
  name                     = "aiala${var.app_id}${var.environment}"
  resource_group_name      = azurerm_resource_group.aiala.name
  location                 = var.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "gallery" {
  name                  = "gallery"
  storage_account_name  = azurerm_storage_account.aiala.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "placepictures" {
  name                  = "placepictures"
  storage_account_name  = azurerm_storage_account.aiala.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "profile" {
  name                  = "profile"
  storage_account_name  = azurerm_storage_account.aiala.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "taskpictures" {
  name                  = "taskpictures"
  storage_account_name  = azurerm_storage_account.aiala.name
  container_access_type = "private"
}

# App service plan for app, api and sts app services hosting
resource "azurerm_app_service_plan" "aiala" {
  name                     = "aiala-app-service-plan${var.environment}"
  resource_group_name      = azurerm_resource_group.aiala.name
  location                 = var.location
  kind                     = "App"

  sku {
    tier = "Shared"
    size = "D1"
  }
}

resource "azurerm_app_service" "aiala-api" {
  name                = "aiala-api-${var.app_id}-${var.environment}"
  resource_group_name = azurerm_resource_group.aiala.name
  location            = var.location
  app_service_plan_id = azurerm_app_service_plan.aiala.id

  app_settings = {
    "ApplicationInsights:InstrumentationKey" = azurerm_application_insights.aiala.instrumentation_key
    "Notification:Smtp:Credentials:Password	"= var.db-pwd
    "Notification:Smtp:Credentials:Username" = var.db-login
    "Notification:Smtp:EnableSsl"            = true
    "Notification:Smtp:Host"                 = smtp.sendgrid.net
    "Notification:Smtp:Port"                 = 587
    "Recaptcha:Enabled"                      = true
    "Recaptcha:Secret"                       = var.db-pwd
    "ConnectionStrings:PortalDatabase"       = "data source=${azurerm_sql_database.aiala-portal.name}.database.windows.net;initial catalog=database;User ID=${var.db-login};Password=${var.db-pwd};Trusted_Connection=False;Encrypt=True;Connection Timeout=30"
    "ConnectionStrings:PortalStorage"        = azurerm_storage_account.aiala.secondary_connection_string
    "Directory:ApiBaseUrl"                   = azurerm_app_service.aiala-api.default_site_hostname
    "Directory:Links:ConfirmInvitation"      = "${azurerm_app_service.aiala-app.default_site_hostname}/public/{0}/invitation/{1}?token={2}"
    "Directory:Links:ConfirmRegistration"    = "${azurerm_app_service.aiala-app.default_site_hostname}/public/{0}/register/confirm/{1}?token={2}"
    "Directory:Links:ResetPassword"          = "${azurerm_app_service.aiala-app.default_site_hostname}/public/{culture}/password-reset"
    "STS:AccessTokenValidation:ApiName"      = "aiala.portal.api"
    "STS:AccessTokenValidation:ApiSecret"    = var.db-pwd
    "STS:AccessTokenValidation:Authority"    = azurerm_app_service.aiala-sts.default_site_hostname
    "STS:ManagementClient:Authority"         = azurerm_app_service.aiala-sts.default_site_hostname
    "STS:ManagementClient:ClientId"          = "sts.management"
    "STS:ManagementClient:ClientSecret"      = var.db-pwd
    "AzureVision:Key"                        = azurerm_cognitive_account.aiala.secondary_access_key
    "AzureVision:TagsConfidenceThreshold"    = 0.1
    "AzureVision:CaptionConfidenceThreshold" = 0.1
    "AzureVision:TagBlacklist"               = ["indoor","outdoor"]
  }
}

resource "azurerm_app_service" "aiala-sts" {
  name                = "aiala-sts-${var.app_id}-${var.environment}"
  resource_group_name = azurerm_resource_group.aiala.name
  location            = var.location
  app_service_plan_id = azurerm_app_service_plan.aiala.id

  app_settings = {
    "AccessTokenValidation:Authority"                    = azurerm_app_service.aiala-sts.default_site_hostname
    "Portal:DefaultUrl"                                  = azurerm_app_service.aiala-app.default_site_hostname
    "ApplicationInsights:InstrumentationKey"             = azurerm_application_insights.aiala.instrumentation_key
    "ConnectionStrings:StsDatabase"                      = "data source=${azurerm_sql_database.aiala-sts.name}.database.windows.net;initial catalog=database;User ID=${var.db-login};Password=${var.db-pwd};Trusted_Connection=False;Encrypt=True;Connection Timeout=30"
    "Directory:ApiBaseUrl"                               = azurerm_app_service.aiala-api.default_site_hostname
    "Directory:Links:ConfirmInvitation"                  = "${azurerm_app_service.aiala-api.default_site_hostname}/public/{0}/invitation/{1}?token={2}"
    "Directory:Links:ConfirmRegistration"                = "${azurerm_app_service.aiala-api.default_site_hostname}/public/{0}/register/confirm/{1}?token={2}"
    "Notification:Smtp:Credentials:Password"             = var.db-pwd
    "Notification:Smtp:Credentials:Username"             = var.db-login
    "Notification:Smtp:EnableSsl"                        = true
    "Notification:Smtp:Host"                             = "smtp.sendgrid.net"
    "Notification:Smtp:Port"                             = 587
    "Recaptcha:Enabled"                                  = true
    "Recaptcha:Secret"                                   = var.db-pwd
    "STS:AccessTokenValidation:ApiName"                  = "${azurerm_app_service.aiala-sts.default_site_hostname}/resources"
    "STS:AccessTokenValidation:ApiSecret"	               = var.db-pwd
    "STS:AccessTokenValidation:Authority"                = azurerm_app_service.aiala-sts.default_site_hostname
    "STS:AccessTokenValidation:Management:ApiName"       = "aiala.sts"
    "STS:AccessTokenValidation:Management:ApiSecret"     = var.db-pwd
    "STS:AccessTokenValidation:Management:Authority"     = azurerm_app_service.aiala-sts.default_site_hostname
    "STS:AccessTokenValidation:SelfManagement:ApiName"   = "aiala.portal.api"
    "STS:AccessTokenValidation:SelfManagement:ApiSecret" = "Ach! Hans, Run! It's the Portal API!"
    "STS:AccessTokenValidation:SelfManagement:Authority" = azurerm_app_service.aiala-sts.default_site_hostname
    "STS:CertificateThumbprint"                          = #??
    "STS:IdentityServer:IssuerUri"                       = azurerm_app_service.aiala-sts.default_site_hostname
    "STS:ManagementClient:Authority"                     = azurerm_app_service.aiala-sts.default_site_hostname
    "STS:ManagementClient:ClientId"                      = "sts.management"
    "STS:ManagementClient:ClientSecret"                  = var.db-pwd
    "STS:RegisterAccountUrl"                             = "${azurerm_app_service.aiala-app.default_site_hostname}/public/{culture}"
    "STS:ResetPasswordUrl"                               = "${azurerm_app_service.aiala-app.default_site_hostname}/public/{culture}/password-reset"
  } 
}

resource "azurerm_app_service" "aiala-app" {
  name                = "aiala-app-${var.app_id}-${var.environment}"
  resource_group_name = azurerm_resource_group.aiala.name
  location            = var.location
  app_service_plan_id = azurerm_app_service_plan.aiala.id

  app_settings = {
    "ApplicationInsights:InstrumentationKey" = azurerm_application_insights.aiala.instrumentation_key
    "AzureClientConfig:DefaultRoute"         = "/portal/{culture}"
    "AzureClientConfig:RootPath"             = "wwwroot"
    "ClientConfig:portal:api:basePath"       = "${azurerm_app_service.aiala-api.default_site_hostname}/api"
    "ClientConfig:portal:authSettings:client_id" = "aiala.webapp"
    "ClientConfig:portal:authSettings:post_logout_redirect_uri" = "${azurerm_app_service.aiala-app.default_site_hostname}/portal/{culture}"
    "ClientConfig:portal:authSettings:redirect_url"             = "${azurerm_app_service.aiala-app.default_site_hostname}/portal/{culture}"
    "ClientConfig:portal:authSettings:response_type"            = # id_token token
    "ClientConfig:portal:authSettings:scope"                    = # openid profile directory
    "ClientConfig:portal:authSettings:stsServer"                = azurerm_app_service.aiala-sts.default_site_hostname
    "ClientConfig:portal:external:azureApiKey"                  = var.db-pwd
    "ClientConfig:portal:external:googleApiKey"                 = var.db-pwd
    "ClientConfig:portal:signalR:url"                           = "${azurerm_app_service.aiala-api.default_site_hostname}/hubs"
    "ClientConfig:public:api:basePath"                          = "${azurerm_app_service.aiala-api.default_site_hostname}/api"
    "ClientConfig:public:invitation:redirectUrl"                = "${azurerm_app_service.aiala-app.default_site_hostname}/portal/{culture}"
    "ClientConfig:public:registration:redirectUrl"              = "${azurerm_app_service.aiala-app.default_site_hostname}/portal/{culture}"
    "ClientConfig:public:recaptcha:publicKey"                   = var.db-pwd
  } 
}

resource "azurerm_application_insights" "aiala" {
  name                = "aiala-api-${var.environment}"
  resource_group_name = azurerm_resource_group.aiala.name
  location            = var.location
  application_type    = "web"
}

# SQL servers for the portal and STS databases
resource "azurerm_sql_server" "aiala" {
  name                         = "aiala-sql-${var.app_id}-${var.environment}"
  resource_group_name          = azurerm_resource_group.aiala.name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.db-login
  administrator_login_password = var.db-pwd
}

resource  "azurerm_sql_database" "aiala-portal" {
  name                = "aiala-sql-portal-${var.environment}"
  location            = var.location
  server_name         = azurerm_sql_server.aiala.name
  resource_group_name = azurerm_resource_group.aiala.name
  create_mode         = "Default"
  edition             = "Basic"
}

resource  "azurerm_sql_database" "aiala-sts" {
  name                = "aiala-sql-sts-${var.environment}"
  location            =  var.location
  server_name         =  azurerm_sql_server.aiala.name
  resource_group_name =  azurerm_resource_group.aiala.name
  create_mode         = "Default"
  edition             = "Basic"
}

# Computer vision API
resource "azurerm_cognitive_account" "aiala" {
  name                = "aiala-vision-${var.environment}"
  resource_group_name = azurerm_resource_group.aiala.name
  location            = var.location
  kind                = "ComputerVision"

  sku_name = "F0"
}

# Azure Maps
resource "azurerm_maps_account" "aiala" {
  name                = "aiala-map-${var.environment}"
  resource_group_name = azurerm_resource_group.aiala.name
  sku_name            = "S0"
}
