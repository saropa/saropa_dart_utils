# PowerShell script to publish a Dart/Flutter package to pub.dev

# Get the directory where the script is located
$scriptDir = $PSScriptRoot

# Set the working directory to the parent directory of the script's directory
$workingDir = Split-Path -Path $scriptDir -Parent

# Navigate to the working directory
Set-Location -Path $workingDir

# Run tests to ensure everything is good
Write-Output "Running tests..."
flutter test

# Check if tests passed
if ($LASTEXITCODE -ne 0) {
    Write-Output "Tests failed. Aborting publish."
    exit 1
}

# Ask the user if they want to publish the package to pub.dev
$publish = Read-Host "Do you want to publish the package to pub.dev? (y/n)"
if ($publish -eq 'y') {
    # Clean the build directory
    flutter clean

    # Get the version from pubspec.yaml
    $pubspec = Get-Content pubspec.yaml
    $version = ($pubspec | Select-String -Pattern '^version:').Line.Split(':')[1].Trim()

    Write-Output "Publishing version $version..."

    # Publish the package to pub.dev
    flutter pub publish --force

    Write-Output "Package published to pub.dev successfully."
} else {
    Write-Output "Package not published."
}
