Write-Host "Collecting MAC Address from workstations..."
 
$recordCount = 0
 
Foreach ($storeNum in Get-Content .\stores.txt) {
 
        $CSworkstations = ("0094", "0095", "0097")
       
        Foreach ($machineName in $CSworkstations) {
       
                $workstation = "S" + $storeNum + $machineName
       
                if(Test-Connection -ComputerName $workstation -Count 1 -Quiet) {
                       
                        $s = new-pssession $workstation
                       
                        $workstationMAC = Invoke-command -Session $s -ScriptBlock {get-netadapter | SELECT MacAddress -ExpandProperty MacAddress}
                       
                        $line = "$workstation   $workstationMAC" | Out-File -FilePath .\MAC_list.txt -append
                       
                        $recordCount++
                       
                        Remove-Pssession $s
                }
        }
}
 
 
Write-Host "Done. $recordCount MACs Retrieved. View report in MAC_list.txt"