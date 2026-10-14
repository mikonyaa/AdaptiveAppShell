# GIF Assets

Run `Scripts/record_showcase.sh` to rebuild `adaptive-app-shell.gif` from an installed iPhone simulator runtime. It checks Xcode/simctl, Python 3 and ffmpeg, creates its own device and removes that device and temporary recording directory on exit. Its trap stops only its own recorder PID. Set `ADAPTIVE_SHELL_RUNTIME=26.5` to choose that installed runtime explicitly.

The source MOV is ignored by Git.

The current GIF was captured on 14 October 2026: iPhone 17 Pro, iOS 26.5, built with Xcode 27.0; 400×870, 20 fps, 243 frames, 12.15 seconds. It records the real demo's `--showcase` sequence across its preset themes and tabs. Temporary recording avoids requiring Simulator to write directly into a protected Documents directory.
