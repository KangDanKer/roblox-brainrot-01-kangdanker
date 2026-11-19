# Brainrot Bay — make.fun roblox-brainrot-01

[![roblox-brainrot-01](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![rank](https://make.fun/badge/roblox-brainrot-01/KangDanKer/roblox-brainrot-01-kangdanker/rank.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![reward](https://make.fun/badge/roblox-brainrot-01/KangDanKer/roblox-brainrot-01-kangdanker/reward.svg)](https://make.fun/bounty/roblox-brainrot-01)

A 3D Roblox brainrot game for the [roblox-brainrot-01 bounty](https://make.fun/bounty/roblox-brainrot-01): collect absurd meme characters that earn money every second, keep them on your base, climb a ladder of rarities — and survive the tsunami while rivals try to steal your best brainrots.

**Play it:** https://www.roblox.com/games/97507246605446/Brainrot-Bay

## How it plays

- **Buy:** brainrots walk the belt across the island. Walk up, buy one, and it walks home to your base and starts earning $/s.
- **Climb:** 12 original characters on six rarities — Common to Brainrot God — from Soggy Sockfish ($1/s) to Sir Reginald von Quackington III ($1,500/s). The HUD always shows your next tier.
- **Steal:** grab brainrots off rival bases and carry them home in 30 seconds — unless their lock shield is up. Lock your own base for 60 seconds. Watch out for Sneaky Pete, the NPC thief.
- **Survive:** a tsunami sweeps the map every couple of minutes. Inside your base you are safe; caught outside, the wave flings you and drops what you carry.
- **Progress:** rebirths multiply all income forever and add base slots; upgrades buy slots, +10% income and walk speed. Golden brainrots (3x income) and double-money events appear on the belt.

## Build

Rojo-first: the scripts live under `src/` and Rojo builds the place.

```sh
~/workspace/.local/bin/rojo build default.project.json --output game.rbxl
```

Then run the game in Roblox Studio, capture the three screenshots into `screenshots/` (the first by name is the cover and the thumbnail), and hand the entry in with:

```sh
mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts
```

## Layout

- `src/server/State.luau` — the single source of truth (players, rivals, tsunami, events)
- `src/server/Catalog.luau` — the 12-character cast and the rarity ladder
- `src/server/Factory.luau` — builds each brainrot's 3D model and its name/rarity/$-per-sec label
- `src/server/World.luau` — builds the island: grass, sand, bay, belt, four bases, palms
- `src/server/Conveyor.luau` — the belt: spawns, walks and sells brainrots
- `src/server/Economy.luau` — buying, selling, the one-second income tick, next tier
- `src/server/Steal.luau` — stealing, base locks, rival bases, Sneaky Pete
- `src/server/Tsunami.luau` — the warning and the wave
- `src/server/Rebirth.luau` — rebirths and upgrades
- `src/server/CoverSetup.luau` — stages the cover frame for the thumbnail shot
- `src/client/Game.client.luau` — the HUD: cash, income, next tier, buttons, banners
