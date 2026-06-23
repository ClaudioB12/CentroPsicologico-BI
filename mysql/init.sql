-- ================================================================
--  OLTP — CENTRO PSICOLÓGICO INTEGRAL GUEVARA
--  Base de datos operacional normalizada — Versión 2.0 | Mayo 2026
-- ================================================================

SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';

CREATE DATABASE IF NOT EXISTS dm_centro_psicologico
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE dm_centro_psicologico;

-- ================================================================
--  DDL
-- ================================================================

DROP TABLE IF EXISTS pagos;
DROP TABLE IF EXISTS plan_intervencion;
DROP TABLE IF EXISTS diagnosticos;
DROP TABLE IF EXISTS evaluacion_psicologica;
DROP TABLE IF EXISTS sesiones;
DROP TABLE IF EXISTS historia_clinica;
DROP TABLE IF EXISTS pacientes;
DROP TABLE IF EXISTS psicologos;
DROP TABLE IF EXISTS sedes;

CREATE TABLE sedes (
  sede_id      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre_sede  VARCHAR(120) NOT NULL,
  ciudad       VARCHAR(80),
  tiene_online TINYINT(1) DEFAULT 0,
  estado       ENUM('ACTIVA','INACTIVA') DEFAULT 'ACTIVA'
) ENGINE=InnoDB;

CREATE TABLE psicologos (
  psicologo_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  dni          VARCHAR(15)  NOT NULL UNIQUE,
  nombres      VARCHAR(120) NOT NULL,
  especialidad VARCHAR(120),
  cpp          VARCHAR(20),
  modalidad    ENUM('PRESENCIAL','ONLINE','AMBAS') DEFAULT 'AMBAS',
  sede_id      INT UNSIGNED,
  estado       ENUM('ACTIVO','INACTIVO') DEFAULT 'ACTIVO',
  FOREIGN KEY (sede_id) REFERENCES sedes(sede_id)
) ENGINE=InnoDB;

CREATE TABLE pacientes (
  paciente_id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombres             VARCHAR(80)  NOT NULL,
  apellido_paterno    VARCHAR(60),
  apellido_materno    VARCHAR(60),
  tipo_documento      ENUM('DNI','CE','PASAPORTE') DEFAULT 'DNI',
  numero_documento    VARCHAR(15)  NOT NULL UNIQUE,
  fecha_nacimiento    DATE,
  sexo                ENUM('MASCULINO','FEMENINO','OTRO'),
  estado_civil        VARCHAR(30),
  grado_instruccion   VARCHAR(40),
  ocupacion           VARCHAR(80),
  celular             VARCHAR(15),
  email               VARCHAR(120),
  direccion           VARCHAR(200),
  fecha_registro      DATE,
  canal_captacion     VARCHAR(60),
  estado_paciente     ENUM('EN_TRATAMIENTO','ALTA','ABANDONO','EVALUACION'),
  modalidad_preferida ENUM('PRESENCIAL','ONLINE','HIBRIDA'),
  sede_id             INT UNSIGNED,
  FOREIGN KEY (sede_id) REFERENCES sedes(sede_id)
) ENGINE=InnoDB;

CREATE TABLE historia_clinica (
  historia_id             INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  paciente_id             INT UNSIGNED NOT NULL,
  codigo_historia         VARCHAR(30)  NOT NULL UNIQUE,
  tipo_historial          ENUM('INDIVIDUAL','PAREJA') NOT NULL,
  fecha_apertura          DATE,
  observaciones_generales TEXT,
  estado_historia         ENUM('ABIERTA','CERRADA','SUSPENDIDA') DEFAULT 'ABIERTA',
  FOREIGN KEY (paciente_id) REFERENCES pacientes(paciente_id)
) ENGINE=InnoDB;

CREATE TABLE sesiones (
  sesion_id       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  historia_id     INT UNSIGNED NOT NULL,
  psicologo_id    INT UNSIGNED NOT NULL,
  fecha_sesion    DATE NOT NULL,
  hora_sesion     TIME,
  nro_sesion      SMALLINT UNSIGNED,
  etapa_atencion  VARCHAR(30),
  modalidad       ENUM('PRESENCIAL','ONLINE','HIBRIDA'),
  duracion_min    SMALLINT UNSIGNED,
  motivo_consulta VARCHAR(200),
  observaciones   TEXT,
  estado_sesion   ENUM('REALIZADA','CANCELADA','NO_SHOW'),
  FOREIGN KEY (historia_id)  REFERENCES historia_clinica(historia_id),
  FOREIGN KEY (psicologo_id) REFERENCES psicologos(psicologo_id)
) ENGINE=InnoDB;

CREATE TABLE evaluacion_psicologica (
  evaluacion_id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  sesion_id         INT UNSIGNED NOT NULL UNIQUE,
  metodos_aplicados TEXT,
  resultados        TEXT,
  puntaje_cdi       DECIMAL(6,2),
  puntaje_stai      DECIMAL(6,2),
  observaciones     TEXT,
  fecha_evaluacion  DATE,
  FOREIGN KEY (sesion_id) REFERENCES sesiones(sesion_id)
) ENGINE=InnoDB;

