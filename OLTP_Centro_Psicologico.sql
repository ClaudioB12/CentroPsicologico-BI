-- ================================================================
--  OLTP — CENTRO PSICOLÓGICO INTEGRAL GUEVARA
--  Base Transaccional (datos en bruto)
--  Extraído del Datamart v1.0 | Abril 2026
-- ================================================================

SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';

CREATE DATABASE IF NOT EXISTS oltp_centro_psicologico
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE oltp_centro_psicologico;

-- ================================================================
--  ESTRUCTURA DE TABLAS OLTP
-- ================================================================

DROP TABLE IF EXISTS oltp_sesiones;
DROP TABLE IF EXISTS oltp_pacientes;
DROP TABLE IF EXISTS oltp_psicologos;
DROP TABLE IF EXISTS oltp_sedes;

CREATE TABLE oltp_sedes (
  sede_id        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre_sede    VARCHAR(120) NOT NULL,
  ciudad         VARCHAR(80),
  tiene_online   TINYINT(1) DEFAULT 0,
  estado         ENUM('ACTIVA','INACTIVA') DEFAULT 'ACTIVA'
) ENGINE=InnoDB;

CREATE TABLE oltp_psicologos (
  psicologo_id  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  dni           VARCHAR(15)  NOT NULL UNIQUE,
  nombres       VARCHAR(120) NOT NULL,
  especialidad  VARCHAR(120),
  cpp           VARCHAR(20),
  modalidad     ENUM('PRESENCIAL','ONLINE','AMBAS') DEFAULT 'AMBAS',
  sede_id       INT UNSIGNED,
  estado        ENUM('ACTIVO','INACTIVO') DEFAULT 'ACTIVO',
  FOREIGN KEY (sede_id) REFERENCES oltp_sedes(sede_id)
) ENGINE=InnoDB;

CREATE TABLE oltp_pacientes (
  paciente_id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  codigo_historia     VARCHAR(30)  NOT NULL UNIQUE,
  tipo_historial      ENUM('INDIVIDUAL','PAREJA') NOT NULL,
  nombres             VARCHAR(80)  NOT NULL,
  apellido_paterno    VARCHAR(60),
  apellido_materno    VARCHAR(60),
  numero_documento    VARCHAR(15)  NOT NULL UNIQUE,
  fecha_nacimiento    DATE,
  sexo                ENUM('MASCULINO','FEMENINO','OTRO'),
  estado_civil        VARCHAR(30),
  grado_instruccion   VARCHAR(40),
  ocupacion           VARCHAR(80),
  ciudad              VARCHAR(80),
  contacto_celular    VARCHAR(15),
  email               VARCHAR(120),
  fecha_ingreso       DATE,
  canal_captacion     VARCHAR(60),
  estado_paciente     ENUM('EN_TRATAMIENTO','ALTA','ABANDONO','EVALUACION'),
  modalidad_preferida ENUM('PRESENCIAL','ONLINE','HIBRIDA'),
  sede_id             INT UNSIGNED,
  FOREIGN KEY (sede_id) REFERENCES oltp_sedes(sede_id)
) ENGINE=InnoDB;

CREATE TABLE oltp_sesiones (
  sesion_id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  codigo_historia     VARCHAR(30) NOT NULL,
  paciente_id         INT UNSIGNED,
  psicologo_id        INT UNSIGNED,
  nro_sesion          SMALLINT UNSIGNED,
  fecha_sesion        DATE NOT NULL,
  tipo_historial      ENUM('INDIVIDUAL','PAREJA'),
  etapa_atencion      VARCHAR(30),
  modalidad           ENUM('PRESENCIAL','ONLINE','HIBRIDA'),
  duracion_min        SMALLINT UNSIGNED,
  estado_sesion       ENUM('REALIZADA','CANCELADA','NO_SHOW'),
  monto_sesion        DECIMAL(8,2) DEFAULT 0,
  estado_pago         ENUM('PAGADO','PENDIENTE','EXONERADO'),
  metodo_pago         VARCHAR(20),
  codigo_cie10        VARCHAR(10),
  descripcion_cie10   VARCHAR(200),
  FOREIGN KEY (paciente_id)  REFERENCES oltp_pacientes(paciente_id),
  FOREIGN KEY (psicologo_id) REFERENCES oltp_psicologos(psicologo_id)
) ENGINE=InnoDB;


-- ================================================================
--  DATOS OLTP — SEDES
-- ================================================================

INSERT INTO oltp_sedes (nombre_sede, ciudad, tiene_online, estado) VALUES
  ('Sede Central Juliaca', 'Juliaca', 1, 'ACTIVA'),
  ('Sede Online',          'Virtual', 1, 'ACTIVA');


-- ================================================================
--  DATOS OLTP — PSICÓLOGOS
-- ================================================================

INSERT INTO oltp_psicologos (dni, nombres, especialidad, cpp, modalidad, sede_id) VALUES
  ('98765432','Dr. García López',    'Psicología Clínica',   'CPP-12345','AMBAS',      1),
  ('87654321','Lic. Mamani Flores',  'Psicología de Pareja', 'CPP-23456','AMBAS',      1),
  ('76543210','Dra. Quispe Condori', 'Psicología Infantil',  'CPP-34567','PRESENCIAL', 1),
  ('65432109','Mg. Torres Huanca',   'Neuropsicología',      'CPP-45678','ONLINE',     2);


-- ================================================================
--  DATOS OLTP — PACIENTES (100 registros)
-- ================================================================

