#!/usr/bin/env python3
"""Compose App Store iPad 13" screenshots: python3 store-screenshots/build_ipad.py
Needs Microsoft Edge (or set CHROME). Output in ipad/ (2064×2752, App Store iPad display)."""
import os, subprocess, pathlib, time

ROOT = pathlib.Path(__file__).parent.resolve()
CHROME = os.environ.get("CHROME", "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge")
W, H = 2064, 2752  # App Store iPad 13" display

# (raw file, title, subtitle)
SLIDES = [
    ("01-search", "ابحث عن الترانيم بسهولة 🔍", "اكتب أي كلمة من الترنيمة وهتلاقيها في ثواني"),
    ("02-player", "كل يوم ترنيمة جديدة 🎵", "مشغّل بسيط ومريح يعيشك جو العبادة"),
    ("03-downloads", "حمّل ترانيمك واسمعها من غير نت 📥", "ترانيمك معاك في أي مكان، حتى من غير إنترنت"),
    ("04-playlists", "نظّم مكتبة ترانيمك 📚", "اعمل قوائمك الخاصة: صباح، صوم، أعياد، تسبيح"),
]

HTML = """<!doctype html><html lang="ar"><meta charset="utf-8"><style>
@font-face{{font-family:T;font-weight:800;src:url("fonts/Tajawal-ExtraBold.ttf")}}
@font-face{{font-family:T;font-weight:500;src:url("fonts/Tajawal-Medium.ttf")}}
*{{margin:0;box-sizing:border-box}}
html,body{{width:{W}px;height:{H}px;overflow:hidden}}
.stage{{position:absolute;inset:0;overflow:hidden;font-family:T,sans-serif;
  background:linear-gradient(165deg,#ff9a56 0%,#ff5733 55%,#d63a1b 100%)}}
.blob{{position:absolute;border-radius:50%;background:rgba(255,255,255,.10)}}
.txt{{direction:rtl;position:absolute;top:120px;left:100px;right:100px;height:420px;display:flex;flex-direction:column;
  justify-content:center;align-items:center;text-align:center;color:#fff}}
h1{{font-weight:800;font-size:112px;line-height:1.28;text-shadow:0 8px 24px rgba(120,20,0,.32)}}
p{{font-weight:500;font-size:54px;margin-top:28px;opacity:.93}}
.tablet{{position:absolute;top:580px;left:182px;width:1700px;padding:26px;background:#101012;
  border-radius:64px;box-shadow:0 50px 110px rgba(90,15,0,.45),inset 0 0 0 4px #2b2b30}}
.scr{{overflow:hidden;border-radius:46px}}
.tablet img{{display:block;width:100%;margin-top:0}}
</style><body><div class="stage">
<div class="blob" style="width:1100px;height:1100px;top:-400px;right:-350px"></div>
<div class="blob" style="width:800px;height:800px;top:1100px;left:-400px"></div>
<div class="txt"><h1>{title}</h1><p>{sub}</p></div>
<div class="tablet"><div class="scr"><img src="{img_path}"></div></div></div></body></html>"""

out_dir = ROOT / "ipad"
out_dir.mkdir(parents=True, exist_ok=True)

for raw, title, sub in SLIDES:
    page = ROOT / f"_{raw}_ipad.html"
    w = title.split(' ')  # keep last word + emoji together so the emoji never wraps alone
    title = ' '.join(w[:-2]) + ' <span style="white-space:nowrap">' + ' '.join(w[-2:]) + '</span>'
    
    # Check if raw-ipad exists, else fallback to raw
    raw_ipad = ROOT / "raw-ipad" / f"{raw}.png"
    img_path = f"raw-ipad/{raw}.png" if raw_ipad.exists() else f"raw/{raw}.png"
    
    page.write_text(HTML.format(W=W, H=H, title=title, sub=sub, img_path=img_path))
    out = out_dir / f"{raw}.png"
    out.unlink(missing_ok=True)
    p = subprocess.Popen([CHROME, "--headless=new", "--user-data-dir=/tmp/edge-shot-ipad", "--virtual-time-budget=3000",
                          "--disable-gpu", "--hide-scrollbars", "--force-device-scale-factor=1",
                          f"--window-size={W},{H}", f"--screenshot={out}", page.as_uri()],
                         stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    for _ in range(120):
        time.sleep(0.5)
        if out.exists() and out.stat().st_size > 50000:
            break
    p.kill()
    page.unlink(missing_ok=True)
    print(f"wrote {out}")