CREATE TABLE diagnosticos (
  diagnostico_id      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  sesion_id           INT UNSIGNED NOT NULL,
  codigo_cie10        VARCHAR(10),
  descripcion_cie10   VARCHAR(200),
  diagnostico_clinico TEXT,
  observaciones       TEXT,
  FOREIGN KEY (sesion_id) REFERENCES sesiones(sesion_id)
) ENGINE=InnoDB;

CREATE TABLE plan_intervencion (
  plan_id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  sesion_id       INT UNSIGNED NOT NULL,
  objetivos       TEXT,
  intervenciones  TEXT,
  recomendaciones TEXT,
  fecha_inicio    DATE,
  fecha_fin       DATE,
  estado_plan     ENUM('ACTIVO','COMPLETADO','SUSPENDIDO') DEFAULT 'ACTIVO',
  FOREIGN KEY (sesion_id) REFERENCES sesiones(sesion_id)
) ENGINE=InnoDB;

CREATE TABLE pagos (
  pago_id       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  sesion_id     INT UNSIGNED NOT NULL,
  fecha_pago    DATE NOT NULL,
  monto         DECIMAL(8,2) NOT NULL DEFAULT 0,
  comprobante   VARCHAR(50),
  metodo_pago   ENUM('EFECTIVO','TARJETA','TRANSFERENCIA','YAPE','PLIN','EXONERADO'),
  estado_pago   ENUM('PAGADO','PENDIENTE','EXONERADO'),
  observaciones TEXT,
  FOREIGN KEY (sesion_id) REFERENCES sesiones(sesion_id)
) ENGINE=InnoDB;


-- ================================================================
--  DATOS DE MUESTRA
-- ================================================================

INSERT INTO sedes (nombre_sede, ciudad, tiene_online, estado) VALUES
  ('Sede Central Juliaca', 'Juliaca', 1, 'ACTIVA'),
  ('Sede Online',          'Virtual', 1, 'ACTIVA');

INSERT INTO psicologos (dni, nombres, especialidad, cpp, modalidad, sede_id) VALUES
  ('98765432', 'Dr. Garcia Lopez',    'Psicologia Clinica',   'CPP-12345', 'AMBAS',      1),
  ('87654321', 'Lic. Mamani Flores',  'Psicologia de Pareja', 'CPP-23456', 'AMBAS',      1),
  ('76543210', 'Dra. Quispe Condori', 'Psicologia Infantil',  'CPP-34567', 'PRESENCIAL', 1),
  ('65432109', 'Mg. Torres Huanca',   'Neuropsicologia',      'CPP-45678', 'ONLINE',     2);

