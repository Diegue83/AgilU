// Levanta los emuladores de Auth y SQL Connect y corre las pruebas.
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const raiz = fileURLToPath(new URL('..', import.meta.url));
const r = spawnSync(
  'firebase',
  [
    'emulators:exec',
    '--only', 'auth,dataconnect',
    '--project', 'demo-agilu',
    '"node --test test_dataconnect/permisos.test.js"',
  ],
  {
    cwd: raiz,
    stdio: 'inherit',
    shell: true,
  },
);
process.exit(r.status ?? 1);
