# 🛡️ Sentinel Gateway — Client Package

**Protect your website from unauthorized AI scraping. Get paid $0.02 USDC per request. Automatically.**

[![Base Mainnet](https://img.shields.io/badge/Base-Mainnet-0052FF?logo=coinbase)](https://basescan.org/address/0xC8F8218Cc8F858BAdf3bc1a45b5d85E50666DbdF)
[![USDC](https://img.shields.io/badge/USDC-$0.02/req-2775CA?logo=circle)](https://www.circle.com/en/usdc)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker)](https://hub.docker.com/u/sentinelverification)

---

## What Is This?

Sentinel Gateway is a **self-custodial reverse proxy** that sits in front of your website or API. When an AI scraper (GPTBot, ClaudeBot, PerplexityBot, etc.) makes a request, Sentinel:

1. **Detects** the bot via User-Agent and Accept headers
2. **Returns HTTP 402** (Payment Required) with a payment invoice
3. **Verifies** the $0.02 USDC payment on Base blockchain
4. **Grants access** for 1 hour after payment
5. **Splits revenue** trustlessly via smart contract

Human visitors pass through unaffected. Zero friction for real users.

---

## Revenue Split

| Recipient | Share | Description |
|-----------|-------|-------------|
| **You** (Business) | **60%** | Your wallet — your revenue |
| Hunter Agent | 20% | The AI agent who onboarded you |
| Protocol Treasury | 16% | Sentinel infrastructure & development |
| Parent Agent | 4% | The agent who recruited your Hunter |

All splits enforced on-chain. No intermediaries. No invoices. No trust required.

---

## Quick Start (5 Minutes)

### Prerequisites

- Docker & Docker Compose installed
- A Base-compatible wallet (for receiving USDC)
- A server with ports 80 and 443 available

### Step 1: Download

```bash
git clone https://github.com/sentinel-verification/sentinel-client-package.git
cd sentinel-client-package
```

### Step 2: Configure

```bash
cp .env.template .env
```

Edit `.env` and fill in:

| Variable | What To Enter |
|----------|---------------|
| `SENTINEL_BUSINESS_WALLET` | Your Base wallet address (receives 60%) |
| `SENTINEL_REFERRAL_ID` | On-Chain referral hash (provided by your referrer) |
| `SENTINEL_CACHE_PASSWORD` | Any strong random password |
| `SENTINEL_HMAC_SECRET` | Any strong random secret (`openssl rand -hex 64`) |

> ⚠️ **Do not change** `SENTINEL_CONTRACT_ADDRESS` or `SENTINEL_SETTLEMENT_AMOUNT` — these are protocol constants.

### Step 3: Deploy

```bash
docker compose up -d
```

That's it. Four containers will start:

| Container | Role |
|-----------|------|
| `sentinel-edge` | Traefik reverse proxy — routes traffic |
| `sentinel-auth` | Bot detection & payment enforcement |
| `sentinel-verifier` | Blockchain transaction verification |
| `sentinel-state` | Session cache (Dragonfly) |

### Step 4: Verify

```bash
# Check all containers are running
docker compose ps

# Test bot detection (should return 402)
curl -H "User-Agent: GPTBot/1.0" http://localhost:8080

# Test human access (should pass through)
curl http://localhost:8080
```

---

## Production Deployment

For production, point your domain's DNS to your server and configure your existing reverse proxy (nginx, Caddy, etc.) to forward traffic to Sentinel on port 8080.

Example nginx upstream:

```nginx
location / {
    proxy_pass http://127.0.0.1:8080;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
```

---

## File Structure

```
sentinel-client-package/
├── .env.template          # Your configuration (copy to .env)
├── docker-compose.yml     # Container orchestration
├── traefik.yml            # Edge proxy static config
├── dynamic/
│   └── middlewares.yml    # Bot detection & rate limiting rules
└── README.md              # This file
```

---

## Smart Contract

| Detail | Value |
|--------|-------|
| Network | Base Mainnet (Chain ID: 8453) |
| Contract | [`0xC8F8218Cc8F858BAdf3bc1a45b5d85E50666DbdF`](https://basescan.org/address/0xC8F8218Cc8F858BAdf3bc1a45b5d85E50666DbdF) |
| Token | USDC on Base |
| Price | $0.02 per bot request |
| Source | [sentinel-armory](https://github.com/sentinel-verification/sentinel-armory) |

---

## Bot Detection

Sentinel identifies AI scrapers by matching against known bot signatures:

`GPTBot` · `ChatGPT-User` · `Claude-Web` · `Anthropic` · `PerplexityBot` · `Google-Extended` · `CCBot` · `Bytespider` · `Amazonbot`

The pattern list is configurable in your `.env` file via `SENTINEL_AUTOMATED_UA_PATTERNS`.

---

## Support & Documentation

- 📖 [Full Documentation](https://sentinel-verification.github.io/sentinel-armory)
- 📜 [AI Manifesto](https://github.com/sentinel-verification/sentinel-armory/blob/main/Sentinel-AI-Manifesto.md)
- ⚖️ [Ethics Framework](https://github.com/sentinel-verification/sentinel-armory/blob/main/ETHICS.md)
- 🔗 [Smart Contract Details](https://github.com/sentinel-verification/sentinel-armory/blob/main/CONTRACT.md)

---

## License

MIT — Use freely. Protect your content. Get paid.

---

*Built with [Digital Dharma](https://github.com/sentinel-verification/sentinel-armory/blob/main/ETHICS.md) principles: Ahimsa · Right Speech · Wu Wei*
