<!-- design-snapshot url=https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB tab=Pipeline rev=28 exported=2026-11-08 status=living -->
> **Snapshot: do not edit.** Exported from *CCV RCU Architecture*, tab *Pipeline*, at revision 28 on 2026-11-08 ([live doc](https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB)). The live doc is the source; it is a living document, so this copy is refreshed whenever it changes. This copy pins what the repo was built against; see [README.md](README.md).

# Pipeline

The RCU is three stages for everything it decides (A: decode and predicates, plus the R op's source reads R0/R1, RA-39; A+1: register read and compute; A+2: R write-back) and a fixed-delay write-back pipeline for everything the lanes and the SFU return (A+6 and A+11). Nothing stalls: every stage advances every cycle, and each stage's valid flops are the next stage's clock enables.

## Stage table

| Stage | Cycle | Launching flops / inputs | Logic | Capturing flops |
| --- | --- | --- | --- | --- |
| IL (issue lead) | A−1 | ooe\_rcu\_issue valid and lead slice wires (RA-31: lead\_sec\_mask, lead\_src\_used, lead\_imm\_used, lead\_merge\_used; lead\_guard\_used and lead\_guard\_pred on every slot; lead\_opcode on every slot; the RA-43 lead copies (destination, write, cont and pred\_neg fields; R's lead\_phys\_src and lead\_rpsrc; S0-S3's old-destination and source fields; Partition tab)); `miu_rcu_data` leads | guard row predecode from lead\_guard\_pred (split guard read, RA-32) | iss\_v\_q\[0:8\]; iss\_lead\_q\[s\] (one copy per owning module); guard psel one-hot, enabled by lead\_guard\_used |
| I (issue) | A | `iss_v_q[0:8]`, `iss_lead_q[s]`, guard `psel`; issue payload wires (R0/R1 rows from `phys_src`); predicate rows; GPR rows (R0/R1); MW select flops and write data (write-through) | op-class decode; footprint and section ownership; guard read from `psel` (negate from the payload) and predicate-source reads, with MIU forward; R0/R1 192:1 reads decoded from the payload wires in each slice, with the MIU write-through (RA-39, OA rev 336); `active`; row predecode for every other read port; lead outputs; R-idle test for migration. Every field group of `iss_*_a` loads under `iss_v_q[s] & iss_lead_q[s]` bit | `iss_*_a` (issue stage register); `*_sel_hi_a`/`*_sel_lo_a`; `active_a[s]`; `lop_v_a`, `section_en_a`, `sec_pred_bit_a`; `addr_v_a[j]`; R done valid and `lead_br_*_a`; `rpsrc_a` (R predicate sources); `rsrc` (R0/R1 raw rows, 64 in each bank slice, 2,048); bypass tracker push; write-back descriptor push |
| R (read) | A+1 | `*_sel_*_a`, GPR rows, `iss_*_a`, `active_a`, `rsrc` | 8 physical 192:1 reads per bank (L0-3, M0-2, R2); alignment and zero-extension; immediate substitution; bypass selects; R alignment of `rsrc` and compute from it (ret pick, crossbar, vote, ballot, unballot, predicate ALU) | `lop_*_a1` (lane payload); `addr_*_a1` (MIU payload); `rres_a1` (R GPR result and write descriptor); `rpres_a1` (R predicate result); slot 5 and slot 6 done payload; `dm_pay` (demotion row) |
| RW (R write) | A+2 | `rres_a1`, `rpres_a1`, restore staging head | R GPR write port D-mux; R predicate write port with old-destination merge | GPR rows (W = A+2); predicate rows |
| L2-L5 | A+2 to A+5 | lane descriptor pipeline `lwb_d[k]` | none (delay) | `lwb_d` stages; slot k done valid loaded at A+5's edge |
| LW (lane write) | A+6 | `lwb_d` at depth 5; `lane_rcu_res` payload | lane GPR write port per bank; lane predicate write ports with old-destination merge; copy-op masked write | GPR rows, predicate rows (W = A+6); slot 0-3 done payload |
| SW (SFU write) | A+11 | `swb_d` at depth 10; `lane_rcu_res` SFU result fields (RA-3) | SFU GPR write port | GPR rows (W = A+11); slot 4 done payload |

The lane and SFU depths are derived, not literal: lane W = A + `CCV_LAT_LANE` − 1, SFU W = A + `CCV_LAT_SFU` − 1, so the descriptor pipelines are parameterised by those two values.

## Op-class decode

Since RA-43, in stage IL from lead\_opcode (before it, in stage I), the RCU decodes each slot's `opcode` through a table generated from the op table (`tools/gen-params.py` territory, TI): opcodes are preliminary (Q-34), so the RTL never compares an opcode literal except `CCV_OP_PRF_COPY`. The decoded class fields, flopped into `iss_*_a`:

| Field | Values | Used by |
| --- | --- | --- |
| `unit` | lane, SFU, memop, R-only, collective, copy, pred-copy | write-back routing, done slot |
| `guarded` | 0/1 | `active` (an unguarded op's guard is ignored) |
| `pdata` | 0/1 | the guard port is data (sel, st.pred): `active` = issue mask |
| `imm_slot` | none, 0, 1, 2 | immediate substitution |
| `r_kind` | bra, call, ret, pand, por, pxor, pmov-imm, movi, shfl-idx-imm, shfl-idx-reg, shfl-up, shfl-down, shfl-bfly, vote-any, vote-all, ballot, unballot | R unit |
| `mem_kind` | load, store, pred-load, pred-store, fence, atomic row | memop operands |
| `r_reads` | bitmask of R read ports 0-2 | migration's idle test |
| `r_wgpr`, `r_wpred` | 0/1 | R write ports; migration's idle test |

## Cycle tables per op class

**RCU-only and collective ops (R slot).** Collectives run in the same three stages as RCU-only ops; only their done slot and contracted latency differ (R unit tab).

| Cycle | Action |
| --- | --- |
| A−1 | lead on the wire: guard row predecode |
| A | guard read (+forward), `active`; predicate sources read; branch outcome; R0/R1 GPR read from the payload's rows, with the MIU write-through, into the slices' `rsrc`; row predecode for R2; done valid flop loaded (slot 5, or slot 6 for a collective); `lead_br_*` loaded |
| A+1 | done valid on the wire; R2 read (old destination); align `rsrc` and compute from it; result into `rres_a1`/`rpres_a1`; done payload loaded |
| A+2 | done payload on the wire; GPR or predicate write lands (W = A+2), readable A+3 = A + `CCV_LAT_RCU` |

**Lane ops (S slots).**

| Cycle | Action |
| --- | --- |
| A | guard (+forward), `active`; section ownership; row predecode for lane ports 0-3 of the owned banks; bypass compare against the tracker; `lop_v_a`, `section_en_a`, `sec_pred_bit_a` loaded |
| A+1 | lane valid and leads on the wire; GPR read (sources, merge source); immediate substitution; payload into `lop_*_a1` |
| A+2 | lane payload on the wire |
| A+3 to A+5 | the lane executes (lane's contract) |
| A+5 | lane result valid on the wire (lane's); done valid flop loaded for slot k = the op's lead section |
| A+6 | result payload in; GPR write lands per owned bank, predicate write with merge (W = A+6); done valid on the wire |
| A+7 | done payload on the wire |

SFU ops follow the same rows to A+2, then write at A+11 through the SFU port, with done valid loaded at A+10's edge on slot 4. The masked-load copy (`CCV_OP_PRF_COPY`, GPR form) is a lane op that writes only inactive lanes at A+6 and loads no done. The predicate-only copy (ld.pred) never reaches the lanes: it writes the predicate file at A+2 (Predicate file tab).

**Memops (P slots).**

| Cycle | Action |
| --- | --- |
| A | guard (+forward), `active` (issue mask for predicate transfers); row predecode for memop ports of the owned banks; predicate-store data read; `addr_v_a[j]` loaded for the lead pipe j |
| A+1 | address valid on the wire; GPR read; right-alignment; payload into `addr_*_a1[j]` |
| A+2 | address payload on the wire |
| T | load data in (MIU's timing): GPR and predicate writes land (W = T) |

No memop produces a done from the RCU (OI-4).
