-- Almacenamiento de ÁgilU en Supabase Storage, con Firebase Auth como identidad.
--
-- Se ejecuta una vez en el editor SQL del proyecto de Supabase, después de dar
-- de alta Firebase (proyecto agilu-a232a) en Authentication > Third-party Auth.
--
-- Supabase verifica la firma del token de Firebase y rechaza tokens de otros
-- proyectos. Los tokens de Firebase no traen el claim "role", así que llegan
-- con el rol anon de Postgres: por eso las políticas aplican "to anon,
-- authenticated" y siempre exigen que el token sea de Firebase (ver la
-- función de abajo). Una petición con solo la llave pública no pasa.
--
-- Quién decide qué archivo se liga a qué pedido o producto es SQL Connect
-- (mutaciones EnviarComprobante y GuardarFotoProducto), no Supabase.

-- ¿El token es de un usuario de Firebase del proyecto agilu-a232a?
create or replace function public.es_usuario_agilu()
returns boolean
language sql
stable
as $$
  select coalesce(
    auth.jwt() ->> 'iss' = 'https://securetoken.google.com/agilu-a232a'
      and auth.jwt() ->> 'aud' = 'agilu-a232a'
      and coalesce(auth.jwt() ->> 'sub', '') <> '',
    false
  );
$$;

-- Comprobantes: privados. Fotos de productos: lectura pública.
-- Máximo 1 MB y solo JPG o PNG (la app ya reduce la foto antes de subirla).
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('comprobantes', 'comprobantes', false, 1048576, array['image/jpeg', 'image/png']),
  ('productos', 'productos', true, 1048576, array['image/jpeg', 'image/png'])
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

-- Cada quien sube solo dentro de su carpeta: <uid de Firebase>/<archivo>.
drop policy if exists "agilu: subir a la carpeta propia" on storage.objects;
create policy "agilu: subir a la carpeta propia"
on storage.objects for insert
to anon, authenticated
with check (
  bucket_id in ('comprobantes', 'productos')
  and public.es_usuario_agilu()
  and (storage.foldername(name))[1] = auth.jwt() ->> 'sub'
);

-- Comprobantes: se descargan solo por su ruta exacta y con sesión. No se
-- permite listar ni firmar URLs. La ruta lleva un identificador aleatorio y
-- solo SQL Connect la entrega al alumno dueño y al personal de la cafetería.
drop policy if exists "agilu: descargar comprobante por ruta" on storage.objects;
create policy "agilu: descargar comprobante por ruta"
on storage.objects for select
to anon, authenticated
using (
  bucket_id = 'comprobantes'
  and public.es_usuario_agilu()
  and storage.allow_any_operation(array[
    'storage.object.get_authenticated',
    'object.get_authenticated'
  ])
);

-- Las fotos de productos se sirven por la URL pública del bucket; no hace
-- falta política de lectura. No hay políticas de update ni delete: nadie
-- reemplaza ni borra archivos desde la app.
