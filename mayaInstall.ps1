$server_names = Get-Content "Computers.txt"
$application = "Maya 2016"
Foreach ($server in $server_names){
    Write-Host "Checking Server: " -nonewline; Write-Host $server
    if(Test-Connection -Cn $server -BufferSize 16 -Count 1 -ea 0 -quiet){
        Write-Host $server -nonewline; Write-Host " is pingable"
        if (test-path "\\$server\c$\Windows\system32\cmd.exe"){
            if (-not (test-path "\\$server\c$\Program Files\Autodesk\Maya2016\bin\maya.exe")){
                Write-Host "$application does not exist on remote host $server"
                Write-Host "Installing $application"
                invoke-command -computername $server -ScriptBlock{
                    $net = new-object -ComObject WScript.Network;
                    $net.MapNetworkDrive("r:", "\\server\deploy", "false", "domain\username", "password");
                    Start-Process -Verb runAs -filepath "\\server\deploy\Maya\Maya2016\Img\Setup.exe" -argumentlist "/qb /I \\server\deploy\Maya\Maya2016\Img\maya2016.ini /language en-us";
                    Write-Host "Install kickedoff";
                    sleep 3600
                } -AsJob
            }
            else {Write-Host "$application is already installed!"}
        }
        else {Write-Host "Cannot connect to machine to run installer.  Aborting"}
    }
    else {Write-Host "$server is not available"}
    Write-Host 
}