# LLM Infrastructure — Architecture & Operations Guide

This document explains the design of the local LLM infrastructure on this machine:
what it is, why it was built this way, how to use it, and how to change it.

It is written for someone with no prior context — including a future version of
yourself who hasn't touched this in months.

---

## What problem this solves

Running AI models locally (or connecting to cloud AI APIs) creates a security
problem: you are running software you didn't write, from organizations you may
not fully trust, that receives your private prompts, files, and context.

Without isolation, a model runtime could:
- Read files on your computer
- Send your data to unexpected endpoints
- Make outbound network calls you didn't authorize

This infrastructure puts every model runtime inside a Docker container with
controlled network access, so you get the benefits of local and cloud AI
without the risks of running untrusted software directly on your machine.

---

## Core concepts (read this first)

### Docker containers
A container is a isolated process that thinks it has its own computer. It can't
see your files, your network, or your other programs unless you explicitly allow
it. Think of it as a sandbox — the model runs inside the box, your Mac runs
outside the box.

### Docker networks
Containers can be connected to virtual networks. A container on one network
can't talk to a container on a different network unless you wire them together.
This is how we control which models can talk to each other and to the internet.

### Control plane vs data plane
- **Data plane**: the actual containers running (models, proxy, UI)
- **Control plane**: how you manage them (adding models, killing internet access,
  setting API keys)

A common mistake is designing the data plane (Docker config) without designing
the control plane (how a human actually manages it day to day). This setup
deliberately separates them: Docker owns the data plane, Open WebUI owns the
control plane.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  Your Mac (host)                                                 │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Docker                                                   │   │
│  │                                                           │   │
│  │  ┌─────────────┐     ┌──────────────────────────────┐    │   │
│  │  │  Open WebUI  │────▶│  llm-net (internal network)  │    │   │
│  │  │  (port 3000) │     │                              │    │   │
│  │  └─────────────┘     │  ┌──────────┐  ┌──────────┐  │    │   │
│  │                       │  │  Ollama  │  │  future  │  │    │   │
│  │                       │  │ (11434)  │  │  models  │  │    │   │
│  │                       │  └────┬─────┘  └────┬─────┘  │    │   │
│  │                       └───────┼─────────────┼────────┘    │   │
│  │                               │             │              │   │
│  │                       ┌───────▼─────────────▼────────┐    │   │
│  │                       │  mitmproxy (egress proxy)     │    │   │
│  │                       │  Logs + filters all outbound  │    │   │
│  │                       │  traffic from model containers│    │   │
│  │                       └───────────────┬───────────────┘    │   │
│  │                                       │                    │   │
│  └───────────────────────────────────────┼────────────────────┘   │
│                                          │                        │
└──────────────────────────────────────────┼────────────────────────┘
                                           │
                                      Internet
                               (model weight downloads,
                                cloud API calls if allowed)
