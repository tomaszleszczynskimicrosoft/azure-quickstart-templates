@description('Server Name for Azure database for PostgreSQL Flexible Server')
param serverName string

@description('Database administrator login name')
@minLength(1)
param administratorLogin string

@description('Database administrator password')
@minLength(8)
@secure()
param administratorLoginPassword string

@description('Azure database for PostgreSQL pricing tier')
@allowed([
  'Basic'
  'GeneralPurpose'
  'MemoryOptimized'
])
param skuTier string = 'GeneralPurpose'

@description('Azure database for PostgreSQL Flexible Server sku name ')
param skuName string = 'Standard_D2ds_v4'

@description('Azure database for PostgreSQL Flexible Server Storage Size in GB ')
param storageSize int = 32

@description('PostgreSQL version')
@allowed([
  '11'
  '12'
  '13'
  '14'
])
param postgresqlVersion string = '14'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('PostgreSQL Flexible Server backup retention days')
param backupRetentionDays int = 7

@description('Geo-Redundant Backup setting')
@allowed([
  'Disabled'
  'Enabled'
])
param geoRedundantBackup string = 'Disabled'

@description('High Availability Mode')
@allowed([
  'Disabled'
  'ZoneRedundant'
  'SameZone'
])
param haMode string = 'Disabled'

@description('Active Directory Authetication')
@allowed([
  'Disabled'
  'Enabled'
])
param activeDirectoryAuth string = 'Enabled'

@description('Password Authetication')
@allowed([
  'Disabled'
  'Enabled'
])
param passwordAuth string = 'Enabled'

@description('The Object ID of the Azure AD admin.')
param aadAdminObjectid string

@description('Azure AD admin name.')
param aadAdminName string

@description('Azure AD admin Type')
@allowed([
  'User'
  'Group'
  'Application'
])
param aadAdminType string = 'User'

resource server 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  name: serverName
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    createMode: 'Default'
    version: postgresqlVersion
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
	authConfig: {
		activeDirectoryAuth: activeDirectoryAuth
		passwordAuth: passwordAuth
		tenantId: subscription().tenantId
	}
    storage: {
      storageSizeGB: storageSize
    }
	backup: {
		backupRetentionDays: backupRetentionDays
		geoRedundantBackup: geoRedundantBackup
	}
	highAvailability: {
		mode: haMode
	}
  }
}

resource addAddUser 'Microsoft.DBforPostgreSQL/flexibleServers/administrators@2022-12-01' = {
  name: concat(serverName, '/', aadAdminObjectid)
  dependsOn: [
    server
  ]
  properties: {
    tenantId: subscription().tenantId
	principalType: aadAdminType
	principalName: aadAdminName
  }
}