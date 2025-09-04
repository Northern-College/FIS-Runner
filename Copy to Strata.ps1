# Define paths
$sourceRoot = "\\missql01\UNITE\FIS\Output"
$destPath = "C:\Orbital\StrataFileService\Watch"
$destFileName = "FIS-CSV 2024.zip"

# Get all ILR folders and extract sortable date-time-version component
$folders = Get-ChildItem -Path $sourceRoot -Directory |
    Where-Object { $_.Name -match '^ILR-\d+-\d+-\d{8}-\d{6}-\d{2}$' } |
    Sort-Object {
        if ($_ -match '^ILR-\d+-\d+-(\d{8})-(\d{6})-(\d{2})$') {
            "$($matches[1])$($matches[2])$($matches[3])"
        } else {
            "0"
        }
    } -Descending

if ($folders.Count -eq 0) {
    Write-Host "No matching folders found."
    exit 1
}

$latestFolder = $folders[0].FullName

# Find the latest zip file inside the latest folder
$zipFile = Get-ChildItem -Path $latestFolder -Filter '*.zip' |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if (-not $zipFile) {
    Write-Host "No ZIP file found in $latestFolder"
    exit 2
}

# Ensure destination folder exists
if (-not (Test-Path $destPath)) {
    New-Item -Path $destPath -ItemType Directory | Out-Null
}

# Copy and rename the zip file to destination
Copy-Item -Path $zipFile.FullName -Destination (Join-Path $destPath $destFileName) -Force

Write-Host "Copied and renamed to $destFileName in $destPath"


exit 0