# OI handoff (OOE model and RTL)

Updated 2026-11-04 (after 9718b81). Keep this current at every task's end; it is what
survives a compaction. CLAUDE.md holds the repo's rules; this holds OI's.

## Working rules
- The user is DA (Daniel). Standing order: rename top, atomics, barriers,
  AR-24 (d), then RTL items 5-8 (done but 7), then the ROB slices; no need
  to ask DA for a go unless there is a key decision point.
- Push only to `ccr-57eff422-5tdecg` (`git push -u origin HEAD:ccr-57eff422-5tdecg`,
  retry with backoff). Never push red: the clean gate is `tools/regen.sh`
  then `CCV_JOBS=4 ./tools/verify.sh`, run alone (no CoreMark beside it:
  memory). No PRs. Don't edit a tree while a gate runs in it.
- Owners: OA the microarchitecture and port budgets; DA waivers and
  anything over OA's 0.5%; TI schema/, params/, tools/ (OI carries a tools
  fix only when TI says so, as OI-89). Never weaken a negative control.
- Commits end with the Co-Authored-By and Claude-Session lines; no model
  ids in commits or artifacts.
- Register: write only the OI tab (node 384bc26c-cef6, table
  m8yvbw8rqgz.11664, rows: title, date, summary ending "Needs: X",
  detail). Notices via `.claude/skills/register/notice.py` and
  send_message. Pings weekly, Fridays (TI-49, DA).
- Trees: the container was replaced on 11-03 (scratchpad, ~/ccv-logs and every
  worktree lost; unpushed commits went with them). Work in the main checkout
  /home/user/custom-cuda-core; send an unpushed commit to gate-scratch/OI
  (`tools/gate-scratch.sh send-commit OI`) before a long gate. Disk is a fixed
  allowance (~39 GB): delete build dirs you no longer need; a gate's build is ~15 GB.

## Daily sweep (scheduled task trig_01RHTzEomNoTP7mgfQxaNkmm)
Read every tab since the bookmarks; merge every remote branch that is
ahead (not release) into wt, gate, push; pongs; pings on Fridays only;
`tools/setup-session-home.py --check` (TI-50; on a mismatch ask DA to
approve the install again, never reinstall unasked).
- Session settings installed 2026-10-31 and again 2026-11-03 (DA approved both): /home/user/.claude.
  The compact hook prints THIS checkout's .claude/handoff/OI.md: keep
  /home/user/custom-cuda-core's copy current, not only the branch's.

## Register bookmarks (revs read through)
Conventions 17, AR 269, OA 330, RA 61, IS 188, TI 304, OI 273, CP 152, DA 104
(sweep 11-03 10:16). RI tab 8e4547bc-c469 not yet bookmarked: read it next sweep.
Pings: next Friday 11-06. Settings reinstalled 11-03 (DA approved); check passes,
the compact hook printed this handoff.

## Compute (DA, 2026-10-31)
- OI-95 raised (rev 245, TI notified): persistent synth-cache incl. ABC,
  map/map -r in parallel, verify.sh --changed for working-branch pushes;
  nightly/release stay full clean. Until TI lands it, the gate is as before.
