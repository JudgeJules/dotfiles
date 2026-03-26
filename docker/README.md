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

This infrastructure puts the UI layer inside a Docker container with controlled
network access, so you get the benefits of local and cloud AI without the risks
of running untrusted software directly on your machine.

---

## Core concepts (read this first)

### Docker containers
A container is an isolated process that thinks it has its own computer. It can't
see your files, your network, or your other programs unless you explicitly allow
it. Think of it as a sandbox — the app runs inside the box, your Mac runs
outside the box.

### Docker networks
Containers can be connected to virtual networks. A container on one network
can't talk to a container on a different network unless you wire them together.
This is how we control which containers can reach the internet.

### Control plane vs data plane
- **Data plane**: the actual containers running (proxy, UI)
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
│  Ollama.app ──────────────────────────────────────────────────  │
│  (Metal GPU, port 11434)                                         │
│  Little Snitch monitors all Ollama network traffic               │
│                        ▲                                         │
│                        │ host.docker.internal:11434              │
│  ┌─────────────────────┼────────────────────────────────────┐   │
│  │  Docker             │                                     │   │
│  │                     │                                     │   │
│  │  ┌──────────────────┴────────────────────────────────┐   │   │
│  │  │  llm-internal network (internal: true, no internet)│   │   │
│  │  │                                                    │   │   │
│  │  │  ┌─────────────┐          ┌─────────────────────┐  │   │   │
│  │  │  │  Open WebUI  │─────────▶│     mitmproxy       │  │   │   │
│  │  │  │  (port 3000) │ proxied  │  (port 8080/8081)   │  │   │   │
│  │  │  └─────────────┘          └──────────┬──────────┘  │   │   │
│  │  └─────────────────────────────────────┼─────────────┘   │   │
│  │                                        │                  │   │
│  │  ┌─────────────────────────────────────┼─────────────┐   │   │
│  │  │  llm-egress network                 │             │   │   │
│  │  │                            mitmproxy only          │   │   │
│  │  └─────────────────────────────────────┼─────────────┘   │   │
│  └─────────────────────────────────────────┼─────────────────┘   │
│                                            │                     │
└────────────────────────────────────────────┼─────────────────────┘
                                             │
                                        Internet
                                  (cloud API calls,
                                   model downloads)
```

**What each piece does:**

| Component | Runs where | What it does |
|---|---|---|
| **Ollama.app** | Host (native) | Downloads and serves local models on Metal GPU. Port 11434. |
| **Open WebUI** | Docker | Chat interface + control plane. Manages models, connects cloud APIs. Port 3000. |
| **mitmproxy** | Docker | Egress proxy. All Open WebUI internet traffic passes through here. Web UI at 8081. |
| **llm-internal** | Docker network | `internal: true` — no direct internet. Open WebUI and mitmproxy live here. |
| **llm-egress** | Docker network | Internet-facing. mitmproxy only. Disconnecting it = kill switch. |
| **Little Snitch** | Host | Monitors all host-level network connections, including Ollama. |

**Key architectural fact**: Ollama runs natively on your Mac, not in Docker. This is
required for Metal GPU access. Open WebUI (in Docker) connects to it via
`http://host.docker.internal:11434` — `host.docker.internal` is a special hostname
that Docker Desktop resolves to the Mac's internal IP from inside any container.

**Models are only stored once**: in `~/.ollama/models` on your Mac. Open WebUI is
just a frontend — it tells Ollama which model to load, but doesn't download or
store anything itself.

---

## Threat model

### What we're protecting against
**Network exfiltration** — software receives your prompt (which may contain
sensitive context, code, or data) and sends it to an unexpected server.

### What we're NOT primarily protecting against
**Container escape** — a process breaking out of Docker and accessing your files
directly. Docker isolation is robust. This is a lower-priority concern than
network exfiltration for a personal machine.

### The defense layers

1. **No bind mounts to sensitive directories** — containers cannot read
   `~/`, `~/.ssh`, `~/.config`, or any host path you haven't explicitly
   mounted. Open WebUI data lives in a named Docker volume, not a host folder.

2. **Egress proxy (mitmproxy)** — all outbound traffic from Open WebUI
   passes through the proxy. You can see exactly what it's calling
   and block domains you don't trust.

3. **Internal network isolation** — Open WebUI is on `llm-internal` (`internal: true`).
   It has no direct path to the internet — everything must go through mitmproxy.

4. **Group kill switch** — one command cuts internet access for all containers.
   See Operations section below.

5. **Little Snitch** — covers Ollama's network traffic, which mitmproxy cannot see
   because Ollama runs on the host (not in Docker).

### What this doesn't solve
- If you paste secrets directly into a prompt, those secrets are in the model's
  context. Isolation doesn't protect against human error.
- Cloud LLM APIs (OpenAI, Anthropic) receive your prompts by design. Only use
  them with data you'd be comfortable sending to those companies.
