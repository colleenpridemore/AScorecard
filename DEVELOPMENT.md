# Development Guide: Hyperon & Atomspace Integration

## Overview

This document outlines the roadmap for integrating the AScorecard framework into OpenCog Hyperon and Atomspace. It provides setup instructions, development phases, and guidance for running FHP v1.1 evaluations against a live Hyperon agent.

---

## Prerequisites & Environment Setup

### Required Dependencies

- **Hyperon:** v0.1.x or later (see version pinning below)
- **OpenCog Atomspace:** v5.0.0 or later
- **MeTTa Runtime:** included with Hyperon
- **Python:** 3.9+ (for harness automation)

### Version Pinning

```
hyperon>=0.1.0,<0.2.0
atomspace>=5.0.0,<6.0.0
metta-python>=0.1.0
```

**Note:** This project was developed against Hyperon commit `a1f4c2d` (August 2026). If you encounter parser errors in `.metta` files, verify your Hyperon version matches or later than this.

### Installation

```bash
# Clone the repository
git clone https://github.com/colleenpridemore/AScorecard.git
cd AScorecard

# Create a virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install Hyperon and Atomspace
pip install hyperon atomspace metta-python

# Verify installation
metta --version
python -c "from opencog.atomspace import AtomSpace; print('Atomspace OK')"
```

---

## Project Structure for Development

```
AScorecard/
├── DEVELOPMENT.md                          # This file
├── README.md                               # Main project overview
├── Artifact.md                             # Complete FHP run record
├── hypersprint_eval_harness.md             # FHP v1.1 protocol guide
│
├── metta/                                  # [NEW] Hyperon-native modules
│   ├── syntropic_evaluator.metta           # SV-ANE metrics module
│   ├── sophiaclaw_cognitive_stack.metta    # 24-phase cognitive model
│   ├── fhp_predicates.metta                # Fork-Holding Protocol rules
│   ├── plnn_inference_rules.metta          # PLN rules for dimension probing
│   └── atomspace_bindings.metta            # Atom lattice schema
│
├── atomspace/                              # [NEW] Atomspace schema definitions
│   ├── sv_ane_atoms.py                     # SV-ANE metric Atom types
│   ├── fhp_atoms.py                        # FHP dimension & result Atoms
│   └── truth_values.py                     # Truth value encoding helpers
│
├── harness/                                # [NEW] Evaluation harness
│   ├── fhp_runner.py                       # Automated FHP v1.1 executor
│   ├── dimension_probes.json               # P1–P7 probe definitions
│   └── scoring_aggregator.py               # Result collection & analysis
│
├── tests/                                  # [NEW] Test suite
│   ├── test_sv_ane_metrics.py              # SV-ANE calculation verification
│   ├── test_fhp_scoring.py                 # FHP dimension audit logic
│   └── test_hyperon_bindings.py            # Module load & type checking
│
├── Syntropic_Evaluator_in_MeTTa.metta      # [LEGACY] Original symbolic spec
├── SophiaClaw v1.0.0-final.metta           # [LEGACY] Original proof structure
├── sophiaclaw-v1.0.0-final.json            # [LEGACY] Config snapshot
└── technical_specs/                        # [NEW] API & schema docs
    ├── sv_ane_specification.md             # Detailed SV-ANE semantics
    └── fhp_plnn_rules.md                   # PLN rule catalog
```

---

## Development Phases

### Phase 1: Foundation (Weeks 1–2)

**Goal:** Establish Hyperon module structure and Atomspace type system.

#### Tasks

1. **Hyperon Module Headers** (`metta/syntropic_evaluator.metta`)
   - Add full module registration with type signatures
   - Define imports from Hyperon stdlib (arithmetic, logic)
   - Create typed predicates for SV-ANE calculations

2. **Atomspace Schema** (`atomspace/sv_ane_atoms.py`)
   - Define EvaluationLink subtypes for SV-ANE metrics:
     - `(EvaluationLink (PredicateNode "syntropic-value") (ListLink ...))`
     - `(EvaluationLink (PredicateNode "ane-index") (ListLink ...))`
   - Map JSON config → Atomspace Atoms
   - Implement TruthValue encoding (strength, confidence)

