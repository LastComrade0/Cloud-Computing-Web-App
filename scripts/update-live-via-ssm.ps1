param(
  [string]$AsgName = "midterm-asg",
  [string]$Bucket  = "portfolio-artifacts",
  [string]$Prefix  = "latest",
  [string]$Profile = "",
  [string]$Region  = "us-west-1"
)

$profileArg = ($Profile -ne "") ? @("--profile", $Profile) : @()

$commands = @(
  "aws s3 sync s3://$Bucket/$Prefix/ /usr/share/nginx/html/ --delete",
  "sudo nginx -t && sudo systemctl reload nginx || sudo systemctl restart nginx"
)

$paramJson = @{ commands = $commands } | ConvertTo-Json -Compress

Write-Host "Sending SSM Run Command to ASG: $AsgName" -ForegroundColor Cyan
aws @profileArg ssm send-command `
  --document-name "AWS-RunShellScript" `
  --parameters $paramJson `
  --targets "Key=tag:aws:autoscaling:groupName,Values=$AsgName" `
  --comment "Hot update portfolio content from S3" `
  --region $Region | Out-Host

Write-Host "Command sent. Fleet will update in-place. ✅"