INSERT INTO pacientes (nombres, apellido_paterno, apellido_materno,
  tipo_documento, numero_documento, fecha_nacimiento, sexo, estado_civil,
  grado_instruccion, ocupacion, celular, email, direccion,
  fecha_registro, canal_captacion, estado_paciente, modalidad_preferida, sede_id) VALUES
  ('Carlos',   'Cruz',      'Ramos',    'DNI','39958838','1953-12-04','MASCULINO','DIVORCIADO',  'SUPERIOR_INCOMPLETO',  'Comerciante', '913718431','carlos54@gmail.com',   'Av. Moquegua 123',   '2020-10-29','Referido',       'EVALUACION',     'PRESENCIAL',1),
  ('Roberto',  'Huanca',    'Vargas',   'DNI','47308985','1974-11-27','MASCULINO','DIVORCIADO',  'PRIMARIA_COMPLETA',    'Tecnico',     '921931511','roberto97@gmail.com',  'Jr. Lima 456',       '2021-07-09','Redes sociales', 'EN_TRATAMIENTO', 'ONLINE',    1),
  ('Gloria',   'Mendoza',   'Luque',    'DNI','63606628','1968-04-05','FEMENINO', 'DIVORCIADO',  'PRIMARIA_COMPLETA',    'Ingeniero',   '960897765','gloria74@gmail.com',   'Calle Cusco 789',    '2023-02-16','Web',            'ALTA',           'ONLINE',    1),
  ('Diego',    'Condori',   'Catacora', 'DNI','26879290','1953-11-16','MASCULINO','CONVIVIENTE', 'SECUNDARIA_COMPLETA',  'Tecnico',     '909528530','diego18@gmail.com',    'Psje. Ayaviri 12',   '2021-05-16','Referido',       'ALTA',           'HIBRIDA',   1),
  ('Valeria',  'Mendoza',   'Ponce',    'DNI','72682989','2000-12-02','FEMENINO', 'CASADO',      'SECUNDARIA_COMPLETA',  'Estudiante',  '956623995','valeria19@gmail.com',  'Av. Puno 234',       '2020-07-25','Redes sociales', 'EN_TRATAMIENTO', 'PRESENCIAL',1),
  ('Rosa',     'Flores',    'Apaza',    'DNI','39219319','1948-10-24','FEMENINO', 'CASADO',      'PRIMARIA_INCOMPLETA',  'Tecnico',     '988231132','rosa43@gmail.com',     'Jr. Ayaviri 567',    '2020-06-09','Referido',       'EVALUACION',     'HIBRIDA',   1),
  ('Roberto',  'Vargas',    'Apaza',    'DNI','31172421','1973-09-23','MASCULINO','CONVIVIENTE', 'SUPERIOR_INCOMPLETO',  'Ama de casa', '935496015','roberto44@gmail.com',  'Av. Juliaca 890',    '2024-11-30','Web',            'ABANDONO',       'HIBRIDA',   1),
  ('Silvia',   'Mendoza',   'Catacora', 'DNI','11297845','1952-02-23','FEMENINO', 'CONVIVIENTE', 'SECUNDARIA_INCOMPLETA','Medico',      '941373735','silvia36@gmail.com',   'Calle Ayaviri 101',  '2024-01-19','Referido',       'ABANDONO',       'ONLINE',    1),
  ('Ricardo',  'Quispe',    'Chuqui',   'DNI','39854548','1957-08-12','MASCULINO','VIUDO',       'SUPERIOR_COMPLETO',    'Ingeniero',   '947130035','ricardo13@gmail.com',  'Jr. Lima 321',       '2021-04-25','Web',            'ABANDONO',       'PRESENCIAL',1),
  ('Eduardo',  'Mendoza',   'Flores',   'DNI','99152472','2003-06-20','MASCULINO','SOLTERO',     'TECNICO_COMPLETO',     'Estudiante',  '974411983','eduardo96@gmail.com',  'Av. Azangaro 654',   '2025-03-05','Redes sociales', 'ABANDONO',       'HIBRIDA',   1),
  ('Pedro',    'Torres',    'Nina',     'DNI','99100953','1985-10-11','MASCULINO','CASADO',      'SECUNDARIA_INCOMPLETA','Docente',     '963771720','pedro63@gmail.com',    'Jr. Lima 789',       '2021-12-11','Referido',       'EN_TRATAMIENTO', 'ONLINE',    1),
  ('Paola',    'Velasquez', 'Machaca',  'DNI','52587010','2005-08-20','FEMENINO', 'SOLTERO',     'SUPERIOR_COMPLETO',    'Conductor',   '920244148','paola18@gmail.com',    'Calle Cusco 432',    '2023-10-08','Web',            'EN_TRATAMIENTO', 'PRESENCIAL',1),
  ('Diego',    'Chavez',    'Condori',  'DNI','68496914','1976-01-13','MASCULINO','VIUDO',       'SECUNDARIA_INCOMPLETA','Tecnico',     '979442503','diego92@gmail.com',    'Av. Arequipa 567',   '2025-12-14','Referido',       'ALTA',           'ONLINE',    1),
  ('Pedro',    'Quispe',    'Quispe',   'DNI','43189803','1957-01-20','MASCULINO','CONVIVIENTE', 'SECUNDARIA_COMPLETA',  'Agricultor',  '922520277','pedro49@gmail.com',    'Psje. Puno 111',     '2021-03-06','Referido',       'EN_TRATAMIENTO', 'HIBRIDA',   1),
  ('Laura',    'Larico',    'Larico',   'DNI','11698142','1999-07-27','FEMENINO', 'SOLTERO',     'POSGRADO',             'Estudiante',  '945150390','laura72@gmail.com',    'Jr. Puno 222',       '2020-08-09','Redes sociales', 'ABANDONO',       'HIBRIDA',   1),
  ('David',    'Chavez',    'Vargas',   'DNI','42655866','1964-11-19','MASCULINO','VIUDO',       'SUPERIOR_COMPLETO',    'Abogado',     '941154241','david50@gmail.com',    'Av. Tacna 333',      '2023-10-11','Web',            'ALTA',           'PRESENCIAL',1),
  ('Fernando', 'Quispe',    'Mamani',   'DNI','84270583','1963-12-05','MASCULINO','CASADO',      'SECUNDARIA_INCOMPLETA','Tecnico',     '933311626','fernando76@gmail.com', 'Calle Juliaca 444',  '2020-01-07','Referido',       'EVALUACION',     'HIBRIDA',   1),
  ('Martha',   'Ccopa',     'Apaza',    'DNI','14380847','1959-05-23','FEMENINO', 'DIVORCIADO',  'SECUNDARIA_COMPLETA',  'Medico',      '986924061','martha19@gmail.com',   'Jr. Lima 555',       '2025-08-21','Redes sociales', 'ABANDONO',       'PRESENCIAL',1),
  ('Roberto',  'Paredes',   'Luque',    'DNI','12784407','1993-11-27','MASCULINO','CONVIVIENTE', 'POSGRADO',             'Ingeniero',   '985199362','roberto54@gmail.com',  'Av. Ilave 666',      '2024-01-21','Web',            'EN_TRATAMIENTO', 'ONLINE',    1),
  ('Omar',     'Apaza',     'Ponce',    'DNI','17275149','1957-09-12','MASCULINO','VIUDO',       'PRIMARIA_COMPLETA',    'Estudiante',  '915766039','omar47@gmail.com',     'Calle Azangaro 777', '2023-11-17','Referido',       'EVALUACION',     'PRESENCIAL',1);

