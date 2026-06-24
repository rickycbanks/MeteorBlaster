# Meteor Blaster - Release Plan

A step-by-step plan to rebrand, prepare for distribution, and set up
GitHub Actions for automated builds.

---

## Overview

Rename "Astroid Luv" → "Meteor Blaster", initialize Git, create a GitHub
Actions workflow for Linux AppImage + Windows EXE releases, write a README,
and set up a proper `.gitignore`.

**Target platforms:** Linux (AppImage) + Windows (fused EXE)
**Engine:** LÖVE 11.5

---

## Step 1: Rebranding (Astroid Luv → Meteor Blaster)

### Folder rename

```
/var/home/ricky/Dev/astroid_luv  →  /var/home/ricky/Dev/MeteorBlaster
```

### Files to update

| File                | Changes                                                              |
|---------------------|----------------------------------------------------------------------|
| `conf.lua`          | `t.title = "Meteor Blaster"`, `t.identity = "meteor_blaster"`       |
| `states/menu.lua`   | Title text `"ASTROID LUV"` → `"METEOR BLASTER"`                     |
| `main.lua`          | Comment header                                                       |
| `utils.lua`         | Comment header                                                       |
| `states/play.lua`   | Comment header                                                       |
| `states/gameover.lua` | Comment header                                                     |
| `states/leaderboard.lua` | Comment header                                                   |
| `ship.lua`          | Comment header                                                       |
| `asteroid.lua`      | Comment header                                                       |
| `bullet.lua`        | Comment header                                                       |
| `sounds.lua`        | Comment header                                                       |

### Impact

- Leaderboard save location changes automatically via `t.identity`
- No code logic changes needed
- All string references to "Astroid Luv" updated

### Questions

> - ~~Should the folder name be `meteor_blaster` (snake_case) or~~
>   ~~`MeteorBlaster` (PascalCase)?~~ → **Decided: PascalCase = `MeteorBlaster`**
> - Any other branding changes (e.g., window icon)?

---

## Step 2: Initialize Git Repository

### Actions

```bash
cd /var/home/ricky/Dev/MeteorBlaster
git init
git add .
git commit -m "Initial commit: Meteor Blaster - LÖVE 11.5 Asteroids clone"
```

### Remote setup

After creating the GitHub repo:

```bash
git remote add origin git@github.com:yourusername/meteor-blaster.git
git push -u origin main
```

### Questions

> - Create the GitHub repo via `gh` CLI, or manually?
> - Branch name: `main` or `master`?

---

## Step 3: GitHub Actions Workflow

**File:** `.github/workflows/release.yml`

### Triggers

- Push of tags matching `v*` (e.g., `v1.0.0`, `v1.2.3`)
- Manual trigger via `workflow_dispatch`

### Job 1: Build Linux AppImage

| Step | Details |
|------|---------|
| Runner | `ubuntu-latest` |
| Create .love file | Zip game files, exclude `.github/`, `.opencode/`, `love.AppImage` |
| Download LÖVE 11.5 | From `https://github.com/love2d/love/releases/download/11.5/love-11.5-x86_64.AppImage` |
| Fuse | `cat love-11.5-x86_64.AppImage game.love > MeteorBlaster-Linux.AppImage` |
| Permissions | `chmod +x` |
| Artifact | `MeteorBlaster-Linux.AppImage` |

### Job 2: Build Windows EXE

| Step | Details |
|------|---------|
| Runner | `windows-latest` |
| Create .love file | Zip game files, exclude `.github/`, `.opencode/` |
| Download LÖVE 11.5 | From `https://github.com/love2d/love/releases/download/11.5/love-11.5-win64.zip` |
| Extract | `love.exe` from the zip |
| Fuse | `copy /b love.exe+game.love MeteorBlaster.exe` |
| Artifact | `MeteorBlaster.exe` |

### Job 3: Create Release

| Step | Details |
|------|---------|
| Needs | `[build-linux, build-windows]` |
| Download | Artifacts from both jobs |
| Release | `softprops/action-gh-release@v1` with both files attached |

