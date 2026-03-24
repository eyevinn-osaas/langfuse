# Langfuse on Eyevinn Open Source Cloud

This repository contains OSC containerization artifacts for deploying [Langfuse](https://github.com/langfuse/langfuse) on [Eyevinn Open Source Cloud (OSC)](https://www.osaas.io).

## About Eyevinn Open Source Cloud

[Eyevinn Open Source Cloud](https://www.osaas.io) is a platform for running open source software as managed services. Deploy and scale battle-tested open source tools without managing infrastructure — pay only for what you use.

## About Langfuse

Langfuse is an open-source LLM observability and analytics platform. It provides:

- **Tracing** — track LLM calls, chains, and agent runs
- **Evaluations** — score model outputs with human or automated feedback
- **Prompt management** — version and deploy prompts
- **Analytics** — dashboards for cost, latency, and quality metrics
- **Integrations** — OpenAI SDK, LangChain, LiteLLM, and more

## Deploying on OSC

### Prerequisites

Before deploying, provision the following external services:

| Service | Purpose |
|---------|---------|
| PostgreSQL | Application database |
| ClickHouse | Analytics and event storage |
| Redis | Queue and caching |

### Required Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection URL | `postgresql://user:pass@host:5432/db` |
| `CLICKHOUSE_URL` | ClickHouse HTTP URL | `http://clickhouse-host:8123` |
| `CLICKHOUSE_MIGRATION_URL` | ClickHouse native URL | `clickhouse://clickhouse-host:9000` |
| `CLICKHOUSE_USER` | ClickHouse username | `default` |
| `CLICKHOUSE_PASSWORD` | ClickHouse password | `secret` |
| `REDIS_HOST` | Redis hostname | `redis-host` |
| `REDIS_PORT` | Redis port | `6379` |
| `REDIS_AUTH` | Redis password | `secret` |
| `NEXTAUTH_SECRET` | Auth secret (run: `openssl rand -base64 32`) | |
| `SALT` | API key hash salt (run: `openssl rand -base64 32`) | |
| `ENCRYPTION_KEY` | 64-char hex key (run: `openssl rand -hex 32`) | |

### OSC-Managed Variables

These are automatically set by the OSC platform:

| Variable | Description |
|----------|-------------|
| `PORT` | HTTP port (default: 8080) |
| `OSC_HOSTNAME` | Public hostname — automatically maps to `NEXTAUTH_URL` |

## OSC Artifacts

- `Dockerfile.osc` — Container definition using official `langfuse/langfuse:3` + `langfuse/langfuse-worker:3` images
- `osc-entrypoint.sh` — Entrypoint that configures OSC conventions, runs migrations, and starts both web and worker processes

## Links

- [Langfuse Documentation](https://langfuse.com/docs)
- [Self-Hosting Guide](https://langfuse.com/docs/deployment/self-host)
- [Eyevinn OSC](https://www.osaas.io)
