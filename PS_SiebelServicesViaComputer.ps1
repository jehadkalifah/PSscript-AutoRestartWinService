# Modify PS Execution Policy

Set-ExecutionPolicy RemoteSigned



# Add Services Variables

$SblGtwyServerName = Read-Host("Enter Siebel Gateway server name: ") 
Write-Host ("Enter number 0 in case both of Siebel Gateway and Application on the same server") -ForegroundColor Green
[int] $SblAppServerNumbers = Read-Host ("Enter Siebel Application servers number")
$counter=1
$SblAppServerArray=$null
$SblAppServiceName=$null



#Get Siebel Application Servers Name

Do 
  {
    if ($SblAppServerNumbers -eq 0){
         Break    } #End if statement

    $SblAppServerArray += @(
    Read-Host ("Enter Siebel Server computer name $counter"))
    $counter++
  } #End do statement

until ($counter -eq $SblAppServerNumbers+1
  ) #End until statement



#Add Credential variable

$Credential=get-credential -credential 'Administrator'



#Add Siebel Servers to WinRM TrustedHosts

if ($SblAppServerNumbers -eq 0){
        Set-Item WSMan:\localhost\Client\TrustedHosts –Value “$SblGtwyServerName” -ea 0 -Force
        } #End if statement

Else{
		Set-Item WSMan:\localhost\Client\TrustedHosts –Value “*” -ea 0 -Force

        } #End else statement



#Get Siebel Application Services Name

if ($SblAppServerNumbers -eq 0){
        $SblAppServiceName=Invoke-Command -ComputerName $SblGtwyServerName -Credential $Credential -ScriptBlock {(Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\services\Sie*).PSChildName}
        } #End if statement

Else{
     ForEach ($SblAppServer in $SblAppServerArray){
     $SblAppServiceName+=@(Invoke-Command -ComputerName $SblAppServer -Credential $Credential -ScriptBlock {(Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\services\Sie*).PSChildName}) 
         }#End foreach statement
     } #End else statement



#Add Function of Services Status

Function GetServicesStatus (){
	$SblGetAppServiceStatus=$null
	$SblGetGtwpServiceStatus=$null

	if ($SblAppServerNumbers -eq 0){
			Invoke-Command -ComputerName $SblGtwyServerName -Credential $Credential -ScriptBlock {Get-Service -Name 'gtwyns',"$using:SblAppServiceName"} | Format-Table -Property Status,DisplayName,PSComputerName -AutoSize
				 } #End if statement

	else{
			$SblGetGtwpServiceStatus=Invoke-Command -ComputerName $SblGtwyServerName -Credential $Credential -ScriptBlock {Get-Service -Name 'gtwyns'}
			$counter=0
			Foreach ($SblServiceName in $SblAppServiceName){
				$SblGetAppServiceStatus+=@(
					Invoke-Command -ComputerName $SblAppServerArray[$counter] -Credential $Credential -ScriptBlock {Get-Service -Name $using:SblServiceName})
					$counter++
						  } #End foreach statement
			$SblGetGtwpServiceStatus,$SblGetAppServiceStatus | Format-Table -Property Status,DisplayName,PSComputerName -AutoSize
			 
				} #End else statement

	} #End function statement
	
	
#Get Siebel Services Status

GetServicesStatus


#Stop Siebel Services

if ($SblAppServerNumbers -eq 0){
        
		Write-Host ("It's stopping Siebel Application service")
        Invoke-Command -ComputerName $SblGtwyServerName -Credential $Credential -ScriptBlock {Stop-Service -Name "$using:SblAppServiceName"}
		Write-Host ("It's stopping Siebel Gateway service")
        Invoke-Command -ComputerName $SblGtwyServerName -Credential $Credential -ScriptBlock {Stop-Service -Name 'gtwyns'}
          } #End if statement

else{
        $counter=0
        Foreach ($SblServiceName in $SblAppServiceName){
                Write-Host ("It's stopping Siebel Application service on server: " + $SblAppServerArray[$counter])
                Invoke-Command -ComputerName $SblAppServerArray[$counter] -Credential $Credential -ScriptBlock {stop-Service -Name $using:SblServiceName}
                $counter++ } #End foreach statement
				
		Write-Host ("It's stopping Siebel Gateway service")
        Invoke-Command -ComputerName $SblGtwyServerName -Credential $Credential -ScriptBlock {Stop-Service -Name 'gtwyns'}		
          } #End else statement



#Get Siebel Services Status

GetServicesStatus 



#Start Siebel Services

if ($SblAppServerNumbers -eq 0){
        Write-Host ("It's starting Siebel Gateway service")
        Invoke-Command -ComputerName $SblGtwyServerName -Credential $Credential -ScriptBlock {Start-Service -Name 'gtwyns'}
		Write-Host ("It's starting Siebel Application service")
        Invoke-Command -ComputerName $SblGtwyServerName -Credential $Credential -ScriptBlock {Start-Service -Name "$using:SblAppServiceName"}
            } #End if statement

else{
        Write-Host ("It's starting Siebel Gateway service")
        Invoke-Command -ComputerName $SblGtwyServerName -Credential $Credential -ScriptBlock {Start-Service -Name 'gtwyns'}
        
        $counter=0
        Foreach ($SblServiceName in $SblAppServiceName){
                Write-Host ("It's starting Siebel Application service on server: " + $SblAppServerArray[$counter])
                Invoke-Command -ComputerName $SblAppServerArray[$counter] -Credential $Credential -ScriptBlock {start-Service -Name $using:SblServiceName}
                $counter++ } #End foreach statement
            } #End else statement



#Get Siebel Services Status

GetServicesStatus 


#Remove WinRM TrustedHosts

Clear-Item WSMan:\localhost\Client\TrustedHosts -Force