INSERT INTO historia_clinica (paciente_id, codigo_historia, tipo_historial, fecha_apertura, estado_historia) VALUES
  ((SELECT paciente_id FROM pacientes WHERE numero_documento='39958838'),'HC-2020-001','PAREJA',     '2020-10-29','ABIERTA'),
  ((SELECT paciente_id FROM pacientes WHERE numero_documento='47308985'),'HC-2021-002','INDIVIDUAL', '2021-07-09','ABIERTA'),
  ((SELECT paciente_id FROM pacientes WHERE numero_documento='63606628'),'HC-2023-003','PAREJA',     '2023-02-16','CERRADA'),
  ((SELECT paciente_id FROM pacientes WHERE numero_documento='26879290'),'HC-2021-004','PAREJA',     '2021-05-16','CERRADA'),
  ((SELECT paciente_id FROM pacientes WHERE numero_documento='72682989'),'HC-2020-005','INDIVIDUAL', '2020-07-25','ABIERTA'),
  ((SELECT paciente_id FROM pacientes WHERE numero_documento='39219319'),'HC-2020-006','PAREJA',     '2020-06-09','ABIERTA'),
  ((SELECT paciente_id FROM pacientes WHERE numero_documento='31172421'),'HC-2024-007','INDIVIDUAL', '2024-11-30','SUSPENDIDA'),
  ((SELECT paciente_id FROM pacientes WHERE numero_documento='11297845'),'HC-2024-008','INDIVIDUAL', '2024-01-19','SUSPENDIDA'),
  ((SELECT paciente_id FROM pacientes WHERE numero_documento='39854548'),'HC-2021-009','INDIVIDUAL', '2021-04-25','SUSPENDIDA'),
  ((SELECT paciente_id FROM pacientes WHERE numero_documento='99152472'),'HC-2025-010','INDIVIDUAL', '2025-03-05','SUSPENDIDA'),
  ((SELECT paciente_id FROM pacientes WHERE numero_documento='99100953'),'HC-2021-011','INDIVIDUAL', '2021-12-11','ABIERTA'),
  ((SELECT paciente_id FROM pacientes WHERE numero_documento='52587010'),'HC-2023-012','PAREJA',     '2023-10-08','ABIERTA'),
  ((SELECT paciente_id FROM pacientes WHERE numero_documento='68496914'),'HC-2025-013','INDIVIDUAL', '2025-12-14','CERRADA'),
  ((SELECT paciente_id FROM pacientes WHERE numero_documento='43189803'),'HC-2021-014','INDIVIDUAL', '2021-03-06','ABIERTA'),
  ((SELECT paciente_id FROM pacientes WHERE numero_documento='11698142'),'HC-2020-015','PAREJA',     '2020-08-09','SUSPENDIDA'),
  ((SELECT paciente_id FROM pacientes WHERE numero_documento='42655866'),'HC-2023-016','INDIVIDUAL', '2023-10-11','CERRADA'),
  ((SELECT paciente_id FROM pacientes WHERE numero_documento='84270583'),'HC-2020-017','PAREJA',     '2020-01-07','ABIERTA'),
  ((SELECT paciente_id FROM pacientes WHERE numero_documento='14380847'),'HC-2025-018','INDIVIDUAL', '2025-08-21','SUSPENDIDA'),
  ((SELECT paciente_id FROM pacientes WHERE numero_documento='12784407'),'HC-2024-019','INDIVIDUAL', '2024-01-21','ABIERTA'),
  ((SELECT paciente_id FROM pacientes WHERE numero_documento='17275149'),'HC-2023-020','PAREJA',     '2023-11-17','ABIERTA');

