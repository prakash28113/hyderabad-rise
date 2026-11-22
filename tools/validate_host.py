"""Run Godot regressions with timeout and explicit log failure detection."""
import argparse,subprocess,sys
from pathlib import Path
p=Path(__file__).resolve().parents[1]
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--out',type=Path,default=p/'build/host-validation')
args=parser.parse_args()
args.out.mkdir(parents=True,exist_ok=True)
# A fresh checkout has no imported GLBs or font cache. Import before testing.
try:
 imported=subprocess.run(['godot','--headless','--path',str(p/'godot'),'--editor','--import'],capture_output=True,text=True,timeout=120)
except subprocess.TimeoutExpired:
 raise SystemExit('FAIL: Godot resource import timed out')
output=imported.stdout+imported.stderr
(args.out/'import.log').write_text(output)
if imported.returncode or 'ERROR:' in output:sys.exit('FAIL: Godot resource import; see import.log')
for script,log in [('validate_mesh.gd','mesh-regression.log'),('validate.gd','scene-regression.log'),('validate_authenticity.gd','authenticity-regression.log')]:
 try:r=subprocess.run(['godot','--headless','--path',str(p/'godot'),'--script','res://scripts/'+script],capture_output=True,text=True,timeout=30)
 except subprocess.TimeoutExpired:
  raise SystemExit('FAIL: '+script+' timed out')
 text=r.stdout+r.stderr
 (args.out/log).write_text(text)
 print(text)
 if r.returncode or 'ERROR:' in text or 'PASS:' not in text:sys.exit('FAIL: '+script)
print('PASS: all host regression processes completed without engine/script errors')
