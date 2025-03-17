# Immich API Configuration
$ImmichServer = "http://your-immich-server"  # Replace with your Immich server URL
$ApiKey = "your-api-key-here"  # Replace with your Immich API Key
$FolderPath = "C:\Path\To\Your\Files"  # Replace with the folder containing your files

# Get all files in the folder
$Files = Get-ChildItem -Path $FolderPath -File
$TotalFiles = $Files.Count
$UploadedFiles = 0
$UploadUrl = "$ImmichServer/api/asset/upload"

# Headers for API Authentication
$Headers = @{
    "x-api-key" = $ApiKey
}

# Start Uploading
$StartTime = Get-Date

foreach ($File in $Files) {
    $FileName = $File.Name
    $FilePath = $File.FullName

    # Start file upload timer
    $FileStartTime = Get-Date

    # Display progress bar
    $PercentComplete = [math]::Round(($UploadedFiles / $TotalFiles) * 100, 2)
    Write-Progress -Activity "Uploading Files to Immich" -Status "Uploading: $FileName ($UploadedFiles/$TotalFiles)" -PercentComplete $PercentComplete

    try {
        # Prepare file stream
        $FileStream = [System.IO.File]::OpenRead($FilePath)
        $FileContent = @{
            "file" = New-Object System.Net.Http.StreamContent($FileStream)
        }
        $FileContent["file"].Headers.ContentDisposition = "form-data; name=`"file`"; filename=`"$FileName`""
        $FileContent["file"].Headers.ContentType = "application/octet-stream"

        # Upload file
        $Response = Invoke-RestMethod -Uri $UploadUrl -Headers $Headers -Method Post -Form $FileContent

        # Close file stream
        $FileStream.Dispose()

        # File upload completed
        $UploadedFiles++

        # Calculate time taken
        $FileEndTime = Get-Date
        $TimeTaken = ($FileEndTime - $FileStartTime).TotalSeconds
        Write-Host "✔️ Uploaded: $FileName ($UploadedFiles/$TotalFiles) - Time taken: $TimeTaken seconds" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to upload: $FileName - Error: $_" -ForegroundColor Red
    }
}

# Total time taken for batch upload
$EndTime = Get-Date
$TotalTimeTaken = ($EndTime - $StartTime).TotalMinutes
Write-Host "✅ Upload Completed! Total files: $UploadedFiles/$TotalFiles - Total Time: $TotalTimeTaken minutes" -ForegroundColor Cyan
