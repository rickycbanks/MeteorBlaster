# Meteor Blaster

A classic Asteroids-style arcade game built with [LÖVE](https://love2d.org/) 11.5.

Destroy meteors, rack up points, and climb the leaderboard. Procedural sound effects, persistent high scores, smooth 60 FPS.

## How to Play

Download the latest release for your platform from [Releases](https://github.com/rickycbanks/MeteorBlaster/releases), run it, and you're in.

### Controls

| Key | Action |
|-----|--------|
| Left / Right Arrow | Rotate ship |
| Up Arrow | Thrust forward |
| Space | Shoot |
| Escape | Return to menu |

### Gameplay

- Shoot meteors to score points — large meteors split into smaller ones
- Survive as long as you can; you start with 3 lives
- Clear all meteors to advance to the next level (things get faster)
- After game over, enter your name for the leaderboard

## Building from Source

### Prerequisites

- [LÖVE 11.5](https://github.com/love2d/love/releases/tag/11.5)
- Git

### Run Locally

```bash
git clone https://github.com/rickycbanks/MeteorBlaster.git
cd MeteorBlaster
love .
```

### Build a Distributable

#### Linux (AppImage)

```bash
zip -r MeteorBlaster.love . -x ".github/*" ".opencode/*" ".git/*" "love.AppImage" "*.exe"
wget https://github.com/love2d/love/releases/download/11.5/love-11.5-x86_64.AppImage
cat love-11.5-x86_64.AppImage MeteorBlaster.love > MeteorBlaster-Linux.AppImage
chmod +x MeteorBlaster-Linux.AppImage
```

#### Windows (EXE)

```bash
zip -r MeteorBlaster.love . -x ".github/*" ".opencode/*" ".git/*" "love.AppImage" "*.exe"
wget https://github.com/love2d/love/releases/download/11.5/love-11.5-win64.zip
unzip love-11.5-win64.zip
copy /b love-11.5-win64\love.exe+MeteorBlaster.love MeteorBlaster.exe
```

## License

MIT

## Credits

- Built with [LÖVE](https://love2d.org/)
- Inspired by the classic Asteroids arcade game
