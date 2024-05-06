if ([System.Environment]::GetEnvironmentVariable('CLEANER_STATUS', 'Machine')) {
    [System.Environment]::SetEnvironmentVariable('CLEANER_STATUS', 'OFF', 'Machine')
    Write-Output "CLEANER_STATUS has been set to OFF."
} else {
    Write-Output "CLEANER_STATUS does not exist."
}

$remoteDesktopCleanerProcess = Get-Process | Where-Object {$_.Path -like "*RemoteDesktopCleaner.exe*"}

if ($remoteDesktopCleanerProcess) {
    Stop-Process -Name "RemoteDesktopCleaner" -Force
    Write-Output "RemoteDesktopCleaner process has been stopped."
} else {
    Write-Output "RemoteDesktopCleaner process is not running."
}