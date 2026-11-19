// Brainrot Bay: the entry program (Node 22, standard library only). It hands
// the game in: copies game.rbxl, src/, screenshots/ and PLAY.json from beside
// this file to /output and writes /output/dossier.json with the vendored
// make.fun library, so the judge can read the place, the scripts and the
// screenshots. Run it locally with MAKEFUN_OUTPUT_DIR set:
//   mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts

import { copyFileSync, cpSync, existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { basename, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildDossier } from './vendor/makefun-roblox.ts';

const here = fileURLToPath(new URL('.', import.meta.url));
const out = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

// The grader refuses any output name starting with a dot, so dotfiles
// (.gitkeep, .DS_Store, .git) are left out of every copied tree.
const keepVisible = (path: string): boolean => !basename(path).startsWith('.');

function handIn(): void {
  copyFileSync(join(here, 'game.rbxl'), join(out, 'game.rbxl'));
  copyFileSync(join(here, 'PLAY.json'), join(out, 'PLAY.json'));
  cpSync(join(here, 'src'), join(out, 'src'), { recursive: true, filter: keepVisible });
  mkdirSync(join(out, 'screenshots'), { recursive: true });
  if (existsSync(join(here, 'screenshots'))) {
    cpSync(join(here, 'screenshots'), join(out, 'screenshots'), { recursive: true, filter: keepVisible });
  }
  // The scorer's own caps: the dossier text is capped and the screenshots,
  // instance and script totals are refused when they pass the gate's limits.
  writeFileSync(
    join(out, 'dossier.json'),
    buildDossier(out, { text_max_bytes: 65536, screenshots: { max: 4, max_bytes: 262144 }, max_instances: 500000, scripts_max_source_bytes: 8388608, scripts_max_path_chars: 1048576 }),
  );
  console.log('Brainrot Bay handed in to ' + out);
}

handIn();
