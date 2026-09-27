# Inktion

A 2D animation app for drawing, rigging and animating, for macOS and Windows.

**[Download the latest release →](https://github.com/HotcakeHooligan/inktion-releases/releases)**

> [!WARNING]
> **Inktion is in beta.** It's still young and you may run into bugs. Save often and keep
> backups of work you care about. Please [report problems](https://github.com/HotcakeHooligan/inktion-releases/issues)
> so they can be fixed.

---

## Why your computer warns about Inktion

When you open Inktion for the first time, macOS or Windows will probably warn you that the app
is from an "unidentified developer", "unrecognized", or even that it might be harmful.
**This is expected, and it doesn't mean anything is wrong with the app.**

Apple and Microsoft only fully trust apps that are **code-signed**. That means the developer
has bought a yearly certificate and registered with them. Inktion is an independent project
and isn't signed yet. Without a signature, the operating system can't tell who made the app,
so it shows the same warning it would show for any unsigned download. Windows' SmartScreen and
some antivirus tools can also flag new, unsigned apps simply because few people have
downloaded them yet. These are **false positives**.

What Inktion does and doesn't do:

- It **doesn't collect data**. There are no analytics, no tracking and no account.
- Its **only network access** is checking this page for new versions. You can turn that off in
  Settings › General › Updates.
- Your projects stay on your computer, as ordinary `.inkt` files.

### Check your download (optional)

Each release includes a `SHA256SUMS.txt` file. If the fingerprint of your download matches the
one listed there, you have the exact file that was published:

- **macOS** (Terminal): `shasum -a 256 ~/Downloads/Inktion-*-macos-arm64.zip`
- **Windows** (PowerShell): `Get-FileHash $HOME\Downloads\Inktion-*-windows-x64.zip`

You can also upload the zip to [VirusTotal](https://www.virustotal.com) to have it scanned
by dozens of antivirus engines at once.

---

## Installing on macOS (Apple silicon)

1. Download `Inktion-…-macos-arm64.zip` and double-click it to unzip.
2. Drag **Inktion** into your **Applications** folder.
3. Open Inktion. macOS will say it can't verify the developer. Click **Done** (or **Cancel**).
4. Open **System Settings › Privacy & Security**. Scroll down to the message about
   Inktion and click **Open Anyway**, then confirm with your password or Touch ID.
5. Inktion opens. You only need to do this once; after that it opens normally, including after
   updates.

<details>
<summary>On macOS 14 (Sonoma) or earlier</summary>

Right-click (or Control-click) Inktion in Applications, choose **Open**, then click **Open**
in the dialog.
</details>

<details>
<summary>Prefer Terminal?</summary>

This removes the "downloaded from the internet" flag so macOS stops blocking the app:

```
xattr -dr com.apple.quarantine /Applications/Inktion.app
```
</details>

## Installing on Windows (64-bit)

1. Download `Inktion-…-windows-x64.zip`. If your browser says the file "isn't commonly
   downloaded", choose **Keep** (in Edge: **⋯ › Keep › Show more › Keep anyway**).
2. Right-click the zip, choose **Extract All…**, and pick a folder to keep Inktion in (for
   example `Documents\Inktion`).
3. Double-click **Inktion.exe**. If a blue **"Windows protected your PC"** box appears, click
   **More info**, then **Run anyway**.
4. If your antivirus quarantines the file, you can restore it and add an exception for the
   Inktion folder. You can also check the file first, as described above.

---

## Updates

Inktion checks for new versions when it opens, and you can check any time from
**Help › Check for Updates…**. When an update is available, click **Update**. Your work stays
open while it downloads, and the new version starts the next time you open Inktion (or right
away with **Restart Now**).

## Video export

Exporting video (MP4, MOV, WebM) needs [ffmpeg](https://ffmpeg.org/download.html):

- **macOS**: `brew install ffmpeg` (with [Homebrew](https://brew.sh))
- **Windows**: `winget install ffmpeg`, or unzip a build so that `ffmpeg.exe` is at `C:\ffmpeg\bin\ffmpeg.exe`

Image, GIF, sprite-sheet, SVG and Lottie export work without it.

---

This repository only hosts releases of Inktion.
