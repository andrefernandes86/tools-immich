# Immich API Configuration
$ImmichServer = "http://192.168.1.21:9000"
$ApiKey = "5z5Hh1212121212121212121212121212tZetP2kc"
$FolderPath = "Z:\OneDrive\Photos"

# Retrieve files
$Files = Get-ChildItem -Path $FolderPath -File
$TotalFiles = $Files.Count
$UploadedFiles = 0
$UploadUrl = "$ImmichServer/api/asset/upload"
$Headers = @{
    "x-api-key" = $ApiKey
}

# Start upload timer
$StartTime = Get-Date

foreach ($File in $Files) {
    $FileStartTime = Get-Date

    # Progress bar
    $PercentComplete = [math]::Round(($UploadedFiles / $TotalFiles) * 100, 2)
    Write-Progress -Activity "Uploading Files to Immich" `
                   -Status "Uploading: $($File.Name) ($UploadedFiles/$TotalFiles)" `
                   -PercentComplete $PercentComplete

    try {
        $FileStream = [System.IO.File]::OpenRead($File.FullName)
        $Form = @{ file = $FileStream }

        Invoke-RestMethod -Uri $UploadUrl -Headers $Headers -Method Post -Form $Form

        $FileStream.Dispose()

        $UploadedFiles++
        $FileTime = [math]::Round(((Get-Date) - $StartTime).TotalSeconds, 2)
        Write-Host "Uploaded: $($File.Name) ($UploadedFiles/$TotalFiles) in $TimeTaken seconds" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed: $($File.Name) - $_" -ForegroundColor Red
    }
}

# Final summary
$TotalTimeTaken = [math]::Round(((Get-Date) - $StartTime).TotalMinutes, 2)
Write-Host "Upload Completed! Uploaded $UploadedFiles/$TotalFiles files in $TotalTimeTaken minutes." -ForegroundColor Cyan