INSERT INTO oltp_pacientes (codigo_historia, tipo_historial, nombres, apellido_paterno,
  apellido_materno, numero_documento, fecha_nacimiento, sexo, estado_civil,
  grado_instruccion, ocupacion, ciudad, contacto_celular, email,
  fecha_ingreso, estado_paciente, modalidad_preferida, sede_id) VALUES
  ('HC-2020-001', 'PAREJA', 'Carlos', 'Cruz', 'Ramos', '39958838', '1953-12-04', 'MASCULINO', 'DIVORCIADO', 'SUPERIOR_INCOMPLETO', 'Comerciante', 'Moquegua', '913718431', 'carlos54@gmail.com', '2020-10-29', 'EVALUACION', 'PRESENCIAL', 1),
  ('HC-2021-002', 'INDIVIDUAL', 'Roberto', 'Huanca', 'Vargas', '47308985', '1974-11-27', 'MASCULINO', 'DIVORCIADO', 'PRIMARIA_COMPLETA', 'Técnico/a', 'Lima', '921931511', 'roberto97@gmail.com', '2021-07-09', 'EN_TRATAMIENTO', 'ONLINE', 1),
  ('HC-2023-003', 'PAREJA', 'Gloria', 'Mendoza', 'Luque', '63606628', '1968-04-05', 'FEMENINO', 'DIVORCIADO', 'PRIMARIA_COMPLETA', 'Ingeniero/a', 'Cusco', '960897765', 'gloria74@gmail.com', '2023-02-16', 'ALTA', 'ONLINE', 1),
  ('HC-2021-004', 'PAREJA', 'Diego', 'Condori', 'Catacora', '26879290', '1953-11-16', 'MASCULINO', 'CONVIVIENTE', 'SECUNDARIA_COMPLETA', 'Técnico/a', 'Ayaviri', '909528530', 'diego18@gmail.com', '2021-05-16', 'ALTA', 'HIBRIDA', 1),
  ('HC-2020-005', 'INDIVIDUAL', 'Valeria', 'Mendoza', 'Ponce', '72682989', '2000-12-02', 'FEMENINO', 'CASADO', 'SECUNDARIA_COMPLETA', 'Estudiante', 'Puno', '956623995', 'valeria19@gmail.com', '2020-07-25', 'EN_TRATAMIENTO', 'PRESENCIAL', 1),
  ('HC-2020-006', 'PAREJA', 'Rosa', 'Flores', 'Apaza', '39219319', '1948-10-24', 'FEMENINO', 'CASADO', 'PRIMARIA_INCOMPLETA', 'Técnico/a', 'Ayaviri', '988231132', 'rosa43@gmail.com', '2020-06-09', 'EVALUACION', 'HIBRIDA', 1),
  ('HC-2024-007', 'INDIVIDUAL', 'Roberto', 'Vargas', 'Apaza', '31172421', '1973-09-23', 'MASCULINO', 'CONVIVIENTE', 'SUPERIOR_INCOMPLETO', 'Ama de casa', 'Juliaca', '935496015', 'roberto44@gmail.com', '2024-11-30', 'ABANDONO', 'HIBRIDA', 1),
  ('HC-2024-008', 'INDIVIDUAL', 'Silvia', 'Mendoza', 'Catacora', '11297845', '1952-02-23', 'FEMENINO', 'CONVIVIENTE', 'SECUNDARIA_INCOMPLETA', 'Médico/a', 'Ayaviri', '941373735', 'silvia36@gmail.com', '2024-01-19', 'ABANDONO', 'ONLINE', 1),
  ('HC-2021-009', 'INDIVIDUAL', 'Ricardo', 'Quispe', 'Chuqui', '39854548', '1957-08-12', 'MASCULINO', 'VIUDO', 'SUPERIOR_COMPLETO', 'Ingeniero/a', 'Lima', '947130035', 'ricardo13@gmail.com', '2021-04-25', 'ABANDONO', 'PRESENCIAL', 1),
  ('HC-2025-010', 'INDIVIDUAL', 'Eduardo', 'Mendoza', 'Flores', '99152472', '2003-06-20', 'MASCULINO', 'DIVORCIADO', 'TECNICO_COMPLETO', 'Abogado/a', 'Azángaro', '974411983', 'eduardo96@gmail.com', '2025-03-05', 'ABANDONO', 'HIBRIDA', 1),
  ('HC-2021-011', 'INDIVIDUAL', 'Pedro', 'Torres', 'Nina', '99100953', '1985-10-11', 'MASCULINO', 'CASADO', 'SECUNDARIA_INCOMPLETA', 'Docente', 'Lima', '963771720', 'pedro63@gmail.com', '2021-12-11', 'EVALUACION', 'ONLINE', 1),
  ('HC-2023-012', 'PAREJA', 'Paola', 'Velásquez', 'Machaca', '52587010', '2005-08-20', 'FEMENINO', 'DIVORCIADO', 'SUPERIOR_COMPLETO', 'Conductor/a', 'Cusco', '920244148', 'paola18@gmail.com', '2023-10-08', 'EVALUACION', 'PRESENCIAL', 1),
  ('HC-2025-013', 'INDIVIDUAL', 'Diego', 'Chávez', 'Condori', '68496914', '1976-01-13', 'MASCULINO', 'VIUDO', 'SECUNDARIA_INCOMPLETA', 'Técnico/a', 'Arequipa', '979442503', 'diego92@gmail.com', '2025-12-14', 'ALTA', 'ONLINE', 1),
  ('HC-2021-014', 'INDIVIDUAL', 'Pedro', 'Quispe', 'Quispe', '43189803', '1957-01-20', 'MASCULINO', 'CONVIVIENTE', 'SECUNDARIA_COMPLETA', 'Agricultor/a', 'Puno', '922520277', 'pedro49@gmail.com', '2021-03-06', 'EVALUACION', 'HIBRIDA', 1),
  ('HC-2020-015', 'PAREJA', 'Laura', 'Larico', 'Larico', '11698142', '1999-07-27', 'FEMENINO', 'DIVORCIADO', 'POSGRADO', 'Estudiante', 'Puno', '945150390', 'laura72@gmail.com', '2020-08-09', 'ABANDONO', 'HIBRIDA', 1),
  ('HC-2023-016', 'INDIVIDUAL', 'David', 'Chávez', 'Vargas', '42655866', '1964-11-19', 'MASCULINO', 'VIUDO', 'SUPERIOR_COMPLETO', 'Abogado/a', 'Tacna', '941154241', 'david50@gmail.com', '2023-10-11', 'ALTA', 'PRESENCIAL', 1),
  ('HC-2020-017', 'PAREJA', 'Fernando', 'Quispe', 'Mamani', '84270583', '1963-12-05', 'MASCULINO', 'CASADO', 'SECUNDARIA_INCOMPLETA', 'Técnico/a', 'Juliaca', '933311626', 'fernando76@gmail.com', '2020-01-07', 'EVALUACION', 'HIBRIDA', 1),
  ('HC-2025-018', 'INDIVIDUAL', 'Martha', 'Ccopa', 'Apaza', '14380847', '1959-05-23', 'FEMENINO', 'DIVORCIADO', 'SECUNDARIA_COMPLETA', 'Médico/a', 'Lima', '986924061', 'martha19@gmail.com', '2025-08-21', 'ABANDONO', 'PRESENCIAL', 1),
  ('HC-2024-019', 'INDIVIDUAL', 'Roberto', 'Paredes', 'Luque', '12784407', '1993-11-27', 'MASCULINO', 'CONVIVIENTE', 'POSGRADO', 'Ingeniero/a', 'Ilave', '985199362', 'roberto54@gmail.com', '2024-01-21', 'EN_TRATAMIENTO', 'ONLINE', 1),
  ('HC-2023-020', 'PAREJA', 'Omar', 'Apaza', 'Ponce', '17275149', '1957-09-12', 'MASCULINO', 'VIUDO', 'PRIMARIA_COMPLETA', 'Estudiante', 'Azángaro', '915766039', 'omar47@gmail.com', '2023-11-17', 'EVALUACION', 'PRESENCIAL', 1),
  ('HC-2023-021', 'PAREJA', 'Diana', 'Paredes', 'Luque', '98575748', '1976-03-15', 'FEMENINO', 'VIUDO', 'PRIMARIA_INCOMPLETA', 'Comerciante', 'Arequipa', '959096899', 'diana28@gmail.com', '2023-06-26', 'ABANDONO', 'HIBRIDA', 1),
  ('HC-2022-022', 'INDIVIDUAL', 'Carmen', 'Huanca', 'Lipa', '32329103', '1989-05-01', 'FEMENINO', 'DIVORCIADO', 'TECNICO_COMPLETO', 'Comerciante', 'Tacna', '975957578', 'carmen32@gmail.com', '2022-01-29', 'ALTA', 'HIBRIDA', 1),
  ('HC-2020-023', 'PAREJA', 'Lucía', 'Cruz', 'Lipa', '50550084', '1957-07-28', 'FEMENINO', 'CASADO', 'SECUNDARIA_COMPLETA', 'Técnico/a', 'Tacna', '984322033', 'lucía66@gmail.com', '2020-05-01', 'ALTA', 'ONLINE', 1),
  ('HC-2024-024', 'INDIVIDUAL', 'Sergio', 'Condori', 'Huanca', '40281491', '2000-11-24', 'MASCULINO', 'SOLTERO', 'SUPERIOR_INCOMPLETO', 'Conductor/a', 'Moquegua', '949470729', 'sergio91@gmail.com', '2024-07-06', 'EVALUACION', 'HIBRIDA', 1),
  ('HC-2023-025', 'PAREJA', 'Luis', 'Chávez', 'Catacora', '28208520', '1969-08-12', 'MASCULINO', 'DIVORCIADO', 'PRIMARIA_INCOMPLETA', 'Médico/a', 'Azángaro', '916395999', 'luis94@gmail.com', '2023-10-28', 'ABANDONO', 'PRESENCIAL', 1),
  ('HC-2024-026', 'INDIVIDUAL', 'Patricia', 'Huanca', 'Quispe', '27690330', '1945-06-26', 'FEMENINO', 'DIVORCIADO', 'PRIMARIA_INCOMPLETA', 'Comerciante', 'Arequipa', '908530615', 'patricia67@gmail.com', '2024-06-14', 'ABANDONO', 'HIBRIDA', 1),
  ('HC-2023-027', 'INDIVIDUAL', 'Martha', 'Paredes', 'Catacora', '53645651', '1969-10-17', 'FEMENINO', 'SOLTERO', 'PRIMARIA_COMPLETA', 'Ama de casa', 'Moquegua', '960606674', 'martha68@gmail.com', '2023-09-16', 'ABANDONO', 'ONLINE', 1),
  ('HC-2022-028', 'INDIVIDUAL', 'Carmen', 'Mendoza', 'Ccopa', '99300492', '2005-07-28', 'FEMENINO', 'SOLTERO', 'SECUNDARIA_COMPLETA', 'Comerciante', 'Tacna', '914524825', 'carmen24@gmail.com', '2022-11-04', 'EVALUACION', 'HIBRIDA', 1),
  ('HC-2021-029', 'INDIVIDUAL', 'Carlos', 'Condori', 'Nina', '38874646', '1969-07-15', 'MASCULINO', 'CONVIVIENTE', 'PRIMARIA_COMPLETA', 'Docente', 'Tacna', '982924837', 'carlos66@gmail.com', '2021-07-09', 'EVALUACION', 'ONLINE', 1),
  ('HC-2022-030', 'INDIVIDUAL', 'Carlos', 'Flores', 'Apaza', '38351344', '1994-03-25', 'MASCULINO', 'VIUDO', 'TECNICO_COMPLETO', 'Comerciante', 'Juliaca', '971481992', 'carlos19@gmail.com', '2022-06-17', 'EVALUACION', 'ONLINE', 1),
  ('HC-2025-031', 'INDIVIDUAL', 'Roberto', 'Mendoza', 'Luque', '63747464', '1978-02-13', 'MASCULINO', 'CASADO', 'PRIMARIA_COMPLETA', 'Conductor/a', 'Tacna', '946892354', 'roberto23@gmail.com', '2025-06-23', 'ALTA', 'PRESENCIAL', 1),
  ('HC-2022-032', 'INDIVIDUAL', 'Andrea', 'Torres', 'Condori', '89379016', '1948-06-17', 'FEMENINO', 'SOLTERO', 'SUPERIOR_COMPLETO', 'Ingeniero/a', 'Juliaca', '982545028', 'andrea84@gmail.com', '2022-08-25', 'ALTA', 'HIBRIDA', 1),
  ('HC-2020-033', 'PAREJA', 'Eduardo', 'Vargas', 'Apaza', '61998170', '1971-06-22', 'MASCULINO', 'CASADO', 'PRIMARIA_COMPLETA', 'Ingeniero/a', 'Moquegua', '917152188', 'eduardo92@gmail.com', '2020-11-19', 'EN_TRATAMIENTO', 'ONLINE', 1),
  ('HC-2021-034', 'PAREJA', 'Martha', 'López', 'Machaca', '60562485', '1954-03-06', 'FEMENINO', 'VIUDO', 'SUPERIOR_INCOMPLETO', 'Médico/a', 'Ilave', '926802975', 'martha16@gmail.com', '2021-08-13', 'EN_TRATAMIENTO', 'HIBRIDA', 1),
  ('HC-2022-035', 'INDIVIDUAL', 'Paola', 'Vargas', 'Ramos', '61830338', '1950-06-08', 'FEMENINO', 'CASADO', 'SECUNDARIA_INCOMPLETA', 'Docente', 'Tacna', '993425200', 'paola88@gmail.com', '2022-02-20', 'ALTA', 'HIBRIDA', 1),
  ('HC-2022-036', 'PAREJA', 'Raúl', 'Paredes', 'Ramos', '29270557', '1963-07-01', 'MASCULINO', 'SOLTERO', 'SUPERIOR_COMPLETO', 'Enfermero/a', 'Cusco', '998373678', 'raúl27@gmail.com', '2022-05-04', 'ALTA', 'ONLINE', 1),
  ('HC-2022-037', 'INDIVIDUAL', 'Claudia', 'Quispe', 'Cruz', '48401154', '1967-01-28', 'FEMENINO', 'VIUDO', 'POSGRADO', 'Médico/a', 'Moquegua', '966599269', 'claudia20@gmail.com', '2022-03-05', 'ALTA', 'ONLINE', 1),
  ('HC-2022-038', 'INDIVIDUAL', 'Martha', 'Mendoza', 'Condori', '95828117', '1995-01-03', 'FEMENINO', 'SOLTERO', 'SECUNDARIA_INCOMPLETA', 'Técnico/a', 'Arequipa', '916942307', 'martha59@gmail.com', '2022-09-20', 'EVALUACION', 'ONLINE', 1),
  ('HC-2022-039', 'PAREJA', 'Silvia', 'Huanca', 'Condori', '44935501', '1990-08-07', 'FEMENINO', 'DIVORCIADO', 'SECUNDARIA_COMPLETA', 'Enfermero/a', 'Arequipa', '931774192', 'silvia80@gmail.com', '2022-12-22', 'ALTA', 'PRESENCIAL', 1),
  ('HC-2020-040', 'PAREJA', 'Rosa', 'Velásquez', 'Luque', '34422678', '1994-03-14', 'FEMENINO', 'DIVORCIADO', 'PRIMARIA_COMPLETA', 'Conductor/a', 'Arequipa', '922978158', 'rosa13@gmail.com', '2020-03-04', 'ABANDONO', 'PRESENCIAL', 1),
  ('HC-2021-041', 'PAREJA', 'Ángel', 'Apaza', 'Ponce', '74995086', '1974-04-11', 'MASCULINO', 'VIUDO', 'TECNICO_COMPLETO', 'Estudiante', 'Cusco', '977535841', 'ángel73@gmail.com', '2021-06-10', 'EVALUACION', 'PRESENCIAL', 1),
  ('HC-2023-042', 'INDIVIDUAL', 'Manuel', 'López', 'Condori', '59093843', '1993-07-12', 'MASCULINO', 'CASADO', 'SUPERIOR_COMPLETO', 'Conductor/a', 'Azángaro', '951854861', 'manuel89@gmail.com', '2023-01-27', 'EN_TRATAMIENTO', 'ONLINE', 1),
  ('HC-2023-043', 'INDIVIDUAL', 'Rosa', 'Suca', 'Nina', '28761086', '1965-10-11', 'FEMENINO', 'DIVORCIADO', 'POSGRADO', 'Contador/a', 'Ayaviri', '902232974', 'rosa84@gmail.com', '2023-11-12', 'ABANDONO', 'HIBRIDA', 1),
  ('HC-2023-044', 'INDIVIDUAL', 'Carlos', 'Apaza', 'Larico', '66207740', '1954-07-23', 'MASCULINO', 'SOLTERO', 'SECUNDARIA_INCOMPLETA', 'Conductor/a', 'Ilave', '988882576', 'carlos32@gmail.com', '2023-09-14', 'ABANDONO', 'HIBRIDA', 1),
  ('HC-2021-045', 'INDIVIDUAL', 'Diana', 'Huanca', 'Luque', '82905845', '1969-07-27', 'FEMENINO', 'SOLTERO', 'SUPERIOR_COMPLETO', 'Agricultor/a', 'Cusco', '928720823', 'diana81@gmail.com', '2021-05-29', 'ALTA', 'PRESENCIAL', 1),
  ('HC-2021-046', 'PAREJA', 'David', 'Ramos', 'Apaza', '96690951', '1948-02-21', 'MASCULINO', 'CONVIVIENTE', 'POSGRADO', 'Comerciante', 'Azángaro', '925878707', 'david68@gmail.com', '2021-10-01', 'EN_TRATAMIENTO', 'ONLINE', 1),
  ('HC-2022-047', 'INDIVIDUAL', 'Sandra', 'Mamani', 'Condori', '61482483', '1960-08-25', 'FEMENINO', 'SOLTERO', 'SUPERIOR_INCOMPLETO', 'Ama de casa', 'Ayaviri', '908338186', 'sandra30@gmail.com', '2022-06-04', 'ABANDONO', 'PRESENCIAL', 1),
  ('HC-2020-048', 'INDIVIDUAL', 'Roberto', 'Suca', 'Flores', '80532309', '1973-09-23', 'MASCULINO', 'CONVIVIENTE', 'SECUNDARIA_COMPLETA', 'Técnico/a', 'Juliaca', '944039203', 'roberto97@gmail.com', '2020-10-15', 'EVALUACION', 'ONLINE', 1),
  ('HC-2020-049', 'PAREJA', 'Juan', 'Mendoza', 'Ccopa', '18557710', '1979-01-03', 'MASCULINO', 'CASADO', 'SECUNDARIA_COMPLETA', 'Docente', 'Azángaro', '962143331', 'juan78@gmail.com', '2020-05-26', 'ABANDONO', 'ONLINE', 1),
  ('HC-2021-050', 'INDIVIDUAL', 'Roberto', 'Quispe', 'Vargas', '68916591', '1959-09-07', 'MASCULINO', 'CONVIVIENTE', 'SUPERIOR_COMPLETO', 'Técnico/a', 'Lima', '940502136', 'roberto62@gmail.com', '2021-09-15', 'ALTA', 'HIBRIDA', 1),
  ('HC-2023-051', 'PAREJA', 'Sandra', 'Chávez', 'Apaza', '29374563', '1996-08-02', 'FEMENINO', 'CONVIVIENTE', 'PRIMARIA_INCOMPLETA', 'Enfermero/a', 'Ayaviri', '964343201', 'sandra11@gmail.com', '2023-08-02', 'EVALUACION', 'HIBRIDA', 1),
  ('HC-2024-052', 'INDIVIDUAL', 'Carmen', 'Ccopa', 'Larico', '37263310', '1968-06-14', 'FEMENINO', 'DIVORCIADO', 'TECNICO_COMPLETO', 'Ingeniero/a', 'Juliaca', '944273769', 'carmen73@gmail.com', '2024-04-23', 'EVALUACION', 'HIBRIDA', 1),
  ('HC-2020-053', 'INDIVIDUAL', 'Carlos', 'Mendoza', 'Huanca', '94651342', '1959-02-23', 'MASCULINO', 'DIVORCIADO', 'PRIMARIA_INCOMPLETA', 'Técnico/a', 'Ilave', '902111482', 'carlos11@gmail.com', '2020-04-21', 'ABANDONO', 'HIBRIDA', 1),
  ('HC-2025-054', 'INDIVIDUAL', 'Andrea', 'Paredes', 'Ramos', '40314047', '1964-11-27', 'FEMENINO', 'VIUDO', 'TECNICO_COMPLETO', 'Médico/a', 'Puno', '985462880', 'andrea73@gmail.com', '2025-11-29', 'EN_TRATAMIENTO', 'PRESENCIAL', 1),
  ('HC-2025-055', 'INDIVIDUAL', 'Ricardo', 'Condori', 'Apaza', '31803703', '1981-04-19', 'MASCULINO', 'CASADO', 'PRIMARIA_COMPLETA', 'Conductor/a', 'Moquegua', '913111164', 'ricardo87@gmail.com', '2025-10-04', 'ABANDONO', 'HIBRIDA', 1),
  ('HC-2022-056', 'INDIVIDUAL', 'Pedro', 'Cruz', 'Huanca', '61002735', '1990-11-05', 'MASCULINO', 'SOLTERO', 'SUPERIOR_INCOMPLETO', 'Agricultor/a', 'Puno', '913721268', 'pedro67@gmail.com', '2022-07-04', 'EN_TRATAMIENTO', 'PRESENCIAL', 1),
  ('HC-2020-057', 'INDIVIDUAL', 'Ricardo', 'García', 'Huanca', '46093692', '1964-05-16', 'MASCULINO', 'VIUDO', 'SUPERIOR_INCOMPLETO', 'Agricultor/a', 'Cusco', '933782566', 'ricardo68@gmail.com', '2020-03-26', 'EVALUACION', 'HIBRIDA', 1),
  ('HC-2022-058', 'INDIVIDUAL', 'Diana', 'Ccopa', 'Luque', '42537638', '1965-07-09', 'FEMENINO', 'CONVIVIENTE', 'SECUNDARIA_INCOMPLETA', 'Ama de casa', 'Lima', '995075416', 'diana62@gmail.com', '2022-02-28', 'ABANDONO', 'ONLINE', 1),
  ('HC-2025-059', 'PAREJA', 'Luis', 'Chávez', 'Ccopa', '32325574', '1986-10-02', 'MASCULINO', 'CASADO', 'SUPERIOR_COMPLETO', 'Docente', 'Azángaro', '939652241', 'luis28@gmail.com', '2025-12-13', 'ALTA', 'ONLINE', 1),
  ('HC-2023-060', 'INDIVIDUAL', 'Roberto', 'Larico', 'García', '84076145', '1955-06-18', 'MASCULINO', 'CASADO', 'TECNICO_COMPLETO', 'Médico/a', 'Arequipa', '960340936', 'roberto37@gmail.com', '2023-04-29', 'EN_TRATAMIENTO', 'PRESENCIAL', 1),
  ('HC-2024-061', 'INDIVIDUAL', 'Eduardo', 'Vargas', 'Lipa', '92861016', '1956-11-23', 'MASCULINO', 'DIVORCIADO', 'PRIMARIA_COMPLETA', 'Estudiante', 'Arequipa', '924567819', 'eduardo63@gmail.com', '2024-10-29', 'EVALUACION', 'ONLINE', 1),
  ('HC-2023-062', 'PAREJA', 'Silvia', 'Larico', 'Chuqui', '64913082', '1988-08-14', 'FEMENINO', 'CONVIVIENTE', 'PRIMARIA_INCOMPLETA', 'Contador/a', 'Tacna', '957063296', 'silvia14@gmail.com', '2023-03-27', 'EN_TRATAMIENTO', 'PRESENCIAL', 1),
  ('HC-2022-063', 'PAREJA', 'Martha', 'Velásquez', 'García', '53440052', '1990-05-10', 'FEMENINO', 'CONVIVIENTE', 'SUPERIOR_INCOMPLETO', 'Ama de casa', 'Arequipa', '960665302', 'martha75@gmail.com', '2022-09-21', 'EVALUACION', 'ONLINE', 1),
  ('HC-2025-064', 'INDIVIDUAL', 'Gabriela', 'Velásquez', 'Luque', '27528063', '1981-08-26', 'FEMENINO', 'VIUDO', 'PRIMARIA_INCOMPLETA', 'Enfermero/a', 'Puno', '961272827', 'gabriela98@gmail.com', '2025-01-25', 'ABANDONO', 'HIBRIDA', 1),
  ('HC-2025-065', 'PAREJA', 'Carlos', 'Flores', 'Chuqui', '20460758', '1953-10-08', 'MASCULINO', 'CASADO', 'PRIMARIA_COMPLETA', 'Conductor/a', 'Arequipa', '959069144', 'carlos62@gmail.com', '2025-08-16', 'EN_TRATAMIENTO', 'PRESENCIAL', 1),
  ('HC-2022-066', 'INDIVIDUAL', 'María', 'Torres', 'Cruz', '79491111', '1983-09-07', 'FEMENINO', 'VIUDO', 'TECNICO_COMPLETO', 'Enfermero/a', 'Lima', '985641960', 'maría56@gmail.com', '2022-11-27', 'EVALUACION', 'HIBRIDA', 1),
  ('HC-2022-067', 'INDIVIDUAL', 'Lucía', 'Gutierrez', 'Flores', '95971459', '1979-09-20', 'FEMENINO', 'CONVIVIENTE', 'SECUNDARIA_COMPLETA', 'Comerciante', 'Puno', '978710263', 'lucía99@gmail.com', '2022-02-12', 'EN_TRATAMIENTO', 'PRESENCIAL', 1),
  ('HC-2022-068', 'INDIVIDUAL', 'Patricia', 'Vargas', 'Huanca', '46072958', '1991-02-25', 'FEMENINO', 'SOLTERO', 'SUPERIOR_INCOMPLETO', 'Contador/a', 'Azángaro', '961095611', 'patricia82@gmail.com', '2022-08-08', 'EN_TRATAMIENTO', 'HIBRIDA', 1),
  ('HC-2020-069', 'INDIVIDUAL', 'Sandra', 'Ramos', 'Ramos', '65869014', '2003-12-11', 'FEMENINO', 'CONVIVIENTE', 'PRIMARIA_INCOMPLETA', 'Comerciante', 'Puno', '953811222', 'sandra49@gmail.com', '2020-10-19', 'EN_TRATAMIENTO', 'PRESENCIAL', 1),
  ('HC-2020-070', 'INDIVIDUAL', 'Roberto', 'Velásquez', 'Ccopa', '95354668', '1998-12-01', 'MASCULINO', 'SOLTERO', 'SECUNDARIA_COMPLETA', 'Conductor/a', 'Cusco', '966038997', 'roberto21@gmail.com', '2020-12-02', 'EVALUACION', 'ONLINE', 1),
  ('HC-2021-071', 'INDIVIDUAL', 'Sofía', 'Ramos', 'Larico', '70768130', '1962-04-03', 'FEMENINO', 'SOLTERO', 'SECUNDARIA_INCOMPLETA', 'Agricultor/a', 'Arequipa', '954561191', 'sofía67@gmail.com', '2021-10-27', 'EN_TRATAMIENTO', 'PRESENCIAL', 1),
  ('HC-2021-072', 'INDIVIDUAL', 'Ricardo', 'Apaza', 'Catacora', '83835976', '1960-02-15', 'MASCULINO', 'CASADO', 'SECUNDARIA_INCOMPLETA', 'Estudiante', 'Juliaca', '992111648', 'ricardo19@gmail.com', '2021-03-04', 'EVALUACION', 'PRESENCIAL', 1),
  ('HC-2021-073', 'PAREJA', 'Fernando', 'Cruz', 'Lipa', '29948970', '1947-10-20', 'MASCULINO', 'CONVIVIENTE', 'POSGRADO', 'Abogado/a', 'Ilave', '936297263', 'fernando13@gmail.com', '2021-11-28', 'ABANDONO', 'PRESENCIAL', 1),
  ('HC-2024-074', 'INDIVIDUAL', 'Valeria', 'Paredes', 'Quispe', '57201978', '2005-10-19', 'FEMENINO', 'DIVORCIADO', 'SECUNDARIA_INCOMPLETA', 'Agricultor/a', 'Azángaro', '907538738', 'valeria77@gmail.com', '2024-04-06', 'ALTA', 'ONLINE', 1),
  ('HC-2025-075', 'PAREJA', 'Andrés', 'Torres', 'Larico', '28314232', '1955-12-14', 'MASCULINO', 'DIVORCIADO', 'SECUNDARIA_COMPLETA', 'Ama de casa', 'Ayaviri', '918876833', 'andrés54@gmail.com', '2025-06-12', 'ABANDONO', 'PRESENCIAL', 1),
  ('HC-2021-076', 'INDIVIDUAL', 'Silvia', 'Gutierrez', 'Torres', '74355957', '1995-10-21', 'FEMENINO', 'DIVORCIADO', 'PRIMARIA_INCOMPLETA', 'Abogado/a', 'Juliaca', '909959009', 'silvia19@gmail.com', '2021-08-20', 'EVALUACION', 'PRESENCIAL', 1),
  ('HC-2021-077', 'PAREJA', 'Sandra', 'Huanca', 'Mamani', '62734442', '1981-09-27', 'FEMENINO', 'DIVORCIADO', 'TECNICO_COMPLETO', 'Agricultor/a', 'Puno', '912232184', 'sandra57@gmail.com', '2021-01-28', 'EN_TRATAMIENTO', 'ONLINE', 1),
  ('HC-2023-078', 'INDIVIDUAL', 'Ricardo', 'Larico', 'Ponce', '81875527', '1988-08-19', 'MASCULINO', 'SOLTERO', 'SECUNDARIA_INCOMPLETA', 'Enfermero/a', 'Moquegua', '922436477', 'ricardo15@gmail.com', '2023-06-03', 'ALTA', 'PRESENCIAL', 1),
  ('HC-2020-079', 'INDIVIDUAL', 'Carmen', 'Mendoza', 'Huanca', '29891032', '1981-10-19', 'FEMENINO', 'CONVIVIENTE', 'SUPERIOR_COMPLETO', 'Médico/a', 'Cusco', '987884113', 'carmen32@gmail.com', '2020-10-15', 'EVALUACION', 'ONLINE', 1),
  ('HC-2021-080', 'PAREJA', 'Gabriela', 'Cruz', 'Ponce', '91198924', '1986-02-07', 'FEMENINO', 'SOLTERO', 'SUPERIOR_COMPLETO', 'Contador/a', 'Ilave', '949439358', 'gabriela91@gmail.com', '2021-07-28', 'EVALUACION', 'ONLINE', 1),
  ('HC-2025-081', 'INDIVIDUAL', 'Roberto', 'Chávez', 'Cruz', '46115786', '1986-07-17', 'MASCULINO', 'CASADO', 'PRIMARIA_INCOMPLETA', 'Estudiante', 'Arequipa', '995662408', 'roberto58@gmail.com', '2025-01-05', 'EVALUACION', 'HIBRIDA', 1),
  ('HC-2021-082', 'INDIVIDUAL', 'Claudia', 'Ramos', 'Condori', '45050544', '1986-12-21', 'FEMENINO', 'SOLTERO', 'TECNICO_COMPLETO', 'Ama de casa', 'Lima', '996808992', 'claudia43@gmail.com', '2021-03-18', 'EN_TRATAMIENTO', 'HIBRIDA', 1),
  ('HC-2021-083', 'INDIVIDUAL', 'Fernando', 'Velásquez', 'García', '55047826', '1986-02-08', 'MASCULINO', 'DIVORCIADO', 'SUPERIOR_INCOMPLETO', 'Técnico/a', 'Tacna', '915808361', 'fernando70@gmail.com', '2021-06-07', 'EVALUACION', 'ONLINE', 1),
  ('HC-2024-084', 'INDIVIDUAL', 'Andrés', 'Quispe', 'Quispe', '70673557', '1962-04-25', 'MASCULINO', 'CASADO', 'TECNICO_COMPLETO', 'Ama de casa', 'Puno', '957582820', 'andrés14@gmail.com', '2024-03-22', 'EN_TRATAMIENTO', 'HIBRIDA', 1),
  ('HC-2022-085', 'PAREJA', 'Juan', 'Torres', 'Apaza', '71193393', '1991-09-20', 'MASCULINO', 'CASADO', 'PRIMARIA_COMPLETA', 'Abogado/a', 'Azángaro', '985942441', 'juan86@gmail.com', '2022-08-11', 'EN_TRATAMIENTO', 'HIBRIDA', 1),
  ('HC-2020-086', 'PAREJA', 'Martha', 'Suca', 'Huanca', '66213840', '1998-02-17', 'FEMENINO', 'VIUDO', 'SUPERIOR_COMPLETO', 'Estudiante', 'Lima', '990145073', 'martha29@gmail.com', '2020-05-24', 'EN_TRATAMIENTO', 'HIBRIDA', 1),
  ('HC-2023-087', 'INDIVIDUAL', 'Juan', 'Mamani', 'Huanca', '99034004', '1986-03-11', 'MASCULINO', 'DIVORCIADO', 'SUPERIOR_COMPLETO', 'Comerciante', 'Puno', '953720675', 'juan98@gmail.com', '2023-11-15', 'ALTA', 'PRESENCIAL', 1),
  ('HC-2025-088', 'INDIVIDUAL', 'Diego', 'Ccopa', 'Torres', '65201639', '1973-01-03', 'MASCULINO', 'CONVIVIENTE', 'SECUNDARIA_COMPLETA', 'Ama de casa', 'Azángaro', '958095862', 'diego54@gmail.com', '2025-06-10', 'EN_TRATAMIENTO', 'HIBRIDA', 1),
  ('HC-2023-089', 'INDIVIDUAL', 'Sofía', 'Chávez', 'Flores', '71618633', '1973-10-15', 'FEMENINO', 'VIUDO', 'PRIMARIA_INCOMPLETA', 'Enfermero/a', 'Puno', '904809280', 'sofía87@gmail.com', '2023-08-17', 'ALTA', 'HIBRIDA', 1),
  ('HC-2024-090', 'INDIVIDUAL', 'Carmen', 'Huanca', 'Ramos', '10294869', '1966-06-27', 'FEMENINO', 'SOLTERO', 'SECUNDARIA_INCOMPLETA', 'Agricultor/a', 'Puno', '914356130', 'carmen25@gmail.com', '2024-09-24', 'ALTA', 'ONLINE', 1),
  ('HC-2025-091', 'INDIVIDUAL', 'Omar', 'Mendoza', 'Luque', '74818030', '2004-09-25', 'MASCULINO', 'SOLTERO', 'TECNICO_COMPLETO', 'Ama de casa', 'Arequipa', '956192230', 'omar60@gmail.com', '2025-10-24', 'ALTA', 'ONLINE', 1),
  ('HC-2025-092', 'INDIVIDUAL', 'Carmen', 'Vargas', 'Catacora', '74474159', '1982-10-22', 'FEMENINO', 'SOLTERO', 'PRIMARIA_COMPLETA', 'Docente', 'Moquegua', '907122263', 'carmen30@gmail.com', '2025-10-01', 'EN_TRATAMIENTO', 'ONLINE', 1),
  ('HC-2020-093', 'PAREJA', 'Ana', 'Gutierrez', 'Vargas', '65910573', '1995-11-11', 'FEMENINO', 'CASADO', 'SECUNDARIA_INCOMPLETA', 'Contador/a', 'Puno', '905453834', 'ana26@gmail.com', '2020-01-07', 'EN_TRATAMIENTO', 'ONLINE', 1),
  ('HC-2024-094', 'INDIVIDUAL', 'Paola', 'Chávez', 'García', '79874593', '1949-09-06', 'FEMENINO', 'DIVORCIADO', 'SECUNDARIA_COMPLETA', 'Estudiante', 'Puno', '948425464', 'paola81@gmail.com', '2024-10-01', 'ABANDONO', 'PRESENCIAL', 1),
  ('HC-2020-095', 'INDIVIDUAL', 'Natalia', 'Quispe', 'Apaza', '97446634', '1957-06-17', 'FEMENINO', 'SOLTERO', 'PRIMARIA_COMPLETA', 'Estudiante', 'Azángaro', '913948820', 'natalia97@gmail.com', '2020-03-26', 'ABANDONO', 'PRESENCIAL', 1),
  ('HC-2020-096', 'PAREJA', 'Carmen', 'Velásquez', 'Quispe', '96090303', '1991-10-03', 'FEMENINO', 'VIUDO', 'SUPERIOR_INCOMPLETO', 'Ama de casa', 'Arequipa', '990904196', 'carmen80@gmail.com', '2020-12-24', 'EN_TRATAMIENTO', 'HIBRIDA', 1),
  ('HC-2023-097', 'PAREJA', 'Elena', 'Huanca', 'García', '86140729', '1999-01-28', 'FEMENINO', 'DIVORCIADO', 'POSGRADO', 'Agricultor/a', 'Lima', '993074374', 'elena50@gmail.com', '2023-11-27', 'ALTA', 'HIBRIDA', 1),
  ('HC-2025-098', 'INDIVIDUAL', 'Fernando', 'López', 'Catacora', '36364647', '1961-12-21', 'MASCULINO', 'SOLTERO', 'TECNICO_COMPLETO', 'Técnico/a', 'Azángaro', '974033693', 'fernando93@gmail.com', '2025-02-08', 'ABANDONO', 'ONLINE', 1),
  ('HC-2022-099', 'INDIVIDUAL', 'Diego', 'Vargas', 'Mamani', '39369404', '1993-08-08', 'MASCULINO', 'CASADO', 'SUPERIOR_COMPLETO', 'Médico/a', 'Juliaca', '906232730', 'diego76@gmail.com', '2022-07-09', 'ABANDONO', 'HIBRIDA', 1),
  ('HC-2021-100', 'INDIVIDUAL', 'Natalia', 'Suca', 'Quispe', '77355419', '2001-03-15', 'FEMENINO', 'CASADO', 'SECUNDARIA_INCOMPLETA', 'Comerciante', 'Cusco', '980801793', 'natalia63@gmail.com', '2021-02-09', 'EVALUACION', 'PRESENCIAL', 1);


