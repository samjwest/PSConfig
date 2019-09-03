function Get-NGICAppPools 
{
    param (
        [Parameter(Mandatory=$True)]
        [string]$ComputerName
    )

    invoke-command -computername $ComputerName -scriptblock {(Get-IISAppPool).Name}
}

function Get-NGICAppPoolInfo 
{
    param (
        [Parameter(Mandatory=$True)]
        [string]$ComputerName,
        [Parameter(Mandatory=$True)]
        [string]$PoolName        
    )

    invoke-command -computername $ComputerName -scriptblock {Get-IISAppPool $PoolName} -Credential $cred
}

function Get-NGICAppPoolState
{
    param (
        [Parameter(Mandatory=$True)]
        [string]$ComputerName,
        [Parameter(Mandatory=$True)]
        [string]$PoolName        
    )

    invoke-command -computername $ComputerName -scriptblock {Get-WebAppPoolState $PoolName}
}

function Recycle-NGICAppPool
{
    param (
        [Parameter(Mandatory=$True)]
        [string]$ComputerName,
        [Parameter(Mandatory=$True)]
        [string]$PoolName        
    )

    invoke-command -computername $ComputerName -scriptblock {C:\Windows\System32\inetsrv\appcmd.exe recycle apppool $PoolName}
}

function Start-NGICAppPool
{
    param (
        [Parameter(Mandatory=$True)]
        [string]$ComputerName,
        [Parameter(Mandatory=$True)]
        [string]$PoolName        
    )

    invoke-command -computername $ComputerName -scriptblock {Start-WebAppPool -Name $PoolName}
}

function Stop-NGICAppPool
{
    param (
        [Parameter(Mandatory=$True)]
        [string]$ComputerName,
        [Parameter(Mandatory=$True)]
        [string]$PoolName        
    )

    invoke-command -computername $ComputerName -scriptblock {Stop-WebAppPool -Name $PoolName}
}


