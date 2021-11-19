
# First, make sure WinRM can't be connected to

netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" new enable=yes action=block

# Set network location to private for all networks
$networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}")) 
$connections = $networkListManager.GetNetworkConnections() 
$connections | ForEach-Object {$_.GetNetwork().SetCategory(1)}

​

# Delete any existing WinRM listeners

winrm delete winrm/config/listener?Address=*+Transport=HTTP 2>$Null
winrm delete winrm/config/listener?Address=*+Transport=HTTPS 2>$Null

​

# Create a new WinRM listener and configure

winrm create winrm/config/listener?Address=*+Transport=HTTP
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="0"}'
winrm set winrm/config '@{MaxTimeoutms="7200000"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service '@{MaxConcurrentOperationsPerUser="12000"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'


# Create a new WinRM HTTPS listener and configure
$c = New-SelfSignedCertificate -DnsName "127.0.0.1" -CertStoreLocation cert:\LocalMachine\My
winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname=`"127.0.0.1`";CertificateThumbprint=`"$($c.ThumbPrint)`"}"


# Configure UAC to allow privilege elevation in remote shells

$Key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
$Setting = 'LocalAccountTokenFilterPolicy'
Set-ItemProperty -Path $Key -Name $Setting -Value 1 -Force


# Configure and restart the WinRM Service; Enable the required firewall exception

Stop-Service -Name WinRM
Set-Service -Name WinRM -StartupType Automatic
netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" new action=allow localip=any remoteip=any
netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow
netsh advfirewall firewall add rule name="WinRM-HTTPS" dir=in localport=5986 protocol=TCP action=allow
Start-Service -Name WinRM