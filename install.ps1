# Installs Kache 0.9.0 for the current Windows user: downloads its installer,
# checks the SHA-256 and installs it. In PowerShell: irm https://simonmalm.github.io/kache/install.ps1 | iex
& ([scriptblock]::Create(@'
# Windows bootstrap for a published MSI. No Python or Rust toolchain needed.
# Release hosting is supplied until the public repository is selected.
[CmdletBinding(DefaultParameterSetName='Download',SupportsShouldProcess=$true)]
param([Parameter(Mandatory=$true,ParameterSetName='Download')][uri]$MsiUri,
      [Parameter(Mandatory=$true,ParameterSetName='Local')][string]$MsiPath,
      [Parameter(Mandatory=$true)][ValidatePattern('^[a-fA-F0-9]{64}$')][string]$Sha256,
      [switch]$ValidateOnly)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Net.Http
function Get-KacheHttpsResponse([Net.Http.HttpClient]$Client,[uri]$Uri,[Threading.CancellationToken]$CancellationToken){
    # HttpClient on .NET Framework can follow an HTTPS-to-HTTP redirect.
    # Follow explicitly so no insecure hop is requested, even if it would
    # eventually redirect back to HTTPS. Keep ordinary OS TLS validation.
    $current=$Uri
    for($hop=0;$hop -lt 10;$hop++){
        if($current.Scheme -ne 'https'){throw 'Refusing a non-HTTPS download or redirect'}
        $response=$Client.GetAsync($current,[Net.Http.HttpCompletionOption]::ResponseHeadersRead,$CancellationToken).GetAwaiter().GetResult()
        if([int]$response.StatusCode -in @(301,302,303,307,308)){
            try {
                $location=$response.Headers.Location
                if(-not $location){throw 'Installer redirect has no Location'}
                $next=if($location.IsAbsoluteUri){$location}else{New-Object Uri -ArgumentList @($current,$location)}
                if($next.Scheme -ne 'https'){throw 'Refusing an HTTPS downgrade'}
            } finally {$response.Dispose()}
            $current=$next
            continue
        }
        try {$null=$response.EnsureSuccessStatusCode();return $response}
        catch {$response.Dispose();throw}
    }
    throw 'Installer download exceeded the redirect limit'
}
if([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT -or -not [Environment]::Is64BitOperatingSystem){throw 'This installer requires Windows x64'}
if($WhatIfPreference){$null=$PSCmdlet.ShouldProcess('Kache for the current Windows user','Install verified MSI and start the tray');return}
if(-not $ValidateOnly -and -not $PSCmdlet.ShouldProcess('Kache for the current Windows user','Install verified MSI and start the tray')){return}
$temp=Join-Path ([IO.Path]::GetTempPath()) ('kache-install-'+[Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $temp | Out-Null
$package=Join-Path $temp kache.msi
$log=Join-Path $temp install.log
$success=$false
try {
    if($PSCmdlet.ParameterSetName -eq 'Download'){
        if($MsiUri.Scheme -ne 'https'){throw 'Download the release over HTTPS'}
        $handler=New-Object Net.Http.HttpClientHandler
        $handler.AllowAutoRedirect=$false
        $client=New-Object Net.Http.HttpClient -ArgumentList $handler
        $client.Timeout=[TimeSpan]::FromMinutes(5)
        $deadline=New-Object Threading.CancellationTokenSource
        $deadline.CancelAfter([TimeSpan]::FromMinutes(5))
        try {
            $response=Get-KacheHttpsResponse $client $MsiUri $deadline.Token
            try {
                $null=$response.EnsureSuccessStatusCode()
                if($response.RequestMessage.RequestUri.Scheme -ne 'https'){throw 'Refusing an HTTPS downgrade'}
                if($response.Content.Headers.ContentLength -gt 256MB){throw 'Unexpectedly large installer'}
                $source=$response.Content.ReadAsStreamAsync().GetAwaiter().GetResult()
                $output=[IO.File]::Create($package)
                try {
                    $buffer=New-Object byte[] 65536
                    $total=0L
                    while(($read=$source.ReadAsync($buffer,0,$buffer.Length,$deadline.Token).GetAwaiter().GetResult()) -gt 0){$total+=$read;if($total -gt 256MB){throw 'Installer exceeds the download limit'};$output.Write($buffer,0,$read)}
                } finally {$output.Dispose();$source.Dispose()}
            } finally {$response.Dispose()}
        } finally {$deadline.Dispose();$client.Dispose()}
    } else {Copy-Item -LiteralPath (Resolve-Path -LiteralPath $MsiPath).Path -Destination $package}
    if((Get-FileHash -LiteralPath $package -Algorithm SHA256).Hash -ne $Sha256){throw 'Installer checksum mismatch; nothing was installed'}
    if($ValidateOnly){$success=$true;Write-Output 'Installer checksum verified; no installation was requested.';return}
    $process=Start-Process -FilePath "$env:SystemRoot\System32\msiexec.exe" -ArgumentList @('/i',('"'+$package+'"'),'/passive','/norestart','/l*v',('"'+$log+'"')) -PassThru
    try {
        $null=$process.Handle
        $process.WaitForExit()
        $exitCode=$process.ExitCode
    } finally {$process.Dispose()}
    if($exitCode -notin @(0,3010)){throw "Windows Installer failed ($exitCode); log: $log"}
    $folder=(Get-ItemProperty -LiteralPath 'HKCU:\Software\Kache\Install' -Name Directory).Directory
    if(-not(Test-Path -LiteralPath (Join-Path $folder kache.exe))){throw 'Windows Installer did not register the native installation'}
    $bin=$folder.TrimEnd('\')
    $other=@($env:PATH -split ';' | Where-Object { $_ -and $_.TrimEnd('\') -ine $bin })
    $env:PATH=(@($bin)+$other) -join ';'
    $success=$true
    Write-Output 'Kache is installed. Open the taskbar tray and double-click the owl.'
    Write-Output 'Remove it through Control Panel > Programs and Features, or Settings > Apps.'
    if($exitCode -eq 3010){Write-Output 'Windows reports that a restart is needed to finish replacing in-use files.'}
} finally {
    if($success){
        # Remove only known temporary files, never a computed tree.
        Remove-Item -LiteralPath $package,$log -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $temp -ErrorAction SilentlyContinue
    } else {Write-Output "Installer diagnostics kept in: $temp"}
}
'@)) -MsiUri 'https://github.com/simonmalm/kache/releases/download/v0.9.0/Kache-0.9.0-windows-x64.msi' -Sha256 'cee5a5a5d088c8d5741c702cbabb75f306ee9197d6fc205624328a159fc6708e'
