
function Install-RemoteAgent
{
  param(
    # [Parameter(Mandatory=$True)]
    # [string]$Type,
    
    [Parameter(Mandatory=$True)]
    [string]$ServerNames,
    [int]$EnvNum = -1,
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


  if($Build -eq $True)
  {
    Install-RemoteBuildAgent -ServerNames $ServerNames
  }
  else 
  {
      if($Sql -eq $True)
      {
        Install-RemoteDeploymentAgent -ServerNames $ServerNames $EnvNum -Sql      
      }
      else
      {
        Install-RemoteDeploymentAgent -ServerNames $ServerNames $EnvNum 
      }    
  }
}

function Install-RemoteBuildAgent
{
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline)]
        [string]$ServerNames,
        # [Parameter(Mandatory=$True,
        # HelpMessage = "Enter either 'Dev', 'UT', 'RC', 'Stage', or 'Prod'")]        
        # [ValidateSet('Dev','UT','RC','Stage','Prod')]           
        [string]$PoolName = 'On-Prem Windows',                     
        [string]$AgentSuffix = 'Agent1'
    )

    #$ErrorActionPreference="Stop";
    If(-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent() ).IsInRole( [Security.Principal.WindowsBuiltInRole]'Administrator'))
    { 
        throw "Run command in an administrator PowerShell prompt"
    };
    If($PSVersionTable.PSVersion -lt (New-Object System.Version("3.0")))
    { 
        throw "The minimum version of Windows PowerShell that is required by the script (3.0) does not match the currently running version of Windows PowerShell." 
    };

    $acctName = 'NGIC\ServTFS'; $acctPass = '5up3Rm@n2!'



    #$servers = $ServerNames -split "`n" | ? {-not [string]::IsNullOrWhiteSpace($_)}
    $servers = $ServerNames -split "," | ? {-not [string]::IsNullOrWhiteSpace($_)}
    Write-Host ""


    #SvcAcct-UT.xml   ServiceAcct.xml

    $cred = Get-MyCredential(Join-Path($PSScriptRoot) '\ServiceAcct.xml')
    #Write-Host "Installing new Agent named $agentName on server $ServerName assigned to deployment group $groupName";
    if(Get-ProceedConfirmation "Azure build agents will be installed on $servers")
    {
        
        foreach($server in $servers)
        {   
            try 
            {   
                $step = 1                                  
                $agentName = -join($server, "-", $AgentSuffix);
                $session = $null;

                Write-Host "Installing new Agent named $agentName on server $server";
                Write-Host "    Opening Session" -NoNewline
                $session = New-PSSession -ComputerName $server.Trim() -Credential $cred -ErrorAction Stop                
                #-Auth CredSSP 
                Write-Host "> Preparing Directory" -NoNewline
                $step++
                $testRootBlock = [scriptblock]::Create("{ If(-NOT (Test-Path e:\Agents)){ mkdir e:\Agents } }")
                $exitcode = Invoke-Command -ScriptBlock $testRootBlock -Session $session -ErrorAction Stop


                $exitcode = Invoke-Command -ScriptBlock { If(-NOT (Test-Path e:\Agents\$args)){ mkdir -Path e:\Agents\$args} } -ArgumentList $AgentSuffix -Session $session -ErrorAction Stop
                $exitcode = Invoke-Command -ScriptBlock { e:; Set-Location \Agents\$args } -ArgumentList $AgentSuffix -Session $session -ErrorAction Stop

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
                    $pool = $args[0]
                    $agentName = $args[1]
                    $accountName = $args[2]
                    $accountPass = $args[3]
                    .\config.cmd --agent $agentName --pool $pool --replace --runasservice --url 'https://dev.azure.com/npsnatgen/' --projectname 'NPS' --unattended --auth pat --token nyod5clci3mqdj72rqe2xpixkl3ty6ba5fiw52ntvp66te4i2tdq --windowsLogonAccount $accountName --windowsLogonPassword $accountPass --proxyurl http://proxy01.gmacinsurance.com:8080 --proxyusername $accountName --proxypassword $accountPass 
                }
                Invoke-Command -ScriptBlock $configBlock -ArgumentList $PoolName, $agentName, $acctName, $acctPass -Session $session -ErrorAction Stop             
                #--windowsLogonAccount $accountName --windowsLogonPassword $accountPass 
                #--proxyurl http://proxy01.gmacinsurance.com:8080 --proxyusername $accountName --proxypassword $accountPass 
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


function Install-RemoteDeploymentAgent      #Install-RemoteAgent
{
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline)]
        [string]$ServerNames,
        # [Parameter(Mandatory=$True,
        # HelpMessage = "Enter either 'Dev', 'UT', 'RC', 'Stage', or 'Prod'")]        
        # [ValidateSet('Dev','UT','RC','Stage','Prod')]        
        [Parameter(Mandatory=$False,ValueFromPipeline)]
        [int]$EnvNum = -1,
        [Parameter(Mandatory=$False,ValueFromPipeline)]
        [switch]$Sql
    )

    while ($EnvNum -notmatch "^[0-5]$"){
        Write-Host "================ Environment ================"
        Write-Host "0: Development" 
        Write-Host "1: UT"
        Write-Host "2: RC"
        Write-Host "3: Staging"
        Write-Host "4: Production"
        Write-Host "5: LiveDebug"
        $EnvNum = Read-Host "What Environment?"
    }

    $EnvAbbrev
    switch ($EnvNum)
    {
        0 { $groupName = 'Development'; $EnvAbbrev = 'DV'; $acctName = 'NGIC\ServTFS'; $acctPass = '5up3Rm@n2!' }
        1 { $groupName = 'UserTest'; $EnvAbbrev = 'UT'; $acctName = 'NGIC\ServTFS'; $acctPass = '5up3Rm@n2!' }
        2 { $groupName = 'ReleaseCandidate'; $EnvAbbrev = 'RC'; $acctName = 'NGIC\ServTFS'; $acctPass = '5up3Rm@n2!' }
        3 { $groupName = 'Staging'; $EnvAbbrev = 'ST'; $acctName = 'NGIC\ServTFS'; $acctPass = '5up3Rm@n2!' }
        4 { $groupName = 'NPS-Production'; $EnvAbbrev = 'PR'; $acctName = ''; $acctPass = '' }
        5 { $groupName = 'LiveDebug'; $EnvAbbrev = 'LD'; $acctName = ''; $acctPass = '' }
    }

    #$acctName = 'NGIC\ServAzureSQLRC'; $acctPass = 'D#*U$~Tn+ws/V7'
    #$servers = $ServerNames -split "`n" | ? {-not [string]::IsNullOrWhiteSpace($_)}
    $servers = $ServerNames -split "," | ? {-not [string]::IsNullOrWhiteSpace($_)}
    Write-Host ""
    
    $agentName = -join($ServerName, "-", $EnvAbbrev);     #$env:COMPUTERNAME
    
    $credFile = '\ServiceAcct.xml'
    if($Sql -eq $True)
    {
        $credFile = -join('\SrvAcct-', $EnvAbbrev, '.xml')
        $groupName = -join($groupName, '-SQL')
    }

    $cred = Get-MyCredential(Join-Path($PSScriptRoot) $credFile)  
    # '\SvcAcct-RC.xml')
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
                    $Uri='https://vstsagentpackage.azureedge.net/agent/2.153.2/vsts-agent-win-x64-2.153.2.zip';
                    #$Credentials = New-Object Net.NetworkCredential("user","domain.local"); 
                    $Credentials = New-Object Net.NetworkCredential("P222408","Life.cpp5", "NGIC"); 
                    $Credentials = $Credentials.GetCredential("proxy01.gmacinsurance.com","8080","KERBEROS");
                    $WebProxy = New-Object Net.WebProxy("proxy01.gmacinsurance.com:8080",$true); 
                    $WebProxy.Credentials = $Credentials;
                    $WebClient = New-Object Net.WebClient;                    
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
                    .\config.cmd --deploymentgroup --deploymentgroupname $groupName --agent $agentName --runasservice --url 'https://dev.azure.com/npsnatgen/' --projectname 'NPS' --unattended --auth pat --token nyod5clci3mqdj72rqe2xpixkl3ty6ba5fiw52ntvp66te4i2tdq --proxyurl http://proxy01.gmacinsurance.com:8080         
                }
                Invoke-Command -ScriptBlock $configBlock -ArgumentList $groupName, $agentName, $acctName, $acctPass -Session $session -ErrorAction Stop             
                #--windowsLogonAccount $accountName --windowsLogonPassword $accountPass 
                #--proxyusername $accountName --proxypassword $accountPass 
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
        }
    }
}

