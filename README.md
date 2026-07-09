# Auto-Publishing CurseForge Modpack (Fabric)

Add a mod with one command, push, and CI exports a CurseForge-format zip and uploads it to your CurseForge project automatically — with a changelog listing exactly the mods you added, updated, or removed.

## How it works

- **packwiz** stores your mod list as small `.toml` files in Git — no jars in the repo.
- **GitHub Actions** watches `mods/`, `pack.toml`, and `config/`. On push to `main`, it exports the pack (`packwiz curseforge export`) and uploads it via **mc-publish**.
- `scripts/changelog.sh` diffs the commit to build the release changelog, so each CurseForge file version reflects only what you changed.

## One-time setup

1. **Install packwiz** (needs Go): `go install github.com/packwiz/packwiz@latest`
   Or grab a prebuilt binary from the packwiz GitHub Actions artifacts.

2. **Initialize the pack** in this folder:
   ```
   packwiz init
   ```
   Choose Fabric and your MC version. This creates `pack.toml` and `index.toml`.

3. **Create the CurseForge project**: submit a modpack project at curseforge.com (Create a Project → Modpacks). Wait for approval — required before API uploads work.

4. **Get an API token**: https://authors.curseforge.com/account/api-tokens

5. **Create a GitHub repo** from this folder and configure it:
   - Settings → Secrets and variables → Actions → **Secrets**: add `CURSEFORGE_TOKEN`
   - Same page → **Variables**: add `CF_PROJECT_ID` (the numeric ID on your project page) and `MC_VERSION` (e.g. `1.21.1`)

6. Make `scripts/changelog.sh` executable before first commit:
   ```
   git update-index --chmod=+x scripts/changelog.sh
   ```

## Daily use — adding mods

```
packwiz curseforge add sodium
packwiz curseforge add fabric-api
git add . && git commit -m "Add Sodium" && git push
```

That's it. CI builds and uploads a new pack version to CurseForge within a few minutes. Players update through the CurseForge launcher.

Other commands: `packwiz remove <mod>`, `packwiz update --all`, `packwiz modrinth add <mod>` (Modrinth-only mods get bundled as jars and need manual CurseForge staff approval — prefer `curseforge add`).

## Versioning

The uploaded file is named `<pack version>-build.<run number>` (e.g. `1.0.0-build.14`), so every push is unique. Bump `version` in `pack.toml` when you want a new "milestone" (1.1.0, etc.).

## Your server

Keep the server in sync with the same repo using **packwiz-installer** — the server pulls the current mod list on every boot:

1. Put `packwiz-installer-bootstrap.jar` (from packwiz/packwiz-installer-bootstrap releases) in the server folder.
2. In your server start script, before launching the server:
   ```
   java -jar packwiz-installer-bootstrap.jar -g -s server https://raw.githubusercontent.com/<you>/<repo>/main/pack.toml
   ```
   `-s server` skips client-only mods. Mark a mod client-only with:
   ```
   packwiz settings ... # or edit mods/<mod>.pw.toml: side = "client"
   ```

Now one `git push` updates both the CurseForge pack for players and the server itself.

## Notes

- Never commit the exported `.zip` or the `packwiz` binary (`.gitignore` handles this).
- The workflow only fires when pack content changes — editing the README won't publish anything.
- CurseForge may hold uploads briefly for approval, especially ones containing non-CurseForge jars.
