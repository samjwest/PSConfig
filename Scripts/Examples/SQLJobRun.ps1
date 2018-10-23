<# 
.SYNOPSIS 
    Executes SQL query for managing database tasks and logs execution success or failure to App Insights.
 
.DESCRIPTION 
    This runbook is designed to replicate the "SQL Server Agent job" functionality of a SQL Server in Azure SQL.
    A SQL job is used to run database management tasks or other value-added database tasks on a SQL Server database.
    The result, either success or failure, of the execution of this job is logged in Application Insights for future 
    audits. It is recommended that the SQL query executes a pre-programmed database stored procedure for better 
    security and audit.
    
    For this runbook to work, the SQL Server must be accessible from the runbook worker running this runbook. Make sure 
    the SQL Server allows incoming connections from Azure services by selecting 'Allow Windows Azure Services' on the SQL 
    Server configuration page in Azure. 
 
    This runbook also requires an Automation Credential asset be created before the runbook is run, which stores the username 
    and password of an account with access to the SQL Server. That credential should be referenced for the SqlCredential parameter 
    of this runbook.

    Finally, to log to Applications Insights, the Custom Events Module ("ApplicationInsightsCustomEvents.zip") must be imported in 
    the Automation account under the "Modules" pane. The zip file can be found here:
    https://gallery.technet.microsoft.com/scriptcenter/Log-Custom-Events-into-847900d7
 
.PARAMETER SqlServer 
    String name of the SQL Server to connect to 
 
.PARAMETER SqlServerPort 
    Integer port to connect to the SQL Server. Default is 1433

.PARAMETER SqlQueryTimeout 
    Integer seconds to query timeout. Default is 30
 
.PARAMETER Database 
    String name of the SQL Server database to connect to 
 
.PARAMETER SqlQuery 
    String of the query to be executed  
 
.PARAMETER SqlCredentialAsset 
    Name of the Automation PowerShell credential setting from the Automation asset store. 
    This setting stores the username and password for the SQL Azure server   

.PARAMETER InstrumentationKey
    Instrumentation key of application insights account to which logs will be stored
 
.EXAMPLE 
    Use-SqlCommandSample -SqlServer "Server.database.windows.net" -SqlServerPort 1433 -SqlQueryTimeout 600 -Database "DatabaseName" -SqlQuery "Exec StoredProceduerName " -SqlCredentialAsset "AdminLogin" -InstrumentationKey "123-***234"
#> 
param( 
    [parameter(Mandatory=$True)] 
    [string] $SqlServer, 
     
    [parameter(Mandatory=$False)] 
    [int] $SqlServerPort = 1433, 

    [parameter(Mandatory=$False)] 
    [int] $SqlQueryTimeout = 30, 
     
    [parameter(Mandatory=$True)] 
    [string] $Database, 

    [parameter(Mandatory=$True)] 
    [string] $SqlCredentialAsset,

    [parameter(Mandatory=$True)] 
    [string] $SqlQuery,

    [parameter(Mandatory=$False)] 
    [string] $InstrumentationKey
)

#Function to log to Applications Insight
function LogAppInsight ([string]$message) 
{
    $dictionary = New-Object 'System.Collections.Generic.Dictionary[string,string]' 
    $dictionary.Add('Message',"$message") | Out-Null 
    Log-ApplicationInsightsEvent -InstrumentationKey $InstrumentationKey -EventName "Azure Automation" -EventDictionary $dictionary
}

$SqlCredential = Get-AutomationPSCredential -Name $SqlCredentialAsset 

if ($SqlCredential -eq $null) 
{ 
    throw "Could not retrieve '$SqlCredentialAsset' credential asset. Check that you created this first in the Automation service." 
}   
# Get the username and password from the SQL Credential 
$SqlUsername = $SqlCredential.UserName 
$SqlPass = $SqlCredential.GetNetworkCredential().Password 

# Define the connection to the SQL Database 
$Conn = New-Object System.Data.SqlClient.SqlConnection("Server=tcp:$SqlServer,$SqlServerPort;Database=$Database;User ID=$SqlUsername;Password=$SqlPass;Trusted_Connection=False;Encrypt=True;Connection Timeout=30;")

Write-Output "Opening Connection to $SqlServer $Database"


try{
    # Open the SQL connection 
    $Conn.Open() 

    # Define the SQL command to run and timeout
    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand($SqlQuery,$Conn)
    $SqlCmd.CommandTimeout = $SqlQueryTimeout

    # Execute the SQL command and record success or failure

    $result = $SqlCmd.ExecuteNonQuery()
    if ($InstrumentationKey){
        LogAppInsight "$result notifications successfully expired"
    }
    Write-Output "Execution of SQL command Successful: $result"
}catch {
    $ErrorMessage = $_.Exception.Message
    if ($InstrumentationKey){
        LogAppInsight "Failed: $ErrorMessage"
    }
    Write-Output "Execution of SQL command failled: $ErrorMessage"
}

# Close the SQL connection display result
$Conn.Close()