- Iterate NGD on the one-slot unit ooe_rob_s1 in scratch tree wt7 (unit
  added to wt7's test/ooe/cg-units.json only; never commit it). Confirm
  once at full size. Keep CoreMark on RH, never beside synthesis here.

## State (2026-11-02 01:30 UTC)
- wt10 (scratchpad/wt10, tip 4cbb111 = 8 commits on cfa62c6: ret hold after the
  edge, model default flip, one_resolution + control, ooe_go reserve fix, this
  handoff). Gate: detached `setsid nohup tools/gate-push.sh` (pgid 21695, log
  scratchpad/gate10.log, ~/ccv-logs/verify-4cbb111-20261101-2300.log), pushes to
  ccr-57eff422-5tdecg on green. Split gate unusable (OI-102 to TI: the only
  container channel is a 64 KiB message the model retypes). Background tasks cap
  at 2 h: long gates via setsid nohup, a waiter loop on the pgid.
- wt11 (scratchpad/wt11, worktree, branch oi-idle-r): 899b4fc + 88cd231 COMMITTED
  (RA-17 RTL + model registered rule; RA-29 (a) r_class_pair err, testRClass,
  inject_split_r_class, split_r_class price knob, collectives (kColl) in testIdleR
  warp 3; RA-29 (e) env checks pred_logic imm sources readable, testPredSources,
  inject_pq_no_dep). Model suite PASS and trio 25 PASS on 88cd231 (migs 2026,
  forced 396, 0 mismatches, 8 controls caught). Price new rule (scratchpad/idle-r-price24R.txt): K4 forced/R grants
  6.2/11.5/10.5% at 0/50/100% R share, longest migration 44/44/44 (no force
  42/131/494), cycles noise. RA-29 (a) kernel price (S1 = test/kernels via
  scratchpad/lag-kernels4.sh pattern with CCV_OOE_CONFIG=split_r_class=1, floors =
  its check-ooo line, rope, audit = ooe-test --audit AUDIT_CFG, cta-reduce =
  tools/time-bench.sh test/bench/cta-reduce*) NOT RUN: needs skel+oracles, after gate.
- NEW FINDING (raise OI row to OA): V-04 under fits_stale 6, repro in
  scratchpad/v04-repro.md (dense setp+vote/ballot, 2 warps, seed 3): a slot under
  its floor spends it twice over took(t-1)+took(t) (registered share adds
  unmetFloor a cycle early); gone at fits_stale 0. testPredSources adds a lane op
  per pair to stay clear; say so in the row.
- RA-22 checked: model rows A1/ordinary 0, copy 1, A2 2, A3 3 (makeIssue,
  memop m.row); ooe_rob counts dones per row. Confirm to OA.
- Next: commit wt11 (docs in ooe-rtl-plan.md + ooe-model.md done), merge onto the
  pushed branch, gate, push. OI row answering OA rev 299 / RA-17 (price, RTL,
  the registered rule as an RTL-realizable form with the same guarantee,
  mig_cq02h's source = the future control block, arrival free: 1.7 NGD to a
  flop); notify OA (RA: no session in local roster; say so).
- After the 4cbb111 push: OI row to OA (fill assert; OI-94 condition 2 with
  Rename's mark; ret hold budgets ret/brk 4.0 to confirm; f-f 24.4 + vel fix;
  replay-lead fix; one_resolution + control; default flip; ooe_go reserve fix).
  Sync this file to origin.

## Open work (most urgent first)
-6. FANOUT ENFORCED (TI b11e60f, ratchet rtl/ngd-ratchet.json "fanout"; caps only fall,
   remove an entry once its path meets 25). State 11-04 08:50 UTC:
   - Freelist scan (a) PUSHED 32ba2d0 (SCOPED PASS); met caps removed, PUSHED 9718b81.
     fanout f-f gpr/gsec 24.1, pred 22.8; CG clean (pred 9 of 10.3 ungated flops: keep
     rqh_cq02h a 5-flop one-hot, a derived bit 0 cost +3 NGD; fsv/fpv under their counts'
     enables). OA told (OI-106, rev 273); TI re-pinned break pins OK (OI-105).
   - NEXT (OA rev 330): gsec inputs sa_row_cq01h/sa_v_cq01h (caps 26.7/26.4): retime in
     freelist, no port budget; caps off in the same push; a lost reuse cycle -> price
     (S1+audit, <0.5% OA's). Worktree scratchpad/wtr, branch oi-fl-saretime, 0b4190a: pend
     holds rows unmasked, consumers take pend & ~rows_of(av,ar) (no extra cycle); assert
     sa_not_rt. Bench/ngd/cg running (~/ccv-logs/oi-r1.log).
   - decq lag (OA 327, DA took 15 + lag 1): worktree scratchpad/wtd, branch oi-decq-lag,
     4bd86ee (FL param, used_o lag, tb freeing, control no-free-lag): 25-seed bench PASS at
     13 entries, 5 controls caught. cg/ngd on ooe_decq running (oi-r1.log). Then gate,
     push, notify TI (TI rev 301: TI bumps CCV_P_DECQ to 15 in the same push); decq caps
     (NGD-1 26.1, NGD-3 enq_v 30.2, enq_slot 27.0, deq_t 25.3) should clear with lag 1.
   - Then: rs copies probe (OA 325) -> ratread path (OA 326) -> RA-39 (b) lead_r_src0/1
     (OA 329) -> go 25.8 path + sched peak -> OA steps 2-5 -> ROB slices 3-6.
-5. STATE 11-03 20:00: main tree gate-push (scoped, detached, log ~/ccv-logs/oi-push-1955.log)
   of c8794c1 ufq + 0d660fa (release thresholds late; rob_w NGD 25.1 -> 23.1, fo 31.6),
   1659753 prodmap, 74d070c ret_hold 2 knob, fe68bcc handoff, 91313cb audit env knobs.
   Worktree scratchpad/wtgo (on 91313cb): 0c1f6c7 go priod x dr pdr copies (go bench 25
   seeds, 13/13 controls), 72b873f sched (b) TAKEN by OA rev 320: hold masks grant after
   the pick in ooe_select, model default ret_hold 2, select/trio benches at 2, trio
   no-rep-lead control now 12 seeds (caught at 12/25, missed at 6). Full run-rtl passed
   otherwise; ooe-test PASS. GATE e1487ea RED (20:47): ooe_go NGD-3 unmet_g_cq01h (6.0) -> fitsx
   25.8 (ABC joins pdr0 copies after the pool at 9.6); ooe_sched one command 2191 MiB > 2048
   light limit (was 975; heavy-units.json is TI's). Both commits taken off the push, kept on
   local branch oi-go-sched (e1487ea) and in wtgo; push gated without them. NEXT: after the push, cherry-pick both into main, measure NGD
   (fanout) of ooe_go, ooe_sched, ooe_select ALONE, gate-push, then report to OA (rev 320
   asks depth + fanout after; still >25 -> bring the remaining path first) + go's
   remaining path and sender-drive table (hv/pl/px/unmet_g/p).
   sched (b) price (OI rev 264): ret-heavy audit 1.25 lost slots/kop, 990 -> 987 cycles;
   kernels zero exposure. OA rev 317 still owed: ooe_wake kind/cls 2.0 in ngd.json + rename akind/acls wiring.
-4. FANOUT PLAN (OA rev 310): 7aeb62a PUSHED (rob_w head read via hoh keep copies
   hrg/hrn/hrp; fanout f-f 38.7 -> 31.9). Row at OI rev 258 (corrected 262) to OA (re:RA-33, notified):
   per-unit table, rulings asked for rs and decq (free-entry candidates ahead), freelist scan, sched
   pick, rendep cp input, go fits. OI's own, no ruling: rob_w fill selects registered
   (ufh -> fl_e ~800 loads), prodmap pm_cq02h copies (~3 NGD), rename
   output copies (NGD-7; retrace the reported map first), rst_r01h copies. Tools: scratchpad/fo/path.py (worst path
   with fanout from build/synth-cache/abc-*.blif; units.txt maps module -> blif).
   OA RULED rev 318 (OA tab row .464349): NO re-budgets (port or stage). Order: retime
   from flops (no behaviour change) > model-priced change (OA <0.5%) > extra stage (DA).
   Fanout term still report-only: after functional work, cheap units first.
   - Mine (proceed): rob_w fill selects (if fl_v/fl_slot need an input->flop stage,
     bring the price BEFORE building); prodmap pm copies; rename output copies; rst
     copies (count in CG). c8794c1 (ufq register) committed, measuring.
   - sched: register the OAI21-after-gnt function beside gnt from gnt's next state,
     kept copies per row group; prove with the select bench. If it takes a same-cycle
     input, tell OA first.
   - rendep: sender registers cp already decoded (one-hot), kept copies by row group;
     report sender depth; only if it doesn't fit, price the rename stage (OA -> DA).
   - OA rev 319 (answer to OI 263): sched BUILD (a) req_f registered from next-state terms
     (no behaviour change); MODEL (b) hold after the pick (held winner cancelled, slot
     lost): lost slots/kilo-op on S1, audit, call/ret kernels (rope, recursion); <0.5%
     OA's. go: register priod x dr one-hot, kept copies 3x12 (~1.4), report remaining
     + sender-drive table for hv/pl/px/unmet_g/p (flop or logic, depth). decq: free
     candidates a cycle ahead, priced with rs alone and together (<0.5% combined OA's).
     prodmap: done 1659753 (fo 28.8 -> 17.4), nothing more unless asked.
   - go: send OA the 3 widest nets in series priod/he -> fits (loads, driver, flop or
     logic, which depend only on last cycle's state). OA rules on the list.
   - rs: model registered free candidates (S1, audit, floors); <0.5% build.
   - freelist: in2_en/as/rst copies first; model scan (a) two-step vs (b) banked on
     S1, audit, scarce-names; OA takes cheaper, (a) on tie.
-3. OI-104 DONE on OI's side: b23bbd8 (store in ooe_rs, full gate PASS), the sweep
   merge 2f64d10 (full PASS), and 1f7c642 (pushed 11-03, SCOPED PASS). 1f7c642 has
   rendep build the per-port {cls,kind} (spec from c_x bit 20, XW 21) and rename
   send akind/acls_cq04h, with wake kind/cls at 2.0 by OA rev 317. Benches compare
   the pairs, with a no-spec control. Row re:OI-104 is at OI rev 257 and TI is
   notified: it asks TI for CCV_LAT_RCU_ADDR_BASE back to 1. Nothing left for OI
   unless TI or OA answer.
-2a. STATE 11-02 (wt13 e35c9f9 = split + archive, on fe523c4 sweep merge): DA closed the
   equivalence work: old ROB + miter moved to archive/ooe-rob-split/ (README has result:
   BMC clean thru frame 9 at D8, control fails f8; never in gate/lint/bench - DA: no
   full-size ROB check may stay in a regression). Full gate via gate-push --full running
   (pgid 461, log scratchpad/gatepush13.log). Then OI row to OA+TI: figures (b) ngd 23.1,
   1915 MiB, widest head_cq02h[0] 2205; CG misfits 55 = 1.03% (win_en gate 20 @37/39%);
   budgets carried (c); TI: drop ooe_rob from tools/heavy-units.json, stale ooe_rob
   comments in check-cg/ngd + ci.yml, gate-scope selftest path rtl/ooe/ooe_rob.sv.
-2. TOP PRIORITY (DA rev 104, OA-24 rev 311): split ooe_rob into 4 identical ooe_rob_w #(WID)
   (all per-warp state inside; no unique instance; ooe_rob = wires only or the four in
   the OOE top; no parent logic). Fill: each takes Rename 2 lanes with fl_slot==WID;
   dones/MIU cmpl/R branch outcome match rob_tag warp bits == WID; frees: each flops its
   gfree/pfree + valids (cq03h/cq02h), ooe_freelist ORs the four (arrival 2.0, OA).
   Done: (a) benches/kernels pass + miter old ooe_rob vs 4x+OR4 (OR4 in harness);
   (b) ooe_rob_w flops, peak check-ngd MiB (<2048), f-f NGD w/ fanout, widest net
   (~700 expected); (c) ooe_rob.ngd.json budgets carry port by port (OA re-signs);
   (d) CG misfits at a quarter's 2% to OA. TI: cg-units, heavy-units, ratchet carry.
   Ahead of slice 2b, idle-R counter, fanout plan's rob part. Work tree wt13 (branch
   oi-rob-split off 917752b; MERGE wt11's pushed merge in first - it has TI's heavy lock).
   DONE (uncommitted, unbuilt): git mv ooe_rob -> ooe_rob_w (+ .ngd.json, budgets carried
   with a note), SA/WID params, S=1 internal, compares LS'(WID+s), TW'(WID*D+e),
   LS'(WID+r/NK); harness test/ooe/ooe_rob_tb.sv (generate g_w[w].u_w, OR4 of frees
   and leads); rob_tb.cpp -> Vooe_rob_tb; run-rtl/cg-build/cg-units -> ooe_rob_w (scope
   g_w[0].u_w: CHECK the VCD scope name); ooe_freelist FS param (ORs sources; fls/fms/fss
   internals), freelist_tb FL_FS spreads frees p%FS, lead rotates; FS 4 in freelist
   units + run-rtl/cg-build; ooe_rename FS pass-through (default 1).
   TODO: build; rob_tb force_rsv poke (rootp name) for two-resolutions; miter
   (scratchpad/miter/build.sh, rob_miter_tb.cpp: old ooe_rob as Vref); NGD/CG of the unit
   (flops, peak MiB, f-f w/ fanout, widest net); docs/ooe-rtl-plan.md; OI row to OA+TI.
-1. 917752b PUSHED (SCOPED PASS, serial). Sweep merge 9a5863f in wt11 (7 branches:
   126afa13 42, 183cc441 15, 3868632d 2, 80102643 13, 9eb50716 2, c22116ce 3, infra 15;
   walkthrough regen, perf-register union PF-47 held + PF-48/49). Gate pgid 18623,
   default jobs (TI's heavy-unit lock now in), log scratchpad/gate11c.log. Then wt12
   (ooe_wake grant-split compares) rebased onto it: measure NGD at LAT_SPEC 12/LAT_MISS 15.
-0.5 TI rev 288 (re:RA-31, row .461856): ADDR_BASE=1 (L1_WAKE 12, L1_CMPL 14, ooe_wake
   LAT_SPEC 12/LAT_MISS 15) reverted until OI fixes: (1) ooe_wake NGD-3 cls_cq01h/
   kind_cq01h 26.1/26.0 > 25 (budget arrive 9; late_time + reached(age,thr) ~l.207-218;
   precompute per-class thresholds/compare terms, or OA re-budgets); (2) run-rtl
   'control no-msd (rs)' MISSED at 12/14 (rs_tb 25 seeds; needs stimulus/seeds, control
   unchanged); (3) docs/ooe-model.md:77 L1_WAKE 16->12 at reapply; (4) merge TI's push
   (lead slice, sim/ooe/ooe_block.cpp senders fill lead). Then answer in OI tab, ring TI.
   TI tab bookmark 288.
-0.4 TI rev 289: (a) OI-102 answered (eb170bf: tools/gate-scratch.sh send/fetch-commit on
   gate-scratch/OI); CCV_HEAVY_SERIAL lock default on (tools/heavy-units.json: ooe_rob,
   ooe_rename; an unlisted unit peaking >2048 MiB fails; ooe_go 1947 is close) - list
   big units in the commit that grows them. Sweep merge SKIPS gate-scratch/* (follow at
   every sweep; the trigger prompt is unchanged, ask DA before rewriting it).
   (b) RA-33 fanout term report-only (ceil(log4(loads/4)) INV x 0.68 past fanout 4):
   10 OOE units over 25 (rob 44.3 f-f, 2783 loads; rename 30.7 / f-o 30.0, 261; rendep
   30.5, 377; rs 29.9, 377; freelist gsec 28.8, 1496 / gpr 27.7 / pred 28.3; prodmap
   28.8, 1826; go 27.7, 959; decq 26.1, 144). Asked: name each widest net (flush, valid
   broadcast, age row...) and say keep-copy replication or re-budget. Answer in OI tab.
-0.3 OA rev 310: fanout - 25 holds, no allowance. Per unit (10): widest nets, flop-driven?,
   fix (flop-driven: k (* keep *) copies at the leaves, e.g. rob 2783 -> 16x174 = 15 flops,
   6->3 stages; logic-driven: restructure/register), flop count. rob +19 = nets in series
   (row select then per-entry broadcast): register the decoded one-hot or split the row
   write. Ports over budget (rename f-o 30.0, go 25.8): NGD-7 output copies, no re-budget.
   Copies count in CG. Extra stage -> OA with price (>0.5% DA). Enforcement DA's.
   ooe_wake: OA grants cls/kind arrival 2 if driven straight from a flop w/ NGD-7 copy
   (both .ngd.json in one commit); try the shallower cone first (wt12 has it). Then
   no-msd (rs); then TI reapplies base 1 and OI reruns S1 + floors. OA bookmark 310.
0. OA revs 306-307 + AR rev 267 (RA-31/32, notices 01:36-01:40 11-02): measure
   ooe_rs select-path NGD for the issue lead slice (selected entry's section mask +
   operand-use bits, R's guard phys pred, grant-muxed and flopped; fallback a
   registered copy of the static fields); confirm no consumer of CCV_LAT_L1_WAKE is
   hardcoded at 16 (speculative wake, miss-check replay, per-row done counts,
   squashed-load free); rerun S1/floors at ~12 (with CCV_LAT_RCU_ADDR_BASE = 1).
   Checked so far: model uses cfg_.lat_l1_wake (core.cpp:1350, unitLat);
   ooe_wake LAT_SPEC param (default 16, benches from wake-params.py). Rows to read.
1. Gate/push 4cbb111; then wt11 (RA-17) as above.
2. OA revs 300-305 (unanswered): RA-22 confirm done_row 0/2/3 (A1 memop,
   A2 lane op, A3 addressless memop) - check model/RTL then answer; RA-18
   (rev 302 supersedes 300): rename writes call link pc[31:0]+bytes(ilen)
   into RS imm (imm_kind 6), target add where the branch's redirect target
   is formed (may move to record fill a cycle later); place both adds, report
   Rename NGD, budgets for moved ports to OA; RA-29 (a): one of RCU-only or
   collective a cycle as one class, both in the idle-R run and ret hold;
   assert + control that splits it; price model-only on S1, audit, floors,
   rope, cta-reduce (<0.5% OA, over DA); after the idle-R counter. RA-29 (e):
   vote/ballot predicate source substituted into imm as pand/por.
3. OA asks: S1 + rets in next floors run; OI-94 (c) price; close OI-88;
   Rename's mark with OI-94 condition 2's assert + control.
4. After AR's lead + TI's schema: branches resolve at lag 0 (lead_br_*),
   rets at 1.
5. Receivers' squash interface at assembly (RS/RAT/decq/go leads).
6. Model fixes in wt4 (release_names_lag V-01; swap seed 2 DRAM miss).
7. OI-87 (go_tb under retire_lag 1), ROB slices 3-6 (the control block that
   drives ooe_sched's mig_cq02h belongs there); RTL 7 (barriers).
