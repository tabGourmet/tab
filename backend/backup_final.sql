--
-- PostgreSQL database dump
--

\restrict sU5c51cm6Ch7U8BIHytPYko0Cx9IMkYTqsFvG12qDg7rHdb54yQ7DLYPkdah1mO

-- Dumped from database version 15.15 (Debian 15.15-1.pgdg13+1)
-- Dumped by pg_dump version 15.15 (Debian 15.15-1.pgdg13+1)

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
-- Name: OrderItemStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."OrderItemStatus" AS ENUM (
    'PENDING',
    'PREPARING',
    'SERVED',
    'CANCELLED'
);


--
-- Name: OrderStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."OrderStatus" AS ENUM (
    'OPEN',
    'CLOSED'
);


--
-- Name: ServiceCallStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."ServiceCallStatus" AS ENUM (
    'PENDING',
    'RESOLVED'
);


--
-- Name: ServiceCallType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."ServiceCallType" AS ENUM (
    'WAITER',
    'BILL',
    'OTHER'
);


--
-- Name: SessionStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."SessionStatus" AS ENUM (
    'ACTIVE',
    'PAYMENT_PENDING',
    'CLOSED'
);


--
-- Name: UserRole; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."UserRole" AS ENUM (
    'OWNER',
    'ADMIN',
    'STAFF'
);


--
-- Name: UserStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."UserStatus" AS ENUM (
    'ACTIVE',
    'TRIAL',
    'INACTIVE'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id text NOT NULL,
    restaurant_id text NOT NULL,
    name text NOT NULL,
    image_url text,
    display_order integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL
);