function Remove-RemoteAgent
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
    If(-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent() ).IsInRole( [Security.Principal.WindowsBuiltInRole]'Administrator'))
    { 
        throw "Run command in an administrator PowerShell prompt"
    };
    If($PSVersionTable.PSVersion -lt (New-Object System.Version("3.0")))
    { 
        throw "The minimum version of Windows PowerShell that is required by the script (3.0) does not match the currently running version of Windows PowerShell." 
    };

    while ($EnvNum -notmatch "^[0-5]$"){
        Write-Host "================ Environment ================"
        Write-Host "0: Development" 
        Write-Host "1: UT"
        Write-Host "2: RC"
        Write-Host "3: Staging"
        Write-Host "4: Production"
        Write-Host "5: LiveDebug"
        $EnvNum = Read-Host "What Environment?"
    }

    $EnvAbbrev
    switch ($EnvNum)
    {
        0 { $groupName = 'Development'; $EnvAbbrev = 'DV'; $acctName = ''; $acctPass = '' }
        1 { $groupName = 'UserTest'; $EnvAbbrev = 'UT'; $acctName = 'NGIC\ServTFS'; $acctPass = '5up3Rm@n2!' }
        2 { $groupName = 'ReleaseCandidate'; $EnvAbbrev = 'RC'; $acctName = ''; $acctPass = '' }
        3 { $groupName = 'Staging'; $EnvAbbrev = 'ST'; $acctName = ''; $acctPass = '' }
        4 { $groupName = 'Production'; $EnvAbbrev = 'PR'; $acctName = ''; $acctPass = '' }
        5 { $groupName = 'LiveDebug'; $EnvAbbrev = 'PR'; $acctName = ''; $acctPass = '' }
    }

    #$servers = $ServerNames -split "`n" | ? {-not [string]::IsNullOrWhiteSpace($_)}
    $servers = $ServerNames -split "," | ? {-not [string]::IsNullOrWhiteSpace($_)}
    Write-Host ""

    #$groupName = "UserTest"; #+$EnvName;
    $agentName = -join($ServerName, "-", $EnvAbbrev);     #$env:COMPUTERNAME
    
    $cred = Get-MyCredential(Join-Path($PSScriptRoot) '\ServiceAcct.xml')
    #Write-Host "Installing new Agent named $agentName on server $ServerName assigned to deployment group $groupName";
    if(Get-ProceedConfirmation "Azure build agents will be removed from $servers")
    {
        
        foreach($server in $servers)
        {   
            try 
            {   
                $step = 1                                  
                $agentName = -join($server, "-", $EnvAbbrev);
                $session = $null;

                Write-Host "UnInstalling Agent named $agentName on server $server assigned to deployment group $groupName";
                Write-Host "    Opening Session" -NoNewline
                $session = New-PSSession -ComputerName $server.Trim() -Credential $cred -ErrorAction Stop


                Write-Host "> Preparing Directory" -NoNewline
                $step++

                $exitcode = Invoke-Command -ScriptBlock { If(Test-Path c:\azagent\$args){ c:; Set-Location \azagent\$args } } -ArgumentList $EnvAbbrev -Session $session -ErrorAction Stop
                #$exitcode = Invoke-Command -ScriptBlock { c:; Set-Location \azagent\$args } -ArgumentList $EnvAbbrev -Session $session -ErrorAction Stop

                Write-Host "> Removing Agent Configuration" -NoNewline
                $step++
                $removeBlock =
                {
                    $groupName = $args[0]
                    $agentName = $args[1]
                    $accountName = $args[2]
                    $accountPass = $args[3]
                    .\config.cmd remove --unattended --auth pat --token nyod5clci3mqdj72rqe2xpixkl3ty6ba5fiw52ntvp66te4i2tdq
                }
                Invoke-Command -ScriptBlock $removeBlock -ArgumentList $groupName, $agentName, $acctName, $acctPass -Session $session -ErrorAction Stop             

                Write-Host "> Deleting Agent" -NoNewline
                $step++
        

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

function Config-RemoteAgent
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
    If(-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent() ).IsInRole( [Security.Principal.WindowsBuiltInRole]'Administrator'))
    { 
        throw "Run command in an administrator PowerShell prompt"
    };
    If($PSVersionTable.PSVersion -lt (New-Object System.Version("3.0")))
    { 
        throw "The minimum version of Windows PowerShell that is required by the script (3.0) does not match the currently running version of Windows PowerShell." 
    };

    while ($EnvNum -notmatch "^[0-5]$"){
        Write-Host "================ Environment ================"
        Write-Host "0: Development" 
        Write-Host "1: UT"
        Write-Host "2: RC"
        Write-Host "3: Staging"
        Write-Host "4: Production"
        Write-Host "5: LiveDebug"
        $EnvNum = Read-Host "What Environment?"
    }

    $EnvAbbrev
    switch ($EnvNum)
    {
        0 { $groupName = 'Development'; $EnvAbbrev = 'DV'; $acctName = ''; $acctPass = '' }
        1 { $groupName = 'UserTest'; $EnvAbbrev = 'UT'; $acctName = 'NGIC\ServTFS'; $acctPass = '5up3Rm@n2!' }
        2 { $groupName = 'ReleaseCandidate'; $EnvAbbrev = 'RC'; $acctName = ''; $acctPass = '' }
        3 { $groupName = 'Staging'; $EnvAbbrev = 'ST'; $acctName = ''; $acctPass = '' }
        4 { $groupName = 'Production'; $EnvAbbrev = 'PR'; $acctName = ''; $acctPass = '' }
        5 { $groupName = 'LiveDebug'; $EnvAbbrev = 'PR'; $acctName = ''; $acctPass = '' }
    }

    #$servers = $ServerNames -split "`n" | ? {-not [string]::IsNullOrWhiteSpace($_)}
    $servers = $ServerNames -split "," | ? {-not [string]::IsNullOrWhiteSpace($_)}
    Write-Host ""

    #$groupName = "UserTest"; #+$EnvName;
    $agentName = -join($ServerName, "-", $EnvAbbrev);     #$env:COMPUTERNAME
    
    $cred = Get-MyCredential(Join-Path($PSScriptRoot) '\ServiceAcct.xml')
    #Write-Host "Installing new Agent named $agentName on server $ServerName assigned to deployment group $groupName";
    if(Get-ProceedConfirmation "Azure build agents will be reconfigured on $servers")
    {
        
        foreach($server in $servers)
        {   
            try 
            {   
                $step = 1                                  
                $agentName = -join($server, "-", $EnvAbbrev);
                $session = $null;

                Write-Host "Configuring Agent named $agentName on server $server assigned to deployment group $groupName";
                Write-Host "    Opening Session" -NoNewline
                $session = New-PSSession -ComputerName $server.Trim() -Credential $cred -ErrorAction Stop

                $exitcode = Invoke-Command -ScriptBlock { c:; Set-Location \azagent\$args } -ArgumentList $EnvAbbrev -Session $session -ErrorAction Stop

                Write-Host "> Removing Agent" -NoNewline  
                $removeBlock =
                {
                    $groupName = $args[0]
                    $agentName = $args[1]
                    $accountName = $args[2]
                    $accountPass = $args[3]
                    .\config.cmd remove --unattended --auth pat --token nyod5clci3mqdj72rqe2xpixkl3ty6ba5fiw52ntvp66te4i2tdq
                }
                Invoke-Command -ScriptBlock $removeBlock -ArgumentList $groupName, $agentName, $acctName, $acctPass -Session $session -ErrorAction Stop             

                Write-Host "> Configuring Agent" -NoNewline                
                
                $configBlock =
                {
                    $groupName = $args[0]
                    $agentName = $args[1]
                    $accountName = $args[2]
                    $accountPass = $args[3]
                    .\config.cmd --deploymentgroup --deploymentgroupname $groupName --agent $agentName --runasservice --windowsLogonAccount $accountName --windowsLogonPassword $accountPass --url 'https://dev.azure.com/npsnatgen/' --projectname 'NPS' --unattended --auth pat --token nyod5clci3mqdj72rqe2xpixkl3ty6ba5fiw52ntvp66te4i2tdq --proxyurl http://proxy01.gmacinsurance.com:8080 --proxyusername $accountName --proxypassword $accountPass
                }
                Invoke-Command -ScriptBlock $configBlock -ArgumentList $groupName, $agentName, $acctName, $acctPass -Session $session -ErrorAction Stop             

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
        }
    }
}



