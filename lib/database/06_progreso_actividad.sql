create table progreso_actividad (
    id uuid primary key default gen_random_uuid(),

    actividad_id uuid not null,

    fecha date not null,

    completada boolean not null default false,

    hora_completada timestamp with time zone,

    constraint fk_actividad
        foreign key (actividad_id)
        references actividades(id)
        on delete cascade,

    constraint actividad_fecha_unica
        unique (actividad_id, fecha)
);