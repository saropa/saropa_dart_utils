#Requires -Version 7
<#
.SYNOPSIS
Publishes a Dart/Flutter package to pub.dev and creates a corresponding GitHub release.

.DESCRIPTION
This PowerShell script automates the complete release workflow for a Dart/Flutter package:
  1. Runs all tests to ensure code quality
  2. Prompts for the semantic version number
  3. Updates pubspec.yaml with the new version
  4. Extracts release notes from CHANGELOG.md
  5. Publishes the package to pub.dev
  6. Commits and pushes changes to the repository
  7. Creates a Git tag and pushes it
  8. Creates a GitHub release with the extracted notes

The script exits immediately on any error to prevent partial releases.

.PARAMETER DryRun
If specified, performs all validation steps but skips actual publishing, commits, and releases.

.EXAMPLE
.\publish_pub_dev.ps1
Runs the full publish workflow interactively.

.EXAMPLE
.\publish_pub_dev.ps1 -DryRun
Validates the release process without making any changes.

.PREREQUISITES
  - Flutter SDK installed and in PATH
  - Git installed and configured
  - GitHub CLI (gh) installed and authenticated
  - Working directory must be a Git repository

.NOTES
  Version:   1.4
  Author:    Saropa
  Copyright: © 2024-present Saropa. All rights reserved.
  Website:   https://saropa.com
  Email:     dev.tools@saropa.com
#>

param(
    [switch]$DryRun
)

#==============================================================================
# CONFIGURATION
#==============================================================================

# Stop script execution immediately on any error
$ErrorActionPreference = 'Stop'

# Ensure we get proper exit codes from native commands
$PSNativeCommandUseErrorActionPreference = $true

#==============================================================================
# HELPER FUNCTIONS
#==============================================================================