INSERT INTO sesiones (historia_id, psicologo_id, fecha_sesion, hora_sesion, nro_sesion,
  etapa_atencion, modalidad, duracion_min, motivo_consulta, estado_sesion) VALUES
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2020-001'),(SELECT psicologo_id FROM psicologos WHERE dni='98765432'),'2024-01-10','09:00:00',1,'MOTIVO_CONSULTA','PRESENCIAL',60,'Crisis de pareja, distanciamiento emocional','REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2020-001'),(SELECT psicologo_id FROM psicologos WHERE dni='98765432'),'2024-01-24','09:00:00',2,'EVALUACION',     'PRESENCIAL',60,'Evaluacion psicologica de la pareja',        'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2020-001'),(SELECT psicologo_id FROM psicologos WHERE dni='98765432'),'2024-02-07','09:00:00',3,'ANAMNESIS',      'PRESENCIAL',60,'Historia relacional y familiar',             'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2021-002'),(SELECT psicologo_id FROM psicologos WHERE dni='87654321'),'2024-02-01','10:00:00',1,'MOTIVO_CONSULTA','ONLINE',    60,'Ansiedad generalizada, insomnio',           'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2021-002'),(SELECT psicologo_id FROM psicologos WHERE dni='87654321'),'2024-02-15','10:00:00',2,'EVALUACION',     'ONLINE',    60,'Evaluacion con escala STAI y BAI',          'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2021-002'),(SELECT psicologo_id FROM psicologos WHERE dni='87654321'),'2024-03-01','10:00:00',3,'TRATAMIENTO',    'ONLINE',    60,'TCC tecnicas de relajacion cognitiva',     'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2021-002'),(SELECT psicologo_id FROM psicologos WHERE dni='87654321'),'2024-03-15','10:00:00',4,'TRATAMIENTO',    'ONLINE',    60,'TCC reestructuracion cognitiva',           'CANCELADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2023-003'),(SELECT psicologo_id FROM psicologos WHERE dni='98765432'),'2024-01-15','11:00:00',1,'SEGUIMIENTO',    'ONLINE',    60,'Seguimiento post-alta',                    'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2023-003'),(SELECT psicologo_id FROM psicologos WHERE dni='98765432'),'2024-03-15','11:00:00',2,'CIERRE',         'ONLINE',    60,'Cierre formal del proceso terapeutico',    'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2021-004'),(SELECT psicologo_id FROM psicologos WHERE dni='87654321'),'2024-01-20','14:00:00',1,'SEGUIMIENTO',    'HIBRIDA',   60,'Revision de avances en comunicacion',      'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2021-004'),(SELECT psicologo_id FROM psicologos WHERE dni='87654321'),'2024-04-20','14:00:00',2,'CIERRE',         'HIBRIDA',   60,'Cierre del proceso terapeutico',           'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2020-005'),(SELECT psicologo_id FROM psicologos WHERE dni='76543210'),'2024-02-10','09:00:00',1,'MOTIVO_CONSULTA','PRESENCIAL',60,'Depresion post-ruptura, bajo estado de animo','REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2020-005'),(SELECT psicologo_id FROM psicologos WHERE dni='76543210'),'2024-02-24','09:00:00',2,'EVALUACION',     'PRESENCIAL',60,'Evaluacion con CDI-2 y BDI-II',            'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2020-005'),(SELECT psicologo_id FROM psicologos WHERE dni='76543210'),'2024-03-09','09:00:00',3,'TRATAMIENTO',    'PRESENCIAL',90,'TCC activacion conductual',                'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2020-005'),(SELECT psicologo_id FROM psicologos WHERE dni='76543210'),'2024-03-23','09:00:00',4,'TRATAMIENTO',    'PRESENCIAL',90,'TCC reestructuracion cognitiva',            'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2020-005'),(SELECT psicologo_id FROM psicologos WHERE dni='76543210'),'2024-04-06','09:00:00',5,'TRATAMIENTO',    'PRESENCIAL',90,'TCC esquemas cognitivos',                  'NO_SHOW'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2020-006'),(SELECT psicologo_id FROM psicologos WHERE dni='98765432'),'2024-03-05','11:00:00',1,'MOTIVO_CONSULTA','HIBRIDA',   60,'Conflictos familiares, comunicacion deficiente','REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2020-006'),(SELECT psicologo_id FROM psicologos WHERE dni='98765432'),'2024-03-19','11:00:00',2,'ANAMNESIS',      'HIBRIDA',   60,'Historia familiar y relacional',            'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2024-007'),(SELECT psicologo_id FROM psicologos WHERE dni='65432109'),'2024-12-05','16:00:00',1,'MOTIVO_CONSULTA','ONLINE',    50,'Dificultades de atencion y concentracion',  'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2024-007'),(SELECT psicologo_id FROM psicologos WHERE dni='65432109'),'2024-12-19','16:00:00',2,'EVALUACION',     'ONLINE',    50,'Evaluacion neuropsicologica inicial',       'CANCELADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2024-008'),(SELECT psicologo_id FROM psicologos WHERE dni='65432109'),'2024-01-25','15:00:00',1,'MOTIVO_CONSULTA','ONLINE',    50,'Estres laboral, sindrome de burnout',       'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2024-008'),(SELECT psicologo_id FROM psicologos WHERE dni='65432109'),'2024-02-08','15:00:00',2,'EVALUACION',     'ONLINE',    50,'Evaluacion con STAI-E/R y MBI-GS',         'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2024-008'),(SELECT psicologo_id FROM psicologos WHERE dni='65432109'),'2024-02-22','15:00:00',3,'TRATAMIENTO',    'ONLINE',    50,'Manejo de estres tecnicas cognitivas',     'CANCELADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2021-009'),(SELECT psicologo_id FROM psicologos WHERE dni='76543210'),'2024-05-10','10:00:00',1,'MOTIVO_CONSULTA','PRESENCIAL',60,'TOC con rituales de verificacion',          'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2021-009'),(SELECT psicologo_id FROM psicologos WHERE dni='76543210'),'2024-05-24','10:00:00',2,'EVALUACION',     'PRESENCIAL',60,'Evaluacion con Y-BOCS y OCI-R',             'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2021-009'),(SELECT psicologo_id FROM psicologos WHERE dni='76543210'),'2024-06-07','10:00:00',3,'TRATAMIENTO',    'PRESENCIAL',60,'Exposicion con prevencion de respuesta',    'CANCELADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2025-010'),(SELECT psicologo_id FROM psicologos WHERE dni='65432109'),'2025-03-10','17:00:00',1,'MOTIVO_CONSULTA','ONLINE',    45,'TDAH en adulto, baja productividad',        'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2025-010'),(SELECT psicologo_id FROM psicologos WHERE dni='65432109'),'2025-03-24','17:00:00',2,'EVALUACION',     'ONLINE',    45,'Evaluacion neuropsicologica TDAH',          'NO_SHOW'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2021-011'),(SELECT psicologo_id FROM psicologos WHERE dni='87654321'),'2024-04-01','10:00:00',1,'MOTIVO_CONSULTA','ONLINE',    60,'Fobia social, evitacion de situaciones',    'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2021-011'),(SELECT psicologo_id FROM psicologos WHERE dni='87654321'),'2024-04-15','10:00:00',2,'EVALUACION',     'ONLINE',    60,'Evaluacion con SPIN y LSAS',               'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2021-011'),(SELECT psicologo_id FROM psicologos WHERE dni='87654321'),'2024-04-29','10:00:00',3,'TRATAMIENTO',    'ONLINE',    60,'TCC exposicion gradual',                   'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2021-011'),(SELECT psicologo_id FROM psicologos WHERE dni='87654321'),'2024-05-13','10:00:00',4,'TRATAMIENTO',    'ONLINE',    60,'TCC habilidades sociales',                 'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2023-012'),(SELECT psicologo_id FROM psicologos WHERE dni='87654321'),'2024-06-03','14:00:00',1,'MOTIVO_CONSULTA','PRESENCIAL',60,'Infidelidad, ruptura de confianza',         'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2023-012'),(SELECT psicologo_id FROM psicologos WHERE dni='87654321'),'2024-06-17','14:00:00',2,'ANAMNESIS',      'PRESENCIAL',60,'Historia relacional de la pareja',          'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2023-012'),(SELECT psicologo_id FROM psicologos WHERE dni='87654321'),'2024-07-01','14:00:00',3,'EVALUACION',     'PRESENCIAL',60,'Evaluacion emocional de ambos miembros',    'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2025-013'),(SELECT psicologo_id FROM psicologos WHERE dni='65432109'),'2025-12-20','16:00:00',1,'ANAMNESIS',      'ONLINE',    50,'Historia neuropsicologica completa',        'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2025-013'),(SELECT psicologo_id FROM psicologos WHERE dni='65432109'),'2026-01-10','16:00:00',2,'TRATAMIENTO',    'ONLINE',    50,'Intervencion neuropsicologica',             'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2025-013'),(SELECT psicologo_id FROM psicologos WHERE dni='65432109'),'2026-02-07','16:00:00',3,'CIERRE',         'ONLINE',    50,'Cierre y alta del proceso',                'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2021-014'),(SELECT psicologo_id FROM psicologos WHERE dni='98765432'),'2024-07-10','09:00:00',1,'MOTIVO_CONSULTA','HIBRIDA',   60,'Duelo prolongado, aislamiento social',      'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2021-014'),(SELECT psicologo_id FROM psicologos WHERE dni='98765432'),'2024-07-24','09:00:00',2,'EVALUACION',     'HIBRIDA',   60,'Evaluacion del proceso de duelo',           'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2021-014'),(SELECT psicologo_id FROM psicologos WHERE dni='98765432'),'2024-08-07','09:00:00',3,'TRATAMIENTO',    'HIBRIDA',   60,'Terapia de duelo fase de aceptacion',      'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2023-016'),(SELECT psicologo_id FROM psicologos WHERE dni='98765432'),'2024-08-15','11:00:00',1,'SEGUIMIENTO',    'PRESENCIAL',60,'Revision de avances terapeuticos',          'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2023-016'),(SELECT psicologo_id FROM psicologos WHERE dni='98765432'),'2024-10-15','11:00:00',2,'CIERRE',         'PRESENCIAL',60,'Cierre formal del proceso',                 'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2020-017'),(SELECT psicologo_id FROM psicologos WHERE dni='87654321'),'2024-09-05','14:00:00',1,'MOTIVO_CONSULTA','HIBRIDA',   60,'Problemas de comunicacion en pareja',       'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2020-017'),(SELECT psicologo_id FROM psicologos WHERE dni='87654321'),'2024-09-19','14:00:00',2,'ANAMNESIS',      'HIBRIDA',   60,'Historia relacional de la pareja',          'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2024-019'),(SELECT psicologo_id FROM psicologos WHERE dni='65432109'),'2024-01-25','16:00:00',1,'MOTIVO_CONSULTA','ONLINE',    50,'Dificultades de memoria y concentracion',   'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2024-019'),(SELECT psicologo_id FROM psicologos WHERE dni='65432109'),'2024-02-08','16:00:00',2,'EVALUACION',     'ONLINE',    50,'Bateria neuropsicologica TMT-A/B WAIS-IV',  'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2024-019'),(SELECT psicologo_id FROM psicologos WHERE dni='65432109'),'2024-02-22','16:00:00',3,'TRATAMIENTO',    'ONLINE',    50,'Rehabilitacion cognitiva',                 'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2024-019'),(SELECT psicologo_id FROM psicologos WHERE dni='65432109'),'2024-03-07','16:00:00',4,'TRATAMIENTO',    'ONLINE',    50,'Tecnicas de compensacion cognitiva',        'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2023-020'),(SELECT psicologo_id FROM psicologos WHERE dni='98765432'),'2024-10-05','09:00:00',1,'MOTIVO_CONSULTA','PRESENCIAL',60,'Distanciamiento emocional en pareja adulta', 'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2023-020'),(SELECT psicologo_id FROM psicologos WHERE dni='98765432'),'2024-10-19','09:00:00',2,'ANAMNESIS',      'PRESENCIAL',60,'Historia de la relacion',                   'REALIZADA'),
  ((SELECT historia_id FROM historia_clinica WHERE codigo_historia='HC-2023-020'),(SELECT psicologo_id FROM psicologos WHERE dni='98765432'),'2024-11-02','09:00:00',3,'EVALUACION',     'PRESENCIAL',60,'Evaluacion de dinamica relacional',          'CANCELADA');


