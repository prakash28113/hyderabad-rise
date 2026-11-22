"""Run graphical before/after captures sequentially on an available desktop display."""
import subprocess,json,os
from pathlib import Path
p=Path(__file__).resolve().parents[1]
if not os.environ.get('DISPLAY') and not os.environ.get('WAYLAND_DISPLAY'):raise SystemExit('BLOCKED: graphical desktop required')
for label,project in [('before',p.parent/'hyderabad-baseline/godot'),('after',p/'godot')]:
 log=p/f'docs/evidence/sprint15/{label}-render.log'
 with log.open('w') as f:r=subprocess.run(['godot','--audio-driver','Dummy','--path',str(project),'--script','res://scripts/capture_views.gd','--',label],stdout=f,stderr=subprocess.STDOUT,timeout=120)
 text=log.read_text()
 if r.returncode or 'SCRIPT ERROR' in text or 'HYD_CAPTURE_DONE' not in text:raise SystemExit('Capture failed: '+str(log))
 print(label,'rendered captures complete',flush=True)
