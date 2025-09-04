# Configurable settings
$ilrFolder = "\\missql01\c$\capita\ILR\2024\Nightly"
$fisPath = "\\missql01\UNITE\FIS\2024\DC-ILR-2425-FIS-Desktop.2425.10\ESFA.DC.ILR.Desktop.CLI.exe"
$outputFolder = "\\missql01\UNITE\FIS\Output"
$connectionString = "Data Source=MISSQL01\ulive;Initial Catalog=ILR2425;Integrated Security=True;TrustServerCertificate=true"

# Get matching ILR files
$filePaths = Get-ChildItem -Path $ilrFolder -Filter "ILR-????????-????-????????-??????-??.xml" -File

if ($filePaths.Count -eq 0) {
    Write-Host "No ILR file found."
    exit 1
}

# Sort files and get the latest one
$sortedFiles = $filePaths | Sort-Object Name
$ilrFile = $sortedFiles[-1].FullName

Write-Host "Using ILR file: $ilrFile"

# Prepare arguments
$arguments = "-f `"$ilrFile`" -o `"$outputFolder`" -c `"$connectionString`" -d `"Y`" "

Write-Host "Using arguments: $arguments"

# Start the FIS process
$startInfo = New-Object System.Diagnostics.ProcessStartInfo
$startInfo.FileName = $fisPath
$startInfo.WorkingDirectory = [System.IO.Path]::GetDirectoryName($fisPath)
$startInfo.Arguments = $arguments
$startInfo.UseShellExecute = $false

$process = [System.Diagnostics.Process]::Start($startInfo)
$process.WaitForExit()

exit 0
