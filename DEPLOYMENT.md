# Qwen and Ollama deployment

The Flask app uses Qwen locally through Ollama. It does not use Streamlit, a hosted Hugging Face app, or a paid inference API.

## Free temporary Windows demo

1. Install Python 3 and Ollama. In PowerShell, install the model once with ollama pull qwen3.5:4b.
2. Download the Windows 64-bit cloudflared executable from [Cloudflare's official download page](https://developers.cloudflare.com/tunnel/downloads/). Save it in this project folder as cloudflared.exe, or install it on PATH.
3. Run: powershell -ExecutionPolicy Bypass -File .\START_FREE_DEMO.ps1
4. Enter the teacher's email for a PIN-protected link, or leave it blank for an open demo. Copy the https://....trycloudflare.com URL printed in PowerShell.

The launcher checks Flask, Ollama, and the configured model, installs the small Python dependencies, and starts Flask plus the tunnel. Keep the computer awake, online, and the launcher window open while the demo is being used. The free tunnel URL changes after restart.

The default model is qwen3.5:4b. Set $env:OLLAMA_MODEL = "qwen2.5:3b" before launching to use another installed Ollama model. OLLAMA_URL and OLLAMA_TIMEOUT_SECONDS can also be configured.

## Docker VPS

Set PUBLIC_DOMAIN in .env to a DNS name pointing at the VPS, then run docker compose up --build -d. Compose starts the Flask app, Ollama, downloads Qwen once, and serves the app through Caddy with HTTPS. The Ollama model volume persists between restarts. The VPS needs enough disk and memory to run the Qwen model.

## Model and accuracy

The app produces an abstractive Hindi summary and an independently prompted headline in a news-headline style. Source-overlap and number-support metrics are diagnostic indicators, not proof of accuracy. Review the output before publishing.
