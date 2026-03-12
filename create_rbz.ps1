Add-Type -AssemblyName System.IO.Compression.FileSystem

$basePath = "c:\Users\User\Desktop\SKP"
$rbzPath = Join-Path $basePath "dwg_material_recolor.rbz"
$tempDir = Join-Path $env:TEMP "rbz_temp"

# Clean up
if (Test-Path $rbzPath) { Remove-Item $rbzPath -Force }
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }

# Create temp structure
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $tempDir "dwg_material_recolor") -Force | Out-Null

# Copy files
Copy-Item (Join-Path $basePath "dwg_material_recolor.rb") (Join-Path $tempDir "dwg_material_recolor.rb")
Copy-Item (Join-Path $basePath "dwg_material_recolor\main.rb") (Join-Path $tempDir "dwg_material_recolor\main.rb")

# Create zip then rename to rbz
$zipPath = Join-Path $env:TEMP "dwg_material_recolor.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
[System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $zipPath)
Move-Item $zipPath $rbzPath -Force

# Clean up temp
Remove-Item $tempDir -Recurse -Force

Write-Host "SUCCESS: RBZ created at $rbzPath"
