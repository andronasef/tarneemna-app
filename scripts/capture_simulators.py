#!/usr/bin/env python3
"""Run Flutter screenshot_runner on iOS simulator and capture authentic device screenshots."""
import subprocess
import time
import os
import sys
import pathlib

ROOT = pathlib.Path(__file__).parent.parent.resolve()

def capture_device(device_id, output_dir_name):
    out_dir = ROOT / "store-screenshots" / output_dir_name
    out_dir.mkdir(parents=True, exist_ok=True)
    
    print(f"\n==========================================")
    print(f"Starting captures on device: {device_id} -> {output_dir_name}")
    print(f"==========================================")
    
    # Terminate any running instance of the app
    subprocess.run(["xcrun", "simctl", "terminate", device_id, "com.increase.tarneemna"], stderr=subprocess.DEVNULL)
    time.sleep(1)

    # Clean status bar
    subprocess.run([
        "xcrun", "simctl", "status_bar", device_id, "override",
        "--time", "9:41", "--batteryState", "charged", "--batteryLevel", "100",
        "--cellularBars", "4", "--wifiBars", "3"
    ], check=True)
    
    cmd = ["flutter", "run", "-t", "lib/screenshot_runner.dart", "-d", device_id]
    proc = subprocess.Popen(cmd, cwd=str(ROOT), stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1)
    
    captured_count = 0
    
    try:
        for line in proc.stdout:
            sys.stdout.write(line)
            sys.stdout.flush()
            
            if "=== CAPTURE" in line:
                # Extract shot name e.g. 01-search
                parts = line.strip().split("=== CAPTURE ")
                if len(parts) > 1:
                    shot_name = parts[1].replace("===", "").strip()
                    time.sleep(1.2) # wait for animation/render
                    out_path = out_dir / f"{shot_name}.png"
                    print(f"\n--> Taking screenshot {out_path} ...")
                    subprocess.run(["xcrun", "simctl", "io", device_id, "screenshot", str(out_path)], check=True)
                    print(f"--> Saved {out_path} ({out_path.stat().st_size} bytes)")
                    captured_count += 1
            
            if "=== ALL CAPTURES COMPLETE ===" in line:
                print("\n--> All captures complete! Stopping app...")
                break
    finally:
        try:
            proc.terminate()
            proc.wait(timeout=5)
        except Exception:
            proc.kill()
        subprocess.run(["xcrun", "simctl", "terminate", device_id, "com.increase.tarneemna"], stderr=subprocess.DEVNULL)
            
    print(f"\nSuccessfully completed {captured_count}/4 screenshots in {out_dir}\n")

if __name__ == "__main__":
    iphone_id = "9759434D-8F81-465B-964E-05022B537976"
    ipad_id = "442882C9-6C4F-4AC9-8A8E-589BA7DCBEB9"
    
    target = sys.argv[1] if len(sys.argv) > 1 else "both"
    
    if target in ("both", "iphone"):
        capture_device(iphone_id, "raw-ios")
    if target in ("both", "ipad"):
        capture_device(ipad_id, "raw-ipad")
