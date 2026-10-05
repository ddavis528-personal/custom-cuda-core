# Kernel coverage plan

What the S1/S2 kernels exercise, what they do not, and the order the gaps
close in. A kernel here is a hand-written `.s` in `test/kernels/<k>/` (or a
compiler-corpus kernel named by `SOURCE=`), run on the functional stubs
against ccv-sim's oracle by `tools/check-kernel.sh` and on the SV-hosted top
by `tools/check-sv-hosted.sh`. Each claim below has a negative control or a
coverage count in the gate; a kernel that only "passes" proves nothing about
a path it never reached.

**Coverage counts.** The stubs count named bins where each path is taken,
and every run prints them on a `COVER` line beside `KERNEL`: redirects,
checkpoint frees, cycles FET stalled with every checkpoint live, the most
checkpoints live at once, merges, copy-only ops, zero-register reads,
physical registers reallocated after a free, memops touching more than one
line, the most lines one memop touched, store lines with a partial byte mask,
and cycles MIU waited for a DCU request id. `tools/check-kernel.sh` holds
each kernel to the bins it exists for, so a stub change that stops reaching
a path fails the gate rather than passing it vacuously. The SV-hosted run
must print the same `COVER` line as the C++ one.

## Where coverage stands

| Area | Kernels | What is reached (gate bins) | Control |
|---|---|---|---|
| Straight-line ALU, loads, stores | vadd, srd, sel | one line per warp access, aligned; a correctly predicted branch frees its checkpoint (`ckpt_free=1`) | vadd's eleven |
| Guarded writes and merge under rename | merge, pguard | GPR merge through a lane, predicate merge in RCU, zero registers (`merge=4 zero_read=2`) | wrong-merge, dirty-zero, ignore-mask |
| Masked loads | mload | the copy-only op (A-38), its landing contract (`copy=2`) | skip-copy, copy-from-new, late-copy |
| Warp access not line-aligned | unal | two lines per access, split at lanes 27, 1 and 15; a store's partial byte mask on two lines (`line_split=3 partial_line=2`) | one-line |
| Scattered lane addresses | gather | one line per lane: 32 line requests for one memop, MIU waiting on DCU request ids and reusing them (`lines_peak=32 dcu_id_wait>0`); reversed order within a line; broadcast; a store with a 4-byte mask in each of 32 lines | (MIU's per-lane address and data checks) |
| Branch mispredicts (redirect, checkpoint restore) | loop, brs | a backward branch mispredicted 99 times, then a correct fall-through (`redirect=99`); a uniform taken forward branch | drop-negate, corrupt-ckpt, stale-free |
| Rename free list wrapping | loop | about 200 writes against 192 registers (`reg_reuse>0`) | free-new |
| Checkpoint pressure | brs | five unresolved branches against `CCV_P_BR_CKPTS` = 4: FET stalls until a free (`ckpt_peak=4 ckpt_full>0 ckpt_free=5`) | |

## What is not reached, and why

1. **Wrong-path execution.** FET predicts not-taken, and the stub fetches
   nothing past a branch it will mispredict (it has no oracle record for the
   wrong path). So a mispredict today exercises the redirect and the
   checkpoint restore, but no squash: no wrong-path uop is renamed, issued or
   discarded, no RAT is recovered, no store is discarded, and MIU's bulk
   discard (A-41) never runs. The interface gap is closed (A-70, applied:
   every uop carries a 3-bit fetch epoch, and OOE drops stale ones before
   rename, `--break stale-epoch` as the control); what remains is stub work,
   step 1 below.
2. **Divergence.** Every kernel's branches are uniform, and every issue mask
   is all 32 lanes. The group mask now reaches OOE with each uop (A-69,
   applied; `--break corrupt-group-mask` as the control), so what remains is
   FET's group state in the stub: splitting a group on a divergent branch and
   reconverging it.
3. **A lane's word split across lines.** ccv-sim accepts a 4-byte access at
   any byte address. Whether the ISA does is deferred to the ISA track
   (Review A-71); the MIU stub assumes a lane's word lies in one line. If it
   is legal, such an access cannot meet the L1 contract and completes late
   (A-46); if not, it faults at retirement.
4. **Per-warp concurrency.** One warp, one CTA throughout: no tier-1 slot
   other than 0, no binding-group contention, no SPM, no barriers, no
   migration.

## Next, in order

1. **Wrong-path fetch and squash** (A-70 is settled). FET fetches past a
   predicted branch for as long as it has a decode for the next PC (in a
   loop, the exit path is decoded on the last iteration). Wrong-path uops get
   their own identity class, the lanes check nothing for them, and the final
   compare and retire order check that none leaked. OOE squashes the ROB
   younger than the branch, restores its RAT, returns the squashed
   destinations to the free list, and bulk-discards the warp's younger
   stores. Controls: a squashed write that lands, a squashed store that
   commits, a register freed twice.
2. **Divergence** (A-69 is settled): a tail warp (`n` not a multiple of
   32, so the bounds branch splits the warp), if/else with reconvergence, and
   masked loads masked by the issue mask rather than a guard.
3. **Compiler-corpus kernels.** `bench-vadd_loop` (a grid-stride loop) and
   `cuda-vadd` (the unaligned ABI of ISA §5.5: byte offsets, slot-indexed
   loads whose window base MIU reads from the launch block) need ops the stub
   table does not decode yet: `shl`, `add`, `mov`, `fadd`, `mad.acc`, the
   unsigned and `le` compares, and `ld/st.global` by launch slot.
4. **Several warps** sharing the machine: tier-1 slots 1 to 3, binding-group
   arbitration, checkpoint frees across slots.
