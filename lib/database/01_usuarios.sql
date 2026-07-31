create table usuarios (
    id uuid primary key default gen_random_uuid(),
    nombre text not null,
    fecha_nacimiento date,
    foto_perfil text,
    fecha_registro timestamp with time zone default now()
);