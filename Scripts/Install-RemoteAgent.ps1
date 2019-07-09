$ErrorActionPreference="Stop";
If(-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent() ).IsInRole( [Security.Principal.WindowsBuiltInRole] “Administrator”))
{ 
    throw "Run command in an administrator PowerShell prompt"
};
If($PSVersionTable.PSVersion -lt (New-Object System.Version("3.0")))
{ 
    throw "The minimum version of Windows PowerShell that is required by the script (3.0) does not match the currently running version of Windows PowerShell." 
};

param(
    [Parameter(Mandatory=$True)]
    [string]$ServerName,
    [Parameter(Mandatory=$True)]
    [string]$EnvName
)

$groupName = "NPS-"+$EnvName;
$agentName = -join($env:COMPUTERNAME, "-", $EnvName);
Write-Host "Installing new Agent named $agentName on server $ServerName assigned to deployment group $groupName";
if(Get-ProceedConfirmation)
{
    Enter-PSSession -ComputerName $ServerName -Credential $UserAcct
    Test-WsMan $ServerName
    # add test of connected session

    If(-NOT (Test-Path $env:SystemDrive\'azagent'))
    {
        # First time to install
        mkdir $env:SystemDrive\'azagent'
    }; 
    cd $env:SystemDrive\'azagent'; 

    $destFolder = $EnvName;
    if(Test-Path ($destFolder))
    {
        # Return error: Agent already installed for this environment
    }
    else 
    {
        mkdir $destFolder;
        cd $destFolder;    
    }

    Write-Host "Downloading Agent ..."
    $agentZip="$PWD\agent.zip";
    $DefaultProxy=[System.Net.WebRequest]::DefaultWebProxy;
    $securityProtocol=@();
    $securityProtocol+=[Net.ServicePointManager]::SecurityProtocol;
    $securityProtocol+=[Net.SecurityProtocolType]::Tls12;
    [Net.ServicePointManager]::SecurityProtocol=$securityProtocol;
    $WebClient=New-Object Net.WebClient; 
    $Uri='https://vstsagentpackage.azureedge.net/agent/2.150.3/vsts-agent-win-x64-2.150.3.zip';

    if($DefaultProxy -and (-not $DefaultProxy.IsBypassed($Uri)))
    {
        $WebClient.Proxy= New-Object Net.WebProxy($DefaultProxy.GetProxy($Uri).OriginalString, $True);
    }; 
    $WebClient.DownloadFile($Uri, $agentZip);
    #Add-Type -AssemblyName System.IO.Compression.FileSystem;
    #[System.IO.Compression.ZipFile]::ExtractToDirectory( $agentZip, "$PWD");

    #.\config.cmd --deploymentgroup --deploymentgroupname $groupName --agent $computerName --runasservice --work '_work' --url 'https://dev.azure.com/npsnatgen/' --projectname 'NPS'; 
    #Remove-Item $agentZip;
}






