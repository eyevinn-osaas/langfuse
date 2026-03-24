# OSC Processing Changelog

## 2026-03-24T00:00:00Z

- Added `Dockerfile.osc` — combined web + worker container based on official `langfuse/langfuse:3` and `langfuse/langfuse-worker:3` images
- Added `osc-entrypoint.sh` — handles OSC environment conventions, PostgreSQL and ClickHouse migrations, starts worker in background before web
- Added `README-OSC.md` — OSC deployment documentation
- Processed by OSC Supply Pipeline Agent
