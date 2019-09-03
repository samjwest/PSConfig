#===============================================================
# Alias 
#===============================================================
set-alias gcid      Get-ChildItemDirectory
set-alias wget      Get-WebItem -Option AllScope
# set-alias ss        
# set-alias ssr       curse 
set-alias go        Jsh.Go-Path
set-alias gop       Jsh.Push-Path
set-alias script    Jsh.Run-Script
set-alias ia        Invoke-Admin
set-alias ica       Invoke-CommandAdmin
set-alias isa       Invoke-ScriptAdmin
Set-Alias ls        Get-ChildItemColor -option AllScope -Force
Set-Alias dir       Get-ChildItemColor -option AllScope -Force
#set-alias su        
#==============================================================================
#
#   https://github.com/joonro/ConEmu-Color-Themes
#==============================================================================
$configfile = "C:\tools\cmder\vendor\conemu-maximus5\ConEmu.xml"
$themedir = "C:\Source\Misc\Repos\ConEmu-Color-Themes\themes"
$psdir = "C:\Users\I222408\Documents\WindowsPowerShell"
#Set-ExecutionPolicy remoteSigned -Scope CurrentUser

Import-Module 'C:\tools\poshgit\posh-git\src\posh-git.psd1'
Import-Module PSColor
Import-Module oh-my-posh
Set-Theme Honukai

#==============================================================================
# Common Variables Start
#==============================================================================
$global:Jsh = new-object psobject 
$Jsh | add-member NoteProperty "ScriptPath" $(split-path -parent $MyInvocation.MyCommand.Definition) 
$Jsh | add-member NoteProperty "ConfigPath" $(split-path -parent $Jsh.ScriptPath)
$Jsh | add-member NoteProperty "UtilsRawPath" $(join-path $Jsh.ConfigPath "Utils")
$Jsh | add-member NoteProperty "UtilsPath" $(join-path $Jsh.UtilsRawPath $env:PROCESSOR_ARCHITECTURE)
$Jsh | add-member NoteProperty "UserPath" $(split-path -parent $Jsh.ConfigPath)
$Jsh | add-member NoteProperty "DesktopPath" $(join-path $env:USERPROFILE "Desktop")
$Jsh | add-member NoteProperty "BuildPath" $(join-path $Jsh.DesktopPath "Build")
$Jsh | add-member NoteProperty "DeployPath" $(join-path $Jsh.DesktopPath "Deploy")
#$Jsh | add-member NoteProperty "DeployPath" "C:\Source\Workspaces\ReleaseManagement\DevOps\NPSBuildScripts\Deployment"
$Jsh | add-member NoteProperty "GoMap" @{}
$Jsh | add-member NoteProperty "ScriptMap" @{}

#$host.PrivateData.ErrorBackgroundColor = "DarkMagenta"
#$host.PrivateData.ErrorForegroundColor = "Yellow"

#==============================================================================
# Functions 
#==============================================================================

# Load snapin's if they are available
function Jsh.Load-Snapin([string]$name) {
    $list = @( get-pssnapin | ? { $_.Name -eq $name })
    if ( $list.Length -gt 0 ) {
        return; 
    }

    $snapin = get-pssnapin -registered | ? { $_.Name -eq $name }
    if ( $snapin -ne $null ) {
        add-pssnapin $name
    }
}

# Update the configuration from the source code server
function Jsh.Update-WinConfig([bool]$force=$false) {

    # First see if we've updated in the last day 
    $target = join-path $env:temp "Jsh.Update.txt"
    $update = $false
    if ( test-path $target ) {
        $last = [datetime] (gc $target)
        if ( ([DateTime]::Now - $last).Days -gt 1) {
            $update = $true
        }
    } else {
        $update = $true;
    }

    if ( $update -or $force ) {
        write-host "Checking for winconfig updates"
        pushd $Jsh.ConfigPath
        $output = @(& svn update)
        if ( $output.Length -gt 1 ) {
            write-host "WinConfig updated.  Re-running configuration"
            cd $Jsh.ScriptPath
            & .\ConfigureAll.ps1
            . .\Profile.ps1
        }

        sc $target $([DateTime]::Now)
        popd
    }
}

