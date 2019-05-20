#Andrew Ettensohn - This script ends the user's session on all workstations at a store
 
$userID = Read-Host "Enter username"
 
$storeNum = Read-Host "Enter store number"
 
#get list of workstations
Foreach ($line in Get-Content .\CurrentSession\store.txt) {
$workstation = "S" + $storeNum + $line
 
Write-Host "Checking $workstation..."
 
    #If the workstation pings then run qwinsta, otherwise display output to user
    if(Test-Connection -ComputerName $workstation -Count 1 -Quiet){
 
        #query the session on each workstation, trim the output and assign to variables
        $test = qwinsta $userID /server:$workstation
        foreach ($line in $test){
                if ( $line -match $userID) {
                        $capuserid = $($line.substring(19,24).Trim())
                        $capSessionID = $($line.substring(44,2).Trim())
                        $capState = $($line.substring(48,8).Trim())
               
                        Write-Host "   Found $capuserid on $workstation, Removing Session..." -ForegroundColor Green
                
                        if ($capState -eq "Active") { Write-Host "$userid is logged on and active on $capsessionid, removing active user..." -ForegroundColor Yellow }

                        #end user's session
                        rwinsta /server:$workstation $capSessionID
                        Start-Sleep -Seconds 2
               
                        Write-Host "   Validating user's session was reset..." -ForegroundColor Green
               
                        #ensure user's session has been reset
                        $validate = qwinsta $userID /server:$workstation
                        foreach ($line in $Validate) {
                                if ( $line -match "No session exists for" ) { Write-Host "   Successfully removed $userid from $workstation" -ForegroundColor Green }
                                Start-Sleep -Seconds 10
                        }
                }
        }
    } else{
            Write-Host "   Store does not have a $workstation" -ForegroundColor Yellow
    }
}