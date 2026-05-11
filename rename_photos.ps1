[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$rootPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$imageExtensions = @('.jpg', '.jpeg', '.png', '.heic', '.gif', '.bmp', '.mp4', '.mov')

$folders = Get-ChildItem -Path $rootPath -Directory

if ($folders.Count -eq 0) {
    Write-Host "No folders found."
    exit
}

foreach ($folder in $folders) {
    $title = $folder.Name

    $files = Get-ChildItem -Path $folder.FullName -File |
             Where-Object { $imageExtensions -contains $_.Extension.ToLower() } |
             Sort-Object LastWriteTime

    if ($files.Count -eq 0) {
        Write-Host "[$title] No images, skipping"
        continue
    }

    Write-Host "[$title] Processing $($files.Count) files..."

    $items = @()
    $counter = 1
    foreach ($file in $files) {
        $tempName = "__TEMP__${counter}$($file.Extension)"
        Rename-Item -Path $file.FullName -NewName $tempName -ErrorAction Stop
        $items += [PSCustomObject]@{ Temp = $tempName; Index = $counter; Ext = $file.Extension }
        $counter++
    }

    foreach ($item in $items) {
        $tempPath = Join-Path $folder.FullName $item.Temp
        $finalName = "${title}-$($item.Index)$($item.Ext)"
        Rename-Item -Path $tempPath -NewName $finalName -ErrorAction Stop
        Write-Host "  $($item.Index) -> $finalName"
    }
}