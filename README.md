# wi-tools
A powerful, pure shell-based network manager for Windows, Linux, and macOS. This tool combines automated ping monitoring, smart connection adapter resets, and express DNS management into lightweight, zero-dependency scripts.

---

## Shout-out to GameVox!

Big shout-out to Ben and the GameVox community for building GameVox! This project features integrations and appreciation inspired directly by Ben's work and the community's support.
My Server: ![Online](https://api.gamevox.com/api/public/widget/65c11531-9ede-4b4c-8534-31527d6cc82c.svg)
---

## Features

- Automated Connection Loop: Continuously tracks network drops against custom domains or fallback targets.
- Smart Hardware Recovery: Automatically cycles network adapters and flushes IP configurations upon link loss.
- Express DNS Manager: Switch profiles instantly between Cloudflare, Google, Quad9, or your own custom servers.
- Zero Overhead: Built purely using native sh and bat scripts—no Java runtime or compilation required.

---

## How to Use

### For Windows
1. Download tool-windows.bat.
2. Right-click the file and select Run as Administrator.
3. Select your utility from the interactive console menu.

### For Linux & macOS
1. Download tool-linux-mac.sh.
2. Open your terminal, navigate to your download folder, and grant execution rights:
   ```bash
   chmod +x tool-linux-mac.sh
   ```
3. Run the script with root permissions:
   ```bash
   sudo ./tool-linux-mac.sh
   ```

---

## Credits & Authorship
- Jetty (Anvnamnet) — Core Creator & Script Developer. | STATUS: RETIRED
- Ben & The GameVox Community — Inspiration & Support  | STATUS: ONLINE
