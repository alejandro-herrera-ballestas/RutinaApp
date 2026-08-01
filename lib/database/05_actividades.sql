create table actividades (
    id uuid primary key default gen_random_uuid(),

    paciente_id uuid not null,

    nombre text not null,
    descripcion text,
    imagen text,

    hora_inicio time not null,
    duracion interval not null,

    constraint fk_paciente
        foreign key (paciente_id)
        references pacientes(id)
        on delete cascade
);