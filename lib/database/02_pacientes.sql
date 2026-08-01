create table pacientes (
  id uuid primary key default gen_random_uuid(),
  usuario_id uuid not null unique,

  constraint fk_usuario
    foreign key (usuario_id)
    references usuarios(id)
    on delete cascade
);