<#
.SYNOPSIS
Displays the Saropa "S" logo in ASCII art with gradient colors.
#>
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

    # Copyright notice with dynamic year
    $currentYear = (Get-Date).Year
    $copyrightYear = if ($currentYear -gt 2024) { "2024-$currentYear" } else { "2024" }

    $coloredCopyright = @"
    $([char]0x1b)[38;5;195m© $copyrightYear Saropa. All rights reserved.
    $([char]0x1b)[38;5;117mhttps://saropa.com
"@
    Write-Host $coloredCopyright

    # Clickable email address for compatible terminals
    $email = "dev.tools@saropa.com"
    $esc = [char]27
    Write-Host "`r`n    $esc]8;;mailto:$email$esc\$email$esc]8;;$esc\`r`n"
}

<#
.SYNOPSIS
Exits the script with an error message if a command failed.
.PARAMETER Message
The error message to display before exiting.
#>
function Exit-OnError {
    param([string]$Message)

    if ($LASTEXITCODE -ne 0) {
        Write-Error "FAILED: $Message (exit code: $LASTEXITCODE)"
        exit $LASTEXITCODE
    }
}

<#
.SYNOPSIS
Checks that a required command-line tool is available.
.PARAMETER Command
The name of the command to check.
.PARAMETER InstallHint
Optional hint for how to install the tool if missing.
#>
function Assert-CommandExists {
    param(
        [string]$Command,
        [string]$InstallHint = ""
    )

    if (-not (Get-Command $Command -ErrorAction SilentlyContinue)) {
        $hint = if ($InstallHint) { " $InstallHint" } else { "" }
        Write-Error "Required command '$Command' not found.$hint"
        exit 1
    }
}

<#
.SYNOPSIS
Writes a section header to the console for visual clarity.
#>
function Write-Section {
    param([string]$Title)

    Write-Host ""
    Write-Host "=== $Title ===" -ForegroundColor Cyan
}

#==============================================================================
# MAIN SCRIPT EXECUTION
#==============================================================================

# Display ASCII art logo
Show-SaropaLogo

# Show dry-run mode warning if applicable
if ($DryRun) {
    Write-Host ""
    Write-Host "[DRY RUN MODE] No changes will be made." -ForegroundColor Yellow
    Write-Host ""
}

#------------------------------------------------------------------------------
# Step 1: Prerequisite Checks
#------------------------------------------------------------------------------
Write-Section "Checking Prerequisites"

Assert-CommandExists "flutter" "Install from https://flutter.dev"
Assert-CommandExists "git" "Install from https://git-scm.com"
Assert-CommandExists "gh" "Install from https://cli.github.com"

Write-Host "All required tools are available." -ForegroundColor Green

#------------------------------------------------------------------------------
# Step 2: Set Working Directory
#------------------------------------------------------------------------------
Write-Section "Setting Up Environment"

$scriptDir = $PSScriptRoot
$workingDir = Split-Path -Path $scriptDir -Parent

if (-not (Test-Path $workingDir)) {
    Write-Error "Working directory not found: $workingDir"
    exit 1
}

Set-Location -Path $workingDir
Write-Host "Working directory: $workingDir"

# Verify required files exist
if (-not (Test-Path "pubspec.yaml")) {
    Write-Error "pubspec.yaml not found in $workingDir"
    exit 1
}
if (-not (Test-Path "CHANGELOG.md")) {
    Write-Error "CHANGELOG.md not found in $workingDir"
    exit 1
}

# Verify we're in a git repository
if (-not (Test-Path ".git")) {
    Write-Error "Not a git repository. Initialize with 'git init' first."
    exit 1
}

#------------------------------------------------------------------------------
# Step 3: Run Tests
#------------------------------------------------------------------------------
Write-Section "Running Tests"

flutter test
Exit-OnError "Tests failed. Fix test failures before publishing."

Write-Host "All tests passed." -ForegroundColor Green

#------------------------------------------------------------------------------
# Step 4: Read Release Version from pubspec.yaml
#------------------------------------------------------------------------------
Write-Section "Release Version"

# Read version from pubspec.yaml (user should have already updated this)
$releaseNumber = (Get-Content pubspec.yaml | Select-String -Pattern "^version:\s*(.+)$").Matches.Groups[1].Value

# Validate semantic version format
if (-not ($releaseNumber -match "^\d+\.\d+\.\d+$")) {
    Write-Error "Invalid version format in pubspec.yaml. Use semantic versioning: MAJOR.MINOR.PATCH (e.g., 0.4.0)"
    exit 1
}

Write-Host "Version to publish: $releaseNumber" -ForegroundColor Green

#------------------------------------------------------------------------------
# Step 6: Extract Release Notes from CHANGELOG
#------------------------------------------------------------------------------
Write-Section "Extracting Release Notes"

$changelogContent = Get-Content "CHANGELOG.md" -Raw

# Try to extract notes for this specific version
# Pattern matches content between this version's header and the next version header
$pattern = "(?s)##\s*\[?$([regex]::Escape($releaseNumber))\]?[^\n]*\n(.*?)(?=##\s*\[?\d+\.\d+\.\d+|$)"
$match = [regex]::Match($changelogContent, $pattern)

if ($match.Success) {
    $releaseNotes = $match.Groups[1].Value.Trim()
} else {
    $releaseNotes = ""
}

if ([string]::IsNullOrWhiteSpace($releaseNotes)) {
    Write-Warning "No release notes found for version $releaseNumber in CHANGELOG.md."
    $useGeneric = Read-Host "Use generic message 'Release $releaseNumber'? (y/n)"
    if ($useGeneric -ne 'y') {
        Write-Error "Aborting. Please add release notes to CHANGELOG.md first."
        exit 1
    }
    $releaseNotes = "Release $releaseNumber"
} else {
    Write-Host "Release notes preview:" -ForegroundColor Cyan
    Write-Host $releaseNotes
}

#------------------------------------------------------------------------------
# Step 7: Confirm and Publish
#------------------------------------------------------------------------------
Write-Section "Publish Confirmation"

Write-Host ""
Write-Host "Ready to publish:" -ForegroundColor Cyan
Write-Host "  Version:    $releaseNumber"
Write-Host "  Tag:        v$releaseNumber"
Write-Host "  Repository: $(git remote get-url origin 2>$null)"
Write-Host ""

$publish = Read-Host "Publish to pub.dev and create GitHub release? (y/n)"
if ($publish -ne 'y') {
    Write-Host "Publish cancelled by user." -ForegroundColor Yellow
    exit 0
}

#------------------------------------------------------------------------------
# Step 8: Clean and Publish to pub.dev
#------------------------------------------------------------------------------
Write-Section "Publishing to pub.dev"

if ($DryRun) {
    Write-Host "[DRY RUN] Would run: flutter clean" -ForegroundColor Yellow
    Write-Host "[DRY RUN] Would run: flutter pub publish --force" -ForegroundColor Yellow
} else {
    flutter clean
    Exit-OnError "flutter clean failed"

    Write-Host "Publishing version $releaseNumber to pub.dev..."
    flutter pub publish --force
    Exit-OnError "Failed to publish package to pub.dev"

    Write-Host "Package published to pub.dev successfully." -ForegroundColor Green
}

#------------------------------------------------------------------------------
# Step 9: Git Commit and Push
#------------------------------------------------------------------------------
Write-Section "Committing Changes"

$tagName = "v$releaseNumber"

if ($DryRun) {
    Write-Host "[DRY RUN] Would run: git add pubspec.yaml CHANGELOG.md" -ForegroundColor Yellow
    Write-Host "[DRY RUN] Would run: git commit -m 'Release $tagName'" -ForegroundColor Yellow
    Write-Host "[DRY RUN] Would run: git push origin main" -ForegroundColor Yellow
} else {
    git add pubspec.yaml CHANGELOG.md
    Exit-OnError "git add failed"

    git commit -m "Release $tagName"
    Exit-OnError "git commit failed"

    git push origin main
    Exit-OnError "git push failed"

    Write-Host "Changes committed and pushed." -ForegroundColor Green
}

#------------------------------------------------------------------------------
# Step 10: Create and Push Git Tag
#------------------------------------------------------------------------------
Write-Section "Creating Git Tag"

if ($DryRun) {
    Write-Host "[DRY RUN] Would run: git tag -a $tagName -m 'Release $tagName'" -ForegroundColor Yellow
    Write-Host "[DRY RUN] Would run: git push origin $tagName" -ForegroundColor Yellow
} else {
    git tag -a $tagName -m "Release $tagName"
    Exit-OnError "git tag creation failed"

    git push origin $tagName
    Exit-OnError "git push tag failed"

    Write-Host "Tag $tagName created and pushed." -ForegroundColor Green
}

#------------------------------------------------------------------------------
# Step 11: Create GitHub Release
#------------------------------------------------------------------------------
Write-Section "Creating GitHub Release"

if ($DryRun) {
    Write-Host "[DRY RUN] Would run: gh release create $tagName" -ForegroundColor Yellow
} else {
    gh release create $tagName --title "Release $tagName" --notes "$releaseNotes"
    Exit-OnError "Failed to create GitHub release"

    Write-Host "GitHub release created successfully." -ForegroundColor Green
}

#------------------------------------------------------------------------------
# Complete
#------------------------------------------------------------------------------
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
if ($DryRun) {
    Write-Host " DRY RUN COMPLETE - No changes made" -ForegroundColor Yellow
} else {
    Write-Host " RELEASE $releaseNumber COMPLETE!" -ForegroundColor Green
}
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

if (-not $DryRun) {
    Write-Host "Next steps:"
    Write-Host "  - Verify package at: https://pub.dev/packages/saropa_dart_utils"
    Write-Host "  - Check release at:  https://github.com/saropa/saropa_dart_utils/releases/tag/$tagName"
}