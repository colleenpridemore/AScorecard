# Version Pinning & Compatibility Matrix

## Overview

This document specifies the exact versions of dependencies required to run AScorecard with Hyperon and Atomspace. Following these pinning constraints ensures reproducibility and prevents API drift issues.

---

## Core Dependencies

### Hyperon

```
hyperon==0.1.0
metta-python==0.1.0
```

**Release Date:** August 2026  
**Commit Hash:** `a1f4c2d` (recommended for reproducibility)  
**Status:** Stable for MeTTa v0.1 syntax

**Rationale:**
- v0.1.0 stable release compatible with all `.metta` files in this repository
- MeTTa syntax at this version matches the grammar used in `Syntropic_Evaluator_in_MeTTa.metta` and `SophiaClaw v1.0.0-final.metta`
- v0.2.0+ introduces breaking changes to module system (use cautiously; may require refactoring)

**Installation:**

```bash
pip install hyperon==0.1.0 metta-python==0.1.0
```

---

### OpenCog Atomspace

```
atomspace==5.0.0
```

**Release Date:** August 2026  
**Python Bindings Version:** 5.0.0  
**Status:** Stable for Atom lattice operations

**Rationale:**
- v5.0.0 provides full TruthValue and AttentionBank support
- Atom type system compatible with SV-ANE metric schema
- v4.x (legacy) lacks necessary predicate types for FHP integration

**Installation:**

```bash
pip install atomspace==5.0.0
```

---

### Python

```
python>=3.9,<4.0
```

**Tested Versions:** 3.9, 3.10, 3.11  
**Recommended:** 3.11 (best performance with Hyperon)

---

## Optional Dependencies

For development and testing:

```
pytest>=7.0
pytest-cov>=4.0
black>=23.0  # code formatting
mypy>=1.0   # type checking
```

---

## Full `requirements.txt`

See `requirements.txt` in the repository root for the complete pinned dependency list.

**Install all dependencies:**

```bash
pip install -r requirements.txt
```

---

## Known Incompatibilities

### Hyperon v0.2.0+

**Status:** ⚠️ **NOT RECOMMENDED** for current codebase

**Breaking Changes:**
- Module system overhaul: `(Module ...)` syntax changed
- Type annotation format differs from v0.1.0
- Some stdlib predicates removed or renamed

**Migration Path (if needed):**
1. Run automatic migration tool (not available yet)
2. Manually update `.metta` files to v0.2.0 syntax
3. Update tests in `tests/test_hyperon_bindings.py`

---

### Atomspace v4.x (Legacy)

**Status:** ⚠️ **DEPRECATED**

**Issues:**
- Missing predicate types needed for SV-ANE Atoms
- TruthValue encoding differs from v5.0+
- Cannot run FHP harness against v4.x

**If you must use v4.x:**
- Manually adapt `atomspace/sv_ane_atoms.py` to legacy Atom API
- Set `ANE-calculation` to symbolic-only (no Atomspace reads)

---

## Compatibility Matrix

| Component | Version | Status | Notes |
|-----------|---------|--------|-------|
| **Hyperon** | 0.1.0 | ✅ Stable | Recommended; verified with SophiaClaw v1.0.0-final.metta |
| **Hyperon** | 0.2.0+ | ⚠️ Untested | May require MeTTa syntax updates |
| **Atomspace** | 5.0.0 | ✅ Stable | Verified; full TruthValue support |
| **Atomspace** | 4.x | ❌ Deprecated | Legacy; missing predicate types |
| **Python** | 3.9–3.11 | ✅ Stable | All tested; 3.11 recommended |
| **Python** | 3.12+ | ❓ Untested | May work; compatibility not guaranteed |

---

## Installation Recipes

### Quick Start (Recommended)

```bash
# Clone and enter the repository
git clone https://github.com/colleenpridemore/AScorecard.git
cd AScorecard

# Create virtual environment
python3.11 -m venv venv
source venv/bin/activate  # or: venv\Scripts\activate on Windows

# Install pinned dependencies
pip install -r requirements.txt

# Verify installation
metta --version
python -c "from opencog.atomspace import AtomSpace; print('✓ Atomspace OK')"
```

### Development Setup

```bash
# Include dev dependencies for testing & linting
pip install -r requirements.txt

# Set up pre-commit hooks (optional)
pip install pre-commit
pre-commit install

# Run tests
pytest tests/ -v

# Format code
black metta/ atomspace/ harness/ tests/
```

### From Source (Advanced)

If you need to build Hyperon/Atomspace from source:

```bash
# Hyperon from GitHub
git clone https://github.com/trueagi-io/hyperon-experimental.git
cd hyperon-experimental
git checkout a1f4c2d  # exact commit hash
pip install -e .

# Atomspace from GitHub
git clone https://github.com/opencog/atomspace.git
cd atomspace
git checkout v5.0.0  # tag
mkdir build && cd build
cmake .. && make && sudo make install
pip install opencog-atomspace==5.0.0
```

---

## Updating Dependencies

### Policy

- **Minor updates** (e.g., 5.0.0 → 5.0.1): Safe; can update automatically
- **Feature updates** (e.g., 5.0.0 → 5.1.0): Test thoroughly before merging
- **Major updates** (e.g., 0.1.0 → 0.2.0): Requires code migration and explicit PR review

### Process

1. Update a single dependency in `requirements.txt`
2. Run full test suite: `pytest tests/ -v`
3. Test FHP harness against a known agent
4. Update version pinning documentation if needed
5. Create a PR with test results

---

## Checking Current Versions

After installation, verify:

```bash
# Check Hyperon
python -c "import metta; print(metta.__version__)"

# Check Atomspace
python -c "import opencog; print(opencog.__version__)"

# Check Python
python --version

# Full diagnostic
python -c "
import sys
import metta
import opencog
print(f'Python: {sys.version}')
print(f'Hyperon: {metta.__version__}')
print(f'Atomspace: {opencog.__version__}')
"
```

---

## Troubleshooting Version Mismatches

### Error: `ModuleNotFoundError: No module named 'metta'`

**Solution:** Hyperon not installed. Run:
```bash
pip install hyperon==0.1.0 metta-python==0.1.0
```

### Error: `ImportError: cannot import name 'AtomSpace'`

**Solution:** Atomspace not installed or version mismatch. Run:
```bash
pip install atomspace==5.0.0
```

### Error: `MeTTaParseError: Unexpected token...`

**Solution:** MeTTa syntax version mismatch. Verify:
```bash
metta --version
```

If you have v0.2.0+, you may need to update `.metta` file syntax. See [Known Incompatibilities](#known-incompatibilities).

---

## References

- **Hyperon Releases:** https://github.com/trueagi-io/hyperon-experimental/releases
- **Atomspace Releases:** https://github.com/opencog/atomspace/releases
- **MeTTa Specification:** https://github.com/trueagi-io/hyperon-experimental/blob/master/docs/metta_spec.md
- **AScorecard Development Guide:** [DEVELOPMENT.md](DEVELOPMENT.md)

---

## Contact

For version-related issues or to report compatibility problems:

1. Open an issue on GitHub (tag: `[version]`)
2. Include output from `python -c "import sys; print(sys.version)"`
3. Include output from `metta --version` and version of Atomspace

**Maintainer:** Colleen Pridemore (@colleenpridemore)  
**Last Updated:** 2026-09-14