import json
cells=[
["OI-185: redirect send lag priced at both options; bar_pend gains explained (re:OI-184, re:OA 449)"],
["—"],
["The redirect RTL now is C, send lag 2: +1.420% on S1. The no-cycle option is D, lag 1 (the payload leaves with the valid): +0.720% on S1. Both are over OA's 0.5%, so the choice is DA's. D is built and benched on branch oi-pwv. The layernorm and sgemm gains under bar_pend come from barrier timing across warps, not from less work. Needs: DA, OA"],
["RH, at 582fedae14; Δ against B, the defaults at send lag 0: S1 D +0.720%, C +1.420%; cm32priv D +1.903%, C +3.721%; cm128priv D +0.527%, C +0.899%. The cost is linear in the lag: D is about half of C on every workload, and the same redirects are lagged at both.",
 "C is on oi-slot. ooe_redir now muxes the held payload flops of ooe_rob_w instead of keeping its own copy, 4 × 82 flops fewer. rob_tb: 25 seeds, 1135 redirects, 0 mismatches, every control caught.",
 "D is on oi-pwv, as parameter PWV on ooe_rob_w and ooe_redir. ooe_rob_w exports the payload in rd_l's cycle (rd_*_cq03h, combinational from its own flops); ooe_redir flops the picked payload beside the valid, and the free mask leaves with its valid too (A-58). rob_tb: same counts, 0 mismatches; control pwv-late and the redirect controls are caught.",
 "If D is chosen, the redirect and ckpt_free payloads move into the valid's cycle: an interface change for TI (lead fields). The ports are renamed to cq04h, which also clears that form's CCV-L23 findings. The rd_*_cq03h output budgets of ooe_rob_w are OA's. NGD and CG on the PWV form are not yet measured.",
 "OA 449, bar_pend P1 against P0 (RH, rh-oi449; it reproduces OA 448's table exactly). The bar.report and bar.release counts are identical, and so is the retired work. layernorm, −232 cycles: rename.one_warp_short falls by 234, one for one; decq_full falls by 480 and the memop credit wait by 614. The one-a-cycle rotating barrier send spreads the warps' releases, so they reach rename evenly. sgemm, −55 cycles: spread across barrier holds (hold.registered.barrier −244) and br_resolve_cycles (−267); no single counter matches."]]
row={"type":"row","content":[{"type":"cell","content":[{"type":"paragraph","content":[{"type":"text","text":t}]} for t in c]} for c in cells]}
op={"op":"insert","target":{"kind":"blocks","ids":["m8yvbw8rqgz.11664"]},"side":"end","source":{"as":"blocks","from":{"kind":"inline","content":[row]}}}
print(json.dumps({"ops":[op]},ensure_ascii=False))
