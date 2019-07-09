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