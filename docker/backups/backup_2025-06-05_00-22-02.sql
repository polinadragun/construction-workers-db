--
-- PostgreSQL database dump
--

-- Dumped from database version 15.12 (Debian 15.12-1.pgdg120+1)
-- Dumped by pg_dump version 15.12 (Debian 15.12-1.pgdg120+1)

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
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: publication_type_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.publication_type_enum AS ENUM (
    'tender',
    'order'
);


ALTER TYPE public.publication_type_enum OWNER TO postgres;

--
-- Name: tender_type_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.tender_type_enum AS ENUM (
    'open',
    'closed',
    'invitation'
);


ALTER TYPE public.tender_type_enum OWNER TO postgres;

--
-- Name: update_bid_score(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_bid_score() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tender_bids
    SET
        total_score = (
            SELECT ROUND(AVG(ev.score)::numeric, 2)
            FROM tender_bid_evaluations ev
            WHERE ev.tender_bid_id = NEW.tender_bid_id
        )
    WHERE id = NEW.tender_bid_id;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_bid_score() OWNER TO postgres;

--
-- Name: update_profile_rating(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_profile_rating() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        UPDATE profiles
        SET
        avg_rating = (
            SELECT ROUND(AVG(r.rating)::numeric, 2)
            FROM reviews r
            WHERE r.user_id = NEW.user_id
        )
        WHERE user_id = NEW.user_id;

        RETURN NEW;
    END;
$$;


ALTER FUNCTION public.update_profile_rating() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: bid_status_codes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bid_status_codes (
    code character varying(15) NOT NULL,
    description character varying(100) NOT NULL
);


ALTER TABLE public.bid_status_codes OWNER TO postgres;

--
-- Name: company_profile_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.company_profile_details (
    id uuid NOT NULL,
    profile_id uuid NOT NULL,
    inn character varying(12) NOT NULL,
    ogrn character varying(13) NOT NULL,
    kpp character varying(9) NOT NULL,
    sro_certificate_number character varying(50),
    company_name character varying(255) NOT NULL
);


ALTER TABLE public.company_profile_details OWNER TO postgres;

--
-- Name: e_signature_verifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.e_signature_verifications (
    id uuid NOT NULL,
    profile_id uuid NOT NULL,
    verification_status character varying(15) NOT NULL,
    signature_provider character varying(100) NOT NULL,
    verified_at timestamp without time zone,
    CONSTRAINT e_signature_verifications_verified_at_check CHECK ((verified_at <= CURRENT_TIMESTAMP))
);


ALTER TABLE public.e_signature_verifications OWNER TO postgres;

--
-- Name: flyway_schema_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.flyway_schema_history (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


ALTER TABLE public.flyway_schema_history OWNER TO postgres;

--
-- Name: gov_profile_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.gov_profile_details (
    id uuid NOT NULL,
    profile_id uuid NOT NULL,
    inn character varying(12) NOT NULL,
    kpp character varying(9) NOT NULL,
    ogrn character varying(13) NOT NULL,
    representative_fio character varying(255) NOT NULL
);


ALTER TABLE public.gov_profile_details OWNER TO postgres;

--
-- Name: ip_profile_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ip_profile_details (
    id uuid NOT NULL,
    profile_id uuid NOT NULL,
    inn character varying(12) NOT NULL,
    ogrnip character varying(15) NOT NULL,
    fio character varying(255) NOT NULL
);


ALTER TABLE public.ip_profile_details OWNER TO postgres;

--
-- Name: legal_profile_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.legal_profile_types (
    legal_type_code character varying(15) NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.legal_profile_types OWNER TO postgres;

--
-- Name: order_bids; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_bids (
    id uuid NOT NULL,
    order_id uuid NOT NULL,
    bidder_id uuid NOT NULL,
    bid_status_code character varying(15) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    additional_comment text,
    CONSTRAINT order_bids_created_at_check CHECK ((created_at <= CURRENT_TIMESTAMP))
);


ALTER TABLE public.order_bids OWNER TO postgres;

--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    id uuid NOT NULL,
    publication_id uuid NOT NULL,
    required_delivery_date timestamp without time zone NOT NULL,
    description text NOT NULL
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: person_profile_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.person_profile_details (
    id uuid NOT NULL,
    profile_id uuid NOT NULL,
    inn character varying(12) NOT NULL
);


ALTER TABLE public.person_profile_details OWNER TO postgres;

--
-- Name: portfolio_projects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.portfolio_projects (
    id uuid NOT NULL,
    profile_id uuid NOT NULL,
    title character varying(255) NOT NULL,
    description text NOT NULL,
    start_date date NOT NULL,
    end_date date,
    CONSTRAINT portfolio_projects_check CHECK ((start_date < end_date))
);


ALTER TABLE public.portfolio_projects OWNER TO postgres;

--
-- Name: profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.profiles (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    legal_type_code character varying(15) NOT NULL,
    verification_status_code character varying(15) NOT NULL,
    verification_comment character varying(250),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    avg_rating numeric(3,2) DEFAULT 0.0,
    CONSTRAINT profiles_check CHECK ((created_at <= updated_at)),
    CONSTRAINT profiles_created_at_check CHECK ((created_at <= CURRENT_TIMESTAMP)),
    CONSTRAINT profiles_updated_at_check CHECK ((updated_at <= CURRENT_TIMESTAMP))
);


ALTER TABLE public.profiles OWNER TO postgres;

--
-- Name: project_mediafiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.project_mediafiles (
    id uuid NOT NULL,
    portfolio_project_id uuid NOT NULL,
    file_url character varying(255) NOT NULL,
    file_type character varying(50) NOT NULL
);


ALTER TABLE public.project_mediafiles OWNER TO postgres;

--
-- Name: publication_mediafiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.publication_mediafiles (
    id uuid NOT NULL,
    publication_id uuid NOT NULL,
    file_url character varying(250) NOT NULL,
    file_type character varying(50) NOT NULL,
    uploaded_at timestamp without time zone NOT NULL,
    CONSTRAINT publication_mediafiles_uploaded_at_check CHECK ((uploaded_at <= CURRENT_TIMESTAMP))
);


ALTER TABLE public.publication_mediafiles OWNER TO postgres;

--
-- Name: publication_regions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.publication_regions (
    publication_id uuid NOT NULL,
    region_code smallint NOT NULL
);


ALTER TABLE public.publication_regions OWNER TO postgres;

--
-- Name: publication_specializations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.publication_specializations (
    publication_id uuid NOT NULL,
    spec_code character varying(15) NOT NULL
);


ALTER TABLE public.publication_specializations OWNER TO postgres;

--
-- Name: publication_status_codes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.publication_status_codes (
    code character varying(15) NOT NULL,
    description character varying(100) NOT NULL
);


ALTER TABLE public.publication_status_codes OWNER TO postgres;

--
-- Name: publications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.publications (
    id uuid NOT NULL,
    creator_id uuid NOT NULL,
    publication_status_code character varying(15) NOT NULL,
    title character varying(255) NOT NULL,
    description text NOT NULL,
    deadline timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    publication_type public.publication_type_enum NOT NULL,
    CONSTRAINT publications_created_at_check CHECK ((created_at <= CURRENT_TIMESTAMP)),
    CONSTRAINT publications_deadline_check CHECK ((deadline > CURRENT_TIMESTAMP))
);


ALTER TABLE public.publications OWNER TO postgres;

--
-- Name: regions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.regions (
    region_code smallint NOT NULL,
    name character varying(100) NOT NULL,
    CONSTRAINT regions_region_code_check CHECK ((region_code > 0))
);


ALTER TABLE public.regions OWNER TO postgres;

--
-- Name: reviews; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reviews (
    id uuid NOT NULL,
    reviewer_id uuid NOT NULL,
    user_id uuid NOT NULL,
    rating integer NOT NULL,
    comment text,
    created_at timestamp without time zone NOT NULL,
    CONSTRAINT reviews_created_at_check CHECK ((created_at <= CURRENT_TIMESTAMP)),
    CONSTRAINT reviews_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE public.reviews OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    role_code character varying(15) NOT NULL,
    requires_legal_profiles boolean DEFAULT false NOT NULL
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: specializations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.specializations (
    spec_code character varying(15) NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.specializations OWNER TO postgres;

--
-- Name: tender_bid_documents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tender_bid_documents (
    id uuid NOT NULL,
    tender_bid_id uuid NOT NULL,
    file_url character varying(255) NOT NULL,
    file_type character varying(50) NOT NULL,
    description character varying(255)
);


ALTER TABLE public.tender_bid_documents OWNER TO postgres;

--
-- Name: tender_bid_evaluations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tender_bid_evaluations (
    id uuid NOT NULL,
    tender_bid_id uuid NOT NULL,
    evaluator_name character varying(50) NOT NULL,
    score numeric(5,2) NOT NULL,
    comment text,
    created_at timestamp without time zone NOT NULL,
    CONSTRAINT tender_bid_evaluations_created_at_check CHECK ((created_at <= CURRENT_TIMESTAMP))
);


ALTER TABLE public.tender_bid_evaluations OWNER TO postgres;

--
-- Name: tender_bids; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tender_bids (
    id uuid NOT NULL,
    tender_id uuid NOT NULL,
    bidder_id uuid NOT NULL,
    bid_status_code character varying(15) NOT NULL,
    proposal text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    warranty_period_months integer NOT NULL,
    completion_time_days integer NOT NULL,
    total_score numeric(5,2) DEFAULT 0.0,
    CONSTRAINT tender_bids_created_at_check CHECK ((created_at <= CURRENT_TIMESTAMP))
);


ALTER TABLE public.tender_bids OWNER TO postgres;

--
-- Name: tenders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tenders (
    id uuid NOT NULL,
    publication_id uuid NOT NULL,
    submission_deadline timestamp without time zone NOT NULL,
    evaluation_criteria text NOT NULL,
    required_documents text NOT NULL,
    description text NOT NULL,
    contract_security_amount numeric(15,2) NOT NULL,
    min_experience_years integer NOT NULL,
    warranty_period_months integer NOT NULL,
    tender_type public.tender_type_enum NOT NULL,
    CONSTRAINT tenders_submission_deadline_check CHECK ((submission_deadline > CURRENT_TIMESTAMP))
);


ALTER TABLE public.tenders OWNER TO postgres;

--
-- Name: user_regions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_regions (
    user_id uuid NOT NULL,
    region_code smallint NOT NULL
);


ALTER TABLE public.user_regions OWNER TO postgres;

--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_roles (
    user_id uuid NOT NULL,
    role_code character varying(15) NOT NULL
);


ALTER TABLE public.user_roles OWNER TO postgres;

--
-- Name: user_specializations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_specializations (
    user_id uuid NOT NULL,
    spec_code character varying(15) NOT NULL
);


ALTER TABLE public.user_specializations OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    email character varying(254) NOT NULL,
    password_hash character varying(128) NOT NULL,
    full_name character varying(255) NOT NULL,
    contact_phone character varying(15),
    CONSTRAINT users_contact_phone_check CHECK (((char_length((contact_phone)::text) >= 7) AND (char_length((contact_phone)::text) <= 15))),
    CONSTRAINT users_email_check CHECK (((email)::text ~~ '%@%'::text))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: verification_documents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.verification_documents (
    id uuid NOT NULL,
    profile_id uuid NOT NULL,
    verification_status_code character varying(15) NOT NULL,
    document_type character varying(50) NOT NULL,
    document_url character varying(250) NOT NULL,
    uploaded_at timestamp without time zone NOT NULL,
    verification_comment character varying(250),
    CONSTRAINT verification_documents_uploaded_at_check CHECK ((uploaded_at <= CURRENT_TIMESTAMP))
);


ALTER TABLE public.verification_documents OWNER TO postgres;

--
-- Name: verification_status_codes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.verification_status_codes (
    code character varying(15) NOT NULL,
    description character varying(100) NOT NULL
);


ALTER TABLE public.verification_status_codes OWNER TO postgres;

--
-- Data for Name: bid_status_codes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bid_status_codes (code, description) FROM stdin;
draft	Черновик
submitted	Подан
selected	Выбран для исполнения
\.


--
-- Data for Name: company_profile_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.company_profile_details (id, profile_id, inn, ogrn, kpp, sro_certificate_number, company_name) FROM stdin;
6cf64fbb-d950-439e-8bca-e748615d30b2	2949b03e-6239-4fd4-a61f-b34fb973f132	4558639181	3338618455817	075766064	30174500	Bechtelar-Williamson
ebf8aae7-b74e-46a6-b158-5b990fa7082f	5d4185c7-bec1-4af1-97e3-0df252431772	0850468717	1000868004048	223985115	13085259	Wuckert-Johns
e1dd5de9-b5b8-425c-a9af-c857df3d0a29	75c21222-cce6-4d68-8967-2f22c594a6b1	0080831460	0256673345134	483828658	09764237	Baumbach-Rau
30a13a70-c974-4fd4-9c27-b4d43f5a2f12	48ba213c-aab9-4494-9a67-6e915ceb1678	0739081712	2947473110783	961163777	01834644	Lehner, Ryan and Lemke
df384724-ce18-4773-9cb9-dbaf835c9158	707a452d-939c-4a48-ae87-5848c2a1c63e	3251011013	4376110042265	864185537	65073433	Cassin LLC
b2ebaa7a-dc8a-4e22-a7b8-0f8d88200b75	e8d66249-846f-46f0-8a3d-4ed4491a97a6	9413051696	4564862546734	442452607	78076807	Lemke Group
af255dec-3ede-4e9c-afd8-70f40e8cda0d	1ca341bb-e272-4f47-bee3-3b0a41f9510a	4742604415	2328585864078	187448386	31185423	Stark-Maggio
857a75ea-9d71-46b3-9de4-2ccdbd4dd254	156acccc-b696-41cc-a429-69e72f76e2a5	8346721825	7721338160225	496360540	18720488	Bednar, Bartoletti and Thompson
ef0b2459-e969-412d-8802-af10f0a92fd4	858cc771-d98e-4b87-91ba-484b7ac82a46	5213678477	7622220431388	727106013	81336030	Crist LLC
562af942-1d9a-4f1d-95f7-fa52cebd1f02	ff3c0225-aebd-4d32-b373-6fb9e240ef8a	0560667280	6147115957363	869207760	53449486	O'Hara-Witting
\.


--
-- Data for Name: e_signature_verifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.e_signature_verifications (id, profile_id, verification_status, signature_provider, verified_at) FROM stdin;
4ce74e5e-124c-4db0-a32a-1f39e0d5f3fe	fda73321-e721-4560-80b8-b062c5090883	failed	Контур	2025-06-04 18:55:34.714349
b616b28b-a440-4a62-a684-b0aa092cd5c4	9bcc795d-4d12-45f0-a592-77f24671ab64	passed	Контур	2025-06-04 18:55:34.714349
e43e2596-6b75-488c-aea3-4c5221afa13d	2949b03e-6239-4fd4-a61f-b34fb973f132	pending	Тензор	2025-06-04 18:55:34.714349
0fa5112b-ee2d-4ce3-ab29-1b2530c984ae	5d4185c7-bec1-4af1-97e3-0df252431772	passed	Контур	2025-06-04 18:55:34.714349
46f3240c-c9d4-450a-9077-e16eaf60bb56	cefd3d85-4f2d-43a6-bc56-f848d4f794ef	failed	КриптоПро	2025-06-04 18:55:34.714349
2ea04297-ada2-4dfe-a6e9-d2d3c119b3ad	6d8ad48b-3ee4-4d10-bce3-192b94b54b00	failed	Другой провайдер	2025-06-04 18:55:34.714349
97a7b3f6-d70b-48bd-bd54-a8f94df812f8	75c21222-cce6-4d68-8967-2f22c594a6b1	pending	КриптоПро	2025-06-04 18:55:34.714349
8382a3ec-225e-47af-b34b-8e005eb28132	2a1753fe-265a-43a2-a791-580a19693ace	pending	Контур	2025-06-04 18:55:34.714349
6ab58ffe-20cd-4bb4-8263-6d81ed1cdcc0	ae22c8fd-4347-4b8e-be79-53718a01c39a	failed	КриптоПро	2025-06-04 18:55:34.714349
21bc68da-e117-4183-806b-c1c4b0027730	0cd37e88-6dcc-4359-b195-3a25d9895663	pending	Тензор	2025-06-04 18:55:34.714349
2d0dfc80-d5fb-46e9-92bf-9d2d968c781d	2dec1f5c-08bd-4048-91ad-057147189e4b	passed	Тензор	2025-06-04 18:55:34.714349
3c2ddfef-5b7e-4c68-9f87-44104da77af0	996fe158-61f3-48b0-a31f-05c472524c62	passed	Госуслуги	2025-06-04 18:55:34.714349
40be8bd6-a9bb-4ecc-ba95-04f63d9354e6	48ba213c-aab9-4494-9a67-6e915ceb1678	pending	Другой провайдер	2025-06-04 18:55:34.714349
89edec70-376a-4fa5-84f1-8f072e3a1044	ad2e6944-7b0c-47b7-b442-b61bdbd75933	passed	КриптоПро	2025-06-04 18:55:34.714349
ef7d341e-a237-4ea6-9de9-22c4148f8849	1aa256a2-6261-47c7-bf21-6456747e4ba7	pending	КриптоПро	2025-06-04 18:55:34.714349
3b4e5b62-f471-4180-ab62-88eec6c15f6f	707a452d-939c-4a48-ae87-5848c2a1c63e	failed	Тензор	2025-06-04 18:55:34.714349
e1a788f3-82f2-457e-bb86-750ee2bc594f	a2ee3c19-8717-48c4-9f8a-2a706c2407d2	passed	Тензор	2025-06-04 18:55:34.714349
a885e04e-bdf9-4391-840b-c99ed1456066	20eab0fe-4e3c-420d-a79d-62a8a2de1447	failed	Тензор	2025-06-04 18:55:34.714349
745a9eab-65a5-4aaf-9b98-7faeb7668867	e8d66249-846f-46f0-8a3d-4ed4491a97a6	passed	Тензор	2025-06-04 18:55:34.714349
1fc7ab4f-e6b9-48e7-8c41-9f00f6d09d02	2a38993b-d9c1-4883-af49-26c955b55ae9	pending	Другой провайдер	2025-06-04 18:55:34.714349
b2ed2b13-b7f8-4804-93d8-54349303c56c	29992cfd-9985-4a02-b328-aa03de1c1939	passed	КриптоПро	2025-06-04 18:55:34.714349
6864825b-f61c-4837-993e-dd5e4e941a76	1ca341bb-e272-4f47-bee3-3b0a41f9510a	failed	КриптоПро	2025-06-04 18:55:34.714349
1fb89905-1537-4760-857a-830db178d1d5	36057578-0f4f-4fac-bd29-4a5490801461	passed	Контур	2025-06-04 18:55:34.714349
926b343d-5235-44f5-a157-e0e23a2fa8b2	e3d5560b-029e-4e74-ad03-daaece398841	passed	Контур	2025-06-04 18:55:34.714349
cada79d0-0165-4bb8-8acb-a3d611d69c33	e6390fc1-74c0-4003-87ec-512fe7c163f7	passed	Контур	2025-06-04 18:55:34.714349
6ed69db8-b8f7-481d-898b-bf11763be719	156acccc-b696-41cc-a429-69e72f76e2a5	failed	Тензор	2025-06-04 18:55:34.714349
ecf22e42-fd2a-42ee-96db-987145f2c338	858cc771-d98e-4b87-91ba-484b7ac82a46	failed	КриптоПро	2025-06-04 18:55:34.714349
fff3aff1-4ddf-45cb-89d5-1d3660c96d38	55d45901-74dc-46ca-9492-d83caf72d393	passed	Контур	2025-06-04 18:55:34.714349
9af4779c-119f-46b6-a9a3-d127a632f2d2	4616d741-946b-4926-b743-9ba387344e28	pending	КриптоПро	2025-06-04 18:55:34.714349
ba08b75b-6d49-41ee-b31e-3b3874e646e1	c2903c62-4eaa-4578-bcd5-2ef88659a30b	failed	Госуслуги	2025-06-04 18:55:34.714349
3ae71031-6a41-4e38-a3a6-ceb0955aa004	ad53b3ff-48ca-4b18-91a6-42da74c01baa	pending	КриптоПро	2025-06-04 18:55:34.714349
dd60a244-e10d-4c02-9d40-5882d9423e85	5333204e-7c6e-4788-a48f-1eb76fffbb6c	pending	Тензор	2025-06-04 18:55:34.714349
d1076498-a915-4e2f-9c36-aea9658b1276	6bd47ccf-2c44-461b-9d71-3800301370f2	failed	Госуслуги	2025-06-04 18:55:34.714349
fbe4de8e-824c-413c-8c56-39d578d802ed	35f09869-9a88-4f45-b957-34138c1dbf13	pending	Госуслуги	2025-06-04 18:55:34.714349
b57ed66e-8301-4f7f-ba8f-59e4f65c4c60	00abf49e-6a04-4e53-9345-bacfe3ba52e6	pending	Другой провайдер	2025-06-04 18:55:34.714349
c3266652-4ff4-4e90-afc0-da06bc222d12	07c91af1-c12e-4b7f-8ca2-877e3d218712	passed	Контур	2025-06-04 18:55:34.714349
b355b272-e2f0-4e53-8c06-3224ea21605f	704b39aa-c212-4e80-a20b-7207b3cad366	failed	Другой провайдер	2025-06-04 18:55:34.714349
a6f22a30-ef5a-4968-8e42-b530b6058caf	7533aebf-2662-4fe7-9178-726965d7fd7e	pending	Другой провайдер	2025-06-04 18:55:34.714349
629d4528-0644-4d4d-9942-efbe12ca8a61	3392c7b6-8d9b-43b6-a388-a506ada131aa	pending	Госуслуги	2025-06-04 18:55:34.714349
bbe250b2-e8ea-4fe7-a08c-ef0bc84c6e6b	1d624d3a-9ec8-45ea-94e5-1c9d37c10d02	failed	Другой провайдер	2025-06-04 18:55:34.714349
7bf9fed1-966f-4f82-affb-6bce2ca9e371	f703e5e5-5866-49c0-816e-11590b1d09da	failed	Другой провайдер	2025-06-04 18:55:34.714349
eba8d9ee-3bd4-44ff-b082-d13f86740ecd	37c2ac00-5f90-4db9-b26d-c3e842ad9265	failed	Другой провайдер	2025-06-04 18:55:34.714349
58ffc5e5-8ee0-404a-80b5-a85c84f9bc60	270c36c6-2330-4e40-b534-0cf48ad03580	pending	Контур	2025-06-04 18:55:34.714349
e816b16b-8c53-48a0-8457-cf4e517f3531	f8264a05-db55-47de-ade8-64157af121ec	passed	Контур	2025-06-04 18:55:34.714349
3ce18ca3-0c27-4a97-b081-3cffb731c122	ff3c0225-aebd-4d32-b373-6fb9e240ef8a	pending	Тензор	2025-06-04 18:55:34.714349
e61465bf-6299-40b2-85b9-f11697dc885e	7dc2e223-4ee9-4ff8-bfd7-86304f286877	passed	Другой провайдер	2025-06-04 18:55:34.714349
312c1d0e-8b2f-4982-9932-4cd275b3248c	c6a4624b-49b5-4d76-ad75-5c4c388d49e3	failed	Контур	2025-06-04 18:55:34.714349
5d3b8d7c-e597-40db-a097-71988f411aac	b1ffdfbc-409a-477b-9460-679b1288d9ce	pending	Другой провайдер	2025-06-04 18:55:34.714349
19b4a20c-3faa-43bb-a27a-da4f1d657997	13e86e43-7909-4166-8164-593019247f89	pending	Контур	2025-06-04 18:55:34.714349
36add3c2-75a2-4b20-8ce5-5c19698f9bd7	6b266b30-16d3-404a-be7c-678941d6f5cf	pending	КриптоПро	2025-06-04 18:55:34.714349
\.


--
-- Data for Name: flyway_schema_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.flyway_schema_history (installed_rank, version, description, type, script, checksum, installed_by, installed_on, execution_time, success) FROM stdin;
1	1	enums and base tables	SQL	V1__enums_and_base_tables.sql	-144376523	postgres	2025-06-04 18:55:31.577029	62	t
2	2	users relations and profiles	SQL	V2__users_relations_and_profiles.sql	1436341938	postgres	2025-06-04 18:55:31.722914	67	t
3	3	publications and bids	SQL	V3__publications_and_bids.sql	-811011160	postgres	2025-06-04 18:55:31.852043	98	t
4	4	portfolios and reviews	SQL	V4__portfolios_and_reviews.sql	327361379	postgres	2025-06-04 18:55:31.985371	32	t
\.


--
-- Data for Name: gov_profile_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.gov_profile_details (id, profile_id, inn, kpp, ogrn, representative_fio) FROM stdin;
03d16351-3919-4ded-8b89-90f1fa677844	fda73321-e721-4560-80b8-b062c5090883	0784497163	053516634	5533613095626	Antwan Wunsch
d90c02e3-6d1b-4884-a43c-8e9601f56eda	2a1753fe-265a-43a2-a791-580a19693ace	3306545713	861840766	7678783201801	Miss Jack Klein
18ce177c-77f8-4ad0-9cf0-43c5c3494182	ad2e6944-7b0c-47b7-b442-b61bdbd75933	4897383509	524260713	5542078004463	Minnie Cassin IV
7b4268b3-c362-41f1-8c31-704abf413dcb	1aa256a2-6261-47c7-bf21-6456747e4ba7	2581034757	214250755	4579746775326	Moriah Abbott
50aed3ac-7f73-403d-9468-859e846c8fd7	a2ee3c19-8717-48c4-9f8a-2a706c2407d2	4658361647	805142099	5251815359687	Curt Stokes
6998a33b-0b61-4686-a9ea-b8d1b72dd161	20eab0fe-4e3c-420d-a79d-62a8a2de1447	1842073106	027139347	4523102105863	Charla King II
65c65a73-3838-4995-9fe9-5afeea7468bb	2a38993b-d9c1-4883-af49-26c955b55ae9	5060605034	822293526	7010140453754	Joaquin Prohaska
b7db0d6d-d786-4a7b-a379-08a5de9a9377	36057578-0f4f-4fac-bd29-4a5490801461	5630073042	042317719	3477435523733	Gilberte Lemke PhD
774287d4-e4b3-4218-a36e-b190bebf951a	e6390fc1-74c0-4003-87ec-512fe7c163f7	7417373684	490173731	8535331742235	Dana Bernhard
ab37233b-87d9-4488-929c-eaf6f5607340	5333204e-7c6e-4788-a48f-1eb76fffbb6c	0016116814	508026642	2766264511152	Jerry Kub
fe6a1f47-cdd7-40d2-a2ee-8febf559ede5	35f09869-9a88-4f45-b957-34138c1dbf13	0686006004	189733513	8610148151320	Asa Kiehn
9e72ed51-a5fe-48fb-b046-5aa45f3843f9	f703e5e5-5866-49c0-816e-11590b1d09da	1053877763	834559766	0183610733781	Dr. Agustin Murphy
4ab632d5-32dc-4601-8e48-84123e875262	f8264a05-db55-47de-ade8-64157af121ec	8587122695	604844095	2650791373069	Nathanael Trantow
70a2b363-2126-4703-b6b3-de98f8c8d7d2	7dc2e223-4ee9-4ff8-bfd7-86304f286877	8268435067	441974335	4586655288969	Dr. Garrett Block
53d06411-718a-44d1-8a14-5b230e45eca3	b1ffdfbc-409a-477b-9460-679b1288d9ce	2434873204	856048336	7106066232815	Lawrence Jast Sr.
a388445f-1bf7-4ab0-8107-076f758f696b	13e86e43-7909-4166-8164-593019247f89	5768136007	632473266	2640084172358	Bernard Sauer
\.


--
-- Data for Name: ip_profile_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ip_profile_details (id, profile_id, inn, ogrnip, fio) FROM stdin;
8ec3a5ba-4bd9-452d-9939-ab4880245304	9bcc795d-4d12-45f0-a592-77f24671ab64	414142823851	158748850705486	Darron Lesch
df3601bc-2fc7-46f5-98f4-79f237e4878c	ae22c8fd-4347-4b8e-be79-53718a01c39a	674407825883	505469436130847	Cristopher Goldner
b63dd7b8-355e-4d5e-8f71-ec3feadd87cb	0cd37e88-6dcc-4359-b195-3a25d9895663	053504344388	547547625837684	Miss Matha Wilkinson
cd4c0c9c-8306-4f25-a953-0139b10d7da0	2dec1f5c-08bd-4048-91ad-057147189e4b	104702578600	755008278638741	Sherika Pfannerstill
70dc80ba-65da-497d-b038-c06f8b822e43	e3d5560b-029e-4e74-ad03-daaece398841	628428015524	712468816546243	Daren Treutel
a321c46b-ba6c-45aa-9aa6-a6e7685a8681	55d45901-74dc-46ca-9492-d83caf72d393	513829723382	739554822854546	Sandy Von
8d058891-4a4b-4c63-a0dc-d815e528bf5c	00abf49e-6a04-4e53-9345-bacfe3ba52e6	012076023566	904857660100220	Glen Lueilwitz DVM
ad0d2760-3169-4484-b781-fbba798862bf	07c91af1-c12e-4b7f-8ca2-877e3d218712	238370352680	717583074586073	Mose Grant
497c69d2-2181-4d00-8937-03b291794b3c	704b39aa-c212-4e80-a20b-7207b3cad366	101530192055	509884984744617	Dr. Giuseppe Lubowitz
19380836-0e48-403e-a570-92e7964b6b38	1d624d3a-9ec8-45ea-94e5-1c9d37c10d02	754558792350	718364160673623	Thomasina Ferry II
543f32aa-8c8b-4bef-bda6-5078e0f85e3f	37c2ac00-5f90-4db9-b26d-c3e842ad9265	524184038873	372566558564463	Williemae Olson
d7fe045a-32ca-483c-82f8-b909a14f27f9	6b266b30-16d3-404a-be7c-678941d6f5cf	443556407904	326036810451913	Dr. Carmon Gorczany
\.


--
-- Data for Name: legal_profile_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.legal_profile_types (legal_type_code, name) FROM stdin;
gov	Госорган
company	Юридическое лицо
ip	Физическое лицо
person	Индивидуальный предприниматель
\.


--
-- Data for Name: order_bids; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_bids (id, order_id, bidder_id, bid_status_code, created_at, additional_comment) FROM stdin;
ff58a022-b755-4932-bb88-09c05dcdbb59	0ac981ff-4623-4b5c-a816-30167f590a76	4ee49614-d5ac-4747-ad7b-53e8d011c033	draft	2025-05-23 18:55:34.959551	Veniam facere omnis laboriosam dolores eveniet.
d685bfef-8c16-4e9a-964b-1f2f8ac5e120	0ac981ff-4623-4b5c-a816-30167f590a76	46d8b973-2d30-4392-a8f8-03e6fa1358b4	submitted	2025-05-31 18:55:34.959873	Quia sequi libero.
bf0de0e6-afdd-4472-b014-fdbe2f4a7add	0ac981ff-4623-4b5c-a816-30167f590a76	88f7f35c-f5ad-4a41-b61d-e1cb92bbe610	submitted	2025-05-16 18:55:34.959988	Sed maxime rerum omnis.
05f97623-33ac-498d-bb8b-f1fbf5588011	3dada1d4-9dd1-41de-84a9-964e0bb6a3a6	928dd269-eb62-4f4a-992d-a3a8d0dd1d98	draft	2025-05-30 18:55:34.960104	Placeat quis omnis animi enim aut consectetur perferendis.
63bb5a8b-92f5-41cd-b5a3-9f02c1cd2fcd	3dada1d4-9dd1-41de-84a9-964e0bb6a3a6	50272aa6-b626-447b-afa3-2b1d7d15787a	submitted	2025-05-12 18:55:34.960209	Qui sed aut fugit quos architecto reprehenderit sapiente.
cf8f8a52-aded-4c7c-b675-e97cd099849b	3dada1d4-9dd1-41de-84a9-964e0bb6a3a6	4bf92c1a-44eb-4161-bd36-dd3a2845a695	submitted	2025-05-10 18:55:34.960356	Quos quam aut sit quia labore qui.
15396eb8-036c-4406-b3ac-45ad810a4dbe	3dada1d4-9dd1-41de-84a9-964e0bb6a3a6	5e846192-3f8c-49f7-9906-4e4a0f3ef781	draft	2025-06-01 18:55:34.960456	Occaecati praesentium enim accusantium dolores quisquam voluptatem.
818de56e-9b88-4124-b8f3-c26f075ebb4d	92b51c89-a4f4-4379-afab-077bedee5a88	2eb659ec-30a6-4d9b-a744-584290717a73	draft	2025-05-28 18:55:34.960599	Suscipit est repellat.
4141c303-44ef-4c0b-9a56-07943cb12b2b	92b51c89-a4f4-4379-afab-077bedee5a88	e831937b-abf5-4d9d-aacd-14d729a07054	draft	2025-05-18 18:55:34.96072	Aliquam voluptates recusandae rem laudantium consequatur optio debitis.
b2799892-4b29-4df1-a0c1-ad894539c3cc	92b51c89-a4f4-4379-afab-077bedee5a88	ddc4ecd3-9abd-49be-add0-1a919620fb35	submitted	2025-05-11 18:55:34.960828	Quae in ut distinctio ut autem.
336da8c6-b691-4fd6-ae09-8d4ca2411fe6	bb01749e-25fb-462e-97c6-2ccaadfebc96	5e846192-3f8c-49f7-9906-4e4a0f3ef781	submitted	2025-05-07 18:55:34.960967	Necessitatibus debitis voluptas aspernatur voluptatem.
99d10bda-c62c-4ecb-9fd6-d916225ffd33	bb01749e-25fb-462e-97c6-2ccaadfebc96	46d8b973-2d30-4392-a8f8-03e6fa1358b4	submitted	2025-05-31 18:55:34.961067	Culpa eaque quo voluptatibus dolorem.
4b6b6582-dca2-4c0e-9f37-d8f9b733c654	bb01749e-25fb-462e-97c6-2ccaadfebc96	38cd8d9e-3491-40da-bc55-4c069b4047de	submitted	2025-05-13 18:55:34.961161	Aut totam dicta deserunt.
69f7a8e5-c6d3-4e13-9c9b-4f27501346aa	bb01749e-25fb-462e-97c6-2ccaadfebc96	5e846192-3f8c-49f7-9906-4e4a0f3ef781	draft	2025-06-02 18:55:34.961251	Delectus non quia ad ut.
83fb1d27-0e31-475c-801b-9312baf016d9	a4d21869-a25d-4439-a283-432221ec54b4	57dc1fb3-c63f-487a-a348-9d43a58f7287	draft	2025-05-31 18:55:34.961384	Qui qui esse voluptas dolorum.
7755b4b9-4885-4f6c-a003-40a7a22c3ec7	a4d21869-a25d-4439-a283-432221ec54b4	46d8b973-2d30-4392-a8f8-03e6fa1358b4	submitted	2025-05-07 18:55:34.961532	Debitis accusamus architecto minima perspiciatis.
8c7d57eb-df1e-4958-8e17-5d05210dbba2	7ea66867-8088-4fcd-a44d-81208d477336	f3fa4ae9-2fec-439b-a043-ecdac59fbd09	submitted	2025-05-18 18:55:34.961661	Ipsa porro sint sequi aliquam sit voluptas ducimus.
092e1eb4-5da8-410e-a7e4-6b717056275b	7ea66867-8088-4fcd-a44d-81208d477336	928dd269-eb62-4f4a-992d-a3a8d0dd1d98	submitted	2025-05-21 18:55:34.96176	Quisquam non iure.
3ee27539-5458-402e-a494-87ecf0f81b59	7ea66867-8088-4fcd-a44d-81208d477336	bba6ba0b-d8c7-4a28-ab8e-62b657a1ca94	submitted	2025-05-30 18:55:34.961849	Maxime est dolorum error.
f886e457-8cf8-4b78-8059-7caa2595d435	7ea66867-8088-4fcd-a44d-81208d477336	e831937b-abf5-4d9d-aacd-14d729a07054	draft	2025-05-31 18:55:34.961941	Ea dolore ut.
dd7225ee-7a18-492d-9921-d430bfdc6d6f	7ea66867-8088-4fcd-a44d-81208d477336	57dc1fb3-c63f-487a-a348-9d43a58f7287	submitted	2025-06-02 18:55:34.962051	Ea voluptatibus molestiae voluptas beatae.
1e9fcdfb-fb2d-4101-99f1-43f26e9ec090	fd4c7a04-db2a-413f-b0ba-05f3ffa5c115	46d8b973-2d30-4392-a8f8-03e6fa1358b4	draft	2025-05-14 18:55:34.962165	Cum doloremque odio id sed enim excepturi.
0a57ff6d-9c31-4492-9b69-4885ff3ab1c4	fd4c7a04-db2a-413f-b0ba-05f3ffa5c115	46d8b973-2d30-4392-a8f8-03e6fa1358b4	submitted	2025-05-29 18:55:34.962285	Omnis a harum qui debitis hic sit.
272dfef2-9031-400c-9cf5-145809815aaf	fd4c7a04-db2a-413f-b0ba-05f3ffa5c115	46d8b973-2d30-4392-a8f8-03e6fa1358b4	submitted	2025-05-25 18:55:34.962407	Cumque vitae aspernatur.
c27976c3-48e2-4ec1-837b-5afb06bb3342	90997904-97e1-45f6-8c82-4b1914048002	5e846192-3f8c-49f7-9906-4e4a0f3ef781	submitted	2025-05-06 18:55:34.962582	Quisquam itaque molestiae voluptatibus unde.
74fd81a0-fecc-4296-b505-1936d69a627a	90997904-97e1-45f6-8c82-4b1914048002	38cd8d9e-3491-40da-bc55-4c069b4047de	draft	2025-05-23 18:55:34.962713	Et ducimus enim et.
23111baf-79ef-454b-9ca1-7ebcc35a38be	251703ff-88b9-4fe4-8e49-f6904c792e91	4ee49614-d5ac-4747-ad7b-53e8d011c033	draft	2025-05-10 18:55:34.962817	Consectetur nam dolores sed aspernatur sint.
ff976b3b-27e8-4d35-b241-246c7b159f96	251703ff-88b9-4fe4-8e49-f6904c792e91	46d8b973-2d30-4392-a8f8-03e6fa1358b4	draft	2025-05-20 18:55:34.962912	Ullam hic et voluptatem voluptas aut est reiciendis.
2e85d266-5fcf-48db-b172-468e6565c700	251703ff-88b9-4fe4-8e49-f6904c792e91	46d8b973-2d30-4392-a8f8-03e6fa1358b4	submitted	2025-05-21 18:55:34.963012	Nulla totam sed fugiat fugit ea facere ut.
100dce3e-ff3e-4cf8-911b-ee9546b8aa8b	251703ff-88b9-4fe4-8e49-f6904c792e91	5af4786d-4f22-4b8a-b1b0-925a45a17693	draft	2025-05-19 18:55:34.963139	Voluptatum aut dolor qui consequatur non.
59d7c826-700a-43d6-9b69-8f670e0ba6f2	218db2ff-ce55-4f11-9d48-9c60b5997ab0	928dd269-eb62-4f4a-992d-a3a8d0dd1d98	draft	2025-06-04 18:55:34.963255	Aliquid error voluptatibus vero officia architecto qui illum.
73c5a717-e57b-4d0e-95ca-74cd331dac4a	218db2ff-ce55-4f11-9d48-9c60b5997ab0	5e846192-3f8c-49f7-9906-4e4a0f3ef781	submitted	2025-05-22 18:55:34.963376	Expedita fuga consequatur voluptatem quia amet.
a0108c36-fc71-4030-a384-70bb8e276a68	218db2ff-ce55-4f11-9d48-9c60b5997ab0	3dac66e8-03ab-4ef5-b8f5-e429736cd315	submitted	2025-05-14 18:55:34.963497	Laboriosam eum et reprehenderit aliquid sint labore ipsum.
edc8080a-7410-4e7e-a272-7e808881461a	d343ebd5-3045-44fe-a85e-edffc51642f2	57dc1fb3-c63f-487a-a348-9d43a58f7287	draft	2025-06-03 18:55:34.963646	Soluta et excepturi sint assumenda itaque et non.
55a5e05e-d303-4137-bbd1-d327c9c5ef83	a73ffa8a-ac05-4a91-b502-ff5fa60adfdf	ddc4ecd3-9abd-49be-add0-1a919620fb35	submitted	2025-05-09 18:55:34.963767	Minima iure et.
cace81ad-7c96-41fb-95c2-912063e84ca3	e8eb155e-701c-4253-abdd-66534bccbb7f	88f7f35c-f5ad-4a41-b61d-e1cb92bbe610	submitted	2025-05-31 18:55:34.963864	Asperiores voluptas voluptate.
ac69555c-bece-4643-bf58-18c74f5c8a86	e8eb155e-701c-4253-abdd-66534bccbb7f	57dc1fb3-c63f-487a-a348-9d43a58f7287	draft	2025-06-03 18:55:34.964524	Occaecati ea doloribus iusto sit asperiores atque dicta.
016dc469-4539-4cab-a857-8452d2952b33	e8eb155e-701c-4253-abdd-66534bccbb7f	3dac66e8-03ab-4ef5-b8f5-e429736cd315	submitted	2025-06-01 18:55:34.964741	Totam pariatur beatae autem.
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (id, publication_id, required_delivery_date, description) FROM stdin;
0ac981ff-4623-4b5c-a816-30167f590a76	25283b85-148d-4c24-a6c8-2b2b8a11a514	2025-07-18 18:55:34.787675	x4o90mgjj6wvv4r09szhylsniv4n1zdbfx72ut4ibnh71mc9h03vvucp3q41pr4s3cpbkts59eqjk56fxyr8z7qyra5mpj7wgmksrr0p
3dada1d4-9dd1-41de-84a9-964e0bb6a3a6	f24f53ff-2176-44b7-a901-076b121a8c53	2025-07-19 18:55:34.78852	e729xjg71nxxftmkdsmnvidjgzek0dadodt0s9oml0amjftsk0o2r6m35dqce4ixu5bwqcjt9wa6rwft95j889ox9cokyf8zqg417gty5guzceylrjy1r37jmxazh682mla6092vdmxti2sy9kpwocm3ab22a959hkf8pz1alh
92b51c89-a4f4-4379-afab-077bedee5a88	bc24dba2-d4bd-4b6c-95c9-50ebdf2abb9c	2025-06-25 18:55:34.79157	eb7qerkbcph6que7as2nfecun0j6u38be2vg8wlor2sy46o32er1ru12p0a383sn4j5kj1q8onfuvawzjs3kqo0fsbauho0xpsli75srxs58cqt788t3wrussnfavlg4380v
bb01749e-25fb-462e-97c6-2ccaadfebc96	93aa563e-dfd6-4cf0-87e2-72b7fe7fd088	2025-07-19 18:55:34.795939	0e1hurxqfewkp93wpwzqp8bpg2cxv1idte93flxwaccqm0rsdw9ku2ft8xswj9t517g2x4zvh2wuqqlbu3ndqkvcapdyae0cnm6mkm7jzp0cz32wzuq9h77u1msoewncoebr8ejd1743v3xshxe4j92w3vimqj784w7w9shzq8s106ve8rmd4bo568t4fzz4rfyyrsdj3b3cww7
a4d21869-a25d-4439-a283-432221ec54b4	ca03a72f-b0f3-4b9a-a157-7b5c2d785be3	2025-07-21 18:55:34.796686	k8dugxry6ibacmlb8gu0go0xd1ng2n633sj30akoj39nuic94m0hk9f13nbujlzyolvfz4dzbrknzzj13ksmjhj8qypttmepy4mm0iljha72k9v3y2szvj96te5l03v3vexbg9
7ea66867-8088-4fcd-a44d-81208d477336	6f7190c4-9de6-4a67-a119-033ce47b7427	2025-07-13 18:55:34.797808	nhtcmyfz5eqf5dzqtawtv5ob7h6l7bne2t6enexg1bmtlrvtkoyg4toyi5qgulsz6byf4jgxoa2ar3tgeiys6dk2xdo4bhmychqrpq6x94jbliv84vj0n8tbpllyrtkff12lmfn8kw57c083lvqthvqpt5s6e5khnrhab61i623j8x862ui7mi7g9q6ro79m5x8xo26r2vy25k7ai5tgshwky3zulpklgl
fd4c7a04-db2a-413f-b0ba-05f3ffa5c115	ed2681f3-f659-48e4-a1e9-5f50a68e6a40	2025-06-26 18:55:34.799408	gaqezo6s4ts14md5vfc64w64ui3l5rz2ctelxu5fowxmxmvk4vvsbcnjn40y56n7g49qjb1vg8j5pyutkh4hmbagoxbkdj6o0hooy2wyuo1rdse7t0192afoblhvccz48j1gaqfal0bnoh6ilog25p9t
90997904-97e1-45f6-8c82-4b1914048002	943509ed-5b40-422f-bfab-913001b18de8	2025-07-24 18:55:34.800465	2sv4k48n7dbrh7223mi5u0lgm7x2athd36v6ar3dt82b2hzytm7ff1nsbdd0pz7qaunecd5baxy8oljmdq2iao1hlv2cebqmiyjlx0kw21jkblr3yxbmcc4j4pnlbzzk846iv1m1knk7ifh7ify2jvmuq
251703ff-88b9-4fe4-8e49-f6904c792e91	2cfd914b-bbdc-475b-974c-f483329089be	2025-07-22 18:55:34.805364	5p6zwuypgmak26yjjwskgi0uhaxihu8zk9vwj2zwswisuc8lshb4n5q44wjwu94i0kvs7pj1f430qi6yh3paell2jhawl2lzq3m0laphjsutwr9v9nltksdxmxbn0o9o5qrk5uj8i46ntnf3kx9fz0qo5wm10u3c946c7b84v6xeda9eexh6x08v1lquwfb4nadoi
218db2ff-ce55-4f11-9d48-9c60b5997ab0	344a6cf9-2798-4b9d-b1a5-4461c116e2b0	2025-07-19 18:55:34.806762	ukbirem3subyw5rbvx22ffr89k483tkj5jyp4lqtnsonojdsr1i6expv5mr1f0ccaac0b17dluh4ogs9r310ztxxv68g4bf5rvzqe3bfkwk6kg5cott7ty7kjklq0gqsyw23ovheyz7x1y3re9vssikqd04eipgjr8hs2cfwsug8y3n0hyw6l2go16zs
d343ebd5-3045-44fe-a85e-edffc51642f2	3e79a2d0-220d-41dc-8240-e5aba82e6bcc	2025-07-01 18:55:34.810009	buyvk703xp0xdmslyzlbn27xxszpqpe1e5495xo8r84kuo1kds4sezrcqq3cissoq18sei6ld3hc5pdf639an4zba47f1p3l594o01hkcgpuu2njt4ybennr15vt8zaro4iombqb3qehz7wy1j5bw5aojxnm9v143ws0
a73ffa8a-ac05-4a91-b502-ff5fa60adfdf	2b490eef-285e-4040-bf3d-947341733fdb	2025-07-07 18:55:34.812321	dleesdrf6qkcykf0e6hfre3r8bgqym77qdtt0h0b1ov2x1h22oer96pf61ly7gwf6j4jw2pvzkrmxjqcb2x40sn1qop3n2g9eawbxvww
e8eb155e-701c-4253-abdd-66534bccbb7f	6b221061-af8d-4786-9a6f-1423826e3e1b	2025-07-01 18:55:34.815363	fhf78gscru2001jmuclnahdmgabkkgpmsse6mqt2s5f1rtl49ffhdyzquvmwbfuoq5snvn1vkjctjffqs6zjx6tch3jy561fyrqvsdz6qzyxcg3o6l0lwzne0ordquslnnw18tipjptxmcu2wyj0cjye7tyamrsgivl2leojay8chfxsofwg6fwfj2vo98ya2pi2ymcr4xorosb257aw63rt7wf
\.


--
-- Data for Name: person_profile_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.person_profile_details (id, profile_id, inn) FROM stdin;
7b2e79f4-6151-44ec-97bc-c42a20d9d457	cefd3d85-4f2d-43a6-bc56-f848d4f794ef	999028641809
b26d538a-a8aa-4c72-9569-42463192be1a	6d8ad48b-3ee4-4d10-bce3-192b94b54b00	848272341803
5c66a090-3a54-48f4-a326-0ecbc005edda	996fe158-61f3-48b0-a31f-05c472524c62	092293481556
ef9eb381-b8df-463f-b16d-536a3a320921	29992cfd-9985-4a02-b328-aa03de1c1939	709491388888
18d7a119-289a-4575-a271-f54f17fded79	4616d741-946b-4926-b743-9ba387344e28	227307123439
89d99217-1330-42a2-8b37-0741ecea2778	c2903c62-4eaa-4578-bcd5-2ef88659a30b	769332008044
6f85349e-abdb-406c-9e67-34c9bf71d20e	ad53b3ff-48ca-4b18-91a6-42da74c01baa	422110404893
20b99fbb-3303-4556-9151-93feec775785	6bd47ccf-2c44-461b-9d71-3800301370f2	604522825756
dedf9236-9cf2-4916-8584-20ad1aff4877	7533aebf-2662-4fe7-9178-726965d7fd7e	630344857675
6a8374b3-7ffc-4473-8dbe-e0e2961609c4	3392c7b6-8d9b-43b6-a388-a506ada131aa	806447353286
7cfdcd81-78f1-4ebb-a980-4b1e8f1fd205	270c36c6-2330-4e40-b534-0cf48ad03580	732321599342
b7b47e73-1db2-44d5-b9db-61095f608bd1	c6a4624b-49b5-4d76-ad75-5c4c388d49e3	187817153775
\.


--
-- Data for Name: portfolio_projects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.portfolio_projects (id, profile_id, title, description, start_date, end_date) FROM stdin;
e320dfce-6b00-4c90-84d2-d5ba3465c55b	fda73321-e721-4560-80b8-b062c5090883	Quidem nemo omnis.	Recusandae accusantium atque inventore laudantium distinctio. Delectus numquam illum laudantium. Impedit eum magni omnis sit. Dolor facilis error magnam vel.	2024-12-04	2025-09-04
ddf43f9d-0479-4136-8471-91a4dc2e1c53	fda73321-e721-4560-80b8-b062c5090883	Velit perferendis rerum quam hic quae.	Asperiores et animi est hic sed. Dicta corporis est. Asperiores tempore provident rerum. Est fugiat adipisci. Voluptates dolore modi.	2024-09-04	2024-11-04
44428f35-82f0-4ec2-a350-44c0f70d55a2	9bcc795d-4d12-45f0-a592-77f24671ab64	Aperiam dolores nisi consequatur voluptatem.	Velit qui ut temporibus. Commodi magnam fugiat quos dolorum aspernatur et. Harum nihil asperiores sed suscipit voluptates. Laboriosam in asperiores fugit optio enim et dolorem. Ipsa impedit at dignissimos quidem hic.	2025-03-04	2025-10-04
13a4b138-10ef-472b-89a5-7cfb84c459a4	9bcc795d-4d12-45f0-a592-77f24671ab64	Ad omnis neque quia quod.	Culpa ut non. Distinctio et minima dolor. In animi qui sequi dolorum deserunt fuga. Tenetur ipsum cumque neque. Qui excepturi ullam.	2025-02-04	2025-09-04
506eee2f-d834-41ad-9e48-24f90afb5f13	2949b03e-6239-4fd4-a61f-b34fb973f132	Voluptas aut omnis qui rerum laudantium porro omnis.	Earum ipsa facilis ut. Aliquid aut quis qui. Tempore non dolore reiciendis laudantium in quos dolor.	2024-10-04	2025-05-04
3acf3f9a-a017-45b7-b9bf-0c3ba19d3efa	2949b03e-6239-4fd4-a61f-b34fb973f132	Similique laudantium non.	Impedit nisi dolorem. Ratione sint omnis quo voluptatibus voluptatem nesciunt sed. Magni unde nobis.	2024-09-04	2024-11-04
37c31f68-49b7-4a2a-b067-d0d23abe2686	2949b03e-6239-4fd4-a61f-b34fb973f132	Eos et dolorum aut.	Dolorem culpa quo quasi voluptas quaerat maiores. Sequi consequuntur non assumenda et beatae maxime. Qui unde et molestias aut repudiandae.	2024-08-04	2025-01-04
33304522-251c-444c-a3bd-fac78f73248c	5d4185c7-bec1-4af1-97e3-0df252431772	Qui ut excepturi rerum.	Praesentium nobis fugiat saepe est. Fugit nesciunt accusamus omnis fugiat nostrum officiis commodi. Doloremque molestias fuga explicabo consectetur eaque. Aut culpa ea et.	2025-03-04	2025-10-04
01e6fba6-be45-40d7-ab30-6c0a0607843b	cefd3d85-4f2d-43a6-bc56-f848d4f794ef	Vel quis veniam consequatur nesciunt maxime velit.	Ex accusamus consectetur dolores. Dignissimos nostrum fugiat possimus est earum. Quam sequi aliquam. Quis officia dolores. Et dolore saepe optio ab corrupti hic porro.	2024-12-04	2025-09-04
69256d0f-a42b-46bd-9bf7-63f406a999f3	cefd3d85-4f2d-43a6-bc56-f848d4f794ef	Dolorem voluptatibus voluptatem iusto fugiat esse qui repellat.	Illo dolores hic excepturi. Quo officia quia eveniet enim et et enim. Magnam error et facilis facere nisi ipsum et.	2025-02-04	2025-05-04
100b910f-ceba-42dc-b534-7ce1910d0911	cefd3d85-4f2d-43a6-bc56-f848d4f794ef	Ea quos perferendis dolores ut.	Sit aut adipisci quam consequatur ea animi. Quia tempora non tempora molestiae quibusdam et inventore. Fugiat in consequuntur doloribus. Reprehenderit aspernatur nemo esse.	2025-03-04	2025-09-04
a3df2afd-a108-4e31-8ed8-050ab7eb40d9	6d8ad48b-3ee4-4d10-bce3-192b94b54b00	Quidem voluptas asperiores natus sit at possimus iusto.	Rerum iste autem nulla at quos quo. Aut qui inventore. Et laudantium incidunt. A reiciendis quasi occaecati ducimus et. Reiciendis vitae aliquid provident ipsum magni perspiciatis.	2025-03-04	2026-01-04
60d298cb-4fd1-4b09-9a2b-dee0f8109078	6d8ad48b-3ee4-4d10-bce3-192b94b54b00	Qui eos quam perferendis.	Exercitationem aspernatur laborum. Illo tempora facilis consequuntur quam a. Neque et voluptas fugiat eum.	2025-05-04	2026-02-04
5cd2bfaf-a931-4ea9-a830-2652029824b6	75c21222-cce6-4d68-8967-2f22c594a6b1	Et saepe quae quo qui animi ea.	Accusantium accusantium qui. Expedita ea et qui perspiciatis esse neque et. Consequuntur fuga est voluptates. Consequuntur et aut qui qui veniam odio exercitationem.	2025-03-04	\N
34373718-616b-4431-91d2-af323710d43e	75c21222-cce6-4d68-8967-2f22c594a6b1	Ullam sed quaerat voluptas inventore quo dolor quia.	Magnam enim omnis. Et praesentium nam eligendi aut. Libero impedit omnis totam. Est qui unde. Explicabo nihil esse nobis aspernatur dolorum error atque.	2024-12-04	2025-03-04
e56bb816-b4b8-4a38-8853-fe8247658e3c	75c21222-cce6-4d68-8967-2f22c594a6b1	Expedita qui neque.	Vel nobis vitae quia molestias amet et error. Quae et blanditiis. Quo magni sit debitis tempore eum modi et. Fugit cumque explicabo rerum ipsa ut cum consequatur. Vel harum non nam.	2024-09-04	2025-07-04
2dae6fd3-a9d5-4328-bd59-e612bd8162b5	2a1753fe-265a-43a2-a791-580a19693ace	Earum adipisci itaque magni quod repellat voluptate.	Saepe delectus sint. Quo cupiditate ullam quasi molestias enim. Sapiente et a sunt fugiat dignissimos.	2025-01-04	2025-11-04
d0ab2df0-ddde-4931-871c-c221bbc57997	2a1753fe-265a-43a2-a791-580a19693ace	Amet eaque eum sit ducimus veritatis.	Ea aut adipisci dolor qui perspiciatis enim. Enim architecto debitis id minus optio. Laboriosam quis nisi facilis blanditiis nostrum.	2024-08-04	2025-06-04
57457771-bdf3-4837-abcc-044cd6935a85	ae22c8fd-4347-4b8e-be79-53718a01c39a	Aut odit ut qui est vero non fugit.	Amet minus ad ea. Consectetur ut accusantium omnis explicabo inventore temporibus nam. Excepturi voluptatibus itaque et vel laborum cum.	2024-11-04	\N
31b082f2-27c5-45d4-8d30-a6e51b3e9a8c	0cd37e88-6dcc-4359-b195-3a25d9895663	Et reprehenderit aut.	Qui inventore distinctio qui saepe possimus. Et fugit autem necessitatibus cupiditate. Magni est mollitia ut dolor omnis. Aliquam corporis neque.	2025-04-04	\N
f3e470fd-bbf3-4d78-8be0-1be29f5f7758	0cd37e88-6dcc-4359-b195-3a25d9895663	Tenetur aspernatur ut itaque accusantium quia.	Animi aliquam in occaecati totam voluptatibus. Voluptas eum soluta qui quo quasi. Maxime voluptas voluptas. Voluptatem iusto qui natus est consequatur sit eum.	2025-05-04	\N
e0189063-ef0d-4cb4-a1b0-9cf50d821d34	0cd37e88-6dcc-4359-b195-3a25d9895663	Qui quis praesentium ut minus.	Suscipit enim eveniet deleniti. Rerum et rerum aut. Unde nobis possimus hic natus.	2025-04-04	\N
a9a0022e-6085-4002-807b-7c046097d32a	2dec1f5c-08bd-4048-91ad-057147189e4b	Aut quia est tempore tempora molestiae qui.	Soluta et consequatur consequatur architecto. Pariatur corporis consequatur molestiae voluptatem. Accusamus totam cumque sunt. Qui dolorum assumenda rerum quibusdam. Perferendis necessitatibus dolores fuga enim qui perspiciatis.	2024-12-04	2025-06-04
1660ed05-21a2-4ce8-b61d-9570f5ec5507	2dec1f5c-08bd-4048-91ad-057147189e4b	Aut qui vitae rerum.	Architecto dolore cumque qui cum velit ut dicta. Molestiae voluptatum nam. Voluptatem rerum aliquam dicta ducimus nobis maxime. Ex earum at rem aut id. Similique incidunt eum unde tempora.	2024-07-04	2025-01-04
08b227f4-3d22-406a-98d5-6818a3bd72de	2dec1f5c-08bd-4048-91ad-057147189e4b	Pariatur pariatur error accusamus qui nisi.	Velit quo et earum commodi quam aperiam iusto. Provident magni itaque itaque. Nemo illum est illo est.	2024-12-04	2025-09-04
c3912bfa-0f45-4227-b7e9-b1508855606a	996fe158-61f3-48b0-a31f-05c472524c62	Aut molestiae est consequatur alias consequatur possimus.	Asperiores et eum eaque. Aliquam rem ut sapiente illo. Et voluptatem eius ut neque quas eveniet esse. Ipsum non atque. Qui similique temporibus qui magnam.	2024-12-04	2025-09-04
bece2079-0284-4c6f-9a07-9cb94bc215a0	48ba213c-aab9-4494-9a67-6e915ceb1678	Non aspernatur quam ipsam magni aliquam id.	Quia deleniti sed deserunt sapiente aut in. Error quis esse animi. In ut incidunt sit velit quisquam.	2025-05-04	2025-11-04
a329f5c8-38ce-4709-87c8-1fbd1e010a25	48ba213c-aab9-4494-9a67-6e915ceb1678	Alias possimus modi.	Qui dolore qui voluptatem. Voluptas quo minus delectus distinctio qui. Et porro et nobis saepe. Molestiae quisquam quia.	2025-05-04	2025-06-04
f8062b87-748b-4eb6-ac4d-33b863d6d78e	ad2e6944-7b0c-47b7-b442-b61bdbd75933	Nisi qui error incidunt nemo saepe non fuga.	Nam ut mollitia. Id ad consequatur et. Quasi dolorem facere exercitationem quia. Perferendis ipsam corporis ipsum.	2025-03-04	2025-11-04
c8306394-afbb-4692-a6e8-c5b8bf5725ea	ad2e6944-7b0c-47b7-b442-b61bdbd75933	Excepturi id tempora rerum sed fugiat.	Illo illum ipsam ut et eum. Nihil saepe in qui accusamus expedita quidem. Eos quia culpa tempore. Consectetur nulla fugiat qui. Praesentium quidem in.	2024-10-04	2024-12-04
94e9a7f8-1a90-4990-802f-df680c53117f	ad2e6944-7b0c-47b7-b442-b61bdbd75933	Ut dolores at repudiandae.	Temporibus et quia iusto perferendis optio. Quis id quia eum non voluptate. Eaque earum voluptatem. Sint totam non veritatis beatae fugiat.	2024-11-04	2025-10-04
4b493d49-ebc0-44af-985a-f4e4734076aa	1aa256a2-6261-47c7-bf21-6456747e4ba7	Quo possimus aliquam velit odit.	Autem autem nesciunt dolor. Ut id consequuntur nihil cumque illum. Adipisci dolores qui. Et error enim at velit quo rerum voluptatem. Ea qui suscipit facere perferendis dolorum.	2025-06-04	2026-02-04
e4b0db23-91d5-420b-a38a-4e391c71fcb2	1aa256a2-6261-47c7-bf21-6456747e4ba7	Omnis est ducimus veniam rerum.	Quasi rem aut quo qui mollitia ipsam alias. Aut quae fugiat culpa consequatur consequatur nesciunt vitae. Quisquam vero voluptates enim. Omnis fugit distinctio voluptatum qui expedita modi. Saepe quia sunt doloribus ut praesentium consequatur.	2024-08-04	2025-01-04
868ff2a3-f526-42ff-a024-02c2721aa78d	1aa256a2-6261-47c7-bf21-6456747e4ba7	Corrupti facilis rerum ullam laboriosam ducimus.	Sapiente qui velit. Qui corporis modi ea sequi. Vitae voluptas repellendus molestiae deserunt aut quibusdam consequatur. Repellat numquam molestiae qui et eum. Expedita aliquam aliquam iure iure.	2025-06-04	2025-11-04
3be061f4-0510-4852-b358-3f21c3090e80	707a452d-939c-4a48-ae87-5848c2a1c63e	Error iusto nobis et magnam nihil et.	Quas excepturi laboriosam aperiam nemo ea soluta. Vitae quod non amet. Id in est ducimus.	2024-09-04	2024-12-04
cbadf037-338c-4dc5-be4f-548528ff5fe2	707a452d-939c-4a48-ae87-5848c2a1c63e	Facilis aut ut dolor.	Unde aut veritatis et incidunt error. Architecto aliquid facere atque ut provident. Beatae vel labore quibusdam et dolorem est qui.	2024-11-04	2025-10-04
67207a21-fb40-4776-96de-54d5057527e6	707a452d-939c-4a48-ae87-5848c2a1c63e	Ducimus quia omnis quia delectus asperiores.	Ab et veniam ipsum delectus reiciendis et quo. Fugit quo excepturi qui vel maxime dignissimos. Eius nostrum et autem dolore autem vero. Et ea est reiciendis eveniet ipsa. Sed sint accusamus.	2025-05-04	2026-04-04
4f494c8e-dff6-4687-935b-6c1b097966f8	a2ee3c19-8717-48c4-9f8a-2a706c2407d2	Dolorem eum blanditiis ut qui iusto veritatis.	Ut quibusdam quaerat nihil autem assumenda quia. Laudantium tempora reprehenderit incidunt. Repellat nemo fugit qui modi ut consequuntur consequatur. Ab quaerat dolores veritatis dicta. Delectus molestiae quia delectus cupiditate.	2024-09-04	2025-04-04
23d41962-cd56-435d-92c1-585b46648c62	a2ee3c19-8717-48c4-9f8a-2a706c2407d2	Quisquam ut nulla velit quis ullam amet.	Optio sit ipsam eum sit eum. Distinctio occaecati repellendus officia. Magnam quis doloremque consequatur itaque placeat. Nemo aut aliquid non qui consequatur.	2024-08-04	2024-10-04
71154b70-223c-444d-a107-5ee2ddf49c28	20eab0fe-4e3c-420d-a79d-62a8a2de1447	Doloribus vitae labore.	Error magnam nobis velit est dolorum possimus facilis. Ut ullam vitae est. Ad iusto reprehenderit. Magni qui quia maiores quibusdam facere ut. Ut sed eos fugit accusamus eaque omnis cumque.	2024-09-04	2025-08-04
b87acc5b-40fa-44fb-b002-4be9cf802ec0	20eab0fe-4e3c-420d-a79d-62a8a2de1447	Nesciunt repellat ducimus.	Autem ad adipisci non assumenda non consequatur. Inventore voluptatem eos rem impedit aliquam suscipit doloremque. Possimus est error porro.	2025-04-04	2025-07-04
75d3023c-0402-471d-b86b-d9d8f266060c	20eab0fe-4e3c-420d-a79d-62a8a2de1447	Quia sed sed natus nisi aliquam quam at.	Porro facere rerum quae sint praesentium. Ut mollitia explicabo qui eveniet. Sapiente laborum dolores. Aspernatur non minima.	2025-01-04	2025-04-04
92ffeab4-de5f-42b7-8c75-c06169fdfee7	e8d66249-846f-46f0-8a3d-4ed4491a97a6	Culpa ipsum eos dolores.	Enim explicabo neque non et veritatis rerum. Quisquam quam illum qui dolorem rerum. Est aliquid distinctio laudantium corporis dolorem. Iusto iusto magni non eligendi excepturi maxime quia. Non unde nemo quia.	2024-12-04	\N
9ea6cde6-e9cb-49ea-845a-bf56cb4660d0	e8d66249-846f-46f0-8a3d-4ed4491a97a6	Consequuntur possimus accusantium blanditiis praesentium assumenda sed velit.	Eaque deleniti ex et odio. Et aperiam culpa. Ullam quaerat perspiciatis ex pariatur non quos.	2024-07-04	2024-09-04
c6b0b42a-ad27-4eb8-bd75-8214c5339e83	2a38993b-d9c1-4883-af49-26c955b55ae9	Natus aut explicabo suscipit non rerum ea.	Facilis vel sapiente et molestiae est magnam. Libero qui aut aut at quisquam aperiam qui. Rerum voluptas voluptates quo minima libero aut. Dolores numquam placeat. Et sit rerum mollitia repellat voluptatibus ad consequuntur.	2025-03-04	2026-01-04
824aca03-dfe8-4207-bb8c-f5d92f7a02ea	2a38993b-d9c1-4883-af49-26c955b55ae9	Aliquam magnam nihil ratione iste dolorem.	Molestiae perferendis est. Eos in et ex. Eveniet hic harum non et. Alias at harum. Consectetur velit et dolore nam.	2025-04-04	2026-02-04
78a34cc7-d6e3-4eeb-80e3-bb427c392fa7	29992cfd-9985-4a02-b328-aa03de1c1939	Veniam veritatis odit iste est.	Possimus repellat rerum eaque voluptas unde vero molestiae. Et distinctio commodi mollitia repudiandae quis accusamus. Et illum expedita id. Qui earum velit est voluptas provident.	2025-05-04	\N
07369c6d-4759-4436-96ba-dfc833cd4271	29992cfd-9985-4a02-b328-aa03de1c1939	Explicabo deleniti velit non voluptatem.	Doloribus voluptatibus possimus corporis excepturi praesentium. Numquam sed excepturi voluptas blanditiis et. Pariatur reiciendis omnis voluptatem.	2024-08-04	2025-07-04
01127f29-8ac0-460d-8cf9-bc67e8fefc8e	29992cfd-9985-4a02-b328-aa03de1c1939	Debitis aut id sit ut dolorem.	Ullam hic veniam rerum numquam. Quam est temporibus. Cupiditate dolores magnam nostrum est veritatis aperiam. Est sequi sint omnis porro illum excepturi.	2025-04-04	2025-09-04
ceac2edd-998d-4f4a-8ac2-26f1a3e05c17	1ca341bb-e272-4f47-bee3-3b0a41f9510a	Corporis inventore qui qui in.	Est illo illo ut vero. Sint debitis maxime officiis ducimus. Perspiciatis dolor ut nobis autem. Est consequatur vel consectetur nulla est veritatis quibusdam. Eos non sunt minus doloribus consectetur.	2025-01-04	2025-12-04
a28c9223-1b12-4349-b96f-aeeb118f9ef9	1ca341bb-e272-4f47-bee3-3b0a41f9510a	Dolore commodi deserunt.	Dolore repellat harum. Perspiciatis voluptatem commodi. Et vel enim illum fugit sequi.	2024-09-04	2025-06-04
0bc632c7-1541-4b1b-8a9c-84113979fd67	36057578-0f4f-4fac-bd29-4a5490801461	Ullam nostrum dignissimos dolor est velit.	Sed voluptas ullam sed quod eos. Nihil perferendis qui tempore dolor eveniet laborum in. Aliquid deleniti atque nostrum. Consequatur possimus nostrum et sit enim aut quasi.	2025-05-04	2026-03-04
f6342af9-48ed-4419-90ca-2456052fe517	36057578-0f4f-4fac-bd29-4a5490801461	Corrupti velit repellendus enim molestiae non sit.	Vitae distinctio ratione impedit et aut aperiam. Veniam ab id soluta pariatur. Expedita voluptas sed autem dolorem aliquam fugit pariatur. Et voluptatibus tempora labore quaerat voluptatibus. Hic veritatis rem aut beatae dolorum rem.	2024-09-04	2024-12-04
96fb6ecc-e3fe-43c6-8bec-62737dea7b1b	e3d5560b-029e-4e74-ad03-daaece398841	Id nesciunt quia et labore.	Laboriosam est eos unde ut. Voluptatum at quos possimus quia quo facere. Tempora accusantium voluptate non repellendus.	2025-05-04	2025-09-04
75a69b57-cbe8-412b-b0f6-6b3d768bdd71	e3d5560b-029e-4e74-ad03-daaece398841	Molestiae error velit dolor et tempore.	Repudiandae sapiente alias. Aut qui velit quidem modi libero ipsum saepe. Pariatur sapiente laudantium. Perferendis molestias saepe ullam ratione veniam.	2025-03-04	2025-05-04
433e2c9d-3b27-4cd0-a263-b870398b3889	e3d5560b-029e-4e74-ad03-daaece398841	Est tenetur et ipsam quaerat incidunt qui.	Expedita ut quibusdam nihil autem quia. Ut quia quod. Quidem sequi in voluptatem sint occaecati.	2025-05-04	2026-03-04
cde4e819-607e-41d5-93eb-60d91cee9a6a	e6390fc1-74c0-4003-87ec-512fe7c163f7	Dolor quisquam sunt.	Qui occaecati nulla dolores ut vero distinctio. Asperiores ratione qui repellendus. Vel non harum.	2025-04-04	2025-10-04
50514d31-c1bc-4f50-a4f9-f206ffbbfe3b	e6390fc1-74c0-4003-87ec-512fe7c163f7	Laborum dolores consectetur inventore.	Numquam laboriosam quia ut optio explicabo minus. Corporis aut officia veniam qui ipsam expedita. Sit non ipsa corrupti quibusdam aut. Libero occaecati sit. Voluptatum doloremque officiis.	2025-01-04	2025-06-04
db52c2b4-ba08-4a8c-ac07-902ead8132fb	156acccc-b696-41cc-a429-69e72f76e2a5	Nobis enim dolor possimus ea animi fugit eos.	Quaerat temporibus accusantium. Id praesentium fuga. Quasi iusto culpa.	2025-01-04	2025-05-04
2650048b-3eb7-49a5-a7d1-fed2ed0f92a7	858cc771-d98e-4b87-91ba-484b7ac82a46	Libero repellat quia.	Dolor quos qui rem et repellendus assumenda. Sequi dolorum voluptas. Fugiat consequatur rerum.	2024-12-04	2025-01-04
e0a15424-8bfa-46bf-800e-20c88efd9121	55d45901-74dc-46ca-9492-d83caf72d393	Consequuntur et sint id et adipisci qui.	A aperiam eveniet suscipit fugiat enim aut sed. Nemo ullam illum a. Quia placeat est ut. Quas mollitia adipisci voluptatem. Et asperiores aut itaque laboriosam.	2025-01-04	2025-07-04
d6c74f40-5d67-49fd-a775-bf862f579d32	55d45901-74dc-46ca-9492-d83caf72d393	Rerum incidunt iste ratione voluptatem velit omnis ratione.	Ea perferendis quasi voluptatem temporibus non aut. Rerum expedita et tempore quia voluptatibus. Dolores et veniam fugit illum. Aut et non.	2024-07-04	2025-06-04
5bc21bbb-05ec-4dd3-a86f-4dffccbe069f	4616d741-946b-4926-b743-9ba387344e28	Vero corrupti saepe quis quidem.	Sint corporis id aspernatur voluptatum at modi ea. In cumque officia porro est nobis. Nostrum cum ea aspernatur dolorem.	2024-08-04	2025-07-04
f510128c-1389-4601-ba7b-a74d3119ff22	4616d741-946b-4926-b743-9ba387344e28	Pariatur beatae et ea iste repudiandae.	Officiis aliquam modi et. Adipisci ad iste illum in laborum provident ut. Asperiores quo et. Repellat sit consequatur molestiae deleniti. Perspiciatis dolor ad laudantium aut.	2024-11-04	2024-12-04
021fa23c-1ae9-46ad-b4dd-40b773574b83	4616d741-946b-4926-b743-9ba387344e28	Saepe fuga rerum reprehenderit est ut non facilis.	Vel sint aut explicabo ut nobis qui ducimus. Asperiores aut et at dicta et eum. Quae veritatis voluptatem sed dolor omnis. Laborum veniam et non voluptates vero rerum.	2024-12-04	2025-02-04
cc62be83-30e8-4792-96d4-b200bbf6bcae	c2903c62-4eaa-4578-bcd5-2ef88659a30b	Saepe officiis iste ab sequi et laborum aut.	Iusto atque quo deserunt voluptas. Consequuntur quos enim qui. Ea qui molestiae eos sit neque. Distinctio numquam ex ullam quod.	2025-04-04	2025-12-04
6b082b37-1f88-4a26-841a-885fa2e62020	ad53b3ff-48ca-4b18-91a6-42da74c01baa	Qui ducimus voluptatem tempora odit enim.	Minus assumenda deleniti veritatis incidunt adipisci iure. Mollitia blanditiis quod nemo necessitatibus est. Cum omnis natus. Voluptatem officiis quia voluptatibus rerum neque.	2024-10-04	2025-08-04
c84bca0f-56ac-4460-8deb-91b3fde76785	ad53b3ff-48ca-4b18-91a6-42da74c01baa	Magni a dicta.	Id dignissimos sequi harum pariatur. Omnis aut natus consequatur dolor officiis consequatur. Vel dicta magnam ratione.	2025-01-04	2025-05-04
acfb6901-13cc-4e81-b778-7aecfd4e487b	ad53b3ff-48ca-4b18-91a6-42da74c01baa	Sint sit eum eum optio illum error eum.	Suscipit nulla sit quam ea. Ut et temporibus aspernatur suscipit molestiae illo eaque. Eos at sapiente fugiat rerum voluptatibus.	2025-04-04	2025-12-04
4aed258f-bbec-46ef-8f0f-f5fe99d3f0b0	5333204e-7c6e-4788-a48f-1eb76fffbb6c	Sit ratione veniam maiores reiciendis nihil cumque facilis.	Aut maiores sunt et labore voluptatibus hic. Id esse tempore magnam quam. Sequi qui et repellendus nam nisi ea earum. Et saepe corrupti. Delectus nam officiis aperiam.	2025-06-04	2025-07-04
ac01fd56-04db-497e-85e4-e9dc40758cc9	6bd47ccf-2c44-461b-9d71-3800301370f2	Quae aspernatur vero fugiat et.	Autem nihil excepturi id quia rem voluptatem. Nam rerum saepe est. Aut ea aut. Quo aut magni voluptas.	2025-06-04	2025-08-04
38779ed9-0886-42f3-895d-c9578bb3de96	6bd47ccf-2c44-461b-9d71-3800301370f2	Quod repellendus doloremque aut similique est dolor quas.	Consequatur quis cupiditate sint. Debitis commodi minus velit temporibus odio adipisci. Voluptates quisquam delectus sint. Earum sint deserunt sit ex consequuntur. Dicta ratione est eaque voluptatem amet quas ab.	2025-02-04	2025-05-04
bf946cde-4484-4d1d-856a-c83501fc0b88	6bd47ccf-2c44-461b-9d71-3800301370f2	Expedita et sint dolores ipsam.	Eum excepturi facilis consectetur vitae. Quos et adipisci vel nesciunt doloribus. Dolore doloribus qui nam est totam. Rerum unde eum expedita nam error sit inventore.	2025-06-04	2025-10-04
f380fe67-3f87-433e-8962-865be7307917	35f09869-9a88-4f45-b957-34138c1dbf13	Eum dolorem laboriosam qui quaerat.	Voluptatem enim est id exercitationem. Minus est labore molestiae eum deleniti eos laboriosam. Nobis necessitatibus dolores praesentium repudiandae nulla.	2025-04-04	2025-12-04
84999702-1bef-497b-9a3c-cd9adf0ef56e	35f09869-9a88-4f45-b957-34138c1dbf13	Quisquam esse nisi aut.	Nam quae rerum harum corporis ratione. Voluptates libero deleniti at. Qui blanditiis ea aut voluptas omnis qui.	2024-11-04	2025-01-04
4e272e37-8871-48e7-89ee-881e0e7bee91	35f09869-9a88-4f45-b957-34138c1dbf13	Officiis tempore dolores temporibus sit sint ipsam molestias.	Vel omnis nihil maiores eos. Explicabo vel ut. Et similique dolores. Et voluptatibus ut sed. Vel eligendi et.	2024-11-04	2025-03-04
d5c3f7f7-4d74-4d69-8b43-7b122df3f73d	00abf49e-6a04-4e53-9345-bacfe3ba52e6	Natus id at.	Placeat velit voluptatem provident. Ipsum veritatis asperiores autem est aut recusandae hic. Ut corrupti explicabo sed. Sapiente corrupti quaerat aspernatur accusantium.	2024-12-04	2025-09-04
4c4e3b5d-10b7-4866-b47d-510c4b8faa84	07c91af1-c12e-4b7f-8ca2-877e3d218712	Quibusdam et exercitationem amet rerum repellendus reprehenderit.	Placeat quasi vitae dolor quia eos. Ex sint dolor quisquam ab corrupti. Quaerat ex quaerat asperiores. Eum voluptatum explicabo cumque exercitationem omnis beatae et. Possimus esse nobis quam.	2024-08-04	2024-10-04
b4c9ff09-b6f3-4e26-9e66-9c47deeb35df	07c91af1-c12e-4b7f-8ca2-877e3d218712	Quidem tempore assumenda consequatur mollitia quam.	Harum sit ut qui aut quia. Expedita autem velit. Qui cupiditate veniam ab.	2024-12-04	2025-08-04
d79693d1-63c5-42b4-8ae5-9e9d1e77d09e	704b39aa-c212-4e80-a20b-7207b3cad366	Qui est sint illo aut occaecati.	Distinctio nihil doloribus nemo voluptas. Quasi voluptatem quam modi labore. Voluptatem fugit voluptatem consequatur sed quia.	2024-08-04	2024-10-04
f7a9b542-a87c-4aa2-bc67-1dbab38dbb15	704b39aa-c212-4e80-a20b-7207b3cad366	Qui quae eius sunt distinctio eum nam.	Atque sapiente debitis. Dolorem eligendi fuga reiciendis rerum. Voluptatem officia quod velit. Eius tempore voluptas molestiae.	2024-12-04	2025-03-04
c3dbff00-203f-4533-a6d7-77b38d411783	7533aebf-2662-4fe7-9178-726965d7fd7e	Dolorum distinctio facere tempora explicabo.	Blanditiis culpa sequi est distinctio et ea. Dolor et vitae pariatur dolores reprehenderit. Dignissimos ratione dolorum quae adipisci explicabo nisi in. Repellendus ducimus qui expedita aliquid est ut dolorum.	2024-12-04	2025-07-04
7f0c9cd5-9071-41bc-8334-f1ca3c7030ed	3392c7b6-8d9b-43b6-a388-a506ada131aa	Impedit nam sit aliquid.	Nobis quibusdam in. Iusto vel illo sed voluptas iste. Et dolorum est.	2025-01-04	2025-11-04
17e46dc3-0bcf-4e8c-b697-868de9b3ab53	3392c7b6-8d9b-43b6-a388-a506ada131aa	Consectetur pariatur facilis voluptatum esse.	Non nesciunt necessitatibus sunt eligendi qui vero. Qui qui ipsam iste. Est voluptas illum suscipit porro sit.	2025-05-04	2025-10-04
651fb32d-a7ce-4de3-bf41-39cf9ba95f46	1d624d3a-9ec8-45ea-94e5-1c9d37c10d02	Impedit ut voluptatem vel harum enim.	Id nostrum autem quo eum facere et laboriosam. Ullam at maiores. Dolorem inventore qui doloribus in labore. Ratione placeat nemo labore nostrum quasi nobis aliquam. Repellat nihil esse eaque vitae eos tempore in.	2024-07-04	2024-08-04
fc39ce8a-a1ef-4599-8ad4-3c2f2af19fa2	1d624d3a-9ec8-45ea-94e5-1c9d37c10d02	Nam alias possimus ipsam in ea eveniet.	Dolor consequatur omnis. Dolore maxime nam quisquam vel iste minima atque. Voluptatum quia aut velit magni qui maiores sapiente. Et autem totam sed et et repellendus.	2024-08-04	2025-07-04
02d7ed01-597e-49d3-ad1e-16e26f3eecaf	1d624d3a-9ec8-45ea-94e5-1c9d37c10d02	Magnam adipisci autem aliquid perferendis architecto.	Numquam vitae modi. Necessitatibus dolores vel quos itaque magni et. Dolores iure deleniti suscipit.	2025-03-04	2025-09-04
2f6f6b3f-5174-4b8f-bff3-2e56f38eb308	f703e5e5-5866-49c0-816e-11590b1d09da	Cupiditate dicta maiores et aliquam sunt ducimus et.	Laboriosam non cupiditate dolores consequatur quo quia. Hic necessitatibus quae est consequatur vel perferendis. Accusantium eos tempora iste rem laborum.	2024-11-04	2025-09-04
bda5f975-5bd7-442c-82cb-c45ca62e6784	f703e5e5-5866-49c0-816e-11590b1d09da	Et totam harum laboriosam iure.	Minima labore enim et id ab. Voluptates maxime provident explicabo at alias. Enim aut assumenda harum voluptas. Nemo sed at odit deleniti quam beatae culpa.	2025-04-04	2025-09-04
28a10188-34e1-450f-a0a9-02d159c2684e	37c2ac00-5f90-4db9-b26d-c3e842ad9265	Occaecati laudantium esse deleniti qui expedita eos est.	Ea quia illo omnis odit. Sed cumque fugit qui repellendus consequatur. Quos voluptatum numquam omnis sint repellat. Quasi sit deserunt aut sed. Ut id nihil distinctio consectetur deserunt.	2024-09-04	2025-02-04
00912dfb-0384-4301-a5fa-97010b6f08e2	37c2ac00-5f90-4db9-b26d-c3e842ad9265	Et error asperiores dignissimos assumenda.	Vitae sunt quia. Minus eos et. Rerum amet ratione. Qui provident rerum exercitationem. Assumenda odit quaerat odio in quas officiis fugiat.	2025-05-04	2025-11-04
793259b0-f06e-4b2a-bfbb-bd35718d48d5	37c2ac00-5f90-4db9-b26d-c3e842ad9265	Possimus maiores ab eligendi.	Numquam aut beatae nihil aut. Soluta maiores et consequatur assumenda necessitatibus occaecati et. Consequatur voluptatem similique aliquam. Quasi eos rerum eos voluptatibus maiores quia. Sint corrupti voluptate.	2025-03-04	2025-06-04
22594d77-ce78-459b-8a5b-ded33be62236	270c36c6-2330-4e40-b534-0cf48ad03580	Ad qui corporis cumque qui iure qui.	Minus praesentium in quo doloribus cum pariatur odio. Voluptas natus quod error officiis omnis. Quas dolor eligendi repudiandae ut quo repellendus.	2025-03-04	2025-11-04
9908d49c-d9b1-48d4-8787-0273c73739f0	f8264a05-db55-47de-ade8-64157af121ec	Ipsam natus quis dolore.	Tenetur non sit est sed eos. Sit in ratione. Asperiores perferendis totam maxime iste quibusdam.	2024-11-04	2025-10-04
b9f2948d-2505-4b23-948b-a979ef020727	f8264a05-db55-47de-ade8-64157af121ec	Et iste sunt.	Quia maxime maiores. Qui impedit consequuntur. Ea sunt voluptatum sapiente eum quia. Eos consequuntur occaecati rerum. Voluptatibus eius eius quos et.	2024-07-04	2025-01-04
10c98e29-017b-4d88-a1e7-5129229d2370	f8264a05-db55-47de-ade8-64157af121ec	Magni deleniti voluptate est.	Quia neque nobis perferendis pariatur eos. Molestiae consequuntur inventore dicta natus enim corrupti qui. Qui distinctio omnis dignissimos quidem. Nulla quisquam ducimus illum iure aut tempore.	2025-04-04	2025-05-04
ffecf17d-66d3-4a57-bdac-77edf1d1b84d	ff3c0225-aebd-4d32-b373-6fb9e240ef8a	Minus dolore voluptas molestiae.	Itaque occaecati et impedit. Quo earum assumenda nulla atque earum recusandae. Dolorem dolores velit quisquam quis fugiat. Aut qui itaque atque pariatur et ab delectus. Unde similique eum eos doloribus voluptas est laboriosam.	2025-04-04	2026-02-04
d8ebb3e2-9050-47c2-bac5-bcc46c09d785	ff3c0225-aebd-4d32-b373-6fb9e240ef8a	Eum at provident nihil debitis repudiandae.	Accusamus eos voluptate debitis. Magni at saepe dolor consequatur aut cupiditate. Facilis aut dicta dolorem rerum qui qui molestiae. Magnam quas ut. Distinctio reiciendis blanditiis quisquam facere sequi delectus.	2025-04-04	2025-10-04
cea9aab9-270e-4140-b094-4fbfb9c4d30e	7dc2e223-4ee9-4ff8-bfd7-86304f286877	Reiciendis et temporibus perferendis qui praesentium sed.	At laborum veritatis eos et. Voluptatem nesciunt rerum velit numquam optio ut. Itaque rerum atque consequatur ullam aperiam et. Praesentium id expedita cupiditate saepe odio officiis. Quas sint aut dolores.	2025-04-04	2025-12-04
6abf67c9-c9c2-4ea6-9d6a-3ea4890457d1	7dc2e223-4ee9-4ff8-bfd7-86304f286877	Occaecati amet rem illum illum.	Sit ullam laborum. Quidem repellendus sed quia sequi qui. Et omnis nesciunt fugit officiis labore.	2024-07-04	2024-12-04
8e431c94-2fec-4afe-ad92-cd36fbcec564	c6a4624b-49b5-4d76-ad75-5c4c388d49e3	Maxime at autem corporis et.	Ipsa voluptatem ducimus. Animi corporis tenetur possimus quidem totam eum et. Quo pariatur in architecto qui eius. Ut ut est cumque iste.	2025-02-04	2025-12-04
842709ec-a882-42f5-adfb-4c0e702ab393	b1ffdfbc-409a-477b-9460-679b1288d9ce	Non exercitationem qui.	Sed laudantium explicabo vitae voluptas optio. Quam quidem error. Tempora suscipit consequuntur est.	2024-12-04	2025-07-04
3dc13e7e-1a7b-45a1-bfac-2a66a56eaae0	b1ffdfbc-409a-477b-9460-679b1288d9ce	Pariatur sed officiis id in quos.	Cum blanditiis quis. Ducimus voluptatem omnis ab voluptatibus veniam tenetur ipsa. Rerum soluta laudantium quas nobis eos.	2025-04-04	2025-07-04
b7236428-64d3-4008-94ef-d467c0493200	b1ffdfbc-409a-477b-9460-679b1288d9ce	Totam dignissimos quasi debitis excepturi vero ut.	Voluptatem aut omnis quia. Voluptatem eum alias laudantium. Hic qui magnam error dignissimos nihil. Exercitationem ex et excepturi aut ut.	2025-01-04	2025-04-04
eb199168-483d-4e96-b965-4b4c7fabef0c	13e86e43-7909-4166-8164-593019247f89	Ut assumenda veniam nihil vel asperiores iste.	Consequatur sed unde aspernatur. Porro id voluptates aspernatur dolorem. Enim minima sit omnis et qui ea reiciendis. Dolorum optio consequuntur doloribus odio sapiente et.	2024-07-04	2025-04-04
ed43c63b-377a-493d-8882-e2b1d87a446f	13e86e43-7909-4166-8164-593019247f89	Enim provident est aut inventore quaerat est.	Omnis adipisci aliquid voluptatum eum assumenda minus. Doloribus ad suscipit aut ut. Consequuntur neque necessitatibus nulla dolor. Soluta quo explicabo ut. Voluptas est adipisci.	2025-04-04	2025-12-04
1ae8983b-d969-412b-9681-ab9293a6fa51	13e86e43-7909-4166-8164-593019247f89	Alias omnis eaque repellat fugiat nesciunt corrupti est.	Tempore sit hic sunt ea eveniet. Necessitatibus non sunt voluptatem recusandae. Dignissimos dolores voluptatibus.	2025-01-04	2025-09-04
78fcca31-5098-49cc-8727-3b49f6253204	6b266b30-16d3-404a-be7c-678941d6f5cf	Velit voluptas et eveniet praesentium aut sint consequatur.	Ea aut suscipit. Unde et illum molestiae quia ut beatae. Fugiat voluptatem id fugiat sed.	2025-04-04	2025-10-04
\.


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.profiles (id, user_id, legal_type_code, verification_status_code, verification_comment, created_at, updated_at, avg_rating) FROM stdin;
fda73321-e721-4560-80b8-b062c5090883	5c33412a-38f7-4856-85c8-b9322c62fb4a	gov	passed	5c88rktiivusp8mjqvrhkkrpf00rh30dpzkzvz29ifim2clpjfuo8b33ks4oqc7psafrmyizyc7f8biosyf14b9zn8f1tcirs6egkwvt5jcp5vvqpnhq8olwns8p1tnobus6lugi3wahms6avgpq6j8i5vwukhv3pryk86xvxy	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
9bcc795d-4d12-45f0-a592-77f24671ab64	70ce0785-73a0-45a4-8d78-93ecba17cb9c	ip	passed	3oxpv9juznh8n2c71az8n3zp1ir4tf0ahf5ut05oisaefz46udcjvviaeroyyrtr33s8wnndynfsjq33q2hioitfqwa4qamma36szbrzw7fbuf8k0i0gior868pz79wy0remd7fgn4buu5v8pkzm4knuhnniycxjg4p9iwpe8ijvxt1vskj7c	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
2949b03e-6239-4fd4-a61f-b34fb973f132	5e846192-3f8c-49f7-9906-4e4a0f3ef781	company	passed	45voekbojw74cz09j0d0y9mrouir7ilncyfww9axvaqff2cq6ddah0d4zds966bdxx4iltxwlb0xygxup2c06v9dq5u43w8ceeitv04hm3chji7wvfyup2vmcuwn	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
cefd3d85-4f2d-43a6-bc56-f848d4f794ef	50272aa6-b626-447b-afa3-2b1d7d15787a	person	passed	6d0eit12qvo0tpeny2tms4vl0bw68q281o2fwkfmv21rfqc99gn0dzkk22cchtk7awfehrhm72u3cg8i989omjrt21nt4qy9ah8ptlblrgvy1iwp56lvh8xgr3kaku7hgu55nulo2412domrmnnxsis3d5kzafmj0kdq8ffqwxgti6ku6nj6s6e1g72raf1cqbhkku1ruorlmdoejire1upvpo7cvxf7fyw	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
6d8ad48b-3ee4-4d10-bce3-192b94b54b00	43556e5a-c501-446c-b81d-59bf84dfe7ea	person	passed	pz3l6ycd4b3wnjs75f34ybnhaxhugevb4bsczagy74aja5mdo0enxd4ht01vm3y7kgocdef2oaonsf3ftbw17gejg3e9pb6dlyuec6pmef4ewhkf2dans9o7fis3j5lma6xhcpxb76wsakw39j8ldobk6yjhumc3g	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
75c21222-cce6-4d68-8967-2f22c594a6b1	2bc7acc4-6bf9-4f53-860f-2a07de92e7f6	company	passed	5xneahitznhc80v7hqtd4bys2rfemlo279imj1551uxywd8bxruj6uiby2jgxlb9m8jbg6ylsildaxddj1h43yvppwsrrqcm0ygipt4596lohbkb6p1ayii9bs468j02ikxevy92uvu9m	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
2a1753fe-265a-43a2-a791-580a19693ace	bc2f6dea-df57-4796-9f20-4a38eda07225	gov	passed	4dub5phry07zxbw2yr8ehdzys47y4h8vha8gc5oaf0zxtfy4jag8rt1ejezaatsv4wnn72d1jvc3y5gjsk62r9fnnp5vr6dp8f1xqtgy07tw4ylqdie9p	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
ae22c8fd-4347-4b8e-be79-53718a01c39a	4bf92c1a-44eb-4161-bd36-dd3a2845a695	ip	passed	ivs6b2tm5irpm9ot0np1ouc0n56gp013xl2epy87qgppi5aymevsvrthxnonaqpowr9fm8deynsfwv73sukb6nmsriitnynribohksuac9uc6glm5n3i5eypyss4m9gq0mso8xhh57pejb3171hncxdn6rtgh5i2dod5n36vwglze5ypnk6zrc07qkubqew6mpna4z0me6ged1w9r8a	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
0cd37e88-6dcc-4359-b195-3a25d9895663	0a09a631-3f80-4aa3-96cb-2155f61a8323	ip	passed	63zs7sobeqdl3o4lmbmg6rtiliqkbdgv96z051gxw6y1x9e4268qt49vs963mjr4e2p8indxd1d1uaurd4q6h75nkgy9ysupsovoeccbl9byrgml0qa7trcc0sqe4cuglmj4gdpjc9bw7vfusv66i208asaqkjzgsn8jhp0qe3hmnjoyfomf4ebhlsbwd14h	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
2dec1f5c-08bd-4048-91ad-057147189e4b	f16b102a-2bdc-4e39-8ccb-6544be128b7a	ip	passed	01intfkm175u3hxxia2kka5wernxmxop8yycngct3u2bwwsab0p1xl9ced0avkwqnh78cmpk6cwym0lk9wst8jszwclpfivr5x4ays331lcgapg4wtpx5ymc08ds6znu3r2lbfqnck9dlbt5x9ohgcgvzktsgw	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
996fe158-61f3-48b0-a31f-05c472524c62	5ed43614-a394-456b-8cd1-f387037826de	person	passed	v1an8dxnhh3rqf5h4cpis64ejfhzr91df0lr809b0rfku6d54dcnfufru0oau1u604juk6c3yrj1o95dsmqs0aqq0hq2nyg2vegzzhxd6aodeq3pn6hyvimtfmb38hczzxey2mknlnx12elpi5qg	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
48ba213c-aab9-4494-9a67-6e915ceb1678	57dc1fb3-c63f-487a-a348-9d43a58f7287	company	passed	hczqzekzf2c11w3rrx27csa2kqb02wx4ji5cblydv5s5aivtet6bu0lax292q42eb9jchyowef0lixf2opqgpa7lbr4lvkvhtzgvm6qwwtw5mi84ayw60uqv6ia26n9cdjrg487h5llk5tu8omj3356c5	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
ad2e6944-7b0c-47b7-b442-b61bdbd75933	c21491b1-1794-487b-932e-9b4827ff8365	gov	passed	0ys4pxomj1jfmsz0bhk1hr5w4anwtq1p0w4zejbc98fei3oiwv4q246uz3skzue5j2i8yvrur86o2x5uy2dclh0nojaxjrwi9cuo9qbu05k53mu3ood6l2dquqhb52zqlqnpzb8e8bxpfjxvj3pci8fnqos2lew5k0ydwb42w6ownwsbz80a4aqsbpoynbus15z7	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
1aa256a2-6261-47c7-bf21-6456747e4ba7	e831937b-abf5-4d9d-aacd-14d729a07054	gov	passed	qgi0kdwib82wuigk1qj8sr1ojgqbq7eu2f65rsbbhzetyia669dyu495brc02d6fdgjlp8qhraseu9yzvyld9twao4h2kzj1ud416mde1u2bfzcb2v7u162vzfu80l6w3kkk	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
707a452d-939c-4a48-ae87-5848c2a1c63e	46d8b973-2d30-4392-a8f8-03e6fa1358b4	company	passed	i95a7azy59rqjvua79uwbqc2uweaa3cke9dsx1sxan469kqsjvu1qntzlh9u46mgvvyjthxtfrrbbz2gdpwm5323fak1b260nda6w242qibu112qxhsgln4t0beogrjkol8xyqq7mq89ah2lg1jdtz03kgombobspmp86iv981vyrou	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
a2ee3c19-8717-48c4-9f8a-2a706c2407d2	5af4786d-4f22-4b8a-b1b0-925a45a17693	gov	passed	ul2dpnjhz2d7xb3fzrj3bjau8u9ge1nba6qfyhkboka0j9bogq7sfd7bqp2fj9bl18e1af94skr7x4cly384j7ipqndazf6ifyd8gvycc99cbmhigrykpfrcihmtgzk9m1c1lz8gu1n2llww2iiuff1903vsn10qot2mtu1ncqerab0ml88vttqnbo13ve4mwxksksmxyotprmdks	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
20eab0fe-4e3c-420d-a79d-62a8a2de1447	5f02884b-aa53-4ed8-8b74-29ca74ae8515	gov	passed	5k3x8s14ypb0q331hleiuphz6je4eyrpqnis27l5gflpmnjujcbelvlzpsmcmzf7xruj61yd5c9msr9vlefxc3s7dhjb84s3ikryhz5a5b472cyeqgvo78rz6fw8v36v1bqk3tlqtspx4yi48x2uwsbs51ts	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
e8d66249-846f-46f0-8a3d-4ed4491a97a6	ffd449ba-4e53-4e11-8d02-40b2455581d5	company	passed	bl0eflqbim5bywsi5m82rw3qgwcz2hbrpxcjb2wbdsk27pqwg2sdklg2vw2fdi831pbh8d0uh3ar26klmbs62fh3rn6ttjz22912nys6s2ogw9u9bhscj8k9qc7yu65t4c1n0tah9fq	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
29992cfd-9985-4a02-b328-aa03de1c1939	9cf2fbbe-7853-47d1-b8fd-b263f8da2dd1	person	passed	m6940ksqwv4oyfz6ylcv3ynob3g2e667r3ryfqka1pz6jhh6wb3d0pg3kj4vu0dat2verzw9w9xmr9yco3x75mmsacxjvli085drt0pl1jm4msrznbwg8g1r3ogg8lkk0295b4q88ny1mxo64iq9n0gochvmdjwc4kv1z148wpt	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
1ca341bb-e272-4f47-bee3-3b0a41f9510a	d8e9d218-616e-4ff0-864a-23a6ab55da73	company	passed	o8krwvhdrc6y6w1u6rfeahu7fxk22g61mi0f315dnns9st15nm5xbghhnk1mahe8hz6n2zo68upkjs0lbaktyv32ysrdyf6cfn6t7jcp	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
36057578-0f4f-4fac-bd29-4a5490801461	c132c2bf-c21e-4c2f-b9cc-36e978e76908	gov	passed	m3wlf3rxmpg3mjwr8rp1d9b2m1jv38u229sv7vav1q3lgz6jii14ertcwxmkq08kzxgj54oz756619okxs17actx22eev43ebz252qibvcduqoas6bjegkixi41903t8g0oep4w033oeygxd0axhpqt8ezhmsmuu7qceqntytw3tpbtd2uxtjzlar7cg052sgv4npndt	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
e6390fc1-74c0-4003-87ec-512fe7c163f7	7448bdbd-8eaa-48e7-b00f-9d64c330571b	gov	passed	meb25qu5purkcyamnig546md6jgrppfggdbit47frlidrki6hot8bks9cf1hbqlhvy61nbfx33ey5czc6e3v2tgjjkhp6mix0icujq7gikuqfaxbo823xdq0reymb611jsh9qyndf91d8y7t536vovok0u1cdqftr8erfvmmo0dbcz28upw8o7drpvy0	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
156acccc-b696-41cc-a429-69e72f76e2a5	6add1836-558f-4d1a-929b-606db7b58de5	company	passed	cl42dzsoqonmd3i3w2wqa6qwrq4c60f3lnxhq4r207mmgtkugdffvkm23cs3jg640pzuc3a2ur1d5khqj6rd67idov6zk2d3p1s9az7szruznfkp	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
858cc771-d98e-4b87-91ba-484b7ac82a46	600fd83f-8f30-487f-97fc-b874c9c5039c	company	passed	yb3sihcn86xp8ls464wy7135no3peus04efl89xa0h4debf3qaed43kbqso2ftsg39sjjl84uv146cduiu3no4hm52er1c830zi29o8ariwcyfledyb0osdzhm	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
55d45901-74dc-46ca-9492-d83caf72d393	3dac66e8-03ab-4ef5-b8f5-e429736cd315	ip	passed	2qq9eambpnmiydpavw6coiu7lqn05au4s8u3utqfai5otdy1rdubjhyb0zeulwkvbwjzmhwh06u92bu7122ilw3b3dmlcj7hl3m377w3ghyndjlw181vixfawivejtv0kdmx9yas070cdtfa8arxy2gcdn4g6ghosigj7mey	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
4616d741-946b-4926-b743-9ba387344e28	c578a4b3-d17f-4201-8469-310a5efc1126	person	passed	np7wonqby7ut1yf7vqybon175ha2uf8ait7ekec8ngujmgfzrr7affavvx5y9fvq1parfd6twntr9421bjbbkf5abkxd8sp6bqixz1giz7vv57lbnu4qztb2e3t7uhjhu70azrbzw63baregafxed70	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
5d4185c7-bec1-4af1-97e3-0df252431772	f3fa4ae9-2fec-439b-a043-ecdac59fbd09	company	passed	ah24bx7elyh2y7mv2shvnt1sp14lw6dewo2wm5h39f9y7y29a6zj509o99durs13g9z5cony60w5dg3u5n1f5sv7ijzfc7wlskyce5pfuv6mbyyu3dymu4uemhdwc8q7u2fkcpvpo5icuf555nv8ipkhiwnmrar7slgpm41	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	2.00
c2903c62-4eaa-4578-bcd5-2ef88659a30b	77702d6b-f044-47f2-bf61-1eeabf8aaa9b	person	passed	o2q78mws409prvg7ycd6ffpy9uy0sxdh1dzytkmc71mfzlg9k1ejycc6v1wlxbu0plziagg9h0eflrilr5neohzdixblx5vfwfrbd7kkemecdbq7jdt5562ona1lqlwm2ep5h3ar0aunw3l87ps6h73q6f48n1xqener6esl1xqsolvvxoc204c7m0ig5jndhxmydetzpmu73rqoubxxzdp0czxj2max7xh	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	2.00
ad53b3ff-48ca-4b18-91a6-42da74c01baa	38cd8d9e-3491-40da-bc55-4c069b4047de	person	passed	93gnt85p56wymhnofwiq9plq02k6nv9bpculooucvwc3nybamtslhh4kg8dhoc2lwtgzdgpmpvs4zf5tefnacjwcl15xtk3e2jy0np60fy8x2bvgfsk0ifby95b0agmd8ozkv2dm9jxbkwn1ynmsxqydv38qx7x4cpjkdc5cs9ex8zqe2z1874tqnp	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
5333204e-7c6e-4788-a48f-1eb76fffbb6c	37e737cc-01e7-452a-b5db-4935de64eb5f	gov	passed	i84pz4vxldijmemszk2grp94eoo7rodctor9fn68m60akc96qpcjty6am0wjsbz7kbg4n0nx4nnwopvfjqdfty80ail5tf63z8uucdq4zzm3ecgauwxwkep8up2pxmaajlu3i0vgbj6eqtszbb1tyxf50ybrxinurzjix3i1d22ww4wfijho	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
6bd47ccf-2c44-461b-9d71-3800301370f2	9900ea36-2ca1-4dd3-8dd3-d707b6a8fb0d	person	passed	1fdnq4l3h54anjlgzkras52jrr2gzw9k8kv6q0wkvjliqqj5cydrky00agqlzelppxi13wby9rku64uslnexmalrqsfdzk0ek7nzw9u49tnznbi0if0suqo5nolwqlv2cdah5wunjch5t0cdntem9w2dgzzqtnp5iokji7apxk2jkv4fjejtmhpozivimxbopva1zom01613ht9nfpovle80dpbhrbc62jv719b4n60vag	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
35f09869-9a88-4f45-b957-34138c1dbf13	07978f14-8190-42e3-9999-b51480731a6d	gov	passed	fp0bh4b37saxtdxw2w5cd6q5wahukr177buhiqwxjnikwmy2vyu99u652np2a8neq70mbclfg042v46qhkyivjuripa3nhpo0oq0zmwakg3j7kjvkylvvv8ggkddv0zd2vhsf0wix7ozgo3mdzhrlhqb5fk02jpi7olnnb02ro	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
07c91af1-c12e-4b7f-8ca2-877e3d218712	3b9df985-7065-4474-83d2-28b298404bf2	ip	passed	pvm136m3mwzxix0qh08mle2ett761k3oxdpjhqd2zp47mq2dj39a0kmqdot5qpj3qo0yytn8zzhgmjxg2obhkagfmrukyomk6oiu2ca6eby2ihakw4arwe5aoiau3143xd43kmtvkppfiujgrifct3v68gclu46xpyhptr7vqd7d5kl8	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
704b39aa-c212-4e80-a20b-7207b3cad366	bba6ba0b-d8c7-4a28-ab8e-62b657a1ca94	ip	passed	5dhh2bbuvs1pphp6h7s7wks19wi49mlilco4i1k0b9ozwt8zkhftkf9kd10ml59ofbnqq8ddgjq9mxvj1dgcpbv5ttexfgr1g9zrtv9y	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
7533aebf-2662-4fe7-9178-726965d7fd7e	55d8ac63-cabd-4b25-90c4-70d82759862f	person	passed	59qli6iw9lpzgmk1boinbc9eqhvoi3mt7m764irv2j4jt37mgleqcryv8ceksn0gtc6vxkxzkdmeyz4wriu2q1heu4fnckdtesgjksvlehjxy3z2c2mz05k2bpe8qzedrh3myzqranzk26vhj62ki0s767t2gbjgl5praou1upibk0t	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
3392c7b6-8d9b-43b6-a388-a506ada131aa	8a50a51b-f6d3-4870-8a1a-ba5eb4d10b6f	person	passed	z9voi1rfllfugeug7xcwo8ztidqf93zi8abjhx9w1nn5yy5dh1cqssi8l6il5cmbp5txvbngpbbcy21itc9xp9g6zrre77dqqhi6jjm3p7b8i4okkvmttado72x5ero4yoliiaxurlhvpan6w542nsd43pli2cy0rk2trb2cmm2nsc99qk9o0x76	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
1d624d3a-9ec8-45ea-94e5-1c9d37c10d02	2eb659ec-30a6-4d9b-a744-584290717a73	ip	passed	5rqo01940o7d1figfyd8ri80u59s0al4iqhxjsq7del0klprqy2bxfqsl2sneta6q0x9l8f9noz7vqc6hblaccr8imugq5mh9hs13yw5cqmbutubtdqv5obhxkbzxp	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
f703e5e5-5866-49c0-816e-11590b1d09da	ddc4ecd3-9abd-49be-add0-1a919620fb35	gov	passed	oq31dlaoiwjlz0nr6nv78bkvr4eghq8gki6lwvyfltzh5o5kmz7zlf5e3vvamdurwcwypmsvbcyexo99cuea6h33byhpv7ad5e756b5yuwtf0pe8hdyda416bd5ocr0lcisdxt1az3e1ty2z9zi	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
37c2ac00-5f90-4db9-b26d-c3e842ad9265	7b9edadc-37ca-464d-9b06-51931dd2fc24	ip	passed	9ixbyr7idq8ri99y3v3cfeqv6ynyxfzz9wqyb6pls70meg3ufzsm4ny4ryu149zqyyghmqpwjr6yppmzli4zm8w3zewb07dvz6ixw851gluj35w6x	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
270c36c6-2330-4e40-b534-0cf48ad03580	2b748d02-13e3-4c56-a774-fc1841027cfd	person	passed	b6izd6jbqln2mx89tqnoyadna3mdx1o0bnhtvui3c5obgt3qnpguq2obhotjumyu0sz4kb6dsy46a7oasur7mlecz9x9hy09tm7881iltk4b0fv5jxuwznfgxiqbb2m5rj3bbc1vgjkgp0578a6s9wn1exlima0uslk2dj8yggwmbjpgjy7kf7qtug6xz9ycnohfmjs4a67f9kyg10c8vlhharlpmx4	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
f8264a05-db55-47de-ade8-64157af121ec	f97b4a83-f14f-4eb8-bfe9-232f3fef80f6	gov	passed	9jht9e7mzdb3mje8wpawax86nsv2ledyyc0rwkzrllyozuxqochsikx0yftaua3m9b0lvtq33kgviooy40fslccougak7ssxzss6btgg7behy6nipo33fdj7wujo08rwwolz8ge54tzg90qnaguj1nwj8h4z5ds	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
ff3c0225-aebd-4d32-b373-6fb9e240ef8a	3162a5f9-37f3-41dd-aa21-3f5262bed586	company	passed	0r48cbycy4dpamphmnbian37hjldtqihivphsxhuocyoioouwpn6yu6qpvywqec66pka4alholepyvypag7132ke9xq3u8rfayz3se2x1hf62p2pqc191fitu9lkk4yg0a10m1ud55v9v45jht0jtq436fxp1qxoacmd90nhnhk9w3i	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
7dc2e223-4ee9-4ff8-bfd7-86304f286877	ded722dc-9021-4324-ab92-62f0b056cebd	gov	passed	1zcj7wl0oa5ay2ay3qd4rg4ls8ww29n191nuikj02no6yzkdgsjwf7e7mcd0kg21c0c50njliv4r7w5blhk7osd5q42zz12q9hmokukhe1zx66xtnykvhiavzx0wcqulv7qqbmkndq13qib18y0k3bc29iy4z1wskee8ltt37pge42ohdeag6pa400cbn7axzrgmhswhsmuyfvo0ilwcoybr0ar9x4	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
c6a4624b-49b5-4d76-ad75-5c4c388d49e3	9cb3d6af-e521-4a64-b95f-f69f17f377b2	person	passed	sx94e5aufeexeski31yfz3g88hianqzszk6cp9al38ivvjy9lhyf9rwhaje7otqn5i6xfjnlqsicpu353i2b888h39mlj5quxk30lcfu5s0kulvjamt7lp9whp3k8bncw6a2pf2g35tc	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
b1ffdfbc-409a-477b-9460-679b1288d9ce	55702c54-5b25-4f00-aea3-d61a0f43cc60	gov	passed	mmwhepkqse9qr7orswwrl2cf8lwnzf1zwvqo4tc4ynky7dk1w5d4chp8jjl3fox0f2fte3qkfetvvx82vabutcidip9detq04m8o07q7mkhq1o7ceqbs427bqow88ao16z8m959a8knishamsl5bh8sn	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
6b266b30-16d3-404a-be7c-678941d6f5cf	928dd269-eb62-4f4a-992d-a3a8d0dd1d98	ip	passed	lxfghqetta72dh4z19sylw4io1sjreydyb78gqpxq62mu8gn589tat6dpjnmltzl3ln9h4k7ikfpuwknemerzo6gti3ic1fmiwhhnffouoiy13c6gfe57388as7fb0694g4ju79kauzja8qt77x4im856u3drgf5ttwrj976t5j3p8kgvp3e9rlev4vozgnygetpd7drxz9yytuy0vt0oo8fmencjw5yzcopk	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	0.00
e3d5560b-029e-4e74-ad03-daaece398841	99026b27-e389-49de-a555-868e3529fdc5	ip	passed	r62orw33psgfvwttcg33c40ot54m16egptyg56ngf3iqyr9ir92h6w5jvh5pcxkukiqx7trsm6ka27ni4ycd3bkg87aosse14k95rkzaenz09xpqbrfn6sqkp91anhya9dpyksfm0fvnqopxx40j9nealonaqiythr4mygz6omkbtku9axamvlgo14w2qvu2fwb3h440l8uk6y18xi7qc183p57epvwkx	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	1.67
2a38993b-d9c1-4883-af49-26c955b55ae9	4ee49614-d5ac-4747-ad7b-53e8d011c033	gov	passed	7j9qlzl9q2waz83cd93f895pe9dt70f4zrrq5bwaej3mp267agf1lbftu2e748g67evy72bdu92rmiithtwu5qss9134hv80e54g75y9rf769pnphbwhyy65x7dqoh4fpvkp9ddi5avzkehi7enqmxb6138u7iepi814o8c8	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	2.50
13e86e43-7909-4166-8164-593019247f89	88f7f35c-f5ad-4a41-b61d-e1cb92bbe610	gov	passed	kapc5m8nirjzw7jno36jnl3m4jx836bttjvx7k9ch4jxmgvatpd2mf7zi5c1psddfjvj2bauj4lpcksb5jf0oaq4w8369ryd6k8qfuylrii7qji7x5hqj1m8qzejfkiyjgvfl7zjtw1wuill7n1zfc84t	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	2.67
00abf49e-6a04-4e53-9345-bacfe3ba52e6	25eb8322-21e4-4a89-a485-5e267d2bfef6	ip	passed	wghsijj8nemdol7cqk83e0y7rpmdwpk77kcgeouokdltw1daf5vasnpe98jp00gp4mbu62zn0dd99b18gsbxvttic0zubfashdp7umm9b424305is3tpdslzffhs96xqplwfefoubp3nu3ot3acdsu1hure0evhmia21mjfy3p1xy263ivem5v9smr2yy8qkk9bypk59oyorjb860cd0c9dwz3999nx03949tj5bs2rh9jkoqtl2him	2025-06-04 18:55:34.593617	2025-06-04 18:55:34.593617	3.00
\.


--
-- Data for Name: project_mediafiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project_mediafiles (id, portfolio_project_id, file_url, file_type) FROM stdin;
b690daba-c07b-4ace-8412-da6d581bcf86	e320dfce-6b00-4c90-84d2-d5ba3465c55b	www.kendall-douglas.co	video
d646ba9a-9224-4587-a3ab-226452fd7f29	e320dfce-6b00-4c90-84d2-d5ba3465c55b	www.danial-denesik.io	image
19143d37-6666-4728-91cc-a3e20c1abd83	e320dfce-6b00-4c90-84d2-d5ba3465c55b	www.kip-kunde.co	video
20435c0a-13b3-4e62-ad91-d0cc1b607ced	ddf43f9d-0479-4136-8471-91a4dc2e1c53	www.isis-kirlin.co	video
0ada6df4-04f6-40a1-98dd-df39c0922e46	ddf43f9d-0479-4136-8471-91a4dc2e1c53	www.romaine-fisher.io	image
978da9fa-bdf8-4fa3-a243-f806147eedf2	ddf43f9d-0479-4136-8471-91a4dc2e1c53	www.osvaldo-keebler.org	video
82963195-32c4-4744-af13-6990624122a3	44428f35-82f0-4ec2-a350-44c0f70d55a2	www.gary-bartoletti.biz	document
03b69bfd-5ada-4d84-9b04-7e14b184321f	44428f35-82f0-4ec2-a350-44c0f70d55a2	www.glen-kshlerin.co	video
c794bf05-a381-411d-9931-d62df7777ed2	44428f35-82f0-4ec2-a350-44c0f70d55a2	www.terica-hane.biz	video
967127c0-af00-4e43-b2fe-a4545943b233	13a4b138-10ef-472b-89a5-7cfb84c459a4	www.jeanetta-dickinson.net	image
5b19cbdc-1a7f-450e-88f8-8f29f9efe34b	13a4b138-10ef-472b-89a5-7cfb84c459a4	www.kendal-lockman.name	document
d3cb7c70-60df-4b32-a51b-a300c830a31d	13a4b138-10ef-472b-89a5-7cfb84c459a4	www.dorian-ortiz.biz	image
f355af99-fe40-4ec8-a45b-afead5f33f60	506eee2f-d834-41ad-9e48-24f90afb5f13	www.laureen-haag.org	image
913fa3eb-df6d-4384-b33b-03c1621c46e7	506eee2f-d834-41ad-9e48-24f90afb5f13	www.marinda-jacobson.name	document
cd225585-a860-44df-a0fe-1b08fbd3a9d5	3acf3f9a-a017-45b7-b9bf-0c3ba19d3efa	www.kenyetta-moore.com	video
ff6fd5b2-2e4d-4105-8b84-b2ec5132d0ba	37c31f68-49b7-4a2a-b067-d0d23abe2686	www.theo-steuber.co	image
ac382ecb-4005-4f10-9b4f-7dd13d598e96	37c31f68-49b7-4a2a-b067-d0d23abe2686	www.dionne-gutkowski.com	video
a0959838-6203-4817-953a-01cd4ad7782d	33304522-251c-444c-a3bd-fac78f73248c	www.shaquana-mann.io	document
087f14ee-4603-46b9-b226-64c5bb591ffc	01e6fba6-be45-40d7-ab30-6c0a0607843b	www.gino-schulist.org	image
788c9dd4-31ec-45d6-b343-e95e17746464	69256d0f-a42b-46bd-9bf7-63f406a999f3	www.leonard-ruecker.com	image
6d3f04e0-17f3-4a91-b2e5-91a7faa7c066	69256d0f-a42b-46bd-9bf7-63f406a999f3	www.ocie-cassin.co	video
d3d01839-1f2f-457e-adf2-58dc329fd7c4	100b910f-ceba-42dc-b534-7ce1910d0911	www.vera-wilkinson.co	document
bb84c4b8-7f56-4797-b7fa-54d736a74e52	100b910f-ceba-42dc-b534-7ce1910d0911	www.claire-treutel.com	document
e94a7832-51b7-4238-9e35-7d3fec02eeaf	a3df2afd-a108-4e31-8ed8-050ab7eb40d9	www.donovan-kub.biz	document
d253978c-883c-4df2-8938-ed0c1256cf5f	a3df2afd-a108-4e31-8ed8-050ab7eb40d9	www.georgie-kreiger.biz	video
53a13d64-2a76-4a62-8a63-4e981da98747	60d298cb-4fd1-4b09-9a2b-dee0f8109078	www.neely-prosacco.org	image
6c057edb-a96e-470a-8b34-585c0e3eb64d	60d298cb-4fd1-4b09-9a2b-dee0f8109078	www.kelley-streich.co	document
166901f9-c18a-4cc9-91b9-e83fe889de39	5cd2bfaf-a931-4ea9-a830-2652029824b6	www.kamala-kertzmann.io	image
deb6fbdc-bdd5-4151-bd61-0f72c1b67060	5cd2bfaf-a931-4ea9-a830-2652029824b6	www.loria-macgyver.org	video
a25a7711-0043-4b9e-a5cb-8f046f3032f6	5cd2bfaf-a931-4ea9-a830-2652029824b6	www.earl-toy.net	document
55919057-3016-4520-945c-2576f1e6e58b	34373718-616b-4431-91d2-af323710d43e	www.fredric-brown.com	image
57f5ce39-208f-4eed-870e-696310485073	34373718-616b-4431-91d2-af323710d43e	www.buck-satterfield.co	video
af09dba4-6e45-4a2a-9047-ad872d99eac9	34373718-616b-4431-91d2-af323710d43e	www.minh-hegmann.info	document
00fa4abc-7880-4b5e-8a5d-80b7e5896679	e56bb816-b4b8-4a38-8853-fe8247658e3c	www.gonzalo-lindgren.io	document
3a209006-401c-4e1d-8c2d-9c8a17abebd2	2dae6fd3-a9d5-4328-bd59-e612bd8162b5	www.leatha-okeefe.name	document
a26b26d7-6875-4c89-a213-06635da37a21	2dae6fd3-a9d5-4328-bd59-e612bd8162b5	www.gaston-jacobs.co	video
aaf6b9c2-2fe6-48c5-a848-3adcfdf83775	2dae6fd3-a9d5-4328-bd59-e612bd8162b5	www.sanford-flatley.name	document
5433f538-5b13-4c2c-9115-0da0349829b5	d0ab2df0-ddde-4931-871c-c221bbc57997	www.freddy-mertz.org	video
20cbe3d8-462e-4240-b9a9-aa93b65a3619	d0ab2df0-ddde-4931-871c-c221bbc57997	www.tony-keeling.info	image
c87ea469-f4a0-4dd2-979a-f1d9112cdb65	57457771-bdf3-4837-abcc-044cd6935a85	www.peggie-mertz.io	video
71bacf91-2ebf-4cf9-ac42-ef4d2d37623a	57457771-bdf3-4837-abcc-044cd6935a85	www.maud-cartwright.info	document
ff16c622-9cef-45cc-a757-f67244992008	57457771-bdf3-4837-abcc-044cd6935a85	www.rikki-reichert.biz	document
2e7721e1-4ca8-4f29-8048-09ade0e18a14	31b082f2-27c5-45d4-8d30-a6e51b3e9a8c	www.douglas-davis.co	video
548a2ab4-b240-4483-9ad5-547685cd1f30	f3e470fd-bbf3-4d78-8be0-1be29f5f7758	www.cameron-tillman.biz	document
cb7e2085-f8bb-43fd-8acd-939a40642394	e0189063-ef0d-4cb4-a1b0-9cf50d821d34	www.mohammad-stamm.com	video
fd64f655-0d23-46e0-9be6-fcb8241eede9	e0189063-ef0d-4cb4-a1b0-9cf50d821d34	www.randell-gulgowski.io	video
7aa41755-fd2d-485e-9ad5-136140277824	e0189063-ef0d-4cb4-a1b0-9cf50d821d34	www.catherin-raynor.biz	document
dbbfbfc1-847f-4475-adbc-ac954da62eab	a9a0022e-6085-4002-807b-7c046097d32a	www.cherilyn-morar.io	image
fd0c1a84-87b9-435e-b2e8-b2db491b6209	a9a0022e-6085-4002-807b-7c046097d32a	www.ofelia-balistreri.io	image
338a9963-74ab-47a3-85cf-71b896f7deb4	a9a0022e-6085-4002-807b-7c046097d32a	www.alvina-gibson.net	video
005cd9df-8883-4449-a24f-5e31d07dac84	1660ed05-21a2-4ce8-b61d-9570f5ec5507	www.anderson-sipes.biz	video
08121256-96c9-4ddc-8350-af08f76fc8f4	1660ed05-21a2-4ce8-b61d-9570f5ec5507	www.diane-hansen.info	document
26af0d95-fa71-4f20-97c1-4f1ddac06dbd	08b227f4-3d22-406a-98d5-6818a3bd72de	www.genaro-greenholt.io	document
978619e0-4be0-46eb-8f6a-7e3415226bcd	c3912bfa-0f45-4227-b7e9-b1508855606a	www.thaddeus-crist.info	image
59544788-0fe4-46d7-8726-e27059d271bd	c3912bfa-0f45-4227-b7e9-b1508855606a	www.luigi-jenkins.co	video
47a58f96-bcc3-415a-af95-2549a3527503	bece2079-0284-4c6f-9a07-9cb94bc215a0	www.gerald-hammes.biz	image
1572e055-53c1-4396-ac31-e6ee3ad8ded3	a329f5c8-38ce-4709-87c8-1fbd1e010a25	www.merlin-spencer.co	document
fe5cbe02-d5a4-49a7-a24b-4df0633a9aba	a329f5c8-38ce-4709-87c8-1fbd1e010a25	www.adelle-powlowski.name	image
143cbf50-ce1f-4d7d-92f5-930052757444	f8062b87-748b-4eb6-ac4d-33b863d6d78e	www.arthur-walter.io	document
7bbc6777-9d29-4afe-9d70-efa1f726b728	f8062b87-748b-4eb6-ac4d-33b863d6d78e	www.todd-mitchell.org	video
737bff53-3c19-4ac1-a71d-d90084f75df6	c8306394-afbb-4692-a6e8-c5b8bf5725ea	www.amos-wisoky.co	document
40892592-4a01-4168-831d-b0037188f1bc	c8306394-afbb-4692-a6e8-c5b8bf5725ea	www.jon-kreiger.io	image
501916db-1b97-4c80-8753-5adcd3c671d7	94e9a7f8-1a90-4990-802f-df680c53117f	www.randell-kris.name	document
5fc2a56b-b911-4aa9-aaed-9e9b01143bc3	94e9a7f8-1a90-4990-802f-df680c53117f	www.stan-ortiz.name	document
3fe1a83c-901c-44e4-a394-5830e8c76b8d	94e9a7f8-1a90-4990-802f-df680c53117f	www.damian-stroman.com	image
f63408ed-2eaa-4249-98d8-e733a34eb111	4b493d49-ebc0-44af-985a-f4e4734076aa	www.jude-fritsch.name	document
b14eb14c-8126-4371-9872-2777aa0a1a47	e4b0db23-91d5-420b-a38a-4e391c71fcb2	www.kevin-brekke.co	document
fccaab22-7524-4aff-adca-c90ddbe448d7	868ff2a3-f526-42ff-a024-02c2721aa78d	www.art-cormier.io	image
da12c4a6-5f0b-4ab9-8077-a371e5521bba	3be061f4-0510-4852-b358-3f21c3090e80	www.jackie-pagac.net	video
b6d19914-2b9a-4a44-8d92-d1e4fb7d4d3e	3be061f4-0510-4852-b358-3f21c3090e80	www.chad-effertz.com	video
7f3df9b9-93c1-4a5e-bcf6-9988cd166f02	cbadf037-338c-4dc5-be4f-548528ff5fe2	www.ann-hansen.io	video
43902480-0078-4fba-89b8-332ba9b0cafa	cbadf037-338c-4dc5-be4f-548528ff5fe2	www.reinaldo-zboncak.org	video
bf92aeb2-189d-4297-808d-84e2acc25c9b	cbadf037-338c-4dc5-be4f-548528ff5fe2	www.cristen-heathcote.org	video
d26e6329-65d2-418e-9663-a2903814bd2d	67207a21-fb40-4776-96de-54d5057527e6	www.jeannette-heller.io	document
92142d1d-1c07-42f5-a4d9-17a087746bae	67207a21-fb40-4776-96de-54d5057527e6	www.kirk-prohaska.info	image
ecca4eeb-d507-437d-87e0-ee3b0bc2843f	67207a21-fb40-4776-96de-54d5057527e6	www.carlton-bednar.org	video
79bc4c55-d42b-42db-91f9-42ddb7141a8d	4f494c8e-dff6-4687-935b-6c1b097966f8	www.kristeen-considine.co	video
dc8d96ed-3c7a-4895-9532-896accb835b9	4f494c8e-dff6-4687-935b-6c1b097966f8	www.paz-morissette.org	video
30a45d05-df11-4e8e-bc7f-e48d1653fb7e	23d41962-cd56-435d-92c1-585b46648c62	www.ellsworth-von.com	image
03e3bc62-c2ba-4c8d-a5a1-2ab077714a57	23d41962-cd56-435d-92c1-585b46648c62	www.mayola-friesen.org	video
769aa9c2-c46c-480a-a162-497bbc2bef0c	23d41962-cd56-435d-92c1-585b46648c62	www.meryl-cartwright.io	image
f2ea8e82-97e7-42cd-90ed-6def2719b190	71154b70-223c-444d-a107-5ee2ddf49c28	www.mickie-collins.com	document
10bf22ff-131a-4127-8370-5e1fe66d87b1	71154b70-223c-444d-a107-5ee2ddf49c28	www.sandi-upton.org	video
066144b4-5756-4617-a7e2-71ce3bad283d	b87acc5b-40fa-44fb-b002-4be9cf802ec0	www.fae-sipes.com	document
7c37e00b-6cb6-49c9-8911-a63748d5dcbc	b87acc5b-40fa-44fb-b002-4be9cf802ec0	www.cammy-sporer.name	document
4b999ebb-d756-4744-aaf5-06e1cfd974e4	75d3023c-0402-471d-b86b-d9d8f266060c	www.adelaida-price.co	document
8b190c7b-2167-489e-b85e-bcc854f63efc	75d3023c-0402-471d-b86b-d9d8f266060c	www.kristel-murphy.com	image
0bc3dbad-9e9e-4289-a4db-983a10ed212a	92ffeab4-de5f-42b7-8c75-c06169fdfee7	www.brock-crona.org	video
eb0fc0a9-cc1d-447f-be30-f8e0d200338c	9ea6cde6-e9cb-49ea-845a-bf56cb4660d0	www.esmeralda-casper.info	document
e278d4e6-081b-4586-8ae2-a9fe67b84986	c6b0b42a-ad27-4eb8-bd75-8214c5339e83	www.eun-yost.co	image
c1f34188-de94-446c-b4e9-b8402776da13	c6b0b42a-ad27-4eb8-bd75-8214c5339e83	www.tracey-batz.net	video
1b35c7fd-b14e-481d-b77f-8e0f3b8ab519	824aca03-dfe8-4207-bb8c-f5d92f7a02ea	www.cheree-armstrong.co	video
1e6ea0e3-2465-41dc-b490-415200cb0ef1	824aca03-dfe8-4207-bb8c-f5d92f7a02ea	www.alene-abernathy.io	document
9ffe2e40-7ffd-4a99-9163-653fd7db268b	824aca03-dfe8-4207-bb8c-f5d92f7a02ea	www.monte-kuhlman.co	document
551f91e5-4812-490f-ac24-dfee439db235	78a34cc7-d6e3-4eeb-80e3-bb427c392fa7	www.romeo-graham.com	image
4847a12a-c08f-4e82-a877-0c4f467a1279	78a34cc7-d6e3-4eeb-80e3-bb427c392fa7	www.foster-yundt.name	video
10f98e33-a8bf-434b-aad4-124d005bc1e8	78a34cc7-d6e3-4eeb-80e3-bb427c392fa7	www.lamar-oberbrunner.biz	image
b7995857-21ff-4aaf-bd13-ac78fff83611	07369c6d-4759-4436-96ba-dfc833cd4271	www.chara-lang.info	image
856fe7d2-3abd-4d10-a1ac-fb4992be3e63	07369c6d-4759-4436-96ba-dfc833cd4271	www.brent-mckenzie.net	video
6e223c31-4bd3-480f-8911-d477264885ba	07369c6d-4759-4436-96ba-dfc833cd4271	www.laquita-stokes.io	video
ef12bebc-e3bd-4444-b836-fe0c86755b23	01127f29-8ac0-460d-8cf9-bc67e8fefc8e	www.ralph-rath.info	video
c697028a-7878-408d-a0b1-3c10c5b8cfec	01127f29-8ac0-460d-8cf9-bc67e8fefc8e	www.malisa-kshlerin.io	video
4aa955e6-3972-4dba-bbcf-abe1ca24c9d3	ceac2edd-998d-4f4a-8ac2-26f1a3e05c17	www.stanton-baumbach.biz	image
4e77475a-4f11-4bbf-900f-45a35b422b59	a28c9223-1b12-4349-b96f-aeeb118f9ef9	www.charlie-emmerich.info	document
eab083aa-624b-4377-ad98-898d8112e6b3	a28c9223-1b12-4349-b96f-aeeb118f9ef9	www.shoshana-satterfield.org	document
7d3d7ce0-8468-4d68-bbec-a80268503ac9	0bc632c7-1541-4b1b-8a9c-84113979fd67	www.jonathan-stiedemann.info	document
3f84034c-a8f6-4d43-866d-d66898295838	0bc632c7-1541-4b1b-8a9c-84113979fd67	www.donald-runte.com	image
4a17e4cb-3a93-45a7-be5a-9b191efaa54d	f6342af9-48ed-4419-90ca-2456052fe517	www.shu-bins.net	document
074da8e0-3006-4855-8e93-ae081400a4da	96fb6ecc-e3fe-43c6-8bec-62737dea7b1b	www.landon-kunze.co	video
07b57912-746e-4b3a-b7ba-3b030b840dae	75a69b57-cbe8-412b-b0f6-6b3d768bdd71	www.kerstin-kemmer.io	video
0da69f3e-aeaf-482f-a4a9-c4d65fcf1b1c	75a69b57-cbe8-412b-b0f6-6b3d768bdd71	www.roma-donnelly.biz	video
861a332b-6263-4580-8e23-200da16a06e9	75a69b57-cbe8-412b-b0f6-6b3d768bdd71	www.tyson-becker.org	document
5984fa82-f058-4e67-8c71-103591d63412	433e2c9d-3b27-4cd0-a263-b870398b3889	www.nguyet-white.info	document
50761276-a102-497e-ae83-a8d73edfa42a	433e2c9d-3b27-4cd0-a263-b870398b3889	www.hilton-breitenberg.biz	video
366025d9-d895-42c8-a260-9405c22e7cd5	433e2c9d-3b27-4cd0-a263-b870398b3889	www.stephen-blick.co	video
586f8b7e-8bd1-4252-9537-ed4631aa1ca4	cde4e819-607e-41d5-93eb-60d91cee9a6a	www.sarai-lehner.org	image
eb62c37e-3dc6-4003-9e76-691e639a6798	50514d31-c1bc-4f50-a4f9-f206ffbbfe3b	www.mozella-casper.io	document
3cb144b8-3844-4eed-9ffd-57058d2ef21e	50514d31-c1bc-4f50-a4f9-f206ffbbfe3b	www.ivan-russel.io	image
a53e52e3-5226-454a-b2cc-0ee279d7026a	50514d31-c1bc-4f50-a4f9-f206ffbbfe3b	www.maira-jerde.biz	image
dde4f663-d63a-4f96-b67e-30e0bad446d0	db52c2b4-ba08-4a8c-ac07-902ead8132fb	www.johnson-hahn.info	image
96a45f08-af48-4f35-a43f-26498b4bbee8	db52c2b4-ba08-4a8c-ac07-902ead8132fb	www.shu-bergnaum.org	video
e73033ef-040d-47a8-94a1-595da877dbe5	2650048b-3eb7-49a5-a7d1-fed2ed0f92a7	www.marcelo-schimmel.biz	image
06727330-78bc-495c-8569-b4cfa0319787	2650048b-3eb7-49a5-a7d1-fed2ed0f92a7	www.hung-harber.info	image
675d3a12-4e74-4936-bc9d-14efbdee6608	e0a15424-8bfa-46bf-800e-20c88efd9121	www.destiny-beier.biz	image
b7c3d2bf-54c1-4400-8d9f-7bbc23fcdf1d	e0a15424-8bfa-46bf-800e-20c88efd9121	www.isiah-schroeder.info	document
fdfdeacc-6806-4805-9e8f-f277f0ff41c2	e0a15424-8bfa-46bf-800e-20c88efd9121	www.lilli-russel.net	document
7ec0ee92-cdb0-4617-9286-17d4007f5584	d6c74f40-5d67-49fd-a775-bf862f579d32	www.robby-lubowitz.info	document
ad74c2d9-6865-445e-bda3-3466f294caa8	d6c74f40-5d67-49fd-a775-bf862f579d32	www.delmer-stehr.info	document
3d1f0bfa-8c39-4419-927a-d84e7aed4033	d6c74f40-5d67-49fd-a775-bf862f579d32	www.delia-mohr.co	video
917860bb-0b17-48dc-8875-b7ee3f0397d6	5bc21bbb-05ec-4dd3-a86f-4dffccbe069f	www.ivan-witting.net	document
7f6f75b8-0f81-4276-aea8-028c52e9cb32	5bc21bbb-05ec-4dd3-a86f-4dffccbe069f	www.arlie-johns.info	document
7af204cd-5dc8-4140-87ff-16ab8dd14283	5bc21bbb-05ec-4dd3-a86f-4dffccbe069f	www.mindy-wolf.com	image
c3c1fa7b-d348-447b-ac75-3355fdb558e8	f510128c-1389-4601-ba7b-a74d3119ff22	www.sage-ferry.name	image
54b30f8b-8b40-4ed5-a770-2b8c9c5de2b9	f510128c-1389-4601-ba7b-a74d3119ff22	www.silva-swaniawski.name	image
2f6be99a-64d2-41cc-9d23-6b37c4dbf9c9	f510128c-1389-4601-ba7b-a74d3119ff22	www.antoine-yundt.com	document
c286dc74-d2f5-4bfc-b35f-cc0a2f3efa86	021fa23c-1ae9-46ad-b4dd-40b773574b83	www.clyde-ziemann.biz	image
48d1a1eb-8e60-4073-9b4c-23aad2ceb5a2	cc62be83-30e8-4792-96d4-b200bbf6bcae	www.florene-torphy.com	video
d93d63df-0810-49f4-8699-c446bc403a32	cc62be83-30e8-4792-96d4-b200bbf6bcae	www.pete-fisher.com	video
527b4c6f-e8f3-41b0-9f39-4be5278cbfa3	cc62be83-30e8-4792-96d4-b200bbf6bcae	www.jere-will.name	video
e24bb7fd-9c95-44cc-b233-20a117f8bda8	6b082b37-1f88-4a26-841a-885fa2e62020	www.burl-rolfson.io	image
4e9010c0-5a88-4a44-908d-cc4c7eab6ac0	6b082b37-1f88-4a26-841a-885fa2e62020	www.margarita-price.name	document
0bf33c21-a6de-41b4-92b1-988b2ca3266f	6b082b37-1f88-4a26-841a-885fa2e62020	www.meri-carter.info	image
bdb5a91d-41b0-4fab-a711-a3aa1e1f020b	c84bca0f-56ac-4460-8deb-91b3fde76785	www.detra-kulas.biz	video
994b7cc0-cc73-491f-aab4-0ef819ff3d95	c84bca0f-56ac-4460-8deb-91b3fde76785	www.hobert-schaefer.org	document
be53571a-b97d-4485-96ca-573d1c097f11	c84bca0f-56ac-4460-8deb-91b3fde76785	www.adriene-okeefe.com	document
dde3ff50-4ce2-4ecd-b7be-70136b318074	acfb6901-13cc-4e81-b778-7aecfd4e487b	www.rona-batz.io	document
1862e8c8-7805-4f02-8ea7-24025d3972be	4aed258f-bbec-46ef-8f0f-f5fe99d3f0b0	www.madalyn-bruen.co	image
8994e081-3d3a-495c-9ab6-15a49c6ccf2e	ac01fd56-04db-497e-85e4-e9dc40758cc9	www.daren-dach.co	document
f6441c54-fa12-44c7-a2fe-a261d1284703	ac01fd56-04db-497e-85e4-e9dc40758cc9	www.gwendolyn-romaguera.net	document
5640d9b0-beb6-4683-8f32-e8de1fbed0a1	38779ed9-0886-42f3-895d-c9578bb3de96	www.prudence-maggio.org	document
e46b7e3f-d94d-4d3b-a9da-375a9f375187	bf946cde-4484-4d1d-856a-c83501fc0b88	www.laurence-johnston.co	document
b3de9d6a-d9c8-4784-997c-5820347e81a8	f380fe67-3f87-433e-8962-865be7307917	www.delmy-grant.biz	document
bd453954-807a-4538-a45c-b62e0817a85c	84999702-1bef-497b-9a3c-cd9adf0ef56e	www.makeda-carter.io	image
2d4b4ad0-15dc-47b9-8ce0-c40da5aa9100	84999702-1bef-497b-9a3c-cd9adf0ef56e	www.foster-vonrueden.co	video
bedc218a-283a-4fc4-af82-5b4b5e708caf	84999702-1bef-497b-9a3c-cd9adf0ef56e	www.misha-ortiz.com	image
02dd5494-bbf9-45b1-9b8c-ef87efaf9cb1	4e272e37-8871-48e7-89ee-881e0e7bee91	www.milda-quigley.org	video
d5c732e0-727b-4be5-b732-aad3fa41a92e	d5c3f7f7-4d74-4d69-8b43-7b122df3f73d	www.loyd-turcotte.co	document
abace3ca-59c0-406c-8b90-2abdf84ac699	4c4e3b5d-10b7-4866-b47d-510c4b8faa84	www.eustolia-hegmann.org	video
469ab051-fa3e-464b-a166-7b28d180285e	b4c9ff09-b6f3-4e26-9e66-9c47deeb35df	www.marcellus-hintz.info	image
c7bcbdb2-6edb-4979-94fd-0a07cfe241c6	b4c9ff09-b6f3-4e26-9e66-9c47deeb35df	www.charmain-streich.io	video
c0001bee-fd7c-41d5-a768-2df768a5f925	d79693d1-63c5-42b4-8ae5-9e9d1e77d09e	www.eliz-effertz.info	image
110fbff4-514f-4680-83df-435c7467f1db	f7a9b542-a87c-4aa2-bc67-1dbab38dbb15	www.katelyn-roob.name	video
91abc130-24ba-4444-9f1b-26ea78942de6	f7a9b542-a87c-4aa2-bc67-1dbab38dbb15	www.mazie-littel.org	image
e20b5417-93a5-45b7-a52d-f7b9ac0bcfed	c3dbff00-203f-4533-a6d7-77b38d411783	www.lesley-fay.biz	image
f3a024e9-69db-4ace-9c5a-9b682cc12749	c3dbff00-203f-4533-a6d7-77b38d411783	www.joaquin-grant.biz	video
3272e717-4168-4601-a273-2ccbfd422d9d	7f0c9cd5-9071-41bc-8334-f1ca3c7030ed	www.mauricio-deckow.org	image
a1323757-1942-4f6c-9a70-d21fdf5a6c2e	17e46dc3-0bcf-4e8c-b697-868de9b3ab53	www.luis-donnelly.org	video
b396e331-1d5d-4975-a333-677b86ca9b5c	17e46dc3-0bcf-4e8c-b697-868de9b3ab53	www.florencio-dickinson.com	image
4aaafa6a-0dfb-45b8-9a4b-6ea4f1498d56	17e46dc3-0bcf-4e8c-b697-868de9b3ab53	www.darnell-armstrong.info	video
80377e15-a2c1-4d34-95b0-ca929fd1467b	651fb32d-a7ce-4de3-bf41-39cf9ba95f46	www.vincent-prosacco.co	image
179f4cd4-c30a-4f37-a77f-b6c04022582b	fc39ce8a-a1ef-4599-8ad4-3c2f2af19fa2	www.tanisha-bauch.net	video
a664a11b-0271-40ce-ac4c-937387f6b050	fc39ce8a-a1ef-4599-8ad4-3c2f2af19fa2	www.rickie-dooley.com	document
14513aa5-940f-4461-acc2-38524a1b8859	fc39ce8a-a1ef-4599-8ad4-3c2f2af19fa2	www.rodrick-mckenzie.biz	video
209b0605-ac78-4e5b-9255-0a5b50154ed4	02d7ed01-597e-49d3-ad1e-16e26f3eecaf	www.coralee-jast.net	image
a2265025-b7f5-4610-8a02-b1ad168d6c78	02d7ed01-597e-49d3-ad1e-16e26f3eecaf	www.rima-runolfsdottir.biz	document
ef054ced-22b1-4234-ac8a-409c90f74a41	2f6f6b3f-5174-4b8f-bff3-2e56f38eb308	www.deshawn-cummerata.biz	video
9a3382b0-db41-48ea-b49d-8d8ae1833d1e	2f6f6b3f-5174-4b8f-bff3-2e56f38eb308	www.ignacio-barrows.io	document
7798941e-4889-4a52-a69d-e9a543653b97	bda5f975-5bd7-442c-82cb-c45ca62e6784	www.keiko-runte.net	image
e42c787f-6403-4e89-a879-3741f8dcf10f	bda5f975-5bd7-442c-82cb-c45ca62e6784	www.noah-pfannerstill.io	document
90cd473d-a015-490a-b016-722a10230784	bda5f975-5bd7-442c-82cb-c45ca62e6784	www.gaylord-mayer.net	document
32f4ba10-8a3d-4fc7-aed0-a78c251a3b9d	28a10188-34e1-450f-a0a9-02d159c2684e	www.annetta-feil.info	image
5e20e92d-7604-4bcb-b5ea-5485b34678a9	00912dfb-0384-4301-a5fa-97010b6f08e2	www.emogene-johnson.net	document
08e107d5-e48a-4cdb-a70b-01ccdb45ead7	00912dfb-0384-4301-a5fa-97010b6f08e2	www.orlando-bergstrom.org	video
4851db5d-4668-427d-8861-a56a539eda04	00912dfb-0384-4301-a5fa-97010b6f08e2	www.odell-reichel.info	video
c1ce7751-539c-4741-89af-3aaa7a1858a4	793259b0-f06e-4b2a-bfbb-bd35718d48d5	www.raymon-cartwright.net	image
35b1aff0-583f-4223-bb46-35a96b05f975	793259b0-f06e-4b2a-bfbb-bd35718d48d5	www.elroy-abernathy.name	document
0151e522-9a2d-480b-8a74-f3c008a79671	22594d77-ce78-459b-8a5b-ded33be62236	www.bronwyn-jacobs.co	image
256dcd18-7d52-4da1-a201-534624c39204	22594d77-ce78-459b-8a5b-ded33be62236	www.meggan-howell.io	image
0d6b7091-86f7-4611-ae79-d70b36693f14	22594d77-ce78-459b-8a5b-ded33be62236	www.jesus-carter.name	video
5b35f0a7-d67c-4d2b-8b9b-eb7d27217151	9908d49c-d9b1-48d4-8787-0273c73739f0	www.mariann-metz.name	video
fa32d378-dc16-41bb-bea2-01bad3f41493	9908d49c-d9b1-48d4-8787-0273c73739f0	www.eugenio-heller.org	image
ce367bdd-0a79-4b03-bf72-80ee194a79d3	9908d49c-d9b1-48d4-8787-0273c73739f0	www.willodean-parisian.io	image
c4d1644a-dc4d-477c-b1a7-17f797f3d80b	b9f2948d-2505-4b23-948b-a979ef020727	www.marquitta-heidenreich.io	video
1246332b-36a0-4e39-a721-7ba52f1c336c	b9f2948d-2505-4b23-948b-a979ef020727	www.willis-kilback.com	image
10aeb1bd-f266-4a64-81c8-e029f559f2e4	b9f2948d-2505-4b23-948b-a979ef020727	www.rhona-doyle.info	document
af639880-2a84-4c7d-88ee-93034adf5c5e	10c98e29-017b-4d88-a1e7-5129229d2370	www.karey-nitzsche.com	document
15375635-7a3f-4f1c-aba5-fce75a274f3d	10c98e29-017b-4d88-a1e7-5129229d2370	www.erwin-cole.com	document
7726d456-90cb-414f-a294-4f6b005441cd	ffecf17d-66d3-4a57-bdac-77edf1d1b84d	www.len-beahan.info	image
54767d04-f0f3-4901-98db-96c672a57616	ffecf17d-66d3-4a57-bdac-77edf1d1b84d	www.giuseppe-kuhlman.net	video
309a0a11-548d-4ce6-8963-51bfad72db5d	d8ebb3e2-9050-47c2-bac5-bcc46c09d785	www.art-johnston.co	video
d9eb568f-65cd-4cf6-b0c4-6630d71b609b	d8ebb3e2-9050-47c2-bac5-bcc46c09d785	www.nickolas-hansen.net	document
2489bcf9-d525-4bd0-a78c-61f1fb223c56	d8ebb3e2-9050-47c2-bac5-bcc46c09d785	www.erick-schinner.info	image
dc668cf5-6218-4185-a69a-3210a26374f6	cea9aab9-270e-4140-b094-4fbfb9c4d30e	www.mechelle-sanford.info	video
444c47f3-e271-4940-a85a-53f8d5aae4a2	6abf67c9-c9c2-4ea6-9d6a-3ea4890457d1	www.greg-rau.biz	video
f6ee907b-e255-48f4-a23f-2e82ba0ced99	6abf67c9-c9c2-4ea6-9d6a-3ea4890457d1	www.dwayne-nienow.biz	video
88423921-103c-4773-aa71-4edada6bafa3	8e431c94-2fec-4afe-ad92-cd36fbcec564	www.diego-hayes.org	video
62ee2d61-b2a2-4f90-8e1f-4fa3dcefff1a	8e431c94-2fec-4afe-ad92-cd36fbcec564	www.alexis-hills.net	image
6eddbb23-b33a-40d3-a356-a42746b90451	8e431c94-2fec-4afe-ad92-cd36fbcec564	www.shila-yost.io	image
9dbfcddb-9daf-4576-906b-6b2008867d81	842709ec-a882-42f5-adfb-4c0e702ab393	www.whitney-hayes.info	document
f3472fb8-bd73-428e-adff-2b1b83ee35c1	3dc13e7e-1a7b-45a1-bfac-2a66a56eaae0	www.garnett-fadel.name	image
19e5faff-0080-46e3-ad1a-b02adea929c2	3dc13e7e-1a7b-45a1-bfac-2a66a56eaae0	www.chere-nitzsche.org	image
e7c48f2b-4e76-4122-8b65-b8bca7a71273	b7236428-64d3-4008-94ef-d467c0493200	www.aleisha-dooley.info	video
409dd68f-329c-43fc-87e4-234046cdf55c	eb199168-483d-4e96-b965-4b4c7fabef0c	www.rigoberto-reinger.info	video
6c218dc2-8733-434b-bbd2-2aab6962973d	ed43c63b-377a-493d-8882-e2b1d87a446f	www.hong-schuster.name	video
44c93a27-7d6e-43c3-8046-a8c0b8d839fd	1ae8983b-d969-412b-9681-ab9293a6fa51	www.kirby-marvin.name	document
c8bc7f38-d305-4d7c-89ea-adb930c67ffe	78fcca31-5098-49cc-8727-3b49f6253204	www.bridgett-christiansen.info	video
18737036-0431-40f7-97de-e66f92f682cd	78fcca31-5098-49cc-8727-3b49f6253204	www.frankie-bernier.co	video
\.


--
-- Data for Name: publication_mediafiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.publication_mediafiles (id, publication_id, file_url, file_type, uploaded_at) FROM stdin;
c6d27440-f809-48bb-b302-f729ce6578db	95e9c3a2-ff0b-437c-90e6-6a58e874ca6c	www.bethel-nader.com	ogg	2025-05-19 18:55:34.777351
b7b5861f-e34b-403e-af22-6c97666dd98b	25283b85-148d-4c24-a6c8-2b2b8a11a514	www.hobert-lesch.io	wav	2025-05-23 18:55:34.787529
7d4d2450-1420-458d-a1f3-5537df2870de	f24f53ff-2176-44b7-a901-076b121a8c53	www.estell-lynch.biz	png	2025-05-17 18:55:34.788169
659d1a59-08cf-4d95-a71b-b7ed68f37faf	f24f53ff-2176-44b7-a901-076b121a8c53	www.valentin-macejkovic.biz	ogg	2025-05-21 18:55:34.788379
4d802ba4-59f1-4228-b5cd-0e31362696f4	a934ec89-1b2d-4f26-827f-bb077c9878db	www.denisha-mosciski.co	jpg	2025-05-12 18:55:34.789168
012e050b-c159-4dcc-907e-eb5a129cb7d6	bc24dba2-d4bd-4b6c-95c9-50ebdf2abb9c	www.jamal-schmeler.com	wav	2025-05-22 18:55:34.790643
00afcc1c-5e01-4ee1-87da-4c2a0fd45708	bc24dba2-d4bd-4b6c-95c9-50ebdf2abb9c	www.avis-satterfield.biz	jpg	2025-05-25 18:55:34.791032
c4bc3eb9-accf-4165-a010-2fcd7ee0ee8f	bc24dba2-d4bd-4b6c-95c9-50ebdf2abb9c	www.sung-halvorson.name	png	2025-05-30 18:55:34.791403
840e9c8f-47be-4aa7-ad07-1fba6c87e21b	906f6597-d02f-41fa-a382-f21a423c8edf	www.fredda-kautzer.net	png	2025-05-12 18:55:34.792201
ce58c4ee-c3ea-4547-851e-52cdc92195e7	906f6597-d02f-41fa-a382-f21a423c8edf	www.claretta-runte.net	png	2025-05-25 18:55:34.792566
f868b73c-7fa4-4aa6-8ab4-413641ec8028	906f6597-d02f-41fa-a382-f21a423c8edf	www.john-klocko.name	wav	2025-06-01 18:55:34.792919
728dbe9a-0684-4837-8376-18e1b19e9055	38035b3f-8980-4e63-bab4-3f4fc1741ed1	www.porfirio-lindgren.info	ogg	2025-05-08 18:55:34.794597
1166c140-0c1e-4fd7-b1aa-c6deb9bab24a	38035b3f-8980-4e63-bab4-3f4fc1741ed1	www.sylvester-conroy.info	jpg	2025-05-24 18:55:34.794877
e5ca7649-7e2f-495a-be84-cf8d9d3e9fb8	93aa563e-dfd6-4cf0-87e2-72b7fe7fd088	www.alden-white.io	mp3	2025-05-28 18:55:34.795647
d64b76f5-df1c-4dd3-bd06-e483af07f507	93aa563e-dfd6-4cf0-87e2-72b7fe7fd088	www.tory-cronin.net	ogg	2025-05-12 18:55:34.795842
cb0843ee-6c11-429f-8091-b02fb61f2602	ca03a72f-b0f3-4b9a-a157-7b5c2d785be3	www.charmain-collins.io	png	2025-05-30 18:55:34.796353
d0a25a59-b8ac-4294-90d7-654ac8fc9c28	ca03a72f-b0f3-4b9a-a157-7b5c2d785be3	www.rene-mcdermott.net	png	2025-05-26 18:55:34.796568
03bfb86d-0aa3-4a4d-bb3c-34f02e73f4b6	6f7190c4-9de6-4a67-a119-033ce47b7427	www.kerstin-green.biz	jpg	2025-05-28 18:55:34.797083
1cb204e6-5522-47f3-9e19-fe0849b647e4	6f7190c4-9de6-4a67-a119-033ce47b7427	www.ami-mertz.org	mp3	2025-05-18 18:55:34.797283
cda29547-83e0-451f-b85d-f50143a7d03a	6f7190c4-9de6-4a67-a119-033ce47b7427	www.stacey-weimann.co	ogg	2025-05-30 18:55:34.797507
c7a32692-b10f-447b-9ca0-f563919f9a95	6f7190c4-9de6-4a67-a119-033ce47b7427	www.irwin-bauch.net	mp3	2025-05-17 18:55:34.797702
888077a3-1168-4cb2-a856-adce65a1d391	ed2681f3-f659-48e4-a1e9-5f50a68e6a40	www.nova-haag.net	wav	2025-06-03 18:55:34.798211
04304d59-d8e1-481a-b5af-1fb03c32a8f5	ed2681f3-f659-48e4-a1e9-5f50a68e6a40	www.lakia-pfeffer.io	wav	2025-05-06 18:55:34.798426
65cc7293-3514-49e5-8949-f1c192ced5a7	ed2681f3-f659-48e4-a1e9-5f50a68e6a40	www.cortez-schaden.name	ogg	2025-05-15 18:55:34.798753
39d2d31f-8a74-4092-9f82-edc052d43c72	ed2681f3-f659-48e4-a1e9-5f50a68e6a40	www.ardath-powlowski.io	ogg	2025-05-14 18:55:34.798991
57806f51-ce9a-47e1-bb35-313706ca9bae	ed2681f3-f659-48e4-a1e9-5f50a68e6a40	www.jayme-brekke.biz	mp3	2025-05-24 18:55:34.799277
d029bbc6-c1d5-44d4-a7a7-81ac95f370d7	943509ed-5b40-422f-bfab-913001b18de8	www.jackie-mayert.io	jpeg	2025-05-09 18:55:34.799881
bb27d737-7c50-4a46-98e2-b23d2d370bd5	943509ed-5b40-422f-bfab-913001b18de8	www.shirley-legros.co	png	2025-05-18 18:55:34.800075
92bfc4ca-7246-4071-8152-d635cdd47bcd	943509ed-5b40-422f-bfab-913001b18de8	www.wm-kuphal.com	ogg	2025-05-16 18:55:34.80027
09a12ef4-624b-4bc6-8c00-d7ba8815fc9d	61063498-d770-432d-bfc0-99e6aa91ff9f	www.stanford-spencer.name	wav	2025-05-23 18:55:34.800958
f2258b9a-6e06-424a-ba12-024c46832616	61063498-d770-432d-bfc0-99e6aa91ff9f	www.patricia-blanda.biz	jpg	2025-05-12 18:55:34.801188
d1300784-03e9-46fc-b876-6ac14ac1398e	61063498-d770-432d-bfc0-99e6aa91ff9f	www.ok-keeling.net	jpeg	2025-05-16 18:55:34.801403
3469a338-0d76-42a9-a903-c9cbd84709f0	61063498-d770-432d-bfc0-99e6aa91ff9f	www.shirlee-rath.co	ogg	2025-06-01 18:55:34.801613
fd9b27e3-a57c-4892-a7ec-0e49407a1aed	79b825c4-6c7d-4eda-b8c5-d19b8ae9a4c2	www.heidi-grimes.org	png	2025-06-03 18:55:34.802583
92fbe65b-45d9-44ce-8959-92cc7bcebc03	79b825c4-6c7d-4eda-b8c5-d19b8ae9a4c2	www.rosendo-baumbach.net	jpg	2025-05-12 18:55:34.802816
f55c182e-ed26-4134-b446-26a32ffa6efc	79b825c4-6c7d-4eda-b8c5-d19b8ae9a4c2	www.rachell-bailey.net	png	2025-05-26 18:55:34.803
6bd55488-e6f1-49a6-8b62-cca62b883b2b	7d230267-35dc-4560-b05b-165ac4ffd03e	www.audra-wolf.biz	jpg	2025-05-22 18:55:34.803853
2813aa7b-4d3c-4283-bd44-12146e36da17	7d230267-35dc-4560-b05b-165ac4ffd03e	www.doug-cummings.info	ogg	2025-05-20 18:55:34.804053
39b55633-4d60-46f4-915b-be30048d88f7	2cfd914b-bbdc-475b-974c-f483329089be	www.toney-hodkiewicz.io	wav	2025-05-26 18:55:34.804868
8c4b96e1-f241-4322-afd5-beaeb7fe0779	2cfd914b-bbdc-475b-974c-f483329089be	www.kimbra-padberg.org	wav	2025-05-20 18:55:34.805088
c0c681b2-1612-45b2-82c2-8b7c089a8d68	2cfd914b-bbdc-475b-974c-f483329089be	www.rupert-conn.info	ogg	2025-06-01 18:55:34.805276
0f98aa8a-c484-4623-89c3-f20efe4e0002	344a6cf9-2798-4b9d-b1a5-4461c116e2b0	www.kelly-satterfield.net	png	2025-05-27 18:55:34.806514
f1e9a7f5-f09e-47a3-838c-0366897ccacd	3d00b60d-8da8-4831-a0a4-98eaae7aaa20	www.octavia-berge.biz	jpeg	2025-05-07 18:55:34.807253
bd9a9d91-6097-4572-bbf7-2cecebd22a92	3d00b60d-8da8-4831-a0a4-98eaae7aaa20	www.bruce-hilll.biz	jpg	2025-05-06 18:55:34.80776
b514c7f4-afe0-40dd-80a6-ed5907b1f0eb	3d00b60d-8da8-4831-a0a4-98eaae7aaa20	www.ozzie-runolfsdottir.info	ogg	2025-05-22 18:55:34.808044
ded97d5a-5c7a-4751-8571-af413133376a	3d00b60d-8da8-4831-a0a4-98eaae7aaa20	www.luigi-orn.net	png	2025-06-04 18:55:34.808277
7a9c42bb-4766-47d1-ac3e-6bb072143c3e	3e79a2d0-220d-41dc-8240-e5aba82e6bcc	www.irving-yost.name	wav	2025-05-22 18:55:34.809654
a1b95ace-c63f-4ce4-a718-dd667a4846c5	3e79a2d0-220d-41dc-8240-e5aba82e6bcc	www.benito-mosciski.co	jpeg	2025-05-18 18:55:34.809895
294ff6a6-3c73-4e4d-bb60-18637a829d58	9e638331-3e73-4fa0-9874-5cb990ba083d	www.alyssa-boyle.com	wav	2025-05-24 18:55:34.810391
5d8aab9f-d154-469d-870c-d866072645d4	2b490eef-285e-4040-bf3d-947341733fdb	www.nicolette-nienow.biz	ogg	2025-06-04 18:55:34.811408
1f893027-5c38-4e1e-b828-80d27d80da35	2b490eef-285e-4040-bf3d-947341733fdb	www.leland-walker.biz	jpg	2025-05-27 18:55:34.811639
cf382f62-ec3a-467b-a2fe-14fa4bdb6391	2b490eef-285e-4040-bf3d-947341733fdb	www.luis-senger.net	jpeg	2025-05-26 18:55:34.811816
ae63967a-7f42-4cae-98f0-ea4721e7629f	2b490eef-285e-4040-bf3d-947341733fdb	www.wayne-fahey.biz	wav	2025-05-17 18:55:34.811996
a044eee9-e76a-41ed-9a02-5b4ca315b684	2b490eef-285e-4040-bf3d-947341733fdb	www.milton-dibbert.net	ogg	2025-05-27 18:55:34.812207
60f6e42e-fd69-47ab-ad64-a127121be5b9	67d7a03e-e366-4468-b507-d08fa20f8fba	www.kristopher-sawayn.biz	png	2025-06-02 18:55:34.812786
8f71532d-37a1-4b26-9529-e76267b9f2b0	3cf10342-6164-494a-a84b-cf10d4dd9f38	www.rosario-grimes.com	mp3	2025-05-25 18:55:34.813601
ae277a21-521f-4050-acf4-eedffd4bfe8d	3cf10342-6164-494a-a84b-cf10d4dd9f38	www.carolina-klocko.org	mp3	2025-05-22 18:55:34.813846
5718cd64-a7f9-422e-ae68-28a70a2e9831	6b221061-af8d-4786-9a6f-1423826e3e1b	www.aliza-pacocha.net	jpg	2025-05-10 18:55:34.814784
6341fbd6-98b7-4ed4-b233-d767853b8464	6b221061-af8d-4786-9a6f-1423826e3e1b	www.shawn-rath.org	jpg	2025-06-04 18:55:34.814991
48fa8faa-fc7e-4909-a6d7-1be28c237d2d	6b221061-af8d-4786-9a6f-1423826e3e1b	www.alfonso-boyle.biz	jpeg	2025-05-26 18:55:34.81525
\.


--
-- Data for Name: publication_regions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.publication_regions (publication_id, region_code) FROM stdin;
95e9c3a2-ff0b-437c-90e6-6a58e874ca6c	38
95e9c3a2-ff0b-437c-90e6-6a58e874ca6c	23
95e9c3a2-ff0b-437c-90e6-6a58e874ca6c	66
25283b85-148d-4c24-a6c8-2b2b8a11a514	54
25283b85-148d-4c24-a6c8-2b2b8a11a514	16
25283b85-148d-4c24-a6c8-2b2b8a11a514	23
25283b85-148d-4c24-a6c8-2b2b8a11a514	78
f24f53ff-2176-44b7-a901-076b121a8c53	77
f24f53ff-2176-44b7-a901-076b121a8c53	54
f24f53ff-2176-44b7-a901-076b121a8c53	38
a934ec89-1b2d-4f26-827f-bb077c9878db	24
bc24dba2-d4bd-4b6c-95c9-50ebdf2abb9c	38
bc24dba2-d4bd-4b6c-95c9-50ebdf2abb9c	24
bc24dba2-d4bd-4b6c-95c9-50ebdf2abb9c	23
906f6597-d02f-41fa-a382-f21a423c8edf	54
906f6597-d02f-41fa-a382-f21a423c8edf	77
906f6597-d02f-41fa-a382-f21a423c8edf	38
38035b3f-8980-4e63-bab4-3f4fc1741ed1	38
38035b3f-8980-4e63-bab4-3f4fc1741ed1	78
38035b3f-8980-4e63-bab4-3f4fc1741ed1	66
38035b3f-8980-4e63-bab4-3f4fc1741ed1	77
93aa563e-dfd6-4cf0-87e2-72b7fe7fd088	54
93aa563e-dfd6-4cf0-87e2-72b7fe7fd088	16
93aa563e-dfd6-4cf0-87e2-72b7fe7fd088	50
ca03a72f-b0f3-4b9a-a157-7b5c2d785be3	24
ca03a72f-b0f3-4b9a-a157-7b5c2d785be3	78
ca03a72f-b0f3-4b9a-a157-7b5c2d785be3	66
6f7190c4-9de6-4a67-a119-033ce47b7427	55
6f7190c4-9de6-4a67-a119-033ce47b7427	24
ed2681f3-f659-48e4-a1e9-5f50a68e6a40	16
ed2681f3-f659-48e4-a1e9-5f50a68e6a40	38
ed2681f3-f659-48e4-a1e9-5f50a68e6a40	78
943509ed-5b40-422f-bfab-913001b18de8	16
943509ed-5b40-422f-bfab-913001b18de8	50
943509ed-5b40-422f-bfab-913001b18de8	78
61063498-d770-432d-bfc0-99e6aa91ff9f	50
79b825c4-6c7d-4eda-b8c5-d19b8ae9a4c2	54
79b825c4-6c7d-4eda-b8c5-d19b8ae9a4c2	23
7d230267-35dc-4560-b05b-165ac4ffd03e	55
7d230267-35dc-4560-b05b-165ac4ffd03e	78
7d230267-35dc-4560-b05b-165ac4ffd03e	23
7d230267-35dc-4560-b05b-165ac4ffd03e	66
2cfd914b-bbdc-475b-974c-f483329089be	55
2cfd914b-bbdc-475b-974c-f483329089be	16
2cfd914b-bbdc-475b-974c-f483329089be	38
2cfd914b-bbdc-475b-974c-f483329089be	78
2cfd914b-bbdc-475b-974c-f483329089be	66
344a6cf9-2798-4b9d-b1a5-4461c116e2b0	78
344a6cf9-2798-4b9d-b1a5-4461c116e2b0	77
344a6cf9-2798-4b9d-b1a5-4461c116e2b0	55
3d00b60d-8da8-4831-a0a4-98eaae7aaa20	55
3d00b60d-8da8-4831-a0a4-98eaae7aaa20	78
3e79a2d0-220d-41dc-8240-e5aba82e6bcc	23
3e79a2d0-220d-41dc-8240-e5aba82e6bcc	78
3e79a2d0-220d-41dc-8240-e5aba82e6bcc	55
3e79a2d0-220d-41dc-8240-e5aba82e6bcc	38
9e638331-3e73-4fa0-9874-5cb990ba083d	38
9e638331-3e73-4fa0-9874-5cb990ba083d	66
2b490eef-285e-4040-bf3d-947341733fdb	38
2b490eef-285e-4040-bf3d-947341733fdb	55
2b490eef-285e-4040-bf3d-947341733fdb	54
2b490eef-285e-4040-bf3d-947341733fdb	24
67d7a03e-e366-4468-b507-d08fa20f8fba	54
67d7a03e-e366-4468-b507-d08fa20f8fba	16
3cf10342-6164-494a-a84b-cf10d4dd9f38	66
6b221061-af8d-4786-9a6f-1423826e3e1b	38
6b221061-af8d-4786-9a6f-1423826e3e1b	50
6b221061-af8d-4786-9a6f-1423826e3e1b	24
6b221061-af8d-4786-9a6f-1423826e3e1b	78
\.


--
-- Data for Name: publication_specializations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.publication_specializations (publication_id, spec_code) FROM stdin;
95e9c3a2-ff0b-437c-90e6-6a58e874ca6c	spec05
25283b85-148d-4c24-a6c8-2b2b8a11a514	spec03
25283b85-148d-4c24-a6c8-2b2b8a11a514	spec02
f24f53ff-2176-44b7-a901-076b121a8c53	spec06
f24f53ff-2176-44b7-a901-076b121a8c53	spec05
a934ec89-1b2d-4f26-827f-bb077c9878db	spec03
a934ec89-1b2d-4f26-827f-bb077c9878db	spec06
bc24dba2-d4bd-4b6c-95c9-50ebdf2abb9c	spec02
bc24dba2-d4bd-4b6c-95c9-50ebdf2abb9c	spec01
906f6597-d02f-41fa-a382-f21a423c8edf	spec02
906f6597-d02f-41fa-a382-f21a423c8edf	spec06
906f6597-d02f-41fa-a382-f21a423c8edf	spec04
38035b3f-8980-4e63-bab4-3f4fc1741ed1	spec06
38035b3f-8980-4e63-bab4-3f4fc1741ed1	spec01
38035b3f-8980-4e63-bab4-3f4fc1741ed1	spec05
93aa563e-dfd6-4cf0-87e2-72b7fe7fd088	spec02
93aa563e-dfd6-4cf0-87e2-72b7fe7fd088	spec05
ca03a72f-b0f3-4b9a-a157-7b5c2d785be3	spec03
ca03a72f-b0f3-4b9a-a157-7b5c2d785be3	spec01
6f7190c4-9de6-4a67-a119-033ce47b7427	spec01
6f7190c4-9de6-4a67-a119-033ce47b7427	spec06
6f7190c4-9de6-4a67-a119-033ce47b7427	spec04
ed2681f3-f659-48e4-a1e9-5f50a68e6a40	spec03
ed2681f3-f659-48e4-a1e9-5f50a68e6a40	spec06
ed2681f3-f659-48e4-a1e9-5f50a68e6a40	spec05
943509ed-5b40-422f-bfab-913001b18de8	spec04
943509ed-5b40-422f-bfab-913001b18de8	spec05
943509ed-5b40-422f-bfab-913001b18de8	spec03
61063498-d770-432d-bfc0-99e6aa91ff9f	spec05
61063498-d770-432d-bfc0-99e6aa91ff9f	spec02
61063498-d770-432d-bfc0-99e6aa91ff9f	spec06
79b825c4-6c7d-4eda-b8c5-d19b8ae9a4c2	spec03
79b825c4-6c7d-4eda-b8c5-d19b8ae9a4c2	spec02
7d230267-35dc-4560-b05b-165ac4ffd03e	spec01
7d230267-35dc-4560-b05b-165ac4ffd03e	spec05
2cfd914b-bbdc-475b-974c-f483329089be	spec03
2cfd914b-bbdc-475b-974c-f483329089be	spec02
2cfd914b-bbdc-475b-974c-f483329089be	spec04
344a6cf9-2798-4b9d-b1a5-4461c116e2b0	spec04
344a6cf9-2798-4b9d-b1a5-4461c116e2b0	spec02
3d00b60d-8da8-4831-a0a4-98eaae7aaa20	spec05
3d00b60d-8da8-4831-a0a4-98eaae7aaa20	spec06
3e79a2d0-220d-41dc-8240-e5aba82e6bcc	spec02
3e79a2d0-220d-41dc-8240-e5aba82e6bcc	spec01
3e79a2d0-220d-41dc-8240-e5aba82e6bcc	spec05
9e638331-3e73-4fa0-9874-5cb990ba083d	spec06
9e638331-3e73-4fa0-9874-5cb990ba083d	spec01
9e638331-3e73-4fa0-9874-5cb990ba083d	spec04
2b490eef-285e-4040-bf3d-947341733fdb	spec03
2b490eef-285e-4040-bf3d-947341733fdb	spec05
67d7a03e-e366-4468-b507-d08fa20f8fba	spec04
67d7a03e-e366-4468-b507-d08fa20f8fba	spec03
3cf10342-6164-494a-a84b-cf10d4dd9f38	spec02
3cf10342-6164-494a-a84b-cf10d4dd9f38	spec05
6b221061-af8d-4786-9a6f-1423826e3e1b	spec04
\.


--
-- Data for Name: publication_status_codes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.publication_status_codes (code, description) FROM stdin;
draft	Черновик
published	Опубликовано
archived	В архиве
\.


--
-- Data for Name: publications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.publications (id, creator_id, publication_status_code, title, description, deadline, created_at, publication_type) FROM stdin;
95e9c3a2-ff0b-437c-90e6-6a58e874ca6c	5c33412a-38f7-4856-85c8-b9322c62fb4a	published	5zm57nz8d22expaa2lbw9da7tinjxa93jakrx3dp4crf8nlhih66bcweagi6y2l8ixtc4u94ln0ducc8dc118jkakhucbyoyicsqpjpq4vpkf17v88dmtb5r6sc98rwygemc76w6avt8vwjlq9u6n6arknvw7qjfvgy2gjh925095766rpfvfelxj	07a2jtj29ryq6y4a4mbpdz7a1iou92m7n5j32l5f69u7e10dm13uwr3ojzca2kppjtwdjib4iy0vhj7kx42un6e5mpoio3sy8515xxfxd3zdrjsnid36y58zx24mmmgy3nopet19uws1vtvw8a0syfmy958je98gocbf1m3tme4bjqlp00net9nzp1kvvh	2025-07-14 18:55:34.737008	2025-05-31 18:55:34.737885	tender
25283b85-148d-4c24-a6c8-2b2b8a11a514	5e846192-3f8c-49f7-9906-4e4a0f3ef781	published	9y144vj1gkzcx7p7srenj4258tpevtu2xjbzf4s2108fwchyrnltt2t6k6mz52k94vjhdla4hi2fjizpe6ztke3f1fg2ieropvwjt1ytkrb31542mpgn75697xpkv97l01a1k	s8q3rojgkfp7cmys0ua7blfmwu90eb96rp4l0eptnut8gvuqioqq60fvdlod30xrw1sx4oaywxc5jxny82ot4raqo5dbtljvsm372nfg	2025-07-05 18:55:34.78677	2025-05-29 18:55:34.786859	order
f24f53ff-2176-44b7-a901-076b121a8c53	f3fa4ae9-2fec-439b-a043-ecdac59fbd09	published	yl5x2ynhqvuxaad54f9oqdrji2pdxplt0a7n9z34d3eq0xbjnu71yayb1998krhbw3ieqmxb7ao0ui768q0v2zod6qa3do53drqq2mktjurtq9hdiecvq	ipetqeizaz72ivnnhz1tdz931pn42ia7uqw29iph3wcbguiy216pwoovo63en15qmdi1lpckwxl06p425iao57h2p4b2vat8l28hkxhgigcnp2rk2b4rcsa3wyq2i3dqo4fcnce7syd9w	2025-07-14 18:55:34.787861	2025-05-28 18:55:34.787909	order
a934ec89-1b2d-4f26-827f-bb077c9878db	43556e5a-c501-446c-b81d-59bf84dfe7ea	published	y8k9ytrdyhcjkg2j52j19vajnl9k5t28cf8rvep1qxmcufby75qd7bn46lltrib1viy4wsotlysatta2hikk8jt4ygtgda4d4duexqsxrck9t5d3zhahn6q6333jlu4wf20afm8ik400f6ato7wzzkyywphsp2nbc3rfg34vzu2c52l91kurbpk1in453zilyotg2th8513xpkd22n0hsx0m540	53kmuu4g7gemteb7u4mka96lzw7p8p5l2rdmws1kh8jgcgui0u1kaxcydecqs23ea8u6zntwb1pu6bo57ulgyvm5wjc2xqex2w358yizyj7si99qs0uixp3eaje0y1qjo8enqqljceqv1f4mdrpigw59iaao4gegup2o3nae7upqjg7809uiy36a0s9z6rson1gtlch95flxw5sf0lbk	2025-07-30 18:55:34.788717	2025-05-11 18:55:34.788783	tender
bc24dba2-d4bd-4b6c-95c9-50ebdf2abb9c	4bf92c1a-44eb-4161-bd36-dd3a2845a695	published	lo8a8erojsc9iughswmn6r8rgzgixt2tikxgmvfyxuhdb6i34knsvepgw9817beevo00bpbao9i80z7crahcdoe4wuvhgohp4lhhn71ox5ippnm89mf040q17ym9yy9cim2wm6g8nbmlugk4c9nrg	lqhesqy05c9vd5c2c7n2yo6ubm6ei295bzrdvnwdx2f5y3h7droypdrv5gvhbgqi0r48wl4md03yzmslz5az49r5ws6eg29x8clp2gmaho2	2025-07-04 18:55:34.790169	2025-05-11 18:55:34.790234	order
906f6597-d02f-41fa-a382-f21a423c8edf	f16b102a-2bdc-4e39-8ccb-6544be128b7a	published	oj821zq7rdjlwq7cc3mliuvsz0lkydypzng1ekbnxuzyeoij679327p8984vo5wyag3j3001bd6zlb69u6h7lsdts8dfpjv946hpw0kp6udh4tv9406sd3i1j77b885kyx5ytkbuxmc3hhncz831s4kcgvrgbj1vvp8iiuxdkzahf809fs5ccqs0f25nh48cjxadbw	2hhdjecp1lz0dr9cbpmh5isdlwnbbd28odqv1997w088y4lahyluldeg6ztv8answvd576mo2dwl47siwl4megrlhv4l57rgiwym9sji24regfz	2025-07-10 18:55:34.791761	2025-05-16 18:55:34.791831	tender
38035b3f-8980-4e63-bab4-3f4fc1741ed1	c21491b1-1794-487b-932e-9b4827ff8365	draft	8s9tqdzn34a4lhfsq9xvam8li2dvaim2c1ukt025plbenjgeb91j3lis1pp9va3raya7tww1q60qrfmrbn9lk8dbki8rksui1ywxrfp0t0dbaqns2malg0d7g338ia3q1elk7wtiyj5ds5xgkzor0bm7o5h3hqe7jtomgrkqiz8753yo2m6v4380wffmgnv62ped8pvg	nzi0cofzv85sbktlb4bc56een231ow1gwary0x9f9jdj3weh1mkqgj7721lkm08e2wgnfzbfdbmrzhcqbhf7c2au4arkdv1z4yen2ckaevi237uwfydyqf7uiqpj329u37llbudchczh070hxwe9lqs07xvfvnn7yvlr8gph25yf4nvrngyywb0q5ipdincz282ro6kqdrgit	2025-07-20 18:55:34.794013	2025-05-29 18:55:34.794135	tender
93aa563e-dfd6-4cf0-87e2-72b7fe7fd088	e831937b-abf5-4d9d-aacd-14d729a07054	published	ygbou3qngv550cpzbnxh12jogqfmnbjmjzn3qqysl29mc3je647br4mvf81ujargmqv1mxafrn4zyjts7nvh8ej3k128455blexgd25hs2t2fq960trvo3mgingeawn86n45c1oxxf4t6c5ry26dgceljglmrov37d35tkvwqhiywzekqhgbn3w2q5j7itpvi4dmctdtful7wdn1ughpy6cgy1t48	qtk3bqgrbd4snjupl9blhfk4538eszfya15rmzpvtjdoax73gshp89lmguxa6zvzhppcfrrj6kux07m0r4z8brij1priszbsa0r5cksljbe1xw3nzuf1lh6f3en6j5vp2khk3cdh85ryzvvg4sot63m6bq1hu8zb8hinzi8pshvxfqe41qtsehlht39x5gw9y41zg5ob0s8im861j7catv8vw1fgkcy4xo0z7vuuo2c47titawfncd5	2025-07-12 18:55:34.79534	2025-05-22 18:55:34.795388	order
ca03a72f-b0f3-4b9a-a157-7b5c2d785be3	46d8b973-2d30-4392-a8f8-03e6fa1358b4	draft	zc01lmet22m1jgkxsf897m25s1ncy5hcb1jk807s851akmlqfy8l0qknppu3mdmk3y6hzrwfggybk1vzumgq9k8vlo1zosx7d6zm5p4dm700	q5h3babp4hp5ldxpi7crlsl6szq1jloqzbrnyz91e4bctshcfz4d4ibnve36o0d3pixpa7o2qobn4fbw0ep8n58mhsrgdkdh0tbqgzvtopc6d6b37atk9d7h8lm0b31ecs6uw	2025-07-27 18:55:34.796067	2025-05-26 18:55:34.796124	order
6f7190c4-9de6-4a67-a119-033ce47b7427	4ee49614-d5ac-4747-ad7b-53e8d011c033	published	br1ysrar3pwl8ro8iaoorlgfyxyemllp53acauwolf3cybj4abz02vwyclkj0dl8b2fzssci1uxn1ke3klaz7ekraewicvb6mozuhaxj2co8nhny5zb7pbsrsyzhu48wn8q91e02i23yrmecx7l1wp392nbe3zjhgsw4waltr3ao2v4isvgmt4a2su2vukia2q1fk9btjxhcmltvi4dkfgllunm	on6ntbu6yozp4qoov7loriehbmcn46p1s52rxuxx0it1nb8yopb4zh1ws9671e7jz5n7t5skhb8uc0k950g9qctk6tbyjg24w3tuz260a7xk7gvh6vnvjsivyrgs0grcb3jhlif	2025-07-14 18:55:34.796817	2025-05-17 18:55:34.796859	order
ed2681f3-f659-48e4-a1e9-5f50a68e6a40	9cf2fbbe-7853-47d1-b8fd-b263f8da2dd1	draft	u5ko71591nrd557snw0x5fpni9l7a0m9nxw1iymushsb5co66ue7blq5k7l856cf9uio8lavah4kkikhl60cej01nx1p2t087uipdzr07pebwfsylsqi6ubl4x3gdaptqe70h7bqozkyv0jd2gcwndlb6ltgycj61fmm9yxpplwwjht17xa6ao0ku34l98vz237ennqxlw3q6gz35lv8dwf378ks6xnbdzq	we0p9pde6kwy3vkq142hq01zxnl3zje7swdekm1226o3qm19qwqqbva43zlm7n4t4osjnkpc1gv2dndnpd6ttx8my8txuekymry99qb6tau2te26czyzoiv5bfnogya0rwucv2g7xaw5tcah1tyghmbx67ay0iewcbccwb3c1je8qbi4inj	2025-07-26 18:55:34.797941	2025-05-15 18:55:34.797983	order
943509ed-5b40-422f-bfab-913001b18de8	99026b27-e389-49de-a555-868e3529fdc5	draft	jkqa243crqeq1dakklnn9wm2i063gxl03v6spzxg32pe9wr9lkc5ke4u96a037ucqfjilxjsvqurj6fa7vp3ug2jqwdumq2ov2gfmdssexd9k83xxmkgf8i7	8goowljeunb79b04rtbm281f6uueozg8yzwzv9kwi9ca7q028ry2k5e12n5lmh8489yxwbtl3hnqg00nxb9oluv92umrvgivcvnkfs1nv1e6kqlvpgxbuzysq0xzawhap032bzktxtlbz6xjwntxj82ov4d66mvz7axs6jak9zfeseluv32hg2bokvygywny3vtq26nqkt5xggx9di	2025-07-31 18:55:34.799581	2025-05-09 18:55:34.799631	order
61063498-d770-432d-bfc0-99e6aa91ff9f	7448bdbd-8eaa-48e7-b00f-9d64c330571b	draft	m874wke49eloiognayj8rgxgee8b9q5fssxinmn4wkq4c2baplp30cj1wb6d3b5mkef076l26hf38jln0nrq411lvl30et9pbxfwk8om0kxnfzsacp2r3hf4d7ynp5tppurkyw4216axfiyvw2v7hufvbqad45exh0p9m3m026b8a5nvy28m2bv9oh5nga3d4siq2zaj35synyhh762nb37emgl5f89a2iidolu73359	2bpaq5nz8eritgrvguf2htkb11x8fx2jmq491xbedw6r9s038h4ddzgi3gozlatj4gtpw1ggdipqn29790ejzvpc8hkravm0594dnrhd6roj5iivwr3vbbaqyz1q6vsca4de42hdboxizkj3zetiwl5p	2025-07-17 18:55:34.800672	2025-05-17 18:55:34.80072	tender
79b825c4-6c7d-4eda-b8c5-d19b8ae9a4c2	600fd83f-8f30-487f-97fc-b874c9c5039c	draft	sdnnq7r0xyyenpxoxowtbgn07rf47a8vpunx2rdyy34kgmrkizhokk9qb490gqsn7xi22fsjqsui23ykjk24dcysc6vdltokckcxra8ke93gb4k70eszkbebi7ofiqcuian3lghzgew05mjmpsr31ntr	x9bqu877mlanmnkunzsddolf8i0pgmjfy4omgflyqeguw6ljwf36sjwh5lcsjrxw51eyxn605ts6xh8mt1ptsknqvh9yvrvbd7yt4q8jran6yamiyn3xwnh4x9uqt1asg2682xztb2c3avjwndswlkfb15w1pb2p9vwnz1x07wbtymy59q08an112etuivyzb1c9ykw2m9w3pdd26ig1g3vfkvzm0qrzw08r	2025-07-29 18:55:34.802249	2025-05-13 18:55:34.802297	tender
7d230267-35dc-4560-b05b-165ac4ffd03e	c578a4b3-d17f-4201-8469-310a5efc1126	published	xi6pn7gb2p4esju6ap5l5xuy00xe27qk0p7ss5vz1l8dfjq3nkvngr0rpbuonl3k4tbjugu564chcksn7ac8ywxl2bms1n3yl78m9wpf4ahuevvvdxmvnbgzz0qjan66qn8d1z1bczftrvbf6ndkb09qn1z2jvsjvlpluf9e9u6h24djlujfiwxhmwgwtveexxhlkc9nwtquvzkyf8i40iz	l7zdu2j2s3g9ndyfoeykj7c97iz4qn3y4fudw4zwf2k9s6qya6zv85ina1y1aml02lb4eavcu0f1p0fnd1pzbv4ugrv1xnaekfy7vfeqb3a57y1jmk85kwojgttrjb1txe9sx4kdn5dq21mqpt3b	2025-07-15 18:55:34.803539	2025-05-23 18:55:34.803597	tender
2cfd914b-bbdc-475b-974c-f483329089be	77702d6b-f044-47f2-bf61-1eeabf8aaa9b	published	f290ruoqhu70vurqb0kfxszb6oiotjhq5tsuumgts8wuztqltiidjhbdj5gvqvv5jfeksyef9e9mn4nyqp6s7cbp1tt8mmtsb3n268lbkgfmvrv45galgjbweuodpfkijrocn2m7puokceywwck5ycmmc9dgppzw9xsh7313cf6myevd1dm6lzdud5kv4n3qbxfbn4as58z2wpnnhnemeawtyc9oyqo76holy30xn5d2q61c85nz	j32v8dhakurm7u3perzoij8o6b1iky3phlu42rcww8rn8a1vhxma257rrr5zk5c65m8tiqr9m2ftshn0ycty68yv0hafly85xc15ww10f6ewn05xvwt42aj716giv3p9j1smb0ptqmc0lafpr311i5l3jugkxah6v9e383h5r2n0lr2pmj93egsw4hdcoey1jmb3bbcgj4g283kklwz	2025-07-15 18:55:34.804573	2025-05-19 18:55:34.804619	order
344a6cf9-2798-4b9d-b1a5-4461c116e2b0	07978f14-8190-42e3-9999-b51480731a6d	draft	0kfkfq3gox4663r4vn5dwy2o1vlkh3vovtpaxzo9qrddb20h34yn3pwityyd57m8l9p9ylsqxdd69jmtk460wavqn3nqi6fif87ljnztjqgooi32ep74mjj7vp1ezyimzc7m4fhoyvzgv34i97oe66vklxdad1aku4qzwbpeknxxmukbx5ebftob9anijkg1k9n9	ptvbim0b35wuvcvimagrx1q7go31p7837v3hlzpr9ttxuu9uq1p7dxhtvy4hs1rtyvvgfj88qp3kp0ug91r5eqouidfdl83o6rhztu4ek5cwt3u079vhpsmlcukrobb5btndy9a0txem954lcz4bhc0jrdjglvw35qko2i9zrkwk99hfwxek3teka6tx	2025-07-30 18:55:34.805993	2025-05-07 18:55:34.806068	order
3d00b60d-8da8-4831-a0a4-98eaae7aaa20	25eb8322-21e4-4a89-a485-5e267d2bfef6	draft	nu70fgo2jdou1hrrf0gcketbxi6a34da5oszdzcq4k1k48iw9n79jn6mkv49up9r01qh2e3ars81bkqme7pughgm372ei5q6kdxmj5lw7oyjy034xxqsx6809034lf2cclp2is7a0wxs2u8ev4ieg41r7p1de1h41lysd3ovkai4e9hhc1cq09br103b6u26zwk2rmxrlztxpwjkovaqxgvx2dgzvx9udjay0	xfjxyhldhbebv3bo9v3hphrk3h09e5494uvgt5ar7y7dycuf7vj0rgkq7a0veyw8zwhn5p6eqeqksvbcbh4lsqgf69g8vn6b6el3ohuy5yx4pikntsowpd2bvnlxtugivzas59rzhqdueyv3gffamhnea3fd1	2025-07-14 18:55:34.806935	2025-05-09 18:55:34.806982	tender
3e79a2d0-220d-41dc-8240-e5aba82e6bcc	8a50a51b-f6d3-4870-8a1a-ba5eb4d10b6f	published	1806uegeskyzvjixfsg4v85jc0sreys4b0mug7xs2rmbaen1g20ln9wwx0eansbbgxdkno3trlka6v636wv51c2blpgu34z5419kpqu79unvv8vbuqom8h7tm7euuwafsx5qvsu24tw8wjenrrkm64blahv3v72cv4h9partyjyzrbnq9oa2teu8wgvu7h98p8iresto1k22qoil10ryux9l1vvlaf1o72krfi5swfr	2zj6to2a4fyor7nlgbhv0lqgt0lwf52raa6c3gku97268gaq5noxsv5olra5vmvu0zvgf8dqrtq6six84x0fop89uxtav5p0mxbtvvge79ot5gvzi34teec0as0bvj0x5kk4dlh2h09ulbdnrgwug4o5ffclz0pct83408xl4keu7qq	2025-07-09 18:55:34.809155	2025-05-25 18:55:34.809251	order
9e638331-3e73-4fa0-9874-5cb990ba083d	7b9edadc-37ca-464d-9b06-51931dd2fc24	published	wk40xh9qvj1z509z1o7r4f6mhdyi4wwqfcg5t3ruvdkb9p5ex66eivq7c27ko91t51vfm2zgz9f5mm4eqc2g8ba2hjhfx2f85w9qd4fq6wlxqilpnxmt4f5l0sxlxph7h09el4pill8u0ox9tysgwnfn4i7zahzzi6lmm5tc0du29mf54ibbnvdo2xv4zti3b14rgpeiuz5rvjja3l2c5rml2ot5s7	byit57rc60cndsfaunljnrfm1rs1bl6w3k56wv2gv2c5qqanckro2j020u0fgeq0k41hb9kd5fqokjb6s1im7ew53r5u4gngd8qbbzor1cyuoqc07bwmo5os5lms19h5uha4pzujadio6wo1oelmbfk22l4f1n0qs6isawh04pjue7rnnd2noclkqr39198	2025-07-13 18:55:34.810143	2025-05-14 18:55:34.810184	tender
2b490eef-285e-4040-bf3d-947341733fdb	2b748d02-13e3-4c56-a774-fc1841027cfd	published	hx71t81fgqndi9etl74jfb2uiqjaj66ytjl1ck4mm5ikyirh4e2f0ay9zqtx0zgr8sdht72yxgkg43urkmdluvgslh3zh7lbq53z4mlf13wyaaqrusnenpclbiy10l8skpf01xs9lyf1mljxdwxpkh7xmhyrbaoge4o64rbkte1e	xhd586btf38km7snqu9qb7tcua1iu117ycb32w4ef66128tsxvl7tncj0ia7yxg9sljzhwvjkbo4ka5yfwq26183ed0tvemdazyr198gou0h88shzo7dz5kd793rsztjx9ai79wxhfv1bf89mvfgirxm9h0dlytt9tc5ylva372nkzzq8hs9le2si1pwnrn6izkauk4i84j3fwp4tqpf0bw03lob4nf	2025-07-17 18:55:34.81105	2025-05-30 18:55:34.811143	order
67d7a03e-e366-4468-b507-d08fa20f8fba	f97b4a83-f14f-4eb8-bfe9-232f3fef80f6	published	fdpi6gcaoncic4iog1qyflccntg8cf5phsv7y5maa7gtzf8pch97bqxyqmkwpk71dtox77xnrmkq4em41cl377uk63lg6tlc4z0p	kx5ffrtqb92v2mapcr4sy1zvk7k5bbgliyp0fzej0c92188bdn840iy1cid64ddlfmi4t7cawo79yus7zaflbt5btxl1jiq75mczu2gcrzn836gfg4hkz6rgyteiwxoyegknue6b4s6psuuitvzpfx6qhlvm1ofelvw	2025-07-28 18:55:34.812458	2025-05-19 18:55:34.812525	tender
3cf10342-6164-494a-a84b-cf10d4dd9f38	55702c54-5b25-4f00-aea3-d61a0f43cc60	draft	j1kzh0u3miibqms64yiavgrqs3r2n24fdlwhvp3x03sj9lx2d1z8lj0m26f922uyulvo13d871r2h7zzcy429endrfsskbhtfsll8c2jbflvqsyxtxcb7l3tvrlk6dgr9rebna724msj9oh43w4whj27uhnd40646g3knesxi4viubuo8lu9omyw8a4vh0a1zyz6kpdslkqjsdnpf815qt4zddb91opcl2	xlx97ljujchtwws1tvzo0dmwwxyv36vg2anpz20iy5t88n1fcn29v46g8x4kxoyu50il7komvonnh0wyrg0dk6sek447mdlbqrs9vblzw8tonn	2025-07-07 18:55:34.813289	2025-05-11 18:55:34.813333	tender
6b221061-af8d-4786-9a6f-1423826e3e1b	88f7f35c-f5ad-4a41-b61d-e1cb92bbe610	draft	e0rtso0moeu3xqnxyehj9xpu46oi6y1qpjjjuigjip8dh6t9cozll0jrzgx87wg7u2gul32x7xa4rgivmkz631vgrqyxzulo28w20hcx7x6t	mrsgidn453wzaurq6gmrbxgrn4nm2z8juwkq2qy3q4g1lhxdy0oityq3qa20wlmt7hybkoh1qhjwijj3upj3zjyfh8ewq1loyx61n5uwd3mvzoptopuudca0ks0sd1ixlwqmk02fqi9g2t6662yjayo5zyo2mnizmsfrn5uv06fp0hgq31	2025-07-21 18:55:34.814372	2025-05-18 18:55:34.814427	order
\.


--
-- Data for Name: regions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.regions (region_code, name) FROM stdin;
77	Москва
78	Санкт-Петербург
50	Московская область
66	Свердловская область
23	Краснодарский край
24	Красноярский край
16	Республика Татарстан
55	Омская область
54	Новосибирская область
38	Иркутская область
1	Республика Адыгея
2	Республика Башкортостан
3	Республика Бурятия
4	Республика Дагестан
5	Республика Ингушетия
6	Кабардино-Балкарская Республика
7	Республика Калмыкия
8	Республика Карачаево-Черкессия
9	Республика Коми
10	Республика Марий Эл
11	Республика Мордовия
12	Республика Саха (Якутия)
13	Республика Северная Осетия — Алания
14	Республика Татарстан
15	Республика Тыва
17	Удмуртская Республика
18	Республика Хакасия
19	Чувашская Республика
20	Алтайский край
21	Амурская область
22	Архангельская область
25	Астраханская область
26	Белгородская область
27	Брянская область
28	Владимирская область
29	Волгоградская область
30	Вологодская область
31	Воронежская область
32	Еврейская автономная область
33	Забайкальский край
34	Ивановская область
35	Иркутская область
36	Калининградская область
37	Калужская область
39	Кемеровская область
40	Кировская область
41	Костромская область
42	Курганская область
43	Курская область
44	Ленинградская область
45	Липецкая область
46	Магаданская область
47	Московская область
48	Мурманская область
49	Нижегородская область
51	Новгородская область
52	Новосибирская область
53	Омская область
56	Оренбургская область
57	Орловская область
58	Пензенская область
59	Пермский край
60	Псковская область
61	Ростовская область
62	Рязанская область
63	Самарская область
64	Саратовская область
65	Сахалинская область
67	Свердловская область
68	Смоленская область
69	Тамбовская область
70	Тверская область
71	Томская область
72	Тульская область
73	Тюменская область
74	Ульяновская область
75	Челябинская область
76	Ярославская область
79	Республика Крым
80	Севастополь
\.


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reviews (id, reviewer_id, user_id, rating, comment, created_at) FROM stdin;
ca0bf410-c4de-4151-a28f-4e349cdb78cd	5c33412a-38f7-4856-85c8-b9322c62fb4a	4ee49614-d5ac-4747-ad7b-53e8d011c033	3	Nemo qui aliquam.	2025-06-02 18:55:35.160343
49006d80-feb2-4401-95e2-678a060a9649	43556e5a-c501-446c-b81d-59bf84dfe7ea	99026b27-e389-49de-a555-868e3529fdc5	1	Quia dolor blanditiis sunt veritatis deleniti deleniti facere.	2025-05-30 18:55:35.169186
798298b8-8136-4694-8523-3a1e71ae1c4e	f16b102a-2bdc-4e39-8ccb-6544be128b7a	99026b27-e389-49de-a555-868e3529fdc5	1	Consectetur voluptate minus.	2025-05-27 18:55:35.175351
c09737bc-3d7a-4ab4-9a4e-2178aafa4acf	c21491b1-1794-487b-932e-9b4827ff8365	99026b27-e389-49de-a555-868e3529fdc5	3	Quae esse eius sapiente consequatur explicabo.	2025-06-02 18:55:35.180022
e768149f-59eb-4e49-857a-dbe47d3fd242	7448bdbd-8eaa-48e7-b00f-9d64c330571b	4ee49614-d5ac-4747-ad7b-53e8d011c033	2	Enim impedit eos voluptate hic.	2025-05-29 18:55:35.187255
90ec8ce4-8798-4d10-8c5a-640b8244ed75	600fd83f-8f30-487f-97fc-b874c9c5039c	f3fa4ae9-2fec-439b-a043-ecdac59fbd09	2	Modi qui praesentium alias perspiciatis quo.	2025-05-16 18:55:35.192108
6f6c71ec-5dc6-46ec-bdbc-31e3b63c41f3	c578a4b3-d17f-4201-8469-310a5efc1126	88f7f35c-f5ad-4a41-b61d-e1cb92bbe610	5	Est omnis sed sit nam velit.	2025-06-03 18:55:35.196724
1b5048a1-b70d-4383-8eb2-9b58a9b50044	25eb8322-21e4-4a89-a485-5e267d2bfef6	88f7f35c-f5ad-4a41-b61d-e1cb92bbe610	1	Voluptas voluptas est nulla in.	2025-05-07 18:55:35.202804
2e50073c-146d-439b-94bc-b98a3af5efdf	7b9edadc-37ca-464d-9b06-51931dd2fc24	77702d6b-f044-47f2-bf61-1eeabf8aaa9b	2	Ipsa et et exercitationem quis.	2025-05-15 18:55:35.207882
0a914155-89d5-41d4-9479-cfecc9ae93c7	f97b4a83-f14f-4eb8-bfe9-232f3fef80f6	88f7f35c-f5ad-4a41-b61d-e1cb92bbe610	2	Repellendus officia iusto quos quis assumenda est.	2025-05-27 18:55:35.21304
2509995e-6957-4c04-ae7b-c980c26cd097	55702c54-5b25-4f00-aea3-d61a0f43cc60	25eb8322-21e4-4a89-a485-5e267d2bfef6	3	Architecto totam distinctio et.	2025-05-12 18:55:35.217391
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (role_code, requires_legal_profiles) FROM stdin;
admin	f
customer	t
gencontractor	t
contractor	t
subcontractor	t
moderator	f
NikitaMatsnev	f
\.


--
-- Data for Name: specializations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.specializations (spec_code, name) FROM stdin;
spec01	Монтаж кровли
spec02	Электромонтажные работы
spec03	Бетонные работы
spec04	Фасадные работы
spec05	Внутренняя отделка
spec06	Дорожное строительство
spec07	Сварочные работы
spec08	Строительство мостов
spec09	Инженерные сети
spec10	Геодезические работы
spec11	Демонтажные работы
spec12	Проектирование зданий
spec13	Кровельные работы
spec14	Монтаж отопления
spec15	Теплоизоляция
spec16	Гидроизоляция
spec17	Механическая обработка металлов
spec18	Пожарная безопасность
spec19	Устройство полов
spec20	Ландшафтные работы
\.


--
-- Data for Name: tender_bid_documents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tender_bid_documents (id, tender_bid_id, file_url, file_type, description) FROM stdin;
783f1768-5373-4e75-8b37-1026b950603f	ee6e99cb-a40a-4fda-aaae-4c7cfaac8193	www.eladia-turcotte.net	docx	yacv2cx9fus0s3ea0j5pk7qmtl5bp5dbhf279qoyneet6ogh7soenfau5yj0cil7on9ultf28656qqfvswnuxi1rkc0vuich88naes2cek1dwhfmw357inag370r4l2w08tu4ce5i9qpkqh3av0aiaamhrzdjgkah1jarn6lg8fvec7tjjakt3w1jgka9j50j0tuvcj3rb
6e7d971a-5200-4c95-a6b4-ba0a1f672d16	ee6e99cb-a40a-4fda-aaae-4c7cfaac8193	www.alisa-douglas.biz	xlsx	mibxgzj0c1tsnzwx5dpu7o8vowt0l7oxb86i6k6a0uc7eidsjnsf366k82dst3bgscxcuk3momw85kifjel049b5fqlpz9uz8j1gk4i1auox3j291qg19l5n0jbmilrd0wgv52jani5482lu4646eafpjmpcncm7n0fmnfnmq9cawgczluzez8ibu7pfsoufmqqscna4dc7n4ryrbkf2x8xhf58666f8t3l0rnrwdabimlkmf9
d23e2dc7-7b31-46c6-9077-b172a06fb746	5489814f-807d-4020-bfea-8653a0fe7acc	www.ophelia-dickens.name	xls	we4xeopa6kjupg4bb1h5xzop0u0utaxzh6tcb325dg9dwjjl108fk6ua3iko80ccol3vacz1o1jcsf3ce2j8eszqui9mjf3rhayuc1thd0vdupxtvyhi6yqnqtuewaluvr8wif750tvqcm0bfdb606wfeog195u0uogbh7pe6ndws8d6b2hcs2ghfrwrp0bq8eip0gcvr3n79x
283c4692-2efb-49f0-b17f-eaaef6ac9560	81da2a0a-90eb-44d9-aaed-6f671ecdd60b	www.telma-marquardt.name	pptx	t3ia2svgp8jjlvvmzrvtntuqmzy6drfjebsf7elo4gtca61t68uekwk023jjs8jde5dt4rxiqajrp1hn3s22rnuecgj4gisz0wswztmhsalfuzzrc3fguy3jbhs1bc12x5rbjy1965m5evwthas90tgn8fz530vl08p788cvjuotrjj1c5bpxkwf3d4efxh4y858eput0ipvvqd
38f7d422-8b79-4e28-ae56-bd4fed7a0e6c	8ee6c63f-fc01-4ccc-98c2-2171e6684cf0	www.leilani-windler.co	pdf	57xp0cvz26xdwf29taw7yhlha3i7ehdnxbi3wwqophpr50ecw6p4dvi1kft4dcuwdg5yv963xbcw271iak8j5c2sk6p1p7fvy4bjx6zgj5nvvzx3i5rfyfdfc533ze03a1wi6h9bup9lo9w7lf2y4abnzz75n9t1g7r2u4xkbag1sdda28uwjfla6gxcdv
33cefe47-ccae-4df4-bc69-6f2d1d30b521	310c6daa-5767-41b2-89bf-eefede34ab4d	www.casey-harvey.co	xls	tb1ofopj7fpv5rv5bcb24y8zf5fmzu4ybq56z6w7h02tbqt8icasn3zub686sp67oemy6kc73l38occoh84hbasrvmoqbnoqaehe0knm0
878dcd43-79ee-4582-b7e8-33976a0f967c	5eb76409-7c6e-40b9-9477-32584d6690f4	www.lakeisha-runte.org	doc	jnihfgj8wd7j35y5ovbz75stk0if2n8xyd79f07ca5hcute1ar4iv0l3to0qb8xnvnxso77qyll6t9yo656vn382imwnk25xgxisscde9ta8uf6n240e7nr97iekqyq6fe6bwrz12fu02t26pke2iu009qlbpj5z0kkybc3yp9101eq4gbp1tulcn02d9x7udshpofj97wg5u2tlh38msqgk1ckqd8m7gd00yhh7bfvb351228o43aclo
ba2eaf1b-edc4-413a-962f-c34db8005a8c	5eb76409-7c6e-40b9-9477-32584d6690f4	www.hilario-kautzer.info	xlsx	gws1q7uwzndfhae3lizk5dhuoqm9thdxfsug6ikyga5kqigxd1y5e73767lq8vn418cwtdgirnot37g1e0pr4f1rl589w8zsci4zishsafs7ct0xyq70mtb48zwfq0zoqme9mic5kpseovyky40uw9xp5ysf6it6qzgsp1hnpl9lobb6y55xgvmqndobrofubx0y6n
39daa9e4-c14e-4678-97dc-6c364f7e4c5f	bcf9f72d-9e7d-4d5c-bc96-a75eed866d7c	www.justine-deckow.name	xlsx	sbg9lepumptwm2mool5ss2vdwvp4q86qbujw8nui90scwl2v11rjwnptrwl9zg8a2dssf5d895mu95sh4w6hq6x2ml76ezv71o16on58jy97nocadxlvc5pavxuvrl2lprsqpr62eqa7wk3n48954a8nt4j1ps5c
6a01a4a9-1dd1-4c4b-9a88-fbd4cf4db32f	37fb007a-b6c4-4768-a5cd-ea9190293e68	www.shad-nicolas.name	docx	y6nnfrq21iojpnfwn7jxvd6f8fjty1hjvtviaqm6bazuywj1y0duiq0b01ywu4lirz53q9bzh7kdx196a9c4cg98ttj029en4112evkgfoysi317j3b18rg1kvm1lsylshs3vtv0r9yxstf4jzb33wro70akff7xmdl39iumrti6kwr577vukfkbo6zsuznj6vpxbf
20e371ca-6058-4dc3-80c1-abaf1cc79012	37fb007a-b6c4-4768-a5cd-ea9190293e68	www.donnetta-boyle.io	xls	628px893o5vlbenhl02vzs9z1vcg7v39iy4dxdbo3kl83s59cig30kdknqkep0wr0fcqt2fp2pcmx9l3sjwzkjpvkbr53o9kax5ihj8ni5xvvu4a9w3zdvosfg65rkexk6b78o9dhg7zyo4i7d8j
7b9bc22d-f74e-4e9f-8d8d-5e4d6e26dd09	37fb007a-b6c4-4768-a5cd-ea9190293e68	www.selena-feil.io	xlsx	a1my6ruw8lqv183pin6akjkzlsz4bimk8vwz88yofj3yng6qq04igsv8xj2bymu6bkr80t1fdrud04xihnkwmy3e1gif8sl2bebzge81k2zou
25d99ed3-25b0-452c-864e-9e59afc9007f	6972fda3-98c2-485b-bc7a-bf3fd3f2e7c2	www.carlos-davis.name	ppt	thcniz9h9ci7x141n2ig7lqmxbcjrbk6tpq19c1nitpa98qgfgpimjijmckzoiuxq2vvawtx9n0w4jtu65ykuqwsr4kcmzc333pz97ylan9i6imq0smno2ln507301haqt0a9iwuprer6xlsl10v7r9a2fh0vyn9uviv233s5q
d98ba67d-637f-4cd2-838e-15d8af64a3b9	6972fda3-98c2-485b-bc7a-bf3fd3f2e7c2	www.dorsey-stracke.io	xlsx	pwdwz1xk0vearn480vix7mbjzwdimyv0zv3i8ykpx1ornr0h3x5cyq9bb9b826a10icz1j0miu17x3ida4crcxnck0tza4wzrfneoj9dtoamdkq69k43ck8mzddfa5jywrw3nfb6kl6kumwa1ewvqant7sq5echwzigzurxzqrhax0s6pscvssmp35hwde8b0su5iukzz0wv1uqh0rx8ox7p6o1soeykwtvlnxltnirn
6ae8d42d-8d4d-4a77-98ad-0c4dc3cf1853	835751ec-f70d-4610-9b25-63c03bd480b3	www.loyd-witting.name	ppt	4l8ivk9oqokeusptbcbwwdgdyu91zv1reno79zv9ik2icnjnnfuq3km3ugga0upq5gjpai5xw20pq3fwes9271foyug731qygmgdmmhqf8120p9pycxfk5r69ubp
83a0a282-bb4e-4e6a-8f86-27f5ccc040bd	835751ec-f70d-4610-9b25-63c03bd480b3	www.annalee-franecki.net	xls	k4n1vq58s2dhdu0hdyai0qg8uzrs10qjnnue1gaqlevzigafq4yoest6u9a1rddjuoinwfmdgu0ce5k3smdcax78sghghmqk14lajk7m7enuvsgxppb5umplqhl1r0z1kzs9fxm8wphbu1wa04ty8dbtf4qbop62wc1qw40s7od4qgmppkis4wlxkgjwxfxw3c43mcfpybn
e8d1cb27-27ae-4712-b8fa-e37e6b90eeb5	835751ec-f70d-4610-9b25-63c03bd480b3	www.raleigh-little.name	pdf	o13vo6ftf6sjypmmo24mgh1zrd521tsuyqkcendz2menf7olsc6k3vwvlv4ff28si0shs0flpfld7l2w1vt9zf60ltj4j675w7j373pzuv8e706veqyx075jt6sl5c8cxbilaqbsnfn8ky73nz5byxrrbbztokh6cvt9k058b1707x0bd301042gfkt29jda
c097eaab-63dd-4ab0-8351-d28f124d58a5	31d5c8e8-339d-4c77-8ea7-b6bdd6657bfe	www.dominic-yundt.io	pdf	1t2u3ovxnk5e0mdr5hrhgsnyzo12yll7p54c49iw135kalub5k8b1euk3e6pu5pnffd2pt2zsqwkxke44vlrfplt7mpjssxapo0ttkcneoc98f4fq78hi9b5z8r8tde9conj428gtagrgzav73ss7bln7fq44dg80eydv4xcj4g6wn14zlym92q878c7tnvecbf
b716cd48-fc0a-4c3b-9aab-798f9ffc2ab7	31d5c8e8-339d-4c77-8ea7-b6bdd6657bfe	www.wm-satterfield.info	ppt	id4iw0ks6b86kagj6zw51byjq4ruz9kcrvlbpwlcja8w57xhaw2y0p2sxy7phwjeyc56ytdzcqok4axxpvaq5t310gybxj6lz56xf2zak6imzt
bc70b382-29fb-4d00-bf22-aef87354821e	31d5c8e8-339d-4c77-8ea7-b6bdd6657bfe	www.ermelinda-moen.io	xls	h8sodxo4y9hklpq31po4civdi5z5do9loit2gaoxggq7pyakarqs7zapw75h9b931m10zoexzf7kq1ahk2ga3bkjcn58we3k1szw6v6hu1r6bdi6g92zd2c5n8izklqvslvfgzercnynl8
7dce4dc9-570a-4b71-a933-5883251bee11	cdb3ef4c-5734-49c9-bcc3-913b3059e40e	www.kirk-raynor.io	docx	dog1twqmz05ke6t1ihhu2dmivwj1sqg4uobjep18aqmmd0r36l9e7rn99hmf4cgyi52956spoa7uf7n9v7ncxb1esd3pa0820etciebyq79r9ufgw4v1gc10hcrryaudx4vxrp2y6ac3fo5r9vw1ceojnc1l73gaoqomuzhq6fjkl8oz2mnws9o
e8e2a9ec-70a4-4b86-a697-355bc9b0e748	cdb3ef4c-5734-49c9-bcc3-913b3059e40e	www.modesto-mayert.co	docx	etgh5ll0sw81yxe8ufvfkzrmxmrbulttf6g78xmrdobb4d6dkm8rialnf7r6ocnv91jvmxijxs61a77sh6y48chbl2ujruf8yal5miiz0jhjv6o15h8trlaitmbybvym8qxu0op
5bab0ab4-74f7-4bda-8fd2-292e17d342ea	cdb3ef4c-5734-49c9-bcc3-913b3059e40e	www.kim-ledner.com	ppt	vvqwadsjmpcndf9qtton0j5usynj9m33ju0xid5t5b0we1erf6sda38bjlmjcym3iersnhrbcshb38xu062uhsykohzjpht68ce9mqluwjs6mt965zjfnkf6gthtqwlky
ccb9af22-fb6e-4d0b-9959-f4386019c22a	0802e79d-a366-417c-a12f-e6c07a5e6fb2	www.octavio-jerde.info	xls	7yxgsk19jji6fdb6xri3fqk2lmownnfmc4gozyl0xts1i7jl9tr8gk4ndd4owo1ecsdvwf5zr6e1180o3s06ala8bxsb2qbxl2063budfuuov4znnaql0b34d66sl2cmh9pbpwbyjtmstc0b1scu26m8ljxrefqapbs7tgendelny33w5yhndkovhu5sw1qleeeikq84nu3j21vdafr9l7hznxe0ftvxqjhg5vg
4f695367-c8b1-4cc4-a983-196732d0eefb	5714b1c9-32fd-4610-9362-1df550ab03f4	www.natosha-stamm.biz	pptx	vz2awo7ovtsyhythprckb5mpgtnpvtc4d9xf25uzckzfds9ycxlelco1uopinbio2e9cgr7hojw5hleqo2liwb819c9m9zvl2610mmsokq9zyox84v64hdqk3b9glrku06x82otdb9ginud6y9heqqsjicz4c84d5gx36r7zr93t13e2wxnjpwbvnjd7llco1aklp8hw6040mu5mzyegul96uwx00vbhgrc70a
793f6f10-2011-4b6b-a1e9-76fd6088b050	c5d0e656-4b0d-450b-96c6-32907264c325	www.lianne-kautzer.io	pdf	8ya4ki7uhw60ctk2nyumqwgigbniwgiw540tyniucy5j2tq56t2ulxvg2wwmojl3b52hkpihhrljx4accj708x4yulbakhfr9rwaofhvre5fvvgvgavsinzwe0ultfkdsj53hm1kep69awexe4grafok6srvd451b5b8v1lrnewlwearrv2nee8otk3ot9p6rcwhisptdrfx0ezxy13ixvio4lx
d8e9a46d-3fca-45f3-846d-fbf7682e6ec2	c5d0e656-4b0d-450b-96c6-32907264c325	www.delmer-crist.io	pdf	vu9yhcq5dau6mj5q4zd73ja6mkbklw3q8edcatvw78nx1llr9pdyodl0ovfny6to1j61gtca66k9f5e7g7bzktqytb25ad6cjz6bn6izfilm7jcoylnvbwdq2ora626l1s2pbs0utd401tssif4o5x2ar2sazfm50jank2ycd2rb5h9ftc8
3705c291-5bfa-48ed-84e6-00810191452f	c5d0e656-4b0d-450b-96c6-32907264c325	www.earnest-cormier.org	xls	z135rntqckuly40wmjk7v33uaqx22z87uo1oofnogwxklfzr8z593u6l5gj2dbs19lmykyscs5s6h2axxdigtijowtosvmj4of66lt5m1r3trhp1nnpw1s8adieg0v8vy94exfdez4esl5o8qnk5rv4oociv8rjzf09x2o0fdf83g20anv8nnsodmlsj0dgkgldgit
011ef684-d892-47e0-bbef-a54300e42332	0dbfbb81-cd73-43ee-9c82-13c58a197913	www.gaye-zulauf.info	doc	rgm9wdffmf55w7roj874ajbtx8sb54puelzxa4f1fyu7cby4iw1xpnlva4zbz2qkxt1rb8holcgzpcu9uzmid8frtxldssvpotij4szbyg0b33cjziu2sofuqyjwr
6fd6dd23-21cd-472d-884a-402d85401fa9	b3f7320f-1fcf-4705-8094-9cd2214a38a3	www.shelly-morissette.biz	docx	rdb3cnqv5uz19j2sqr8uz3hjesxq7i4aoajenj1711u2poo2d0r5pbzjqhqx19nnlgb7jxqamgym4dhsda15u5d35g6ovtfp2mva6364wn7t7e50nc48bgzjib533o9lm2enjocry9pzpn50bn5rhzavnp6kvw02a0
a2f11d2e-ebed-42ca-8e4a-486bd3619057	ba8ad27a-fbd5-4eb0-8bcf-753349579c90	www.carlie-gerlach.com	docx	xtjv1o3fz7wr2ky1lipo6kpl19bhk8igr5lcpb5u1sbff6avn4nlleqfcq20gxqvj9zy716ti2algpvyqwelgax7wbnfzf5lhigh5qrrfueah99t5jrcdeu46zjtnc7am4551jt8vweoy8osc45uanxyp0p0d3ghle6uw2m96w3oybg04w1yw2m6pcayt0c22xybet
d98ec116-194e-4f74-b47e-2ce3d1c01281	9681b136-b520-479d-bdfe-43cc5beacea2	www.israel-bergstrom.net	xlsx	a37lzze8omksoik2tvcyfxbpfas3aklh30km869ycpzyq32blyqz1rtp9g9eccocj6e80z3g5azisnc5j1pyo000nt1cjpm33yxpvakk8xh8duhp3e47s98x8v9asit1k2c78ugkkn8q6jvvp6ojk1x5w5pimsqstvjiojn91y5
ff613b5d-684b-46e3-8d20-8253c5c08144	9681b136-b520-479d-bdfe-43cc5beacea2	www.willie-von.io	ppt	qiz0dhy43y36em9iayjsbeh33fnrjgyh0sldq85yx4im8xe4bpjbcnmt62iu75co92lb4rpqyuzgc9hy4iwegd5hvof9345l4e7gn1t1zccylg2ju3hljko58rd7jizkxpc3m3z7661z7px9nymhg2xqj491iukhs0ncn5ho9ksc4mu25dsk0
61a5f865-68e7-4cde-8b56-d3b25c61a4e8	9681b136-b520-479d-bdfe-43cc5beacea2	www.cecily-brakus.com	pdf	ewcdh71ygrni48n2kf6vcvbqex3x0a010p3aiwx6whxuc2ccq6yxtztfl94iapq98fluzi2mftridv5aot3kvsr6o2sez1my9rq0o6y0bvu6z7ogq6yrnkeezrq2vmyik7k9cb8u2wlluaz6vbzyt48an4odmv0g8ld0xncr4n1fir5kfrhbysbgfir5oqrbyhhay0qfgwyx
0e5dfcb9-5237-49fa-9785-23376d04f0f5	82bc62ed-172f-4ffa-baa2-310f2e3f4dd6	www.tanner-hand.org	doc	0w5b66icxzrptwi4h2gnue1ecrj8jyme26qadvvyise28xidv9eczkpp714rpcsbautqtvzupoo0n9ywl7fx5zv0n0j2bbg1qwi8g679qbssb5zyt9c
b354a6bf-4576-4712-843a-ec4f33a35de3	82bc62ed-172f-4ffa-baa2-310f2e3f4dd6	www.caitlin-gottlieb.com	docx	uox5as3wszgfeff8dhyngh9fpv4okio0md8gtjx4v9fz0eju7arsln43wyge3nzmifc8e3u9f945akvem2ekf6gya87408sk2q8setmitb6g8lm38h8mxwxfoz9xrlj2aeodw8osnvmoxg6i074mdpffwlbdwbwn73thp9en3l2lauh7ege4tq5q8vccy6rgv5629j
e35b22ef-12f5-4250-8aa2-8ca07fbf676d	5e474308-d308-4f27-b5e9-16a11149791c	www.kymberly-hickle.name	xlsx	k32qmkn744jm15yearr5evz0ypzr6q6t4r9l6h8rayi0466s8va2rno7yjc592k3ucgmgxba7uumkd83yiiot7aclyz13icc8i21768oakqc9ku23hku5y059pmqgzde5mxre1za0sbljhvo3m3h0613lobgoxreuvug5qpygvpmmtn7nr8w0xbzyvqk7wm81x4r30wmu
6427cbb2-8e28-46d8-aff9-4c82f576f31c	49364c43-878c-43e7-a477-dafb1670b62e	www.art-breitenberg.biz	pptx	8ry8k5j7ghjdcnoznumbeu4tp8h08ojty25hqjtpybn8hkbwizutj283oi0boalh21k9uyjtsitrqo505td9dlmht3u87872as7xumq69lzzrmfzxc5104jngdqj4784otmoel6dr9jnh7w5aoggwvm15uuh7fcfltl3cpqbgk4r3y2ucy07e58ach15l8c3x5scqi6atk10
7ae98ca6-62e0-40fc-a1ff-6fb27554c5e4	49364c43-878c-43e7-a477-dafb1670b62e	www.marco-metz.name	xlsx	93c9nlogaand54wvc0u3irbqz8t4u28ixfvx93971n8jana42ranzlubrcrjx8262e3j2pjzfzcr9e4gbmab1n7bf9hyb8qbwzo5n90cumyegcgjb1eauiqbnqkd4uq9b9vi0biw4j2v7ac1u4p
ea7d79d9-d69a-4c6a-b763-eb2290624a34	e2a0cabd-9cf7-495e-a3fc-53c6817f404a	www.kori-beahan.co	docx	zp0gpr7rr6k1pqek4uf8la60wkseniaokjdpxtxum20l6n3zjn3r1ixeenz7fjk9zjsbsc1kzne0295jaddt8mnaone5cwp8fjr7plmyc42ptayr5gmrokgsr9wei2zqxinzsjgs6cws7iikv7yrnnsvj9vgx84vknnltewm0tw1877u04kfzc44jbsplenutwt8grhzkpdoh0vo1xue6x76z2yvb5ddzrjo59j0y98icixrqo2c
d3ad6257-3f5c-4c34-8792-04cd38cbbe30	e6ffb9ca-72c1-4c9b-8e87-4257e91dde18	www.elnora-jacobson.co	xlsx	j4lpj1o7tdzw1j5rg2pif06gce8p4phjpzld9guz84d4geykz4aynm4ftd59rkpfhdbqjyhdakqegepsebri9lhuwuvje11w8bluew5ufc3kauagtohitq0lllficdw48fssdtltbw3yy7
f4d11ccc-ecad-451c-8ec8-28f9a67142e8	e6ffb9ca-72c1-4c9b-8e87-4257e91dde18	www.ahmed-larson.net	pdf	fptbmif5ra84xruyktmforvf2bcqozoucnx8boykl0dzx4dybmie5p3iiiqxcffhajvth8vo09gqybm9802xdrvotncu72wkv2isotb906nqswvmvmuxc4ni0qb8yq5s18mukrwslz3plvaxp5tu1o3jdur51mwgvdx44ygh43zozxlfp0b92vf42rz34af
6719ae4f-542a-43c3-89a4-ed62d9eda5e2	2233d38c-78fd-4072-bda9-2722b40378cc	www.irving-padberg.net	xlsx	3lp16bmv9b4zb7za4l6076rzv11vyajc288xm3v6mwovzfupueuar8dbe95ada1slhziwu7fgsyrvfx33c00g0fqsvtq6882cxxt835ifxp1azuop78a1tu2wqk0
282e5449-dd1b-445b-8079-ae294f7a5339	2233d38c-78fd-4072-bda9-2722b40378cc	www.jerry-flatley.net	pdf	jgqv49by0o24wvp46q3e75qbv5u3lf40smdfc4jm0t6dks9quu8b152teygk5nxuogdu3llnyqxikoggi4twlgry2lshasrjmn4751lcxsqd4jz1rz6i2x
156b7126-0162-4e9f-93bc-c848f15fd14a	954071a5-3d7a-4b47-b299-161c388cd207	www.reuben-goodwin.net	pptx	tgirnzgpmtvmzyumtn2fcr314lz37uqi8z965smnklph6tjrda02w8z9lx1fmayd9rqq760xgi2lm38dwv6jy8tjyktt9aebzzhpmtbcvhlycnbofnj22nxncvuai75kcjal0t
34ed7dcf-3807-4a8c-9901-11f8f4540d3e	954071a5-3d7a-4b47-b299-161c388cd207	www.aron-heathcote.org	docx	wv5jt1xd6choua6zpjzw5akd0ny1ymreezlxy76udcqhzeka0n0y55m62ydx95aae8742lpnl3adaha1hes7lukxptcq1inxqqste7jwj7tbfa3ppxxszxf5bogihzxzzxerkkv1uiwr
bfaad8bb-3f63-48d1-bc99-0e307a953369	c25ac95e-e095-4db5-a854-801d2b1fd548	www.foster-block.org	pptx	8uk6ovz4penjwj7k7jpkzvatn5fbn2yrbzfy2t63rnsmri6wdlxcw4n97ovvz1p0dad3rqejhwnehmy6tc5apbbzp5ilobfhv1ckdj6t8ew4a33nuk8nxs40y8f8an8lk8xy1oyzvb9cecexsp0feiolctkqsvtmppzsntvanq8ls7ttok69mai8e9yzclojxyb7ay7j3g5w2ui0tohq282jxb4k86fs
a9069476-f9ab-49bd-bfe2-2eb85be0f319	c25ac95e-e095-4db5-a854-801d2b1fd548	www.fabian-dickens.biz	xlsx	e4sriqsmibo8pzt3sosnv7wda9x3y46g6czspoudy6ngck3vxklwmzkcguitox3lyxv5cq138arp0yn39fsfu0sz267je8gt6mjroeqsagp89fuvezfsphrj
\.


--
-- Data for Name: tender_bid_evaluations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tender_bid_evaluations (id, tender_bid_id, evaluator_name, score, comment, created_at) FROM stdin;
6f1ae21d-a0ba-4dfb-97b0-f9d046f8eb6d	ee6e99cb-a40a-4fda-aaae-4c7cfaac8193	Dr. Jaimie Macejkovic	2.78	Unde ut et nostrum quo non est. Totam distinctio eum laboriosam esse. Omnis sunt sunt.	2025-05-25 18:55:34.867912
427cf186-2dae-4071-a775-6c87b4c359bb	ee6e99cb-a40a-4fda-aaae-4c7cfaac8193	Mrs. Carrol Keeling	1.82	Doloremque doloremque omnis eos nihil a sit sit. Natus ut ipsa repellat dolores ea at eligendi. Et expedita corrupti nobis ullam est odit officiis.	2025-05-07 18:55:34.868619
164b223e-c1f1-461a-a7d5-c57dd1a31468	5489814f-807d-4020-bfea-8653a0fe7acc	Katia Kihn	3.47	Et necessitatibus iusto animi modi exercitationem error illo. Aliquid recusandae fuga soluta esse. Molestiae modi veritatis voluptatem fuga non odit ipsam.	2025-05-24 18:55:34.869445
2ce8e912-72f4-4502-bab5-283784975f41	5489814f-807d-4020-bfea-8653a0fe7acc	Delia Koepp	2.27	Aut blanditiis repudiandae libero blanditiis. Assumenda molestiae est consequatur explicabo iusto. Nulla quidem autem qui omnis.	2025-05-11 18:55:34.869979
5d549bad-69d5-4bce-932d-e4cfaf1f4d92	81da2a0a-90eb-44d9-aaed-6f671ecdd60b	Jean Volkman	2.29	Iste suscipit qui tenetur deleniti qui est optio. Ipsa illo omnis qui ab nesciunt saepe ut. Porro voluptatibus nobis. Tenetur dolores iste.	2025-06-04 18:55:34.870677
e9999309-57e4-4e46-b84a-633276bc2dc5	81da2a0a-90eb-44d9-aaed-6f671ecdd60b	Reid Klein IV	0.48	Non molestiae exercitationem molestiae. Dolores voluptatem dolor pariatur ullam natus. Alias in rerum beatae laboriosam ex repudiandae optio. Assumenda ad in suscipit ut accusantium est. Facere aliquid incidunt totam et vel iste.	2025-06-01 18:55:34.871404
e6262b02-0dd1-4e42-ab04-eee57636a213	8ee6c63f-fc01-4ccc-98c2-2171e6684cf0	Lawana Jerde	3.45	Sint culpa atque. Non voluptatum minus id occaecati aperiam unde praesentium. Sit placeat quae in quia possimus harum vitae.	2025-05-30 18:55:34.872016
70a751fa-d644-4976-a507-a33725be707f	310c6daa-5767-41b2-89bf-eefede34ab4d	Ronnie Feest	4.75	Quo inventore consequuntur sed. Praesentium expedita doloribus. Ipsum et quas et quod quam facere. Nobis officiis fugit enim et. Sit quod officiis.	2025-06-02 18:55:34.873394
2d5432b0-cf45-4989-896d-b86e550a26f3	310c6daa-5767-41b2-89bf-eefede34ab4d	Earle Gerlach	4.18	Voluptas qui repellat eveniet illo. Reiciendis molestiae recusandae provident. Adipisci iure voluptas id inventore qui distinctio quidem. Incidunt voluptas cupiditate cum rerum facere pariatur omnis. Molestiae tenetur totam quam dolorum possimus.	2025-05-14 18:55:34.874004
ea13435a-a5f8-4e47-8201-4a72e60a500f	310c6daa-5767-41b2-89bf-eefede34ab4d	Mack Pfeffer	1.36	Blanditiis dolores maxime necessitatibus. Laudantium quaerat at voluptatum nihil. Consequatur dolore fuga quibusdam saepe ratione sit enim. Consequatur harum at sed suscipit ea qui.	2025-05-09 18:55:34.874615
2a41c069-56aa-4969-a503-46b1fecf0fa8	5eb76409-7c6e-40b9-9477-32584d6690f4	Marco Johnston	1.62	Dicta a amet pariatur quia laborum ut nulla. Esse asperiores repellendus numquam odit rem. Amet dicta accusamus. Eos ab qui rem nisi.	2025-05-08 18:55:34.875435
4d3fbff5-6c63-4887-b62a-27c330bbe7b9	5eb76409-7c6e-40b9-9477-32584d6690f4	Romelia Towne	0.97	Quibusdam animi nulla omnis. Dicta repellendus blanditiis. Et odit ut sit autem aut aliquid. Numquam corporis quos corrupti quam voluptas.	2025-05-16 18:55:34.876014
45ac91cb-b72e-4360-920e-8573efff275f	5eb76409-7c6e-40b9-9477-32584d6690f4	Elmer Hodkiewicz DVM	1.02	Aut libero pariatur numquam consequuntur ipsam. Dicta omnis ipsam culpa quasi quo voluptas perferendis. Voluptatum et vitae rem. Non maiores veniam. Quis doloribus eum officiis et.	2025-06-03 18:55:34.876704
6c3be2ab-2463-4412-9455-7d08165eee3e	bcf9f72d-9e7d-4d5c-bc96-a75eed866d7c	Forest Hagenes Jr.	0.61	Magnam omnis voluptatem illum quidem magnam voluptatibus. Est quidem at atque alias perferendis enim rerum. Eius nihil adipisci numquam doloremque maxime eum. Ullam sint et aut qui odit sapiente.	2025-06-03 18:55:34.87912
8d399256-ccb0-40f6-8d94-e1bb0ee51268	bcf9f72d-9e7d-4d5c-bc96-a75eed866d7c	Mr. Gilberto Kessler	3.26	At nisi odit dolores. Porro non repellat at provident vitae occaecati. Totam nihil mollitia excepturi voluptatem rerum.	2025-06-02 18:55:34.879685
f2f059da-61ed-47a5-9bde-c84e1280ad97	bcf9f72d-9e7d-4d5c-bc96-a75eed866d7c	Ms. Barry Heathcote	2.38	Quia inventore possimus est deserunt ea rerum. Recusandae et enim cum rerum esse quas omnis. Iusto laborum fugiat enim occaecati sed. Ut non vel. Asperiores ut consectetur sed sit.	2025-05-08 18:55:34.880768
654f3875-e6fd-4f66-834f-cac0b8b40ed7	37fb007a-b6c4-4768-a5cd-ea9190293e68	Signe Breitenberg	0.40	Sequi quas necessitatibus. Quibusdam autem rerum molestias excepturi cum dolor accusantium. Velit et dolorum dolorem officiis nemo delectus quas.	2025-05-24 18:55:34.881707
a28e276f-834f-424a-869a-3c28b2119846	6972fda3-98c2-485b-bc7a-bf3fd3f2e7c2	Walter Lesch DDS	2.98	Porro qui inventore quam est. Voluptas voluptate sequi eaque dolore nihil. Animi fugit qui quos. Maiores quis eius rem nobis ut itaque quis.	2025-05-08 18:55:34.882634
bc8488e5-c27b-4f3d-a6fc-db7809c7eaaf	835751ec-f70d-4610-9b25-63c03bd480b3	Lyn Corwin	0.09	Velit quasi qui est ea consequatur. Velit numquam ex cumque maxime soluta doloremque sunt. Ut aut ut. Quisquam a sed. Qui aut similique debitis dolorem et modi voluptatem.	2025-05-22 18:55:34.883552
04fa79ad-07c6-45f4-8a2f-900690bc2aea	835751ec-f70d-4610-9b25-63c03bd480b3	Arlinda Stroman V	4.96	Nostrum vel autem at consequatur sint reiciendis. Debitis exercitationem sint id. Corrupti tempore et voluptatem earum.	2025-05-25 18:55:34.884101
6d40212c-9583-4e7a-b903-c4bb032681ca	835751ec-f70d-4610-9b25-63c03bd480b3	Kathlyn Lynch	0.16	Reprehenderit sit debitis dignissimos. Alias molestiae similique. Fugiat quae sunt consequatur nostrum veniam animi. Nam cupiditate quod adipisci impedit ut sit quia.	2025-05-17 18:55:34.884679
0e2d4a5a-b1cb-4b03-8604-83ac5381fb56	31d5c8e8-339d-4c77-8ea7-b6bdd6657bfe	Parker Stokes	1.37	Molestias qui quia similique. Est tempora vel dignissimos. Sint molestiae qui magnam velit.	2025-05-06 18:55:34.885376
f0cf60d4-aaac-4f15-abcc-669d17421aef	31d5c8e8-339d-4c77-8ea7-b6bdd6657bfe	Avelina Little	1.77	Et asperiores ea rerum quia qui quos in. Et eum odio repellendus quae placeat distinctio accusamus. Eos vel mollitia temporibus incidunt voluptas illo. Consequuntur rerum et et est repudiandae reprehenderit eos.	2025-05-19 18:55:34.886015
f4e21684-0b68-4fc0-a528-cf3d38352588	cdb3ef4c-5734-49c9-bcc3-913b3059e40e	Avril Ryan	2.58	Architecto tenetur atque ab labore rerum explicabo quam. Rem id dolore porro rem odio architecto aut. Cum numquam dolores vero id dicta.	2025-05-16 18:55:34.888091
d1f21072-4c9a-4e80-b8cd-6c2d399d3e30	cdb3ef4c-5734-49c9-bcc3-913b3059e40e	Henry Cruickshank	3.00	Mollitia illum facilis mollitia perspiciatis fuga nesciunt. Placeat rem at magni qui incidunt fugiat velit. Dolorem laboriosam voluptatem. Quam vel eos magni facere. Et sapiente dolor magni aliquam commodi ipsam qui.	2025-05-07 18:55:34.888694
63414b28-d219-4efc-b93a-9ecc6acd3390	cdb3ef4c-5734-49c9-bcc3-913b3059e40e	Deneen Schowalter	1.33	Accusamus recusandae ipsam sit mollitia amet eaque ea. Ratione a minima eveniet. Eaque iste doloremque voluptate qui doloribus nihil. Quaerat et itaque consequuntur enim illum. Est consequuntur velit.	2025-05-25 18:55:34.889266
de1d5a47-8b36-413f-b5f9-c23f18d787a4	0802e79d-a366-417c-a12f-e6c07a5e6fb2	Cierra Huel	3.35	Sunt vero eos doloremque eius repudiandae cum. Voluptates ea iste et recusandae. Aut voluptas minima explicabo rerum velit dolorem nam. Aut in voluptate aut maxime molestiae quis soluta.	2025-05-23 18:55:34.889951
57f5b3fe-48b6-4f76-b845-c8a349ebc80a	0802e79d-a366-417c-a12f-e6c07a5e6fb2	Roberto Thompson	3.53	Facere repudiandae sit. Neque qui repellendus id voluptatem dolores facere velit. Quia amet ipsam est.	2025-05-11 18:55:34.89041
fc494c96-d5d0-45b2-a8c7-332417cf6570	0802e79d-a366-417c-a12f-e6c07a5e6fb2	Dr. Arlie Zemlak	4.74	Ea omnis dolor est dolorum esse voluptatem. Repellendus repellat quaerat. Enim quas minima ratione neque eius modi sunt. Dicta et consequatur esse beatae.	2025-05-26 18:55:34.890976
6870b325-462a-4afd-9885-102162a43de6	5714b1c9-32fd-4610-9362-1df550ab03f4	Miss Elizebeth Bergstrom	1.07	Voluptatem perferendis deleniti occaecati sequi qui doloribus. Aut tempora et commodi fugiat ab libero fuga. Eaque est praesentium. Nulla possimus debitis qui. Et quod possimus deleniti culpa.	2025-06-03 18:55:34.891728
6bdc90eb-b1bc-4653-a33c-32f18160d795	5714b1c9-32fd-4610-9362-1df550ab03f4	Carli Cole	4.13	Voluptates ducimus ut doloribus ipsum dolor deserunt sed. Ratione qui cupiditate eligendi ducimus quidem. Ab numquam totam consequuntur cum porro consequatur.	2025-05-11 18:55:34.893173
12f77282-f816-47aa-857b-81dd37b7fee5	5714b1c9-32fd-4610-9362-1df550ab03f4	Ted Turner	0.21	Mollitia accusamus sit modi quod. Temporibus quae adipisci. Nulla id et tenetur. Harum facere laborum.	2025-05-11 18:55:34.893665
937efe5a-0d32-460b-b801-96fcc3e152bb	c5d0e656-4b0d-450b-96c6-32907264c325	Thi Olson	0.20	Dolores accusantium laudantium. Qui eligendi inventore rerum totam aut minima. Et eligendi doloremque. Autem praesentium harum neque et. Nulla mollitia voluptatem.	2025-05-23 18:55:34.894653
4a67577d-a157-4c66-ab1a-76b0e75aa0a0	c5d0e656-4b0d-450b-96c6-32907264c325	Maribel Goodwin	0.18	Aut officia impedit est. Cupiditate beatae sit et ea excepturi non sunt. Aut non perspiciatis non amet temporibus. Soluta autem perferendis officia. Iusto voluptas dolorem atque voluptatem.	2025-05-23 18:55:34.895216
44f28ec9-e72b-435f-8ec3-6086a029769d	0dbfbb81-cd73-43ee-9c82-13c58a197913	Dr. Mardell Ritchie	1.25	Ea quisquam quibusdam dolorem velit vero ut in. Placeat sunt facilis dolorum sed deleniti vel cumque. Et et vel. Voluptate omnis doloribus exercitationem.	2025-05-08 18:55:34.896283
3757f30b-54be-4ee4-a161-c69141d7e48a	0dbfbb81-cd73-43ee-9c82-13c58a197913	Kenny Green	4.92	Et eum rerum quisquam. Odit commodi culpa suscipit. Ex assumenda laborum earum et et.	2025-05-26 18:55:34.896773
8f9bc503-43d5-4c90-a832-cd157c9cf011	0dbfbb81-cd73-43ee-9c82-13c58a197913	Ms. Temeka Moen	4.19	Numquam sunt aut ea laudantium laborum voluptas. Rerum non dolorem velit. Vitae optio veniam est.	2025-05-27 18:55:34.897206
ad086733-c020-4d8c-af88-23c3f62779f6	b3f7320f-1fcf-4705-8094-9cd2214a38a3	Mrs. Avril Kassulke	4.10	Sed deleniti sequi qui. Aperiam veritatis placeat aut odio perspiciatis eaque. Quo id vitae sequi et non dolore. Sint alias quas nisi et corrupti.	2025-05-19 18:55:34.8983
a33d4557-1ffd-4f2e-a979-8b038b746d84	b3f7320f-1fcf-4705-8094-9cd2214a38a3	Brian Tromp	3.29	Vero incidunt nisi qui qui. Non harum et sit. Aut earum et. Culpa corrupti hic repellendus et adipisci sit sit.	2025-05-15 18:55:34.898961
20aa3595-081f-4d6f-b8b8-66932fb65d4f	ba8ad27a-fbd5-4eb0-8bcf-753349579c90	Billy Bartoletti	0.82	Voluptatum consequatur sit. Accusantium maxime ipsum in corrupti. Aut accusantium repudiandae eum suscipit maxime suscipit. Ut vitae adipisci quasi aspernatur voluptas asperiores perferendis. Rerum modi laudantium perferendis.	2025-05-17 18:55:34.90113
0f82fd6e-6ea8-4923-bcc1-eab73e88d352	ba8ad27a-fbd5-4eb0-8bcf-753349579c90	Kris West	2.53	Sit et nihil officiis quidem. Accusantium esse fugit et esse. Voluptas praesentium recusandae. Nam quos harum reprehenderit dolorum.	2025-05-20 18:55:34.901613
5b567ac5-e4d1-436c-b111-9e39a689ceb1	ba8ad27a-fbd5-4eb0-8bcf-753349579c90	Jeniffer Homenick	1.60	Cupiditate earum sequi exercitationem doloribus. Consequuntur porro eligendi. Similique nobis sunt vitae ratione. Dolorem tempore provident possimus optio sequi sed explicabo. Iure beatae eaque.	2025-05-13 18:55:34.902515
2a9d44f1-c21d-444a-a5fa-22845d753a9a	9681b136-b520-479d-bdfe-43cc5beacea2	Delila Wolff	1.48	Consequatur omnis eum. Explicabo voluptas voluptas voluptates beatae repellat. Est pariatur dolorem.	2025-05-11 18:55:34.903272
d72f7532-b721-4f48-a4c7-74fd7983c383	9681b136-b520-479d-bdfe-43cc5beacea2	Dr. Jamar Orn	4.58	Aut inventore velit rem. Vel fuga asperiores qui. Maiores nihil doloremque. Excepturi deleniti delectus autem.	2025-06-03 18:55:34.903826
b385ad6d-6f3c-4c89-a881-3275427d307d	82bc62ed-172f-4ffa-baa2-310f2e3f4dd6	Lakeshia Runolfsson V	1.63	Tenetur praesentium quia aliquam beatae. Est quaerat at dolores. Nobis nulla consectetur veritatis atque ut vel. Minus et libero et. Doloremque expedita iusto officia.	2025-05-16 18:55:34.904605
fb9844ed-2f7e-4b5d-aced-57a189bccb25	82bc62ed-172f-4ffa-baa2-310f2e3f4dd6	Dusty Oberbrunner II	0.31	Provident harum amet in. Et ratione doloremque ducimus sunt. Pariatur molestiae aliquam nam qui voluptatem nemo.	2025-05-16 18:55:34.905098
d191881c-16ab-4ee7-a063-7d4cb3f4dccf	82bc62ed-172f-4ffa-baa2-310f2e3f4dd6	Monte Huel	3.07	Accusamus quas velit consequatur reprehenderit laboriosam minus cum. Sed vitae repellendus eum. Mollitia non voluptas corrupti saepe maiores dolores. Sapiente perferendis at animi quo incidunt fugit.	2025-05-21 18:55:34.905644
99e0b51d-301e-47db-8add-09cd0e4032c0	5e474308-d308-4f27-b5e9-16a11149791c	Young Crist	4.93	Id aspernatur accusamus repellat non cum ex. Sunt est nisi nihil esse reprehenderit delectus dolor. Neque quis et voluptas. Aliquam assumenda suscipit. Explicabo et a non.	2025-05-14 18:55:34.906289
9eba5bb4-26e8-4ace-8bb2-6c0d0135c32f	5e474308-d308-4f27-b5e9-16a11149791c	Joanna Jakubowski	0.09	Autem blanditiis expedita laboriosam et excepturi laboriosam aut. Quae nihil nobis et similique et. Quisquam dolorum aliquid neque sapiente voluptatem optio. Possimus distinctio aspernatur vero eum quia.	2025-05-11 18:55:34.906821
a6eb80e6-e539-4b63-8a7d-e7d150b7fc9c	49364c43-878c-43e7-a477-dafb1670b62e	Minh Bednar	1.48	Aliquid maiores est sapiente dignissimos. Alias modi aliquid. Consequatur quaerat ut corporis. Facere ducimus aperiam maiores debitis nihil quos molestiae. Autem molestias quae maiores.	2025-05-30 18:55:34.909041
88c678ce-030e-4425-a968-c8bfde4fe841	49364c43-878c-43e7-a477-dafb1670b62e	Dana Veum	1.64	Eum enim est neque ratione porro et. Sed eos minima voluptatibus et. Qui doloribus et. Possimus reprehenderit dolor nulla voluptate itaque dignissimos facilis. Autem suscipit et et ullam quibusdam.	2025-05-16 18:55:34.909677
5dbca022-00b4-4ee7-99f9-03539978be46	e2a0cabd-9cf7-495e-a3fc-53c6817f404a	Willia Schultz	3.63	Et fugit sunt laboriosam repudiandae aut et. Ullam id repudiandae a minus. Blanditiis ex delectus voluptate quo. Soluta fugit molestias officia ut praesentium. Quia sed aliquam et.	2025-05-24 18:55:34.910384
4c21346f-cb0f-4b55-aadd-1ca045579f38	e6ffb9ca-72c1-4c9b-8e87-4257e91dde18	Jarod Hodkiewicz	3.68	Exercitationem repellat ea ratione fugit asperiores similique. Maiores pariatur perferendis ut et ut aut voluptatem. Ut maxime iusto maiores itaque in. Eius nulla voluptas. Repellat sed voluptatem.	2025-05-23 18:55:34.911302
01a68eae-0806-407e-b7d2-639428af90dd	2233d38c-78fd-4072-bda9-2722b40378cc	Paul Renner	0.19	Culpa quo eos ea qui numquam ut. Perspiciatis corporis et. Quibusdam eligendi laudantium quisquam explicabo tempore aut. Vel voluptas sed dicta sed soluta enim autem.	2025-05-25 18:55:34.911951
65645f41-2152-4823-a546-e16df75ecd69	954071a5-3d7a-4b47-b299-161c388cd207	Moira Kuvalis	3.24	Facere mollitia ut. Ut similique sint. Ut nesciunt illum veniam ad veritatis ex autem. Voluptatum quo non. Corrupti tempora qui deserunt sed dolor tempore.	2025-05-22 18:55:34.913099
ce382305-d525-4cd4-88c5-e8df6d8aaa24	c25ac95e-e095-4db5-a854-801d2b1fd548	Mrs. Lilia Runolfsdottir	2.76	Quo error architecto similique aliquam quo. In molestias blanditiis vero. Quis sunt quae.	2025-05-23 18:55:34.913766
04240adc-c479-46c1-9e83-87d1ed53dc54	c25ac95e-e095-4db5-a854-801d2b1fd548	Austin Luettgen	3.53	Quidem vel et. Nemo quam est voluptatem voluptatem molestiae consectetur. Ut quia illo hic voluptatum. Perferendis deserunt dignissimos qui enim ea. Error possimus qui praesentium iste consequatur fugiat quam.	2025-06-03 18:55:34.914231
\.


--
-- Data for Name: tender_bids; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tender_bids (id, tender_id, bidder_id, bid_status_code, proposal, created_at, warranty_period_months, completion_time_days, total_score) FROM stdin;
ee6e99cb-a40a-4fda-aaae-4c7cfaac8193	e7399781-573f-4cf1-90dc-81d35e46f014	4ee49614-d5ac-4747-ad7b-53e8d011c033	draft	Architecto accusantium qui molestiae fugiat. Non aut qui facilis et sed. Ducimus architecto sed nihil tempora. Quaerat enim natus. Repudiandae vel accusamus vel et et voluptatem inventore.	2025-06-02 18:55:34.863344	15	55	2.30
5489814f-807d-4020-bfea-8653a0fe7acc	e7399781-573f-4cf1-90dc-81d35e46f014	4bf92c1a-44eb-4161-bd36-dd3a2845a695	draft	Odio totam blanditiis excepturi non. Sed iure rem unde molestiae. Inventore facilis deserunt sed voluptatem mollitia ut.	2025-05-17 18:55:34.864262	14	112	2.87
81da2a0a-90eb-44d9-aaed-6f671ecdd60b	e7399781-573f-4cf1-90dc-81d35e46f014	99026b27-e389-49de-a555-868e3529fdc5	draft	Repudiandae autem aliquam. Minima recusandae cum laboriosam asperiores maxime. Explicabo vel quis enim nihil pariatur et.	2025-05-19 18:55:34.86472	28	106	1.39
8ee6c63f-fc01-4ccc-98c2-2171e6684cf0	e7399781-573f-4cf1-90dc-81d35e46f014	5e846192-3f8c-49f7-9906-4e4a0f3ef781	submitted	Corrupti enim nulla deleniti ad. Incidunt fugit praesentium dignissimos perferendis natus illum repellendus. Eos dignissimos asperiores et corrupti nemo sit odio. Et totam ipsa commodi similique blanditiis. Et optio sit ut aspernatur sed maxime accusamus.	2025-05-18 18:55:34.865176	29	80	3.45
310c6daa-5767-41b2-89bf-eefede34ab4d	281b0303-7ea1-4e45-a44a-3900c72fce1d	99026b27-e389-49de-a555-868e3529fdc5	draft	Distinctio consectetur soluta tempora aut. Ut amet iure tempora ut. Quaerat dolorem suscipit est ullam adipisci sint reiciendis.	2025-05-26 18:55:34.872207	17	111	3.43
5eb76409-7c6e-40b9-9477-32584d6690f4	281b0303-7ea1-4e45-a44a-3900c72fce1d	4ee49614-d5ac-4747-ad7b-53e8d011c033	submitted	Sint qui harum voluptates inventore excepturi eum eum. Ut magnam autem excepturi placeat veniam voluptas. Eius est ut modi. Quia similique officia laboriosam ut.	2025-05-17 18:55:34.872451	22	95	1.20
bcf9f72d-9e7d-4d5c-bc96-a75eed866d7c	c27fc3fc-4d96-4c6e-b5fc-62b789deb769	99026b27-e389-49de-a555-868e3529fdc5	draft	Repudiandae dignissimos dolorum dolores voluptate iure aut. Sed voluptatem quis animi deleniti adipisci iure dicta. Itaque neque sed eos id eum. Ullam possimus cum quis quas est porro.	2025-05-31 18:55:34.876821	29	39	2.08
37fb007a-b6c4-4768-a5cd-ea9190293e68	c27fc3fc-4d96-4c6e-b5fc-62b789deb769	2b748d02-13e3-4c56-a774-fc1841027cfd	submitted	Esse totam ut eligendi doloremque est voluptate voluptatibus. In voluptates autem repellendus dolorem. Dicta doloremque corporis nostrum repudiandae sit. Voluptas voluptatem harum consequatur fuga labore debitis et.	2025-05-10 18:55:34.877209	23	88	0.40
6972fda3-98c2-485b-bc7a-bf3fd3f2e7c2	c27fc3fc-4d96-4c6e-b5fc-62b789deb769	25eb8322-21e4-4a89-a485-5e267d2bfef6	draft	Perspiciatis deserunt non. Veritatis consequatur voluptatem veritatis autem numquam impedit qui. Tempore et repellendus hic voluptate. Velit consequatur qui doloribus.	2025-05-13 18:55:34.877527	16	69	2.98
835751ec-f70d-4610-9b25-63c03bd480b3	c27fc3fc-4d96-4c6e-b5fc-62b789deb769	e831937b-abf5-4d9d-aacd-14d729a07054	submitted	Reprehenderit laboriosam accusantium. Consectetur nesciunt nobis praesentium et. Fugit aut aut. Nisi laudantium atque.	2025-05-06 18:55:34.877837	27	33	1.74
31d5c8e8-339d-4c77-8ea7-b6bdd6657bfe	c27fc3fc-4d96-4c6e-b5fc-62b789deb769	46d8b973-2d30-4392-a8f8-03e6fa1358b4	submitted	Quasi esse perferendis magnam architecto eum amet. Officia amet aut voluptas adipisci provident praesentium. Vel enim qui voluptatem voluptatibus sit aut tempora. Laborum unde consequatur aliquid autem.	2025-05-25 18:55:34.878048	29	72	1.57
cdb3ef4c-5734-49c9-bcc3-913b3059e40e	a1b8d135-4ac8-41c7-8ae7-b360c3599c45	99026b27-e389-49de-a555-868e3529fdc5	draft	Deleniti est itaque. Ea adipisci tempore. Itaque excepturi ipsa aut veniam.	2025-05-26 18:55:34.886126	17	57	2.30
0802e79d-a366-417c-a12f-e6c07a5e6fb2	a1b8d135-4ac8-41c7-8ae7-b360c3599c45	77702d6b-f044-47f2-bf61-1eeabf8aaa9b	draft	Provident ea optio sapiente. Aut autem doloremque fugit qui suscipit corporis. Et aspernatur ullam autem expedita id sint.	2025-05-31 18:55:34.886325	13	70	3.87
5714b1c9-32fd-4610-9362-1df550ab03f4	a1b8d135-4ac8-41c7-8ae7-b360c3599c45	9cf2fbbe-7853-47d1-b8fd-b263f8da2dd1	submitted	Laudantium officia reprehenderit. Dolorem facere quos. Facere quia nostrum quas vitae. Quaerat ut ipsa.	2025-05-22 18:55:34.886588	34	72	1.80
c5d0e656-4b0d-450b-96c6-32907264c325	a1b8d135-4ac8-41c7-8ae7-b360c3599c45	4ee49614-d5ac-4747-ad7b-53e8d011c033	submitted	Vitae voluptatem voluptatum. Quisquam corrupti laboriosam harum aperiam in. Unde dolores officia praesentium voluptas. Nobis distinctio beatae error magnam quis quidem.	2025-05-08 18:55:34.886961	16	87	0.19
0dbfbb81-cd73-43ee-9c82-13c58a197913	cc43e09e-e607-4905-96e2-b2a918c79a45	4ee49614-d5ac-4747-ad7b-53e8d011c033	draft	Fugiat optio sunt impedit. In non est et tempore nulla quo. Iusto tenetur repellendus aspernatur adipisci autem impedit minus.	2025-05-18 18:55:34.895357	22	60	3.45
b3f7320f-1fcf-4705-8094-9cd2214a38a3	986a022e-53fc-4487-95a0-067d0e090a28	f3fa4ae9-2fec-439b-a043-ecdac59fbd09	submitted	Pariatur ad neque. Quia et possimus recusandae officiis porro. Ut omnis eligendi dolorum explicabo. Et quidem facilis voluptate voluptas. Minima magnam placeat aut quisquam qui voluptatum.	2025-06-01 18:55:34.897311	27	44	3.70
ba8ad27a-fbd5-4eb0-8bcf-753349579c90	fbbbb6d2-d8b2-4f1c-9fd6-818a54f5df48	88f7f35c-f5ad-4a41-b61d-e1cb92bbe610	submitted	Et et qui dolores et facere rerum optio. Incidunt perferendis qui magni quasi labore. Assumenda necessitatibus asperiores adipisci aut. Officia placeat ab expedita. Officia blanditiis eius quos aperiam voluptatibus id.	2025-05-08 18:55:34.899118	26	72	1.65
9681b136-b520-479d-bdfe-43cc5beacea2	fbbbb6d2-d8b2-4f1c-9fd6-818a54f5df48	25eb8322-21e4-4a89-a485-5e267d2bfef6	draft	Minima fuga earum. Quo ut eum nihil amet architecto nesciunt et. Inventore dolorum sint similique consequatur accusantium ut voluptas.	2025-05-18 18:55:34.899497	35	73	3.03
82bc62ed-172f-4ffa-baa2-310f2e3f4dd6	fbbbb6d2-d8b2-4f1c-9fd6-818a54f5df48	5c33412a-38f7-4856-85c8-b9322c62fb4a	draft	Nihil illo molestias eligendi similique ut reiciendis ad. Rerum dicta ad aut. Rerum perspiciatis laboriosam aut. Id illo nihil. Neque aut iusto non molestias est.	2025-05-28 18:55:34.899801	17	87	1.67
5e474308-d308-4f27-b5e9-16a11149791c	fbbbb6d2-d8b2-4f1c-9fd6-818a54f5df48	e831937b-abf5-4d9d-aacd-14d729a07054	draft	Autem est sit quod qui ab fuga. Ea deserunt hic eos inventore in autem. Et est error rerum maxime vel unde. Dolore et id nisi. Earum nam ut perspiciatis voluptatem ab quidem deserunt.	2025-05-29 18:55:34.900113	12	48	2.51
49364c43-878c-43e7-a477-dafb1670b62e	9e51169b-a90f-4bbd-ab83-91d356b027e2	88f7f35c-f5ad-4a41-b61d-e1cb92bbe610	submitted	Dicta atque ut aut quasi. Id praesentium est ipsam. Tempora sed laborum corporis. Assumenda rerum necessitatibus sit a.	2025-05-14 18:55:34.906937	28	92	1.56
e2a0cabd-9cf7-495e-a3fc-53c6817f404a	a7da0fa5-d717-49b6-8fef-2227deee4c07	77702d6b-f044-47f2-bf61-1eeabf8aaa9b	submitted	Harum perferendis consequuntur omnis in aperiam. Voluptates blanditiis tempora sunt. Dolorum dolores et minima. Dolor veniam tempore. Adipisci mollitia earum neque sequi.	2025-05-11 18:55:34.909792	13	91	3.63
e6ffb9ca-72c1-4c9b-8e87-4257e91dde18	e0234274-f15f-4f12-97a3-53ff683bff5d	88f7f35c-f5ad-4a41-b61d-e1cb92bbe610	draft	Rem qui autem autem. Autem laboriosam qui beatae iste voluptatibus deserunt sapiente. Reiciendis est consectetur distinctio sed.	2025-05-26 18:55:34.910504	21	47	3.68
2233d38c-78fd-4072-bda9-2722b40378cc	e0234274-f15f-4f12-97a3-53ff683bff5d	5c33412a-38f7-4856-85c8-b9322c62fb4a	draft	Natus commodi voluptates maxime nobis delectus. Quos unde officia ea sed possimus recusandae. Sint ullam et optio magnam quasi ut.	2025-05-31 18:55:34.910667	22	70	0.19
954071a5-3d7a-4b47-b299-161c388cd207	72e31b2d-aee8-4797-b876-1cea29d78f00	25eb8322-21e4-4a89-a485-5e267d2bfef6	submitted	Aut inventore modi. Quasi facere atque. Libero consequatur nesciunt quis. Ipsa nemo culpa aperiam blanditiis itaque. Cupiditate enim et omnis odio.	2025-05-12 18:55:34.912108	22	48	3.24
c25ac95e-e095-4db5-a854-801d2b1fd548	72e31b2d-aee8-4797-b876-1cea29d78f00	8a50a51b-f6d3-4870-8a1a-ba5eb4d10b6f	draft	Excepturi temporibus eligendi similique dicta ad aliquam vel. Nisi qui fuga nihil repellendus. Cumque nobis quidem labore quae maiores.	2025-06-04 18:55:34.912363	35	88	3.15
\.


--
-- Data for Name: tenders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tenders (id, publication_id, submission_deadline, evaluation_criteria, required_documents, description, contract_security_amount, min_experience_years, warranty_period_months, tender_type) FROM stdin;
e7399781-573f-4cf1-90dc-81d35e46f014	95e9c3a2-ff0b-437c-90e6-6a58e874ca6c	2025-06-14 18:55:34.777609	Iusto voluptatem a et iure nostrum.	Qui dolore similique.	Expedita voluptatum quia numquam quibusdam iusto. Rem ea dolores est consequatur. Vitae rerum ut. Nobis esse nobis.	19782.00	2	24	open
281b0303-7ea1-4e45-a44a-3900c72fce1d	a934ec89-1b2d-4f26-827f-bb077c9878db	2025-06-30 18:55:34.7893	Voluptatem velit consectetur vel sit suscipit.	Sunt est et doloremque qui.	At voluptatem eaque. Incidunt aut qui vel enim qui. Aut voluptatem minus et magnam non ut. Alias consequuntur qui tempora autem ipsa voluptatem est. Nemo aliquid facere in nulla ut.	45371.00	1	29	open
c27fc3fc-4d96-4c6e-b5fc-62b789deb769	906f6597-d02f-41fa-a382-f21a423c8edf	2025-06-27 18:55:34.793048	Aut dolore doloremque ut nihil.	Sequi qui distinctio minus tenetur iste.	Natus ea alias. Illo id qui quia quis et sit. Ratione in quo in reprehenderit pariatur. Optio quia qui expedita eveniet dolores esse eum. Dolores dolorem cumque consectetur voluptas ullam totam molestiae.	100808.00	5	13	closed
a1b8d135-4ac8-41c7-8ae7-b360c3599c45	38035b3f-8980-4e63-bab4-3f4fc1741ed1	2025-06-22 18:55:34.79499	Provident itaque ea in.	Quasi incidunt esse unde ut.	Numquam minima non. Perspiciatis est voluptas sunt. Rerum doloremque voluptates quas dicta corporis.	23905.00	5	30	closed
cc43e09e-e607-4905-96e2-b2a918c79a45	61063498-d770-432d-bfc0-99e6aa91ff9f	2025-06-17 18:55:34.801721	Ducimus voluptates aperiam vel sapiente earum eaque.	Assumenda et quo.	Odio delectus modi modi sapiente est. Ab ipsa exercitationem perferendis animi eligendi. Ipsa rerum in ipsam rem accusamus unde alias. In omnis harum tenetur et qui at debitis. Ut qui facere eum labore sed ex aliquam.	49498.00	2	12	open
986a022e-53fc-4487-95a0-067d0e090a28	79b825c4-6c7d-4eda-b8c5-d19b8ae9a4c2	2025-06-28 18:55:34.803103	Dolore voluptates et dolore aliquam quidem.	Dolorum laborum consequatur reiciendis maiores.	Nihil at voluptatem tempore. Soluta ut voluptatem ratione. Enim perspiciatis et magni. Et tempore dolorem ea a.	71602.00	9	33	closed
fbbbb6d2-d8b2-4f1c-9fd6-818a54f5df48	7d230267-35dc-4560-b05b-165ac4ffd03e	2025-06-15 18:55:34.804154	Sunt ut repellendus ut.	Sint necessitatibus ipsum beatae officiis ducimus sapiente.	Provident eos fugiat dolores odit ullam ut. Et sed dolore quo. Et animi non. Et delectus unde voluptatum.	30978.00	9	34	closed
9e51169b-a90f-4bbd-ab83-91d356b027e2	3d00b60d-8da8-4831-a0a4-98eaae7aaa20	2025-06-17 18:55:34.808369	Itaque vero sit beatae.	Impedit est voluptatem et rerum at provident adipisci.	Ut reiciendis corporis. Occaecati nostrum odio et ea in. Est molestias id quasi cum explicabo qui. Magni minima aut asperiores temporibus dolor omnis nesciunt. Eveniet iure ut quia error quibusdam odit.	72418.00	6	15	closed
a7da0fa5-d717-49b6-8fef-2227deee4c07	9e638331-3e73-4fa0-9874-5cb990ba083d	2025-06-28 18:55:34.810529	Impedit quia aut rerum aliquid ut omnis est.	Et beatae ab tenetur consequatur assumenda ratione commodi.	Labore qui sed numquam non aut. Maiores fuga aspernatur enim est et. Earum nobis inventore neque qui. Exercitationem voluptatem vel hic vitae voluptatibus doloremque. Natus rem voluptatem.	56833.00	3	13	closed
e0234274-f15f-4f12-97a3-53ff683bff5d	67d7a03e-e366-4468-b507-d08fa20f8fba	2025-06-19 18:55:34.812883	Et ad reiciendis dolor qui blanditiis non esse.	Quo magnam ratione eos sit.	Atque ab rerum est et id non sint. Iusto ab iste velit eligendi in. Quia blanditiis dolorem ratione nobis ab libero.	33475.00	8	12	open
72e31b2d-aee8-4797-b876-1cea29d78f00	3cf10342-6164-494a-a84b-cf10d4dd9f38	2025-06-30 18:55:34.813948	Culpa quam rem dolor.	Ex et ab fuga numquam et ratione repellendus.	Nihil in id in molestias et. Autem architecto distinctio. Veniam labore impedit et ut aut natus architecto. Laboriosam sint et quaerat ipsa dicta ut.	56012.00	4	19	closed
\.


--
-- Data for Name: user_regions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_regions (user_id, region_code) FROM stdin;
5c33412a-38f7-4856-85c8-b9322c62fb4a	78
70ce0785-73a0-45a4-8d78-93ecba17cb9c	66
5e846192-3f8c-49f7-9906-4e4a0f3ef781	77
f3fa4ae9-2fec-439b-a043-ecdac59fbd09	23
f3fa4ae9-2fec-439b-a043-ecdac59fbd09	54
f3fa4ae9-2fec-439b-a043-ecdac59fbd09	24
50272aa6-b626-447b-afa3-2b1d7d15787a	78
50272aa6-b626-447b-afa3-2b1d7d15787a	50
43556e5a-c501-446c-b81d-59bf84dfe7ea	78
2bc7acc4-6bf9-4f53-860f-2a07de92e7f6	16
2bc7acc4-6bf9-4f53-860f-2a07de92e7f6	24
bc2f6dea-df57-4796-9f20-4a38eda07225	50
bc2f6dea-df57-4796-9f20-4a38eda07225	54
4bf92c1a-44eb-4161-bd36-dd3a2845a695	16
0a09a631-3f80-4aa3-96cb-2155f61a8323	24
0a09a631-3f80-4aa3-96cb-2155f61a8323	38
f16b102a-2bdc-4e39-8ccb-6544be128b7a	54
f16b102a-2bdc-4e39-8ccb-6544be128b7a	55
f16b102a-2bdc-4e39-8ccb-6544be128b7a	77
5ed43614-a394-456b-8cd1-f387037826de	16
5ed43614-a394-456b-8cd1-f387037826de	23
5ed43614-a394-456b-8cd1-f387037826de	78
57dc1fb3-c63f-487a-a348-9d43a58f7287	23
57dc1fb3-c63f-487a-a348-9d43a58f7287	24
57dc1fb3-c63f-487a-a348-9d43a58f7287	66
c21491b1-1794-487b-932e-9b4827ff8365	66
c21491b1-1794-487b-932e-9b4827ff8365	38
c21491b1-1794-487b-932e-9b4827ff8365	16
e831937b-abf5-4d9d-aacd-14d729a07054	55
e831937b-abf5-4d9d-aacd-14d729a07054	50
46d8b973-2d30-4392-a8f8-03e6fa1358b4	23
46d8b973-2d30-4392-a8f8-03e6fa1358b4	54
5af4786d-4f22-4b8a-b1b0-925a45a17693	23
5af4786d-4f22-4b8a-b1b0-925a45a17693	38
5f02884b-aa53-4ed8-8b74-29ca74ae8515	23
5f02884b-aa53-4ed8-8b74-29ca74ae8515	24
5f02884b-aa53-4ed8-8b74-29ca74ae8515	50
ffd449ba-4e53-4e11-8d02-40b2455581d5	23
ffd449ba-4e53-4e11-8d02-40b2455581d5	55
ffd449ba-4e53-4e11-8d02-40b2455581d5	66
4ee49614-d5ac-4747-ad7b-53e8d011c033	54
4ee49614-d5ac-4747-ad7b-53e8d011c033	66
4ee49614-d5ac-4747-ad7b-53e8d011c033	16
9cf2fbbe-7853-47d1-b8fd-b263f8da2dd1	16
d8e9d218-616e-4ff0-864a-23a6ab55da73	66
d8e9d218-616e-4ff0-864a-23a6ab55da73	50
d8e9d218-616e-4ff0-864a-23a6ab55da73	54
c132c2bf-c21e-4c2f-b9cc-36e978e76908	77
c132c2bf-c21e-4c2f-b9cc-36e978e76908	23
c132c2bf-c21e-4c2f-b9cc-36e978e76908	66
99026b27-e389-49de-a555-868e3529fdc5	55
99026b27-e389-49de-a555-868e3529fdc5	50
7448bdbd-8eaa-48e7-b00f-9d64c330571b	54
7448bdbd-8eaa-48e7-b00f-9d64c330571b	50
7448bdbd-8eaa-48e7-b00f-9d64c330571b	38
6add1836-558f-4d1a-929b-606db7b58de5	55
600fd83f-8f30-487f-97fc-b874c9c5039c	54
600fd83f-8f30-487f-97fc-b874c9c5039c	23
3dac66e8-03ab-4ef5-b8f5-e429736cd315	24
3dac66e8-03ab-4ef5-b8f5-e429736cd315	66
c578a4b3-d17f-4201-8469-310a5efc1126	55
77702d6b-f044-47f2-bf61-1eeabf8aaa9b	50
77702d6b-f044-47f2-bf61-1eeabf8aaa9b	55
77702d6b-f044-47f2-bf61-1eeabf8aaa9b	66
38cd8d9e-3491-40da-bc55-4c069b4047de	66
37e737cc-01e7-452a-b5db-4935de64eb5f	50
37e737cc-01e7-452a-b5db-4935de64eb5f	16
37e737cc-01e7-452a-b5db-4935de64eb5f	23
9900ea36-2ca1-4dd3-8dd3-d707b6a8fb0d	24
9900ea36-2ca1-4dd3-8dd3-d707b6a8fb0d	54
07978f14-8190-42e3-9999-b51480731a6d	23
25eb8322-21e4-4a89-a485-5e267d2bfef6	78
25eb8322-21e4-4a89-a485-5e267d2bfef6	16
25eb8322-21e4-4a89-a485-5e267d2bfef6	24
3b9df985-7065-4474-83d2-28b298404bf2	16
bba6ba0b-d8c7-4a28-ab8e-62b657a1ca94	38
bba6ba0b-d8c7-4a28-ab8e-62b657a1ca94	78
bba6ba0b-d8c7-4a28-ab8e-62b657a1ca94	16
55d8ac63-cabd-4b25-90c4-70d82759862f	50
8a50a51b-f6d3-4870-8a1a-ba5eb4d10b6f	55
8a50a51b-f6d3-4870-8a1a-ba5eb4d10b6f	66
2eb659ec-30a6-4d9b-a744-584290717a73	78
ddc4ecd3-9abd-49be-add0-1a919620fb35	38
7b9edadc-37ca-464d-9b06-51931dd2fc24	23
2b748d02-13e3-4c56-a774-fc1841027cfd	50
2b748d02-13e3-4c56-a774-fc1841027cfd	54
f97b4a83-f14f-4eb8-bfe9-232f3fef80f6	78
3162a5f9-37f3-41dd-aa21-3f5262bed586	24
ded722dc-9021-4324-ab92-62f0b056cebd	54
ded722dc-9021-4324-ab92-62f0b056cebd	16
9cb3d6af-e521-4a64-b95f-f69f17f377b2	38
9cb3d6af-e521-4a64-b95f-f69f17f377b2	54
55702c54-5b25-4f00-aea3-d61a0f43cc60	54
55702c54-5b25-4f00-aea3-d61a0f43cc60	16
88f7f35c-f5ad-4a41-b61d-e1cb92bbe610	77
88f7f35c-f5ad-4a41-b61d-e1cb92bbe610	23
928dd269-eb62-4f4a-992d-a3a8d0dd1d98	24
928dd269-eb62-4f4a-992d-a3a8d0dd1d98	16
928dd269-eb62-4f4a-992d-a3a8d0dd1d98	23
\.


--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_roles (user_id, role_code) FROM stdin;
5c33412a-38f7-4856-85c8-b9322c62fb4a	gencontractor
70ce0785-73a0-45a4-8d78-93ecba17cb9c	moderator
5e846192-3f8c-49f7-9906-4e4a0f3ef781	contractor
f3fa4ae9-2fec-439b-a043-ecdac59fbd09	contractor
50272aa6-b626-447b-afa3-2b1d7d15787a	subcontractor
43556e5a-c501-446c-b81d-59bf84dfe7ea	customer
2bc7acc4-6bf9-4f53-860f-2a07de92e7f6	admin
bc2f6dea-df57-4796-9f20-4a38eda07225	moderator
4bf92c1a-44eb-4161-bd36-dd3a2845a695	contractor
0a09a631-3f80-4aa3-96cb-2155f61a8323	admin
f16b102a-2bdc-4e39-8ccb-6544be128b7a	customer
5ed43614-a394-456b-8cd1-f387037826de	moderator
57dc1fb3-c63f-487a-a348-9d43a58f7287	subcontractor
c21491b1-1794-487b-932e-9b4827ff8365	customer
e831937b-abf5-4d9d-aacd-14d729a07054	contractor
46d8b973-2d30-4392-a8f8-03e6fa1358b4	contractor
5af4786d-4f22-4b8a-b1b0-925a45a17693	subcontractor
5f02884b-aa53-4ed8-8b74-29ca74ae8515	moderator
ffd449ba-4e53-4e11-8d02-40b2455581d5	moderator
4ee49614-d5ac-4747-ad7b-53e8d011c033	contractor
9cf2fbbe-7853-47d1-b8fd-b263f8da2dd1	gencontractor
d8e9d218-616e-4ff0-864a-23a6ab55da73	moderator
c132c2bf-c21e-4c2f-b9cc-36e978e76908	admin
99026b27-e389-49de-a555-868e3529fdc5	contractor
7448bdbd-8eaa-48e7-b00f-9d64c330571b	customer
6add1836-558f-4d1a-929b-606db7b58de5	admin
600fd83f-8f30-487f-97fc-b874c9c5039c	customer
3dac66e8-03ab-4ef5-b8f5-e429736cd315	subcontractor
c578a4b3-d17f-4201-8469-310a5efc1126	customer
77702d6b-f044-47f2-bf61-1eeabf8aaa9b	gencontractor
38cd8d9e-3491-40da-bc55-4c069b4047de	subcontractor
37e737cc-01e7-452a-b5db-4935de64eb5f	moderator
9900ea36-2ca1-4dd3-8dd3-d707b6a8fb0d	admin
07978f14-8190-42e3-9999-b51480731a6d	gencontractor
25eb8322-21e4-4a89-a485-5e267d2bfef6	gencontractor
3b9df985-7065-4474-83d2-28b298404bf2	moderator
bba6ba0b-d8c7-4a28-ab8e-62b657a1ca94	subcontractor
55d8ac63-cabd-4b25-90c4-70d82759862f	admin
8a50a51b-f6d3-4870-8a1a-ba5eb4d10b6f	contractor
2eb659ec-30a6-4d9b-a744-584290717a73	subcontractor
ddc4ecd3-9abd-49be-add0-1a919620fb35	subcontractor
7b9edadc-37ca-464d-9b06-51931dd2fc24	customer
2b748d02-13e3-4c56-a774-fc1841027cfd	contractor
f97b4a83-f14f-4eb8-bfe9-232f3fef80f6	customer
3162a5f9-37f3-41dd-aa21-3f5262bed586	admin
ded722dc-9021-4324-ab92-62f0b056cebd	moderator
9cb3d6af-e521-4a64-b95f-f69f17f377b2	moderator
55702c54-5b25-4f00-aea3-d61a0f43cc60	customer
88f7f35c-f5ad-4a41-b61d-e1cb92bbe610	contractor
928dd269-eb62-4f4a-992d-a3a8d0dd1d98	subcontractor
\.


--
-- Data for Name: user_specializations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_specializations (user_id, spec_code) FROM stdin;
5c33412a-38f7-4856-85c8-b9322c62fb4a	spec03
5c33412a-38f7-4856-85c8-b9322c62fb4a	spec06
70ce0785-73a0-45a4-8d78-93ecba17cb9c	spec01
70ce0785-73a0-45a4-8d78-93ecba17cb9c	spec02
5e846192-3f8c-49f7-9906-4e4a0f3ef781	spec02
5e846192-3f8c-49f7-9906-4e4a0f3ef781	spec06
f3fa4ae9-2fec-439b-a043-ecdac59fbd09	spec05
f3fa4ae9-2fec-439b-a043-ecdac59fbd09	spec01
f3fa4ae9-2fec-439b-a043-ecdac59fbd09	spec02
50272aa6-b626-447b-afa3-2b1d7d15787a	spec01
50272aa6-b626-447b-afa3-2b1d7d15787a	spec02
43556e5a-c501-446c-b81d-59bf84dfe7ea	spec05
2bc7acc4-6bf9-4f53-860f-2a07de92e7f6	spec04
bc2f6dea-df57-4796-9f20-4a38eda07225	spec03
4bf92c1a-44eb-4161-bd36-dd3a2845a695	spec03
4bf92c1a-44eb-4161-bd36-dd3a2845a695	spec06
0a09a631-3f80-4aa3-96cb-2155f61a8323	spec04
f16b102a-2bdc-4e39-8ccb-6544be128b7a	spec04
5ed43614-a394-456b-8cd1-f387037826de	spec02
57dc1fb3-c63f-487a-a348-9d43a58f7287	spec06
c21491b1-1794-487b-932e-9b4827ff8365	spec01
c21491b1-1794-487b-932e-9b4827ff8365	spec02
c21491b1-1794-487b-932e-9b4827ff8365	spec04
e831937b-abf5-4d9d-aacd-14d729a07054	spec03
46d8b973-2d30-4392-a8f8-03e6fa1358b4	spec02
46d8b973-2d30-4392-a8f8-03e6fa1358b4	spec04
5af4786d-4f22-4b8a-b1b0-925a45a17693	spec04
5af4786d-4f22-4b8a-b1b0-925a45a17693	spec06
5af4786d-4f22-4b8a-b1b0-925a45a17693	spec02
5f02884b-aa53-4ed8-8b74-29ca74ae8515	spec05
ffd449ba-4e53-4e11-8d02-40b2455581d5	spec02
ffd449ba-4e53-4e11-8d02-40b2455581d5	spec01
4ee49614-d5ac-4747-ad7b-53e8d011c033	spec02
9cf2fbbe-7853-47d1-b8fd-b263f8da2dd1	spec01
9cf2fbbe-7853-47d1-b8fd-b263f8da2dd1	spec05
d8e9d218-616e-4ff0-864a-23a6ab55da73	spec05
d8e9d218-616e-4ff0-864a-23a6ab55da73	spec03
c132c2bf-c21e-4c2f-b9cc-36e978e76908	spec01
c132c2bf-c21e-4c2f-b9cc-36e978e76908	spec06
99026b27-e389-49de-a555-868e3529fdc5	spec06
99026b27-e389-49de-a555-868e3529fdc5	spec05
99026b27-e389-49de-a555-868e3529fdc5	spec04
7448bdbd-8eaa-48e7-b00f-9d64c330571b	spec05
7448bdbd-8eaa-48e7-b00f-9d64c330571b	spec03
6add1836-558f-4d1a-929b-606db7b58de5	spec02
6add1836-558f-4d1a-929b-606db7b58de5	spec01
600fd83f-8f30-487f-97fc-b874c9c5039c	spec01
3dac66e8-03ab-4ef5-b8f5-e429736cd315	spec06
3dac66e8-03ab-4ef5-b8f5-e429736cd315	spec05
3dac66e8-03ab-4ef5-b8f5-e429736cd315	spec02
c578a4b3-d17f-4201-8469-310a5efc1126	spec02
77702d6b-f044-47f2-bf61-1eeabf8aaa9b	spec05
77702d6b-f044-47f2-bf61-1eeabf8aaa9b	spec03
38cd8d9e-3491-40da-bc55-4c069b4047de	spec02
37e737cc-01e7-452a-b5db-4935de64eb5f	spec01
9900ea36-2ca1-4dd3-8dd3-d707b6a8fb0d	spec05
9900ea36-2ca1-4dd3-8dd3-d707b6a8fb0d	spec01
9900ea36-2ca1-4dd3-8dd3-d707b6a8fb0d	spec03
07978f14-8190-42e3-9999-b51480731a6d	spec04
07978f14-8190-42e3-9999-b51480731a6d	spec05
25eb8322-21e4-4a89-a485-5e267d2bfef6	spec01
25eb8322-21e4-4a89-a485-5e267d2bfef6	spec02
25eb8322-21e4-4a89-a485-5e267d2bfef6	spec03
3b9df985-7065-4474-83d2-28b298404bf2	spec04
3b9df985-7065-4474-83d2-28b298404bf2	spec01
bba6ba0b-d8c7-4a28-ab8e-62b657a1ca94	spec04
55d8ac63-cabd-4b25-90c4-70d82759862f	spec03
55d8ac63-cabd-4b25-90c4-70d82759862f	spec01
55d8ac63-cabd-4b25-90c4-70d82759862f	spec05
8a50a51b-f6d3-4870-8a1a-ba5eb4d10b6f	spec01
2eb659ec-30a6-4d9b-a744-584290717a73	spec02
2eb659ec-30a6-4d9b-a744-584290717a73	spec03
2eb659ec-30a6-4d9b-a744-584290717a73	spec05
ddc4ecd3-9abd-49be-add0-1a919620fb35	spec04
ddc4ecd3-9abd-49be-add0-1a919620fb35	spec01
7b9edadc-37ca-464d-9b06-51931dd2fc24	spec05
7b9edadc-37ca-464d-9b06-51931dd2fc24	spec06
2b748d02-13e3-4c56-a774-fc1841027cfd	spec03
2b748d02-13e3-4c56-a774-fc1841027cfd	spec02
2b748d02-13e3-4c56-a774-fc1841027cfd	spec06
f97b4a83-f14f-4eb8-bfe9-232f3fef80f6	spec06
f97b4a83-f14f-4eb8-bfe9-232f3fef80f6	spec05
3162a5f9-37f3-41dd-aa21-3f5262bed586	spec04
3162a5f9-37f3-41dd-aa21-3f5262bed586	spec02
ded722dc-9021-4324-ab92-62f0b056cebd	spec01
ded722dc-9021-4324-ab92-62f0b056cebd	spec04
ded722dc-9021-4324-ab92-62f0b056cebd	spec05
9cb3d6af-e521-4a64-b95f-f69f17f377b2	spec03
9cb3d6af-e521-4a64-b95f-f69f17f377b2	spec02
9cb3d6af-e521-4a64-b95f-f69f17f377b2	spec06
55702c54-5b25-4f00-aea3-d61a0f43cc60	spec01
88f7f35c-f5ad-4a41-b61d-e1cb92bbe610	spec04
88f7f35c-f5ad-4a41-b61d-e1cb92bbe610	spec03
928dd269-eb62-4f4a-992d-a3a8d0dd1d98	spec04
928dd269-eb62-4f4a-992d-a3a8d0dd1d98	spec01
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, password_hash, full_name, contact_phone) FROM stdin;
5c33412a-38f7-4856-85c8-b9322c62fb4a	thi.mcclure@gmail.com	6692b78defdac1adc58cc8ba088502d8f2008b1552fa96ebbfbb301f04446966	Guillermo Murphy	88472843987
70ce0785-73a0-45a4-8d78-93ecba17cb9c	corey.homenick@hotmail.com	cb92867008f8dca3e1e39590a9bb5bcd269059e3b04066a0e3c3ec8cd014dd22	Mrs. Randy Runte	31484921845
5e846192-3f8c-49f7-9906-4e4a0f3ef781	ariel.kunze@hotmail.com	bb5662a2f202cacbc47dfa648d72572b61700678facb45caffb20df1489a7863	Christiane Kutch	23356582894
f3fa4ae9-2fec-439b-a043-ecdac59fbd09	ronald.kris@gmail.com	ee65bfd62878d5939641e84d39d5ee175bcc6171780a3d209f9510250d8ccc6e	Norah Jenkins	90825754258
50272aa6-b626-447b-afa3-2b1d7d15787a	murray.barrows@hotmail.com	ca7d507347500f880fcac3a7d91dbda4d1b2f5beefd7456f879b4984cbec31ac	Ned Skiles	54241983973
43556e5a-c501-446c-b81d-59bf84dfe7ea	lilian.moen@hotmail.com	7ceb9ddcd098a9b80dac21aed860405778d2dcafd46eb5b86088ccf449033653	Mirella Bailey	81347666241
2bc7acc4-6bf9-4f53-860f-2a07de92e7f6	jessi.dickinson@yahoo.com	14fd52c6ac6ff305f705fd714eb97fbc88e7451cd096666727f65f5a0d6d288d	Shawanna Bosco I	05187990619
bc2f6dea-df57-4796-9f20-4a38eda07225	lorna.ziemann@gmail.com	d1d2e90266b245c13f1b7ede4d38fcb5fb24964c164f8d126ec8d8aaa8667b4f	Lyndsey Hermann	73008166746
4bf92c1a-44eb-4161-bd36-dd3a2845a695	walter.oconnell@hotmail.com	fa2853ab7f3fff5aee515712bf4aefe1d49e7da15e769a0e998db8698c58ceb8	Roland Grant	18315395715
0a09a631-3f80-4aa3-96cb-2155f61a8323	lakeisha.casper@gmail.com	63376a9d33c143514e307f7ebbba6add758e5f9978e4ef4b0b18a5d4cc7a7b4	Lissette Gleichner	95623581261
f16b102a-2bdc-4e39-8ccb-6544be128b7a	douglas.crooks@gmail.com	66c36be8e3d912f9e61386c65255ed26bfa3418be29c2c81595c6a0e82a95e0	Jimmie Hessel	08350470146
5ed43614-a394-456b-8cd1-f387037826de	reyes.abernathy@yahoo.com	926d3669a8dd54acba3314168bf839578b4b434e21b6898346c0bd421459a53e	Shad Schmitt	11603622534
57dc1fb3-c63f-487a-a348-9d43a58f7287	shawnda.dubuque@yahoo.com	e6a0c1fd57c8edd2e00530ed7a7e94d09e03b0525ceba9c10184534544b52ec8	Hiram Veum	11385481289
c21491b1-1794-487b-932e-9b4827ff8365	elisha.brakus@yahoo.com	ea5adcde65fe0a7a12f06fbe2c28844724d1386f85de1fd66b1ab94b4bc6a3c6	Andre Dooley	08732341900
e831937b-abf5-4d9d-aacd-14d729a07054	petra.oconner@yahoo.com	b3d6860716fc6f853667cc93294dd76a52e59751d411f37e6c86f87b521f38bc	Miguel Johnson	25624902371
46d8b973-2d30-4392-a8f8-03e6fa1358b4	daisey.romaguera@yahoo.com	70caf77816263e4b331401084559e6bb35c1138e55634348925cf266e454b0d6	Ms. Kristopher Ward	11935975679
5af4786d-4f22-4b8a-b1b0-925a45a17693	jon.pollich@hotmail.com	fe965ca1595d680536d3c01a43fb7212e9172b682d9c13cdc727acc51be989f9	Ms. Diane Jacobson	28124700406
5f02884b-aa53-4ed8-8b74-29ca74ae8515	barrett.bergnaum@yahoo.com	2626a66bdcb15b465ebe4a3eb40a47cb3ef641cd54d60c24712ee1bfb28045cf	Arleen Hilll	15637629611
ffd449ba-4e53-4e11-8d02-40b2455581d5	belkis.cruickshank@gmail.com	b331a7583e68553df8e2d7d4e7b7f5c382c9d381694249efd2b5050358b0065	Sean Quigley	64640199021
4ee49614-d5ac-4747-ad7b-53e8d011c033	emmaline.gleichner@hotmail.com	5d88ba05fa66222d5ecc931e88b9cf695d3d67dfe010536fced6ab153f4227ca	Lavonne Towne	47178501950
9cf2fbbe-7853-47d1-b8fd-b263f8da2dd1	lupita.carroll@gmail.com	f8752012a36fcdefe3f4e105918a34da351d32c06c87ed5452052a5de67cf9a	Stanford Gutmann	12146904105
d8e9d218-616e-4ff0-864a-23a6ab55da73	milda.bednar@yahoo.com	a818531e954b50ec16e406d32c33f09b78c925cb822499dc2c9e1717dc501011	William Muller	62255796406
c132c2bf-c21e-4c2f-b9cc-36e978e76908	ali.mueller@gmail.com	1b3549febb475758af8b810d06ac4afe062e8e27bd08e427a603f309fbf8d4ff	Dennise Rohan	57340627112
99026b27-e389-49de-a555-868e3529fdc5	ariel.schneider@gmail.com	7733b5eb023dcd91b6ea89f9e9a02d743553e6121580840fefe488e2b8964185	Garfield Oberbrunner	23574687006
7448bdbd-8eaa-48e7-b00f-9d64c330571b	chadwick.tromp@yahoo.com	8e0ce0090431cf65e556707bdb593e495c21cf51aaa9626f3d57ad3bdd6f58cf	Marna Armstrong II	51021457762
6add1836-558f-4d1a-929b-606db7b58de5	arletta.kuvalis@yahoo.com	e124f25239c1a48410005affa90bf61f4296448baf66a4ec761b1b64e53cde18	Mr. Mike Koelpin	35666559325
600fd83f-8f30-487f-97fc-b874c9c5039c	deidra.stroman@yahoo.com	f67607fc21f42c6e30c3b4031c8f760c804225739b8c5e83a53d0905f4e89bd4	Dr. Genna Russel	92365996324
3dac66e8-03ab-4ef5-b8f5-e429736cd315	wilber.wolf@hotmail.com	53cc69fa6e7c1cd3cbdffab29be22912d9b6a28507c2d544d94a29b6328207ad	Kip Abbott III	17514384885
c578a4b3-d17f-4201-8469-310a5efc1126	wes.hettinger@yahoo.com	3bf5f64f5717fce4a5af36be20d765bd1ff795717a07eb873535a28999adb4c1	Lucien DuBuque	95583854179
77702d6b-f044-47f2-bf61-1eeabf8aaa9b	bethel.buckridge@hotmail.com	72829b81beb9afd93513d1a57690f0e36f5639fd9bc9cc093a671ae9e70a08d9	Valeria Towne	82458345525
38cd8d9e-3491-40da-bc55-4c069b4047de	juan.keebler@gmail.com	287d4f0e5d3557e813d824bed811edd4675bd6f87b9f4b75134339f491e877ff	Dr. Cesar Bednar	14953226870
37e737cc-01e7-452a-b5db-4935de64eb5f	florinda.tromp@hotmail.com	329057aa2cb317cde4560b202746b41d4e81028fd47f394be3e80f8fdfc47878	Dr. Carolyn Jones	68677361263
9900ea36-2ca1-4dd3-8dd3-d707b6a8fb0d	reyna.dietrich@gmail.com	87bdd4a32a097f37cd45505e6da5d8b5f46a1589f23c0d4340c28dc7c64ccb5f	Virgil Torp	15916157156
07978f14-8190-42e3-9999-b51480731a6d	thi.cormier@gmail.com	ac94b8f930f9b87ea4bb87d38132e08a2cb1a4c3d866aa452219f6703168aba5	Shizue Streich	79969797525
25eb8322-21e4-4a89-a485-5e267d2bfef6	agnes.kulas@yahoo.com	69ade432f4e9480e049f7e944bd56dbcb6e219915d8a8d59ddacc4293b675883	Denis Dicki V	68857150412
3b9df985-7065-4474-83d2-28b298404bf2	hunter.jaskolski@hotmail.com	beafca64912923bc8364092922fb057a72857f06d0159c7ac76d37bda9d4840f	Sammie Schmitt	45562931318
bba6ba0b-d8c7-4a28-ab8e-62b657a1ca94	chin.christiansen@yahoo.com	b2bf985790d3cf37860b54f90ef2b77c2410c207ab3e490ba3727a894f386204	Quinn Ebert	53064955721
55d8ac63-cabd-4b25-90c4-70d82759862f	sophie.kassulke@gmail.com	cabef09ac3d5f8ae91e75dec518f4ef6f5adbcdedfe3ed4041f5ce304c2f4450	Luigi Reichel	60909755266
8a50a51b-f6d3-4870-8a1a-ba5eb4d10b6f	arnoldo.mann@yahoo.com	52bfd5e1004619fa326c0f828c996bda42380d13560064b6e6902b3cecf36961	Claretta Hirthe	15343265137
2eb659ec-30a6-4d9b-a744-584290717a73	gerry.dietrich@hotmail.com	4b8ed0de25c842dc43ea2610056aa12fd65b577df4b63d5fc455e2d96787189a	Trish Weber	16309809682
ddc4ecd3-9abd-49be-add0-1a919620fb35	chanel.oberbrunner@gmail.com	4d542a9ecddbeab086a2d6a6daa95964e6e6dbc915ed7cfc7a875e2313d3f4fe	Terresa Corkery	47463174424
7b9edadc-37ca-464d-9b06-51931dd2fc24	kylie.cartwright@yahoo.com	78522b879d8326e2663b317be81d7dc3970b0097f329fea87b64ce3b9cbd5b8	Jake Schoen	51347011929
2b748d02-13e3-4c56-a774-fc1841027cfd	jetta.nolan@yahoo.com	fe99bfeb0461717b35039f1c362712df7e1252eed657d0e201b464e8a12c70ce	Boris Wisozk	47930753474
f97b4a83-f14f-4eb8-bfe9-232f3fef80f6	taylor.lehner@yahoo.com	c3e089a5e5dfe5b5547ecf34c9f1fdd3b9387b361b4be2e38375b43f6326637b	Demetrius Shanahan	43228147891
3162a5f9-37f3-41dd-aa21-3f5262bed586	michel.emmerich@yahoo.com	834a80329845c898747985999ed8a8f9c08944e3239092ed9d2e2fae523b6da5	Carl Hansen	59133147817
ded722dc-9021-4324-ab92-62f0b056cebd	lynsey.wilderman@gmail.com	eaadf3fdaf82f1b4737b8215cb92269c81b5933fcb2087c30d25fd0790bc1d2	Mrs. Kit Rohan	67699480446
9cb3d6af-e521-4a64-b95f-f69f17f377b2	michaela.schuster@gmail.com	f9f38c61c2a07c2b2926f431a62ef06fc4ccac9c8a8f785ede43fc9fe83f4d42	Neida Crist	71831749860
55702c54-5b25-4f00-aea3-d61a0f43cc60	ivan.mann@yahoo.com	a51af039b205ffd26952ae69d4febc2a0b84f17a313688a52986fb9c4e59b479	Adele Okuneva	86371098219
88f7f35c-f5ad-4a41-b61d-e1cb92bbe610	berta.grady@hotmail.com	d8d4e30d34c805a22a0da77924e1280cac346379e04103853620065242acb1e9	Lina Pouros	10956407103
928dd269-eb62-4f4a-992d-a3a8d0dd1d98	otto.marvin@hotmail.com	78c57ba35bcad046c731464d5ad93c7ce58881724c6043a697b6358f15b91a7c	Mrs. Venus Harvey	21285630820
\.


--
-- Data for Name: verification_documents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.verification_documents (id, profile_id, verification_status_code, document_type, document_url, uploaded_at, verification_comment) FROM stdin;
50bc199e-f87e-4b4a-b2f5-e797edf8eedb	fda73321-e721-4560-80b8-b062c5090883	pending	license	www.penny-wyman.org	2025-06-04 18:55:34.700302	uktp6v991oonoub5nms1whf3diqb2y6fkaud51nt7zzvctvc8e0k74p3rtf0zlb0m9o7xdumfzjm30p1xl5b2vyiabjj4qjxl87w7oxl54odvfo04i57o719h56fagv7xsd4quqldjm33ie56t
ea86f707-e16d-4bb9-90ac-53b57e802600	9bcc795d-4d12-45f0-a592-77f24671ab64	pending	other	www.abram-rogahn.name	2025-06-04 18:55:34.700302	jrq44s0i4fgoenvnt4bq1ld187vgkbmp4iiugfyym1w8r6fhbop2n98ip8jf600o45yb1erlwkhv3ih0v24p8he4lvtk4k0v74dr4mdoytabpsvvjyg822
8a3da406-44cb-48cc-800f-9719d817e2c7	9bcc795d-4d12-45f0-a592-77f24671ab64	failed	other	www.antonia-ferry.io	2025-06-04 18:55:34.700302	r0gdthnoz4m1fkegrefk0ghmx6an3i3ld7oq13xuue7mxnhy32v7djhhn7x17kcr58a1ojofwugusdkkokdlrr32i32b4dzfjtdsavvotvyg281fkltvtggw32qi
06d761e2-19d5-4b04-927f-3ad1ac2107d3	2949b03e-6239-4fd4-a61f-b34fb973f132	pending	passport	www.jennie-ward.org	2025-06-04 18:55:34.700302	jn0eea46e1zw7ia6hab5ie3k28wtvbrnpwtu4xkmbw9le9qbzlqtlr8oh59sak68s9nc2kblu70z55mp0pke1hu8swvtv4k7kya1yn906fl0tpqfzfpkzqmemixsaeg5wy6camze7wxdkbn5pjwel0j5kmvob02l1ifzs987vduy42c0q03ytdqdml8mu1z371cgy0xf33tqceaaiedmi4taffqukhr39zjcc41zmly38i42k6d780rd
d09e12c6-0fd2-45e2-939c-1ecc51556e29	2949b03e-6239-4fd4-a61f-b34fb973f132	failed	license	www.wendolyn-waters.io	2025-06-04 18:55:34.700302	rka4m2vsr5uqkg3ks6p9zh94ntdkpko9lgbgrjdbagscnxfg79h46nbk4yb5ap1xebukl0t2pe2ofo29rw5izoemjbllqzcnekg1aa4vtkml3oyhsg9b5sehv69wgwtvd7c36hi0g5i40zdaqwhz9b71mafvg
9fb98b70-6433-42fe-89ff-be9aad8aa3cf	5d4185c7-bec1-4af1-97e3-0df252431772	passed	registration_certificate	www.charleen-ondricka.co	2025-06-04 18:55:34.700302	m12hv439allj8zpxupad5arcxe81siwtik5a2vftwf3tr8he3i0afsmzt55e21kwh0kodm2oirul21qbtpp6rzn86b5zuh792s37qj1ncw1443k5u7ulygyeolw7cctsp1ham8hpgc8wmsrjcwq2vabtgvpb0aamf6ifk8834kgh8artm3qvtpyul
131eec93-3e40-436a-abc7-90d05328c51d	cefd3d85-4f2d-43a6-bc56-f848d4f794ef	pending	registration_certificate	www.malorie-beatty.org	2025-06-04 18:55:34.700302	uun1z42b08nbhxe0cghtxqjdbo35w4oua9pokjmt0o9vervevbcyx86iqz6lw05yga9jc6dmfkrdsmpcqvjtyt60roz9kog0lxcfcyf7vr44qsir63antir4qr5l20ko1zlon3fum6cucvnxf06khhogsagg28iixcwy2hqdeof0gpjs6tyb7qeizc14pkiury2goswbuly13ck31ue9vj510qnmb3coofuj2o18y
8b8a2b0d-7500-4fe1-bcc4-2b2733d78b53	cefd3d85-4f2d-43a6-bc56-f848d4f794ef	pending	license	www.stevie-glover.info	2025-06-04 18:55:34.700302	syx0a2kfl9vey17fohhz0ifwl0xy53xssdfqf5rm6r1gv7pah8gp86w6rn9u2w6104hl8jrfvdw24pv2og7tjz0kx25da7c03zxsxg88xd5jbae9db0o0k04p4l3hgulrv9fnb83stx48fcskld5zzbgg415rit3y3bv99s94vujhw1n804ox1mhxkxqtatg57577yiq82mw88867tfi0xpv9wh3645mnfl8tp6ixvry04qpzl4my53qh
3ad7e430-0ac5-4741-868c-6aba51038aad	6d8ad48b-3ee4-4d10-bce3-192b94b54b00	pending	registration_certificate	www.goldie-murazik.io	2025-06-04 18:55:34.700302	tj2bmtwfkdb831lsacx3x1rlgqzvhm6cat4bvizz6r2uo1wn17of121f2jj4hp9roxis20azz06ysvgerqipz2q9ipb8dr3bevkoeeyk9w2vpbt5b8lthspkmztbldcddvtp6hylciztl08v1va
32bdb6e7-1bcb-4345-a393-b201b04db8ce	6d8ad48b-3ee4-4d10-bce3-192b94b54b00	passed	license	www.denise-schmeler.biz	2025-06-04 18:55:34.700302	mrq55eplwd3q0s6o9g1s7a4pq1942jr3pb269alu4lgnbb2azc49me5bt7dbpkxg0pguqusl0v597n367kcy0zfcjtr4n89xen6qmmjqtai
3338ce6b-85ab-4a70-89d7-26a408853e53	75c21222-cce6-4d68-8967-2f22c594a6b1	failed	license	www.ambrose-grimes.biz	2025-06-04 18:55:34.700302	dyc1k9zhwv87n6gn4u65m0wciouw24trsjtw65k67dt0nedy9ip3f6lwc72e5xrg5bndprqutfhz65gt6ffsrk6i6g2clrgnv21b752m5l7t0idhb17oj9u1p06aep7hbwxbfx6hgzm19xd1bsy3otk6tla0o7t1otp3lzw1hgvmt3r7agtechfgt01ybec02wa1pe0jxqeetozppc
ed33dc37-058e-4b0a-9c6c-2a38d6336e77	75c21222-cce6-4d68-8967-2f22c594a6b1	passed	passport	www.debi-fay.name	2025-06-04 18:55:34.700302	kh989zpuynzobv6o2nbu1jz2702t09712203so0iitc6brku445p1oozyawrcq9pa0du724xl0hxg1r1irip3osaavodz2igrez5mtg9ft4ezloyrh3b0ryj3t419nr3u40jdm9tzfmuu32099gqzhy7slprz7nh20q9s7qh2vfc2sprhklcsjp5yx3t3ceaornj
9ec3a533-7c06-4b2e-8219-4f0ee1cabceb	2a1753fe-265a-43a2-a791-580a19693ace	failed	license	www.gus-schneider.net	2025-06-04 18:55:34.700302	pfbkqib6iirbf6pgte9rh1qksxt79yj8ce2jekxumnkkuq47o68aukqug9azhckrcgmrwb7awbrbt44nb36kyadlqff7qbx92deg4gc1lwv1y88oho3prvvijr43d671eokejjt4hga97btljr
8ab98116-7c78-4bdf-b127-6fe15038d09a	2a1753fe-265a-43a2-a791-580a19693ace	passed	other	www.demetria-runolfsdottir.info	2025-06-04 18:55:34.700302	8uptnkm5gzfyefb0jr9aiac5f5i55t3i091lc9mcmpsm6tsgdchkuhwfxi3ecqneqw7mo2euyal546jlbvhwleqbcuwpibu5d4z651ztx3gyfs7wl
f235923d-2f2d-4b22-9623-0a2dfae8fb26	ae22c8fd-4347-4b8e-be79-53718a01c39a	failed	other	www.clifton-torp.biz	2025-06-04 18:55:34.700302	j1462kzf40ycoaikkkz3a8vl4bnd90ru6iod5pr85udx49bxacfnraobf5cftd49n9516tilu3xr9pgr0bi6zdjk3fk59c33fjbbectznw3tokmh6jjhihyi9z5x9t4vlqxh8iq4fgb8xzjtlcc30l7f085blbjj5ot7rzb96bcb9yp64w36cnhtk68s8gkicos4ra7axdj32t7vclcuk1o26hkf4643yj99vkyrbn8j4
7b0ed987-8c39-48f0-9d45-3e7d9db9dfd6	0cd37e88-6dcc-4359-b195-3a25d9895663	passed	registration_certificate	www.luigi-wintheiser.info	2025-06-04 18:55:34.700302	sk7go99ezdf5hsxvyphhsggomr1pnmg3z84n9m2wx2mvl0w33dfs6hdcup4bdfl5dt0wwsc4791ar3koqwib2npkgihhod3r5vcl3h041ewnftzf8beoy8xy7lzq2kkxjvujwo5urezadm458dgcppgdwgk3p46kdljeqd7u05ajdq
7df687d7-bdc2-4895-8293-ddb3de41d6e0	0cd37e88-6dcc-4359-b195-3a25d9895663	passed	passport	www.cameron-pfeffer.name	2025-06-04 18:55:34.700302	nfzneejils95vlc3idcrm1619k5u85ok8w8hnffmlv3s2s1lmh0gkmyohhvzt3xsk8p6qpbc2uqjx9vv37rize42fbo6stedfgjfmswwyimv5lfg9h0yvyxd3w43p8yvh68nwhian9zz18wjktnbt9o35nnnl0ptawyqu0822lpblhvasasa0oei0h912w4h
1ec717b4-3f76-4bb2-91e1-34a9ea8602ed	2dec1f5c-08bd-4048-91ad-057147189e4b	pending	registration_certificate	www.pura-herman.info	2025-06-04 18:55:34.700302	1zoexk4xyz3c47a4fuotcy2n5v50xdk3v2oud8ue850pzkgxu96o2vhdul6dpn1zzxxtpy3jekbnkcvok3452i328jsgzcb20pdkeotlmt9hpx78ey2zk0upnof3pav87amn6fgak4qhso5tv1c4s5xy3x78p4v
0b3d9eb0-7415-4883-8e88-65f0a8e2db4a	996fe158-61f3-48b0-a31f-05c472524c62	passed	license	www.bryant-hyatt.io	2025-06-04 18:55:34.700302	n8rgm421gx04sqqm6m1tj1cs1xryyxj4st6i2thep8d8llr9y98j0xy30npejbeuwf6d4keofyn96b1jtombpwhp2x4houb4qr2fqhzempu0246up5ie734tov1k4qum73zv1n3uemj3pfw8suw6uppoow26d5fwc5sag29e42d4lp9nhtxtufenwe73k295ujltxo6njr5r
1638f989-d603-4187-9c88-99d6adff6b2a	996fe158-61f3-48b0-a31f-05c472524c62	pending	other	www.wilford-kilback.co	2025-06-04 18:55:34.700302	8svmx4v3027crym87bl1qrk3uayvsfmid56668z5mqvighjufxp0rizwoo7t5069eh88a09agwuqips0hwml042yfwt3h5cfd78qi9a6660753ku4bf98xud95h57q0jkg2xubimss6iwgcwbyooc9z2ogleo
c7fe82e3-c18a-4591-9552-a40f699aa85e	48ba213c-aab9-4494-9a67-6e915ceb1678	failed	passport	www.cyrus-dickinson.com	2025-06-04 18:55:34.700302	n455dk2drz0mgfoqxprvls6gvz3bl1atakj1iuk9vpgughiuu5vpraatighsyfa9vxmyrjb5ahg80worwnsueujs3kmg9wlz6yz36vxwh7mgvr8sugr9q0311o1x2ub0cssa8ebyn6numa559w487ulywr6503of0vhlcdxgcbmhpivzr7m1k
a38b5e92-c0a2-4735-ab57-0379b621ce4c	ad2e6944-7b0c-47b7-b442-b61bdbd75933	passed	other	www.lashaunda-sanford.co	2025-06-04 18:55:34.700302	ut12rp725ds23dtqwfs1i2y0h5f2a2yahljvm5ja5byrmic6kvixuw64msuoi0loqdz64ranlxjv0uwcjg5t3r9alat3gz1btt4f1wvwwgyym6mnozjplnl31zmn8krgs5wj5bfqi01gt84l1hopobtjr778qu12sx59wtolccitf7kv6sa18ntl2i6jqh1vzsg0exwc5mm
9ba7cce0-b587-4ea4-a592-8206efc1ad87	1aa256a2-6261-47c7-bf21-6456747e4ba7	pending	passport	www.tyree-kuhic.info	2025-06-04 18:55:34.700302	kpjh5gam30pq8i3oxotijzj4y1l6w602jspib93a94kb455p1v7y4gzsj8boz6nei9er668t5ctpq0t18709zjepjhz6du57xby32ciyemica6mxqyyhpd73zmmowlyj54397fjx9zkockhsdx60a1ju6wsgewznynvemtqcdrvdc85fssvdq78lgrdndur2jj3ftc4df3r0qu6i9rb0ak0dunxygcymdur5dgaobpvca8op82
e70a6d4b-01e6-4c9e-8086-e531af4d1d9c	707a452d-939c-4a48-ae87-5848c2a1c63e	failed	registration_certificate	www.bryce-klein.org	2025-06-04 18:55:34.700302	1wwfoa50kbe72289jsp8okocjqtfwxprztekglpybyoyot0xcyx2y5qww7vkd692cyp8cwpb4t01q0dwbikhd7pz2em315f7rfp3gu8rvh68shmge8axin5qnv8363ciu
62f60187-17da-448a-a552-ee136bdaf967	707a452d-939c-4a48-ae87-5848c2a1c63e	pending	license	www.vikki-johnston.com	2025-06-04 18:55:34.700302	3zch2fie00jry9ntvbssb9ul80qyf4841aee4u5xa4a4ua2iqt82ld8dtwm51rgfag18ocrswpkyc82kzsgrnvht9yv7gpkezhn25mmprexd9r2159gz1u70czp9dunlvuqsd0piqnx3te93xevhrgjpxu8beddsfibzu6gpqsj18ncklquy5ruqovbcgrrz6d1jyb7guegii8suwm9tb8b5au2g387id89jbsn5yso
f93c4ef3-c258-49c2-ade3-d2ef6d65ad5f	a2ee3c19-8717-48c4-9f8a-2a706c2407d2	passed	license	www.yetta-jacobson.io	2025-06-04 18:55:34.700302	3k37lyegy8vgn8fxyanryh673ui3zg010rh4a3ru8g4kbylc4bygjyqasl7c2vc63rry8h2j52hj94zfwfv2ivehyvien8l5j48gdhjmxy8qso4mobaofvmqcfgu447dszlsz7zhetjc3elqwaijyrqw2edwf230bnyewm9fn6uuvkkhzwo2vr2rt617qt3xfhqnt7x89tf7xorw1qrmtffztezjnsxrcn2zam7o27g43k0fjupyq
308c5b18-3dc1-430d-8a86-b3566f6cd5e7	a2ee3c19-8717-48c4-9f8a-2a706c2407d2	pending	license	www.somer-damore.name	2025-06-04 18:55:34.700302	k9vw0c7jq9z7jvq31kmeh7sz8jcqoeoy3lqpgrftxmkyxtf5cseatuo6w119t5xb1mkatw5bwh5amibprjfuodwlufj0e1yg6htpvv43a7i9oam4amhw7xsqq5zqj2nu1l1kich4xr259lv9utrhscyc0wpd
e8ff6f5c-05f1-4ab9-8520-934916efc267	20eab0fe-4e3c-420d-a79d-62a8a2de1447	failed	passport	www.garret-bechtelar.biz	2025-06-04 18:55:34.700302	zjwfv36y9768nmwjzvpd04czkdn2f71omll54yu0nrqxgsa9of4xregkcj14j93grxq77vjtr3b1kxyb9tt8z37e4nay8426lp1c0xtelsrm
efc2755c-2b9f-411a-8cb2-a05b4327b5bb	e8d66249-846f-46f0-8a3d-4ed4491a97a6	failed	license	www.heath-bednar.net	2025-06-04 18:55:34.700302	fpm6vlbh0wg6k9mpnolb4weesf660seuqovyrjsbo1qivkuqo03cp5jh06kbkjyuj6f6as4xuupeb3gdc4v7gfancj3fx8fx4f75lc10x7vjcrkajmbs4bik0h6a
5197e4c6-5378-4d31-a8f9-59e49b5be2a2	e8d66249-846f-46f0-8a3d-4ed4491a97a6	failed	other	www.jenee-brekke.org	2025-06-04 18:55:34.700302	6a9bvgricqphb8otcl8979779upo1ey4w8lkesr6kg5y7u7if49zdwk7fsy5ltw8p9w1ouvnl3lk3i4av4474esnmhy9r8d9hd8l1a0ip3zi8qr47dxxtwbaov6vfp2e7s8tm7
1af20c4d-dad8-42b5-bf71-5808d5285460	2a38993b-d9c1-4883-af49-26c955b55ae9	failed	other	www.larry-wuckert.com	2025-06-04 18:55:34.700302	x5knehopsy6gun087ale18v4c6vz149hs6shm7cicd37hgjiavz280wwu1n6279ljwgkuys5tm5ecf0inmpu9rpgo3i4tihnnqt8o16n0bd
f8e3743f-e6e6-410d-b03e-4e2d150a34f1	29992cfd-9985-4a02-b328-aa03de1c1939	pending	registration_certificate	www.retha-turner.io	2025-06-04 18:55:34.700302	mgcpml9gd52gtlldf4ej16tetiaqqh9d073jwdw8iefsg0xl4uhjpvxgjyeblp5it1npvwvwyq38gu55lhfw0xzrqg50wjr7z6cbjy8k5yoer1dzqcsrek55j2hrjfffkodo8jdk45q7fjmuo3znjv10l6o81c91ktjcpy5ceznhlkiqibhxq8iqcr2g83hn
5020b7ce-5b0c-4c5e-a31e-eabdbf5d12f1	1ca341bb-e272-4f47-bee3-3b0a41f9510a	pending	registration_certificate	www.lavonne-hane.biz	2025-06-04 18:55:34.700302	gkocgdwlyzahzl8pt02hyd2as7oiupcwmq4l1ojz7440npprnz3z6zf57k0pa18wd7wyh2r7gln3fawveznfrgrf8rmak6eaojsmox7w5znrorkattx0xtx9y8cywn14tz55rt84a080
b5be894f-389d-46ed-b19f-621126596f74	36057578-0f4f-4fac-bd29-4a5490801461	passed	registration_certificate	www.hisako-bruen.name	2025-06-04 18:55:34.700302	gp6x69rirt8nx6vm2d0o3dhbey06k8e6vieej490w9ksgsjortyizfhbo1to8dy40yocbq34vorr394ykq3i9yafecb9v3pbasm4by1ldu443pabpywmwstz021c1jiyiwrkrh6wkbg4gxpqcq44lc326cjeu03u2e8
14487844-64b9-4cce-8dc3-d9a6742e1593	36057578-0f4f-4fac-bd29-4a5490801461	pending	other	www.dustin-corwin.co	2025-06-04 18:55:34.700302	qjuqtwocq30zgwi6cvutp3nfo2f6xuacey2qvn9hojngcgzpzrhra3ltmsjan0rd0c9t5arxhcm5ehtg2wsfr1n0uk1ot1o3paeehgdnpwgxxbaz02oei83fv28vn8urzuypd20o8hd0u5hlblhishb3he1gt2z1op8epvlcayqfx0hfjthacv98twn2ya85j
3fa1abc8-47b4-41af-99f5-37eb57cf59b1	e3d5560b-029e-4e74-ad03-daaece398841	passed	passport	www.cleo-turcotte.biz	2025-06-04 18:55:34.700302	e30ympyvg6mvjavryi1kedbt9m71rskko4o3mecz4zthgj5tao76z5nvqtj1c0b3zx88lao3vlh8uo1ctfa3djrnang40f67b0v07q1wfy5hgdgk7ny1tlnpjtnb602lrm9t9t0h1shin7q2vk7x6u764
6db4f201-fce7-487c-b153-e915c6c20b5d	e6390fc1-74c0-4003-87ec-512fe7c163f7	passed	other	www.alphonse-boyle.co	2025-06-04 18:55:34.700302	y8p6amiftbhh91uk6e3q1w0b6aw40cxsbucm3j6hv5fht0qq5zmk1cgm0kkc2gz8tz7sywfmn0je2ce1e2n7hityvhlequ2azs8hlsiitzpmiuqrnqfjjjsf9gda8okavolhb5h
a5f17db8-836c-4c80-a5f0-873d463f43a9	e6390fc1-74c0-4003-87ec-512fe7c163f7	passed	other	www.kerry-veum.name	2025-06-04 18:55:34.700302	797m6grwehwyjqts14pgag7gsi7k2wqmsgodzz9tu2dx82hrjs09b0qxg3hikpli1delz0ufrs4jhhp8w7pkg7m97cabpi3h6as8mumumh
af21d221-27b3-4a1d-a11b-4ac261e80963	156acccc-b696-41cc-a429-69e72f76e2a5	pending	passport	www.darrick-howe.com	2025-06-04 18:55:34.700302	33ohal17otpqsrompsx2goa52hbi5ailbcpnpgvh2j6msev7wtxxlov2fyc9aeckir9rfbp8q0b1j4y6zrh0p3angkito290u436n
c739ceaa-9740-4674-8d61-f8acc5f926e8	858cc771-d98e-4b87-91ba-484b7ac82a46	passed	passport	www.rossana-howell.co	2025-06-04 18:55:34.700302	l4dzqvx1ngyke3ijn7rx9bsb9cuvjgfz2ujniyzzqcj9ox5je3g8r705u4jk75g5jzsiznm92pdr0ztgqn27nqtteiieb8wn004xk2wfnh6hhnt3l5uxmp9nt2nkaz6zhh4fqu9ypf4hre3i6p6fko6bjti75zzjfcey4x3g8sycfk
20f85176-4389-4fb2-9530-0102701327fa	55d45901-74dc-46ca-9492-d83caf72d393	pending	other	www.darrell-lebsack.biz	2025-06-04 18:55:34.700302	44bx5wvgnf4buczdjfd4zne9tlt811482m6lpo6pr5imwpm6my81eo549gh700wsmzd8crd7kv10hjo7e64ate0nwl488d56jjfkw9
858be700-5381-4bee-8680-f608912d7a66	55d45901-74dc-46ca-9492-d83caf72d393	pending	passport	www.jasmine-kreiger.com	2025-06-04 18:55:34.700302	w9sdi8nea4lnyubydyojtrxum3mkngwqjtuiyvg6fwyniennfw579zm9q8uyw3wjp3b6ophkbzfjmg8uywc1zjdbfjth8icep9dyew3cbntbmif99dpjaez17t34d63xhey4bk2e3f0gmqzulfgfads7ggo4ejpm7m033y5din4qnl1auqdl7jmqfior8hrzcd51bmxbiflvcmkxovgsul083uk5tj9lk0vmysl2tro
49e23c58-2653-47c8-8e0d-e8e9815fbc85	4616d741-946b-4926-b743-9ba387344e28	passed	other	www.buster-schiller.com	2025-06-04 18:55:34.700302	382c2rwemfyx4ieweddusvxw8sv0n9khybdywda7qsrvdxbsc2a2djrv2dvn1ys83bql6mfhg2sjodb10egee6c4p5pan29zgrp2eqrnoejfeebvzpmsuez7f2ny2tgxtimwf79sahxwq469on0jxc5g5g6ehql2c5qrqn
96e419f5-59ca-4955-bcff-e18caab18dab	c2903c62-4eaa-4578-bcd5-2ef88659a30b	passed	other	www.hosea-haag.io	2025-06-04 18:55:34.700302	85qdl5l90cb5rv9vv4qfpfxr4x3kja4jy51fh8pb9acl446s4nlvof72aqyel51v7g8hv2pdi7vpztknxem45si4expa2uct6eord
44dceca7-aa3c-4b25-b564-ca7bd8237f8c	c2903c62-4eaa-4578-bcd5-2ef88659a30b	pending	other	www.april-zboncak.name	2025-06-04 18:55:34.700302	v24zaezyyvxm67rco9rci7vdhc0ma5d3tcav335ukj0sfdhd2ik99bnnm4sl3nvq92f0upob21yc1k1n4mhnn7ej4olar11sqwdhovrk5kr48m6juo6mvqypn4fqfnjuhvtp276t89zthx5bj1i4pr9ai3uhp1kvang9dk225n227rlhc5bclkrtr2qyfvs3kn8hrlinlzg9lez
c460a40b-e855-4e34-8853-d6cd8d312464	ad53b3ff-48ca-4b18-91a6-42da74c01baa	passed	passport	www.kacy-kulas.org	2025-06-04 18:55:34.700302	b4vy3weu49o20wu4mw7h0ok0h029lbkcvrt6htwx4f316p241ssblb8gfwuztes0a0ifnb6rjm9r1rzvg5eqd8q4pprqhb1bvtx397msyk7g25bukjfcr6sucpzi4rhfu936ps6nbq4xhg5gn22f8h00p3fs7yhxncj
b86f2279-73ba-4a86-b4c7-2fdf1826be94	5333204e-7c6e-4788-a48f-1eb76fffbb6c	pending	registration_certificate	www.tawanna-armstrong.biz	2025-06-04 18:55:34.700302	gkdghz07f9kfk3fj77db2fdp2e1llfheo7dwz32dr23yy9pbyh8vw71rr3eum6s6n5xuvr5jac3mchio2t9dylxifrhqcc8oxvks8kmp37jmvbypj2ffr1848irbvat6qqi4nytbzbbeme1
7a0d3820-2f47-4e31-8e62-1c02a9a80870	5333204e-7c6e-4788-a48f-1eb76fffbb6c	pending	registration_certificate	www.luigi-waters.net	2025-06-04 18:55:34.700302	p5grgw7rik32bc49zrm4n10rrr66xc0tlm77e11e2l99rz1weudxc3587hne2sqnyf3eq1amz9lad1dv5t6a1a21x1e6kuqj2iyihg1h0l1fvo9dzdhzxa0v2at8f2vwy3t4d7nuehrewuxiy92rqvvwa1aefc5jiblwo8v6o05o5ln7v9w8wth7w
047c5522-dd1d-479b-85d1-d799fbe80645	6bd47ccf-2c44-461b-9d71-3800301370f2	failed	license	www.norbert-lindgren.com	2025-06-04 18:55:34.700302	9n9h8ig89jgbkdw0uzlbpwx55plvh0fnvsfqnabzyv7hwgbi7aaknoutob5rf5e316qyxzoe5ecq934ts4zqsfc2kujc8i3paa88w2cnjelsbc5cs6rlenu546ceoo5133eg3vt3zt712oh6kvko62k4d1gmzbw8mtr3xltjeq9dd25pnzns8lmgyl2ws65orw0lc2mpuyod2czceffh4ws28xjf9j6qw99tqc6f6
fc45c43c-9634-4532-93f0-ef9c41f73740	35f09869-9a88-4f45-b957-34138c1dbf13	pending	registration_certificate	www.omer-macgyver.com	2025-06-04 18:55:34.700302	s7s6hqemb0axnkwwdbs3ezh0kj7rxz6ntyakdntttgkylqzawp0me1jdkzf165511l6l25fvwkzjiawgdpen1otlvdias7htogr6tj3hzya41vs0nke1pn7673jxmpyda3aqmacyqpylwy743sjosrxtqs6i52orf2hpwyjwpsyr9qttrflgibjizj4xpa38sxgg8ehxt1adck2rdb
d866946b-14f7-466a-a090-fcde49df28cd	35f09869-9a88-4f45-b957-34138c1dbf13	pending	passport	www.pierre-abbott.biz	2025-06-04 18:55:34.700302	12qwbl3nbskymuroqkvv7ajeijqh97ly5bkr7yq0eajbn58ljchc2b4od770t0cgzqcbx4hejoqvfqd0zs9yl7bmt4l8u6p1nzsb1qocrd9cn1ktcsu4s96rayyx9fdih7bhg92se2gju5u4sgwzjycuoa5cxf0kxdpxxloko1sekzqwgwnlb1roaex03k5xq56n0ldhkgboar17gxutn3ced0gtxzg2l7y8ui
37c7caab-15d9-41e0-bc87-64b5af423c34	00abf49e-6a04-4e53-9345-bacfe3ba52e6	passed	passport	www.maple-grant.net	2025-06-04 18:55:34.700302	umgywfhzszkeeinh01jqvqr0w20mvx61fnvjemu5wf4t9660pr27ctpu1kmyj6q9juo4q9vwp8ie7g8lu9dmx9unygxq39t4r1a6xogcape13e68pxg4d7cn8fhd1o4sbiegxz5pnv6x7i
a7c33f1e-9051-4df6-9b69-5140df4d4668	07c91af1-c12e-4b7f-8ca2-877e3d218712	pending	registration_certificate	www.bennie-kohler.co	2025-06-04 18:55:34.700302	gi3pzlo138lx79sffntjrlw8zyyifoc0v6hc55cadk1umcs6jjbk736lmv6wcngx4rxlu6hj78fey9gjzxxijiw0zosigwtf87qxqj1qst5tmybqfszs4kfihby6tq3vm31et5bkkwt31edi9adiyoez5qd0cqa0jjqy7ajowzo0pejwqqqctrl6vjlu17rkqoh7pqukgvuk4dwfgrfuy4gsmzqhcx9c4j9bdgrl7ku8cccon7o5
25729d85-1dda-47c9-97c0-9b21b99d43b9	07c91af1-c12e-4b7f-8ca2-877e3d218712	pending	passport	www.gilbert-kirlin.com	2025-06-04 18:55:34.700302	ub2h1139375k4mmeel7oivny88wlhw0s8lgc6xy4v3yj3k941wdbz6ga71ux2wi0xsnm0nx5bhkg883qlsqr8wy68pddcsbxgwndg2wl2t18z2vrukuvs99r
7e2b7de8-d6f1-42af-bbe7-87d1430f6489	704b39aa-c212-4e80-a20b-7207b3cad366	failed	passport	www.isaura-schmidt.biz	2025-06-04 18:55:34.700302	puzfx0q2jao62v8def83rdvgavkk5kdhusb1ivl9czht1oadhotec87n2uqrobkon5t1c63lzt54inosadtxwxmp5v50o7pf98g8v7yzguns1ck9dv0172mr75wqn7efvednf5wip7ozmooo7i3bcyygl9zjqe5zt2vcjg76c3nmolm2ma9h1ta1q3zqgi58fufk0gp40r1tcxkvcuvkw0a1yakunjpxyosjficnez9wuvh19mtw
dcc5de45-a524-4ddd-b551-c052c535d325	7533aebf-2662-4fe7-9178-726965d7fd7e	passed	license	www.kurt-douglas.com	2025-06-04 18:55:34.700302	nhk1fjuhojt5gqs0uoepb8bzw6wmam7lei8r8as477p18dqst5p3d3us2nqe2nqjadipwxz4hxd9pzptct7ut9kscrto87vgc7m2xet4yhsezueguo2vv20lsfwhnrg9ki8gucg0dqt424wc84c24xz98ad9kfd9t6c9rzowr0y3qo8528bqnc8fwhmvsvxc4emqtj4h349zwq133yptkycz23whssgjdn
b4895296-6c16-421c-a25d-5f612cdb00ae	3392c7b6-8d9b-43b6-a388-a506ada131aa	failed	other	www.ninfa-schumm.net	2025-06-04 18:55:34.700302	iuyn3udob4vrpvriywxktqc7o71ff49szo9w4q384s2pzobm3m68sk0d672275gqp5hgijr5ilvzuny1yqz9apkem4dor7cvmo77ct98adzcg98yzajzuutvmssvne9l9e75otd0eg6izgh6zer9ydx4k9rwvgj7ve4qslb9crfccmp4tfnlwnezr3jbiiqu
071711dd-631c-4fb2-a6d0-ea17444a5e05	1d624d3a-9ec8-45ea-94e5-1c9d37c10d02	passed	passport	www.glen-williamson.io	2025-06-04 18:55:34.700302	nrk8qz1neowltyqc96qcnw0l9nhdjrcf9dcwlxb3kqj4scbcufd59dr4vclcnpidp16iv6cylz8tj6inyn3tlio32yc7ys2dy71txx5qrs44johchs8o6o3mhldjgt1xgna66newwnyx8pt4b81jxvb8l9en0ovlk9c0ngjjehm
f5fc4dd0-8998-4470-a3fb-09ad57b05172	f703e5e5-5866-49c0-816e-11590b1d09da	passed	passport	www.julene-klocko.io	2025-06-04 18:55:34.700302	91pthi2ak3rjrohnsx7fcropby9bfq44t2tuzm2szhwwttt2a38rx0tkmzezdivsd24qn24ajsyx98jtlvello6l8m624lzbk7ey4jdf7pla0h9xlei8df747wwf8cc1ygc50kn8zyf0efmi6afs4gnkty9ypqu2rp5z8ez1zsaliqez0o1prbkvgij7
a5853b08-483f-4207-a826-cb5a0cc60dc8	37c2ac00-5f90-4db9-b26d-c3e842ad9265	pending	other	www.eldon-hane.biz	2025-06-04 18:55:34.700302	xidvc1yncmndbcxgtdwilkja65nfl0kvqyuvfhb8sey72y1wbi0giwtac856eoduv12trmnomq87mm0qbx5215xoabdlb90fswp8b6z5kjza8lhlypgg7tyhyfzp3k38l60d7j3a00a8vrjhauc1rdtfy20libsxqgmgw7n
5fa78941-7fd9-423a-a420-f28443ae911e	270c36c6-2330-4e40-b534-0cf48ad03580	pending	other	www.synthia-lueilwitz.co	2025-06-04 18:55:34.700302	ow9mx59amtrwkjb6tr9035fse82kuwpz6k44tlrb3w5nmnd0ssbm49gusklqpqtguncssbbzrsms3pgmea5slloquh4v1p64jl4tcys36g4nimqxbcq9ewzfdon1hhy7mqivrna3af14pty19sddfv9qp52v7svd3502gktaqbzzfi51pljc59rv940t2wg5lsfuaoepsm6lwy2upioyinopudmrm1
38d93e41-90eb-443d-8ce9-97176474012e	f8264a05-db55-47de-ade8-64157af121ec	failed	license	www.genna-witting.biz	2025-06-04 18:55:34.700302	v3cssspcpw4x8xs3zzbwxvbwha6nllqzyie0y7937roae4c2gssgy54a84bhp0tchz2sod4sjkvetf0j4pf6ynarqrs3o4jqyxjyup3zpp979axbz3vd7i71h3rm6hw9oulavouchxtkl3b6t4pq5qt60kxtyxclr192sts6o0nqmpafyerzpeder2wk1hftj22oc0ruo2jvoyybizg6zu0z29rvyvp29h0ztnisbv2imi
413866a2-d373-40c4-b3ac-cade0d77afbc	ff3c0225-aebd-4d32-b373-6fb9e240ef8a	passed	license	www.truman-gutkowski.biz	2025-06-04 18:55:34.700302	avv8vapv7m7x0busfdn44cgcft64sgy5kssqc52r3tkhbbd2don3ufr8rw6ixy79izr24dpgb2z7b0y083ctlhtuwlxu83hgff93fd8dbqc176dp8q93m8ayp6cmnruura4vfh4m85h1kx26p5gtd6mhvvybomc
407236a3-41a3-4c83-b991-ab9853920c4d	ff3c0225-aebd-4d32-b373-6fb9e240ef8a	passed	other	www.sharri-bauch.io	2025-06-04 18:55:34.700302	q5t41mtkmp51wfdn6ltz4lvyj1ehqjs891jube26xv22wdpxgvc7rssdmmb14ild06bkoxsb4ut3maznxvllcg9xb715xzmxb37niqkfoxf2g3ot3mhmnwx5bnfpa9wmdvcf4mi
fc521a0b-10bb-46d1-b023-cd0caf5ad101	7dc2e223-4ee9-4ff8-bfd7-86304f286877	pending	other	www.ferdinand-tremblay.net	2025-06-04 18:55:34.700302	kosz72lp1xhrei9wytqdv0jyzl94r139tseko1zmhyliws2elv1ulhqfy21oa8ug08bubhxqgwrxcqwvgv0pjffntqjs98whfgaz5oh40bq2siq
b80722c1-05c8-4f79-a496-54cff82f6fa0	7dc2e223-4ee9-4ff8-bfd7-86304f286877	failed	other	www.harley-bradtke.biz	2025-06-04 18:55:34.700302	lkkw8p7212njcsrs81l13qkjmq0xreg5yifdzas8u9tbf3kuss7st7xaetihbn91b7yzbmrk0lkc25q332d60fytanocj5vc8pjdfx37uy17ns40z5t9a9r1okm3ad9ch3ok4yllxwlypuv1
77d0509b-1699-4ba7-85e4-0a7855ad6d6c	c6a4624b-49b5-4d76-ad75-5c4c388d49e3	passed	registration_certificate	www.esperanza-osinski.co	2025-06-04 18:55:34.700302	vrat0s5oqj7x677hmou9niolz6ddvw5cim85oiqi9a7lsb720xqm0e65lye7lto9ttn0qk77u6xl3bi3ivl8pwqnaqn6tytcdcqa8en3o6h9x9jglbyqsj86a0zzvy9tq2nyt0basnv94kbi0l7do1jjjgwens7lb4pp5uudxgncnscg5kbx9dz9r3gr2mk6lxjrcso3hu53ax23tk1q0ux0u5kinf3ywmbvb3mg6g1q
0bf8ba8b-756b-4da1-8aea-f109b4cdf4df	b1ffdfbc-409a-477b-9460-679b1288d9ce	passed	registration_certificate	www.brett-donnelly.co	2025-06-04 18:55:34.700302	e6ffiokuxl2qrxln6jn49slwz25tpqgty2y08kutnpob65tnyg9dfwk9i6v5hdwkrep6oylngl4mwng4pqmx6cgnyb6su4fv98xl1xht0k5jpwt1kxtw4oumm3c0c37kqlldlu3r6gpj1j17ypc26bk
d01ee326-b0ad-44c6-b1e1-376e9f38e017	13e86e43-7909-4166-8164-593019247f89	passed	other	www.tiffany-leuschke.com	2025-06-04 18:55:34.700302	bfnwzozq3opxf0qg4la9465vtdh617blb3ni2npkbotqu4hg6hj5m7tgfvxjr8llgswfj5owd137wzaarbh5zuwnmw419zeim9lzt9b1xn5jwbgy3wd9j2me0wbp4w3i2f611h43bb5cj21pmrcuviaw7kle03vfalcyjn9anknb0djt8h1ozzt1t0u5czs4
b98b20e5-cf62-423d-a737-f4de1a4f09e0	13e86e43-7909-4166-8164-593019247f89	passed	registration_certificate	www.brynn-turcotte.com	2025-06-04 18:55:34.700302	t32p6x70cjkax57im7mov7a96kmxekou1in1u1mun9cene25x4dmhjleawn0d6uksqubcq1b2g3psyav94o1yuh3xswlwxdn6a1gr8brd5gr3965ya103sv6dgeaonksvk2yjshdc88p5djmovmeome43ro8tjovvm420xr56hxl1o1byna17bnw0qqc5
6d5ec192-3dc9-47f9-817e-5c28c34ddca6	6b266b30-16d3-404a-be7c-678941d6f5cf	passed	registration_certificate	www.caryl-gleason.net	2025-06-04 18:55:34.700302	zkbj5gxk5xw9obqa6czkicm100fqm0jw8t06uewse3dxfbrb4n9rq0dgmiwy7fbc1rqfvqequl4yfu4zpif6xdvrlkiyv0j9kjthrxgm0damzhfuatxkcqjtzkd3t2xvb2l8nq2ksh2g40ykqb1mqk1z203k2qbm06
\.


--
-- Data for Name: verification_status_codes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.verification_status_codes (code, description) FROM stdin;
passed	Проверка пройдена
failed	Проверка не пройдена
pending	Ожидает проверки
\.


--
-- Name: bid_status_codes bid_status_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bid_status_codes
    ADD CONSTRAINT bid_status_codes_pkey PRIMARY KEY (code);


--
-- Name: company_profile_details company_profile_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company_profile_details
    ADD CONSTRAINT company_profile_details_pkey PRIMARY KEY (id);


--
-- Name: e_signature_verifications e_signature_verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.e_signature_verifications
    ADD CONSTRAINT e_signature_verifications_pkey PRIMARY KEY (id);


--
-- Name: flyway_schema_history flyway_schema_history_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.flyway_schema_history
    ADD CONSTRAINT flyway_schema_history_pk PRIMARY KEY (installed_rank);


--
-- Name: gov_profile_details gov_profile_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gov_profile_details
    ADD CONSTRAINT gov_profile_details_pkey PRIMARY KEY (id);


--
-- Name: ip_profile_details ip_profile_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ip_profile_details
    ADD CONSTRAINT ip_profile_details_pkey PRIMARY KEY (id);


--
-- Name: legal_profile_types legal_profile_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.legal_profile_types
    ADD CONSTRAINT legal_profile_types_pkey PRIMARY KEY (legal_type_code);


--
-- Name: order_bids order_bids_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_bids
    ADD CONSTRAINT order_bids_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: person_profile_details person_profile_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person_profile_details
    ADD CONSTRAINT person_profile_details_pkey PRIMARY KEY (id);


--
-- Name: portfolio_projects portfolio_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.portfolio_projects
    ADD CONSTRAINT portfolio_projects_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: project_mediafiles project_mediafiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_mediafiles
    ADD CONSTRAINT project_mediafiles_pkey PRIMARY KEY (id);


--
-- Name: publication_mediafiles publication_mediafiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publication_mediafiles
    ADD CONSTRAINT publication_mediafiles_pkey PRIMARY KEY (id);


--
-- Name: publication_regions publication_regions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publication_regions
    ADD CONSTRAINT publication_regions_pkey PRIMARY KEY (publication_id, region_code);


--
-- Name: publication_specializations publication_specializations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publication_specializations
    ADD CONSTRAINT publication_specializations_pkey PRIMARY KEY (publication_id, spec_code);


--
-- Name: publication_status_codes publication_status_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publication_status_codes
    ADD CONSTRAINT publication_status_codes_pkey PRIMARY KEY (code);


--
-- Name: publications publications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publications
    ADD CONSTRAINT publications_pkey PRIMARY KEY (id);


--
-- Name: regions regions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_pkey PRIMARY KEY (region_code);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (role_code);


--
-- Name: specializations specializations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.specializations
    ADD CONSTRAINT specializations_pkey PRIMARY KEY (spec_code);


--
-- Name: tender_bid_documents tender_bid_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tender_bid_documents
    ADD CONSTRAINT tender_bid_documents_pkey PRIMARY KEY (id);


--
-- Name: tender_bid_evaluations tender_bid_evaluations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tender_bid_evaluations
    ADD CONSTRAINT tender_bid_evaluations_pkey PRIMARY KEY (id);


--
-- Name: tender_bids tender_bids_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tender_bids
    ADD CONSTRAINT tender_bids_pkey PRIMARY KEY (id);


--
-- Name: tenders tenders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tenders
    ADD CONSTRAINT tenders_pkey PRIMARY KEY (id);


--
-- Name: user_regions user_regions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_regions
    ADD CONSTRAINT user_regions_pkey PRIMARY KEY (user_id, region_code);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (user_id, role_code);


--
-- Name: user_specializations user_specializations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_specializations
    ADD CONSTRAINT user_specializations_pkey PRIMARY KEY (user_id, spec_code);


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
-- Name: verification_documents verification_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.verification_documents
    ADD CONSTRAINT verification_documents_pkey PRIMARY KEY (id);


--
-- Name: verification_status_codes verification_status_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.verification_status_codes
    ADD CONSTRAINT verification_status_codes_pkey PRIMARY KEY (code);


--
-- Name: flyway_schema_history_s_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX flyway_schema_history_s_idx ON public.flyway_schema_history USING btree (success);


--
-- Name: reviews trigger_update_profile_rating; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_update_profile_rating AFTER INSERT ON public.reviews FOR EACH ROW EXECUTE FUNCTION public.update_profile_rating();


--
-- Name: tender_bid_evaluations trigger_update_profile_rating; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_update_profile_rating AFTER INSERT ON public.tender_bid_evaluations FOR EACH ROW EXECUTE FUNCTION public.update_bid_score();


--
-- Name: company_profile_details company_profile_details_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company_profile_details
    ADD CONSTRAINT company_profile_details_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: e_signature_verifications e_signature_verifications_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.e_signature_verifications
    ADD CONSTRAINT e_signature_verifications_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: e_signature_verifications e_signature_verifications_verification_status_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.e_signature_verifications
    ADD CONSTRAINT e_signature_verifications_verification_status_fkey FOREIGN KEY (verification_status) REFERENCES public.verification_status_codes(code);


--
-- Name: gov_profile_details gov_profile_details_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gov_profile_details
    ADD CONSTRAINT gov_profile_details_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: ip_profile_details ip_profile_details_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ip_profile_details
    ADD CONSTRAINT ip_profile_details_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: order_bids order_bids_bid_status_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_bids
    ADD CONSTRAINT order_bids_bid_status_code_fkey FOREIGN KEY (bid_status_code) REFERENCES public.bid_status_codes(code);


--
-- Name: order_bids order_bids_bidder_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_bids
    ADD CONSTRAINT order_bids_bidder_id_fkey FOREIGN KEY (bidder_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: order_bids order_bids_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_bids
    ADD CONSTRAINT order_bids_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: orders orders_publication_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_publication_id_fkey FOREIGN KEY (publication_id) REFERENCES public.publications(id) ON DELETE CASCADE;


--
-- Name: person_profile_details person_profile_details_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person_profile_details
    ADD CONSTRAINT person_profile_details_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: portfolio_projects portfolio_projects_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.portfolio_projects
    ADD CONSTRAINT portfolio_projects_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: profiles profiles_legal_type_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_legal_type_code_fkey FOREIGN KEY (legal_type_code) REFERENCES public.legal_profile_types(legal_type_code);


--
-- Name: profiles profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: profiles profiles_verification_status_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_verification_status_code_fkey FOREIGN KEY (verification_status_code) REFERENCES public.verification_status_codes(code);


--
-- Name: project_mediafiles project_mediafiles_portfolio_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_mediafiles
    ADD CONSTRAINT project_mediafiles_portfolio_project_id_fkey FOREIGN KEY (portfolio_project_id) REFERENCES public.portfolio_projects(id) ON DELETE CASCADE;


--
-- Name: publication_mediafiles publication_mediafiles_publication_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publication_mediafiles
    ADD CONSTRAINT publication_mediafiles_publication_id_fkey FOREIGN KEY (publication_id) REFERENCES public.publications(id) ON DELETE CASCADE;


--
-- Name: publication_regions publication_regions_publication_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publication_regions
    ADD CONSTRAINT publication_regions_publication_id_fkey FOREIGN KEY (publication_id) REFERENCES public.publications(id) ON DELETE CASCADE;


--
-- Name: publication_regions publication_regions_region_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publication_regions
    ADD CONSTRAINT publication_regions_region_code_fkey FOREIGN KEY (region_code) REFERENCES public.regions(region_code) ON DELETE CASCADE;


--
-- Name: publication_specializations publication_specializations_publication_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publication_specializations
    ADD CONSTRAINT publication_specializations_publication_id_fkey FOREIGN KEY (publication_id) REFERENCES public.publications(id) ON DELETE CASCADE;


--
-- Name: publication_specializations publication_specializations_spec_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publication_specializations
    ADD CONSTRAINT publication_specializations_spec_code_fkey FOREIGN KEY (spec_code) REFERENCES public.specializations(spec_code) ON DELETE CASCADE;


--
-- Name: publications publications_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publications
    ADD CONSTRAINT publications_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: publications publications_publication_status_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publications
    ADD CONSTRAINT publications_publication_status_code_fkey FOREIGN KEY (publication_status_code) REFERENCES public.publication_status_codes(code);


--
-- Name: reviews reviews_reviewer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_reviewer_id_fkey FOREIGN KEY (reviewer_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: reviews reviews_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: tender_bid_documents tender_bid_documents_tender_bid_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tender_bid_documents
    ADD CONSTRAINT tender_bid_documents_tender_bid_id_fkey FOREIGN KEY (tender_bid_id) REFERENCES public.tender_bids(id) ON DELETE CASCADE;


--
-- Name: tender_bid_evaluations tender_bid_evaluations_tender_bid_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tender_bid_evaluations
    ADD CONSTRAINT tender_bid_evaluations_tender_bid_id_fkey FOREIGN KEY (tender_bid_id) REFERENCES public.tender_bids(id) ON DELETE CASCADE;


--
-- Name: tender_bids tender_bids_bid_status_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tender_bids
    ADD CONSTRAINT tender_bids_bid_status_code_fkey FOREIGN KEY (bid_status_code) REFERENCES public.bid_status_codes(code);


--
-- Name: tender_bids tender_bids_bidder_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tender_bids
    ADD CONSTRAINT tender_bids_bidder_id_fkey FOREIGN KEY (bidder_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: tender_bids tender_bids_tender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tender_bids
    ADD CONSTRAINT tender_bids_tender_id_fkey FOREIGN KEY (tender_id) REFERENCES public.tenders(id) ON DELETE CASCADE;


--
-- Name: tenders tenders_publication_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tenders
    ADD CONSTRAINT tenders_publication_id_fkey FOREIGN KEY (publication_id) REFERENCES public.publications(id) ON DELETE CASCADE;


--
-- Name: user_regions user_regions_region_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_regions
    ADD CONSTRAINT user_regions_region_code_fkey FOREIGN KEY (region_code) REFERENCES public.regions(region_code) ON DELETE CASCADE;


--
-- Name: user_regions user_regions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_regions
    ADD CONSTRAINT user_regions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_roles user_roles_role_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_role_code_fkey FOREIGN KEY (role_code) REFERENCES public.roles(role_code) ON DELETE CASCADE;


--
-- Name: user_roles user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_specializations user_specializations_spec_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_specializations
    ADD CONSTRAINT user_specializations_spec_code_fkey FOREIGN KEY (spec_code) REFERENCES public.specializations(spec_code) ON DELETE CASCADE;


--
-- Name: user_specializations user_specializations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_specializations
    ADD CONSTRAINT user_specializations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: verification_documents verification_documents_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.verification_documents
    ADD CONSTRAINT verification_documents_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: verification_documents verification_documents_verification_status_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.verification_documents
    ADD CONSTRAINT verification_documents_verification_status_code_fkey FOREIGN KEY (verification_status_code) REFERENCES public.verification_status_codes(code);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO analytic;


--
-- Name: TABLE bid_status_codes; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.bid_status_codes TO analytic;


--
-- Name: TABLE company_profile_details; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.company_profile_details TO analytic;


--
-- Name: TABLE e_signature_verifications; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.e_signature_verifications TO analytic;


--
-- Name: TABLE flyway_schema_history; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.flyway_schema_history TO analytic;


--
-- Name: TABLE gov_profile_details; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.gov_profile_details TO analytic;


--
-- Name: TABLE ip_profile_details; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.ip_profile_details TO analytic;


--
-- Name: TABLE legal_profile_types; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.legal_profile_types TO analytic;


--
-- Name: TABLE order_bids; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.order_bids TO analytic;


--
-- Name: TABLE orders; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.orders TO analytic;


--
-- Name: TABLE person_profile_details; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.person_profile_details TO analytic;


--
-- Name: TABLE portfolio_projects; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.portfolio_projects TO analytic;


--
-- Name: TABLE profiles; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.profiles TO analytic;


--
-- Name: TABLE project_mediafiles; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.project_mediafiles TO analytic;


--
-- Name: TABLE publication_mediafiles; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.publication_mediafiles TO analytic;


--
-- Name: TABLE publication_regions; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.publication_regions TO analytic;


--
-- Name: TABLE publication_specializations; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.publication_specializations TO analytic;


--
-- Name: TABLE publication_status_codes; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.publication_status_codes TO analytic;


--
-- Name: TABLE publications; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.publications TO analytic;


--
-- Name: TABLE regions; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.regions TO analytic;


--
-- Name: TABLE reviews; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.reviews TO analytic;


--
-- Name: TABLE roles; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.roles TO analytic;


--
-- Name: TABLE specializations; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.specializations TO analytic;


--
-- Name: TABLE tender_bid_documents; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tender_bid_documents TO analytic;


--
-- Name: TABLE tender_bid_evaluations; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tender_bid_evaluations TO analytic;


--
-- Name: TABLE tender_bids; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tender_bids TO analytic;


--
-- Name: TABLE tenders; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tenders TO analytic;


--
-- Name: TABLE user_regions; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.user_regions TO analytic;


--
-- Name: TABLE user_roles; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.user_roles TO analytic;


--
-- Name: TABLE user_specializations; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.user_specializations TO analytic;


--
-- Name: TABLE users; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.users TO analytic;


--
-- Name: TABLE verification_documents; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.verification_documents TO analytic;


--
-- Name: TABLE verification_status_codes; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.verification_status_codes TO analytic;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT ON TABLES  TO analytic;


--
-- PostgreSQL database dump complete
--

