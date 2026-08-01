create table cuidadores (
  id uuid primary key default gen_random_uuid(),
  usuario_id uuid not null unique,
  telefono text,

  constraint fk_usuario_cuidador
    foreign key (usuario_id)
    references usuarios(id)
    on delete cascade
);