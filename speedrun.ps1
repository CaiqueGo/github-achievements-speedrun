<#
.SYNOPSIS
  Desbloqueia Pull Shark, YOLO, Quickdraw (e opcionalmente Pair Extraordinaire)
  no seu proprio repositorio publico do GitHub.

.DESCRIPTION
  Versao PowerShell do speedrun.sh. Requer git e gh (GitHub CLI) autenticado.

.EXAMPLE
  .\speedrun.ps1
.EXAMPLE
  .\speedrun.ps1 -Repo meu-user/meu-repo -Rounds 3
.EXAMPLE
  .\speedrun.ps1 -CoAuthor "Fulana <123456+fulana@users.noreply.github.com>"
#>
[CmdletBinding()]
param(
  [string] $Repo = "",
  [int]    $Rounds = 2,
  [string] $CoAuthor = "",
  [switch] $SkipQuickdraw,
  [switch] $DryRun
)

$ErrorActionPreference = "Stop"

function Write-Step { param($m) Write-Host "==> $m" -ForegroundColor Cyan }
function Write-Ok   { param($m) Write-Host "  ok $m"  -ForegroundColor Green }
function Write-Warn { param($m) Write-Host "  !! $m"  -ForegroundColor Yellow }
function Die        { param($m) Write-Host "erro: $m" -ForegroundColor Red; exit 1 }

function Invoke-Step {
  param([string] $Exe, [string[]] $Args)
  if ($DryRun) {
    Write-Host "  (dry-run) $Exe $($Args -join ' ')" -ForegroundColor DarkGray
    return ""
  }
  $out = & $Exe @Args
  if ($LASTEXITCODE -ne 0) { Die "$Exe $($Args -join ' ') falhou (exit $LASTEXITCODE)" }
  return $out
}

# --- pre-flight ------------------------------------------------------------

if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Die "git nao encontrado no PATH." }
if (-not (Get-Command gh  -ErrorAction SilentlyContinue)) { Die "gh (GitHub CLI) nao encontrado. Instale: winget install GitHub.cli" }

gh auth status 1>$null
if ($LASTEXITCODE -ne 0) { Die "gh nao autenticado. Rode: gh auth login" }

if ([string]::IsNullOrWhiteSpace($Repo)) {
  $Repo = gh repo view --json nameWithOwner -q .nameWithOwner
  if ($LASTEXITCODE -ne 0) { Die "Nao consegui detectar o repo. Rode dentro de um clone ou passe -Repo owner/nome." }
}

$visibility = gh repo view $Repo --json visibility -q .visibility
$base       = gh repo view $Repo --json defaultBranchRef -q .defaultBranchRef.name

Write-Step "Repo:    $Repo ($visibility)"
Write-Step "Base:    $base"
Write-Step "Rodadas: $Rounds"
if ($CoAuthor) { Write-Step "Co-autor: $CoAuthor" }

if ($visibility -ne "PUBLIC") {
  Write-Warn "Repo NAO e publico. Achievements so contam em repositorio publico."
  Write-Warn "Torne publico: gh repo edit $Repo --visibility public --accept-visibility-change-consequences"
  $yn = Read-Host "Continuar mesmo assim? [s/N]"
  if ($yn -notmatch '^[SsYy]$') { exit 1 }
}

# --- garante um clone de trabalho -----------------------------------------

$cloned  = $false
$inRepo  = $false
git rev-parse --is-inside-work-tree 1>$null 2>$null
if ($LASTEXITCODE -eq 0) {
  $here = gh repo view --json nameWithOwner -q .nameWithOwner 2>$null
  if ($here -eq $Repo) { $inRepo = $true }
}

if ($inRepo) {
  $workdir = git rev-parse --show-toplevel
} else {
  $workdir = Join-Path ([System.IO.Path]::GetTempPath()) ("ghspeedrun-" + [guid]::NewGuid().ToString("N").Substring(0,8))
  Write-Step "Clonando $Repo em $workdir"
  Invoke-Step gh @("repo", "clone", $Repo, $workdir, "--", "--quiet") | Out-Null
  $cloned = $true
}
Set-Location $workdir

Invoke-Step git @("checkout", $base, "--quiet") | Out-Null
git pull --quiet --ff-only 2>$null

