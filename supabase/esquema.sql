-- ============================================================================
-- FitCore - Esquema de base de datos para Supabase
-- Ejecuta todo este archivo en el SQL Editor de tu proyecto Supabase.
-- ============================================================================

create extension if not exists pgcrypto;

-- ----------------------------------------------------------------------------
-- Usuarios (perfil publico enlazado a auth.users)
-- ----------------------------------------------------------------------------
create table if not exists public.usuarios (
  id uuid primary key references auth.users (id) on delete cascade,
  nombre text not null default '',
  apellidos text not null default '',
  correo text not null default '',
  telefono text not null default '',
  rol text not null default 'socio' check (rol in ('admin', 'coach', 'socio')),
  activo boolean not null default true,
  especialidad text,
  fecha_registro timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- Clases dirigidas
-- ----------------------------------------------------------------------------
create table if not exists public.clases (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  descripcion text not null default '',
  coach_id uuid references public.usuarios (id) on delete set null,
  coach_nombre text not null default '',
  dia_semana int not null default 1 check (dia_semana between 1 and 7),
  hora text not null default '18:00',
  duracion_min int not null default 60,
  cupo_max int not null default 20,
  sala text not null default '',
  activa boolean not null default true
);

-- ----------------------------------------------------------------------------
-- Rutinas
-- ----------------------------------------------------------------------------
create table if not exists public.rutinas (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  descripcion text not null default '',
  coach_id uuid references public.usuarios (id) on delete set null,
  coach_nombre text not null default '',
  nivel text not null default 'Principiante',
  semanas int not null default 4,
  activa boolean not null default true
);

-- ----------------------------------------------------------------------------
-- Membresias
-- ----------------------------------------------------------------------------
create table if not exists public.membresias (
  id uuid primary key default gen_random_uuid(),
  socio_id uuid references public.usuarios (id) on delete cascade,
  socio_nombre text not null default '',
  plan text not null default 'Mensual',
  precio numeric(10, 2) not null default 0,
  fecha_inicio date default now(),
  fecha_fin date,
  activa boolean not null default true
);

-- ----------------------------------------------------------------------------
-- Pagos
-- ----------------------------------------------------------------------------
create table if not exists public.pagos (
  id uuid primary key default gen_random_uuid(),
  socio_id uuid references public.usuarios (id) on delete cascade,
  socio_nombre text not null default '',
  concepto text not null default 'Mensualidad',
  monto numeric(10, 2) not null default 0,
  metodo text not null default 'Efectivo',
  fecha timestamptz default now(),
  pagado boolean not null default true
);

-- ----------------------------------------------------------------------------
-- Trigger: al registrarse en Auth se crea el perfil en public.usuarios
-- ----------------------------------------------------------------------------
create or replace function public.crear_perfil()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.usuarios (id, nombre, apellidos, telefono, correo, rol)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'nombre', ''),
    coalesce(new.raw_user_meta_data ->> 'apellidos', ''),
    coalesce(new.raw_user_meta_data ->> 'telefono', ''),
    coalesce(new.email, ''),
    coalesce(new.raw_user_meta_data ->> 'rol', 'socio')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.crear_perfil();

-- ----------------------------------------------------------------------------
-- Funcion auxiliar para saber si el usuario actual es administrador
-- ----------------------------------------------------------------------------
create or replace function public.es_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.usuarios u
    where u.id = auth.uid() and u.rol = 'admin' and u.activo
  );
$$;

-- ----------------------------------------------------------------------------
-- Seguridad a nivel de filas (RLS)
-- ----------------------------------------------------------------------------
alter table public.usuarios enable row level security;
alter table public.clases enable row level security;
alter table public.rutinas enable row level security;
alter table public.membresias enable row level security;
alter table public.pagos enable row level security;

-- usuarios
drop policy if exists usuarios_select on public.usuarios;
create policy usuarios_select on public.usuarios
  for select using (id = auth.uid() or public.es_admin());

drop policy if exists usuarios_insert on public.usuarios;
create policy usuarios_insert on public.usuarios
  for insert with check (id = auth.uid() or public.es_admin());

drop policy if exists usuarios_update on public.usuarios;
create policy usuarios_update on public.usuarios
  for update using (id = auth.uid() or public.es_admin());

drop policy if exists usuarios_delete on public.usuarios;
create policy usuarios_delete on public.usuarios
  for delete using (public.es_admin());

-- clases
drop policy if exists clases_lectura on public.clases;
create policy clases_lectura on public.clases
  for select using (auth.role() = 'authenticated');

drop policy if exists clases_escritura on public.clases;
create policy clases_escritura on public.clases
  for all using (public.es_admin()) with check (public.es_admin());

-- rutinas
drop policy if exists rutinas_lectura on public.rutinas;
create policy rutinas_lectura on public.rutinas
  for select using (auth.role() = 'authenticated');

drop policy if exists rutinas_escritura on public.rutinas;
create policy rutinas_escritura on public.rutinas
  for all using (public.es_admin()) with check (public.es_admin());

-- membresias
drop policy if exists membresias_lectura on public.membresias;
create policy membresias_lectura on public.membresias
  for select using (socio_id = auth.uid() or public.es_admin());

drop policy if exists membresias_escritura on public.membresias;
create policy membresias_escritura on public.membresias
  for all using (public.es_admin()) with check (public.es_admin());

-- pagos
drop policy if exists pagos_lectura on public.pagos;
create policy pagos_lectura on public.pagos
  for select using (socio_id = auth.uid() or public.es_admin());

drop policy if exists pagos_escritura on public.pagos;
create policy pagos_escritura on public.pagos
  for all using (public.es_admin()) with check (public.es_admin());

-- ----------------------------------------------------------------------------
-- Convierte tu cuenta en administrador (cambia el correo).
-- Ejecuta esto DESPUES de registrarte desde la app.
-- ----------------------------------------------------------------------------
-- update public.usuarios set rol = 'admin' where correo = 'tu-correo@ejemplo.com';
