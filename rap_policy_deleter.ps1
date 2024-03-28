param(
    [string]$serverName,
    [string[]]$rapNamesToDelete
)

$namespacePath = "root\CIMV2\TerminalServices"
$oldGatewayServerHost = "\\$($serverName).cern.ch"
$query = "SELECT * FROM Win32_TSGatewayResourceAuthorizationPolicy"

function Delete-RAP {
    param (
        $session,
        $rapInstance,
        $rapName
    )

    try {
        $result = $session.InvokeMethod($rapInstance, "Delete", $null)
        Write-Host "Deleted RAP '$rapName'."
        return $true

    } catch {
        Write-Host "Error deleting RAP '$rapName': $_"
        return $false
    }
}

try {
    $session = New-CimSession -ComputerName $serverName
    $queryInstance = Get-CimInstance -Query $query -Namespace $namespacePath -CimSession $session

    $filteredInstances = $queryInstance | Where-Object { $rapNamesToDelete -contains $_.CimInstanceProperties["Name"].Value.ToString() }

    foreach ($rapInstance in $filteredInstances) {
        $rapName = $rapInstance.CimInstanceProperties["Name"].Value
        if ($rapNamesToDelete -contains $rapName) {
            $deleted = Delete-RAP -session $session -rapInstance $rapInstance -rapName $rapName
        }
    }
} catch {
    Write-Host "Error while getting rap names from gateway: '$serverName'. $_"
} finally {
    if ($session) {
        $session | Remove-CimSession
    }
}
