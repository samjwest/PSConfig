#requires -version 4
#region Documentation

<#
.SYNOPSIS
  <Overview of script>

.DESCRIPTION
  <Brief description of script>

.PARAMETER <Parameter_Name>
  <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
  <Inputs if any, otherwise state None>

.OUTPUTS Log File
  The script log file stored in C:\Windows\Temp\<name>.log

.NOTES
  Version:        1.0
  Author:         <Name>
  Creation Date:  <Date>
  Purpose/Change: Initial script development

.EXAMPLE
  <Example explanation goes here>
  
  <Example goes here. Repeat this attribute for more than one example>

.CREDIT
  Original PowerShell Script Template v2 by Luca Sturlese
  https://9to5it.com/powershell-script-template-version-2/
#>
#endregion

#region Parameters

Param (
  #Script parameters go here
)
#endregion

#region Initialisations

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

#Import Modules & Snap-ins
Import-Module PSLogging
#endregion

#region Declarations

#Script Version
$sScriptVersion = '1.0'

#Log File Info
$sLogPath = 'C:\Windows\Temp'
$sLogName = '<script_name>.log'
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName
#endregion

#region Functions

function Install-RemoteAgent
{
  param(
    # [Parameter(Mandatory=$True)]
    # [string]$Type,
    
    [Parameter(Mandatory=$True)]
    [string]$ServerNames,
    [int]$EnvNum = -1
    [switch]$Build,
    [switch]$Sql
  )

  if(-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent() ).IsInRole( [Security.Principal.WindowsBuiltInRole]'Administrator'))
  { 
      throw "Run command in an administrator PowerShell prompt"
  };
  if($PSVersionTable.PSVersion -lt (New-Object System.Version("3.0")))
  { 
      throw "The minimum version of Windows PowerShell that is required by the script (3.0) does not match the currently running version of Windows PowerShell." 
  };

  Write-LogInfo -LogPath $sLogFile -Message '<description of what is going on>...'

  if($Build -eq $True)
  {
    Install-RemoteBuildAgent -ServerNames $ServerNames
  }
  else 
  {
    Install-RemoteDeploymentAgent -ServerNames $ServerNames $EnvNum $Sql
  }

}

