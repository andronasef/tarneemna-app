#!/usr/bin/env python3
"""Compose Play Store screenshots: python3 store-screenshots/build.py
Needs Microsoft Edge (or set CHROME). Raw device captures live in raw/, output in android/."""
import os, subprocess, pathlib, time

ROOT = pathlib.Path(__file__).parent.resolve()
CHROME = os.environ.get("CHROME", "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge")
W, H = 1080, 1920  # Google Play 9:16

# (raw file, title, subtitle)
SLIDES = [
    ("01-search", "ابحث عن الترانيم بسهولة 🔍", "اكتب أي كلمة من الترنيمة وهتلاقيها في ثواني"),
    ("02-player", "كل يوم ترنيمة جديدة 🎶", "مشغّل بسيط ومريح يعيشك جو العبادة"),
    ("03-downloads", "حمّل ترانيمك واسمعها من غير نت 📥", "ترانيمك معاك في أي مكان، حتى من غير إنترنت"),
    ("04-playlists", "نظّم مكتبة ترانيمك 📚", "اعمل قوايمك الخاصة: صباح، صوم، أعياد، تسبيح"),
]

HTML = """<!doctype html><html lang="ar"><meta charset="utf-8"><style>
@font-face{{font-family:T;font-weight:800;src:url("fonts/Tajawal-ExtraBold.ttf")}}
@font-face{{font-family:T;font-weight:500;src:url("fonts/Tajawal-Medium.ttf")}}
*{{margin:0;box-sizing:border-box}}
html,body{{width:{W}px;height:{H}px;overflow:hidden}}
.stage{{position:absolute;inset:0;overflow:hidden;font-family:T,sans-serif;
  background:linear-gradient(165deg,#ff9a56 0%,#ff5733 55%,#d63a1b 100%)}}
.blob{{position:absolute;border-radius:50%;background:rgba(255,255,255,.10)}}
.txt{{direction:rtl;position:absolute;top:90px;left:70px;right:70px;height:340px;display:flex;flex-direction:column;
  justify-content:center;align-items:center;text-align:center;color:#fff}}
h1{{font-weight:800;font-size:86px;line-height:1.28;text-shadow:0 6px 18px rgba(120,20,0,.28)}}
p{{font-weight:500;font-size:42px;margin-top:22px;opacity:.93}}
.phone{{position:absolute;top:470px;left:130px;width:820px;padding:18px;background:#101012;
  border-radius:112px;box-shadow:0 40px 90px rgba(90,15,0,.45),inset 0 0 0 3px #2b2b30}}
.scr{{overflow:hidden;border-radius:94px}}
.phone img{{display:block;width:100%;margin-top:-58px}}  /* crops the emulator status bar */
</style><body><div class="stage">
<div class="blob" style="width:760px;height:760px;top:-300px;right:-260px"></div>
<div class="blob" style="width:520px;height:520px;top:900px;left:-300px"></div>
<div class="txt"><h1>{title}</h1><p>{sub}</p></div>
<div class="phone"><div class="scr"><img src="raw/{raw}.png"></div></div></div></body></html>"""

for raw, title, sub in SLIDES:
    page = ROOT / f"_{raw}.html"
    w = title.split(' ')  # keep last word + emoji together so the emoji never wraps alone
    title = ' '.join(w[:-2]) + ' <span style="white-space:nowrap">' + ' '.join(w[-2:]) + '</span>'
    page.write_text(HTML.format(W=W, H=H, title=title, sub=sub, raw=raw))
    out = ROOT / "android" / f"{raw}.png"
    out.unlink(missing_ok=True)
    p = subprocess.Popen([CHROME, "--headless=new", "--user-data-dir=/tmp/edge-shot", "--virtual-time-budget=3000",
                          "--disable-gpu", "--hide-scrollbars", "--force-device-scale-factor=1",
                          f"--window-size={W},{H}", f"--screenshot={out}", page.as_uri()],
                         stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    for _ in range(120):  # Edge can linger after writing the file, so poll instead of wait()
        time.sleep(0.5)
        if out.exists() and out.stat().st_size > 0 and p.poll() is None:
            time.sleep(1); break
        if p.poll() is not None: break
    p.kill()
    page.unlink()
    print("wrote", out)
