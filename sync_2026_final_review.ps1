$ErrorActionPreference = "Stop"

$PrivateSource = "D:\Study\Obsidian Vault\2026春学期期末考试内容"
$PublicRepo = "D:\Study\2026-Final-Review"

if (!(Test-Path -LiteralPath $PrivateSource)) {
  throw "Private source not found: $PrivateSource"
}

if (!(Test-Path -LiteralPath $PublicRepo)) {
  throw "Public repo not found: $PublicRepo"
}

$privateResolved = (Resolve-Path -LiteralPath $PrivateSource).Path
$publicResolved = (Resolve-Path -LiteralPath $PublicRepo).Path

if ($publicResolved -notlike "D:\Study\2026-Final-Review*") {
  throw "Safety check failed. Public repo path is unexpected: $publicResolved"
}

Write-Host "Syncing review notes..."
Write-Host "From: $privateResolved"
Write-Host "To:   $publicResolved"

$subjectDirs = @("操作系统", "数据库原理")
foreach ($dir in $subjectDirs) {
  $src = Join-Path $privateResolved $dir
  $dst = Join-Path $publicResolved $dir
  if (Test-Path -LiteralPath $dst) {
    Remove-Item -LiteralPath $dst -Recurse -Force
  }
  if (Test-Path -LiteralPath $src) {
    Copy-Item -LiteralPath $src -Destination $dst -Recurse -Force
  }
}

Set-Location -LiteralPath $publicResolved
git status --short
git add -A

$changes = git status --short
if ([string]::IsNullOrWhiteSpace($changes)) {
  Write-Host "No changes to commit."
} else {
  $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  git commit -m "sync final review notes: $timestamp"
}

git push origin main
