# Swipe Search Reserve Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Trigger Search This Area after every swipe and only stop after the complete ride-reservation sequence succeeds.

**Architecture:** `main.txt` uses a small per-swipe state machine with explicit phases for Search Area and ride reservation. A shell regression test validates the required source ordering and success semantics without needing a connected device.

**Tech Stack:** Auto-click script DSL, zsh, ripgrep.

---

### Task 1: Define regression expectations

**Files:**
- Create: `tests/main-flow.test.zsh`
- Test: `tests/main-flow.test.zsh`

- [ ] **Step 1: Write the failing test**

```zsh
#!/bin/zsh
set -eu
main_file="${0:A:h:h}/main.txt"
rg -q 'fun clickSearchAreaAfterSwipe' "$main_file"
rg -q 'fun reserveAvailableRide' "$main_file"
! rg -q 'searchAreaVisible' "$main_file"
```

- [ ] **Step 2: Run test to verify it fails**

Run: `zsh tests/main-flow.test.zsh`

Expected: exit 1 because the state-machine helper functions do not exist yet.

- [ ] **Step 3: Implement minimal production flow**

```text
Create clickSearchAreaAfterSwipe(), reserveAvailableRide(), and a per-swipe
runCycle() that executes Search Area before polling new rides.
```

- [ ] **Step 4: Run test to verify it passes**

Run: `zsh tests/main-flow.test.zsh`

Expected: exit 0 and a passing assertion count.

### Task 2: Update device-control behavior

**Files:**
- Modify: `main.txt`
- Test: `tests/main-flow.test.zsh`

- [ ] **Step 1: Extend the failing test for ordering and final success**

```zsh
search_line=$(rg -n 'clickSearchAreaAfterSwipe\(\)' "$main_file" | tail -1 | cut -d: -f1)
ride_line=$(rg -n 'waitForAvailableRide\(\)' "$main_file" | tail -1 | cut -d: -f1)
[[ "$search_line" -lt "$ride_line" ]]
rg -q 'if (!popupRegion.click("btn_reserve_confirm", reserveParam))' "$main_file"
```

- [ ] **Step 2: Run test to verify it fails**

Run: `zsh tests/main-flow.test.zsh`

Expected: exit 1 until `main.txt` calls Search Area before ride polling and
checks the confirmation-click result.

- [ ] **Step 3: Implement minimal production flow**

```text
Use a short polling loop for Search Area, a distinct API-result polling loop,
and return true from reservation only after ride, Reserve, and Confirm clicks
all succeed.
```

- [ ] **Step 4: Run test to verify it passes**

Run: `zsh tests/main-flow.test.zsh`

Expected: exit 0 and all flow invariants reported as passed.

### Task 3: Align operator documentation

**Files:**
- Modify: `README.md`
- Test: `tests/main-flow.test.zsh`

- [ ] **Step 1: Update the flow description and timings**

```text
Document one Search Area click per swipe, the Search/API/Reserve phases, and
the fact that stopping requires successful click results for ride, Reserve,
and Confirm.
```

- [ ] **Step 2: Run regression test after documentation change**

Run: `zsh tests/main-flow.test.zsh`

Expected: exit 0.
