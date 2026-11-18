#!/usr/bin/env python3
"""rss-run.py FD CMD...: run CMD, then write its peak resident memory (KiB,
with its children's) to file descriptor FD, and exit as CMD did.

tools/check-cg.py's run() measures every command through this. Measured
directly, a child of check-cg reports check-cg's own size: Linux carries the
resident set a process had before exec into its peak (ru_maxrss), and a
child forked from a 2 GB Python starts at 2 GB. Eleven light units each
read 2179 MiB, check-cg's own size, and failed the light limit in the
release gate of 2026-11-02. Spawned from this small process instead, the
command's peak is its own.
"""
import os
import signal
import subprocess
import sys


def main():
    fd = int(sys.argv[1])
    cmd = sys.argv[2:]
    p = subprocess.Popen(cmd)
    _, status, ru = os.wait4(p.pid, 0)
    with os.fdopen(fd, "w") as f:
        f.write("%d\n" % ru.ru_maxrss)
    if os.WIFSIGNALED(status):
        sig = os.WTERMSIG(status)
        if sig not in (signal.SIGKILL, signal.SIGSTOP):
            signal.signal(sig, signal.SIG_DFL)
        os.kill(os.getpid(), sig)
    sys.exit(os.waitstatus_to_exitcode(status))


if __name__ == "__main__":
    main()
