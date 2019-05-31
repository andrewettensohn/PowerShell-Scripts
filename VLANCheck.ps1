
#Andrew Ettensohn, this script finds if a workstation has been converted to the correct VLAN using the IP address.
 
$ErrorActionPreference='silentlycontinue'
 
$recordCount = 0
 
Write-Host "Clearing Previous Report..."
 
#This sets the top line in the .txt file and deletes the old content
$cleanReport = "Machine         IP              VLAN" | Out-File -FilePath .\report.txt
 
Write-Host "Report Cleared."
 
Write-Host "Gathering List of IPs..."
 
Foreach ($storeNum in Get-Content .\stores.txt) {
 
#array of machine types
$CSworkstations = ("0032", "0648", "1378")
 
        Foreach ($machineName in $CSworkstations) {
               
        #Build workstation name
        $workstation = "S" + $storeNum + $machineName
               
                #This will pull the IP with no extra details
                $workstationIP = Resolve-DNSName -Name $workstation | SELECT -ExpandProperty IPAddress
               
                #if this is a VLAN99 IP
                if ($workstationIP -match ".356|.335|.218" ) {
               
                        $line = "$workstation   $workstationIP  VLAN99" | Out-File -FilePath .\report.txt -append
                        Write-Host "$workstation        $workstationIP  VLAN99" -ForeGroundColor Green
                        $recordCount++
                       
                #if this is a VLAN66 IP
                } elseif ($workstationIP -match ".65|.79|.30") {
                       
                        $line = "$workstation   $workstationIP  VLAN66" | Out-File -FilePath .\report.txt -append
                        Write-Host "$workstation        $workstationIP  VLAN66" -ForeGroundColor Red
                        $recordCount++
               
                #if the IP is set incorrectly
                } else {
                       
                        Write-Host "$workstation is not present or has incorrect IP" -ForeGroundColor Yellow
                }
        }
}
 
Write-Host "Done! $recordCount IPs Retrieved. View report in report.txt"