$config=&'S:\work\programs\powershell\BuildData.ps1'
  <# we read in the data as a structure. Then we do some sanity checking to make sure that the data is reasonably viable. #>
  $DataError = ''
  if ($config.BuildArtifact -eq $null) { $DataError += 'no $config.BuildArtifact, ' };
  if ($config.Databases -eq $null) { $DataError += 'no $config.Databases, ' };
  if ($config.PackageVersion -eq $null) { $DataError += 'no $config.PackageVersion, ' };
  if ($config.PackageId -eq $null) { $DataError += 'no $config.PackageId, ' };
  if ($config.LogDirectory -eq $null) { $DataError += 'no $config.LogDirectory, ' };
  if ($config.Project -eq $null) { $DataError += 'no $config.Project, ' };
  if ($DataError -ne '') { Throw "Cannot run the application because there is $DataError" }


  $errorActionPreference = "stop"
  #variables that you need to fill in
  $TemporaryDatabaseServer = 'MyConnectionStringToTheServer'
  $TargetServerInstance = 'MyTargetServerr'
  $TargetDatabase = 'MyTargetDatabase'
  $TargetUserName = 'MyLogin'
  $TargetPassword = 'MyPassword'
  $project = "MyPathTotheProject" # The SQL Change Automation project to validate, test and sync
  # Validate the SQL Change Automation project
  $validatedProject = Invoke-DatabaseBuild $project -TemporaryDatabaseServer $TemporaryDatabaseServer
  #this builds the server temporarily to check that it can be done
  #produce documentation and the nuget package
  $documentation = $validatedProject | New-DatabaseDocumentation -TemporaryDatabaseServer $TemporaryDatabaseServer
  $buildArtifact = $validatedProject | New-DatabaseBuildArtifact -PackageId MyDatabase -PackageVersion 1.0.0 -Documentation $documentation
  $buildArtifact | Export-DatabaseBuildArtifact -Path "$project\buildArtifacts"
  # Sync a database
  $deploymentTargetConnection = New-DatabaseConnection -ServerInstance $TargetServerInstance -Database $TargetDatabase -Username $TargetUserName -Password $TargetPassword # Update this to use the blank database created earlier
  $ConnectionErrors = @() # to store any connection errors in
  $TestResult = Test-DatabaseConnection $deploymentTargetConnection -ErrorAction silentlycontinue -ErrorVariable ConnectionErrors
  if ($ConnectionErrors.count -eq 0) #if we couldn't connect
      { $syncResult = Sync-DatabaseSchema -Source $validatedProject -Target $deploymentTargetConnection 
      $syncResult.UpdateSql
      }
  else
  {write-warning $ConnectionErrors[0]}