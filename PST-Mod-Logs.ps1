
# initialize the items variable with the
# contents of a directory
#Folders are arranged \StressTesting\<device>\<passName>\<RS3|RS4|RS>\<bldRevision>\<dateRun>\
# Builds testParameter = " "<deviceType>_<passName>_<dateRun>_lkg<OSImageVer>_test:PLE-CS-STRESS

$baseFolder = "\\10.200.205.9\New_StressTesting\StressTesting\ZaP"
$passNames = Get-ChildItem -Path $baseFolder | where {$_.Attributes -match 'Directory'}
$deviceType = Split-Path $baseFolder -Leaf

foreach ($passName in $passNames)
{
    $pathPassName = Join-path -Path $baseFolder -ChildPath $passName.Name
    $rsVersions = GCI -Path $pathPassName | where {$_.Attributes -match 'Directory'}

    foreach ($rsVersion in $rsVersions)
    {
        $pathRSVersion = Join-path -Path $pathPassName -ChildPath $rsVersion.Name 
        $buildRevisions = GCI -Path $pathRSVersion | where {$_.Attributes -match 'Directory'}

        foreach($buildRevision in $buildRevisions)
        {
            $pathRunDate = Join-Path -Path $pathRSVersion -ChildPath $buildRevision.Name
            $runDates = GCI -Path $pathRunDate | where {$_.Attributes -match 'Directory'}
            Write-Host '$buildRevision = +' $buildRevision
                                                        
            foreach($runDate in $runDates) 
            {
                $pathDutDataFolder = Join-Path -Path $pathRunDate -ChildPath $runDate.Name
                $dutDataFolders = GCI -Path $pathDutDataFolder | where {$_.Attributes -match 'Directory'}  | where {$_.Name -notmatch 'trace'}

                ForEach ($dutDataFolder in $dutDataFolders) 
                {
                    $FilePath = $dutDataFolder.FullName +"\Trace\PSTtrace.txt"
                    $FilePath2 = $dutDataFolder.FullName +"\DeviceInfo.csv"
                    # Request to remove timestamp - HHL
                    #$timeStamp = $dutDataFolder.CreationTime.ToString("yyyyMMdd-HHmmss")

                    $osImageVer = (Get-Content $FilePath2) | Select-String '.wim'
                    $osImageVer = $osImageVer.ToString().Split('.')
                    $osImageVerCount = $osImageVer.Count
                    $osImageVer = ($osImageVer[$osImageVerCount-4] + "." + $osImageVer[$osImageVerCount-3] + "." +  $osImageVer[$osImageVerCount-2]).ToString()


                    $testParameter = " " + $deviceType + "_" + $passName +"_"+ $rsVersion + "_lkg" + $osImageVer + "_test:PLE-CS-Stress"
                    # Request to remove timestamp - HHL
                    #$testParameter = " " + $deviceType + "_" + $passName + "_" + $timeStamp +"_"+ $rsVersion + "_lkg" + $osImageVer + "_test:PLE-CS-Stress"

                    Write-Host $DutDataFolder.FullName
                    Write-host $testParameter
                    #Read-Host "Press a key to continue"

                    (Get-Content $FilePath2).replace(' si', $testParameter) | Set-Content $FilePath2
                    (Get-Content $FilePath).replace('SI Power State stress test', $testParameter) | Set-Content $FilePath
                }
            }
        }
    }
}

