# OI handoff (OOE model and RTL)

Updated 2026-11-06 ~04:30 UTC (OI-114 awaiting OA; first-kind cmpl probe done, OI 302/303; RH jobs R49, 2, 2b). Keep this current at every task's end; it is what
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
Conventions 17, AR 298, RA 82, IS 189, TI 336, OA 350, OI 293, CP 152, DA 108, RI 15
(sweep 11-05 10:20; CP/IS searches too big to read, no bookmark).
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
-12. STATE 11-06 ~04:30 UTC. Bookmarks OA 357, AR 303, OI 303 (rev 304). Main checkout as -11.
   - First-kind miu_ooe_cmpl RTL probe DONE (worktree scratchpad/byp, probe RTL, not for push;
     ports2.py prints flop-flop, in->flop, out ready). wake: capture idx (en cv) 14.1->0, ff
     21.9->22.8, fin bypass ready 9.9; sched fin->flop 13.8 (fits); rs cfin->flop 18.6 (28.5,
     over) but a separate bypass term kept off rmask: cfb->flop 14.1 = 24.0, ff 27.1 (cap 29.4).
     rob_w: capture tag 22.1->0, ff 31.6 (cap 31.7); retire window is the arrival reader, so the
     done is an edge late (bit 1). OI 302 + correction OI 303 (OA, AR notified).
   - Model knob cmpl_split bit 8 (hit-freed RS entry held a cycle) in scratchpad/wcs (497efb8 +
     rxsplit + cmplsplit-delta + c8-delta, uncommitted): audit = base at 4 points; C9 (8|1):
     993.60/991.81/903.35/909.65 vs 983.50/990.83/896.15/898.81.
   - RH queue: R49 S1 (sent 00:30) -> job 2 (cs-run.sh: A6,C1,C2,C4,C7,F S1+audit+CM128/32)
     -> job 2b (c8-delta: C8, C9). On return: row to OA, AR with the first-kind cost.
   - Still: OI-114 awaits OA on OI 301; Friday pings (11-06); ROB slices 3-6.
-11. STATE 11-06 ~00:45 UTC. Bookmarks OA 357, AR 303, OI 301. Main checkout: branch
   oi-handoff (b8dcb7d + this) holds the unpushed handoff; ccr-57eff422-5tdecg = origin 93457a4.
   - OI-114: built in wtf branch oi-floor114, 5664f5e (gate-scratch/OI): model split floor term
     less own take (share_hold_ for the pool, share_reg_ adjusted after takes); ooe_go per-k
     uk/sgk; go_tb names<=credit assert; run-rtl scarce-names run + control floor-pre-take
     (caught only with GO_NAMES=144,24). go_tb 0 mismatches; ooe-test PASS. NGD OVER caps
     (ff 28.5, unmet_p 30.2, hv 31.4, ...). OI 301 asks OA: register unmet in ooe_rename
     (budget 6->0) + term max(0,u - last take names - take k) + need-side shift. AWAIT OA.
   - OI 300 (re OA 355/357, AR 302/303): cmpl/hint payload cones 14.1 (ooe_wake idx), 22.1
     (ooe_rob_w cm_tag), leads 1.9. A6L=A6, A6H=H3 (no runs). Promised next: RTL probe of the
     two bypasses (wake hit->fin/confirm, rob done->retire) + model knob delaying only ROB done or
     only timer hit, S1 on RH. Script scratchpad cmplcone/ports.py.
   - OI 298 cand-ahead (OA rejected, 355), OI 299 RI-11 package v2 complete. OA 354: ooe_go keep caps;
     (a)+(b) pricing low priority. RH: R49 S1 job sent 00:30 (aa9ad9c, rs_rcu=32,rs_miu=17) -> row to OA.
   - Then: ROB slices 3-6; Friday pings today (11-06).
