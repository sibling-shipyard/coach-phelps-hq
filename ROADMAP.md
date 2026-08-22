# Coach Phelps — Roadmap

Structure: **Epic → Task** (two levels). Epics are GitHub issues with linked sub-issues and live progress bars; they span workstreams — the stream stays a label on each task.

This file is the curated view; issues are the record. Flip a box here or tell Uno — it regenerates from issues, never drifts.

**Priority:** P0 unblocks Nats · P1 unblocks 10 users · P2 good to have (incl. M4)

## ✅ M2: Onboard Nats

### ✅ Epic: Chat reliability — THE GATE (#295) — CLOSED Aug 22

- [x] #296 MVP chat commit works
- [x] #297 Gemini end-to-end in coach chat — web + iOS (checklist: #280)
- [x] #298 First-session protocol
- [x] #280 Coach chat: consolidated manual test checklist
- [x] #347 Refactor coach-chat.ts
- [x] #424 validate-soul can't fail CI

### ✅ Epic: Onboard Nats (#299) — CLOSED Aug 22

- [x] #300 Remove sleep analytics (simplify onboarding)
- [x] #301 Remove PRE
- [x] #358 Carve ships no SOUL — a fresh repo cannot run BYOB
- [x] #292 bob: pre-populate vs_usual baseline — moved to M3 (p1) per 2026-08-22, not blocking Nats

_Supporting:_ #292 now in M3

## 🎯 Now — M3: Scale to 10

### Epic: New-user magic (#302)

- [ ] #303 Review: setup flow becomes a beautiful journey
- [ ] #304 Empty activity history handling
- [ ] #305 Coach uses 1-year history patterns in FSP
- [ ] #306 Coach chat works perfectly for FSP
- [x] #362 First-session predicate can never complete

### Epic: Homescreen UX (#307)

- [ ] #308 iOS bug batch: couldn't-load-home error, navbar moves lower
- [ ] #309 Redesign home page
- [ ] #310 Webapp: better SVG activity icons
- [ ] #311 Webapp: reuse color system from iOS
- [ ] #312 Webapp bug batch: items from Skanda's WhatsApp list
- [ ] #354 ios: CoachHQWidget.entitlements not referenced

### Epic: Sport-agnostic core (#313)

- [ ] #314 Generalize home widgets beyond current sports
- [ ] #315 Badminton + calisthenics analytics
- [x] #316 challenge_v2 seasons/phases + quest_history — absorbed into #86/#378; leftover is #411
- [ ] #156 healthkit-enrichment
- [ ] #365 Workout templates aren't generic — Coach can't personalise them
- [ ] #367 Audit the quest/gamification system end to end
- [ ] #460 athlete_insights: expose category as sub-tag breakdown

### Epic: Coach depth (#317)

- [x] #357 SOUL v5.8 trim (509 → ~232 app / ~289 BYOB)
- [x] #318 SOUL split (post-trim)
- [ ] #359 App silently drops archive writes
- [ ] #360 What does an ordinary turn need in context?
- [ ] #319 Coach patterns per user
- [ ] #320 Coach comment widget powered properly
- [ ] #321 Narrative to 5/5: first-week experience, strength benchmark
- [ ] #322 Coach memory: shrink coach-notes
- [ ] #323 Chat UI polish + layered prompts (incl #270)
- [ ] #324 Nuances: cycles, injuries, pregnancy, new sports, cross-sport load
- [ ] #270 [coach-chat] Stream Gemini responses instead of full-response wait

### Epic: Platform hardening (#325)

