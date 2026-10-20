-- ============================================================================
-- FitCore - Esquema complementario para Supabase
-- Tablas para los modulos: Avisos, Planes (tipos de membresia) e
-- Informacion del gimnasio.
-- Ejecuta todo este archivo en el SQL Editor de tu proyecto Supabase,
-- DESPUES de haber ejecutado esquema.sql (depende de public.es_admin()).
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Avisos y novedades
-- ----------------------------------------------------------------------------
create table if not exists public.avisos (
  id uuid primary key default gen_random_uuid(),
  titulo text not null default '',
  contenido text not null default '',
  fecha_publicacion timestamptz not null default now(),
  activo boolean not null default true,
  importante boolean not null default false
);

-- ----------------------------------------------------------------------------
-- Planes / tipos de membresia
-- ----------------------------------------------------------------------------
create table if not exists public.planes (
  id uuid primary key default gen_random_uuid(),
  nombre text not null default '',
  descripcion text not null default '',
  duracion_dias int not null default 30,
  precio numeric(10, 2) not null default 0,
  condiciones text not null default '',
  activo boolean not null default true
);

-- ----------------------------------------------------------------------------
-- Informacion general del gimnasio (registro unico)
-- ----------------------------------------------------------------------------
create table if not exists public.info_gimnasio (
  id uuid primary key default gen_random_uuid(),
  nombre text not null default 'Ciclic Studio',
  descripcion text not null default '',
  direccion text not null default '',
  telefono text not null default '',
  horarios_atencion text not null default '',
  servicios text not null default '',
  imagen_url text not null default ''
);

-- ----------------------------------------------------------------------------
-- Seguridad a nivel de filas (RLS)
-- ----------------------------------------------------------------------------
alter table public.avisos enable row level security;
alter table public.planes enable row level security;
alter table public.info_gimnasio enable row level security;

-- avisos
drop policy if exists avisos_lectura on public.avisos;
create policy avisos_lectura on public.avisos
  for select using (auth.role() = 'authenticated');

drop policy if exists avisos_escritura on public.avisos;
create policy avisos_escritura on public.avisos
  for all using (public.es_admin()) with check (public.es_admin());

-- planes
drop policy if exists planes_lectura on public.planes;
create policy planes_lectura on public.planes
  for select using (auth.role() = 'authenticated');

drop policy if exists planes_escritura on public.planes;
create policy planes_escritura on public.planes
  for all using (public.es_admin()) with check (public.es_admin());

-- info_gimnasio
drop policy if exists info_gimnasio_lectura on public.info_gimnasio;
create policy info_gimnasio_lectura on public.info_gimnasio
  for select using (auth.role() = 'authenticated');

drop policy if exists info_gimnasio_escritura on public.info_gimnasio;
create policy info_gimnasio_escritura on public.info_gimnasio
  for all using (public.es_admin()) with check (public.es_admin());
