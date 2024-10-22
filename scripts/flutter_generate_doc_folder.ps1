# PowerShell script to generate and upload Flutter documentation
# Get the directory where the script is located
$scriptDir = $PSScriptRoot

# Set the working directory to the parent directory of the script's directory
$workingDir = Split-Path -Path $scriptDir -Parent

# Navigate to the working directory
Set-Location -Path $workingDir

# Define the documentation output directory
$docOutputDir = Join-Path $workingDir "doc"

# Clean the documentation directory
if (Test-Path $docOutputDir) {
    Remove-Item $docOutputDir -Recurse -Force
    Write-Output "Cleaned the documentation directory."
}

# Run Flutter command to generate documentation
flutter pub global activate dartdoc
flutter pub global run dartdoc

# Check if the documentation is created
$apiDocPath = Join-Path $docOutputDir "api"
if (Test-Path $apiDocPath) {
    Write-Output "Documentation generated successfully in $apiDocPath."
} else {
    Write-Output "Failed to generate documentation."
    exit 1
}

# Optional: Check for common warnings
$logPath = Join-Path $workingDir "dartdoc-log.txt"
flutter pub global run dartdoc > $logPath

# Check the log for common issues
$logContent = Get-Content $logPath

# Unresolved doc reference
if ($logContent -match "warning: unresolved doc reference") {
    Write-Output "Warning: Unresolved doc reference found."
}

# Broken links
if ($logContent -match "dartdoc generated a broken link") {
    Write-Output "Warning: Broken links detected."
}

# Ask the user if they want to upload the documentation
$upload = Read-Host "Do you want to upload the documentation to the gh-pages branch? (y/n)"
if ($upload -eq 'y') {
    # Uploading to gh-pages branch
    git checkout --orphan gh-pages
    mkdir -p doc/api
    cp -r $apiDocPath/* doc/api/
    git add doc
    git commit -m "Update generated documentation"
    git push origin gh-pages --force
    Write-Output "Documentation uploaded to gh-pages branch successfully."
} else {
    Write-Output "Documentation not uploaded."
}
