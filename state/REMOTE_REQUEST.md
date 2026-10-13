# REMOTE REQUEST

Current remote task: BASELINE_COLLECT

Collector:
- Keep output small and text-first.
- Confirm game EXE and gamedll hashes, sizes, loaded data*.pak files, and live module list if DLTB is running.
- Do not upload saves or full memory dumps.

Monitor:
- Initial monitor is only a workflow smoke test.
- Do not run unless ChatGPT explicitly asks for it.

Apply:
- No candidate is active yet.

Clean:
- No candidate is active yet.

MASTER STATE RULE:
After ChatGPT reads a meaningful collector/monitor result or receives a candidate verdict, update MASTER_STATE.md before creating the next test.
