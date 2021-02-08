# Checks if user is an admin. If not, prompts for an admin shell to open.
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
  if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
    try {
      $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
      Start-Process -FilePath powershell.exe -Verb Runas -ArgumentList $CommandLine
      Exit
    }
    catch {
      Exit
    }
  }
}

$remoteport = bash.exe -c "ifconfig eth0 | grep 'inet '" # Finds ip address of default wsl
$found = $remoteport -match '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'; # Ensures it's correct

if ( $found ) {
  $remoteport = $matches[0];
}
else {
  # Couldn't find ip address of default wsl
  Write-Output "The ip address of WSL 2 could not be found.";
  Write-Output "Do you have ifconfig installed in your default WSL?";
  Pause
  exit;
}

$ipaddress = ( Read-Host "Enter ip address to bridge (defaults to 0.0.0.0)" )

if ( $ipaddress -eq "" ) {
  $ipaddress = '0.0.0.0';
}

$ports = @()
try {
  while ($temp = (Read-Host "Enter a port to bridge (Enter on empty to continue)").Trim()) {
    $ports += [int]$temp
  }
}
catch {
  Write-Output "Syntax Error. Did you follow the instructions?";
  Pause
  exit;
}

if ($ports.Count -eq 0) {
  Write-Output "Please enter at least one port.";
  Pause
  exit;
}

$ports_a = $ports -join ",";

# Removes firewall exception rules
Invoke-Expression "Remove-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' " > $null;

# Adds exception rules for inbound and outbound rules
Invoke-Expression "New-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' -Direction Outbound -LocalPort $ports_a -Action Allow -Protocol TCP"  > $null;
Invoke-Expression "New-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' -Direction Inbound -LocalPort $ports_a -Action Allow -Protocol TCP"  > $null;
Invoke-Expression "New-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' -Direction Outbound -LocalPort $ports_a -Action Allow -Protocol UDP"  > $null;
Invoke-Expression "New-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' -Direction Inbound -LocalPort $ports_a -Action Allow -Protocol UDP"  > $null;

# Binds specified ports between WSL and Host
for ( $i = 0; $i -lt $ports.length; $i++ ) {
  $port = $ports[$i];
  Invoke-Expression "netsh interface portproxy delete v4tov4 listenport=$port listenaddress=$ipaddress"  > $null;
  Invoke-Expression "netsh interface portproxy add v4tov4 listenport=$port listenaddress=$ipaddress connectport=$port connectaddress=$remoteport"  > $null;
}

Exit