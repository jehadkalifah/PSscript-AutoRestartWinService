# PSscript-AutoRestartWinService
Description:

AutoRestartWinService PS script file support you to automate restart Siebel CRM services without spend any effort/time to login remotely or open services console on every machine...etc, also no matter if your Siebel environment rely on single server or even multi servers such as Staging, Production environment and so on.\
This PS script file familiar to work with different environments after enter require information needed before run PS script.

#Prerequisite:
* Open PowerShell as administrator.
* PS verion should be 3 or above.
  - You can verify PS version by command "$PSVersionTable".
  - You can upgrade PS version after install Windows Management Framework by url (https://docs.microsoft.com/en-us/powershell/scripting/setup/installing-windows-powershell?view=powershell-6)
* Verify WinRM service is running on remote servers by command "winrm qc", and enable PSremoting by command "Enable-PSRemoting", with considering open concern ports through firewall.

#Instruction:
1. Execute PS script file after go to correct path.
2. Enter Gateway Server hostname (It's a server all application servers depend on it).
3. Enter number of application servers (0 number mean both of Siebel Gateway and Application services configured on single server).
4. Enter application servers hostname.
5. Enter Standard credential.

#Note:
* You can find two scripts one of them login remotely as session (which help you to cache session and execute command take a lot of time) and another script depend on computer name (which remote session will close immediately after finish command).
* You can customize mentioned PS script on different services with considering PS script go through register to get service name.