function Jsh.Push-Path([string] $location) { 
    go $location $true 
}
function Jsh.Go-Path([string] $location, [bool]$push = $false) {
    if ( $location -eq "" ) {
        write-output $Jsh.GoMap
    } elseif ( $Jsh.GoMap.ContainsKey($location) ) {
        if ( $push ) {
            push-location $Jsh.GoMap[$location]
        } else {
            set-location $Jsh.GoMap[$location]
        }
    } elseif ( test-path $location ) {
        if ( $push ) {
            push-location $location
        } else {
            set-location $location
        }
    } else {
        write-output "$loctaion is not a valid go location"
        write-output "Current defined locations"
        write-output $Jsh.GoMap
    }
}

function Jsh.Run-Script([string] $name) {
    if ( $Jsh.ScriptMap.ContainsKey($name) ) {
        . $Jsh.ScriptMap[$name]
    } else {
        write-output "$name is not a valid script location"
        write-output $Jsh.ScriptMap
    }
}

## Detect if we are running powershell without a console.
$_ISCONSOLE = $TRUE
try {
    [System.Console]::Clear()
}
catch {
    $_ISCONSOLE = $FALSE
}

# Everything in this block is only relevant in a console. This keeps nonconsole based powershell sessions clean.
if ($_ISCONSOLE) {
    ##  Check SHIFT state ASAP at startup so we can use that to control verbosity :)
    try {
	Add-Type -Assembly PresentationCore, WindowsBase
        if ([System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::LeftShift) -or [System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::RightShift)) {
            $VerbosePreference = "Continue"
        }
    }
    catch {
        # Maybe this is a non-windows host?
    }

    ## Set the profile directory variable for possible use later
    Set-Variable ProfileDir (Split-Path $MyInvocation.MyCommand.Path -Parent) -Scope Global -Option AllScope, Constant -ErrorAction SilentlyContinue

    # Start OhMyPsh only if we are in a console
    if ($Host.Name -eq 'ConsoleHost') {
        if (Get-Module OhMyPsh -ListAvailable) {
            Import-Module OhMyPsh
        }
    }
}

# Set the prompt
# function prompt() {
#     $realLASTEXITCODE = $LASTEXITCODE
#     $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor
    
#     if ( Test-Admin ) { 
#         write-host -NoNewLine -f red "Admin "
#     }

#     Write-Host "[" -NoNewline -ForegroundColor DarkMagenta
#     Write-Host (Get-Date -Format t) -NoNewline -ForegroundColor Magenta
#     Write-Host "]" -NoNewline -ForegroundColor DarkMagenta

#     #$width = ($Host.UI.RawUI.WindowSize.Width - 2 - $(Get-Location).ToString().Length)
#     $width = (132 - 2 - $(Get-Location).ToString().Length)
#     $hr = New-Object System.String @('-',$width)
#     Write-Host -ForegroundColor Green $(Get-Location) $hr

#     $global:LASTEXITCODE = $realLASTEXITCODE
#     return "> "
# }

### ---------------------------------------------------------------------------
### Load function / filter definition library
### ---------------------------------------------------------------------------

Get-ChildItem "${psdir}\Scripts\Autoload\*.ps1" | %{ 
    .$_
    write-host "Loading library file:`t$($_.name)"
  }


pushd $Jsh.ScriptPath

# Setup the go locations
$Jsh.GoMap["ps"]        = $Jsh.ScriptPath
$Jsh.GoMap["config"]    = $Jsh.ConfigPath
$Jsh.GoMap["~"]         = "~"
$Jsh.GoMap["build"]     = $Jsh.BuildPath
$Jsh.GoMap["deploy"]     = $Jsh.DeployPath
