#This script is used to quickly run commonly used support commands on a remote computer

$ErrorActionPreference='silentlycontinue'

#This function starts a powershell session on the inputted workstation
function changeMachine {

#Assign machine name to variable
$workstation = Read-Host "Enter a machine name"
 
        if (Test-Connection -ComputerName $workstation -Count 1 -Quiet) {
 
                $s = new-pssession $workstation
 
                $changeMachineFlag = 0
 
                #Run function to display user's options
                userInputMenu
               
        } else {
       
                Write-Host "Unable to start session. Check the machine name and make sure the workstation is on the network." -ForegroundColor Red
                changeMachine
               
        }
}

#This function displays user options and runs commands depending on the input
function userInputMenu {

                #Show this menu after every command is finished, end on change machine option
                while ($changeMachineFlag -eq 0) {
                        Write-Host "Reinitialzing...
                       
                       
                       
                       
                       
                       
                       
                       
                       
                        "
                        $displaySelectionMenu =
                        " [ 1] Turn autologon OFF       [ 6] Cycle CmRcService",
                        " [ 2] Turn autologon ON                [ 7] Find Username of Logged on User",
                        " [ 3] Log off user             [ 8] Force Group Policy Update",
                        " [ 4] Change Machine",
                        " [ 5] Ping                     [ 0] Exit
                       
                        "
                        #Display option menu
                        $displaySelectionMenu
                        
                        $userSelection = Read-Host "What would you like to do?"
                        
                        #Set autologon off
                        if ($userSelection -eq 1) {
                       
                                Invoke-command -Session $s -ScriptBlock {setautologon}
                        
                        #set autologon on  
                        } elseif ($userSelection -eq 2) {
                       
                                Invoke-command -Session $s -ScriptBlock {setautologon bto}
                        
                        #logoff command
                        } elseif ($userSelection -eq 3) {
                       
                                Invoke-command -Session $s -ScriptBlock {logoff console}
                        
                        #change session to a different remote computer
                        } elseif ($userSelection -eq 4) {
                       
                                $changeMachineFlag = 1
                                Remove-Pssession $s
                                changeMachine
                        
                        #Display ping results
                        } elseif ($userSelection -eq 5) {
                       
                                Test-Connection -ComputerName $workstation -Count 4

                        #Cycle remote control service
                        } elseif ($userSelection -eq 6) {
                       
                                Invoke-command -Session $s -ScriptBlock {net stop cmrcservice}
                                Start-Sleep -seconds 5
                                Invoke-command -Session $s -ScriptBlock {net start cmrcservice}
                               
                        #Borrowed code from findUser.ps1, finds users that have session on the computer by querying the SIDs
                        } elseif ($userSelection -eq 7) {
                               
                                $keyList = Invoke-command -Session $s -ScriptBlock {Get-ChildItem REGISTRY::HKEY_USERS|SELECT NAME -ExpandProperty Name}
 
                                Foreach ($key in $keyList ) {
                                       
                                        if ($key -notmatch "Classes" -and $key.length -gt 25) {
                                               
                                                $sidUser = Invoke-command -Session $s -ScriptBlock {param($keyEntry)Get-ItemProperty REGISTRY::$keyEntry\SOFTWARE\Passlogix\Extensions\SessionManager|SELECT Username -ExpandProperty Username} -ArgumentList $key
                                               
                                                if ($sidUser -ne $null) {
                                               
                                                        Write-Host "$sidUser is logged onto $workstation" -ForegroundColor Green
                                                       
                                                } else {
                                                       
                                                        Write-Host "No user is logged on or an inactive logon session was found." -ForegroundColor Red
                                                       
                                                }
                                        }
                                }
                        
                        #Group policy update
                        } elseif ($userSelection -eq 8) {
                               
                                Write-Host "Running gpupdate /force..."
                                Invoke-command -Session $s -ScriptBlock {gpupdate /force}
                               
                        } else {
                                Write-Host "Invalid option. Enter a number from the choices above"
                }
        }
}

#Starts the script
changeMachine