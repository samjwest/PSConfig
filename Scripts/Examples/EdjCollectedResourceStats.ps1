<#  
.SYNOPSIS 
    Use Elastic Database jobs (EDJ) to easily and reliably manage a large group of Azure SQL Database databases.
    Monitor the performance of many databases using a scheduled job to retrieve CPU, I/O, and memory consumption 
    by periodically executing a DMV, specfically sys.dm_db_resource_stats, across the group of databases and retrieving the UNION ALL result set for analysis.
 
.PREREQUISITES
    1) Azure PowerShell must be installed. For more information, see https://azure.microsoft.com/en-us/documentation/articles/powershell-install-configure/
    2) Elastic Database jobs and PowerShell module must both be installed
       For more information, see https://azure.microsoft.com/en-us/documentation/articles/sql-database-elastic-jobs-service-installation/
    3) Server with target databases as source for query execution must exist
    4) Destination server and database must exist for results collection

.DESCRIPTION 
    This script uses Elastic Database jobs (EDJ) to do the following:
    1) Configure a custom collection containing all databases within a server, except master.
    2) Save a credential to be used when executing the query across all databases within the group.
    3) Create a script within EDJ to be executed across all databases within the group.
    4) Create a database target and credential to be used to store the query results from execution across all databases within the group in a destination table.
    5) Create a job to execute the script across all databases in the group using the specified credential and result set destination configuration.
    6) Create a schedule to run on an interval.
    7) Create a trigger which causes the job to be bound to the schedule.

.PARAMETER destinationServerName 
    Required. This is the name of the destination server to store the results of the performance data retrieved from each database in the group.
 
.PARAMETER destinationDatabaseName 
    Required. This is the name of the destination database to store the results of the performance data retrieved from each database in the group.

.PARAMETER destinationSchemaName 
    Required. This is the name of the destination schmea to store the results of the performance data retrieved from each database in the group.

.PARAMETER destinationTableName 
    Required. This is the name of the destination table to store the results of the performance data retrieved from each database in the group.

.PARAMETER destinationCredentialName 
    Required. This is the name of the credential to use to connect to the destination database.

.PARAMETER serverResourceGroupName 
    Required. This is the name of the resource group containing the source server from which the target databases will be retrieved.

.PARAMETER serverName 
    Required. This is the name of the server to use as the source containing the group of databases for the group.

.PARAMETER jobsResourceGroupName 
    Optional. The name of the Resource Group containing the Elastic Database Jobs compoenents.
    Defaults to "__ElasticDatabaseJobs".

.PARAMETER customCollectionName 
    Optional. This is the name of the custom collection containing the group of databases.
    Defaults to "MyCustomCollection".

.PARAMETER credentialName 
    Optional. This is the name of the custom collection containing the group of databases.
    Defaults to "MyCredential".

