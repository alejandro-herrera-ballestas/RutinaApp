create table cuidador_paciente (
    cuidador_id uuid not null,
    paciente_id uuid not null,

    primary key (cuidador_id, paciente_id),

    constraint fk_cuidador
        foreign key (cuidador_id)
        references cuidadores(id)
        on delete cascade,

    constraint fk_paciente
        foreign key (paciente_id)
        references pacientes(id)
        on delete cascade
);