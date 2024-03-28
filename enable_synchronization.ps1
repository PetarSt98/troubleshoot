if ([System.Environment]::GetEnvironmentVariable('CLEANER_STATUS', 'Machine')) {
    [System.Environment]::SetEnvironmentVariable('CLEANER_STATUS', 'OFF', 'Machine')
    Write-Output "CLEANER_STATUS has been set to OFF."
} else {
    Write-Output "CLEANER_STATUS does not exist."
}