.EXAMPLE 
    .\EdjCollectedResourceStats.ps1 `
    -destinationServerName 'samples' `
    -destinationDatabaseName 'resultsdb' `
    -destinationSchemaName 'dbo' `
    -serverResourceGroupName 'samples' `
    -serverName 'samples'

.ADDITIONAL INFORMATION
The GetDatabasesForCustomCollection function can be updated to return a different set of databases, for you needs.
For example, update the GetDatabasesForCustomCollection function to retrieve all databases in a pool using the call Get-AzureSqlElasticPoolDatabase.

Monitor the execution of the script using the following API calls: 
Get-AzureSqlJobExecution -ScheduleName $scheduleName can be used to get active job executions for the schedule.
Get-AzureSqlJobExecution -ScheduleName $scheduleName -IncludeChildren -IncludeInactive can be used to view all resulting job executions across all databases within the group.
Get-AzureSqlJobTaskExecution -JobExecutionId X can be used to view details and error messages of each job execution.

The following can be used to run the job on-demand, wait for completion and print status:
Start-AzureSqlJobExecution -JobName DbResourceStatsCollection | Wait-AzureSqlJobExecution -Verbose
 
.NOTES 
    Authors: Jason Stowe; Debra Dove 
    Last Updated: 08/19/2015
#>

######################################################################################
### Variables
######################################################################################

# This script will prompt for credentials including the jobs control database, target databases for query execution and destination result set database.

param([Parameter(Mandatory=$True)] 
      [ValidateNotNullOrEmpty()] 
      [String]$destinationServerName, 
      [Parameter(Mandatory=$True)]  
      [ValidateNotNullOrEmpty()] 
      [String]$destinationDatabaseName,
      [Parameter(Mandatory=$True)] 
      [ValidateNotNullOrEmpty()] 
      [String]$destinationSchemaName, 
      [Parameter(Mandatory=$True)]  
      [ValidateNotNullOrEmpty()] 
      [String]$serverResourceGroupName,
      [Parameter(Mandatory=$True)]  
      [ValidateNotNullOrEmpty()] 
      [String]$serverName,
      [Parameter(Mandatory=$False)]
      [ValidateNotNullOrEmpty()] 
      [String]$jobsResourceGroupName = "__ElasticDatabaseJobs",
      [Parameter(Mandatory=$False)]  
      [ValidateNotNullOrEmpty()] 
      [String]$destinationTableName = "CollectedResourceStats",
      [Parameter(Mandatory=$False)]  
      [ValidateNotNullOrEmpty()] 
      [String]$destinationCredentialName = "MyDestinationCredential",
      [Parameter(Mandatory=$False)]  
      [ValidateNotNullOrEmpty()] 
      [String]$customCollectionName = "MyCustomCollection",
      [Parameter(Mandatory=$False)]  
      [ValidateNotNullOrEmpty()] 
      [String]$DbResourceStatsCollection = "DbResourceStatsCollection",
      [Parameter(Mandatory=$False)]  
      [ValidateNotNullOrEmpty()] 
      [String]$credentialName = "MyCredential"
      )#end param

# The schedule name and its interval
$scheduleName = "20Minute"
$scheduleMinuteInterval = 20

# The content name and command text. Application specific queries could be used instead to collect 
# application specific results across multiple databases.
$contentName = "Resource stats query"
$commandText = "SELECT DB_NAME() DatabaseName, * FROM sys.dm_db_resource_stats WHERE end_time > DATEADD(mi, -$scheduleMinuteInterval, GETDATE());"

# The job name
$jobName = "DbResourceStatsCollection"

######################################################################################
### Helper functions
######################################################################################

# Log function helper
function Log([Parameter(ValueFromPipeline=$true)]$Message, $LogColor = "Cyan")
{
    Write-Host $Message -ForegroundColor $LogColor
}

# Function to setup the job connection.  If the job connection was previously setup, this function is a no-op.
# If the job connection has not been setup, credentials will be prompted for the job database.
function SetupJobConnection()
{
    try
    {
        # Test to see if the connection has already been setup
        $null = Get-AzureSqlJobCredential
    }
    catch
    {
        if(!$Error[0].Exception.Message.Contains("Use-AzureSqlJobConnection"))
        {
            throw
        }
        # Connection has not yet been set, now set it up
        Log "Please enter the SQL job database credentials when prompted"
        Use-AzureSqlJobConnection -CurrentAzureSubscription -ResourceGroupName $jobsResourceGroupName
    }
}

# Helper function to combine the server and database names together into a key
# that can be used within a hash table
function GetServerDatabaseHashMapKey
{
    param (
        [Parameter(Mandatory=$true)][string]$ServerName,
        [Parameter(Mandatory=$true)][string]$DatabaseName
    )

    return [String]::Format("{0}:{1}", $ServerName, $DatabaseName)
}

# Function to obtain the databases to use within a custom collection
# Currently, this function returns all databases within a server.  The 
# function could be updated to return a different set of databases.
function GetDatabasesForCustomCollection
{
    param (
        [Parameter(Mandatory=$true)][string]$ResourceGroupName,
        [Parameter(Mandatory=$true)][string]$ServerName
    )

    # This function returns all the databases in the server
    # However, this function could be modified to return a different set of databases for your scenario, for example all databases in a pool.
    # For all DBs in a pool, simply replace Get-AzureSqlDatabase with Get-AzureSqlElasticPoolDatabase and 
    # provide the value the -ElasticPoolName parameter in addition to the -ResourceGroupName and -ServerName parameters
    $azureSqlDatabases = @{}
    Log ("Getting the Azure SQL Databases in Azure SQL Server: " + $ServerName)
    foreach($azureSqlDatabase in Get-AzureSqlDatabase -ResourceGroupName $serverResourceGroupName -ServerName $ServerName)
    {
        if($azureSqlDatabase.DatabaseName -ne "master") 
        {
            Log ("Identified Azure SQL Database: " + $azureSqlDatabase.DatabaseName)
            $key = GetServerDatabaseHashMapKey  -ServerName $ServerName `
                                                -DatabaseName $azureSqlDatabase.DatabaseName
            $azureSqlDatabases.add($key, $true)
        }
    } 
    return $azureSqlDatabases
}

