$recordCount = 0
 
Write-Host "Clearing Previous Report..."
 
#This sets the top line in the .txt file and deletes the old content
$cleanReport = "Machine         MAC" | Out-File -FilePath .\MAC_list.txt
 
Write-Host "Collecting MAC Address from workstations..."
 
Write-Host "Report Cleared."
 
Foreach ($storeNum in Get-Content .\stores.txt) {
 
        $CSworkstations = ("2578", "3574", "3128")
        
        #run script for all three machine types
        Foreach ($machineName in $CSworkstations) {
       
                $workstation = "S" + $storeNum + $machineName
                
                #only add record if the workstation is on the network
                if(Test-Connection -ComputerName $workstation -Count 1 -Quiet) {
                       
                        $s = new-pssession $workstation
                       
                        #retrieve MAC address
                        $workstationMAC = Invoke-command -Session $s -ScriptBlock {get-netadapter | SELECT MacAddress -ExpandProperty MacAddress}
                       
                        #Add a new line to the report
                        $line = "$workstation   $workstationMAC" | Out-File -FilePath .\MAC_list.txt -append
                       
                        $recordCount++
                       
                        Remove-Pssession $s
                }
        }
}
 
 
Write-Host "Done. $recordCount MACs Retrieved. View report in MAC_list.txt"