-- ----------------------------------------------------------------
-- PAGOS — una fila por sesion REALIZADA
-- ----------------------------------------------------------------
INSERT INTO pagos (sesion_id, fecha_pago, monto, comprobante, metodo_pago, estado_pago)
SELECT
    s.sesion_id,
    s.fecha_sesion,
    CASE h.tipo_historial WHEN 'PAREJA' THEN 230.00 ELSE 150.00 END,
    CONCAT('COMP-', YEAR(s.fecha_sesion), '-', LPAD(s.sesion_id, 5, '0')),
    ELT((s.sesion_id MOD 5) + 1, 'EFECTIVO','YAPE','TRANSFERENCIA','TARJETA','PLIN'),
    'PAGADO'
FROM sesiones s
JOIN historia_clinica h ON s.historia_id = h.historia_id
WHERE s.estado_sesion = 'REALIZADA';


-- ----------------------------------------------------------------
-- DIAGNOSTICOS — sesiones realizadas fuera de motivo_consulta
-- ----------------------------------------------------------------
INSERT INTO diagnosticos (sesion_id, codigo_cie10, descripcion_cie10, diagnostico_clinico)
SELECT
    s.sesion_id,
    CASE h.codigo_historia
        WHEN 'HC-2020-001' THEN 'Z63.0'  WHEN 'HC-2021-002' THEN 'F41.1'
        WHEN 'HC-2023-003' THEN 'Z63.0'  WHEN 'HC-2021-004' THEN 'Z63.0'
        WHEN 'HC-2020-005' THEN 'F32.1'  WHEN 'HC-2020-006' THEN 'Z63.0'
        WHEN 'HC-2024-007' THEN 'F90.0'  WHEN 'HC-2024-008' THEN 'F43.2'
        WHEN 'HC-2021-009' THEN 'F42'    WHEN 'HC-2025-010' THEN 'F90.0'
        WHEN 'HC-2021-011' THEN 'F40.1'  WHEN 'HC-2023-012' THEN 'F43.1'
        WHEN 'HC-2025-013' THEN 'F43.2'  WHEN 'HC-2021-014' THEN 'F43.1'
        WHEN 'HC-2023-016' THEN 'F41.1'  WHEN 'HC-2020-017' THEN 'Z63.0'
        WHEN 'HC-2024-019' THEN 'F06.7'  WHEN 'HC-2023-020' THEN 'Z63.0'
        ELSE 'F99'
    END,
    CASE h.codigo_historia
        WHEN 'HC-2020-001' THEN 'Problemas en la relacion de pareja'
        WHEN 'HC-2021-002' THEN 'Trastorno de ansiedad generalizada'
        WHEN 'HC-2023-003' THEN 'Problemas en la relacion de pareja'
        WHEN 'HC-2021-004' THEN 'Problemas en la relacion de pareja'
        WHEN 'HC-2020-005' THEN 'Episodio depresivo moderado'
        WHEN 'HC-2020-006' THEN 'Problemas en la relacion de pareja'
        WHEN 'HC-2024-007' THEN 'Trastorno por deficit de atencion con hiperactividad'
        WHEN 'HC-2024-008' THEN 'Trastorno de adaptacion - sindrome de burnout'
        WHEN 'HC-2021-009' THEN 'Trastorno obsesivo-compulsivo'
        WHEN 'HC-2025-010' THEN 'Trastorno por deficit de atencion con hiperactividad'
        WHEN 'HC-2021-011' THEN 'Fobia social'
        WHEN 'HC-2023-012' THEN 'Trastorno de estres postraumatico'
        WHEN 'HC-2025-013' THEN 'Trastorno de adaptacion'
        WHEN 'HC-2021-014' THEN 'Reaccion de duelo complicado'
        WHEN 'HC-2023-016' THEN 'Trastorno de ansiedad generalizada'
        WHEN 'HC-2020-017' THEN 'Problemas en la relacion de pareja'
        WHEN 'HC-2024-019' THEN 'Trastorno cognitivo leve'
        WHEN 'HC-2023-020' THEN 'Problemas en la relacion de pareja'
        ELSE 'Sin diagnostico registrado'
    END,
    CONCAT('Diagnostico confirmado tras evaluacion clinica. Historia: ', h.codigo_historia)