### Questions

> - Include a macOS job as a placeholder, or skip entirely?
> - Run workflow on every push to `main`, or only on tags?

---

## Step 4: README Documentation

### Structure

```
# Meteor Blaster

A classic Asteroids-style arcade game built with LÖVE 11.5.

## Features
- Classic arcade gameplay with modern polish
- Procedural sound effects (no external audio files)
- Persistent high score leaderboard
- Smooth 60 FPS gameplay

## Controls
- Left/Right Arrow  → Rotate ship
- Up Arrow          → Thrust forward
- Space             → Shoot
- Escape            → Return to menu

## How to Play
1. Download the latest release for your platform
2. Run the executable
3. Navigate the menu with arrow keys, press Enter to select

## Building from Source
### Prerequisites
- LÖVE 11.5
- Git

### Running Locally
    git clone https://github.com/yourusername/meteor-blaster.git
    cd MeteorBlaster
    love .

### Building Distributables
#### Linux (AppImage)
    zip -r meteor_blaster.love . -x ".github/*" ".opencode/*" "*.git*" "love.AppImage"
    wget https://github.com/love2d/love/releases/download/11.5/love-11.5-x86_64.AppImage
    cat love-11.5-x86_64.AppImage meteor_blaster.love > MeteorBlaster-Linux.AppImage
    chmod +x MeteorBlaster-Linux.AppImage

#### Windows (EXE)
    zip -r meteor_blaster.love . -x ".github/*" ".opencode/*" "*.git*"
    wget https://github.com/love2d/love/releases/download/11.5/love-11.5-win64.zip
    unzip love-11.5-win64.zip
    copy /b love.exe+meteor_blaster.love MeteorBlaster.exe

## License
MIT License

## Credits
- Built with LÖVE (https://love2d.org/)
- Inspired by the classic Asteroids arcade game
```

### Questions

> - What license? (MIT, GPL, Unlicense, or "All rights reserved"?)
> - Add a screenshot placeholder?
> - Extra sections (e.g., "Contributing", "Roadmap")?

---

## Step 5: .gitignore

```gitignore
# LÖVE build artifacts
*.love
*.AppImage
*.exe
*.dmg

# Downloaded LÖVE binaries
love-11.5-x86_64.AppImage
love-11.5-win64.zip
love.exe

# IDE / Editor
.opencode/
.vscode/
.idea/
*.swp
*.swo
*~

# OS files
.DS_Store
Thumbs.db

# Build directories
build/
dist/
out/

# Temporary files
*.tmp
*.log
```

### Questions

> - Add any other patterns (e.g., `*.zip` for all zips)?
> - Other editors/IDEs that need ignoring?

---

## Execution Order

1. **Step 1: Rebrand** → Review → Approve
2. **Step 2: Git Init** → Review → Approve
3. **Step 3: GitHub Actions** → Review → Approve
4. **Step 4: README** → Review → Approve
5. **Step 5: .gitignore** → Review → Approve

After all steps, push to GitHub, tag a release, and let the workflow build
and upload the distributables.

---

## Summary of Open Questions

| #  | Question                                                      | Options                                     |
|----|---------------------------------------------------------------|---------------------------------------------|
| 1  | ~~Folder naming~~ → **Decided: PascalCase**                   | `MeteorBlaster` ✅                            |
| 2  | GitHub repo creation                                          | `gh` CLI or manual?                         |
| 3  | macOS build                                                   | Placeholder job or skip?                    |
| 4  | Branch name                                                   | `main` or `master`?                         |
| 5  | License                                                       | MIT, GPL, Unlicense, other?                 |
| 6  | Screenshot placeholder                                        | Yes or no?                                  |
| 7  | Extra README sections                                         | Contributing, Roadmap, etc.?                |
| 8  | .gitignore patterns                                           | Add `*.zip` globally, or keep specific?     |
| 9  | Workflow trigger                                              | Tags only, or also push to `main`?          |
| 10 | Window icon                                                   | Need one, or skip for now?                  |
