<!-- design-snapshot url=https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB tab=Lane_and_memory_paths rev=11 exported=2026-11-05 status=living -->
> **Snapshot: do not edit.** Exported from *CCV RCU Architecture*, tab *Lane and memory paths*, at revision 11 on 2026-11-05 ([live doc](https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB)). The live doc is the source; it is a living document, so this copy is refreshed whenever it changes. This copy pins what the repo was built against; see [README.md](README.md).

# Lane and memory paths

The lane path is owned per section: in A each bank k learns which S op owns it, and every per-section field of the lane message, every lane write and the bypass selects follow that owner. The memory path does the same per MIU pipe, with pipe k ≡ section k. Both modules are `rcu_lanes` and `rcu_mem`.

## Lane message assembly

`own[k]` is the lead S slot that owns section k (Register file tab). Fields of every lane copy c\_l:

| Field | Loaded at | Value for section k (owner o = `own[k]`) |
| --- | --- | --- |
| `section_en`\[k\] (lead) | A's edge | o exists and is a lane, SFU or GPR-copy op (a predicate-only copy sends nothing) |
| `sec_pred_bit`\[k\] lane l (lead) | A's edge | `active`\[o\]\[l\] |
| valid | A's edge | OR of `section_en` |
| `sec_opcode`\[k\] | A+1's edge | o's `opcode` (9 bits, no narrowing in this build; `CCV_OP_PRF_COPY` for the copy) |
| `sec_owner`\[k\] | A+1's edge | o's lead section |
| `operand`\[i\] byte k, lane l (i = 0-2) | A+1's edge | Li's read, byte k; if o's `imm_slot` = i: `imm` byte (k − lead section) (the immediate placed at the op's lead section) |
| `merge_data` byte k, lane l | A+1's edge | L3's read, byte k; 0 when o's `merge_en` = 0 |
| `sec_opnd_pos`\[k\]\[i\], `sec_opnd_width`\[k\]\[i\] | A+1's edge | o's `src_pos`\[i\], `src_width`\[i\]; for the immediate port, pos = lead section; port 3: `old_dst_pos`, `dst_width` |
| `sec_dst_pos`\[k\], `sec_dst_width`\[k\] | A+1's edge | o's `dst_pos`, `dst_width` |
| `sec_pred_data`\[k\] lane l | A+1's edge | for a `pdata` op the guard port's negated value, lane l; else 0 |
| `operand_byp`\[k\]\[i\] | A+1's edge | the bypass select below |

Every per-section field is written for every section the op owns, not only its lead (the stub writes section 0 only because it models full-width ops). The GPR copy sends operands 0 and the old destination as `merge_data` (never the new one: stub control `copy-from-new`).

## Bypass tracker

