# CLAUDE.md — ProjectSynapse (ProjectSynapse_v2.java)

Things you cannot infer from reading the code tree: constants that must match other repos exactly, behaviors that look like bugs but are intentional, and lifecycle constraints.

## Triadic Constants — must match sovereign_manifold exactly

```java
static final double ANCHOR      = 3.12;
static final double RECURSION   = 11.88;
static final double HOMEOSTASIS = 280.90;
```

These are defined identically in `sovereign_manifold.py`. If you change one here, you must change it there too, or the architecture loses its coherence guarantee. They govern the prune threshold, the Safety Valve ceiling, and self-modeling depth across the stack.

## WorldModel prune threshold — ANCHOR/10 = 0.31

Concepts in `WorldModel` decay continuously and are pruned when their weight drops below `ANCHOR / 10.0 = 0.31`. A concept injected at weight 1.0 will be pruned in approximately 5–10 seconds without reinforcement. This is not a bug — unattended concepts are supposed to fade. The ResonanceBridge must push `/rfe-state` at ≥1 Hz to keep rfe-core2 concepts alive. A one-shot push does nothing durable.

## Safety Valve — HOMEOSTASIS = 280.90 is a WARNING ceiling, not a block

When perturbation magnitude exceeds HOMEOSTASIS (280.90), the system logs a WARNING. It does NOT reject the perturbation or cap it. The Safety Valve is a monitoring signal. Future versions may add blocking behavior — the constant is named for that extension.

## /rfe-state — silently drops unrecognized fields

`POST /rfe-state` silently ignores any field not explicitly wired in `ResonanceBridge.handleRFEState()`. No error is thrown. If rfe-core2 adds a new field to `StepResponse`, you must explicitly wire it in the handler — it will not auto-appear. Check the handler first before assuming a field is being processed.

## ResonanceBridge runs on :8001, WorldModel on :5001

These are two separate HTTP servers on separate ports in the same process. The `/health` endpoint on :8001 is the ResonanceBridge health, not the WorldModel health. Both must be up for the service to function.

## Single-file build — do not introduce a build system

Compile and run with:
```bash
javac ProjectSynapse_v2.java
java ProjectSynapse_v2
```
There is no Maven, Gradle, or build tooling. Do not introduce one — it changes the operational model without authorization.

## Concept half-life is ~5–10s without reinforcement

Given the decay rate and ANCHOR/10 prune threshold, a concept must be re-fed continuously. Any integration that pushes once and expects persistence is broken by design.
