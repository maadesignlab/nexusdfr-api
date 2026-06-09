--
-- PostgreSQL database dump
--

\restrict kGXL45IRRyCUFt5hyEoh2XGdmP6Ndrmv9oQWjgdGQfsCgg04hbfOnVLo90cUNjw

-- Dumped from database version 16.14 (Debian 16.14-1.pgdg13+1)
-- Dumped by pg_dump version 16.14 (Debian 16.14-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: order_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.order_status AS ENUM (
    'PENDING',
    'COMPLETED',
    'CANCELLED'
);


ALTER TYPE public.order_status OWNER TO postgres;

--
-- Name: publication_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.publication_type AS ENUM (
    'BOOK',
    'MAGAZINE'
);


ALTER TYPE public.publication_type OWNER TO postgres;

--
-- Name: reservation_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.reservation_status AS ENUM (
    'ACTIVE',
    'COMPLETED',
    'CANCELLED'
);


ALTER TYPE public.reservation_status OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: authors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.authors (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(150) NOT NULL,
    country character varying(100),
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.authors OWNER TO postgres;

--
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    slug character varying(120) NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- Name: coworking_spaces; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.coworking_spaces (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(120) NOT NULL,
    capacity integer NOT NULL,
    available boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    space_type character varying(50),
    location character varying(100),
    CONSTRAINT coworking_spaces_capacity_check CHECK ((capacity > 0))
);


ALTER TABLE public.coworking_spaces OWNER TO postgres;

--
-- Name: order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_items (
    order_id uuid NOT NULL,
    publication_id uuid NOT NULL,
    quantity integer NOT NULL,
    unit_price numeric(10,2) NOT NULL,
    subtotal numeric(10,2) NOT NULL,
    CONSTRAINT order_items_quantity_check CHECK ((quantity > 0))
);


ALTER TABLE public.order_items OWNER TO postgres;

--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    total numeric(10,2) DEFAULT 0 NOT NULL,
    status public.order_status DEFAULT 'PENDING'::public.order_status NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: publication_authors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.publication_authors (
    publication_id uuid NOT NULL,
    author_id uuid NOT NULL
);


ALTER TABLE public.publication_authors OWNER TO postgres;

--
-- Name: publications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.publications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    publication_type public.publication_type NOT NULL,
    price numeric(10,2) NOT NULL,
    stock integer DEFAULT 0 NOT NULL,
    published_year integer,
    cover_url text,
    featured boolean DEFAULT false,
    category_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    isbn character varying(50),
    publisher character varying(150),
    pages integer,
    sold integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.publications OWNER TO postgres;

--
-- Name: reservations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reservations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    coworking_space_id uuid NOT NULL,
    start_at timestamp without time zone NOT NULL,
    end_at timestamp without time zone NOT NULL,
    status public.reservation_status DEFAULT 'ACTIVE'::public.reservation_status NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    CONSTRAINT chk_reservation_dates CHECK ((end_at > start_at))
);


ALTER TABLE public.reservations OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    email character varying(255) NOT NULL,
    auth0_sub character varying(255),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Data for Name: authors; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.authors VALUES ('6515c766-4cb3-41a4-a0a6-3a74cc526e02', 'Héctor Abad Faciolince', NULL, '2026-06-05 01:50:45.832048');
INSERT INTO public.authors VALUES ('649ddac8-f106-4da0-9592-03a3f7ab68d4', 'Gabriel García Márquez', NULL, '2026-06-05 01:50:45.832048');
INSERT INTO public.authors VALUES ('1b29f6bb-fda9-4d1c-a8f2-5a1c0e0d6b62', 'Laura Restrepo', NULL, '2026-06-05 01:50:45.832048');
INSERT INTO public.authors VALUES ('b7f40809-5b0b-4210-bad3-4ec85e9e5a5a', 'José Eustasio Rivera', NULL, '2026-06-05 01:50:45.832048');
INSERT INTO public.authors VALUES ('d163d09a-1475-4ff9-95d5-0e3cba8e2b89', 'Juan Gabriel Vásquez', NULL, '2026-06-05 01:50:45.832048');
INSERT INTO public.authors VALUES ('2add67bf-e527-41dd-b1b3-3a74dc407809', 'Mario Mendoza', NULL, '2026-06-05 01:50:45.832048');
INSERT INTO public.authors VALUES ('cc8017c9-dc3f-46f4-a43a-7f7770db69ca', 'Pilar Quintana', NULL, '2026-06-05 01:50:45.832048');
INSERT INTO public.authors VALUES ('0459d52a-44f1-4d4c-81f2-3d9bfb013f28', 'Miguel de Cervantes', NULL, '2026-06-05 01:50:45.832048');
INSERT INTO public.authors VALUES ('43bd04b9-779e-483a-aa1a-601751ba896a', 'Robert Louis Stevenson', NULL, '2026-06-05 01:50:45.832048');
INSERT INTO public.authors VALUES ('2166414a-9244-45ea-b800-6eca9f6a5b20', 'Grupo Diners', NULL, '2026-06-05 01:50:45.832048');
INSERT INTO public.authors VALUES ('587f9ad7-ee39-48e2-9bba-4e5e1fdf33a3', 'Casa Editorial El Tiempo', NULL, '2026-06-05 01:50:45.832048');
INSERT INTO public.authors VALUES ('1bbdd2e0-5420-49cb-941e-8315a7bf8680', 'Grupo Portafolio', NULL, '2026-06-05 01:50:45.832048');
INSERT INTO public.authors VALUES ('bf054d6c-6edf-4916-881e-339b653c627c', 'Publicaciones Semana', NULL, '2026-06-05 01:50:45.832048');
INSERT INTO public.authors VALUES ('f22e1019-88de-485a-b55a-f9bfd5b95922', 'Noam Chomsky', NULL, '2026-06-05 01:50:45.832048');
INSERT INTO public.authors VALUES ('5000b4f8-2457-4ada-aa68-7a6b99bde6d3', 'Condé Nast', NULL, '2026-06-05 01:50:45.832048');
INSERT INTO public.authors VALUES ('6394997d-1ce1-41cb-bff7-a114e838c72d', 'Viktor Frankl', NULL, '2026-06-05 01:50:45.832048');
INSERT INTO public.authors VALUES ('29574345-3325-4710-930c-42fb5540cd17', 'Isabel Allende', NULL, '2026-06-05 01:50:45.832048');
INSERT INTO public.authors VALUES ('85ec148d-91d1-4bca-b8d4-c58d89000219', 'National Geographic', NULL, '2026-06-05 01:50:45.832048');


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.categories VALUES ('5b946e9b-eb35-4d13-a716-e806212dfb00', 'Drama', 'drama', '2026-06-05 01:50:22.246976');
INSERT INTO public.categories VALUES ('94231629-c4be-43d3-be58-8309855e3ddc', 'Ficción', 'ficcion', '2026-06-05 01:50:22.246976');
INSERT INTO public.categories VALUES ('460c970e-cd89-4b72-8ae4-2922e70c407f', 'Clásico', 'clasico', '2026-06-05 01:50:22.246976');
INSERT INTO public.categories VALUES ('ffa533dc-bcc5-4088-8684-04be0b4c3c2a', 'Economía', 'economia', '2026-06-05 01:50:22.246976');
INSERT INTO public.categories VALUES ('5dc7bf92-0900-4323-991e-80ca7606cbed', 'Arte y Cultura', 'arte-cultura', '2026-06-05 01:50:22.246976');
INSERT INTO public.categories VALUES ('5fcc48f5-84d9-436e-a613-1275695d0d61', 'Estilo de vida', 'estilo-vida', '2026-06-05 01:50:22.246976');


--
-- Data for Name: coworking_spaces; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.coworking_spaces VALUES ('159b5f5b-db8b-4eb4-a999-46fdcbb57930', 'Sala 01 - Reunión', 6, false, '2026-06-05 02:05:10.230983', 'Reunión', 'Piso 1');
INSERT INTO public.coworking_spaces VALUES ('afecaa38-eba0-4feb-9ccd-683136dcd588', 'Mesa 01 - Ventana', 1, true, '2026-06-05 02:05:10.230983', 'Silencioso', 'Piso 2');
INSERT INTO public.coworking_spaces VALUES ('bfc0e476-6f4f-455c-8236-6f49031c8e39', 'Mesa 02 - Central', 1, true, '2026-06-05 02:05:10.230983', 'Abierto', 'Piso 2');
INSERT INTO public.coworking_spaces VALUES ('71b77472-689e-4c43-b9c0-7ae660a37768', 'Mesa 03 - Pasillo', 1, true, '2026-06-05 02:05:10.230983', 'Abierto', 'Piso 2');
INSERT INTO public.coworking_spaces VALUES ('3cf466a9-5463-49fd-b59d-2de9b6145c26', 'Mesa 04 - Ventana', 1, true, '2026-06-05 02:05:10.230983', 'Silencioso', 'Piso 2');
INSERT INTO public.coworking_spaces VALUES ('0aafb0a2-9feb-49ad-ab0b-8d47adb9377e', 'Cabina 01 - Llamadas', 1, false, '2026-06-05 02:05:10.230983', 'Cabina', 'Piso 1');


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.order_items VALUES ('bd26093c-c444-45cd-bfb4-c69d81cb3d40', '9cdde891-af37-4613-b2f3-624658494ed5', 3, 18000.00, 54000.00);


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.orders VALUES ('bd26093c-c444-45cd-bfb4-c69d81cb3d40', 'f6067f72-2eb9-4db1-a8a9-091db0c08be1', 54000.00, 'PENDING', '2026-06-05 02:59:46.634793');


--
-- Data for Name: publication_authors; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.publication_authors VALUES ('5f2d239c-c65e-4d49-be5f-7b70daf564a9', '6515c766-4cb3-41a4-a0a6-3a74cc526e02');
INSERT INTO public.publication_authors VALUES ('1370d648-d852-4a92-9977-ae1bb0af0257', '649ddac8-f106-4da0-9592-03a3f7ab68d4');
INSERT INTO public.publication_authors VALUES ('b89aa72d-8883-4cf1-ba26-e04fc25106c8', '1b29f6bb-fda9-4d1c-a8f2-5a1c0e0d6b62');
INSERT INTO public.publication_authors VALUES ('603f0ef9-61f6-4f40-9f12-249fb96e87b0', 'b7f40809-5b0b-4210-bad3-4ec85e9e5a5a');
INSERT INTO public.publication_authors VALUES ('2140298c-a73e-4edc-bf45-72a9b77b71e9', 'd163d09a-1475-4ff9-95d5-0e3cba8e2b89');
INSERT INTO public.publication_authors VALUES ('510208ca-1c56-4e41-b59e-5db045ed62df', '2add67bf-e527-41dd-b1b3-3a74dc407809');
INSERT INTO public.publication_authors VALUES ('11eec181-842f-4a9e-b904-11fcc5f9149a', '649ddac8-f106-4da0-9592-03a3f7ab68d4');
INSERT INTO public.publication_authors VALUES ('67faa064-7ea5-4874-92cc-19b004156893', 'cc8017c9-dc3f-46f4-a43a-7f7770db69ca');
INSERT INTO public.publication_authors VALUES ('22f64e57-05c8-4530-8c31-5ff0d197822c', '0459d52a-44f1-4d4c-81f2-3d9bfb013f28');
INSERT INTO public.publication_authors VALUES ('e6dfe805-840b-43d1-81f4-0382c86b99d7', '43bd04b9-779e-483a-aa1a-601751ba896a');
INSERT INTO public.publication_authors VALUES ('9cdde891-af37-4613-b2f3-624658494ed5', '2166414a-9244-45ea-b800-6eca9f6a5b20');
INSERT INTO public.publication_authors VALUES ('3853eeb1-0afc-4023-bb28-9f67aed50ed6', '587f9ad7-ee39-48e2-9bba-4e5e1fdf33a3');
INSERT INTO public.publication_authors VALUES ('66e9abd6-5f25-4e7c-a049-07241f81d370', '1bbdd2e0-5420-49cb-941e-8315a7bf8680');
INSERT INTO public.publication_authors VALUES ('4fc7d366-6cdd-48aa-bfa4-8a6b760202bd', 'bf054d6c-6edf-4916-881e-339b653c627c');
INSERT INTO public.publication_authors VALUES ('c62a4dcf-fb61-4fc6-89fd-3c36545c96a0', 'f22e1019-88de-485a-b55a-f9bfd5b95922');
INSERT INTO public.publication_authors VALUES ('ee93bd7c-bfca-4653-ad5f-cdfea36b9ea9', '5000b4f8-2457-4ada-aa68-7a6b99bde6d3');
INSERT INTO public.publication_authors VALUES ('430f74f8-bae3-4acf-af26-c4397908b2ec', '6394997d-1ce1-41cb-bff7-a114e838c72d');
INSERT INTO public.publication_authors VALUES ('9dfcc543-e3c5-4e7f-91fc-f56d33e0126f', '29574345-3325-4710-930c-42fb5540cd17');
INSERT INTO public.publication_authors VALUES ('29e6a880-3f9b-45a9-85b7-c32898fdcaf0', 'bf054d6c-6edf-4916-881e-339b653c627c');
INSERT INTO public.publication_authors VALUES ('0018d11d-b958-475e-a4ee-18103ee556d2', '85ec148d-91d1-4bca-b8d4-c58d89000219');


--
-- Data for Name: publications; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.publications VALUES ('9cdde891-af37-4613-b2f3-624658494ed5', 'Diners', 'Revista sobre estilo de vida, gastronomía y viajes.', 'MAGAZINE', 18000.00, 37, 2023, 'img/diners.png', true, '5fcc48f5-84d9-436e-a613-1275695d0d61', '2026-06-05 02:00:57.000651', '2026-06-05 02:00:57.000651', '0123-4567', 'Diners Publishing', 96, 1008);
INSERT INTO public.publications VALUES ('5f2d239c-c65e-4d49-be5f-7b70daf564a9', 'El olvido que seremos', 'Memorias sobre la vida y muerte del padre del autor en Medellín.', 'BOOK', 65000.00, 32, 2006, 'img/olvido.png', true, '5b946e9b-eb35-4d13-a716-e806212dfb00', '2026-06-05 01:54:54.256814', '2026-06-05 01:54:54.256814', '9789587046138', 'Planeta', 412, 1507);
INSERT INTO public.publications VALUES ('1370d648-d852-4a92-9977-ae1bb0af0257', 'Cien años de soledad', 'La historia mítica de la familia Buendía en Macondo.', 'BOOK', 58000.00, 50, 1967, 'img/cienaños.png', true, '94231629-c4be-43d3-be58-8309855e3ddc', '2026-06-05 01:54:54.256814', '2026-06-05 01:54:54.256814', '9780307474728', 'Penguin Random House', 384, 442);
INSERT INTO public.publications VALUES ('b89aa72d-8883-4cf1-ba26-e04fc25106c8', 'Delirio', 'Una historia sobre amor, locura y violencia en Colombia.', 'BOOK', 52000.00, 41, 2004, 'img/delirio.png', false, '94231629-c4be-43d3-be58-8309855e3ddc', '2026-06-05 01:54:54.256814', '2026-06-05 01:54:54.256814', '9789587042925', 'Alfaguara', 312, 523);
INSERT INTO public.publications VALUES ('603f0ef9-61f6-4f40-9f12-249fb96e87b0', 'La vorágine', 'Crítica social sobre la explotación en la selva amazónica.', 'BOOK', 40000.00, 29, 1924, 'img/voragine.png', false, '460c970e-cd89-4b72-8ae4-2922e70c407f', '2026-06-05 01:54:54.256814', '2026-06-05 01:54:54.256814', '9789583001605', 'Panamericana', 298, 1042);
INSERT INTO public.publications VALUES ('2140298c-a73e-4edc-bf45-72a9b77b71e9', 'El ruido de las cosas al caer', 'Reflexión sobre la violencia y el narcotráfico en Colombia.', 'BOOK', 56000.00, 47, 2011, 'img/ruido.png', false, '5b946e9b-eb35-4d13-a716-e806212dfb00', '2026-06-05 01:54:54.256814', '2026-06-05 01:54:54.256814', '9780307950826', 'Alfaguara', 352, 365);
INSERT INTO public.publications VALUES ('510208ca-1c56-4e41-b59e-5db045ed62df', 'Satanás', 'Novela basada en hechos reales del atentado en Pozzetto.', 'BOOK', 42000.00, 60, 2002, 'img/satanas.png', true, '5b946e9b-eb35-4d13-a716-e806212dfb00', '2026-06-05 01:59:47.498641', '2026-06-05 01:59:47.498641', '9789587048880', 'Planeta', 286, 1352);
INSERT INTO public.publications VALUES ('11eec181-842f-4a9e-b904-11fcc5f9149a', 'El coronel no tiene quien le escriba', 'Historia de esperanza y pobreza en un pequeño pueblo colombiano.', 'BOOK', 38000.00, 38, 1961, 'img/coronel.png', true, '94231629-c4be-43d3-be58-8309855e3ddc', '2026-06-05 01:59:47.498641', '2026-06-05 01:59:47.498641', '9780307390752', 'Penguin Random House', 192, 1292);
INSERT INTO public.publications VALUES ('67faa064-7ea5-4874-92cc-19b004156893', 'La perra', 'Una mujer rural vive un deseo obsesivo de maternidad.', 'BOOK', 39000.00, 22, 2017, 'img/laperra.png', false, '5b946e9b-eb35-4d13-a716-e806212dfb00', '2026-06-05 01:59:47.498641', '2026-06-05 01:59:47.498641', '9789584266911', 'Random House', 204, 1039);
INSERT INTO public.publications VALUES ('22f64e57-05c8-4530-8c31-5ff0d197822c', 'El Quijote de la Mancha', 'Clásico de la literatura española sobre las aventuras de Don Quijote y Sancho Panza.', 'BOOK', 50000.00, 20, 1605, 'img/quijote.png', true, '460c970e-cd89-4b72-8ae4-2922e70c407f', '2026-06-05 01:59:47.498641', '2026-06-05 01:59:47.498641', '9788491050246', 'Alianza Editorial', 1024, 873);
INSERT INTO public.publications VALUES ('e6dfe805-840b-43d1-81f4-0382c86b99d7', 'La Isla del Tesoro', 'Aventura clásica de piratas en busca de un tesoro escondido.', 'BOOK', 42000.00, 18, 1883, 'img/islatesoro.png', false, '460c970e-cd89-4b72-8ae4-2922e70c407f', '2026-06-05 01:59:47.498641', '2026-06-05 01:59:47.498641', '9788497591346', 'Debolsillo', 320, 973);
INSERT INTO public.publications VALUES ('3853eeb1-0afc-4023-bb28-9f67aed50ed6', 'Cromos', 'Revista de entretenimiento y arte cultural.', 'MAGAZINE', 13000.00, 80, 2024, 'img/cromos.png', true, '5dc7bf92-0900-4323-991e-80ca7606cbed', '2026-06-05 02:00:57.000651', '2026-06-05 02:00:57.000651', '0120-0620', 'El Tiempo', 102, 283);
INSERT INTO public.publications VALUES ('66e9abd6-5f25-4e7c-a049-07241f81d370', 'Portafolio', 'Revista sobre economía, finanzas y negocios en Colombia.', 'MAGAZINE', 16000.00, 70, 2024, 'img/portafolio.png', true, 'ffa533dc-bcc5-4088-8684-04be0b4c3c2a', '2026-06-05 02:00:57.000651', '2026-06-05 02:00:57.000651', '0125-9876', 'Portafolio Publishing', 88, 1485);
INSERT INTO public.publications VALUES ('4fc7d366-6cdd-48aa-bfa4-8a6b760202bd', 'Arcadia', 'Revista cultural colombiana.', 'MAGAZINE', 15000.00, 70, 2023, 'img/arcadia.png', false, '5dc7bf92-0900-4323-991e-80ca7606cbed', '2026-06-05 02:00:57.000651', '2026-06-05 02:00:57.000651', '1900-589X', 'Grupo Semana', 84, 1031);
INSERT INTO public.publications VALUES ('c62a4dcf-fb61-4fc6-89fd-3c36545c96a0', 'Cómo entender el poder', 'Análisis del funcionamiento real del poder político y económico.', 'BOOK', 70000.00, 34, 2002, 'img/poder.png', false, 'ffa533dc-bcc5-4088-8684-04be0b4c3c2a', '2026-06-05 02:00:57.000651', '2026-06-05 02:00:57.000651', '9781583226876', 'Seven Stories Press', 368, 986);
INSERT INTO public.publications VALUES ('ee93bd7c-bfca-4653-ad5f-cdfea36b9ea9', 'Vogue Latinoamérica', 'Moda, belleza y tendencias.', 'MAGAZINE', 25000.00, 65, 2024, 'img/vogue.png', false, '5fcc48f5-84d9-436e-a613-1275695d0d61', '2026-06-05 02:01:41.095019', '2026-06-05 02:01:41.095019', '0042-8000', 'Condé Nast', 98, 939);
INSERT INTO public.publications VALUES ('430f74f8-bae3-4acf-af26-c4397908b2ec', 'El hombre en busca de sentido', 'Reflexiones desde los campos de concentración.', 'BOOK', 50000.00, 45, 1946, 'img/hombre-sentido.png', true, '5b946e9b-eb35-4d13-a716-e806212dfb00', '2026-06-05 02:01:41.095019', '2026-06-05 02:01:41.095019', '9780807014271', 'Beacon Press', 256, 1301);
INSERT INTO public.publications VALUES ('9dfcc543-e3c5-4e7f-91fc-f56d33e0126f', 'La casa de los espíritus', 'Novela dramática familiar y política en Chile.', 'BOOK', 48000.00, 40, 1982, 'img/casadeespiritus.png', true, '5b946e9b-eb35-4d13-a716-e806212dfb00', '2026-06-05 02:01:41.095019', '2026-06-05 02:01:41.095019', '9789580410774', 'Sudamericana', 448, 1083);
INSERT INTO public.publications VALUES ('29e6a880-3f9b-45a9-85b7-c32898fdcaf0', 'Soho', 'Revista de estilo de vida, fotografía y entrevistas.', 'MAGAZINE', 14000.00, 35, 2019, 'img/soho.png', true, '5fcc48f5-84d9-436e-a613-1275695d0d61', '2026-06-05 02:01:41.095019', '2026-06-05 02:01:41.095019', '0123-1787', 'Grupo Semana', 110, 278);
INSERT INTO public.publications VALUES ('0018d11d-b958-475e-a4ee-18103ee556d2', 'National Geographic en Español', 'Ciencia, naturaleza e investigación.', 'MAGAZINE', 22000.00, 75, 2024, 'img/natgeo.png', false, '5dc7bf92-0900-4323-991e-80ca7606cbed', '2026-06-05 02:01:41.095019', '2026-06-05 02:01:41.095019', '1542-8440', 'National Geographic', 114, 843);


--
-- Data for Name: reservations; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.reservations VALUES ('a42a164e-70a4-4a3e-9405-e25ca2cd8a0a', 'f6067f72-2eb9-4db1-a8a9-091db0c08be1', 'bfc0e476-6f4f-455c-8236-6f49031c8e39', '2026-06-10 09:00:00', '2026-06-10 11:00:00', 'ACTIVE', '2026-06-05 03:03:50.482888');


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.users VALUES ('f6067f72-2eb9-4db1-a8a9-091db0c08be1', 'Miguel Arias', 'miguel@test.com', NULL, '2026-05-28 04:56:51.047363', '2026-05-28 04:56:51.047363');
INSERT INTO public.users VALUES ('5203835f-064c-4227-944d-8c13720c613e', 'Laura Gómez', 'laura@test.com', NULL, '2026-05-28 04:56:51.047363', '2026-05-28 04:56:51.047363');
INSERT INTO public.users VALUES ('85c44eed-ab6b-40a4-8a52-a4e2f3e1f98b', 'Carlos Ruiz', 'carlos@test.com', NULL, '2026-05-28 04:56:51.047363', '2026-05-28 04:56:51.047363');


--
-- Name: authors authors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.authors
    ADD CONSTRAINT authors_pkey PRIMARY KEY (id);


--
-- Name: categories categories_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_name_key UNIQUE (name);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: categories categories_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_slug_key UNIQUE (slug);


--
-- Name: coworking_spaces coworking_spaces_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coworking_spaces
    ADD CONSTRAINT coworking_spaces_pkey PRIMARY KEY (id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (order_id, publication_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: publication_authors publication_authors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publication_authors
    ADD CONSTRAINT publication_authors_pkey PRIMARY KEY (publication_id, author_id);


--
-- Name: publications publications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publications
    ADD CONSTRAINT publications_pkey PRIMARY KEY (id);


--
-- Name: reservations reservations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservations
    ADD CONSTRAINT reservations_pkey PRIMARY KEY (id);


--
-- Name: users users_auth0_sub_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_auth0_sub_key UNIQUE (auth0_sub);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: order_items fk_order_item_order; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT fk_order_item_order FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: order_items fk_order_item_publication; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT fk_order_item_publication FOREIGN KEY (publication_id) REFERENCES public.publications(id) ON DELETE RESTRICT;


--
-- Name: orders fk_order_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_order_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: publication_authors fk_pa_author; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publication_authors
    ADD CONSTRAINT fk_pa_author FOREIGN KEY (author_id) REFERENCES public.authors(id) ON DELETE CASCADE;


--
-- Name: publication_authors fk_pa_publication; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publication_authors
    ADD CONSTRAINT fk_pa_publication FOREIGN KEY (publication_id) REFERENCES public.publications(id) ON DELETE CASCADE;


--
-- Name: publications fk_publication_category; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publications
    ADD CONSTRAINT fk_publication_category FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE RESTRICT;


--
-- Name: reservations fk_reservation_space; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservations
    ADD CONSTRAINT fk_reservation_space FOREIGN KEY (coworking_space_id) REFERENCES public.coworking_spaces(id) ON DELETE RESTRICT;


--
-- Name: reservations fk_reservation_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservations
    ADD CONSTRAINT fk_reservation_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict kGXL45IRRyCUFt5hyEoh2XGdmP6Ndrmv9oQWjgdGQfsCgg04hbfOnVLo90cUNjw