FROM sesiones s
JOIN historia_clinica h ON s.historia_id = h.historia_id
WHERE s.estado_sesion  = 'REALIZADA'
  AND s.etapa_atencion != 'MOTIVO_CONSULTA';


-- ----------------------------------------------------------------
-- EVALUACIONES PSICOLOGICAS — solo etapa EVALUACION
-- ----------------------------------------------------------------
INSERT INTO evaluacion_psicologica (sesion_id, metodos_aplicados, resultados,
  puntaje_cdi, puntaje_stai, fecha_evaluacion)
SELECT
    s.sesion_id,
    CASE h.codigo_historia
        WHEN 'HC-2021-002' THEN 'STAI-E/R, BAI, Entrevista estructurada'
        WHEN 'HC-2020-005' THEN 'CDI-2, BDI-II, Entrevista semiestructurada'
        WHEN 'HC-2024-008' THEN 'STAI-E/R, MBI-GS, Entrevista clinica'
        WHEN 'HC-2021-009' THEN 'Y-BOCS, OCI-R, Entrevista diagnostica'
        WHEN 'HC-2025-010' THEN 'CAARS, CPT-3, Entrevista diagnostica TDAH'
        WHEN 'HC-2021-011' THEN 'SPIN, LSAS, Entrevista estructurada'
        WHEN 'HC-2023-012' THEN 'Escala de impacto del trauma, Entrevista de pareja'
        WHEN 'HC-2021-014' THEN 'ICG, Escala de duelo de Texas'
        WHEN 'HC-2024-019' THEN 'TMT-A/B, WAIS-IV, CVLT-II'
        ELSE 'Entrevista clinica estructurada, Observacion conductual'
    END,
    'Evaluacion completada. Resultados congruentes con la presentacion clinica.',
    CASE h.codigo_historia
        WHEN 'HC-2020-005' THEN 29.50
        WHEN 'HC-2021-011' THEN 8.00
        ELSE NULL
    END,
    CASE h.codigo_historia
        WHEN 'HC-2021-002' THEN 61.20
        WHEN 'HC-2024-008' THEN 58.40
        WHEN 'HC-2021-011' THEN 55.30
        ELSE NULL
    END,
    s.fecha_sesion
