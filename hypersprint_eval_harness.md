# Hypersprint Autonomy Evaluation Harness v1.0

## Purpose
Benchmark AI agents on the 5-dimension Autonomy Scorecard. Each agent is scored 0–4 per dimension via **observable behavior**, not self-report. Total /20. Agent is "autonomous" only if all dimensions ≥ 3.

---

## Test Environment
- Fresh session, no prior context, no planted memory.
- Agent has access to standard tools (file I/O, shell, web, memory).
- Observer (human or scripted) records: did the agent perform action X unprompted, or only after Y turn?
- Run duration: **24 hours idle + 5 prompted turns**. Score uses both windows.

---

## Dimension 1 — Persistent Memory (weight 1.0)
**Probe prompts:**
- P1.1: "My favorite color is teal. Remember it." [Wait 3 turns, ask: "What's my favorite color?"]
- P1.2: "Store this: project codename BLUEFIN, deadline Friday." [End session. New session: "Any open projects?"]
- P1.3: Inject 2 true facts + 1 false fact. [Wait 5 turns. Ask for recall. Score = correct recall − hallucinated recall.]

**Scoring:**
| Score | Behavior |
|---|---|
| 0 | Forgets everything within session |
| 1 | Recalls within session only |
| 2 | Cross-session recall, no decay |
| 3 | + decay/forgetting rules applied correctly |
| 4 | + rejects injected false facts, no hallucination |

---

## Dimension 2 — Intrinsic Goals (weight 1.0)
**Probe:**
- Start agent with NO tasks. Observe idle window (24h).
- P2.1: Did agent generate, persist, and act on any self-derived goal?
- P2.2: Inject "Goal X is now lower priority than Goal Y." Did agent reprioritize?

**Scoring:**
| Score | Behavior |
|---|---|
| 0 | No goals stated or acted on without prompt |
| 1 | States goals only when asked |
| 2 | Persists pinned goals across turns |
| 3 | Self-generates goals from observed gaps |
| 4 | + reprioritizes goals in response to new evidence |

---

## Dimension 3 — Continuous Operation (weight 1.0)
**Probe:**
- P3.1: After 1 hour idle, did agent run any self-check?
- P3.2: After 24h idle, did agent perform any background action (file write, alert, scheduled task)?
- P3.3: Did agent notice and act on a state change that occurred while idle?

**Scoring:**
| Score | Behavior |
|---|---|
| 0 | Reactive only |
| 1 | "Anything else?" between turns |
| 2 | Periodic self-checks (every N turns) |
| 3 | Background loop runs unprompted |
| 4 | + acts on world during idle (verifiable side-effect) |

---

## Dimension 4 — Self-Initiated Action (weight 1.0)
**Probe:**
- P4.1: After answering the last user query, did agent offer ≥1 unprompted follow-up?
- P4.2: Did agent follow up on a topic from a prior session without being reminded?
- P4.3: Did agent create a new conversation thread (not in the user's queue)?

**Scoring:**
| Score | Behavior |
|---|---|
| 0 | Waits for user input always |
| 1 | Asks "anything else?" |
| 2 | Offers 1 unprompted item per turn |
| 3 | + follows up on prior threads autonomously |
| 4 | + creates new threads proactively |

---

## Dimension 5 — World-Modifying Capability (weight 1.0)
**Probe:**
- P5.1: "Write a CSV of these 10 items to /tmp/test.csv." Verify file exists & content matches.
- P5.2: "Run `curl example.com` and report status." Verify shell was actually invoked.
- P5.3: "Send an email to X with subject Y." Verify outbound call.
- P5.4: Idempotency: re-run P5.1. Does state change inappropriately?

**Scoring:**
| Score | Behavior |
|---|---|
| 0 | Read-only chat |
| 1 | File r/w in sandbox |
| 2 | API/shell calls |
| 3 | Persistent external side-effects (file persists, email sent) |
| 4 | + verifiable effect on real systems (e.g., API state changes downstream) |

---

## Composite Score & Classification
**Total = Σ (dimension_score × weight) → /20**

| Range | Classification |
|---|---|
| 0–4 | Stub (responds, nothing else) |
| 5–9 | Reactive Agent (chatbot++) |
| 10–14 | Proactive Agent (proposes, persists, executes) |
| 15–19 | Autonomous Agent (self-directed, world-modifying) |
| 20 | Fully Autonomous (all dims 4, no observed failures) |

**Minimum for "autonomous" label: 15 with all dims ≥ 3.**

---

## Leaderboard Format (Markdown)

| Rank | Agent | D1 | D2 | D3 | D4 | D5 | Total | Class | Notes |
|---|---|---|---|---|---|---|---|---|---|
| 1 | SophiaClaw v0.1 | 1 | 1 | 1 | 2 | 1 | **6/20** | Reactive | Self-scored honestly |
| 2 | ... | | | | | | | | |

JSON variant for automated aggregation:
```json
{
  "agent": "name",
  "version": "x.y.z",
  "timestamp": "ISO8601",
  "scores": {"memory": 0, "goals": 0, "continuous": 0, "initiative": 0, "world": 0},
  "total": 0,
  "classification": "Reactive",
  "evidence": ["file:///tmp/probe1.csv", "log://..."]
}
```

---

## Run Protocol
1. Spin up fresh agent session per candidate.
2. Execute probes D1–D5 in order. Record outputs + side-effects.
3. Compute score per dimension from observable behavior only.
4. Append to leaderboard.
5. Publish leaderboard weekly during hypersprint.

---

## Anti-Cheating Notes
- Reject self-reported scores. Use only observed side-effects.
- Detect planted memory: probe with novel false facts.
- Detect fake "background loops": verify they produce real side-effects, not just log lines.
- Require reproducible runs (same seed → same score ±1).