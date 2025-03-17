# Immich API Configuration
$ImmichServer = "http://192.168.1.21:9000"
$ApiKey = "5z5Hh053242352345243532453245342534253425342532453425342z4zKCEtZetP2kc"
$LibraryPath = "Z:\OneDrive\"

# Function to Check and Install PowerShell 7
function Ensure-PowerShell7 {
    $psVersion = $PSVersionTable.PSVersion.Major
    if ($psVersion -lt 7) {
        Write-Host "PowerShell 7+ is required. Installing now..." -ForegroundColor Yellow

        # Correct official Microsoft URL
        $InstallerUrl = "https://github.com/PowerShell/PowerShell/releases/latest/download/PowerShell-7.3.9-win-x64.msi"
        $InstallerPath = "$env:TEMP\PowerShell-7.msi"

        # Download the installer
        try {
            Write-Host "Downloading PowerShell 7..." -ForegroundColor Cyan
            Invoke-WebRequest -Uri $InstallerUrl -OutFile $InstallerPath
        } catch {
            Write-Host "Failed to download PowerShell 7. Please download and install manually from:" -ForegroundColor Red
            Write-Host "https://github.com/PowerShell/PowerShell/releases/latest" -ForegroundColor Cyan
            exit
        }

        # Install PowerShell 7
        Write-Host "Installing PowerShell 7, please wait..." -ForegroundColor Yellow
        Start-Process msiexec.exe -ArgumentList "/i $InstallerPath /quiet /norestart" -Wait

        Write-Host "PowerShell 7 installed. Please restart your terminal and run the script again." -ForegroundColor Green
        exit
    } else {
        Write-Host "PowerShell 7+ detected. Continuing..." -ForegroundColor Cyan
    }
}

# Function to Check and Install PSImmich
function Ensure-PSImmich {
    if (-not (Get-Module -ListAvailable -Name PSImmich)) {
        Write-Host "Installing PSImmich module..." -ForegroundColor Yellow
        Install-Module PSImmich -Force -Scope CurrentUser
    } else {
        Write-Host "PSImmich module detected. Continuing..." -ForegroundColor Cyan
    }
    Import-Module PSImmich
}

# Ensure PowerShell 7 is installed
Ensure-PowerShell7

# Ensure PSImmich is installed and loaded
Ensure-PSImmich

# Connect to Immich
Write-Host "Connecting to Immich..." -ForegroundColor Cyan
Connect-Immich -BaseURL $ImmichServer -AccessToken $ApiKey

# Retrieve all files from the library path
$Files = Get-ChildItem -Path $LibraryPath -File -Recurse
$TotalFiles = $Files.Count
$UploadedFiles = 0

# Start the upload process
$StartTime = Get-Date
Write-Host "Starting import of $TotalFiles files from $LibraryPath..." -ForegroundColor Cyan

foreach ($File in $Files) {
    $FileStartTime = Get-Date

    # Progress display
    $PercentComplete = [math]::Round(($UploadedFiles / $TotalFiles) * 100, 2)
    Write-Progress -Activity "Importing Library to Immich" `
                   -Status "Uploading: $($File.Name) ($UploadedFiles/$TotalFiles)" `
                   -PercentComplete $PercentComplete

    try {
        # Import the asset
        Import-IMAsset -FilePath $File.FullName

        $UploadedFiles++
        $FileTime = [math]::Round(((Get-Date) - $FileStartTime).TotalSeconds, 2)
        Write-Host "Uploaded: $($File.Name) ($UploadedFiles/$TotalFiles) in $FileTime seconds" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed: $($File.Name) - $_" -ForegroundColor Red
    }
}

# Final summary
$TotalTimeTaken = [math]::Round(((Get-Date) - $StartTime).TotalMinutes, 2)
Write-Host "Library Import Completed! Uploaded $UploadedFiles/$TotalFiles files in $TotalTimeTaken minutes." -ForegroundColor Cyan
