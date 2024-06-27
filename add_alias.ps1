param(
    [string]$target_username,
    [string]$target_password
)

$target_hostname = "dbod-remotedesktop.cern.ch"
$target_database = "RemoteDesktop"
$target_port = "5500"

# Load the MySql.Data.dll assembly
Add-Type -Path "C:\Program Files (x86)\MySQL\MySQL Connector NET 8.0.32\Assemblies\v4.5.2\MySql.Data.dll"

# Create a connection to the target MySQL database
$target_conn = New-Object MySql.Data.MySqlClient.MySqlConnection("Server=$target_hostname;Port=$target_port;Uid=$target_username;Pwd=$target_password;Database=$target_database;")
$target_conn.Open()

# Prompt for username, device name, and owner name
$username = (Read-Host "Enter the username").ToLower()
$deviceName = (Read-Host "Enter the device name").ToUpper()
$ownerName = (Read-Host "Enter the owner name").ToLower()

# Check if the username already exists in the RAP table
$queryCheckRAP = "SELECT COUNT(*) FROM `RemoteDesktop`.`RAP` WHERE name = 'RAP_$username'"
$cmdCheckRAP = New-Object MySql.Data.MySqlClient.MySqlCommand($queryCheckRAP, $target_conn)
$rapExists = [int]$cmdCheckRAP.ExecuteScalar()

# If the username does not exist, insert a new row into the RAP table
if ($rapExists -eq 0) {
    $queryInsertRAP = @"
    INSERT INTO `RemoteDesktop`.`RAP` (name, description, login, port, enabled, resourceGroupName, resourceGroupDescription, synchronized, lastModified, toDelete, unsynchronizedGateways)
    VALUES ('RAP_$username', '', '$username', '3389', 1, 'LG-$username', '', 0, NOW(), 0, '')
"@
    $cmdInsertRAP = New-Object MySql.Data.MySqlClient.MySqlCommand($queryInsertRAP, $target_conn)
    $cmdInsertRAP.ExecuteNonQuery() | Out-Null
    Write-Host "Inserted new row into RAP table."
} else {
    Write-Host "A row with the username 'RAP_$username' already exists in the RAP table. Skipping insertion."
}

# Check if the combination of username and device name already exists in the RAP_Resource table
$queryCheckRAPResource = "SELECT COUNT(*) FROM `RemoteDesktop`.`RAP_Resource` WHERE RAPName = 'RAP_$username' AND resourceName = '$deviceName'"
$cmdCheckRAPResource = New-Object MySql.Data.MySqlClient.MySqlCommand($queryCheckRAPResource, $target_conn)
$rapResourceExists = [int]$cmdCheckRAPResource.ExecuteScalar()

# If the combination does not exist, insert a new row into the RAP_Resource table
if ($rapResourceExists -eq 0) {
    $queryInsertRAPResource = @"
    INSERT INTO `RemoteDesktop`.`RAP_Resource` (RAPName, resourceName, resourceOwner, access, synchronized, invalid, exception, createDate, updateDate, toDelete, unsynchronizedGateways, alias)
    VALUES ('RAP_$username', '$deviceName', 'CERN\\$ownerName', 1, 0, 0, 0, NOW(), NOW(), 0, '', 1)
"@
    $cmdInsertRAPResource = New-Object MySql.Data.MySqlClient.MySqlCommand($queryInsertRAPResource, $target_conn)
    $cmdInsertRAPResource.ExecuteNonQuery() | Out-Null
    Write-Host "Inserted new row into RAP_Resource table."
} else {
    Write-Host "A row with the username 'RAP_$username' and device name '$deviceName' already exists in the RAP_Resource table. Skipping insertion."
}

# Close the connection
$target_conn.Close()