# Function to get or create a custom collection.  If the provided custom collection name points to an
# existing custom collection, that will be returned regardless of its contents.
function GetOrCreateCustomCollection()
{
    param (
        [Parameter(Mandatory=$true)][String]$CustomCollectionName
    )

    $customCollection = Get-AzureSqlJobTarget   -CustomCollectionName $CustomCollectionName `
                                                -ErrorAction SilentlyContinue
    if($customCollection)
    {
        return $customCollection;
    }
    return New-AzureSqlJobTarget -CustomCollectionName $CustomCollectionName
}

# Function to get or create a database target given server and database names
function GetOrCreateDatabaseTarget()
{
    param (
        [Parameter(Mandatory=$true)][String]$ServerName,
        [Parameter(Mandatory=$true)][String]$DatabaseName
    )

    $databaseTarget = Get-AzureSqlJobTarget -ServerName $ServerName `
                                            -DatabaseName $DatabaseName `
                                            -ErrorAction SilentlyContinue
    if($databaseTarget)
    {
        return $databaseTarget
    }
    return New-AzureSqlJobTarget    -ServerName $ServerName `
                                    -DatabaseName $DatabaseName
}

# Function to refresh a custom collection.  As a result of this function, the specified custom collection
# will contain and only contain child targets for all the databases within $AzureSqlDatabases.
function RefreshCustomCollection
{
    param (
        [Parameter(Mandatory=$true)][String]$CustomCollectionName,
        [Parameter(Mandatory=$true)][hashtable]$AzureSqlDatabases
    )

    # Get the databases already in the custom collection
    Log "Looking up existing databases in the custom collection then determining mismatches"
    $targetsToRemove = @()
    foreach($existingCollectionTarget in Get-AzureSqlJobTarget -ParentCustomCollectionName $CustomCollectionName)
    {
        $serverDatabaseKey = GetServerDatabaseHashMapKey -ServerName $existingCollectionTarget.ServerName -DatabaseName $existingCollectionTarget.DatabaseName
        if($AzureSqlDatabases.ContainsKey($serverDatabaseKey))
        {
            $AzureSqlDatabases.Remove($serverDatabaseKey)
        }
        else
        {
            $targetsToRemove += $existingCollectionTarget
        }
    }

    # Remove any extra databases that now no longer exist
    foreach($targetToRemove in $targetsToRemove)
    {
        Log ("Removing database from the custom collection: " + $targetToRemove.TargetDescription)
        Remove-AzureSqlJobChildTarget   -CustomCollectionName $CustomCollectionName `
                                        -TargetId $targetToRemove.TargetId
    }

    # Add in any databases that need to exist
    foreach($azureSqlDatabase in $AzureSqlDatabases.Keys)
    {
        $parts = $azureSqlDatabase.Split(":")
        $serverName = $parts[0]
        $databaseName = $parts[1]
    
        Log ("Adding database to the custom collection, Server: " + $serverName + ", Database: " + $databaseName)
        $databaseTarget = GetOrCreateDatabaseTarget -ServerName $serverName `
                                                    -DatabaseName $databaseName
        Add-AzureSqlJobChildTarget  -CustomCollectionName $customCollectionName `
                                    -TargetId $databaseTarget.TargetId
    }
}

# Function to get or create a schedule.  If the schedule already exists, it will be returned
# regardless of its configuration.  
# NOTE: Use Set-AzureSqlJobSchedule to alter a schedule's configuration.
function GetOrCreateSchedule()
{
    param (
        [Parameter(Mandatory=$true)][String]$ScheduleName,
        [Parameter(Mandatory=$true)][int]$MinuteInterval
    )

    $schedule = Get-AzureSqlJobSchedule -ScheduleName $ScheduleName `
                                        -ErrorAction SilentlyContinue
    if($schedule)
    {
        return $schedule
    }
    return New-AzureSqlJobSchedule  -ScheduleName $ScheduleName `
                                    -MinuteInterval $MinuteInterval
}

# Function to get or create a credential.  If the credential already exists, it will be returned
# regardless of its configuration.
# NOTE: Use Set-AzureSqlJobCredential to alter a credential's configuration.
function GetOrCreateCredential()
{
    param (
        [Parameter(Mandatory=$true)][String]$CredentialName,
        [Parameter(Mandatory=$true)][String]$CredentialDescription
    )

    $credential = Get-AzureSqlJobCredential -CredentialName $CredentialName `
                                            -ErrorAction SilentlyContinue
    if($credential)
    {       
        return $credential
    }
    Log "Enter the desired username/password for the $CredentialDescription"
    return New-AzureSqlJobCredential -CredentialName $CredentialName
}

# Function to get or create script content.  If the script content already exists, it will
# be returned regardless of its content definition.
# NOTE: Use Set-AzureSqlJobContentDefinition to alter the definition within content.
function GetOrCreateScriptContent()
{
    param (
        [Parameter(Mandatory=$true)][String]$ContentName,
        [Parameter(Mandatory=$true)][String]$CommandText

    )

    $script = Get-AzureSqlJobContent    -ContentName $ContentName `
                                        -ErrorAction SilentlyContinue
    if($script)
    {       
        return $script
    }
    return New-AzureSqlJobContent   -ContentName $ContentName `
                                    -CommandText $CommandText
}

# Get or create a job.  If the job already exists, it will be returned regardless of its configuration.
# NOTE: Use Set-AzureSqlJob to alter the definition of an existing job.
function GetOrCreateJob()
{
    param (
        [Parameter(Mandatory=$true)][String]$JobName,
        [Parameter(Mandatory=$true)][String]$ResultSetDestinationServerName,
        [Parameter(Mandatory=$true)][String]$ResultSetDestinationDatabaseName,
        [Parameter(Mandatory=$true)][String]$ResultSetDestinationSchemaName,
        [Parameter(Mandatory=$true)][String]$ResultSetDestinationTableName,
        [Parameter(Mandatory=$true)][String]$ResultSetDestinationCredentialName,
        [Parameter(Mandatory=$true)][String]$CredentialName,
        [Parameter(Mandatory=$true)][String]$ContentName,
        [Parameter(Mandatory=$true)][String]$CustomCollectionName
    )

    $job = Get-AzureSqlJob  -JobName $JobName `
                            -ErrorAction SilentlyContinue
    if($job)
    {       
        return $job
    }

    return New-AzureSqlJob  -JobName $JobName `
                            -ResultSetDestinationServerName $ResultSetDestinationServerName `
                            -ResultSetDestinationDatabaseName $ResultSetDestinationDatabaseName `
                            -ResultSetDestinationSchemaName $ResultSetDestinationSchemaName `
                            -ResultSetDestinationTableName $ResultSetDestinationTableName `
                            -ResultSetDestinationCredentialName $ResultSetDestinationCredentialName `
                            -CredentialName $CredentialName `
                            -ContentName $ContentName `
                            -TargetId (Get-AzureSqlJobTarget -CustomCollectionName $CustomCollectionName).TargetId

}

# Gets or creates a trigger.  If a trigger already exists for the provided job name / schedule name, it will
# be returned.
function GetOrCreateTrigger()
{
    param (
        [Parameter(Mandatory=$true)][String]$JobName,
        [Parameter(Mandatory=$true)][String]$ScheduleName
    )

    $trigger = Get-AzureSqlJobTrigger   -JobName $jobName `
                                        -ScheduleName $ScheduleName `
                                        -ErrorAction SilentlyContinue
    if($trigger)
    {
       return $trigger
    }

    return New-AzureSqlJobTrigger   -JobName $JobName `
                                    -ScheduleName $ScheduleName
}


######################################################################################
### Execution starts here
######################################################################################

Set-StrictMode -Version latest 

try 
{ 
    Import-Module ElasticDatabaseJobs -ErrorAction Stop 
} 
catch 
{ 
    Log "[ERROR] The Elastic Database jobs PowerShell module could not be loaded.  Please first invoke the InstallElasticDatabaseJobsCmdlets.ps1 script included in the Elastic Database jobs nuget package.  See https://azure.microsoft.com/en-us/documentation/articles/sql-database-elastic-jobs-service-installation/ for more information" 
    throw
} 

Log "This script will prompt for credentials including the jobs control database, target databases for query execution and destination result set database."
Log "Initialize the connection to the Elastic Database jobs control database"
SetupJobConnection

Log "Get the Azure SQL Databases to target for the custom group of databases"
$azureSqlDatabasesForCollection = GetDatabasesForCustomCollection -ResourceGroupName $serverResourceGroupName `
                                                                  -ServerName $serverName

Log "Get or create the custom collection"
GetOrCreateCustomCollection -CustomCollectionName $customCollectionName

Log "Refresh the collection to contain and only contain the databases currently within the server"
RefreshCustomCollection -CustomCollectionName $customCollectionName `
                        -AzureSqlDatabases $azureSqlDatabasesForCollection

Log "Get or create the credential with appropiate permissions to execute the T-SQL script against the targets"
GetOrCreateCredential   -CredentialName $credentialName `
                        -CredentialDescription "Credentials used to connect to each database for query execution."

Log "Get or create the script content"
GetOrCreateScriptContent    -ContentName $ContentName `
                            -CommandText $CommandText

Log "Get or create the destination database credentials to store the query results"
GetOrCreateCredential   -CredentialName $destinationCredentialName `
                        -CredentialDescription "Credentials used to connect to the destination result set database to insert query results."

Log "Get or create a database target for the result set destination database"
GetOrCreateDatabaseTarget   -ServerName $destinationServerName `
                            -DatabaseName $destinationDatabaseName

Log "Get or create the job"
GetOrCreateJob  -JobName $jobName `
                -ResultSetDestinationServerName $destinationServerName `
                -ResultSetDestinationDatabaseName $destinationDatabaseName `
                -ResultSetDestinationSchemaName $destinationSchemaName `
                -ResultSetDestinationTableName $destinationTableName `
                -ResultSetDestinationCredentialName $destinationCredentialName `
                -CredentialName $credentialName `
                -CustomCollectionName $customCollectionName `
                -ContentName $contentName

Log "Get or create the schedule"
GetOrCreateSchedule -ScheduleName $scheduleName `
                    -MinuteInterval $scheduleMinuteInterval
                    
Log "Get or create the job trigger which binds the job to the schedule"
GetOrCreateTrigger  -JobName $jobName `
                    -ScheduleName $scheduleName

### CLEANUP OBJECTS BY EXECUTING Remove-AzureSqlJobTrigger and Remove-AzureSqlJob ###
# Remove the trigger associating the schedule to the job
# Remove-AzureSqlJobTrigger -JobName DbResourceStatsCollection -ScheduleName $scheduleName

# Remove the job and all job history
# Remove-AzureSqlJob -JobName $jobName