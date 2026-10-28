// Carga dataconnect/seed_data.gql en el emulador de SQL Connect que ya está corriendo.
import { readFileSync } from 'node:fs';

const url =
  'http://127.0.0.1:9399/v1/projects/demo-agilu/locations/us-east4/' +
  'services/agilu-a232a-service:executeGraphql';

const res = await fetch(url, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    query: readFileSync(new URL('../dataconnect/seed_data.gql', import.meta.url), 'utf8'),
    operationName: 'SembrarCatalogo',
  }),
});
const cuerpo = await res.json();
if (!res.ok || cuerpo.errors?.length) {
  console.error(JSON.stringify(cuerpo, null, 2));
  process.exit(1);
}
console.log('Catálogo de prueba cargado.');
