# Configurable settings - Array of configurations
$configurations = @(
    @{
        Name = "FIS 2024"
        SourceRoot = "\\missql01\UNITE\FIS\Output"
        DestPath = "C:\Orbital\StrataFileService\Watch"
        DestFileName = "FIS-CSV 2024.zip"
        FilterYear = "2425"  # Year format in ILR filename (e.g., 2425 for 2024-25)
    }
    @{
        Name = "FIS 2025"
        SourceRoot = "\\missql01\UNITE\FIS\Output"
        DestPath = "C:\Orbital\StrataFileService\Watch"
        DestFileName = "FIS-CSV 2025.zip"
        FilterYear = "2526"  # Year format in ILR filename (e.g., 2526 for 2025-26)
    }
)

# Function to copy files for a single configuration
function Copy-StrataFiles {
    param(
        [hashtable]$config
    )
    
    Write-Host "Processing configuration: $($config.Name)"
    Write-Host "Filtering for year: $($config.FilterYear)"
    
    # Get all ILR folders matching the year filter and extract sortable date-time-version component
    $folders = Get-ChildItem -Path $config.SourceRoot -Directory |
        Where-Object { 
            # Match the ILR pattern and filter by the specified year
            $_.Name -match "^ILR-\d+-$($config.FilterYear)-\d{8}-\d{6}-\d{2}$" 
        } |
        Sort-Object {
            if ($_ -match '^ILR-\d+-\d+-(\d{8})-(\d{6})-(\d{2})$') {
                "$($matches[1])$($matches[2])$($matches[3])"
            } else {
                "0"
            }
        } -Descending

    if ($folders.Count -eq 0) {
        Write-Host "No matching ILR folders found for year $($config.FilterYear) in configuration: $($config.Name)"
        return $false
    }

    $latestFolder = $folders[0].FullName

    # Find the latest zip file inside the latest folder
    $zipFile = Get-ChildItem -Path $latestFolder -Filter '*.zip' |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $zipFile) {
        Write-Host "No ZIP file found in $latestFolder for configuration: $($config.Name)"
        return $false
    }

    # Ensure destination folder exists
    if (-not (Test-Path $config.DestPath)) {
        New-Item -Path $config.DestPath -ItemType Directory | Out-Null
    }

    # Copy and rename the zip file to destination
    $destinationFile = Join-Path $config.DestPath $config.DestFileName
    Copy-Item -Path $zipFile.FullName -Destination $destinationFile -Force

    Write-Host "Copied and renamed to $($config.DestFileName) in $($config.DestPath)"
    return $true
}

# Process each configuration
$allSuccessful = $true
foreach ($config in $configurations) {
    $success = Copy-StrataFiles -config $config
    if (-not $success) {
        $allSuccessful = $false
    }
    Write-Host "----------------------------------------"
}

if ($allSuccessful) {
    Write-Host "All configurations processed successfully."
    exit 0
} else {
    Write-Host "One or more configurations failed."
    exit 1
}