-- ================================================================
--  DATOS OLTP — SESIONES (100 registros)
-- ================================================================

INSERT INTO oltp_sesiones (codigo_historia, paciente_id, psicologo_id, nro_sesion,
  fecha_sesion, tipo_historial, etapa_atencion, modalidad, duracion_min,
  estado_sesion, monto_sesion, estado_pago, metodo_pago,
  codigo_cie10, descripcion_cie10) VALUES
  ('EXT-2025-018', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='EXT-2025-018' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='98765432' LIMIT 1), 7, '2025-01-28', 'PAREJA', 'MOTIVO_CONSULTA', 'HIBRIDA', 50, 'NO_SHOW', 0.0, 'EXONERADO', NULL, 'F43.1', 'Trastorno de estrés postraumático'),
  ('HC-2024-052', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2024-052' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='76543210' LIMIT 1), 12, '2025-11-16', 'INDIVIDUAL', 'EVALUACION', 'PRESENCIAL', 50, 'REALIZADA', 150.0, 'PAGADO', 'YAPE', 'F40.1', 'Fobia social'),
  ('EXT-2025-006', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='EXT-2025-006' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='76543210' LIMIT 1), 22, '2025-07-04', 'INDIVIDUAL', 'TRATAMIENTO', 'HIBRIDA', 45, 'CANCELADA', 0.0, 'EXONERADO', NULL, 'F43.2', 'Trastorno de adaptación'),
  ('EXT-2022-009', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='EXT-2022-009' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='98765432' LIMIT 1), 6, '2025-12-18', 'PAREJA', 'SEGUIMIENTO', 'HIBRIDA', 50, 'CANCELADA', 0.0, 'PENDIENTE', NULL, 'F32.1', 'Episodio depresivo moderado'),
  ('HC-2023-020', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2023-020' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='98765432' LIMIT 1), 16, '2024-05-02', 'PAREJA', 'ANAMNESIS', 'HIBRIDA', 60, 'NO_SHOW', 0.0, 'EXONERADO', NULL, 'F43.2', 'Trastorno de adaptación'),
  ('HC-2023-051', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2023-051' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='87654321' LIMIT 1), 9, '2025-04-13', 'PAREJA', 'ANAMNESIS', 'ONLINE', 90, 'NO_SHOW', 0.0, 'EXONERADO', NULL, 'F32.1', 'Episodio depresivo moderado'),
  ('HC-2024-052', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2024-052' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='76543210' LIMIT 1), 28, '2025-04-06', 'INDIVIDUAL', 'TRATAMIENTO', 'PRESENCIAL', 50, 'REALIZADA', 150.0, 'PAGADO', 'TARJETA', 'F43.1', 'Trastorno de estrés postraumático'),
  ('EXT-2020-013', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='EXT-2020-013' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='98765432' LIMIT 1), 24, '2025-02-11', 'INDIVIDUAL', 'EVALUACION', 'ONLINE', 60, 'REALIZADA', 150.0, 'PAGADO', 'TARJETA', 'F43.1', 'Trastorno de estrés postraumático'),
  ('EXT-2022-003', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='EXT-2022-003' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='65432109' LIMIT 1), 6, '2024-03-21', 'PAREJA', 'EVALUACION', 'PRESENCIAL', 60, 'REALIZADA', 150.0, 'PAGADO', 'PLIN', 'F90.0', 'TDAH'),
  ('HC-2023-003', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2023-003' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='87654321' LIMIT 1), 17, '2024-08-28', 'PAREJA', 'MOTIVO_CONSULTA', 'PRESENCIAL', 60, 'REALIZADA', 150.0, 'PAGADO', 'TARJETA', 'F32.1', 'Episodio depresivo moderado'),
  ('HC-2022-022', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2022-022' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='98765432' LIMIT 1), 5, '2024-02-05', 'INDIVIDUAL', 'SEGUIMIENTO', 'HIBRIDA', 50, 'REALIZADA', 150.0, 'PAGADO', 'TRANSFERENCIA', 'F90.0', 'TDAH'),
  ('HC-2021-034', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2021-034' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='87654321' LIMIT 1), 20, '2024-11-06', 'PAREJA', 'ANAMNESIS', 'PRESENCIAL', 60, 'REALIZADA', 230.0, 'PAGADO', 'YAPE', 'F43.2', 'Trastorno de adaptación'),
  ('HC-2025-055', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2025-055' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='87654321' LIMIT 1), 10, '2025-06-13', 'INDIVIDUAL', 'MOTIVO_CONSULTA', 'HIBRIDA', 90, 'CANCELADA', 0.0, 'EXONERADO', NULL, 'F60.3', 'Trastorno límite de personalidad'),
  ('HC-2021-014', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2021-014' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='76543210' LIMIT 1), 11, '2024-10-02', 'INDIVIDUAL', 'TRATAMIENTO', 'ONLINE', 90, 'REALIZADA', 150.0, 'PAGADO', 'TRANSFERENCIA', 'F43.2', 'Trastorno de adaptación'),
  ('HC-2024-024', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2024-024' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='87654321' LIMIT 1), 15, '2024-09-13', 'INDIVIDUAL', 'SEGUIMIENTO', 'PRESENCIAL', 50, 'CANCELADA', 0.0, 'PENDIENTE', NULL, 'F32.1', 'Episodio depresivo moderado'),
  ('HC-2024-026', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2024-026' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='76543210' LIMIT 1), 19, '2024-02-23', 'INDIVIDUAL', 'MOTIVO_CONSULTA', 'ONLINE', 50, 'CANCELADA', 0.0, 'PENDIENTE', NULL, 'F32.1', 'Episodio depresivo moderado'),
  ('HC-2023-044', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2023-044' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='98765432' LIMIT 1), 26, '2024-03-02', 'INDIVIDUAL', 'TRATAMIENTO', 'HIBRIDA', 50, 'REALIZADA', 150.0, 'PAGADO', 'PLIN', 'F43.1', 'Trastorno de estrés postraumático'),
  ('EXT-2020-013', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='EXT-2020-013' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='87654321' LIMIT 1), 15, '2025-07-10', 'INDIVIDUAL', 'EVALUACION', 'ONLINE', 60, 'REALIZADA', 150.0, 'PAGADO', 'TRANSFERENCIA', 'F43.2', 'Trastorno de adaptación'),
  ('HC-2023-025', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2023-025' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='65432109' LIMIT 1), 16, '2025-07-18', 'PAREJA', 'ANAMNESIS', 'PRESENCIAL', 45, 'REALIZADA', 230.0, 'PAGADO', 'TRANSFERENCIA', 'F32.1', 'Episodio depresivo moderado'),
  ('HC-2021-011', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2021-011' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='65432109' LIMIT 1), 27, '2025-10-16', 'INDIVIDUAL', 'EVALUACION', 'PRESENCIAL', 50, 'REALIZADA', 150.0, 'PAGADO', 'TRANSFERENCIA', 'F42', 'TOC'),
  ('EXT-2025-036', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='EXT-2025-036' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='98765432' LIMIT 1), 17, '2025-10-15', 'INDIVIDUAL', 'EVALUACION', 'HIBRIDA', 50, 'REALIZADA', 150.0, 'PAGADO', 'TARJETA', 'F43.2', 'Trastorno de adaptación'),
  ('HC-2022-028', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2022-028' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='65432109' LIMIT 1), 20, '2025-07-17', 'INDIVIDUAL', 'MOTIVO_CONSULTA', 'HIBRIDA', 50, 'NO_SHOW', 0.0, 'EXONERADO', NULL, 'F90.0', 'TDAH'),
  ('HC-2021-046', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2021-046' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='87654321' LIMIT 1), 27, '2024-05-21', 'PAREJA', 'SEGUIMIENTO', 'HIBRIDA', 45, 'REALIZADA', 150.0, 'PAGADO', 'YAPE', 'F42', 'TOC'),
  ('EXT-2022-039', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='EXT-2022-039' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='87654321' LIMIT 1), 11, '2025-10-30', 'INDIVIDUAL', 'CIERRE', 'HIBRIDA', 50, 'CANCELADA', 0.0, 'PENDIENTE', NULL, 'F42', 'TOC'),
  ('HC-2024-019', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2024-019' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='87654321' LIMIT 1), 25, '2024-12-10', 'INDIVIDUAL', 'ANAMNESIS', 'ONLINE', 50, 'REALIZADA', 150.0, 'PAGADO', 'YAPE', 'F41.1', 'Trastorno de ansiedad generalizada'),
  ('HC-2020-015', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2020-015' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='65432109' LIMIT 1), 15, '2025-03-09', 'PAREJA', 'MOTIVO_CONSULTA', 'PRESENCIAL', 50, 'REALIZADA', 230.0, 'PAGADO', 'EFECTIVO', 'F60.3', 'Trastorno límite de personalidad'),
  ('EXT-2024-029', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='EXT-2024-029' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='98765432' LIMIT 1), 19, '2024-11-08', 'PAREJA', 'SEGUIMIENTO', 'HIBRIDA', 45, 'REALIZADA', 230.0, 'PAGADO', 'TRANSFERENCIA', 'F60.3', 'Trastorno límite de personalidad'),
  ('EXT-2020-025', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='EXT-2020-025' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='76543210' LIMIT 1), 23, '2025-11-09', 'INDIVIDUAL', 'MOTIVO_CONSULTA', 'ONLINE', 90, 'CANCELADA', 0.0, 'EXONERADO', NULL, 'F32.1', 'Episodio depresivo moderado'),
  ('EXT-2022-003', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='EXT-2022-003' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='65432109' LIMIT 1), 9, '2024-06-09', 'PAREJA', 'ANAMNESIS', 'PRESENCIAL', 60, 'REALIZADA', 150.0, 'PAGADO', 'EFECTIVO', 'F60.3', 'Trastorno límite de personalidad'),
  ('HC-2022-058', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2022-058' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='87654321' LIMIT 1), 21, '2024-07-30', 'INDIVIDUAL', 'CIERRE', 'PRESENCIAL', 60, 'REALIZADA', 150.0, 'PAGADO', 'EFECTIVO', 'F40.1', 'Fobia social'),
  ('HC-2023-020', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2023-020' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='87654321' LIMIT 1), 17, '2024-04-19', 'PAREJA', 'CIERRE', 'ONLINE', 60, 'REALIZADA', 150.0, 'PAGADO', 'YAPE', 'F40.1', 'Fobia social'),
  ('HC-2022-035', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2022-035' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='65432109' LIMIT 1), 28, '2024-08-15', 'INDIVIDUAL', 'TRATAMIENTO', 'PRESENCIAL', 90, 'CANCELADA', 0.0, 'PENDIENTE', NULL, 'F40.1', 'Fobia social'),
  ('HC-2022-032', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2022-032' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='65432109' LIMIT 1), 15, '2024-02-10', 'INDIVIDUAL', 'ANAMNESIS', 'ONLINE', 60, 'REALIZADA', 150.0, 'PAGADO', 'TARJETA', 'F41.1', 'Trastorno de ansiedad generalizada'),
  ('HC-2025-018', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2025-018' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='65432109' LIMIT 1), 3, '2025-02-27', 'INDIVIDUAL', 'EVALUACION', 'ONLINE', 50, 'REALIZADA', 150.0, 'PAGADO', 'TRANSFERENCIA', 'F41.1', 'Trastorno de ansiedad generalizada'),
  ('EXT-2024-011', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='EXT-2024-011' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='65432109' LIMIT 1), 21, '2024-02-14', 'PAREJA', 'ANAMNESIS', 'PRESENCIAL', 50, 'CANCELADA', 0.0, 'EXONERADO', NULL, 'F43.1', 'Trastorno de estrés postraumático'),
  ('HC-2025-031', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2025-031' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='87654321' LIMIT 1), 29, '2025-08-25', 'INDIVIDUAL', 'CIERRE', 'ONLINE', 50, 'REALIZADA', 150.0, 'PAGADO', 'YAPE', 'F43.2', 'Trastorno de adaptación'),
  ('HC-2025-054', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2025-054' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='87654321' LIMIT 1), 11, '2024-06-14', 'INDIVIDUAL', 'EVALUACION', 'ONLINE', 45, 'REALIZADA', 150.0, 'PAGADO', 'TARJETA', 'F43.1', 'Trastorno de estrés postraumático'),
  ('HC-2023-027', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2023-027' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='87654321' LIMIT 1), 17, '2025-09-18', 'INDIVIDUAL', 'CIERRE', 'HIBRIDA', 60, 'REALIZADA', 150.0, 'PAGADO', 'TRANSFERENCIA', 'F32.1', 'Episodio depresivo moderado'),
  ('EXT-2022-021', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='EXT-2022-021' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='98765432' LIMIT 1), 21, '2024-07-31', 'INDIVIDUAL', 'ANAMNESIS', 'HIBRIDA', 60, 'CANCELADA', 0.0, 'EXONERADO', NULL, 'F42', 'TOC'),
  ('EXT-2020-019', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='EXT-2020-019' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='98765432' LIMIT 1), 21, '2024-06-28', 'INDIVIDUAL', 'TRATAMIENTO', 'HIBRIDA', 60, 'REALIZADA', 230.0, 'PAGADO', 'EFECTIVO', 'F90.0', 'TDAH'),
  ('HC-2021-009', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2021-009' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='87654321' LIMIT 1), 23, '2024-10-14', 'INDIVIDUAL', 'EVALUACION', 'HIBRIDA', 45, 'CANCELADA', 0.0, 'EXONERADO', NULL, 'F42', 'TOC'),
  ('HC-2020-015', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2020-015' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='76543210' LIMIT 1), 25, '2024-02-08', 'PAREJA', 'MOTIVO_CONSULTA', 'HIBRIDA', 50, 'CANCELADA', 0.0, 'PENDIENTE', NULL, 'F40.1', 'Fobia social'),
  ('HC-2020-006', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2020-006' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='98765432' LIMIT 1), 9, '2025-06-17', 'PAREJA', 'ANAMNESIS', 'PRESENCIAL', 60, 'CANCELADA', 0.0, 'EXONERADO', NULL, 'F40.1', 'Fobia social'),
  ('HC-2022-037', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2022-037' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='87654321' LIMIT 1), 13, '2024-06-24', 'INDIVIDUAL', 'MOTIVO_CONSULTA', 'PRESENCIAL', 90, 'REALIZADA', 150.0, 'PAGADO', 'YAPE', 'F90.0', 'TDAH'),
  ('EXT-2025-030', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='EXT-2025-030' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='65432109' LIMIT 1), 23, '2024-04-09', 'PAREJA', 'SEGUIMIENTO', 'ONLINE', 60, 'REALIZADA', 230.0, 'PAGADO', 'EFECTIVO', 'F40.1', 'Fobia social'),
  ('EXT-2025-018', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='EXT-2025-018' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='87654321' LIMIT 1), 6, '2025-06-04', 'PAREJA', 'TRATAMIENTO', 'ONLINE', 45, 'REALIZADA', 230.0, 'PAGADO', 'TARJETA', 'F60.3', 'Trastorno límite de personalidad'),
  ('EXT-2022-003', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='EXT-2022-003' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='98765432' LIMIT 1), 16, '2025-08-29', 'PAREJA', 'SEGUIMIENTO', 'HIBRIDA', 45, 'REALIZADA', 150.0, 'PAGADO', 'TARJETA', 'F42', 'TOC'),
  ('HC-2022-058', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2022-058' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='87654321' LIMIT 1), 3, '2024-07-29', 'INDIVIDUAL', 'CIERRE', 'PRESENCIAL', 90, 'REALIZADA', 150.0, 'PAGADO', 'YAPE', 'F90.0', 'TDAH'),
  ('HC-2025-031', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2025-031' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='65432109' LIMIT 1), 16, '2025-12-20', 'INDIVIDUAL', 'ANAMNESIS', 'PRESENCIAL', 90, 'REALIZADA', 150.0, 'PAGADO', 'PLIN', 'F90.0', 'TDAH'),
  ('EXT-2022-033', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='EXT-2022-033' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='65432109' LIMIT 1), 20, '2025-11-04', 'INDIVIDUAL', 'ANAMNESIS', 'ONLINE', 90, 'REALIZADA', 150.0, 'PAGADO', 'EFECTIVO', 'F43.1', 'Trastorno de estrés postraumático'),
  ('HC-2020-053', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2020-053' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='76543210' LIMIT 1), 24, '2024-02-04', 'INDIVIDUAL', 'SEGUIMIENTO', 'HIBRIDA', 60, 'NO_SHOW', 0.0, 'EXONERADO', NULL, 'F90.0', 'TDAH'),
  ('EXT-2020-001', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='EXT-2020-001' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='65432109' LIMIT 1), 2, '2025-06-08', 'PAREJA', 'SEGUIMIENTO', 'ONLINE', 50, 'NO_SHOW', 0.0, 'EXONERADO', NULL, 'F43.1', 'Trastorno de estrés postraumático'),
  ('HC-2022-036', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2022-036' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='76543210' LIMIT 1), 16, '2024-05-15', 'PAREJA', 'ANAMNESIS', 'HIBRIDA', 45, 'REALIZADA', 230.0, 'PAGADO', 'TARJETA', 'F43.1', 'Trastorno de estrés postraumático'),
  ('EXT-2023-034', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='EXT-2023-034' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='76543210' LIMIT 1), 28, '2024-02-25', 'PAREJA', 'TRATAMIENTO', 'PRESENCIAL', 60, 'REALIZADA', 150.0, 'PAGADO', 'EFECTIVO', 'F43.2', 'Trastorno de adaptación'),
  ('HC-2025-013', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2025-013' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='76543210' LIMIT 1), 18, '2025-11-01', 'INDIVIDUAL', 'MOTIVO_CONSULTA', 'HIBRIDA', 45, 'REALIZADA', 150.0, 'PAGADO', 'EFECTIVO', 'F43.2', 'Trastorno de adaptación'),
  ('HC-2023-025', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2023-025' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='98765432' LIMIT 1), 29, '2024-01-25', 'PAREJA', 'MOTIVO_CONSULTA', 'HIBRIDA', 50, 'REALIZADA', 230.0, 'PAGADO', 'YAPE', 'F32.1', 'Episodio depresivo moderado'),
  ('HC-2022-036', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2022-036' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='98765432' LIMIT 1), 5, '2025-01-26', 'PAREJA', 'CIERRE', 'ONLINE', 50, 'REALIZADA', 230.0, 'PAGADO', 'TRANSFERENCIA', 'F32.1', 'Episodio depresivo moderado'),
  ('HC-2023-020', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2023-020' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='98765432' LIMIT 1), 8, '2024-02-08', 'PAREJA', 'MOTIVO_CONSULTA', 'ONLINE', 90, 'REALIZADA', 150.0, 'PAGADO', 'TRANSFERENCIA', 'F41.1', 'Trastorno de ansiedad generalizada'),
  ('EXT-2021-038', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='EXT-2021-038' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='76543210' LIMIT 1), 5, '2025-10-25', 'PAREJA', 'MOTIVO_CONSULTA', 'PRESENCIAL', 45, 'REALIZADA', 230.0, 'PAGADO', 'EFECTIVO', 'F42', 'TOC'),
  ('HC-2024-008', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2024-008' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='76543210' LIMIT 1), 2, '2024-02-13', 'INDIVIDUAL', 'SEGUIMIENTO', 'PRESENCIAL', 90, 'REALIZADA', 150.0, 'PAGADO', 'TRANSFERENCIA', 'F40.1', 'Fobia social'),
  ('EXT-2020-019', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='EXT-2020-019' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='87654321' LIMIT 1), 26, '2025-08-28', 'INDIVIDUAL', 'ANAMNESIS', 'ONLINE', 60, 'REALIZADA', 230.0, 'PAGADO', 'EFECTIVO', 'F32.1', 'Episodio depresivo moderado'),
  ('HC-2024-019', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2024-019' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='65432109' LIMIT 1), 25, '2024-06-21', 'INDIVIDUAL', 'ANAMNESIS', 'PRESENCIAL', 90, 'REALIZADA', 150.0, 'PAGADO', 'EFECTIVO', 'F43.1', 'Trastorno de estrés postraumático'),
  ('EXT-2020-007', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='EXT-2020-007' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='65432109' LIMIT 1), 8, '2025-02-25', 'PAREJA', 'ANAMNESIS', 'PRESENCIAL', 45, 'REALIZADA', 150.0, 'PAGADO', 'PLIN', 'F43.2', 'Trastorno de adaptación'),
  ('EXT-2023-028', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='EXT-2023-028' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='65432109' LIMIT 1), 4, '2025-05-24', 'PAREJA', 'SEGUIMIENTO', 'PRESENCIAL', 50, 'REALIZADA', 230.0, 'PAGADO', 'EFECTIVO', 'F40.1', 'Fobia social'),
  ('HC-2022-030', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2022-030' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='98765432' LIMIT 1), 19, '2024-11-29', 'INDIVIDUAL', 'TRATAMIENTO', 'PRESENCIAL', 90, 'REALIZADA', 150.0, 'PAGADO', 'EFECTIVO', 'F40.1', 'Fobia social'),
  ('HC-2024-026', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2024-026' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='76543210' LIMIT 1), 6, '2024-05-10', 'INDIVIDUAL', 'EVALUACION', 'PRESENCIAL', 60, 'REALIZADA', 150.0, 'PAGADO', 'EFECTIVO', 'F41.1', 'Trastorno de ansiedad generalizada'),
  ('HC-2021-002', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2021-002' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='65432109' LIMIT 1), 2, '2024-09-09', 'INDIVIDUAL', 'MOTIVO_CONSULTA', 'ONLINE', 45, 'REALIZADA', 150.0, 'PAGADO', 'EFECTIVO', 'F42', 'TOC'),
  ('HC-2022-038', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2022-038' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='87654321' LIMIT 1), 15, '2025-10-25', 'INDIVIDUAL', 'TRATAMIENTO', 'PRESENCIAL', 90, 'NO_SHOW', 0.0, 'PENDIENTE', NULL, 'F43.2', 'Trastorno de adaptación'),
  ('HC-2025-055', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2025-055' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='76543210' LIMIT 1), 4, '2025-12-15', 'INDIVIDUAL', 'TRATAMIENTO', 'ONLINE', 90, 'NO_SHOW', 0.0, 'PENDIENTE', NULL, 'F32.1', 'Episodio depresivo moderado'),
  ('HC-2020-015', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2020-015' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='65432109' LIMIT 1), 17, '2025-08-17', 'PAREJA', 'CIERRE', 'PRESENCIAL', 90, 'CANCELADA', 0.0, 'PENDIENTE', NULL, 'F42', 'TOC'),
  ('HC-2022-037', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2022-037' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='98765432' LIMIT 1), 10, '2024-04-21', 'INDIVIDUAL', 'TRATAMIENTO', 'HIBRIDA', 50, 'REALIZADA', 150.0, 'PAGADO', 'EFECTIVO', 'F32.1', 'Episodio depresivo moderado'),
  ('HC-2020-053', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2020-053' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='76543210' LIMIT 1), 10, '2025-11-02', 'INDIVIDUAL', 'CIERRE', 'PRESENCIAL', 60, 'REALIZADA', 150.0, 'PAGADO', 'TARJETA', 'F90.0', 'TDAH'),
  ('HC-2023-021', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2023-021' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='76543210' LIMIT 1), 22, '2024-07-05', 'PAREJA', 'EVALUACION', 'ONLINE', 50, 'NO_SHOW', 0.0, 'PENDIENTE', NULL, 'F43.1', 'Trastorno de estrés postraumático'),
  ('HC-2021-041', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2021-041' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='87654321' LIMIT 1), 22, '2024-01-05', 'PAREJA', 'CIERRE', 'PRESENCIAL', 60, 'NO_SHOW', 0.0, 'EXONERADO', NULL, 'F43.1', 'Trastorno de estrés postraumático'),
  ('HC-2023-025', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2023-025' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='87654321' LIMIT 1), 30, '2024-10-11', 'PAREJA', 'SEGUIMIENTO', 'ONLINE', 90, 'REALIZADA', 230.0, 'PAGADO', 'TARJETA', 'F42', 'TOC'),
  ('HC-2023-012', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2023-012' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='87654321' LIMIT 1), 16, '2025-03-30', 'PAREJA', 'CIERRE', 'ONLINE', 45, 'CANCELADA', 0.0, 'EXONERADO', NULL, 'F42', 'TOC'),
  ('EXT-2020-031', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='EXT-2020-031' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='87654321' LIMIT 1), 26, '2024-07-23', 'PAREJA', 'MOTIVO_CONSULTA', 'PRESENCIAL', 60, 'REALIZADA', 230.0, 'PAGADO', 'EFECTIVO', 'F60.3', 'Trastorno límite de personalidad'),
  ('EXT-2023-004', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='EXT-2023-004' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='98765432' LIMIT 1), 19, '2025-09-05', 'PAREJA', 'MOTIVO_CONSULTA', 'PRESENCIAL', 60, 'CANCELADA', 0.0, 'EXONERADO', NULL, 'F32.1', 'Episodio depresivo moderado'),
  ('HC-2022-038', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2022-038' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='98765432' LIMIT 1), 9, '2025-06-10', 'INDIVIDUAL', 'SEGUIMIENTO', 'HIBRIDA', 60, 'REALIZADA', 150.0, 'PAGADO', 'YAPE', 'F43.1', 'Trastorno de estrés postraumático'),
  ('HC-2022-028', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2022-028' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='87654321' LIMIT 1), 30, '2025-05-30', 'INDIVIDUAL', 'MOTIVO_CONSULTA', 'ONLINE', 60, 'REALIZADA', 150.0, 'PAGADO', 'PLIN', 'F40.1', 'Fobia social'),
  ('HC-2020-040', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2020-040' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='87654321' LIMIT 1), 19, '2024-08-02', 'PAREJA', 'MOTIVO_CONSULTA', 'ONLINE', 45, 'REALIZADA', 150.0, 'PAGADO', 'EFECTIVO', 'F41.1', 'Trastorno de ansiedad generalizada'),
  ('HC-2021-004', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2021-004' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='98765432' LIMIT 1), 23, '2024-05-29', 'PAREJA', 'ANAMNESIS', 'ONLINE', 50, 'CANCELADA', 0.0, 'EXONERADO', NULL, 'F40.1', 'Fobia social'),
  ('HC-2021-014', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2021-014' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='87654321' LIMIT 1), 15, '2024-12-29', 'INDIVIDUAL', 'MOTIVO_CONSULTA', 'HIBRIDA', 50, 'NO_SHOW', 0.0, 'EXONERADO', NULL, 'F40.1', 'Fobia social'),
  ('EXT-2024-017', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='EXT-2024-017' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='76543210' LIMIT 1), 13, '2025-12-04', 'PAREJA', 'TRATAMIENTO', 'HIBRIDA', 45, 'NO_SHOW', 0.0, 'EXONERADO', NULL, 'F40.1', 'Fobia social'),
  ('HC-2024-026', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2024-026' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='65432109' LIMIT 1), 16, '2024-05-05', 'INDIVIDUAL', 'SEGUIMIENTO', 'HIBRIDA', 90, 'REALIZADA', 150.0, 'PAGADO', 'YAPE', 'F42', 'TOC'),
  ('HC-2025-013', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2025-013' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='98765432' LIMIT 1), 20, '2024-03-10', 'INDIVIDUAL', 'CIERRE', 'PRESENCIAL', 45, 'REALIZADA', 150.0, 'PAGADO', 'TARJETA', 'F41.1', 'Trastorno de ansiedad generalizada'),
  ('HC-2023-003', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2023-003' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='98765432' LIMIT 1), 16, '2025-03-16', 'PAREJA', 'TRATAMIENTO', 'PRESENCIAL', 60, 'CANCELADA', 0.0, 'PENDIENTE', NULL, 'F41.1', 'Trastorno de ansiedad generalizada'),
  ('HC-2023-051', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2023-051' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='76543210' LIMIT 1), 26, '2025-05-21', 'PAREJA', 'SEGUIMIENTO', 'HIBRIDA', 45, 'REALIZADA', 150.0, 'PAGADO', 'PLIN', 'F41.1', 'Trastorno de ansiedad generalizada'),
  ('HC-2022-032', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2022-032' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='87654321' LIMIT 1), 11, '2025-10-25', 'INDIVIDUAL', 'MOTIVO_CONSULTA', 'ONLINE', 90, 'REALIZADA', 150.0, 'PAGADO', 'TARJETA', 'F32.1', 'Episodio depresivo moderado'),
  ('HC-2025-013', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2025-013' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='65432109' LIMIT 1), 20, '2024-04-12', 'INDIVIDUAL', 'EVALUACION', 'ONLINE', 90, 'REALIZADA', 150.0, 'PAGADO', 'TARJETA', 'F40.1', 'Fobia social'),
  ('EXT-2025-036', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='EXT-2025-036' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='98765432' LIMIT 1), 7, '2025-08-15', 'INDIVIDUAL', 'EVALUACION', 'PRESENCIAL', 60, 'REALIZADA', 150.0, 'PAGADO', 'TARJETA', 'F90.0', 'TDAH'),
  ('HC-2024-024', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2024-024' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='65432109' LIMIT 1), 17, '2024-08-06', 'INDIVIDUAL', 'ANAMNESIS', 'ONLINE', 90, 'REALIZADA', 150.0, 'PAGADO', 'PLIN', 'F43.2', 'Trastorno de adaptación'),
  ('HC-2020-033', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2020-033' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='87654321' LIMIT 1), 6, '2025-02-19', 'PAREJA', 'EVALUACION', 'PRESENCIAL', 45, 'REALIZADA', 230.0, 'PAGADO', 'TARJETA', 'F43.2', 'Trastorno de adaptación'),
  ('HC-2022-039', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2022-039' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='98765432' LIMIT 1), 16, '2025-02-20', 'PAREJA', 'MOTIVO_CONSULTA', 'PRESENCIAL', 45, 'CANCELADA', 0.0, 'PENDIENTE', NULL, 'F32.1', 'Episodio depresivo moderado'),
  ('HC-2022-036', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2022-036' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='65432109' LIMIT 1), 16, '2025-02-22', 'PAREJA', 'SEGUIMIENTO', 'ONLINE', 60, 'REALIZADA', 230.0, 'PAGADO', 'PLIN', 'F90.0', 'TDAH'),
  ('HC-2020-057', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2020-057' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='65432109' LIMIT 1), 21, '2024-01-09', 'INDIVIDUAL', 'EVALUACION', 'HIBRIDA', 90, 'NO_SHOW', 0.0, 'EXONERADO', NULL, 'F60.3', 'Trastorno límite de personalidad'),
  ('EXT-2025-030', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='EXT-2025-030' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='76543210' LIMIT 1), 1, '2025-06-02', 'PAREJA', 'TRATAMIENTO', 'PRESENCIAL', 60, 'REALIZADA', 230.0, 'PAGADO', 'PLIN', 'F43.2', 'Trastorno de adaptación'),
  ('HC-2021-034', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2021-034' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='87654321' LIMIT 1), 21, '2025-12-04', 'PAREJA', 'CIERRE', 'HIBRIDA', 50, 'REALIZADA', 230.0, 'PAGADO', 'EFECTIVO', 'F43.1', 'Trastorno de estrés postraumático'),
  ('HC-2022-022', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2022-022' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='98765432' LIMIT 1), 10, '2024-01-15', 'INDIVIDUAL', 'SEGUIMIENTO', 'ONLINE', 90, 'CANCELADA', 0.0, 'EXONERADO', NULL, 'F43.2', 'Trastorno de adaptación'),
  ('HC-2021-004', (SELECT paciente_id FROM oltp_pacientes WHERE codigo_historia='HC-2021-004' LIMIT 1), (SELECT psicologo_id FROM oltp_psicologos WHERE dni='76543210' LIMIT 1), 22, '2024-09-25', 'PAREJA', 'ANAMNESIS', 'HIBRIDA', 90, 'REALIZADA', 230.0, 'PAGADO', 'EFECTIVO', 'F43.2', 'Trastorno de adaptación');


SET FOREIGN_KEY_CHECKS = 1;

-- ================================================================
--  FIN — Solo datos OLTP (sin Star Schema, sin ETL, sin vistas)
-- ================================================================
