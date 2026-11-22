"""Physical Android evidence collector. Requires user-run ADB, no mock metrics."""
import argparse,subprocess,sys,time,json,hashlib
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--adb',default='adb');p.add_argument('--serial');p.add_argument('--apk',type=Path,required=True)
p.add_argument('--seconds',type=int,default=60);p.add_argument('--out',type=Path,default=Path('android-evidence'))
a=p.parse_args()
def run(args,check=True):
 r=subprocess.run([a.adb,*args],capture_output=True,text=True,timeout=40)
 if check and r.returncode:raise RuntimeError(r.stderr.strip() or r.stdout.strip())
 return r.stdout+r.stderr
try:
 devices=[line.split()[0] for line in run(['devices']).splitlines()[1:] if len(line.split())>=2 and line.split()[1]=='device']
 serial=a.serial or (devices[0] if len(devices)==1 else None)
 if serial not in devices:sys.exit('BLOCKED: select one connected and authorized physical device with --serial; no test executed')
 prefix=['-s',serial]
 def adb(*args,check=True):return run([*prefix,*args],check)
 if adb('shell','getprop','ro.kernel.qemu').strip()=='1' or serial.startswith('emulator-'):
  sys.exit('BLOCKED: emulator detected; this collector requires physical hardware')
 if not a.apk.is_file():sys.exit('APK does not exist')
 if not 5<=a.seconds<=1800:sys.exit('--seconds must be between 5 and 1800')
 a.out.mkdir(parents=True,exist_ok=False)
 manifest={'status':'in_progress','apk_sha256':hashlib.sha256(a.apk.read_bytes()).hexdigest(),'duration_requested_s':a.seconds,'model':adb('shell','getprop','ro.product.model').strip(),'android':adb('shell','getprop','ro.build.version.release').strip(),'scope':'physical-device data collection; manual controls/visual acceptance remain separate'}
 (a.out/'session.json').write_text(json.dumps(manifest,indent=2))
 (a.out/'install.txt').write_text(adb('install','-r',str(a.apk.resolve())))
 package='in.hyderabad.rise.prototype'
 resolved=adb('shell','cmd','package','resolve-activity','--brief',package).strip().splitlines()[-1]
 if '/' not in resolved:raise RuntimeError('Launcher activity could not be resolved')
 adb('shell','am','force-stop',package)
 (a.out/'launch.txt').write_text(adb('shell','am','start','-W','-n',resolved))
 pid=adb('shell','pidof',package).strip().split()
 if len(pid)!=1:raise RuntimeError('Expected exactly one application process after launch')
 print('Launched. Walk the route and operate the camera on the phone while collecting evidence.',flush=True)
 started=time.monotonic();i=0
 while time.monotonic()-started<a.seconds:
  (a.out/f'memory-{i:04}.txt').write_text(adb('shell','dumpsys','meminfo',package,check=False))
  i+=1;time.sleep(min(5,max(0,a.seconds-(time.monotonic()-started))))
 (a.out/'app-logcat.txt').write_text(adb('logcat','--pid='+pid[0],'-d',check=False))
 manifest.update(status='collection_completed_not_acceptance',elapsed_collection_s=time.monotonic()-started,memory_samples=i)
 (a.out/'session.json').write_text(json.dumps(manifest,indent=2))
 print('Evidence collected. Review crash/ANR logs, engine frame intervals, and raw PSS samples; no automatic Sprint 1 PASS.')
except (RuntimeError,subprocess.SubprocessError,OSError) as e:
 sys.exit('FAILED / BLOCKED: '+str(e))
