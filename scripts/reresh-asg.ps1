param(
  [string]$AsgName = "midterm-asg",
  [string]$Profile = "",
  [string]$Region  = "us-west-1"
)

$profileArg = ($Profile -ne "") ? @("--profile", $Profile) : @()

Write-Host "Starting ASG instance refresh for $AsgName…" -ForegroundColor Cyan
aws @profileArg autoscaling start-instance-refresh `
  --auto-scaling-group-name $AsgName `
  --preferences '{
    "MinHealthyPercentage": 100,
    "InstanceWarmup": 300
  }' `
  --region $Region | Out-Host

Write-Host "Refresh started. Instances will roll to the new content on boot. ✅"
