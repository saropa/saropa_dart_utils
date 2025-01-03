#Requires -Version 7
<#
.SYNOPSIS
Generates and optionally uploads Flutter project documentation to the gh-pages branch.

.DESCRIPTION
This PowerShell script automates the process of generating Flutter project documentation using `dartdoc` and optionally uploading it to the `gh-pages` branch of a Git repository. It cleans the output directory, activates `dartdoc` if necessary, generates the documentation, checks for common warnings, and handles the Git operations for committing and pushing the documentation to the `gh-pages` branch.

.NOTES
  Version:   2.9
  Author:    Saropa
  Copyright: © 2024 Saropa. All rights reserved.
  Website:   https://saropa.com
  Email:     dev.tools@saropa.com
#>

# Function to display the Saropa "S" logo in ASCII art
function Show-SaropaLogo {
    Write-Host @"

$([char]0x1b)[38;5;208m                               ....$([char]0x1b)[0m
$([char]0x1b)[38;5;208m                       `-+shdmNMMMMNmdhs+-$([char]0x1b)[0m
$([char]0x1b)[38;5;209m                    -odMMMNyo/-..````.++:+o+/-$([char]0x1b)[0m
$([char]0x1b)[38;5;215m                 `/dMMMMMM/`               ``````````$([char]0x1b)[0m
$([char]0x1b)[38;5;220m                `dMMMMMMMMNdhhhdddmmmNmmddhs+-$([char]0x1b)[0m
$([char]0x1b)[38;5;226m                /MMMMMMMMMMMMMMMMMMMMMMMMMMMMMNh/$([char]0x1b)[0m
$([char]0x1b)[38;5;190m              . :sdmNNNNMMMMMNNNMMMMMMMMMMMMMMMMm+$([char]0x1b)[0m
$([char]0x1b)[38;5;154m              o     `..~~~::~+==+~:/+sdNMMMMMMMMMMMo$([char]0x1b)[0m
$([char]0x1b)[38;5;118m              m                        .+NMMMMMMMMMN$([char]0x1b)[0m
$([char]0x1b)[38;5;123m              m+                         :MMMMMMMMMm$([char]0x1b)[0m
$([char]0x1b)[38;5;87m              /N:                        :MMMMMMMMM/$([char]0x1b)[0m
$([char]0x1b)[38;5;51m               oNs.                    `+NMMMMMMMMo$([char]0x1b)[0m
$([char]0x1b)[38;5;45m                :dNy/.              ./smMMMMMMMMm:$([char]0x1b)[0m
$([char]0x1b)[38;5;39m                 `/dMNmhyso+++oosydNNMMMMMMMMMd/$([char]0x1b)[0m
$([char]0x1b)[38;5;33m                    .odMMMMMMMMMMMMMMMMMMMMdo-$([char]0x1b)[0m
$([char]0x1b)[38;5;57m                       `-+shdNNMMMMNNdhs+-$([char]0x1b)[0m
$([char]0x1b)[38;5;57m                               ````$([char]0x1b)[0m

"@ -ForegroundColor Green

    # Copyright notice with color, indentation, and email
    $coloredCopyright = @"
    $([char]0x1b)[38;5;195m© 2024 Saropa. All rights reserved.
    $([char]0x1b)[38;5;117mhttps://saropa.com
"@
    Write-Host $coloredCopyright

    # Clickable email address for compatible terminals
    $email = "dev.tools@saropa.com"
    $esc = [char]27
    Write-Host "`r`n    $esc]8;;mailto:$email$esc\$email$esc]8;;$esc\`r`n" # Added indent and line breaks
}

# Display ASCII art logo with color
Show-SaropaLogo

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

# Generate documentation
flutter pub get
dart doc .

# Check if the documentation is created
$apiDocPath = Join-Path $docOutputDir "api"
if (Test-Path $apiDocPath) {
    Write-Output "Documentation generated successfully in $apiDocPath."
} else {
    Write-Output "Failed to generate documentation."
    exit 1
}

# Check for common warnings (optional)
$logPath = Join-Path $workingDir "dartdoc-log.txt"
# dart doc command already sends output to stdout, so no need to redirect here

# Check the log for common issues
$logContent = Get-Content $logPath -ErrorAction SilentlyContinue

# Unresolved doc reference
if ($logContent -match "warning: unresolved doc reference") {
    Write-Output "Warning: Unresolved doc reference found in dartdoc-log.txt."
}

# Broken links
if ($logContent -match "dartdoc generated a broken link") {
    Write-Output "Warning: Broken links detected in dartdoc-log.txt."
}

# Ask the user if they want to upload the documentation
$upload = Read-Host "Do you want to upload the documentation to the gh-pages branch? (y/n)"
if ($upload -eq 'y') {
    # Check for uncommitted changes
    $status = git status --porcelain
    if ($status) {
        Write-Warning "You have uncommitted changes. Please commit or stash them before proceeding."
        exit 1
    }

    # Check if gh-pages branch exists locally
    $localBranchExists = git branch --list gh-pages

    if ($localBranchExists) {
        # Switch to gh-pages branch
        git checkout gh-pages
    } else {
        # Create new gh-pages branch
        git checkout --orphan gh-pages
    }

    # Clean the doc/api directory before copying
    $docApiDir = Join-Path $docOutputDir "api"
    if (Test-Path $docApiDir) {
        Remove-Item $docApiDir -Recurse -Force
    }

    # Copy the newly generated documentation
    Copy-Item -Path $apiDocPath -Destination $docOutputDir -Recurse -Force

    # Add and commit the changes
    git add doc
    git commit -m "Update generated documentation"

    # Push to remote gh-pages branch (force push to overwrite)
    git push origin gh-pages --force

    Write-Output "Documentation uploaded to gh-pages branch successfully."

    # Switch back to the main branch (or whichever branch you were on)
    git checkout main  # Or git checkout - to switch to the previous branch
} else {
    Write-Output "Documentation not uploaded."
}