-10. STATE 11-06 ~00:15 UTC. PUSHED 93457a4 (SCOPED PASS 22/22): 11-05 sweep merge + call link
   (c10c4b4) + handoff; OI rows 295 (TI notified: call link in) and 296 (re OA 326: ratread
   path 17.9 with fanout, under 25, off the plan; parent is ooe_rename, unbuilt, so TI's
   alone-16 question stands; OA and TI notified). Task 4 done.
   OA 352 RTL probe DONE (ri11/summary.txt): rows side <= 24.0, candidate prefix 26.0-27.2
   (16 endpoints). RH container was reclaimed; RH relaunched 22:19: Pn/Pn2048, cm32, then the
   ca audit (~02:15 UTC). Then ONE row to OA (cand-ahead + R49 + probe), and the RI-11 row
   (S1, audit, CM128: H3 +1.89% over A6; P = Ph = -0.05% vs H3) to OA, AR, DA.
   GO PATH: ooe_go at its caps (f-f 27.6, in 29.9, out 25.8; 22.8 without fanout). Measuring
   748e071 (priority decode copies, OA 319) on HEAD in scratchpad/wtgo2. Sched (b) and the
   sched peak are done (20c31b6; TI listed ooe_sched heavy).
   Bookmarks now: OA 353, OI 296, AR 300.
