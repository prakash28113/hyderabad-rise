"""Run Godot regressions with timeout and explicit log failure detection."""
import subprocess,sys
from pathlib import Path
p=Path(__file__).resolve().parents[1]
for script,log in [('validate_mesh.gd','mesh-regression.log'),('validate.gd','scene-regression.log')]:
 try:r=subprocess.run(['godot','--headless','--path',str(p/'godot'),'--script','res://scripts/'+script],capture_output=True,text=True,timeout=30)
 except subprocess.TimeoutExpired:
  raise SystemExit('FAIL: '+script+' timed out')
 text=r.stdout+r.stderr
 (p/'docs/evidence/fixes'/log).write_text(text)
 print(text)
 if r.returncode or 'ERROR:' in text or 'PASS:' not in text:sys.exit('FAIL: '+script)
print('PASS: all host regression processes completed without engine/script errors')
