--
-- PostgreSQL database dump
--

\restrict UhrHWfLPjxXZc7bPGSMCPXiX0zWIseLUdVeSCTb13Ertc6Xz6wPukuar3umcgIG

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admins; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admins (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.admins OWNER TO postgres;

--
-- Name: cache; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cache (
    key character varying(255) NOT NULL,
    value text NOT NULL,
    expiration bigint NOT NULL
);


ALTER TABLE public.cache OWNER TO postgres;

--
-- Name: cache_locks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cache_locks (
    key character varying(255) NOT NULL,
    owner character varying(255) NOT NULL,
    expiration bigint NOT NULL
);


ALTER TABLE public.cache_locks OWNER TO postgres;

--
-- Name: clients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clients (
    id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255),
    phone character varying(255),
    address character varying(255),
    company character varying(255),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.clients OWNER TO postgres;

--
-- Name: failed_jobs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.failed_jobs (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    connection text NOT NULL,
    queue text NOT NULL,
    payload text NOT NULL,
    exception text NOT NULL,
    failed_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.failed_jobs OWNER TO postgres;

--
-- Name: failed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.failed_jobs_id_seq OWNER TO postgres;

--
-- Name: failed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.failed_jobs_id_seq OWNED BY public.failed_jobs.id;


--
-- Name: invites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invites (
    id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    invited_by uuid NOT NULL,
    email character varying(255) NOT NULL,
    role character varying(255) DEFAULT 'member'::character varying NOT NULL,
    token character varying(64) NOT NULL,
    expires_at timestamp(0) without time zone NOT NULL,
    accepted_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.invites OWNER TO postgres;

--
-- Name: invoice_activities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invoice_activities (
    id uuid NOT NULL,
    invoice_id uuid NOT NULL,
    type character varying(255) NOT NULL,
    meta jsonb,
    created_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.invoice_activities OWNER TO postgres;

--
-- Name: invoice_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invoice_items (
    id uuid NOT NULL,
    invoice_id uuid NOT NULL,
    product_id uuid,
    description character varying(255) NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    unit_price integer DEFAULT 0 NOT NULL,
    total integer DEFAULT 0 NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.invoice_items OWNER TO postgres;

--
-- Name: invoices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invoices (
    id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    client_id uuid NOT NULL,
    number character varying(255) NOT NULL,
    type character varying(255) DEFAULT 'invoice'::character varying NOT NULL,
    status character varying(255) DEFAULT 'draft'::character varying NOT NULL,
    view_token character varying(255),
    subtotal integer DEFAULT 0 NOT NULL,
    tax_rate integer DEFAULT 0 NOT NULL,
    tax_amount integer DEFAULT 0 NOT NULL,
    total integer DEFAULT 0 NOT NULL,
    notes text,
    due_date date,
    sent_at timestamp(0) without time zone,
    viewed_at timestamp(0) without time zone,
    paid_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.invoices OWNER TO postgres;

--
-- Name: job_batches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_batches (
    id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    total_jobs integer NOT NULL,
    pending_jobs integer NOT NULL,
    failed_jobs integer NOT NULL,
    failed_job_ids text NOT NULL,
    options text,
    cancelled_at integer,
    created_at integer NOT NULL,
    finished_at integer
);


ALTER TABLE public.job_batches OWNER TO postgres;

--
-- Name: jobs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.jobs (
    id bigint NOT NULL,
    queue character varying(255) NOT NULL,
    payload text NOT NULL,
    attempts smallint NOT NULL,
    reserved_at integer,
    available_at integer NOT NULL,
    created_at integer NOT NULL
);


ALTER TABLE public.jobs OWNER TO postgres;

--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.jobs_id_seq OWNER TO postgres;

--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.jobs_id_seq OWNED BY public.jobs.id;


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    migration character varying(255) NOT NULL,
    batch integer NOT NULL
);


ALTER TABLE public.migrations OWNER TO postgres;

--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.migrations_id_seq OWNER TO postgres;

--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.password_reset_tokens (
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp(0) without time zone
);


ALTER TABLE public.password_reset_tokens OWNER TO postgres;

--
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payments (
    id uuid NOT NULL,
    invoice_id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    provider character varying(255) NOT NULL,
    provider_ref character varying(255) NOT NULL,
    amount integer NOT NULL,
    status character varying(255) NOT NULL,
    meta jsonb,
    paid_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.payments OWNER TO postgres;

--
-- Name: plans; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.plans (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    slug character varying(255) NOT NULL,
    price_monthly integer DEFAULT 0 NOT NULL,
    invoice_limit integer DEFAULT 5 NOT NULL,
    features jsonb,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.plans OWNER TO postgres;

--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    default_price integer DEFAULT 0 NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sessions (
    id character varying(255) NOT NULL,
    user_id bigint,
    ip_address character varying(45),
    user_agent text,
    payload text NOT NULL,
    last_activity integer NOT NULL
);


ALTER TABLE public.sessions OWNER TO postgres;

--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subscriptions (
    id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    plan_id uuid NOT NULL,
    status character varying(255) NOT NULL,
    paystack_ref character varying(255),
    trial_ends_at timestamp(0) without time zone,
    current_period_start timestamp(0) without time zone,
    current_period_end timestamp(0) without time zone,
    cancelled_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.subscriptions OWNER TO postgres;

--
-- Name: tenants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tenants (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    slug character varying(255) NOT NULL,
    currency character varying(3) DEFAULT 'GHS'::character varying NOT NULL,
    logo_url character varying(255),
    invoice_prefix character varying(255) DEFAULT 'INV'::character varying NOT NULL,
    address character varying(255),
    phone character varying(255),
    website character varying(255),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    timezone character varying(255) DEFAULT 'Africa/Accra'::character varying NOT NULL,
    is_active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.tenants OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    role character varying(255) DEFAULT 'member'::character varying NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    invited_at timestamp(0) without time zone,
    email_verified_at timestamp(0) without time zone,
    remember_token character varying(100),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    email_verification_token character varying(64)
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: failed_jobs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.failed_jobs ALTER COLUMN id SET DEFAULT nextval('public.failed_jobs_id_seq'::regclass);


--
-- Name: jobs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jobs ALTER COLUMN id SET DEFAULT nextval('public.jobs_id_seq'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Data for Name: admins; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admins (id, name, email, password, created_at, updated_at) FROM stdin;
9d348545-4a6f-484e-922c-95f352ca5e6b	TuaKa Admin	admin@tuaka.app	$2y$12$V1Pb15cD08M6yG9BauRWLudryCxInpIvheBR8C35xFAWmWjY6ud.G	2026-05-06 20:44:39	2026-05-06 21:22:57
\.


--
-- Data for Name: cache; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cache (key, value, expiration) FROM stdin;
tuaka-cache-TJJtEe7DrQtcgqp6	a:1:{s:11:"valid_until";i:1778103011;}	1779312491
tuaka-cache-zUfoOnNzDHcAQ6x3	a:1:{s:11:"valid_until";i:1778152742;}	1779362342
tuaka-cache-RGNHPlpaPbOpPAGn	a:1:{s:11:"valid_until";i:1778159493;}	1779365613
tuaka-cache-GKnPJdK5570iV1KX	a:1:{s:11:"valid_until";i:1778160241;}	1779369241
tuaka-cache-PCI0fWkgSqhds7z8	a:1:{s:11:"valid_until";i:1778160842;}	1779369902
tuaka-cache-e45444ecc678a271a6330f468a373360:timer	i:1778160920;	1778160920
tuaka-cache-e45444ecc678a271a6330f468a373360	i:1;	1778160920
\.


--
-- Data for Name: cache_locks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cache_locks (key, owner, expiration) FROM stdin;
\.


--
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.clients (id, tenant_id, name, email, phone, address, company, created_at, updated_at) FROM stdin;
ae800822-fed9-4119-8688-964ab94e5829	04e240e3-e4de-4dfa-87bd-fad64e3fb803	THEOPHILOUS ASANTE FRIMPONG	theophilusfrimpong17@gmail.com	+233243596533	Accra	Theo's Heart	2026-05-05 00:24:14	2026-05-05 00:24:14
4b82176f-b28b-4b34-ac7e-4c6ba973eeab	04e240e3-e4de-4dfa-87bd-fad64e3fb803	Mariam	mariam@gmail.com	\N	\N	\N	2026-05-05 00:28:02	2026-05-05 02:36:51
5c01d918-4e33-4b50-bba1-2c42b7474f94	04e240e3-e4de-4dfa-87bd-fad64e3fb803	Ama Owusu	ama@owusu.com	+233243596533	Accra	owusu corporations	2026-05-05 19:23:22	2026-05-05 19:23:22
d2c2a0a8-7c3b-4b0b-9c93-2274dec6ddff	abbb1866-9613-456a-96d0-c22ab063f448	Akosua Agoo Aboagye	agoo@gmail.com	+233 243567544	Accra	UTV	2026-05-06 12:03:03	2026-05-06 12:03:03
206dbe31-566b-42e0-adaa-2b1930e4af05	abbb1866-9613-456a-96d0-c22ab063f448	Mamle Wonko Menko	mamle@gmail.com	+233 564467736	Accra	MTV	2026-05-06 12:03:47	2026-05-06 12:03:47
f3362550-a159-4776-b1ac-a7e278bb5ba1	f5248b0c-7637-4233-863f-059d7f28383b	test 1	meso@gmail.com	+233243596533	Accra	testing	2026-05-07 13:14:33	2026-05-07 13:14:33
\.


--
-- Data for Name: failed_jobs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.failed_jobs (id, uuid, connection, queue, payload, exception, failed_at) FROM stdin;
1	86308b67-58ca-44bc-8769-bec57e60c107	database	default	{"uuid":"86308b67-58ca-44bc-8769-bec57e60c107","displayName":"App\\\\Mail\\\\VerifyEmailMail","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":null,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":null,"retryUntil":null,"deleteWhenMissingModels":false,"data":{"commandName":"Illuminate\\\\Mail\\\\SendQueuedMailable","command":"O:34:\\"Illuminate\\\\Mail\\\\SendQueuedMailable\\":18:{s:8:\\"mailable\\";O:24:\\"App\\\\Mail\\\\VerifyEmailMail\\":4:{s:4:\\"user\\";O:45:\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\":5:{s:5:\\"class\\";s:15:\\"App\\\\Models\\\\User\\";s:2:\\"id\\";s:36:\\"d3290a06-5d9c-45b9-8263-98cbb960e49b\\";s:9:\\"relations\\";a:0:{}s:10:\\"connection\\";s:5:\\"pgsql\\";s:15:\\"collectionClass\\";N;}s:15:\\"verificationUrl\\";s:130:\\"http:\\/\\/localhost:3001\\/verify-email?token=DQ6zNpUfp4g76doMq3KivZBe1ADifRQkXAcu06A5iTnthnIAhNjc9yH5t3guNxPp&email=mariam%40gmail.com\\";s:2:\\"to\\";a:1:{i:0;a:2:{s:4:\\"name\\";N;s:7:\\"address\\";s:16:\\"mariam@gmail.com\\";}}s:6:\\"mailer\\";s:4:\\"smtp\\";}s:5:\\"tries\\";N;s:7:\\"timeout\\";N;s:13:\\"maxExceptions\\";N;s:17:\\"shouldBeEncrypted\\";b:0;s:3:\\"job\\";N;s:10:\\"connection\\";N;s:5:\\"queue\\";N;s:12:\\"messageGroup\\";N;s:12:\\"deduplicator\\";N;s:13:\\"debounceOwner\\";s:0:\\"\\";s:5:\\"delay\\";N;s:11:\\"afterCommit\\";N;s:10:\\"middleware\\";a:0:{}s:7:\\"chained\\";a:0:{}s:15:\\"chainConnection\\";N;s:10:\\"chainQueue\\";N;s:19:\\"chainCatchCallbacks\\";N;}","batchId":null},"createdAt":1777927088,"delay":null}	Symfony\\Component\\Mailer\\Exception\\UnexpectedResponseException: Expected response code "354" but got code "550", with message "550 5.7.0 Too many emails per second. Please upgrade your plan https://mailtrap.io/billing/plans/testing". in C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\SmtpTransport.php:331\nStack trace:\n#0 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\SmtpTransport.php(187): Symfony\\Component\\Mailer\\Transport\\Smtp\\SmtpTransport->assertResponseCode()\n#1 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\EsmtpTransport.php(150): Symfony\\Component\\Mailer\\Transport\\Smtp\\SmtpTransport->executeCommand()\n#2 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\SmtpTransport.php(209): Symfony\\Component\\Mailer\\Transport\\Smtp\\EsmtpTransport->executeCommand()\n#3 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\AbstractTransport.php(69): Symfony\\Component\\Mailer\\Transport\\Smtp\\SmtpTransport->doSend()\n#4 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\SmtpTransport.php(138): Symfony\\Component\\Mailer\\Transport\\AbstractTransport->send()\n#5 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Mail\\Mailer.php(584): Symfony\\Component\\Mailer\\Transport\\Smtp\\SmtpTransport->send()\n#6 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Mail\\Mailer.php(331): Illuminate\\Mail\\Mailer->sendSymfonyMessage()\n#7 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Mail\\Mailable.php(209): Illuminate\\Mail\\Mailer->send()\n#8 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Support\\Traits\\Localizable.php(19): Illuminate\\Mail\\Mailable->{closure:Illuminate\\Mail\\Mailable::send():202}()\n#9 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Mail\\Mailable.php(202): Illuminate\\Mail\\Mailable->withLocale()\n#10 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Mail\\SendQueuedMailable.php(89): Illuminate\\Mail\\Mailable->send()\n#11 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(36): Illuminate\\Mail\\SendQueuedMailable->handle()\n#12 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\Util.php(43): Illuminate\\Container\\BoundMethod::{closure:Illuminate\\Container\\BoundMethod::call():35}()\n#13 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(96): Illuminate\\Container\\Util::unwrapIfClosure()\n#14 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(35): Illuminate\\Container\\BoundMethod::callBoundMethod()\n#15 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\Container.php(799): Illuminate\\Container\\BoundMethod::call()\n#16 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Bus\\Dispatcher.php(136): Illuminate\\Container\\Container->call()\n#17 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Pipeline\\Pipeline.php(180): Illuminate\\Bus\\Dispatcher->{closure:Illuminate\\Bus\\Dispatcher::dispatchNow():133}()\n#18 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Pipeline\\Pipeline.php(137): Illuminate\\Pipeline\\Pipeline->{closure:Illuminate\\Pipeline\\Pipeline::prepareDestination():178}()\n#19 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Bus\\Dispatcher.php(140): Illuminate\\Pipeline\\Pipeline->then()\n#20 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\CallQueuedHandler.php(153): Illuminate\\Bus\\Dispatcher->dispatchNow()\n#21 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Pipeline\\Pipeline.php(180): Illuminate\\Queue\\CallQueuedHandler->{closure:Illuminate\\Queue\\CallQueuedHandler::dispatchThroughMiddleware():146}()\n#22 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Pipeline\\Pipeline.php(137): Illuminate\\Pipeline\\Pipeline->{closure:Illuminate\\Pipeline\\Pipeline::prepareDestination():178}()\n#23 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\CallQueuedHandler.php(146): Illuminate\\Pipeline\\Pipeline->then()\n#24 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\CallQueuedHandler.php(84): Illuminate\\Queue\\CallQueuedHandler->dispatchThroughMiddleware()\n#25 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Jobs\\Job.php(102): Illuminate\\Queue\\CallQueuedHandler->call()\n#26 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Worker.php(515): Illuminate\\Queue\\Jobs\\Job->fire()\n#27 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Worker.php(461): Illuminate\\Queue\\Worker->process()\n#28 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Worker.php(224): Illuminate\\Queue\\Worker->runJob()\n#29 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Console\\WorkCommand.php(148): Illuminate\\Queue\\Worker->daemon()\n#30 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Console\\WorkCommand.php(131): Illuminate\\Queue\\Console\\WorkCommand->runWorker()\n#31 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(36): Illuminate\\Queue\\Console\\WorkCommand->handle()\n#32 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\Util.php(43): Illuminate\\Container\\BoundMethod::{closure:Illuminate\\Container\\BoundMethod::call():35}()\n#33 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(96): Illuminate\\Container\\Util::unwrapIfClosure()\n#34 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(35): Illuminate\\Container\\BoundMethod::callBoundMethod()\n#35 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\Container.php(799): Illuminate\\Container\\BoundMethod::call()\n#36 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Console\\Command.php(280): Illuminate\\Container\\Container->call()\n#37 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\console\\Command\\Command.php(291): Illuminate\\Console\\Command->execute()\n#38 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Console\\Command.php(249): Symfony\\Component\\Console\\Command\\Command->run()\n#39 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\console\\Application.php(1107): Illuminate\\Console\\Command->run()\n#40 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\console\\Application.php(356): Symfony\\Component\\Console\\Application->doRunCommand()\n#41 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\console\\Application.php(195): Symfony\\Component\\Console\\Application->doRun()\n#42 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Foundation\\Console\\Kernel.php(198): Symfony\\Component\\Console\\Application->run()\n#43 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Foundation\\Application.php(1235): Illuminate\\Foundation\\Console\\Kernel->handle()\n#44 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\artisan(16): Illuminate\\Foundation\\Application->handleCommand()\n#45 {main}	2026-05-04 20:44:12
2	fb3b465d-d1ab-44bf-bab1-3d13bf3117a8	database	default	{"uuid":"fb3b465d-d1ab-44bf-bab1-3d13bf3117a8","displayName":"App\\\\Mail\\\\InvoiceMail","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":null,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":null,"retryUntil":null,"deleteWhenMissingModels":false,"data":{"commandName":"Illuminate\\\\Mail\\\\SendQueuedMailable","command":"O:34:\\"Illuminate\\\\Mail\\\\SendQueuedMailable\\":18:{s:8:\\"mailable\\";O:20:\\"App\\\\Mail\\\\InvoiceMail\\":4:{s:7:\\"invoice\\";O:45:\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\":5:{s:5:\\"class\\";s:18:\\"App\\\\Models\\\\Invoice\\";s:2:\\"id\\";s:36:\\"b84052ae-0b8d-44b9-ac2b-70ad6ae82076\\";s:9:\\"relations\\";a:1:{i:0;s:6:\\"tenant\\";}s:10:\\"connection\\";s:5:\\"pgsql\\";s:15:\\"collectionClass\\";N;}s:10:\\"invoiceUrl\\";s:90:\\"http:\\/\\/localhost:3001\\/inv\\/3OoYhJop38umJkFPSt4t1HxsisQjgawkFXuUGNI0cuKYCaEIs7td2WiBRCb2WHwI\\";s:2:\\"to\\";a:1:{i:0;a:2:{s:4:\\"name\\";N;s:7:\\"address\\";s:30:\\"theophilusfrimpong17@gmail.com\\";}}s:6:\\"mailer\\";s:4:\\"smtp\\";}s:5:\\"tries\\";N;s:7:\\"timeout\\";N;s:13:\\"maxExceptions\\";N;s:17:\\"shouldBeEncrypted\\";b:0;s:3:\\"job\\";N;s:10:\\"connection\\";N;s:5:\\"queue\\";N;s:12:\\"messageGroup\\";N;s:12:\\"deduplicator\\";N;s:13:\\"debounceOwner\\";s:0:\\"\\";s:5:\\"delay\\";N;s:11:\\"afterCommit\\";N;s:10:\\"middleware\\";a:0:{}s:7:\\"chained\\";a:0:{}s:15:\\"chainConnection\\";N;s:10:\\"chainQueue\\";N;s:19:\\"chainCatchCallbacks\\";N;}","batchId":null},"createdAt":1777985156,"delay":null}	Symfony\\Component\\Mailer\\Exception\\TransportException: Connection to "sandbox.smtp.mailtrap.io:2525" timed out. in C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\Stream\\AbstractStream.php:85\nStack trace:\n#0 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\SmtpTransport.php(339): Symfony\\Component\\Mailer\\Transport\\Smtp\\Stream\\AbstractStream->readLine()\n#1 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\SmtpTransport.php(186): Symfony\\Component\\Mailer\\Transport\\Smtp\\SmtpTransport->getFullResponse()\n#2 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\EsmtpTransport.php(150): Symfony\\Component\\Mailer\\Transport\\Smtp\\SmtpTransport->executeCommand()\n#3 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\SmtpTransport.php(252): Symfony\\Component\\Mailer\\Transport\\Smtp\\EsmtpTransport->executeCommand()\n#4 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\SmtpTransport.php(204): Symfony\\Component\\Mailer\\Transport\\Smtp\\SmtpTransport->doMailFromCommand()\n#5 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\AbstractTransport.php(69): Symfony\\Component\\Mailer\\Transport\\Smtp\\SmtpTransport->doSend()\n#6 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\SmtpTransport.php(138): Symfony\\Component\\Mailer\\Transport\\AbstractTransport->send()\n#7 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Mail\\Mailer.php(584): Symfony\\Component\\Mailer\\Transport\\Smtp\\SmtpTransport->send()\n#8 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Mail\\Mailer.php(331): Illuminate\\Mail\\Mailer->sendSymfonyMessage()\n#9 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Mail\\Mailable.php(209): Illuminate\\Mail\\Mailer->send()\n#10 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Support\\Traits\\Localizable.php(19): Illuminate\\Mail\\Mailable->{closure:Illuminate\\Mail\\Mailable::send():202}()\n#11 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Mail\\Mailable.php(202): Illuminate\\Mail\\Mailable->withLocale()\n#12 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Mail\\SendQueuedMailable.php(89): Illuminate\\Mail\\Mailable->send()\n#13 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(36): Illuminate\\Mail\\SendQueuedMailable->handle()\n#14 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\Util.php(43): Illuminate\\Container\\BoundMethod::{closure:Illuminate\\Container\\BoundMethod::call():35}()\n#15 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(96): Illuminate\\Container\\Util::unwrapIfClosure()\n#16 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(35): Illuminate\\Container\\BoundMethod::callBoundMethod()\n#17 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\Container.php(799): Illuminate\\Container\\BoundMethod::call()\n#18 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Bus\\Dispatcher.php(136): Illuminate\\Container\\Container->call()\n#19 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Pipeline\\Pipeline.php(180): Illuminate\\Bus\\Dispatcher->{closure:Illuminate\\Bus\\Dispatcher::dispatchNow():133}()\n#20 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Pipeline\\Pipeline.php(137): Illuminate\\Pipeline\\Pipeline->{closure:Illuminate\\Pipeline\\Pipeline::prepareDestination():178}()\n#21 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Bus\\Dispatcher.php(140): Illuminate\\Pipeline\\Pipeline->then()\n#22 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\CallQueuedHandler.php(153): Illuminate\\Bus\\Dispatcher->dispatchNow()\n#23 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Pipeline\\Pipeline.php(180): Illuminate\\Queue\\CallQueuedHandler->{closure:Illuminate\\Queue\\CallQueuedHandler::dispatchThroughMiddleware():146}()\n#24 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Pipeline\\Pipeline.php(137): Illuminate\\Pipeline\\Pipeline->{closure:Illuminate\\Pipeline\\Pipeline::prepareDestination():178}()\n#25 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\CallQueuedHandler.php(146): Illuminate\\Pipeline\\Pipeline->then()\n#26 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\CallQueuedHandler.php(84): Illuminate\\Queue\\CallQueuedHandler->dispatchThroughMiddleware()\n#27 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Jobs\\Job.php(102): Illuminate\\Queue\\CallQueuedHandler->call()\n#28 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Worker.php(515): Illuminate\\Queue\\Jobs\\Job->fire()\n#29 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Worker.php(461): Illuminate\\Queue\\Worker->process()\n#30 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Worker.php(224): Illuminate\\Queue\\Worker->runJob()\n#31 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Console\\WorkCommand.php(148): Illuminate\\Queue\\Worker->daemon()\n#32 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Console\\WorkCommand.php(131): Illuminate\\Queue\\Console\\WorkCommand->runWorker()\n#33 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(36): Illuminate\\Queue\\Console\\WorkCommand->handle()\n#34 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\Util.php(43): Illuminate\\Container\\BoundMethod::{closure:Illuminate\\Container\\BoundMethod::call():35}()\n#35 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(96): Illuminate\\Container\\Util::unwrapIfClosure()\n#36 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(35): Illuminate\\Container\\BoundMethod::callBoundMethod()\n#37 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\Container.php(799): Illuminate\\Container\\BoundMethod::call()\n#38 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Console\\Command.php(280): Illuminate\\Container\\Container->call()\n#39 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\console\\Command\\Command.php(291): Illuminate\\Console\\Command->execute()\n#40 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Console\\Command.php(249): Symfony\\Component\\Console\\Command\\Command->run()\n#41 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\console\\Application.php(1107): Illuminate\\Console\\Command->run()\n#42 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\console\\Application.php(356): Symfony\\Component\\Console\\Application->doRunCommand()\n#43 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\console\\Application.php(195): Symfony\\Component\\Console\\Application->doRun()\n#44 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Foundation\\Console\\Kernel.php(198): Symfony\\Component\\Console\\Application->run()\n#45 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Foundation\\Application.php(1235): Illuminate\\Foundation\\Console\\Kernel->handle()\n#46 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\artisan(16): Illuminate\\Foundation\\Application->handleCommand()\n#47 {main}	2026-05-05 12:47:00
3	80baf79d-a1fb-4db3-822f-52bdb79a15d4	database	default	{"uuid":"80baf79d-a1fb-4db3-822f-52bdb79a15d4","displayName":"App\\\\Mail\\\\InvoiceMail","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":null,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":null,"retryUntil":null,"deleteWhenMissingModels":false,"data":{"commandName":"Illuminate\\\\Mail\\\\SendQueuedMailable","command":"O:34:\\"Illuminate\\\\Mail\\\\SendQueuedMailable\\":18:{s:8:\\"mailable\\";O:20:\\"App\\\\Mail\\\\InvoiceMail\\":4:{s:7:\\"invoice\\";O:45:\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\":5:{s:5:\\"class\\";s:18:\\"App\\\\Models\\\\Invoice\\";s:2:\\"id\\";s:36:\\"b84052ae-0b8d-44b9-ac2b-70ad6ae82076\\";s:9:\\"relations\\";a:1:{i:0;s:6:\\"tenant\\";}s:10:\\"connection\\";s:5:\\"pgsql\\";s:15:\\"collectionClass\\";N;}s:10:\\"invoiceUrl\\";s:90:\\"http:\\/\\/localhost:3001\\/inv\\/EDpHlbfdbHZdFmCOSmdDSvkTbQIteTSpwsa2KrkHPPeVWxNp5PAIJDPTYxt7OpDW\\";s:2:\\"to\\";a:1:{i:0;a:2:{s:4:\\"name\\";N;s:7:\\"address\\";s:30:\\"theophilusfrimpong17@gmail.com\\";}}s:6:\\"mailer\\";s:4:\\"smtp\\";}s:5:\\"tries\\";N;s:7:\\"timeout\\";N;s:13:\\"maxExceptions\\";N;s:17:\\"shouldBeEncrypted\\";b:0;s:3:\\"job\\";N;s:10:\\"connection\\";N;s:5:\\"queue\\";N;s:12:\\"messageGroup\\";N;s:12:\\"deduplicator\\";N;s:13:\\"debounceOwner\\";s:0:\\"\\";s:5:\\"delay\\";N;s:11:\\"afterCommit\\";N;s:10:\\"middleware\\";a:0:{}s:7:\\"chained\\";a:0:{}s:15:\\"chainConnection\\";N;s:10:\\"chainQueue\\";N;s:19:\\"chainCatchCallbacks\\";N;}","batchId":null},"createdAt":1777986514,"delay":null}	Symfony\\Component\\Mailer\\Exception\\TransportException: Connection to "sandbox.smtp.mailtrap.io:2525" timed out. in C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\Stream\\AbstractStream.php:85\nStack trace:\n#0 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\SmtpTransport.php(339): Symfony\\Component\\Mailer\\Transport\\Smtp\\Stream\\AbstractStream->readLine()\n#1 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\SmtpTransport.php(186): Symfony\\Component\\Mailer\\Transport\\Smtp\\SmtpTransport->getFullResponse()\n#2 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\EsmtpTransport.php(150): Symfony\\Component\\Mailer\\Transport\\Smtp\\SmtpTransport->executeCommand()\n#3 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\SmtpTransport.php(252): Symfony\\Component\\Mailer\\Transport\\Smtp\\EsmtpTransport->executeCommand()\n#4 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\SmtpTransport.php(204): Symfony\\Component\\Mailer\\Transport\\Smtp\\SmtpTransport->doMailFromCommand()\n#5 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\AbstractTransport.php(69): Symfony\\Component\\Mailer\\Transport\\Smtp\\SmtpTransport->doSend()\n#6 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\SmtpTransport.php(138): Symfony\\Component\\Mailer\\Transport\\AbstractTransport->send()\n#7 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Mail\\Mailer.php(584): Symfony\\Component\\Mailer\\Transport\\Smtp\\SmtpTransport->send()\n#8 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Mail\\Mailer.php(331): Illuminate\\Mail\\Mailer->sendSymfonyMessage()\n#9 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Mail\\Mailable.php(209): Illuminate\\Mail\\Mailer->send()\n#10 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Support\\Traits\\Localizable.php(19): Illuminate\\Mail\\Mailable->{closure:Illuminate\\Mail\\Mailable::send():202}()\n#11 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Mail\\Mailable.php(202): Illuminate\\Mail\\Mailable->withLocale()\n#12 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Mail\\SendQueuedMailable.php(89): Illuminate\\Mail\\Mailable->send()\n#13 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(36): Illuminate\\Mail\\SendQueuedMailable->handle()\n#14 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\Util.php(43): Illuminate\\Container\\BoundMethod::{closure:Illuminate\\Container\\BoundMethod::call():35}()\n#15 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(96): Illuminate\\Container\\Util::unwrapIfClosure()\n#16 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(35): Illuminate\\Container\\BoundMethod::callBoundMethod()\n#17 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\Container.php(799): Illuminate\\Container\\BoundMethod::call()\n#18 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Bus\\Dispatcher.php(136): Illuminate\\Container\\Container->call()\n#19 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Pipeline\\Pipeline.php(180): Illuminate\\Bus\\Dispatcher->{closure:Illuminate\\Bus\\Dispatcher::dispatchNow():133}()\n#20 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Pipeline\\Pipeline.php(137): Illuminate\\Pipeline\\Pipeline->{closure:Illuminate\\Pipeline\\Pipeline::prepareDestination():178}()\n#21 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Bus\\Dispatcher.php(140): Illuminate\\Pipeline\\Pipeline->then()\n#22 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\CallQueuedHandler.php(153): Illuminate\\Bus\\Dispatcher->dispatchNow()\n#23 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Pipeline\\Pipeline.php(180): Illuminate\\Queue\\CallQueuedHandler->{closure:Illuminate\\Queue\\CallQueuedHandler::dispatchThroughMiddleware():146}()\n#24 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Pipeline\\Pipeline.php(137): Illuminate\\Pipeline\\Pipeline->{closure:Illuminate\\Pipeline\\Pipeline::prepareDestination():178}()\n#25 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\CallQueuedHandler.php(146): Illuminate\\Pipeline\\Pipeline->then()\n#26 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\CallQueuedHandler.php(84): Illuminate\\Queue\\CallQueuedHandler->dispatchThroughMiddleware()\n#27 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Jobs\\Job.php(102): Illuminate\\Queue\\CallQueuedHandler->call()\n#28 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Worker.php(515): Illuminate\\Queue\\Jobs\\Job->fire()\n#29 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Worker.php(461): Illuminate\\Queue\\Worker->process()\n#30 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Worker.php(224): Illuminate\\Queue\\Worker->runJob()\n#31 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Console\\WorkCommand.php(148): Illuminate\\Queue\\Worker->daemon()\n#32 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Console\\WorkCommand.php(131): Illuminate\\Queue\\Console\\WorkCommand->runWorker()\n#33 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(36): Illuminate\\Queue\\Console\\WorkCommand->handle()\n#34 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\Util.php(43): Illuminate\\Container\\BoundMethod::{closure:Illuminate\\Container\\BoundMethod::call():35}()\n#35 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(96): Illuminate\\Container\\Util::unwrapIfClosure()\n#36 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(35): Illuminate\\Container\\BoundMethod::callBoundMethod()\n#37 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\Container.php(799): Illuminate\\Container\\BoundMethod::call()\n#38 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Console\\Command.php(280): Illuminate\\Container\\Container->call()\n#39 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\console\\Command\\Command.php(291): Illuminate\\Console\\Command->execute()\n#40 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Console\\Command.php(249): Symfony\\Component\\Console\\Command\\Command->run()\n#41 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\console\\Application.php(1107): Illuminate\\Console\\Command->run()\n#42 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\console\\Application.php(356): Symfony\\Component\\Console\\Application->doRunCommand()\n#43 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\console\\Application.php(195): Symfony\\Component\\Console\\Application->doRun()\n#44 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Foundation\\Console\\Kernel.php(198): Symfony\\Component\\Console\\Application->run()\n#45 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Foundation\\Application.php(1235): Illuminate\\Foundation\\Console\\Kernel->handle()\n#46 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\artisan(16): Illuminate\\Foundation\\Application->handleCommand()\n#47 {main}	2026-05-05 13:08:58
4	1e902148-e024-44f9-9e86-6b5eb2e3a3ca	database	default	{"uuid":"1e902148-e024-44f9-9e86-6b5eb2e3a3ca","displayName":"App\\\\Mail\\\\InvoiceMail","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":null,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":null,"retryUntil":null,"deleteWhenMissingModels":false,"data":{"commandName":"Illuminate\\\\Mail\\\\SendQueuedMailable","command":"O:34:\\"Illuminate\\\\Mail\\\\SendQueuedMailable\\":18:{s:8:\\"mailable\\";O:20:\\"App\\\\Mail\\\\InvoiceMail\\":4:{s:7:\\"invoice\\";O:45:\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\":5:{s:5:\\"class\\";s:18:\\"App\\\\Models\\\\Invoice\\";s:2:\\"id\\";s:36:\\"eed874f9-f8a7-493b-92a2-0f5eba96950a\\";s:9:\\"relations\\";a:1:{i:0;s:6:\\"tenant\\";}s:10:\\"connection\\";s:5:\\"pgsql\\";s:15:\\"collectionClass\\";N;}s:10:\\"invoiceUrl\\";s:90:\\"http:\\/\\/localhost:3001\\/inv\\/bp6j4jnzEbkRSJic1lgtyeVoG6zPbeto169F7mT3fKyga2Lc9aIiCw9s9vOmVkbK\\";s:2:\\"to\\";a:1:{i:0;a:2:{s:4:\\"name\\";N;s:7:\\"address\\";s:16:\\"mariam@gmail.com\\";}}s:6:\\"mailer\\";s:4:\\"smtp\\";}s:5:\\"tries\\";N;s:7:\\"timeout\\";N;s:13:\\"maxExceptions\\";N;s:17:\\"shouldBeEncrypted\\";b:0;s:3:\\"job\\";N;s:10:\\"connection\\";N;s:5:\\"queue\\";N;s:12:\\"messageGroup\\";N;s:12:\\"deduplicator\\";N;s:13:\\"debounceOwner\\";s:0:\\"\\";s:5:\\"delay\\";N;s:11:\\"afterCommit\\";N;s:10:\\"middleware\\";a:0:{}s:7:\\"chained\\";a:0:{}s:15:\\"chainConnection\\";N;s:10:\\"chainQueue\\";N;s:19:\\"chainCatchCallbacks\\";N;}","batchId":null},"createdAt":1777989298,"delay":null}	Symfony\\Component\\Mailer\\Exception\\TransportException: Connection to "sandbox.smtp.mailtrap.io:2525" timed out. in C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\Stream\\AbstractStream.php:85\nStack trace:\n#0 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\SmtpTransport.php(339): Symfony\\Component\\Mailer\\Transport\\Smtp\\Stream\\AbstractStream->readLine()\n#1 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\SmtpTransport.php(186): Symfony\\Component\\Mailer\\Transport\\Smtp\\SmtpTransport->getFullResponse()\n#2 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\EsmtpTransport.php(150): Symfony\\Component\\Mailer\\Transport\\Smtp\\SmtpTransport->executeCommand()\n#3 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\SmtpTransport.php(252): Symfony\\Component\\Mailer\\Transport\\Smtp\\EsmtpTransport->executeCommand()\n#4 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\SmtpTransport.php(204): Symfony\\Component\\Mailer\\Transport\\Smtp\\SmtpTransport->doMailFromCommand()\n#5 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\AbstractTransport.php(69): Symfony\\Component\\Mailer\\Transport\\Smtp\\SmtpTransport->doSend()\n#6 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\SmtpTransport.php(138): Symfony\\Component\\Mailer\\Transport\\AbstractTransport->send()\n#7 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Mail\\Mailer.php(584): Symfony\\Component\\Mailer\\Transport\\Smtp\\SmtpTransport->send()\n#8 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Mail\\Mailer.php(331): Illuminate\\Mail\\Mailer->sendSymfonyMessage()\n#9 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Mail\\Mailable.php(209): Illuminate\\Mail\\Mailer->send()\n#10 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Support\\Traits\\Localizable.php(19): Illuminate\\Mail\\Mailable->{closure:Illuminate\\Mail\\Mailable::send():202}()\n#11 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Mail\\Mailable.php(202): Illuminate\\Mail\\Mailable->withLocale()\n#12 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Mail\\SendQueuedMailable.php(89): Illuminate\\Mail\\Mailable->send()\n#13 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(36): Illuminate\\Mail\\SendQueuedMailable->handle()\n#14 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\Util.php(43): Illuminate\\Container\\BoundMethod::{closure:Illuminate\\Container\\BoundMethod::call():35}()\n#15 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(96): Illuminate\\Container\\Util::unwrapIfClosure()\n#16 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(35): Illuminate\\Container\\BoundMethod::callBoundMethod()\n#17 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\Container.php(799): Illuminate\\Container\\BoundMethod::call()\n#18 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Bus\\Dispatcher.php(136): Illuminate\\Container\\Container->call()\n#19 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Pipeline\\Pipeline.php(180): Illuminate\\Bus\\Dispatcher->{closure:Illuminate\\Bus\\Dispatcher::dispatchNow():133}()\n#20 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Pipeline\\Pipeline.php(137): Illuminate\\Pipeline\\Pipeline->{closure:Illuminate\\Pipeline\\Pipeline::prepareDestination():178}()\n#21 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Bus\\Dispatcher.php(140): Illuminate\\Pipeline\\Pipeline->then()\n#22 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\CallQueuedHandler.php(153): Illuminate\\Bus\\Dispatcher->dispatchNow()\n#23 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Pipeline\\Pipeline.php(180): Illuminate\\Queue\\CallQueuedHandler->{closure:Illuminate\\Queue\\CallQueuedHandler::dispatchThroughMiddleware():146}()\n#24 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Pipeline\\Pipeline.php(137): Illuminate\\Pipeline\\Pipeline->{closure:Illuminate\\Pipeline\\Pipeline::prepareDestination():178}()\n#25 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\CallQueuedHandler.php(146): Illuminate\\Pipeline\\Pipeline->then()\n#26 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\CallQueuedHandler.php(84): Illuminate\\Queue\\CallQueuedHandler->dispatchThroughMiddleware()\n#27 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Jobs\\Job.php(102): Illuminate\\Queue\\CallQueuedHandler->call()\n#28 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Worker.php(515): Illuminate\\Queue\\Jobs\\Job->fire()\n#29 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Worker.php(461): Illuminate\\Queue\\Worker->process()\n#30 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Worker.php(224): Illuminate\\Queue\\Worker->runJob()\n#31 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Console\\WorkCommand.php(148): Illuminate\\Queue\\Worker->daemon()\n#32 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Console\\WorkCommand.php(131): Illuminate\\Queue\\Console\\WorkCommand->runWorker()\n#33 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(36): Illuminate\\Queue\\Console\\WorkCommand->handle()\n#34 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\Util.php(43): Illuminate\\Container\\BoundMethod::{closure:Illuminate\\Container\\BoundMethod::call():35}()\n#35 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(96): Illuminate\\Container\\Util::unwrapIfClosure()\n#36 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(35): Illuminate\\Container\\BoundMethod::callBoundMethod()\n#37 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\Container.php(799): Illuminate\\Container\\BoundMethod::call()\n#38 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Console\\Command.php(280): Illuminate\\Container\\Container->call()\n#39 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\console\\Command\\Command.php(291): Illuminate\\Console\\Command->execute()\n#40 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Console\\Command.php(249): Symfony\\Component\\Console\\Command\\Command->run()\n#41 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\console\\Application.php(1107): Illuminate\\Console\\Command->run()\n#42 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\console\\Application.php(356): Symfony\\Component\\Console\\Application->doRunCommand()\n#43 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\console\\Application.php(195): Symfony\\Component\\Console\\Application->doRun()\n#44 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Foundation\\Console\\Kernel.php(198): Symfony\\Component\\Console\\Application->run()\n#45 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Foundation\\Application.php(1235): Illuminate\\Foundation\\Console\\Kernel->handle()\n#46 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\artisan(16): Illuminate\\Foundation\\Application->handleCommand()\n#47 {main}	2026-05-05 13:56:04
5	8a3433b9-5f4a-46e1-83f6-392da5e5e9bd	database	default	{"uuid":"8a3433b9-5f4a-46e1-83f6-392da5e5e9bd","displayName":"App\\\\Mail\\\\InvoiceMail","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":null,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":null,"retryUntil":null,"deleteWhenMissingModels":false,"data":{"commandName":"Illuminate\\\\Mail\\\\SendQueuedMailable","command":"O:34:\\"Illuminate\\\\Mail\\\\SendQueuedMailable\\":18:{s:8:\\"mailable\\";O:20:\\"App\\\\Mail\\\\InvoiceMail\\":4:{s:7:\\"invoice\\";O:45:\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\":5:{s:5:\\"class\\";s:18:\\"App\\\\Models\\\\Invoice\\";s:2:\\"id\\";s:36:\\"eed874f9-f8a7-493b-92a2-0f5eba96950a\\";s:9:\\"relations\\";a:1:{i:0;s:6:\\"tenant\\";}s:10:\\"connection\\";s:5:\\"pgsql\\";s:15:\\"collectionClass\\";N;}s:10:\\"invoiceUrl\\";s:90:\\"http:\\/\\/localhost:3001\\/inv\\/t26K2K1Z6y9rfnXRRH6u73F2c2yeq4BlcvMoo1EKfH9VmCU13RvcggmBxkr1NCGT\\";s:2:\\"to\\";a:1:{i:0;a:2:{s:4:\\"name\\";N;s:7:\\"address\\";s:16:\\"mariam@gmail.com\\";}}s:6:\\"mailer\\";s:4:\\"smtp\\";}s:5:\\"tries\\";N;s:7:\\"timeout\\";N;s:13:\\"maxExceptions\\";N;s:17:\\"shouldBeEncrypted\\";b:0;s:3:\\"job\\";N;s:10:\\"connection\\";N;s:5:\\"queue\\";N;s:12:\\"messageGroup\\";N;s:12:\\"deduplicator\\";N;s:13:\\"debounceOwner\\";s:0:\\"\\";s:5:\\"delay\\";N;s:11:\\"afterCommit\\";N;s:10:\\"middleware\\";a:0:{}s:7:\\"chained\\";a:0:{}s:15:\\"chainConnection\\";N;s:10:\\"chainQueue\\";N;s:19:\\"chainCatchCallbacks\\";N;}","batchId":null},"createdAt":1777989684,"delay":null}	Symfony\\Component\\Mailer\\Exception\\TransportException: Connection to "sandbox.smtp.mailtrap.io:2525" timed out. in C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\Stream\\AbstractStream.php:85\nStack trace:\n#0 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\SmtpTransport.php(339): Symfony\\Component\\Mailer\\Transport\\Smtp\\Stream\\AbstractStream->readLine()\n#1 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\SmtpTransport.php(186): Symfony\\Component\\Mailer\\Transport\\Smtp\\SmtpTransport->getFullResponse()\n#2 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\EsmtpTransport.php(150): Symfony\\Component\\Mailer\\Transport\\Smtp\\SmtpTransport->executeCommand()\n#3 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\SmtpTransport.php(252): Symfony\\Component\\Mailer\\Transport\\Smtp\\EsmtpTransport->executeCommand()\n#4 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\SmtpTransport.php(204): Symfony\\Component\\Mailer\\Transport\\Smtp\\SmtpTransport->doMailFromCommand()\n#5 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\AbstractTransport.php(69): Symfony\\Component\\Mailer\\Transport\\Smtp\\SmtpTransport->doSend()\n#6 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\SmtpTransport.php(138): Symfony\\Component\\Mailer\\Transport\\AbstractTransport->send()\n#7 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Mail\\Mailer.php(584): Symfony\\Component\\Mailer\\Transport\\Smtp\\SmtpTransport->send()\n#8 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Mail\\Mailer.php(331): Illuminate\\Mail\\Mailer->sendSymfonyMessage()\n#9 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Mail\\Mailable.php(209): Illuminate\\Mail\\Mailer->send()\n#10 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Support\\Traits\\Localizable.php(19): Illuminate\\Mail\\Mailable->{closure:Illuminate\\Mail\\Mailable::send():202}()\n#11 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Mail\\Mailable.php(202): Illuminate\\Mail\\Mailable->withLocale()\n#12 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Mail\\SendQueuedMailable.php(89): Illuminate\\Mail\\Mailable->send()\n#13 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(36): Illuminate\\Mail\\SendQueuedMailable->handle()\n#14 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\Util.php(43): Illuminate\\Container\\BoundMethod::{closure:Illuminate\\Container\\BoundMethod::call():35}()\n#15 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(96): Illuminate\\Container\\Util::unwrapIfClosure()\n#16 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(35): Illuminate\\Container\\BoundMethod::callBoundMethod()\n#17 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\Container.php(799): Illuminate\\Container\\BoundMethod::call()\n#18 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Bus\\Dispatcher.php(136): Illuminate\\Container\\Container->call()\n#19 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Pipeline\\Pipeline.php(180): Illuminate\\Bus\\Dispatcher->{closure:Illuminate\\Bus\\Dispatcher::dispatchNow():133}()\n#20 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Pipeline\\Pipeline.php(137): Illuminate\\Pipeline\\Pipeline->{closure:Illuminate\\Pipeline\\Pipeline::prepareDestination():178}()\n#21 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Bus\\Dispatcher.php(140): Illuminate\\Pipeline\\Pipeline->then()\n#22 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\CallQueuedHandler.php(153): Illuminate\\Bus\\Dispatcher->dispatchNow()\n#23 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Pipeline\\Pipeline.php(180): Illuminate\\Queue\\CallQueuedHandler->{closure:Illuminate\\Queue\\CallQueuedHandler::dispatchThroughMiddleware():146}()\n#24 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Pipeline\\Pipeline.php(137): Illuminate\\Pipeline\\Pipeline->{closure:Illuminate\\Pipeline\\Pipeline::prepareDestination():178}()\n#25 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\CallQueuedHandler.php(146): Illuminate\\Pipeline\\Pipeline->then()\n#26 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\CallQueuedHandler.php(84): Illuminate\\Queue\\CallQueuedHandler->dispatchThroughMiddleware()\n#27 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Jobs\\Job.php(102): Illuminate\\Queue\\CallQueuedHandler->call()\n#28 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Worker.php(515): Illuminate\\Queue\\Jobs\\Job->fire()\n#29 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Worker.php(461): Illuminate\\Queue\\Worker->process()\n#30 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Worker.php(224): Illuminate\\Queue\\Worker->runJob()\n#31 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Console\\WorkCommand.php(148): Illuminate\\Queue\\Worker->daemon()\n#32 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Console\\WorkCommand.php(131): Illuminate\\Queue\\Console\\WorkCommand->runWorker()\n#33 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(36): Illuminate\\Queue\\Console\\WorkCommand->handle()\n#34 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\Util.php(43): Illuminate\\Container\\BoundMethod::{closure:Illuminate\\Container\\BoundMethod::call():35}()\n#35 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(96): Illuminate\\Container\\Util::unwrapIfClosure()\n#36 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(35): Illuminate\\Container\\BoundMethod::callBoundMethod()\n#37 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\Container.php(799): Illuminate\\Container\\BoundMethod::call()\n#38 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Console\\Command.php(280): Illuminate\\Container\\Container->call()\n#39 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\console\\Command\\Command.php(291): Illuminate\\Console\\Command->execute()\n#40 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Console\\Command.php(249): Symfony\\Component\\Console\\Command\\Command->run()\n#41 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\console\\Application.php(1107): Illuminate\\Console\\Command->run()\n#42 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\console\\Application.php(356): Symfony\\Component\\Console\\Application->doRunCommand()\n#43 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\console\\Application.php(195): Symfony\\Component\\Console\\Application->doRun()\n#44 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Foundation\\Console\\Kernel.php(198): Symfony\\Component\\Console\\Application->run()\n#45 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Foundation\\Application.php(1235): Illuminate\\Foundation\\Console\\Kernel->handle()\n#46 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\artisan(16): Illuminate\\Foundation\\Application->handleCommand()\n#47 {main}	2026-05-05 14:01:27
6	6e379fed-63cb-45bb-8da9-b36a0ba5d8e8	database	default	{"uuid":"6e379fed-63cb-45bb-8da9-b36a0ba5d8e8","displayName":"App\\\\Mail\\\\InviteMail","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":null,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":null,"retryUntil":null,"deleteWhenMissingModels":false,"data":{"commandName":"Illuminate\\\\Mail\\\\SendQueuedMailable","command":"O:34:\\"Illuminate\\\\Mail\\\\SendQueuedMailable\\":18:{s:8:\\"mailable\\";O:19:\\"App\\\\Mail\\\\InviteMail\\":4:{s:6:\\"invite\\";O:45:\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\":5:{s:5:\\"class\\";s:17:\\"App\\\\Models\\\\Invite\\";s:2:\\"id\\";s:36:\\"48ab9c79-1f68-4ea9-93bc-fd14fd25f871\\";s:9:\\"relations\\";a:2:{i:0;s:6:\\"tenant\\";i:1;s:9:\\"invitedBy\\";}s:10:\\"connection\\";s:5:\\"pgsql\\";s:15:\\"collectionClass\\";N;}s:9:\\"acceptUrl\\";s:106:\\"http:\\/\\/localhost:3001\\/invite\\/accept?token=IFqYP3QjsPvN1Z6u8vsFyacAuuknIgGWKUp5y8qlpFFAz6az8TSX6mRwMtcqTkjN\\";s:2:\\"to\\";a:1:{i:0;a:2:{s:4:\\"name\\";N;s:7:\\"address\\";s:19:\\"testadmin@gmail.com\\";}}s:6:\\"mailer\\";s:4:\\"smtp\\";}s:5:\\"tries\\";N;s:7:\\"timeout\\";N;s:13:\\"maxExceptions\\";N;s:17:\\"shouldBeEncrypted\\";b:0;s:3:\\"job\\";N;s:10:\\"connection\\";N;s:5:\\"queue\\";N;s:12:\\"messageGroup\\";N;s:12:\\"deduplicator\\";N;s:13:\\"debounceOwner\\";s:0:\\"\\";s:5:\\"delay\\";N;s:11:\\"afterCommit\\";N;s:10:\\"middleware\\";a:0:{}s:7:\\"chained\\";a:0:{}s:15:\\"chainConnection\\";N;s:10:\\"chainQueue\\";N;s:19:\\"chainCatchCallbacks\\";N;}","batchId":null},"createdAt":1778076284,"delay":null}	Symfony\\Component\\Mailer\\Exception\\UnexpectedResponseException: Expected response code "354" but got code "550", with message "550 5.7.0 Too many emails per second. Please upgrade your plan https://mailtrap.io/billing/plans/testing". in C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\SmtpTransport.php:331\nStack trace:\n#0 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\SmtpTransport.php(187): Symfony\\Component\\Mailer\\Transport\\Smtp\\SmtpTransport->assertResponseCode()\n#1 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\EsmtpTransport.php(150): Symfony\\Component\\Mailer\\Transport\\Smtp\\SmtpTransport->executeCommand()\n#2 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\SmtpTransport.php(209): Symfony\\Component\\Mailer\\Transport\\Smtp\\EsmtpTransport->executeCommand()\n#3 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\AbstractTransport.php(69): Symfony\\Component\\Mailer\\Transport\\Smtp\\SmtpTransport->doSend()\n#4 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\mailer\\Transport\\Smtp\\SmtpTransport.php(138): Symfony\\Component\\Mailer\\Transport\\AbstractTransport->send()\n#5 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Mail\\Mailer.php(584): Symfony\\Component\\Mailer\\Transport\\Smtp\\SmtpTransport->send()\n#6 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Mail\\Mailer.php(331): Illuminate\\Mail\\Mailer->sendSymfonyMessage()\n#7 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Mail\\Mailable.php(209): Illuminate\\Mail\\Mailer->send()\n#8 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Support\\Traits\\Localizable.php(19): Illuminate\\Mail\\Mailable->{closure:Illuminate\\Mail\\Mailable::send():202}()\n#9 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Mail\\Mailable.php(202): Illuminate\\Mail\\Mailable->withLocale()\n#10 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Mail\\SendQueuedMailable.php(89): Illuminate\\Mail\\Mailable->send()\n#11 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(36): Illuminate\\Mail\\SendQueuedMailable->handle()\n#12 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\Util.php(43): Illuminate\\Container\\BoundMethod::{closure:Illuminate\\Container\\BoundMethod::call():35}()\n#13 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(96): Illuminate\\Container\\Util::unwrapIfClosure()\n#14 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(35): Illuminate\\Container\\BoundMethod::callBoundMethod()\n#15 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\Container.php(799): Illuminate\\Container\\BoundMethod::call()\n#16 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Bus\\Dispatcher.php(136): Illuminate\\Container\\Container->call()\n#17 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Pipeline\\Pipeline.php(180): Illuminate\\Bus\\Dispatcher->{closure:Illuminate\\Bus\\Dispatcher::dispatchNow():133}()\n#18 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Pipeline\\Pipeline.php(137): Illuminate\\Pipeline\\Pipeline->{closure:Illuminate\\Pipeline\\Pipeline::prepareDestination():178}()\n#19 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Bus\\Dispatcher.php(140): Illuminate\\Pipeline\\Pipeline->then()\n#20 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\CallQueuedHandler.php(153): Illuminate\\Bus\\Dispatcher->dispatchNow()\n#21 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Pipeline\\Pipeline.php(180): Illuminate\\Queue\\CallQueuedHandler->{closure:Illuminate\\Queue\\CallQueuedHandler::dispatchThroughMiddleware():146}()\n#22 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Pipeline\\Pipeline.php(137): Illuminate\\Pipeline\\Pipeline->{closure:Illuminate\\Pipeline\\Pipeline::prepareDestination():178}()\n#23 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\CallQueuedHandler.php(146): Illuminate\\Pipeline\\Pipeline->then()\n#24 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\CallQueuedHandler.php(84): Illuminate\\Queue\\CallQueuedHandler->dispatchThroughMiddleware()\n#25 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Jobs\\Job.php(102): Illuminate\\Queue\\CallQueuedHandler->call()\n#26 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Worker.php(515): Illuminate\\Queue\\Jobs\\Job->fire()\n#27 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Worker.php(461): Illuminate\\Queue\\Worker->process()\n#28 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Worker.php(224): Illuminate\\Queue\\Worker->runJob()\n#29 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Console\\WorkCommand.php(148): Illuminate\\Queue\\Worker->daemon()\n#30 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Queue\\Console\\WorkCommand.php(131): Illuminate\\Queue\\Console\\WorkCommand->runWorker()\n#31 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(36): Illuminate\\Queue\\Console\\WorkCommand->handle()\n#32 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\Util.php(43): Illuminate\\Container\\BoundMethod::{closure:Illuminate\\Container\\BoundMethod::call():35}()\n#33 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(96): Illuminate\\Container\\Util::unwrapIfClosure()\n#34 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\BoundMethod.php(35): Illuminate\\Container\\BoundMethod::callBoundMethod()\n#35 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Container\\Container.php(799): Illuminate\\Container\\BoundMethod::call()\n#36 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Console\\Command.php(280): Illuminate\\Container\\Container->call()\n#37 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\console\\Command\\Command.php(291): Illuminate\\Console\\Command->execute()\n#38 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Console\\Command.php(249): Symfony\\Component\\Console\\Command\\Command->run()\n#39 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\console\\Application.php(1107): Illuminate\\Console\\Command->run()\n#40 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\console\\Application.php(356): Symfony\\Component\\Console\\Application->doRunCommand()\n#41 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\symfony\\console\\Application.php(195): Symfony\\Component\\Console\\Application->doRun()\n#42 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Foundation\\Console\\Kernel.php(198): Symfony\\Component\\Console\\Application->run()\n#43 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\vendor\\laravel\\framework\\src\\Illuminate\\Foundation\\Application.php(1235): Illuminate\\Foundation\\Console\\Kernel->handle()\n#44 C:\\Users\\HP\\Kobi\\tua_ka\\tuaka-api\\artisan(16): Illuminate\\Foundation\\Application->handleCommand()\n#45 {main}	2026-05-06 14:04:45
\.


--
-- Data for Name: invites; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invites (id, tenant_id, invited_by, email, role, token, expires_at, accepted_at, created_at, updated_at) FROM stdin;
48ab9c79-1f68-4ea9-93bc-fd14fd25f871	abbb1866-9613-456a-96d0-c22ab063f448	dd8732fa-8c79-4a44-a034-fb1272791f08	testadmin@gmail.com	admin	IFqYP3QjsPvN1Z6u8vsFyacAuuknIgGWKUp5y8qlpFFAz6az8TSX6mRwMtcqTkjN	2026-05-08 14:04:44	\N	2026-05-06 14:04:44	2026-05-06 14:04:44
cf1d5d0b-7cf0-41b3-a22e-dfba2b24a3c6	abbb1866-9613-456a-96d0-c22ab063f448	dd8732fa-8c79-4a44-a034-fb1272791f08	test@gmail.com	member	z9UNDGZpHQG6LnhfsQzC5N3SNP0j6KoN7dj75qsyBRFwrTKDbdTG0slgVeq7xNsn	2026-05-08 14:04:30	2026-05-06 14:05:22	2026-05-06 14:04:30	2026-05-06 14:05:22
641c7e84-fede-4df5-b774-82d7a30ecf05	04e240e3-e4de-4dfa-87bd-fad64e3fb803	d3290a06-5d9c-45b9-8263-98cbb960e49b	ama123@gmail.com	member	ijofeziWZa5u9SAKma4QKQtwWSud6IMGtOHeHoIu4woUgupA1uVEUSJ6WnDCNuw2	2026-05-09 12:35:47	\N	2026-05-07 12:35:47	2026-05-07 12:35:47
055453aa-def8-4859-b16e-0a530dd4a68c	f5248b0c-7637-4233-863f-059d7f28383b	b1382f86-7c0f-4f2f-a3c0-646c013f8f07	youngdon@gmail.com	member	8bnxXLRvrTHDsUdzUwVs6CeeKWWLihZJiNJ2i7HdXLHVCSglvNsgA3TCfjJjPcPE	2026-05-09 13:23:55	\N	2026-05-07 13:23:55	2026-05-07 13:23:55
\.


--
-- Data for Name: invoice_activities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invoice_activities (id, invoice_id, type, meta, created_at) FROM stdin;
7c462780-6419-4e63-8f74-007409b4a2c9	172d2eff-4058-4ef0-8f36-5e92e585d24f	created	{"by": "d3290a06-5d9c-45b9-8263-98cbb960e49b"}	2026-05-05 02:00:43
32a170ea-358d-4e56-91f9-e2a30476f9a0	2f99a354-7868-4459-a369-a8a53c49bf0f	created	{"by": "d3290a06-5d9c-45b9-8263-98cbb960e49b"}	2026-05-05 02:20:23
f26aaeda-0c55-47b8-a05e-2d052210f9c6	2f99a354-7868-4459-a369-a8a53c49bf0f	paid	{"paid_at": "2026-05-05T02:45:57+00:00"}	2026-05-05 02:45:57
56c9bb0c-2480-4c8a-b0b1-ab94cd32ac76	172d2eff-4058-4ef0-8f36-5e92e585d24f	paid	{"paid_at": "2026-05-05T02:52:32+00:00"}	2026-05-05 02:52:32
2f23b51b-6be6-4671-9ddc-caf4f45d3df5	34cf3aa8-e59e-42d2-91cb-0bcfbeb1954f	created	{"by": "d3290a06-5d9c-45b9-8263-98cbb960e49b"}	2026-05-05 10:54:09
e1e7f27e-2e16-4f75-b775-049922199cf8	34cf3aa8-e59e-42d2-91cb-0bcfbeb1954f	sent	{"to": "mariam@gmail.com", "sent_at": "2026-05-05T10:58:59+00:00"}	2026-05-05 10:58:59
d966c907-cc53-4e2e-82ff-97717639329f	34cf3aa8-e59e-42d2-91cb-0bcfbeb1954f	paid	{"paid_at": "2026-05-05T11:00:15+00:00"}	2026-05-05 11:00:15
d407ddb2-7467-4c07-b01f-e569b1d9eea5	b84052ae-0b8d-44b9-ac2b-70ad6ae82076	created	{"by": "d3290a06-5d9c-45b9-8263-98cbb960e49b"}	2026-05-05 12:05:06
b9ec7937-5217-494e-ad13-d132cb9ebe2c	b84052ae-0b8d-44b9-ac2b-70ad6ae82076	sent	{"to": "theophilusfrimpong17@gmail.com", "sent_at": "2026-05-05T12:06:24+00:00"}	2026-05-05 12:06:24
125418f6-e4ef-44c7-ac5d-0b8333f9adae	b84052ae-0b8d-44b9-ac2b-70ad6ae82076	sent	{"to": "theophilusfrimpong17@gmail.com", "sent_at": "2026-05-05T12:38:48+00:00"}	2026-05-05 12:38:48
d29e71d3-0154-4778-9c66-a2e0327e174f	b84052ae-0b8d-44b9-ac2b-70ad6ae82076	sent	{"to": "theophilusfrimpong17@gmail.com", "sent_at": "2026-05-05T12:44:47+00:00"}	2026-05-05 12:44:47
3e1239f1-31f8-45ba-9a34-4e4de26e33a9	b84052ae-0b8d-44b9-ac2b-70ad6ae82076	sent	{"to": "theophilusfrimpong17@gmail.com", "sent_at": "2026-05-05T12:45:56+00:00"}	2026-05-05 12:45:56
409a7ff9-1cd3-4dc3-b234-32f633f8b4b2	b84052ae-0b8d-44b9-ac2b-70ad6ae82076	sent	{"to": "theophilusfrimpong17@gmail.com", "sent_at": "2026-05-05T13:08:34+00:00"}	2026-05-05 13:08:34
e894e1dc-e8a2-481e-8f57-46469690bc7a	d7068cb6-19a6-4f41-bcfa-dd20c91012f9	created	{"by": "d3290a06-5d9c-45b9-8263-98cbb960e49b"}	2026-05-05 13:09:13
691ae473-e7cb-4df5-b6e6-f9fa9c8f1e0a	d7068cb6-19a6-4f41-bcfa-dd20c91012f9	sent	{"to": "theophilusfrimpong17@gmail.com", "sent_at": "2026-05-05T13:09:24+00:00"}	2026-05-05 13:09:24
fb1816a3-4217-40aa-9d03-451645320fd6	d7068cb6-19a6-4f41-bcfa-dd20c91012f9	viewed	{"ip": "127.0.0.1"}	2026-05-05 13:45:02
c98300ab-d83d-4bbd-b8a4-0b5c27ebe1b8	d7068cb6-19a6-4f41-bcfa-dd20c91012f9	viewed	{"ip": "127.0.0.1"}	2026-05-05 13:46:30
a90379e5-e542-483d-a921-80d5c163a160	d7068cb6-19a6-4f41-bcfa-dd20c91012f9	viewed	{"ip": "127.0.0.1"}	2026-05-05 13:49:43
c0a786ef-3b1b-4f59-8d60-5f8b39b5e41e	d7068cb6-19a6-4f41-bcfa-dd20c91012f9	viewed	{"ip": "127.0.0.1"}	2026-05-05 13:52:33
35bb4f17-6cc5-4318-bcb1-ae0739d6215c	b84052ae-0b8d-44b9-ac2b-70ad6ae82076	sent	{"to": "theophilusfrimpong17@gmail.com", "sent_at": "2026-05-05T13:53:31+00:00"}	2026-05-05 13:53:31
e6f31976-9b1f-4d38-84fa-ee27bf922d37	d7068cb6-19a6-4f41-bcfa-dd20c91012f9	viewed	{"ip": "127.0.0.1"}	2026-05-05 13:54:07
dab491df-fc12-4dc2-8091-36e27bec82df	eed874f9-f8a7-493b-92a2-0f5eba96950a	created	{"by": "d3290a06-5d9c-45b9-8263-98cbb960e49b"}	2026-05-05 13:54:51
14715e66-e30a-4e2e-aa60-dc1ac33ae270	eed874f9-f8a7-493b-92a2-0f5eba96950a	sent	{"to": "mariam@gmail.com", "sent_at": "2026-05-05T13:54:58+00:00"}	2026-05-05 13:54:58
542d4763-80fb-432e-8de7-22a3e466d386	d7068cb6-19a6-4f41-bcfa-dd20c91012f9	viewed	{"ip": "127.0.0.1"}	2026-05-05 13:55:22
b7820f9e-c08f-44fd-bb7c-23250ccfea87	d7068cb6-19a6-4f41-bcfa-dd20c91012f9	viewed	{"ip": "127.0.0.1"}	2026-05-05 14:00:58
cdde05ef-36f8-4b75-a2c5-f01ec8017d63	eed874f9-f8a7-493b-92a2-0f5eba96950a	sent	{"to": "mariam@gmail.com", "sent_at": "2026-05-05T14:01:24+00:00"}	2026-05-05 14:01:24
32d4d2dd-82a2-49e1-8f33-d45e3e0d4a49	d7068cb6-19a6-4f41-bcfa-dd20c91012f9	viewed	{"ip": "127.0.0.1"}	2026-05-05 14:05:52
58968804-bec4-4101-b554-2f4ce25cb773	d7068cb6-19a6-4f41-bcfa-dd20c91012f9	viewed	{"ip": "127.0.0.1"}	2026-05-05 14:27:52
3a2ca439-cad0-461f-b1eb-feace9bd247c	d7068cb6-19a6-4f41-bcfa-dd20c91012f9	viewed	{"ip": "127.0.0.1"}	2026-05-05 14:29:23
be68f1ca-dfdc-48cb-a1b5-be231a8f1428	d7068cb6-19a6-4f41-bcfa-dd20c91012f9	viewed	{"ip": "127.0.0.1"}	2026-05-05 18:02:15
da727679-0548-450b-ae6a-20e562b6df0d	d7068cb6-19a6-4f41-bcfa-dd20c91012f9	viewed	{"ip": "127.0.0.1"}	2026-05-05 18:14:30
577b4209-8776-4f0f-948e-699266ad6c32	d7068cb6-19a6-4f41-bcfa-dd20c91012f9	viewed	{"ip": "127.0.0.1"}	2026-05-05 18:18:09
3c99b74a-b28a-48b2-a463-48037c3c6db8	d7068cb6-19a6-4f41-bcfa-dd20c91012f9	viewed	{"ip": "127.0.0.1"}	2026-05-05 18:19:22
feff89f7-d3d4-4917-9086-049121a8f15c	d7068cb6-19a6-4f41-bcfa-dd20c91012f9	viewed	{"ip": "127.0.0.1"}	2026-05-05 18:20:29
b8037aa7-8e03-46cb-b595-c2c5a4063dab	d7068cb6-19a6-4f41-bcfa-dd20c91012f9	viewed	{"ip": "127.0.0.1"}	2026-05-05 18:39:58
59f8fd28-2a2d-4ae0-aba2-cdc975298d4e	d7068cb6-19a6-4f41-bcfa-dd20c91012f9	viewed	{"ip": "127.0.0.1"}	2026-05-05 18:50:38
caadd389-1f10-46b2-a4bf-761f5abbaea5	d7068cb6-19a6-4f41-bcfa-dd20c91012f9	viewed	{"ip": "127.0.0.1"}	2026-05-05 18:59:22
a23e438d-950c-4b9d-80f3-31ecdf8ebdcb	d7068cb6-19a6-4f41-bcfa-dd20c91012f9	viewed	{"ip": "127.0.0.1"}	2026-05-05 19:01:18
048dfad5-e5f7-4fa3-b077-eb468f304633	d7068cb6-19a6-4f41-bcfa-dd20c91012f9	viewed	{"ip": "127.0.0.1"}	2026-05-05 19:05:38
1c4ca421-940e-4a0f-ad3e-a387f862ad92	33d54ff4-a766-47a2-a91c-f2d00016d2e9	created	{"by": "d3290a06-5d9c-45b9-8263-98cbb960e49b"}	2026-05-05 19:06:57
9060bcb6-1c8e-4f04-bfab-83d6a5460eb8	33d54ff4-a766-47a2-a91c-f2d00016d2e9	sent	{"to": "theophilusfrimpong17@gmail.com", "sent_at": "2026-05-05T19:07:07+00:00"}	2026-05-05 19:07:07
2775ca66-b002-4529-b7e1-3eb495d7c6ae	33d54ff4-a766-47a2-a91c-f2d00016d2e9	viewed	{"ip": "127.0.0.1"}	2026-05-05 19:07:49
a9d02d16-6bbc-44f7-823e-ea47032f02c8	33d54ff4-a766-47a2-a91c-f2d00016d2e9	viewed	{"ip": "127.0.0.1"}	2026-05-05 19:17:34
7d3f03fa-795f-41fb-8dcc-7b5ef2739c62	8b09a282-18bc-4ca5-b830-6cc7fb84dbd9	created	{"by": "d3290a06-5d9c-45b9-8263-98cbb960e49b"}	2026-05-05 19:24:12
ca826069-4cf2-474f-ae61-1ebc2d8114fc	8b09a282-18bc-4ca5-b830-6cc7fb84dbd9	sent	{"to": "ama@owusu.com", "sent_at": "2026-05-05T19:25:43+00:00"}	2026-05-05 19:25:43
a22c6e56-9a6f-48d6-8db4-c39b1a70b1be	8b09a282-18bc-4ca5-b830-6cc7fb84dbd9	viewed	{"ip": "127.0.0.1"}	2026-05-05 19:26:11
9850a04b-2019-449e-8e98-cc423a1734d0	8b09a282-18bc-4ca5-b830-6cc7fb84dbd9	viewed	{"ip": "127.0.0.1"}	2026-05-05 19:29:10
d08cb267-d524-4ad2-9f21-9a88e9e91286	7b1ba67c-0a28-404f-b5d9-b9db602d16f5	created	{"by": "d3290a06-5d9c-45b9-8263-98cbb960e49b"}	2026-05-05 19:39:17
709eb5a7-db16-4313-846b-644b3b9a90a5	7b1ba67c-0a28-404f-b5d9-b9db602d16f5	sent	{"to": "mariam@gmail.com", "sent_at": "2026-05-05T19:39:25+00:00"}	2026-05-05 19:39:25
4da4cace-5594-4e28-ab43-4149aa75e514	7b1ba67c-0a28-404f-b5d9-b9db602d16f5	viewed	{"ip": "127.0.0.1"}	2026-05-05 19:40:19
498a573c-08fa-464e-806d-76df0ba0b697	7b1ba67c-0a28-404f-b5d9-b9db602d16f5	paid	{"paid_at": "2026-05-05T19:40:54+00:00"}	2026-05-05 19:40:54
50b3efbb-4a7f-4416-94ef-b67ae8867f63	7b1ba67c-0a28-404f-b5d9-b9db602d16f5	viewed	{"ip": "127.0.0.1"}	2026-05-05 19:42:24
b747975d-e645-4b62-9e94-0746599ed784	8b09a282-18bc-4ca5-b830-6cc7fb84dbd9	viewed	{"ip": "127.0.0.1"}	2026-05-05 19:42:25
14c7946c-7389-4c52-ae23-c6a6b1a2ea4e	8b09a282-18bc-4ca5-b830-6cc7fb84dbd9	viewed	{"ip": "127.0.0.1"}	2026-05-05 20:55:26
61ff7808-ac07-4868-becb-122a20e9788b	8b09a282-18bc-4ca5-b830-6cc7fb84dbd9	viewed	{"ip": "127.0.0.1"}	2026-05-05 22:53:16
9b8f73dd-a3b8-4023-b4a0-b5ca76de2667	de78bf1c-0c16-4a4c-97a7-770ae36fa868	created	{"by": "dd8732fa-8c79-4a44-a034-fb1272791f08"}	2026-05-06 12:04:32
65133275-0990-4b41-88d0-cadfe87ff646	de78bf1c-0c16-4a4c-97a7-770ae36fa868	sent	{"to": "agoo@gmail.com", "sent_at": "2026-05-06T12:05:05+00:00"}	2026-05-06 12:05:05
f099e717-4eed-432f-bdba-e9011df1860f	de78bf1c-0c16-4a4c-97a7-770ae36fa868	viewed	{"ip": "127.0.0.1"}	2026-05-06 12:06:29
052e076a-9477-4d69-9790-ab7b0cf0ee94	de78bf1c-0c16-4a4c-97a7-770ae36fa868	viewed	{"ip": "127.0.0.1"}	2026-05-06 12:14:54
2ac5629e-864a-4e88-8530-68b105e24dbb	de78bf1c-0c16-4a4c-97a7-770ae36fa868	viewed	{"ip": "127.0.0.1"}	2026-05-06 12:25:58
07fb8397-1ddb-4836-be4f-077f0900f383	de78bf1c-0c16-4a4c-97a7-770ae36fa868	viewed	{"ip": "127.0.0.1"}	2026-05-06 13:35:07
b1135484-ea57-4303-a227-3fe5e5193edc	de78bf1c-0c16-4a4c-97a7-770ae36fa868	viewed	{"ip": "127.0.0.1"}	2026-05-06 13:39:47
a4ef5caa-438d-4e3b-839c-8c153b167690	de78bf1c-0c16-4a4c-97a7-770ae36fa868	viewed	{"ip": "127.0.0.1"}	2026-05-06 13:47:42
ed2880f4-5afe-4d5d-8bdb-6b50e035ae6d	d7068cb6-19a6-4f41-bcfa-dd20c91012f9	reminder	{"sent_at": "2026-05-07T11:54:00+00:00", "sent_to": "theophilusfrimpong17@gmail.com", "days_until_due": 1}	2026-05-07 11:54:00
d0b07fcd-6168-489b-887f-06682a984fc6	d7068cb6-19a6-4f41-bcfa-dd20c91012f9	viewed	{"ip": "127.0.0.1"}	2026-05-07 11:54:48
1be34121-973a-477a-83c1-a49df815db6c	d7068cb6-19a6-4f41-bcfa-dd20c91012f9	viewed	{"ip": "127.0.0.1"}	2026-05-07 12:11:24
8c9562ec-f713-4df7-bc74-429abbeaf46f	d7068cb6-19a6-4f41-bcfa-dd20c91012f9	reminder	{"sent_at": "2026-05-07T13:10:46+00:00", "sent_to": "theophilusfrimpong17@gmail.com", "days_until_due": 1}	2026-05-07 13:10:46
567083c0-5cb5-4b83-bfd6-3c6c31458c5b	f57aab35-bca0-464b-ae51-8652c7f8524f	created	{"by": "b1382f86-7c0f-4f2f-a3c0-646c013f8f07"}	2026-05-07 13:18:21
14b58bea-4aa6-474a-b77f-ab6893064357	f57aab35-bca0-464b-ae51-8652c7f8524f	sent	{"to": "meso@gmail.com", "sent_at": "2026-05-07T13:18:27+00:00"}	2026-05-07 13:18:27
\.


--
-- Data for Name: invoice_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invoice_items (id, invoice_id, product_id, description, quantity, unit_price, total, sort_order, created_at, updated_at) FROM stdin;
5e34ee2c-d876-4065-921b-91087f5d0b77	172d2eff-4058-4ef0-8f36-5e92e585d24f	\N	work	10	200	2000	0	2026-05-05 02:02:57	2026-05-05 02:02:57
c9d7cd9d-9492-4e42-96d9-601005c9ea4b	2f99a354-7868-4459-a369-a8a53c49bf0f	\N	make sosos	14	3400	47600	0	2026-05-05 02:23:00	2026-05-05 02:23:00
c0a5a9b7-ce03-4ed3-be16-7779ecc32825	2f99a354-7868-4459-a369-a8a53c49bf0f	\N	something	1	2200	2200	1	2026-05-05 02:23:00	2026-05-05 02:23:00
4b4666c7-5c4c-41e1-aaed-710929f7313a	34cf3aa8-e59e-42d2-91cb-0bcfbeb1954f	\N	workmanship	1	400	400	0	2026-05-05 10:54:09	2026-05-05 10:54:09
458553d3-c85e-4805-a503-c971d0f370dd	b84052ae-0b8d-44b9-ac2b-70ad6ae82076	\N	dog s le g ls	1	200	200	0	2026-05-05 12:05:06	2026-05-05 12:05:06
bdce56e4-1be2-4002-b065-8fc782d15bc5	d7068cb6-19a6-4f41-bcfa-dd20c91012f9	\N	hfhfyj	1	500	500	0	2026-05-05 13:09:13	2026-05-05 13:09:13
54fb18bf-8926-4635-8cf4-d75e5ab64e76	eed874f9-f8a7-493b-92a2-0f5eba96950a	\N	quote for the day	1	1200	1200	0	2026-05-05 13:54:51	2026-05-05 13:54:51
67d416ae-e295-45a6-bc7e-e3554676595c	33d54ff4-a766-47a2-a91c-f2d00016d2e9	\N	Tuaka website	1	300	300	0	2026-05-05 19:06:57	2026-05-05 19:06:57
ccf9d888-c728-4d4d-9691-4f9f5e66732a	8b09a282-18bc-4ca5-b830-6cc7fb84dbd9	\N	ama's service 1	45	4500	202500	0	2026-05-05 19:24:12	2026-05-05 19:24:12
38866c80-ed98-4403-8451-679fa31e84f6	7b1ba67c-0a28-404f-b5d9-b9db602d16f5	\N	ama's second service	9	10000	90000	0	2026-05-05 19:39:17	2026-05-05 19:39:17
95160b2a-ff19-4d41-a0ab-3a53fd4421c2	de78bf1c-0c16-4a4c-97a7-770ae36fa868	fcf9f576-caba-4c72-b162-7931448d3b10	Consultation	1	5000	5000	0	2026-05-06 12:04:32	2026-05-06 12:04:32
73c8f082-761e-4937-8553-410152a117ae	de78bf1c-0c16-4a4c-97a7-770ae36fa868	ef6cc12a-c545-43ee-9640-d722d5c4e190	Graphic Design	1	40000	40000	1	2026-05-06 12:04:32	2026-05-06 12:04:32
6992816b-9c53-449f-8f6b-25e0e3a1cc94	f57aab35-bca0-464b-ae51-8652c7f8524f	\N	make a toast	1	4400	4400	0	2026-05-07 13:18:21	2026-05-07 13:18:21
\.


--
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invoices (id, tenant_id, client_id, number, type, status, view_token, subtotal, tax_rate, tax_amount, total, notes, due_date, sent_at, viewed_at, paid_at, created_at, updated_at) FROM stdin;
de78bf1c-0c16-4a4c-97a7-770ae36fa868	abbb1866-9613-456a-96d0-c22ab063f448	d2c2a0a8-7c3b-4b0b-9c93-2274dec6ddff	INV-0001	invoice	viewed	rYh9nDX2rQFm4mC6N8n2txJhl9bLDdylXoP2MSnaAvnXngfhbiFQHdBhOpHNLPBf	45000	2	900	45900	\N	2026-05-15	2026-05-06 12:05:05	2026-05-06 12:06:29	\N	2026-05-06 12:04:32	2026-05-06 12:06:29
d7068cb6-19a6-4f41-bcfa-dd20c91012f9	04e240e3-e4de-4dfa-87bd-fad64e3fb803	ae800822-fed9-4119-8688-964ab94e5829	LVE-0005	invoice	viewed	VXmrYJbQujutB8ILFweVIAL3FZ5eOMWEJ7U46yhFr4rOr0FI9hPyko4xQlToboU5	500	0	0	500	\N	2026-05-08	2026-05-05 13:09:24	2026-05-05 13:45:02	\N	2026-05-05 13:09:13	2026-05-05 13:45:02
b84052ae-0b8d-44b9-ac2b-70ad6ae82076	04e240e3-e4de-4dfa-87bd-fad64e3fb803	ae800822-fed9-4119-8688-964ab94e5829	LVE-0004	invoice	sent	Yrjb7hQhoyyg0HCN6efurxND766UEcFzzrShzbebrZ4Zgh1sz3MmcusXq2kdKGPI	200	2	4	204	\N	2026-05-07	2026-05-05 13:53:31	\N	\N	2026-05-05 12:05:06	2026-05-05 13:53:31
2f99a354-7868-4459-a369-a8a53c49bf0f	04e240e3-e4de-4dfa-87bd-fad64e3fb803	4b82176f-b28b-4b34-ac7e-4c6ba973eeab	INV-0002	invoice	paid	GTXhCdDCkoqYYqFIK1RpL01jRJb7rB9qGVJ1oB0YwHYPaimgBiEeRoYWk1T0p7op	49800	0	0	49800	\N	2026-05-14	2026-05-05 02:45:41	\N	2026-05-05 02:45:57	2026-05-05 02:20:23	2026-05-05 02:45:57
172d2eff-4058-4ef0-8f36-5e92e585d24f	04e240e3-e4de-4dfa-87bd-fad64e3fb803	ae800822-fed9-4119-8688-964ab94e5829	INV-0001	invoice	paid	1vG5YZIUocDmPGPsLa3WBVyI9Sxlxmpax96lci18TTILu870jCJmSaqTvza38I8X	2000	1	20	2020	bank details	2026-05-07	2026-05-05 02:22:31	\N	2026-05-05 02:52:32	2026-05-05 02:00:43	2026-05-05 02:52:32
34cf3aa8-e59e-42d2-91cb-0bcfbeb1954f	04e240e3-e4de-4dfa-87bd-fad64e3fb803	4b82176f-b28b-4b34-ac7e-4c6ba973eeab	LVE-0003	invoice	paid	oeGM3Q3HpwY5nsAGJZzn95XvcFaakwFqyHwBK76hpyclcnfzHBU2lXk2Wl2v3EtZ	400	2	8	408	\N	2026-05-22	2026-05-05 10:58:58	\N	2026-05-05 11:00:15	2026-05-05 10:54:09	2026-05-05 11:00:15
eed874f9-f8a7-493b-92a2-0f5eba96950a	04e240e3-e4de-4dfa-87bd-fad64e3fb803	4b82176f-b28b-4b34-ac7e-4c6ba973eeab	QUO-0001	quote	sent	t26K2K1Z6y9rfnXRRH6u73F2c2yeq4BlcvMoo1EKfH9VmCU13RvcggmBxkr1NCGT	1200	4	48	1248	\N	2026-05-08	2026-05-05 14:01:24	\N	\N	2026-05-05 13:54:51	2026-05-05 14:01:24
f57aab35-bca0-464b-ae51-8652c7f8524f	f5248b0c-7637-4233-863f-059d7f28383b	f3362550-a159-4776-b1ac-a7e278bb5ba1	INV-0001	invoice	sent	94fnDG7niFTreBTwxGytw4LtwZGlhFPZp3iSc6yMqs5ntqeh8ZJrQBjIj5bNuofL	4400	0	0	4400	\N	\N	2026-05-07 13:18:26	\N	\N	2026-05-07 13:18:21	2026-05-07 13:18:26
33d54ff4-a766-47a2-a91c-f2d00016d2e9	04e240e3-e4de-4dfa-87bd-fad64e3fb803	ae800822-fed9-4119-8688-964ab94e5829	LVE-0006	invoice	viewed	Ik7KzHJUUjrkp6puZavBBV5RXU10h79NmSSUu2o9RzFGvuQZuLi3o98A9IbY0ivA	300	2	6	306	\N	2026-05-14	2026-05-05 19:07:06	2026-05-05 19:07:49	\N	2026-05-05 19:06:57	2026-05-05 19:07:49
8b09a282-18bc-4ca5-b830-6cc7fb84dbd9	04e240e3-e4de-4dfa-87bd-fad64e3fb803	5c01d918-4e33-4b50-bba1-2c42b7474f94	LVE-0007	invoice	viewed	q5DGsaCoDZjYO5YiSNaCfBm4cTovg0fQd2fMiQbAotnh2w5qG10yP2Wwnjg8G86f	202500	56	113400	315900	\N	2026-05-06	2026-05-05 19:25:43	2026-05-05 19:26:11	\N	2026-05-05 19:24:12	2026-05-05 19:26:11
7b1ba67c-0a28-404f-b5d9-b9db602d16f5	04e240e3-e4de-4dfa-87bd-fad64e3fb803	4b82176f-b28b-4b34-ac7e-4c6ba973eeab	LVE-0008	invoice	paid	x7AIH0uBrbHUSUaZFULnYyjuM5jz3pvsX8MKlBaMphyXFEL10hw9CnKfkB1nyIXs	90000	7	6300	96300	\N	2026-05-13	2026-05-05 19:39:25	2026-05-05 19:40:19	2026-05-05 19:40:54	2026-05-05 19:39:17	2026-05-05 19:40:54
\.


--
-- Data for Name: job_batches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job_batches (id, name, total_jobs, pending_jobs, failed_jobs, failed_job_ids, options, cancelled_at, created_at, finished_at) FROM stdin;
\.


--
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.jobs (id, queue, payload, attempts, reserved_at, available_at, created_at) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.migrations (id, migration, batch) FROM stdin;
1	0001_01_01_000000_create_users_table	1
2	0001_01_01_000001_create_cache_table	1
3	0001_01_01_000002_create_jobs_table	1
4	2026_05_01_042605_create_tenants_table	1
5	2026_05_01_042710_create_plans_table	1
6	2026_05_01_042757_create_subscriptions_table	1
7	2026_05_01_042845_create_clients_table	1
8	2026_05_01_042857_create_products_table	1
9	2026_05_01_042910_create_invoices_table	1
10	2026_05_01_042923_create_invoice_items_table	1
11	2026_05_01_042936_create_invoice_activities_table	1
12	2026_05_01_042955_create_payments_table	1
13	2026_05_01_043019_create_admins_table	1
14	2026_05_01_132454_add_tenant_id_to_users_table	1
15	2026_05_03_022131_add_missing_columns_to_tenants_table	2
16	2026_05_03_022624_recreate_users_table_with_uuid	3
17	2026_05_03_200337_add_verification_columns_to_users_table	4
18	2026_05_06_124046_create_invites_table	5
\.


--
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.password_reset_tokens (email, token, created_at) FROM stdin;
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payments (id, invoice_id, tenant_id, provider, provider_ref, amount, status, meta, paid_at, created_at, updated_at) FROM stdin;
cc321a6e-e2e3-4103-8f8a-75ab96ee4e8a	d7068cb6-19a6-4f41-bcfa-dd20c91012f9	04e240e3-e4de-4dfa-87bd-fad64e3fb803	paystack	TK-D7068CB6-MJMLUSQK	500	pending	{"email": "theophilusfrimpong17@gmail.com", "phone": "0551234987", "network": "mtn"}	\N	2026-05-05 18:52:28	2026-05-05 18:52:28
d5572a81-0868-4703-84fa-63ec2c6cfd87	33d54ff4-a766-47a2-a91c-f2d00016d2e9	04e240e3-e4de-4dfa-87bd-fad64e3fb803	paystack	TK-33D54FF4-LJAVROGR	306	pending	{"email": "theophilusfrimpong17@gmail.com", "phone": "0551234987", "network": "mtn"}	\N	2026-05-05 19:08:34	2026-05-05 19:08:34
344ef2cb-4619-4664-bc97-214d8c18407d	8b09a282-18bc-4ca5-b830-6cc7fb84dbd9	04e240e3-e4de-4dfa-87bd-fad64e3fb803	paystack	TK-8B09A282-MHNDISTD	315900	pending	{"email": "ama@owusu.com", "phone": "0551234987", "network": "mtn"}	\N	2026-05-05 19:27:24	2026-05-05 19:27:24
7d5e071d-d7ad-498f-bb90-6f435f8a9cb1	7b1ba67c-0a28-404f-b5d9-b9db602d16f5	04e240e3-e4de-4dfa-87bd-fad64e3fb803	paystack	TK-7B1BA67C-FMWGTEVK	96300	completed	{"email": "mariam@gmail.com", "phone": "0551234987", "network": "mtn", "paystack_data": {"id": 6115530291, "log": {"input": [], "errors": 0, "mobile": false, "history": [{"time": 0, "type": "action", "message": "Set payment method to mobile_money"}], "success": false, "attempts": 0, "start_time": 1778010052, "time_spent": 0}, "fees": 1878, "plan": null, "split": [], "amount": 96300, "domain": "test", "paidAt": "2026-05-05T19:40:52.000Z", "source": null, "status": "success", "channel": "mobile_money", "connect": null, "message": null, "paid_at": "2026-05-05T19:40:52.000Z", "currency": "GHS", "customer": {"id": 362216615, "email": "mariam@gmail.com", "phone": null, "metadata": null, "last_name": null, "first_name": null, "risk_action": "default", "customer_code": "CUS_y5amkfw2ugx1jwk", "international_format_phone": null}, "metadata": {"tenant_id": "04e240e3-e4de-4dfa-87bd-fad64e3fb803", "invoice_id": "7b1ba67c-0a28-404f-b5d9-b9db602d16f5", "invoice_number": "LVE-0008"}, "order_id": null, "createdAt": "2026-05-05T19:40:52.000Z", "reference": "TK-7B1BA67C-FMWGTEVK", "created_at": "2026-05-05T19:40:52.000Z", "fees_split": null, "ip_address": "154.161.34.104, 141.101.98.24, 172.31.62.52", "subaccount": [], "plan_object": [], "authorization": {"bin": "055XXX", "bank": "MTN", "brand": "Mtn", "last4": "X987", "channel": "mobile_money", "exp_year": "9999", "reusable": false, "card_type": "", "exp_month": "12", "signature": null, "account_name": null, "country_code": "GH", "receiver_bank": null, "authorization_code": "AUTH_829cwb14tm", "mobile_money_number": "0551234987", "receiver_bank_account_number": null}, "response_code": null, "fees_breakdown": null, "receipt_number": "10101", "gateway_response": "Approved", "requested_amount": 96300, "transaction_date": "2026-05-05T19:40:52.000Z", "pos_transaction_data": null}}	2026-05-05 19:40:54	2026-05-05 19:40:50	2026-05-05 19:40:54
c84c18e2-f365-4a6b-b2fb-34be66139964	de78bf1c-0c16-4a4c-97a7-770ae36fa868	abbb1866-9613-456a-96d0-c22ab063f448	paystack	TK-DE78BF1C-I7WKU09C	45900	failed	{"email": "agoo@gmail.com", "phone": "0243597768", "network": "mtn"}	\N	2026-05-06 12:07:20	2026-05-06 12:07:22
94c1ea5e-3263-43e1-9af7-397ffb7319f2	de78bf1c-0c16-4a4c-97a7-770ae36fa868	abbb1866-9613-456a-96d0-c22ab063f448	paystack	TK-DE78BF1C-A9IM1WCR	45900	failed	{"email": "agoo@gmail.com", "phone": "0243597768", "network": "vodafone"}	\N	2026-05-06 12:07:40	2026-05-06 12:07:40
c0a81963-ee5d-4815-86d5-09e59b2a5106	de78bf1c-0c16-4a4c-97a7-770ae36fa868	abbb1866-9613-456a-96d0-c22ab063f448	paystack	TK-DE78BF1C-EJWUITIO	45900	failed	{"email": "agoo@gmail.com", "phone": "0243596533", "network": "mtn"}	\N	2026-05-06 12:08:07	2026-05-06 12:08:08
\.


--
-- Data for Name: plans; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.plans (id, name, slug, price_monthly, invoice_limit, features, is_active, created_at, updated_at) FROM stdin;
d272fdef-e565-41ad-b6a0-651525d638fa	Free	free	0	5	["5 invoices per month", "PDF downloads", "MoMo payments", "1 user"]	t	2026-05-02 02:28:24	2026-05-05 23:24:10
fd02c0a4-79a1-4358-819e-03c1765502c2	Starter	starter	9900	-1	["Unlimited invoices", "PDF downloads", "MoMo payments", "Up to 3 team members", "Email support"]	t	2026-05-05 23:24:10	2026-05-05 23:24:10
a66084f8-4812-4f98-b88f-7421396b3b6c	Growth	growth	19900	-1	["Unlimited invoices", "PDF downloads", "MoMo payments", "Up to 10 team members", "Priority support", "Custom invoice prefix"]	t	2026-05-05 23:24:10	2026-05-05 23:24:10
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, tenant_id, name, description, default_price, created_at, updated_at) FROM stdin;
fcf9f576-caba-4c72-b162-7931448d3b10	abbb1866-9613-456a-96d0-c22ab063f448	Consultation	\N	5000	2026-05-06 12:01:49	2026-05-06 12:01:49
96250b57-7727-4c2e-8290-245958a831fd	abbb1866-9613-456a-96d0-c22ab063f448	Web Design	\N	20000	2026-05-06 12:02:01	2026-05-06 12:02:01
ef6cc12a-c545-43ee-9640-d722d5c4e190	abbb1866-9613-456a-96d0-c22ab063f448	Graphic Design	\N	40000	2026-05-06 12:02:15	2026-05-06 12:02:15
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sessions (id, user_id, ip_address, user_agent, payload, last_activity) FROM stdin;
\.


--
-- Data for Name: subscriptions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subscriptions (id, tenant_id, plan_id, status, paystack_ref, trial_ends_at, current_period_start, current_period_end, cancelled_at, created_at, updated_at) FROM stdin;
841eba23-adc1-4714-9e17-d3317f4bb3d9	04e240e3-e4de-4dfa-87bd-fad64e3fb803	fd02c0a4-79a1-4358-819e-03c1765502c2	active	TK-04E240E3-48DPGSU2	\N	2026-05-06 11:41:45	2026-06-06 11:41:45	\N	2026-05-06 11:41:46	2026-05-06 11:41:46
c76901b9-c06b-4a00-84dc-1785c416e0e6	abbb1866-9613-456a-96d0-c22ab063f448	fd02c0a4-79a1-4358-819e-03c1765502c2	trialing	\N	2026-05-20 12:00:40	2026-05-06 12:00:40	2026-05-20 12:00:40	\N	2026-05-06 12:00:40	2026-05-06 12:00:40
320d18ab-7dd9-4d50-95d5-980ead99fdb4	f5248b0c-7637-4233-863f-059d7f28383b	fd02c0a4-79a1-4358-819e-03c1765502c2	trialing	\N	2026-05-21 13:12:20	2026-05-07 13:12:20	2026-05-21 13:12:20	\N	2026-05-07 13:12:20	2026-05-07 13:12:20
\.


--
-- Data for Name: tenants; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tenants (id, name, slug, currency, logo_url, invoice_prefix, address, phone, website, created_at, updated_at, timezone, is_active) FROM stdin;
b8ed316e-890c-47da-b8f9-05f2b6357c6a	Acme Co	acme	GHS	\N	INV	\N	\N	\N	2026-05-03 02:37:38	2026-05-03 02:37:38	Africa/Accra	t
a2aba803-54fb-42eb-afe7-147cdd78a6b1	Asante Corporations Limited	asante-corporations-limited	GHS	\N	INV	\N	\N	\N	2026-05-03 19:37:46	2026-05-03 19:37:46	Africa/Accra	t
fde27ca3-490a-4cb2-a2d0-159092667bec	Indicorp Limited	indicorp-limited	GHS	\N	INV	\N	\N	\N	2026-05-04 00:33:15	2026-05-04 00:33:15	Africa/Accra	t
f67a0599-0fda-4b67-9e17-4461a8ab2b65	Wallstreet	wallstreet	GHS	\N	INV	\N	\N	\N	2026-05-04 00:52:12	2026-05-04 00:52:12	Africa/Accra	t
04e240e3-e4de-4dfa-87bd-fad64e3fb803	Felicia Corporation	felicia-corporation	GHS	\N	LVE	\N	\N	\N	2026-05-04 20:33:51	2026-05-05 02:24:49	Africa/Accra	t
abbb1866-9613-456a-96d0-c22ab063f448	Frimpong Limited	frimpong-limited	GHS	\N	INV	\N	\N	\N	2026-05-06 12:00:39	2026-05-06 12:00:39	Africa/Accra	t
f5248b0c-7637-4233-863f-059d7f28383b	onboarding checklist	onboarding-checklist	GHS	\N	INV	\N	\N	\N	2026-05-07 13:12:20	2026-05-07 13:12:20	Africa/Accra	t
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, tenant_id, name, email, password, role, is_active, invited_at, email_verified_at, remember_token, created_at, updated_at, email_verification_token) FROM stdin;
dad9624e-a9f7-4592-8a9b-403b2c0952d7	b8ed316e-890c-47da-b8f9-05f2b6357c6a	Kofi Mensah	kofi@acme.com	$2y$12$F6lcaS6JH0FE9JOnUWLq6eUxOs8cQGu6wAHOtMUbM4rlmb5yWMDti	owner	t	\N	\N	\N	2026-05-03 02:37:38	2026-05-03 02:37:38	\N
506ff519-f2d8-4f2a-9c3f-2f13efbfe185	a2aba803-54fb-42eb-afe7-147cdd78a6b1	Kwabena Asante	kwabena@gmail.com	$2y$12$JzFTmHXVeYCiqI60hwVGwOqy8Sf2ci3oZt9jIa4/eGmotO/LM9I0a	owner	t	\N	\N	\N	2026-05-03 19:37:46	2026-05-03 19:37:46	\N
b875089e-63b2-47a1-bf09-47d354910b95	abbb1866-9613-456a-96d0-c22ab063f448	Test member	test@gmail.com	$2y$12$OMccCzEWlzOyTq9lViElxO7qz4IGJbQCoOWnQz.cmWZJr0uKj.Bz6	member	t	2026-05-06 14:05:22	\N	\N	2026-05-06 14:05:22	2026-05-06 14:05:22	\N
213810d7-5743-47cc-83bc-500537227bd8	fde27ca3-490a-4cb2-a2d0-159092667bec	THEOPHILOUS ASANTE FRIMPONG	theophilusfrimpong17@gmail.com	$2y$12$YGdj6nCd1JdVfHVWAgBgoOa4HCrPo4caivCvhwoTD.AcdjXgegj9G	owner	t	\N	2026-05-04 00:41:49	\N	2026-05-04 00:33:15	2026-05-04 00:41:49	\N
b1382f86-7c0f-4f2f-a3c0-646c013f8f07	f5248b0c-7637-4233-863f-059d7f28383b	onboarder	onboard@gmail.com	$2y$12$NVqIEwgaLQ7IKCaHMtw2du5LnPGnYrB8nJgun9/ZgvMdgJFl5zdv.	owner	t	\N	\N	\N	2026-05-07 13:12:20	2026-05-07 13:12:20	rXJBAUiX1D1BBlSsf2YBqwmn6ajTzxqEIIPG5LAaweMyHC7jxBB821e9wVrmsIs5
39a80830-5b71-4cd8-b33f-cf00c058f547	f67a0599-0fda-4b67-9e17-4461a8ab2b65	John Mclean	john@gmail.com	$2y$12$MUNbJqC4gk.wlSEOs5n4Q.hn6Hl1IaD14RwfVZ96mr2LG8YAyLgwW	owner	t	\N	2026-05-04 00:52:44	\N	2026-05-04 00:52:12	2026-05-04 01:51:03	\N
d3290a06-5d9c-45b9-8263-98cbb960e49b	04e240e3-e4de-4dfa-87bd-fad64e3fb803	Mariam	mariam@gmail.com	$2y$12$pOXPl8h0dOTXsxoQlv0ReOZb5PiIlrSqrHjuuFGvq5v8nGgZZ/csG	owner	t	\N	2026-05-04 22:13:48	\N	2026-05-04 20:33:51	2026-05-04 22:25:03	\N
dd8732fa-8c79-4a44-a034-fb1272791f08	abbb1866-9613-456a-96d0-c22ab063f448	Mr. Frimpong	frimpong@gmail.com	$2y$12$lZj/rreTs0nMvmIJJ5GIteqxYTlTwb3EwLh6jeoHeFsGTS5XxVFuS	owner	t	\N	2026-05-06 12:05:28	\N	2026-05-06 12:00:40	2026-05-06 12:05:28	\N
\.


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.failed_jobs_id_seq', 6, true);


--
-- Name: jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.jobs_id_seq', 36, true);


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.migrations_id_seq', 18, true);


--
-- Name: admins admins_email_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_email_unique UNIQUE (email);


--
-- Name: admins admins_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- Name: cache_locks cache_locks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cache_locks
    ADD CONSTRAINT cache_locks_pkey PRIMARY KEY (key);


--
-- Name: cache cache_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cache
    ADD CONSTRAINT cache_pkey PRIMARY KEY (key);


--
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);


--
-- Name: failed_jobs failed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_pkey PRIMARY KEY (id);


--
-- Name: failed_jobs failed_jobs_uuid_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_uuid_unique UNIQUE (uuid);


--
-- Name: invites invites_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invites
    ADD CONSTRAINT invites_pkey PRIMARY KEY (id);


--
-- Name: invites invites_tenant_id_email_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invites
    ADD CONSTRAINT invites_tenant_id_email_unique UNIQUE (tenant_id, email);


--
-- Name: invites invites_token_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invites
    ADD CONSTRAINT invites_token_unique UNIQUE (token);


--
-- Name: invoice_activities invoice_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoice_activities
    ADD CONSTRAINT invoice_activities_pkey PRIMARY KEY (id);


--
-- Name: invoice_items invoice_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_tenant_id_number_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_tenant_id_number_unique UNIQUE (tenant_id, number);


--
-- Name: invoices invoices_view_token_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_view_token_unique UNIQUE (view_token);


--
-- Name: job_batches job_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_batches
    ADD CONSTRAINT job_batches_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (email);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: payments payments_provider_ref_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_provider_ref_unique UNIQUE (provider_ref);


--
-- Name: plans plans_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plans
    ADD CONSTRAINT plans_pkey PRIMARY KEY (id);


--
-- Name: plans plans_slug_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plans
    ADD CONSTRAINT plans_slug_unique UNIQUE (slug);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (id);


--
-- Name: tenants tenants_slug_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_slug_unique UNIQUE (slug);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_tenant_id_email_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_tenant_id_email_unique UNIQUE (tenant_id, email);


--
-- Name: cache_expiration_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX cache_expiration_index ON public.cache USING btree (expiration);


--
-- Name: cache_locks_expiration_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX cache_locks_expiration_index ON public.cache_locks USING btree (expiration);


--
-- Name: jobs_queue_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX jobs_queue_index ON public.jobs USING btree (queue);


--
-- Name: sessions_last_activity_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sessions_last_activity_index ON public.sessions USING btree (last_activity);


--
-- Name: sessions_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sessions_user_id_index ON public.sessions USING btree (user_id);


--
-- Name: users_tenant_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_tenant_id_index ON public.users USING btree (tenant_id);


--
-- Name: clients clients_tenant_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_tenant_id_foreign FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: invites invites_invited_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invites
    ADD CONSTRAINT invites_invited_by_foreign FOREIGN KEY (invited_by) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: invites invites_tenant_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invites
    ADD CONSTRAINT invites_tenant_id_foreign FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: invoice_activities invoice_activities_invoice_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoice_activities
    ADD CONSTRAINT invoice_activities_invoice_id_foreign FOREIGN KEY (invoice_id) REFERENCES public.invoices(id) ON DELETE CASCADE;


--
-- Name: invoice_items invoice_items_invoice_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_invoice_id_foreign FOREIGN KEY (invoice_id) REFERENCES public.invoices(id) ON DELETE CASCADE;


--
-- Name: invoice_items invoice_items_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE SET NULL;


--
-- Name: invoices invoices_client_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_client_id_foreign FOREIGN KEY (client_id) REFERENCES public.clients(id) ON DELETE CASCADE;


--
-- Name: invoices invoices_tenant_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_tenant_id_foreign FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: payments payments_invoice_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_invoice_id_foreign FOREIGN KEY (invoice_id) REFERENCES public.invoices(id) ON DELETE CASCADE;


--
-- Name: payments payments_tenant_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_tenant_id_foreign FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: products products_tenant_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_tenant_id_foreign FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: subscriptions subscriptions_plan_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_plan_id_foreign FOREIGN KEY (plan_id) REFERENCES public.plans(id);


--
-- Name: subscriptions subscriptions_tenant_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_tenant_id_foreign FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: users users_tenant_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_tenant_id_foreign FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict UhrHWfLPjxXZc7bPGSMCPXiX0zWIseLUdVeSCTb13Ertc6Xz6wPukuar3umcgIG

