$ErrorActionPreference = 'Stop'

function Assert-Contains {
  param(
    [string]$Content,
    [string]$Expected,
    [string]$Label
  )

  if (-not $Content.Contains($Expected)) {
    throw "Assertion failed for ${Label}: missing '${Expected}'"
  }
}

$root = Split-Path -Parent $PSScriptRoot
$job = Start-Job -ScriptBlock {
  param($siteRoot)
  Set-Location $siteRoot
  python -m http.server 4173
} -ArgumentList $root

Start-Sleep -Seconds 2

$homePage = Invoke-WebRequest -Uri 'http://127.0.0.1:4173/' -UseBasicParsing
Assert-Contains -Content $homePage.Content -Expected 'data-testid="hero-title"' -Label 'home hero'
Assert-Contains -Content $homePage.Content -Expected 'data-testid="featured-projects"' -Label 'home featured projects'
Assert-Contains -Content $homePage.Content -Expected 'data-testid="about-section"' -Label 'home about section'
Assert-Contains -Content $homePage.Content -Expected 'data-testid="contact-section"' -Label 'home contact section'

$detailPaths = @(
  '/projects/embedded-system.html',
  '/projects/smart-car-platform.html',
  '/projects/jlc-pcb-design.html',
  '/projects/xingdouxinghe.html'
)

foreach ($path in $detailPaths) {
  $page = Invoke-WebRequest -Uri ("http://127.0.0.1:4173" + $path) -UseBasicParsing
  Assert-Contains -Content $page.Content -Expected 'data-testid="project-title"' -Label $path
  Assert-Contains -Content $page.Content -Expected 'data-testid="project-background"' -Label $path
  Assert-Contains -Content $page.Content -Expected 'data-testid="project-branches"' -Label $path
  Assert-Contains -Content $page.Content -Expected 'data-testid="project-gallery"' -Label $path
}

Write-Host 'Smoke test passed.'

Stop-Job $job -ErrorAction SilentlyContinue | Out-Null
Remove-Job $job -Force -ErrorAction SilentlyContinue | Out-Null
