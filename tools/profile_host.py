"""Headless host process smoke metrics; never Android performance evidence."""
import subprocess,time,resource,json
from pathlib import Path
p=Path(__file__).resolve().parents[1]
t=time.monotonic()
r=subprocess.run(['godot','--headless','--path',str(p/'godot'),'--script','res://scripts/validate.gd'],capture_output=True,text=True)
print(r.stdout,r.stderr)
print(json.dumps({'exit_code':r.returncode,'host_elapsed_s':time.monotonic()-t,'host_peak_child_rss_kib':resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss,'scope':'Linux headless process including scene setup and streaming tests; not frame times or Android PSS'},indent=2))
raise SystemExit(r.returncode)
