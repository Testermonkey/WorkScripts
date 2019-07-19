$TopLevelDir = Get-Item -Path "\\10.200.205.9\New_StressTesting\StressTesting\Foxburg\RS3_Readiness_Train\RS3\18126131243\Dec16";
$DutDataFolders = Get-ChildItem $TopLevelDir | where {$_.Attributes -match 'Directory'}

ForEach ($DutDataFolder in $DutDataFolders) 
{
  Write-Host $DutDataFolder.Name;

  $FilePath = $DutDataFolder.FullName +"\Trace\PSTtrace.txt";
  # <project>_<milestone>_<date as yyyymmdd>_lkg<lkg#>_test:<run number>
   (Get-Content $FilePath).replace('SI Power State stress test', 'Foxburg_RS3_RS3ReadinessTrain_20181216_lkg12.1108.0_test:PLE-CS-STRESS.0') | Set-Content $FilePath

  $FilePath2 = $DutDataFolder.FullName +"\DeviceInfo.csv";
   (Get-Content $FilePath2).replace(' si', ' Cruz_RS3_RS3ReadinessTrain_20181216_lkg12.1108.0_test:PLE-CS-STRESS.0') | Set-Content $FilePath2
} 