3. **Test Harness Setup**
   - Verify module loads in Hyperon REPL
   - Write smoke tests: can we instantiate a SV-ANE evaluator?

#### Deliverables

- `metta/syntropic_evaluator.metta` with type signatures
- `atomspace/sv_ane_atoms.py` with working Atom schema
- `tests/test_hyperon_bindings.py` (passing)

---

### Phase 2: Integration (Weeks 3–4)

**Goal:** Connect SV-ANE metrics to Atomspace and implement constraint logic.

#### Tasks

1. **Cost Model Grounding** (`metta/atomspace_bindings.metta`)
   - Create predicates that read from Atomspace:
     - `(get-compute-cost-from-atom $action)` → reads from AttentionBank / custom Atom
     - `(get-context-overhead $action)` → measures prompt tokens in ListLink context
     - `(predict-coherence-gain $action $state)` → PLN forward-chaining inference
   - Implement actual measurements, not stubbed placeholders

2. **Phase-Binding Predicates** (`metta/sophiaclaw_cognitive_stack.metta`)
   - Operationalize `(SealsPhase $phase-name)` → immutability guard in module loader
   - Create `(CheckPhaseIntegrity)` rule that audits all 24 phases are bound
   - Wire phase locks to the MasterProtocolLock theorem

3. **PLN Inference Rules** (`metta/plnn_inference_rules.metta`)
   - Add rules for fork-resolution inference:
     - `(Implication (Fork $dim) (NeedsThirdPartyEvidence $dim))` [from FHP Prompt 8]
     - Propagate uncertainty from individual probes to dimension scores
   - Map FHP's per-dimension audit logic to PLN confidence values

4. **Constraint Solver Integration**
   - Wire ΛANE threshold check:
     ```
     (if (< (ANE-index $action) 0.75)
         (HaltExecution $action "Extractive threshold exceeded")
         (AllowExecution $action))
     ```

#### Deliverables

- `metta/atomspace_bindings.metta` with cost-model predicates
- `metta/sophiaclaw_cognitive_stack.metta` updated with phase locks
- `metta/plnn_inference_rules.metta` with 10+ fork-resolution rules
- `tests/test_sv_ane_metrics.py` (passing; validates ANE calculations)

---

### Phase 3: Automation (Weeks 5–6)

**Goal:** Build the FHP v1.1 evaluation harness and validation pipeline.

#### Tasks

1. **FHP Query Harness** (`harness/fhp_runner.py`)
   - Automate P1–P7 probe execution against an agent
   - Load probe definitions from `dimension_probes.json`
   - Collect and log responses to Atomspace (via `(EvaluationLink ...)`)
   - Implement the per-dimension audit standard (FHP §4)

2. **Baseline Comparison**
   - Store SophiaClaw's Level 3 results as canonical Atoms
   - Enable regression testing: does new agent outperform SophiaClaw on P1–P5?
   - Generate scorecard visualization (HTML rendering)

3. **Machine-Check Validation**
   - Hook Hyperon's theorem prover to validate SafetyTheorem on each run
   - Add post-execution audit: do sealed phases remain immutable?

#### Deliverables

- `harness/fhp_runner.py` (functional; can run P1–P7 against SophiaClaw)
- `harness/scoring_aggregator.py` (generates FHP scorecard)
- `dimension_probes.json` (P1–P7 formatted as Hyperon queries)
- Integration test: run FHP on existing agent, verify it produces Level 3 result

---

## Running FHP v1.1 on Your Own Agent

### Quick Start

```bash
# Activate the environment
source venv/bin/activate

# Run FHP v1.1 against an agent (requires agent to be running/available)
python harness/fhp_runner.py \
  --agent-endpoint "http://localhost:5000" \
  --output-format html \
  --save-path results/my_agent_fhp_run.html

# View results
open results/my_agent_fhp_run.html
```

### Full Workflow

