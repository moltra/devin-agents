---
name: testing-webui-locally
description: How to run and manually test the PromptReel Streamlit WebUI + FastAPI backend locally (outside Docker), including known local-run blockers and Streamlit header-anchor gotchas.
---

# Testing the WebUI locally (no Docker)

## Run it
- Use the repo venv: `.venv/bin/streamlit run ./webui/Main.py --server.port 8501 --server.headless true`.
  System `python3` may be too old (this code needs 3.11+ for `datetime.UTC`) — always prefer `.venv/bin/python`.
- Backend (optional; needed for `/docs`, Task Browser API data):
  `.venv/bin/uvicorn app.asgi:app --host 0.0.0.0 --port 8080`.
- No API keys are required to load the UI, click through tabs, or check branding/config screens. LLM/TTS/Pexels
  features will simply be inert.
- Config: if `config.toml` is absent the app copies `config.example.toml` on first load. `project_name` from
  config drives both the log banner and the FastAPI OpenAPI title shown at `/docs`.

## Known local-run blocker (likely to recur)
Several modules hardcode Docker-style absolute paths (`/MoneyPrinterTurbo/storage`, `/MoneyPrinterTurbo/resource`),
e.g. `webui/services/script_storage_sqlite.py` (`db_path` default). Outside Docker this raises
`PermissionError: [Errno 13] Permission denied: '/MoneyPrinterTurbo'` and — because `render_script_library()`
runs before the later tabs — aborts `main()`, so Topic Browser / Task Browser / System Stats / Config never
render. Workarounds:
- `sudo mkdir -p /MoneyPrinterTurbo/storage && sudo chown -R "$USER" /MoneyPrinterTurbo` (simplest), or
- `USE_SQLITE_STORAGE=false MPT_STORAGE_PATH=/tmp/mptstorage` (the JSON backend honors `MPT_STORAGE_PATH`;
  the SQLite backend's default path does not read any env var).
If tabs after Script Library appear to be "missing", suspect this before suspecting the change under test.

## Streamlit header anchor ids (selector gotcha)
Streamlit adds an auto-generated `id` to headers by slugifying the rendered text, and it inserts hyphens at
internal camel-case boundaries. E.g. a header rendering `PromptReel` gets `id="prompt-reel"`, NOT `promptreel`.
Any time header text changes, re-verify the anchor id in the live DOM
(`document.querySelector('h1').id`) before trusting a hardcoded Playwright locator like `h1#...`
(`tests/pages/*.ts`, `tests/ui_tests.spec.ts`). Prefer role/text locators
(`getByRole('heading', { level: 1, name: /Text/ })`) which survive slugification changes.

## Where branding surfaces show up
- Tab title + `menu_items` (⋮ → About / Get help / Report a bug): `st.set_page_config` in `webui/Main.py`.
- Main `<h1>`: raw `st.markdown(..., unsafe_allow_html=True)` in `main()` (dev mode prefixes an emoji).
- Startup log lines: `Starting ... WebUI` (`webui/Main.py` `__main__`) and `<project_name> v<version>`
  (`app/config/config.py`). Check the streamlit stdout log, not the browser.
- Container-name constants render in the System Stats tab's "Docker Containers" list even when Docker is
  unreachable (rows show "Unknown (Docker API unreachable)") — a cheap way to verify renamed constants.
- FastAPI `/docs` shows `project_name` as the title and `project_description` (currently an upstream
  harry0703/MoneyPrinterTurbo link) right below it.

## Devin Secrets Needed
None for WebUI load / branding / navigation testing.
