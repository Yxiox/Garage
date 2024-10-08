-- Criação das tabelas
BEGIN;


CREATE TABLE IF NOT EXISTS public.cliente
(
    id serial NOT NULL,
    nome character(30) NOT NULL,
    "CPF" bigint,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.veiculo
(
    id serial NOT NULL,
    placa character(7) NOT NULL,
    modelo text NOT NULL,
    cor character(15) NOT NULL,
    cliente_id serial NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.movimento
(
    id serial NOT NULL,
    ativo boolean NOT NULL,
    data daterange NOT NULL,
    hora_entrada time without time zone NOT NULL,
    hora_saida time without time zone,
    preco money,
    carro_id serial NOT NULL,
    PRIMARY KEY (id)
);

ALTER TABLE IF EXISTS public.veiculo
    ADD FOREIGN KEY (cliente_id)
    REFERENCES public.cliente (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.movimento
    ADD CONSTRAINT veiculo_movimento_fk FOREIGN KEY (carro_id)
    REFERENCES public.veiculo (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

END;

-- ============================================================================================================================ --

-- Inserts de exemplo

-- Insert Cliente
INSERT INTO public.cliente (nome, "CPF")
VALUES ('Carlos Pereira', 12345678901);

-- Insert Veiculo
INSERT INTO public.veiculo (placa, modelo, cor, cliente_id)
VALUES ('ABC1234', 'Toyota Corolla', 'Prata', 1);

-- Insert movimento com data de saída
INSERT INTO public.movimento (ativo, data, hora_entrada, hora_saida, preco, carro_id)
VALUES (false, '[2024-01-01, 2024-02-02]', '08:30:00', '08:30:00', NULL, 1);

-- Insert movimento sem data de saída ou ativo
INSERT INTO public.movimento (ativo, data, hora_entrada, hora_saida, preco, carro_id)
VALUES (true, '[2024-01-01, infinity]', '08:30:00', NULL, NULL, 1);

-- ============================================================================================================================ --

-- Selects

-- Select de todos os clientes / Transformei em view para abstrair
SELECT id, nome, "CPF" FROM public.cliente;

SELECT * FROM public."TODOS_CLIENTES"

-- Select de todos os veículos / Transformei em view para abstrair
SELECT v.id, v.placa, v.modelo, v.cor, c.id AS cliente_id, c.nome AS cliente_nome
FROM public.veiculo v
JOIN public.cliente c ON v.cliente_id = c.id;

SELECT * FROM public."TODOS_VEICULOS"

-- Select de todos os veículos de determinado cliente
SELECT * FROM public."TODOS_VEICULOS" where cliente_id = 1

-- Select de todos os movimentos / Transformei em view para abstrair
SELECT m.id, m.ativo, m.data, lower(m.data) AS data_inicial, upper(m.data) AS data_final, m.hora_entrada, m.hora_saida, m.preco, v.placa, v.modelo
FROM public.movimento m
JOIN public.veiculo v ON m.carro_id = v.id;

SELECT * FROM public."TODOS_MOVIMENTOS"

-- Select dos movimentos nos últimos 30 dias / Transformei em view para abstrair
SELECT m.id,m.ativo,m.data,lower(m.data) AS data_inicial,upper(m.data) AS data_final,m.hora_entrada,m.hora_saida,m.preco,v.placa,v.modelo
FROM movimento m
JOIN veiculo v ON m.carro_id = v.id
WHERE m.data && daterange((CURRENT_DATE - '30 days'::interval)::date, CURRENT_DATE);

SELECT * FROM public."MOVIMENTOS_30DIAS"

