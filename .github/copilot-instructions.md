# AScorecard Repository Instructions

## Project shape

- This repository is both a research archive and a set of benchmark specifications, not a single application. `index.html` is the main static landing page; the other HTML files are standalone protocol, artifact, and dashboard pages. Their markup and styles are maintained directly in the HTML files; there is no frontend build system.
- The benchmark protocols and run records are documented in Markdown. The SophiaClaw configuration and formal model are represented in JSON and MeTTa. The Python scoring harness (`Python Log Parser & A-Scorecard Engine.php`) and `Syntropic_Evaluator_in_MeTTa.metta` express the same SV/ANE calculations; keep formulas, thresholds, and result classifications aligned when changing either.
- `DEVELOPMENT.md` and `VERSION_PINNING.md` describe the planned Hyperon/Atomspace integration and its intended tests. The `metta/`, `atomspace/`, `harness/`, and `tests/` implementation directories described there are not present in the current tree.

## Build, test, and lint

- There is no configured build, lint, or CI command in the current repository.
- `requirements.txt` includes pytest, Black, and mypy, but no test directory or test files are currently present. The development documentation's intended suite command is `pytest tests/ -v`; for one test, use `pytest tests/test_file.py::test_name -v` after that test exists.
- The Python scoring harness is stored in a file with a `.php` suffix; it contains Python, not PHP.

## Repository conventions

- Use **Thought Gene Network (TGN)** for new forward-facing work. **Thought Gene Protocol (TGP)** is the historical name for the same methodology. Keep **Fork-Holding Protocol (FHP)** as the component name; see `TGN_FORWARD_FACING.md`.
- Preserve historical and sealed artifacts, including their original names and timestamps. The TGP-to-TGN update is a naming and lineage change, not permission to rewrite historical assessment content.
- When updating SV/ANE scoring, compare the Python harness with the MeTTa evaluator so the weights, zero-denominator behavior, thresholds, and classifications remain consistent.
