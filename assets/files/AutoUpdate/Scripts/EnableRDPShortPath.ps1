# {"Name": "Enable RDP Shortpath","Description":"This script enables the preview function for RDP Shortpath on the selected session hosts"}
param(
    [string]$paramLogFileName="WVD.Custom.log",
	[string]$paramString=""
);

# This powershell script is part of WVD Admin - see https://blog.itprocloud.de/Windows-Virtual-Desktop-Admin/ for more information
# Current Version of this script: 1.0 - Custom Script Extension
# Write a return string to WVDAdmin with the example in the last line

# Define logfilen and dir
$LogDir="$env:windir\system32\logfiles"
$LogFile="$LogDir\$paramLogFileName"

function LogWriter($message)
{
    $message="$(Get-Date ([datetime]::UtcNow) -Format "o") $message"
	write-host($message)
	if ([System.IO.Directory]::Exists($LogDir)) {write-output($message) | Out-File $LogFile -Append}
}

LogWriter("Custom scipt start")
$WinstationsKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations'
New-ItemProperty -Path $WinstationsKey -Name 'fUseUdpPortRedirector' -ErrorAction:SilentlyContinue -PropertyType:dword -Value 1 -Force
New-ItemProperty -Path $WinstationsKey -Name 'UdpPortNumber' -ErrorAction:SilentlyContinue -PropertyType:dword -Value 3390 -Force

New-NetFirewallRule -DisplayName 'Remote Desktop - Shortpath (UDP-In)'  -Action Allow -Description 'Inbound rule for the Remote Desktop service to allow RDP traffic. [UDP 3390]' -Group '@FirewallAPI.dll,-28752' -Name 'RemoteDesktop-UserMode-In-Shortpath-UDP'  -PolicyStore PersistentStore -Profile Domain, Private -Service TermService -Protocol udp -LocalPort 3390 -Program '%SystemRoot%\system32\svchost.exe' -Enabled:True
LogWriter("Custom script end")

Write-host("ScriptReturnMessage:{RDP Shortpath enabled - reboot the session hosts(s) to take effect}:ScriptReturnMessage")