- mitmproxy cannot inspect HTTPS traffic without the mitmproxy CA cert being
  trusted inside the container. The CA is not installed, so HTTPS calls from
  Open WebUI to cloud APIs (OpenAI, etc.) pass through as opaque TLS tunnels.
  You can see that a connection was made and to where, but not the content.

### Remote access via Tailscale
To expose your local LLM to another device or a cloud app, use Tailscale — not
a public port. Your Mac has a stable private Tailscale IP (100.x.x.x) reachable
only from devices on your Tailnet. A cloud app with Tailscale installed connects
to `100.x.x.x:3000` for Open WebUI, or `100.x.x.x:11434` for raw Ollama API.

To allow Tailscale access to Open WebUI, change the port binding in compose.yml:
```yaml
ports:
  - "0.0.0.0:3000:8080"   # change from 127.0.0.1 to allow Tailscale
```

---

## Why these specific tools

### Why Open WebUI (not raw Docker Compose, not Portainer)
Open WebUI is purpose-built for managing local LLMs. It handles:
- Pulling and managing Ollama models through a UI (no terminal required)
- Connecting to cloud LLM APIs (OpenAI, Anthropic, etc.) with API keys
- A chat interface for testing models
- Multiple model backends behind one UI

The alternative — editing `docker-compose.yml` directly — requires you to know
Docker syntax and restart containers manually every time you add a model.

### Why Ollama (not Docker Model Runner, not llama.cpp, not LM Studio)
- Runs as a proper service (not a one-shot CLI tool)
- Has a clean HTTP API that Open WebUI integrates with natively
- 45,000+ models available via pull — Docker Model Runner has ~200
- Battle-tested: 2+ years vs Docker Model Runner's 1 month (as of March 2026)
- Faster for single-user use (333-345 tok/s vs 251-279 tok/s) — vllm-metal wins
  on concurrent batch requests, not single-session latency
- Adding a new model: type the name in Open WebUI, done

**On Docker Model Runner (vllm-metal):** Docker's native inference engine, released
February 2026. Worth re-evaluating in 12-18 months. Key facts:
- Requires Docker Desktop 4.62+ (not standalone Docker)
- Uses MLX/safetensors format — incompatible with GGUF models Ollama uses
- Can coexist with Ollama on the same machine (different ports: 11434 vs 12434)
- Open WebUI connects to it as a generic OpenAI endpoint, not natively

### Why Ollama as a native app (cask), not a Homebrew formula
`brew install ollama` (formula) installs the Ollama CLI binary. On macOS 26 Tahoe
(as of Ollama 0.18.2), this crashes immediately with a Metal error:

```
ggml_metal_library_init: error: Error Domain=MTLLibraryErrorDomain
MPPTensorOpsMatMul2dImpl.h:3266:5: static_assert failed due to requirement
'__tensor_ops_detail::__is_same_v<bfloat, half>'
ggml_metal_device_init: error: failed to allocate context
GGML_ASSERT(backend) failed
```

This is a Metal Performance Primitives framework incompatibility in Tahoe.
`brew install --cask ollama` installs Ollama.app, which ships its own Metal
shaders and handles the initialization differently — no crash.

**Use the cask. The Brewfile already reflects this.**

### Why Little Snitch (in addition to mitmproxy)
mitmproxy only monitors traffic from Docker containers. Ollama runs natively on
the host — its network traffic is invisible to mitmproxy. Little Snitch fills
this gap by monitoring all network connections at the OS level, including native
processes. Together they give complete coverage: containers via mitmproxy, host
processes via Little Snitch.

### Why mitmproxy (not iptables, not a firewall rule)
- **Visibility**: inspect traffic in a web UI at `localhost:8081`
- **Scriptable**: write Python rules to block specific domains or log patterns
- **Transparent**: works without changing anything inside the containers
- iptables rules are powerful but invisible — you can't see what's being
  blocked or why without reading rules

### Why group kill switch (not per-container)
- Simple enough to actually use under pressure
- Covers the most likely scenario: "I don't trust what's happening, stop everything"
- Per-container kill switches can be added later when you have models with
  meaningfully different trust levels

---

## How to use this (Operations)

### Open the UI
```
open http://localhost:3000
```
This is where you do everything: pull models, chat, connect cloud APIs.