function Install-RemoteDeploymentAgent
{
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline)]
        [string]$ServerNames,
        # [Parameter(Mandatory=$True,
        # HelpMessage = "Enter either 'Dev', 'UT', 'RC', 'Stage', or 'Prod'")]        
        # [ValidateSet('Dev','UT','RC','Stage','Prod')]        
        [int]$EnvNum = -1
    )

    #$ErrorActionPreference="Stop";

    while ($EnvNum -notmatch "^[0-4]$"){
        Write-Host "================ Environment ================"
        Write-Host "0: Development" 
        Write-Host "1: UT"
        Write-Host "2: RC"
        Write-Host "3: Staging"
        Write-Host "4: Production"
        $EnvNum = Read-Host "What Environment?"
    }

    $EnvAbbrev
    switch ($EnvNum)
    {
        0 { $groupName = 'Development'; $EnvAbbrev = 'DV'; $acctName = 'NGIC\ServTFS'; $acctPass = '5up3Rm@n2!' }
        1 { $groupName = 'UserTest'; $EnvAbbrev = 'UT'; $acctName = 'NGIC\ServAzureSQLUT'; $acctPass = 'xl2rRQpr(Zj%z8' }
        2 { $groupName = 'ReleaseCandidate'; $EnvAbbrev = 'RC'; $acctName = 'NGIC\ServAzureSQLRC'; $acctPass = 'D#*U$~Tn+ws/V7' }
        3 { $groupName = 'Staging'; $EnvAbbrev = 'ST'; $acctName = ''; $acctPass = '' }
        4 { $groupName = 'NPS-Production'; $EnvAbbrev = 'PR'; $acctName = ''; $acctPass = '' }
    }

    #$servers = $ServerNames -split "`n" | ? {-not [string]::IsNullOrWhiteSpace($_)}
    $servers = $ServerNames -split "," | ? {-not [string]::IsNullOrWhiteSpace($_)}
    Write-Host ""

    #$groupName = "UserTest"; #+$EnvName;
    $agentName = -join($ServerName, "-", $EnvAbbrev);     #$env:COMPUTERNAME
    
    #SvcAcct-UT.xml   ServiceAcct.xml

    $cred = Get-MyCredential(Join-Path($PSScriptRoot) '\ServiceAcct.xml')
    #Write-Host "Installing new Agent named $agentName on server $ServerName assigned to deployment group $groupName";
    if(Get-ProceedConfirmation "Azure deployment agents will be installed on $servers")
    {
        
        foreach($server in $servers)
        {   
            try 
            {   
                $step = 1                                  
                $agentName = -join($server, "-", $EnvAbbrev);
                $session = $null;

                Write-Host "Installing new Agent named $agentName on server $server assigned to deployment group $groupName";
                Write-Host "    Opening Session" -NoNewline
                $session = New-PSSession -ComputerName $server.Trim() -Credential $cred -ErrorAction Stop                
                #-Auth CredSSP 
                Write-Host "> Preparing Directory" -NoNewline
                $step++
                $testRootBlock = [scriptblock]::Create("{ If(-NOT (Test-Path c:\azagent)){ mkdir c:\azagent } }")
                $exitcode = Invoke-Command -ScriptBlock $testRootBlock -Session $session -ErrorAction Stop


                $exitcode = Invoke-Command -ScriptBlock { If(-NOT (Test-Path c:\azagent\$args)){ mkdir -Path c:\azagent\$args} } -ArgumentList $EnvAbbrev -Session $session -ErrorAction Stop
                $exitcode = Invoke-Command -ScriptBlock { c:; Set-Location \azagent\$args } -ArgumentList $EnvAbbrev -Session $session -ErrorAction Stop

                Write-Host "> Downloading Agent" -NoNewline
                $step++
                # Set security to TLS1.2
                Invoke-Command -ScriptBlock {$securityProtocol=@(); $securityProtocol+=[Net.ServicePointManager]::SecurityProtocol; $securityProtocol+=[Net.SecurityProtocolType]::Tls12; [Net.ServicePointManager]::SecurityProtocol=$securityProtocol;} -Session $session        
                
                # Not Used-----------------------------
                # $netCred = $cred.GetNetworkCredential();
                # #$Credentials = $args; # New-Object Net.NetworkCredential("user","domain.local"); 
                # $Credentials = $netCred.GetCredential("proxy01.gmacinsurance.com","8080","KERBEROS");
                # $WebProxy = New-Object Net.WebProxy("proxy01.gmacinsurance.com:8080",$true); 
                # $WebProxy.Credentials = $Credentials;
                # -------------------------------------

                # Set the proxy and download the agent zip file
                $webDownloadBlock =
                {
                    $agentZip="$PWD\agent.zip";
                    $Uri='https://vstsagentpackage.azureedge.net/agent/2.150.3/vsts-agent-win-x64-2.150.3.zip';
                    #$Credentials = New-Object Net.NetworkCredential("user","domain.local"); 
                    $Credentials = New-Object Net.NetworkCredential("P222408","Life.cpp5", "NGIC"); 
                    $Credentials = $Credentials.GetCredential("proxy01.gmacinsurance.com","8080","KERBEROS");
                    $WebProxy = New-Object Net.WebProxy("proxy01.gmacinsurance.com:8080",$true); 
                    $WebProxy.Credentials = $Credentials;
                    $WebClient = New-Object Net.WebClient;
                    #$webclient.UseDefaultCredentials=$true; 
                    $WebClient.Proxy = $WebProxy;
                    $WebClient.DownloadFile($Uri, $agentZip);
                }
                Invoke-Command -ScriptBlock $webDownloadBlock -Session $session -ErrorAction Stop #-ArgumentList $WebProxy
                
                Write-Host "> Configuring Agent" -NoNewline
                $step++
                # Extract the files
                $extractBlock =
                {
                    $agentZip="$PWD\agent.zip";
                    Add-Type -AssemblyName System.IO.Compression.FileSystem;
                    [System.IO.Compression.ZipFile]::ExtractToDirectory( $agentZip, "$PWD");            
                }
                Invoke-Command -ScriptBlock $extractBlock -Session $session -ErrorAction Stop

                $configBlock =
                {
                    $groupName = $args[0]
                    $agentName = $args[1]
                    $accountName = $args[2]
                    $accountPass = $args[3]
                    .\config.cmd --deploymentgroup --deploymentgroupname $groupName --agent $agentName --runasservice --url 'https://dev.azure.com/npsnatgen/' --projectname 'NPS' --unattended --auth pat --token nyod5clci3mqdj72rqe2xpixkl3ty6ba5fiw52ntvp66te4i2tdq --proxyurl http://proxy01.gmacinsurance.com:8080 --proxyusername $accountName --proxypassword $accountPass         
                }
                Invoke-Command -ScriptBlock $configBlock -ArgumentList $groupName, $agentName, $acctName, $acctPass -Session $session -ErrorAction Stop             
                #--windowsLogonAccount $accountName --windowsLogonPassword $accountPass 
            }
            catch 
            {
                Write-Host " !Exception"
                #Write-Error -Exception $_.Exception
                Write-Error -Message $_.Exception.Message
                # if($step -lt 4)
                # {
                #     Write-Host "Reverting Changes..."
                #     $testRevertBlock = [scriptblock]::Create("{ If(Test-Path c:\azagent\$args){ rm c:\azagent\$args } }")                    
                #     $exitcode = Invoke-Command -ScriptBlock $testRootBlock -ArgumentList $EnvAbbrev -Session $session -ErrorAction Continue
                # }
                continue
            }
            finally
            {
                Write-Host "> Closing Session" 
                Remove-PSSession -Session $session
            }
            # catch
            # { 
            #     Write-Host " !Exception"
            #     Write-Error -Message "Unable to establish connection with server"
            #     continue
            # }
            # catch[System.IO.Exception]
            # { 
            #     Write-Host " !Folder Exists"
            #     Write-Error -Message "Agent folder already exists for $EnvAbbrev"
            #     continue
            # }
        }
    }
}

function Install-RemoteBuildAgent
{

}

<#

Function <FunctionName> {
  Param ()

  Begin {
    Write-LogInfo -LogPath $sLogFile -Message '<description of what is going on>...'
  }

  Process {
    Try {
      <code goes here>
    }

    Catch {
      Write-LogError -LogPath $sLogFile -Message $_.Exception -ExitGracefully
      Break
    }
  }

  End {
    If ($?) {
      Write-LogInfo -LogPath $sLogFile -Message 'Completed Successfully.'
      Write-LogInfo -LogPath $sLogFile -Message ' '
    }
  }
}

#>
#endregion

#region Execution

Start-Log -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
#Script Execution goes here
Stop-Log -LogPath $sLogFile

#endregion