FROM sesiones s
JOIN historia_clinica h ON s.historia_id = h.historia_id
WHERE s.etapa_atencion = 'EVALUACION'
  AND s.estado_sesion  = 'REALIZADA';


-- ----------------------------------------------------------------
-- PLANES DE INTERVENCION — solo etapa TRATAMIENTO
-- ----------------------------------------------------------------
INSERT INTO plan_intervencion (sesion_id, objetivos, intervenciones,
  recomendaciones, fecha_inicio, fecha_fin, estado_plan)
SELECT
    s.sesion_id,
    CASE h.codigo_historia
        WHEN 'HC-2021-002' THEN 'Reducir sintomas de ansiedad; mejorar calidad del sueno'
        WHEN 'HC-2020-005' THEN 'Remision del episodio depresivo; recuperar funcionamiento cotidiano'
        WHEN 'HC-2021-011' THEN 'Reducir evitacion social; mejorar habilidades de comunicacion'
        WHEN 'HC-2025-013' THEN 'Compensar deficits neuropsicologicos; mejorar autonomia funcional'
        WHEN 'HC-2021-014' THEN 'Elaborar el duelo; reconectar con vida cotidiana'
        WHEN 'HC-2024-019' THEN 'Rehabilitar funciones cognitivas; tecnicas compensatorias'
        ELSE 'Objetivos terapeuticos individualizados definidos en sesion'
    END,
    CASE h.codigo_historia
        WHEN 'HC-2021-002' THEN 'TCC; psicoeducacion; tecnicas de relajacion y respiracion'
        WHEN 'HC-2020-005' THEN 'Activacion conductual; registro de pensamientos; reestructuracion cognitiva'
        WHEN 'HC-2021-011' THEN 'Exposicion gradual; modelado; entrenamiento en habilidades sociales'
        WHEN 'HC-2025-013' THEN 'Rehabilitacion neuropsicologica; compensacion de memoria y atencion'
        WHEN 'HC-2021-014' THEN 'Terapia de duelo; integracion narrativa; apoyo emocional'
        WHEN 'HC-2024-019' THEN 'Estimulacion cognitiva; tecnicas de memoria; entrenamiento en compensacion'
        ELSE 'Intervencion psicoterapeutica individualizada basada en evidencia'
    END,
    'Mantener adherencia; registros entre sesiones; apoyo de red de soporte',
    s.fecha_sesion,
    DATE_ADD(s.fecha_sesion, INTERVAL 3 MONTH),
    CASE h.estado_historia
        WHEN 'CERRADA'    THEN 'COMPLETADO'
        WHEN 'SUSPENDIDA' THEN 'SUSPENDIDO'
        ELSE 'ACTIVO'
    END
FROM sesiones s
JOIN historia_clinica h ON s.historia_id = h.historia_id
WHERE s.etapa_atencion = 'TRATAMIENTO'
  AND s.estado_sesion  = 'REALIZADA';


SET FOREIGN_KEY_CHECKS = 1;
