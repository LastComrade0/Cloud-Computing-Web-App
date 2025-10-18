param(
  [ValidateSet("refresh","hot")] [string]$Mode = "refresh",
  [string]$Bucket  = "portfolio-artifacts",
  [string]$Prefix  = "latest",
  [string]$AsgName = "midterm-asg",
  [string]$Profile = "",
  [string]$Region  = "us-west-1"
)

& "$PSScriptRoot\deploy-frontend.ps1" -Bucket $Bucket -Prefix $Prefix -Profile $Profile -Region $Region

if ($Mode -eq "refresh") {
  & "$PSScriptRoot\refresh-asg.ps1" -AsgName $AsgName -Profile $Profile -Region $Region
} else {
  & "$PSScriptRoot\update-live-via-ssm.ps1" -AsgName $AsgName -Bucket $Bucket -Prefix $Prefix -Profile $Profile -Region $Region
}
