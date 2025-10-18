param(
  [string]$Bucket = "portfolio-artifacts",
  [string]$Prefix = "latest",
  [string]$Profile = "",             # e.g. "default" or "dev"
  [string]$Region  = "us-west-1"
)

$ErrorActionPreference = "Stop"
$profileArg = ($Profile -ne "") ? @("--profile", $Profile) : @()

Write-Host "1) Building React app…" -ForegroundColor Cyan
Push-Location ..\frontend
npm ci | Out-Host
npm run build | Out-Host
Pop-Location

Write-Host "2) Syncing build/ to s3://$Bucket/$Prefix/ …" -ForegroundColor Cyan
$buildPath = Join-Path -Path ..\frontend -ChildPath "build"
aws @profileArg s3 sync $buildPath "s3://$Bucket/$Prefix/" --delete --region $Region | Out-Host

Write-Host "Done ✅"