A lane consumer issued in A reads the PRF in A+1. A lane producer issued in A\_p lands in A\_p + `CCV_LAT_LANE` − 1. So the lanes must forward exactly when the age a = A − A\_p satisfies `CCV_LAT_LANE_BYP` ≤ a ≤ `CCV_LAT_LANE` − 2 (4 to 6 since CCV\_LAT\_LANE went to 8 with the boundary flops; the lane's bypass holds a value one cycle longer, AR row 286); at a ≥ 7 the PRF read has the value. The tracker:

- **History:** a shift register, depth `CCV_LAT_LANE` − 2, of per-section entries pushed in A for every lane-class op that writes a GPR: {valid, dst row, dst pos, lead section}. Copies and SFU ops are not pushed (an SFU result reaches the PRF at A\_p + 12 and has no lane-local bypass; RA-29 asks OA to confirm that no SFU consumer reads before then).
- **Compare (stage I):** for each owner o, operand port i (0-3), the source's (row, pos) on the wire against every history entry at ages `CCV_LAT_LANE_BYP` to `CCV_LAT_LANE` − 2 (12 entries: three ages of four sections, from 8 since CCV\_LAT\_LANE went to 8 with the boundary flops, AR rev 285 and row 286; CCV\_LAT\_LANE\_BYP stays 4 and the 2-bit age field still covers it): a 10-bit equality, about 3 NGD. At most one matches (single assignment; asserted).
- **Select:** on a match, `operand_byp`\[k\]\[i\] = {age − `CCV_LAT_LANE_BYP` (2 bits), producer's lead section (2), forward = 1}, LSB first; else 0. Written for every k o owns. Flopped at A's edge (`byp_a`), moved into the payload at A+1's edge.

## Lane write-back

At A each owned section pushes a descriptor into `lwb_d[k]`, depth `CCV_LAT_LANE` − 1: {valid, writes this bank (the op owns section k and writes a GPR: the Register file tab's LW enable), dst predecode, lane mask (all ones; \~`active` for the GPR copy)}, and the op's lead section adds {`pred_we`, pd and old-destination predicates' predecode, `active`, rob\_tag, done\_row, unit}. The banks written are the op's footprint, never `secmask(dst_width, dst_pos)`: they differ for chwidth's widening, whose `dst_width` names the old width (AR-24) while its footprint covers the new one, and the new upper sections must be written (RI-4). In A+7 bank k's LW port writes `lane_rcu_res` c\_l `result`\[8k+7:8k\] under the descriptor (Register file tab), and PLk writes the predicate (Predicate file tab). The lanes' `sec_valid` must equal the descriptor's write flags (asserted; it is never an enable, CG-5).

SFU ops push into `swb_d`, depth `CCV_LAT_SFU` − 1, and write the SFU result field (RA-3) through SW in A+12.

All 32 lane copies must deliver a result in the same cycle (lockstep): the RCU uses one valid flop per floorplan side and asserts the 32 valids agree.

## Memop operands

| Item | Rule |
| --- | --- |
| Owner | lead P slot j whose footprint covers pipe k (V-60) |
| Operand rows | from the op-class table's operand map: base, index and data sources are each one of `phys_src`\[15:8\], \[7:0\], `phys_src2` or none, with their `src_pos`, `src_width` |
| Read | A+1, ports M0 (base), M1 (index), M2 (data) of every bank the memop owns |
| Assembly | lane word from the owned banks' bytes, then right-aligned and zero-extended by the operand's pos and width (2 NGD); a missing operand is 0 |
| `store_data` for a predicate store | lane 0 = the predicate row read in A (raw); other lanes 0 |
| `active_mask` | `active` (issue mask for predicate transfers, mem\_kind pred-load and pred-store) |
| Valid | `addr_v_a[j]` at A's edge for every lead memop, a fence included (RA-21, AR: MIU pairs every memop with exactly one address message). A fence's message carries only rob\_tag and active\_mask; RCU reads no operand for it and every other field is don't-care. The bulk discard (mem\_op 0xF) is never issued, so RCU never sees it |
| Slot | j = the memop's lead pipe (RA-21 settled: slot\_binding bound, slot k = MIU pipe Pk, fixed\_latency true) |

No memop gets a done from the RCU. Atomics' rows A1 and A3 are memops here and A2 a lane op, pending OA's answer to RA-22.

## Load write-back

In T−1 the RCU captures, per MIU slot j, from the lead on the wire: `mdat_v_q[j]`, the row predecode of `phys_dst` (28 bits), `secmask(dst_width, dst_pos)`, `dst_pos`, `dst_width`, `active_mask`, and the predicate predecode of `phys_pred` with `pred_we`: 4 × about 110 flops written every cycle, inside the block's 2% allowance.

In T: bank k's MW port takes the slot j with k in its secmask (one-hot from flops; two such slots is RA-28's breach). Lane l's data is `load_data`\[32l+31:32l\] & elemmask(dst\_width), shifted left by 8·pos, byte k; lanes written are `active_mask`. A predicate-only load (phys\_dst = zero register) selects no row. PMj writes `pred_result` under `active_mask` when `pred_we`. No state is kept (Q-25).