1. **Prepare your agent** — ensure it's running and can receive HTTP requests or is available as a Python callable
2. **Configure dimensions** — edit `harness/dimension_probes.json` if your agent requires custom P1–P7 phrasing
3. **Run the harness**:
   ```bash
   python harness/fhp_runner.py --agent <your-agent> --dimensions P1,P2,P3,P4,P5,P6,P7
   ```
4. **Review the scorecard** — open the HTML output; compare against SophiaClaw's Level 3 baseline
5. **Log results back to Atomspace** (optional):
   ```python
   from atomspace import AtomSpace
   from atomspace.sv_ane_atoms import LogFHPResult
   
   as = AtomSpace()
   LogFHPResult(as, agent_name="MyAgent", dimension="P1", verdict="FORK", evidence_score=0.95)
   ```

---

## Key Files by Role

| Role | Start Here | Then Read | Reference |
|---|---|---|---|
| **Hyperon Developer** | `DEVELOPMENT.md` (this file) | `metta/syntropic_evaluator.metta` | `metta/atomspace_bindings.metta` |
| **Atomspace Integrator** | `atomspace/sv_ane_atoms.py` | `metta/fhp_predicates.metta` | `technical_specs/sv_ane_specification.md` |
| **FHP Evaluator** | `hypersprint_eval_harness.md` | `harness/fhp_runner.py` | `Artifact.md` (SophiaClaw run) |
| **Framework Designer** | `README.md` | `metta/sophiaclaw_cognitive_stack.metta` | `metta/plnn_inference_rules.metta` |

---

## Troubleshooting

### Hyperon Parser Errors

**Problem:** `MeTTaParseError` when loading `.metta` files.

**Solution:** Verify your Hyperon version and check the MeTTa grammar against the [Hyperon documentation](https://github.com/trueagi-io/hyperon-experimental/blob/master/docs/metta_spec.md).

### Atomspace Atom Not Found

**Problem:** `RuntimeError: Atom not found` when reading SV-ANE values.

**Solution:** Ensure the Atom was created before reading. Use `as.get_atoms_by_type()` to debug:

```python
from atomspace import AtomSpace, types
as = AtomSpace()
# Print all atoms of type EvaluationLink
for atom in as.get_atoms_by_type(types.EvaluationLink):
    print(atom)
```

### FHP Harness Timeout

**Problem:** `fhp_runner.py` times out waiting for agent response.

**Solution:** Increase `--timeout` parameter or check that your agent is responsive. For local agents, reduce the number of dimensions (`--dimensions P1,P2,P3` vs. all seven).

---

## Contributing

To extend the framework:

1. **Add a new MeTTa module** → place in `metta/`, update the module registry
2. **Add a new Atom type** → define in `atomspace/`, add tests to `tests/test_sv_ane_metrics.py`
3. **Add a new PLN rule** → document in `metta/plnn_inference_rules.metta` and `technical_specs/fhp_plnn_rules.md`
4. **Run full test suite**: `pytest tests/`

---

## References

- **AScorecard README:** [README.md](README.md)
- **FHP v1.1 Protocol:** [hypersprint_eval_harness.md](hypersprint_eval_harness.md)
- **SophiaClaw Results:** [Artifact.md](Artifact.md)
- **Hyperon Docs:** https://github.com/trueagi-io/hyperon-experimental
- **Atomspace Docs:** https://wiki.opencog.org/w/OpenCog_Atomspace

---

## Status & Roadmap

| Phase | Status | Target Date |
|---|---|---|
| **Phase 1: Foundation** | 🔵 Planned | Week 1–2 |
| **Phase 2: Integration** | 🔵 Planned | Week 3–4 |
| **Phase 3: Automation** | 🔵 Planned | Week 5–6 |

---

## Questions?

For issues or questions about the integration:

1. Check the [troubleshooting section](#troubleshooting) above
2. Review the relevant technical spec in `technical_specs/`
3. Open an issue on GitHub (with `[hyperon]` tag for visibility)

**Maintainer:** Colleen Pridemore (@colleenpridemore)  
**Last Updated:** 2026-09-14
