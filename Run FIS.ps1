# Configurable settings - Array of configurations
$configurations = @(
    @{
        Enabled = $true
        Name = "ILR 2024"
        IlrFolder = "\\missql01\c$\capita\ILR\2024\Nightly"
        FisPath = "\\missql01\UNITE\FIS\2024\DC-ILR-2425-FIS-Desktop.2425.11\ESFA.DC.ILR.Desktop.CLI.exe"
        OutputFolder = "\\missql01\UNITE\FIS\Output\2024"
        ConnectionString = "Data Source=MISSQL01\ulive;Initial Catalog=ILR2425;Integrated Security=True;TrustServerCertificate=true"
    }
    @{
        Enabled = $true
        Name = "ILR 2025"
        IlrFolder = "\\missql01\c$\capita\ILR\2025\Nightly"
        FisPath = "\\missql01\UNITE\FIS\2025\DC-ILR-2526-FIS-Desktop.2526.1\ESFA.DC.ILR.Desktop.CLI.exe"
        OutputFolder = "\\missql01\UNITE\FIS\Output\2025"
        ConnectionString = "Data Source=MISSQL01\ulive;Initial Catalog=ILR2526;Integrated Security=True;TrustServerCertificate=true"
    }
)

# Function to invoke FIS for a single configuration
function Invoke-FISConfiguration {
    param(
        [hashtable]$config
    )
    
    Write-Host "Processing configuration: $($config.Name)"

    # Skip if not enabled
    if (-not $config.Enabled) {
        Write-Host "Skipping configuration $($config.Name) as it is not enabled"
        return $true
    }

    # Get matching ILR files
    $filePaths = Get-ChildItem -Path $config.IlrFolder -Filter "ILR-????????-????-????????-??????-??.xml" -File

    if ($filePaths.Count -eq 0) {
        Write-Host "No ILR file found for configuration: $($config.Name)"
        return $false
    }

    # Sort files and get the latest one
    $sortedFiles = $filePaths | Sort-Object Name
    $ilrFile = $sortedFiles[-1].FullName

    Write-Host "Using ILR file: $ilrFile"

    # Prepare arguments
    $arguments = "-f `"$ilrFile`" -o `"$($config.OutputFolder)`" -c `"$($config.ConnectionString)`" -d `"Y`" "

    Write-Host "Using arguments: $arguments"

    # Start the FIS process
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $config.FisPath
    $startInfo.WorkingDirectory = [System.IO.Path]::GetDirectoryName($config.FisPath)
    $startInfo.Arguments = $arguments
    $startInfo.UseShellExecute = $false

    $process = [System.Diagnostics.Process]::Start($startInfo)
    $process.WaitForExit()
    
    if ($process.ExitCode -eq 0) {
        Write-Host "Successfully processed configuration: $($config.Name)"
        return $true
    } else {
        Write-Host "Failed to process configuration: $($config.Name) (Exit code: $($process.ExitCode))"
        return $false
    }
}

# Process each configuration
$allSuccessful = $true
foreach ($config in $configurations) {
    $success = Invoke-FISConfiguration -config $config
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