```

**What each piece does:**

| Component | What it is | Why it's here |
|---|---|---|
| **Open WebUI** | Web UI for managing and chatting with models | Your control plane — you never edit YAML directly |
| **Ollama** | Runtime that downloads and serves local models | Runs models like Llama, Mistral, Gemma locally |
| **llm-net** | Internal Docker network | Lets containers talk to each other, isolated from host |
| **mitmproxy** | Egress proxy | Logs and filters everything model containers send to the internet |
| **Little Snitch** | Host-level network monitor | Covers what mitmproxy misses — monitors native processes including Ollama itself |

---

## Threat model

### What we're protecting against
**Network exfiltration** — a model runtime receives your prompt (which may
contain sensitive context, code, or data) and sends it to an unexpected server.

### What we're NOT primarily protecting against
**Container escape** — a model breaking out of Docker and accessing your files
directly. Docker isolation is robust. This is a lower-priority concern than
network exfiltration for a personal machine.

### The defense layers

1. **No bind mounts to sensitive directories** — containers cannot read
   `~/`, `~/.ssh`, `~/.config`, or any host path you haven't explicitly
   mounted. Model weights live in named Docker volumes, not host folders.

2. **Egress proxy (mitmproxy)** — all outbound traffic from model containers
   passes through the proxy. You can see exactly what each container is calling
   and block domains you don't trust.

3. **Internal network isolation** — model containers are on `llm-net`. They
   can't reach other Docker containers (like databases or other services) unless
   explicitly connected.

4. **Group kill switch** — one command cuts internet access for all model
   containers simultaneously. See Operations section below.

### What this doesn't solve
- If you paste secrets directly into a prompt, those secrets are in the model's
  context. Isolation doesn't protect against human error.
- Cloud LLM APIs (OpenAI, Anthropic) receive your prompts by design. Only use
  them with data you'd be comfortable sending to those companies.
- mitmproxy cannot monitor Ollama's network traffic — Ollama runs natively on
  the host for Metal GPU access. Little Snitch covers this gap.

### Remote access via Tailscale
To expose your local LLM to a cloud app or another device, use Tailscale — not
a public port. Your Mac has a stable private Tailscale IP (100.x.x.x) reachable
only from devices on your Tailnet. A cloud app with Tailscale installed connects
to `100.x.x.x:11434` directly. No public exposure, no firewall rules.

---

## Why these specific tools

### Why Open WebUI (not raw Docker Compose, not Portainer)
Open WebUI is purpose-built for managing local LLMs. It handles:
- Pulling and managing Ollama models through a UI (no YAML editing)
- Connecting to cloud LLM APIs (OpenAI, Anthropic, etc.) with API keys
- A chat interface for testing models
- Multiple model backends behind one UI

The alternative — editing `docker-compose.yml` directly — requires you to know
Docker syntax and restart containers manually every time you add a model. That's
an engineer's workflow, not an admin's.

### Why Ollama (not Docker Model Runner, not llama.cpp, not LM Studio)
- Runs as a proper service (not a one-shot CLI tool)
- Has a clean HTTP API that Open WebUI integrates with natively — first-class, not a compatibility shim
- 45,000+ models available via `ollama pull modelname` — Docker Model Runner has ~100-200
- Battle-tested: 2 years old vs Docker Model Runner's 1 month
- Faster for single-user use (333-345 tok/s vs 251-279 tok/s) — vllm-metal wins on concurrent batch requests, not single-session latency
- Adding a new model is `ollama pull modelname`, not a manual Hugging Face download

**On Docker Model Runner (vllm-metal):** Docker's native inference engine, released February 2026.
Worth re-evaluating in 12-18 months. Key facts to know:
- Requires Docker Desktop 4.62+ (not standalone)
- Uses MLX/safetensors format — incompatible with GGUF models Ollama uses
- Can coexist with Ollama on the same machine (different ports: 11434 vs 12434)
- Better throughput for concurrent requests; worse for single-session latency
- Open WebUI connects to it as a generic OpenAI endpoint, not natively

### Why Little Snitch (in addition to mitmproxy)
mitmproxy only monitors traffic from Docker containers. Ollama runs natively on the host
for Metal GPU access — its network traffic is invisible to mitmproxy. Little Snitch fills
this gap by monitoring all network connections at the OS level, including native processes.
Together they give complete coverage: containers via mitmproxy, host processes via Little Snitch.

### Why mitmproxy (not iptables, not a firewall rule)
- **Visibility**: you can inspect traffic in a web UI at `localhost:8081`
- **Scriptable**: you can write Python rules to block specific domains or
  log specific request patterns
- **Transparent**: works without changing anything inside the containers
- iptables rules are powerful but invisible — you can't see what's being
  blocked or why without reading rules

### Why group kill switch (not per-container)
- Simple enough to actually use under pressure
- Covers the most likely scenario: "I don't trust what's happening, stop everything"
- Per-container kill switches can be added later when you have models with
  meaningfully different trust levels (e.g., a local model vs one that calls
  out to an external API)

---

## How to use this (Operations)

### Open the UI
```
open http://localhost:3000
```
This is where you do everything: add models, chat, connect cloud APIs.

### Start everything
```
cd ~/docker
docker compose up -d
```

### Stop everything
```
cd ~/docker
docker compose down
```

### Kill internet access for all model containers (kill switch)
```
docker network disconnect llm-egress ollama
```
To restore:
```
docker network connect llm-egress ollama
```

### Add a local model
Open WebUI → Models → Pull a model → type the model name (e.g. `llama3.3`)

Or via terminal:
```
docker exec ollama ollama pull llama3.3
```

### Add a cloud LLM (OpenAI, Anthropic, etc.)
Open WebUI → Settings → Connections → add the API endpoint and key.
Keys should come from 1Password — never paste them into a config file.

### View egress proxy traffic (what models are calling out to)
```
open http://localhost:8081
```
This is the mitmproxy web UI. Every outbound request from model containers
appears here in real time.

### Check what's running
```
docker compose ps
```

### View logs for a specific container
```
docker compose logs ollama
docker compose logs open-webui
docker compose logs mitmproxy
```

---

## How to add a new model runtime (beyond Ollama)

When you want to add a second model runtime (e.g., a specialized runtime for
image models, or a different inference engine):

1. Add a new service to `docker/compose.yml`
2. Connect it to `llm-net` (so Open WebUI can reach it)
3. Connect it to `llm-egress` (so its traffic goes through the proxy)
4. Do NOT mount any host paths except named volumes
5. Register it in Open WebUI under Settings → Connections

---

## What is intentionally NOT automated

### Model versions
Model weights are large (2–70GB), change frequently, and are pulled from
Ollama's registry at runtime. They are not pinned in config files because:
- The registry always has the latest version
- Pinning versions creates stale configs that need constant updating
- Models are re-downloaded on a new machine anyway (too large to store in dotfiles)

### Cloud API keys
API keys for OpenAI, Anthropic, etc. are stored in 1Password and entered into
Open WebUI's settings UI. They are not in any config file because:
- Config files get committed to git (even accidentally)
- Open WebUI stores them encrypted in its own database
- Keys rotate; a config file would go stale

### Runtime flags
Ollama and Open WebUI release frequently. Specific flags that work today may
be renamed or removed in 3 months. The defaults are good. Only add flags when
you have a specific, documented reason to.

---

## Files in this directory

```
docker/
  README.md         this file
  compose.yml       Docker Compose service definitions (built separately)
  .env.example      template showing which env vars are needed (no real values)
```

---

## Key decisions log

| Decision | Chosen | Rejected | Reason |
|---|---|---|---|
| Control plane | Open WebUI | Raw YAML, Portainer | Purpose-built for LLMs, right abstraction level |
| Local runtime | Ollama | Docker Model Runner, llama.cpp, LM Studio | Maturity, 45K+ models, native Open WebUI support, faster single-session |
| Egress proxy | mitmproxy | iptables, pfctl | Visible, scriptable, inspectable |
| Host-level monitoring | Little Snitch | mitmproxy alone | mitmproxy only sees containers; Ollama runs on host — Little Snitch covers the gap |
| Remote/cloud access | Tailscale | Public port + auth | No public exposure, no firewall rules, works with existing Tailnet |
| Kill switch granularity | Group (all LLMs) | Per-container | Simpler, extensible later |
| Model version pinning | Not pinned | Pinned in compose.yml | Too volatile, downloaded fresh each time |
| API key storage | 1Password → Open WebUI | .env files, config files | Security, rotation, never touches disk |
| Sensitive dir mounts | Forbidden | Allowed with restrictions | Simpler security model — no exceptions |
| Docker Model Runner | Deferred (re-evaluate 2027) | Adopted now | 1 month old, smaller model library, no Open WebUI native support yet |
