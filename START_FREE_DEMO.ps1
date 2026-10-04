$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$python = Get-Command python -ErrorAction SilentlyContinue
$cloudflared = Get-Command cloudflared -ErrorAction SilentlyContinue
if (-not $cloudflared) {
    $localCloudflared = Join-Path $projectRoot "cloudflared.exe"
    if (Test-Path $localCloudflared) { $cloudflared = [pscustomobject]@{ Source = $localCloudflared } }
}

if (-not $python) { throw "Python 3 is required. Install it, then reopen PowerShell." }
if (-not $cloudflared) { throw "cloudflared was not found. Download the Windows 64-bit executable from https://developers.cloudflare.com/tunnel/downloads/, rename it to cloudflared.exe, and save it beside START_FREE_DEMO.ps1; or install cloudflared on PATH." }

Push-Location $projectRoot
$appProcess = $null
$oldUnbuffered = $env:PYTHONUNBUFFERED
try {
    & $python.Source -c "import flask" 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Installing the small Flask web dependencies..."
        & $python.Source -m pip install -r requirements.txt
        if ($LASTEXITCODE -ne 0) { throw "Python dependency installation failed." }
    }

    $model = if ($env:OLLAMA_MODEL) { $env:OLLAMA_MODEL } else { "qwen3.5:4b" }
    $ollamaUrl = if ($env:OLLAMA_URL) { $env:OLLAMA_URL.TrimEnd("/") } else { "http://127.0.0.1:11434" }
    try { $tags = Invoke-RestMethod -Uri "$ollamaUrl/api/tags" -TimeoutSec 3 }
    catch { throw "Ollama is not responding. Open Ollama, install the model with 'ollama pull $model', then rerun this launcher." }
    $installed = $tags.models | Where-Object { $_.name -eq $model -or $_.model -eq $model }
    if (-not $installed) { throw "Qwen model '$model' is not installed. Run 'ollama pull $model', then rerun." }
    $env:OLLAMA_MODEL = $model
    $env:OLLAMA_URL = $ollamaUrl
    if (-not $env:OLLAMA_TIMEOUT_SECONDS) { $env:OLLAMA_TIMEOUT_SECONDS = "240" }

    $allowedEmail = Read-Host "Optional: enter your teacher's email to require a one-time PIN (leave blank for an open link)"
    $env:PYTHONUNBUFFERED = "1"
    $logDirectory = Join-Path $env:TEMP "newsroom-free-demo"
    New-Item -ItemType Directory -Force -Path $logDirectory | Out-Null
    $appProcess = Start-Process -FilePath $python.Source -ArgumentList "app.py" -WorkingDirectory $projectRoot -PassThru -WindowStyle Hidden -RedirectStandardOutput (Join-Path $logDirectory "app.log") -RedirectStandardError (Join-Path $logDirectory "app-error.log")

    $appReady = $false
    for ($attempt = 0; $attempt -lt 30; $attempt++) {
        Start-Sleep -Seconds 1
        try {
            $health = Invoke-RestMethod -Uri "http://127.0.0.1:5000/healthz" -TimeoutSec 3
            if ($health.status -eq "ok") { $appReady = $true; break }
        } catch { }
    }
    if (-not $appReady) { throw "The Flask app did not start. Check $logDirectory for its error log." }

    $tunnelArguments = @("tunnel", "--url", "http://127.0.0.1:5000")
    if ($allowedEmail.Trim()) {
        $tunnelArguments += @("--allowed-mail", $allowedEmail.Trim())
        Write-Host "Only $($allowedEmail.Trim()) can open the demo; Cloudflare will send a one-time PIN."
    } else {
        Write-Warning "The demo link will be accessible to anyone who has it."
    }
    Write-Host "Starting the temporary public link. Keep this window and your computer on; press Ctrl+C to stop."
    & $cloudflared.Source @tunnelArguments
} finally {
    if ($appProcess -and -not $appProcess.HasExited) { Stop-Process -Id $appProcess.Id -Force -ErrorAction SilentlyContinue }
    if ($null -ne $oldUnbuffered) { $env:PYTHONUNBUFFERED = $oldUnbuffered } else { Remove-Item Env:PYTHONUNBUFFERED -ErrorAction SilentlyContinue }
    Pop-Location
}