# --- Pull Shark + YOLO -----------------------------------------------------

$logfile = "ACHIEVEMENTS.md"
$merged  = 0

for ($i = 1; $i -le $Rounds; $i++) {
  $stamp  = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
  $branch = "achievement/run-$stamp-$i"
  Write-Step "[$i/$Rounds] branch $branch"

  Invoke-Step git @("checkout", "-b", $branch, "--quiet") | Out-Null

  if (-not $DryRun) {
    if (-not (Test-Path $logfile)) {
      "# Achievements log`n`nCada linha abaixo e um PR mergeado por ``speedrun.ps1``.`n" |
        Out-File -FilePath $logfile -Encoding utf8
    }
    $iso = [DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
    "- run $iso -- PR $i/$Rounds -- $branch" |
      Out-File -FilePath $logfile -Encoding utf8 -Append
  }
  Invoke-Step git @("add", $logfile) | Out-Null

  $msg = "chore: registra rodada $i do speedrun de achievements"
  if ($CoAuthor) { $msg = "$msg`n`nCo-authored-by: $CoAuthor" }
  Invoke-Step git @("commit", "-m", $msg, "--quiet") | Out-Null
  Invoke-Step git @("push", "-u", "origin", $branch, "--quiet") | Out-Null

  $body = @"
PR gerado por ``speedrun.ps1``.

- Merge direto, sem code review -> conta para **YOLO**
- PR mergeado -> conta para **Pull Shark** (precisa de 2)
"@

  Invoke-Step gh @(
    "pr", "create",
    "--repo", $Repo,
    "--base", $base,
    "--head", $branch,
    "--title", "Rodada ${i}: registra progresso dos achievements",
    "--body", $body
  ) | Out-Null

  # merge sem review nenhum = YOLO; merge = Pull Shark
  Invoke-Step gh @("pr", "merge", $branch, "--repo", $Repo, "--squash", "--delete-branch") | Out-Null
  Write-Ok "PR $i mergeado sem review"
  $merged++

  Invoke-Step git @("checkout", $base, "--quiet") | Out-Null
  git pull --quiet --ff-only 2>$null
}

# --- Quickdraw -------------------------------------------------------------

if (-not $SkipQuickdraw) {
  Write-Step "Quickdraw: abrindo issue e fechando em menos de 5 minutos"
  if ($DryRun) {
    Write-Host "  (dry-run) gh issue create + gh issue close" -ForegroundColor DarkGray
  } else {
    $url = gh issue create --repo $Repo `
             --title "Quickdraw: issue de teste" `
             --body  "Issue aberta e fechada em seguida para desbloquear o achievement **Quickdraw**."
    if ($LASTEXITCODE -ne 0) { Die "gh issue create falhou" }
    $num = ($url -split '/')[-1]
    Start-Sleep -Seconds 15
    gh issue close $num --repo $Repo --comment "Fechando rapido. Quickdraw unlocked."
    Write-Ok "issue #$num aberta e fechada"
  }
}

# --- resumo ----------------------------------------------------------------

$pullShark = if ($merged -ge 2) { "ok" } else { "parcial" }
$quick     = if ($SkipQuickdraw) { "pulado" } else { "ok" }
$pair      = if ($CoAuthor) { "ok (trailer Co-authored-by)" } else { "pulado (use -CoAuthor)" }

Write-Host ""
Write-Step "Resumo"
Write-Host "  Pull Shark          $pullShark ($merged de 2 PRs mergeados nesta execucao)"
Write-Host "  YOLO                ok (merge sem review)"
Write-Host "  Quickdraw           $quick"
Write-Host "  Pair Extraordinaire $pair"
Write-Host "  Starstruck          manual - 16 estrelas, veja docs/checklist.md"
Write-Host "  Galaxy Brain        manual - 2 respostas aceitas em Discussions"
Write-Host "  Public Sponsor      manual - exige cartao de credito, faca voce mesmo"

$login = gh api user -q .login
Write-Host ""
Write-Host "Os badges aparecem no perfil em ate ~24h: https://github.com/$login"

if ($cloned) { Write-Warn "Clone temporario em $workdir (pode apagar)." }