--
-- Name: consumers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.consumers (
    id text NOT NULL,
    session_id text NOT NULL,
    name text NOT NULL,
    joined_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: domain_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.domain_events (
    id text NOT NULL,
    restaurant_id text NOT NULL,
    event_type text NOT NULL,
    payload jsonb DEFAULT '{}'::jsonb NOT NULL,
    occurred_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: order_item_consumers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_item_consumers (
    order_item_id text NOT NULL,
    consumer_id text NOT NULL
);


--
-- Name: order_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_items (
    id text NOT NULL,
    order_id text NOT NULL,
    product_id text NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    unit_price numeric(10,2) NOT NULL,
    status public."OrderItemStatus" DEFAULT 'PENDING'::public."OrderItemStatus" NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orders (
    id text NOT NULL,
    session_id text NOT NULL,
    status public."OrderStatus" DEFAULT 'OPEN'::public."OrderStatus" NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id text NOT NULL,
    restaurant_id text NOT NULL,
    category_id text NOT NULL,
    name text NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    price numeric(10,2) NOT NULL,
    image_url text,
    is_available boolean DEFAULT true NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: restaurants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.restaurants (
    id text NOT NULL,
    name text NOT NULL,
    slug text NOT NULL,
    timezone text DEFAULT 'America/Argentina/Buenos_Aires'::text NOT NULL,
    settings jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    owner_id text
);


--
-- Name: service_calls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.service_calls (
    id text NOT NULL,
    session_id text,
    type public."ServiceCallType" NOT NULL,
    status public."ServiceCallStatus" DEFAULT 'PENDING'::public."ServiceCallStatus" NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    resolved_at timestamp(3) without time zone,
    restaurant_id text
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id text NOT NULL,
    table_id text NOT NULL,
    status public."SessionStatus" DEFAULT 'ACTIVE'::public."SessionStatus" NOT NULL,
    started_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ended_at timestamp(3) without time zone
);


--
-- Name: tables; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tables (
    id text NOT NULL,
    restaurant_id text NOT NULL,
    number text NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    qr_code_url text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id text NOT NULL,
    email text NOT NULL,
    password_hash text NOT NULL,
    role public."UserRole" DEFAULT 'OWNER'::public."UserRole" NOT NULL,
    status public."UserStatus" DEFAULT 'TRIAL'::public."UserStatus" NOT NULL,
    first_name text,
    last_name text,
    phone text,
    business_name text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    last_login_at timestamp(3) without time zone,
    trial_ends_at timestamp(3) without time zone
);


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) VALUES ('cc0388d6-bfc8-4661-b263-60fa4ef96d78', '460677cb1ffdcdf13457551bf4977aeac932290df3873216f53b1ed8d21eff86', '2026-01-27 21:24:05.529109+00', '20260122150045_init', NULL, NULL, '2026-01-27 21:24:05.394108+00', 1);
INSERT INTO public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) VALUES ('b840c59d-9049-484a-b5b0-c974632257fe', 'a87f8274f95b27784fc93b7c8eb4088136bb83a880e594c68d554308ed025267', '2026-01-27 22:28:31.263813+00', '20260127222831_add_service_call_restaurant_id', NULL, NULL, '2026-01-27 22:28:31.250429+00', 1);
INSERT INTO public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) VALUES ('191c482d-a471-4f7c-8f81-c2ecd56ea50a', '1bd5f5fa23ca8557c173ff281cc9b6cf63ddce93e78591b627f41d0b435661fe', '2026-01-27 23:22:44.064851+00', '20260127232244_add_user_model', NULL, NULL, '2026-01-27 23:22:44.044641+00', 1);


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.categories (id, restaurant_id, name, image_url, display_order, is_active) VALUES ('cat-bebidas', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'Bebidas', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?auto=format&fit=crop&w=800&q=80', 3, true);
INSERT INTO public.categories (id, restaurant_id, name, image_url, display_order, is_active) VALUES ('cat-entradas', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'Entradas', 'https://images.unsplash.com/photo-1541014741259-de529411b96a?auto=format&fit=crop&w=800&q=80', 1, true);
INSERT INTO public.categories (id, restaurant_id, name, image_url, display_order, is_active) VALUES ('cat-comida', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'Comida', 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=800&q=80', 2, true);
INSERT INTO public.categories (id, restaurant_id, name, image_url, display_order, is_active) VALUES ('cat-postres', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'Postres', 'https://images.unsplash.com/photo-1551024601-bec78aea704b?auto=format&fit=crop&w=800&q=80', 4, true);
INSERT INTO public.categories (id, restaurant_id, name, image_url, display_order, is_active) VALUES ('9e4c3f92-2550-46be-ac3e-87611d0bf59a', '48aa5c94-579d-4d7a-bb26-12c3b266bb78', 'Entradas', 'https://images.unsplash.com/photo-1541014741259-de529411b96a?auto=format&fit=crop&w=800&q=80', 1, true);
INSERT INTO public.categories (id, restaurant_id, name, image_url, display_order, is_active) VALUES ('80db926c-4c09-42f8-92e9-09f4eb592e94', '48aa5c94-579d-4d7a-bb26-12c3b266bb78', 'Comida', 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=800&q=80', 2, true);
INSERT INTO public.categories (id, restaurant_id, name, image_url, display_order, is_active) VALUES ('90ede13f-2a04-44a2-9121-f6c49ccf5021', '48aa5c94-579d-4d7a-bb26-12c3b266bb78', 'Bebidas', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?auto=format&fit=crop&w=800&q=80', 3, true);
INSERT INTO public.categories (id, restaurant_id, name, image_url, display_order, is_active) VALUES ('6467fef3-3a4f-4be4-9c82-e09e465b86f6', '48aa5c94-579d-4d7a-bb26-12c3b266bb78', 'Postres', 'https://images.unsplash.com/photo-1551024601-bec78aea704b?auto=format&fit=crop&w=800&q=80', 4, true);


--
-- Data for Name: consumers; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('ec1811cd-1a27-4ae0-8a41-44b0139d9576', '505752fd-88c6-4bcf-bfd1-13e95c0a5143', 'SPIDER', '2026-01-28 00:16:48.285');
INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('b2bcdf7f-4db9-4aa2-8021-c862ebb3ea4b', '1471ab8e-25e1-4107-b64c-25e51f6aba31', 'asdasd', '2026-02-09 17:48:24.944');
INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('0a0bdcbc-5a94-4084-a0e3-ec704b26dff6', '1471ab8e-25e1-4107-b64c-25e51f6aba31', 'Julia Lopez', '2026-02-09 17:58:10.602');
INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('c9c05b94-eb2d-4028-8396-88bb22866102', '4ee894f6-1567-478f-a4de-41956eb7ae0d', 'Martin Gonzales', '2026-02-09 17:59:21.779');
INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('424043cf-8c6d-469a-b24c-ae56c6a15e60', '4ee894f6-1567-478f-a4de-41956eb7ae0d', 'SDF', '2026-02-09 18:07:20.485');
INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('e0aa5bf9-5a60-415e-884e-ecb7bec92dcf', '1f7dec00-b5b1-476c-9caf-91842a44fcab', 'alguien', '2026-02-09 18:39:28.636');
INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('1363385b-8eac-4a1c-a40c-1ce4ba248e0b', '1f7dec00-b5b1-476c-9caf-91842a44fcab', 'alguien 2', '2026-02-09 18:44:57.28');
INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('1d0d2327-6340-486a-9e17-b5f7caaf2b16', '1f7dec00-b5b1-476c-9caf-91842a44fcab', 'alguien 3', '2026-02-09 18:45:53.646');
INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('f411264e-074e-43b3-8de9-8cc9eb6a44c2', '1f7dec00-b5b1-476c-9caf-91842a44fcab', 'alguien 4', '2026-02-09 18:47:36.636');
INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('5e7b5628-17e6-4056-bba7-5b1ac6b93e92', '7c152543-d41d-42ea-8860-0697825ce78d', 'Test User', '2026-02-12 17:48:37.981');
INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('f6fcd1e3-16ef-47eb-9f67-1c14166e63a9', '7c152543-d41d-42ea-8860-0697825ce78d', 'Test User2', '2026-02-12 17:51:41.191');
INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('920df71e-8156-47a1-8c8e-db949259efec', '6464461a-d145-430b-a982-bb971cc61db9', 'Martin Casanova', '2026-02-14 13:06:13.628');
INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('9bd6b911-a101-4ef9-b93d-d51c1634dbd0', '6464461a-d145-430b-a982-bb971cc61db9', 'SPIDER', '2026-02-14 13:07:44.759');
INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('8709e22f-81d5-4822-a56f-c032c14655a7', '6464461a-d145-430b-a982-bb971cc61db9', 'asdasd', '2026-02-14 13:17:59.437');
INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('81e5089b-c6a8-4797-b60f-0abbb35afa47', '6464461a-d145-430b-a982-bb971cc61db9', 'jjjjj', '2026-02-14 13:19:02.894');
INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('d492b8b3-7a4d-4a67-894e-1ded6026c170', '58f3ea13-0311-4913-8cde-b352f1cb2c6f', 'Martin Casanova', '2026-02-15 16:33:19.824');
INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('bd2cce15-8759-4272-84e6-87f8457439a3', '58f3ea13-0311-4913-8cde-b352f1cb2c6f', 'llll', '2026-02-15 16:42:28.38');
INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('e2ea28a1-4afa-4baf-804c-0b52dcd3b1ad', '58f3ea13-0311-4913-8cde-b352f1cb2c6f', 'uuuuu', '2026-02-15 16:50:42.732');
INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('dc0c92e9-1ed4-4f20-ab7c-60f9176f65ff', '58f3ea13-0311-4913-8cde-b352f1cb2c6f', 'aaaaa', '2026-02-15 16:51:53.426');
INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('924345a4-15b0-433a-95ee-0ce128a74bc6', '58f3ea13-0311-4913-8cde-b352f1cb2c6f', 'www', '2026-02-15 16:55:59.936');
INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('2b89389b-5a28-4c17-9ec9-c4651e472880', '58f3ea13-0311-4913-8cde-b352f1cb2c6f', 'wwww', '2026-02-15 16:56:23.294');
INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('673304df-159b-4e15-84c7-5312b0e7b992', '58f3ea13-0311-4913-8cde-b352f1cb2c6f', 'ghjghj', '2026-02-15 16:59:18.764');
INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('cc72588b-a0d1-4a62-91bf-b14e2103313b', '58f3ea13-0311-4913-8cde-b352f1cb2c6f', 'Martin Casanova', '2026-02-15 17:01:05.167');
INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('db1ad794-d89a-4ca6-8fa7-5984f252cdd9', '8cf0cf6b-8c1c-4767-af87-c502dfa29755', 'alguien', '2026-02-15 17:17:34.098');
INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('ec11a6b1-3ab0-4ca9-8577-1af6a80a862d', '51937dc5-e017-4b4a-ab80-f40755d12c7e', 'ttt', '2026-02-15 18:30:29.217');
INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('b224452d-dbeb-4fa4-88a3-7a2c90bcf45b', '51937dc5-e017-4b4a-ab80-f40755d12c7e', 'llllllll', '2026-02-19 15:14:29.192');
INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('5e16f470-0447-4231-82a6-4fbedd98aed3', 'bd975644-ef20-4abb-a26e-ceefa9477f03', 'fghfghfghfgh', '2026-02-20 23:07:16.741');
INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('8f03fb55-0fec-4f83-a00e-8e0a482b1729', 'bd975644-ef20-4abb-a26e-ceefa9477f03', 'hjkghkgjk', '2026-02-20 23:07:46.499');
INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('9fd96c35-8c58-4e23-9426-783fb2a8a7d1', 'bd975644-ef20-4abb-a26e-ceefa9477f03', 'oooooooo', '2026-02-20 23:17:36.344');
INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('66be3f8b-238b-4688-9109-4a432c5dd3a5', 'f3013e06-af6d-4f8a-9eea-27a5c751f0b6', 'dddddddddddd', '2026-02-20 23:18:43.887');
INSERT INTO public.consumers (id, session_id, name, joined_at) VALUES ('b1318f5b-4248-4dab-9089-e10e48325ded', 'f3013e06-af6d-4f8a-9eea-27a5c751f0b6', '├▒lkkjh', '2026-02-20 23:19:48.243');


--
-- Data for Name: domain_events; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('c368fff1-a3dc-4aec-abaa-41604efb76ac', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'TABLE_CREATED', '{"number": "11", "tableId": "986244c1-48cd-4655-9364-88396003cb58"}', '2026-01-27 21:30:12.878');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('07e4a27e-538d-4fd3-9cb7-94aa5b009944', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'PRODUCT_CREATED', '{"name": "Aguita fresca", "price": 1500, "category": "Bebidas", "productId": "b83ecbcf-f7fa-4cb9-a8c7-ec91cf65cf4c"}', '2026-01-27 21:53:22.317');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('7de38a8c-3ef2-49cf-8b1c-f79ab33e753b', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'PRODUCT_UPDATED', '{"name": "Aguita fresca", "price": 15, "productId": "b83ecbcf-f7fa-4cb9-a8c7-ec91cf65cf4c", "isAvailable": true}', '2026-01-27 22:14:50.585');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('e5e24543-c5a2-459e-9501-54dcac720e39', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'PRODUCT_UPDATED', '{"name": "Aguita ", "price": 15, "productId": "b83ecbcf-f7fa-4cb9-a8c7-ec91cf65cf4c", "isAvailable": true}', '2026-01-27 22:15:00.737');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('85db326b-8003-46a5-b92b-b1abe2d95a74', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'WAITER_CALLED', '{"callId": "cabc30a4-dd45-439f-b18b-2f63bafdbb80", "location": "Entrance"}', '2026-01-27 22:30:40.497');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('e19c419b-82d2-469b-a9ff-ebd60755bf53', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'WAITER_CALLED', '{"callId": "55e83a5e-0b50-4d87-9406-e093767152e5", "location": "Entrance"}', '2026-01-27 22:30:54.469');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('070f9ef9-a845-43d2-9d48-5c5dae7504e9', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'WAITER_CALLED', '{"callId": "d93b0fbe-f877-47e5-b285-f98e07a1d36b", "location": "Entrance"}', '2026-01-27 22:44:48.988');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('b18a3495-c7fc-45f0-9b35-174af2b49443', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'TABLE_CREATED', '{"number": "1", "tableId": "1e9a335d-36dd-44b8-b8d6-ba0077059e5c"}', '2026-01-27 23:54:07.518');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('9727486b-9b37-44da-bf19-337393f5ab82', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'TABLE_CREATED', '{"number": "2", "tableId": "e29414ea-4acd-4007-9999-78650cfd4a30"}', '2026-01-27 23:54:07.518');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('47bbf8cd-aa76-435a-94bb-d9305b6fd8b4', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'TABLE_CREATED', '{"number": "3", "tableId": "655bbca2-72bd-4168-af1d-628dd068720b"}', '2026-01-27 23:54:07.528');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('505329d1-e820-4c46-849e-13297896c0ef', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'TABLE_CREATED', '{"number": "4", "tableId": "c8deaf7b-bf70-4a6b-ab77-04a4ccd0b5d8"}', '2026-01-27 23:54:07.529');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('4c223cad-1423-4488-ac49-21b6b6226972', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'TABLE_CREATED', '{"number": "5", "tableId": "ff3bbbcb-1aa0-40d0-ad65-a849e96db668"}', '2026-01-27 23:54:07.53');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('cce51451-1073-4802-a847-ab862331ec83', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'WAITER_CALLED', '{"callId": "8284930d-8207-4693-9394-7ae5ef85152a", "location": "Entrance"}', '2026-01-28 00:05:59.87');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('b9d35452-7a48-459c-9e4f-67e86edd46fd', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'SESSION_STARTED', '{"tableId": "d65613d3-dd52-4208-8f4a-6dbff42589e5", "sessionId": "505752fd-88c6-4bcf-bfd1-13e95c0a5143", "tableNumber": "1", "firstConsumer": "SPIDER"}', '2026-01-28 00:16:48.291');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('28584ac7-5c2a-4a55-afff-968fe9a364ed', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'ORDER_PLACED', '{"orderId": "6472b21c-e371-4647-94a4-95eecba49287", "itemCount": 1, "sessionId": "505752fd-88c6-4bcf-bfd1-13e95c0a5143", "tableNumber": "1"}', '2026-01-28 00:17:34.406');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('3cc08500-ca41-43d5-8180-35a3cffac5a5', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'WAITER_CALLED', '{"sessionId": "505752fd-88c6-4bcf-bfd1-13e95c0a5143", "tableNumber": "1"}', '2026-01-28 00:16:54.252');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('1ae5f939-7c25-44b7-851e-6d1d6ca0a21c', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'ORDER_PLACED', '{"orderId": "6472b21c-e371-4647-94a4-95eecba49287", "itemCount": 1, "sessionId": "505752fd-88c6-4bcf-bfd1-13e95c0a5143", "tableNumber": "1"}', '2026-01-28 00:17:13.719');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('31d4b5c0-c834-43f8-90e5-b1967e1323df', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'TABLE_CREATED', '{"number": "1", "tableId": "d65613d3-dd52-4208-8f4a-6dbff42589e5"}', '2026-01-28 00:16:42.542');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('d086d10f-623d-4d8f-a4ae-e2fbb66fbc72', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'ORDER_PLACED', '{"orderId": "6472b21c-e371-4647-94a4-95eecba49287", "itemCount": 1, "sessionId": "505752fd-88c6-4bcf-bfd1-13e95c0a5143", "tableNumber": "1"}', '2026-01-28 00:27:28.4');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('0c2663fb-ab17-4d6b-8907-5806e0000d81', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'WAITER_CALLED', '{"sessionId": "505752fd-88c6-4bcf-bfd1-13e95c0a5143", "tableNumber": "1"}', '2026-01-28 00:27:34.073');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('0e46d13b-e508-41b2-9731-5dcdd8a47759', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'BILL_REQUESTED', '{"sessionId": "505752fd-88c6-4bcf-bfd1-13e95c0a5143", "tableNumber": "1"}', '2026-01-28 00:36:41.001');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('5d15bcf3-4c07-4648-88aa-67663a9d3f4c', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'WAITER_CALLED', '{"sessionId": "505752fd-88c6-4bcf-bfd1-13e95c0a5143", "tableNumber": "1"}', '2026-01-28 00:36:41.596');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('75657f47-55f6-45e5-9daf-9d87f074dc30', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'WAITER_CALLED', '{"callId": "74cd77ca-4785-443d-8b1e-3ffca6179835", "location": "Entrance"}', '2026-02-07 20:55:55.932');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('a1f2be2c-8181-4cd5-9db9-4587b19ea685', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'TABLE_CREATED', '{"number": "5", "tableId": "8e50385e-c3e3-48c9-a5dd-8864ab730847"}', '2026-02-07 22:59:21.087');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('53fd2368-6572-4b60-8424-e934cd0c5303', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'PRODUCT_UPDATED', '{"name": "Ensalada C├®s", "price": 9500, "productId": "prod-6", "isAvailable": true}', '2026-02-07 22:59:32.626');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('2b983edf-e581-493b-8df3-5d9cef95c717', '48aa5c94-579d-4d7a-bb26-12c3b266bb78', 'SESSION_STARTED', '{"tableId": "f88fa4c6-fb48-42f8-ac80-0a40cc8bfa64", "sessionId": "1471ab8e-25e1-4107-b64c-25e51f6aba31", "tableNumber": "1", "firstConsumer": "asdasd"}', '2026-02-09 17:48:24.953');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('1e646aee-ddde-4e83-8a95-9566a654cb6c', '48aa5c94-579d-4d7a-bb26-12c3b266bb78', 'CONSUMER_JOINED', '{"name": "Julia Lopez", "sessionId": "1471ab8e-25e1-4107-b64c-25e51f6aba31", "consumerId": "0a0bdcbc-5a94-4084-a0e3-ec704b26dff6", "tableNumber": "1"}', '2026-02-09 17:58:10.604');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('a59c22e8-bde7-4892-b350-38d2bb3b2747', '48aa5c94-579d-4d7a-bb26-12c3b266bb78', 'SESSION_STARTED', '{"tableId": "9366dfec-1ac7-47c0-9338-3ad4bccd2081", "sessionId": "4ee894f6-1567-478f-a4de-41956eb7ae0d", "tableNumber": "2", "firstConsumer": "Martin Gonzales"}', '2026-02-09 17:59:21.786');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('48b61482-1281-4aa7-bb60-33fb5c34e300', '48aa5c94-579d-4d7a-bb26-12c3b266bb78', 'CONSUMER_JOINED', '{"name": "SDF", "sessionId": "4ee894f6-1567-478f-a4de-41956eb7ae0d", "consumerId": "424043cf-8c6d-469a-b24c-ae56c6a15e60", "tableNumber": "2"}', '2026-02-09 18:07:20.489');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('b2df0a35-f5e5-4d08-957a-bb249ce2780e', '48aa5c94-579d-4d7a-bb26-12c3b266bb78', 'SESSION_STARTED', '{"tableId": "6e427177-78d7-48b0-9398-e0b72ae0136e", "sessionId": "1f7dec00-b5b1-476c-9caf-91842a44fcab", "tableNumber": "4", "firstConsumer": "alguien"}', '2026-02-09 18:39:28.644');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('9cd24215-40f9-4382-96b3-ca5e7a2f61dd', '48aa5c94-579d-4d7a-bb26-12c3b266bb78', 'CONSUMER_JOINED', '{"name": "alguien 2", "sessionId": "1f7dec00-b5b1-476c-9caf-91842a44fcab", "consumerId": "1363385b-8eac-4a1c-a40c-1ce4ba248e0b", "tableNumber": "4"}', '2026-02-09 18:44:57.283');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('9476e9a0-0acf-4f7b-ab36-13e547fcbf25', '48aa5c94-579d-4d7a-bb26-12c3b266bb78', 'CONSUMER_JOINED', '{"name": "alguien 3", "sessionId": "1f7dec00-b5b1-476c-9caf-91842a44fcab", "consumerId": "1d0d2327-6340-486a-9e17-b5f7caaf2b16", "tableNumber": "4"}', '2026-02-09 18:45:53.649');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('ab920678-57a3-4fd6-af50-d9c7dfe278bb', '48aa5c94-579d-4d7a-bb26-12c3b266bb78', 'PRODUCT_CREATED', '{"name": "algo", "price": 50, "category": "Entradas", "productId": "df1c694a-0eac-4d5a-b699-a5a6a31c91a9"}', '2026-02-09 18:47:06.242');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('1a39e6b7-a9d8-4f55-958d-ef228cb7df87', '48aa5c94-579d-4d7a-bb26-12c3b266bb78', 'CONSUMER_JOINED', '{"name": "alguien 4", "sessionId": "1f7dec00-b5b1-476c-9caf-91842a44fcab", "consumerId": "f411264e-074e-43b3-8de9-8cc9eb6a44c2", "tableNumber": "4"}', '2026-02-09 18:47:36.639');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('7c8046cc-af01-4aee-b1a7-1c2efb214ed3', '48aa5c94-579d-4d7a-bb26-12c3b266bb78', 'ITEM_SHARED', '{"productId": "df1c694a-0eac-4d5a-b699-a5a6a31c91a9", "orderItemId": "9cbc02bc-3179-4d8c-9c3d-05224ec1b268", "productName": "algo", "consumerCount": 4}', '2026-02-09 18:48:02.296');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('b4c74ff3-b64d-4ddd-9b1a-8258632f0e7c', '48aa5c94-579d-4d7a-bb26-12c3b266bb78', 'ORDER_PLACED', '{"orderId": "d8483e8f-913f-416a-861c-fd7efac25c93", "itemCount": 1, "sessionId": "1f7dec00-b5b1-476c-9caf-91842a44fcab", "tableNumber": "4"}', '2026-02-09 18:48:02.299');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('f24baf48-cd6e-468c-bf48-6453d1237041', '48aa5c94-579d-4d7a-bb26-12c3b266bb78', 'WAITER_CALLED', '{"sessionId": "1f7dec00-b5b1-476c-9caf-91842a44fcab", "tableNumber": "4"}', '2026-02-09 18:48:14.89');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('53bdb699-c579-4728-95ef-82a40a7bc3c9', '48aa5c94-579d-4d7a-bb26-12c3b266bb78', 'WAITER_CALLED', '{"sessionId": "1f7dec00-b5b1-476c-9caf-91842a44fcab", "tableNumber": "4"}', '2026-02-09 18:48:16.388');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('b0ba3667-3fb7-4f95-9298-19aa97c6b102', '48aa5c94-579d-4d7a-bb26-12c3b266bb78', 'BILL_REQUESTED', '{"sessionId": "1f7dec00-b5b1-476c-9caf-91842a44fcab", "tableNumber": "4"}', '2026-02-09 18:48:17.38');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('9274942a-8e76-4c40-93c5-725372b1240b', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'ORDER_PLACED', '{"orderId": "fab60072-73a0-42af-b758-64b31cc3d17d", "itemCount": 1, "sessionId": "6464461a-d145-430b-a982-bb971cc61db9", "tableNumber": "1"}', '2026-02-14 13:19:18.496');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('72388f0d-0276-4734-b9e3-e93885261f65', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'BILL_REQUESTED', '{"sessionId": "6464461a-d145-430b-a982-bb971cc61db9", "tableNumber": "1"}', '2026-02-14 13:20:00.944');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('8b7971f9-887e-4e21-8210-966ae3447ac2', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'WAITER_CALLED', '{"sessionId": "6464461a-d145-430b-a982-bb971cc61db9", "tableNumber": "1"}', '2026-02-14 13:20:16.42');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('51372486-e509-4d6d-b5b7-6fc21afa8278', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'WAITER_CALLED', '{"sessionId": "6464461a-d145-430b-a982-bb971cc61db9", "tableNumber": "1"}', '2026-02-14 13:20:38.711');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('1e6f4d64-059e-4767-a445-d40375eaa97b', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'BILL_REQUESTED', '{"sessionId": "6464461a-d145-430b-a982-bb971cc61db9", "tableNumber": "1"}', '2026-02-14 13:20:40.04');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('795749d2-fe12-4086-abea-d10b4afea7f8', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'WAITER_CALLED', '{"callId": "c4009e3f-2617-4880-bd70-1dd6088441ef", "location": "Entrance"}', '2026-02-15 16:56:13.807');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('8e2f1a75-8bd6-4e84-96a7-6d7302234076', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'ORDER_PLACED', '{"orderId": "93027d28-46d6-4771-b619-18c430abde78", "itemCount": 1, "sessionId": "58f3ea13-0311-4913-8cde-b352f1cb2c6f", "tableNumber": "1"}', '2026-02-15 16:56:30.633');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('668b2ed3-c2df-46c5-a56c-d0c58c9c90bb', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'BILL_REQUESTED', '{"sessionId": "58f3ea13-0311-4913-8cde-b352f1cb2c6f", "tableNumber": "1"}', '2026-02-15 17:02:39.52');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('6c04f48d-84ea-4b03-9f8e-d95fedcd0d85', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'WAITER_CALLED', '{"sessionId": "58f3ea13-0311-4913-8cde-b352f1cb2c6f", "tableNumber": "1"}', '2026-02-15 17:02:50.206');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('5e5775a1-e84c-4f2a-8988-d651fe123f4b', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'BILL_REQUESTED', '{"sessionId": "58f3ea13-0311-4913-8cde-b352f1cb2c6f", "tableNumber": "1"}', '2026-02-15 17:02:54.332');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('71559604-2ee7-4b2f-b433-3dc330153182', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'WAITER_CALLED', '{"sessionId": "58f3ea13-0311-4913-8cde-b352f1cb2c6f", "tableNumber": "1"}', '2026-02-15 17:02:55.123');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('8c7d33d5-5911-4d27-bb99-1c1ddf2afcef', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'BILL_REQUESTED', '{"sessionId": "58f3ea13-0311-4913-8cde-b352f1cb2c6f", "tableNumber": "1"}', '2026-02-15 17:02:55.515');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('08e6f16d-03d9-49db-bc90-e84df0ebb5d2', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'BILL_REQUESTED', '{"sessionId": "58f3ea13-0311-4913-8cde-b352f1cb2c6f", "tableNumber": "1"}', '2026-02-15 17:02:55.857');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('1dcf1e0c-a99c-4fee-bce8-7946ea2bdb3e', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'TABLE_CREATED', '{"number": "6", "tableId": "aa76e95f-0085-412d-8c95-a2d8e6365f10"}', '2026-02-15 17:17:03.711');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('eef30fd0-4aad-45e7-b1af-ac73d406a629', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'ORDER_PLACED', '{"orderId": "715c6c15-d85a-4ece-8a6e-e53ccab5c0d6", "itemCount": 1, "sessionId": "8cf0cf6b-8c1c-4767-af87-c502dfa29755", "tableNumber": "6"}', '2026-02-15 17:17:54.854');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('fd08d794-4bc2-47aa-96aa-4cd436d07fe7', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'BILL_REQUESTED', '{"sessionId": "8cf0cf6b-8c1c-4767-af87-c502dfa29755", "tableNumber": "6"}', '2026-02-15 17:18:05.9');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('b8db6330-e6c6-4228-ade8-5cd79d6646e3', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'WAITER_CALLED', '{"callId": "99b82a8c-93ae-4647-8460-71d2601d8396", "location": "Entrance"}', '2026-02-15 17:49:07.509');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('175101a4-3b0f-4d21-a30a-38ceaf90bddf', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'ORDER_PLACED', '{"orderId": "8936e5ea-7447-4374-ac12-db014ba5ecd8", "itemCount": 1, "sessionId": "51937dc5-e017-4b4a-ab80-f40755d12c7e", "tableNumber": "6"}', '2026-02-15 18:40:17.404');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('4dce11ac-4bdc-4ff2-879c-39b97614d579', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'WAITER_CALLED', '{"sessionId": "51937dc5-e017-4b4a-ab80-f40755d12c7e", "tableNumber": "6"}', '2026-02-15 18:51:23.869');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('d61cf77f-a9f8-4fd7-a04e-ed48ef97778f', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'SESSION_CLOSED', '{"duration": 74778751, "sessionId": "f3013e06-af6d-4f8a-9eea-27a5c751f0b6", "tableNumber": "3"}', '2026-02-21 20:05:02.649');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('aa5f7241-7a83-4a98-b74a-3403cebb3f39', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'SESSION_CLOSED', '{"duration": 531119110, "sessionId": "58f3ea13-0311-4913-8cde-b352f1cb2c6f", "tableNumber": "1"}', '2026-02-21 20:05:18.938');
INSERT INTO public.domain_events (id, restaurant_id, event_type, payload, occurred_at) VALUES ('c152023b-38b0-49af-8c5b-d515e4b056e4', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'SESSION_CLOSED', '{"duration": 75494032, "sessionId": "bd975644-ef20-4abb-a26e-ceefa9477f03", "tableNumber": "1"}', '2026-02-21 20:05:30.779');


--
-- Data for Name: order_item_consumers; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.order_item_consumers (order_item_id, consumer_id) VALUES ('8d9f263a-dea8-48da-818a-4c580fb1dc9d', 'ec1811cd-1a27-4ae0-8a41-44b0139d9576');
INSERT INTO public.order_item_consumers (order_item_id, consumer_id) VALUES ('f36e8eea-f9db-4201-bc76-b61e76f0935c', 'ec1811cd-1a27-4ae0-8a41-44b0139d9576');
INSERT INTO public.order_item_consumers (order_item_id, consumer_id) VALUES ('51b7d29f-2bf2-4f72-876b-94692a3cf9af', 'ec1811cd-1a27-4ae0-8a41-44b0139d9576');
INSERT INTO public.order_item_consumers (order_item_id, consumer_id) VALUES ('a0a0944f-a970-41eb-afe0-38663a81d3fb', '81e5089b-c6a8-4797-b60f-0abbb35afa47');
INSERT INTO public.order_item_consumers (order_item_id, consumer_id) VALUES ('87127f7e-9de6-48ad-a2cb-2b9593bd9dc1', '2b89389b-5a28-4c17-9ec9-c4651e472880');
INSERT INTO public.order_item_consumers (order_item_id, consumer_id) VALUES ('433e2c40-e106-435b-bfc5-3e744eddfe53', 'db1ad794-d89a-4ca6-8fa7-5984f252cdd9');
INSERT INTO public.order_item_consumers (order_item_id, consumer_id) VALUES ('14ca5640-4237-4264-839f-0c7763205ca8', 'ec11a6b1-3ab0-4ca9-8577-1af6a80a862d');


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.order_items (id, order_id, product_id, quantity, unit_price, status, created_at) VALUES ('8d9f263a-dea8-48da-818a-4c580fb1dc9d', '6472b21c-e371-4647-94a4-95eecba49287', 'prod-5', 1, 2000.00, 'PENDING', '2026-01-28 00:17:13.713');
INSERT INTO public.order_items (id, order_id, product_id, quantity, unit_price, status, created_at) VALUES ('f36e8eea-f9db-4201-bc76-b61e76f0935c', '6472b21c-e371-4647-94a4-95eecba49287', 'prod-1', 1, 12000.00, 'PENDING', '2026-01-28 00:17:34.399');
INSERT INTO public.order_items (id, order_id, product_id, quantity, unit_price, status, created_at) VALUES ('51b7d29f-2bf2-4f72-876b-94692a3cf9af', '6472b21c-e371-4647-94a4-95eecba49287', 'prod-6', 1, 9500.00, 'PENDING', '2026-01-28 00:27:28.389');
INSERT INTO public.order_items (id, order_id, product_id, quantity, unit_price, status, created_at) VALUES ('a0a0944f-a970-41eb-afe0-38663a81d3fb', 'fab60072-73a0-42af-b758-64b31cc3d17d', 'prod-5', 1, 2000.00, 'PENDING', '2026-02-14 13:19:18.484');
INSERT INTO public.order_items (id, order_id, product_id, quantity, unit_price, status, created_at) VALUES ('87127f7e-9de6-48ad-a2cb-2b9593bd9dc1', '93027d28-46d6-4771-b619-18c430abde78', 'prod-5', 1, 2000.00, 'PENDING', '2026-02-15 16:56:30.62');
INSERT INTO public.order_items (id, order_id, product_id, quantity, unit_price, status, created_at) VALUES ('433e2c40-e106-435b-bfc5-3e744eddfe53', '715c6c15-d85a-4ece-8a6e-e53ccab5c0d6', 'prod-5', 1, 2000.00, 'PENDING', '2026-02-15 17:17:54.847');
INSERT INTO public.order_items (id, order_id, product_id, quantity, unit_price, status, created_at) VALUES ('14ca5640-4237-4264-839f-0c7763205ca8', '8936e5ea-7447-4374-ac12-db014ba5ecd8', 'prod-6', 1, 9500.00, 'SERVED', '2026-02-15 18:40:17.395');


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.orders (id, session_id, status, created_at) VALUES ('6472b21c-e371-4647-94a4-95eecba49287', '505752fd-88c6-4bcf-bfd1-13e95c0a5143', 'OPEN', '2026-01-28 00:17:13.705');
INSERT INTO public.orders (id, session_id, status, created_at) VALUES ('d8483e8f-913f-416a-861c-fd7efac25c93', '1f7dec00-b5b1-476c-9caf-91842a44fcab', 'OPEN', '2026-02-09 18:48:02.272');
INSERT INTO public.orders (id, session_id, status, created_at) VALUES ('fab60072-73a0-42af-b758-64b31cc3d17d', '6464461a-d145-430b-a982-bb971cc61db9', 'OPEN', '2026-02-14 13:19:18.475');
INSERT INTO public.orders (id, session_id, status, created_at) VALUES ('93027d28-46d6-4771-b619-18c430abde78', '58f3ea13-0311-4913-8cde-b352f1cb2c6f', 'OPEN', '2026-02-15 16:56:30.612');
INSERT INTO public.orders (id, session_id, status, created_at) VALUES ('715c6c15-d85a-4ece-8a6e-e53ccab5c0d6', '8cf0cf6b-8c1c-4767-af87-c502dfa29755', 'OPEN', '2026-02-15 17:17:54.838');
INSERT INTO public.orders (id, session_id, status, created_at) VALUES ('8936e5ea-7447-4374-ac12-db014ba5ecd8', '51937dc5-e017-4b4a-ab80-f40755d12c7e', 'OPEN', '2026-02-15 18:40:17.386');


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.products (id, restaurant_id, category_id, name, description, price, image_url, is_available, created_at) VALUES ('prod-1', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'cat-comida', 'Pizza Margherita', 'Tomate, mozzarella, albahaca fresca.', 12000.00, 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?auto=format&fit=crop&w=500&q=80', true, '2026-01-27 21:24:23.088');
INSERT INTO public.products (id, restaurant_id, category_id, name, description, price, image_url, is_available, created_at) VALUES ('prod-3', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'cat-bebidas', 'Cerveza IPA', 'Artesanal, lupulada y refrescante.', 5000.00, 'https://images.unsplash.com/photo-1566633806327-68e152aaf26d?auto=format&fit=crop&w=500&q=80', true, '2026-01-27 21:24:23.096');
INSERT INTO public.products (id, restaurant_id, category_id, name, description, price, image_url, is_available, created_at) VALUES ('prod-5', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'cat-bebidas', 'Agua Mineral', 'Con o sin gas, 500ml.', 2000.00, 'https://images.unsplash.com/photo-1564419320461-6870880221ad?auto=format&fit=crop&w=500&q=80', true, '2026-01-27 21:24:23.103');
INSERT INTO public.products (id, restaurant_id, category_id, name, description, price, image_url, is_available, created_at) VALUES ('prod-2', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'cat-comida', 'Salm├│n Rosado', 'Grillado con vegetales de estaci├│n.', 25000.00, 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?auto=format&fit=crop&w=500&q=80', true, '2026-01-27 23:29:58.106');
INSERT INTO public.products (id, restaurant_id, category_id, name, description, price, image_url, is_available, created_at) VALUES ('prod-4', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'cat-postres', 'Tiramis├║', 'Cl├ísico postre italiano.', 6500.00, 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?auto=format&fit=crop&w=500&q=80', true, '2026-01-27 23:29:58.113');
INSERT INTO public.products (id, restaurant_id, category_id, name, description, price, image_url, is_available, created_at) VALUES ('prod-6', 'c67bc918-eb73-4687-960b-ed7a5721863c', 'cat-entradas', 'Ensalada C├®s', 'Lechuga, pollo, parmesano, croutones.', 9500.00, 'https://images.unsplash.com/photo-1546793665-c74683f339c1?auto=format&fit=crop&w=500&q=80', true, '2026-01-27 21:24:23.107');


--
-- Data for Name: restaurants; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.restaurants (id, name, slug, timezone, settings, created_at, updated_at, owner_id) VALUES ('c67bc918-eb73-4687-960b-ed7a5721863c', 'GastroSplit Demo', 'demo-restaurant', 'America/Argentina/Buenos_Aires', '{}', '2026-01-27 21:24:23.059', '2026-02-05 16:18:35.289', '5b66baf6-dc7f-4766-9254-7db6905f31ec');
INSERT INTO public.restaurants (id, name, slug, timezone, settings, created_at, updated_at, owner_id) VALUES ('48aa5c94-579d-4d7a-bb26-12c3b266bb78', 'prueba', 'prueba', 'America/Argentina/Buenos_Aires', '{}', '2026-02-09 17:47:51.312', '2026-02-09 17:47:51.312', '4d131ff3-ec10-477f-9cc2-6579b26ef03d');


--
-- Data for Name: service_calls; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.service_calls (id, session_id, type, status, created_at, resolved_at, restaurant_id) VALUES ('cabc30a4-dd45-439f-b18b-2f63bafdbb80', NULL, 'WAITER', 'PENDING', '2026-01-27 22:30:40.492', NULL, 'c67bc918-eb73-4687-960b-ed7a5721863c');
INSERT INTO public.service_calls (id, session_id, type, status, created_at, resolved_at, restaurant_id) VALUES ('55e83a5e-0b50-4d87-9406-e093767152e5', NULL, 'WAITER', 'PENDING', '2026-01-27 22:30:54.465', NULL, 'c67bc918-eb73-4687-960b-ed7a5721863c');
INSERT INTO public.service_calls (id, session_id, type, status, created_at, resolved_at, restaurant_id) VALUES ('d93b0fbe-f877-47e5-b285-f98e07a1d36b', NULL, 'WAITER', 'PENDING', '2026-01-27 22:44:48.984', NULL, 'c67bc918-eb73-4687-960b-ed7a5721863c');
INSERT INTO public.service_calls (id, session_id, type, status, created_at, resolved_at, restaurant_id) VALUES ('8284930d-8207-4693-9394-7ae5ef85152a', NULL, 'WAITER', 'PENDING', '2026-01-28 00:05:59.865', NULL, 'c67bc918-eb73-4687-960b-ed7a5721863c');
INSERT INTO public.service_calls (id, session_id, type, status, created_at, resolved_at, restaurant_id) VALUES ('3ed38fad-c880-4214-bddb-bec9c4d4fbc4', '505752fd-88c6-4bcf-bfd1-13e95c0a5143', 'WAITER', 'PENDING', '2026-01-28 00:16:54.246', NULL, NULL);
INSERT INTO public.service_calls (id, session_id, type, status, created_at, resolved_at, restaurant_id) VALUES ('d44215b1-4269-4308-abb0-da2e61c200ad', '505752fd-88c6-4bcf-bfd1-13e95c0a5143', 'WAITER', 'PENDING', '2026-01-28 00:27:34.069', NULL, NULL);
INSERT INTO public.service_calls (id, session_id, type, status, created_at, resolved_at, restaurant_id) VALUES ('59fabb5f-a285-4a33-9bc5-49b9b41601d8', '505752fd-88c6-4bcf-bfd1-13e95c0a5143', 'BILL', 'PENDING', '2026-01-28 00:36:40.991', NULL, NULL);
INSERT INTO public.service_calls (id, session_id, type, status, created_at, resolved_at, restaurant_id) VALUES ('2e36100f-7fb4-4eab-a352-98bad5aa6a65', '505752fd-88c6-4bcf-bfd1-13e95c0a5143', 'WAITER', 'PENDING', '2026-01-28 00:36:41.59', NULL, NULL);
INSERT INTO public.service_calls (id, session_id, type, status, created_at, resolved_at, restaurant_id) VALUES ('74cd77ca-4785-443d-8b1e-3ffca6179835', NULL, 'WAITER', 'PENDING', '2026-02-07 20:55:55.923', NULL, 'c67bc918-eb73-4687-960b-ed7a5721863c');
INSERT INTO public.service_calls (id, session_id, type, status, created_at, resolved_at, restaurant_id) VALUES ('50ee8087-ccab-4f6b-8928-11c224bfa4d7', '1f7dec00-b5b1-476c-9caf-91842a44fcab', 'WAITER', 'PENDING', '2026-02-09 18:48:14.886', NULL, NULL);
INSERT INTO public.service_calls (id, session_id, type, status, created_at, resolved_at, restaurant_id) VALUES ('cadc5e30-692a-4430-99be-fb136852e680', '1f7dec00-b5b1-476c-9caf-91842a44fcab', 'WAITER', 'PENDING', '2026-02-09 18:48:16.382', NULL, NULL);
INSERT INTO public.service_calls (id, session_id, type, status, created_at, resolved_at, restaurant_id) VALUES ('89719bdc-f810-4435-ad98-c379ba91d555', '1f7dec00-b5b1-476c-9caf-91842a44fcab', 'BILL', 'PENDING', '2026-02-09 18:48:17.368', NULL, NULL);
INSERT INTO public.service_calls (id, session_id, type, status, created_at, resolved_at, restaurant_id) VALUES ('0a9e6111-363d-4195-a275-6382dc678218', '6464461a-d145-430b-a982-bb971cc61db9', 'BILL', 'PENDING', '2026-02-14 13:20:00.936', NULL, NULL);
INSERT INTO public.service_calls (id, session_id, type, status, created_at, resolved_at, restaurant_id) VALUES ('f6da0f7f-3612-4b52-8496-f3da6b28c5c2', '6464461a-d145-430b-a982-bb971cc61db9', 'WAITER', 'PENDING', '2026-02-14 13:20:16.417', NULL, NULL);
INSERT INTO public.service_calls (id, session_id, type, status, created_at, resolved_at, restaurant_id) VALUES ('230082e1-55ca-4238-a816-1f69d25a5291', '6464461a-d145-430b-a982-bb971cc61db9', 'WAITER', 'PENDING', '2026-02-14 13:20:38.704', NULL, NULL);
INSERT INTO public.service_calls (id, session_id, type, status, created_at, resolved_at, restaurant_id) VALUES ('d22d9e38-5ee3-4f03-bde3-7f2640e3b62e', '6464461a-d145-430b-a982-bb971cc61db9', 'BILL', 'PENDING', '2026-02-14 13:20:40.035', NULL, NULL);
INSERT INTO public.service_calls (id, session_id, type, status, created_at, resolved_at, restaurant_id) VALUES ('c4009e3f-2617-4880-bd70-1dd6088441ef', NULL, 'WAITER', 'PENDING', '2026-02-15 16:56:13.798', NULL, 'c67bc918-eb73-4687-960b-ed7a5721863c');
INSERT INTO public.service_calls (id, session_id, type, status, created_at, resolved_at, restaurant_id) VALUES ('e0eec950-75dc-46e1-a2c2-1fc8268afd0b', '58f3ea13-0311-4913-8cde-b352f1cb2c6f', 'BILL', 'PENDING', '2026-02-15 17:02:39.513', NULL, NULL);
INSERT INTO public.service_calls (id, session_id, type, status, created_at, resolved_at, restaurant_id) VALUES ('da871ace-4dbf-4f2c-b760-72b6b6834348', '58f3ea13-0311-4913-8cde-b352f1cb2c6f', 'WAITER', 'PENDING', '2026-02-15 17:02:50.204', NULL, NULL);
INSERT INTO public.service_calls (id, session_id, type, status, created_at, resolved_at, restaurant_id) VALUES ('4fbff3da-b337-4748-9a3d-e4716258520d', '58f3ea13-0311-4913-8cde-b352f1cb2c6f', 'BILL', 'PENDING', '2026-02-15 17:02:54.323', NULL, NULL);
INSERT INTO public.service_calls (id, session_id, type, status, created_at, resolved_at, restaurant_id) VALUES ('d6a502de-1c33-47e9-beb2-7157cf69a45b', '58f3ea13-0311-4913-8cde-b352f1cb2c6f', 'WAITER', 'PENDING', '2026-02-15 17:02:55.117', NULL, NULL);
INSERT INTO public.service_calls (id, session_id, type, status, created_at, resolved_at, restaurant_id) VALUES ('8dcc1aef-a6a5-47a7-9434-32640b2ea7c6', '58f3ea13-0311-4913-8cde-b352f1cb2c6f', 'BILL', 'PENDING', '2026-02-15 17:02:55.51', NULL, NULL);
INSERT INTO public.service_calls (id, session_id, type, status, created_at, resolved_at, restaurant_id) VALUES ('6d1f371d-ae1a-4a08-98fb-1143bcf2b6bb', '58f3ea13-0311-4913-8cde-b352f1cb2c6f', 'BILL', 'PENDING', '2026-02-15 17:02:55.849', NULL, NULL);
INSERT INTO public.service_calls (id, session_id, type, status, created_at, resolved_at, restaurant_id) VALUES ('388e0a18-7cc0-45de-a10c-e59e338e355c', '8cf0cf6b-8c1c-4767-af87-c502dfa29755', 'BILL', 'PENDING', '2026-02-15 17:18:05.891', NULL, NULL);
INSERT INTO public.service_calls (id, session_id, type, status, created_at, resolved_at, restaurant_id) VALUES ('99b82a8c-93ae-4647-8460-71d2601d8396', NULL, 'WAITER', 'PENDING', '2026-02-15 17:49:07.499', NULL, 'c67bc918-eb73-4687-960b-ed7a5721863c');
INSERT INTO public.service_calls (id, session_id, type, status, created_at, resolved_at, restaurant_id) VALUES ('b9c5fecc-9ec8-49dd-a6ec-e512ce169761', '51937dc5-e017-4b4a-ab80-f40755d12c7e', 'WAITER', 'PENDING', '2026-02-15 18:51:23.863', NULL, NULL);


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sessions (id, table_id, status, started_at, ended_at) VALUES ('505752fd-88c6-4bcf-bfd1-13e95c0a5143', 'd65613d3-dd52-4208-8f4a-6dbff42589e5', 'PAYMENT_PENDING', '2026-01-28 00:16:48.285', NULL);
INSERT INTO public.sessions (id, table_id, status, started_at, ended_at) VALUES ('1471ab8e-25e1-4107-b64c-25e51f6aba31', 'f88fa4c6-fb48-42f8-ac80-0a40cc8bfa64', 'ACTIVE', '2026-02-09 17:48:24.944', NULL);
INSERT INTO public.sessions (id, table_id, status, started_at, ended_at) VALUES ('4ee894f6-1567-478f-a4de-41956eb7ae0d', '9366dfec-1ac7-47c0-9338-3ad4bccd2081', 'ACTIVE', '2026-02-09 17:59:21.779', NULL);
INSERT INTO public.sessions (id, table_id, status, started_at, ended_at) VALUES ('1f7dec00-b5b1-476c-9caf-91842a44fcab', '6e427177-78d7-48b0-9398-e0b72ae0136e', 'PAYMENT_PENDING', '2026-02-09 18:39:28.636', NULL);
INSERT INTO public.sessions (id, table_id, status, started_at, ended_at) VALUES ('7c152543-d41d-42ea-8860-0697825ce78d', 'e29414ea-4acd-4007-9999-78650cfd4a30', 'ACTIVE', '2026-02-12 17:48:37.972', NULL);
INSERT INTO public.sessions (id, table_id, status, started_at, ended_at) VALUES ('6464461a-d145-430b-a982-bb971cc61db9', 'd65613d3-dd52-4208-8f4a-6dbff42589e5', 'PAYMENT_PENDING', '2026-02-14 13:06:13.623', NULL);
INSERT INTO public.sessions (id, table_id, status, started_at, ended_at) VALUES ('8cf0cf6b-8c1c-4767-af87-c502dfa29755', 'aa76e95f-0085-412d-8c95-a2d8e6365f10', 'PAYMENT_PENDING', '2026-02-15 17:17:34.094', NULL);
INSERT INTO public.sessions (id, table_id, status, started_at, ended_at) VALUES ('51937dc5-e017-4b4a-ab80-f40755d12c7e', 'aa76e95f-0085-412d-8c95-a2d8e6365f10', 'ACTIVE', '2026-02-15 18:30:29.211', NULL);
INSERT INTO public.sessions (id, table_id, status, started_at, ended_at) VALUES ('f3013e06-af6d-4f8a-9eea-27a5c751f0b6', '655bbca2-72bd-4168-af1d-628dd068720b', 'CLOSED', '2026-02-20 23:18:43.883', '2026-02-21 20:05:02.634');
INSERT INTO public.sessions (id, table_id, status, started_at, ended_at) VALUES ('58f3ea13-0311-4913-8cde-b352f1cb2c6f', 'd65613d3-dd52-4208-8f4a-6dbff42589e5', 'CLOSED', '2026-02-15 16:33:19.816', '2026-02-21 20:05:18.926');
INSERT INTO public.sessions (id, table_id, status, started_at, ended_at) VALUES ('bd975644-ef20-4abb-a26e-ceefa9477f03', 'd65613d3-dd52-4208-8f4a-6dbff42589e5', 'CLOSED', '2026-02-20 23:07:16.736', '2026-02-21 20:05:30.768');


--
-- Data for Name: tables; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.tables (id, restaurant_id, number, is_enabled, qr_code_url, created_at) VALUES ('aa76e95f-0085-412d-8c95-a2d8e6365f10', 'c67bc918-eb73-4687-960b-ed7a5721863c', '6', true, NULL, '2026-02-15 17:17:03.707');
INSERT INTO public.tables (id, restaurant_id, number, is_enabled, qr_code_url, created_at) VALUES ('e29414ea-4acd-4007-9999-78650cfd4a30', 'c67bc918-eb73-4687-960b-ed7a5721863c', '2', true, NULL, '2026-01-27 23:54:07.506');
INSERT INTO public.tables (id, restaurant_id, number, is_enabled, qr_code_url, created_at) VALUES ('655bbca2-72bd-4168-af1d-628dd068720b', 'c67bc918-eb73-4687-960b-ed7a5721863c', '3', true, NULL, '2026-01-27 23:54:07.507');
INSERT INTO public.tables (id, restaurant_id, number, is_enabled, qr_code_url, created_at) VALUES ('c8deaf7b-bf70-4a6b-ab77-04a4ccd0b5d8', 'c67bc918-eb73-4687-960b-ed7a5721863c', '4', true, NULL, '2026-01-27 23:54:07.507');
INSERT INTO public.tables (id, restaurant_id, number, is_enabled, qr_code_url, created_at) VALUES ('d65613d3-dd52-4208-8f4a-6dbff42589e5', 'c67bc918-eb73-4687-960b-ed7a5721863c', '1', true, NULL, '2026-01-28 00:16:42.535');
INSERT INTO public.tables (id, restaurant_id, number, is_enabled, qr_code_url, created_at) VALUES ('8e50385e-c3e3-48c9-a5dd-8864ab730847', 'c67bc918-eb73-4687-960b-ed7a5721863c', '5', true, NULL, '2026-02-07 22:59:21.084');
INSERT INTO public.tables (id, restaurant_id, number, is_enabled, qr_code_url, created_at) VALUES ('6e427177-78d7-48b0-9398-e0b72ae0136e', '48aa5c94-579d-4d7a-bb26-12c3b266bb78', '4', true, NULL, '2026-02-09 17:47:51.34');
INSERT INTO public.tables (id, restaurant_id, number, is_enabled, qr_code_url, created_at) VALUES ('c0439465-9c87-4637-a8fe-3611de1677dc', '48aa5c94-579d-4d7a-bb26-12c3b266bb78', '3', true, NULL, '2026-02-09 17:47:51.34');
INSERT INTO public.tables (id, restaurant_id, number, is_enabled, qr_code_url, created_at) VALUES ('9366dfec-1ac7-47c0-9338-3ad4bccd2081', '48aa5c94-579d-4d7a-bb26-12c3b266bb78', '2', true, NULL, '2026-02-09 17:47:51.34');
INSERT INTO public.tables (id, restaurant_id, number, is_enabled, qr_code_url, created_at) VALUES ('f88fa4c6-fb48-42f8-ac80-0a40cc8bfa64', '48aa5c94-579d-4d7a-bb26-12c3b266bb78', '1', true, NULL, '2026-02-09 17:47:51.34');
INSERT INTO public.tables (id, restaurant_id, number, is_enabled, qr_code_url, created_at) VALUES ('1911af73-f35d-4528-a8ff-b3c06836958f', '48aa5c94-579d-4d7a-bb26-12c3b266bb78', '6', true, NULL, '2026-02-09 17:47:51.34');
INSERT INTO public.tables (id, restaurant_id, number, is_enabled, qr_code_url, created_at) VALUES ('38d16aad-6bee-4d29-b22e-43d82646f872', '48aa5c94-579d-4d7a-bb26-12c3b266bb78', '5', true, NULL, '2026-02-09 17:47:51.34');
INSERT INTO public.tables (id, restaurant_id, number, is_enabled, qr_code_url, created_at) VALUES ('31dceacb-56f7-4cdc-a20a-adf79fb4ecb9', '48aa5c94-579d-4d7a-bb26-12c3b266bb78', '10', true, NULL, '2026-02-09 17:47:51.34');
INSERT INTO public.tables (id, restaurant_id, number, is_enabled, qr_code_url, created_at) VALUES ('f0e2c70a-fb06-4928-826e-91d33a749d3e', '48aa5c94-579d-4d7a-bb26-12c3b266bb78', '9', true, NULL, '2026-02-09 17:47:51.34');
INSERT INTO public.tables (id, restaurant_id, number, is_enabled, qr_code_url, created_at) VALUES ('1924fbe6-d904-45fc-96df-392b80d7caf1', '48aa5c94-579d-4d7a-bb26-12c3b266bb78', '8', true, NULL, '2026-02-09 17:47:51.34');
INSERT INTO public.tables (id, restaurant_id, number, is_enabled, qr_code_url, created_at) VALUES ('c2f25a7a-85e1-46eb-8222-fc70c7e367e3', '48aa5c94-579d-4d7a-bb26-12c3b266bb78', '7', true, NULL, '2026-02-09 17:47:51.34');


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.users (id, email, password_hash, role, status, first_name, last_name, phone, business_name, created_at, updated_at, last_login_at, trial_ends_at) VALUES ('e87a0b3c-476e-4dbc-ba28-e53970d0503b', 'adriancasanova_@outlook.es', '$2b$12$6gkEEpXkV7uSebvdlkJp/O3//J5LRYrpUiJ8CPy2UMwJbCjV1LzYK', 'OWNER', 'TRIAL', 'Adrian', 'Casanova', '03415944125', '', '2026-01-27 23:39:32.287', '2026-01-27 23:39:32.287', NULL, '2026-02-11 23:39:32.286');
INSERT INTO public.users (id, email, password_hash, role, status, first_name, last_name, phone, business_name, created_at, updated_at, last_login_at, trial_ends_at) VALUES ('f1ed6e33-53d8-4928-9f43-d6dfb3d0250e', 'trial@gastrosplit.com', '$2b$12$GWVqn16EkTAWVM.wBnF7mubG5hyvnsK7xr5isAxES/Wan5GI9Rh/y', 'OWNER', 'TRIAL', 'Trial', 'User', NULL, 'Trial Business', '2026-01-27 23:29:58.071', '2026-01-27 23:56:58.733', '2026-01-27 23:56:58.732', '2026-02-11 23:29:58.069');
INSERT INTO public.users (id, email, password_hash, role, status, first_name, last_name, phone, business_name, created_at, updated_at, last_login_at, trial_ends_at) VALUES ('5c16e833-3758-4e82-a46b-eefa91078626', 'test.user.1770310087624@example.com', '$2b$12$uFLJ20M2rrnfMfInLdRfNO311GkpS6K/dfULJzwdL9XdBsOhBZQsC', 'OWNER', 'TRIAL', 'Test', 'User', '1234567890', 'Test Resto 1770310087624', '2026-02-05 16:48:07.909', '2026-02-05 16:48:08.163', '2026-02-05 16:48:08.161', '2026-02-20 16:48:07.906');
INSERT INTO public.users (id, email, password_hash, role, status, first_name, last_name, phone, business_name, created_at, updated_at, last_login_at, trial_ends_at) VALUES ('4d131ff3-ec10-477f-9cc2-6579b26ef03d', 'adriancasanova_@outlook.com', '$2b$12$e4xMGGiBriYTB3lHJjAmhubLaAPuXwEGTIWcis0CNvA7tD.HQSmYy', 'OWNER', 'TRIAL', 'Adrian', 'Casanova', '03415944125', 'asd', '2026-02-09 17:47:42.785', '2026-02-09 17:47:42.785', NULL, '2026-02-24 17:47:42.78');
INSERT INTO public.users (id, email, password_hash, role, status, first_name, last_name, phone, business_name, created_at, updated_at, last_login_at, trial_ends_at) VALUES ('5b66baf6-dc7f-4766-9254-7db6905f31ec', 'demo@gastrosplit.com', '$2b$12$drQ1x4VRHBrVgfTTJ6LTC..6XnwvMRHF1bMmv1mxLVui9N4ZG2MZi', 'OWNER', 'ACTIVE', 'Demo', 'User', NULL, 'Demo Business', '2026-01-27 23:29:58.058', '2026-02-21 19:26:43.707', '2026-02-21 19:26:43.706', NULL);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: consumers consumers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consumers
    ADD CONSTRAINT consumers_pkey PRIMARY KEY (id);


--
-- Name: domain_events domain_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.domain_events
    ADD CONSTRAINT domain_events_pkey PRIMARY KEY (id);


--
-- Name: order_item_consumers order_item_consumers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_item_consumers
    ADD CONSTRAINT order_item_consumers_pkey PRIMARY KEY (order_item_id, consumer_id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: restaurants restaurants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT restaurants_pkey PRIMARY KEY (id);


--
-- Name: service_calls service_calls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_calls
    ADD CONSTRAINT service_calls_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: tables tables_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tables
    ADD CONSTRAINT tables_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: categories_restaurant_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX categories_restaurant_id_idx ON public.categories USING btree (restaurant_id);


--
-- Name: consumers_session_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX consumers_session_id_idx ON public.consumers USING btree (session_id);


--
-- Name: domain_events_event_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX domain_events_event_type_idx ON public.domain_events USING btree (event_type);


--
-- Name: domain_events_occurred_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX domain_events_occurred_at_idx ON public.domain_events USING btree (occurred_at);


--
-- Name: domain_events_restaurant_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX domain_events_restaurant_id_idx ON public.domain_events USING btree (restaurant_id);


--
-- Name: order_item_consumers_consumer_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX order_item_consumers_consumer_id_idx ON public.order_item_consumers USING btree (consumer_id);


--
-- Name: order_items_order_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX order_items_order_id_idx ON public.order_items USING btree (order_id);


--
-- Name: order_items_product_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX order_items_product_id_idx ON public.order_items USING btree (product_id);


--
-- Name: orders_session_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX orders_session_id_key ON public.orders USING btree (session_id);


--
-- Name: products_category_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_category_id_idx ON public.products USING btree (category_id);


--
-- Name: products_restaurant_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_restaurant_id_idx ON public.products USING btree (restaurant_id);


--
-- Name: restaurants_owner_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX restaurants_owner_id_idx ON public.restaurants USING btree (owner_id);


--
-- Name: restaurants_slug_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX restaurants_slug_key ON public.restaurants USING btree (slug);


--
-- Name: service_calls_restaurant_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX service_calls_restaurant_id_idx ON public.service_calls USING btree (restaurant_id);


--
-- Name: service_calls_session_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX service_calls_session_id_idx ON public.service_calls USING btree (session_id);


--
-- Name: service_calls_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX service_calls_status_idx ON public.service_calls USING btree (status);


--
-- Name: sessions_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sessions_status_idx ON public.sessions USING btree (status);


--
-- Name: sessions_table_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sessions_table_id_idx ON public.sessions USING btree (table_id);


--
-- Name: tables_restaurant_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tables_restaurant_id_idx ON public.tables USING btree (restaurant_id);


--
-- Name: tables_restaurant_id_number_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX tables_restaurant_id_number_key ON public.tables USING btree (restaurant_id, number);


--
-- Name: users_email_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);


--
-- Name: categories categories_restaurant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_restaurant_id_fkey FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: consumers consumers_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consumers
    ADD CONSTRAINT consumers_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.sessions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: domain_events domain_events_restaurant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.domain_events
    ADD CONSTRAINT domain_events_restaurant_id_fkey FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_item_consumers order_item_consumers_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_item_consumers
    ADD CONSTRAINT order_item_consumers_consumer_id_fkey FOREIGN KEY (consumer_id) REFERENCES public.consumers(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_item_consumers order_item_consumers_order_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_item_consumers
    ADD CONSTRAINT order_item_consumers_order_item_id_fkey FOREIGN KEY (order_item_id) REFERENCES public.order_items(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_items order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: orders orders_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.sessions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: products products_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: products products_restaurant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_restaurant_id_fkey FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: restaurants restaurants_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT restaurants_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: service_calls service_calls_restaurant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_calls
    ADD CONSTRAINT service_calls_restaurant_id_fkey FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: service_calls service_calls_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_calls
    ADD CONSTRAINT service_calls_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.sessions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sessions sessions_table_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_table_id_fkey FOREIGN KEY (table_id) REFERENCES public.tables(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tables tables_restaurant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tables
    ADD CONSTRAINT tables_restaurant_id_fkey FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict sU5c51cm6Ch7U8BIHytPYko0Cx9IMkYTqsFvG12qDg7rHdb54yQ7DLYPkdah1mO

