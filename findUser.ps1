#Andrew Ettensohn - This script find the ESSO workstations a user is logged into 

$ErrorActionPreference='silentlycontinue'
 
$userID = Read-Host "Enter username"
 
$storeNum = Read-Host "Enter store number"

#retrieve list of machine names script will run on
Foreach ($line in Get-Content .\store.txt) {

#create workstation name from store number and machine name
$workstation = "S" +$storeNum + $line

$s = new-pssession $workstation

#Output list of SIDs to .txt file
$keyList = Invoke-command -Session $s -ScriptBlock {Get-ChildItem REGISTRY::HKEY_USERS|SELECT Name -ExpandProperty Name}| Out-File -FilePath .\keyList.txt
 
        #Check all SIDs on the workstation
        Foreach ($key in Get-Content .\keyList.txt) {
                       
                       #Only check the SIDs that the key is found under
                        if ($key -notmatch "Classes" -and $key.length -gt 25) {
                                $sidUser = Invoke-command -Session $s -ScriptBlock {param($keyEntry)Get-ItemProperty REGISTRY::$keyEntry\SOFTWARE\Passlogix\Extensions\SessionManager|SELECT Username -ExpandProperty Username} -ArgumentList $key
                               
                               #Display if the user is logged onto the workstation
                                if ($sidUser -match $userID) {
                                    Write-Host "$userID is logged onto $workstation"
                                }
                        }
        }
        Remove-PSSession $s
}