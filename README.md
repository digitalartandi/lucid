# Lucid Dreams AAA – Full Snapshot
(Generated: 2025-08-14)

Dies ist ein **kompilierbares Flutter-Projekt** mit:
- **Wissen** (DE/EN), TOC-Jumps, Abschnitts-Lesezeichen, **Fortschritts‑Badges**
- **Studien & News** (PubMed/CrossRef, Auto-Update Settings, **Leseliste** mit Notizen/Export)
- **Research** (N‑of‑1 Builder, LRLR/Marker, Live-Stream, Exporte)
- Apple‑style UI (Cupertino), **100% on-device** Speicherung

## Start
```bash
flutter pub get
flutter run
```
Tabs: **Home**, **Wissen**, **Research**, **Feed**.

## Hinweise
- Auto‑Update nutzt Workmanager/BackgroundFetch (optional). Für iOS ggf. Info.plist UIBackgroundModes setzen, für Android RECEIVE_BOOT_COMPLETED (siehe frühere Guides). App läuft auch ohne Aktivierung (Toggle in Studien‑Feed Settings).
- Audio‑Cues sind aktuell Stub – können via `just_audio` im `CueProfiles.play()` implementiert werden.


## GitHub Upload
```bash
# inside lucid_dreams_aaa
git init
git add .
git commit -m "feat: initial AAA lucid dreaming app snapshot"
git branch -M main
git remote add origin <YOUR_GITHUB_REPO_URL>
git push -u origin main
```

If you want platform folders in Git:
```bash
bash scripts/setup_platforms.sh
git add android ios macos windows linux web
git commit -m "chore: add platform folders"
git push
```