### Start the stack
```bash
cd ~/docker
docker compose up -d
```
Note: Ollama.app must be running separately (it's native, not in Docker).
It starts automatically if you have the app set to launch at login, or:
```bash
open -a Ollama
```

### Stop the stack
```bash
cd ~/docker
docker compose down
```

### Kill internet access for all containers (kill switch)
```bash
docker network disconnect llm-egress mitmproxy
```
To restore:
```bash
docker network connect llm-egress mitmproxy
```
This disconnects mitmproxy from the egress network. Since all container internet
traffic routes through mitmproxy, this effectively cuts internet for all containers.

### Add a local model
Open WebUI → Settings → Models → enter model name (e.g. `llama3.3`) → pull.

Or via terminal (Ollama runs natively, so use `ollama` directly, not `docker exec`):
```bash
ollama pull llama3.3
```

### List models
```bash
ollama list
```
Or check the API:
```bash
curl http://localhost:11434/api/tags
```

### Remove a model
```bash
ollama rm modelname
```

### Add a cloud LLM (OpenAI, Anthropic, etc.)
Open WebUI → Settings → Connections → add the API endpoint and key.
Keys should come from 1Password — never paste them into a config file.

### View egress proxy traffic
```bash
open http://localhost:8081
```
Every outbound request from Open WebUI appears here in real time.

### Check what's running
```bash
docker compose ps
```

### View container logs
```bash
docker compose logs open-webui
docker compose logs mitmproxy
docker compose logs -f open-webui   # follow in real time
```

For Ollama logs (runs natively, check the app or Console.app):
```bash
# Ollama logs go to macOS unified logging
log stream --predicate 'process == "ollama"' --level debug
```

---

## Troubleshooting

### Port 3000 not reachable
Open WebUI is on `llm-internal` which is `internal: true`. On macOS Docker Desktop,
containers only on internal networks don't bind host ports. The `host-access`
bridge network in compose.yml exists solely to work around this limitation — it has
no security role. Both `llm-internal` and `host-access` are required on open-webui.

### Ollama not reachable from inside Docker
Open WebUI resolves `host.docker.internal` to reach Ollama on the host. This
hostname only resolves if `extra_hosts: - "host.docker.internal:host-gateway"` is
set on the container. Check compose.yml — it's there. If it stops working after
a Docker Desktop update, verify this line is still present.

### "No models available" in Open WebUI
- Check Ollama is running: `curl http://localhost:11434/api/tags`
- If Ollama isn't running: `open -a Ollama`
- Check `OLLAMA_BASE_URL` in `~/docker/.env` matches the running Ollama address

### Ollama crashes immediately on startup (Metal error)
See "Why Ollama as a native app (cask)" above. Ensure you have the cask version:
```bash
brew list --cask | grep ollama     # should show ollama
brew list --formula | grep ollama  # should be empty
```
If you have the formula, switch:
```bash
brew uninstall ollama
brew install --cask ollama
```

### mitmproxy web UI shows 403
The web UI is password-protected. Password is set via `MITMPROXY_PASSWORD` in
`~/docker/.env` (defaults to `admin` if not set). If you've changed it, check
your `.env` file.

### Open WebUI stuck on loading / blank screen
Usually Open WebUI starting before it's fully ready. Check logs:
```bash
docker compose logs open-webui
```
Wait 10-15 seconds after `docker compose up -d`, then reload.

---

## How to add a new model runtime (beyond Ollama)

When you want to add a second model runtime:

1. Add a new service to `docker/compose.yml`
2. Connect it to `llm-internal` (so Open WebUI can reach it)
3. Ensure its traffic routes through mitmproxy (set `HTTP_PROXY`/`HTTPS_PROXY` env vars)
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
  compose.yml       Docker Compose service definitions
  .env.example      template showing which env vars are needed (no real values)
  .env              your actual env vars — gitignored, never committed
  .gitignore        ensures .env is never committed
```

The `~/docker/` directory is intentionally NOT managed directly by chezmoi.
You may edit `compose.yml` locally while iterating. A drift check in `~/.zshrc`
warns you when your local files differ from the chezmoi source, so you remember
to commit changes back.

---

## Key decisions log

| Decision | Chosen | Rejected | Reason |
|---|---|---|---|
| Control plane | Open WebUI | Raw YAML, Portainer | Purpose-built for LLMs, right abstraction level |
| Local runtime | Ollama (cask) | Docker Model Runner, llama.cpp, LM Studio | Maturity, 45K+ models, native Open WebUI support, faster single-session |
| Ollama install method | `brew install --cask ollama` | `brew install ollama` (formula) | Formula crashes on macOS 26 Tahoe with Metal error; cask resolves it |
| Ollama location | Host (native) | Docker container | Metal GPU requires host access on macOS; no viable workaround |
| Egress proxy | mitmproxy | iptables, pfctl | Visible, scriptable, inspectable web UI |
| Host-level monitoring | Little Snitch | mitmproxy alone | mitmproxy only sees containers; Ollama runs on host — Little Snitch covers the gap |
| Remote/cloud access | Tailscale | Public port + auth | No public exposure, no firewall rules, works with existing Tailnet |
| Kill switch granularity | Group (disconnect mitmproxy from llm-egress) | Per-container | Simpler, extensible later |
| Model version pinning | Not pinned | Pinned in compose.yml | Too volatile, downloaded fresh each time |
| API key storage | 1Password → Open WebUI | .env files, config files | Security, rotation, never touches disk |
| Sensitive dir mounts | Forbidden | Allowed with restrictions | Simpler security model — no exceptions |
| Docker Model Runner | Deferred (re-evaluate 2027) | Adopted now | 1 month old, smaller model library, no Open WebUI native support yet |
| HTTPS interception | Not configured | mitmproxy CA in container | Added complexity, low value for personal use; connection metadata still visible |
