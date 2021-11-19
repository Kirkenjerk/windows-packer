<# Init Log #>;
Start-Transcript -Path 'C:/Automation/setup_enable.txt' -append;


# Delete any existing WinRM listeners
winrm delete winrm/config/listener?Address=*+Transport=HTTP 2>$Null
winrm delete winrm/config/listener?Address=*+Transport=HTTPS 2>$Null

# Grab existing networks
$networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}")) 
$connections = $networkListManager.GetNetworkConnections() 

# Set network location to Private for all networks 
$connections | ForEach-Object {$_.GetNetwork().SetCategory(1)}

Enable-PSRemoting
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="800"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/listener?Address=*+Transport=HTTP '@{Port="5985"}'
netsh advfirewall firewall set rule group="Windows Remote Administration" new enable=yes
netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" new enable=yes action=allow
netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow
$c = New-SelfSignedCertificate -DnsName "127.0.0.1" -CertStoreLocation cert:\LocalMachine\My
winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname=`"127.0.0.1`";CertificateThumbprint=`"$($c.ThumbPrint)`"}"
netsh advfirewall firewall add rule name="WinRM-HTTPS" dir=in localport=5986 protocol=TCP action=allow

Set-Service winrm -StartupType Automatic
Restart-Service winrm

Exit
