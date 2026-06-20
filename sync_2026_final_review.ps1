$ErrorActionPreference = "Stop"

$PrivateSource = "D:\Study\Obsidian Vault\2026春学期期末考试内容"
$PublicRepo = "D:\Study\2026-Final-Review"
$SubjectDirs = @("操作系统", "数据库原理", "计算机组成")

if (!(Test-Path -LiteralPath $PrivateSource)) {
  throw "Private source not found: $PrivateSource"
}

if (!(Test-Path -LiteralPath $PublicRepo)) {
  throw "Public repo not found: $PublicRepo"
}

$privateResolved = (Resolve-Path -LiteralPath $PrivateSource).Path
$publicResolved = (Resolve-Path -LiteralPath $PublicRepo).Path

if ($privateResolved -notlike "D:\Study\Obsidian Vault\2026春学期期末考试内容*") {
  throw "Safety check failed. Private source path is unexpected: $privateResolved"
}

if ($publicResolved -notlike "D:\Study\2026-Final-Review*") {
  throw "Safety check failed. Public repo path is unexpected: $publicResolved"
}

Write-Host "Syncing review notes..."
Write-Host "From: $privateResolved"
Write-Host "To:   $publicResolved"

foreach ($dir in $SubjectDirs) {
  $src = Join-Path $privateResolved $dir
  $dst = Join-Path $publicResolved $dir

  if (!(Test-Path -LiteralPath $src)) {
    Write-Host "Skip missing subject: $dir"
    continue
  }

  if (Test-Path -LiteralPath $dst) {
    Remove-Item -LiteralPath $dst -Recurse -Force
  }

  Copy-Item -LiteralPath $src -Destination $dst -Recurse -Force
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
