# Newsroom — Hindi News Studio

Newsroom is a Flask web app that turns Hindi news articles into a Hindi news headline and an abstractive Hindi summary. It uses a local Qwen model through Ollama, so article text is sent to your Ollama service rather than to a hosted model API.

## Features

- Generates a separate, news-style Hindi headline and an abstractive Hindi summary.
- Accepts Hindi and mixed Hindi/English articles.
- Shows article highlights related to the summary.
- Includes Results & Metrics, Project Details, and NLP Pipeline tabs.
- Displays source-overlap, number-support, coverage, repetition, and other diagnostic values.
- Uses Flask for the website and Ollama for local Qwen inference.

The metrics are calculated by comparing the generated text with the input article. They are useful diagnostics and are not reference-based evaluation scores.

## Requirements

- Python 3.10 or newer
- [Ollama](https://ollama.com/download)
- The default model: Qwen 3.5 4B (downloaded separately through Ollama)

## Run locally on Windows

Open PowerShell and move into the project folder:

    Set-Location 'D:\SEM 7 (2028)\MINIPROJECTS\NLP'

Create and activate a virtual environment:

    python -m venv .venv
    .\.venv\Scripts\Activate.ps1

Install the Python packages and download the model:

    python -m pip install --upgrade pip
    pip install -r requirements.txt
    ollama pull qwen3.5:4b

Make sure Ollama is running, then start the website:

    python app.py

Open the app at http://127.0.0.1:5000. The health endpoint is http://127.0.0.1:5000/healthz.

If PowerShell prevents environment activation, install packages and run the app through the virtual environment directly:

    .\.venv\Scripts\python.exe -m pip install -r requirements.txt
    .\.venv\Scripts\python.exe app.py

## Configuration

The app defaults to model qwen3.5:4b and Ollama at http://127.0.0.1:11434. You can override these values before starting the app:

    $env:OLLAMA_MODEL = "qwen2.5:3b"
    $env:OLLAMA_URL = "http://127.0.0.1:11434"
    $env:OLLAMA_TIMEOUT_SECONDS = "240"
    python app.py

The selected model must already be installed in Ollama. For another model, replace the model name and run ollama pull with that model name first.

## Project structure

- app.py — Flask routes, interface, Ollama requests, summary generation, and metrics.
- requirements.txt — Python web server dependencies.
- static/ — UI assets, including the newspaper background.
- START_FREE_DEMO.ps1 — Windows launcher for a temporary public demo.
- Dockerfile and compose.yaml — Container setup for a VPS with Ollama and Caddy.
- Caddyfile and .env.example — HTTPS reverse-proxy configuration example.

## Optional: share a free temporary demo link

The free demo runs on your own computer and exposes the local Flask site using Cloudflare Quick Tunnels. It is for demos and testing; the URL changes when the tunnel restarts, and your computer must remain on and connected to the internet.

1. Download the Windows 64-bit cloudflared executable from [Cloudflare's download page](https://developers.cloudflare.com/tunnel/downloads/).
2. Save it beside START_FREE_DEMO.ps1 as cloudflared.exe.
3. Confirm Ollama is running and the selected Qwen model is installed.
4. In PowerShell, run:

       Set-Location 'D:\SEM 7 (2028)\MINIPROJECTS\NLP'
       powershell -ExecutionPolicy Bypass -File .\START_FREE_DEMO.ps1

5. Copy the trycloudflare.com URL printed in the terminal. The launcher can request an email PIN for access.

## Docker VPS deployment

The Docker Compose configuration starts the Flask app, Ollama, downloads Qwen into a persistent volume, and places Caddy in front of the app. It expects a VPS with enough disk and memory for the model and a domain pointed at the server.

1. Copy .env.example to .env.
2. Set PUBLIC_DOMAIN in .env to your domain.
3. Run docker compose up --build -d.
4. Check status with docker compose ps and view logs with docker compose logs -f app ollama.

## Troubleshooting

- Ollama connection error: start the Ollama application and confirm the Ollama API is reachable at http://127.0.0.1:11434.
- Model missing: run ollama pull qwen3.5:4b, or install the model selected in OLLAMA_MODEL.
- Slow first response: Ollama may need to load the model into memory. Generation speed depends on your computer.
- Port 5000 is in use: stop the other app using that port before starting Newsroom.

## License

No license file is currently included. Add a license before you permit others to reuse or redistribute the project.