-9. STATE 11-05 ~11:50 UTC. OA rev 352 (re:OI 294): rs_free_lag dropped; price (1) cand-ahead
   + RTL depth, (2) 49 rows no lag, one audit. Model knob rs_cand_ahead=A in worktree
   scratchpad/wtca (branch oi-candahead, uncommitted, patch ri11/candahead.patch): candidates
   = first A free at the prior cycle's start, less that cycle's candidates; rsHeld/rsAlloc
   honour them (renCredits not, fits_stale 6 split slightly optimistic). Unit suite: all pass
   but control pair-rounds MISSED (timing; knob not for push). 4-seed audit 917 -> 959.
   RH job SENT 11-05 11:50 (after its CoreMark): ri11/ca-run.sh, 12 audits base/CA/R49 x
   s1/s0 x n0/n1 -> out/audit.txt. RTL probe caprobe/ooe_rs_ca.sv (g = req & cnd regs, cnd
   from grants(valid|cany,'1)); runs after the cf39eec gate (bfl6x8959, caprobe/ca.log).
   Base crit (old 29.2 netlist): prefix to the grant ~17.1, broadcast + row write ~12.
   Then: OI row to OA (Needs OA) with both, notify OA.
   AR rev 300 (re:RI-16, Needs incl. OI): crossing = HOP + link_n + bnd_rx (links.json, both
   hosts). AFTER TI lands it: RI prices, then OI prices D, N, Z1-Z3 and the package (AR 298,
   OA 349) as links.json no_flop configs, not rx_lag knobs. Nothing now. AR bookmark 300.
-8. STATE 11-05 ~11:00 UTC. PUSHED aa9ad9c (SCOPED PASS): RA-31 leads per OA 343 (A)
   (790a38d: lead in I at t+1, payload t+2 via gd) + OA 325 step 1 copies (ooe_rs f-f 26.2,
   sqf 26.3 AT cap 26.3, req 28.5; prv_code/row_code caps removed). OI rev 293 reported
   343/325 + step 2 (RH audit: R32 = rs_free_lag 1 + RCU 32/MIU 17 is 0.5-1.5% FASTER than
   base; ~1,944 ooe_rs flops); OA owns step 3 (DA). Notified OA.
   IN FLIGHT: wtf branch oi-sweep = oi-call (c10c4b4 call link, rebased on aa9ad9c) + daily
   merge of 126afa13 17, 183cc441 7, 80102643 14, 888218a3 20, 9eb50716 15, c22116ce 6
   (walkthrough conflicts taken ours; regen fixes). gate-push from wtf; on green ring TI
   (session_01J4Yp3xeV6DJtgCtcoqVsAq) re call link (TI rev 331 ask) with OI row.
   RI-11: OI rows 291 (pricing) and 292 (sign convention, AR). OA 349/350 + AR 298 package:
   RH runs scratchpad/ri11/pkg-run.sh + rxsplit.patch (A6, H3, P, Ph, Pn, Pn+class).
   S1 back (scratchpad/ri11/summary.txt): P +2.10% vs base, +0.44% vs AR; hint flop 0;
   cmpl flop +1.39% = global load .74 + store .39 + hinted .26 + shared .05; H3-A6 +0.56%.
   CoreMark due ~16:00 UTC: then one OI row to OA, AR, DA (Needs) + notices.
   NEXT after: OA 326 (ooe_rat via ooe_ratread, NGD with fanout, report), go path 25.8,
   sched peak, OI-114 floor term, ROB slices 3-6. TI will ring for S1+floors after PF-47.
-7. STATE 11-05 ~04:00 UTC. PUSHED 497efb8 (SCOPED PASS): RA-39 (c) payload store + issue
   register (dca9c5f), its lint/stage-tag fixes + ooe_rs heavy unit (TI 327), RI-12 fix
   (release drops the warp's queued uops, invariant, testReleaseDrop, control
   keep-released-uops, check-ooe-unit 47 controls, TI 328). OI rev 287 answered RI-12 (RI + TI
   notified; RI to merge OI's branch). Verified on RI's 600004a in scratchpad/wri (provswap 0
   check failures with the fix).
   NEXT: RI-11 pricing (OA 340) in worktree scratchpad/wtx (branch oi-ri11-price, AR params
   applied, NEVER push its params): rx_lag knob (bits 1 alloc, 2 demote, 4 syu rel, 8 rcu done,
   16 hint, 32 cmpl, 64 dec uop) in sim/ooe (uncommitted; also a --dbg-partial debug mode in
   ooe_test.cpp main to remove). wtx also has the RI-12 fix (already pushed via wtp). Plan: S1 +
   audit at base, AR, AR+rx_lag=127, each bit alone; top 2 by cost; coremark128 (>2h); report to
   DA. Scripts: scratchpad/price/run.sh, price/s1.sh, skel-build.sh (point it at the tree).
   S1 + audit DONE (scratchpad/ri11/summary.txt): ar +1.66% gm over base; all flops +3.49% over
   ar; cmpl (32) +1.60%, dec uop (64) +1.29%, rcu done (8) +0.62% (trips V-35: done bound +1),
   others 0. CoreMark SENT TO RH 11-05 (send_message, 6 configs, warm, patches inline: ri11/
   rxlag.patch + arparams.patch on 497efb8). Long runs go to RH (DA, 11-05): coremark needs
   CCV_MLC_WARM (cold floods dec_ooe_uop response_within_n) and peaks at 12.4 GB.
   When RH answers: OI row to OA (Needs OA, DA) with S1, audit, CoreMark; notify OA.
   Then: lane-slot leads late 2:1; R guard pred off R's pick; phys_src0/1 from issue register;
   OI-114 floor term; OI-112 due 11-06; Friday pings 11-06.
-6. FANOUT ENFORCED (TI b11e60f, ratchet rtl/ngd-ratchet.json "fanout"; caps only fall,
   remove an entry once its path meets 25). State 11-04 ~13:30 UTC:
   - Freelist: scan (a) 32ba2d0, caps 9718b81, gsec retime (wr_q flop, no reuse cycle lost)
     PUSHED 013ed10; freelist has no caps left. OI rev 275 (OI-108) told OA, no notice.
   - decq PUSHED 41ebad9; sched (b) PUSHED 8ba738f (ret_hold 2; ooe_sched brk/older_m fanout caps
     dropped). OI-109/111 closed by OI-113 (rev 280).
   - RA-11 (OI-114, rev 281, notices to OA and TI): fits_stale 6 at PHYS 160 is the go's floor
     term: a slot below its floor gets unmet floor from held BEFORE its own in-flight take, so
     the allowance is one over the credit (dump: held 45/43/44/25, want 28, 3 free, allowance 4).
     Check is right; model and ooe_go share the term. Proposed fix max(0, want-held-took);
     OA RULED (OA rev 334): form taken; took = every unseen take; assert in model + go_tb; fit go's
     fanout caps (else register the term); model + ooe_go land together, GoLog compare unchanged;
     then TI re-runs 160 (coremark128 + a 4-warp kernel, S1, audit); V-N@128 after that.
     DESIGN NOTE: RTL unmet_g = rem_of(ufg, tq_gs) (ooe_rename.sv:848) ALREADY subtracts the lagged
     take; the model's unmetFloor matches. The missing take is the go's OWN take in the split cycle
     (split at rename() start, before takes; the dump: split from held 24, take same cycle -> 25).
     It is the go's output, so 'register off the go path' doesn't apply. Build it like fits_s[k]:
     per own take k, floor term max(0, unmet - GPR writes in the warp's first k heads) (constants
     from the heads alone), selected by the take next cycle; model per k too. Price NGD vs caps. Then: fix model + ooe_go (price NGD), V-N at 128 (one
     firing, untraced). Repro worktree scratchpad/wtr: params 160/12/44, debug dump in
     ooe_core.cpp (RA11 lines), run build/skel/ccv-skel --kernel
     build/bench-oracle/coremark128/oracle.jsonl (~25 min to first firing; full run >2h).
     time-bench.sh stops at its chwidth selftest on coremark128 (told TI).
   - RA-39 (c): the OOE RTL has NO payload-read stage yet (no RS payload store, no issue
     payload/lead). Probe test/ooe/probes/rlead_probe.sv in worktree scratchpad/wtl (branch
     oi-rlead-probe, unit added to its cg-units.json): ooe_sched + names flops + R lead mux
     into a flop beside the grant register: 38.8 NGD flop-flop (sched alone 30.5). OI-115 (rev 282,
     notice to OA): lead in select's cycle cannot fit; options (1) valid moves a cycle, (2) lead
     same-cycle for RCU, (3) predicted lead (no). OA rev 335: probe (0), lead muxed off R's own
     pick. DONE, OI-116 (rev 283, FYI OA/RA): rlead_only 18.7 NGD (13.9 w/o fanout), ~23.7 with
     input arrivals; rlead_probe 26.4 vs sched alone 26.6 (8ba738f). Probes uncommitted in wtl
     (ooe_select_rp.sv, rlead_probe.sv, rlead_only.sv + temp units). NEXT: lane slots (RA-31
     fields) main + fallback pick with late 2:1: export ooe_pick's single-section fallback pick
     in a probe copy; then build ooe_rs payload store + payload-read mux + lead mux. RA-39 (c)
     RTL date moved to 2026-11-09.
     OA rev 336: OPTION (2) TAKEN: no R lead / lead_r_src0/1 in OOE; phys_src0/1 straight from
     the issue register, OOE out budget 7 (record in the issue register owner's ngd.json). OI-117
     (rev 284, FYI OA): lane-slot leads off own picks: sched 28.3 (late 2:1), 27.5 (2:1 after
     flop), 26.6 main only, vs sched alone 26.6, cap 30.5; 20.7 without fanout in all; kept
     copies 28.6 (no help). Final-grant form alone 34.9 vs late 25.7. R guard pred = rlead form.
     Probes in wtl (lslot_probe.sv LATE 1-4, lslot_only.sv, ooe_pick_fp.sv, ooe_select_lp.sv).
     DONE dca9c5f (wtp, branch oi-payload; gating): ooe_rs payload store (pst/hst staged on
     req_en, written an edge late via kept lgp, pw_en), issue register iss_v/iss_pay off
     gnt_cq01h & home, on iss_en <= sched gnt_l_cq03h, a SUPERSET lead (kept rq_l copy |
     gnt_out | force_l | rrun_l; gnt_l_covers assert); own reset rst_p_r01h (rst_r01h fanout).
     NGD: rs 29.4 (= cap), sched 26.7 (caps all hold, no NGD-7). CG pass both (sched med 79%).
     Trio 3 seeds: 7234 grants = issued slots, 0 mismatches; controls pay-port/no-home caught.
     Rejected sched variants: direct gnt_en (NGD-7), copies of ready too (vel 28.4 > 28.2),
     separate copy enables (code in 31.3). OI row on the payload store still to write.
     NEXT RTL: lane-slot leads in the late 2:1 form, R guard pred off R's pick, phys_src0/1
     from the issue reg. RA-39's 6 out budget LAPSED (DA interface flops, RI-11; OA 339).
   - RI-11 (DA: interface module defaults to a flop each side; AR 285: HOP/credits unchanged,
     LANE 7->8, SFU 12->13, L1_WAKE 16->17, L1_CMPL 18->19). OA 340 asks OI: audit OOE inputs
     with logic before first flop (cmpl+hint wakes, rcu done, RAU, decq enq, ckpt/redirect);
     price those latencies + OOE moves, and zero-cycle on the top 2 links, for DA. Read OA 340.
   - OI-112 (OI rev 279, re TI 308/309, notice sent) PROMISED 2026-11-06: imm_kind 6 call
     link (RA-30/RI-7), ooe_wake cls/kind arrival-2 cone (RA-31 base 1), RA-39 (c)
     lead_r_src0/1 from RS names (TI 39a1861 on ccr-183cc441-doowtf; merge it). sched (b)
     83c2900 (46b478e in wts) is UNPUSHED: gating next.
     TI tab bookmark 309.
   - RI-7 (answered OI rev 277): RA-18 call link imm_kind 6 OOE substitution is OI's, queued
     after the fanout cleanup; when it lands, row with rev + notify RI.
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
