<#
.SYNOPSIS
    Collects multiple data points and uses them to rename the device to the following schema
    Device type:
•	SB – Surface Book (original)
•	SV – Surface Book (Low Cost)
•	BD – Surface Base (Non-GPU)
•	RZ- Surface Base (GPU Nvidia)
•	P4 – Pro4
•	NAG – North American (S3)
•	ROW – Rest Of the World (S3)
•	US1 -  United States (S3)
•	WIF – Wifi Only (S3)
•	NYX – SP3

Processor Modifier: 
Used on SB and Pro4
•	M
•   3
•	5
•	7

The following fields are programmatically available:
•	Win32_ComputerSystem – Model (Type)
•	Win32_processor – Name (Processor Modifier)
•	Win32_Bios – SerialNumber

Example
•	SB7000950763157 – SBi7
•	P47014757454953 – P4i7
•	NAG000003452752 – S3 North American Group

.DESCRIPTION
    ComputerRename is invoked with the default ps1 wrapper
    
.PARAMETER
    This file has no parameters
#>

#Check Permissions
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host -ForegroundColor Red "You do not have Administrator rights to run this script!"
    Write-Host -ForegroundColor Yellow "Please re-run this script as an Administrator!"
    exit
} 

function Main{
    #Collect Information
    $currentComputerName = (Get-WmiObject -Class:Win32_Computersystem).Name
    $model =  (Get-WmiObject -Class:Win32_Computersystem).Model
    $proc = (Get-WmiObject -Class:Win32_Processor).Name
    $serialNumber = (Get-WmiObject -Class:Win32_Bios).SerialNumber

    #Get Processor modifier
    $p = Processor

    #Get Model version
    #Model will overwrite if Surf3
    $m = Model
    
    #Rename function - Needs a try catch
    Rename
    exit
}

function Processor{
    ##Get processor model
    if ($proc -like '*i7-*')   { return "7"}
    if ($proc -like '*i5-*')   { return "5"}
    if ($proc -like '*i3-*')   { return "3"}
    if ($proc -like '*m3-*')   { return "M"}
    if ($model -like "Surface 3"){ return ""}
    else {
        Write-Host "The Processor could not be determined. Aborting"
        exit
    }
}

function Model{
    #Check Model version
    if ($model -eq "Surface 3")      {return Surf3} #Themis
    if ($model -eq "Surface Pro 3")  {return "Ni"}  #Nyx
    if ($model -eq "Surface Pro 4")  {return "P4"}  #Peregrine
    if ($model -eq "Surface Book")   {return "SB"}  #Hera
    else {
        Write-Host "The Model could not be determined. Aborting"
        Exit
    }
}


function Rename{
    #Construct computer name
    $newName = $m + $p + $serialNumber
    
    #validate with user first
    Write-Host "Rename from $currentComputerName to $newName."
    $confirmation = Read-Host "Confirm Rename device? [y/n]"
    while($confirmation -ne "y")
    {
        if ($confirmation -eq 'n') {exit}
        $confirmation = Read-Host "Confirm Rename device? [y/n]"
    }

    #User selected yes - Rename
    Write-Host "Press enter when prompted for password"
	Rename-Computer -NewName $newName -DomainCredential Domain01\Admin01
}

function Surf3{
    $mBB = Invoke-Expression "netsh M S I" | Select-String -Pattern "Firmware"
    if ($mBB -like '*_NAG_*')           { return "NAG"}
    if ($mBB -like '*_ROW_*')           { return "ROW"}
    if ($mBB -like '*_US1_*')           { return "US1"}
    if ($mBB -like '*_US2_*')           { return "US2"}
    if ([String]::IsNullOrEmpty($mBB))  { return "WIF"}
    else {
        Write-Host "mbb = $mBB"
        Write-Host "The Surf3 could not be determined. Aborting"
        exit
    }
}

main
