#!/usr/bin/env python3
"""Archived (RCU bank sizing, 2026-11-03; run by hand only, never by the gate).
measure.py NAME MODULE FILE[,FILE] [K=V ...]: one unit through check-ngd's
own synth + ABC timing, with a private, empty synthesis cache, so the peak RSS
and time are a cold run's. Prints NGD, flops, cells, peak MiB, seconds."""
import importlib.util, json, os, resource, sys, time, collections
ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "../.."))
os.chdir(ROOT); sys.path.insert(0, os.path.join(ROOT, "tools"))
os.environ["PATH"] = os.path.join(ROOT, "tools/shim") + ":" + os.environ["PATH"]
spec = importlib.util.spec_from_file_location("ngd", os.path.join(ROOT, "tools/check-ngd.py"))
ngd = importlib.util.module_from_spec(spec); spec.loader.exec_module(ngd)
here = os.path.join(ROOT, "build", "rcu-bank-sizing")
name, module, files = sys.argv[1], sys.argv[2], sys.argv[3].split(",")
params = dict(a.split("=", 1) for a in sys.argv[4:])
ngd.cg.SYNTH_CACHE = os.path.join(here, "cache", name)
ngd.BUILD = os.path.join(here, "build")
t0 = time.time()
u = ngd.Unit({"name": name, "module": module, "files": files, "params": params}, "exp")
u.measure(budgets=ngd.Budgets.load(), modules=ngd.design_modules())
ngd.report(u)
net = json.load(open(os.path.join(ngd.BUILD, "u_" + name, "net.json")))
m = [v for k, v in net["modules"].items() if v.get("attributes", {}).get("top")][0]
c = collections.Counter(x["type"] for x in m["cells"].values())
ff = sum(len(x["connections"].get("Q", [])) for x in m["cells"].values() if "DFF" in x["type"] or "dff" in x["type"])
print("RESULT %s flops=%d cells=%d peak_mib=%.0f secs=%.0f" % (
    name, ff, sum(c.values()), resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss / 1024, time.time() - t0))