- [ ] #326 Plugin install flow
- [ ] #327 How updates reach athlete repos
- [x] #328 Docs audit + agent framework: prune role files, clean docs (incl #130)
- [ ] #329 Testing framework shape (decision)
- [x] #130 [core] Prune and separate eng vs coach docs; add path CI
- [ ] #361 App writes current_week.json without validation
- [x] #363 Carve template drift
- [x] #366 validate-soul: lint SOUL against reality
- [ ] #454 Athlete-repo leftovers: keep BYOB files, decide fate of sleep_log/opponent_notes/archived seasons later
- [ ] #292 bob: pre-populate vs_usual baseline (moved from M2)
- [ ] #414 iOS Builder's boot is the heaviest, and the role-doc diet barely moved it
- [ ] #415 validate_kdb path checker silently skips paths after an odd backtick
- [ ] #416 Staleness rule only polices docs that opted in via Status: Current
- [ ] #417 Widen validate_kdb path-checking to .claude/hooks/
- [ ] #419 decide schema-version migration policy before version:2
- [ ] #436 coach_log.json grows unbounded — cap/rotate storage
- [ ] #462 Hard caps on agent-written free text — per-entry limits in SOUL + validate-data
- [x] #392 Delegation rule charges a cold boot for every task

### Epic: Stretch features — M3 (#330)

- [ ] #331 Per-activity screens
- [ ] #332 Product page: web margins
- [ ] #333 Product page: animation improvements
- [ ] #334 Codebase refactor: remove dead code (#288 #223 #224)
- [ ] #348 ui: drop explicit opponent name mapping (nameAliases.ts)

### ✅ Epic: Coach data redesign — group files by how often they change (#378) — CLOSED Aug 22

Schema migration done (Part 1 #406, Part 2 #409/#412, #408, #410). Epic tracks final verification + closing.
- [x] #406 Part 1 — profile/memory/injuries/sessions
- [x] #408 memory_update batch-job rework
- [x] #409/#412 Part 2 — seasons/quests/progress/progressions
- [x] #410 quest_event multi-quest fix
- [ ] #411 season-closing recap/archive ritual — revisit whether to bring it back (follow-up)

## 🚀 M4: Beyond 10+

### Epic: New features — M4 (#335)

- [ ] #336 Live Activity
- [ ] #337 Apple Watch app
- [ ] #338 Rich interactions for widgets (calendar, contextual empty states, motion)
- [ ] #339 Animations pass
- [ ] #340 Category tagging via rules
- [ ] #341 Sleep analytics (rebuild)

### Epic: Ready for strangers — M4 (#342)

- [ ] #343 Testing framework: LLM benchmarks + iOS UI tests
- [ ] #344 Product page dashboard check
- [ ] #345 Remove "Phelps" everywhere (rebrand)
- [ ] #346 Signup-as-runner/cyclist reality check

## 🧊 Backlog — P2

- #68 calories 12k hardcode · #21 Vercel KV races · #239 silent re-auth
- #247 bob: prune unwanted keys from old activities (Skanda & Akash repos)

## 🔀 Decisions to take

- [x] **Gemini vs Claude** — blocks M2 chat — RESOLVED, Gemini e2e shipped (#297 closed Aug 22)
- [ ] backend+DB (P2)

## ✅ Done

**Aug 22 — M3 board hygiene:** #299 M2 epic closed (#292 lives in M3), #316 absorbed into #411, #318/#392 closed as shipped, #440/#441 iOS sync+Health Settings shipped
**Aug 22 2026 — M2 Chat gate closed:** #295 epic closed, #296 MVP chat, #297 Gemini e2e, #298 FSP, #424 validate-soul CI, #358 carve SOUL fix, #459 athlete_insights bucket fix
**Aug 22 — Auto-sync:** Auto-sync when new activity lands — already works (moved from Vision)
**Aug 16-21 — Schema + trim:** #300 sleep analytics removed, #301 PRE removed, #406 Part 1 schema, #408/#409/#412 Part 2 schema, #357 SOUL trim, #362 predicate, #363 carve drift, #366 validate-soul lint, #455 carve-skeleton + migration plan

## 🧭 Vision — north star, unscheduled

- lock-screen tracking · coach pre-reads + drops proactive comments · widgets inside chat · configurable widget sets · crazy narrative dashboards / unique insights

