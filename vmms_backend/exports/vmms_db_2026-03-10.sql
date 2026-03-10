--
-- PostgreSQL database dump
--

\restrict JFgQKx13EBmmTqzfnMIuZbQwUW207d8TUG8fW6GB8npM0nA28JtrQOKHx8KzrDX

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

-- Started on 2026-03-10 21:24:13

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

--
-- TOC entry 280 (class 1255 OID 17620)
-- Name: validate_host_project_department(); Type: FUNCTION; Schema: public; Owner: svr_user
--

CREATE FUNCTION public.validate_host_project_department() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM hosts h
    JOIN projects p ON p.id = NEW.project_id
    WHERE h.id = NEW.host_id
      AND h.department_id = p.department_id
  ) THEN
    RAISE EXCEPTION 'Project does not belong to host department';
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.validate_host_project_department() OWNER TO svr_user;

SET default_tablespace = '';

--
-- TOC entry 255 (class 1259 OID 17434)
-- Name: access_logs; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.access_logs (
    id bigint NOT NULL,
    person_type character varying(20),
    person_id bigint,
    gate_id integer,
    direction character varying(10),
    scan_time timestamp without time zone NOT NULL,
    status character varying(20),
    error_code character varying(10),
    live_photo_path text,
    manual_override boolean DEFAULT false
)
PARTITION BY RANGE (scan_time);


ALTER TABLE public.access_logs OWNER TO svr_user;

--
-- TOC entry 254 (class 1259 OID 17433)
-- Name: access_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: svr_user
--

CREATE SEQUENCE public.access_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.access_logs_id_seq OWNER TO svr_user;

--
-- TOC entry 5431 (class 0 OID 0)
-- Dependencies: 254
-- Name: access_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svr_user
--

ALTER SEQUENCE public.access_logs_id_seq OWNED BY public.access_logs.id;


SET default_table_access_method = heap;

--
-- TOC entry 256 (class 1259 OID 17448)
-- Name: access_logs_default; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.access_logs_default (
    id bigint DEFAULT nextval('public.access_logs_id_seq'::regclass) CONSTRAINT access_logs_id_not_null NOT NULL,
    person_type character varying(20),
    person_id bigint,
    gate_id integer,
    direction character varying(10),
    scan_time timestamp without time zone CONSTRAINT access_logs_scan_time_not_null NOT NULL,
    status character varying(20),
    error_code character varying(10),
    live_photo_path text,
    manual_override boolean DEFAULT false
);


ALTER TABLE public.access_logs_default OWNER TO svr_user;

--
-- TOC entry 240 (class 1259 OID 17286)
-- Name: biometric_data; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.biometric_data (
    id bigint NOT NULL,
    visitor_id bigint,
    biometric_hash text NOT NULL,
    algorithm character varying(50) DEFAULT 'SHA256'::character varying,
    enrolled_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.biometric_data OWNER TO svr_user;

--
-- TOC entry 239 (class 1259 OID 17285)
-- Name: biometric_data_id_seq; Type: SEQUENCE; Schema: public; Owner: svr_user
--

CREATE SEQUENCE public.biometric_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.biometric_data_id_seq OWNER TO svr_user;

--
-- TOC entry 5432 (class 0 OID 0)
-- Dependencies: 239
-- Name: biometric_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svr_user
--

ALTER SEQUENCE public.biometric_data_id_seq OWNED BY public.biometric_data.id;


--
-- TOC entry 242 (class 1259 OID 17304)
-- Name: biometric_match_audit; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.biometric_match_audit (
    id bigint NOT NULL,
    visitor_id bigint,
    gate_id integer,
    biometric_hash text,
    match_score numeric(5,2),
    match_result character varying(20),
    attempt_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.biometric_match_audit OWNER TO svr_user;

--
-- TOC entry 241 (class 1259 OID 17303)
-- Name: biometric_match_audit_id_seq; Type: SEQUENCE; Schema: public; Owner: svr_user
--

CREATE SEQUENCE public.biometric_match_audit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.biometric_match_audit_id_seq OWNER TO svr_user;

--
-- TOC entry 5433 (class 0 OID 0)
-- Dependencies: 241
-- Name: biometric_match_audit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svr_user
--

ALTER SEQUENCE public.biometric_match_audit_id_seq OWNED BY public.biometric_match_audit.id;


--
-- TOC entry 262 (class 1259 OID 17492)
-- Name: blacklist; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.blacklist (
    id integer NOT NULL,
    aadhaar_hash text,
    phone character varying(20),
    biometric_hash text,
    reason text,
    block_type character varying(20),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.blacklist OWNER TO svr_user;

--
-- TOC entry 261 (class 1259 OID 17491)
-- Name: blacklist_id_seq; Type: SEQUENCE; Schema: public; Owner: svr_user
--

CREATE SEQUENCE public.blacklist_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.blacklist_id_seq OWNER TO svr_user;

--
-- TOC entry 5434 (class 0 OID 0)
-- Dependencies: 261
-- Name: blacklist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svr_user
--

ALTER SEQUENCE public.blacklist_id_seq OWNED BY public.blacklist.id;


--
-- TOC entry 246 (class 1259 OID 17340)
-- Name: card_reissue_log; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.card_reissue_log (
    id bigint NOT NULL,
    old_card_id bigint,
    new_card_id bigint,
    aso_document_id bigint,
    reissued_by integer,
    reason text,
    reissued_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.card_reissue_log OWNER TO svr_user;

--
-- TOC entry 245 (class 1259 OID 17339)
-- Name: card_reissue_log_id_seq; Type: SEQUENCE; Schema: public; Owner: svr_user
--

CREATE SEQUENCE public.card_reissue_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.card_reissue_log_id_seq OWNER TO svr_user;

--
-- TOC entry 5435 (class 0 OID 0)
-- Dependencies: 245
-- Name: card_reissue_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svr_user
--

ALTER SEQUENCE public.card_reissue_log_id_seq OWNED BY public.card_reissue_log.id;


--
-- TOC entry 226 (class 1259 OID 17145)
-- Name: departments; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.departments (
    id integer NOT NULL,
    department_name character varying(150) NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.departments OWNER TO svr_user;

--
-- TOC entry 225 (class 1259 OID 17144)
-- Name: departments_id_seq; Type: SEQUENCE; Schema: public; Owner: svr_user
--

CREATE SEQUENCE public.departments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.departments_id_seq OWNER TO svr_user;

--
-- TOC entry 5436 (class 0 OID 0)
-- Dependencies: 225
-- Name: departments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svr_user
--

ALTER SEQUENCE public.departments_id_seq OWNED BY public.departments.id;


--
-- TOC entry 230 (class 1259 OID 17178)
-- Name: entrances; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.entrances (
    id integer NOT NULL,
    entrance_code character varying(20) NOT NULL,
    entrance_name character varying(100),
    is_main_gate boolean DEFAULT false
);


ALTER TABLE public.entrances OWNER TO svr_user;

--
-- TOC entry 229 (class 1259 OID 17177)
-- Name: entrances_id_seq; Type: SEQUENCE; Schema: public; Owner: svr_user
--

CREATE SEQUENCE public.entrances_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.entrances_id_seq OWNER TO svr_user;

--
-- TOC entry 5437 (class 0 OID 0)
-- Dependencies: 229
-- Name: entrances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svr_user
--

ALTER SEQUENCE public.entrances_id_seq OWNED BY public.entrances.id;


--
-- TOC entry 267 (class 1259 OID 17530)
-- Name: gate_health; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.gate_health (
    gate_id integer NOT NULL,
    last_heartbeat timestamp without time zone,
    is_online boolean,
    cpu_usage numeric(5,2),
    memory_usage numeric(5,2),
    storage_usage numeric(5,2),
    camera_status boolean,
    rfid_status boolean,
    biometric_status boolean,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.gate_health OWNER TO svr_user;

--
-- TOC entry 269 (class 1259 OID 17543)
-- Name: gate_health_logs; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.gate_health_logs (
    id bigint NOT NULL,
    gate_id integer,
    heartbeat_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    cpu_usage numeric(5,2),
    memory_usage numeric(5,2),
    storage_usage numeric(5,2),
    camera_status boolean,
    rfid_status boolean,
    biometric_status boolean
);


ALTER TABLE public.gate_health_logs OWNER TO svr_user;

--
-- TOC entry 268 (class 1259 OID 17542)
-- Name: gate_health_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: svr_user
--

CREATE SEQUENCE public.gate_health_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.gate_health_logs_id_seq OWNER TO svr_user;

--
-- TOC entry 5438 (class 0 OID 0)
-- Dependencies: 268
-- Name: gate_health_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svr_user
--

ALTER SEQUENCE public.gate_health_logs_id_seq OWNED BY public.gate_health_logs.id;


--
-- TOC entry 232 (class 1259 OID 17190)
-- Name: gates; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.gates (
    id integer NOT NULL,
    gate_name character varying(100),
    entrance_id integer,
    ip_address character varying(50),
    device_serial character varying(100),
    is_active boolean DEFAULT true
);


ALTER TABLE public.gates OWNER TO svr_user;

--
-- TOC entry 231 (class 1259 OID 17189)
-- Name: gates_id_seq; Type: SEQUENCE; Schema: public; Owner: svr_user
--

CREATE SEQUENCE public.gates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.gates_id_seq OWNER TO svr_user;

--
-- TOC entry 5439 (class 0 OID 0)
-- Dependencies: 231
-- Name: gates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svr_user
--

ALTER SEQUENCE public.gates_id_seq OWNED BY public.gates.id;


--
-- TOC entry 275 (class 1259 OID 17596)
-- Name: host_projects; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.host_projects (
    id integer NOT NULL,
    host_id integer NOT NULL,
    project_id integer NOT NULL,
    assigned_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.host_projects OWNER TO svr_user;

--
-- TOC entry 274 (class 1259 OID 17595)
-- Name: host_projects_id_seq; Type: SEQUENCE; Schema: public; Owner: svr_user
--

CREATE SEQUENCE public.host_projects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.host_projects_id_seq OWNER TO svr_user;

--
-- TOC entry 5440 (class 0 OID 0)
-- Dependencies: 274
-- Name: host_projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svr_user
--

ALTER SEQUENCE public.host_projects_id_seq OWNED BY public.host_projects.id;


--
-- TOC entry 228 (class 1259 OID 17161)
-- Name: hosts; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.hosts (
    id integer NOT NULL,
    host_name character varying(150) NOT NULL,
    phone character varying(20) NOT NULL,
    email character varying(150),
    department_id integer,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.hosts OWNER TO svr_user;

--
-- TOC entry 227 (class 1259 OID 17160)
-- Name: hosts_id_seq; Type: SEQUENCE; Schema: public; Owner: svr_user
--

CREATE SEQUENCE public.hosts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hosts_id_seq OWNER TO svr_user;

--
-- TOC entry 5441 (class 0 OID 0)
-- Dependencies: 227
-- Name: hosts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svr_user
--

ALTER SEQUENCE public.hosts_id_seq OWNED BY public.hosts.id;


--
-- TOC entry 252 (class 1259 OID 17401)
-- Name: labour_manifests; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.labour_manifests (
    id bigint NOT NULL,
    supervisor_id bigint,
    manifest_date date,
    printed_at timestamp without time zone,
    signed boolean DEFAULT false,
    pdf_path text
);


ALTER TABLE public.labour_manifests OWNER TO svr_user;

--
-- TOC entry 251 (class 1259 OID 17400)
-- Name: labour_manifests_id_seq; Type: SEQUENCE; Schema: public; Owner: svr_user
--

CREATE SEQUENCE public.labour_manifests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.labour_manifests_id_seq OWNER TO svr_user;

--
-- TOC entry 5442 (class 0 OID 0)
-- Dependencies: 251
-- Name: labour_manifests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svr_user
--

ALTER SEQUENCE public.labour_manifests_id_seq OWNED BY public.labour_manifests.id;


--
-- TOC entry 250 (class 1259 OID 17387)
-- Name: labour_tokens; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.labour_tokens (
    id bigint NOT NULL,
    labour_id bigint,
    token_uid character varying(100),
    assigned_date date,
    valid_until timestamp without time zone,
    status character varying(20) DEFAULT 'ACTIVE'::character varying
);


ALTER TABLE public.labour_tokens OWNER TO svr_user;

--
-- TOC entry 249 (class 1259 OID 17386)
-- Name: labour_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: svr_user
--

CREATE SEQUENCE public.labour_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.labour_tokens_id_seq OWNER TO svr_user;

--
-- TOC entry 5443 (class 0 OID 0)
-- Dependencies: 249
-- Name: labour_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svr_user
--

ALTER SEQUENCE public.labour_tokens_id_seq OWNED BY public.labour_tokens.id;


--
-- TOC entry 248 (class 1259 OID 17371)
-- Name: labours; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.labours (
    id bigint NOT NULL,
    supervisor_id bigint,
    full_name character varying(150),
    phone character varying(20),
    aadhaar_encrypted text,
    aadhaar_last4 character varying(4),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.labours OWNER TO svr_user;

--
-- TOC entry 247 (class 1259 OID 17370)
-- Name: labours_id_seq; Type: SEQUENCE; Schema: public; Owner: svr_user
--

CREATE SEQUENCE public.labours_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.labours_id_seq OWNER TO svr_user;

--
-- TOC entry 5444 (class 0 OID 0)
-- Dependencies: 247
-- Name: labours_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svr_user
--

ALTER SEQUENCE public.labours_id_seq OWNED BY public.labours.id;


--
-- TOC entry 253 (class 1259 OID 17416)
-- Name: manifest_labours; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.manifest_labours (
    manifest_id bigint NOT NULL,
    labour_id bigint NOT NULL
);


ALTER TABLE public.manifest_labours OWNER TO svr_user;

--
-- TOC entry 260 (class 1259 OID 17473)
-- Name: material_transactions; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.material_transactions (
    id bigint NOT NULL,
    visitor_id bigint,
    material_id integer,
    quantity integer,
    direction character varying(10),
    transaction_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.material_transactions OWNER TO svr_user;

--
-- TOC entry 259 (class 1259 OID 17472)
-- Name: material_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: svr_user
--

CREATE SEQUENCE public.material_transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.material_transactions_id_seq OWNER TO svr_user;

--
-- TOC entry 5445 (class 0 OID 0)
-- Dependencies: 259
-- Name: material_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svr_user
--

ALTER SEQUENCE public.material_transactions_id_seq OWNED BY public.material_transactions.id;


--
-- TOC entry 258 (class 1259 OID 17463)
-- Name: materials; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.materials (
    id integer NOT NULL,
    category character varying(50),
    make character varying(100),
    model character varying(100),
    serial_number character varying(100),
    description text
);


ALTER TABLE public.materials OWNER TO svr_user;

--
-- TOC entry 257 (class 1259 OID 17462)
-- Name: materials_id_seq; Type: SEQUENCE; Schema: public; Owner: svr_user
--

CREATE SEQUENCE public.materials_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.materials_id_seq OWNER TO svr_user;

--
-- TOC entry 5446 (class 0 OID 0)
-- Dependencies: 257
-- Name: materials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svr_user
--

ALTER SEQUENCE public.materials_id_seq OWNED BY public.materials.id;


--
-- TOC entry 224 (class 1259 OID 17134)
-- Name: projects; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.projects (
    id integer NOT NULL,
    project_name character varying(150) NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    department_id integer
);


ALTER TABLE public.projects OWNER TO svr_user;

--
-- TOC entry 223 (class 1259 OID 17133)
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: svr_user
--

CREATE SEQUENCE public.projects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.projects_id_seq OWNER TO svr_user;

--
-- TOC entry 5447 (class 0 OID 0)
-- Dependencies: 223
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svr_user
--

ALTER SEQUENCE public.projects_id_seq OWNED BY public.projects.id;


--
-- TOC entry 244 (class 1259 OID 17320)
-- Name: rfid_cards; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.rfid_cards (
    id bigint NOT NULL,
    visitor_id bigint,
    card_uid character varying(100) NOT NULL,
    qr_code text,
    issue_date date,
    expiry_date date,
    card_status character varying(20) DEFAULT 'ACTIVE'::character varying,
    replaced_by bigint,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.rfid_cards OWNER TO svr_user;

--
-- TOC entry 243 (class 1259 OID 17319)
-- Name: rfid_cards_id_seq; Type: SEQUENCE; Schema: public; Owner: svr_user
--

CREATE SEQUENCE public.rfid_cards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rfid_cards_id_seq OWNER TO svr_user;

--
-- TOC entry 5448 (class 0 OID 0)
-- Dependencies: 243
-- Name: rfid_cards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svr_user
--

ALTER SEQUENCE public.rfid_cards_id_seq OWNED BY public.rfid_cards.id;


--
-- TOC entry 277 (class 1259 OID 17623)
-- Name: rfid_cards_stock; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.rfid_cards_stock (
    id bigint NOT NULL,
    uid character varying(100) NOT NULL,
    status character varying(20) DEFAULT 'AVAILABLE'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    removed_reason text
);


ALTER TABLE public.rfid_cards_stock OWNER TO svr_user;

--
-- TOC entry 276 (class 1259 OID 17622)
-- Name: rfid_cards_stock_id_seq; Type: SEQUENCE; Schema: public; Owner: svr_user
--

CREATE SEQUENCE public.rfid_cards_stock_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rfid_cards_stock_id_seq OWNER TO svr_user;

--
-- TOC entry 5449 (class 0 OID 0)
-- Dependencies: 276
-- Name: rfid_cards_stock_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svr_user
--

ALTER SEQUENCE public.rfid_cards_stock_id_seq OWNED BY public.rfid_cards_stock.id;


--
-- TOC entry 273 (class 1259 OID 17585)
-- Name: rfid_stock; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.rfid_stock (
    id bigint NOT NULL,
    uid character varying(100),
    status character varying(20) DEFAULT 'AVAILABLE'::character varying,
    removed_reason text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.rfid_stock OWNER TO svr_user;

--
-- TOC entry 272 (class 1259 OID 17584)
-- Name: rfid_stock_id_seq; Type: SEQUENCE; Schema: public; Owner: svr_user
--

CREATE SEQUENCE public.rfid_stock_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rfid_stock_id_seq OWNER TO svr_user;

--
-- TOC entry 5450 (class 0 OID 0)
-- Dependencies: 272
-- Name: rfid_stock_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svr_user
--

ALTER SEQUENCE public.rfid_stock_id_seq OWNED BY public.rfid_stock.id;


--
-- TOC entry 220 (class 1259 OID 17099)
-- Name: roles; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    role_name character varying(50) NOT NULL,
    can_export_pdf boolean DEFAULT false,
    can_export_excel boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.roles OWNER TO svr_user;

--
-- TOC entry 219 (class 1259 OID 17098)
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: svr_user
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_id_seq OWNER TO svr_user;

--
-- TOC entry 5451 (class 0 OID 0)
-- Dependencies: 219
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svr_user
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- TOC entry 264 (class 1259 OID 17503)
-- Name: sms_logs; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.sms_logs (
    id integer NOT NULL,
    recipient character varying(20),
    message text,
    event_type character varying(50),
    related_entity_id bigint,
    sent_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(20)
);


ALTER TABLE public.sms_logs OWNER TO svr_user;

--
-- TOC entry 263 (class 1259 OID 17502)
-- Name: sms_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: svr_user
--

CREATE SEQUENCE public.sms_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sms_logs_id_seq OWNER TO svr_user;

--
-- TOC entry 5452 (class 0 OID 0)
-- Dependencies: 263
-- Name: sms_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svr_user
--

ALTER SEQUENCE public.sms_logs_id_seq OWNED BY public.sms_logs.id;


--
-- TOC entry 266 (class 1259 OID 17514)
-- Name: sync_queue; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.sync_queue (
    id bigint NOT NULL,
    gate_id integer,
    payload jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    synced boolean DEFAULT false
);


ALTER TABLE public.sync_queue OWNER TO svr_user;

--
-- TOC entry 265 (class 1259 OID 17513)
-- Name: sync_queue_id_seq; Type: SEQUENCE; Schema: public; Owner: svr_user
--

CREATE SEQUENCE public.sync_queue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sync_queue_id_seq OWNER TO svr_user;

--
-- TOC entry 5453 (class 0 OID 0)
-- Dependencies: 265
-- Name: sync_queue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svr_user
--

ALTER SEQUENCE public.sync_queue_id_seq OWNED BY public.sync_queue.id;


--
-- TOC entry 222 (class 1259 OID 17113)
-- Name: users; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(100) NOT NULL,
    password_hash text NOT NULL,
    full_name character varying(150),
    phone character varying(20),
    role_id integer,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO svr_user;

--
-- TOC entry 221 (class 1259 OID 17112)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: svr_user
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO svr_user;

--
-- TOC entry 5454 (class 0 OID 0)
-- Dependencies: 221
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svr_user
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 238 (class 1259 OID 17270)
-- Name: visitor_documents; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.visitor_documents (
    id bigint NOT NULL,
    visitor_id bigint,
    doc_type character varying(50),
    doc_number character varying(100),
    expiry_date date,
    file_path text,
    uploaded_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.visitor_documents OWNER TO svr_user;

--
-- TOC entry 237 (class 1259 OID 17269)
-- Name: visitor_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: svr_user
--

CREATE SEQUENCE public.visitor_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.visitor_documents_id_seq OWNER TO svr_user;

--
-- TOC entry 5455 (class 0 OID 0)
-- Dependencies: 237
-- Name: visitor_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svr_user
--

ALTER SEQUENCE public.visitor_documents_id_seq OWNED BY public.visitor_documents.id;


--
-- TOC entry 279 (class 1259 OID 17665)
-- Name: visitor_gate_permissions; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.visitor_gate_permissions (
    id integer NOT NULL,
    visitor_id bigint NOT NULL,
    gate_id integer NOT NULL,
    valid_from date,
    valid_to date,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.visitor_gate_permissions OWNER TO svr_user;

--
-- TOC entry 278 (class 1259 OID 17664)
-- Name: visitor_gate_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: svr_user
--

CREATE SEQUENCE public.visitor_gate_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.visitor_gate_permissions_id_seq OWNER TO svr_user;

--
-- TOC entry 5456 (class 0 OID 0)
-- Dependencies: 278
-- Name: visitor_gate_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svr_user
--

ALTER SEQUENCE public.visitor_gate_permissions_id_seq OWNED BY public.visitor_gate_permissions.id;


--
-- TOC entry 271 (class 1259 OID 17557)
-- Name: visitor_status_audit; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.visitor_status_audit (
    id bigint NOT NULL,
    visitor_id bigint,
    old_status character varying(20),
    new_status character varying(20),
    changed_by integer,
    reason text,
    changed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.visitor_status_audit OWNER TO svr_user;

--
-- TOC entry 270 (class 1259 OID 17556)
-- Name: visitor_status_audit_id_seq; Type: SEQUENCE; Schema: public; Owner: svr_user
--

CREATE SEQUENCE public.visitor_status_audit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.visitor_status_audit_id_seq OWNER TO svr_user;

--
-- TOC entry 5457 (class 0 OID 0)
-- Dependencies: 270
-- Name: visitor_status_audit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svr_user
--

ALTER SEQUENCE public.visitor_status_audit_id_seq OWNED BY public.visitor_status_audit.id;


--
-- TOC entry 234 (class 1259 OID 17204)
-- Name: visitor_types; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.visitor_types (
    id integer NOT NULL,
    type_name character varying(50) NOT NULL,
    allows_labour boolean DEFAULT false,
    is_internal boolean DEFAULT false
);


ALTER TABLE public.visitor_types OWNER TO svr_user;

--
-- TOC entry 233 (class 1259 OID 17203)
-- Name: visitor_types_id_seq; Type: SEQUENCE; Schema: public; Owner: svr_user
--

CREATE SEQUENCE public.visitor_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.visitor_types_id_seq OWNER TO svr_user;

--
-- TOC entry 5458 (class 0 OID 0)
-- Dependencies: 233
-- Name: visitor_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svr_user
--

ALTER SEQUENCE public.visitor_types_id_seq OWNED BY public.visitor_types.id;


--
-- TOC entry 236 (class 1259 OID 17217)
-- Name: visitors; Type: TABLE; Schema: public; Owner: svr_user
--

CREATE TABLE public.visitors (
    id bigint NOT NULL,
    visitor_type_id integer,
    pass_no character varying(50) NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100),
    full_name character varying(200) GENERATED ALWAYS AS ((((first_name)::text || ' '::text) || (COALESCE(last_name, ''::character varying))::text)) STORED,
    designation character varying(150),
    company_name character varying(150),
    company_address text,
    project_id integer,
    department_id integer,
    host_id integer,
    primary_phone character varying(20),
    alternate_phone character varying(20),
    email character varying(150),
    date_of_birth date,
    blood_group character varying(5),
    height_cm integer,
    visible_marks text,
    temp_address text,
    perm_address text,
    aadhaar_encrypted text NOT NULL,
    aadhaar_last4 character varying(4) NOT NULL,
    entrance_id integer,
    smartphone_allowed boolean DEFAULT false,
    smartphone_expiry date,
    laptop_allowed boolean DEFAULT false,
    laptop_make character varying(100),
    laptop_model character varying(100),
    laptop_serial character varying(100),
    laptop_expiry date,
    ops_area_permitted boolean DEFAULT false,
    status character varying(20) DEFAULT 'ACTIVE'::character varying,
    valid_from date,
    valid_to date,
    enrollment_photo_path text,
    created_by integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    can_register_labours boolean DEFAULT false,
    gender character varying(20),
    work_order_no character varying(100),
    work_order_expiry date,
    police_verification_certificate_number character varying(100),
    pvc_expiry date
);


ALTER TABLE public.visitors OWNER TO svr_user;

--
-- TOC entry 235 (class 1259 OID 17216)
-- Name: visitors_id_seq; Type: SEQUENCE; Schema: public; Owner: svr_user
--

CREATE SEQUENCE public.visitors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.visitors_id_seq OWNER TO svr_user;

--
-- TOC entry 5459 (class 0 OID 0)
-- Dependencies: 235
-- Name: visitors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svr_user
--

ALTER SEQUENCE public.visitors_id_seq OWNED BY public.visitors.id;


--
-- TOC entry 5009 (class 0 OID 0)
-- Name: access_logs_default; Type: TABLE ATTACH; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.access_logs ATTACH PARTITION public.access_logs_default DEFAULT;


--
-- TOC entry 5060 (class 2604 OID 17437)
-- Name: access_logs id; Type: DEFAULT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.access_logs ALTER COLUMN id SET DEFAULT nextval('public.access_logs_id_seq'::regclass);


--
-- TOC entry 5044 (class 2604 OID 17289)
-- Name: biometric_data id; Type: DEFAULT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.biometric_data ALTER COLUMN id SET DEFAULT nextval('public.biometric_data_id_seq'::regclass);


--
-- TOC entry 5047 (class 2604 OID 17307)
-- Name: biometric_match_audit id; Type: DEFAULT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.biometric_match_audit ALTER COLUMN id SET DEFAULT nextval('public.biometric_match_audit_id_seq'::regclass);


--
-- TOC entry 5067 (class 2604 OID 17495)
-- Name: blacklist id; Type: DEFAULT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.blacklist ALTER COLUMN id SET DEFAULT nextval('public.blacklist_id_seq'::regclass);


--
-- TOC entry 5052 (class 2604 OID 17343)
-- Name: card_reissue_log id; Type: DEFAULT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.card_reissue_log ALTER COLUMN id SET DEFAULT nextval('public.card_reissue_log_id_seq'::regclass);


--
-- TOC entry 5020 (class 2604 OID 17148)
-- Name: departments id; Type: DEFAULT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.departments ALTER COLUMN id SET DEFAULT nextval('public.departments_id_seq'::regclass);


--
-- TOC entry 5026 (class 2604 OID 17181)
-- Name: entrances id; Type: DEFAULT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.entrances ALTER COLUMN id SET DEFAULT nextval('public.entrances_id_seq'::regclass);


--
-- TOC entry 5075 (class 2604 OID 17546)
-- Name: gate_health_logs id; Type: DEFAULT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.gate_health_logs ALTER COLUMN id SET DEFAULT nextval('public.gate_health_logs_id_seq'::regclass);


--
-- TOC entry 5028 (class 2604 OID 17193)
-- Name: gates id; Type: DEFAULT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.gates ALTER COLUMN id SET DEFAULT nextval('public.gates_id_seq'::regclass);


--
-- TOC entry 5083 (class 2604 OID 17599)
-- Name: host_projects id; Type: DEFAULT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.host_projects ALTER COLUMN id SET DEFAULT nextval('public.host_projects_id_seq'::regclass);


--
-- TOC entry 5023 (class 2604 OID 17164)
-- Name: hosts id; Type: DEFAULT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.hosts ALTER COLUMN id SET DEFAULT nextval('public.hosts_id_seq'::regclass);


--
-- TOC entry 5058 (class 2604 OID 17404)
-- Name: labour_manifests id; Type: DEFAULT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.labour_manifests ALTER COLUMN id SET DEFAULT nextval('public.labour_manifests_id_seq'::regclass);


--
-- TOC entry 5056 (class 2604 OID 17390)
-- Name: labour_tokens id; Type: DEFAULT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.labour_tokens ALTER COLUMN id SET DEFAULT nextval('public.labour_tokens_id_seq'::regclass);


--
-- TOC entry 5054 (class 2604 OID 17374)
-- Name: labours id; Type: DEFAULT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.labours ALTER COLUMN id SET DEFAULT nextval('public.labours_id_seq'::regclass);


--
-- TOC entry 5065 (class 2604 OID 17476)
-- Name: material_transactions id; Type: DEFAULT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.material_transactions ALTER COLUMN id SET DEFAULT nextval('public.material_transactions_id_seq'::regclass);


--
-- TOC entry 5064 (class 2604 OID 17466)
-- Name: materials id; Type: DEFAULT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.materials ALTER COLUMN id SET DEFAULT nextval('public.materials_id_seq'::regclass);


--
-- TOC entry 5017 (class 2604 OID 17137)
-- Name: projects id; Type: DEFAULT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.projects ALTER COLUMN id SET DEFAULT nextval('public.projects_id_seq'::regclass);


--
-- TOC entry 5049 (class 2604 OID 17323)
-- Name: rfid_cards id; Type: DEFAULT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.rfid_cards ALTER COLUMN id SET DEFAULT nextval('public.rfid_cards_id_seq'::regclass);


--
-- TOC entry 5085 (class 2604 OID 17626)
-- Name: rfid_cards_stock id; Type: DEFAULT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.rfid_cards_stock ALTER COLUMN id SET DEFAULT nextval('public.rfid_cards_stock_id_seq'::regclass);


--
-- TOC entry 5079 (class 2604 OID 17588)
-- Name: rfid_stock id; Type: DEFAULT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.rfid_stock ALTER COLUMN id SET DEFAULT nextval('public.rfid_stock_id_seq'::regclass);


--
-- TOC entry 5010 (class 2604 OID 17102)
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- TOC entry 5069 (class 2604 OID 17506)
-- Name: sms_logs id; Type: DEFAULT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.sms_logs ALTER COLUMN id SET DEFAULT nextval('public.sms_logs_id_seq'::regclass);


--
-- TOC entry 5071 (class 2604 OID 17517)
-- Name: sync_queue id; Type: DEFAULT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.sync_queue ALTER COLUMN id SET DEFAULT nextval('public.sync_queue_id_seq'::regclass);


--
-- TOC entry 5014 (class 2604 OID 17116)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 5042 (class 2604 OID 17273)
-- Name: visitor_documents id; Type: DEFAULT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.visitor_documents ALTER COLUMN id SET DEFAULT nextval('public.visitor_documents_id_seq'::regclass);


--
-- TOC entry 5089 (class 2604 OID 17668)
-- Name: visitor_gate_permissions id; Type: DEFAULT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.visitor_gate_permissions ALTER COLUMN id SET DEFAULT nextval('public.visitor_gate_permissions_id_seq'::regclass);


--
-- TOC entry 5077 (class 2604 OID 17560)
-- Name: visitor_status_audit id; Type: DEFAULT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.visitor_status_audit ALTER COLUMN id SET DEFAULT nextval('public.visitor_status_audit_id_seq'::regclass);


--
-- TOC entry 5030 (class 2604 OID 17207)
-- Name: visitor_types id; Type: DEFAULT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.visitor_types ALTER COLUMN id SET DEFAULT nextval('public.visitor_types_id_seq'::regclass);


--
-- TOC entry 5033 (class 2604 OID 17220)
-- Name: visitors id; Type: DEFAULT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.visitors ALTER COLUMN id SET DEFAULT nextval('public.visitors_id_seq'::regclass);


--
-- TOC entry 5402 (class 0 OID 17448)
-- Dependencies: 256
-- Data for Name: access_logs_default; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.access_logs_default (id, person_type, person_id, gate_id, direction, scan_time, status, error_code, live_photo_path, manual_override) FROM stdin;
4	VISITOR	1013	2	IN	2026-02-28 16:30:56.076047	SUCCESS	\N	\N	f
5	VISITOR	1013	2	OUT	2026-02-28 16:32:16.842027	SUCCESS	\N	\N	f
6	VISITOR	1013	2	IN	2026-02-28 16:37:42.900581	SUCCESS	\N	\N	f
7	VISITOR	1013	2	OUT	2026-02-28 16:37:55.877777	SUCCESS	\N	\N	f
8	LABOUR	5032	2	IN	2026-02-28 16:39:30.364039	SUCCESS	\N	\N	f
9	LABOUR	5033	2	IN	2026-02-28 16:39:56.128627	SUCCESS	\N	\N	f
10	LABOUR	5033	2	OUT	2026-02-28 16:41:46.150753	SUCCESS	\N	\N	f
11	VISITOR	1012	2	IN	2026-02-28 16:41:56.593082	SUCCESS	\N	\N	f
12	LABOUR	5032	2	OUT	2026-02-28 16:42:08.95794	SUCCESS	\N	\N	f
13	VISITOR	1012	2	OUT	2026-02-28 16:44:03.709142	SUCCESS	\N	\N	f
14	VISITOR	1013	2	IN	2026-02-28 16:58:11.252215	SUCCESS	\N	\N	f
15	VISITOR	1013	2	OUT	2026-02-28 16:58:37.843429	SUCCESS	\N	\N	f
16	VISITOR	1012	2	IN	2026-02-28 16:58:56.957592	SUCCESS	\N	\N	f
17	VISITOR	1011	2	IN	2026-02-28 17:39:07.202798	SUCCESS	\N	\N	f
18	VISITOR	1006	2	IN	2026-02-28 17:39:24.775665	SUCCESS	\N	\N	f
19	VISITOR	1012	2	OUT	2026-02-28 19:12:07.818081	SUCCESS	\N	\N	f
20	VISITOR	1007	2	IN	2026-02-28 19:13:54.356213	SUCCESS	\N	\N	f
21	VISITOR	1014	2	IN	2026-02-28 20:43:43.539975	SUCCESS	\N	\N	f
22	LABOUR	5034	2	IN	2026-03-02 17:35:47.27316	SUCCESS	\N	\N	f
23	LABOUR	5035	2	IN	2026-03-02 17:36:03.424995	SUCCESS	\N	\N	f
24	VISITOR	1009	2	IN	2026-03-02 17:37:06.204405	SUCCESS	\N	\N	f
25	LABOUR	5034	2	OUT	2026-03-02 20:18:48.420537	SUCCESS	\N	\N	f
26	LABOUR	5035	2	OUT	2026-03-02 20:19:18.624885	SUCCESS	\N	\N	f
27	VISITOR	1009	2	OUT	2026-03-02 20:19:50.060167	SUCCESS	\N	\N	f
28	VISITOR	1013	2	IN	2026-03-02 23:06:16.250152	SUCCESS	\N	\N	f
29	VISITOR	1013	2	OUT	2026-03-02 23:07:03.76991	SUCCESS	\N	\N	f
30	VISITOR	1013	2	IN	2026-03-02 23:08:52.53405	SUCCESS	\N	\N	f
33	VISITOR	\N	\N	IN	2026-03-02 23:12:24.675162	SUCCESS	\N	gate_1_1772473344670.jpg	f
34	VISITOR	\N	\N	IN	2026-03-02 23:12:39.204967	SUCCESS	\N	gate_1_1772473359201.jpg	f
35	VISITOR	1012	2	IN	2026-03-02 23:13:50.048139	SUCCESS	\N	\N	f
36	VISITOR	\N	\N	IN	2026-03-02 23:13:50.066014	SUCCESS	\N	gate_1_1772473430064.jpg	f
37	VISITOR	1011	2	OUT	2026-03-02 23:14:06.994157	SUCCESS	\N	\N	f
38	VISITOR	\N	\N	OUT	2026-03-02 23:14:07.011021	SUCCESS	\N	gate_1_1772473447009.jpg	f
39	VISITOR	1006	2	OUT	2026-03-02 23:14:21.933712	SUCCESS	\N	\N	f
40	VISITOR	\N	\N	OUT	2026-03-02 23:14:21.951143	SUCCESS	\N	gate_1_1772473461949.jpg	f
41	VISITOR	1007	2	OUT	2026-03-02 23:18:27.736616	SUCCESS	\N	\N	f
42	VISITOR	1006	2	IN	2026-03-02 23:18:44.978855	SUCCESS	\N	\N	f
43	LABOUR	5039	2	IN	2026-03-02 23:19:47.149612	SUCCESS	\N	\N	f
44	VISITOR	1012	2	OUT	2026-03-03 13:05:17.403941	SUCCESS	\N	\N	f
45	VISITOR	1011	2	IN	2026-03-03 13:05:29.20247	SUCCESS	\N	\N	f
46	VISITOR	1006	2	OUT	2026-03-03 13:05:53.35341	SUCCESS	\N	\N	f
47	VISITOR	1088	2	IN	2026-03-03 13:07:11.560692	SUCCESS	\N	\N	f
48	LABOUR	5040	2	IN	2026-03-03 13:19:41.970694	SUCCESS	\N	\N	f
49	LABOUR	5041	2	IN	2026-03-03 13:20:14.050274	SUCCESS	\N	\N	f
50	LABOUR	5042	2	IN	2026-03-03 13:20:24.912659	SUCCESS	\N	\N	f
51	LABOUR	5043	2	IN	2026-03-03 13:20:35.683104	SUCCESS	\N	\N	f
52	LABOUR	5043	2	OUT	2026-03-03 13:21:19.36993	SUCCESS	\N	\N	f
53	LABOUR	5042	2	OUT	2026-03-03 13:21:29.752871	SUCCESS	\N	\N	f
54	LABOUR	5041	2	OUT	2026-03-03 13:21:39.580878	SUCCESS	\N	\N	f
55	LABOUR	5040	2	OUT	2026-03-03 13:21:49.429733	SUCCESS	\N	\N	f
56	LABOUR	5044	2	IN	2026-03-03 13:25:43.966111	SUCCESS	\N	\N	f
57	LABOUR	5045	2	IN	2026-03-03 13:25:49.638762	SUCCESS	\N	\N	f
58	LABOUR	5044	2	OUT	2026-03-03 13:26:09.382556	SUCCESS	\N	\N	f
59	LABOUR	5044	2	IN	2026-03-03 13:26:14.311973	SUCCESS	\N	\N	f
60	LABOUR	5044	2	OUT	2026-03-03 13:26:41.413747	SUCCESS	\N	\N	f
61	LABOUR	5045	2	OUT	2026-03-03 13:27:03.774882	SUCCESS	\N	\N	f
62	LABOUR	5045	2	IN	2026-03-03 13:27:15.073908	SUCCESS	\N	\N	f
63	LABOUR	5045	2	OUT	2026-03-03 13:28:23.581107	SUCCESS	\N	\N	f
64	LABOUR	5046	2	IN	2026-03-03 14:37:33.500194	SUCCESS	\N	\N	f
65	LABOUR	5047	2	IN	2026-03-03 14:37:50.474632	SUCCESS	\N	\N	f
66	LABOUR	5048	2	IN	2026-03-03 14:38:02.089172	SUCCESS	\N	\N	f
67	LABOUR	5048	2	OUT	2026-03-03 14:38:25.092979	SUCCESS	\N	\N	f
68	LABOUR	5047	2	OUT	2026-03-03 14:38:38.333294	SUCCESS	\N	\N	f
69	LABOUR	5046	2	OUT	2026-03-03 14:38:57.039042	SUCCESS	\N	\N	f
70	VISITOR	1011	2	OUT	2026-03-03 17:19:19.655384	SUCCESS	\N	\N	f
71	VISITOR	1088	2	OUT	2026-03-03 17:20:16.127587	SUCCESS	\N	\N	f
72	VISITOR	1013	2	OUT	2026-03-03 17:23:53.848322	SUCCESS	\N	\N	f
73	VISITOR	1014	2	OUT	2026-03-03 17:24:27.284122	SUCCESS	\N	\N	f
74	LABOUR	5039	\N	OUT	2026-03-03 17:42:41.364245	SUCCESS	\N	\N	t
75	VISITOR	1013	2	IN	2026-03-03 23:44:02.662137	SUCCESS	\N	\N	f
76	VISITOR	1013	2	OUT	2026-03-03 23:44:15.782272	SUCCESS	\N	\N	f
77	VISITOR	1013	2	IN	2026-03-03 23:46:34.843922	SUCCESS	\N	\N	f
78	VISITOR	1013	2	OUT	2026-03-03 23:47:02.788265	SUCCESS	\N	\N	f
79	VISITOR	1012	2	IN	2026-03-03 23:47:38.85863	SUCCESS	\N	\N	f
80	VISITOR	1012	2	OUT	2026-03-03 23:47:56.482137	SUCCESS	\N	\N	f
81	VISITOR	1011	2	IN	2026-03-03 23:50:19.478893	SUCCESS	\N	\N	f
82	VISITOR	1011	2	OUT	2026-03-03 23:51:57.916248	SUCCESS	\N	\N	f
83	VISITOR	1006	2	IN	2026-03-03 23:54:49.33543	SUCCESS	\N	\N	f
84	VISITOR	1006	2	OUT	2026-03-03 23:55:04.976328	SUCCESS	\N	\N	f
85	VISITOR	1007	2	IN	2026-03-04 00:00:01.420767	SUCCESS	\N	\N	f
86	VISITOR	1013	2	IN	2026-03-04 00:01:36.964154	SUCCESS	\N	\N	f
87	VISITOR	1013	2	OUT	2026-03-04 00:01:50.755676	SUCCESS	\N	\N	f
88	VISITOR	1013	2	IN	2026-03-04 00:02:02.658632	SUCCESS	\N	\N	f
89	VISITOR	1013	2	OUT	2026-03-04 00:02:15.003257	SUCCESS	\N	\N	f
90	VISITOR	1012	2	IN	2026-03-04 00:02:29.541669	SUCCESS	\N	\N	f
91	VISITOR	1013	2	IN	2026-03-04 00:02:41.717605	SUCCESS	\N	\N	f
92	VISITOR	1013	2	OUT	2026-03-04 00:02:46.394527	SUCCESS	\N	\N	f
93	VISITOR	1012	2	OUT	2026-03-04 00:02:55.251257	SUCCESS	\N	\N	f
94	VISITOR	1013	2	IN	2026-03-04 00:04:34.066617	SUCCESS	\N	\N	f
95	VISITOR	1013	2	OUT	2026-03-04 00:04:42.998084	SUCCESS	\N	\N	f
96	VISITOR	1012	2	IN	2026-03-04 00:04:57.156826	SUCCESS	\N	\N	f
97	VISITOR	1012	2	OUT	2026-03-04 00:05:09.960915	SUCCESS	\N	\N	f
98	LABOUR	5153	2	IN	2026-03-04 17:37:47.83924	SUCCESS	\N	\N	f
99	LABOUR	5154	2	IN	2026-03-04 17:38:07.750262	SUCCESS	\N	\N	f
100	LABOUR	5155	2	IN	2026-03-04 17:38:23.944694	SUCCESS	\N	\N	f
101	LABOUR	5156	2	IN	2026-03-04 17:38:43.865844	SUCCESS	\N	\N	f
102	LABOUR	5157	2	IN	2026-03-04 17:38:56.564381	SUCCESS	\N	\N	f
103	LABOUR	5158	2	IN	2026-03-04 17:39:09.745095	SUCCESS	\N	\N	f
104	LABOUR	5159	2	IN	2026-03-04 17:39:26.951755	SUCCESS	\N	\N	f
105	VISITOR	1007	2	OUT	2026-03-04 17:44:13.593176	SUCCESS	\N	\N	f
106	VISITOR	1012	2	IN	2026-03-04 18:33:34.80937	SUCCESS	\N	\N	f
107	VISITOR	1012	2	OUT	2026-03-04 18:33:48.363819	SUCCESS	\N	\N	f
108	LABOUR	5153	2	OUT	2026-03-04 19:03:43.102534	SUCCESS	\N	\N	f
109	LABOUR	5154	2	OUT	2026-03-04 19:03:55.329791	SUCCESS	\N	\N	f
110	LABOUR	5155	2	OUT	2026-03-04 19:05:05.461066	SUCCESS	\N	\N	f
111	LABOUR	5156	2	OUT	2026-03-04 19:05:22.732674	SUCCESS	\N	\N	f
112	LABOUR	5157	2	OUT	2026-03-04 19:05:38.74976	SUCCESS	\N	\N	f
113	LABOUR	5158	2	OUT	2026-03-04 19:05:52.721439	SUCCESS	\N	\N	f
114	LABOUR	5159	2	OUT	2026-03-04 19:06:04.773284	SUCCESS	\N	\N	f
115	LABOUR	5160	2	IN	2026-03-04 19:11:38.323001	SUCCESS	\N	\N	f
116	LABOUR	5160	2	OUT	2026-03-04 19:12:23.5444	SUCCESS	\N	\N	f
117	VISITOR	1115	2	IN	2026-03-04 19:13:51.266353	SUCCESS	\N	\N	f
118	VISITOR	1115	2	OUT	2026-03-04 19:17:34.905849	SUCCESS	\N	\N	f
119	VISITOR	1013	2	IN	2026-03-05 19:00:03.666846	SUCCESS	\N	\N	f
120	VISITOR	1011	2	IN	2026-03-05 19:01:49.825897	SUCCESS	\N	\N	f
121	VISITOR	1011	2	OUT	2026-03-05 19:03:44.715048	SUCCESS	\N	\N	f
122	VISITOR	1013	2	OUT	2026-03-05 19:03:57.891117	SUCCESS	\N	\N	f
123	VISITOR	1013	2	IN	2026-03-05 19:47:42.393069	SUCCESS	\N	\N	f
124	VISITOR	1013	2	OUT	2026-03-05 19:47:53.756549	SUCCESS	\N	\N	f
125	VISITOR	1011	2	IN	2026-03-05 20:11:15.87766	SUCCESS	\N	\N	f
126	VISITOR	1013	2	IN	2026-03-05 20:11:29.428438	SUCCESS	\N	\N	f
127	VISITOR	1011	2	OUT	2026-03-05 20:11:54.553736	SUCCESS	\N	\N	f
128	VISITOR	1013	2	OUT	2026-03-05 20:12:07.518187	SUCCESS	\N	\N	f
129	LABOUR	5161	2	IN	2026-03-05 20:13:52.961051	SUCCESS	\N	\N	f
130	LABOUR	5162	2	IN	2026-03-05 20:14:11.459269	SUCCESS	\N	\N	f
131	LABOUR	5161	2	OUT	2026-03-05 20:14:32.239323	SUCCESS	\N	\N	f
132	LABOUR	5162	2	OUT	2026-03-05 20:14:46.108169	SUCCESS	\N	\N	f
133	VISITOR	1013	2	IN	2026-03-06 14:57:33.826816	SUCCESS	\N	\N	f
134	VISITOR	1011	2	IN	2026-03-06 15:02:27.38948	SUCCESS	\N	\N	f
135	VISITOR	1011	2	OUT	2026-03-06 15:02:41.057361	SUCCESS	\N	\N	f
136	VISITOR	1013	2	OUT	2026-03-06 15:02:58.263117	SUCCESS	\N	\N	f
137	LABOUR	5163	2	IN	2026-03-06 15:08:36.211935	SUCCESS	\N	\N	f
138	LABOUR	5164	2	IN	2026-03-06 15:09:11.188603	SUCCESS	\N	\N	f
139	LABOUR	5163	2	OUT	2026-03-06 15:21:12.719925	SUCCESS	\N	\N	f
140	LABOUR	5164	2	OUT	2026-03-06 15:21:34.150144	SUCCESS	\N	\N	f
141	LABOUR	5165	2	IN	2026-03-06 17:14:46.776491	SUCCESS	\N	\N	f
142	LABOUR	5166	2	IN	2026-03-06 17:15:09.353086	SUCCESS	\N	\N	f
143	LABOUR	5165	2	OUT	2026-03-06 17:15:45.143389	SUCCESS	\N	\N	f
144	LABOUR	5166	2	OUT	2026-03-06 17:16:11.30611	SUCCESS	\N	\N	f
145	VISITOR	1013	2	IN	2026-03-06 17:29:33.925745	SUCCESS	\N	\N	f
146	VISITOR	1013	2	OUT	2026-03-06 17:35:22.354582	SUCCESS	\N	\N	f
147	LABOUR	5167	2	IN	2026-03-06 17:44:13.335667	SUCCESS	\N	\N	f
148	LABOUR	5168	2	IN	2026-03-06 17:44:46.108366	SUCCESS	\N	\N	f
149	LABOUR	5169	2	IN	2026-03-06 17:44:59.952366	SUCCESS	\N	\N	f
150	VISITOR	1116	2	IN	2026-03-06 17:46:05.467797	SUCCESS	\N	\N	f
151	VISITOR	1013	2	IN	2026-03-06 17:51:44.861612	SUCCESS	\N	uploads/visitors/1013/live/gate_1_1772799704960.jpg	f
152	LABOUR	5167	2	OUT	2026-03-06 17:53:10.363736	SUCCESS	\N	uploads/visitors/1116/labours/gate_2_1772799790352.jpg	f
153	LABOUR	5168	2	OUT	2026-03-06 17:53:37.892619	SUCCESS	\N	uploads/visitors/1116/labours/gate_2_1772799817881.jpg	f
154	LABOUR	5169	2	OUT	2026-03-06 17:53:49.270603	SUCCESS	\N	uploads/visitors/1116/labours/gate_2_1772799829257.jpg	f
155	VISITOR	1013	2	OUT	2026-03-06 17:57:18.328195	SUCCESS	\N	uploads/visitors/1013/live/gate_2_1772800038318.jpg	f
156	VISITOR	1116	2	OUT	2026-03-06 17:57:36.796009	SUCCESS	\N	uploads/visitors/1116/live/gate_2_1772800056786.jpg	f
157	LABOUR	5170	2	IN	2026-03-06 18:01:50.222071	SUCCESS	\N	uploads/visitors/1016/labours/gate_2_1772800310214.jpg	f
158	LABOUR	5171	2	IN	2026-03-06 18:02:42.063219	SUCCESS	\N	uploads/visitors/1016/labours/gate_2_1772800362056.jpg	f
159	LABOUR	5170	2	OUT	2026-03-06 18:10:54.57636	SUCCESS	\N	uploads/visitors/1016/labours/gate_2_1772800854570.jpg	f
160	LABOUR	5171	2	OUT	2026-03-06 18:11:00.788809	SUCCESS	\N	uploads/visitors/1016/labours/gate_2_1772800860783.jpg	f
161	VISITOR	1013	2	IN	2026-03-06 18:24:09.687901	SUCCESS	\N	uploads/visitors/1013/live/gate_2_1772801649684.jpg	f
162	VISITOR	1013	2	OUT	2026-03-06 18:28:19.543584	SUCCESS	\N	uploads/visitors/1013/live/gate_2_1772801899538.jpg	f
163	VISITOR	1013	2	IN	2026-03-06 18:33:26.364014	SUCCESS	\N	uploads/visitors/1013/live/gate_2_1772802206358.jpg	f
164	VISITOR	1013	2	OUT	2026-03-06 19:12:48.892189	SUCCESS	\N	uploads/visitors/1013/live/gate_2_1772804568888.jpg	f
165	VISITOR	1013	2	IN	2026-03-06 19:15:42.710706	SUCCESS	\N	uploads/visitors/1013/live/gate_2_1772804742707.jpg	f
166	VISITOR	1013	2	OUT	2026-03-06 19:16:01.66068	SUCCESS	\N	uploads/visitors/1013/live/gate_2_1772804761658.jpg	f
167	VISITOR	1013	2	IN	2026-03-06 19:16:21.213479	SUCCESS	\N	uploads/visitors/1013/live/gate_2_1772804781208.jpg	f
168	VISITOR	1013	2	OUT	2026-03-06 19:20:45.371621	SUCCESS	\N	uploads/visitors/1013/live/gate_2_1772805045365.jpg	f
169	VISITOR	1013	2	IN	2026-03-06 19:26:54.274483	SUCCESS	\N	uploads/visitors/1013/live/gate_2_1772805414267.jpg	f
170	VISITOR	1013	2	OUT	2026-03-06 19:27:07.656067	SUCCESS	\N	uploads/visitors/1013/live/gate_2_1772805427648.jpg	f
171	VISITOR	1013	2	IN	2026-03-06 19:32:20.305054	SUCCESS	\N	uploads/visitors/1013/live/gate_2_1772805740299.jpg	f
172	VISITOR	1013	2	OUT	2026-03-06 19:32:53.408699	SUCCESS	\N	uploads/visitors/1013/live/gate_2_1772805773403.jpg	f
173	VISITOR	1013	2	IN	2026-03-06 19:34:07.655219	SUCCESS	\N	uploads/visitors/1013/live/gate_2_1772805847650.jpg	f
174	VISITOR	1116	2	IN	2026-03-06 19:34:26.071562	SUCCESS	\N	uploads/visitors/1116/live/gate_2_1772805866067.jpg	f
175	VISITOR	1013	2	OUT	2026-03-06 23:00:53.570069	SUCCESS	\N	uploads/visitors/1013/live/gate_2_1772818253557.jpg	f
176	VISITOR	1013	2	IN	2026-03-06 23:01:03.645907	SUCCESS	\N	uploads/visitors/1013/live/gate_2_1772818263634.jpg	f
177	VISITOR	1116	2	OUT	2026-03-06 23:08:09.247914	SUCCESS	\N	uploads/visitors/1116/live/gate_2_1772818689238.jpg	f
178	VISITOR	1011	2	IN	2026-03-06 23:08:36.382623	SUCCESS	\N	uploads/visitors/1011/live/gate_2_1772818716367.jpg	f
179	VISITOR	1013	2	OUT	2026-03-06 23:09:00.674942	SUCCESS	\N	uploads/visitors/1013/live/gate_2_1772818740663.jpg	f
180	VISITOR	1116	2	IN	2026-03-06 23:09:22.639336	SUCCESS	\N	uploads/visitors/1116/live/gate_2_1772818762630.jpg	f
181	VISITOR	1117	2	IN	2026-03-08 16:52:28.254036	SUCCESS	\N	uploads/visitors/1117/live/gate_2_1772968948245.jpg	f
182	VISITOR	1117	2	OUT	2026-03-08 17:19:25.332469	SUCCESS	\N	uploads/visitors/1117/live/gate_2_1772970565321.jpg	f
183	VISITOR	1116	2	OUT	2026-03-08 17:19:43.712661	SUCCESS	\N	uploads/visitors/1116/live/gate_2_1772970583705.jpg	f
184	VISITOR	1115	2	IN	2026-03-08 17:19:58.631757	SUCCESS	\N	uploads/visitors/1115/live/gate_2_1772970598625.jpg	f
185	VISITOR	1016	2	IN	2026-03-08 17:20:36.11928	SUCCESS	\N	uploads/visitors/1016/live/gate_2_1772970636112.jpg	f
186	VISITOR	1077	2	IN	2026-03-08 17:20:54.073345	SUCCESS	\N	uploads/visitors/1077/live/gate_2_1772970654061.jpg	f
187	VISITOR	1115	2	OUT	2026-03-08 17:24:45.615652	SUCCESS	\N	uploads/visitors/1115/live/gate_2_1772970885610.jpg	f
188	VISITOR	1117	2	IN	2026-03-08 17:26:05.000484	SUCCESS	\N	uploads/visitors/1117/live/gate_2_1772970964991.jpg	f
189	VISITOR	1117	2	OUT	2026-03-08 17:28:56.937453	SUCCESS	\N	uploads/visitors/1117/live/gate_2_1772971136931.jpg	f
190	VISITOR	1117	2	IN	2026-03-08 17:29:19.185124	SUCCESS	\N	uploads/visitors/1117/live/gate_2_1772971159177.jpg	f
191	VISITOR	1117	2	OUT	2026-03-08 17:31:46.545584	SUCCESS	\N	uploads/visitors/1117/live/gate_2_1772971306535.jpg	f
192	VISITOR	1117	2	IN	2026-03-08 17:32:27.743503	SUCCESS	\N	uploads/visitors/1117/live/gate_2_1772971347732.jpg	f
193	VISITOR	1117	2	OUT	2026-03-08 17:33:22.219171	SUCCESS	\N	uploads/visitors/1117/live/gate_2_1772971402213.jpg	f
194	VISITOR	1117	2	IN	2026-03-08 17:41:28.431869	SUCCESS	\N	uploads/visitors/1117/live/gate_2_1772971888425.jpg	f
195	VISITOR	1117	2	OUT	2026-03-08 17:45:35.723716	SUCCESS	\N	uploads/visitors/1117/live/gate_2_1772972135710.jpg	f
196	VISITOR	1117	2	IN	2026-03-08 17:46:11.47815	SUCCESS	\N	uploads/visitors/1117/live/gate_2_1772972171467.jpg	f
197	VISITOR	1117	2	OUT	2026-03-08 17:49:23.467342	SUCCESS	\N	uploads/visitors/1117/live/gate_2_1772972363458.jpg	f
198	VISITOR	1116	2	IN	2026-03-08 17:49:59.389877	SUCCESS	\N	uploads/visitors/1116/live/gate_2_1772972399381.jpg	f
199	VISITOR	1117	2	IN	2026-03-08 17:52:21.119259	SUCCESS	\N	uploads/visitors/1117/live/gate_2_1772972541112.jpg	f
200	VISITOR	1117	2	OUT	2026-03-08 17:58:00.139263	SUCCESS	\N	uploads/visitors/1117/live/gate_2_1772972880132.jpg	f
201	VISITOR	1117	2	IN	2026-03-08 18:04:28.012707	SUCCESS	\N	uploads/visitors/1117/live/gate_2_1772973268009.jpg	f
202	VISITOR	1117	2	OUT	2026-03-08 18:06:01.302574	SUCCESS	\N	uploads/visitors/1117/live/gate_2_1772973361298.jpg	f
203	VISITOR	1117	2	IN	2026-03-08 18:07:54.014443	SUCCESS	\N	uploads/visitors/1117/live/gate_2_1772973474011.jpg	f
204	VISITOR	1117	2	OUT	2026-03-08 18:09:26.87694	SUCCESS	\N	uploads/visitors/1117/live/gate_2_1772973566873.jpg	f
205	VISITOR	1117	2	IN	2026-03-08 18:09:41.553983	SUCCESS	\N	uploads/visitors/1117/live/gate_2_1772973581550.jpg	f
206	VISITOR	1117	2	OUT	2026-03-08 18:11:30.30735	SUCCESS	\N	uploads/visitors/1117/live/gate_2_1772973690304.jpg	f
207	VISITOR	1117	2	IN	2026-03-08 18:13:17.421172	SUCCESS	\N	uploads/visitors/1117/live/gate_2_1772973797418.jpg	f
208	VISITOR	1116	2	OUT	2026-03-08 18:25:52.104479	SUCCESS	\N	uploads/visitors/1116/live/gate_2_1772974552100.jpg	f
209	VISITOR	1116	2	IN	2026-03-08 18:48:26.394807	SUCCESS	\N	uploads/visitors/1116/live/gate_2_1772975906389.jpg	f
210	VISITOR	1116	2	OUT	2026-03-08 18:50:28.827535	SUCCESS	\N	uploads/visitors/1116/live/gate_2_1772976028823.jpg	f
211	VISITOR	1117	2	OUT	2026-03-08 18:50:47.691842	SUCCESS	\N	uploads/visitors/1117/live/gate_2_1772976047688.jpg	f
212	VISITOR	1116	2	IN	2026-03-08 18:55:52.99984	SUCCESS	\N	uploads/visitors/1116/live/gate_2_1772976352993.jpg	f
213	VISITOR	1116	2	OUT	2026-03-08 18:57:30.336517	SUCCESS	\N	uploads/visitors/1116/live/gate_2_1772976450333.jpg	f
214	VISITOR	1116	2	IN	2026-03-08 18:58:30.960895	SUCCESS	\N	uploads/visitors/1116/live/gate_2_1772976510954.jpg	f
215	VISITOR	1116	2	OUT	2026-03-08 18:59:03.951173	SUCCESS	\N	uploads/visitors/1116/live/gate_2_1772976543948.jpg	f
216	VISITOR	1116	2	IN	2026-03-08 19:00:04.918445	SUCCESS	\N	uploads/visitors/1116/live/gate_2_1772976604914.jpg	f
217	VISITOR	1116	2	OUT	2026-03-08 19:00:41.585659	SUCCESS	\N	uploads/visitors/1116/live/gate_2_1772976641582.jpg	f
218	VISITOR	1116	2	IN	2026-03-08 19:02:23.128413	SUCCESS	\N	uploads/visitors/1116/live/gate_2_1772976743125.jpg	f
219	VISITOR	1116	2	OUT	2026-03-08 19:05:17.213457	SUCCESS	\N	uploads/visitors/1116/live/gate_2_1772976917209.jpg	f
220	VISITOR	1116	2	IN	2026-03-08 19:07:20.367683	SUCCESS	\N	uploads/visitors/1116/live/gate_2_1772977040364.jpg	f
221	VISITOR	1116	2	OUT	2026-03-08 19:07:43.412665	SUCCESS	\N	uploads/visitors/1116/live/gate_2_1772977063406.jpg	f
222	VISITOR	1116	2	IN	2026-03-08 19:09:16.850044	SUCCESS	\N	uploads/visitors/1116/live/gate_2_1772977156847.jpg	f
223	VISITOR	1117	2	IN	2026-03-08 19:09:43.300712	SUCCESS	\N	uploads/visitors/1117/live/gate_2_1772977183298.jpg	f
224	VISITOR	1013	2	IN	2026-03-08 19:10:27.076196	SUCCESS	\N	uploads/visitors/1013/live/gate_2_1772977227070.jpg	f
225	VISITOR	1116	2	OUT	2026-03-08 19:10:49.116725	SUCCESS	\N	uploads/visitors/1116/live/gate_2_1772977249112.jpg	f
226	VISITOR	1116	2	IN	2026-03-08 19:12:11.204116	SUCCESS	\N	uploads/visitors/1116/live/gate_2_1772977331200.jpg	f
227	VISITOR	1117	2	OUT	2026-03-08 19:12:32.418761	SUCCESS	\N	uploads/visitors/1117/live/gate_2_1772977352416.jpg	f
228	LABOUR	5174	2	IN	2026-03-08 19:14:05.827234	SUCCESS	\N	uploads/visitors/1116/labours/gate_2_1772977445824.jpg	f
229	LABOUR	5175	2	IN	2026-03-08 19:14:39.647724	SUCCESS	\N	uploads/visitors/1116/labours/gate_2_1772977479644.jpg	f
230	LABOUR	5174	2	OUT	2026-03-08 19:15:10.250095	SUCCESS	\N	uploads/visitors/1116/labours/gate_2_1772977510246.jpg	f
231	LABOUR	5175	2	OUT	2026-03-08 19:15:21.214835	SUCCESS	\N	uploads/visitors/1116/labours/gate_2_1772977521210.jpg	f
232	VISITOR	1116	2	OUT	2026-03-08 23:17:53.843464	SUCCESS	\N	uploads/visitors/1116/live/gate_2_1772992073837.jpg	f
233	VISITOR	1013	2	OUT	2026-03-08 23:18:46.078368	SUCCESS	\N	uploads/visitors/1013/live/gate_2_1772992126073.jpg	f
234	VISITOR	1077	2	OUT	2026-03-08 23:20:03.487205	SUCCESS	\N	uploads/visitors/1077/live/gate_2_1772992203483.jpg	f
235	VISITOR	1011	2	OUT	2026-03-08 23:20:38.063134	SUCCESS	\N	uploads/visitors/1011/live/gate_2_1772992238059.jpg	f
236	VISITOR	1016	2	OUT	2026-03-08 23:21:21.5771	SUCCESS	\N	uploads/visitors/1016/live/gate_2_1772992281573.jpg	f
237	LABOUR	5176	2	IN	2026-03-09 12:13:39.847144	SUCCESS	\N	uploads/visitors/1115/labours/gate_2_1773038619837.jpg	f
238	LABOUR	5177	2	IN	2026-03-09 12:14:12.407782	SUCCESS	\N	uploads/visitors/1115/labours/gate_2_1773038652400.jpg	f
239	LABOUR	5176	2	OUT	2026-03-09 12:14:53.244025	SUCCESS	\N	uploads/visitors/1115/labours/gate_2_1773038693230.jpg	f
240	LABOUR	5177	2	OUT	2026-03-09 12:15:26.425254	SUCCESS	\N	uploads/visitors/1115/labours/gate_2_1773038726413.jpg	f
241	VISITOR	1013	2	IN	2026-03-09 12:21:05.624151	SUCCESS	\N	uploads/visitors/1013/live/gate_2_1773039065616.jpg	f
242	VISITOR	1116	2	IN	2026-03-09 12:21:41.08179	SUCCESS	\N	uploads/visitors/1116/live/gate_2_1773039101077.jpg	f
243	VISITOR	1117	2	IN	2026-03-09 12:28:22.913518	SUCCESS	\N	uploads/visitors/1117/live/gate_2_1773039502906.jpg	f
244	LABOUR	5178	2	IN	2026-03-09 15:10:04.526854	SUCCESS	\N	uploads/visitors/1115/labours/gate_2_1773049204519.jpg	f
245	LABOUR	5179	2	IN	2026-03-09 15:10:13.16076	SUCCESS	\N	uploads/visitors/1115/labours/gate_2_1773049213153.jpg	f
246	LABOUR	5179	2	OUT	2026-03-09 16:45:37.889223	SUCCESS	\N	uploads/visitors/1115/labours/gate_2_1773054937885.jpg	f
247	LABOUR	5178	2	OUT	2026-03-09 16:45:46.051402	SUCCESS	\N	uploads/visitors/1115/labours/gate_2_1773054946047.jpg	f
248	VISITOR	1013	2	OUT	2026-03-09 16:46:40.669007	SUCCESS	\N	uploads/visitors/1013/live/gate_2_1773055000664.jpg	f
249	VISITOR	1117	2	OUT	2026-03-09 16:47:01.749605	SUCCESS	\N	uploads/visitors/1117/live/gate_2_1773055021743.jpg	f
250	VISITOR	1116	2	OUT	2026-03-09 16:47:36.781621	SUCCESS	\N	uploads/visitors/1116/live/gate_2_1773055056776.jpg	f
251	VISITOR	1115	2	IN	2026-03-10 18:52:35.066384	SUCCESS	\N	uploads/visitors/1115/live/gate_2_1773148955063.jpg	f
252	VISITOR	1115	2	OUT	2026-03-10 19:12:36.271928	SUCCESS	\N	uploads/visitors/1115/live/gate_2_1773150156266.jpg	f
253	VISITOR	1117	2	IN	2026-03-10 19:15:01.902742	SUCCESS	\N	uploads/visitors/1117/live/gate_2_1773150301899.jpg	f
254	VISITOR	1115	2	IN	2026-03-10 19:19:44.464158	SUCCESS	\N	uploads/visitors/1115/live/gate_2_1773150584460.jpg	f
255	VISITOR	1115	2	OUT	2026-03-10 19:19:47.72048	SUCCESS	\N	uploads/visitors/1115/live/gate_2_1773150587718.jpg	f
256	VISITOR	1117	2	OUT	2026-03-10 19:52:27.840872	SUCCESS	\N	uploads/visitors/1117/live/gate_2_1773152547833.jpg	f
\.


--
-- TOC entry 5387 (class 0 OID 17286)
-- Dependencies: 240
-- Data for Name: biometric_data; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.biometric_data (id, visitor_id, biometric_hash, algorithm, enrolled_at) FROM stdin;
3002	1009	e93a61d9f73966cc4f49308299504994bce43a509eca585321c668e0a0437733	SHA256	2026-02-27 19:07:15.047554
3003	1012	7f6ab7beca22eb589fc3716bdd0ae2560d29e686eca7d7fd80b3f4bdb0f86182	SHA256	2026-02-27 19:17:18.917858
3004	1014	5b793d330915f50790710f920494674e85b7638219e72d34f9dac45b4b8fbf17	SHA256	2026-02-28 11:39:45.407988
3005	1013	8a0f689819a1fc90f4b57b26ae6002a311ef38a4445c1e2f83e94019f18f6a5d	SHA256	2026-02-28 12:00:22.933558
\.


--
-- TOC entry 5389 (class 0 OID 17304)
-- Dependencies: 242
-- Data for Name: biometric_match_audit; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.biometric_match_audit (id, visitor_id, gate_id, biometric_hash, match_score, match_result, attempt_time) FROM stdin;
\.


--
-- TOC entry 5408 (class 0 OID 17492)
-- Dependencies: 262
-- Data for Name: blacklist; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.blacklist (id, aadhaar_hash, phone, biometric_hash, reason, block_type, created_at) FROM stdin;
9001	hash_blacklist_1	9990001111	\N	Security concern	TEMPORARY	2026-02-23 00:16:02.150516
9002	fb968757c74706d2cc7f1427ab8b55fdcfaa0148e74c508da3a205cc190682b3	\N	\N	blocked	TEMPORARY	2026-03-03 23:30:30.341738
\.


--
-- TOC entry 5393 (class 0 OID 17340)
-- Dependencies: 246
-- Data for Name: card_reissue_log; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.card_reissue_log (id, old_card_id, new_card_id, aso_document_id, reissued_by, reason, reissued_at) FROM stdin;
\.


--
-- TOC entry 5373 (class 0 OID 17145)
-- Dependencies: 226
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.departments (id, department_name, is_active, created_at) FROM stdin;
2	Engineering	t	2026-02-23 11:55:46.257238
3	Operations	t	2026-02-23 11:55:46.257238
5	Administration	f	2026-02-23 11:55:46.257238
6	Administration	t	2026-02-26 16:39:21.270669
4	Security	f	2026-02-23 11:55:46.257238
7	Security	t	2026-02-26 17:01:50.161636
8	Air Traffic Control	t	2026-03-07 15:28:01.415337
9	Base Support Facility	t	2026-03-07 15:28:20.266604
10	Motor Transport	t	2026-03-07 15:29:38.493275
11	Fire Fighting Service	t	2026-03-07 15:29:58.75288
\.


--
-- TOC entry 5377 (class 0 OID 17178)
-- Dependencies: 230
-- Data for Name: entrances; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.entrances (id, entrance_code, entrance_name, is_main_gate) FROM stdin;
2	MGR	Main Guard Room	t
3	SGR	Sub Guard Room	f
4	NORA	Naval Officers Residential Area	f
\.


--
-- TOC entry 5413 (class 0 OID 17530)
-- Dependencies: 267
-- Data for Name: gate_health; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.gate_health (gate_id, last_heartbeat, is_online, cpu_usage, memory_usage, storage_usage, camera_status, rfid_status, biometric_status, updated_at) FROM stdin;
2	2026-03-02 23:20:44.52046	f	\N	\N	\N	\N	\N	\N	2026-03-03 12:40:27.698018
3	2026-03-02 23:20:44.559484	f	\N	\N	\N	\N	\N	\N	2026-03-03 12:40:27.717845
4	2026-03-02 23:20:44.562697	f	\N	\N	\N	\N	\N	\N	2026-03-03 12:40:27.721622
5	2026-03-02 23:20:44.567175	f	\N	\N	\N	\N	\N	\N	2026-03-03 12:40:27.724996
\.


--
-- TOC entry 5415 (class 0 OID 17543)
-- Dependencies: 269
-- Data for Name: gate_health_logs; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.gate_health_logs (id, gate_id, heartbeat_time, cpu_usage, memory_usage, storage_usage, camera_status, rfid_status, biometric_status) FROM stdin;
1	2	2026-02-28 21:18:02.903848	48.13	34.88	28.92	t	t	t
5	4	2026-02-28 21:18:12.834942	20.06	57.06	54.08	t	t	t
1228	2	2026-03-02 17:43:28.715325	38.94	27.29	50.02	t	t	t
1235	3	2026-03-02 17:43:38.727655	24.65	69.00	47.75	t	t	t
1237	4	2026-03-02 17:43:48.724687	28.11	66.63	51.14	t	t	t
1243	4	2026-03-02 17:43:58.73606	11.17	42.36	22.30	t	t	t
1247	5	2026-03-02 17:44:08.746355	70.74	49.44	58.05	t	t	t
1248	2	2026-03-02 17:44:18.74852	19.15	12.27	42.99	t	t	t
1253	5	2026-03-02 17:44:28.766742	54.11	47.83	62.67	t	t	t
1258	4	2026-03-02 17:44:38.768453	49.89	12.66	58.31	t	t	t
1263	4	2026-03-02 17:44:48.768637	30.19	12.45	65.99	t	t	f
1264	2	2026-03-02 17:44:58.770485	60.28	61.33	38.48	t	t	t
1269	5	2026-03-02 17:45:08.783826	29.66	31.24	26.46	t	t	t
1272	4	2026-03-02 17:45:18.783378	62.24	78.44	34.56	t	t	t
1278	3	2026-03-02 17:45:28.783843	31.83	41.53	43.70	f	t	t
1283	3	2026-03-02 17:45:38.792918	44.14	26.89	50.89	t	t	t
1284	2	2026-03-02 17:45:48.798355	71.83	12.25	68.55	t	t	t
1290	3	2026-03-02 17:45:58.806192	69.28	60.07	31.71	t	t	t
1293	5	2026-03-02 17:46:08.82092	63.82	65.41	25.94	t	t	t
1297	4	2026-03-02 17:46:18.831623	51.37	36.99	67.31	t	t	t
1889	3	2026-03-02 18:10:59.973865	78.52	23.43	69.14	t	t	t
1893	5	2026-03-02 18:11:09.955695	10.65	66.77	64.91	t	t	t
1899	3	2026-03-02 18:11:19.969328	38.05	18.03	21.63	t	t	t
1900	3	2026-03-02 18:11:29.97975	53.72	71.93	33.13	t	t	t
1906	3	2026-03-02 18:11:39.979396	35.90	59.21	57.12	f	t	t
1908	2	2026-03-02 18:11:49.984882	30.10	46.71	45.22	t	t	t
2215	3	2026-03-02 18:24:30.630855	30.00	58.90	28.88	t	t	t
2217	4	2026-03-02 18:24:40.636773	36.15	64.10	27.07	t	t	t
2223	4	2026-03-02 18:24:50.645919	66.39	45.06	36.10	t	t	t
2227	2	2026-03-02 18:25:00.64828	11.31	25.36	55.47	t	f	t
2228	2	2026-03-02 18:25:10.658735	53.67	11.81	21.23	t	t	t
2233	4	2026-03-02 18:25:20.668045	38.78	26.91	21.32	t	t	t
2236	3	2026-03-02 18:25:30.672459	57.31	53.19	27.04	t	f	t
2502	4	2026-03-02 18:36:31.125878	73.50	24.15	36.06	t	t	t
2507	3	2026-03-02 18:36:41.135468	71.83	71.05	28.79	t	t	t
2511	4	2026-03-02 18:36:51.148833	23.09	45.85	48.49	t	t	t
2514	3	2026-03-02 18:37:01.153404	78.75	25.12	32.22	t	t	t
2518	3	2026-03-02 18:37:11.163048	30.98	59.96	32.11	f	t	t
2520	2	2026-03-02 18:37:21.167154	35.55	39.87	67.16	f	t	t
2525	5	2026-03-02 18:37:31.180812	26.44	52.21	69.36	t	t	f
2531	4	2026-03-02 18:37:41.195078	22.10	21.85	54.75	t	f	t
2534	4	2026-03-02 18:37:51.207895	17.35	19.76	69.49	t	t	t
2538	3	2026-03-02 18:38:01.211895	27.69	61.14	24.63	t	t	f
2542	4	2026-03-02 18:38:11.226224	29.10	21.08	63.36	t	t	f
2547	4	2026-03-02 18:38:21.236895	77.83	20.61	23.41	t	f	t
2548	2	2026-03-02 18:38:31.255411	14.14	76.70	67.39	t	t	f
2555	4	2026-03-02 18:38:41.262046	25.75	19.98	65.45	t	t	t
2556	2	2026-03-02 18:38:51.27273	38.33	44.67	61.53	t	t	f
2561	5	2026-03-02 18:39:01.276943	49.39	73.61	67.50	t	t	t
2567	4	2026-03-02 18:39:11.277941	66.40	25.53	46.92	t	t	t
2568	2	2026-03-02 18:39:21.286895	19.58	21.68	30.34	t	t	f
2573	5	2026-03-02 18:39:31.285599	42.80	67.16	64.18	t	t	t
2578	5	2026-03-02 18:39:41.295841	48.88	15.74	30.87	t	t	t
2582	4	2026-03-02 18:39:51.31083	25.81	68.05	36.22	f	t	t
2586	3	2026-03-02 18:40:01.315139	71.55	30.45	47.39	t	t	t
2588	2	2026-03-02 18:40:11.322807	66.09	13.97	34.92	t	t	t
2593	5	2026-03-02 18:40:21.34127	18.52	74.31	45.50	t	f	t
2598	3	2026-03-02 18:40:31.353398	45.52	54.15	20.51	t	t	t
2601	5	2026-03-02 18:40:41.360285	51.45	41.29	45.38	t	f	t
2604	3	2026-03-02 18:40:51.374342	76.00	37.37	25.29	t	t	t
2608	2	2026-03-02 18:41:01.389824	16.43	46.45	22.42	t	t	t
2613	5	2026-03-02 18:41:11.405573	46.68	77.41	45.82	t	t	t
2618	5	2026-03-02 18:41:21.406764	26.97	62.23	63.16	t	t	t
2622	3	2026-03-02 18:41:31.422694	71.06	74.73	30.25	t	t	t
2625	5	2026-03-02 18:41:41.434796	39.64	40.87	39.57	t	t	t
2628	3	2026-03-02 18:41:51.435768	37.07	42.40	66.44	t	t	t
2633	5	2026-03-02 18:42:01.454341	55.75	23.16	31.29	t	t	t
2639	4	2026-03-02 18:42:11.454806	61.62	27.01	33.78	t	t	f
2640	3	2026-03-02 18:42:21.456445	28.09	32.05	63.17	t	t	t
2647	5	2026-03-02 18:42:31.465828	72.14	73.72	40.73	t	t	t
2648	2	2026-03-02 18:42:41.474786	12.34	27.43	30.62	t	t	t
2652	2	2026-03-02 18:42:51.477769	20.43	75.47	28.27	t	t	t
2657	5	2026-03-02 18:43:01.481492	25.09	66.45	49.26	t	t	t
2660	2	2026-03-02 18:43:11.480634	12.88	52.04	53.92	t	t	t
2665	5	2026-03-02 18:43:21.487428	12.66	45.14	42.76	t	t	t
2668	3	2026-03-02 18:43:31.502307	17.78	38.86	52.74	t	f	t
2673	5	2026-03-02 18:43:41.501703	16.25	78.56	60.93	t	t	t
2679	3	2026-03-02 18:43:51.514958	48.77	68.37	44.40	t	t	t
2683	3	2026-03-02 18:44:01.52926	54.12	43.72	20.34	t	t	t
2687	3	2026-03-02 18:44:11.537851	32.97	42.31	53.38	t	t	t
2688	3	2026-03-02 18:44:21.542404	27.36	35.37	27.32	t	t	t
2695	4	2026-03-02 18:44:31.560715	57.79	70.38	29.87	t	t	t
2699	4	2026-03-02 18:44:41.565783	61.88	15.40	65.41	t	t	t
2703	3	2026-03-02 18:44:51.582533	26.56	43.47	55.34	t	t	t
2706	4	2026-03-02 18:45:01.582056	15.71	68.39	31.40	t	t	t
2710	3	2026-03-02 18:45:11.588336	48.91	39.52	60.32	t	t	t
2712	2	2026-03-02 18:45:21.599329	27.43	49.41	64.42	t	t	f
2718	3	2026-03-02 18:45:31.60444	51.39	24.17	37.19	t	f	f
2722	2	2026-03-02 18:45:41.605432	19.93	76.28	35.65	t	t	t
2726	3	2026-03-02 18:45:51.608657	54.45	19.75	45.87	t	t	t
2728	2	2026-03-02 18:46:01.622774	49.90	50.29	52.80	t	t	t
2733	5	2026-03-02 18:46:11.62979	15.53	19.08	66.41	t	t	t
2737	5	2026-03-02 18:46:21.63253	36.87	78.23	61.17	t	t	t
2740	3	2026-03-02 18:46:31.644591	10.06	20.99	46.16	t	t	t
2744	4	2026-03-02 18:46:41.659126	64.68	11.13	41.49	t	t	t
2751	3	2026-03-02 18:46:51.661066	60.28	28.03	28.99	t	t	f
2752	2	2026-03-02 18:47:01.660613	74.56	11.22	51.48	t	t	t
2759	5	2026-03-02 18:47:11.671615	46.72	65.20	53.52	t	t	t
2760	2	2026-03-02 18:47:21.672658	43.98	48.99	48.01	t	t	t
2766	5	2026-03-02 18:47:31.677375	40.26	10.12	54.62	t	t	t
2770	4	2026-03-02 18:47:41.683566	10.51	43.52	20.04	t	t	t
2775	2	2026-03-02 18:47:51.687429	27.93	58.62	27.08	t	t	t
2778	4	2026-03-02 18:48:01.691743	27.99	11.37	30.88	f	t	t
2780	2	2026-03-02 18:48:11.710455	39.53	34.69	27.25	t	t	t
2786	4	2026-03-02 18:48:21.718231	12.22	51.60	64.53	t	t	t
2789	5	2026-03-02 18:48:31.730717	73.30	44.10	58.94	t	t	t
2793	5	2026-03-02 18:48:41.731811	50.02	69.94	37.03	t	t	f
2	3	2026-02-28 21:18:02.904243	55.85	11.22	37.86	t	t	t
4	3	2026-02-28 21:18:12.834693	12.61	35.62	46.44	t	t	t
1230	3	2026-03-02 17:43:28.71564	57.31	15.05	52.38	t	t	t
1233	5	2026-03-02 17:43:38.727385	37.75	57.97	47.60	t	t	t
1236	3	2026-03-02 17:43:48.724622	77.42	20.51	62.95	t	t	t
1242	3	2026-03-02 17:43:58.735668	42.48	62.08	69.20	t	t	f
1246	3	2026-03-02 17:44:08.746207	74.14	11.19	40.99	t	t	t
1249	5	2026-03-02 17:44:18.74884	18.45	70.25	25.17	t	t	f
1254	4	2026-03-02 17:44:28.767079	23.47	42.13	33.73	t	t	t
1256	2	2026-03-02 17:44:38.767879	28.79	68.68	55.63	t	t	t
1261	5	2026-03-02 17:44:48.768015	10.06	12.11	21.34	t	t	f
1266	4	2026-03-02 17:44:58.770805	53.30	28.15	36.61	t	t	t
1270	4	2026-03-02 17:45:08.78406	79.49	65.59	63.99	t	f	f
1274	3	2026-03-02 17:45:18.783425	46.66	32.71	24.05	t	t	t
1279	4	2026-03-02 17:45:28.784083	58.31	61.31	43.88	t	t	f
1281	4	2026-03-02 17:45:38.792736	73.04	56.71	52.03	t	t	f
1287	3	2026-03-02 17:45:48.799304	24.73	34.27	47.03	t	t	t
1291	4	2026-03-02 17:45:58.806373	51.23	56.89	43.14	t	t	t
1292	2	2026-03-02 17:46:08.820772	34.56	55.59	29.21	t	t	t
1299	3	2026-03-02 17:46:18.831986	76.18	20.65	20.34	f	t	t
1890	4	2026-03-02 18:10:59.97876	19.07	33.22	63.07	t	t	t
1894	4	2026-03-02 18:11:09.956099	30.15	32.01	49.95	t	t	t
1896	2	2026-03-02 18:11:19.968623	23.20	52.86	51.48	t	t	t
1901	5	2026-03-02 18:11:29.979948	17.93	49.11	60.30	t	t	t
1904	2	2026-03-02 18:11:39.978915	19.96	66.35	51.01	t	t	t
1910	5	2026-03-02 18:11:49.985289	38.63	61.69	27.26	t	t	t
2239	2	2026-03-02 18:25:30.672928	61.40	52.04	64.79	t	t	t
2240	2	2026-03-02 18:25:40.677888	12.08	62.36	20.03	t	t	t
2503	3	2026-03-02 18:36:31.126078	58.01	68.79	42.76	t	t	t
2504	2	2026-03-02 18:36:41.134695	12.95	14.82	56.24	t	t	t
2509	5	2026-03-02 18:36:51.148712	43.44	26.61	21.24	t	t	t
2515	4	2026-03-02 18:37:01.153636	10.23	58.30	32.05	t	t	t
2516	2	2026-03-02 18:37:11.162621	45.44	58.60	44.16	t	t	f
2521	5	2026-03-02 18:37:21.167438	12.57	33.69	34.68	t	t	t
2526	4	2026-03-02 18:37:31.180999	55.04	69.46	30.85	f	t	t
2528	2	2026-03-02 18:37:41.193898	57.50	73.60	38.27	t	t	t
2533	5	2026-03-02 18:37:51.207835	43.94	25.34	64.87	t	t	t
2539	4	2026-03-02 18:38:01.212046	10.76	57.15	40.67	t	t	t
2540	2	2026-03-02 18:38:11.225736	22.97	60.19	57.71	t	t	t
2545	5	2026-03-02 18:38:21.236466	11.04	61.69	64.49	t	t	t
2550	5	2026-03-02 18:38:31.255786	40.23	78.35	39.66	t	t	t
2554	3	2026-03-02 18:38:41.261801	22.86	18.40	35.98	t	t	t
2558	3	2026-03-02 18:38:51.273172	71.59	47.80	68.90	t	t	t
2560	2	2026-03-02 18:39:01.276799	70.74	13.04	33.94	t	t	t
2566	5	2026-03-02 18:39:11.277648	50.08	24.28	69.21	t	t	f
2570	3	2026-03-02 18:39:21.287863	38.74	49.98	32.49	t	f	t
2572	3	2026-03-02 18:39:31.285345	54.29	17.42	43.66	t	t	f
2577	4	2026-03-02 18:39:41.294873	46.05	31.40	28.11	f	t	t
2581	5	2026-03-02 18:39:51.310578	60.50	11.09	33.99	t	t	t
2584	2	2026-03-02 18:40:01.314523	38.71	73.19	42.68	t	t	t
2591	3	2026-03-02 18:40:11.323555	74.77	34.29	65.58	t	f	t
2594	4	2026-03-02 18:40:21.341557	34.50	30.29	61.92	t	t	t
2599	4	2026-03-02 18:40:31.353681	13.48	35.85	52.16	t	t	t
2603	2	2026-03-02 18:40:41.360724	10.55	11.14	57.66	t	t	t
2605	4	2026-03-02 18:40:51.37473	23.43	64.97	36.98	t	t	t
2609	5	2026-03-02 18:41:01.389983	31.75	67.75	32.39	t	t	t
2614	3	2026-03-02 18:41:11.405752	57.29	36.09	56.30	t	t	t
2617	2	2026-03-02 18:41:21.406598	64.55	16.92	39.13	t	t	t
2623	4	2026-03-02 18:41:31.422998	74.77	27.80	39.78	t	t	t
2626	4	2026-03-02 18:41:41.435117	35.15	33.41	69.48	t	t	t
2630	4	2026-03-02 18:41:51.436236	56.41	15.10	26.78	t	t	f
2634	4	2026-03-02 18:42:01.454617	70.44	61.96	23.74	t	t	t
2636	2	2026-03-02 18:42:11.454407	49.77	57.26	46.17	t	t	t
2641	5	2026-03-02 18:42:21.456776	43.90	35.20	34.98	t	t	t
2645	3	2026-03-02 18:42:31.464415	16.83	59.90	37.22	t	t	t
2650	5	2026-03-02 18:42:41.475609	31.44	38.39	56.67	t	f	t
2654	4	2026-03-02 18:42:51.478176	31.66	48.93	55.06	t	t	t
2656	2	2026-03-02 18:43:01.480845	34.21	35.88	60.86	t	t	t
2662	3	2026-03-02 18:43:11.481143	29.42	19.75	26.63	t	t	t
2667	3	2026-03-02 18:43:21.487641	27.69	74.43	23.10	t	f	t
2671	2	2026-03-02 18:43:31.503247	61.00	59.20	63.13	t	t	t
2672	3	2026-03-02 18:43:41.50131	34.34	72.26	30.47	t	t	t
2678	4	2026-03-02 18:43:51.514699	56.77	14.40	48.89	t	t	t
2680	2	2026-03-02 18:44:01.528348	44.43	77.17	49.60	t	t	f
2684	2	2026-03-02 18:44:11.537083	45.58	27.18	63.35	t	t	t
2690	4	2026-03-02 18:44:21.543392	53.74	38.03	62.45	t	t	f
2694	5	2026-03-02 18:44:31.560543	23.41	21.07	30.47	t	t	f
2698	3	2026-03-02 18:44:41.56564	49.14	50.83	36.42	t	t	t
2700	2	2026-03-02 18:44:51.581737	77.04	28.13	69.16	t	t	t
2705	2	2026-03-02 18:45:01.581774	75.99	31.08	63.49	t	f	t
2711	4	2026-03-02 18:45:11.58852	31.90	36.19	68.34	t	f	f
2715	4	2026-03-02 18:45:21.599872	74.84	64.07	39.97	t	f	t
2717	5	2026-03-02 18:45:31.604267	29.70	54.36	65.21	t	t	t
2720	3	2026-03-02 18:45:41.605177	37.33	50.76	44.68	t	t	t
2724	4	2026-03-02 18:45:51.607765	67.25	77.75	32.56	t	f	t
2731	4	2026-03-02 18:46:01.623456	26.91	27.18	37.73	t	t	t
2734	4	2026-03-02 18:46:11.629993	10.11	58.52	47.28	f	t	t
2739	4	2026-03-02 18:46:21.632995	61.50	23.70	29.47	t	t	t
2741	2	2026-03-02 18:46:31.645088	10.88	42.20	33.11	t	t	t
2747	3	2026-03-02 18:46:41.659635	70.83	78.00	53.14	t	t	t
2748	2	2026-03-02 18:46:51.660804	28.71	40.94	61.46	t	t	t
2753	5	2026-03-02 18:47:01.660917	53.85	10.91	38.03	t	t	t
2756	2	2026-03-02 18:47:11.6712	75.97	39.44	36.99	t	t	t
2761	4	2026-03-02 18:47:21.672842	56.57	63.89	30.82	t	t	f
2765	3	2026-03-02 18:47:31.677272	72.86	75.95	29.41	t	t	t
2769	3	2026-03-02 18:47:41.68348	51.43	53.48	53.85	t	t	t
2772	3	2026-03-02 18:47:51.686743	32.32	71.24	68.99	t	t	f
2777	5	2026-03-02 18:48:01.691518	55.61	30.18	40.84	t	t	f
2782	3	2026-03-02 18:48:11.710941	79.24	58.54	58.94	t	t	f
2784	2	2026-03-02 18:48:21.717813	32.47	14.19	49.77	t	t	t
2791	3	2026-03-02 18:48:31.731261	60.52	63.78	49.45	t	t	t
2794	2	2026-03-02 18:48:41.731973	20.29	58.01	54.39	t	t	t
2798	4	2026-03-02 18:48:51.734061	77.63	11.41	35.31	t	t	t
2800	4	2026-03-02 18:49:01.74691	12.12	37.54	60.75	t	t	t
2804	2	2026-03-02 18:49:11.751445	39.81	12.52	29.25	t	t	f
2811	5	2026-03-02 18:49:21.761999	24.87	25.77	63.95	t	t	f
2812	2	2026-03-02 18:49:31.766812	35.39	73.31	59.54	t	t	t
3	4	2026-02-28 21:18:02.910092	71.30	31.76	24.40	t	t	t
6	2	2026-02-28 21:18:12.835104	78.70	18.21	37.91	t	f	t
7	2	2026-02-28 21:18:22.892744	78.76	75.05	56.63	t	f	t
8	3	2026-02-28 21:18:22.89295	23.13	29.66	25.73	t	t	t
9	4	2026-02-28 21:18:22.893116	50.62	33.88	59.60	t	t	t
10	2	2026-02-28 21:18:32.850578	25.57	71.19	30.93	t	t	t
11	3	2026-02-28 21:18:32.850895	31.97	16.70	69.62	t	t	t
12	4	2026-02-28 21:18:32.851029	32.06	18.20	52.65	t	t	t
13	2	2026-02-28 21:18:42.901718	77.54	14.21	28.29	t	t	t
14	4	2026-02-28 21:18:42.911446	62.69	56.50	46.28	t	t	t
15	3	2026-02-28 21:18:42.911906	57.10	76.24	67.20	t	t	t
16	2	2026-02-28 21:18:52.869906	38.59	41.40	52.00	t	t	t
17	3	2026-02-28 21:18:52.870204	59.85	42.00	56.34	t	t	t
18	4	2026-02-28 21:18:52.870588	48.94	78.64	36.71	t	t	t
19	2	2026-02-28 21:19:02.916529	32.66	43.06	49.90	t	t	t
20	3	2026-02-28 21:19:02.918672	62.68	69.99	45.40	t	t	t
21	4	2026-02-28 21:19:02.919235	28.48	34.83	60.80	t	t	t
22	3	2026-02-28 21:19:12.883935	12.09	58.49	37.26	t	t	t
23	4	2026-02-28 21:19:12.884264	22.42	21.77	50.57	t	t	t
24	2	2026-02-28 21:19:12.884404	40.44	32.12	56.84	t	t	t
25	2	2026-02-28 21:19:22.931337	58.25	44.79	32.81	t	t	t
26	3	2026-02-28 21:19:22.93492	42.94	38.82	38.52	t	t	t
27	4	2026-02-28 21:19:22.935194	58.45	37.51	65.03	t	t	t
28	2	2026-02-28 21:19:32.90769	57.40	17.52	44.14	t	t	t
29	3	2026-02-28 21:19:32.907933	58.18	71.70	68.40	t	t	t
30	4	2026-02-28 21:19:32.908216	29.74	11.28	27.53	t	t	t
31	2	2026-02-28 21:19:42.953111	65.91	20.72	30.99	t	t	t
32	3	2026-02-28 21:19:42.955616	69.90	23.59	69.54	t	t	t
33	4	2026-02-28 21:19:42.955876	22.80	62.33	60.76	t	t	t
34	2	2026-02-28 21:19:52.924799	72.95	31.52	25.91	t	t	t
35	4	2026-02-28 21:19:52.925562	58.46	34.91	50.59	t	t	t
36	3	2026-02-28 21:19:52.925985	72.14	56.36	45.87	t	t	t
37	2	2026-02-28 21:20:02.928327	73.29	77.89	56.55	t	t	t
38	3	2026-02-28 21:20:02.928573	46.18	13.99	46.27	t	t	t
39	4	2026-02-28 21:20:02.929361	21.23	51.36	42.80	t	t	t
40	2	2026-02-28 21:20:12.932627	79.52	72.94	38.47	t	t	f
41	3	2026-02-28 21:20:12.932757	47.05	53.38	63.37	t	t	t
42	4	2026-02-28 21:20:12.964928	67.39	19.46	34.31	t	t	t
43	2	2026-02-28 21:20:22.933952	77.89	58.82	24.64	t	t	t
44	3	2026-02-28 21:20:22.934227	15.89	14.54	64.79	t	t	t
45	4	2026-02-28 21:20:22.934552	54.55	36.68	32.28	t	t	t
46	2	2026-02-28 21:20:32.979452	65.98	14.95	52.69	t	t	t
47	4	2026-02-28 21:20:32.98685	71.52	54.04	68.63	f	t	t
48	3	2026-02-28 21:20:32.987144	57.96	16.57	30.27	t	t	t
49	2	2026-02-28 21:20:42.952386	18.66	35.26	20.13	t	t	t
50	4	2026-02-28 21:20:42.952621	43.81	48.59	33.51	t	t	t
51	3	2026-02-28 21:20:42.952974	47.54	27.44	30.11	t	t	f
52	2	2026-02-28 21:20:52.95489	67.28	76.62	39.15	t	t	t
53	3	2026-02-28 21:20:52.955124	25.51	28.85	65.08	t	t	t
54	4	2026-02-28 21:20:52.955338	44.52	43.44	67.88	t	t	f
55	2	2026-02-28 21:21:02.966535	71.62	24.74	58.05	t	t	f
56	3	2026-02-28 21:21:02.998929	31.66	38.26	43.41	f	t	f
57	4	2026-02-28 21:21:03.001415	19.41	14.77	37.23	t	t	t
58	2	2026-02-28 21:21:12.974763	24.45	55.90	50.30	f	t	t
59	3	2026-02-28 21:21:12.975363	23.35	27.36	58.18	t	f	t
60	4	2026-02-28 21:21:13.00543	20.07	47.42	36.77	t	t	t
61	2	2026-02-28 21:21:22.989689	35.48	56.32	45.72	f	t	f
62	4	2026-02-28 21:21:23.022733	20.78	22.94	63.41	t	t	t
63	3	2026-02-28 21:21:23.022846	43.65	58.47	66.61	t	t	t
64	2	2026-02-28 21:21:33.002286	18.85	68.57	43.63	t	t	t
65	3	2026-02-28 21:21:33.002586	48.13	17.25	33.55	t	t	t
66	4	2026-02-28 21:21:33.033536	71.29	34.38	45.42	t	t	t
67	3	2026-02-28 21:21:43.013652	48.30	66.41	54.51	t	t	t
68	2	2026-02-28 21:21:43.050477	25.79	74.66	27.74	t	t	t
69	4	2026-02-28 21:21:43.051859	37.38	12.79	39.97	t	f	t
70	2	2026-02-28 21:21:53.020337	25.42	63.59	20.93	t	t	t
71	3	2026-02-28 21:21:53.020533	78.66	75.42	25.81	t	t	t
72	4	2026-02-28 21:21:53.058725	48.11	54.10	45.96	t	t	t
73	2	2026-02-28 21:22:03.023957	33.04	16.89	60.85	t	t	t
74	4	2026-02-28 21:22:03.02426	37.90	73.71	66.44	t	t	t
75	3	2026-02-28 21:22:03.024605	57.67	20.08	30.11	t	t	t
76	2	2026-02-28 21:22:13.040439	24.89	74.34	40.90	t	t	t
77	4	2026-02-28 21:22:13.073399	37.55	10.25	50.60	t	t	t
78	3	2026-02-28 21:22:13.182008	50.73	43.65	52.15	t	t	t
79	2	2026-02-28 21:22:23.041688	35.46	34.42	27.66	t	t	t
80	4	2026-02-28 21:22:23.042189	34.62	44.43	46.28	t	t	t
81	3	2026-02-28 21:22:23.042652	18.19	47.97	60.91	t	t	f
82	2	2026-02-28 21:22:33.054999	64.32	34.39	48.90	t	t	t
83	3	2026-02-28 21:22:33.090871	56.53	42.54	68.68	t	f	t
84	4	2026-02-28 21:22:33.09229	58.54	52.16	57.38	t	t	f
85	2	2026-02-28 21:22:43.0709	52.15	45.41	63.63	t	t	f
86	3	2026-02-28 21:22:43.071077	29.78	26.55	31.85	t	t	f
87	4	2026-02-28 21:22:43.100815	44.07	43.14	60.84	t	t	t
88	2	2026-02-28 21:22:53.080566	26.51	40.19	38.88	t	t	t
89	4	2026-02-28 21:22:53.12123	79.88	29.09	64.47	t	t	t
90	3	2026-02-28 21:22:53.230105	46.78	78.87	66.49	t	t	t
91	2	2026-02-28 21:23:03.094837	13.13	42.77	62.22	t	t	t
92	3	2026-02-28 21:23:03.095021	44.57	14.42	39.19	t	t	t
93	4	2026-02-28 21:23:03.244404	32.37	66.33	67.25	t	t	f
94	2	2026-02-28 21:23:13.102531	45.73	30.57	44.51	t	f	t
95	4	2026-02-28 21:23:13.13985	44.58	18.64	20.75	t	t	t
96	3	2026-02-28 21:23:13.242382	79.70	77.50	32.54	t	f	t
97	2	2026-02-28 21:23:23.112068	63.75	72.83	27.37	t	t	t
98	3	2026-02-28 21:23:23.112531	77.31	72.36	65.29	t	t	t
99	4	2026-02-28 21:23:23.142236	22.49	36.33	67.35	t	t	t
100	2	2026-02-28 21:23:33.133825	54.53	37.47	33.53	t	t	t
101	3	2026-02-28 21:23:33.170592	56.70	49.65	27.86	t	t	t
102	4	2026-02-28 21:23:33.173078	45.80	49.68	60.81	t	t	t
103	2	2026-02-28 21:23:43.136597	20.07	13.87	56.92	t	t	t
104	3	2026-02-28 21:23:43.137594	46.79	74.17	54.54	t	t	t
105	4	2026-02-28 21:23:43.138458	43.63	41.54	25.53	f	t	f
106	2	2026-02-28 21:23:53.14304	78.08	38.21	42.41	t	t	t
107	3	2026-02-28 21:23:53.143396	35.38	58.68	37.51	t	t	t
108	4	2026-02-28 21:23:53.14369	20.07	55.63	67.35	t	t	t
109	2	2026-02-28 21:24:03.155327	52.79	64.99	38.77	t	t	t
110	3	2026-02-28 21:24:03.155633	33.29	47.19	59.38	t	t	t
111	4	2026-02-28 21:24:03.194596	28.50	77.95	62.79	t	t	t
112	2	2026-02-28 21:24:13.162644	54.65	75.85	45.56	t	f	f
113	3	2026-02-28 21:24:13.202484	22.49	75.91	52.23	t	t	t
114	4	2026-02-28 21:24:13.20481	66.29	67.41	39.85	t	t	t
115	2	2026-02-28 21:24:23.167377	57.67	18.13	59.52	t	t	f
116	3	2026-02-28 21:24:23.167899	29.58	58.38	40.12	f	t	t
117	4	2026-02-28 21:24:23.168493	60.24	17.36	67.86	t	t	t
118	3	2026-02-28 21:24:33.22659	59.17	55.65	30.93	t	t	t
119	2	2026-02-28 21:24:33.226701	47.41	27.59	29.98	t	t	f
120	4	2026-02-28 21:24:33.227532	40.41	23.52	53.64	t	t	t
121	2	2026-02-28 21:24:43.194569	40.40	19.51	47.23	t	t	f
122	3	2026-02-28 21:24:43.195085	57.62	71.91	64.80	t	t	t
123	4	2026-02-28 21:24:43.195618	71.59	31.36	47.12	t	t	t
124	2	2026-02-28 21:24:53.194653	50.16	60.72	59.27	t	t	t
125	3	2026-02-28 21:24:53.195104	23.89	49.88	45.45	t	t	t
126	4	2026-02-28 21:24:53.195626	18.37	52.43	33.00	t	t	t
127	2	2026-02-28 21:25:03.244829	23.32	64.56	45.51	t	t	t
128	3	2026-02-28 21:25:03.278143	68.10	49.01	45.45	t	t	t
129	4	2026-02-28 21:25:03.278887	34.15	26.27	40.17	t	t	t
130	2	2026-02-28 21:25:13.22271	58.15	13.66	47.90	t	t	t
131	3	2026-02-28 21:25:13.223367	40.12	32.35	66.14	t	t	t
132	4	2026-02-28 21:25:13.223604	46.51	78.78	67.68	t	t	t
133	2	2026-02-28 21:25:23.227136	46.70	41.96	40.24	t	t	t
134	3	2026-02-28 21:25:23.227766	35.13	39.37	32.46	t	t	t
135	4	2026-02-28 21:25:23.228103	69.32	52.71	25.31	t	t	f
136	2	2026-02-28 21:25:33.227484	73.83	52.66	64.22	t	t	t
137	3	2026-02-28 21:25:33.228038	68.09	48.47	52.67	t	t	f
138	4	2026-02-28 21:25:33.228533	21.93	50.65	27.53	t	t	t
139	3	2026-02-28 21:25:43.232773	47.39	68.83	21.65	t	t	t
140	4	2026-02-28 21:25:43.233106	56.16	56.77	41.97	t	t	t
141	2	2026-02-28 21:25:43.233378	51.42	17.28	42.42	t	t	t
142	2	2026-02-28 21:25:53.229092	35.30	58.70	36.79	t	t	t
143	3	2026-02-28 21:25:53.229793	58.17	37.45	69.26	t	t	t
144	4	2026-02-28 21:25:53.230086	31.68	36.61	66.97	t	t	t
145	3	2026-02-28 21:26:03.240854	23.61	19.90	63.68	t	t	t
146	4	2026-02-28 21:26:03.241188	69.67	29.18	27.40	f	f	f
147	2	2026-02-28 21:26:03.241842	56.29	78.80	59.80	t	t	f
148	3	2026-02-28 21:26:13.242479	61.71	22.15	52.27	t	f	t
149	4	2026-02-28 21:26:13.24274	45.05	68.95	33.37	t	t	t
150	2	2026-02-28 21:26:13.243028	45.16	45.21	60.13	t	f	t
151	2	2026-02-28 21:26:23.256706	12.36	31.37	69.67	t	t	f
152	3	2026-02-28 21:26:23.257205	56.54	25.39	66.21	t	t	t
153	4	2026-02-28 21:26:23.257699	21.92	14.87	60.34	t	t	f
154	2	2026-02-28 21:26:33.251252	47.40	20.16	26.87	t	t	t
155	4	2026-02-28 21:26:33.251412	14.81	33.17	46.22	t	t	t
156	3	2026-02-28 21:26:33.251575	44.23	63.93	64.08	t	t	t
157	2	2026-02-28 21:26:43.264161	63.44	67.43	42.99	t	t	t
158	4	2026-02-28 21:26:43.264287	74.34	54.57	47.03	t	t	t
159	3	2026-02-28 21:26:43.264398	59.37	45.31	37.81	t	t	t
160	2	2026-02-28 21:26:53.27938	77.23	74.06	66.02	t	t	t
161	3	2026-02-28 21:26:53.279537	75.49	37.72	41.24	t	t	t
162	4	2026-02-28 21:26:53.279755	63.85	26.07	38.46	t	t	t
163	2	2026-02-28 21:27:03.295701	51.98	37.12	22.10	t	t	t
164	4	2026-02-28 21:27:03.296077	39.66	62.02	62.59	t	t	f
165	3	2026-02-28 21:27:03.296275	18.16	33.50	62.18	t	t	t
166	2	2026-02-28 21:27:13.302655	62.02	60.45	64.27	t	f	t
167	4	2026-02-28 21:27:13.303012	78.56	18.99	66.86	t	t	t
168	3	2026-02-28 21:27:13.304293	43.55	32.41	61.16	t	t	t
169	2	2026-02-28 21:27:23.309391	78.50	59.09	47.37	f	t	t
170	4	2026-02-28 21:27:23.309967	19.67	41.16	38.85	t	t	f
171	3	2026-02-28 21:27:23.310254	33.90	37.18	41.39	t	t	t
172	2	2026-02-28 21:27:33.318031	55.04	17.26	68.28	t	t	t
173	4	2026-02-28 21:27:33.318376	39.47	52.32	35.55	f	t	f
174	3	2026-02-28 21:27:33.318592	37.31	60.90	30.23	t	t	t
175	2	2026-02-28 21:27:43.325113	53.62	16.97	29.32	t	t	f
176	4	2026-02-28 21:27:43.325388	18.69	26.64	45.25	t	t	f
177	3	2026-02-28 21:27:43.325696	25.37	62.59	37.99	t	t	t
178	2	2026-02-28 21:27:53.324736	27.70	66.70	37.49	t	t	t
179	4	2026-02-28 21:27:53.3249	59.54	22.19	38.48	t	t	t
180	3	2026-02-28 21:27:53.325102	41.77	51.40	23.73	t	f	f
181	3	2026-02-28 21:28:03.331817	47.36	30.58	27.43	t	f	t
182	2	2026-02-28 21:28:03.332331	32.80	63.28	24.49	t	t	t
183	4	2026-02-28 21:28:03.332322	20.68	55.51	26.03	t	t	t
184	2	2026-02-28 21:28:13.344757	58.67	55.66	48.09	t	t	t
185	3	2026-02-28 21:28:13.345772	58.48	28.63	36.32	t	t	t
186	4	2026-02-28 21:28:13.346068	70.67	74.84	68.84	t	t	t
187	3	2026-02-28 21:28:23.361325	27.55	40.18	37.60	t	f	t
188	2	2026-02-28 21:28:23.361635	13.06	74.46	24.78	t	t	t
189	4	2026-02-28 21:28:23.362291	28.83	27.01	64.55	t	t	f
190	2	2026-02-28 21:28:33.361033	67.11	70.28	57.50	t	t	t
191	3	2026-02-28 21:28:33.361257	35.14	71.50	62.66	t	t	t
192	4	2026-02-28 21:28:33.361449	26.14	67.39	28.74	t	t	t
193	3	2026-02-28 21:28:43.364093	15.41	72.34	44.84	f	t	f
194	4	2026-02-28 21:28:43.364271	51.35	38.65	48.90	t	t	t
195	2	2026-02-28 21:28:43.364405	65.56	10.60	25.91	t	t	t
196	2	2026-02-28 21:28:53.363049	49.21	52.09	27.26	t	t	t
197	3	2026-02-28 21:28:53.363195	59.32	71.52	43.90	t	t	t
198	4	2026-02-28 21:28:53.363292	13.43	20.53	24.30	t	t	t
199	2	2026-02-28 21:29:03.366302	64.23	68.95	31.08	t	t	t
200	4	2026-02-28 21:29:03.366376	72.63	63.76	25.31	t	t	t
201	3	2026-02-28 21:29:03.366578	48.59	19.62	28.10	t	t	t
202	2	2026-02-28 21:29:13.370759	12.42	14.34	23.10	t	t	t
203	3	2026-02-28 21:29:13.370992	59.55	56.00	64.75	t	t	t
204	4	2026-02-28 21:29:13.371313	21.94	21.38	21.20	t	t	t
205	2	2026-02-28 21:29:23.378106	19.33	21.61	63.24	t	t	f
206	3	2026-02-28 21:29:23.378298	76.96	27.34	69.32	t	t	t
207	4	2026-02-28 21:29:23.378831	48.61	25.32	32.95	t	t	f
208	2	2026-02-28 21:29:33.378586	38.74	76.02	59.70	t	f	f
209	4	2026-02-28 21:29:33.378794	31.96	10.77	27.43	t	t	f
210	3	2026-02-28 21:29:33.37895	61.76	39.81	53.98	t	t	t
211	2	2026-02-28 21:29:43.390585	74.98	61.55	35.68	t	t	f
212	4	2026-02-28 21:29:43.390888	78.25	39.15	27.34	t	t	f
213	3	2026-02-28 21:29:43.391243	18.62	73.60	38.10	t	t	t
214	2	2026-02-28 21:29:53.400545	12.75	38.68	43.02	t	t	t
215	3	2026-02-28 21:29:53.400665	62.08	19.32	50.76	t	t	t
216	4	2026-02-28 21:29:53.40083	19.14	54.83	28.18	t	t	f
217	2	2026-02-28 21:30:03.413268	42.13	78.67	62.64	t	f	f
218	3	2026-02-28 21:30:03.413503	29.51	61.58	37.92	t	t	t
219	4	2026-02-28 21:30:03.566627	24.69	60.71	52.75	t	t	t
221	4	2026-02-28 21:30:13.413374	34.19	18.02	51.42	t	f	f
223	2	2026-02-28 21:30:23.428328	12.12	19.53	39.94	t	t	t
226	2	2026-02-28 21:30:33.440411	25.28	72.10	43.57	t	t	t
229	2	2026-02-28 21:30:43.458669	42.61	60.39	57.38	t	t	t
1229	5	2026-03-02 17:43:28.715458	42.27	65.57	68.02	t	t	t
1234	4	2026-03-02 17:43:38.72761	14.95	23.50	60.53	t	t	t
1239	5	2026-03-02 17:43:48.725112	70.40	59.40	24.32	t	t	t
1240	2	2026-03-02 17:43:58.734826	28.68	68.09	55.57	t	t	t
1244	2	2026-03-02 17:44:08.745817	59.29	79.29	55.87	t	t	t
1251	4	2026-03-02 17:44:18.749303	69.11	13.35	53.25	t	f	t
1252	2	2026-03-02 17:44:28.766495	50.78	69.44	58.17	t	t	t
1259	3	2026-03-02 17:44:38.76871	28.54	74.37	41.79	t	t	f
1260	2	2026-03-02 17:44:48.767796	56.79	48.33	67.98	t	f	t
1265	5	2026-03-02 17:44:58.770664	16.95	61.86	44.05	t	t	f
1271	3	2026-03-02 17:45:08.784167	39.86	64.47	32.49	t	t	t
1273	2	2026-03-02 17:45:18.783285	12.99	47.27	51.85	t	t	f
1277	5	2026-03-02 17:45:28.783632	41.11	20.48	45.54	t	t	t
1282	5	2026-03-02 17:45:38.792833	57.14	31.17	21.74	t	t	t
1286	4	2026-03-02 17:45:48.799057	43.72	28.52	54.32	t	t	t
1288	2	2026-03-02 17:45:58.805748	65.59	30.03	67.06	t	t	f
1295	3	2026-03-02 17:46:08.821507	52.82	73.74	46.32	f	t	t
1296	2	2026-03-02 17:46:18.831393	43.93	48.09	21.99	t	t	f
1891	5	2026-03-02 18:10:59.980324	71.38	10.14	27.63	t	t	t
1892	2	2026-03-02 18:11:09.955455	10.22	78.54	52.90	t	t	t
1897	5	2026-03-02 18:11:19.968882	31.67	67.90	48.87	t	t	f
1903	4	2026-03-02 18:11:29.980248	44.34	40.81	69.12	t	f	t
1907	4	2026-03-02 18:11:39.979566	19.62	21.63	49.20	t	t	f
1911	4	2026-03-02 18:11:49.985529	64.10	18.37	55.68	t	t	t
1912	2	2026-03-02 18:11:59.990262	79.45	41.84	42.08	t	t	t
1919	4	2026-03-02 18:12:09.998066	24.78	19.24	47.35	t	t	t
1922	5	2026-03-02 18:12:20.009404	64.60	46.10	20.81	t	t	t
1927	5	2026-03-02 18:12:30.023005	53.81	52.37	26.43	t	t	t
1930	4	2026-03-02 18:12:40.024125	28.17	34.38	45.67	t	t	t
1934	4	2026-03-02 18:12:50.041652	59.28	67.66	41.55	f	t	t
1938	4	2026-03-02 18:13:00.04829	15.33	51.91	28.82	t	t	t
1942	4	2026-03-02 18:13:10.069304	37.90	52.96	20.61	t	t	f
1947	4	2026-03-02 18:13:20.077175	47.49	28.09	25.90	t	t	t
2241	3	2026-03-02 18:25:40.678514	62.53	37.77	32.55	t	t	t
2245	5	2026-03-02 18:25:50.68051	69.77	35.61	35.04	f	t	t
2696	2	2026-03-02 18:44:41.565172	43.20	14.43	40.34	t	t	t
2701	5	2026-03-02 18:44:51.582046	22.43	25.46	35.97	t	t	t
2707	5	2026-03-02 18:45:01.582296	12.93	15.35	65.46	t	t	t
2708	2	2026-03-02 18:45:11.587834	65.62	61.81	33.65	t	t	t
2714	5	2026-03-02 18:45:21.599763	60.68	12.37	31.06	t	t	t
2716	2	2026-03-02 18:45:31.603999	72.40	50.40	48.55	t	t	t
2721	5	2026-03-02 18:45:41.605271	55.93	39.18	62.87	t	t	t
2725	5	2026-03-02 18:45:51.60847	71.86	70.72	69.58	t	t	t
2729	3	2026-03-02 18:46:01.622955	11.01	77.52	41.20	t	t	t
2735	3	2026-03-02 18:46:11.630298	74.69	66.26	21.75	t	t	t
2738	2	2026-03-02 18:46:21.632838	27.84	13.20	21.01	t	t	t
2742	4	2026-03-02 18:46:31.64541	17.81	70.94	44.20	t	t	t
2746	5	2026-03-02 18:46:41.659348	50.43	27.04	33.59	t	t	t
2750	4	2026-03-02 18:46:51.660946	69.37	15.11	22.72	t	t	t
2754	3	2026-03-02 18:47:01.661246	50.77	72.50	49.74	t	t	t
2757	4	2026-03-02 18:47:11.671421	70.92	28.68	55.11	t	t	t
2763	3	2026-03-02 18:47:21.673174	44.51	21.49	58.20	t	t	t
2767	4	2026-03-02 18:47:31.677552	24.32	39.28	60.04	t	t	t
2768	2	2026-03-02 18:47:41.683234	48.40	67.42	33.52	t	t	t
2773	5	2026-03-02 18:47:51.687023	42.36	10.86	31.60	t	t	t
2779	2	2026-03-02 18:48:01.691909	76.66	13.82	48.02	t	t	t
2781	5	2026-03-02 18:48:11.710628	18.67	65.78	26.93	f	t	t
2787	3	2026-03-02 18:48:21.718493	72.58	30.79	69.72	t	t	t
2788	2	2026-03-02 18:48:31.730371	25.22	49.26	33.30	t	t	f
2792	3	2026-03-02 18:48:41.731567	75.89	67.08	63.78	t	t	t
2799	3	2026-03-02 18:48:51.73433	14.15	42.63	46.02	t	t	t
2803	2	2026-03-02 18:49:01.747707	76.05	49.18	68.18	t	t	t
2805	4	2026-03-02 18:49:11.751864	54.67	69.79	48.47	t	t	t
2808	2	2026-03-02 18:49:21.761025	42.29	20.22	53.88	t	t	t
2815	3	2026-03-02 18:49:31.767265	77.35	31.87	41.65	t	t	t
2817	5	2026-03-02 18:49:41.782399	78.40	22.86	58.27	t	t	t
2820	2	2026-03-02 18:49:51.80291	15.42	46.06	60.61	t	t	t
2825	5	2026-03-02 18:50:01.815666	78.55	23.59	55.98	t	t	f
2829	2	2026-03-02 18:50:11.831867	37.07	61.81	31.57	t	t	t
2835	4	2026-03-02 18:50:21.84746	54.56	56.55	42.40	t	t	t
2839	3	2026-03-02 18:50:31.840604	11.04	40.83	52.06	t	t	t
2843	4	2026-03-02 18:50:41.850186	27.68	60.01	27.51	t	t	t
2844	4	2026-03-02 18:50:51.850608	23.06	28.64	67.08	t	t	t
2848	2	2026-03-02 18:51:01.849679	27.52	66.12	58.30	t	t	f
2854	4	2026-03-02 18:51:11.863308	75.25	45.80	54.19	t	t	t
2857	5	2026-03-02 18:51:21.872939	20.61	23.64	42.66	t	t	t
2863	4	2026-03-02 18:51:31.884962	13.77	60.01	21.04	t	t	t
2864	2	2026-03-02 18:51:41.893294	42.56	42.44	36.43	f	t	t
2870	5	2026-03-02 18:51:51.902785	51.03	71.03	44.54	t	t	t
2872	4	2026-03-02 18:52:01.910174	15.07	11.11	54.94	t	t	t
2879	3	2026-03-02 18:52:11.915667	57.55	57.91	52.97	t	t	t
2880	2	2026-03-02 18:52:21.928623	55.59	73.96	46.27	t	f	t
2886	3	2026-03-02 18:52:31.935675	11.09	12.21	58.74	t	t	t
2889	5	2026-03-02 18:52:41.94756	19.52	19.31	22.97	t	t	t
2892	2	2026-03-02 18:52:51.948802	70.47	76.10	22.37	t	t	t
2897	5	2026-03-02 18:53:01.951362	69.54	10.05	45.78	f	t	t
2903	4	2026-03-02 18:53:11.963829	74.28	49.09	62.96	t	t	t
2906	2	2026-03-02 18:53:21.970033	19.11	55.24	54.96	t	t	t
2911	4	2026-03-02 18:53:31.975815	33.25	67.14	47.09	t	t	t
2912	2	2026-03-02 18:53:41.97556	52.65	13.92	29.04	t	t	t
2916	3	2026-03-02 18:53:51.976619	55.95	43.24	39.96	t	t	f
2923	3	2026-03-02 18:54:01.978549	44.30	57.79	33.36	f	t	t
2924	2	2026-03-02 18:54:11.993256	27.39	34.79	55.31	t	t	f
2930	3	2026-03-02 18:54:22.007386	71.25	18.93	60.61	t	t	t
2935	4	2026-03-02 18:54:32.012316	65.36	16.97	64.85	t	t	t
2939	3	2026-03-02 18:54:42.026023	63.94	43.74	56.01	t	f	t
2940	4	2026-03-02 18:54:52.025603	64.09	48.71	21.22	t	t	t
2945	5	2026-03-02 18:55:02.039242	24.28	66.41	67.50	t	t	t
2948	2	2026-03-02 18:55:12.042481	77.34	45.68	38.76	t	t	t
2952	2	2026-03-02 18:55:22.055196	61.08	56.13	38.14	t	t	t
2957	5	2026-03-02 18:55:32.059298	48.60	24.97	25.44	t	t	t
2961	5	2026-03-02 18:55:42.069865	45.76	23.03	22.73	t	t	t
220	2	2026-02-28 21:30:13.41313	65.80	68.63	31.95	t	t	t
225	3	2026-02-28 21:30:23.42891	36.43	26.91	50.14	t	t	t
228	3	2026-02-28 21:30:33.441121	51.74	79.00	24.06	t	t	t
230	3	2026-02-28 21:30:43.459091	51.52	66.29	33.07	t	t	t
1231	4	2026-03-02 17:43:28.715888	75.62	47.70	44.45	t	t	t
1232	2	2026-03-02 17:43:38.726919	26.24	78.40	21.31	t	t	t
1238	2	2026-03-02 17:43:48.724789	49.19	71.99	24.98	t	t	t
1241	5	2026-03-02 17:43:58.73539	52.01	29.66	29.34	t	t	t
1245	4	2026-03-02 17:44:08.746073	66.05	55.96	34.19	t	t	t
1250	3	2026-03-02 17:44:18.749071	26.64	64.23	58.66	t	t	t
1255	3	2026-03-02 17:44:28.767346	71.88	51.83	68.85	t	t	t
1257	5	2026-03-02 17:44:38.768098	75.62	39.94	58.11	t	t	t
1262	3	2026-03-02 17:44:48.768422	43.31	46.08	58.66	t	t	t
1267	3	2026-03-02 17:44:58.770853	15.79	17.67	35.25	t	t	f
1268	2	2026-03-02 17:45:08.783349	63.89	65.02	67.24	t	t	t
1275	5	2026-03-02 17:45:18.783564	77.84	10.54	31.33	t	t	f
1276	2	2026-03-02 17:45:28.783225	67.59	53.49	22.77	t	t	t
1280	2	2026-03-02 17:45:38.792562	73.05	39.44	40.92	t	t	t
1285	5	2026-03-02 17:45:48.798785	47.52	69.79	54.02	t	t	t
1289	5	2026-03-02 17:45:58.805987	57.73	72.71	42.50	t	t	t
1294	4	2026-03-02 17:46:08.821076	78.97	54.63	60.37	t	t	t
1298	5	2026-03-02 17:46:18.831736	76.60	79.50	28.57	t	t	t
1913	3	2026-03-02 18:12:00.022657	69.74	14.14	58.27	t	f	f
1917	5	2026-03-02 18:12:09.997506	33.49	14.46	21.27	t	t	t
1921	4	2026-03-02 18:12:20.00904	11.12	70.39	69.49	t	t	f
1924	2	2026-03-02 18:12:30.0225	12.71	61.85	27.61	t	t	t
1929	5	2026-03-02 18:12:40.023942	50.32	64.35	45.14	t	t	t
1935	2	2026-03-02 18:12:50.041906	39.55	61.98	65.68	t	t	t
1936	2	2026-03-02 18:13:00.047856	30.09	19.37	37.78	t	t	f
1941	5	2026-03-02 18:13:10.069082	64.76	64.29	27.50	t	t	t
1946	3	2026-03-02 18:13:20.076905	31.40	34.78	50.09	t	t	f
2243	4	2026-03-02 18:25:40.678859	66.84	33.52	63.94	t	f	t
2244	2	2026-03-02 18:25:50.679929	60.64	44.78	27.91	t	t	t
2249	5	2026-03-02 18:26:00.675234	25.23	64.28	36.92	t	t	t
2253	3	2026-03-02 18:26:10.685311	36.77	24.07	25.59	t	f	t
2257	5	2026-03-02 18:26:20.692534	40.92	61.73	65.69	t	t	t
2260	2	2026-03-02 18:26:30.706183	49.36	69.15	58.50	t	t	t
2264	3	2026-03-02 18:26:40.706017	56.78	47.30	61.30	t	t	t
2269	5	2026-03-02 18:26:50.712078	10.50	36.35	28.20	t	t	t
2274	4	2026-03-02 18:27:00.714519	30.88	57.63	46.60	f	t	t
2276	3	2026-03-02 18:27:10.724887	14.81	73.50	28.23	t	t	t
2281	5	2026-03-02 18:27:20.72905	41.96	33.50	29.05	t	t	f
2285	5	2026-03-02 18:27:30.747436	21.42	20.98	50.18	t	t	t
2290	3	2026-03-02 18:27:40.749074	68.45	56.61	58.77	t	t	t
2292	2	2026-03-02 18:27:50.749519	36.87	66.09	40.70	t	t	t
2299	4	2026-03-02 18:28:00.753706	72.03	45.62	68.43	t	t	t
2302	3	2026-03-02 18:28:10.765969	15.71	27.32	60.31	t	t	t
2307	4	2026-03-02 18:28:20.765854	60.70	71.80	46.73	t	t	t
2308	2	2026-03-02 18:28:30.780623	59.30	32.85	63.73	t	t	t
2315	4	2026-03-02 18:28:40.7843	41.42	68.71	61.96	t	t	t
2319	3	2026-03-02 18:28:50.798897	31.27	68.98	40.17	f	t	t
2320	2	2026-03-02 18:29:00.805182	63.24	43.85	65.78	t	t	f
2327	4	2026-03-02 18:29:10.80742	47.63	65.17	45.38	t	t	t
2328	2	2026-03-02 18:29:20.805687	50.17	31.09	52.89	t	t	t
2335	5	2026-03-02 18:29:30.812915	69.12	48.63	26.64	t	t	t
2336	2	2026-03-02 18:29:40.820089	30.24	13.27	58.72	t	t	t
2341	5	2026-03-02 18:29:50.820311	71.38	32.88	55.12	t	t	t
2702	4	2026-03-02 18:44:51.582221	53.62	14.05	23.81	t	t	t
2704	3	2026-03-02 18:45:01.581039	79.55	31.14	21.71	t	t	f
2709	5	2026-03-02 18:45:11.587992	43.62	49.86	64.46	t	t	t
2713	3	2026-03-02 18:45:21.599508	17.69	20.12	44.67	t	t	t
2719	4	2026-03-02 18:45:31.60474	67.09	44.67	62.32	t	t	t
2723	4	2026-03-02 18:45:41.605696	25.47	74.21	42.02	t	t	t
2727	2	2026-03-02 18:45:51.608816	59.67	48.86	69.97	t	t	t
2730	5	2026-03-02 18:46:01.623211	70.36	24.06	65.57	t	t	t
2732	2	2026-03-02 18:46:11.629405	70.81	52.68	25.86	t	t	t
2736	3	2026-03-02 18:46:21.632221	40.10	48.66	58.38	t	t	t
2743	5	2026-03-02 18:46:31.6461	78.42	19.79	30.17	t	t	t
2745	2	2026-03-02 18:46:41.65881	37.05	77.82	44.55	t	f	t
2749	5	2026-03-02 18:46:51.660861	69.93	23.52	55.40	t	t	t
2755	4	2026-03-02 18:47:01.661445	59.68	53.75	36.08	t	t	t
2758	3	2026-03-02 18:47:11.671522	76.59	60.21	26.60	t	t	t
2762	5	2026-03-02 18:47:21.673111	76.92	48.26	31.69	f	f	f
2764	2	2026-03-02 18:47:31.676985	42.04	13.04	45.01	t	t	t
2771	5	2026-03-02 18:47:41.683711	77.76	21.01	46.84	f	f	t
2774	4	2026-03-02 18:47:51.68718	62.43	16.82	58.66	t	f	t
2776	3	2026-03-02 18:48:01.691293	76.11	49.03	30.38	t	t	t
2783	4	2026-03-02 18:48:11.711075	24.80	75.68	47.84	t	t	t
2785	5	2026-03-02 18:48:21.718076	42.89	69.66	67.42	t	t	t
2790	4	2026-03-02 18:48:31.730925	63.96	53.07	20.65	t	t	t
2795	4	2026-03-02 18:48:41.732231	71.12	35.30	51.34	t	t	t
2797	5	2026-03-02 18:48:51.733902	13.48	59.46	56.55	t	t	f
2802	3	2026-03-02 18:49:01.747429	23.43	51.07	66.22	t	t	t
2807	3	2026-03-02 18:49:11.752169	38.26	31.03	52.81	t	t	t
2810	3	2026-03-02 18:49:21.761782	10.95	44.42	30.92	t	t	t
2813	5	2026-03-02 18:49:31.767108	22.46	54.18	68.76	t	t	t
2818	4	2026-03-02 18:49:41.782574	63.51	63.46	29.10	t	f	t
2821	4	2026-03-02 18:49:51.803248	46.86	62.53	31.08	t	t	t
2827	3	2026-03-02 18:50:01.816069	10.04	15.61	26.67	t	t	t
2828	3	2026-03-02 18:50:11.831639	16.64	59.35	66.62	t	t	t
2833	5	2026-03-02 18:50:21.846943	20.83	65.94	26.65	t	t	t
2850	3	2026-03-02 18:51:01.850216	41.30	17.66	34.14	t	f	t
2853	3	2026-03-02 18:51:11.862986	48.41	19.89	33.12	t	t	t
2856	2	2026-03-02 18:51:21.872726	32.21	36.65	57.46	t	t	f
2861	5	2026-03-02 18:51:31.884429	39.62	51.41	69.66	t	t	t
2866	4	2026-03-02 18:51:41.893671	38.93	66.11	44.85	t	t	t
2868	2	2026-03-02 18:51:51.902203	18.37	27.46	68.85	t	t	t
2874	5	2026-03-02 18:52:01.9106	40.19	60.88	65.89	t	t	t
2878	4	2026-03-02 18:52:11.915632	57.31	46.77	29.20	t	t	t
2883	4	2026-03-02 18:52:21.929247	43.65	69.65	24.80	t	t	f
2887	4	2026-03-02 18:52:31.935923	58.43	19.86	47.05	f	t	t
2888	2	2026-03-02 18:52:41.947322	31.42	61.57	38.54	t	t	t
2893	5	2026-03-02 18:52:51.949191	39.20	55.92	30.57	t	t	t
2896	4	2026-03-02 18:53:01.951094	41.99	31.49	36.08	t	t	t
2901	5	2026-03-02 18:53:11.963333	27.11	49.28	21.16	t	t	t
2904	4	2026-03-02 18:53:21.969285	56.09	75.18	64.66	t	t	t
2909	5	2026-03-02 18:53:31.97528	30.17	64.55	52.97	t	t	f
222	3	2026-02-28 21:30:13.413484	71.30	79.82	65.99	t	t	t
224	4	2026-02-28 21:30:23.428603	72.53	39.77	38.87	t	t	t
227	4	2026-02-28 21:30:33.440818	27.35	78.13	68.85	t	t	t
231	4	2026-02-28 21:30:43.459645	16.21	75.05	46.21	t	t	t
232	2	2026-02-28 21:37:09.565426	42.61	60.39	57.38	t	t	t
233	3	2026-02-28 21:37:09.571511	51.52	66.29	33.07	t	t	t
234	4	2026-02-28 21:37:09.575369	16.21	75.05	46.21	t	t	t
235	2	2026-02-28 21:41:29.538083	51.95	19.69	59.17	t	t	f
236	4	2026-02-28 21:41:29.538248	10.89	37.66	52.02	t	t	f
237	3	2026-02-28 21:41:29.538392	21.72	58.83	38.86	t	t	t
238	2	2026-02-28 21:41:39.51471	43.16	30.99	54.93	t	t	t
239	4	2026-02-28 21:41:39.51507	70.40	20.28	49.90	t	f	t
240	3	2026-02-28 21:41:39.515279	40.62	20.20	44.08	t	t	t
241	2	2026-02-28 21:41:49.517862	77.86	16.53	61.56	t	t	t
242	4	2026-02-28 21:41:49.518644	63.21	30.93	38.31	t	t	t
243	3	2026-02-28 21:41:49.518966	41.21	37.80	29.37	t	t	t
244	2	2026-02-28 21:41:59.514192	76.07	14.56	39.02	t	t	f
245	3	2026-02-28 21:41:59.514655	25.28	65.60	45.56	t	t	f
246	4	2026-02-28 21:41:59.514724	36.51	50.48	69.09	t	t	t
247	3	2026-02-28 21:42:09.516114	11.87	42.03	38.10	t	t	f
248	2	2026-02-28 21:42:09.516481	38.18	68.78	63.27	t	t	f
249	4	2026-02-28 21:42:09.516724	32.58	68.34	34.53	t	t	t
250	2	2026-02-28 21:42:19.531921	53.10	10.59	44.65	f	t	t
251	4	2026-02-28 21:42:19.532291	63.07	37.16	47.23	t	t	t
252	3	2026-02-28 21:42:19.532436	56.69	17.95	49.51	t	t	t
253	2	2026-02-28 21:42:49.872031	53.10	10.59	44.65	f	t	t
254	3	2026-02-28 21:42:49.875725	56.69	17.95	49.51	t	t	t
255	4	2026-02-28 21:42:49.879085	63.07	37.16	47.23	t	t	t
256	2	2026-02-28 21:53:50.824255	\N	\N	\N	\N	\N	\N
257	3	2026-02-28 21:53:50.829975	\N	\N	\N	\N	\N	\N
258	4	2026-02-28 21:53:50.833386	\N	\N	\N	\N	\N	\N
260	4	2026-02-28 21:54:56.668286	77.59	64.79	47.96	t	t	t
259	2	2026-02-28 21:54:56.667888	71.53	55.00	36.22	f	t	t
261	3	2026-02-28 21:54:56.668125	32.60	71.32	59.85	t	t	t
262	2	2026-02-28 21:55:06.60628	54.49	48.82	21.05	t	t	t
263	3	2026-02-28 21:55:06.606719	72.57	62.91	47.96	t	t	t
264	4	2026-02-28 21:55:06.607464	24.51	53.06	46.08	t	t	t
265	2	2026-02-28 21:55:16.609289	10.83	29.35	67.50	t	t	t
266	4	2026-02-28 21:55:16.609833	46.11	21.10	57.36	f	t	t
267	3	2026-02-28 21:55:16.610477	23.63	52.63	27.32	t	t	t
268	2	2026-02-28 21:55:26.619157	18.32	25.31	52.41	t	t	t
269	4	2026-02-28 21:55:26.619679	21.73	30.85	25.32	t	t	f
270	3	2026-02-28 21:55:26.620021	36.04	38.29	65.80	t	t	t
271	3	2026-02-28 21:55:36.611432	69.29	13.66	34.68	t	t	t
272	2	2026-02-28 21:55:36.611628	34.57	24.86	31.67	t	t	t
273	4	2026-02-28 21:55:36.611905	42.23	11.23	34.82	t	t	t
274	2	2026-02-28 21:55:46.62885	65.01	37.41	46.72	t	t	t
275	4	2026-02-28 21:55:46.629486	23.01	56.42	25.10	t	t	t
276	3	2026-02-28 21:55:46.629918	44.96	74.77	40.11	t	t	t
277	3	2026-02-28 21:55:56.636622	18.83	54.82	36.86	t	t	t
278	4	2026-02-28 21:55:56.637245	46.18	53.13	52.73	t	f	t
279	2	2026-02-28 21:55:56.637618	35.75	41.57	67.80	t	t	t
280	2	2026-02-28 21:56:06.631642	65.82	39.25	64.48	t	t	t
281	4	2026-02-28 21:56:06.631975	38.31	33.04	51.44	t	t	t
282	3	2026-02-28 21:56:06.632291	38.57	17.84	64.48	t	t	t
283	3	2026-02-28 21:56:16.652382	22.18	48.77	64.98	t	f	f
284	2	2026-02-28 21:56:16.652723	37.10	56.39	66.80	t	t	f
285	4	2026-02-28 21:56:16.686167	34.68	36.29	63.18	t	f	t
286	2	2026-02-28 21:56:26.647276	13.87	74.58	47.84	t	t	t
287	3	2026-02-28 21:56:26.64769	54.62	43.15	23.61	t	f	t
288	4	2026-02-28 21:56:26.648	47.75	17.92	44.27	t	t	t
289	2	2026-02-28 21:56:36.665099	71.94	30.15	58.65	t	t	t
290	3	2026-02-28 21:56:36.696969	33.55	78.24	35.06	t	t	f
291	4	2026-02-28 21:56:36.699266	18.90	78.41	36.20	t	t	t
292	2	2026-02-28 21:56:46.679091	19.34	35.20	41.37	t	f	t
293	3	2026-02-28 21:56:46.679652	52.43	56.06	30.94	t	t	t
294	4	2026-02-28 21:56:46.713956	18.92	66.04	56.71	t	t	t
295	2	2026-02-28 21:56:56.680321	46.21	48.77	44.86	t	t	t
296	4	2026-02-28 21:56:56.680982	16.50	73.35	44.93	t	t	t
297	3	2026-02-28 21:56:56.681468	42.01	41.64	38.86	t	t	t
298	2	2026-02-28 21:57:06.678755	65.84	51.69	47.09	t	t	t
299	4	2026-02-28 21:57:06.679951	23.11	45.25	26.73	t	t	f
300	3	2026-02-28 21:57:06.680476	62.08	78.81	44.74	t	t	t
301	2	2026-02-28 21:57:16.688162	69.53	15.73	59.28	t	t	t
302	4	2026-02-28 21:57:16.722961	18.97	55.06	26.20	t	f	t
303	3	2026-02-28 21:57:16.826483	24.29	24.34	55.00	t	f	t
304	3	2026-02-28 21:57:26.703905	62.27	33.06	47.26	t	t	t
305	2	2026-02-28 21:57:26.703777	62.78	33.99	49.10	t	t	t
306	4	2026-02-28 21:57:26.741326	26.05	26.64	33.76	t	t	t
307	2	2026-02-28 21:57:36.725031	56.15	27.37	31.65	t	t	f
308	3	2026-02-28 21:57:36.725469	62.80	55.90	48.17	t	t	t
309	4	2026-02-28 21:57:36.725956	42.13	34.94	33.03	t	t	t
310	2	2026-02-28 21:57:46.725261	52.20	65.76	34.39	t	t	t
311	4	2026-02-28 21:57:46.725625	79.66	55.38	25.19	t	t	t
312	3	2026-02-28 21:57:46.726171	46.21	57.63	40.18	t	t	t
313	2	2026-02-28 21:57:56.725993	75.46	38.88	22.00	t	f	t
314	4	2026-02-28 21:57:56.726569	26.70	24.83	62.46	t	t	t
315	3	2026-02-28 21:57:56.726873	70.51	79.40	23.17	t	t	f
316	2	2026-02-28 21:58:06.735946	74.74	32.51	47.85	f	t	t
317	4	2026-02-28 21:58:06.736599	75.72	54.71	46.78	t	t	t
318	3	2026-02-28 21:58:06.736978	41.04	29.53	47.11	t	f	t
319	2	2026-02-28 21:58:16.750873	52.13	12.74	47.31	t	t	t
320	4	2026-02-28 21:58:16.751208	33.13	12.21	69.54	t	t	f
321	3	2026-02-28 21:58:16.751507	16.88	38.60	27.85	t	t	t
322	3	2026-02-28 21:58:26.770141	26.62	27.23	69.17	t	t	t
323	2	2026-02-28 21:58:26.770413	54.21	78.90	64.39	t	t	t
324	4	2026-02-28 21:58:26.77051	39.48	67.24	58.76	t	t	t
325	2	2026-02-28 21:58:36.778821	35.26	59.48	29.25	t	t	t
326	4	2026-02-28 21:58:36.779167	69.20	60.43	46.22	t	t	t
327	3	2026-02-28 21:58:36.77937	50.77	30.49	61.34	t	t	t
328	2	2026-02-28 21:58:46.777744	35.66	58.89	28.16	t	t	t
329	3	2026-02-28 21:58:46.778249	42.53	22.98	62.97	t	t	t
330	4	2026-02-28 21:58:46.778431	50.89	58.85	59.02	t	t	f
331	2	2026-02-28 21:58:56.786136	17.95	61.48	59.56	t	t	f
332	3	2026-02-28 21:58:56.786653	43.69	77.54	58.28	t	t	f
333	4	2026-02-28 21:58:56.786962	58.51	47.35	65.23	t	t	f
334	4	2026-02-28 21:59:06.788341	55.53	47.57	46.99	t	t	t
336	3	2026-02-28 21:59:06.78849	27.68	71.80	39.09	t	f	t
335	2	2026-02-28 21:59:06.78813	26.49	20.64	52.05	t	t	t
337	2	2026-02-28 21:59:16.798709	69.91	51.37	66.99	t	t	t
342	4	2026-02-28 21:59:26.804202	67.80	76.06	38.53	f	t	t
343	2	2026-02-28 21:59:36.818568	75.48	41.77	36.08	t	t	t
347	3	2026-02-28 21:59:46.820797	64.44	43.10	62.49	t	t	f
351	3	2026-02-28 21:59:56.818803	46.98	28.16	38.16	t	t	t
1300	2	2026-03-02 17:46:28.840297	55.79	70.85	22.92	t	t	t
1305	5	2026-03-02 17:46:38.851825	74.49	51.77	60.30	t	t	t
1311	2	2026-03-02 17:46:48.849347	20.55	58.85	44.43	t	t	t
1312	2	2026-03-02 17:46:58.850441	14.11	76.07	27.23	t	f	f
1317	5	2026-03-02 17:47:08.865059	79.84	75.37	44.68	t	t	t
1321	5	2026-03-02 17:47:18.868018	29.58	57.83	36.39	t	f	t
1327	5	2026-03-02 17:47:28.875915	47.98	55.42	48.05	t	t	t
1329	2	2026-03-02 17:47:38.878236	33.17	35.16	60.79	t	t	t
1335	4	2026-03-02 17:47:48.889	26.07	25.71	54.44	f	t	t
1336	2	2026-03-02 17:47:58.897525	37.90	16.62	56.35	t	t	t
1342	5	2026-03-02 17:48:08.909793	56.99	36.72	48.75	t	t	t
1347	3	2026-03-02 17:48:18.924518	58.85	17.41	28.62	t	t	t
1349	4	2026-03-02 17:48:28.928052	25.68	60.75	25.72	t	t	t
1353	5	2026-03-02 17:48:38.934687	15.48	51.29	31.17	t	f	t
1359	4	2026-03-02 17:48:48.939875	49.44	19.46	64.31	t	t	t
1360	2	2026-03-02 17:48:58.948903	66.96	74.70	21.25	t	f	t
1366	3	2026-03-02 17:49:08.953748	51.06	52.60	43.73	t	t	t
1368	2	2026-03-02 17:49:18.954352	79.09	45.80	55.44	t	t	t
1375	5	2026-03-02 17:49:28.955577	42.44	11.01	44.81	t	t	t
1377	3	2026-03-02 17:49:38.970204	74.39	44.82	20.00	t	t	t
1383	4	2026-03-02 17:49:48.970981	64.97	36.26	20.55	t	t	t
1384	2	2026-03-02 17:49:58.979479	21.69	68.97	62.87	t	f	t
1389	5	2026-03-02 17:50:08.986439	52.03	18.61	51.00	t	t	t
1393	3	2026-03-02 17:50:18.986958	11.88	78.03	44.72	t	t	f
1399	5	2026-03-02 17:50:29.001059	10.14	70.13	34.20	t	t	t
1400	2	2026-03-02 17:50:39.006072	72.20	78.90	20.24	t	t	t
1406	3	2026-03-02 17:50:49.009252	26.45	60.99	49.60	t	f	t
1408	3	2026-03-02 17:50:59.018548	59.74	58.44	25.22	t	t	t
1413	5	2026-03-02 17:51:09.029987	72.95	28.71	68.70	t	t	t
1417	4	2026-03-02 17:51:19.036609	60.61	66.39	53.90	t	t	t
1420	2	2026-03-02 17:51:29.045136	17.90	65.38	66.41	t	t	t
1427	4	2026-03-02 17:51:39.051532	50.47	21.50	37.15	t	t	t
1430	5	2026-03-02 17:51:49.052354	59.66	77.20	32.81	t	f	t
1433	3	2026-03-02 17:51:59.072806	50.44	40.55	60.13	t	t	f
1438	4	2026-03-02 17:52:09.07158	24.23	62.53	30.49	t	t	t
1440	2	2026-03-02 17:52:19.081324	39.98	42.57	68.61	t	t	t
1445	5	2026-03-02 17:52:29.093812	10.89	77.28	48.28	f	t	t
1450	4	2026-03-02 17:52:39.09813	65.03	65.70	53.87	t	t	t
1454	3	2026-03-02 17:52:49.095876	41.41	13.31	69.40	t	t	t
1456	2	2026-03-02 17:52:59.102763	44.85	79.37	61.41	t	t	t
1461	5	2026-03-02 17:53:09.111624	27.34	31.49	54.59	t	t	t
1465	4	2026-03-02 17:53:19.118304	28.49	75.38	68.50	t	t	t
1470	4	2026-03-02 17:53:29.131203	47.16	18.57	38.03	t	f	f
1473	5	2026-03-02 17:53:39.133099	57.04	35.80	44.25	t	t	f
1479	4	2026-03-02 17:53:49.13821	15.84	72.93	49.54	t	t	t
1482	3	2026-03-02 17:53:59.149637	46.57	11.85	29.52	t	t	t
1486	3	2026-03-02 17:54:09.158966	23.58	12.39	20.26	t	t	t
1489	3	2026-03-02 17:54:19.173901	55.62	79.19	56.72	t	t	t
1914	4	2026-03-02 18:12:00.027801	51.70	49.99	68.93	t	t	t
1916	3	2026-03-02 18:12:09.997294	47.26	76.50	30.48	t	t	t
1920	3	2026-03-02 18:12:20.008299	26.52	12.60	41.83	t	t	t
1926	4	2026-03-02 18:12:30.022869	67.47	12.89	22.04	t	t	t
1931	2	2026-03-02 18:12:40.024476	59.66	12.40	45.25	t	t	t
1932	3	2026-03-02 18:12:50.041082	20.57	14.42	39.50	t	t	f
1937	5	2026-03-02 18:13:00.048114	52.64	65.97	34.89	t	t	t
1943	3	2026-03-02 18:13:10.069694	17.94	24.02	45.05	t	t	t
1944	2	2026-03-02 18:13:20.076305	61.75	60.79	49.86	t	t	t
2246	3	2026-03-02 18:25:50.680681	32.95	67.74	21.52	f	t	t
2250	2	2026-03-02 18:26:00.675384	26.83	74.24	48.40	t	t	t
2252	2	2026-03-02 18:26:10.685182	18.09	45.57	55.75	t	t	t
2258	3	2026-03-02 18:26:20.692727	51.50	51.23	38.71	t	t	t
2261	5	2026-03-02 18:26:30.706413	72.02	74.26	25.45	t	f	t
2267	2	2026-03-02 18:26:40.706488	50.95	72.09	47.12	t	f	f
2271	4	2026-03-02 18:26:50.712343	62.11	49.88	62.49	t	t	f
2272	2	2026-03-02 18:27:00.713807	21.99	29.25	21.71	t	t	t
2278	5	2026-03-02 18:27:10.725576	45.34	12.73	32.39	t	t	t
2280	2	2026-03-02 18:27:20.728866	40.70	19.90	59.27	t	t	t
2286	3	2026-03-02 18:27:30.747582	32.92	64.82	68.88	t	t	t
2288	2	2026-03-02 18:27:40.748701	51.19	49.05	52.89	t	t	f
2294	5	2026-03-02 18:27:50.750276	57.30	34.90	42.59	t	t	t
2296	2	2026-03-02 18:28:00.752858	11.34	41.91	62.48	t	t	t
2300	2	2026-03-02 18:28:10.76531	41.78	45.13	28.56	t	t	t
2306	3	2026-03-02 18:28:20.765511	70.72	49.97	22.14	t	f	t
2311	4	2026-03-02 18:28:30.781444	67.38	49.29	20.22	f	t	t
2314	5	2026-03-02 18:28:40.784005	74.90	65.28	34.74	t	t	t
2316	2	2026-03-02 18:28:50.797982	39.41	18.76	34.49	t	t	t
2321	5	2026-03-02 18:29:00.805356	19.75	38.38	38.55	t	t	t
2325	5	2026-03-02 18:29:10.80701	75.98	45.67	56.01	t	t	t
2331	4	2026-03-02 18:29:20.806217	10.52	21.65	26.56	t	t	t
2333	2	2026-03-02 18:29:30.811549	54.67	21.60	22.11	t	t	t
2338	4	2026-03-02 18:29:40.820851	35.42	28.95	22.30	t	t	f
2340	2	2026-03-02 18:29:50.820075	41.15	19.71	30.64	t	f	t
2345	3	2026-03-02 18:30:00.823835	43.76	29.75	46.16	t	t	t
2350	5	2026-03-02 18:30:10.833212	50.01	30.02	36.48	t	t	f
2354	3	2026-03-02 18:30:20.843474	20.61	11.88	42.07	t	f	t
2356	2	2026-03-02 18:30:30.850837	41.22	31.37	20.08	t	t	t
2362	5	2026-03-02 18:30:40.857876	67.47	43.42	49.18	t	t	f
2366	4	2026-03-02 18:30:50.867189	22.88	54.23	27.34	t	t	t
2370	4	2026-03-02 18:31:00.879383	21.76	52.45	46.19	t	t	t
2374	5	2026-03-02 18:31:10.890507	45.45	30.92	45.42	t	t	t
2378	4	2026-03-02 18:31:20.892435	55.12	57.61	21.18	t	t	t
2382	3	2026-03-02 18:31:30.906632	59.99	35.08	31.44	t	t	t
2387	4	2026-03-02 18:31:40.914308	40.97	61.01	63.07	t	t	t
2389	3	2026-03-02 18:31:50.916157	57.33	10.74	24.17	t	t	f
2394	4	2026-03-02 18:32:00.920018	56.07	74.86	63.86	t	t	t
2397	5	2026-03-02 18:32:10.918349	27.59	66.65	66.24	t	t	t
2403	4	2026-03-02 18:32:20.931959	30.81	66.34	58.72	t	t	t
2407	4	2026-03-02 18:32:30.932439	24.40	49.36	23.52	t	t	t
2408	2	2026-03-02 18:32:40.936457	16.48	47.22	40.94	t	t	t
2413	5	2026-03-02 18:32:50.940621	78.92	13.94	32.92	t	t	t
2419	3	2026-03-02 18:33:00.949649	35.16	33.13	49.99	f	t	t
338	3	2026-02-28 21:59:16.799356	59.12	23.87	24.97	t	f	t
341	3	2026-02-28 21:59:26.803869	35.37	45.31	61.81	t	t	t
345	4	2026-02-28 21:59:36.81979	71.26	45.69	64.09	t	t	t
346	2	2026-02-28 21:59:46.82025	23.70	29.64	52.37	t	t	t
350	4	2026-02-28 21:59:56.818634	48.19	25.04	25.15	t	f	t
352	2	2026-02-28 22:00:06.820987	50.78	73.50	45.64	t	t	t
1301	3	2026-03-02 17:46:28.840946	17.55	24.84	24.71	t	t	t
1306	3	2026-03-02 17:46:38.851989	24.25	27.94	31.71	t	t	t
1309	5	2026-03-02 17:46:48.848904	65.82	22.33	27.14	t	t	t
1314	3	2026-03-02 17:46:58.850927	37.34	32.23	25.37	t	t	t
1316	2	2026-03-02 17:47:08.864652	29.66	46.29	46.19	t	t	t
1320	2	2026-03-02 17:47:18.867602	16.83	47.20	22.40	t	t	t
1326	3	2026-03-02 17:47:28.875635	77.11	52.62	33.84	t	t	t
1330	3	2026-03-02 17:47:38.878851	71.66	42.45	25.53	t	t	f
1334	3	2026-03-02 17:47:48.888673	12.65	40.65	55.30	t	t	t
1338	4	2026-03-02 17:47:58.898294	10.95	53.80	48.63	t	t	t
1340	2	2026-03-02 17:48:08.909136	67.50	33.71	49.29	t	t	f
1345	5	2026-03-02 17:48:18.923833	54.05	74.85	49.93	t	t	t
1351	3	2026-03-02 17:48:28.928455	77.54	51.98	61.38	t	t	t
1354	4	2026-03-02 17:48:38.934957	30.66	66.88	58.51	t	t	f
1356	2	2026-03-02 17:48:48.938902	57.66	26.32	40.99	t	t	t
1362	4	2026-03-02 17:48:58.949494	67.33	77.99	32.83	t	f	t
1367	4	2026-03-02 17:49:08.95398	71.98	29.56	32.03	t	f	t
1371	4	2026-03-02 17:49:18.955138	45.93	49.49	33.63	t	f	t
1372	2	2026-03-02 17:49:28.955041	13.01	46.52	34.81	t	t	t
1376	2	2026-03-02 17:49:38.969624	24.92	52.97	55.14	t	t	t
1382	3	2026-03-02 17:49:48.970727	29.92	68.38	27.75	t	t	t
1386	3	2026-03-02 17:49:58.980108	34.41	35.71	35.39	t	f	t
1388	2	2026-03-02 17:50:08.986	41.81	16.86	42.92	f	t	t
1394	5	2026-03-02 17:50:18.987218	32.07	72.29	47.59	t	t	t
1397	3	2026-03-02 17:50:29.000798	27.01	55.10	39.57	t	t	t
1403	4	2026-03-02 17:50:39.006631	37.21	16.25	50.40	t	t	t
1404	2	2026-03-02 17:50:49.008598	48.78	68.43	52.98	t	t	t
1409	2	2026-03-02 17:50:59.018654	18.76	69.71	43.44	t	t	f
1412	2	2026-03-02 17:51:09.029717	42.86	58.84	38.56	t	t	t
1419	5	2026-03-02 17:51:19.037169	75.68	10.82	27.55	t	t	f
1421	5	2026-03-02 17:51:29.045363	69.89	31.71	45.55	t	t	t
1425	3	2026-03-02 17:51:39.051185	67.36	73.68	25.91	t	t	t
1428	2	2026-03-02 17:51:49.051721	55.62	67.34	25.93	t	t	t
1434	5	2026-03-02 17:51:59.07304	12.20	63.13	60.81	t	f	t
1439	3	2026-03-02 17:52:09.071751	15.15	68.38	24.31	f	t	t
1442	3	2026-03-02 17:52:19.081871	62.14	34.06	49.93	t	f	t
1444	3	2026-03-02 17:52:29.093875	44.16	53.54	23.17	t	t	t
1449	5	2026-03-02 17:52:39.097822	21.42	13.81	62.34	t	t	t
1455	4	2026-03-02 17:52:49.095949	43.61	25.44	37.78	t	t	f
1458	4	2026-03-02 17:52:59.1033	58.73	78.58	43.28	f	f	t
1462	4	2026-03-02 17:53:09.111806	29.97	32.96	57.06	t	t	t
1467	3	2026-03-02 17:53:19.118829	73.27	67.63	22.40	t	t	t
1468	2	2026-03-02 17:53:29.130722	73.95	23.70	48.22	t	t	t
1472	3	2026-03-02 17:53:39.132947	30.05	48.77	63.40	t	t	f
1477	5	2026-03-02 17:53:49.137719	51.64	42.48	23.37	t	t	t
1480	2	2026-03-02 17:53:59.149182	13.69	10.12	41.60	f	t	t
1485	5	2026-03-02 17:54:09.158686	55.62	26.03	44.34	t	f	t
1491	4	2026-03-02 17:54:19.17449	15.33	57.90	26.68	t	t	t
1915	5	2026-03-02 18:12:00.028111	23.70	65.19	39.66	t	t	t
1918	2	2026-03-02 18:12:09.997754	19.34	50.11	57.80	t	t	t
1923	2	2026-03-02 18:12:20.009301	53.40	72.58	37.97	t	t	t
1925	3	2026-03-02 18:12:30.022958	37.34	72.95	34.21	f	t	t
1928	3	2026-03-02 18:12:40.023515	49.01	50.99	52.16	t	t	t
1933	5	2026-03-02 18:12:50.041399	25.45	24.29	49.58	t	t	t
1939	3	2026-03-02 18:13:00.048594	46.60	69.89	52.21	t	t	t
1940	2	2026-03-02 18:13:10.068662	74.22	37.37	38.04	t	t	t
1945	5	2026-03-02 18:13:20.076617	73.30	67.41	68.06	t	t	t
2247	4	2026-03-02 18:25:50.680629	34.63	15.84	40.59	t	t	t
2248	3	2026-03-02 18:26:00.67508	18.48	27.69	38.37	t	t	f
2796	2	2026-03-02 18:48:51.7336	48.73	13.67	42.49	t	t	f
2801	5	2026-03-02 18:49:01.747258	63.21	26.41	49.88	t	t	t
2806	5	2026-03-02 18:49:11.752137	40.75	68.27	37.29	t	t	t
2809	4	2026-03-02 18:49:21.761511	52.76	54.26	28.95	t	t	t
2814	4	2026-03-02 18:49:31.767241	35.36	11.03	54.71	t	t	t
2819	3	2026-03-02 18:49:41.782856	47.36	58.51	68.57	t	t	t
2822	3	2026-03-02 18:49:51.803413	74.54	39.76	22.28	t	t	t
2824	2	2026-03-02 18:50:01.815505	31.43	18.72	23.28	t	t	t
2830	5	2026-03-02 18:50:11.832007	64.51	60.91	28.98	t	t	t
2834	3	2026-03-02 18:50:21.847282	48.69	74.24	34.86	t	t	t
2898	2	2026-03-02 18:53:01.951534	52.98	67.72	25.68	t	t	t
2902	3	2026-03-02 18:53:11.963596	12.25	72.42	61.19	t	t	t
2907	3	2026-03-02 18:53:21.970283	17.47	19.49	20.55	t	t	t
2908	2	2026-03-02 18:53:31.974596	53.34	63.70	52.41	t	t	t
2913	4	2026-03-02 18:53:41.975929	51.62	13.83	20.51	t	t	t
2917	5	2026-03-02 18:53:51.977073	15.65	34.57	45.13	t	t	t
2922	4	2026-03-02 18:54:01.978401	11.21	42.96	50.67	t	f	t
2927	3	2026-03-02 18:54:11.994193	57.33	58.15	22.26	t	f	t
2931	4	2026-03-02 18:54:22.007696	62.31	49.85	53.36	t	t	t
2934	3	2026-03-02 18:54:32.012009	58.59	59.72	22.17	t	t	t
2936	2	2026-03-02 18:54:42.025038	78.00	33.58	40.94	t	t	t
2941	5	2026-03-02 18:54:52.025826	18.47	63.65	30.43	t	f	t
2947	4	2026-03-02 18:55:02.03968	63.25	57.09	53.93	t	t	t
2949	3	2026-03-02 18:55:12.043096	35.57	11.51	67.21	t	t	t
2954	3	2026-03-02 18:55:22.055748	41.57	69.37	64.28	t	t	t
2958	2	2026-03-02 18:55:32.059412	11.97	53.26	43.80	t	f	t
2962	3	2026-03-02 18:55:42.070033	11.62	38.14	30.90	t	t	t
2964	3	2026-03-02 18:55:52.071489	21.01	18.51	62.93	f	t	t
2966	2	2026-03-02 18:55:52.071986	12.71	44.28	31.49	t	t	t
2968	2	2026-03-02 18:56:02.089215	75.56	47.21	53.10	t	t	t
2971	3	2026-03-02 18:56:02.089509	45.51	71.32	35.16	t	t	f
2973	4	2026-03-02 18:56:12.101826	39.62	28.03	40.74	t	t	t
2975	2	2026-03-02 18:56:12.102303	26.52	75.38	46.41	t	t	t
2976	4	2026-03-02 18:56:22.116343	12.60	38.43	25.65	t	f	t
2978	2	2026-03-02 18:56:22.116826	23.25	50.80	48.38	t	t	t
2982	4	2026-03-02 18:56:32.117604	32.97	72.72	43.68	t	t	t
2983	5	2026-03-02 18:56:32.117804	57.63	10.88	35.98	t	t	t
2985	5	2026-03-02 18:56:42.120355	56.67	70.19	65.25	t	t	t
2987	4	2026-03-02 18:56:42.12088	39.56	29.85	45.17	f	t	f
2988	3	2026-03-02 18:56:52.138991	45.50	44.87	62.76	t	t	t
2990	2	2026-03-02 18:56:52.139321	45.84	51.82	45.84	t	t	t
2992	4	2026-03-02 18:57:02.137944	40.04	15.76	51.54	t	t	t
339	4	2026-02-28 21:59:16.799945	26.94	10.77	68.59	t	t	t
340	2	2026-02-28 21:59:26.803485	26.48	27.50	39.09	t	t	t
344	3	2026-02-28 21:59:36.819021	14.31	14.74	38.09	t	t	t
348	4	2026-02-28 21:59:46.821715	63.44	44.63	45.81	t	f	t
349	2	2026-02-28 21:59:56.818426	57.05	75.37	69.63	t	t	t
353	3	2026-02-28 22:00:06.821096	48.53	74.83	63.31	t	t	t
354	4	2026-02-28 22:00:06.852586	18.21	79.04	56.16	t	t	t
355	2	2026-02-28 22:00:16.83564	22.76	39.34	22.57	t	t	f
356	3	2026-02-28 22:00:16.86613	17.93	70.79	26.19	t	t	t
357	4	2026-02-28 22:00:16.998297	75.85	13.97	35.66	t	t	t
358	2	2026-02-28 22:00:26.838985	76.52	19.15	44.15	t	t	f
359	4	2026-02-28 22:00:26.839455	78.77	42.39	55.13	t	t	f
360	3	2026-02-28 22:00:26.839639	46.58	30.81	65.49	t	t	t
361	2	2026-02-28 22:00:36.847625	68.38	61.79	31.77	f	t	t
362	4	2026-02-28 22:00:36.882319	64.04	37.14	57.34	t	t	t
363	3	2026-02-28 22:00:36.994478	41.23	73.57	45.06	t	t	t
364	2	2026-02-28 22:00:46.851782	27.09	52.99	23.15	t	t	t
365	3	2026-02-28 22:00:46.85202	10.90	52.34	63.93	t	t	t
366	4	2026-02-28 22:00:46.852169	28.04	45.31	34.54	t	t	f
367	2	2026-02-28 22:00:56.872759	40.02	45.33	56.42	t	t	f
368	4	2026-02-28 22:00:56.907904	51.29	37.02	47.67	t	t	t
369	3	2026-02-28 22:00:57.016278	45.18	15.33	40.91	t	t	t
370	2	2026-02-28 22:01:06.897416	29.82	24.37	40.03	t	t	t
371	4	2026-02-28 22:01:06.92625	12.81	13.16	46.84	t	t	t
372	3	2026-02-28 22:01:07.049417	21.75	28.34	61.05	t	t	t
373	2	2026-02-28 22:01:16.886702	51.06	34.95	23.23	t	t	t
374	4	2026-02-28 22:01:16.887095	76.11	19.71	68.67	t	t	f
375	3	2026-02-28 22:01:16.887267	60.30	39.66	65.06	t	t	t
376	2	2026-02-28 22:01:26.931973	66.86	64.67	31.58	t	t	t
377	3	2026-02-28 22:01:26.982481	70.40	30.51	55.57	t	t	t
378	4	2026-02-28 22:01:26.982649	49.12	35.42	47.45	t	t	t
379	3	2026-02-28 22:01:36.897756	33.47	36.33	43.07	t	t	t
380	4	2026-02-28 22:01:36.898267	68.33	29.32	60.92	t	t	t
381	2	2026-02-28 22:01:36.898964	47.42	76.04	55.75	t	t	t
382	2	2026-02-28 22:01:46.900109	15.54	67.86	44.58	t	t	t
383	4	2026-02-28 22:01:46.900452	61.82	14.51	58.56	t	t	f
384	3	2026-02-28 22:01:46.900758	37.30	49.29	64.71	t	t	t
385	2	2026-02-28 22:01:56.917284	68.12	72.59	34.42	t	t	t
386	4	2026-02-28 22:01:56.91767	20.04	30.51	68.23	t	t	t
387	3	2026-02-28 22:01:56.918217	62.42	55.08	32.91	t	t	t
388	2	2026-02-28 22:02:06.931525	62.61	26.50	47.71	t	t	t
389	4	2026-02-28 22:02:06.932265	60.70	34.51	49.29	t	t	t
390	3	2026-02-28 22:02:06.9328	57.57	24.74	30.31	t	f	t
391	2	2026-02-28 22:02:16.94504	42.58	60.15	27.31	t	t	t
392	4	2026-02-28 22:02:16.945409	57.01	53.50	48.76	t	t	t
393	3	2026-02-28 22:02:16.945851	78.99	54.00	36.02	t	t	t
394	2	2026-02-28 22:02:26.961868	78.03	47.37	54.94	t	t	t
395	4	2026-02-28 22:02:26.962407	36.78	65.15	55.28	t	t	t
396	3	2026-02-28 22:02:26.962944	25.01	21.11	48.63	f	t	t
397	2	2026-02-28 22:02:36.975503	61.78	65.28	44.09	t	t	t
398	3	2026-02-28 22:02:36.976087	11.94	54.00	42.37	f	t	t
399	4	2026-02-28 22:02:36.976594	51.50	18.92	64.49	t	t	t
400	2	2026-02-28 22:02:46.987487	24.42	62.91	21.37	t	t	t
401	4	2026-02-28 22:02:46.988015	76.32	40.93	65.02	t	t	t
402	3	2026-02-28 22:02:46.988387	32.53	79.86	25.26	t	t	t
403	2	2026-02-28 22:02:56.994357	61.68	31.23	33.06	t	t	t
404	3	2026-02-28 22:02:56.994675	68.81	62.47	27.53	t	t	t
405	4	2026-02-28 22:02:56.995129	29.30	19.81	65.40	t	t	t
406	2	2026-02-28 22:03:07.004222	45.30	65.11	48.22	t	f	t
407	3	2026-02-28 22:03:07.004536	44.85	34.46	60.32	t	t	t
408	4	2026-02-28 22:03:07.005159	13.58	26.47	28.88	t	t	t
409	2	2026-02-28 22:03:17.007625	12.43	26.85	64.93	t	t	t
410	4	2026-02-28 22:03:17.008213	24.28	26.34	42.00	t	f	t
411	3	2026-02-28 22:03:17.00854	29.97	71.12	49.78	t	t	t
412	3	2026-02-28 22:03:27.018145	55.29	73.47	38.49	t	t	t
413	2	2026-02-28 22:03:27.018466	60.74	43.86	53.08	f	t	t
414	4	2026-02-28 22:03:27.018595	63.57	49.05	33.59	t	t	t
415	2	2026-02-28 22:03:37.024138	24.43	47.67	59.44	t	t	t
416	4	2026-02-28 22:03:37.024615	49.36	24.78	68.76	t	t	t
417	3	2026-02-28 22:03:37.025166	55.01	65.14	28.54	t	t	t
418	2	2026-02-28 22:03:47.037584	25.75	39.38	44.61	t	t	t
419	4	2026-02-28 22:03:47.037941	44.24	43.97	23.50	t	t	t
420	3	2026-02-28 22:03:47.03821	35.07	20.50	34.98	t	t	t
421	2	2026-02-28 22:03:57.037113	30.75	32.62	22.20	t	f	t
422	4	2026-02-28 22:03:57.03761	19.69	68.44	46.98	f	t	t
423	3	2026-02-28 22:03:57.03795	20.66	35.54	36.84	t	f	t
424	2	2026-02-28 22:04:07.050245	60.95	69.62	38.85	t	t	t
425	3	2026-02-28 22:04:07.050621	12.32	55.77	58.90	t	t	t
426	4	2026-02-28 22:04:07.051115	53.21	44.54	48.38	t	t	t
427	2	2026-02-28 22:04:17.054618	31.41	65.15	30.90	t	t	t
428	4	2026-02-28 22:04:17.055143	41.73	76.19	37.87	t	t	t
429	3	2026-02-28 22:04:17.055473	28.07	43.00	61.79	t	t	t
430	2	2026-02-28 22:04:27.069291	54.43	21.49	38.37	t	t	t
431	3	2026-02-28 22:04:27.06984	60.43	44.75	29.59	t	t	t
432	4	2026-02-28 22:04:27.070314	50.92	36.46	24.45	t	t	t
433	2	2026-02-28 22:04:37.070275	77.15	23.53	21.68	t	t	t
434	4	2026-02-28 22:04:37.070779	25.64	61.70	48.24	t	f	f
435	3	2026-02-28 22:04:37.071112	66.87	76.82	34.80	t	t	t
436	2	2026-02-28 22:04:47.087591	38.52	65.87	41.92	t	t	t
437	3	2026-02-28 22:04:47.087769	28.54	60.19	61.33	t	t	t
438	4	2026-02-28 22:04:47.088019	30.49	79.08	26.42	t	t	t
439	2	2026-02-28 22:04:57.099831	66.15	66.94	40.16	t	t	t
440	4	2026-02-28 22:04:57.100287	45.64	40.22	22.72	t	f	t
441	3	2026-02-28 22:04:57.100812	23.79	73.37	39.09	t	t	t
442	2	2026-02-28 22:05:07.110285	62.35	50.59	61.88	t	t	t
443	4	2026-02-28 22:05:07.11051	17.97	29.79	35.95	t	f	t
444	3	2026-02-28 22:05:07.110683	11.13	48.61	37.84	t	t	t
445	3	2026-02-28 22:05:17.115014	76.75	48.29	57.34	t	t	t
446	4	2026-02-28 22:05:17.11537	60.97	39.86	28.37	t	t	t
447	2	2026-02-28 22:05:17.115536	50.89	14.55	46.18	t	t	t
448	2	2026-02-28 22:05:27.117863	23.66	31.40	44.38	t	f	t
449	4	2026-02-28 22:05:27.118183	38.63	32.80	55.11	t	t	t
450	3	2026-02-28 22:05:27.118399	63.52	55.46	61.40	t	t	t
451	3	2026-02-28 22:05:37.130819	66.89	78.82	55.37	t	t	t
452	4	2026-02-28 22:05:37.13109	31.82	28.41	29.35	t	f	f
453	2	2026-02-28 22:05:37.131296	79.31	32.65	39.28	t	t	t
454	2	2026-02-28 22:05:47.133595	49.70	22.66	32.20	t	t	t
455	3	2026-02-28 22:05:47.133835	22.27	53.05	58.95	t	t	t
456	4	2026-02-28 22:05:47.134209	32.61	19.31	47.61	t	t	t
457	2	2026-02-28 22:05:57.145903	67.58	55.48	28.05	t	t	t
458	3	2026-02-28 22:05:57.178611	40.71	51.01	66.58	t	t	t
459	4	2026-02-28 22:05:57.182164	76.58	40.47	68.00	t	t	t
460	2	2026-02-28 22:06:07.146522	30.46	21.07	68.16	t	t	t
461	4	2026-02-28 22:06:07.146877	35.18	10.57	56.60	t	t	t
462	3	2026-02-28 22:06:07.147074	24.29	52.61	24.19	t	t	t
463	2	2026-02-28 22:06:17.159956	64.29	35.60	59.53	t	t	t
464	3	2026-02-28 22:06:17.193017	22.90	12.45	62.27	t	t	t
465	4	2026-02-28 22:06:17.194594	67.83	13.42	34.33	t	t	t
466	2	2026-02-28 22:06:27.174351	43.02	46.01	59.53	t	t	t
467	3	2026-02-28 22:06:27.174469	71.43	37.84	63.52	t	t	t
468	4	2026-02-28 22:06:27.314929	76.77	10.46	27.87	t	t	t
469	2	2026-02-28 22:06:37.18262	73.13	27.33	35.74	t	t	t
470	3	2026-02-28 22:06:37.215479	55.76	27.49	50.76	t	t	t
471	4	2026-02-28 22:06:37.216547	46.41	79.41	69.11	t	t	t
472	2	2026-02-28 22:06:47.196001	29.50	49.66	49.00	t	t	f
473	3	2026-02-28 22:06:47.196406	60.96	50.60	68.28	t	t	t
474	4	2026-02-28 22:06:47.225864	63.85	31.26	48.06	t	t	t
475	2	2026-02-28 22:06:57.19676	38.08	78.23	48.72	t	t	t
476	4	2026-02-28 22:06:57.196962	78.51	71.52	32.26	t	t	t
477	3	2026-02-28 22:06:57.197162	32.46	23.72	45.17	t	t	t
478	2	2026-02-28 22:07:07.204054	13.04	26.63	55.59	f	t	t
479	3	2026-02-28 22:07:07.237325	72.66	35.97	54.44	t	t	t
480	4	2026-02-28 22:07:07.238266	73.14	10.41	30.14	t	t	t
481	2	2026-02-28 22:07:17.201847	32.49	75.08	37.05	t	t	t
482	4	2026-02-28 22:07:17.202153	35.68	12.11	65.73	t	t	t
483	3	2026-02-28 22:07:17.202357	13.40	27.06	57.29	t	t	f
484	2	2026-02-28 22:07:27.205649	50.60	26.70	56.27	t	t	t
485	4	2026-02-28 22:07:27.206088	68.61	42.20	40.40	t	t	t
486	3	2026-02-28 22:07:27.206337	64.77	65.41	22.61	t	t	t
487	2	2026-02-28 22:07:37.217657	38.30	29.98	63.29	t	t	t
488	3	2026-02-28 22:07:37.249485	38.50	37.86	66.89	t	t	t
489	4	2026-02-28 22:07:37.25137	50.41	29.15	26.83	t	t	t
490	2	2026-02-28 22:07:47.236217	28.74	73.75	62.93	t	t	f
491	3	2026-02-28 22:07:47.236609	70.62	74.89	39.21	t	t	t
492	4	2026-02-28 22:07:47.266775	38.12	27.62	42.27	t	t	t
493	2	2026-02-28 22:07:57.249482	55.45	46.05	20.86	t	t	t
494	3	2026-02-28 22:07:57.281966	29.51	49.63	64.96	t	t	t
495	4	2026-02-28 22:07:57.284525	30.53	69.34	64.14	t	f	t
496	2	2026-02-28 22:08:07.255314	70.24	68.45	31.35	t	t	f
497	3	2026-02-28 22:08:07.255705	41.25	22.58	52.98	t	t	t
498	4	2026-02-28 22:08:07.25617	46.28	29.07	65.20	f	f	t
499	2	2026-02-28 22:08:17.253618	76.87	19.87	53.51	t	t	t
500	4	2026-02-28 22:08:17.253987	46.40	10.74	30.81	t	f	t
501	3	2026-02-28 22:08:17.254213	30.13	30.01	35.82	t	t	t
502	2	2026-02-28 22:08:27.266232	12.77	71.53	65.47	t	f	t
503	4	2026-02-28 22:08:27.302731	22.70	77.27	33.38	t	t	t
504	3	2026-02-28 22:08:27.303088	29.73	47.32	23.60	f	t	t
505	2	2026-02-28 22:08:37.271583	79.28	58.33	44.03	t	t	t
506	4	2026-02-28 22:08:37.271845	48.91	63.10	22.63	t	t	t
507	3	2026-02-28 22:08:37.272124	25.44	20.20	67.55	t	t	t
508	2	2026-02-28 22:08:47.285564	71.09	25.07	39.85	t	t	t
509	3	2026-02-28 22:08:47.315897	51.03	58.76	58.19	t	t	t
510	4	2026-02-28 22:08:47.317472	71.81	53.59	22.07	t	f	t
511	4	2026-02-28 22:08:57.28478	49.54	64.97	55.32	t	t	f
512	3	2026-02-28 22:08:57.285101	44.82	56.08	35.03	t	t	f
513	2	2026-02-28 22:08:57.285311	27.66	77.01	49.64	t	t	t
514	2	2026-02-28 22:09:07.291433	37.60	74.95	68.05	t	t	t
515	3	2026-02-28 22:09:07.291955	25.80	19.14	28.62	t	t	f
516	4	2026-02-28 22:09:07.292257	61.98	75.92	28.04	t	t	t
517	2	2026-02-28 22:09:17.298245	67.07	44.53	48.95	t	t	t
518	3	2026-02-28 22:09:17.298783	41.26	15.89	62.86	t	t	t
519	4	2026-02-28 22:09:17.327524	35.40	73.98	38.39	t	t	t
520	2	2026-02-28 22:09:27.312464	10.91	47.66	53.00	t	t	t
521	3	2026-02-28 22:09:27.346785	17.58	72.17	66.70	t	f	t
522	4	2026-02-28 22:09:27.347082	35.19	28.32	63.28	t	t	t
523	2	2026-02-28 22:09:37.318901	35.20	29.99	62.32	t	t	t
524	4	2026-02-28 22:09:37.319295	77.44	50.12	63.54	t	t	t
525	3	2026-02-28 22:09:37.31966	58.21	20.90	29.12	t	t	t
526	4	2026-02-28 22:09:47.314023	39.33	28.06	31.46	t	t	t
527	2	2026-02-28 22:09:47.313973	76.49	56.93	41.06	t	t	t
528	3	2026-02-28 22:09:47.314144	38.01	11.29	42.24	t	t	f
529	2	2026-02-28 22:09:57.327354	20.45	50.77	55.48	t	f	t
530	3	2026-02-28 22:09:57.360185	76.61	66.10	31.95	t	t	t
531	4	2026-02-28 22:09:57.362938	30.22	11.37	50.98	t	t	t
532	2	2026-02-28 22:10:07.331791	28.65	62.32	64.72	t	t	t
533	4	2026-02-28 22:10:07.332068	78.80	29.29	52.69	t	t	f
534	3	2026-02-28 22:10:07.332262	29.24	78.54	22.56	t	t	t
535	2	2026-02-28 22:10:17.346363	39.97	72.46	26.20	t	t	f
536	3	2026-02-28 22:10:17.378846	35.01	76.61	55.72	t	t	t
537	4	2026-02-28 22:10:17.38079	61.22	59.48	53.34	t	t	t
538	2	2026-02-28 22:10:27.347831	54.07	35.24	51.39	t	t	t
540	3	2026-02-28 22:10:27.348259	40.25	68.91	47.25	t	f	f
539	4	2026-02-28 22:10:27.348219	52.30	44.38	38.61	t	t	t
541	2	2026-02-28 22:10:37.343207	37.24	49.13	64.18	t	t	f
542	4	2026-02-28 22:10:37.343338	18.08	75.41	27.08	t	t	t
543	3	2026-02-28 22:10:37.343443	11.44	52.75	51.49	t	t	t
544	2	2026-02-28 22:10:47.360077	66.61	59.17	34.31	t	t	f
545	3	2026-02-28 22:10:47.392053	24.31	15.84	26.67	t	t	f
546	4	2026-02-28 22:10:47.393314	51.38	23.77	30.73	t	t	f
547	2	2026-02-28 22:10:57.376958	55.60	44.35	37.85	t	t	t
548	3	2026-02-28 22:10:57.377428	79.68	31.98	54.08	t	f	t
549	4	2026-02-28 22:10:57.40919	10.90	31.86	43.05	t	t	t
550	2	2026-02-28 22:11:07.381517	12.04	55.04	44.33	t	f	t
551	4	2026-02-28 22:11:07.381809	33.12	16.52	63.40	t	f	f
552	3	2026-02-28 22:11:07.382001	47.13	37.97	67.87	t	t	t
553	2	2026-02-28 22:11:17.380116	52.62	14.03	31.05	t	t	t
554	4	2026-02-28 22:11:17.380331	42.10	47.04	64.86	t	t	t
555	3	2026-02-28 22:11:17.380495	45.03	12.16	69.35	t	t	t
556	2	2026-02-28 22:11:27.383546	48.26	36.36	43.62	t	t	f
557	4	2026-02-28 22:11:27.384036	31.73	69.74	29.85	t	t	f
558	3	2026-02-28 22:11:27.384189	51.37	34.26	58.24	t	t	t
559	2	2026-02-28 22:11:37.398325	62.54	65.98	34.80	t	t	t
560	3	2026-02-28 22:11:37.432931	27.28	25.19	23.40	t	t	t
561	4	2026-02-28 22:11:37.433355	32.96	30.88	37.46	t	t	t
562	2	2026-02-28 22:11:47.395397	71.54	13.17	22.22	t	t	t
1302	5	2026-03-02 17:46:28.840667	76.62	35.73	51.97	t	t	f
1304	2	2026-03-02 17:46:38.851486	45.04	63.58	61.87	t	t	t
1308	3	2026-03-02 17:46:48.848497	31.63	22.12	60.89	f	t	f
1315	5	2026-03-02 17:46:58.851132	25.05	56.37	28.16	t	t	f
1318	4	2026-03-02 17:47:08.865351	54.95	24.30	48.38	t	t	t
1322	4	2026-03-02 17:47:18.868231	18.54	15.10	52.25	t	t	t
1325	4	2026-03-02 17:47:28.875337	15.74	47.08	41.05	t	f	t
1328	5	2026-03-02 17:47:38.878539	32.56	23.84	63.13	t	t	t
1333	5	2026-03-02 17:47:48.888499	26.37	25.87	27.53	t	t	t
1339	3	2026-03-02 17:47:58.898624	27.86	77.57	30.67	t	t	f
1341	3	2026-03-02 17:48:08.909532	61.91	41.02	20.30	t	t	t
1346	4	2026-03-02 17:48:18.924217	53.68	45.62	35.29	t	t	t
1348	2	2026-03-02 17:48:28.927899	67.54	58.12	46.42	t	t	t
1355	3	2026-03-02 17:48:38.93515	61.99	71.02	28.70	t	t	t
1357	5	2026-03-02 17:48:48.939166	56.76	76.93	23.44	t	t	t
1363	3	2026-03-02 17:48:58.94991	52.53	75.56	55.78	t	t	f
1364	2	2026-03-02 17:49:08.953034	12.96	13.41	39.40	t	t	f
1369	5	2026-03-02 17:49:18.954483	52.49	10.63	59.36	t	t	t
1374	3	2026-03-02 17:49:28.955458	36.52	19.94	30.98	t	t	t
1378	4	2026-03-02 17:49:38.970523	37.54	78.56	37.52	t	t	t
1381	5	2026-03-02 17:49:48.970459	35.25	26.31	61.43	t	t	t
1387	5	2026-03-02 17:49:58.980277	16.15	79.29	69.63	t	t	t
1390	3	2026-03-02 17:50:08.9868	71.22	39.57	25.62	t	t	t
1392	2	2026-03-02 17:50:18.986627	70.33	75.58	44.73	t	t	t
1398	4	2026-03-02 17:50:29.000968	20.10	40.55	54.06	t	t	t
1402	3	2026-03-02 17:50:39.006478	70.50	40.66	53.01	t	t	t
1407	5	2026-03-02 17:50:49.009374	40.40	60.98	60.78	t	t	t
1411	4	2026-03-02 17:50:59.019024	38.63	38.55	62.78	t	t	t
1415	3	2026-03-02 17:51:09.030485	16.53	76.05	26.04	t	f	t
1418	3	2026-03-02 17:51:19.036948	12.06	27.92	62.55	t	t	f
1423	4	2026-03-02 17:51:29.04587	36.39	65.19	59.41	t	t	t
1426	5	2026-03-02 17:51:39.051421	73.35	77.54	32.38	t	t	t
1431	4	2026-03-02 17:51:49.052523	27.85	54.45	23.63	t	t	t
1432	2	2026-03-02 17:51:59.072433	25.88	74.04	35.71	t	t	f
1437	5	2026-03-02 17:52:09.070924	29.68	52.99	21.28	t	t	t
1441	5	2026-03-02 17:52:19.081603	73.55	48.32	25.04	t	t	t
1447	4	2026-03-02 17:52:29.094052	70.40	65.85	42.13	t	f	t
1451	3	2026-03-02 17:52:39.098406	36.81	70.62	25.65	t	t	t
1452	2	2026-03-02 17:52:49.095428	57.15	73.99	24.42	t	t	f
1457	5	2026-03-02 17:52:59.102956	57.33	60.36	61.51	f	t	t
1460	2	2026-03-02 17:53:09.111349	31.77	47.19	58.39	t	t	f
1466	5	2026-03-02 17:53:19.118494	67.78	79.41	69.76	t	t	t
1471	3	2026-03-02 17:53:29.131536	66.50	54.51	69.96	t	t	f
1474	2	2026-03-02 17:53:39.133155	41.93	19.80	32.11	t	f	f
1478	3	2026-03-02 17:53:49.1379	74.30	46.03	62.85	t	t	t
1483	4	2026-03-02 17:53:59.149928	56.87	47.63	41.97	t	t	t
1487	4	2026-03-02 17:54:09.159225	71.57	12.59	40.65	t	t	t
1488	5	2026-03-02 17:54:19.173691	28.62	23.79	22.52	t	t	t
1948	2	2026-03-02 18:13:30.090049	49.17	76.07	35.55	t	f	f
1954	5	2026-03-02 18:13:40.090792	33.91	18.58	33.75	t	t	t
1958	4	2026-03-02 18:13:50.111142	79.82	67.87	28.16	t	t	t
1963	4	2026-03-02 18:14:00.120874	19.86	15.67	51.27	t	f	t
1967	3	2026-03-02 18:14:10.1269	13.19	30.35	66.57	t	t	t
1971	3	2026-03-02 18:14:20.129696	19.11	43.65	21.42	t	t	t
1972	2	2026-03-02 18:14:30.140395	75.68	30.66	48.85	t	t	t
1978	4	2026-03-02 18:14:40.150995	42.39	16.76	30.07	t	t	t
1983	3	2026-03-02 18:14:50.157278	49.95	56.22	69.51	t	t	f
1984	2	2026-03-02 18:15:00.166145	47.86	16.47	40.46	t	t	f
1991	5	2026-03-02 18:15:10.168396	58.64	70.27	23.47	t	t	f
1992	2	2026-03-02 18:15:20.183294	33.27	14.49	69.42	t	t	t
1997	5	2026-03-02 18:15:30.185081	62.09	13.25	44.88	t	f	t
2001	5	2026-03-02 18:15:40.196253	48.13	54.50	61.20	t	t	t
2007	5	2026-03-02 18:15:50.202236	22.07	31.84	65.92	t	t	t
2008	2	2026-03-02 18:16:00.21597	59.40	71.47	33.58	f	t	f
2015	3	2026-03-02 18:16:10.227876	22.73	11.54	45.21	t	f	t
2016	2	2026-03-02 18:16:20.23583	27.53	55.63	31.29	t	t	t
2021	5	2026-03-02 18:16:30.245798	17.83	74.49	30.38	t	f	f
2024	4	2026-03-02 18:16:40.258792	65.95	29.40	30.52	t	t	t
2251	4	2026-03-02 18:26:00.675313	10.24	32.30	23.65	t	t	t
2254	4	2026-03-02 18:26:10.685421	47.96	55.27	29.28	t	t	t
2259	4	2026-03-02 18:26:20.692727	23.51	15.24	29.65	t	t	t
2262	3	2026-03-02 18:26:30.706538	35.83	19.52	41.87	t	f	t
2265	4	2026-03-02 18:26:40.706166	62.09	54.44	66.19	t	t	t
2268	2	2026-03-02 18:26:50.7117	79.75	32.12	41.87	t	t	t
2275	5	2026-03-02 18:27:00.714895	57.61	15.67	44.97	f	t	t
2277	2	2026-03-02 18:27:10.725383	10.52	26.08	27.46	f	t	t
2283	3	2026-03-02 18:27:20.72948	78.53	46.59	42.46	t	t	t
2287	4	2026-03-02 18:27:30.747841	45.77	38.79	43.15	t	t	t
2291	4	2026-03-02 18:27:40.74935	70.25	16.54	51.42	t	t	t
2293	3	2026-03-02 18:27:50.74994	50.32	48.04	52.31	t	t	t
2298	3	2026-03-02 18:28:00.753674	10.37	11.07	66.04	t	t	t
2303	4	2026-03-02 18:28:10.766184	29.19	77.70	32.50	t	t	t
2304	2	2026-03-02 18:28:20.764686	79.16	39.04	49.87	t	t	t
2310	3	2026-03-02 18:28:30.781274	68.40	24.43	50.68	t	t	t
2313	2	2026-03-02 18:28:40.783852	61.10	42.56	56.06	t	t	t
2318	4	2026-03-02 18:28:50.798653	27.76	47.63	63.59	t	t	t
2322	3	2026-03-02 18:29:00.805692	45.42	25.27	44.22	t	t	t
2324	2	2026-03-02 18:29:10.806903	37.56	21.61	30.10	t	t	f
2329	5	2026-03-02 18:29:20.80605	69.39	14.89	43.55	t	f	t
2334	4	2026-03-02 18:29:30.812224	50.41	27.95	54.29	t	t	t
2339	3	2026-03-02 18:29:40.82105	67.12	33.12	59.11	t	t	t
2342	3	2026-03-02 18:29:50.820645	40.96	29.53	25.50	t	t	t
2346	4	2026-03-02 18:30:00.824312	68.06	77.45	54.36	t	t	t
2348	3	2026-03-02 18:30:10.832281	29.95	59.35	45.20	t	f	t
2353	5	2026-03-02 18:30:20.843258	72.63	74.89	32.21	t	t	t
2359	3	2026-03-02 18:30:30.851466	74.03	43.01	66.84	t	t	f
2361	4	2026-03-02 18:30:40.857367	24.14	38.57	54.39	f	t	t
2367	3	2026-03-02 18:30:50.867126	16.64	61.86	37.07	t	t	t
2368	2	2026-03-02 18:31:00.878533	61.14	43.26	23.61	t	t	t
2375	4	2026-03-02 18:31:10.890806	21.96	35.08	61.39	t	f	t
2379	2	2026-03-02 18:31:20.892718	42.72	79.09	60.96	t	t	t
2380	2	2026-03-02 18:31:30.906149	54.13	28.79	41.98	f	t	t
2384	5	2026-03-02 18:31:40.913958	46.00	78.09	64.03	t	t	t
2390	5	2026-03-02 18:31:50.915941	57.79	18.88	20.66	t	t	t
2393	5	2026-03-02 18:32:00.919844	18.09	64.13	64.47	f	t	t
2399	4	2026-03-02 18:32:10.91882	67.46	47.82	54.21	t	t	t
563	3	2026-02-28 22:11:47.396039	46.94	71.99	53.60	t	t	t
1303	4	2026-03-02 17:46:28.841168	53.57	68.51	26.49	t	t	t
1307	4	2026-03-02 17:46:38.852398	71.33	55.07	34.45	t	t	t
1310	4	2026-03-02 17:46:48.849089	56.67	10.11	47.53	t	t	f
1313	4	2026-03-02 17:46:58.850727	27.57	26.33	56.59	t	t	t
1319	3	2026-03-02 17:47:08.865638	12.70	58.08	42.47	t	t	t
1323	3	2026-03-02 17:47:18.86837	55.45	46.53	67.66	t	t	f
1324	2	2026-03-02 17:47:28.875049	23.71	35.81	29.60	t	t	t
1331	4	2026-03-02 17:47:38.879329	47.94	20.18	35.22	t	t	t
1332	2	2026-03-02 17:47:48.888246	29.57	21.03	58.06	t	t	t
1337	5	2026-03-02 17:47:58.898093	24.29	76.04	52.30	t	f	t
1343	4	2026-03-02 17:48:08.910252	38.36	16.01	29.74	t	t	t
1344	2	2026-03-02 17:48:18.923249	32.45	54.86	50.63	t	t	t
1350	5	2026-03-02 17:48:28.928305	22.95	21.27	62.08	f	t	t
1352	2	2026-03-02 17:48:38.934271	14.16	70.94	24.43	t	t	t
1358	3	2026-03-02 17:48:48.939658	57.44	54.28	50.68	t	t	t
1361	5	2026-03-02 17:48:58.949296	64.22	42.17	42.76	t	t	t
1365	5	2026-03-02 17:49:08.953437	71.70	59.92	21.97	t	t	t
1370	3	2026-03-02 17:49:18.954595	37.70	36.90	47.63	t	t	t
1373	4	2026-03-02 17:49:28.955351	33.77	23.21	61.39	t	t	t
1379	5	2026-03-02 17:49:38.97079	27.34	59.58	20.40	t	t	t
1380	2	2026-03-02 17:49:48.970152	59.61	59.45	20.19	t	t	t
1385	4	2026-03-02 17:49:58.979808	44.70	13.39	68.09	t	t	t
1391	4	2026-03-02 17:50:08.986975	63.03	75.43	34.00	t	t	t
1395	4	2026-03-02 17:50:18.987468	71.92	59.42	24.16	t	t	t
1396	2	2026-03-02 17:50:29.000655	44.73	42.76	31.81	t	t	f
1401	5	2026-03-02 17:50:39.006382	16.32	59.03	34.70	t	t	t
1405	4	2026-03-02 17:50:49.009138	53.82	14.44	36.61	t	t	t
1410	5	2026-03-02 17:50:59.018745	48.44	53.71	64.59	t	t	t
1414	4	2026-03-02 17:51:09.03017	69.66	49.70	25.70	t	t	f
1416	2	2026-03-02 17:51:19.036225	57.73	62.87	26.85	t	t	t
1422	3	2026-03-02 17:51:29.045645	53.72	35.11	59.64	t	t	t
1424	2	2026-03-02 17:51:39.050473	68.31	12.78	24.24	t	t	t
1429	3	2026-03-02 17:51:49.052173	59.54	79.97	25.78	t	t	t
1435	4	2026-03-02 17:51:59.073033	42.29	32.39	51.35	t	f	t
1436	2	2026-03-02 17:52:09.070709	33.32	21.23	41.24	t	t	f
1443	4	2026-03-02 17:52:19.082217	16.02	65.14	56.85	t	t	t
1446	2	2026-03-02 17:52:29.093729	37.54	12.24	35.27	t	t	t
1448	2	2026-03-02 17:52:39.097564	44.18	64.36	68.10	t	t	t
1453	5	2026-03-02 17:52:49.095629	53.97	24.75	25.73	t	t	f
1459	3	2026-03-02 17:52:59.103794	67.16	22.48	30.54	t	t	t
1463	3	2026-03-02 17:53:09.112104	59.83	78.78	25.40	t	f	t
1464	2	2026-03-02 17:53:19.118004	26.83	54.43	45.60	t	t	t
1469	5	2026-03-02 17:53:29.130994	61.21	39.44	67.51	t	t	f
1475	4	2026-03-02 17:53:39.133334	45.55	10.54	24.74	t	f	t
1476	2	2026-03-02 17:53:49.137453	11.39	23.05	31.53	t	t	t
1481	5	2026-03-02 17:53:59.149467	52.21	44.83	26.76	t	t	f
1484	2	2026-03-02 17:54:09.158501	16.62	38.97	64.59	t	t	t
1490	2	2026-03-02 17:54:19.174238	19.73	47.95	47.04	t	t	t
1950	5	2026-03-02 18:13:30.090685	28.42	42.86	22.48	t	t	t
1953	3	2026-03-02 18:13:40.090605	48.23	33.42	50.93	t	t	t
1956	3	2026-03-02 18:13:50.110509	15.80	42.08	66.06	t	t	f
1961	5	2026-03-02 18:14:00.120326	65.53	16.84	28.87	t	t	t
1966	4	2026-03-02 18:14:10.12674	30.07	78.08	34.49	t	f	t
1968	4	2026-03-02 18:14:20.12928	39.04	27.70	55.28	f	f	t
1974	4	2026-03-02 18:14:30.140936	62.37	29.32	54.87	t	t	t
1979	3	2026-03-02 18:14:40.151256	63.77	49.86	43.88	t	t	t
1982	4	2026-03-02 18:14:50.156911	21.92	75.67	23.83	t	t	t
1986	4	2026-03-02 18:15:00.166569	74.16	46.54	59.84	t	t	t
1988	2	2026-03-02 18:15:10.16767	15.69	40.94	39.30	t	t	t
1993	5	2026-03-02 18:15:20.183692	30.72	31.08	43.09	t	t	t
1996	2	2026-03-02 18:15:30.184873	28.69	49.81	65.97	t	t	t
2003	3	2026-03-02 18:15:40.196708	44.12	13.31	26.25	t	t	t
2005	4	2026-03-02 18:15:50.202166	36.53	50.08	49.88	t	t	t
2010	3	2026-03-02 18:16:00.216423	38.01	74.79	46.13	t	t	t
2014	5	2026-03-02 18:16:10.227562	60.28	60.21	22.08	t	t	t
2018	5	2026-03-02 18:16:20.236873	47.70	69.72	58.61	t	t	t
2023	3	2026-03-02 18:16:30.246357	50.93	46.30	58.49	t	t	t
2026	2	2026-03-02 18:16:40.259162	39.82	77.86	45.46	t	t	t
2030	4	2026-03-02 18:16:50.267476	67.98	56.18	25.68	t	t	t
2034	3	2026-03-02 18:17:00.277246	52.14	19.82	24.09	t	t	t
2038	4	2026-03-02 18:17:10.280163	64.55	77.07	34.09	t	t	f
2040	4	2026-03-02 18:17:20.29173	48.18	75.02	67.86	t	t	t
2255	5	2026-03-02 18:26:10.686341	29.05	42.59	41.53	t	t	t
2256	2	2026-03-02 18:26:20.692233	56.21	32.84	35.23	f	t	t
2263	4	2026-03-02 18:26:30.706785	70.52	26.44	31.00	t	t	f
2266	5	2026-03-02 18:26:40.706417	28.68	79.43	58.30	t	t	t
2270	3	2026-03-02 18:26:50.71211	20.36	41.42	25.96	t	t	f
2273	3	2026-03-02 18:27:00.714247	61.21	24.63	53.31	t	t	t
2279	4	2026-03-02 18:27:10.725806	22.96	48.71	23.35	t	t	f
2282	4	2026-03-02 18:27:20.72921	37.21	13.85	47.14	t	f	t
2284	2	2026-03-02 18:27:30.747141	55.74	32.54	60.46	t	t	t
2289	5	2026-03-02 18:27:40.748886	35.42	70.84	67.29	t	t	t
2295	4	2026-03-02 18:27:50.750496	76.00	63.11	66.96	t	t	t
2297	5	2026-03-02 18:28:00.753437	41.84	30.28	61.96	t	t	t
2301	5	2026-03-02 18:28:10.765565	16.89	38.69	40.05	t	t	f
2305	5	2026-03-02 18:28:20.765261	43.57	68.06	48.17	t	t	t
2309	5	2026-03-02 18:28:30.78082	39.10	51.52	24.40	t	t	t
2312	3	2026-03-02 18:28:40.783597	57.45	77.65	62.06	t	t	f
2317	5	2026-03-02 18:28:50.798468	30.17	59.81	39.45	t	t	t
2323	4	2026-03-02 18:29:00.805834	58.97	73.96	32.01	t	t	t
2326	3	2026-03-02 18:29:10.807263	73.33	64.09	33.46	t	t	t
2330	3	2026-03-02 18:29:20.806115	19.26	44.34	25.56	t	t	t
2332	3	2026-03-02 18:29:30.8112	15.95	41.46	57.89	t	t	f
2337	5	2026-03-02 18:29:40.820364	40.47	44.64	20.52	t	t	t
2343	4	2026-03-02 18:29:50.820796	40.11	33.86	43.96	t	t	t
2344	2	2026-03-02 18:30:00.823741	37.34	42.65	25.17	t	t	t
2351	4	2026-03-02 18:30:10.833709	12.29	29.37	67.93	t	t	t
2352	2	2026-03-02 18:30:20.843118	66.63	16.22	22.96	t	t	t
2357	5	2026-03-02 18:30:30.851003	21.12	72.28	21.07	t	t	t
2363	3	2026-03-02 18:30:40.857966	16.72	22.45	39.75	t	t	t
2364	2	2026-03-02 18:30:50.866666	77.46	38.72	55.31	t	t	t
2371	5	2026-03-02 18:31:00.880162	47.89	18.01	50.04	t	t	t
2372	2	2026-03-02 18:31:10.890105	76.54	16.95	41.62	t	t	t
2377	5	2026-03-02 18:31:20.892231	11.22	70.48	37.07	t	t	t
2383	5	2026-03-02 18:31:30.906778	28.59	74.45	39.13	t	t	t
2385	2	2026-03-02 18:31:40.91375	22.61	39.58	42.25	t	t	t
564	4	2026-02-28 22:11:47.396295	23.02	39.68	50.37	t	t	t
1492	2	2026-03-02 17:54:29.185892	60.54	59.43	64.19	t	t	t
1497	5	2026-03-02 17:54:39.19389	48.34	20.89	33.69	t	t	t
1502	4	2026-03-02 17:54:49.200906	32.27	12.24	56.26	t	t	t
1506	3	2026-03-02 17:54:59.210151	14.01	71.83	49.44	t	t	t
1510	3	2026-03-02 17:55:09.217586	55.82	11.64	22.53	t	f	t
1514	5	2026-03-02 17:55:19.229459	64.23	55.18	51.27	t	f	t
1517	2	2026-03-02 17:55:29.229995	41.09	22.01	54.11	t	t	t
1521	5	2026-03-02 17:55:39.234835	40.66	31.75	20.67	t	t	t
1524	3	2026-03-02 17:55:49.243901	31.79	59.36	41.00	t	t	t
1530	3	2026-03-02 17:55:59.260276	79.20	40.34	23.00	t	t	t
1535	4	2026-03-02 17:56:09.274296	26.22	41.32	56.33	t	t	t
1536	2	2026-03-02 17:56:19.291712	46.66	48.74	50.77	t	t	t
1543	5	2026-03-02 17:56:29.294079	63.48	11.46	43.92	t	t	t
1544	2	2026-03-02 17:56:39.296901	75.94	64.64	68.95	t	t	t
1550	3	2026-03-02 17:56:49.305321	33.28	13.97	53.35	t	t	t
1554	2	2026-03-02 17:56:59.314724	20.94	55.80	50.24	t	t	t
1556	2	2026-03-02 17:57:09.307428	54.67	58.58	36.97	f	t	t
1561	5	2026-03-02 17:57:19.322265	69.23	70.14	21.10	t	f	t
1566	4	2026-03-02 17:57:29.321496	36.86	77.52	42.62	f	t	f
1570	4	2026-03-02 17:57:39.340862	58.64	13.73	55.20	t	t	t
1572	2	2026-03-02 17:57:49.33869	28.91	73.43	55.45	t	t	t
1577	5	2026-03-02 17:57:59.357852	33.20	67.15	54.53	t	t	t
1581	4	2026-03-02 17:58:09.366627	41.41	45.04	64.62	t	t	f
1584	3	2026-03-02 17:58:19.374042	16.57	47.09	54.78	t	t	t
1589	5	2026-03-02 17:58:29.374837	14.43	55.38	66.91	t	t	t
1594	3	2026-03-02 17:58:39.392911	75.53	64.93	58.15	t	t	t
1598	4	2026-03-02 17:58:49.398733	57.17	57.48	51.27	t	t	t
1602	5	2026-03-02 17:58:59.401759	33.49	12.15	56.17	t	t	t
1607	4	2026-03-02 17:59:09.406029	31.74	74.76	60.39	t	t	t
1610	3	2026-03-02 17:59:19.407989	24.69	65.95	38.16	t	t	t
1615	3	2026-03-02 17:59:29.408788	59.25	27.63	29.22	t	t	t
1616	5	2026-03-02 17:59:39.413725	47.04	25.30	43.76	t	t	t
1623	4	2026-03-02 17:59:49.422671	76.49	52.25	35.77	t	t	t
1627	4	2026-03-02 17:59:59.423782	45.04	43.35	28.77	t	t	t
1629	2	2026-03-02 18:00:09.436734	14.72	59.49	28.56	t	f	t
1635	3	2026-03-02 18:00:19.455024	20.59	24.12	30.91	t	t	t
1637	3	2026-03-02 18:00:29.459151	58.28	79.12	27.52	f	t	t
1642	4	2026-03-02 18:00:39.475106	60.14	14.83	25.36	f	t	f
1645	4	2026-03-02 18:00:49.470655	10.87	39.58	24.26	t	t	t
1650	3	2026-03-02 18:00:59.485147	61.83	44.20	62.43	t	t	t
1652	2	2026-03-02 18:01:09.48841	54.29	24.92	45.85	t	f	t
1659	5	2026-03-02 18:01:19.502837	21.47	62.71	30.86	t	f	f
1662	3	2026-03-02 18:01:29.503598	57.66	13.57	52.42	t	t	t
1666	4	2026-03-02 18:01:39.504766	62.58	69.67	25.53	t	t	t
1669	4	2026-03-02 18:01:49.515423	37.97	39.27	48.84	t	t	t
1675	4	2026-03-02 18:01:59.518562	77.47	30.89	67.04	f	t	f
1678	3	2026-03-02 18:02:09.528754	54.07	57.67	40.56	t	t	t
1680	2	2026-03-02 18:02:19.531669	48.65	63.51	55.14	t	t	t
1686	5	2026-03-02 18:02:29.538757	44.58	44.91	25.32	t	t	t
1689	2	2026-03-02 18:02:39.543802	64.09	69.69	38.30	t	t	t
1692	3	2026-03-02 18:02:49.546815	21.04	16.96	34.48	t	t	t
1697	5	2026-03-02 18:02:59.550569	52.07	10.54	62.83	t	t	t
1702	3	2026-03-02 18:03:09.564259	75.26	59.53	52.46	t	t	t
1706	4	2026-03-02 18:03:19.566332	17.08	19.83	22.67	t	t	f
1949	3	2026-03-02 18:13:30.090499	10.44	32.64	20.81	t	t	f
1955	2	2026-03-02 18:13:40.091084	31.03	68.22	49.94	t	t	f
1959	2	2026-03-02 18:13:50.111528	47.07	78.44	21.90	t	t	t
1960	2	2026-03-02 18:14:00.120167	73.74	31.62	43.02	t	t	t
1965	5	2026-03-02 18:14:10.126274	53.07	73.65	49.48	t	f	t
1969	5	2026-03-02 18:14:20.12943	34.59	74.19	24.51	t	t	t
1973	5	2026-03-02 18:14:30.140745	65.54	76.62	45.72	t	f	t
1977	5	2026-03-02 18:14:40.15071	61.08	71.85	44.19	t	t	t
1980	2	2026-03-02 18:14:50.156321	43.77	42.97	64.51	t	t	t
1985	5	2026-03-02 18:15:00.166406	17.39	65.43	42.77	t	t	t
1989	3	2026-03-02 18:15:10.167913	70.89	26.29	53.77	t	t	t
1995	4	2026-03-02 18:15:20.184196	78.26	47.49	60.52	t	t	t
1998	4	2026-03-02 18:15:30.185433	63.17	18.29	55.51	t	t	t
2000	2	2026-03-02 18:15:40.196028	34.16	65.51	58.48	t	t	t
2347	5	2026-03-02 18:30:00.855546	22.60	36.05	52.32	t	t	t
2349	2	2026-03-02 18:30:10.832957	26.34	35.97	68.77	t	t	t
2355	4	2026-03-02 18:30:20.843389	63.01	63.10	53.69	t	t	t
2358	4	2026-03-02 18:30:30.851315	58.67	61.97	27.15	t	t	t
2360	2	2026-03-02 18:30:40.85684	10.12	13.23	58.03	t	t	t
2365	5	2026-03-02 18:30:50.866876	34.89	70.00	23.49	t	t	t
2369	3	2026-03-02 18:31:00.878791	38.41	35.79	47.67	t	f	t
2373	3	2026-03-02 18:31:10.890353	54.57	66.01	52.50	t	t	t
2376	3	2026-03-02 18:31:20.891672	50.66	54.04	33.67	t	f	t
2381	4	2026-03-02 18:31:30.906324	72.88	40.79	51.84	t	t	f
2386	3	2026-03-02 18:31:40.91418	26.02	49.26	30.49	t	t	f
2391	4	2026-03-02 18:31:50.916374	55.87	52.91	36.94	t	t	t
2392	2	2026-03-02 18:32:00.919521	55.86	73.10	63.22	t	t	t
2398	3	2026-03-02 18:32:10.918683	23.95	64.11	62.95	t	t	t
2400	2	2026-03-02 18:32:20.930939	22.07	25.56	34.20	t	t	t
2405	5	2026-03-02 18:32:30.931961	39.77	66.23	66.51	t	t	t
2409	5	2026-03-02 18:32:40.93662	25.64	28.93	38.87	t	f	t
2415	4	2026-03-02 18:32:50.941165	71.40	34.63	44.96	t	f	t
2416	2	2026-03-02 18:33:00.948799	41.28	56.22	42.76	t	t	t
2421	5	2026-03-02 18:33:10.952228	10.51	77.12	57.55	t	t	t
2427	4	2026-03-02 18:33:20.964395	44.03	29.06	37.59	f	f	t
2429	3	2026-03-02 18:33:30.97235	59.02	43.94	26.39	t	t	t
2435	5	2026-03-02 18:33:40.971621	20.15	60.76	55.42	t	t	t
2436	2	2026-03-02 18:33:50.981126	17.51	15.44	32.86	t	t	t
2441	5	2026-03-02 18:34:00.998212	65.83	25.43	23.61	t	t	t
2444	2	2026-03-02 18:34:11.000567	73.81	32.23	68.77	t	t	t
2449	3	2026-03-02 18:34:21.011184	14.11	76.36	58.38	t	t	t
2454	5	2026-03-02 18:34:31.028251	30.81	29.21	63.18	t	t	t
2456	2	2026-03-02 18:34:41.037229	47.42	67.78	28.86	t	t	f
2463	5	2026-03-02 18:34:51.047585	51.46	58.77	38.41	t	t	f
2465	4	2026-03-02 18:35:01.051865	48.18	11.95	21.14	t	f	t
2469	5	2026-03-02 18:35:11.062281	77.91	72.41	20.90	t	t	t
2475	3	2026-03-02 18:35:21.062496	12.91	65.37	67.03	t	f	t
2478	3	2026-03-02 18:35:31.080887	52.55	27.39	27.94	t	t	t
2480	2	2026-03-02 18:35:41.084884	35.52	56.18	25.50	t	t	t
2486	5	2026-03-02 18:35:51.100482	50.29	67.68	42.92	t	t	t
2488	2	2026-03-02 18:36:01.111789	31.76	74.55	24.89	t	t	t
2493	5	2026-03-02 18:36:11.115924	30.31	17.84	45.56	t	t	t
566	3	2026-02-28 22:11:57.396902	77.00	75.18	68.37	t	t	t
565	4	2026-02-28 22:11:57.396615	21.37	74.26	52.98	t	t	t
567	2	2026-02-28 22:11:57.397109	52.16	58.37	36.66	t	t	t
568	2	2026-02-28 22:12:07.410024	45.08	39.24	33.99	t	t	t
569	3	2026-02-28 22:12:07.442889	34.00	67.84	35.04	t	t	t
570	4	2026-02-28 22:12:07.445582	60.56	26.53	44.13	t	t	t
571	3	2026-02-28 22:12:17.41292	63.08	28.16	52.68	t	f	t
572	2	2026-02-28 22:12:17.413205	14.36	76.83	54.46	t	t	t
573	4	2026-02-28 22:12:17.41339	13.29	35.49	52.48	t	t	t
574	2	2026-02-28 22:12:27.429671	34.23	40.00	39.70	t	t	t
575	3	2026-02-28 22:12:27.464242	23.92	62.45	59.22	t	t	t
576	4	2026-02-28 22:12:27.464643	71.65	49.87	43.13	t	t	t
577	2	2026-02-28 22:12:37.431125	21.13	68.88	35.70	t	t	t
578	4	2026-02-28 22:12:37.431404	38.28	49.04	24.05	t	f	t
579	3	2026-02-28 22:12:37.431606	71.62	31.03	57.29	t	t	t
580	2	2026-02-28 22:12:47.436245	16.22	37.24	65.56	t	t	t
581	3	2026-02-28 22:12:47.436467	37.93	35.10	57.09	t	t	t
582	4	2026-02-28 22:12:47.463528	31.62	70.22	45.37	t	t	t
583	2	2026-02-28 22:12:57.456284	56.53	63.17	43.46	t	t	t
584	4	2026-02-28 22:12:57.489449	65.08	66.42	38.76	t	t	t
585	3	2026-02-28 22:12:57.602556	66.78	69.23	21.83	t	t	t
586	2	2026-02-28 22:13:07.461251	13.61	70.85	48.15	t	t	t
587	4	2026-02-28 22:13:07.461536	43.39	63.57	68.93	t	t	t
588	3	2026-02-28 22:13:07.461721	63.22	39.59	63.81	t	t	t
589	3	2026-02-28 22:13:17.474233	15.72	43.10	34.53	t	t	f
590	2	2026-02-28 22:13:17.505985	56.11	61.63	22.35	t	t	t
591	4	2026-02-28 22:13:17.506179	42.34	21.32	34.97	t	t	t
592	2	2026-02-28 22:13:27.474887	73.11	24.02	38.21	t	t	t
593	4	2026-02-28 22:13:27.475169	45.99	61.00	27.59	t	t	t
594	3	2026-02-28 22:13:27.475373	49.39	67.64	68.28	t	t	t
595	2	2026-02-28 22:13:37.479798	46.16	69.76	55.34	t	t	t
596	4	2026-02-28 22:13:37.480107	53.65	46.75	69.01	t	t	t
597	3	2026-02-28 22:13:37.480302	64.58	66.27	31.66	t	t	t
598	2	2026-02-28 22:13:47.505717	46.53	13.32	53.27	t	t	t
599	3	2026-02-28 22:13:47.538157	59.73	40.03	28.75	t	t	t
600	4	2026-02-28 22:13:47.540216	12.90	18.10	25.31	t	t	t
601	3	2026-02-28 22:13:57.519605	45.95	39.04	60.45	t	t	f
602	2	2026-02-28 22:13:57.519801	62.13	69.42	61.76	t	t	t
603	4	2026-02-28 22:13:57.548453	20.81	59.78	36.93	t	t	t
604	3	2026-02-28 22:14:07.523578	66.33	45.61	37.64	t	t	f
605	4	2026-02-28 22:14:07.52409	10.66	74.33	30.35	t	t	t
606	2	2026-02-28 22:14:07.524367	27.72	68.85	23.83	t	t	f
607	2	2026-02-28 22:14:17.537525	35.60	14.48	60.50	t	f	t
608	4	2026-02-28 22:14:17.5729	14.72	27.72	44.49	t	t	t
609	3	2026-02-28 22:14:17.678846	34.45	66.87	42.38	t	t	t
610	2	2026-02-28 22:14:27.551585	50.44	17.07	32.34	t	t	t
611	3	2026-02-28 22:14:27.551992	24.47	13.57	44.79	t	t	t
612	4	2026-02-28 22:14:27.58464	26.57	71.67	31.18	t	t	t
613	3	2026-02-28 22:14:37.549918	75.06	59.94	30.29	t	t	f
614	4	2026-02-28 22:14:37.550223	29.34	51.26	53.99	t	t	t
615	2	2026-02-28 22:14:37.550423	41.34	74.33	50.85	t	t	t
616	2	2026-02-28 22:14:47.570109	15.58	36.05	43.72	t	t	t
617	3	2026-02-28 22:14:47.605784	39.46	76.62	58.60	t	f	t
618	4	2026-02-28 22:14:47.606308	20.94	67.33	41.89	t	t	t
619	3	2026-02-28 22:14:57.578514	17.28	63.82	27.33	f	t	t
620	2	2026-02-28 22:14:57.578705	66.11	71.90	52.77	t	f	t
621	4	2026-02-28 22:14:57.609289	10.05	67.86	29.88	t	t	t
622	2	2026-02-28 22:15:07.580915	34.70	68.21	29.67	t	t	t
623	3	2026-02-28 22:15:07.581423	18.68	59.58	67.43	t	t	f
624	4	2026-02-28 22:15:07.615686	49.01	75.82	66.48	t	t	f
625	2	2026-02-28 22:15:17.598019	70.78	44.27	45.58	t	t	t
626	3	2026-02-28 22:15:17.631376	21.26	66.70	67.37	t	t	t
627	4	2026-02-28 22:15:17.631666	21.65	28.98	58.12	t	t	t
628	2	2026-02-28 22:15:27.599953	27.18	26.00	63.35	t	t	t
629	4	2026-02-28 22:15:27.600378	51.83	53.83	57.36	t	t	t
630	3	2026-02-28 22:15:27.600597	69.14	33.89	23.27	t	t	t
631	2	2026-02-28 22:15:37.60089	53.07	60.06	60.27	t	t	t
632	3	2026-02-28 22:15:37.601327	32.82	38.99	53.65	t	t	t
633	4	2026-02-28 22:15:37.601544	55.97	32.12	62.91	t	t	t
634	2	2026-02-28 22:15:47.618888	73.24	57.14	55.71	t	t	f
635	4	2026-02-28 22:15:47.652246	14.99	57.85	67.57	t	t	t
636	3	2026-02-28 22:15:47.652728	63.18	29.40	24.43	t	t	t
637	2	2026-02-28 22:15:57.632674	64.24	31.30	29.17	t	t	t
638	3	2026-02-28 22:15:57.632982	30.39	60.89	67.95	t	t	t
639	4	2026-02-28 22:15:57.663885	19.68	51.73	30.22	t	f	t
640	2	2026-02-28 22:16:07.632445	24.25	75.20	47.33	t	f	t
641	4	2026-02-28 22:16:07.632714	22.77	73.22	20.44	t	t	t
642	3	2026-02-28 22:16:07.632899	17.97	66.78	52.02	t	t	t
643	3	2026-02-28 22:16:17.632367	15.05	64.33	60.44	t	t	t
644	4	2026-02-28 22:16:17.63219	24.75	34.97	67.22	t	t	f
645	2	2026-02-28 22:16:17.632501	42.42	51.61	35.88	t	t	t
646	2	2026-02-28 22:16:27.634928	42.80	57.14	48.72	t	t	t
647	4	2026-02-28 22:16:27.635235	55.54	59.34	57.68	t	t	t
648	3	2026-02-28 22:16:27.635431	52.82	38.04	37.60	t	t	t
649	3	2026-02-28 22:16:37.658916	72.43	64.19	40.39	t	t	t
650	2	2026-02-28 22:16:37.692374	34.67	23.21	41.47	t	t	t
651	4	2026-02-28 22:16:37.692868	58.81	56.61	64.21	t	t	t
652	2	2026-02-28 22:16:47.66486	63.81	51.62	55.34	t	t	t
653	4	2026-02-28 22:16:47.665132	65.42	65.17	46.44	t	t	t
654	3	2026-02-28 22:16:47.665509	11.54	42.71	25.62	t	t	f
655	2	2026-02-28 22:16:57.680506	18.74	17.46	38.84	t	f	t
656	3	2026-02-28 22:16:57.713819	71.32	42.50	64.66	t	t	f
657	4	2026-02-28 22:16:57.840142	20.00	54.03	27.75	t	t	t
658	2	2026-02-28 22:17:07.6792	52.41	43.09	39.76	t	t	f
659	4	2026-02-28 22:17:07.67944	39.56	59.82	68.35	t	t	t
660	3	2026-02-28 22:17:07.679623	12.74	59.77	50.93	t	t	t
661	4	2026-02-28 22:17:17.694614	79.67	50.02	37.49	t	t	t
662	2	2026-02-28 22:17:17.726847	16.97	23.73	22.21	t	t	t
663	3	2026-02-28 22:17:17.850116	23.52	66.45	45.72	t	t	t
664	2	2026-02-28 22:17:27.69557	41.89	54.27	63.41	t	t	f
665	4	2026-02-28 22:17:27.696076	32.95	38.90	67.38	t	f	t
666	3	2026-02-28 22:17:27.696497	68.15	74.26	54.41	t	t	t
667	2	2026-02-28 22:17:37.708975	78.52	71.99	66.22	t	t	t
668	4	2026-02-28 22:17:37.742078	50.08	38.23	44.00	t	t	f
669	3	2026-02-28 22:17:37.743491	13.79	77.00	69.61	t	t	t
670	2	2026-02-28 22:17:47.726194	21.72	26.69	43.90	t	t	t
671	3	2026-02-28 22:17:47.72676	73.19	62.57	56.39	t	t	t
672	4	2026-02-28 22:17:47.758978	45.14	64.01	61.13	t	t	t
673	2	2026-02-28 22:17:57.744155	72.33	38.39	24.13	t	t	t
674	3	2026-02-28 22:17:57.777186	14.07	39.31	40.08	t	t	t
675	4	2026-02-28 22:17:57.778731	23.14	43.35	49.46	t	t	t
676	2	2026-02-28 22:18:07.756009	52.85	42.58	69.76	t	t	f
677	3	2026-02-28 22:18:07.756192	54.93	79.34	61.30	t	t	t
678	4	2026-02-28 22:18:07.788793	15.03	43.32	67.49	t	t	t
679	2	2026-02-28 22:18:17.769503	77.63	61.71	63.98	t	t	t
680	3	2026-02-28 22:18:17.802873	33.58	52.44	63.76	t	t	t
681	4	2026-02-28 22:18:17.805568	46.30	23.78	25.70	t	t	t
682	2	2026-02-28 22:18:27.784048	52.03	17.17	69.76	t	t	t
683	3	2026-02-28 22:18:27.784275	61.47	73.40	44.16	t	f	t
684	4	2026-02-28 22:18:27.926894	79.87	47.59	32.78	t	t	t
685	2	2026-02-28 22:18:37.789109	44.61	22.00	61.82	t	t	t
686	4	2026-02-28 22:18:37.789477	23.08	61.30	58.41	t	t	t
687	3	2026-02-28 22:18:37.789679	40.33	14.58	35.80	t	f	f
688	3	2026-02-28 22:18:47.804996	11.18	56.56	24.89	t	t	t
689	2	2026-02-28 22:18:47.836747	17.44	24.87	60.84	t	t	t
690	4	2026-02-28 22:18:47.840162	35.11	17.59	33.28	t	t	t
691	2	2026-02-28 22:18:57.80512	60.36	12.63	25.11	t	t	t
692	4	2026-02-28 22:18:57.8054	69.19	77.17	37.90	t	t	t
693	3	2026-02-28 22:18:57.805575	75.46	44.61	69.01	t	t	t
694	2	2026-02-28 22:19:07.819304	45.25	20.22	66.88	t	t	t
695	4	2026-02-28 22:19:07.85287	72.29	28.79	59.64	t	t	t
696	3	2026-02-28 22:19:07.961982	24.39	10.02	30.10	t	t	t
697	2	2026-02-28 22:19:17.821749	47.86	20.68	55.60	t	t	t
698	3	2026-02-28 22:19:17.822097	54.29	28.44	51.93	t	t	t
699	4	2026-02-28 22:19:17.822339	79.78	69.77	25.64	t	t	t
700	2	2026-02-28 22:19:27.819322	57.62	51.69	69.75	t	t	t
701	4	2026-02-28 22:19:27.819632	45.53	24.99	64.24	t	t	t
702	3	2026-02-28 22:19:27.820005	66.25	13.08	69.48	f	t	t
703	2	2026-02-28 22:19:37.833034	22.31	61.24	58.63	t	t	t
704	4	2026-02-28 22:19:37.865095	24.74	22.56	22.31	t	t	t
705	3	2026-02-28 22:19:37.972089	60.34	15.98	61.62	f	t	t
706	2	2026-02-28 22:19:47.847917	39.90	51.01	61.93	t	t	t
707	3	2026-02-28 22:19:47.848343	17.28	23.71	25.93	t	t	t
708	4	2026-02-28 22:19:47.879497	28.93	21.32	52.19	t	t	t
709	2	2026-02-28 22:19:57.863348	78.47	15.01	47.17	t	t	t
710	3	2026-02-28 22:19:57.897503	66.88	24.76	50.14	t	t	t
711	4	2026-02-28 22:19:57.898452	72.15	72.46	51.28	t	t	f
712	2	2026-02-28 22:20:07.866757	27.23	77.30	67.39	t	t	t
713	4	2026-02-28 22:20:07.867006	28.98	69.32	56.48	t	t	t
714	3	2026-02-28 22:20:07.867206	34.50	72.45	37.59	t	t	t
715	2	2026-02-28 22:20:17.883176	76.63	30.40	47.14	t	t	t
716	3	2026-02-28 22:20:17.914589	64.45	73.92	38.56	t	t	t
717	4	2026-02-28 22:20:17.918004	17.59	16.38	69.55	t	t	t
718	2	2026-02-28 22:20:27.888939	65.60	32.05	68.88	t	f	t
719	3	2026-02-28 22:20:27.889052	33.25	10.85	44.35	t	f	t
720	4	2026-02-28 22:20:27.91723	18.58	33.14	64.18	t	t	t
721	2	2026-02-28 22:20:37.909245	65.14	12.13	60.75	t	f	f
722	3	2026-02-28 22:20:37.943513	46.76	36.52	37.67	t	t	t
723	4	2026-02-28 22:20:37.944483	39.48	48.71	62.99	t	t	t
724	2	2026-02-28 22:20:47.912463	55.38	38.88	42.63	t	t	t
725	4	2026-02-28 22:20:47.912901	29.75	28.14	58.32	t	t	t
726	3	2026-02-28 22:20:47.913132	32.95	17.12	66.40	t	t	t
727	2	2026-02-28 22:20:57.914703	17.12	10.59	20.22	t	t	t
728	4	2026-02-28 22:20:57.914895	40.05	26.63	25.46	t	t	t
729	3	2026-02-28 22:20:57.915088	68.12	44.91	53.88	t	t	t
730	3	2026-02-28 22:21:07.909103	72.30	57.70	31.34	t	t	t
731	2	2026-02-28 22:21:07.909461	63.79	15.78	37.15	t	t	t
732	4	2026-02-28 22:21:07.910628	32.40	56.11	46.06	t	t	t
733	3	2026-02-28 22:21:17.929693	47.18	41.28	20.84	t	t	t
734	2	2026-02-28 22:21:17.962544	28.11	42.24	53.95	t	t	t
735	4	2026-02-28 22:21:17.962858	45.71	13.76	51.39	t	t	t
736	3	2026-02-28 22:21:27.942879	52.89	11.19	32.71	t	t	t
737	2	2026-02-28 22:21:27.943127	73.64	45.60	47.74	t	t	f
738	4	2026-02-28 22:21:28.087463	71.00	39.40	21.49	t	t	t
739	2	2026-02-28 22:21:37.951683	36.54	24.52	45.62	t	t	f
740	3	2026-02-28 22:21:37.98812	35.38	66.92	68.43	t	t	t
741	4	2026-02-28 22:21:37.990753	79.86	42.84	57.31	t	t	t
742	3	2026-02-28 22:21:47.959908	62.41	45.21	60.29	t	t	t
743	2	2026-02-28 22:21:47.960774	35.93	24.53	69.11	t	t	f
744	4	2026-02-28 22:21:47.993781	19.73	12.45	57.48	t	t	t
745	2	2026-02-28 22:21:57.962957	35.06	48.34	34.43	t	t	t
746	4	2026-02-28 22:21:57.963256	75.40	66.84	29.30	t	t	t
747	3	2026-02-28 22:21:57.963442	26.39	79.45	29.94	t	t	t
748	2	2026-02-28 22:22:07.974675	79.91	50.83	57.96	f	t	t
749	3	2026-02-28 22:22:08.006321	31.60	19.75	55.32	t	t	t
750	4	2026-02-28 22:22:08.009124	45.88	71.80	47.49	t	t	f
751	2	2026-02-28 22:22:17.974459	62.23	48.92	48.77	t	t	t
752	4	2026-02-28 22:22:17.974715	19.58	29.17	54.21	t	t	t
753	3	2026-02-28 22:22:17.974988	42.62	58.57	68.71	t	t	t
754	2	2026-02-28 22:22:27.975928	71.34	38.46	62.13	t	f	t
755	4	2026-02-28 22:22:27.976204	49.83	20.00	39.33	t	t	t
756	3	2026-02-28 22:22:27.97639	70.63	43.47	23.93	t	t	t
757	2	2026-02-28 22:22:37.976568	70.09	73.70	46.03	t	t	t
758	3	2026-02-28 22:22:37.976812	23.19	63.38	22.86	t	f	t
759	4	2026-02-28 22:22:37.977071	25.95	66.07	25.91	t	t	t
760	2	2026-02-28 22:22:47.991645	37.48	14.08	55.02	t	t	t
761	4	2026-02-28 22:22:48.026401	19.99	36.86	28.66	t	t	f
762	3	2026-02-28 22:22:48.137786	79.51	13.55	20.32	t	t	t
763	2	2026-02-28 22:22:58.007409	64.43	46.46	50.47	t	f	t
764	3	2026-02-28 22:22:58.00774	49.60	42.97	67.50	t	t	t
765	4	2026-02-28 22:22:58.041385	37.44	71.16	29.56	t	t	f
766	2	2026-02-28 22:23:08.020838	25.13	73.76	61.85	t	f	t
767	3	2026-02-28 22:23:08.054385	75.42	59.30	66.11	t	t	f
768	4	2026-02-28 22:23:08.054699	13.57	52.67	43.65	t	t	t
769	2	2026-02-28 22:23:18.039346	33.31	10.96	44.85	t	f	t
770	3	2026-02-28 22:23:18.039564	71.81	69.31	55.06	t	t	t
771	4	2026-02-28 22:23:18.071694	36.32	64.49	41.19	t	t	t
772	2	2026-02-28 22:23:28.0525	70.64	31.22	56.52	t	t	t
773	3	2026-02-28 22:23:28.084688	17.06	36.58	64.67	t	f	t
774	4	2026-02-28 22:23:28.086589	43.67	59.25	24.36	t	t	t
775	2	2026-02-28 22:23:38.067813	57.29	76.41	69.10	t	t	t
776	3	2026-02-28 22:23:38.068444	60.71	46.73	28.95	t	t	t
777	4	2026-02-28 22:23:38.102393	64.93	28.47	39.70	t	t	f
778	2	2026-02-28 22:23:48.082873	39.51	76.28	51.79	t	t	t
779	4	2026-02-28 22:23:48.116115	50.56	37.52	38.94	t	t	t
780	3	2026-02-28 22:23:48.117989	35.69	10.67	21.27	t	t	t
781	2	2026-02-28 22:23:58.094953	57.77	53.55	20.00	t	t	t
782	3	2026-02-28 22:23:58.095505	46.91	56.00	54.56	t	t	f
783	4	2026-02-28 22:23:58.130939	51.85	67.61	20.06	f	t	t
784	2	2026-02-28 22:24:08.101561	36.60	58.36	27.24	f	t	t
785	3	2026-02-28 22:24:08.101845	58.88	58.37	50.76	t	f	t
786	4	2026-02-28 22:24:08.102041	31.35	11.27	55.79	t	t	t
787	3	2026-02-28 22:24:18.115305	32.66	15.00	52.40	t	f	t
788	2	2026-02-28 22:24:18.14618	50.64	31.04	69.56	t	f	t
789	4	2026-02-28 22:24:18.14639	33.34	54.87	57.08	t	t	t
790	2	2026-02-28 22:24:28.1152	22.49	19.07	40.08	f	t	t
791	4	2026-02-28 22:24:28.115463	79.00	70.56	53.02	t	t	t
792	3	2026-02-28 22:24:28.115639	55.26	22.92	45.56	t	t	t
793	2	2026-02-28 22:24:38.117238	76.54	49.71	69.64	t	f	t
794	4	2026-02-28 22:24:38.117495	54.91	53.69	60.10	t	t	f
795	3	2026-02-28 22:24:38.117753	46.07	20.94	50.18	t	t	t
796	2	2026-02-28 22:24:48.132043	21.29	59.41	32.15	t	t	t
797	3	2026-02-28 22:24:48.163473	56.90	29.44	27.51	t	t	f
798	4	2026-02-28 22:24:48.165585	13.63	26.79	61.28	t	t	t
799	2	2026-02-28 22:24:58.144736	25.74	65.12	44.28	t	t	t
800	3	2026-02-28 22:24:58.144997	24.51	28.65	42.14	t	t	t
801	4	2026-02-28 22:24:58.17728	79.23	47.84	22.60	t	t	t
802	2	2026-02-28 22:25:08.158667	24.70	70.14	28.05	t	t	f
803	4	2026-02-28 22:25:08.192162	74.73	38.00	26.56	t	t	t
804	3	2026-02-28 22:25:08.297401	29.12	37.91	53.10	t	t	t
805	3	2026-02-28 22:25:18.16372	66.02	50.53	25.78	t	t	t
806	2	2026-02-28 22:25:18.163916	27.74	16.78	20.27	t	t	t
807	4	2026-02-28 22:25:18.164126	37.65	34.88	21.28	t	t	t
808	2	2026-02-28 22:25:28.162317	50.97	13.41	24.33	t	t	t
809	3	2026-02-28 22:25:28.162517	48.07	76.71	22.07	t	t	t
810	4	2026-02-28 22:25:28.16269	17.63	32.23	36.32	t	t	f
811	2	2026-02-28 22:25:38.185274	35.65	47.49	34.90	t	f	t
812	4	2026-02-28 22:25:38.218635	64.69	39.04	63.03	t	f	t
813	3	2026-02-28 22:25:38.21937	10.10	76.43	41.01	t	t	t
814	3	2026-02-28 22:25:48.200214	67.91	34.28	59.00	t	t	t
815	2	2026-02-28 22:25:48.200445	22.76	42.89	26.04	t	t	f
816	4	2026-02-28 22:25:48.229332	72.90	51.47	43.27	t	t	f
817	2	2026-02-28 22:25:58.212108	25.20	64.34	54.45	t	t	t
818	3	2026-02-28 22:25:58.24371	40.44	40.85	57.23	t	t	t
819	4	2026-02-28 22:25:58.244178	64.97	33.29	45.46	t	t	t
820	2	2026-02-28 22:26:08.226014	36.91	41.26	26.75	t	t	t
821	3	2026-02-28 22:26:08.226514	63.03	79.38	63.82	t	t	t
822	4	2026-02-28 22:26:08.259456	31.96	57.15	28.88	t	t	t
823	2	2026-02-28 22:26:18.236953	12.13	61.60	51.21	t	t	t
824	3	2026-02-28 22:26:18.270804	42.04	14.94	58.42	t	t	t
825	4	2026-02-28 22:26:18.271377	61.14	38.91	30.83	t	t	t
826	2	2026-02-28 22:26:28.249887	63.76	19.81	20.64	t	f	t
827	3	2026-02-28 22:26:28.250102	78.10	61.73	54.79	f	t	t
828	4	2026-02-28 22:26:28.280841	40.11	74.06	58.90	t	t	t
829	2	2026-02-28 22:26:38.251385	76.49	50.12	39.89	t	t	t
830	4	2026-02-28 22:26:38.251574	63.85	71.16	64.70	t	t	t
831	3	2026-02-28 22:26:38.251825	52.35	71.21	49.67	t	t	t
832	2	2026-02-28 22:26:48.255081	63.65	36.89	45.69	t	t	f
833	4	2026-02-28 22:26:48.255366	37.16	54.48	55.63	t	t	t
834	3	2026-02-28 22:26:48.255547	12.98	47.55	40.82	t	t	t
835	2	2026-02-28 22:26:58.255965	50.35	68.78	43.55	t	t	t
836	4	2026-02-28 22:26:58.256235	58.66	67.25	65.49	t	t	t
837	3	2026-02-28 22:26:58.256416	21.46	38.06	38.76	t	t	t
838	2	2026-02-28 22:27:08.26877	13.38	74.18	20.32	t	t	t
839	3	2026-02-28 22:27:08.299758	41.20	50.07	47.83	t	t	t
840	4	2026-02-28 22:27:08.302373	67.96	77.77	21.04	t	t	t
841	2	2026-02-28 22:27:18.284307	45.13	68.15	29.95	t	t	t
842	3	2026-02-28 22:27:18.284486	77.51	15.34	26.86	t	f	f
843	4	2026-02-28 22:27:18.315244	66.56	26.25	64.81	t	t	t
844	2	2026-02-28 22:27:28.300739	59.59	58.11	34.94	t	t	t
845	3	2026-02-28 22:27:28.337382	47.27	38.60	35.07	t	t	f
846	4	2026-02-28 22:27:28.338536	59.98	62.24	49.29	t	t	t
847	2	2026-02-28 22:27:38.30691	77.62	58.57	38.30	t	t	t
848	4	2026-02-28 22:27:38.307201	63.63	47.84	54.61	t	t	t
849	3	2026-02-28 22:27:38.307396	56.60	80.00	57.79	t	t	t
850	2	2026-02-28 22:27:48.318087	70.30	25.12	63.07	t	t	t
851	3	2026-02-28 22:27:48.348213	76.41	72.33	23.37	t	t	t
852	4	2026-02-28 22:27:48.349064	14.91	74.27	25.38	t	t	t
853	2	2026-02-28 22:27:58.332016	79.98	78.09	66.03	t	t	t
854	3	2026-02-28 22:27:58.3323	67.77	37.61	43.48	t	t	t
855	4	2026-02-28 22:27:58.362844	30.54	51.98	58.29	t	t	t
856	2	2026-02-28 22:28:08.328239	26.45	25.13	51.48	t	f	t
857	3	2026-02-28 22:28:08.328467	18.36	39.42	62.58	t	f	t
858	4	2026-02-28 22:28:08.328455	60.13	71.19	44.50	t	t	t
859	3	2026-02-28 22:28:18.331987	60.20	48.87	37.34	t	t	t
860	4	2026-02-28 22:28:18.332146	61.33	55.48	52.38	t	t	t
861	2	2026-02-28 22:28:18.332404	14.52	68.30	67.32	t	t	t
862	2	2026-02-28 22:28:28.338792	65.51	36.20	49.06	t	t	t
863	3	2026-02-28 22:28:28.339192	15.80	37.26	61.96	t	t	t
864	4	2026-02-28 22:28:28.33928	68.60	44.26	28.14	t	t	t
865	2	2026-02-28 22:28:38.352002	63.37	51.24	46.33	t	t	t
866	3	2026-02-28 22:28:38.384648	73.25	16.40	29.37	t	f	t
867	4	2026-02-28 22:28:38.387156	41.46	70.46	51.21	t	t	t
868	2	2026-02-28 22:28:48.366226	52.98	42.97	53.62	t	t	t
869	3	2026-02-28 22:28:48.366492	39.80	58.56	67.86	t	t	t
870	4	2026-02-28 22:28:48.401835	41.34	79.79	53.95	t	t	f
871	2	2026-02-28 22:28:58.381056	28.29	76.43	35.16	t	t	t
872	3	2026-02-28 22:28:58.416941	76.72	31.30	36.38	t	t	f
873	4	2026-02-28 22:28:58.418515	63.02	24.54	29.98	t	t	t
874	2	2026-02-28 22:29:08.393078	77.91	45.52	31.75	t	t	t
875	3	2026-02-28 22:29:08.393401	14.83	58.25	60.83	t	t	t
876	4	2026-02-28 22:29:08.426085	47.49	44.34	21.24	t	t	t
877	2	2026-02-28 22:29:18.393774	51.39	17.60	44.67	t	t	t
878	4	2026-02-28 22:29:18.393955	34.08	17.82	44.55	t	f	t
879	3	2026-02-28 22:29:18.394093	10.28	75.67	48.42	t	t	f
880	2	2026-02-28 22:29:28.413082	35.28	45.19	45.97	t	t	t
881	3	2026-02-28 22:29:28.445497	36.38	23.31	24.52	t	t	t
882	4	2026-02-28 22:29:28.447659	24.66	43.51	27.74	t	t	f
883	2	2026-02-28 22:29:38.42461	29.63	70.03	36.17	t	t	f
884	3	2026-02-28 22:29:38.424553	76.39	46.18	23.21	t	f	t
885	4	2026-02-28 22:29:38.570361	74.77	24.13	54.26	t	t	t
886	2	2026-02-28 22:29:48.427797	38.70	78.48	29.43	t	f	t
1493	5	2026-03-02 17:54:29.186041	47.71	79.13	68.09	t	t	t
1499	4	2026-03-02 17:54:39.1943	62.09	56.17	49.58	t	t	t
1500	2	2026-03-02 17:54:49.200271	79.99	36.46	21.14	t	t	t
1505	5	2026-03-02 17:54:59.209907	73.71	45.42	52.08	t	t	t
1511	4	2026-03-02 17:55:09.217893	31.99	29.38	54.80	t	t	t
1512	2	2026-03-02 17:55:19.228424	36.10	33.23	40.82	t	t	t
1518	3	2026-03-02 17:55:29.23039	75.35	21.46	37.38	t	f	t
1520	2	2026-03-02 17:55:39.234372	64.96	28.59	58.68	t	t	f
1525	5	2026-03-02 17:55:49.244206	13.04	41.68	61.34	t	t	f
1529	4	2026-03-02 17:55:59.259906	41.87	20.50	40.88	t	t	f
1533	3	2026-03-02 17:56:09.273457	59.97	57.26	30.11	t	f	f
1539	3	2026-03-02 17:56:19.292457	77.35	57.48	54.30	t	t	t
1540	2	2026-03-02 17:56:29.293014	59.46	19.92	62.84	t	t	t
1545	3	2026-03-02 17:56:39.297119	58.07	14.48	38.72	t	t	t
1551	5	2026-03-02 17:56:49.305534	13.47	32.05	62.69	t	t	t
1552	3	2026-03-02 17:56:59.313884	40.76	46.74	40.98	t	t	t
1559	5	2026-03-02 17:57:09.308183	62.63	29.07	67.68	t	t	t
1563	4	2026-03-02 17:57:19.322583	17.69	64.06	24.05	t	t	f
1567	5	2026-03-02 17:57:29.321722	41.37	30.66	50.88	t	t	t
1568	2	2026-03-02 17:57:39.340383	75.41	14.71	58.22	t	t	t
1573	5	2026-03-02 17:57:49.338916	26.66	72.78	59.11	t	t	t
1578	4	2026-03-02 17:57:59.35804	50.13	44.61	59.85	t	t	t
1582	2	2026-03-02 17:58:09.366841	10.58	26.75	66.71	f	t	t
1586	4	2026-03-02 17:58:19.374603	63.46	78.03	56.95	t	t	f
1588	3	2026-03-02 17:58:29.374388	35.84	21.76	43.06	t	t	f
1593	5	2026-03-02 17:58:39.39268	67.19	68.21	23.03	t	t	t
1599	3	2026-03-02 17:58:49.399037	14.79	45.08	66.77	t	t	t
1600	3	2026-03-02 17:58:59.401102	46.75	72.70	37.19	t	t	t
1605	5	2026-03-02 17:59:09.405858	57.86	37.54	55.98	t	t	t
1608	2	2026-03-02 17:59:19.40724	64.13	55.39	21.79	t	t	f
1614	5	2026-03-02 17:59:29.408697	46.94	19.84	50.93	t	t	t
1617	2	2026-03-02 17:59:39.413598	52.95	61.68	39.56	t	t	t
1622	3	2026-03-02 17:59:49.422583	77.42	21.68	55.64	t	t	f
1624	2	2026-03-02 17:59:59.423051	30.90	42.57	67.00	t	t	t
1630	3	2026-03-02 18:00:09.437013	33.08	71.23	31.32	t	f	t
1634	4	2026-03-02 18:00:19.45467	69.07	64.77	34.89	t	t	f
1638	4	2026-03-02 18:00:29.459476	79.13	21.28	41.50	t	t	t
1641	5	2026-03-02 18:00:39.474818	47.60	56.80	28.43	t	t	f
1647	2	2026-03-02 18:00:49.471169	66.00	72.07	55.58	f	t	t
1651	4	2026-03-02 18:00:59.485403	48.63	30.84	51.96	t	t	f
1654	3	2026-03-02 18:01:09.488861	73.68	15.78	24.36	t	t	t
1657	3	2026-03-02 18:01:19.502296	10.90	20.38	50.56	f	t	t
1661	5	2026-03-02 18:01:29.503282	40.28	70.80	69.71	t	t	t
1667	3	2026-03-02 18:01:39.505108	24.83	30.17	63.52	t	t	t
1670	2	2026-03-02 18:01:49.515619	65.12	72.47	56.55	t	t	t
1672	3	2026-03-02 18:01:59.517577	29.90	33.71	35.35	t	t	t
1679	4	2026-03-02 18:02:09.529	72.60	11.66	46.80	t	t	t
1683	3	2026-03-02 18:02:19.53243	28.94	49.61	41.10	f	t	t
1685	2	2026-03-02 18:02:29.538576	39.87	29.23	63.53	t	t	t
1690	4	2026-03-02 18:02:39.544191	25.53	61.55	38.78	f	t	f
1694	2	2026-03-02 18:02:49.547423	49.21	45.11	40.73	t	t	f
1696	2	2026-03-02 18:02:59.550353	68.88	50.46	64.71	t	t	f
1701	5	2026-03-02 18:03:09.564022	66.38	41.05	41.54	t	t	t
1707	3	2026-03-02 18:03:19.566656	24.42	51.87	25.43	t	t	t
1951	4	2026-03-02 18:13:30.091022	11.16	56.75	55.67	t	t	t
1952	4	2026-03-02 18:13:40.090313	54.20	41.15	69.90	t	t	t
1957	5	2026-03-02 18:13:50.110925	11.12	57.34	38.37	t	t	f
1962	3	2026-03-02 18:14:00.120647	73.61	70.03	55.25	t	t	t
1964	2	2026-03-02 18:14:10.125875	61.89	57.54	36.94	t	t	t
1970	2	2026-03-02 18:14:20.129471	55.11	53.85	30.57	t	t	t
1975	3	2026-03-02 18:14:30.141252	50.29	51.72	37.90	t	f	t
1976	2	2026-03-02 18:14:40.150513	51.80	26.82	55.95	t	t	t
1981	5	2026-03-02 18:14:50.15673	41.27	61.86	55.76	t	f	t
1987	3	2026-03-02 18:15:00.166886	16.08	26.68	67.87	t	t	t
1990	4	2026-03-02 18:15:10.168084	16.82	37.49	37.53	t	t	f
1994	3	2026-03-02 18:15:20.183871	74.66	12.27	49.42	t	t	f
1999	3	2026-03-02 18:15:30.185795	74.01	50.45	33.70	t	t	t
2002	4	2026-03-02 18:15:40.196423	69.74	77.18	22.09	t	t	t
2004	3	2026-03-02 18:15:50.201908	41.17	60.26	54.91	t	t	t
2011	4	2026-03-02 18:16:00.216756	68.51	72.08	30.92	f	t	t
2012	2	2026-03-02 18:16:10.227161	55.32	27.66	68.58	f	t	t
2388	2	2026-03-02 18:31:50.915735	25.81	25.77	22.06	t	t	t
2395	3	2026-03-02 18:32:00.920285	19.85	49.23	57.49	t	t	t
2396	2	2026-03-02 18:32:10.918182	22.15	75.11	49.64	t	t	t
2401	5	2026-03-02 18:32:20.931492	38.55	78.75	27.90	t	t	t
2404	2	2026-03-02 18:32:30.931778	44.43	53.96	47.52	t	t	t
2410	4	2026-03-02 18:32:40.936853	64.37	19.03	34.00	t	t	f
2414	3	2026-03-02 18:32:50.940849	51.71	75.12	45.60	t	t	t
2417	4	2026-03-02 18:33:00.949422	58.10	72.55	55.30	t	t	t
2420	3	2026-03-02 18:33:10.951971	52.63	52.01	49.49	t	t	t
2425	5	2026-03-02 18:33:20.964075	26.97	29.14	46.81	t	t	t
2430	5	2026-03-02 18:33:30.972504	31.56	68.41	55.11	t	t	f
2434	4	2026-03-02 18:33:40.970652	28.56	71.22	34.09	t	t	t
2437	3	2026-03-02 18:33:50.981643	13.15	41.79	61.61	t	t	t
2440	2	2026-03-02 18:34:00.99798	78.79	38.42	20.37	t	t	t
2446	4	2026-03-02 18:34:11.000989	35.51	38.29	59.84	t	t	t
2448	2	2026-03-02 18:34:21.010921	79.70	71.69	20.65	t	t	t
2452	3	2026-03-02 18:34:31.02784	77.64	67.18	47.20	t	t	f
2457	5	2026-03-02 18:34:41.037413	68.98	70.29	30.95	t	t	t
2460	2	2026-03-02 18:34:51.04614	20.95	40.29	28.82	t	t	t
2467	5	2026-03-02 18:35:01.052364	32.20	22.81	30.70	t	t	t
2471	4	2026-03-02 18:35:11.062742	27.15	78.82	51.25	t	t	t
2474	2	2026-03-02 18:35:21.062348	48.46	53.04	48.89	t	f	t
2476	2	2026-03-02 18:35:31.080576	66.20	70.81	24.74	t	f	t
2481	5	2026-03-02 18:35:41.085051	28.30	57.89	37.63	t	t	t
2484	2	2026-03-02 18:35:51.100032	54.15	24.57	40.16	t	t	t
2489	5	2026-03-02 18:36:01.112052	51.05	46.46	54.92	t	f	t
2492	2	2026-03-02 18:36:11.115425	77.96	79.75	27.54	t	t	t
2497	5	2026-03-02 18:36:21.116742	48.32	53.01	50.04	t	t	t
2816	2	2026-03-02 18:49:41.782109	10.92	47.31	30.13	t	t	f
2823	5	2026-03-02 18:49:51.803714	16.19	71.22	32.73	t	t	f
2826	4	2026-03-02 18:50:01.815798	57.35	26.36	51.25	t	t	t
2831	4	2026-03-02 18:50:11.832157	27.16	41.64	23.40	t	t	t
2832	2	2026-03-02 18:50:21.846534	66.56	58.75	47.91	t	t	t
2914	3	2026-03-02 18:53:41.976092	68.15	17.20	55.41	t	f	t
2918	4	2026-03-02 18:53:51.977343	33.11	76.82	28.34	t	t	f
887	4	2026-02-28 22:29:48.428101	49.53	69.71	53.68	t	t	t
1494	3	2026-03-02 17:54:29.186385	58.47	14.15	26.91	t	t	t
1498	3	2026-03-02 17:54:39.194221	70.22	31.79	64.85	t	t	f
1503	3	2026-03-02 17:54:49.201112	52.08	32.40	26.48	t	t	t
1504	2	2026-03-02 17:54:59.20956	55.65	27.75	25.07	f	t	t
1509	5	2026-03-02 17:55:09.217386	14.22	48.66	47.10	t	t	t
1515	3	2026-03-02 17:55:19.229592	43.34	78.16	69.78	t	f	f
1519	4	2026-03-02 17:55:29.230614	38.86	75.10	33.28	t	t	t
1523	4	2026-03-02 17:55:39.235457	31.10	38.06	66.25	t	t	t
1526	4	2026-03-02 17:55:49.244401	61.83	74.27	43.05	t	t	f
1531	5	2026-03-02 17:55:59.260759	79.25	34.65	63.60	t	t	f
1532	2	2026-03-02 17:56:09.272828	25.02	63.43	30.90	t	t	t
1537	5	2026-03-02 17:56:19.291994	60.92	51.55	22.25	t	t	t
1541	3	2026-03-02 17:56:29.293518	24.55	43.36	33.74	t	t	t
1546	4	2026-03-02 17:56:39.297151	28.24	38.12	46.01	t	t	t
1548	2	2026-03-02 17:56:49.304886	31.84	27.10	45.40	t	t	t
1553	5	2026-03-02 17:56:59.314493	55.90	33.68	32.05	t	t	t
1557	4	2026-03-02 17:57:09.307851	18.24	22.99	41.84	t	t	t
1562	3	2026-03-02 17:57:19.322414	36.15	58.14	67.98	t	t	t
1565	2	2026-03-02 17:57:29.320842	61.52	54.13	22.79	t	t	t
1569	5	2026-03-02 17:57:39.340613	54.30	72.64	33.33	t	t	t
1575	4	2026-03-02 17:57:49.339365	31.25	18.53	59.88	t	t	t
1576	2	2026-03-02 17:57:59.357584	18.76	61.07	55.05	t	t	t
1583	5	2026-03-02 17:58:09.367197	24.07	56.68	46.75	t	t	f
1587	2	2026-03-02 17:58:19.374805	38.40	26.15	27.52	t	f	f
1591	2	2026-03-02 17:58:29.375371	60.96	57.81	34.24	f	t	t
1592	2	2026-03-02 17:58:39.392235	58.21	40.01	24.41	t	t	t
1597	5	2026-03-02 17:58:49.39854	27.86	12.73	54.71	t	t	t
1601	4	2026-03-02 17:58:59.401473	25.04	64.51	35.50	t	t	t
1606	3	2026-03-02 17:59:09.406042	40.35	57.61	68.47	t	t	t
1611	4	2026-03-02 17:59:19.408223	70.17	19.20	31.03	t	f	t
1612	2	2026-03-02 17:59:29.407714	50.96	45.36	23.19	t	f	t
1618	3	2026-03-02 17:59:39.413912	14.70	33.01	62.51	t	t	t
1620	2	2026-03-02 17:59:49.422065	50.74	67.48	36.27	t	t	t
1625	5	2026-03-02 17:59:59.423268	76.98	35.62	52.88	f	t	t
2006	2	2026-03-02 18:15:50.202018	38.62	54.45	45.82	t	t	t
2009	5	2026-03-02 18:16:00.216288	55.77	17.93	28.72	t	t	t
2013	4	2026-03-02 18:16:10.227332	38.77	13.11	23.60	t	t	t
2017	4	2026-03-02 18:16:20.236434	39.58	37.25	60.55	t	t	t
2022	4	2026-03-02 18:16:30.246047	63.01	11.08	43.50	t	t	t
2027	3	2026-03-02 18:16:40.259461	45.16	20.79	43.60	t	t	t
2028	5	2026-03-02 18:16:50.267276	13.42	72.39	44.03	t	t	t
2035	4	2026-03-02 18:17:00.277448	13.52	21.33	66.27	t	t	t
2036	3	2026-03-02 18:17:10.2787	46.13	63.65	63.78	t	t	t
2043	3	2026-03-02 18:17:20.292511	46.41	41.54	55.32	t	t	t
2046	4	2026-03-02 18:17:30.300611	38.29	79.68	35.28	t	t	t
2049	5	2026-03-02 18:17:40.300376	74.29	73.56	29.33	t	t	t
2054	2	2026-03-02 18:17:50.316248	40.11	68.38	45.87	t	t	t
2057	5	2026-03-02 18:18:00.313383	29.11	27.27	60.28	t	t	t
2060	3	2026-03-02 18:18:10.32693	31.54	79.65	48.17	t	t	t
2065	5	2026-03-02 18:18:20.330755	29.91	47.00	54.29	t	f	t
2069	5	2026-03-02 18:18:30.345011	57.10	27.42	24.17	t	t	t
2072	2	2026-03-02 18:18:40.356056	30.96	75.89	31.40	t	t	t
2076	2	2026-03-02 18:18:50.360539	52.28	15.71	55.40	t	t	t
2081	5	2026-03-02 18:19:00.373255	67.19	23.18	46.08	t	t	t
2086	3	2026-03-02 18:19:10.376921	20.91	49.20	63.13	t	t	t
2090	4	2026-03-02 18:19:20.37751	43.42	70.72	55.98	t	t	f
2094	4	2026-03-02 18:19:30.381613	63.36	30.98	41.90	t	t	t
2098	5	2026-03-02 18:19:40.382338	66.93	62.12	44.16	t	t	f
2100	2	2026-03-02 18:19:50.388928	25.93	28.95	64.34	t	t	t
2105	5	2026-03-02 18:20:00.389623	14.31	46.22	39.40	t	t	t
2110	4	2026-03-02 18:20:10.402211	61.09	54.26	57.32	t	t	t
2112	3	2026-03-02 18:20:20.417684	16.20	24.22	51.95	t	t	f
2118	5	2026-03-02 18:20:30.422767	67.37	58.93	57.99	t	t	t
2120	5	2026-03-02 18:20:40.435252	19.76	12.44	40.87	t	t	t
2125	5	2026-03-02 18:20:50.443919	27.35	36.47	43.92	t	t	f
2130	3	2026-03-02 18:21:00.454368	66.47	27.56	52.44	t	t	t
2132	2	2026-03-02 18:21:10.457107	28.81	69.91	40.27	f	f	t
2137	5	2026-03-02 18:21:20.468137	69.92	47.91	25.41	t	t	t
2141	4	2026-03-02 18:21:30.475583	16.81	77.52	41.21	t	t	t
2147	4	2026-03-02 18:21:40.482463	31.64	10.57	39.29	t	t	t
2151	3	2026-03-02 18:21:50.49859	35.58	29.60	29.78	t	t	t
2155	3	2026-03-02 18:22:00.510872	71.97	59.08	23.89	t	t	t
2156	2	2026-03-02 18:22:10.523743	54.33	23.36	61.75	t	t	t
2161	5	2026-03-02 18:22:20.52474	77.28	64.30	28.49	t	t	t
2167	3	2026-03-02 18:22:30.533012	11.87	23.42	28.15	f	t	t
2169	3	2026-03-02 18:22:40.533708	29.64	40.04	61.44	t	f	t
2173	2	2026-03-02 18:22:50.537584	28.47	44.30	26.26	t	f	f
2178	5	2026-03-02 18:23:00.554116	10.94	78.96	47.21	t	t	t
2181	5	2026-03-02 18:23:10.567571	45.49	52.21	27.23	t	f	t
2187	4	2026-03-02 18:23:20.569653	38.63	53.47	31.60	t	f	t
2190	3	2026-03-02 18:23:30.569494	42.79	52.19	39.09	t	t	t
2195	4	2026-03-02 18:23:40.577797	22.02	63.35	36.63	f	t	t
2196	3	2026-03-02 18:23:50.583008	52.77	54.43	37.00	t	t	f
2200	3	2026-03-02 18:24:00.582426	75.53	52.58	67.12	t	t	f
2205	5	2026-03-02 18:24:10.598606	59.88	56.70	48.14	t	t	t
2209	5	2026-03-02 18:24:20.614284	67.63	49.28	27.60	t	t	t
2402	3	2026-03-02 18:32:20.931701	29.46	75.73	58.95	t	t	t
2406	3	2026-03-02 18:32:30.932291	75.78	67.44	61.99	t	t	t
2411	3	2026-03-02 18:32:40.937126	60.04	66.07	69.44	t	f	t
2412	2	2026-03-02 18:32:50.940444	67.86	77.22	61.97	t	t	t
2418	5	2026-03-02 18:33:00.94952	39.33	51.73	41.41	t	t	t
2423	4	2026-03-02 18:33:10.952672	10.27	33.38	45.80	t	t	t
2424	2	2026-03-02 18:33:20.963487	31.11	73.98	34.94	t	f	t
2431	4	2026-03-02 18:33:30.972803	49.74	41.76	35.22	t	f	f
2432	2	2026-03-02 18:33:40.969644	21.30	69.75	44.20	t	t	t
2439	4	2026-03-02 18:33:50.982272	11.63	79.86	42.89	t	t	t
2443	4	2026-03-02 18:34:00.998658	23.16	62.01	51.47	t	f	f
2447	3	2026-03-02 18:34:11.001254	34.29	70.76	48.39	t	t	t
2450	4	2026-03-02 18:34:21.011808	20.51	57.43	28.49	t	t	t
2453	4	2026-03-02 18:34:31.028025	46.70	44.93	61.88	t	t	f
2459	3	2026-03-02 18:34:41.037981	39.27	72.28	57.75	t	t	t
2461	4	2026-03-02 18:34:51.046858	19.72	37.28	31.93	t	t	f
2466	3	2026-03-02 18:35:01.05207	64.72	68.60	26.60	t	f	t
2470	3	2026-03-02 18:35:11.062584	28.91	30.13	28.42	t	t	f
2472	4	2026-03-02 18:35:21.061838	71.10	50.93	41.83	f	f	t
2477	5	2026-03-02 18:35:31.080741	35.06	18.93	31.97	t	t	t
997	2	2026-02-28 22:35:58.799915	42.85	19.68	66.17	t	t	t
998	3	2026-02-28 22:35:58.831862	72.58	79.73	47.81	t	t	t
999	4	2026-02-28 22:35:58.832102	60.71	64.07	20.67	t	t	t
1000	2	2026-02-28 22:36:08.817948	70.25	77.87	36.83	t	t	f
1001	3	2026-02-28 22:36:08.818507	61.42	58.94	28.16	t	t	t
1002	4	2026-02-28 22:36:08.849392	53.99	25.77	64.17	t	t	t
1003	2	2026-02-28 22:36:18.830784	27.35	54.60	67.47	t	t	t
1004	3	2026-02-28 22:36:18.865648	41.02	21.67	50.17	t	t	t
1005	4	2026-02-28 22:36:18.866612	37.24	60.59	69.28	t	t	f
1006	2	2026-02-28 22:36:28.835656	54.83	78.05	25.84	t	f	t
1007	4	2026-02-28 22:36:28.835848	78.16	39.02	47.60	t	t	t
1008	3	2026-02-28 22:36:28.836125	30.44	59.11	20.82	t	t	t
1009	2	2026-02-28 22:36:38.851353	47.11	73.98	52.35	f	t	f
1010	3	2026-02-28 22:36:38.883893	51.84	79.67	59.24	t	t	t
1011	4	2026-02-28 22:36:38.995338	22.07	78.09	51.81	t	t	t
1012	2	2026-02-28 22:36:48.863873	34.98	29.27	56.88	t	t	t
1013	4	2026-02-28 22:36:48.864413	35.26	58.33	40.66	t	t	f
1014	3	2026-02-28 22:36:48.899308	69.19	13.32	65.57	t	t	f
1015	2	2026-02-28 22:36:58.873828	35.71	41.02	38.22	t	t	t
1016	4	2026-02-28 22:36:58.907531	16.26	54.46	33.13	f	t	t
1017	3	2026-02-28 22:36:58.907622	39.77	29.22	38.78	t	t	t
1018	2	2026-02-28 22:37:08.88516	52.06	27.11	40.50	t	t	t
1019	3	2026-02-28 22:37:08.885076	79.48	60.26	29.01	t	t	t
1020	4	2026-02-28 22:37:08.918593	33.15	13.82	60.87	t	t	t
1021	2	2026-02-28 22:37:18.895276	72.02	41.04	61.64	t	t	t
1022	3	2026-02-28 22:37:18.927849	64.83	51.77	65.32	t	f	t
1023	4	2026-02-28 22:37:18.928258	41.20	26.66	37.74	t	f	t
1024	2	2026-02-28 22:37:28.910775	74.09	54.24	52.34	t	t	t
1025	3	2026-02-28 22:37:28.911041	29.29	76.33	46.96	t	t	t
1026	4	2026-02-28 22:37:28.942775	46.39	16.83	39.28	t	t	t
1027	2	2026-02-28 22:37:38.912816	63.18	53.82	62.48	t	t	t
1028	3	2026-02-28 22:37:38.913165	58.56	35.30	21.89	t	t	t
1029	4	2026-02-28 22:37:38.91337	48.06	70.75	59.42	t	t	t
1030	2	2026-02-28 22:37:48.918682	79.37	73.31	53.23	t	t	t
1031	4	2026-02-28 22:37:48.918943	60.82	78.05	60.15	t	t	t
1032	3	2026-02-28 22:37:48.91914	14.93	14.37	52.56	t	f	t
1033	2	2026-02-28 22:37:58.919467	61.03	54.43	37.44	t	t	t
1034	3	2026-02-28 22:37:58.919692	45.09	49.73	43.78	t	t	t
1035	4	2026-02-28 22:37:58.919964	30.28	64.71	56.22	t	t	t
1036	2	2026-02-28 22:38:08.926157	28.46	64.61	57.00	t	f	f
1037	4	2026-02-28 22:38:08.960951	51.46	59.49	55.21	t	t	t
1038	3	2026-02-28 22:38:08.961196	59.96	55.62	53.86	t	f	t
1039	2	2026-02-28 22:38:18.925136	13.47	70.37	66.78	t	t	t
1040	3	2026-02-28 22:38:18.925342	36.53	21.10	41.26	t	t	t
1041	4	2026-02-28 22:38:18.925401	11.35	37.67	61.72	t	t	t
1042	2	2026-02-28 22:38:28.937949	47.77	46.42	66.04	t	t	t
1043	3	2026-02-28 22:38:28.969457	23.04	73.33	26.92	t	t	f
1044	4	2026-02-28 22:38:28.970423	10.32	39.19	58.56	t	t	t
1045	2	2026-02-28 22:38:38.948545	45.48	54.56	63.40	t	t	t
1046	3	2026-02-28 22:38:38.948721	47.40	46.95	27.61	t	t	t
1047	4	2026-02-28 22:38:38.98118	39.76	53.81	52.44	t	t	t
1048	2	2026-02-28 22:38:48.958269	65.95	66.19	32.76	f	t	t
1049	4	2026-02-28 22:38:48.958697	23.08	21.15	67.43	t	t	t
1050	3	2026-02-28 22:38:48.96252	33.43	55.44	67.13	t	t	f
1051	2	2026-02-28 22:38:58.964051	60.98	50.01	59.50	t	t	t
1052	4	2026-02-28 22:38:58.964457	47.74	14.62	44.45	t	t	t
1053	3	2026-02-28 22:38:58.964649	67.79	56.50	58.77	t	t	t
1054	3	2026-02-28 22:39:08.960484	61.04	15.62	37.84	t	t	t
1055	2	2026-02-28 22:39:08.960724	23.39	44.62	62.05	t	t	t
1056	4	2026-02-28 22:39:08.960804	16.57	52.28	62.04	t	t	t
1057	2	2026-02-28 22:39:18.973214	55.85	37.56	24.01	t	t	t
1058	3	2026-02-28 22:39:19.005041	54.61	34.58	34.03	t	t	t
1059	4	2026-02-28 22:39:19.006162	71.51	13.52	55.65	t	t	t
1060	3	2026-02-28 22:39:28.985486	66.73	51.67	23.80	t	f	f
1061	2	2026-02-28 22:39:28.986	77.41	23.22	46.27	t	f	t
1062	4	2026-02-28 22:39:29.017587	72.32	63.58	59.44	t	t	t
1063	2	2026-02-28 22:39:38.988122	24.34	49.69	53.94	t	t	t
1064	3	2026-02-28 22:39:38.988371	57.06	19.00	54.93	t	t	t
1065	4	2026-02-28 22:39:38.988624	60.36	16.10	63.46	t	t	f
1066	2	2026-02-28 22:39:49.001427	76.73	50.34	29.91	t	t	t
1067	4	2026-02-28 22:39:49.001796	35.53	53.52	34.13	t	t	t
1068	3	2026-02-28 22:39:49.002659	17.34	66.95	42.73	t	t	f
1069	2	2026-02-28 22:39:59.003117	38.32	52.37	54.93	t	t	t
1070	4	2026-02-28 22:39:59.003268	20.28	45.53	26.88	t	f	t
1071	3	2026-02-28 22:39:59.00349	62.12	38.05	31.93	t	t	t
1072	2	2026-02-28 22:40:09.014775	69.55	15.24	21.03	t	t	f
1073	3	2026-02-28 22:40:09.015274	68.03	57.97	57.83	t	t	t
1074	4	2026-02-28 22:40:09.045232	59.99	79.10	49.74	t	t	t
1075	3	2026-02-28 22:40:19.019796	44.64	75.90	50.01	t	t	t
1076	2	2026-02-28 22:40:19.020376	17.58	19.08	23.25	t	t	t
1077	4	2026-02-28 22:40:19.021932	51.16	31.91	49.04	t	t	t
1078	2	2026-02-28 22:40:29.022317	67.83	75.74	51.03	t	t	t
1079	3	2026-02-28 22:40:29.022832	73.67	60.47	26.66	t	f	f
1080	4	2026-02-28 22:40:29.023329	62.03	68.85	66.12	t	t	t
1081	3	2026-02-28 22:40:39.028997	70.40	13.26	46.05	t	t	t
1082	2	2026-02-28 22:40:39.029502	19.24	58.36	46.21	t	t	t
1083	4	2026-02-28 22:40:39.058614	45.66	75.49	51.12	t	t	t
1084	2	2026-02-28 22:40:49.038935	10.83	14.19	22.12	t	t	t
1085	3	2026-02-28 22:40:49.068783	30.24	36.71	54.57	f	t	f
1086	4	2026-02-28 22:40:49.179884	50.14	30.06	64.44	t	t	t
1087	3	2026-02-28 22:40:59.056504	11.40	43.91	20.14	t	t	t
1088	2	2026-02-28 22:40:59.056731	63.78	48.16	63.23	t	t	t
1089	4	2026-02-28 22:40:59.088113	21.11	63.21	56.16	t	t	f
1090	2	2026-02-28 22:41:09.067376	24.45	10.49	32.55	t	t	f
1091	3	2026-02-28 22:41:09.103268	75.83	78.00	24.86	t	t	t
1092	4	2026-02-28 22:41:09.107639	28.53	60.53	48.49	t	t	t
1093	3	2026-02-28 22:41:19.072198	53.94	59.63	27.04	t	t	f
1094	2	2026-02-28 22:41:19.072328	59.12	15.08	49.01	t	t	t
1095	4	2026-02-28 22:41:19.226084	51.62	45.33	64.42	t	t	t
1096	2	2026-02-28 22:41:29.081373	50.03	62.45	37.09	t	f	t
1097	3	2026-02-28 22:41:29.114343	65.19	13.75	62.74	t	t	t
1098	4	2026-02-28 22:41:29.114608	71.35	14.35	59.54	t	t	t
1099	4	2026-02-28 22:41:39.083724	74.99	46.23	28.46	t	t	t
1100	3	2026-02-28 22:41:39.084038	56.86	31.40	51.73	t	t	t
1101	2	2026-02-28 22:41:39.084202	41.69	37.72	43.14	t	t	t
1102	2	2026-02-28 22:41:49.093151	32.78	42.27	44.25	t	t	t
1103	3	2026-02-28 22:41:49.122349	35.50	28.57	59.25	t	f	t
888	3	2026-02-28 22:29:48.428384	31.59	66.80	41.95	t	t	t
889	2	2026-02-28 22:29:58.444292	14.99	27.95	45.58	t	t	t
1495	4	2026-03-02 17:54:29.18657	40.28	71.28	68.50	t	t	t
1496	2	2026-03-02 17:54:39.193292	10.74	44.57	39.50	t	t	f
1501	5	2026-03-02 17:54:49.20054	16.19	21.70	27.77	t	t	t
1507	4	2026-03-02 17:54:59.210394	67.24	21.84	42.14	t	t	t
1508	2	2026-03-02 17:55:09.217076	62.05	18.72	39.16	t	t	t
1513	4	2026-03-02 17:55:19.229265	71.40	74.19	54.10	t	t	t
1516	5	2026-03-02 17:55:29.230107	50.02	27.82	62.29	t	t	t
1522	3	2026-03-02 17:55:39.235235	14.89	68.07	37.50	t	t	t
1527	2	2026-03-02 17:55:49.244707	67.84	36.32	56.59	t	t	f
1528	2	2026-03-02 17:55:59.259515	30.48	22.70	29.19	t	t	t
1534	5	2026-03-02 17:56:09.2741	40.08	73.74	41.01	t	t	t
1538	4	2026-03-02 17:56:19.292217	16.67	50.21	44.04	t	t	f
1542	4	2026-03-02 17:56:29.293792	63.19	25.05	33.56	t	t	f
1547	5	2026-03-02 17:56:39.297068	42.91	11.00	42.56	t	t	t
1549	4	2026-03-02 17:56:49.305071	20.95	10.83	56.28	t	t	t
1555	4	2026-03-02 17:56:59.315086	55.87	51.79	68.18	t	t	t
1558	3	2026-03-02 17:57:09.307951	20.27	11.44	51.21	t	t	f
1560	2	2026-03-02 17:57:19.322035	13.52	18.44	60.94	t	t	t
1564	3	2026-03-02 17:57:29.320598	78.77	66.64	24.78	t	t	t
1571	3	2026-03-02 17:57:39.341161	53.62	30.57	40.36	t	f	f
1574	3	2026-03-02 17:57:49.339069	16.29	34.87	38.96	t	t	t
1579	3	2026-03-02 17:57:59.358249	43.34	54.99	68.65	t	t	t
1580	3	2026-03-02 17:58:09.36619	65.98	24.42	68.42	t	t	t
1585	5	2026-03-02 17:58:19.374255	72.27	47.34	51.44	t	t	t
1590	4	2026-03-02 17:58:29.375028	64.65	25.68	27.15	t	t	t
1595	4	2026-03-02 17:58:39.393246	44.45	26.52	39.12	t	t	t
1596	2	2026-03-02 17:58:49.398241	21.00	21.56	65.24	t	t	t
1603	2	2026-03-02 17:58:59.40203	32.59	55.03	38.07	f	t	t
1604	2	2026-03-02 17:59:09.405605	57.24	27.44	50.40	t	t	t
1609	5	2026-03-02 17:59:19.40776	35.17	19.19	67.05	t	f	t
1613	4	2026-03-02 17:59:29.408471	62.42	64.97	68.32	t	t	t
1619	4	2026-03-02 17:59:39.414146	20.11	51.41	61.12	t	t	t
1621	5	2026-03-02 17:59:49.422325	57.98	19.86	45.35	t	t	t
1626	3	2026-03-02 17:59:59.423533	33.00	35.41	28.88	t	t	t
1628	4	2026-03-02 18:00:09.436486	24.31	29.30	20.17	f	t	t
1633	5	2026-03-02 18:00:19.454462	24.32	66.43	54.91	t	t	t
1636	2	2026-03-02 18:00:29.458387	69.02	33.67	24.89	t	t	t
1643	3	2026-03-02 18:00:39.47546	55.65	47.66	21.54	t	t	t
1644	3	2026-03-02 18:00:49.470211	12.40	74.30	38.17	t	f	t
1649	5	2026-03-02 18:00:59.484864	30.21	28.42	30.19	t	t	t
1655	5	2026-03-02 18:01:09.489178	65.53	24.50	61.21	t	t	t
1658	4	2026-03-02 18:01:19.502566	17.33	41.86	48.96	t	t	t
1660	2	2026-03-02 18:01:29.503055	73.23	45.92	22.63	t	t	t
1665	5	2026-03-02 18:01:39.504583	73.10	18.15	62.74	t	t	t
1668	3	2026-03-02 18:01:49.515178	52.99	71.32	51.11	t	t	f
1673	5	2026-03-02 18:01:59.518009	29.94	63.15	59.77	t	t	t
1677	5	2026-03-02 18:02:09.528406	32.22	58.68	30.77	f	t	t
1682	4	2026-03-02 18:02:19.532238	66.57	57.74	64.02	t	t	t
1687	4	2026-03-02 18:02:29.539037	48.80	51.29	31.94	t	t	t
1691	5	2026-03-02 18:02:39.544366	56.40	53.58	31.21	t	t	t
1693	4	2026-03-02 18:02:49.547065	63.34	37.25	48.19	t	t	t
1699	4	2026-03-02 18:02:59.551139	12.27	43.13	67.97	t	f	t
1700	2	2026-03-02 18:03:09.563629	24.64	70.68	54.79	t	f	t
1705	5	2026-03-02 18:03:19.566149	46.56	13.50	26.40	t	t	t
2019	3	2026-03-02 18:16:20.236665	56.76	14.04	28.74	t	t	t
2020	2	2026-03-02 18:16:30.24553	56.01	74.11	21.11	t	t	t
2025	5	2026-03-02 18:16:40.258993	32.04	50.28	39.86	t	t	t
2029	3	2026-03-02 18:16:50.267398	38.98	22.42	61.11	t	t	t
2033	5	2026-03-02 18:17:00.277042	67.56	28.03	29.73	t	t	t
2037	5	2026-03-02 18:17:10.279453	73.08	22.53	43.74	t	t	t
2041	5	2026-03-02 18:17:20.291948	60.48	64.84	64.35	t	t	t
2045	5	2026-03-02 18:17:30.300584	60.48	45.78	44.56	t	t	t
2050	4	2026-03-02 18:17:40.300573	24.76	10.36	47.65	t	t	t
2053	4	2026-03-02 18:17:50.316071	58.94	72.69	57.16	t	t	t
2058	4	2026-03-02 18:18:00.313732	19.43	74.23	31.14	t	t	t
2061	4	2026-03-02 18:18:10.327229	40.41	20.41	67.35	t	t	t
2066	4	2026-03-02 18:18:20.330967	70.80	10.47	24.21	t	t	t
2071	4	2026-03-02 18:18:30.345214	43.37	12.46	65.14	t	t	t
2074	4	2026-03-02 18:18:40.356474	66.16	79.20	54.43	t	t	f
2078	3	2026-03-02 18:18:50.361029	39.33	39.44	33.53	t	t	f
2083	2	2026-03-02 18:19:00.373737	64.45	35.75	51.32	t	t	f
2087	5	2026-03-02 18:19:10.377273	24.28	10.98	43.14	t	t	t
2091	3	2026-03-02 18:19:20.377827	29.18	21.79	44.73	t	t	t
2092	2	2026-03-02 18:19:30.380956	43.13	37.51	21.45	t	t	t
2099	4	2026-03-02 18:19:40.382466	26.10	25.26	60.99	t	t	t
2102	3	2026-03-02 18:19:50.389936	26.27	57.63	65.12	t	t	f
2106	4	2026-03-02 18:20:00.389986	54.18	61.43	44.07	t	t	t
2108	3	2026-03-02 18:20:10.401405	39.51	19.41	33.80	t	t	f
2113	4	2026-03-02 18:20:20.418088	11.20	15.86	31.66	t	t	f
2119	4	2026-03-02 18:20:30.423061	33.49	49.76	48.49	t	f	t
2121	2	2026-03-02 18:20:40.435248	60.31	58.45	36.22	t	f	t
2127	4	2026-03-02 18:20:50.444321	79.72	79.54	29.09	t	t	t
2131	4	2026-03-02 18:21:00.454601	45.63	46.45	31.61	t	t	f
2133	4	2026-03-02 18:21:10.457525	56.30	49.74	55.75	t	t	t
2139	3	2026-03-02 18:21:20.468702	29.13	44.66	66.55	t	t	t
2140	2	2026-03-02 18:21:30.475054	58.57	25.45	61.02	t	t	t
2146	5	2026-03-02 18:21:40.482392	29.77	51.53	65.25	t	t	t
2149	5	2026-03-02 18:21:50.498002	78.89	78.63	51.29	t	t	f
2154	4	2026-03-02 18:22:00.510537	37.83	23.96	22.90	t	t	t
2158	5	2026-03-02 18:22:10.524346	15.75	59.38	61.45	t	t	t
2160	4	2026-03-02 18:22:20.524546	61.78	68.40	32.87	t	t	t
2165	5	2026-03-02 18:22:30.53267	58.19	23.67	65.15	f	t	t
2170	5	2026-03-02 18:22:40.533919	39.21	60.81	55.89	t	t	t
2172	5	2026-03-02 18:22:50.537367	45.99	45.50	60.39	t	t	t
2177	4	2026-03-02 18:23:00.553935	76.86	14.84	64.27	t	t	t
2180	2	2026-03-02 18:23:10.567231	79.12	63.04	36.95	t	t	t
2185	5	2026-03-02 18:23:20.569048	38.01	71.10	43.85	t	t	t
2191	4	2026-03-02 18:23:30.569793	48.87	57.92	41.83	t	t	t
2194	3	2026-03-02 18:23:40.577496	55.86	59.38	63.11	t	t	t
2198	2	2026-03-02 18:23:50.583358	10.12	21.16	23.90	t	t	t
2203	4	2026-03-02 18:24:00.583198	46.39	50.48	28.23	t	t	t
2204	3	2026-03-02 18:24:10.598179	62.72	59.21	46.67	t	t	t
2211	3	2026-03-02 18:24:20.614792	15.75	20.63	36.49	t	t	f
2422	2	2026-03-02 18:33:10.952394	73.36	33.86	65.24	t	t	t
2426	3	2026-03-02 18:33:20.964275	55.16	76.97	36.35	t	t	t
890	3	2026-02-28 22:29:58.479052	19.33	12.15	21.38	t	t	t
891	4	2026-02-28 22:29:58.482919	48.14	14.84	52.49	t	f	t
892	2	2026-02-28 22:30:08.458005	69.46	70.59	37.41	t	t	t
893	3	2026-02-28 22:30:08.493642	56.15	17.78	27.32	t	t	t
894	4	2026-02-28 22:30:08.494303	37.44	14.85	40.24	t	t	t
895	2	2026-02-28 22:30:18.4624	43.21	19.37	66.80	t	t	t
896	4	2026-02-28 22:30:18.463088	32.67	70.37	60.58	t	t	t
897	3	2026-02-28 22:30:18.463361	56.66	16.54	38.74	t	t	f
898	2	2026-02-28 22:30:28.483458	74.96	34.24	42.86	t	f	t
899	3	2026-02-28 22:30:28.515925	74.61	32.48	29.68	t	f	t
900	4	2026-02-28 22:30:28.516508	16.85	50.04	51.47	t	t	t
901	2	2026-02-28 22:30:38.490258	32.62	15.24	20.84	t	t	t
902	4	2026-02-28 22:30:38.490548	72.04	70.71	28.87	t	f	t
903	3	2026-02-28 22:30:38.490747	29.05	41.41	36.77	t	f	t
904	2	2026-02-28 22:30:48.500302	61.22	78.34	22.86	t	t	f
905	3	2026-02-28 22:30:48.532911	20.89	43.54	21.31	t	t	t
906	4	2026-02-28 22:30:48.534878	33.49	23.12	26.91	t	t	t
907	2	2026-02-28 22:30:58.508487	19.01	44.05	47.35	t	t	f
908	3	2026-02-28 22:30:58.509364	13.96	59.15	36.90	t	t	t
909	4	2026-02-28 22:30:58.542209	18.03	36.90	38.29	t	t	f
910	2	2026-02-28 22:31:08.536544	68.05	50.53	38.97	t	t	t
911	4	2026-02-28 22:31:08.56815	36.02	27.08	35.81	t	t	t
912	3	2026-02-28 22:31:08.571195	79.22	27.58	30.62	t	t	t
913	3	2026-02-28 22:31:18.540367	23.06	15.31	69.61	t	t	f
914	4	2026-02-28 22:31:18.540646	39.85	64.79	29.55	t	t	t
915	2	2026-02-28 22:31:18.540825	76.29	33.50	57.85	t	t	f
916	2	2026-02-28 22:31:28.550903	49.56	57.92	32.57	t	t	f
917	3	2026-02-28 22:31:28.582477	64.32	76.87	29.11	t	t	t
918	4	2026-02-28 22:31:28.582687	62.56	65.40	69.49	t	t	t
919	2	2026-02-28 22:31:38.567668	43.75	69.92	61.09	t	t	f
920	3	2026-02-28 22:31:38.567959	71.12	68.04	24.72	t	t	t
921	4	2026-02-28 22:31:38.599975	70.57	47.59	59.11	t	t	t
922	2	2026-02-28 22:31:48.572086	57.50	76.22	61.09	t	t	t
923	4	2026-02-28 22:31:48.572366	23.24	70.12	65.50	t	t	t
924	3	2026-02-28 22:31:48.572553	63.04	44.96	40.58	t	t	f
925	2	2026-02-28 22:31:58.582285	65.59	28.97	55.61	t	t	t
926	3	2026-02-28 22:31:58.614128	40.37	19.93	48.39	t	t	f
927	4	2026-02-28 22:31:58.614334	64.50	71.79	66.77	t	t	t
928	2	2026-02-28 22:32:08.599121	42.14	39.07	62.89	t	t	f
929	3	2026-02-28 22:32:08.599427	27.97	55.40	46.83	t	t	t
930	4	2026-02-28 22:32:08.632347	21.88	53.93	37.11	t	t	t
931	2	2026-02-28 22:32:18.60114	16.81	56.88	55.48	t	f	t
932	4	2026-02-28 22:32:18.601421	29.43	61.76	69.96	t	t	t
933	3	2026-02-28 22:32:18.601604	43.95	53.93	35.62	f	t	t
934	2	2026-02-28 22:32:28.613301	61.67	46.75	51.21	f	t	t
935	4	2026-02-28 22:32:28.646616	16.26	34.76	59.60	t	t	f
936	3	2026-02-28 22:32:28.647164	13.98	18.53	32.92	t	t	t
937	2	2026-02-28 22:32:38.629619	19.11	64.14	26.16	t	t	t
938	3	2026-02-28 22:32:38.629758	74.33	38.44	26.16	t	f	t
939	4	2026-02-28 22:32:38.659812	31.52	53.56	21.23	t	t	t
940	2	2026-02-28 22:32:48.632518	73.98	22.61	68.52	t	t	t
941	4	2026-02-28 22:32:48.63281	75.23	28.15	55.72	t	t	t
942	3	2026-02-28 22:32:48.633013	44.72	53.38	22.41	t	t	t
943	2	2026-02-28 22:32:58.628473	54.36	11.76	69.00	t	t	t
945	3	2026-02-28 22:32:58.628953	52.69	68.51	24.30	t	t	f
944	4	2026-02-28 22:32:58.629007	42.54	65.50	38.04	t	t	t
946	2	2026-02-28 22:33:08.642491	66.74	54.32	46.39	t	t	t
947	3	2026-02-28 22:33:08.674306	53.99	71.13	34.58	t	t	t
948	4	2026-02-28 22:33:08.675905	41.98	57.73	35.22	t	t	t
949	2	2026-02-28 22:33:18.660227	30.93	56.22	31.76	t	t	t
950	3	2026-02-28 22:33:18.661145	40.14	75.25	70.00	t	t	t
951	4	2026-02-28 22:33:18.692505	74.45	26.85	43.17	t	t	t
952	3	2026-02-28 22:33:28.660567	57.95	40.38	38.87	t	t	t
953	2	2026-02-28 22:33:28.660662	41.90	25.88	48.46	t	f	t
954	4	2026-02-28 22:33:28.661247	49.58	36.83	54.71	t	t	t
956	3	2026-02-28 22:33:38.655332	45.84	66.93	44.30	t	t	t
955	2	2026-02-28 22:33:38.655248	60.16	75.45	53.46	t	t	t
957	4	2026-02-28 22:33:38.655446	14.57	62.43	26.14	t	t	t
958	2	2026-02-28 22:33:48.659979	27.46	44.85	45.68	t	t	t
959	4	2026-02-28 22:33:48.69133	25.19	58.69	41.75	t	t	t
960	3	2026-02-28 22:33:48.796352	32.34	49.87	24.19	t	t	t
961	2	2026-02-28 22:33:58.677556	64.92	41.27	34.95	t	t	t
962	3	2026-02-28 22:33:58.677848	19.11	78.51	42.11	t	t	t
963	4	2026-02-28 22:33:58.704926	72.96	49.92	48.01	t	f	t
964	2	2026-02-28 22:34:08.681249	24.96	73.80	66.88	t	t	t
965	4	2026-02-28 22:34:08.681832	73.21	74.45	34.88	t	t	t
966	3	2026-02-28 22:34:08.682223	37.09	53.01	40.25	t	t	t
967	2	2026-02-28 22:34:18.696924	31.35	34.04	21.87	t	t	t
968	3	2026-02-28 22:34:18.730307	72.63	64.63	34.61	t	t	t
969	4	2026-02-28 22:34:18.732245	71.55	52.08	42.60	t	t	f
970	2	2026-02-28 22:34:28.704214	32.39	75.28	57.15	t	t	t
971	3	2026-02-28 22:34:28.704512	58.16	69.23	60.82	t	t	t
972	4	2026-02-28 22:34:28.734505	46.26	55.40	46.73	t	t	t
973	2	2026-02-28 22:34:38.709404	66.07	20.07	68.48	t	t	t
974	3	2026-02-28 22:34:38.709778	77.23	43.18	34.85	t	t	t
975	4	2026-02-28 22:34:38.846208	58.31	71.48	39.86	f	t	f
976	2	2026-02-28 22:34:48.70761	73.98	64.60	49.53	t	t	t
977	3	2026-02-28 22:34:48.708394	42.28	32.49	24.64	t	t	t
978	4	2026-02-28 22:34:48.709103	60.87	44.25	30.13	t	t	f
979	2	2026-02-28 22:34:58.714182	28.01	67.30	68.43	t	t	t
980	3	2026-02-28 22:34:58.747102	68.23	12.40	56.51	t	f	t
981	4	2026-02-28 22:34:58.747299	63.42	77.10	33.70	t	t	t
982	2	2026-02-28 22:35:08.714686	47.06	25.15	38.20	t	t	f
983	4	2026-02-28 22:35:08.715087	30.82	58.53	61.80	t	t	t
984	3	2026-02-28 22:35:08.715324	52.98	62.00	67.37	t	t	t
985	3	2026-02-28 22:35:18.723748	30.09	59.21	32.42	t	t	t
986	2	2026-02-28 22:35:18.756728	53.76	78.53	67.91	t	t	f
987	4	2026-02-28 22:35:18.75979	39.52	34.80	31.44	t	t	t
988	2	2026-02-28 22:35:28.741462	39.07	46.06	42.76	t	t	t
989	3	2026-02-28 22:35:28.741744	61.08	42.88	66.46	t	t	f
990	4	2026-02-28 22:35:28.773135	12.90	66.58	67.46	t	t	t
991	2	2026-02-28 22:35:38.771921	40.57	79.41	34.61	t	t	f
992	4	2026-02-28 22:35:38.805205	11.86	21.25	58.48	t	t	t
993	3	2026-02-28 22:35:38.807258	25.73	30.39	61.70	t	t	t
994	2	2026-02-28 22:35:48.785852	54.10	11.79	26.81	t	t	t
995	4	2026-02-28 22:35:48.785997	56.65	36.75	24.45	t	t	t
996	3	2026-02-28 22:35:48.820578	22.13	67.54	48.90	t	t	t
1104	4	2026-02-28 22:41:49.240093	15.01	78.92	24.40	t	t	t
1105	2	2026-02-28 22:41:59.103022	64.52	50.74	67.05	t	t	t
1106	3	2026-02-28 22:41:59.103364	42.47	72.03	32.50	t	t	t
1107	4	2026-02-28 22:41:59.132962	28.69	47.93	58.65	t	t	t
1108	2	2026-02-28 22:42:09.106787	10.09	28.47	36.24	t	t	t
1109	4	2026-02-28 22:42:09.107075	22.63	29.60	28.21	t	t	t
1110	3	2026-02-28 22:42:09.108087	52.64	27.60	45.45	t	f	t
1111	2	2026-02-28 22:42:19.105806	70.57	74.68	35.57	t	t	t
1112	3	2026-02-28 22:42:19.106137	67.81	77.60	23.57	t	t	f
1113	4	2026-02-28 22:42:19.106325	52.26	61.15	49.30	t	t	t
1114	2	2026-02-28 22:42:29.112615	16.77	62.19	46.14	t	t	t
1115	3	2026-02-28 22:42:29.149239	63.69	35.56	29.63	t	t	t
1116	4	2026-02-28 22:42:29.156377	40.14	77.58	58.97	t	t	f
1117	3	2026-02-28 22:42:39.1164	57.58	74.76	29.52	t	t	f
1118	4	2026-02-28 22:42:39.116621	27.56	64.82	47.63	t	t	t
1119	2	2026-02-28 22:42:39.1174	69.53	29.80	30.14	t	t	t
1120	2	2026-02-28 22:42:49.126663	77.99	68.55	23.28	t	t	t
1121	3	2026-02-28 22:42:49.159292	58.82	46.80	50.55	t	t	t
1122	4	2026-02-28 22:42:49.15949	41.11	14.98	21.04	t	f	t
1123	2	2026-02-28 22:42:59.125299	31.34	68.03	24.98	t	t	t
1124	4	2026-02-28 22:42:59.125443	67.14	62.53	23.08	t	t	t
1125	3	2026-02-28 22:42:59.125572	44.51	38.31	34.58	t	t	t
1126	2	2026-02-28 22:43:09.13501	75.51	15.23	23.70	t	t	t
1127	3	2026-02-28 22:43:09.166869	64.57	51.36	28.72	t	t	t
1128	4	2026-02-28 22:43:09.168007	48.01	39.67	37.81	t	t	t
1129	2	2026-02-28 22:43:19.144887	27.21	48.02	67.24	f	t	t
1130	3	2026-02-28 22:43:19.145538	43.69	41.19	46.07	t	t	t
1131	4	2026-02-28 22:43:19.298413	34.80	54.93	66.45	t	t	t
1132	2	2026-02-28 22:43:29.150819	63.02	19.29	33.41	t	t	t
1133	3	2026-02-28 22:43:29.183367	74.60	76.72	34.12	t	t	t
1134	4	2026-02-28 22:43:29.186458	54.94	41.44	25.68	t	t	t
1135	2	2026-02-28 22:43:39.173612	72.84	57.65	62.63	t	t	f
1136	4	2026-02-28 22:43:39.210777	22.55	27.01	33.45	t	t	t
1137	3	2026-02-28 22:43:39.326982	59.68	39.20	23.09	t	t	t
1138	2	2026-02-28 22:43:49.154669	68.90	74.34	66.20	t	t	t
1139	3	2026-02-28 22:43:49.155127	36.39	30.77	38.93	t	t	t
1140	4	2026-02-28 22:43:49.155215	22.78	65.57	31.18	t	t	t
1141	2	2026-02-28 22:44:28.32336	\N	\N	\N	\N	\N	\N
1142	3	2026-02-28 22:44:28.326576	\N	\N	\N	\N	\N	\N
1143	4	2026-02-28 22:44:28.329004	\N	\N	\N	\N	\N	\N
1146	2	2026-03-02 17:39:58.610944	74.95	47.32	39.97	t	t	t
1147	4	2026-03-02 17:39:58.611008	43.96	76.65	57.54	t	f	t
1145	3	2026-03-02 17:39:58.611253	68.27	38.79	38.07	t	t	t
1144	5	2026-03-02 17:39:58.610779	14.96	21.70	47.37	t	t	t
1148	2	2026-03-02 17:40:08.602818	13.39	64.38	47.51	t	t	t
1149	4	2026-03-02 17:40:08.602928	63.07	70.70	55.42	t	t	t
1150	3	2026-03-02 17:40:08.603131	71.84	75.16	24.09	t	t	t
1151	5	2026-03-02 17:40:08.603464	56.96	68.47	53.56	t	t	t
1152	2	2026-03-02 17:40:18.612712	25.68	65.72	66.97	t	t	f
1153	3	2026-03-02 17:40:18.612926	13.95	50.12	35.53	t	t	t
1154	5	2026-03-02 17:40:18.613843	71.36	25.80	28.87	t	f	t
1155	4	2026-03-02 17:40:18.614228	31.02	23.19	26.38	t	t	t
1156	2	2026-03-02 17:40:28.611124	64.86	11.53	43.83	t	t	t
1157	4	2026-03-02 17:40:28.611724	41.79	72.68	51.93	t	t	t
1158	5	2026-03-02 17:40:28.611959	39.42	71.54	49.89	t	t	t
1159	3	2026-03-02 17:40:28.6121	26.65	69.79	37.22	t	t	t
1160	2	2026-03-02 17:40:38.626457	51.97	58.54	30.69	t	t	t
1161	3	2026-03-02 17:40:38.62676	79.61	57.67	35.58	t	f	t
1162	4	2026-03-02 17:40:38.627157	34.83	67.83	67.75	t	f	f
1163	5	2026-03-02 17:40:38.627525	43.96	32.09	34.12	t	t	t
1164	2	2026-03-02 17:40:48.637252	10.26	70.83	40.99	f	f	t
1165	4	2026-03-02 17:40:48.637615	61.85	24.15	65.55	t	t	t
1166	3	2026-03-02 17:40:48.637888	54.57	36.22	41.92	t	t	t
1167	5	2026-03-02 17:40:48.638141	21.01	48.70	42.15	t	t	f
1168	2	2026-03-02 17:40:58.650533	67.72	57.97	27.73	t	t	f
1169	4	2026-03-02 17:40:58.650925	75.08	77.77	57.66	t	t	t
1170	3	2026-03-02 17:40:58.651401	34.12	53.37	40.49	t	t	f
1171	5	2026-03-02 17:40:58.651725	77.24	28.56	65.79	t	t	t
1172	2	2026-03-02 17:41:08.651734	67.52	22.85	20.30	t	t	t
1173	4	2026-03-02 17:41:08.651965	14.55	70.21	47.61	t	f	t
1174	3	2026-03-02 17:41:08.652321	65.55	47.60	29.57	t	t	t
1175	5	2026-03-02 17:41:08.652613	34.09	70.95	55.81	f	f	f
1176	3	2026-03-02 17:41:18.657644	71.25	74.21	43.11	t	t	t
1177	2	2026-03-02 17:41:18.657759	20.29	67.13	69.97	t	t	f
1178	5	2026-03-02 17:41:18.657613	22.48	36.19	27.33	t	t	t
1179	4	2026-03-02 17:41:18.657554	22.08	55.75	57.91	t	t	f
1180	4	2026-03-02 17:41:28.660814	65.26	14.05	67.17	t	t	f
1181	5	2026-03-02 17:41:28.661331	57.44	55.65	39.22	t	t	t
1182	2	2026-03-02 17:41:28.661371	20.40	68.21	29.95	t	t	t
1183	3	2026-03-02 17:41:28.661264	40.84	22.80	50.91	t	t	t
1184	2	2026-03-02 17:41:38.668543	72.25	50.62	40.78	t	t	t
1185	3	2026-03-02 17:41:38.668752	34.83	12.14	34.50	t	t	t
1186	5	2026-03-02 17:41:38.668908	70.52	67.34	37.54	t	t	f
1187	4	2026-03-02 17:41:38.66914	79.90	16.11	28.90	t	t	t
1188	3	2026-03-02 17:41:48.663192	18.61	64.92	62.84	t	t	t
1189	2	2026-03-02 17:41:48.663428	33.39	38.53	49.80	t	t	t
1190	4	2026-03-02 17:41:48.663578	66.18	63.02	60.24	t	t	f
1191	5	2026-03-02 17:41:48.663644	23.57	36.00	33.02	t	t	t
1192	2	2026-03-02 17:41:58.671637	62.64	39.27	56.57	t	t	t
1193	4	2026-03-02 17:41:58.67194	56.80	69.55	68.82	t	t	t
1194	5	2026-03-02 17:41:58.672068	47.27	30.81	62.74	f	f	t
1195	3	2026-03-02 17:41:58.708935	62.07	17.90	27.94	t	t	t
1196	3	2026-03-02 17:42:08.67532	13.15	49.59	38.78	t	f	t
1197	2	2026-03-02 17:42:08.675511	23.86	63.76	29.10	t	t	t
1198	4	2026-03-02 17:42:08.675597	53.24	58.83	55.69	t	t	t
1199	5	2026-03-02 17:42:08.67591	75.92	38.75	43.45	t	t	t
1200	2	2026-03-02 17:42:18.688319	18.69	77.59	61.91	t	t	t
1201	5	2026-03-02 17:42:18.688604	50.41	27.67	31.62	t	t	t
1202	3	2026-03-02 17:42:18.688637	29.10	33.49	54.18	t	t	t
1203	4	2026-03-02 17:42:18.688697	77.21	71.10	35.69	t	t	t
1204	2	2026-03-02 17:42:28.695944	20.56	15.76	61.98	t	t	t
1205	5	2026-03-02 17:42:28.696205	61.55	28.94	64.18	t	t	t
1206	3	2026-03-02 17:42:28.696279	45.62	40.13	54.18	t	t	t
1207	4	2026-03-02 17:42:28.697033	74.38	47.47	23.81	t	t	t
1208	3	2026-03-02 17:42:38.69609	68.68	72.67	59.56	t	t	f
1209	5	2026-03-02 17:42:38.696121	41.51	43.03	20.15	t	f	t
1210	2	2026-03-02 17:42:38.696238	41.30	78.81	38.66	t	t	t
1211	4	2026-03-02 17:42:38.696452	22.07	40.55	55.59	t	t	t
1212	2	2026-03-02 17:42:48.696707	60.04	50.91	56.24	t	t	t
1217	5	2026-03-02 17:42:58.700398	73.25	32.65	37.94	t	t	t
1223	4	2026-03-02 17:43:08.700641	41.32	20.36	68.71	t	t	t
1226	4	2026-03-02 17:43:18.707558	78.09	10.53	27.97	t	t	t
1631	5	2026-03-02 18:00:09.437335	33.21	47.83	48.28	t	t	t
1632	2	2026-03-02 18:00:19.453989	68.95	18.56	34.02	t	f	t
1639	5	2026-03-02 18:00:29.459735	10.93	46.41	48.97	t	t	t
1640	2	2026-03-02 18:00:39.47445	12.45	76.38	46.05	t	t	t
1646	5	2026-03-02 18:00:49.470872	21.37	40.73	33.15	t	t	t
1648	2	2026-03-02 18:00:59.484579	79.01	47.41	33.72	t	f	t
1653	4	2026-03-02 18:01:09.488611	43.09	44.37	52.29	t	t	t
1656	2	2026-03-02 18:01:19.501994	58.49	48.10	67.83	t	t	t
1663	4	2026-03-02 18:01:29.50387	22.97	48.29	67.99	t	t	t
1664	2	2026-03-02 18:01:39.504318	25.51	21.82	46.44	t	t	f
1671	5	2026-03-02 18:01:49.515961	72.18	73.56	65.37	t	t	t
1674	2	2026-03-02 18:01:59.518211	26.97	14.34	41.58	t	t	f
1676	2	2026-03-02 18:02:09.528272	32.40	44.66	55.02	t	t	t
1681	5	2026-03-02 18:02:19.531886	21.07	44.58	35.60	t	t	t
1684	3	2026-03-02 18:02:29.538153	40.58	74.65	60.37	t	t	t
1688	3	2026-03-02 18:02:39.543505	32.67	23.88	24.40	t	t	f
1695	5	2026-03-02 18:02:49.547689	59.80	66.18	47.31	t	t	t
1698	3	2026-03-02 18:02:59.550881	60.43	55.55	69.14	t	t	t
1703	4	2026-03-02 18:03:09.564585	51.20	14.79	58.24	t	t	t
1704	2	2026-03-02 18:03:19.565847	17.68	63.15	28.68	t	t	t
2031	2	2026-03-02 18:16:50.267154	58.76	20.90	29.19	t	t	t
2032	2	2026-03-02 18:17:00.276683	17.62	25.73	69.35	t	t	t
2428	2	2026-03-02 18:33:30.972113	23.76	75.86	22.15	t	t	f
2433	3	2026-03-02 18:33:40.969765	30.62	18.12	62.51	t	t	t
2438	5	2026-03-02 18:33:50.981847	55.19	33.98	33.20	t	t	t
2442	3	2026-03-02 18:34:00.998372	31.99	66.53	39.47	f	t	t
2445	5	2026-03-02 18:34:11.000824	65.03	31.74	20.05	t	t	t
2451	5	2026-03-02 18:34:21.012848	46.92	36.13	21.03	t	t	t
2455	2	2026-03-02 18:34:31.028309	42.85	56.30	57.32	t	t	t
2458	4	2026-03-02 18:34:41.037669	20.45	75.96	62.16	t	t	t
2462	3	2026-03-02 18:34:51.047134	32.91	45.64	28.33	t	t	t
2464	2	2026-03-02 18:35:01.05154	18.55	32.65	22.56	t	t	t
2468	2	2026-03-02 18:35:11.062099	59.70	48.76	39.33	t	t	t
2473	5	2026-03-02 18:35:21.062021	35.63	18.30	57.19	t	t	t
2479	4	2026-03-02 18:35:31.08117	21.54	18.18	37.77	t	t	t
2483	3	2026-03-02 18:35:41.085634	12.18	76.05	41.50	t	f	t
2485	4	2026-03-02 18:35:51.100393	59.83	13.73	68.05	t	t	f
2490	3	2026-03-02 18:36:01.112215	49.98	64.64	37.79	t	t	t
2494	3	2026-03-02 18:36:11.116158	57.97	37.07	58.53	f	t	t
2496	3	2026-03-02 18:36:21.116043	36.98	60.54	22.90	t	t	t
2836	2	2026-03-02 18:50:31.840052	21.56	46.69	21.82	t	t	t
2841	5	2026-03-02 18:50:41.849699	33.55	22.77	29.00	t	t	t
2847	3	2026-03-02 18:50:51.850581	30.32	17.32	30.46	t	t	t
2849	5	2026-03-02 18:51:01.850064	22.36	15.46	36.96	t	f	t
2855	5	2026-03-02 18:51:11.863676	48.18	38.95	64.67	t	t	t
2859	4	2026-03-02 18:51:21.873356	17.34	65.37	30.38	t	t	t
2860	2	2026-03-02 18:51:31.884021	33.52	24.90	26.26	t	t	t
2865	5	2026-03-02 18:51:41.893443	56.27	13.69	68.64	t	t	t
2869	3	2026-03-02 18:51:51.902608	35.20	32.57	33.11	t	t	t
2875	2	2026-03-02 18:52:01.910913	32.29	18.78	31.12	t	t	t
2876	5	2026-03-02 18:52:11.915466	16.78	23.37	40.08	t	t	t
2881	5	2026-03-02 18:52:21.928811	57.16	23.15	44.45	t	t	t
2885	5	2026-03-02 18:52:31.935467	68.72	58.95	27.56	t	f	t
2890	3	2026-03-02 18:52:41.947821	19.80	41.26	40.21	f	f	t
2894	3	2026-03-02 18:52:51.94935	46.07	52.26	28.98	t	t	t
2899	3	2026-03-02 18:53:01.951809	60.89	46.97	20.31	t	t	t
2900	2	2026-03-02 18:53:11.962707	23.62	67.89	21.07	t	t	f
2905	5	2026-03-02 18:53:21.969795	60.56	44.93	67.67	t	t	f
2910	3	2026-03-02 18:53:31.975481	18.15	52.96	66.09	t	t	t
2915	5	2026-03-02 18:53:41.976459	33.68	30.70	51.65	t	t	t
2919	2	2026-03-02 18:53:51.977565	34.14	60.71	23.92	f	t	t
2920	2	2026-03-02 18:54:01.977925	38.14	68.76	37.19	t	f	t
2921	5	2026-03-02 18:54:01.978099	54.44	53.22	24.80	t	t	t
2925	5	2026-03-02 18:54:11.9936	69.60	29.47	26.53	t	t	t
2926	4	2026-03-02 18:54:11.993899	44.51	78.72	26.97	t	t	t
2928	2	2026-03-02 18:54:22.006984	58.00	61.19	26.42	t	t	t
2929	5	2026-03-02 18:54:22.007154	36.01	15.99	67.93	t	t	t
2932	2	2026-03-02 18:54:32.011601	63.91	29.95	24.52	t	t	t
2933	5	2026-03-02 18:54:32.011763	51.88	22.26	21.93	t	t	f
2937	5	2026-03-02 18:54:42.025618	63.44	47.33	44.39	t	t	t
2938	4	2026-03-02 18:54:42.025953	36.03	10.98	30.00	t	t	t
2942	3	2026-03-02 18:54:52.025978	43.74	54.16	49.66	t	t	t
2943	2	2026-03-02 18:54:52.026239	36.18	22.49	41.36	t	t	t
2944	2	2026-03-02 18:55:02.039119	19.46	72.49	31.43	t	t	t
2946	3	2026-03-02 18:55:02.039557	18.54	34.73	55.90	t	t	t
2950	4	2026-03-02 18:55:12.043441	69.33	53.34	63.41	t	t	t
2951	5	2026-03-02 18:55:12.044468	58.05	41.59	54.63	t	t	f
2953	5	2026-03-02 18:55:22.055579	58.40	32.87	57.41	t	t	f
2955	4	2026-03-02 18:55:22.055993	62.08	58.20	25.17	t	t	t
2956	4	2026-03-02 18:55:32.058777	47.11	36.11	22.30	t	t	t
2959	3	2026-03-02 18:55:32.059482	78.17	23.29	31.76	t	t	t
2960	2	2026-03-02 18:55:42.069478	24.93	37.38	67.34	t	t	t
2963	4	2026-03-02 18:55:42.070379	28.56	55.17	61.19	t	t	f
2965	4	2026-03-02 18:55:52.071743	71.54	27.51	46.65	t	t	t
2967	5	2026-03-02 18:55:52.072252	12.15	43.28	41.36	t	t	t
2969	5	2026-03-02 18:56:02.089429	50.61	32.64	46.62	t	t	t
2970	4	2026-03-02 18:56:02.089423	29.22	21.10	39.23	t	t	t
2972	3	2026-03-02 18:56:12.101586	73.10	68.59	42.98	t	t	t
2974	5	2026-03-02 18:56:12.102156	65.89	38.51	47.99	t	t	t
2977	3	2026-03-02 18:56:22.116514	27.34	47.01	41.55	t	t	t
2979	5	2026-03-02 18:56:22.116832	39.12	31.73	24.52	t	t	t
2980	2	2026-03-02 18:56:32.116971	47.64	34.05	55.67	t	t	t
2981	3	2026-03-02 18:56:32.117214	30.09	47.60	65.00	t	t	t
2984	3	2026-03-02 18:56:42.120182	41.43	71.55	46.66	t	t	t
2986	2	2026-03-02 18:56:42.120678	47.50	11.03	58.25	f	t	t
2989	5	2026-03-02 18:56:52.139165	65.72	26.61	39.72	t	t	f
2991	4	2026-03-02 18:56:52.13961	74.26	22.01	67.30	t	t	t
2993	5	2026-03-02 18:57:02.138176	78.99	14.25	47.36	t	f	t
2994	2	2026-03-02 18:57:02.138329	25.64	61.70	60.24	t	t	t
2995	3	2026-03-02 18:57:02.138615	44.97	77.34	31.69	t	t	t
2996	2	2026-03-02 18:57:12.152635	49.13	52.56	40.45	t	t	t
2997	5	2026-03-02 18:57:12.152775	74.89	48.20	48.23	t	t	t
2998	4	2026-03-02 18:57:12.153127	23.88	59.80	67.25	t	t	t
1213	3	2026-03-02 17:42:48.697056	20.18	20.25	40.54	t	t	t
1218	3	2026-03-02 17:42:58.700601	53.58	28.55	61.52	t	t	t
1222	2	2026-03-02 17:43:08.700598	75.20	12.72	49.82	t	t	t
1225	2	2026-03-02 17:43:18.707309	29.04	25.13	69.27	t	t	t
1708	3	2026-03-02 18:03:29.578261	55.12	73.40	69.24	t	t	t
1714	4	2026-03-02 18:03:39.581541	57.01	30.05	45.23	t	t	t
1719	4	2026-03-02 18:03:49.590227	12.75	55.19	67.61	t	t	t
1720	2	2026-03-02 18:03:59.608168	69.49	71.24	24.09	t	t	t
1725	4	2026-03-02 18:04:09.61167	58.14	76.62	34.00	t	t	t
1729	3	2026-03-02 18:04:19.612825	37.41	75.31	62.10	f	t	t
1735	4	2026-03-02 18:04:29.618766	19.92	23.68	43.97	t	f	t
1738	2	2026-03-02 18:04:39.61817	63.82	42.11	29.26	t	t	t
1742	2	2026-03-02 18:04:49.629615	65.26	33.85	69.29	t	t	f
1747	3	2026-03-02 18:04:59.646448	33.80	40.18	47.20	t	t	t
1749	5	2026-03-02 18:05:09.644371	66.08	29.55	35.20	t	t	t
1754	4	2026-03-02 18:05:19.649178	73.06	50.20	63.30	t	t	f
1759	3	2026-03-02 18:05:29.663882	22.50	21.53	32.83	t	t	t
1762	4	2026-03-02 18:05:39.669425	45.68	48.85	46.40	t	t	t
1766	3	2026-03-02 18:05:49.684761	23.15	76.67	57.42	t	t	t
1769	5	2026-03-02 18:05:59.681722	58.12	68.33	38.95	t	f	t
1774	4	2026-03-02 18:06:09.682964	42.06	39.26	50.17	t	t	t
1776	2	2026-03-02 18:06:19.686393	35.69	74.82	33.52	t	t	t
1782	5	2026-03-02 18:06:29.700595	47.64	55.59	63.16	t	t	t
1785	3	2026-03-02 18:06:39.706477	79.39	50.51	63.02	t	t	t
1788	3	2026-03-02 18:06:49.716244	60.05	26.12	47.63	t	f	t
1795	4	2026-03-02 18:06:59.727045	22.35	45.21	22.72	t	t	t
1798	4	2026-03-02 18:07:09.730786	24.63	70.45	35.79	t	t	f
1803	3	2026-03-02 18:07:19.73833	27.42	67.48	27.28	t	t	t
1807	4	2026-03-02 18:07:29.744609	45.59	59.79	46.21	t	t	t
1811	3	2026-03-02 18:07:39.755579	56.36	30.83	63.68	f	t	t
1812	2	2026-03-02 18:07:49.752484	63.11	57.20	62.58	t	t	t
1817	5	2026-03-02 18:07:59.767022	26.88	51.82	22.42	t	t	t
1823	4	2026-03-02 18:08:09.76511	64.38	79.40	65.69	t	t	t
1824	2	2026-03-02 18:08:19.775859	78.99	31.83	67.09	t	t	t
1830	5	2026-03-02 18:08:29.807804	16.69	44.41	28.52	t	t	t
1833	5	2026-03-02 18:08:39.801333	21.44	66.40	59.41	t	t	t
1836	2	2026-03-02 18:08:49.817478	70.40	48.17	28.70	t	t	t
1841	5	2026-03-02 18:08:59.83412	52.69	17.87	68.85	t	t	t
1847	3	2026-03-02 18:09:09.849364	75.42	64.20	24.31	t	t	t
1848	2	2026-03-02 18:09:19.857102	74.92	18.78	33.29	f	t	t
1853	5	2026-03-02 18:09:29.86551	48.50	41.81	39.41	t	t	t
1858	2	2026-03-02 18:09:39.862647	54.12	67.40	67.22	f	t	t
1862	4	2026-03-02 18:09:49.872868	14.96	61.32	33.61	t	t	t
1866	4	2026-03-02 18:09:59.884425	53.12	56.38	57.15	t	t	t
1869	3	2026-03-02 18:10:09.898717	79.56	10.18	32.48	t	t	t
1873	5	2026-03-02 18:10:19.908833	29.65	74.94	36.93	f	t	t
1878	4	2026-03-02 18:10:29.91586	33.05	48.98	22.00	t	t	f
1882	3	2026-03-02 18:10:39.918321	66.64	18.01	62.16	t	t	t
1886	3	2026-03-02 18:10:49.930081	12.68	78.40	29.54	t	t	t
1888	2	2026-03-02 18:10:59.942556	30.16	40.94	22.84	t	t	t
1895	3	2026-03-02 18:11:09.956368	11.34	52.86	46.97	t	t	t
1898	4	2026-03-02 18:11:19.969056	75.93	46.40	27.54	t	t	t
1902	2	2026-03-02 18:11:29.980184	40.67	71.62	26.78	t	t	t
1905	5	2026-03-02 18:11:39.979088	21.88	52.77	65.01	t	t	t
1909	3	2026-03-02 18:11:49.985155	42.38	14.60	52.31	t	t	t
2039	2	2026-03-02 18:17:10.279843	65.99	77.32	31.14	t	t	t
2042	2	2026-03-02 18:17:20.292182	48.05	69.09	34.17	t	t	f
2044	3	2026-03-02 18:17:30.299734	66.38	45.65	46.75	t	t	t
2048	3	2026-03-02 18:17:40.29997	51.10	72.09	63.29	t	t	t
2052	3	2026-03-02 18:17:50.315751	77.00	68.04	33.42	t	t	t
2056	3	2026-03-02 18:18:00.313179	26.01	50.07	49.25	t	t	t
2063	5	2026-03-02 18:18:10.327707	47.59	21.45	46.16	t	t	t
2067	2	2026-03-02 18:18:20.331311	71.67	73.26	31.18	t	t	t
2068	2	2026-03-02 18:18:30.344794	24.12	56.21	55.07	t	t	t
2073	5	2026-03-02 18:18:40.356287	17.53	79.29	29.60	f	t	t
2077	5	2026-03-02 18:18:50.360838	30.19	76.67	60.91	t	t	t
2080	3	2026-03-02 18:19:00.373006	24.04	26.97	69.54	t	t	t
2085	4	2026-03-02 18:19:10.376719	62.73	58.37	31.05	t	t	t
2088	2	2026-03-02 18:19:20.377077	48.01	45.68	53.73	t	t	t
2093	5	2026-03-02 18:19:30.381347	35.30	12.20	53.54	t	t	t
2096	2	2026-03-02 18:19:40.38132	20.85	53.17	59.71	t	t	t
2103	5	2026-03-02 18:19:50.390227	13.38	64.68	58.51	t	t	t
2104	2	2026-03-02 18:20:00.388993	10.81	41.12	61.55	t	t	t
2111	5	2026-03-02 18:20:10.402466	37.29	74.88	44.57	t	t	t
2114	5	2026-03-02 18:20:20.418268	50.57	77.94	43.66	t	t	t
2117	3	2026-03-02 18:20:30.422545	63.24	68.93	25.61	t	t	t
2122	3	2026-03-02 18:20:40.435777	44.03	63.64	64.68	t	t	t
2126	3	2026-03-02 18:20:50.444086	13.54	28.55	31.76	t	t	t
2129	2	2026-03-02 18:21:00.453978	12.73	25.16	45.15	t	t	t
2135	5	2026-03-02 18:21:10.458042	19.60	20.89	49.31	t	t	t
2136	2	2026-03-02 18:21:20.467929	76.82	40.95	60.10	t	t	t
2142	5	2026-03-02 18:21:30.475425	62.74	60.32	50.64	t	t	f
2144	2	2026-03-02 18:21:40.482196	37.25	49.49	63.64	t	t	t
2150	4	2026-03-02 18:21:50.498242	25.55	43.43	62.64	t	t	t
2152	2	2026-03-02 18:22:00.510068	76.60	42.12	59.51	t	t	f
2159	4	2026-03-02 18:22:10.52473	43.84	10.54	69.15	t	t	t
2163	2	2026-03-02 18:22:20.525208	44.20	63.48	43.86	t	t	t
2166	4	2026-03-02 18:22:30.533185	72.98	60.38	54.49	t	t	t
2168	2	2026-03-02 18:22:40.532701	59.89	46.86	25.79	t	f	t
2175	3	2026-03-02 18:22:50.538103	52.01	72.70	37.35	t	t	t
2176	2	2026-03-02 18:23:00.55367	62.88	66.70	30.35	t	t	f
2182	3	2026-03-02 18:23:10.567891	77.85	15.67	53.18	t	t	t
2186	3	2026-03-02 18:23:20.569282	34.67	53.39	58.14	t	t	t
2188	2	2026-03-02 18:23:30.569141	40.02	65.80	63.89	f	t	t
2193	5	2026-03-02 18:23:40.577239	12.41	57.09	47.73	t	t	f
2199	4	2026-03-02 18:23:50.583646	46.08	68.27	33.35	t	t	f
2202	2	2026-03-02 18:24:00.582893	26.75	66.81	36.40	t	f	t
2206	2	2026-03-02 18:24:10.598972	40.05	33.22	65.22	t	t	t
2210	4	2026-03-02 18:24:20.614626	66.79	32.67	59.22	t	t	f
2482	4	2026-03-02 18:35:41.0853	48.19	38.66	42.46	t	f	t
2487	3	2026-03-02 18:35:51.100639	10.15	42.33	53.11	t	t	t
2491	4	2026-03-02 18:36:01.112509	41.97	28.44	56.14	t	t	t
2495	4	2026-03-02 18:36:11.116454	78.11	19.56	33.04	t	t	t
2498	4	2026-03-02 18:36:21.11693	75.52	44.06	60.06	t	t	f
2837	4	2026-03-02 18:50:31.840394	32.51	71.92	42.78	t	t	t
2842	3	2026-03-02 18:50:41.84995	66.55	38.94	63.29	t	t	t
2846	5	2026-03-02 18:50:51.850513	44.87	59.54	40.40	t	t	t
1214	5	2026-03-02 17:42:48.697109	53.54	24.06	57.81	t	t	t
1219	4	2026-03-02 17:42:58.70074	53.96	62.51	56.21	t	t	t
1220	3	2026-03-02 17:43:08.700101	69.79	66.05	35.32	t	t	t
1224	5	2026-03-02 17:43:18.707269	11.32	56.46	55.13	t	t	t
1709	5	2026-03-02 18:03:29.57872	31.11	79.43	20.76	t	t	t
1712	2	2026-03-02 18:03:39.581099	40.81	34.90	51.84	t	t	t
1717	5	2026-03-02 18:03:49.59002	24.18	65.71	62.58	t	t	t
1722	4	2026-03-02 18:03:59.608601	35.78	39.83	52.45	t	t	t
1726	5	2026-03-02 18:04:09.611832	26.53	32.95	21.13	t	t	t
1728	2	2026-03-02 18:04:19.612352	10.80	13.35	33.61	t	t	f
1733	5	2026-03-02 18:04:29.618362	25.97	72.82	42.31	t	t	f
1739	4	2026-03-02 18:04:39.618246	37.97	63.13	69.31	t	t	t
1741	4	2026-03-02 18:04:49.629345	30.28	32.41	45.24	f	f	t
1744	2	2026-03-02 18:04:59.645027	22.71	70.02	45.07	f	t	t
1748	4	2026-03-02 18:05:09.644179	23.11	11.64	39.92	t	t	t
1752	2	2026-03-02 18:05:19.648655	14.29	15.87	45.20	t	t	t
1758	5	2026-03-02 18:05:29.663845	10.56	42.41	20.98	t	t	t
1760	3	2026-03-02 18:05:39.668276	33.59	73.35	59.61	t	t	f
1765	5	2026-03-02 18:05:49.684599	56.08	55.78	69.27	t	t	t
1770	4	2026-03-02 18:05:59.68187	78.26	62.48	30.50	t	t	t
1772	3	2026-03-02 18:06:09.682366	28.40	19.44	47.90	t	t	f
1777	5	2026-03-02 18:06:19.686668	48.80	78.23	42.28	t	t	f
1783	4	2026-03-02 18:06:29.70089	61.66	47.08	69.14	t	t	t
1784	2	2026-03-02 18:06:39.706234	60.25	53.19	43.74	t	t	t
1790	4	2026-03-02 18:06:49.716715	28.30	63.09	40.97	t	t	t
1793	5	2026-03-02 18:06:59.726514	10.55	67.25	50.29	t	t	t
1799	3	2026-03-02 18:07:09.731077	72.71	71.77	46.77	t	t	t
1800	2	2026-03-02 18:07:19.737508	14.61	62.43	20.81	t	t	t
1805	5	2026-03-02 18:07:29.744124	28.97	69.96	33.65	t	t	t
1810	4	2026-03-02 18:07:39.755309	37.12	72.96	64.12	f	t	t
1813	5	2026-03-02 18:07:49.75265	40.10	65.12	41.09	t	t	t
1816	2	2026-03-02 18:07:59.766775	79.36	66.07	66.11	t	t	t
1821	5	2026-03-02 18:08:09.764544	52.06	25.99	30.32	t	t	t
1826	3	2026-03-02 18:08:19.776328	21.29	29.08	22.13	t	f	f
1831	4	2026-03-02 18:08:29.808058	66.24	44.82	34.66	t	t	t
1835	4	2026-03-02 18:08:39.801904	66.64	74.52	28.56	t	t	t
1838	4	2026-03-02 18:08:49.817949	17.20	23.42	62.97	t	t	t
1843	4	2026-03-02 18:08:59.834441	38.33	35.41	34.08	t	t	t
1846	4	2026-03-02 18:09:09.849072	29.04	52.44	38.20	t	t	t
1849	4	2026-03-02 18:09:19.857227	26.14	77.58	49.22	t	t	t
1855	4	2026-03-02 18:09:29.866319	50.69	55.17	32.99	t	t	t
1856	3	2026-03-02 18:09:39.862036	68.53	51.59	21.25	t	t	t
1863	5	2026-03-02 18:09:49.873543	20.86	56.66	28.66	t	f	t
1864	2	2026-03-02 18:09:59.88402	64.26	58.35	42.05	t	t	t
1871	5	2026-03-02 18:10:09.899127	26.34	13.05	50.16	t	f	t
1874	4	2026-03-02 18:10:19.909078	10.56	24.60	47.65	t	t	t
1876	2	2026-03-02 18:10:29.914889	19.95	78.54	36.26	t	t	t
1883	4	2026-03-02 18:10:39.918523	29.97	36.37	49.07	t	t	t
1884	2	2026-03-02 18:10:49.929703	32.28	67.90	52.23	t	t	t
2047	2	2026-03-02 18:17:30.300346	52.65	73.86	59.41	t	f	t
2051	2	2026-03-02 18:17:40.300926	44.28	33.77	56.47	f	t	t
2055	5	2026-03-02 18:17:50.316442	65.19	22.81	22.06	t	t	t
2059	2	2026-03-02 18:18:00.313901	70.63	37.30	66.61	f	t	t
2062	2	2026-03-02 18:18:10.327418	41.15	70.74	59.84	t	t	t
2064	3	2026-03-02 18:18:20.330351	62.04	45.86	39.05	t	t	t
2070	3	2026-03-02 18:18:30.345368	24.61	56.85	43.23	t	t	t
2075	3	2026-03-02 18:18:40.356802	11.64	36.02	27.59	t	t	t
2079	4	2026-03-02 18:18:50.36119	33.67	69.90	64.79	t	t	t
2082	4	2026-03-02 18:19:00.373434	38.93	29.05	21.47	f	t	t
2084	2	2026-03-02 18:19:10.376279	45.86	24.00	32.83	t	t	t
2089	5	2026-03-02 18:19:20.37734	37.51	52.72	36.89	t	t	t
2095	3	2026-03-02 18:19:30.38193	56.87	79.90	56.67	f	f	t
2097	3	2026-03-02 18:19:40.382113	56.71	26.82	52.78	t	t	t
2101	4	2026-03-02 18:19:50.389517	58.35	56.37	27.81	t	t	t
2107	3	2026-03-02 18:20:00.390059	25.36	64.24	32.47	t	f	t
2109	2	2026-03-02 18:20:10.401893	53.06	78.29	26.13	t	t	t
2115	2	2026-03-02 18:20:20.418637	69.30	49.67	46.32	t	t	t
2116	2	2026-03-02 18:20:30.422223	79.64	48.62	54.20	t	t	t
2123	4	2026-03-02 18:20:40.436126	49.67	48.93	69.11	t	t	f
2124	2	2026-03-02 18:20:50.443667	72.15	41.81	65.40	t	t	t
2128	5	2026-03-02 18:21:00.454189	22.13	39.96	56.81	t	t	f
2134	3	2026-03-02 18:21:10.457712	22.50	12.48	42.09	t	t	t
2138	4	2026-03-02 18:21:20.468397	19.08	51.60	25.25	t	t	t
2143	3	2026-03-02 18:21:30.476	30.06	31.03	53.93	t	t	t
2145	3	2026-03-02 18:21:40.482433	66.65	75.66	45.74	t	t	t
2148	2	2026-03-02 18:21:50.497353	39.95	32.33	60.05	t	t	t
2153	5	2026-03-02 18:22:00.510289	33.36	19.11	50.47	f	t	t
2157	3	2026-03-02 18:22:10.52416	30.12	72.33	45.68	t	t	t
2162	3	2026-03-02 18:22:20.524908	73.14	26.24	42.21	t	t	t
2164	2	2026-03-02 18:22:30.532474	30.09	29.28	50.91	t	t	t
2171	4	2026-03-02 18:22:40.534605	17.82	21.14	46.75	t	t	t
2174	4	2026-03-02 18:22:50.537942	62.98	79.68	43.78	t	t	t
2179	3	2026-03-02 18:23:00.554415	35.56	46.71	43.22	t	t	t
2183	4	2026-03-02 18:23:10.568185	70.39	56.29	30.92	t	f	f
2184	2	2026-03-02 18:23:20.568826	16.57	11.92	43.12	t	t	t
2189	5	2026-03-02 18:23:30.569323	44.52	15.77	39.69	t	t	t
2192	2	2026-03-02 18:23:40.577056	28.34	37.83	29.07	t	t	t
2197	5	2026-03-02 18:23:50.5832	65.89	58.85	64.76	t	t	t
2201	5	2026-03-02 18:24:00.582713	44.08	57.85	59.35	t	t	t
2207	4	2026-03-02 18:24:10.59927	39.73	74.78	24.84	t	t	t
2208	2	2026-03-02 18:24:20.614092	71.88	28.50	59.23	t	t	t
2499	2	2026-03-02 18:36:21.117084	15.55	45.44	59.56	t	f	t
2838	5	2026-03-02 18:50:31.840477	55.48	61.83	55.36	t	t	t
2840	2	2026-03-02 18:50:41.849026	54.00	47.14	25.15	t	t	t
2845	2	2026-03-02 18:50:51.850374	32.22	70.46	54.75	t	t	t
2851	4	2026-03-02 18:51:01.850544	77.21	23.23	28.93	t	f	t
2852	2	2026-03-02 18:51:11.862834	62.69	57.48	45.33	t	t	t
2858	3	2026-03-02 18:51:21.873083	38.25	44.35	62.88	t	t	t
2862	3	2026-03-02 18:51:31.884619	10.36	12.76	40.24	t	t	t
2867	3	2026-03-02 18:51:41.893969	25.82	29.63	45.88	t	t	t
2871	4	2026-03-02 18:51:51.903105	48.44	66.94	66.85	t	f	t
2873	3	2026-03-02 18:52:01.910353	16.39	64.69	30.69	t	t	t
2877	2	2026-03-02 18:52:11.915384	74.11	21.60	22.63	t	f	t
2882	3	2026-03-02 18:52:21.928987	28.82	76.90	66.68	t	t	t
2884	2	2026-03-02 18:52:31.935163	62.93	20.15	47.72	t	t	t
2891	4	2026-03-02 18:52:41.948224	40.85	14.19	68.41	t	t	t
2895	4	2026-03-02 18:52:51.950013	18.15	38.19	54.83	f	f	t
1710	2	2026-03-02 18:03:29.578962	43.45	48.68	43.07	t	f	t
1715	5	2026-03-02 18:03:39.581845	44.56	13.40	40.46	t	t	t
1718	2	2026-03-02 18:03:49.590154	63.23	60.99	21.08	t	t	t
1721	5	2026-03-02 18:03:59.608352	22.13	30.16	23.96	t	t	f
1727	2	2026-03-02 18:04:09.612046	40.54	28.27	41.20	t	f	t
1730	4	2026-03-02 18:04:19.612977	26.60	77.30	37.67	t	t	t
1734	3	2026-03-02 18:04:29.6187	29.91	63.52	69.70	t	t	t
1736	3	2026-03-02 18:04:39.617221	30.51	20.89	28.68	t	t	t
1743	5	2026-03-02 18:04:49.629946	39.69	26.51	28.91	t	t	t
1745	4	2026-03-02 18:04:59.646105	24.00	10.01	47.99	t	t	t
1751	3	2026-03-02 18:05:09.644845	43.69	16.12	34.19	t	f	t
1753	5	2026-03-02 18:05:19.649007	14.00	79.54	48.30	t	t	t
1757	4	2026-03-02 18:05:29.663765	18.74	67.90	42.87	t	t	t
1761	5	2026-03-02 18:05:39.668912	57.43	70.07	36.65	t	t	t
1767	4	2026-03-02 18:05:49.685111	45.18	57.89	40.81	t	t	f
1771	2	2026-03-02 18:05:59.682047	21.82	47.07	54.17	t	t	t
1775	2	2026-03-02 18:06:09.682802	64.38	68.78	62.15	t	t	t
1779	4	2026-03-02 18:06:19.687136	77.03	22.82	24.68	f	t	t
1780	2	2026-03-02 18:06:29.699433	78.56	64.46	59.12	t	t	t
1787	4	2026-03-02 18:06:39.706768	30.49	54.60	38.84	t	t	f
1789	5	2026-03-02 18:06:49.716475	44.80	29.68	28.70	t	t	t
1794	3	2026-03-02 18:06:59.726859	30.61	42.12	56.78	t	t	t
1796	2	2026-03-02 18:07:09.730402	33.74	24.89	57.31	t	f	t
1801	5	2026-03-02 18:07:19.737839	56.50	67.15	64.21	t	f	t
1806	3	2026-03-02 18:07:29.744295	16.03	61.04	64.65	t	t	t
1808	2	2026-03-02 18:07:39.754627	11.43	39.82	57.49	t	t	f
1814	4	2026-03-02 18:07:49.752966	63.95	45.42	55.39	t	t	t
1819	3	2026-03-02 18:07:59.767809	29.65	65.08	37.84	t	t	t
1822	2	2026-03-02 18:08:09.764752	66.28	71.64	64.91	t	t	t
1825	5	2026-03-02 18:08:19.776049	53.42	53.79	24.49	t	t	t
1828	3	2026-03-02 18:08:29.790351	16.38	36.30	53.11	t	t	t
1832	2	2026-03-02 18:08:39.801047	28.97	24.55	57.09	t	t	t
1837	5	2026-03-02 18:08:49.817675	27.53	76.39	37.11	t	t	t
1842	3	2026-03-02 18:08:59.834379	46.31	34.90	66.18	t	t	t
1844	2	2026-03-02 18:09:09.848786	15.53	43.33	60.30	t	t	t
1850	3	2026-03-02 18:09:19.857469	50.87	44.21	26.70	t	t	t
1854	3	2026-03-02 18:09:29.865763	39.71	59.63	52.53	t	t	t
1857	5	2026-03-02 18:09:39.862453	65.99	58.89	28.49	t	t	t
1861	3	2026-03-02 18:09:49.872646	22.65	29.96	28.25	t	t	t
1867	3	2026-03-02 18:09:59.884744	57.40	35.22	27.99	t	t	t
1868	2	2026-03-02 18:10:09.898346	46.66	22.23	45.78	t	t	t
1872	2	2026-03-02 18:10:19.908583	57.76	39.75	48.54	f	t	t
1879	3	2026-03-02 18:10:29.916169	40.63	25.24	47.86	t	t	t
1880	2	2026-03-02 18:10:39.917806	26.28	41.51	66.49	t	t	t
1885	5	2026-03-02 18:10:49.929904	74.43	18.89	64.27	t	f	t
2213	5	2026-03-02 18:24:30.630396	18.92	62.95	34.94	t	t	t
2212	2	2026-03-02 18:24:30.630117	31.98	61.01	43.35	t	t	f
2218	3	2026-03-02 18:24:40.637049	31.40	44.10	58.13	t	t	t
2219	5	2026-03-02 18:24:40.637148	34.85	16.00	41.21	f	t	t
2220	3	2026-03-02 18:24:50.644956	61.87	32.44	37.30	t	t	t
2222	2	2026-03-02 18:24:50.64556	32.17	61.37	36.29	t	t	t
2224	3	2026-03-02 18:25:00.648001	34.01	32.56	66.33	t	t	t
2226	5	2026-03-02 18:25:00.648123	66.99	35.65	24.19	f	t	t
2229	5	2026-03-02 18:25:10.659112	75.68	59.66	51.23	t	t	t
2230	3	2026-03-02 18:25:10.659274	33.78	55.24	38.15	t	t	t
2234	5	2026-03-02 18:25:20.668138	51.40	48.97	60.58	t	t	t
2235	3	2026-03-02 18:25:20.668293	60.33	63.50	29.90	t	t	t
2237	4	2026-03-02 18:25:30.6728	36.08	45.34	59.95	t	t	t
2500	2	2026-03-02 18:36:31.124797	18.26	78.97	48.97	t	t	t
2505	5	2026-03-02 18:36:41.134986	50.29	65.02	29.35	t	t	t
2508	2	2026-03-02 18:36:51.14832	41.78	72.07	55.99	t	t	t
2513	5	2026-03-02 18:37:01.153062	13.69	67.77	41.01	t	t	t
2517	5	2026-03-02 18:37:11.162946	51.53	11.36	35.23	t	t	t
2523	4	2026-03-02 18:37:21.167914	52.23	27.11	25.89	t	f	t
2524	3	2026-03-02 18:37:31.180418	51.65	16.31	30.11	t	t	t
2529	5	2026-03-02 18:37:41.194503	15.69	43.86	44.75	t	f	t
2535	3	2026-03-02 18:37:51.207974	78.86	31.23	56.75	t	t	f
2536	2	2026-03-02 18:38:01.211421	27.43	72.10	67.09	t	t	f
2541	5	2026-03-02 18:38:11.225917	65.19	59.62	61.64	t	t	f
2544	3	2026-03-02 18:38:21.236236	36.08	38.77	37.66	t	t	t
2549	3	2026-03-02 18:38:31.255629	38.85	21.12	46.80	t	t	f
2553	5	2026-03-02 18:38:41.261536	33.25	64.66	34.14	t	t	t
2559	4	2026-03-02 18:38:51.27348	29.07	32.64	26.63	t	t	t
2562	4	2026-03-02 18:39:01.277276	37.08	21.00	44.44	t	t	f
2564	3	2026-03-02 18:39:11.2773	23.82	45.51	31.30	t	t	f
2569	5	2026-03-02 18:39:21.287515	79.45	18.20	52.64	t	t	t
2574	4	2026-03-02 18:39:31.285769	12.53	18.70	52.77	t	t	f
2576	2	2026-03-02 18:39:41.294402	52.88	17.42	44.05	t	f	t
2583	3	2026-03-02 18:39:51.311141	18.49	42.44	55.52	t	t	t
2587	4	2026-03-02 18:40:01.315452	43.34	65.88	27.55	f	t	t
2590	4	2026-03-02 18:40:11.323228	54.42	70.51	61.33	t	t	t
2595	3	2026-03-02 18:40:21.34194	79.66	26.86	35.36	t	t	t
2596	2	2026-03-02 18:40:31.35235	45.39	12.82	21.38	t	t	f
2600	3	2026-03-02 18:40:41.360074	58.09	21.87	58.86	t	t	t
2607	5	2026-03-02 18:40:51.375205	67.12	63.35	67.39	t	t	f
2611	3	2026-03-02 18:41:01.39054	44.82	77.99	48.05	t	t	f
2612	2	2026-03-02 18:41:11.405216	54.08	62.43	35.86	t	t	t
2619	4	2026-03-02 18:41:21.406985	54.24	59.51	64.10	t	t	t
2620	2	2026-03-02 18:41:31.42235	40.78	76.45	47.53	t	t	t
2627	3	2026-03-02 18:41:41.435281	23.52	29.81	24.91	t	f	f
2631	2	2026-03-02 18:41:51.436544	78.84	69.54	57.60	t	t	t
2632	2	2026-03-02 18:42:01.454074	76.98	30.37	60.09	t	t	f
2638	3	2026-03-02 18:42:11.454647	29.60	26.64	36.56	t	t	t
2643	4	2026-03-02 18:42:21.457271	15.73	19.03	54.33	t	t	t
2646	4	2026-03-02 18:42:31.465072	12.09	31.09	23.87	t	t	t
2649	4	2026-03-02 18:42:41.475195	60.23	46.15	59.05	t	t	f
2653	5	2026-03-02 18:42:51.477969	61.04	17.19	52.22	t	t	t
2659	4	2026-03-02 18:43:01.48187	40.14	21.58	61.09	t	t	t
2661	5	2026-03-02 18:43:11.481002	47.05	38.10	36.53	t	t	t
2666	4	2026-03-02 18:43:21.487454	66.12	43.28	40.48	t	t	t
2670	4	2026-03-02 18:43:31.502905	66.45	26.96	68.24	t	t	t
2675	4	2026-03-02 18:43:41.501853	75.53	44.67	25.55	t	t	t
2677	5	2026-03-02 18:43:51.514378	44.44	48.21	20.85	t	t	t
2682	4	2026-03-02 18:44:01.529021	58.20	61.77	49.05	t	t	t
2686	4	2026-03-02 18:44:11.537693	76.14	18.32	44.04	t	t	t
2689	2	2026-03-02 18:44:21.543027	42.76	38.15	29.02	t	t	t
2693	3	2026-03-02 18:44:31.559975	70.93	21.25	45.20	t	f	t
1215	4	2026-03-02 17:42:48.697166	50.37	12.62	66.98	t	f	t
1216	2	2026-03-02 17:42:58.700017	30.76	31.01	66.92	t	t	t
1221	5	2026-03-02 17:43:08.70041	21.53	43.67	56.95	t	t	t
1227	3	2026-03-02 17:43:18.707642	52.42	39.27	32.57	t	t	t
1711	4	2026-03-02 18:03:29.579135	10.28	44.21	49.95	t	t	t
1713	3	2026-03-02 18:03:39.581371	71.52	32.56	47.36	t	t	t
1716	3	2026-03-02 18:03:49.589745	42.45	59.09	32.52	t	t	t
1723	3	2026-03-02 18:03:59.608712	12.34	59.78	56.48	t	t	t
1724	3	2026-03-02 18:04:09.611389	11.17	60.00	21.05	t	t	f
1731	5	2026-03-02 18:04:19.613537	21.21	69.56	33.76	t	t	t
1732	2	2026-03-02 18:04:29.617726	14.71	77.67	62.80	t	t	t
1737	5	2026-03-02 18:04:39.617816	31.08	60.94	38.72	t	t	t
1740	3	2026-03-02 18:04:49.62914	67.16	27.72	55.56	t	t	t
1746	5	2026-03-02 18:04:59.646351	27.20	34.60	48.42	t	t	t
1750	2	2026-03-02 18:05:09.644535	41.44	61.00	28.75	t	t	t
1755	3	2026-03-02 18:05:19.64948	47.20	53.50	44.38	t	t	t
1756	2	2026-03-02 18:05:29.663501	40.80	33.89	67.13	t	f	f
1763	2	2026-03-02 18:05:39.669205	12.38	28.03	57.41	t	t	t
1764	2	2026-03-02 18:05:49.684208	78.33	42.27	62.91	t	t	t
1768	3	2026-03-02 18:05:59.681526	32.15	11.53	68.65	t	t	t
1773	5	2026-03-02 18:06:09.682535	73.18	31.47	64.61	t	t	f
1778	3	2026-03-02 18:06:19.68685	17.65	49.96	55.37	t	t	t
1781	3	2026-03-02 18:06:29.699622	22.84	48.28	40.91	t	t	t
1786	5	2026-03-02 18:06:39.706445	29.30	68.19	22.15	t	t	t
1791	2	2026-03-02 18:06:49.717	51.25	38.41	44.30	t	t	t
1792	2	2026-03-02 18:06:59.726329	38.11	48.75	52.61	t	t	t
1797	5	2026-03-02 18:07:09.730632	36.82	42.49	34.22	t	t	t
1802	4	2026-03-02 18:07:19.7381	79.73	32.83	36.54	t	t	f
1804	2	2026-03-02 18:07:29.743915	61.45	61.66	51.36	t	t	t
1809	5	2026-03-02 18:07:39.755115	45.38	42.20	28.72	t	t	t
1815	3	2026-03-02 18:07:49.753102	12.02	19.57	35.08	t	t	f
1818	4	2026-03-02 18:07:59.767476	14.04	61.66	40.06	t	t	t
1820	3	2026-03-02 18:08:09.764122	36.96	77.40	22.44	t	t	t
1827	4	2026-03-02 18:08:19.77658	73.61	76.64	34.85	t	t	t
1829	2	2026-03-02 18:08:29.790835	35.97	33.33	68.33	f	t	t
1834	3	2026-03-02 18:08:39.801697	37.56	67.65	57.85	t	t	f
1839	3	2026-03-02 18:08:49.818269	26.48	77.69	33.48	t	f	t
1840	2	2026-03-02 18:08:59.833906	16.48	40.73	45.68	t	t	t
1845	5	2026-03-02 18:09:09.848942	24.90	38.06	63.66	t	t	t
1851	5	2026-03-02 18:09:19.85772	32.46	37.24	65.37	f	t	t
1852	2	2026-03-02 18:09:29.865338	12.56	33.15	57.72	t	t	t
1859	4	2026-03-02 18:09:39.863006	68.43	21.58	49.68	t	t	t
1860	2	2026-03-02 18:09:49.872235	32.48	43.87	31.17	t	t	t
1865	5	2026-03-02 18:09:59.884242	20.41	56.24	41.35	t	t	t
1870	4	2026-03-02 18:10:09.898939	76.88	31.04	68.23	t	t	t
1875	3	2026-03-02 18:10:19.909393	33.36	44.58	22.18	t	t	t
1877	5	2026-03-02 18:10:29.915471	59.46	23.97	34.68	t	t	t
1881	5	2026-03-02 18:10:39.91808	29.87	39.10	61.88	t	t	t
1887	4	2026-03-02 18:10:49.930391	59.40	58.50	47.28	t	t	t
2214	4	2026-03-02 18:24:30.630574	65.49	24.21	23.76	t	t	t
2216	2	2026-03-02 18:24:40.636119	73.09	22.82	33.64	t	t	t
2221	5	2026-03-02 18:24:50.645368	36.96	12.77	60.81	t	t	f
2225	4	2026-03-02 18:25:00.648193	48.35	73.75	26.84	t	t	t
2231	4	2026-03-02 18:25:10.659546	40.50	27.41	67.33	t	t	t
2232	2	2026-03-02 18:25:20.667925	29.19	35.12	22.39	t	t	f
2238	5	2026-03-02 18:25:30.673121	50.67	20.57	31.16	t	t	t
2242	5	2026-03-02 18:25:40.67887	43.38	68.52	23.37	t	t	t
2501	5	2026-03-02 18:36:31.125307	35.05	24.77	20.91	t	t	t
2506	4	2026-03-02 18:36:41.135245	39.93	41.12	67.23	t	t	t
2510	3	2026-03-02 18:36:51.148833	68.32	23.03	58.54	t	t	t
2512	2	2026-03-02 18:37:01.152893	29.92	42.73	31.78	t	t	t
2519	4	2026-03-02 18:37:11.163001	30.37	52.21	68.39	t	t	t
2522	3	2026-03-02 18:37:21.167626	33.62	29.37	40.18	t	t	t
2527	2	2026-03-02 18:37:31.18132	47.27	36.85	45.88	t	t	t
2530	3	2026-03-02 18:37:41.194711	45.17	75.08	41.19	t	t	t
2532	2	2026-03-02 18:37:51.207739	61.40	51.96	22.30	f	t	t
2537	5	2026-03-02 18:38:01.21159	51.53	67.20	62.63	t	t	t
2543	3	2026-03-02 18:38:11.226388	22.72	60.79	44.86	t	t	t
2546	2	2026-03-02 18:38:21.236627	11.54	55.14	55.51	t	t	t
2551	4	2026-03-02 18:38:31.256118	13.41	68.21	23.40	t	t	t
2552	2	2026-03-02 18:38:41.261033	28.09	41.40	49.18	t	t	t
2557	5	2026-03-02 18:38:51.272998	26.00	75.34	66.49	t	t	f
2563	3	2026-03-02 18:39:01.277516	39.60	13.59	57.00	t	t	t
2565	2	2026-03-02 18:39:11.277497	68.52	10.95	44.19	t	t	t
2571	4	2026-03-02 18:39:21.287921	78.59	41.00	63.74	t	t	t
2575	2	2026-03-02 18:39:31.286074	48.57	63.77	61.75	t	t	t
2579	3	2026-03-02 18:39:41.296026	14.24	64.41	20.59	f	t	t
2580	2	2026-03-02 18:39:51.310387	74.22	61.83	28.84	t	f	t
2585	5	2026-03-02 18:40:01.314841	21.15	69.15	25.71	t	t	t
2589	5	2026-03-02 18:40:11.322983	12.98	29.37	27.50	t	t	t
2592	2	2026-03-02 18:40:21.340785	15.59	18.97	30.61	t	f	t
2597	5	2026-03-02 18:40:31.353245	25.79	31.15	42.01	t	t	t
2602	4	2026-03-02 18:40:41.360432	71.81	72.52	24.30	t	t	t
2606	2	2026-03-02 18:40:51.37489	18.41	24.67	35.73	t	t	f
2610	4	2026-03-02 18:41:01.390318	11.50	77.55	20.10	t	t	t
2615	4	2026-03-02 18:41:11.406081	69.13	30.95	44.52	t	t	t
2616	3	2026-03-02 18:41:21.40639	28.32	23.72	60.99	t	f	t
2621	5	2026-03-02 18:41:31.422536	12.77	13.23	34.87	t	t	t
2624	2	2026-03-02 18:41:41.434618	33.72	24.55	54.12	t	t	t
2629	5	2026-03-02 18:41:51.436042	34.63	70.15	66.03	t	t	t
2635	3	2026-03-02 18:42:01.454856	72.58	76.76	44.44	t	t	t
2637	5	2026-03-02 18:42:11.454561	56.22	46.69	24.31	t	t	t
2642	2	2026-03-02 18:42:21.457099	36.70	45.25	44.22	t	t	t
2644	2	2026-03-02 18:42:31.464064	46.15	49.11	34.26	t	t	t
2651	3	2026-03-02 18:42:41.47593	22.82	72.78	45.56	t	t	f
2655	3	2026-03-02 18:42:51.478233	13.64	69.22	53.96	t	t	t
2658	3	2026-03-02 18:43:01.481655	16.37	50.57	55.28	t	t	f
2663	4	2026-03-02 18:43:11.481472	21.91	16.00	31.00	t	t	t
2664	2	2026-03-02 18:43:21.487274	33.27	30.72	20.52	t	t	t
2669	5	2026-03-02 18:43:31.502708	72.41	32.79	68.07	f	t	t
2674	2	2026-03-02 18:43:41.501816	72.96	59.26	63.94	f	t	t
2676	2	2026-03-02 18:43:51.514179	12.92	20.15	26.37	t	f	t
2681	5	2026-03-02 18:44:01.528799	25.38	65.96	27.49	t	t	t
2685	5	2026-03-02 18:44:11.537466	15.14	34.95	34.75	t	t	t
2691	5	2026-03-02 18:44:21.543637	24.82	41.80	49.31	t	t	f
2692	2	2026-03-02 18:44:31.559185	33.41	46.47	53.02	t	f	t
2697	5	2026-03-02 18:44:41.565327	40.72	13.42	69.92	t	t	t
2999	3	2026-03-02 18:57:12.15302	18.26	65.98	25.36	t	t	t
3000	2	2026-03-02 18:57:22.153887	30.27	30.91	47.18	t	t	t
3005	5	2026-03-02 18:57:32.1584	24.49	11.32	25.66	t	t	f
3009	2	2026-03-02 18:57:42.16779	68.73	53.62	51.99	t	t	t
3014	4	2026-03-02 18:57:52.17252	75.00	28.67	55.94	t	t	t
3018	3	2026-03-02 18:58:02.179035	18.90	65.44	27.91	t	t	t
3020	2	2026-03-02 18:58:12.187964	76.69	32.14	57.54	t	t	t
3026	5	2026-03-02 18:58:22.197595	23.69	46.69	24.48	t	t	f
3028	2	2026-03-02 18:58:32.203968	67.60	12.85	60.98	t	t	t
3033	5	2026-03-02 18:58:42.217909	51.53	70.82	24.81	t	f	t
3039	4	2026-03-02 18:58:52.229987	42.37	61.97	40.72	f	t	t
3042	3	2026-03-02 18:59:02.231722	23.51	52.94	59.67	f	t	t
3045	2	2026-03-02 18:59:12.232954	78.43	50.00	45.91	t	t	f
3048	2	2026-03-02 18:59:22.238582	35.73	10.77	46.72	t	t	t
3053	5	2026-03-02 18:59:32.252073	34.13	27.32	63.84	f	t	t
3057	5	2026-03-02 18:59:42.267405	24.95	57.64	24.32	t	f	t
3062	3	2026-03-02 18:59:52.268125	51.17	32.77	22.12	t	t	t
4648	2	2026-03-02 20:06:05.37361	47.60	63.86	29.01	t	f	t
4654	5	2026-03-02 20:06:15.357561	20.60	13.61	55.48	t	t	t
4656	2	2026-03-02 20:06:25.373181	62.94	23.38	29.55	t	t	t
4661	5	2026-03-02 20:06:35.375194	18.53	24.31	59.29	t	t	t
4666	3	2026-03-02 20:06:45.377067	56.61	27.19	40.92	t	f	t
4717	2	2026-03-02 20:08:55.540291	78.41	69.36	26.97	t	t	t
4721	4	2026-03-02 20:09:05.513849	26.50	46.82	46.98	t	t	t
4786	4	2026-03-02 20:11:55.652948	57.43	46.87	41.78	t	t	t
4789	3	2026-03-02 20:12:05.61428	33.37	23.02	29.58	t	t	f
4863	5	2026-03-02 20:15:05.776841	47.62	18.81	27.73	t	t	f
4864	2	2026-03-02 20:15:15.749645	15.48	60.39	36.88	t	t	t
4871	5	2026-03-02 20:15:25.753153	24.98	19.08	54.94	t	f	t
4872	2	2026-03-02 20:15:35.755216	64.38	54.04	24.22	t	t	t
4930	5	2026-03-02 20:17:55.911764	53.43	74.20	63.50	t	f	t
4933	3	2026-03-02 20:18:05.890641	59.20	20.51	36.54	t	t	f
4938	4	2026-03-02 20:18:15.887811	79.86	12.08	49.95	t	t	t
4942	3	2026-03-02 20:18:25.896391	32.01	45.29	45.41	t	t	f
4947	3	2026-03-02 20:18:35.900817	60.06	29.73	21.48	t	t	f
4950	2	2026-03-02 20:18:45.909317	70.30	32.08	30.78	t	t	t
4952	3	2026-03-02 20:18:55.922865	43.38	28.34	50.27	t	t	t
4997	3	2026-03-02 20:20:46.016233	39.64	13.91	60.24	t	t	t
5074	4	2026-03-02 20:23:56.225823	23.47	72.95	41.07	t	f	t
5078	3	2026-03-02 20:24:06.182082	46.92	13.47	34.48	t	t	f
5171	5	2026-03-02 20:27:56.355459	43.53	63.10	48.44	t	t	t
5172	2	2026-03-02 20:28:06.319698	53.83	17.91	60.49	t	t	t
5179	5	2026-03-02 20:28:16.322006	18.64	36.73	23.66	f	t	t
5180	2	2026-03-02 20:28:26.334755	31.62	73.87	20.08	t	t	t
5187	5	2026-03-02 20:28:36.33176	60.82	36.36	69.45	t	t	t
5188	2	2026-03-02 20:28:46.337075	24.56	78.53	32.97	t	t	t
5234	4	2026-03-02 20:30:36.440519	19.63	78.96	53.37	t	t	t
5237	3	2026-03-02 20:30:46.413442	56.50	79.63	56.53	t	t	t
5242	4	2026-03-02 20:30:56.417017	11.09	49.13	49.67	f	t	t
5307	5	2026-03-02 20:33:36.551148	63.10	63.46	61.92	t	f	f
5308	2	2026-03-02 20:33:46.52213	19.80	47.43	47.32	t	t	t
5315	5	2026-03-02 20:33:56.519912	66.22	24.31	32.42	t	t	t
5316	2	2026-03-02 20:34:06.529504	38.84	58.34	65.68	t	t	t
5375	4	2026-03-02 20:36:26.700628	65.75	25.50	25.72	t	t	t
5379	2	2026-03-02 20:36:36.663834	41.20	17.92	57.17	t	f	t
5454	3	2026-03-02 20:39:46.881917	55.47	39.32	43.86	t	t	t
5458	3	2026-03-02 20:39:56.860268	36.67	11.81	61.21	t	t	t
5460	3	2026-03-02 20:40:06.867857	76.97	76.63	64.52	t	t	t
5523	5	2026-03-02 20:42:37.046397	12.18	37.71	33.66	f	t	t
5526	2	2026-03-02 20:42:47.016619	35.80	27.35	45.48	f	t	t
5585	3	2026-03-02 20:45:17.195118	68.83	41.28	59.33	t	t	t
5591	4	2026-03-02 20:45:27.163436	64.43	28.60	27.31	t	t	t
5592	2	2026-03-02 20:45:37.181921	42.25	34.93	35.16	t	t	t
5646	3	2026-03-02 20:47:47.297193	16.48	31.92	43.65	t	t	t
5648	3	2026-03-02 20:47:57.261986	76.01	20.43	50.69	t	t	t
5714	5	2026-03-02 20:50:37.405395	57.12	74.44	49.14	t	t	t
5718	3	2026-03-02 20:50:47.370212	49.21	36.26	28.64	t	t	f
5721	4	2026-03-02 20:50:57.372571	46.81	27.88	46.36	t	t	t
5771	5	2026-03-02 20:52:57.533523	27.53	38.94	61.55	t	t	t
5772	2	2026-03-02 20:53:07.508288	68.95	47.41	68.76	t	t	t
5842	4	2026-03-02 20:55:57.666373	33.76	74.76	43.18	t	t	t
5845	3	2026-03-02 20:56:07.642009	51.00	55.88	21.93	t	t	t
5850	4	2026-03-02 20:56:17.644353	64.51	51.79	28.04	t	t	t
5855	4	2026-03-02 20:56:27.644502	65.48	38.31	36.52	t	t	t
5856	2	2026-03-02 20:56:37.646579	21.65	21.24	43.05	t	t	t
5909	3	2026-03-02 20:58:47.807219	19.93	32.47	67.35	t	t	t
5914	4	2026-03-02 20:58:57.775404	69.82	79.40	22.28	t	t	t
5918	3	2026-03-02 20:59:07.773559	68.85	25.85	30.84	t	t	t
5955	5	2026-03-02 21:00:37.898848	28.49	46.66	55.24	t	t	t
5956	2	2026-03-02 21:00:47.863336	53.43	32.79	54.84	t	t	t
5963	5	2026-03-02 21:00:57.866793	77.26	24.43	22.33	t	t	t
5965	2	2026-03-02 21:01:07.868721	34.27	35.71	44.32	t	t	t
5971	3	2026-03-02 21:01:17.871842	46.81	50.24	42.62	t	t	t
5974	3	2026-03-02 21:01:27.872106	77.28	23.07	63.24	t	t	t
5976	2	2026-03-02 21:01:37.884368	38.87	53.17	40.15	f	t	t
5982	5	2026-03-02 21:01:47.886411	17.67	18.53	46.98	t	t	t
5987	3	2026-03-02 21:01:57.885761	16.67	23.55	63.22	t	t	t
6030	4	2026-03-02 21:03:48.009195	30.04	41.18	24.65	t	t	t
6033	3	2026-03-02 21:03:57.984372	27.19	41.76	46.58	t	t	t
6074	5	2026-03-02 21:05:38.116846	66.52	61.02	61.11	t	t	t
6076	3	2026-03-02 21:05:48.073813	21.77	19.44	28.35	t	t	t
6129	3	2026-03-02 21:07:58.192305	60.59	78.49	28.82	t	t	t
6178	4	2026-03-02 21:09:58.308298	58.33	56.35	49.77	t	t	t
6180	3	2026-03-02 21:10:08.278173	27.30	18.09	27.40	t	t	t
6229	3	2026-03-02 21:12:08.404996	16.37	16.10	50.62	t	t	t
6233	4	2026-03-02 21:12:18.392018	60.07	37.81	51.18	t	t	f
6239	4	2026-03-02 21:12:28.391747	38.39	42.68	61.07	t	t	t
6240	2	2026-03-02 21:12:38.391783	12.38	61.82	56.90	t	t	t
6247	5	2026-03-02 21:12:48.39466	76.19	78.87	56.03	t	t	t
6248	4	2026-03-02 21:12:58.398424	10.32	25.88	42.77	t	t	t
6286	4	2026-03-02 21:14:28.525984	40.73	42.76	32.92	t	t	t
6288	3	2026-03-02 21:14:38.459544	20.73	11.85	56.38	t	t	t
6335	5	2026-03-02 21:16:28.591791	20.61	40.28	43.02	t	t	t
6336	2	2026-03-02 21:16:38.562444	47.55	79.02	62.02	t	t	t
6383	5	2026-03-02 21:18:28.665779	42.43	20.54	59.89	t	t	t
6385	2	2026-03-02 21:18:38.639831	71.90	19.90	65.98	t	t	f
6427	5	2026-03-02 21:20:18.744326	28.78	66.65	43.76	t	t	t
3001	5	2026-03-02 18:57:22.154145	73.09	58.09	39.20	t	t	f
3006	3	2026-03-02 18:57:32.158581	73.37	37.30	67.67	t	t	t
3011	3	2026-03-02 18:57:42.16838	49.15	54.26	69.75	t	t	t
3012	2	2026-03-02 18:57:52.172004	63.70	68.20	35.33	t	f	t
3019	4	2026-03-02 18:58:02.179304	15.04	28.25	33.12	t	t	t
3023	4	2026-03-02 18:58:12.188763	16.89	44.60	37.36	t	t	f
3025	2	2026-03-02 18:58:22.197298	41.35	32.63	53.26	t	t	t
3031	3	2026-03-02 18:58:32.204446	19.16	74.74	45.85	f	t	t
3034	4	2026-03-02 18:58:42.218108	52.09	13.25	39.81	t	t	t
3036	2	2026-03-02 18:58:52.229296	65.85	11.70	67.85	t	t	t
3043	4	2026-03-02 18:59:02.232025	67.37	32.01	69.32	t	t	f
3047	3	2026-03-02 18:59:12.23344	36.31	74.08	64.05	t	t	t
3050	4	2026-03-02 18:59:22.239166	21.71	62.00	24.54	f	t	t
3052	2	2026-03-02 18:59:32.2519	38.04	34.32	63.67	t	t	t
3058	3	2026-03-02 18:59:42.267594	41.47	35.37	68.83	t	t	t
3061	4	2026-03-02 18:59:52.267406	20.86	49.08	27.84	t	t	t
3065	3	2026-03-02 19:00:02.276619	35.73	33.18	32.62	t	t	t
3068	2	2026-03-02 19:00:12.27992	53.11	79.47	54.68	t	t	t
3074	5	2026-03-02 19:00:22.2819	63.09	29.70	64.65	t	t	t
3077	5	2026-03-02 19:00:32.298438	41.19	41.62	25.61	t	f	t
3082	2	2026-03-02 19:00:42.313722	57.42	35.14	66.17	t	t	t
3086	2	2026-03-02 19:00:52.326481	17.69	21.63	43.73	t	t	t
3089	5	2026-03-02 19:01:02.327767	22.45	45.74	22.89	t	t	t
3092	4	2026-03-02 19:01:12.328928	58.91	79.66	30.07	t	t	t
3097	3	2026-03-02 19:01:22.342632	20.38	26.11	61.92	t	t	t
3103	4	2026-03-02 19:01:32.351058	42.05	60.70	68.89	t	t	t
3106	2	2026-03-02 19:01:42.357766	22.66	11.60	24.48	f	t	t
3109	4	2026-03-02 19:01:52.365999	66.37	46.22	66.89	t	t	t
3115	4	2026-03-02 19:02:02.365182	58.11	49.23	65.15	t	t	t
3118	2	2026-03-02 19:02:12.378755	51.44	66.42	58.20	f	t	t
3122	2	2026-03-02 19:02:22.37527	61.89	27.65	39.68	t	t	t
3124	3	2026-03-02 19:02:32.395234	64.00	55.68	23.13	t	t	t
3131	5	2026-03-02 19:02:42.394308	74.72	43.00	35.28	t	t	t
3134	4	2026-03-02 19:02:52.409578	78.45	23.00	65.20	t	t	t
3137	3	2026-03-02 19:03:02.422717	46.49	27.39	52.41	t	t	t
3141	5	2026-03-02 19:03:12.425446	41.88	71.77	35.72	t	t	t
3147	4	2026-03-02 19:03:22.440953	51.13	37.81	42.72	t	t	t
3148	2	2026-03-02 19:03:32.445363	61.27	45.06	45.00	t	t	f
3153	5	2026-03-02 19:03:42.454358	20.73	67.79	29.88	t	t	f
3156	3	2026-03-02 19:03:52.460704	22.04	21.79	47.62	f	t	t
3162	4	2026-03-02 19:04:02.461444	25.67	24.77	25.05	t	t	t
3166	4	2026-03-02 19:04:12.475742	58.81	65.74	68.45	t	t	f
3168	2	2026-03-02 19:04:22.488818	39.49	42.98	42.09	t	t	t
3173	5	2026-03-02 19:04:32.495078	34.19	40.73	30.25	t	t	t
4649	3	2026-03-02 20:06:05.433646	28.30	52.04	53.70	t	t	t
4655	4	2026-03-02 20:06:15.357611	17.12	68.62	49.88	t	t	t
4718	4	2026-03-02 20:08:55.542983	63.48	58.53	27.45	t	t	t
4720	3	2026-03-02 20:09:05.513754	56.37	69.76	31.68	t	f	t
4787	5	2026-03-02 20:11:55.660368	15.57	23.79	43.11	t	t	t
4788	2	2026-03-02 20:12:05.613329	64.09	41.30	46.78	t	f	t
4866	4	2026-03-02 20:15:15.780661	21.85	72.48	69.59	t	t	t
4869	3	2026-03-02 20:15:25.752541	68.48	25.71	57.29	t	t	t
4874	4	2026-03-02 20:15:35.755773	20.62	14.33	44.59	t	t	t
4931	4	2026-03-02 20:17:55.912077	61.15	53.00	23.94	t	t	t
4932	2	2026-03-02 20:18:05.89048	26.23	37.89	54.33	t	t	t
4937	5	2026-03-02 20:18:15.887666	78.50	62.06	38.31	t	f	t
4943	4	2026-03-02 20:18:25.896688	49.62	69.90	59.59	t	t	t
4944	2	2026-03-02 20:18:35.900088	13.78	78.37	24.49	t	t	t
4998	4	2026-03-02 20:20:46.05639	41.89	48.32	64.24	t	t	t
5000	3	2026-03-02 20:20:56.027258	28.49	38.69	20.89	t	f	t
5075	5	2026-03-02 20:23:56.227084	14.21	68.03	23.71	t	f	t
5076	2	2026-03-02 20:24:06.180601	33.36	41.36	63.08	t	t	f
5182	4	2026-03-02 20:28:26.370108	38.72	22.87	68.19	t	t	t
5185	3	2026-03-02 20:28:36.331543	47.49	23.77	40.93	t	f	t
5235	5	2026-03-02 20:30:36.443099	56.64	43.12	27.41	t	t	t
5236	2	2026-03-02 20:30:46.413332	41.90	16.45	29.14	t	t	t
5243	5	2026-03-02 20:30:56.416967	75.76	60.82	67.57	t	t	t
5317	3	2026-03-02 20:34:06.564317	63.08	36.96	36.88	t	t	t
5321	2	2026-03-02 20:34:16.539146	73.23	62.23	50.81	t	t	t
5381	3	2026-03-02 20:36:46.710874	14.34	15.68	58.78	t	f	t
5385	4	2026-03-02 20:36:56.695446	20.75	20.55	57.91	t	t	t
5391	4	2026-03-02 20:37:06.697842	61.55	29.27	28.41	t	f	t
5455	5	2026-03-02 20:39:46.882141	31.69	66.22	38.43	t	t	t
5456	2	2026-03-02 20:39:56.860003	20.19	53.21	63.33	f	t	t
5527	5	2026-03-02 20:42:47.045888	29.19	67.55	66.56	t	t	t
5528	2	2026-03-02 20:42:57.0236	36.39	51.42	30.81	t	f	t
5586	5	2026-03-02 20:45:17.198266	10.91	30.15	36.15	t	t	f
5590	3	2026-03-02 20:45:27.163137	17.52	25.77	21.16	t	t	f
5647	5	2026-03-02 20:47:47.298366	77.57	71.32	33.68	t	t	t
5651	2	2026-03-02 20:47:57.262526	77.19	34.78	20.55	t	t	t
5653	3	2026-03-02 20:48:07.270682	60.11	45.77	31.96	t	t	t
5715	4	2026-03-02 20:50:37.513764	78.33	62.86	39.15	t	t	t
5716	2	2026-03-02 20:50:47.369366	57.43	39.01	41.48	t	t	t
5723	5	2026-03-02 20:50:57.373173	34.65	42.80	68.01	t	t	t
5724	2	2026-03-02 20:51:07.387179	66.54	40.89	66.06	t	t	t
5775	5	2026-03-02 20:53:07.539705	46.82	69.88	26.05	t	t	t
5776	2	2026-03-02 20:53:17.517725	60.93	19.32	48.21	t	f	t
5843	5	2026-03-02 20:55:57.666597	57.69	21.41	53.59	f	t	t
5844	2	2026-03-02 20:56:07.64187	65.51	21.56	54.85	t	t	f
5849	5	2026-03-02 20:56:17.64407	23.09	47.68	35.51	t	t	f
5853	3	2026-03-02 20:56:27.643936	56.56	14.15	57.09	t	t	t
5858	4	2026-03-02 20:56:37.647051	21.85	62.16	58.16	t	t	t
5910	4	2026-03-02 20:58:47.810214	75.07	10.02	30.43	t	t	t
5913	3	2026-03-02 20:58:57.775269	33.55	62.03	58.40	t	t	t
5917	4	2026-03-02 20:59:07.773447	56.52	76.95	30.52	t	t	t
5959	5	2026-03-02 21:00:47.89222	62.39	58.01	68.87	t	t	f
5960	2	2026-03-02 21:00:57.866074	55.79	68.60	63.94	t	t	t
5966	5	2026-03-02 21:01:07.868925	16.43	34.35	50.17	t	t	t
5970	4	2026-03-02 21:01:17.871761	16.20	40.25	68.08	t	t	f
5972	2	2026-03-02 21:01:27.8714	19.50	24.11	24.92	t	f	t
6031	5	2026-03-02 21:03:48.0095	28.35	42.84	38.41	t	t	t
6032	2	2026-03-02 21:03:57.984186	25.37	45.65	26.09	t	t	t
6075	4	2026-03-02 21:05:38.119279	65.96	25.68	51.52	t	t	t
6130	4	2026-03-02 21:07:58.194934	22.48	19.36	42.95	t	t	t
6179	5	2026-03-02 21:09:58.312983	56.99	21.15	40.74	t	t	f
6182	2	2026-03-02 21:10:08.278674	19.28	38.11	48.42	t	t	t
6230	4	2026-03-02 21:12:08.409587	71.61	61.21	60.26	t	f	t
3002	3	2026-03-02 18:57:22.15431	29.40	12.62	56.46	t	t	t
3007	4	2026-03-02 18:57:32.15881	15.05	14.19	41.44	t	t	t
3010	5	2026-03-02 18:57:42.167967	20.17	45.70	50.34	t	t	t
3015	3	2026-03-02 18:57:52.172882	40.10	60.69	61.95	t	t	t
3016	2	2026-03-02 18:58:02.178598	26.64	51.64	37.13	f	t	t
3022	5	2026-03-02 18:58:12.188444	22.52	19.84	60.39	t	t	t
3027	4	2026-03-02 18:58:22.19785	72.25	67.63	25.49	t	t	t
3030	4	2026-03-02 18:58:32.204487	79.67	42.91	65.87	t	t	t
3035	2	2026-03-02 18:58:42.218377	74.69	54.59	66.15	t	t	t
3038	3	2026-03-02 18:58:52.229685	34.02	76.95	36.75	t	t	t
3040	2	2026-03-02 18:59:02.231339	18.43	19.06	47.32	t	t	t
3044	4	2026-03-02 18:59:12.233141	53.31	59.53	68.39	t	t	t
3049	5	2026-03-02 18:59:22.239017	24.71	79.60	67.17	t	t	f
3055	3	2026-03-02 18:59:32.252635	49.82	71.97	55.67	t	t	t
3056	2	2026-03-02 18:59:42.266992	63.63	18.90	43.08	t	t	t
3063	5	2026-03-02 18:59:52.268458	14.39	43.22	52.56	t	t	t
3064	2	2026-03-02 19:00:02.27603	16.47	66.19	23.90	t	t	t
3070	5	2026-03-02 19:00:12.280411	72.60	55.49	57.68	t	t	t
3072	4	2026-03-02 19:00:22.281368	73.94	47.96	67.35	t	t	t
3078	3	2026-03-02 19:00:32.298592	13.69	12.78	27.76	t	t	t
3083	3	2026-03-02 19:00:42.313875	41.88	70.15	24.38	t	t	t
3084	3	2026-03-02 19:00:52.326053	10.05	64.22	32.45	t	t	t
3091	4	2026-03-02 19:01:02.328281	54.19	46.21	35.87	t	t	t
3093	2	2026-03-02 19:01:12.329202	50.59	65.91	35.05	t	t	t
3099	5	2026-03-02 19:01:22.343472	58.88	17.74	61.50	t	t	t
3102	3	2026-03-02 19:01:32.350738	54.85	26.39	51.05	t	t	t
3107	4	2026-03-02 19:01:42.357924	30.73	73.01	63.36	f	t	t
3108	3	2026-03-02 19:01:52.364903	72.11	28.88	50.13	t	t	t
3113	5	2026-03-02 19:02:02.364696	57.16	65.25	22.62	t	t	t
3116	3	2026-03-02 19:02:12.378316	78.19	48.17	43.15	t	t	t
3121	3	2026-03-02 19:02:22.375101	19.77	35.97	48.44	t	f	t
3127	2	2026-03-02 19:02:32.39604	15.79	19.31	52.85	t	t	f
3128	2	2026-03-02 19:02:42.393785	50.53	48.04	39.62	t	t	t
3132	2	2026-03-02 19:02:52.409085	32.46	21.62	22.01	t	t	f
3139	4	2026-03-02 19:03:02.423232	27.77	62.06	23.00	t	t	t
3142	3	2026-03-02 19:03:12.425615	52.44	56.59	42.25	t	t	f
3146	2	2026-03-02 19:03:22.440641	36.62	45.77	38.79	t	t	t
3149	5	2026-03-02 19:03:32.445587	57.74	23.57	22.61	t	t	f
3155	2	2026-03-02 19:03:42.454783	17.98	15.84	21.83	t	f	t
3159	2	2026-03-02 19:03:52.461009	74.41	29.99	65.82	t	t	t
3161	2	2026-03-02 19:04:02.460869	61.16	20.54	63.87	t	t	t
3167	2	2026-03-02 19:04:12.475858	52.92	57.66	27.66	t	t	t
3171	4	2026-03-02 19:04:22.489685	66.73	53.35	65.65	t	t	t
3172	2	2026-03-02 19:04:32.494817	74.00	28.32	69.24	t	t	t
4650	4	2026-03-02 20:06:05.436542	25.87	13.49	55.58	t	t	t
4653	3	2026-03-02 20:06:15.357486	60.22	10.45	54.49	t	f	f
4719	5	2026-03-02 20:08:55.543297	60.19	32.71	64.03	t	t	t
4722	2	2026-03-02 20:09:05.513875	75.67	68.23	28.22	t	t	f
4792	2	2026-03-02 20:12:15.677294	71.62	76.99	54.44	t	t	t
4867	5	2026-03-02 20:15:15.781098	76.20	64.57	49.33	t	t	t
4868	2	2026-03-02 20:15:25.7522	49.52	77.31	52.68	t	t	t
4875	5	2026-03-02 20:15:35.756575	23.27	13.29	43.16	t	t	t
4876	3	2026-03-02 20:15:45.763912	12.51	43.67	39.06	t	t	t
4883	5	2026-03-02 20:15:55.766766	60.19	38.55	54.12	t	t	t
4885	2	2026-03-02 20:16:05.76886	64.93	64.98	36.02	t	t	t
4934	4	2026-03-02 20:18:05.924055	26.28	11.44	21.94	t	t	t
4939	2	2026-03-02 20:18:15.888133	70.09	37.23	22.23	t	t	t
4940	2	2026-03-02 20:18:25.895604	32.53	31.19	26.75	t	t	t
4945	5	2026-03-02 20:18:35.900355	42.41	76.85	62.61	f	t	t
4949	4	2026-03-02 20:18:45.908986	75.33	67.03	66.53	t	t	t
4999	5	2026-03-02 20:20:46.056592	45.53	61.06	42.00	t	f	t
5001	2	2026-03-02 20:20:56.027523	41.49	20.52	30.96	t	t	t
5081	3	2026-03-02 20:24:16.258843	41.96	39.67	66.59	t	t	f
5086	4	2026-03-02 20:24:26.213297	60.28	67.37	27.40	t	t	t
5088	3	2026-03-02 20:24:36.204377	60.17	63.16	66.78	t	f	t
5183	5	2026-03-02 20:28:26.370352	42.49	55.21	49.45	t	t	t
5184	2	2026-03-02 20:28:36.331315	36.70	14.08	27.64	t	t	t
5238	5	2026-03-02 20:30:46.444295	64.21	44.86	35.05	t	t	t
5241	3	2026-03-02 20:30:56.416733	44.33	40.55	68.57	t	t	t
5318	4	2026-03-02 20:34:06.567054	61.26	42.95	26.86	t	t	t
5382	5	2026-03-02 20:36:46.712363	54.05	39.13	47.53	t	t	t
5384	3	2026-03-02 20:36:56.695255	77.73	48.08	32.19	t	t	t
5389	5	2026-03-02 20:37:06.697342	70.66	27.26	68.02	t	t	t
5392	2	2026-03-02 20:37:16.71435	55.31	42.24	39.81	t	t	t
5459	5	2026-03-02 20:39:57.007215	36.55	34.86	55.13	t	t	t
5461	2	2026-03-02 20:40:06.868505	23.72	57.40	41.40	t	t	t
5464	2	2026-03-02 20:40:16.882278	27.58	70.64	68.91	t	t	t
5469	5	2026-03-02 20:40:26.884562	40.33	24.59	37.32	t	t	t
5529	3	2026-03-02 20:42:57.052087	17.44	49.32	24.91	t	t	t
5534	4	2026-03-02 20:43:07.040903	42.91	12.97	29.70	t	t	t
5538	2	2026-03-02 20:43:17.048188	79.92	15.94	63.93	t	t	f
5587	4	2026-03-02 20:45:17.301394	11.60	74.13	36.41	t	t	t
5588	2	2026-03-02 20:45:27.16273	34.54	17.73	52.91	t	t	t
5654	4	2026-03-02 20:48:07.302231	43.09	34.92	30.90	t	t	f
5657	3	2026-03-02 20:48:17.283224	38.85	11.49	45.03	t	t	t
5662	4	2026-03-02 20:48:27.284459	27.89	59.10	21.24	f	t	t
5664	2	2026-03-02 20:48:37.28033	51.81	45.61	36.66	t	f	t
5725	3	2026-03-02 20:51:07.41945	42.66	10.23	51.15	t	t	t
5729	4	2026-03-02 20:51:17.395296	34.62	36.86	54.23	t	f	t
5777	3	2026-03-02 20:53:17.549312	11.67	53.56	49.93	t	t	f
5781	3	2026-03-02 20:53:27.522102	16.84	68.28	33.74	t	t	t
5847	5	2026-03-02 20:56:07.674695	15.72	37.23	30.70	t	t	t
5848	2	2026-03-02 20:56:17.643825	68.81	59.42	32.48	t	t	t
5854	5	2026-03-02 20:56:27.644178	34.99	14.14	41.57	t	t	t
5857	3	2026-03-02 20:56:37.646984	41.52	45.00	35.58	f	t	t
5861	3	2026-03-02 20:56:47.659992	57.64	56.78	52.23	t	t	t
5866	4	2026-03-02 20:56:57.66203	31.35	21.26	29.88	t	t	f
5911	5	2026-03-02 20:58:47.812714	56.47	65.42	42.15	t	t	t
5912	2	2026-03-02 20:58:57.775001	71.83	51.67	62.32	t	f	t
5919	5	2026-03-02 20:59:07.773642	33.40	48.99	40.98	t	t	t
5977	3	2026-03-02 21:01:37.91936	21.69	14.12	25.09	t	t	f
5983	4	2026-03-02 21:01:47.886552	49.06	70.79	65.84	t	t	t
5984	2	2026-03-02 21:01:57.885388	36.73	13.44	51.65	t	t	f
6034	4	2026-03-02 21:03:58.012911	11.53	30.78	25.91	t	t	t
6036	2	2026-03-02 21:04:07.994708	66.89	24.16	59.76	t	f	t
6077	2	2026-03-02 21:05:48.073881	32.76	79.45	36.35	t	t	t
6131	5	2026-03-02 21:07:58.198215	43.40	38.11	22.75	t	t	t
3003	4	2026-03-02 18:57:22.154614	74.59	69.79	65.92	t	t	t
3004	2	2026-03-02 18:57:32.157948	54.73	12.84	40.38	t	t	t
3008	4	2026-03-02 18:57:42.16739	67.63	50.57	30.33	t	t	t
3013	5	2026-03-02 18:57:52.172128	33.02	78.09	65.47	t	t	t
3017	5	2026-03-02 18:58:02.178864	19.47	73.79	58.64	t	t	t
3021	3	2026-03-02 18:58:12.188211	76.57	13.38	63.80	t	t	t
3024	3	2026-03-02 18:58:22.196848	46.20	10.75	20.52	f	t	t
3029	5	2026-03-02 18:58:32.204297	65.60	23.58	45.92	t	f	t
3032	3	2026-03-02 18:58:42.217683	76.70	43.10	26.49	t	t	t
3037	5	2026-03-02 18:58:52.229442	71.19	19.88	65.86	t	t	t
3041	5	2026-03-02 18:59:02.231559	23.05	13.69	59.27	t	t	t
3046	5	2026-03-02 18:59:12.233282	30.65	32.53	41.07	t	f	t
3051	3	2026-03-02 18:59:22.23947	43.69	76.53	62.24	t	t	t
3054	4	2026-03-02 18:59:32.25232	54.12	69.76	67.48	t	t	t
3059	4	2026-03-02 18:59:42.267804	13.06	68.06	37.66	t	t	t
3060	2	2026-03-02 18:59:52.2671	55.83	31.17	53.14	t	t	t
3066	4	2026-03-02 19:00:02.276773	56.58	43.92	69.54	t	t	t
3069	3	2026-03-02 19:00:12.280061	29.32	11.40	53.00	t	t	t
3073	2	2026-03-02 19:00:22.28175	73.94	35.19	36.24	t	t	t
3076	2	2026-03-02 19:00:32.298177	13.47	36.77	23.31	t	t	t
3081	5	2026-03-02 19:00:42.313401	48.98	72.10	20.95	t	t	t
3087	4	2026-03-02 19:00:52.326713	60.90	47.88	36.24	t	t	t
3090	3	2026-03-02 19:01:02.327952	22.01	39.33	45.46	t	t	t
3095	3	2026-03-02 19:01:12.33025	20.87	17.14	44.09	f	t	t
3096	2	2026-03-02 19:01:22.342375	48.53	70.56	64.99	t	t	t
3100	2	2026-03-02 19:01:32.350215	77.66	33.19	36.14	t	t	t
3105	5	2026-03-02 19:01:42.35745	77.69	51.09	41.75	t	t	t
3110	2	2026-03-02 19:01:52.366256	42.80	55.97	54.56	t	t	t
3114	3	2026-03-02 19:02:02.364968	46.03	71.60	58.67	t	f	t
3119	4	2026-03-02 19:02:12.378715	51.09	21.20	61.57	t	f	t
3123	5	2026-03-02 19:02:22.375554	45.64	39.50	51.93	t	t	t
3125	4	2026-03-02 19:02:32.39571	72.47	66.40	42.05	t	t	f
3130	3	2026-03-02 19:02:42.394361	18.29	40.05	46.94	t	t	t
3133	5	2026-03-02 19:02:52.409258	72.31	10.48	55.45	t	t	t
3138	5	2026-03-02 19:03:02.42297	20.87	22.17	59.79	t	t	t
3143	2	2026-03-02 19:03:12.425872	21.98	22.81	69.30	t	t	t
3145	5	2026-03-02 19:03:22.440489	58.07	19.29	55.73	t	t	t
3150	4	2026-03-02 19:03:32.445839	27.04	46.62	61.82	t	t	t
3152	4	2026-03-02 19:03:42.454191	10.05	65.54	30.98	t	t	t
3158	5	2026-03-02 19:03:52.461133	35.68	40.16	57.50	t	t	t
3160	3	2026-03-02 19:04:02.460712	40.70	64.38	42.18	f	t	t
3164	3	2026-03-02 19:04:12.475323	71.91	59.47	39.03	t	t	t
3169	5	2026-03-02 19:04:22.48919	33.20	28.35	66.27	t	t	t
3174	4	2026-03-02 19:04:32.495233	76.97	37.29	20.21	t	t	t
4651	5	2026-03-02 20:06:05.451663	33.03	32.24	63.94	t	t	t
4652	2	2026-03-02 20:06:15.357201	40.61	41.83	46.89	t	t	f
4723	5	2026-03-02 20:09:05.65614	16.27	18.59	20.56	t	t	t
4724	2	2026-03-02 20:09:15.524504	14.60	53.36	37.14	f	t	t
4793	5	2026-03-02 20:12:15.720152	18.65	41.93	36.76	t	t	t
4877	4	2026-03-02 20:15:45.802161	18.18	36.75	57.50	t	t	t
4881	4	2026-03-02 20:15:55.766512	49.48	55.30	22.41	t	f	f
4886	4	2026-03-02 20:16:05.769172	77.50	65.74	56.39	t	t	t
4935	5	2026-03-02 20:18:05.924846	17.08	44.39	61.10	t	t	t
4936	3	2026-03-02 20:18:15.88729	40.81	50.96	69.54	t	t	t
4941	5	2026-03-02 20:18:25.896128	64.12	45.97	34.76	t	t	t
4946	4	2026-03-02 20:18:35.900511	22.81	10.46	22.24	t	t	t
4948	3	2026-03-02 20:18:45.908426	28.80	21.76	64.11	t	t	t
5002	4	2026-03-02 20:20:56.058411	56.82	78.35	30.62	t	t	t
5004	3	2026-03-02 20:21:06.040721	62.47	41.44	68.64	t	t	t
5082	4	2026-03-02 20:24:16.264536	20.39	31.98	28.82	t	f	t
5085	3	2026-03-02 20:24:26.212909	57.87	23.20	67.24	t	t	t
5091	4	2026-03-02 20:24:36.204669	13.53	46.19	58.58	t	t	t
5092	2	2026-03-02 20:24:46.208489	38.69	22.23	45.39	t	f	t
5097	5	2026-03-02 20:24:56.209308	13.11	75.64	26.51	t	t	t
5189	5	2026-03-02 20:28:46.381701	73.66	24.52	57.46	t	t	t
5239	4	2026-03-02 20:30:46.550097	78.76	11.96	43.18	t	t	t
5240	2	2026-03-02 20:30:56.416615	52.84	42.76	41.54	t	t	f
5319	5	2026-03-02 20:34:06.569912	48.76	51.26	23.63	t	t	t
5320	3	2026-03-02 20:34:16.53901	16.74	15.69	41.87	t	t	t
5383	2	2026-03-02 20:36:46.823023	12.05	77.99	34.94	t	t	t
5386	2	2026-03-02 20:36:56.695718	14.11	66.14	40.44	t	t	t
5390	3	2026-03-02 20:37:06.69759	11.72	10.44	22.55	t	f	t
5393	3	2026-03-02 20:37:16.714615	50.42	78.80	29.61	t	f	t
5462	5	2026-03-02 20:40:06.897522	67.80	61.33	57.38	t	t	t
5465	3	2026-03-02 20:40:16.882492	43.26	12.22	25.32	t	f	t
5470	4	2026-03-02 20:40:26.884766	49.66	60.81	69.31	t	t	f
5530	5	2026-03-02 20:42:57.056451	14.20	68.55	25.99	t	t	t
5533	3	2026-03-02 20:43:07.040691	27.69	13.08	32.58	t	t	t
5536	3	2026-03-02 20:43:17.047361	43.61	55.30	51.91	t	t	t
5593	3	2026-03-02 20:45:37.214731	33.56	34.20	46.90	t	t	t
5655	5	2026-03-02 20:48:07.30466	18.13	24.20	66.04	t	t	t
5656	2	2026-03-02 20:48:17.282837	42.00	13.14	48.99	f	t	t
5661	5	2026-03-02 20:48:27.284252	48.91	50.53	41.44	t	t	f
5665	3	2026-03-02 20:48:37.280512	35.51	22.25	58.64	t	t	t
5726	4	2026-03-02 20:51:07.42587	45.41	41.10	34.93	t	t	t
5728	2	2026-03-02 20:51:17.395224	11.44	52.66	68.16	t	t	t
5778	4	2026-03-02 20:53:17.551314	17.10	11.46	41.48	t	t	t
5782	4	2026-03-02 20:53:27.522204	19.42	36.43	63.80	t	t	t
5862	4	2026-03-02 20:56:47.698179	60.64	57.85	69.37	t	t	t
5865	3	2026-03-02 20:56:57.661734	30.65	40.77	25.40	t	t	f
5915	5	2026-03-02 20:58:57.806115	26.36	30.44	40.27	t	t	t
5916	2	2026-03-02 20:59:07.773111	54.66	29.20	60.99	t	t	t
5920	2	2026-03-02 20:59:17.782714	40.44	66.92	53.68	t	t	t
5978	4	2026-03-02 21:01:37.926354	63.06	29.99	66.15	t	t	t
5981	3	2026-03-02 21:01:47.886222	19.50	43.13	27.22	f	t	t
5986	4	2026-03-02 21:01:57.885741	73.65	33.74	65.68	t	t	t
5988	2	2026-03-02 21:02:07.900915	17.07	35.18	29.37	t	t	t
5993	5	2026-03-02 21:02:17.903897	42.08	17.32	38.34	f	t	t
5999	4	2026-03-02 21:02:27.903505	71.20	48.65	44.97	t	t	t
6035	5	2026-03-02 21:03:58.138766	48.59	74.84	50.62	t	t	t
6037	3	2026-03-02 21:04:07.995217	55.91	41.00	32.70	t	t	t
6078	5	2026-03-02 21:05:48.107199	28.94	45.44	46.42	t	t	t
6081	3	2026-03-02 21:05:58.085201	10.96	46.97	65.49	t	f	t
6132	2	2026-03-02 21:08:08.197956	61.52	23.16	22.46	t	t	t
6137	5	2026-03-02 21:08:18.189176	44.58	47.48	49.86	t	t	t
6183	5	2026-03-02 21:10:08.30851	15.21	36.42	58.65	t	t	t
6184	2	2026-03-02 21:10:18.288459	42.96	30.55	26.16	t	t	f
3067	5	2026-03-02 19:00:02.277346	35.59	15.40	49.90	t	t	t
3071	4	2026-03-02 19:00:12.280616	44.25	62.83	67.11	t	t	f
3075	3	2026-03-02 19:00:22.282226	63.44	58.70	59.00	f	t	t
3079	4	2026-03-02 19:00:32.298862	26.35	13.07	28.63	t	f	t
3080	4	2026-03-02 19:00:42.313228	54.12	57.04	28.24	t	t	t
3085	5	2026-03-02 19:00:52.326325	13.33	23.36	39.42	t	t	t
3088	2	2026-03-02 19:01:02.327393	39.65	41.03	50.77	t	t	t
3094	5	2026-03-02 19:01:12.33008	49.10	42.36	64.77	t	t	t
3098	4	2026-03-02 19:01:22.343004	25.71	58.70	23.75	t	f	t
3101	5	2026-03-02 19:01:32.350487	19.86	53.93	29.54	t	f	t
3104	3	2026-03-02 19:01:42.357266	19.51	46.42	50.61	f	t	f
3111	5	2026-03-02 19:01:52.36648	46.60	75.85	59.21	t	t	t
3112	2	2026-03-02 19:02:02.364565	65.19	73.55	29.97	t	t	t
3117	5	2026-03-02 19:02:12.378491	66.54	63.19	30.97	t	f	t
3120	4	2026-03-02 19:02:22.374751	17.91	52.23	30.40	t	t	t
3126	5	2026-03-02 19:02:32.395511	24.91	73.51	49.19	t	t	t
3129	4	2026-03-02 19:02:42.394049	51.52	24.09	29.68	t	t	t
3135	3	2026-03-02 19:02:52.409859	14.33	40.89	50.31	t	t	t
3136	2	2026-03-02 19:03:02.422451	48.54	11.91	20.82	t	t	t
3140	4	2026-03-02 19:03:12.425198	21.22	78.82	62.18	t	t	f
3144	3	2026-03-02 19:03:22.4401	54.11	51.80	30.49	t	t	t
3151	3	2026-03-02 19:03:32.446049	65.23	43.88	35.22	t	t	t
3154	3	2026-03-02 19:03:42.454497	25.55	48.36	26.53	t	t	t
3157	4	2026-03-02 19:03:52.461061	58.27	30.30	24.78	t	t	t
3163	5	2026-03-02 19:04:02.461758	31.85	77.28	49.25	t	t	t
3165	5	2026-03-02 19:04:12.475534	61.12	72.42	38.04	t	t	t
3170	3	2026-03-02 19:04:22.489372	40.33	25.63	56.24	t	t	f
3175	3	2026-03-02 19:04:32.49552	29.66	23.85	55.22	t	t	t
3176	2	2026-03-02 19:04:42.494454	63.95	73.15	27.12	t	t	t
3177	4	2026-03-02 19:04:42.494768	27.43	72.89	20.59	t	t	t
3179	3	2026-03-02 19:04:42.495333	63.66	19.84	47.38	t	t	t
3178	5	2026-03-02 19:04:42.495059	76.72	53.71	45.15	t	t	t
3180	2	2026-03-02 19:04:52.507974	33.72	33.29	56.53	t	t	t
3181	5	2026-03-02 19:04:52.508138	44.33	52.11	58.99	t	t	t
3182	4	2026-03-02 19:04:52.508379	63.06	44.88	48.23	t	t	t
3183	3	2026-03-02 19:04:52.50869	78.99	13.02	69.07	t	t	t
3184	2	2026-03-02 19:05:02.520005	32.56	20.56	23.81	t	t	t
3185	5	2026-03-02 19:05:02.520221	21.49	69.61	42.14	t	t	t
3186	4	2026-03-02 19:05:02.520709	40.49	69.66	37.77	t	t	t
3187	3	2026-03-02 19:05:02.520545	29.63	34.04	65.43	t	t	f
3188	2	2026-03-02 19:05:12.525012	18.88	48.73	26.19	t	t	t
3189	5	2026-03-02 19:05:12.525219	69.16	25.54	52.45	t	t	t
3190	4	2026-03-02 19:05:12.525395	15.06	43.22	52.42	t	t	t
3191	3	2026-03-02 19:05:12.525395	47.85	10.76	43.02	f	t	t
3192	3	2026-03-02 19:05:22.528715	53.23	71.95	40.90	t	t	t
3193	5	2026-03-02 19:05:22.528997	50.51	65.94	23.62	t	t	t
3194	4	2026-03-02 19:05:22.529336	62.55	42.40	42.86	t	t	t
3195	2	2026-03-02 19:05:22.529477	20.96	16.82	24.94	t	f	t
3196	2	2026-03-02 19:05:32.5322	60.17	48.18	54.55	t	t	t
3197	4	2026-03-02 19:05:32.532606	75.24	13.36	28.94	t	t	t
3198	3	2026-03-02 19:05:32.532785	45.73	22.54	65.05	t	t	t
3199	5	2026-03-02 19:05:32.533016	18.54	56.46	40.95	t	f	t
3200	2	2026-03-02 19:05:42.531867	37.25	76.97	50.20	t	t	t
3201	3	2026-03-02 19:05:42.532089	64.96	23.66	24.13	t	t	t
3202	4	2026-03-02 19:05:42.532242	66.96	73.44	39.40	t	t	t
3203	5	2026-03-02 19:05:42.532383	64.48	38.93	48.66	t	t	t
3204	2	2026-03-02 19:05:52.531664	18.72	62.23	32.08	t	t	t
3205	5	2026-03-02 19:05:52.531831	19.75	54.18	45.72	t	t	t
3206	4	2026-03-02 19:05:52.532083	34.90	34.81	55.32	t	t	t
3207	3	2026-03-02 19:05:52.532406	12.85	35.42	51.74	t	t	t
3208	2	2026-03-02 19:06:02.544439	66.68	33.61	28.46	f	t	t
3209	3	2026-03-02 19:06:02.544822	59.80	52.63	32.56	f	t	f
3210	4	2026-03-02 19:06:02.545268	20.07	68.40	35.13	t	t	t
3211	5	2026-03-02 19:06:02.545477	62.42	71.37	44.46	t	t	f
3212	2	2026-03-02 19:06:12.556458	52.19	36.96	34.62	t	t	t
3213	4	2026-03-02 19:06:12.556836	15.96	35.14	51.58	t	t	f
3214	3	2026-03-02 19:06:12.557019	60.75	16.05	23.58	t	t	f
3215	5	2026-03-02 19:06:12.557338	18.83	74.02	37.60	t	t	t
3216	2	2026-03-02 19:06:22.569973	19.78	75.31	64.09	t	f	t
3217	5	2026-03-02 19:06:22.570537	29.21	22.50	28.53	t	t	t
3218	3	2026-03-02 19:06:22.570972	19.16	42.83	21.02	t	t	t
3219	4	2026-03-02 19:06:22.570725	53.01	35.78	41.04	t	t	t
3220	2	2026-03-02 19:06:32.567695	16.75	22.39	65.11	t	f	t
3221	5	2026-03-02 19:06:32.567873	20.83	16.20	63.42	t	t	t
3222	4	2026-03-02 19:06:32.568121	73.21	73.77	36.74	t	f	t
3223	3	2026-03-02 19:06:32.568443	32.70	73.85	60.69	t	t	t
3224	2	2026-03-02 19:06:42.584322	67.31	28.90	46.66	t	t	t
3225	5	2026-03-02 19:06:42.584479	50.64	41.26	24.12	t	f	t
3226	3	2026-03-02 19:06:42.584799	56.48	30.91	57.45	t	t	t
3227	4	2026-03-02 19:06:42.58495	77.14	67.95	32.39	t	f	f
3228	2	2026-03-02 19:06:52.602741	72.44	13.58	60.04	t	t	f
3229	5	2026-03-02 19:06:52.602974	12.28	39.23	57.57	t	t	t
3230	3	2026-03-02 19:06:52.603201	69.33	25.89	28.04	t	t	t
3231	4	2026-03-02 19:06:52.603435	36.75	18.86	41.11	t	t	t
3232	2	2026-03-02 19:07:02.607825	16.92	59.31	26.68	t	t	t
3233	5	2026-03-02 19:07:02.60793	15.99	35.86	33.84	t	t	t
3234	4	2026-03-02 19:07:02.608028	66.70	71.57	46.28	t	t	t
3235	3	2026-03-02 19:07:02.608225	33.65	45.92	42.99	t	t	t
3236	2	2026-03-02 19:07:12.617999	50.20	42.72	31.84	t	t	t
3237	5	2026-03-02 19:07:12.618343	23.74	39.99	65.42	t	t	f
3238	4	2026-03-02 19:07:12.618616	44.28	18.93	66.35	t	t	t
3239	3	2026-03-02 19:07:12.618756	26.98	40.94	40.50	t	t	t
3240	3	2026-03-02 19:07:22.613213	64.21	39.77	21.38	t	t	t
3241	4	2026-03-02 19:07:22.613385	16.48	30.01	49.38	f	t	t
3242	2	2026-03-02 19:07:22.613613	26.17	29.39	54.81	t	t	t
3243	5	2026-03-02 19:07:22.613864	16.86	38.07	49.86	t	t	f
3244	4	2026-03-02 19:07:32.619856	37.33	79.87	52.26	t	t	t
3245	5	2026-03-02 19:07:32.619992	18.41	40.89	55.33	f	t	t
3246	2	2026-03-02 19:07:32.620023	64.10	56.56	25.57	t	f	t
3247	3	2026-03-02 19:07:32.620268	50.75	30.87	35.84	t	t	t
3248	4	2026-03-02 19:07:42.618597	47.60	67.10	38.86	t	t	t
3249	5	2026-03-02 19:07:42.618883	63.14	47.30	57.88	t	t	t
3250	3	2026-03-02 19:07:42.619036	42.38	72.41	56.73	t	t	f
3251	2	2026-03-02 19:07:42.61933	59.90	46.73	60.89	t	t	f
3252	2	2026-03-02 19:07:52.634983	71.07	65.85	52.72	t	f	t
3253	5	2026-03-02 19:07:52.63539	29.71	79.49	24.46	t	t	t
3254	3	2026-03-02 19:07:52.635558	54.00	27.02	39.13	t	t	f
3255	4	2026-03-02 19:07:52.635879	72.35	21.35	33.92	t	t	f
3256	2	2026-03-02 19:08:02.63329	30.74	71.74	52.55	t	t	f
3261	5	2026-03-02 19:08:12.650968	47.68	41.61	68.75	t	f	t
3264	5	2026-03-02 19:08:22.656918	60.19	60.16	44.92	t	t	t
3271	5	2026-03-02 19:08:32.663565	54.56	79.67	63.10	t	t	f
3274	3	2026-03-02 19:08:42.67156	50.77	61.65	52.00	t	t	t
3276	3	2026-03-02 19:08:52.671444	57.32	29.05	66.23	f	t	t
3281	2	2026-03-02 19:09:02.680067	29.45	77.99	61.15	t	t	t
3285	5	2026-03-02 19:09:12.691399	38.12	35.75	52.80	t	t	t
3291	3	2026-03-02 19:09:22.698946	46.82	18.63	35.54	t	t	t
3293	3	2026-03-02 19:09:32.709251	63.49	25.96	62.15	t	t	t
3296	3	2026-03-02 19:09:42.713643	65.24	71.64	57.50	t	t	t
3301	5	2026-03-02 19:09:52.727992	64.87	52.62	60.93	t	t	t
3304	3	2026-03-02 19:10:02.735882	63.72	52.39	36.99	t	f	t
3310	3	2026-03-02 19:10:12.74836	37.03	43.52	63.12	t	t	t
3312	4	2026-03-02 19:10:22.748115	64.99	13.95	54.49	t	f	t
3318	5	2026-03-02 19:10:32.764443	36.43	26.72	58.06	t	t	f
3321	5	2026-03-02 19:10:42.778778	48.88	63.13	68.52	t	t	t
3327	3	2026-03-02 19:10:52.783477	75.55	16.54	41.03	t	t	t
3331	4	2026-03-02 19:11:02.792883	19.53	19.15	40.78	t	t	t
3334	4	2026-03-02 19:11:12.804106	35.45	26.47	24.04	t	t	t
3338	4	2026-03-02 19:11:22.802679	74.70	15.83	38.11	t	t	t
3341	4	2026-03-02 19:11:32.811773	33.46	21.97	69.52	t	t	t
3344	2	2026-03-02 19:11:42.816864	52.68	42.76	62.87	t	t	t
3351	3	2026-03-02 19:11:52.826823	29.95	77.55	30.97	t	f	t
3354	2	2026-03-02 19:12:02.834857	75.24	38.07	29.38	t	t	t
3356	2	2026-03-02 19:12:12.84999	30.30	70.30	69.31	t	f	f
3361	5	2026-03-02 19:12:22.852019	29.62	23.79	62.65	t	t	t
3367	3	2026-03-02 19:12:32.859073	21.88	16.23	52.08	t	t	t
3371	3	2026-03-02 19:12:42.859609	32.67	74.45	49.47	t	t	t
3375	4	2026-03-02 19:12:52.874111	43.54	29.00	34.79	t	t	t
3378	4	2026-03-02 19:13:02.880385	27.77	10.99	60.82	t	t	t
3380	2	2026-03-02 19:13:12.889237	33.24	63.41	31.17	t	t	t
3386	5	2026-03-02 19:13:22.892715	24.78	55.22	35.04	t	t	t
3388	2	2026-03-02 19:13:32.892027	39.68	21.96	33.16	t	t	t
3392	4	2026-03-02 19:13:42.89074	79.15	11.17	35.83	t	t	t
3397	5	2026-03-02 19:13:52.907827	61.62	11.25	31.42	t	t	t
3400	4	2026-03-02 19:14:02.918662	44.62	53.37	50.23	t	t	t
3405	5	2026-03-02 19:14:12.925515	44.83	48.47	29.95	t	f	t
3408	2	2026-03-02 19:14:22.931643	43.79	26.63	29.00	t	t	t
3414	5	2026-03-02 19:14:32.941434	55.92	69.97	62.61	t	t	t
3418	4	2026-03-02 19:14:42.946037	22.61	26.83	43.93	t	t	f
3422	4	2026-03-02 19:14:52.960874	27.74	17.09	64.30	t	f	f
3425	2	2026-03-02 19:15:02.959959	47.69	69.64	44.00	t	t	t
3428	2	2026-03-02 19:15:12.972707	39.11	51.27	55.58	t	f	t
3433	5	2026-03-02 19:15:22.978653	49.72	60.26	65.69	t	t	f
3438	3	2026-03-02 19:15:32.981325	10.18	50.10	40.26	t	f	t
3443	2	2026-03-02 19:15:42.977318	29.13	56.22	39.30	t	t	t
3445	3	2026-03-02 19:15:52.998118	35.25	74.67	53.27	t	t	f
3450	2	2026-03-02 19:16:03.009352	77.69	47.89	33.75	t	t	t
3452	3	2026-03-02 19:16:13.022038	18.66	56.62	67.32	t	f	t
3459	2	2026-03-02 19:16:23.022826	24.16	54.74	49.59	t	t	t
3460	2	2026-03-02 19:16:33.028544	29.10	27.84	48.60	t	t	t
3465	5	2026-03-02 19:16:43.041497	52.71	63.77	59.07	t	t	f
3469	3	2026-03-02 19:16:53.041903	33.03	56.17	20.29	t	t	t
3472	4	2026-03-02 19:17:03.05165	54.52	34.75	68.15	t	t	t
3478	5	2026-03-02 19:17:13.058127	13.81	51.02	68.99	t	t	t
3482	2	2026-03-02 19:17:23.071591	74.62	18.09	69.58	t	t	f
3484	3	2026-03-02 19:17:33.077151	27.67	57.81	47.23	t	t	t
3491	3	2026-03-02 19:17:43.090559	34.22	32.20	37.78	f	t	t
3495	5	2026-03-02 19:17:53.090907	53.69	30.95	41.48	t	t	t
3499	4	2026-03-02 19:18:03.107233	29.55	42.28	27.66	f	t	t
3502	3	2026-03-02 19:18:13.115236	68.79	32.72	30.70	t	t	f
3506	4	2026-03-02 19:18:23.119694	74.28	61.82	57.46	t	t	f
3510	3	2026-03-02 19:18:33.125372	15.11	47.98	62.89	t	t	t
3512	3	2026-03-02 19:18:43.137646	47.33	34.24	47.68	t	f	t
3517	5	2026-03-02 19:18:53.137925	58.55	20.77	52.39	t	t	t
3522	3	2026-03-02 19:19:03.136329	49.66	63.53	66.30	t	t	t
3525	3	2026-03-02 19:19:13.154853	52.56	39.37	24.29	t	t	t
3531	3	2026-03-02 19:19:23.168106	50.14	76.72	42.18	t	t	t
3533	4	2026-03-02 19:19:33.178943	61.79	19.58	53.84	t	t	t
3537	3	2026-03-02 19:19:43.185695	48.01	19.15	38.58	t	t	t
3540	3	2026-03-02 19:19:53.19313	71.19	47.98	62.47	t	t	t
3545	5	2026-03-02 19:20:03.201899	43.42	13.65	38.59	t	t	f
3551	2	2026-03-02 19:20:13.21577	32.31	70.75	56.82	t	t	t
3552	2	2026-03-02 19:20:23.226568	62.39	56.06	21.51	t	t	t
3557	5	2026-03-02 19:20:33.229612	20.59	59.27	38.48	t	t	t
4657	3	2026-03-02 20:06:25.409769	43.14	37.16	66.43	t	t	t
4662	4	2026-03-02 20:06:35.37533	23.87	60.36	62.89	t	t	t
4665	4	2026-03-02 20:06:45.376823	76.30	67.81	69.16	t	t	f
4725	3	2026-03-02 20:09:15.559375	61.86	12.24	47.62	t	f	t
4728	4	2026-03-02 20:09:25.530934	57.81	77.82	60.93	t	t	t
4733	4	2026-03-02 20:09:35.531013	31.34	35.08	67.73	t	t	t
4739	4	2026-03-02 20:09:45.531818	75.87	12.79	32.71	t	t	f
4742	3	2026-03-02 20:09:55.535427	55.27	20.07	31.06	t	t	f
4794	4	2026-03-02 20:12:15.720611	73.95	78.71	41.28	t	t	t
4878	2	2026-03-02 20:15:45.80548	11.42	79.10	65.59	t	t	t
4882	3	2026-03-02 20:15:55.766601	38.21	61.91	62.88	t	f	t
4884	3	2026-03-02 20:16:05.768602	41.59	14.97	67.75	t	t	t
4951	5	2026-03-02 20:18:45.937641	34.09	38.70	20.30	f	t	t
5003	5	2026-03-02 20:20:56.058695	24.75	69.32	37.59	t	t	t
5005	2	2026-03-02 20:21:06.040851	53.72	12.68	21.53	f	t	t
5083	5	2026-03-02 20:24:16.264771	31.60	43.44	33.08	t	t	t
5084	2	2026-03-02 20:24:26.212155	73.58	73.33	61.31	t	t	t
5089	5	2026-03-02 20:24:36.204514	11.00	23.30	39.00	t	f	t
5093	3	2026-03-02 20:24:46.208891	36.88	23.18	22.48	t	t	t
5099	4	2026-03-02 20:24:56.209521	43.84	21.51	53.34	t	t	t
5100	2	2026-03-02 20:25:06.225085	65.29	75.51	69.41	t	t	t
5190	4	2026-03-02 20:28:46.381843	25.40	60.03	49.67	t	t	t
5192	2	2026-03-02 20:28:56.347616	49.96	54.62	58.66	t	t	t
5244	2	2026-03-02 20:31:06.422763	45.65	21.39	61.35	t	t	t
5251	4	2026-03-02 20:31:16.422927	15.03	25.78	40.51	t	t	f
5252	2	2026-03-02 20:31:26.432017	12.47	78.49	62.40	t	t	t
5257	4	2026-03-02 20:31:36.433835	65.77	40.05	50.12	t	t	t
5322	5	2026-03-02 20:34:16.573705	17.88	64.88	46.75	t	t	t
5325	3	2026-03-02 20:34:26.551939	24.01	67.47	27.36	t	t	t
5387	5	2026-03-02 20:36:56.728103	53.00	67.03	30.81	t	t	t
3257	5	2026-03-02 19:08:02.633454	58.02	27.44	53.13	t	t	t
3263	3	2026-03-02 19:08:12.651457	19.50	69.14	23.00	t	t	t
3267	3	2026-03-02 19:08:22.656993	32.29	41.03	56.57	t	t	t
3268	2	2026-03-02 19:08:32.663154	33.47	71.63	55.71	t	t	t
3273	4	2026-03-02 19:08:42.671328	70.39	51.60	34.46	t	t	f
3277	5	2026-03-02 19:08:52.67155	43.38	61.06	27.61	t	t	t
3283	4	2026-03-02 19:09:02.680421	65.29	10.74	65.31	t	t	t
3286	3	2026-03-02 19:09:12.691498	11.22	43.58	51.54	t	t	t
3289	2	2026-03-02 19:09:22.698463	61.51	69.58	48.44	t	f	t
3294	2	2026-03-02 19:09:32.709563	28.74	19.88	49.43	t	f	t
3298	2	2026-03-02 19:09:42.714088	29.86	63.82	33.00	t	t	t
3303	4	2026-03-02 19:09:52.728438	18.63	22.93	38.25	t	t	t
3307	4	2026-03-02 19:10:02.736558	11.48	74.73	25.95	t	t	t
3308	2	2026-03-02 19:10:12.747991	67.88	45.95	62.86	t	t	t
3313	3	2026-03-02 19:10:22.748493	24.35	64.51	40.58	t	t	t
3316	2	2026-03-02 19:10:32.764194	49.92	48.56	52.11	t	t	t
3320	3	2026-03-02 19:10:42.778545	38.04	43.13	62.06	t	t	t
3325	5	2026-03-02 19:10:52.782957	11.77	76.00	43.78	t	t	t
3330	2	2026-03-02 19:11:02.792596	16.74	39.95	28.30	t	t	t
3332	2	2026-03-02 19:11:12.803694	42.71	75.66	59.35	t	t	t
3337	5	2026-03-02 19:11:22.802438	79.05	37.39	66.59	t	t	t
3342	3	2026-03-02 19:11:32.812171	39.98	70.71	44.55	t	t	t
3347	4	2026-03-02 19:11:42.817516	23.04	57.67	57.28	t	t	t
3349	4	2026-03-02 19:11:52.826687	35.51	45.10	46.83	t	t	t
3352	3	2026-03-02 19:12:02.834939	10.95	35.58	34.15	t	t	t
3357	5	2026-03-02 19:12:12.850312	56.60	67.47	23.04	t	t	t
3362	4	2026-03-02 19:12:22.852156	17.94	54.86	41.45	t	t	f
3366	4	2026-03-02 19:12:32.858926	49.22	54.74	23.41	t	t	t
3369	4	2026-03-02 19:12:42.859458	39.51	68.67	25.83	t	t	t
3374	3	2026-03-02 19:12:52.873994	60.34	30.68	66.80	t	t	t
3377	5	2026-03-02 19:13:02.880099	16.91	53.13	66.19	t	f	t
3382	5	2026-03-02 19:13:12.88948	39.27	43.05	21.42	t	t	t
3384	2	2026-03-02 19:13:22.892118	16.30	26.27	51.39	t	t	t
3389	5	2026-03-02 19:13:32.89264	13.49	41.22	22.60	t	t	t
3394	2	2026-03-02 19:13:42.891169	38.96	29.17	46.00	t	t	t
3399	4	2026-03-02 19:13:52.908263	56.26	27.95	28.28	t	t	t
3402	2	2026-03-02 19:14:02.919055	76.80	23.38	34.56	t	t	t
3407	4	2026-03-02 19:14:12.926041	77.39	45.13	61.83	t	t	t
3410	3	2026-03-02 19:14:22.932144	31.68	24.84	63.88	t	t	t
3412	4	2026-03-02 19:14:32.941122	32.69	42.71	48.20	t	f	t
3416	3	2026-03-02 19:14:42.945485	34.97	36.14	35.69	t	t	t
3421	5	2026-03-02 19:14:52.960642	32.71	40.28	36.64	t	f	t
3427	3	2026-03-02 19:15:02.960408	19.24	35.41	32.25	t	t	f
3429	3	2026-03-02 19:15:12.973231	53.36	42.63	31.92	t	t	t
3434	3	2026-03-02 19:15:22.978802	11.08	46.54	48.88	t	t	t
3436	2	2026-03-02 19:15:32.980806	62.06	14.65	45.98	t	t	t
3442	5	2026-03-02 19:15:42.977033	78.70	38.15	68.41	t	t	t
3444	2	2026-03-02 19:15:52.997427	21.58	18.63	53.58	t	t	t
3449	5	2026-03-02 19:16:03.009208	55.52	33.76	63.91	t	t	t
3454	4	2026-03-02 19:16:13.022487	54.01	67.10	29.35	t	t	t
3457	4	2026-03-02 19:16:23.022377	58.82	72.14	30.95	t	t	t
3463	4	2026-03-02 19:16:33.029175	45.52	73.37	23.64	t	t	t
3464	4	2026-03-02 19:16:43.04057	42.74	28.73	38.42	t	t	t
3470	5	2026-03-02 19:16:53.042126	47.21	54.73	54.43	t	t	t
3474	3	2026-03-02 19:17:03.052437	18.10	19.63	53.74	t	t	t
3477	3	2026-03-02 19:17:13.058024	64.00	16.28	39.58	t	t	f
3480	3	2026-03-02 19:17:23.071235	23.27	45.34	33.77	t	t	t
3486	5	2026-03-02 19:17:33.07755	60.15	68.54	31.36	t	t	t
3490	4	2026-03-02 19:17:43.090269	41.91	49.32	23.83	t	t	t
3492	2	2026-03-02 19:17:53.090292	48.62	47.21	31.83	t	t	t
3498	3	2026-03-02 19:18:03.106885	63.17	52.88	47.68	t	t	t
3503	4	2026-03-02 19:18:13.115499	48.71	29.60	26.62	t	f	t
3507	2	2026-03-02 19:18:23.119977	10.64	45.46	21.91	t	t	t
3511	4	2026-03-02 19:18:33.125606	13.99	12.63	60.44	t	t	t
3515	2	2026-03-02 19:18:43.139099	50.10	52.96	65.22	t	t	t
3519	3	2026-03-02 19:18:53.138394	20.23	14.43	65.49	t	t	t
3521	4	2026-03-02 19:19:03.136158	45.62	44.21	27.76	t	t	t
3527	4	2026-03-02 19:19:13.155398	79.11	45.99	62.38	t	t	f
3528	2	2026-03-02 19:19:23.166484	24.35	67.09	49.79	t	t	t
3535	2	2026-03-02 19:19:33.179355	31.56	42.83	56.67	t	f	f
3536	2	2026-03-02 19:19:43.185386	41.24	35.68	66.62	t	t	t
3543	4	2026-03-02 19:19:53.193499	50.92	71.69	23.24	t	t	t
3547	2	2026-03-02 19:20:03.202458	41.13	24.35	24.11	t	t	t
3549	3	2026-03-02 19:20:13.215321	13.40	71.69	68.09	t	t	t
3554	4	2026-03-02 19:20:23.227065	41.94	36.23	65.21	t	t	t
3559	3	2026-03-02 19:20:33.230044	60.01	74.61	55.95	f	t	t
4658	5	2026-03-02 20:06:25.412791	37.17	42.49	66.26	t	t	t
4660	3	2026-03-02 20:06:35.374886	54.21	70.50	69.54	t	t	f
4667	5	2026-03-02 20:06:45.377283	75.60	74.76	41.66	t	t	t
4668	2	2026-03-02 20:06:55.386528	68.87	33.56	36.58	t	t	t
4726	4	2026-03-02 20:09:15.560645	59.83	63.63	21.13	f	f	t
4730	3	2026-03-02 20:09:25.531265	36.72	28.09	65.42	t	t	t
4735	3	2026-03-02 20:09:35.531167	41.37	45.22	24.76	t	t	t
4736	2	2026-03-02 20:09:45.530971	51.67	57.37	60.07	f	t	f
4743	5	2026-03-02 20:09:55.535677	28.70	26.56	35.40	t	t	t
4744	2	2026-03-02 20:10:05.545564	63.78	70.39	48.06	t	t	t
4795	3	2026-03-02 20:12:15.833718	55.30	34.79	43.60	t	t	t
4879	5	2026-03-02 20:15:45.806205	14.72	20.20	52.09	t	t	t
4880	2	2026-03-02 20:15:55.766381	39.03	53.88	42.81	t	t	t
4887	5	2026-03-02 20:16:05.769356	72.38	47.18	69.80	t	t	t
4888	2	2026-03-02 20:16:15.787703	53.59	61.95	42.67	t	t	t
4953	2	2026-03-02 20:18:55.924824	56.35	69.92	54.74	t	t	t
5006	4	2026-03-02 20:21:06.075149	10.02	19.51	40.74	t	t	t
5009	3	2026-03-02 20:21:16.053008	62.65	67.54	57.90	t	t	f
5015	5	2026-03-02 20:21:26.052718	70.86	65.40	24.56	f	t	t
5016	2	2026-03-02 20:21:36.06944	78.28	74.26	56.39	t	t	t
5021	5	2026-03-02 20:21:46.065325	55.50	76.70	30.97	t	t	t
5094	5	2026-03-02 20:24:46.243941	50.94	72.17	45.18	t	t	t
5098	3	2026-03-02 20:24:56.209382	53.03	52.47	31.63	t	t	t
5191	3	2026-03-02 20:28:46.476206	73.64	29.22	52.50	f	f	t
5193	3	2026-03-02 20:28:56.347787	39.11	42.35	35.68	t	t	t
5245	3	2026-03-02 20:31:06.423403	27.67	69.59	50.42	t	t	t
5249	5	2026-03-02 20:31:16.42232	75.05	16.34	23.61	t	t	t
5253	3	2026-03-02 20:31:26.432469	26.54	70.36	24.00	t	t	t
5323	4	2026-03-02 20:34:16.674612	51.08	77.40	68.69	t	t	t
5324	2	2026-03-02 20:34:26.55177	75.36	46.16	33.19	t	t	t
5388	2	2026-03-02 20:37:06.697103	28.98	38.24	43.30	t	t	t
3258	3	2026-03-02 19:08:02.633681	46.98	58.27	34.51	t	t	t
3262	4	2026-03-02 19:08:12.651285	69.07	40.50	38.07	t	t	t
3266	2	2026-03-02 19:08:22.656705	74.38	16.42	61.26	t	t	t
3270	3	2026-03-02 19:08:32.663486	18.50	13.50	47.00	t	t	t
3275	2	2026-03-02 19:08:42.671808	54.31	49.08	37.72	t	t	t
3279	2	2026-03-02 19:08:52.671704	23.73	26.92	24.34	t	t	t
3280	3	2026-03-02 19:09:02.679865	19.56	78.17	35.21	t	t	t
3287	4	2026-03-02 19:09:12.691709	48.59	58.72	65.86	t	t	t
3290	5	2026-03-02 19:09:22.698685	32.62	30.95	50.64	t	t	t
3292	4	2026-03-02 19:09:32.709085	34.70	58.21	28.66	t	t	t
3297	5	2026-03-02 19:09:42.713799	17.87	28.92	21.56	t	t	t
3300	2	2026-03-02 19:09:52.72784	35.58	77.80	66.76	t	t	f
3306	5	2026-03-02 19:10:02.73627	44.24	71.66	65.50	t	t	t
3309	5	2026-03-02 19:10:12.748148	47.19	12.42	35.77	f	t	t
3314	5	2026-03-02 19:10:22.748851	66.03	21.07	60.31	t	t	t
3319	3	2026-03-02 19:10:32.764541	22.78	41.81	41.76	t	t	t
3323	2	2026-03-02 19:10:42.779263	58.87	26.05	25.16	t	f	t
3324	2	2026-03-02 19:10:52.782815	76.24	31.29	41.60	t	t	t
3329	5	2026-03-02 19:11:02.792445	12.02	36.67	63.25	t	t	t
3333	5	2026-03-02 19:11:12.803948	57.42	77.27	56.27	t	t	f
3339	3	2026-03-02 19:11:22.802979	10.41	64.29	60.93	t	t	t
3340	2	2026-03-02 19:11:32.811146	23.41	53.74	54.41	t	t	t
3345	5	2026-03-02 19:11:42.81732	35.05	13.25	56.30	t	t	f
3350	5	2026-03-02 19:11:52.826652	68.65	21.16	67.05	f	f	t
3355	4	2026-03-02 19:12:02.835089	66.56	73.75	46.45	t	t	t
3358	4	2026-03-02 19:12:12.85047	51.86	64.57	49.48	t	t	t
3363	3	2026-03-02 19:12:22.852491	66.01	76.79	27.95	t	t	t
3364	2	2026-03-02 19:12:32.858497	18.97	39.00	52.48	t	t	t
3370	5	2026-03-02 19:12:42.859394	51.65	73.75	61.39	t	t	t
3373	2	2026-03-02 19:12:52.873942	33.50	60.29	22.59	t	f	t
3376	2	2026-03-02 19:13:02.87996	10.56	53.25	28.07	t	t	t
3383	4	2026-03-02 19:13:12.889934	21.27	43.58	31.46	t	t	t
3387	4	2026-03-02 19:13:22.892807	13.78	79.08	52.19	t	t	t
3391	3	2026-03-02 19:13:32.892798	50.31	47.48	67.18	t	t	t
3393	5	2026-03-02 19:13:42.891002	79.60	38.73	36.06	t	t	t
3396	2	2026-03-02 19:13:52.907666	41.36	37.14	48.87	f	t	t
3401	3	2026-03-02 19:14:02.918813	52.74	35.65	57.52	t	t	t
3406	2	2026-03-02 19:14:12.925767	36.15	12.83	21.00	t	t	t
3411	4	2026-03-02 19:14:22.932293	76.89	15.31	45.13	t	t	f
3415	3	2026-03-02 19:14:32.941716	13.15	12.35	32.06	t	f	t
3419	5	2026-03-02 19:14:42.945994	13.75	25.13	66.95	t	t	t
3423	3	2026-03-02 19:14:52.961078	79.81	40.99	57.14	t	t	t
3424	4	2026-03-02 19:15:02.959784	17.95	60.45	29.87	t	t	t
3431	5	2026-03-02 19:15:12.973575	53.93	77.70	29.24	t	t	t
3435	4	2026-03-02 19:15:22.979383	62.93	13.55	39.08	t	t	t
3439	5	2026-03-02 19:15:32.981595	73.43	47.39	59.12	t	t	t
3440	4	2026-03-02 19:15:42.976651	76.48	32.73	63.72	t	t	t
3447	5	2026-03-02 19:15:52.997803	41.46	53.24	25.01	t	t	t
3448	4	2026-03-02 19:16:03.008391	64.85	33.93	49.59	t	f	t
3455	5	2026-03-02 19:16:13.02277	21.18	31.09	40.49	t	t	t
3458	5	2026-03-02 19:16:23.022552	59.20	77.73	24.98	t	t	f
3462	3	2026-03-02 19:16:33.029025	79.03	46.85	52.43	t	t	t
3466	2	2026-03-02 19:16:43.041766	18.97	79.30	52.02	t	t	t
3468	2	2026-03-02 19:16:53.04167	21.79	18.58	50.82	t	t	t
3473	5	2026-03-02 19:17:03.052191	38.72	36.04	43.17	t	t	t
3479	4	2026-03-02 19:17:13.058259	16.79	21.19	26.87	t	t	t
3483	4	2026-03-02 19:17:23.071861	20.24	30.06	56.93	t	t	t
3487	4	2026-03-02 19:17:33.077771	53.28	14.04	32.75	t	t	t
3488	2	2026-03-02 19:17:43.089813	28.20	21.89	56.63	t	t	t
3493	3	2026-03-02 19:17:53.090467	29.67	61.71	62.21	t	t	t
3497	5	2026-03-02 19:18:03.106612	71.63	24.55	64.99	t	t	t
3501	5	2026-03-02 19:18:13.115093	43.57	56.07	40.65	t	t	t
3504	3	2026-03-02 19:18:23.119304	49.62	31.30	43.68	t	t	t
3509	5	2026-03-02 19:18:33.125145	68.90	53.83	66.80	t	t	t
3514	4	2026-03-02 19:18:43.138848	23.44	41.90	69.43	t	t	t
3516	2	2026-03-02 19:18:53.137706	56.09	53.48	67.10	t	t	t
3523	5	2026-03-02 19:19:03.136643	64.51	42.85	37.77	t	t	t
3526	5	2026-03-02 19:19:13.15508	29.18	65.72	38.76	t	t	t
3530	4	2026-03-02 19:19:23.167688	66.69	38.65	51.10	t	t	t
3532	3	2026-03-02 19:19:33.178732	47.01	54.89	45.53	t	t	t
3539	4	2026-03-02 19:19:43.186136	25.59	72.52	33.97	t	t	t
3541	2	2026-03-02 19:19:53.193318	73.53	66.72	56.38	t	t	f
3546	4	2026-03-02 19:20:03.202152	66.08	62.37	35.28	t	t	t
3550	5	2026-03-02 19:20:13.215627	19.58	38.05	45.32	t	t	t
3553	5	2026-03-02 19:20:23.226904	57.92	25.32	42.89	t	t	t
3558	4	2026-03-02 19:20:33.229927	63.26	51.18	53.59	t	t	t
4659	4	2026-03-02 20:06:25.413005	39.21	10.30	48.80	t	t	t
4663	2	2026-03-02 20:06:35.37549	27.93	43.17	32.23	t	t	t
4664	2	2026-03-02 20:06:45.376562	21.50	43.21	44.67	t	t	t
4727	5	2026-03-02 20:09:15.561674	55.62	64.31	59.08	t	f	t
4729	2	2026-03-02 20:09:25.531351	28.45	34.92	38.53	t	t	t
4734	5	2026-03-02 20:09:35.531104	35.46	41.64	65.94	f	t	f
4737	3	2026-03-02 20:09:45.531547	29.00	55.24	25.84	t	t	t
4741	4	2026-03-02 20:09:55.535285	73.63	61.31	32.52	t	f	t
4796	2	2026-03-02 20:12:25.670164	12.81	72.81	28.74	t	t	t
4803	5	2026-03-02 20:12:35.637524	27.61	60.51	60.32	t	t	t
4804	2	2026-03-02 20:12:45.646338	77.95	60.76	48.45	t	t	t
4809	5	2026-03-02 20:12:55.651611	61.75	24.04	36.83	t	t	t
4814	3	2026-03-02 20:13:05.651379	16.69	21.09	30.55	t	t	t
4817	3	2026-03-02 20:13:15.650989	25.17	43.72	44.87	t	t	f
4889	3	2026-03-02 20:16:15.830413	31.27	35.16	32.77	t	t	f
4894	4	2026-03-02 20:16:25.809257	45.89	29.57	36.97	t	t	t
4954	4	2026-03-02 20:18:55.958284	34.56	62.72	45.78	t	t	t
5007	5	2026-03-02 20:21:06.076905	77.13	67.16	61.07	t	t	t
5008	2	2026-03-02 20:21:16.052764	25.68	15.16	60.78	t	t	f
5013	4	2026-03-02 20:21:26.051625	20.00	68.61	42.35	f	t	t
5095	4	2026-03-02 20:24:46.246663	56.22	45.57	47.33	t	t	t
5096	2	2026-03-02 20:24:56.2092	79.80	26.09	33.73	t	t	t
5194	4	2026-03-02 20:28:56.381238	47.21	49.17	60.88	t	t	t
5197	3	2026-03-02 20:29:06.36108	11.98	16.64	53.87	t	t	t
5246	4	2026-03-02 20:31:06.456328	17.92	71.40	56.76	t	t	t
5250	3	2026-03-02 20:31:16.422589	71.36	30.08	42.83	t	t	t
5326	4	2026-03-02 20:34:26.582568	25.03	60.18	24.21	t	t	t
5329	3	2026-03-02 20:34:36.56132	55.94	47.16	21.94	t	t	f
5394	4	2026-03-02 20:37:16.748664	15.15	48.75	22.78	t	t	t
5397	3	2026-03-02 20:37:26.726701	52.59	37.76	58.34	f	t	t
5403	4	2026-03-02 20:37:36.734187	28.71	79.45	59.04	t	t	t
3259	4	2026-03-02 19:08:02.633774	12.30	13.00	22.07	t	t	f
3260	2	2026-03-02 19:08:12.650622	23.02	12.20	42.31	t	t	t
3265	4	2026-03-02 19:08:22.656656	45.86	45.26	37.16	t	t	t
3269	4	2026-03-02 19:08:32.663435	27.32	22.07	26.26	f	t	t
3272	5	2026-03-02 19:08:42.670471	49.91	26.84	41.23	t	t	t
3278	4	2026-03-02 19:08:52.671704	46.42	71.38	57.29	t	t	t
3282	5	2026-03-02 19:09:02.680191	69.21	32.25	39.71	t	t	t
3284	2	2026-03-02 19:09:12.691005	27.79	37.14	32.96	t	t	t
3288	4	2026-03-02 19:09:22.697607	61.55	18.12	23.33	t	t	t
3295	5	2026-03-02 19:09:32.709737	17.27	65.83	67.35	t	t	f
3299	4	2026-03-02 19:09:42.714242	67.11	39.20	42.27	t	t	t
3302	3	2026-03-02 19:09:52.72829	32.04	44.46	27.34	t	t	t
3305	2	2026-03-02 19:10:02.736117	69.69	77.91	59.01	t	f	f
3311	4	2026-03-02 19:10:12.748668	45.09	57.13	22.24	t	t	t
3315	2	2026-03-02 19:10:22.748998	28.73	79.08	41.90	t	t	t
3317	4	2026-03-02 19:10:32.76433	18.33	40.27	58.79	t	t	t
3322	4	2026-03-02 19:10:42.778937	50.63	51.85	33.92	t	t	f
3326	4	2026-03-02 19:10:52.783185	43.55	40.82	28.53	t	t	t
3328	3	2026-03-02 19:11:02.792215	77.16	74.31	20.12	t	t	t
3335	3	2026-03-02 19:11:12.804459	32.23	74.85	66.49	t	t	f
3336	2	2026-03-02 19:11:22.802278	62.82	63.22	50.66	t	t	t
3343	5	2026-03-02 19:11:32.812117	43.39	12.64	44.60	t	f	t
3346	3	2026-03-02 19:11:42.817516	69.78	46.53	42.68	t	t	t
3348	2	2026-03-02 19:11:52.826311	33.78	53.83	44.23	t	t	t
3353	5	2026-03-02 19:12:02.83488	31.04	37.89	35.34	t	t	f
3359	3	2026-03-02 19:12:12.850688	48.08	26.32	62.69	t	t	t
3360	2	2026-03-02 19:12:22.851636	11.03	44.61	43.03	f	t	t
3365	5	2026-03-02 19:12:32.858771	10.57	48.39	27.82	t	t	f
3368	2	2026-03-02 19:12:42.859334	26.25	54.61	20.64	t	f	t
3372	5	2026-03-02 19:12:52.87389	31.82	68.61	67.20	t	t	t
3379	3	2026-03-02 19:13:02.880598	39.02	73.77	53.66	t	t	t
3381	3	2026-03-02 19:13:12.889661	60.28	22.01	20.90	t	t	t
3385	3	2026-03-02 19:13:22.892486	62.35	47.64	67.61	f	t	f
3390	4	2026-03-02 19:13:32.892988	63.64	47.04	34.98	t	t	f
3395	3	2026-03-02 19:13:42.891459	65.31	31.97	24.08	t	f	t
3398	3	2026-03-02 19:13:52.90798	28.06	73.66	56.15	t	t	t
3403	5	2026-03-02 19:14:02.919371	44.86	38.74	25.02	t	t	t
3404	3	2026-03-02 19:14:12.925327	62.01	45.05	23.57	t	t	t
3409	5	2026-03-02 19:14:22.931813	51.84	49.86	55.08	t	t	f
3413	2	2026-03-02 19:14:32.941274	68.99	37.76	53.60	t	t	t
3417	2	2026-03-02 19:14:42.945716	13.47	44.44	33.31	t	f	t
3420	2	2026-03-02 19:14:52.960504	38.15	69.71	51.50	t	t	t
3426	5	2026-03-02 19:15:02.960102	39.52	59.38	59.16	t	t	t
3430	4	2026-03-02 19:15:12.973704	53.23	19.35	65.56	t	t	f
3432	2	2026-03-02 19:15:22.978281	19.81	47.03	23.98	t	t	t
3437	4	2026-03-02 19:15:32.981118	34.86	47.56	43.13	t	t	t
3441	3	2026-03-02 19:15:42.976878	13.31	25.90	61.15	t	t	t
3446	4	2026-03-02 19:15:52.998373	47.75	40.53	29.53	t	t	t
3451	3	2026-03-02 19:16:03.00961	40.57	44.90	24.94	t	t	f
3453	2	2026-03-02 19:16:13.022314	78.09	58.54	57.57	t	f	t
3456	3	2026-03-02 19:16:23.022122	55.92	10.79	40.89	t	f	t
3461	5	2026-03-02 19:16:33.02871	22.70	77.54	61.83	t	t	t
3467	3	2026-03-02 19:16:43.041974	26.21	54.25	40.12	t	t	t
3471	4	2026-03-02 19:16:53.042388	69.00	57.27	38.05	t	t	t
3475	2	2026-03-02 19:17:03.052654	59.55	59.86	22.14	t	t	t
3476	2	2026-03-02 19:17:13.05762	18.23	17.67	22.17	t	t	t
3481	5	2026-03-02 19:17:23.07145	64.90	16.44	32.12	t	t	f
3485	2	2026-03-02 19:17:33.077305	18.00	46.69	30.62	t	t	f
3489	5	2026-03-02 19:17:43.090095	66.12	35.74	47.66	t	t	t
3494	4	2026-03-02 19:17:53.090613	56.94	44.99	21.59	t	t	t
3496	2	2026-03-02 19:18:03.105797	18.87	61.77	37.70	t	t	t
3500	2	2026-03-02 19:18:13.114967	38.85	75.83	41.64	t	t	t
3505	5	2026-03-02 19:18:23.119538	64.12	73.73	59.53	t	t	t
3508	2	2026-03-02 19:18:33.124842	11.79	78.09	69.27	t	t	f
3513	5	2026-03-02 19:18:43.138554	26.69	23.81	42.95	t	t	t
3518	4	2026-03-02 19:18:53.138224	70.86	69.91	35.36	t	t	t
3520	2	2026-03-02 19:19:03.135799	27.13	59.35	35.99	t	t	t
3524	2	2026-03-02 19:19:13.154629	30.41	28.32	34.75	t	t	t
3529	5	2026-03-02 19:19:23.166664	39.54	11.07	40.65	t	t	t
3534	5	2026-03-02 19:19:33.179086	31.62	18.82	31.78	t	t	t
3538	5	2026-03-02 19:19:43.185867	23.42	59.62	56.62	t	f	t
3542	5	2026-03-02 19:19:53.193675	48.26	67.11	54.16	f	t	t
3544	3	2026-03-02 19:20:03.201681	22.84	38.77	57.55	t	t	f
3548	4	2026-03-02 19:20:13.215178	79.21	44.32	31.44	t	f	t
3555	3	2026-03-02 19:20:23.227287	23.49	37.69	66.53	t	t	t
3556	2	2026-03-02 19:20:33.229439	23.55	75.25	50.83	t	t	t
3560	2	2026-03-02 19:20:43.231543	32.95	15.11	50.42	t	t	t
3561	3	2026-03-02 19:20:43.231669	78.90	69.25	30.62	t	t	f
3563	5	2026-03-02 19:20:43.232463	49.71	25.20	47.84	t	t	t
3562	4	2026-03-02 19:20:43.232267	46.11	38.95	46.13	t	t	t
3564	2	2026-03-02 19:20:53.237703	38.58	48.76	21.04	t	t	t
3565	5	2026-03-02 19:20:53.238168	41.06	31.00	53.70	t	t	t
3566	3	2026-03-02 19:20:53.23836	18.32	33.66	38.51	t	t	t
3567	4	2026-03-02 19:20:53.238693	26.42	76.13	27.60	t	t	t
3568	3	2026-03-02 19:21:03.233883	61.89	45.06	60.02	t	t	f
3569	5	2026-03-02 19:21:03.234154	14.25	51.02	35.73	t	t	t
3570	4	2026-03-02 19:21:03.234311	36.11	10.62	62.54	t	t	t
3571	2	2026-03-02 19:21:03.234615	67.62	76.69	63.71	t	t	f
3572	4	2026-03-02 19:21:13.244786	21.89	20.28	54.19	t	t	t
3573	3	2026-03-02 19:21:13.244961	65.59	20.43	23.22	t	t	t
3574	2	2026-03-02 19:21:13.245196	51.30	15.13	54.93	f	t	t
3575	5	2026-03-02 19:21:13.24549	62.79	67.63	30.89	t	t	t
3576	3	2026-03-02 19:21:23.245757	26.96	37.83	39.73	t	t	f
3577	4	2026-03-02 19:21:23.245971	58.79	55.19	32.79	t	t	t
3578	2	2026-03-02 19:21:23.24613	62.29	22.96	41.78	t	t	t
3579	5	2026-03-02 19:21:23.246408	14.39	52.87	44.61	t	t	t
3580	4	2026-03-02 19:21:33.249081	32.40	77.30	60.53	t	t	t
3581	2	2026-03-02 19:21:33.249886	52.32	13.09	46.62	t	t	t
3582	3	2026-03-02 19:21:33.250167	73.97	60.09	58.87	t	t	f
3583	5	2026-03-02 19:21:33.250394	16.55	76.77	58.57	t	t	t
3585	4	2026-03-02 19:21:43.263108	47.23	60.94	25.59	t	t	t
3584	5	2026-03-02 19:21:43.263202	32.00	75.25	58.79	t	f	t
3586	2	2026-03-02 19:21:43.263322	30.22	63.71	42.44	t	t	t
3587	3	2026-03-02 19:21:43.263527	63.59	33.26	39.61	t	t	t
3588	3	2026-03-02 19:21:53.262065	56.53	71.08	51.87	t	t	t
3589	2	2026-03-02 19:21:53.262222	72.26	12.34	47.98	t	t	t
3590	4	2026-03-02 19:21:53.262377	68.47	30.02	36.25	t	t	t
3591	5	2026-03-02 19:21:53.262669	26.75	31.45	52.17	t	f	t
3595	2	2026-03-02 19:22:03.262468	15.68	51.00	26.31	t	t	t
3599	4	2026-03-02 19:22:13.265284	51.46	36.88	69.84	t	t	f
3600	2	2026-03-02 19:22:23.265663	51.44	26.01	21.31	t	f	f
3605	5	2026-03-02 19:22:33.276524	73.28	67.78	32.54	t	f	t
3611	3	2026-03-02 19:22:43.29019	64.16	52.41	69.25	t	t	t
3613	2	2026-03-02 19:22:53.297231	23.27	63.26	54.45	t	t	f
3618	3	2026-03-02 19:23:03.311969	33.92	21.79	34.01	t	t	t
3620	2	2026-03-02 19:23:13.322745	56.99	58.87	48.80	t	t	t
3626	5	2026-03-02 19:23:23.328403	32.35	27.35	65.91	t	t	t
3630	3	2026-03-02 19:23:33.340489	24.71	22.40	32.10	t	t	f
3632	4	2026-03-02 19:23:43.341487	13.81	18.19	24.87	t	t	t
3637	5	2026-03-02 19:23:53.3474	59.67	73.44	25.24	t	t	t
3643	3	2026-03-02 19:24:03.346324	35.84	39.18	51.13	t	f	t
3646	3	2026-03-02 19:24:13.347698	29.24	10.79	63.11	t	t	t
3651	2	2026-03-02 19:24:23.351876	33.60	24.24	38.05	t	t	t
3653	4	2026-03-02 19:24:33.361179	19.41	35.53	66.01	t	t	f
3658	3	2026-03-02 19:24:43.361905	63.43	24.10	31.03	t	f	t
3660	2	2026-03-02 19:24:53.373604	12.54	15.46	24.72	t	t	f
3667	4	2026-03-02 19:25:03.37745	57.95	32.78	28.40	t	t	t
3669	4	2026-03-02 19:25:13.378879	53.69	64.20	51.57	t	f	t
3674	4	2026-03-02 19:25:23.391545	40.28	68.28	33.39	t	t	t
3677	5	2026-03-02 19:25:33.408643	15.65	64.18	34.65	t	t	t
3680	5	2026-03-02 19:25:43.416241	50.13	32.86	68.11	t	t	t
3685	5	2026-03-02 19:25:53.423352	33.36	12.42	68.68	t	t	t
3691	4	2026-03-02 19:26:03.430295	29.68	54.76	63.48	t	t	f
3694	4	2026-03-02 19:26:13.444411	59.64	12.54	30.26	t	t	t
3698	4	2026-03-02 19:26:23.451935	30.90	32.41	60.48	t	t	t
3703	2	2026-03-02 19:26:33.460147	22.64	30.10	28.52	t	t	t
3706	2	2026-03-02 19:26:43.468345	73.32	69.04	44.84	t	t	t
3711	3	2026-03-02 19:26:53.475838	77.91	40.96	66.99	t	t	t
3715	3	2026-03-02 19:27:03.493117	79.00	34.83	58.26	t	t	t
3718	4	2026-03-02 19:27:13.495769	69.53	26.30	50.11	t	t	t
3720	3	2026-03-02 19:27:23.50887	65.07	16.66	50.57	t	t	t
3726	4	2026-03-02 19:27:33.526308	61.50	72.20	51.67	t	t	t
3730	3	2026-03-02 19:27:43.531636	19.97	27.16	62.62	f	t	f
3735	4	2026-03-02 19:27:53.541063	45.44	25.28	55.49	t	t	t
3739	2	2026-03-02 19:28:03.551787	52.67	35.76	59.67	t	t	f
3740	2	2026-03-02 19:28:13.557076	70.04	38.87	52.43	t	t	f
3747	2	2026-03-02 19:28:23.560157	10.19	25.10	46.99	t	t	t
3750	4	2026-03-02 19:28:33.56675	46.38	46.97	23.38	t	t	t
3752	3	2026-03-02 19:28:43.568485	62.02	78.02	64.14	t	t	t
3757	5	2026-03-02 19:28:53.585672	53.87	69.55	63.17	t	t	t
3761	2	2026-03-02 19:29:03.594799	27.25	25.22	27.91	t	f	t
3765	3	2026-03-02 19:29:13.605011	18.29	67.11	56.21	t	t	t
3769	3	2026-03-02 19:29:23.60257	43.94	79.04	64.96	t	t	t
3772	4	2026-03-02 19:29:33.610261	32.98	65.08	41.77	t	t	t
3777	3	2026-03-02 19:29:43.619754	43.11	32.73	37.72	t	t	t
3783	4	2026-03-02 19:29:53.635081	15.14	51.28	42.12	t	t	t
4669	3	2026-03-02 20:06:55.418736	77.15	70.55	21.14	t	t	t
4672	3	2026-03-02 20:07:05.399363	72.86	32.34	60.10	t	t	t
4679	4	2026-03-02 20:07:15.400986	55.71	52.75	21.77	t	t	t
4731	5	2026-03-02 20:09:25.559611	19.26	49.62	52.92	t	t	t
4732	2	2026-03-02 20:09:35.530575	30.82	29.81	37.30	t	t	t
4738	5	2026-03-02 20:09:45.531757	76.33	20.23	31.08	t	t	t
4740	2	2026-03-02 20:09:55.534917	61.29	45.81	43.83	t	t	t
4797	3	2026-03-02 20:12:25.707029	33.59	14.75	67.60	t	t	t
4801	4	2026-03-02 20:12:35.636956	24.96	15.78	61.76	t	t	t
4806	4	2026-03-02 20:12:45.647915	49.49	49.32	20.56	t	t	t
4811	3	2026-03-02 20:12:55.652452	63.56	54.78	68.72	t	f	t
4812	2	2026-03-02 20:13:05.650934	65.81	62.47	66.16	t	t	t
4819	5	2026-03-02 20:13:15.651942	15.72	18.84	26.60	t	t	t
4820	2	2026-03-02 20:13:25.664497	70.64	32.80	68.07	t	t	t
4827	5	2026-03-02 20:13:35.671662	37.81	67.45	20.42	t	t	t
4829	2	2026-03-02 20:13:45.674123	31.28	13.19	37.61	t	t	f
4890	4	2026-03-02 20:16:15.831722	21.37	60.52	20.84	t	t	t
4893	3	2026-03-02 20:16:25.808336	20.23	10.44	24.40	t	t	t
4955	5	2026-03-02 20:18:55.95861	13.21	69.49	43.07	t	f	t
5010	4	2026-03-02 20:21:16.082456	17.85	20.99	48.32	t	t	t
5014	3	2026-03-02 20:21:26.052413	77.21	12.84	46.02	t	t	f
5102	3	2026-03-02 20:25:06.261802	56.43	35.42	37.61	t	f	t
5106	4	2026-03-02 20:25:16.232676	51.93	74.04	53.96	t	t	f
5195	5	2026-03-02 20:28:56.384061	14.64	20.30	50.96	t	t	f
5196	2	2026-03-02 20:29:06.360588	64.78	38.53	50.25	t	t	t
5247	5	2026-03-02 20:31:06.457528	57.80	63.03	45.70	t	t	t
5248	2	2026-03-02 20:31:16.422146	47.22	72.84	35.82	t	t	t
5327	5	2026-03-02 20:34:26.58322	37.26	30.06	49.09	t	f	t
5328	2	2026-03-02 20:34:36.56074	38.56	17.05	41.23	t	f	t
5395	5	2026-03-02 20:37:16.75008	45.21	17.42	69.28	t	t	f
5396	2	2026-03-02 20:37:26.726407	59.86	56.11	21.45	t	t	t
5401	5	2026-03-02 20:37:36.733605	23.49	28.94	49.92	t	t	t
5404	3	2026-03-02 20:37:46.736411	45.70	40.57	26.45	t	t	t
5463	4	2026-03-02 20:40:07.010755	41.43	50.22	40.01	t	t	t
5531	4	2026-03-02 20:42:57.162969	45.89	61.37	64.70	t	t	t
5532	2	2026-03-02 20:43:07.04019	11.47	34.47	57.41	t	t	t
5537	4	2026-03-02 20:43:17.047995	63.99	20.03	20.32	t	t	t
5594	5	2026-03-02 20:45:37.22033	22.82	74.00	47.22	t	t	t
5658	4	2026-03-02 20:48:17.313885	52.25	71.76	24.81	t	t	t
5660	2	2026-03-02 20:48:27.283836	52.15	56.38	58.78	t	f	t
5667	5	2026-03-02 20:48:37.280712	68.13	13.55	50.37	t	t	t
5669	3	2026-03-02 20:48:47.288403	69.51	24.77	42.47	t	t	t
5674	4	2026-03-02 20:48:57.294325	26.41	46.46	51.65	t	t	f
5727	5	2026-03-02 20:51:07.425905	74.03	40.20	35.51	t	t	t
5730	3	2026-03-02 20:51:17.395361	70.04	46.30	55.10	t	t	f
5779	5	2026-03-02 20:53:17.663535	60.56	60.54	25.94	f	f	t
5780	2	2026-03-02 20:53:27.522014	45.75	24.95	62.43	t	f	t
5863	5	2026-03-02 20:56:47.700175	79.32	39.66	43.50	t	t	t
5864	2	2026-03-02 20:56:57.66149	36.84	44.45	67.13	t	t	t
5921	3	2026-03-02 20:59:17.815932	70.04	70.21	41.84	t	t	t
5925	2	2026-03-02 20:59:27.789915	22.80	45.94	46.80	t	t	t
5979	5	2026-03-02 21:01:37.926489	26.14	34.60	60.18	t	f	t
5980	2	2026-03-02 21:01:47.88574	39.42	55.95	23.24	t	t	t
5985	5	2026-03-02 21:01:57.885627	62.06	56.88	64.56	t	t	t
6038	5	2026-03-02 21:04:08.029432	61.45	42.52	61.88	t	t	t
6040	3	2026-03-02 21:04:18.009955	15.47	52.36	24.08	t	t	t
6045	5	2026-03-02 21:04:28.002774	78.07	62.55	40.01	t	t	t
6048	3	2026-03-02 21:04:38.00638	75.59	42.98	37.08	t	t	t
3592	4	2026-03-02 19:22:03.261062	78.53	21.88	37.80	t	t	t
3598	5	2026-03-02 19:22:13.265209	45.67	49.73	40.61	t	t	t
3602	4	2026-03-02 19:22:23.266087	64.61	42.69	30.76	t	t	t
3604	2	2026-03-02 19:22:33.276291	34.68	71.61	34.11	t	t	f
3610	2	2026-03-02 19:22:43.289783	26.46	62.04	47.76	t	t	t
3614	5	2026-03-02 19:22:53.297386	45.18	48.46	24.07	t	t	t
3617	5	2026-03-02 19:23:03.311795	11.84	59.48	24.60	t	t	t
3622	5	2026-03-02 19:23:13.323296	68.83	37.20	69.34	t	t	t
3625	3	2026-03-02 19:23:23.328479	37.30	37.84	20.16	t	t	t
3629	5	2026-03-02 19:23:33.340251	62.55	66.64	35.16	t	t	t
3634	3	2026-03-02 19:23:43.342011	34.74	47.20	69.78	t	t	t
3639	4	2026-03-02 19:23:53.347842	59.57	11.78	57.30	t	t	t
3640	4	2026-03-02 19:24:03.345621	48.00	13.73	22.10	t	t	f
3647	4	2026-03-02 19:24:13.348003	47.64	16.98	63.48	t	t	t
3648	4	2026-03-02 19:24:23.351194	66.22	12.66	58.52	t	t	f
3655	5	2026-03-02 19:24:33.361344	15.15	50.00	54.60	t	t	t
3656	2	2026-03-02 19:24:43.361496	64.06	13.59	66.89	t	t	t
3661	5	2026-03-02 19:24:53.373856	51.33	64.37	65.52	t	t	t
3666	5	2026-03-02 19:25:03.377217	67.88	44.63	21.24	t	f	t
3671	3	2026-03-02 19:25:13.379343	27.13	75.35	47.72	t	t	t
3675	5	2026-03-02 19:25:23.391834	56.48	19.40	36.29	t	f	t
3679	4	2026-03-02 19:25:33.409199	28.55	60.78	49.66	t	t	t
3682	2	2026-03-02 19:25:43.416771	69.33	43.91	69.49	t	t	f
3684	3	2026-03-02 19:25:53.423091	29.68	56.15	42.34	t	t	t
3690	3	2026-03-02 19:26:03.429786	41.04	46.56	27.18	f	t	t
3692	2	2026-03-02 19:26:13.443822	75.64	61.40	44.22	t	t	t
3697	5	2026-03-02 19:26:23.451758	30.43	77.90	24.73	t	t	t
3702	4	2026-03-02 19:26:33.460002	43.22	19.19	35.97	t	f	t
3707	4	2026-03-02 19:26:43.468634	70.80	32.40	24.46	t	t	f
3710	2	2026-03-02 19:26:53.475706	70.17	14.34	50.38	t	t	t
3712	2	2026-03-02 19:27:03.492282	33.66	67.34	34.78	t	t	t
3717	5	2026-03-02 19:27:13.495522	63.15	45.18	33.64	t	t	t
3722	2	2026-03-02 19:27:23.50989	35.43	59.23	64.23	t	t	t
3725	5	2026-03-02 19:27:33.526103	38.66	52.62	60.86	t	t	t
3728	2	2026-03-02 19:27:43.531146	40.82	36.37	48.47	t	t	t
3733	5	2026-03-02 19:27:53.540628	66.03	15.31	23.20	t	t	t
3737	5	2026-03-02 19:28:03.551659	44.67	16.78	51.28	t	t	t
3743	3	2026-03-02 19:28:13.557726	13.86	33.18	66.56	t	t	t
3746	5	2026-03-02 19:28:23.559854	35.80	42.49	43.52	t	t	t
3748	3	2026-03-02 19:28:33.566367	58.01	30.11	45.82	f	f	t
3753	5	2026-03-02 19:28:43.568744	39.99	15.32	39.57	t	t	t
3758	3	2026-03-02 19:28:53.585764	38.38	46.44	20.24	t	f	t
3763	4	2026-03-02 19:29:03.59532	69.77	24.80	28.10	t	t	t
3764	2	2026-03-02 19:29:13.604839	17.17	49.78	61.89	t	f	f
3771	4	2026-03-02 19:29:23.603339	41.54	70.55	39.10	t	t	t
3775	2	2026-03-02 19:29:33.611328	36.90	46.47	47.66	t	t	t
3776	2	2026-03-02 19:29:43.619471	16.75	61.25	31.89	t	f	t
3782	5	2026-03-02 19:29:53.634869	55.88	76.32	35.23	t	t	t
3784	3	2026-03-02 19:30:03.638732	10.53	11.95	51.63	t	t	f
3789	4	2026-03-02 19:30:13.643926	29.42	29.97	57.39	t	t	t
3793	3	2026-03-02 19:30:23.65486	54.35	78.95	45.64	f	t	t
3799	3	2026-03-02 19:30:33.680052	66.56	57.56	51.86	t	t	t
3800	2	2026-03-02 19:30:43.683153	65.90	63.84	68.96	f	t	t
3805	5	2026-03-02 19:30:53.685257	23.49	43.25	52.49	t	t	t
3808	3	2026-03-02 19:31:03.692594	31.18	56.15	54.37	t	t	f
3813	5	2026-03-02 19:31:13.692132	17.47	15.62	47.51	t	t	t
3816	2	2026-03-02 19:31:23.693766	73.86	76.46	48.91	f	t	t
3822	4	2026-03-02 19:31:33.707366	51.57	23.42	31.13	t	t	t
3824	2	2026-03-02 19:31:43.711685	17.97	65.64	67.51	t	t	f
3830	3	2026-03-02 19:31:53.713856	61.67	46.64	38.26	t	t	f
3835	4	2026-03-02 19:32:03.713103	23.93	28.56	64.02	t	f	f
3839	3	2026-03-02 19:32:13.727511	63.96	27.46	68.70	t	t	t
3840	3	2026-03-02 19:32:23.745128	66.12	58.81	43.26	f	t	t
3844	3	2026-03-02 19:32:33.746711	54.77	16.70	32.27	t	t	f
3851	4	2026-03-02 19:32:43.75599	14.65	69.49	45.10	t	t	t
3853	4	2026-03-02 19:32:53.755967	27.41	20.35	29.97	t	t	t
3857	3	2026-03-02 19:33:03.755516	24.86	10.48	47.99	t	t	t
3861	5	2026-03-02 19:33:13.760848	19.90	60.67	36.91	t	t	t
3865	5	2026-03-02 19:33:23.760995	61.09	55.80	44.62	t	t	t
4670	5	2026-03-02 20:06:55.423739	36.20	59.58	60.24	t	t	t
4673	2	2026-03-02 20:07:05.399519	52.99	77.40	66.92	t	t	t
4677	2	2026-03-02 20:07:15.400583	25.71	65.58	66.45	t	t	f
4745	3	2026-03-02 20:10:05.578757	12.35	15.85	36.63	t	t	t
4750	4	2026-03-02 20:10:15.557383	76.96	52.50	58.04	t	t	f
4798	4	2026-03-02 20:12:25.710124	34.08	23.85	56.72	t	t	t
4802	3	2026-03-02 20:12:35.637156	17.94	27.20	63.33	t	t	t
4805	3	2026-03-02 20:12:45.647024	32.04	35.91	62.13	t	t	t
4810	4	2026-03-02 20:12:55.65198	57.34	58.04	25.26	t	t	t
4813	4	2026-03-02 20:13:05.651176	27.32	24.57	41.54	t	t	t
4818	4	2026-03-02 20:13:15.651601	33.52	30.59	30.72	t	t	f
4821	3	2026-03-02 20:13:25.664684	44.26	72.83	23.79	t	t	t
4826	4	2026-03-02 20:13:35.671076	28.78	44.11	49.53	t	t	t
4828	3	2026-03-02 20:13:45.674254	27.22	27.31	31.99	t	t	t
4891	5	2026-03-02 20:16:15.837084	35.16	65.36	68.58	t	t	f
4892	2	2026-03-02 20:16:25.807649	73.85	13.33	21.15	t	t	t
4956	2	2026-03-02 20:19:05.925853	77.83	38.81	42.33	t	t	t
5011	5	2026-03-02 20:21:16.192799	15.02	54.69	35.56	t	f	t
5012	2	2026-03-02 20:21:26.051229	71.32	41.10	30.30	t	t	t
5101	4	2026-03-02 20:25:06.26174	66.70	69.89	25.18	t	t	t
5105	3	2026-03-02 20:25:16.232442	51.63	37.88	52.03	t	t	f
5198	4	2026-03-02 20:29:06.392501	60.69	18.30	57.08	t	t	t
5201	3	2026-03-02 20:29:16.364105	38.57	28.83	41.19	t	t	t
5254	4	2026-03-02 20:31:26.46489	65.17	31.96	65.69	t	t	t
5258	3	2026-03-02 20:31:36.43423	70.03	65.29	22.68	t	t	t
5330	5	2026-03-02 20:34:36.592639	46.06	20.03	28.43	t	t	t
5333	3	2026-03-02 20:34:46.570771	53.17	28.11	27.45	t	t	t
5337	5	2026-03-02 20:34:56.573962	64.67	21.80	54.19	t	t	t
5398	4	2026-03-02 20:37:26.755838	79.59	78.79	68.89	t	f	t
5402	3	2026-03-02 20:37:36.733799	17.38	11.13	25.72	t	f	t
5406	4	2026-03-02 20:37:46.737243	45.34	25.74	54.80	t	t	f
5408	2	2026-03-02 20:37:56.74681	52.43	62.80	56.31	t	t	t
5466	4	2026-03-02 20:40:16.914638	76.10	75.38	30.76	t	t	t
5471	3	2026-03-02 20:40:26.884853	28.19	17.19	57.72	t	t	t
5472	2	2026-03-02 20:40:36.89693	47.52	66.44	45.38	t	t	t
5535	5	2026-03-02 20:43:07.070576	11.40	79.90	67.96	t	t	t
5595	4	2026-03-02 20:45:37.22057	62.14	48.32	61.55	t	t	t
5596	4	2026-03-02 20:45:47.184862	13.03	10.01	52.53	f	t	f
3593	3	2026-03-02 19:22:03.262028	21.42	26.95	30.43	t	t	t
3597	3	2026-03-02 19:22:13.265009	50.79	73.72	50.24	t	t	f
3603	3	2026-03-02 19:22:23.26637	59.25	66.02	33.70	t	t	t
3606	4	2026-03-02 19:22:33.276692	58.72	48.09	61.56	t	f	f
3608	4	2026-03-02 19:22:43.288657	55.83	39.08	65.13	t	t	t
3615	3	2026-03-02 19:22:53.297664	35.71	38.71	37.14	t	t	t
3619	2	2026-03-02 19:23:03.312256	31.22	31.25	66.30	t	t	t
3623	3	2026-03-02 19:23:13.323565	21.30	57.65	46.71	t	t	t
3627	2	2026-03-02 19:23:23.328398	53.08	26.98	39.00	t	t	f
3628	4	2026-03-02 19:23:33.34011	55.40	38.99	30.43	t	t	t
3633	5	2026-03-02 19:23:43.341757	70.58	60.75	48.52	t	t	t
3638	3	2026-03-02 19:23:53.347661	21.05	46.83	50.87	t	t	t
3642	2	2026-03-02 19:24:03.346164	59.79	37.47	46.10	t	t	t
3644	2	2026-03-02 19:24:13.347364	21.63	65.21	61.42	f	t	t
3649	5	2026-03-02 19:24:23.351438	45.76	48.47	39.18	t	t	t
3652	2	2026-03-02 19:24:33.361075	68.12	12.57	50.99	t	t	t
3657	5	2026-03-02 19:24:43.361734	27.55	63.99	24.21	t	t	t
3663	3	2026-03-02 19:24:53.374287	29.08	40.36	22.12	t	t	t
3664	2	2026-03-02 19:25:03.376807	27.96	25.55	34.84	t	t	f
3670	5	2026-03-02 19:25:13.379152	53.59	12.97	22.45	t	f	t
3672	2	2026-03-02 19:25:23.391209	51.74	34.11	43.89	t	f	t
3676	3	2026-03-02 19:25:33.408412	51.78	36.91	52.71	t	t	t
3681	4	2026-03-02 19:25:43.416573	24.72	44.72	60.82	t	t	t
3686	4	2026-03-02 19:25:53.423522	10.60	49.35	25.29	t	t	t
3688	2	2026-03-02 19:26:03.429242	78.21	40.27	32.98	t	f	t
3693	5	2026-03-02 19:26:13.444177	26.96	62.18	48.96	t	t	t
3699	2	2026-03-02 19:26:23.452204	69.74	68.97	21.26	f	t	t
3700	3	2026-03-02 19:26:33.459551	59.66	25.90	26.83	t	f	t
3704	3	2026-03-02 19:26:43.467777	60.70	57.09	34.38	t	t	t
3709	5	2026-03-02 19:26:53.475377	66.52	30.49	46.52	t	t	t
3714	5	2026-03-02 19:27:03.49281	37.51	64.42	36.90	t	t	t
3716	3	2026-03-02 19:27:13.495372	77.16	50.19	36.55	t	t	t
3721	5	2026-03-02 19:27:23.509644	58.51	72.67	21.74	t	t	f
3727	3	2026-03-02 19:27:33.526565	28.07	52.51	47.28	t	t	f
3731	4	2026-03-02 19:27:43.531937	56.23	12.28	61.44	t	t	t
3734	3	2026-03-02 19:27:53.540921	51.79	78.20	47.53	t	t	t
3738	4	2026-03-02 19:28:03.551864	13.43	68.13	58.09	t	t	t
3741	5	2026-03-02 19:28:13.557277	43.90	22.42	50.47	t	t	t
3745	3	2026-03-02 19:28:23.559696	60.33	61.42	45.36	t	t	t
3749	2	2026-03-02 19:28:33.566593	62.12	42.93	54.70	f	t	t
3755	2	2026-03-02 19:28:43.569164	26.24	44.75	23.62	t	t	t
3759	4	2026-03-02 19:28:53.586074	79.94	61.17	31.53	t	t	f
3760	3	2026-03-02 19:29:03.594209	45.16	62.52	54.71	t	t	t
3766	5	2026-03-02 19:29:13.605305	34.50	63.33	37.79	t	t	t
3768	2	2026-03-02 19:29:23.602259	33.73	28.91	22.28	t	f	t
3774	5	2026-03-02 19:29:33.61081	62.42	75.58	40.19	t	t	t
3778	4	2026-03-02 19:29:43.62014	73.04	15.10	25.90	t	t	t
3780	3	2026-03-02 19:29:53.634397	29.19	77.09	64.18	t	t	t
3785	4	2026-03-02 19:30:03.638969	57.14	75.61	59.38	t	t	t
3790	5	2026-03-02 19:30:13.643887	68.89	28.43	56.15	t	t	t
3794	5	2026-03-02 19:30:23.654993	39.02	75.37	50.85	t	t	t
3796	2	2026-03-02 19:30:33.679648	55.40	19.40	40.67	t	t	t
3803	5	2026-03-02 19:30:43.683776	67.52	51.46	37.65	t	t	t
3807	3	2026-03-02 19:30:53.68541	12.93	40.68	62.24	t	t	t
3809	4	2026-03-02 19:31:03.693299	31.17	68.30	64.02	t	t	t
3815	3	2026-03-02 19:31:13.692557	20.61	77.66	20.75	t	f	t
3817	4	2026-03-02 19:31:23.694104	37.44	72.71	62.22	t	f	t
3820	3	2026-03-02 19:31:33.706378	70.45	69.98	50.67	t	t	f
3825	5	2026-03-02 19:31:43.712417	60.05	68.63	42.86	t	t	f
3831	4	2026-03-02 19:31:53.71411	51.24	30.91	31.30	t	t	t
3832	2	2026-03-02 19:32:03.71261	57.81	40.26	58.76	t	t	t
3837	5	2026-03-02 19:32:13.726918	14.58	78.49	27.84	t	t	t
3843	4	2026-03-02 19:32:23.745752	23.89	70.31	53.42	t	t	t
3846	4	2026-03-02 19:32:33.747031	19.25	76.69	23.21	t	t	t
3849	2	2026-03-02 19:32:43.755541	68.82	32.46	26.86	t	t	t
3854	3	2026-03-02 19:32:53.756166	37.54	76.41	56.40	t	t	t
3858	4	2026-03-02 19:33:03.75618	25.75	60.29	24.10	t	t	t
3863	3	2026-03-02 19:33:13.761175	59.43	54.48	65.38	t	t	f
3866	4	2026-03-02 19:33:23.761339	11.42	38.35	63.93	t	t	t
3868	2	2026-03-02 19:33:33.773052	47.64	64.52	49.25	t	t	f
4671	4	2026-03-02 20:06:55.531222	23.08	20.16	57.37	t	t	t
4674	4	2026-03-02 20:07:05.399435	48.93	10.79	36.08	t	t	f
4676	5	2026-03-02 20:07:15.400155	38.07	20.69	27.76	t	t	t
4746	4	2026-03-02 20:10:05.580801	29.00	31.42	63.25	t	f	t
4749	3	2026-03-02 20:10:15.556875	44.84	76.92	68.53	t	t	t
4799	5	2026-03-02 20:12:25.717439	42.02	41.63	29.28	t	t	t
4800	2	2026-03-02 20:12:35.636505	18.04	36.71	66.21	t	t	t
4807	5	2026-03-02 20:12:45.648549	12.42	76.72	30.50	t	t	f
4808	2	2026-03-02 20:12:55.651099	12.79	48.08	67.00	t	t	t
4815	5	2026-03-02 20:13:05.651611	13.28	41.87	38.23	t	t	t
4816	2	2026-03-02 20:13:15.650774	48.18	65.93	67.12	t	t	t
4895	5	2026-03-02 20:16:25.864497	23.41	20.66	47.91	t	t	t
4957	5	2026-03-02 20:19:05.926834	78.93	57.99	20.06	t	t	f
5017	3	2026-03-02 20:21:36.107193	45.42	78.06	25.22	t	t	f
5023	4	2026-03-02 20:21:46.065526	67.27	66.23	38.68	t	t	f
5103	5	2026-03-02 20:25:06.264142	47.43	47.37	38.32	t	t	t
5104	2	2026-03-02 20:25:16.232013	67.08	23.87	63.41	t	t	t
5199	5	2026-03-02 20:29:06.395378	46.36	37.49	37.40	t	t	t
5255	5	2026-03-02 20:31:26.466713	75.90	20.68	28.43	t	t	t
5256	2	2026-03-02 20:31:36.433307	65.93	58.46	34.96	t	t	t
5331	4	2026-03-02 20:34:36.698693	45.89	12.64	54.92	t	t	t
5332	2	2026-03-02 20:34:46.57049	73.05	74.68	31.24	t	t	t
5338	4	2026-03-02 20:34:56.574337	28.70	57.83	44.99	t	t	t
5399	5	2026-03-02 20:37:26.756094	20.24	11.12	56.28	t	t	t
5400	2	2026-03-02 20:37:36.733162	21.94	78.62	60.03	t	t	t
5407	5	2026-03-02 20:37:46.737421	18.62	69.97	48.48	f	t	t
5467	5	2026-03-02 20:40:16.915285	71.86	66.35	67.24	t	t	t
5468	2	2026-03-02 20:40:26.884461	33.69	58.07	22.22	t	t	t
5539	5	2026-03-02 20:43:17.081226	50.58	66.72	41.58	f	t	f
5540	2	2026-03-02 20:43:27.056586	52.01	41.23	28.44	t	t	t
5597	2	2026-03-02 20:45:47.185205	35.96	66.16	22.65	t	t	t
5659	5	2026-03-02 20:48:17.424257	12.60	54.60	27.10	f	f	t
5663	3	2026-03-02 20:48:27.284837	62.07	38.70	39.68	t	t	t
5666	4	2026-03-02 20:48:37.280601	32.36	16.92	50.81	t	t	t
5668	2	2026-03-02 20:48:47.28802	28.33	67.77	64.25	t	t	t
5673	5	2026-03-02 20:48:57.29409	64.88	14.83	69.03	t	t	t
5731	5	2026-03-02 20:51:17.427007	55.52	47.63	60.57	t	t	t
3594	5	2026-03-02 19:22:03.262179	79.26	30.51	29.52	t	t	t
3596	2	2026-03-02 19:22:13.264817	58.04	74.57	62.15	t	t	f
3601	5	2026-03-02 19:22:23.265917	27.75	66.58	30.78	t	t	t
3607	3	2026-03-02 19:22:33.276985	24.55	53.15	37.12	t	t	t
3609	5	2026-03-02 19:22:43.289475	79.57	60.84	50.66	t	t	f
3612	4	2026-03-02 19:22:53.296915	53.15	58.28	41.29	t	t	t
3616	4	2026-03-02 19:23:03.311537	77.38	53.33	23.71	t	t	t
3621	4	2026-03-02 19:23:13.323048	11.79	19.79	57.16	t	t	t
3624	4	2026-03-02 19:23:23.328424	75.88	71.55	32.72	t	t	t
3631	2	2026-03-02 19:23:33.340811	31.63	66.08	69.16	t	t	t
3635	2	2026-03-02 19:23:43.342326	68.47	68.25	37.53	t	t	t
3636	2	2026-03-02 19:23:53.346766	78.57	26.68	60.72	t	t	t
3641	5	2026-03-02 19:24:03.345846	72.50	47.94	48.31	t	f	t
3645	5	2026-03-02 19:24:13.347552	40.12	75.07	30.21	t	t	t
3650	3	2026-03-02 19:24:23.351587	59.34	55.71	60.19	f	t	t
3654	3	2026-03-02 19:24:33.361265	23.60	39.18	50.50	t	t	f
3659	4	2026-03-02 19:24:43.362187	77.69	48.37	29.23	t	t	t
3662	4	2026-03-02 19:24:53.374028	54.12	79.42	55.63	t	t	f
3665	3	2026-03-02 19:25:03.377052	37.71	51.92	65.29	t	t	t
3668	2	2026-03-02 19:25:13.378649	72.33	56.61	55.82	t	t	t
3673	3	2026-03-02 19:25:23.391394	43.99	62.29	52.06	t	t	t
3678	2	2026-03-02 19:25:33.408883	23.36	45.32	34.37	t	t	t
3683	3	2026-03-02 19:25:43.417099	23.86	20.31	67.51	t	t	f
3687	2	2026-03-02 19:25:53.423799	66.26	11.54	42.07	f	t	f
3689	5	2026-03-02 19:26:03.429625	50.12	74.03	63.70	t	t	t
3695	3	2026-03-02 19:26:13.444745	72.16	38.09	49.96	t	t	t
3696	3	2026-03-02 19:26:23.4515	74.60	50.61	25.03	t	t	t
3701	5	2026-03-02 19:26:33.459712	35.88	66.57	59.22	t	t	t
3705	5	2026-03-02 19:26:43.468063	55.13	11.88	67.52	t	t	t
3708	4	2026-03-02 19:26:53.475228	43.67	61.57	49.11	t	t	f
3713	4	2026-03-02 19:27:03.492658	30.41	63.81	29.03	t	f	t
3719	2	2026-03-02 19:27:13.495992	44.55	42.92	61.35	t	t	t
3723	4	2026-03-02 19:27:23.510187	45.87	20.51	41.92	t	t	t
3724	2	2026-03-02 19:27:33.525565	25.60	77.10	49.32	t	t	t
3729	5	2026-03-02 19:27:43.531499	78.25	20.97	27.27	t	t	f
3732	2	2026-03-02 19:27:53.540463	23.90	47.92	54.91	t	t	f
3736	3	2026-03-02 19:28:03.551269	34.42	59.45	22.94	t	t	t
3742	4	2026-03-02 19:28:13.557438	17.20	54.11	56.96	f	t	t
3744	4	2026-03-02 19:28:23.559446	36.14	74.06	48.96	t	t	t
3751	5	2026-03-02 19:28:33.567027	11.66	32.43	41.50	t	t	t
3754	4	2026-03-02 19:28:43.568906	69.47	56.42	61.64	t	t	t
3756	2	2026-03-02 19:28:53.585022	18.12	57.60	36.78	t	t	t
3762	5	2026-03-02 19:29:03.594545	48.32	54.49	67.75	t	t	t
3767	4	2026-03-02 19:29:13.605531	50.17	25.56	25.82	t	t	t
3770	5	2026-03-02 19:29:23.603213	10.02	77.08	64.95	t	f	t
3773	3	2026-03-02 19:29:33.610381	27.49	36.78	39.04	t	t	t
3779	5	2026-03-02 19:29:43.619986	76.99	47.19	42.69	t	t	t
3781	2	2026-03-02 19:29:53.634704	36.45	72.46	44.79	t	t	t
3786	2	2026-03-02 19:30:03.639117	71.45	25.04	20.21	t	t	t
3791	2	2026-03-02 19:30:13.643978	53.91	17.43	56.58	t	t	t
3792	4	2026-03-02 19:30:23.654541	29.61	78.83	52.23	t	t	t
3797	5	2026-03-02 19:30:33.679806	77.08	53.68	34.41	t	t	t
3801	4	2026-03-02 19:30:43.683307	73.95	57.58	36.67	t	t	t
3806	4	2026-03-02 19:30:53.685343	37.94	29.62	62.65	t	t	t
3811	2	2026-03-02 19:31:03.693533	28.84	55.93	59.94	t	t	t
3814	4	2026-03-02 19:31:13.692289	58.88	12.72	58.69	t	t	t
3818	3	2026-03-02 19:31:23.694302	33.89	79.72	52.40	t	t	t
3821	5	2026-03-02 19:31:33.707125	67.88	40.86	41.75	t	t	t
3827	4	2026-03-02 19:31:43.712707	51.47	39.15	64.25	t	t	t
3828	2	2026-03-02 19:31:53.713442	57.06	51.71	58.32	t	t	t
3834	3	2026-03-02 19:32:03.712997	49.15	47.70	40.11	t	t	t
3838	4	2026-03-02 19:32:13.72721	29.39	42.60	67.59	t	t	t
3841	2	2026-03-02 19:32:23.745306	18.56	60.44	49.81	f	t	t
3845	5	2026-03-02 19:32:33.746879	13.27	48.18	46.54	t	f	t
3850	5	2026-03-02 19:32:43.755692	60.40	53.18	68.47	t	t	f
3852	2	2026-03-02 19:32:53.755467	78.21	46.78	53.32	t	f	f
3859	5	2026-03-02 19:33:03.756345	37.88	56.94	40.08	t	t	t
3860	2	2026-03-02 19:33:13.760697	38.97	61.02	47.28	t	t	t
3867	2	2026-03-02 19:33:23.761514	11.18	25.22	32.79	t	t	t
4675	5	2026-03-02 20:07:05.431011	47.14	46.90	53.88	t	t	t
4678	3	2026-03-02 20:07:15.400746	28.36	17.98	31.94	t	t	f
4680	2	2026-03-02 20:07:25.416823	67.51	42.10	20.16	t	t	t
4747	5	2026-03-02 20:10:05.581974	34.54	30.18	51.33	t	t	f
4748	2	2026-03-02 20:10:15.55665	73.10	29.46	54.30	t	t	t
4822	4	2026-03-02 20:13:25.69866	71.41	37.68	27.52	t	t	t
4825	3	2026-03-02 20:13:35.670628	34.58	51.32	68.86	t	t	t
4830	4	2026-03-02 20:13:45.674525	11.40	43.74	35.22	t	t	t
4896	2	2026-03-02 20:16:35.804222	42.86	52.51	64.66	t	t	t
4903	5	2026-03-02 20:16:45.80992	39.87	55.79	68.69	t	t	t
4958	3	2026-03-02 20:19:05.92717	69.38	76.31	66.08	t	t	t
5018	4	2026-03-02 20:21:36.111483	27.68	64.10	38.93	t	f	t
5022	3	2026-03-02 20:21:46.065457	50.06	16.86	23.63	t	t	t
5024	2	2026-03-02 20:21:56.072222	70.30	73.45	45.94	t	f	t
5107	5	2026-03-02 20:25:16.26737	70.62	30.12	47.73	t	t	t
5108	2	2026-03-02 20:25:26.243542	10.24	15.30	36.65	t	t	t
5115	5	2026-03-02 20:25:36.24608	18.16	79.89	33.76	t	t	t
5116	2	2026-03-02 20:25:46.255578	14.67	76.33	23.26	t	t	f
5200	2	2026-03-02 20:29:16.363854	18.31	48.64	63.76	t	t	t
5259	5	2026-03-02 20:31:36.463411	61.12	56.61	41.71	t	t	t
5260	2	2026-03-02 20:31:46.445146	17.76	50.88	69.60	t	t	t
5266	5	2026-03-02 20:31:56.443005	72.57	50.43	65.78	t	t	t
5334	4	2026-03-02 20:34:46.602746	40.16	10.89	23.64	t	t	t
5339	3	2026-03-02 20:34:56.574487	10.76	74.46	54.50	t	t	t
5340	2	2026-03-02 20:35:06.584293	29.40	38.62	45.55	t	t	t
5405	2	2026-03-02 20:37:46.736833	40.92	73.23	55.17	t	t	f
5473	4	2026-03-02 20:40:36.929724	77.12	59.11	47.62	t	t	t
5477	4	2026-03-02 20:40:46.913598	22.62	66.30	62.21	t	t	t
5483	4	2026-03-02 20:40:56.917455	48.40	13.53	59.47	t	t	t
5487	3	2026-03-02 20:41:06.919815	34.87	20.62	47.80	t	t	t
5541	4	2026-03-02 20:43:27.091118	35.19	50.17	33.95	t	t	f
5545	4	2026-03-02 20:43:37.070325	21.25	20.48	44.47	t	t	t
5550	3	2026-03-02 20:43:47.070671	43.38	60.60	42.19	t	t	t
5598	3	2026-03-02 20:45:47.22503	51.29	14.10	27.83	t	t	t
5670	4	2026-03-02 20:48:47.317465	39.04	32.66	39.82	t	t	t
5675	3	2026-03-02 20:48:57.294723	75.00	57.69	38.50	t	t	t
5676	2	2026-03-02 20:49:07.306067	36.60	61.74	49.48	t	t	f
5681	5	2026-03-02 20:49:17.30957	37.60	18.43	61.11	t	t	t
3787	5	2026-03-02 19:30:03.639296	41.24	23.22	65.96	t	t	t
3788	3	2026-03-02 19:30:13.643746	21.34	70.85	36.33	t	t	t
3795	2	2026-03-02 19:30:23.655037	45.40	55.33	31.54	t	t	t
3798	4	2026-03-02 19:30:33.680005	56.93	79.74	60.00	f	t	t
3802	3	2026-03-02 19:30:43.683557	68.24	53.50	23.75	t	t	t
3804	2	2026-03-02 19:30:53.684616	59.28	64.30	50.05	t	t	t
3810	5	2026-03-02 19:31:03.693401	74.05	50.74	23.30	f	t	t
3812	2	2026-03-02 19:31:13.691877	71.47	36.21	23.64	t	t	t
3819	5	2026-03-02 19:31:23.694434	48.36	34.36	63.72	t	t	t
3823	2	2026-03-02 19:31:33.707598	32.43	15.50	66.98	t	t	t
3826	3	2026-03-02 19:31:43.71257	50.40	33.91	35.02	t	t	t
3829	5	2026-03-02 19:31:53.713704	71.87	53.51	30.49	t	t	t
3833	5	2026-03-02 19:32:03.712807	40.56	32.14	59.22	t	t	f
3836	2	2026-03-02 19:32:13.726128	40.20	10.04	41.41	t	t	t
3842	5	2026-03-02 19:32:23.745486	35.47	11.58	25.41	t	t	t
3847	2	2026-03-02 19:32:33.747286	27.55	48.91	62.40	t	t	t
3848	3	2026-03-02 19:32:43.755306	41.65	22.90	25.09	t	t	t
3855	5	2026-03-02 19:32:53.756384	23.04	50.08	23.83	t	t	t
3856	2	2026-03-02 19:33:03.755164	49.11	13.20	36.45	t	t	t
3862	4	2026-03-02 19:33:13.761011	54.48	56.92	34.36	f	t	t
3864	3	2026-03-02 19:33:23.760419	18.39	56.31	56.33	t	t	t
3869	3	2026-03-02 19:33:33.809752	57.09	54.00	21.69	t	t	t
3870	5	2026-03-02 19:33:33.814603	57.81	78.82	41.08	t	t	t
3871	4	2026-03-02 19:33:33.815239	20.00	75.35	47.44	t	t	t
3872	2	2026-03-02 19:33:43.788675	65.45	73.30	63.94	t	t	t
3873	4	2026-03-02 19:33:43.789204	54.73	70.42	64.67	t	t	t
3874	3	2026-03-02 19:33:43.789056	34.03	38.77	67.11	t	t	t
3875	5	2026-03-02 19:33:43.823276	72.73	13.60	45.50	t	t	t
3876	2	2026-03-02 19:33:53.795782	36.71	26.18	39.50	t	t	t
3877	4	2026-03-02 19:33:53.796074	65.37	38.79	40.13	t	t	t
3878	3	2026-03-02 19:33:53.796235	16.13	24.13	42.84	t	f	t
3879	5	2026-03-02 19:33:53.826179	64.45	49.15	23.64	t	t	t
3880	2	2026-03-02 19:34:03.802599	10.46	61.84	21.32	t	f	f
3881	3	2026-03-02 19:34:03.836673	14.34	21.16	40.74	t	t	t
3882	4	2026-03-02 19:34:03.838533	52.63	16.75	25.01	t	t	t
3883	5	2026-03-02 19:34:03.83901	19.12	72.60	67.74	t	t	t
3884	4	2026-03-02 19:34:13.823704	29.92	23.81	22.21	t	t	t
3885	2	2026-03-02 19:34:13.824086	47.02	37.70	43.44	t	f	t
3886	3	2026-03-02 19:34:13.824382	26.56	29.03	59.79	t	t	t
3887	5	2026-03-02 19:34:13.969285	48.37	64.51	49.58	t	t	t
3888	3	2026-03-02 19:34:23.828372	38.08	67.00	38.38	t	t	t
3889	2	2026-03-02 19:34:23.828574	29.49	58.59	41.42	t	t	t
3890	5	2026-03-02 19:34:23.828735	19.13	60.03	60.20	t	t	t
3891	4	2026-03-02 19:34:23.829016	63.16	30.13	31.88	t	t	t
3892	2	2026-03-02 19:34:33.839407	50.45	73.38	62.99	t	t	t
3893	3	2026-03-02 19:34:33.870628	61.40	44.95	49.22	t	t	t
3894	4	2026-03-02 19:34:33.876145	54.99	63.83	69.17	t	t	t
3895	5	2026-03-02 19:34:33.877904	31.10	29.55	67.32	f	t	t
3896	2	2026-03-02 19:34:43.857289	56.15	29.78	63.22	t	t	t
3897	3	2026-03-02 19:34:43.857688	45.23	43.38	33.42	t	t	t
3898	4	2026-03-02 19:34:43.858036	19.36	18.06	41.26	t	f	t
3899	5	2026-03-02 19:34:43.889699	44.00	32.01	59.67	t	t	t
3900	2	2026-03-02 19:34:53.866626	78.13	24.33	59.77	t	t	f
3901	3	2026-03-02 19:34:53.897347	73.51	68.17	45.96	t	t	t
3902	5	2026-03-02 19:34:53.901311	52.22	47.57	36.54	t	t	t
3903	4	2026-03-02 19:34:54.010946	23.21	55.35	64.75	t	t	t
3904	2	2026-03-02 19:35:03.875685	17.07	12.39	33.20	t	t	t
3905	3	2026-03-02 19:35:03.876533	76.51	45.57	21.91	t	f	t
3906	4	2026-03-02 19:35:03.876867	29.48	72.63	22.38	t	t	t
3907	5	2026-03-02 19:35:03.908791	79.79	62.44	54.31	t	t	f
3908	2	2026-03-02 19:35:13.891388	17.83	16.21	33.96	t	t	t
3909	3	2026-03-02 19:35:13.922095	21.46	32.34	55.24	t	t	t
3910	5	2026-03-02 19:35:13.928351	29.40	51.66	56.07	t	t	f
3911	4	2026-03-02 19:35:13.928424	29.66	70.99	60.58	t	t	f
3912	3	2026-03-02 19:35:23.896903	71.42	46.36	28.42	t	t	f
3913	2	2026-03-02 19:35:23.897148	22.46	57.98	24.31	t	f	f
3914	5	2026-03-02 19:35:23.897309	52.30	48.13	45.75	t	f	t
3915	4	2026-03-02 19:35:23.897582	66.33	29.23	31.15	t	t	t
3916	2	2026-03-02 19:35:33.913409	26.34	26.29	20.77	t	t	t
3917	3	2026-03-02 19:35:33.947953	30.29	42.85	39.85	t	t	t
3918	4	2026-03-02 19:35:33.949395	44.71	17.50	64.86	t	t	t
3919	5	2026-03-02 19:35:33.953136	74.47	27.96	50.10	t	t	t
3920	2	2026-03-02 19:35:43.91943	36.13	67.52	63.86	t	t	t
3921	4	2026-03-02 19:35:43.919754	37.81	64.62	30.53	t	f	t
3922	3	2026-03-02 19:35:43.919587	64.06	34.39	42.08	t	t	t
3923	5	2026-03-02 19:35:43.951354	51.64	43.86	53.20	t	t	t
3924	2	2026-03-02 19:35:53.937633	60.57	78.47	64.26	t	t	t
3925	3	2026-03-02 19:35:53.969063	54.38	55.56	67.60	t	t	t
3926	4	2026-03-02 19:35:53.973251	51.09	70.65	47.95	t	t	t
3927	5	2026-03-02 19:35:53.975195	51.07	49.64	50.92	t	t	t
3928	2	2026-03-02 19:36:03.950815	22.41	71.56	66.56	t	t	t
3929	3	2026-03-02 19:36:03.951039	14.17	31.37	64.73	t	t	t
3930	4	2026-03-02 19:36:03.951184	30.49	21.91	52.77	f	t	t
3931	5	2026-03-02 19:36:03.980263	13.44	44.97	35.40	t	t	f
3932	3	2026-03-02 19:36:13.954173	79.85	19.51	61.01	t	t	t
3933	5	2026-03-02 19:36:13.954566	48.78	51.72	54.74	t	t	t
3934	2	2026-03-02 19:36:13.954435	69.16	38.98	63.48	t	t	t
3935	4	2026-03-02 19:36:13.954667	41.91	44.80	31.15	t	f	t
3936	2	2026-03-02 19:36:23.953758	57.35	47.83	52.66	t	t	t
3937	5	2026-03-02 19:36:23.954004	77.91	35.60	64.06	t	f	f
3938	3	2026-03-02 19:36:23.954184	27.12	22.10	20.73	t	t	f
3939	4	2026-03-02 19:36:23.95446	15.94	24.04	59.36	t	t	t
3940	2	2026-03-02 19:36:33.962371	16.95	20.58	40.99	t	t	t
3941	3	2026-03-02 19:36:33.99251	47.29	22.60	46.51	t	t	t
3942	5	2026-03-02 19:36:33.994394	51.50	28.28	49.65	t	f	t
3943	4	2026-03-02 19:36:34.110169	46.07	11.01	41.00	t	t	t
3944	3	2026-03-02 19:36:43.973639	38.04	53.77	23.95	t	t	f
3945	2	2026-03-02 19:36:43.973776	67.27	54.12	26.98	t	t	t
3946	4	2026-03-02 19:36:43.973941	58.73	16.12	24.93	t	t	t
3947	5	2026-03-02 19:36:44.003096	31.94	14.73	33.43	t	t	t
3948	2	2026-03-02 19:36:53.979109	20.79	68.45	42.49	t	t	t
3949	3	2026-03-02 19:36:53.97946	72.15	56.22	35.17	t	t	t
3950	5	2026-03-02 19:36:53.979659	12.52	25.81	36.05	t	t	t
3951	4	2026-03-02 19:36:53.979972	48.24	76.76	43.37	t	t	t
3952	5	2026-03-02 19:37:03.974881	48.43	23.23	68.70	t	t	t
3953	3	2026-03-02 19:37:03.975002	41.87	21.47	67.10	t	f	f
3954	4	2026-03-02 19:37:03.975443	42.16	11.52	66.41	f	t	f
3955	2	2026-03-02 19:37:03.975311	50.20	71.34	57.44	t	t	t
3959	2	2026-03-02 19:37:13.977697	17.04	11.34	58.02	t	t	t
3960	4	2026-03-02 19:37:23.983327	45.20	65.96	55.53	t	t	t
4681	3	2026-03-02 20:07:25.449256	21.60	70.82	69.10	t	t	t
4686	4	2026-03-02 20:07:35.423432	52.93	46.28	32.60	t	f	t
4751	5	2026-03-02 20:10:15.58996	31.26	63.19	44.68	t	t	t
4752	2	2026-03-02 20:10:25.573734	57.13	43.74	41.08	t	t	t
4758	5	2026-03-02 20:10:35.566476	62.90	56.63	20.79	t	t	t
4823	5	2026-03-02 20:13:25.698959	46.83	61.51	62.93	t	t	t
4824	2	2026-03-02 20:13:35.670243	71.17	10.39	53.46	t	t	f
4831	5	2026-03-02 20:13:45.67466	75.65	57.88	55.21	t	t	f
4897	4	2026-03-02 20:16:35.804499	18.63	47.21	24.25	t	f	t
4902	3	2026-03-02 20:16:45.809605	13.05	22.63	57.10	t	t	t
4904	2	2026-03-02 20:16:55.822655	68.35	58.01	68.24	t	t	t
4959	4	2026-03-02 20:19:05.927523	79.34	25.69	37.95	t	t	t
4960	2	2026-03-02 20:19:15.938895	37.63	16.40	23.34	t	t	t
4967	5	2026-03-02 20:19:25.941241	18.44	49.22	27.93	t	t	t
4968	2	2026-03-02 20:19:35.949662	35.32	20.66	21.05	t	t	t
5019	5	2026-03-02 20:21:36.113249	32.93	46.85	35.87	t	t	t
5020	2	2026-03-02 20:21:46.065215	18.88	12.19	23.20	t	t	t
5109	3	2026-03-02 20:25:26.279302	43.18	29.42	22.82	t	t	t
5113	4	2026-03-02 20:25:36.245622	68.54	42.90	22.02	t	t	t
5202	4	2026-03-02 20:29:16.401279	14.11	75.27	27.15	t	f	t
5205	3	2026-03-02 20:29:26.380809	49.64	45.21	40.95	t	t	t
5261	3	2026-03-02 20:31:46.481063	10.64	26.16	25.47	t	t	f
5267	4	2026-03-02 20:31:56.443175	17.85	44.29	30.22	t	t	t
5268	2	2026-03-02 20:32:06.449344	33.17	72.15	55.05	t	t	t
5335	5	2026-03-02 20:34:46.60467	31.55	15.40	53.22	t	t	t
5336	2	2026-03-02 20:34:56.573314	61.37	60.99	24.31	f	t	t
5409	3	2026-03-02 20:37:56.777398	35.42	63.85	46.94	t	t	t
5413	4	2026-03-02 20:38:06.758716	36.73	72.92	41.89	t	f	t
5417	5	2026-03-02 20:38:16.766222	49.04	48.35	63.06	t	t	t
5422	5	2026-03-02 20:38:26.770036	75.07	38.20	28.47	t	t	t
5424	2	2026-03-02 20:38:36.784135	46.21	64.92	27.51	t	f	t
5474	5	2026-03-02 20:40:36.934582	32.28	71.31	53.02	t	f	t
5478	3	2026-03-02 20:40:46.913492	25.30	49.21	40.72	t	t	t
5482	3	2026-03-02 20:40:56.917299	16.06	25.53	63.41	t	t	t
5486	4	2026-03-02 20:41:06.919522	43.37	13.54	48.71	t	t	t
5489	2	2026-03-02 20:41:16.928855	46.99	62.29	44.11	t	t	t
5495	4	2026-03-02 20:41:26.932144	12.76	45.24	42.89	t	t	t
5496	2	2026-03-02 20:41:36.939222	12.72	55.52	45.97	t	t	t
5501	5	2026-03-02 20:41:46.940203	30.99	74.16	52.56	t	t	t
5505	3	2026-03-02 20:41:56.949637	74.09	40.17	64.85	t	t	t
5542	3	2026-03-02 20:43:27.091408	46.26	33.39	49.87	t	t	f
5546	3	2026-03-02 20:43:37.070083	11.55	54.59	45.64	t	t	t
5551	4	2026-03-02 20:43:47.070937	48.41	45.74	58.60	t	t	t
5552	2	2026-03-02 20:43:57.084136	23.64	34.91	50.00	f	t	t
5599	5	2026-03-02 20:45:47.225955	69.02	60.34	57.55	t	t	t
5671	5	2026-03-02 20:48:47.318892	56.34	50.95	55.17	t	t	t
5672	2	2026-03-02 20:48:57.293647	36.76	44.52	47.41	t	t	t
5732	2	2026-03-02 20:51:27.408812	20.45	72.75	31.31	t	t	t
5783	5	2026-03-02 20:53:27.555093	62.91	74.13	36.68	t	f	t
5784	2	2026-03-02 20:53:37.527283	67.81	23.32	28.18	t	t	t
5869	3	2026-03-02 20:57:07.709767	73.96	61.89	52.97	t	t	t
5873	5	2026-03-02 20:57:17.676877	64.37	32.01	58.35	t	t	t
5922	5	2026-03-02 20:59:17.820931	28.80	61.94	54.36	t	f	f
5926	5	2026-03-02 20:59:27.790036	40.78	38.64	65.80	t	f	t
5989	3	2026-03-02 21:02:07.932457	57.75	68.12	66.29	t	t	t
5995	4	2026-03-02 21:02:17.904334	63.66	57.64	58.23	t	t	t
5997	2	2026-03-02 21:02:27.903023	59.58	39.69	45.02	t	t	t
6039	4	2026-03-02 21:04:08.030133	55.04	20.74	49.14	t	t	t
6041	2	2026-03-02 21:04:18.010082	15.46	56.97	26.80	t	t	t
6047	4	2026-03-02 21:04:28.002944	37.03	32.69	33.88	t	f	f
6049	2	2026-03-02 21:04:38.006583	63.31	55.99	29.77	t	t	f
6079	4	2026-03-02 21:05:48.215593	77.41	12.62	63.19	t	t	f
6080	2	2026-03-02 21:05:58.084904	68.33	14.58	22.79	t	t	t
6133	3	2026-03-02 21:08:08.201536	20.19	45.22	29.30	t	t	t
6138	4	2026-03-02 21:08:18.189422	23.89	66.60	51.23	t	t	t
6185	4	2026-03-02 21:10:18.328948	78.38	59.01	68.81	t	t	f
6190	4	2026-03-02 21:10:28.296806	16.90	25.64	52.96	t	t	t
6194	3	2026-03-02 21:10:38.298256	79.83	51.81	60.11	t	t	t
6197	2	2026-03-02 21:10:48.302844	75.57	51.71	57.12	t	t	t
6202	4	2026-03-02 21:10:58.308421	10.23	22.40	35.27	t	t	t
6231	5	2026-03-02 21:12:08.409882	74.85	31.82	48.28	t	t	t
6232	2	2026-03-02 21:12:18.39179	14.59	33.03	23.95	t	f	t
6238	5	2026-03-02 21:12:28.391619	26.45	12.65	67.44	t	t	f
6242	3	2026-03-02 21:12:38.392644	47.13	65.42	46.53	t	t	t
6246	3	2026-03-02 21:12:48.394595	30.25	67.29	52.61	t	t	t
6249	3	2026-03-02 21:12:58.398595	58.94	18.28	20.96	t	t	f
6287	5	2026-03-02 21:14:28.530323	12.81	65.09	33.08	t	t	t
6290	2	2026-03-02 21:14:38.45969	45.41	60.39	67.85	t	t	t
6292	2	2026-03-02 21:14:48.46755	43.59	66.43	55.37	t	t	t
6339	5	2026-03-02 21:16:38.594547	75.07	76.11	54.30	t	t	t
6340	2	2026-03-02 21:16:48.577306	57.38	32.85	47.69	t	t	f
6386	4	2026-03-02 21:18:38.671862	43.36	36.25	36.95	t	t	f
6389	3	2026-03-02 21:18:48.651943	27.98	71.17	52.63	t	t	t
6393	5	2026-03-02 21:18:58.654657	77.93	46.35	57.42	t	t	t
6396	2	2026-03-02 21:19:08.667119	77.48	58.21	37.69	t	t	t
6401	5	2026-03-02 21:19:18.665309	73.27	30.77	43.98	t	t	t
6404	2	2026-03-02 21:19:28.671294	46.43	63.13	26.10	t	t	t
6409	5	2026-03-02 21:19:38.671141	67.50	73.90	50.49	t	t	t
6430	2	2026-03-02 21:20:28.714314	44.54	32.92	45.21	t	t	t
6433	3	2026-03-02 21:20:38.71446	43.43	15.76	49.35	f	t	t
6486	5	2026-03-02 21:22:48.806325	33.94	51.79	35.12	t	t	t
6489	3	2026-03-02 21:22:58.778311	66.95	28.80	58.51	t	f	f
6541	3	2026-03-02 21:25:08.894545	18.20	14.61	22.62	t	t	t
6545	4	2026-03-02 21:25:18.880891	39.86	15.97	50.73	t	t	t
6571	5	2026-03-02 21:26:18.95162	72.98	37.54	48.38	t	t	t
6572	3	2026-03-02 21:26:28.933937	34.32	59.37	27.34	t	t	t
6613	3	2026-03-02 21:28:09.058981	21.86	79.00	58.27	t	t	t
6619	4	2026-03-02 21:28:19.030759	58.58	52.02	41.07	t	t	t
6620	2	2026-03-02 21:28:29.034874	15.10	76.32	49.38	t	t	t
6663	5	2026-03-02 21:30:09.134472	15.73	49.20	37.57	t	t	t
6664	2	2026-03-02 21:30:19.109881	50.99	52.25	65.98	t	t	t
6670	5	2026-03-02 21:30:29.105812	77.42	62.02	27.17	t	t	f
6698	4	2026-03-02 21:31:39.200407	62.48	58.86	56.60	t	t	t
6701	3	2026-03-02 21:31:49.168666	12.89	11.99	66.05	t	f	t
3956	3	2026-03-02 19:37:13.976912	18.38	61.07	46.49	t	t	t
4682	4	2026-03-02 20:07:25.453695	22.12	38.79	67.17	t	f	t
4685	3	2026-03-02 20:07:35.423159	54.86	52.02	35.58	t	t	t
4753	3	2026-03-02 20:10:25.63053	41.28	41.98	32.46	t	t	t
4757	4	2026-03-02 20:10:35.566398	73.00	50.56	36.08	t	t	t
4832	2	2026-03-02 20:13:55.698633	48.32	62.67	44.85	f	t	t
4839	5	2026-03-02 20:14:05.677646	23.30	54.45	53.58	t	t	t
4840	2	2026-03-02 20:14:15.676457	42.29	31.85	68.01	t	t	t
4898	3	2026-03-02 20:16:35.804796	61.44	75.78	52.52	t	t	t
4901	4	2026-03-02 20:16:45.809231	47.05	31.42	22.01	t	t	t
4961	3	2026-03-02 20:19:15.970857	47.85	50.83	63.42	t	f	t
4965	4	2026-03-02 20:19:25.940083	54.94	59.38	45.38	t	t	t
4971	3	2026-03-02 20:19:35.950162	39.04	72.21	68.60	t	t	t
5025	3	2026-03-02 20:21:56.107403	49.04	74.23	30.08	t	t	t
5029	4	2026-03-02 20:22:06.092245	63.39	11.50	67.64	t	t	t
5033	4	2026-03-02 20:22:16.088637	79.80	43.02	55.14	t	t	t
5110	4	2026-03-02 20:25:26.283903	78.69	61.79	54.06	t	t	t
5114	3	2026-03-02 20:25:36.245885	20.30	69.18	39.40	t	t	t
5203	5	2026-03-02 20:29:16.404943	38.42	41.34	66.36	t	t	t
5204	2	2026-03-02 20:29:26.380558	12.31	13.76	65.25	t	t	t
5262	4	2026-03-02 20:31:46.482476	50.26	63.16	55.53	t	t	t
5265	3	2026-03-02 20:31:56.442881	65.56	71.83	40.17	t	t	t
5269	3	2026-03-02 20:32:06.449712	42.81	27.73	55.42	f	t	f
5341	5	2026-03-02 20:35:06.615932	30.72	44.89	52.34	t	t	t
5344	3	2026-03-02 20:35:16.60159	27.29	36.02	43.30	t	t	t
5349	5	2026-03-02 20:35:26.606416	57.99	14.37	55.68	t	t	t
5410	4	2026-03-02 20:37:56.781858	35.24	30.85	59.56	t	t	t
5414	3	2026-03-02 20:38:06.75938	56.59	27.75	32.20	f	t	t
5475	3	2026-03-02 20:40:36.93481	61.91	53.43	40.00	t	t	t
5476	2	2026-03-02 20:40:46.913337	69.84	31.72	33.38	f	t	t
5481	5	2026-03-02 20:40:56.917019	60.75	56.38	36.42	t	t	t
5485	5	2026-03-02 20:41:06.919321	14.91	42.61	58.61	t	t	t
5488	3	2026-03-02 20:41:16.928642	69.41	49.13	43.55	t	t	t
5493	5	2026-03-02 20:41:26.931682	35.30	41.03	66.93	t	t	t
5498	4	2026-03-02 20:41:36.940055	38.31	32.33	20.02	t	t	t
5503	3	2026-03-02 20:41:46.940863	28.24	13.51	37.78	t	t	t
5543	5	2026-03-02 20:43:27.093686	28.38	79.44	44.34	t	t	t
5544	2	2026-03-02 20:43:37.069794	46.93	71.04	22.20	t	t	t
5549	5	2026-03-02 20:43:47.070466	61.29	64.86	36.70	t	t	t
5600	2	2026-03-02 20:45:57.190755	75.86	78.32	25.83	t	t	t
5607	5	2026-03-02 20:46:07.192433	17.23	11.48	34.57	t	t	t
5677	3	2026-03-02 20:49:07.341242	55.77	16.22	59.39	t	t	t
5682	4	2026-03-02 20:49:17.309686	21.46	66.14	64.14	t	f	t
5733	4	2026-03-02 20:51:27.444166	30.13	43.11	53.34	f	t	t
5738	4	2026-03-02 20:51:37.423989	30.56	79.67	38.85	t	t	t
5742	2	2026-03-02 20:51:47.424767	76.04	42.59	66.39	t	f	t
5745	3	2026-03-02 20:51:57.434904	69.20	26.98	61.52	t	t	t
5785	4	2026-03-02 20:53:37.565603	14.76	32.27	38.88	t	t	f
5789	4	2026-03-02 20:53:47.542185	58.46	70.77	39.39	f	t	t
5870	4	2026-03-02 20:57:07.716393	46.79	13.51	60.97	t	f	t
5875	3	2026-03-02 20:57:17.677041	51.08	40.53	63.65	t	t	f
5923	4	2026-03-02 20:59:17.82117	17.92	26.62	69.28	t	t	f
5924	4	2026-03-02 20:59:27.789821	46.52	37.91	45.88	t	t	t
5990	4	2026-03-02 21:02:07.935567	45.71	46.63	63.79	t	t	t
5994	3	2026-03-02 21:02:17.90409	35.96	26.92	57.94	t	t	t
5996	3	2026-03-02 21:02:27.902798	42.16	13.81	40.40	t	t	t
6042	4	2026-03-02 21:04:18.041696	49.02	29.17	40.79	t	t	f
6044	3	2026-03-02 21:04:28.002646	35.50	50.20	47.32	t	t	t
6082	4	2026-03-02 21:05:58.116914	42.32	51.03	21.58	t	t	t
6084	3	2026-03-02 21:06:08.096685	52.07	23.43	28.09	t	t	f
6089	4	2026-03-02 21:06:18.09806	45.65	73.11	36.58	t	t	f
6095	5	2026-03-02 21:06:28.100998	11.35	24.22	62.45	t	t	t
6096	2	2026-03-02 21:06:38.109047	37.38	58.77	40.32	t	t	t
6134	4	2026-03-02 21:08:08.202023	42.11	14.20	44.96	t	t	t
6136	3	2026-03-02 21:08:18.18899	60.84	57.20	58.35	t	f	f
6186	3	2026-03-02 21:10:18.329337	68.45	12.27	67.49	t	t	t
6189	3	2026-03-02 21:10:28.296651	36.11	21.93	32.01	t	t	t
6195	4	2026-03-02 21:10:38.298256	55.09	36.42	27.08	f	t	t
6198	3	2026-03-02 21:10:48.303065	56.78	17.94	42.69	t	t	t
6201	3	2026-03-02 21:10:58.308138	61.43	54.73	53.14	t	t	t
6234	3	2026-03-02 21:12:18.392255	73.50	32.83	42.44	t	t	t
6237	2	2026-03-02 21:12:28.391128	72.79	31.33	66.32	t	t	f
6241	4	2026-03-02 21:12:38.392059	46.88	73.04	63.47	t	f	t
6244	4	2026-03-02 21:12:48.39451	42.75	58.34	42.69	f	t	t
6251	5	2026-03-02 21:12:58.39875	13.81	25.89	57.70	t	t	t
6252	2	2026-03-02 21:13:08.40813	46.30	16.19	21.33	t	t	t
6259	5	2026-03-02 21:13:18.411599	52.71	38.31	55.98	t	t	t
6262	2	2026-03-02 21:13:28.417879	74.27	17.12	52.20	t	t	t
6293	4	2026-03-02 21:14:48.505413	31.11	28.88	67.00	t	t	t
6297	4	2026-03-02 21:14:58.480096	65.67	14.50	64.34	t	t	t
6341	3	2026-03-02 21:16:48.624407	21.49	51.80	64.51	f	t	t
6346	4	2026-03-02 21:16:58.585056	52.08	45.34	46.12	t	t	f
6348	3	2026-03-02 21:17:08.592919	66.19	31.17	36.18	t	t	t
6353	5	2026-03-02 21:17:18.591114	70.93	51.07	23.53	t	t	t
6387	5	2026-03-02 21:18:38.674215	77.29	23.03	21.23	t	t	t
6388	2	2026-03-02 21:18:48.651861	21.59	70.23	68.85	t	t	t
6395	4	2026-03-02 21:18:58.655125	19.89	20.15	43.85	t	f	t
6431	4	2026-03-02 21:20:28.74397	27.82	26.77	20.46	t	t	t
6432	2	2026-03-02 21:20:38.714199	54.01	74.16	21.84	t	t	t
6487	4	2026-03-02 21:22:48.90993	11.39	78.17	67.56	t	t	t
6488	2	2026-03-02 21:22:58.778197	66.23	68.14	51.82	t	t	t
6542	5	2026-03-02 21:25:08.894811	73.13	19.98	41.18	t	t	t
6546	3	2026-03-02 21:25:18.881065	71.72	58.36	69.76	t	t	t
6574	5	2026-03-02 21:26:28.969793	39.65	36.78	62.50	t	t	t
6614	4	2026-03-02 21:28:09.062209	44.05	36.71	28.92	t	t	f
6618	3	2026-03-02 21:28:19.030557	20.86	71.65	59.15	t	f	t
6622	3	2026-03-02 21:28:29.035085	20.69	49.48	40.50	t	t	f
6665	3	2026-03-02 21:30:19.142572	39.31	47.23	36.76	t	t	t
6671	4	2026-03-02 21:30:29.105891	11.05	78.86	47.07	t	t	f
6672	2	2026-03-02 21:30:39.117456	36.41	66.61	51.40	t	t	t
6677	5	2026-03-02 21:30:49.119886	74.72	29.63	61.48	t	t	t
6699	5	2026-03-02 21:31:39.202614	16.95	37.97	44.45	t	t	t
6700	2	2026-03-02 21:31:49.168396	26.53	40.21	36.65	t	f	t
6706	4	2026-03-02 21:31:59.166617	35.80	66.97	21.55	t	t	t
6708	3	2026-03-02 21:32:09.17988	67.78	58.95	32.44	t	t	t
6730	4	2026-03-02 21:32:59.289658	30.96	21.92	58.78	t	t	t
6735	3	2026-03-02 21:33:09.261992	42.05	38.52	34.26	f	t	t
3957	5	2026-03-02 19:37:13.977303	41.45	32.32	24.24	t	t	t
3961	3	2026-03-02 19:37:23.983228	17.88	47.72	46.63	t	t	t
4683	5	2026-03-02 20:07:25.454195	19.51	74.18	52.53	t	t	t
4684	2	2026-03-02 20:07:35.422886	73.49	10.25	61.26	t	t	f
4754	4	2026-03-02 20:10:25.633316	17.32	35.71	29.89	t	t	f
4759	3	2026-03-02 20:10:35.566571	77.01	34.40	31.87	t	t	t
4760	3	2026-03-02 20:10:45.581975	62.31	27.25	38.91	f	t	t
4766	5	2026-03-02 20:10:55.582996	71.42	33.14	49.98	t	t	t
4769	3	2026-03-02 20:11:05.587451	27.96	38.78	53.41	t	t	t
4772	2	2026-03-02 20:11:15.610969	51.94	52.39	33.32	t	f	t
4778	5	2026-03-02 20:11:25.604938	45.34	57.43	24.54	t	t	t
4833	3	2026-03-02 20:13:55.738407	43.81	28.54	32.80	f	t	t
4838	4	2026-03-02 20:14:05.677418	41.45	46.00	65.53	f	t	t
4841	3	2026-03-02 20:14:15.676656	56.55	47.32	42.64	t	t	t
4899	5	2026-03-02 20:16:35.836336	70.24	47.48	26.94	t	t	t
4900	2	2026-03-02 20:16:45.808837	20.82	69.02	65.41	t	t	f
4962	4	2026-03-02 20:19:15.976035	76.99	16.66	64.96	t	t	t
4966	3	2026-03-02 20:19:25.940271	31.16	50.88	68.96	t	t	t
4969	5	2026-03-02 20:19:35.949789	23.02	13.97	33.48	t	t	t
4972	3	2026-03-02 20:19:45.963387	49.92	51.88	37.94	t	t	t
5026	5	2026-03-02 20:21:56.112828	55.55	57.41	45.27	t	t	t
5030	3	2026-03-02 20:22:06.092702	74.74	39.89	47.72	t	t	t
5034	3	2026-03-02 20:22:16.088857	24.56	33.24	31.92	f	t	t
5036	2	2026-03-02 20:22:26.102305	58.24	34.41	44.89	t	t	t
5111	5	2026-03-02 20:25:26.286401	23.75	64.00	67.03	f	t	t
5112	2	2026-03-02 20:25:36.245286	58.03	74.21	35.90	t	t	t
5206	5	2026-03-02 20:29:26.412495	16.60	58.74	63.71	t	t	t
5208	3	2026-03-02 20:29:36.386695	49.66	16.98	67.30	t	t	t
5213	4	2026-03-02 20:29:46.38432	74.44	55.20	52.09	t	f	t
5263	5	2026-03-02 20:31:46.488073	77.19	70.63	39.40	t	t	t
5264	2	2026-03-02 20:31:56.442702	60.36	22.59	34.45	t	t	t
5270	4	2026-03-02 20:32:06.450084	75.56	29.17	66.21	t	t	t
5342	3	2026-03-02 20:35:06.616224	43.91	61.25	58.41	t	t	t
5411	5	2026-03-02 20:37:56.782169	49.12	69.14	29.14	t	f	t
5412	2	2026-03-02 20:38:06.758428	33.56	75.10	64.95	t	f	t
5479	5	2026-03-02 20:40:46.944325	65.51	73.84	27.19	t	f	t
5480	2	2026-03-02 20:40:56.916701	47.83	14.03	26.64	t	t	t
5484	2	2026-03-02 20:41:06.918838	50.63	38.86	65.30	t	t	t
5547	5	2026-03-02 20:43:37.100065	56.34	19.00	67.16	t	t	f
5548	2	2026-03-02 20:43:47.070017	63.94	13.19	51.04	t	t	t
5601	3	2026-03-02 20:45:57.191362	12.08	63.24	65.94	t	t	t
5605	4	2026-03-02 20:46:07.192445	44.73	32.34	56.68	t	t	t
5678	4	2026-03-02 20:49:07.343018	26.74	13.49	50.67	t	t	f
5683	2	2026-03-02 20:49:17.309937	57.15	55.19	35.92	t	t	t
5734	5	2026-03-02 20:51:27.445911	20.93	79.87	68.60	t	t	t
5737	3	2026-03-02 20:51:37.423873	35.22	17.52	33.32	t	t	t
5743	4	2026-03-02 20:51:47.424799	73.98	75.22	56.45	t	t	t
5786	3	2026-03-02 20:53:37.566392	70.72	17.94	64.00	t	t	t
5790	3	2026-03-02 20:53:47.542365	57.13	62.93	35.42	t	t	t
5871	5	2026-03-02 20:57:07.717436	20.41	51.24	28.00	t	t	t
5872	2	2026-03-02 20:57:17.676562	39.59	79.20	31.34	t	t	t
5927	3	2026-03-02 20:59:27.8194	73.72	45.86	55.25	t	t	f
5928	2	2026-03-02 20:59:37.80613	44.42	76.17	65.26	t	t	t
5991	5	2026-03-02 21:02:07.937698	35.61	16.72	35.04	t	t	t
5992	2	2026-03-02 21:02:17.903345	13.04	56.95	62.03	f	t	t
5998	5	2026-03-02 21:02:27.903431	24.27	51.04	62.72	t	t	t
6000	3	2026-03-02 21:02:37.913391	57.75	41.13	20.19	t	t	f
6043	5	2026-03-02 21:04:18.043511	71.48	72.21	44.99	t	t	t
6046	2	2026-03-02 21:04:28.002831	36.42	70.20	30.29	t	t	t
6083	5	2026-03-02 21:05:58.117891	50.18	71.65	37.81	t	t	t
6085	2	2026-03-02 21:06:08.096908	35.80	57.97	40.44	t	t	t
6091	5	2026-03-02 21:06:18.098275	24.55	66.82	25.31	t	t	t
6092	2	2026-03-02 21:06:28.100128	17.47	49.04	51.81	t	t	t
6135	5	2026-03-02 21:08:08.348378	65.69	30.57	33.70	t	t	t
6139	2	2026-03-02 21:08:18.189647	32.08	59.48	61.06	t	t	t
6140	2	2026-03-02 21:08:28.205662	61.94	10.53	68.09	t	t	t
6147	5	2026-03-02 21:08:38.205123	43.23	15.60	33.96	t	t	t
6148	2	2026-03-02 21:08:48.206679	36.67	48.20	55.75	t	t	t
6187	5	2026-03-02 21:10:18.332724	42.99	76.98	35.92	t	t	t
6188	2	2026-03-02 21:10:28.295944	67.94	75.15	46.96	t	t	t
6193	5	2026-03-02 21:10:38.298115	71.23	18.26	42.98	t	t	f
6196	4	2026-03-02 21:10:48.302204	15.46	45.46	35.63	t	f	f
6203	5	2026-03-02 21:10:58.309389	32.51	15.82	41.58	f	t	t
6204	2	2026-03-02 21:11:08.320364	42.54	75.90	52.31	t	t	f
6235	5	2026-03-02 21:12:18.537923	28.93	29.88	32.16	t	t	f
6236	3	2026-03-02 21:12:28.390258	69.17	15.71	64.16	t	t	t
6243	5	2026-03-02 21:12:38.392997	34.68	68.76	53.06	t	f	t
6245	2	2026-03-02 21:12:48.394474	62.15	78.11	20.88	t	t	t
6250	2	2026-03-02 21:12:58.398658	37.95	11.59	50.60	t	t	f
6294	3	2026-03-02 21:14:48.505516	35.09	25.50	52.41	t	t	t
6298	3	2026-03-02 21:14:58.480293	21.73	46.92	31.60	f	t	t
6342	4	2026-03-02 21:16:48.626235	50.88	12.28	56.37	t	t	t
6345	3	2026-03-02 21:16:58.584592	72.02	49.40	66.07	t	t	t
6390	4	2026-03-02 21:18:48.68267	19.96	29.53	64.78	t	t	t
6394	3	2026-03-02 21:18:58.654826	33.58	61.01	49.49	t	t	t
6437	3	2026-03-02 21:20:48.756847	43.45	78.20	27.29	t	t	t
6443	4	2026-03-02 21:20:58.723432	52.12	37.91	35.89	t	t	t
6444	3	2026-03-02 21:21:08.72415	60.03	46.40	27.32	t	t	t
6491	5	2026-03-02 21:22:58.808666	58.57	79.66	50.58	t	t	t
6492	2	2026-03-02 21:23:08.787221	50.69	53.70	67.06	t	t	t
6543	4	2026-03-02 21:25:08.894828	35.07	39.67	44.28	t	t	t
6544	2	2026-03-02 21:25:18.880653	50.51	76.26	68.28	t	t	t
6575	4	2026-03-02 21:26:29.073317	40.03	17.53	24.88	t	t	t
6615	5	2026-03-02 21:28:09.063254	14.76	29.27	40.74	t	t	t
6616	2	2026-03-02 21:28:19.029724	79.97	69.95	36.46	t	t	t
6666	4	2026-03-02 21:30:19.147842	12.90	16.90	46.47	t	t	t
6669	3	2026-03-02 21:30:29.105659	45.06	74.52	27.54	f	t	t
6707	3	2026-03-02 21:31:59.166728	79.19	50.02	27.52	t	t	t
6731	5	2026-03-02 21:32:59.291367	14.00	38.57	55.96	t	t	t
6732	2	2026-03-02 21:33:09.261343	74.87	51.07	51.72	t	t	f
6766	5	2026-03-02 21:34:29.370651	57.69	42.46	33.87	t	t	t
6769	3	2026-03-02 21:34:39.337498	29.74	26.83	35.13	t	t	t
6775	3	2026-03-02 21:34:49.340928	28.98	19.81	54.82	t	t	t
6779	4	2026-03-02 21:34:59.341484	30.53	58.25	41.61	t	t	t
6780	2	2026-03-02 21:35:09.356832	48.09	73.57	41.67	t	t	t
6799	5	2026-03-02 21:35:49.419179	10.74	75.42	36.17	t	t	f
6800	2	2026-03-02 21:35:59.395209	14.80	42.09	39.73	t	t	f
3963	5	2026-03-02 19:37:24.011616	57.15	56.83	67.97	t	t	t
3964	2	2026-03-02 19:37:33.994142	70.99	57.54	40.25	t	t	t
3967	5	2026-03-02 19:37:34.035658	33.45	66.80	26.05	f	t	t
3969	4	2026-03-02 19:37:43.990621	70.51	26.61	61.01	f	t	t
3970	2	2026-03-02 19:37:43.990897	11.98	17.91	35.71	t	t	t
3975	3	2026-03-02 19:37:54.147071	30.63	72.88	36.58	t	t	t
3978	3	2026-03-02 19:38:04.010441	30.03	23.29	59.95	t	t	t
3980	4	2026-03-02 19:38:14.015992	54.06	16.89	41.48	t	t	t
3986	5	2026-03-02 19:38:24.059057	23.96	26.30	22.76	t	t	t
3988	3	2026-03-02 19:38:34.036288	51.80	75.34	31.02	t	t	t
3993	3	2026-03-02 19:38:44.079849	15.41	35.77	36.38	t	f	t
3997	4	2026-03-02 19:38:54.051928	25.69	37.48	68.81	t	t	t
3999	5	2026-03-02 19:38:54.083125	37.18	25.44	44.75	t	t	t
4002	4	2026-03-02 19:39:04.055115	32.68	11.36	68.83	t	t	t
4003	2	2026-03-02 19:39:04.055312	17.07	51.30	57.42	t	t	t
4004	2	2026-03-02 19:39:14.065078	14.58	73.86	50.96	t	t	t
4007	3	2026-03-02 19:39:14.209852	48.10	57.11	29.11	t	t	t
4008	3	2026-03-02 19:39:24.070012	68.87	17.45	27.08	t	t	t
4010	5	2026-03-02 19:39:24.07055	26.11	55.43	57.57	t	t	f
4015	5	2026-03-02 19:39:34.122512	67.52	14.78	37.62	t	t	t
4016	3	2026-03-02 19:39:44.085994	73.22	65.08	56.79	t	t	t
4023	4	2026-03-02 19:39:54.248102	58.13	10.85	43.54	t	t	t
4027	2	2026-03-02 19:40:04.105154	56.30	70.47	52.69	t	t	t
4031	3	2026-03-02 19:40:14.111717	72.73	31.43	56.42	t	f	t
4032	2	2026-03-02 19:40:24.119041	30.16	28.24	31.51	t	f	f
4039	4	2026-03-02 19:40:34.280956	37.86	39.53	58.18	f	t	t
4040	2	2026-03-02 19:40:44.138573	10.79	15.65	31.80	t	t	t
4047	5	2026-03-02 19:40:54.183167	72.59	61.54	40.33	t	t	t
4048	2	2026-03-02 19:41:04.155814	66.14	37.87	58.60	t	t	t
4054	5	2026-03-02 19:41:14.207474	18.45	35.70	65.35	t	f	t
4057	3	2026-03-02 19:41:24.168279	14.55	42.04	39.93	t	t	t
4062	3	2026-03-02 19:41:34.172144	27.70	71.72	53.41	t	t	f
4066	3	2026-03-02 19:41:44.176028	64.21	69.55	60.72	t	t	t
4070	2	2026-03-02 19:41:54.18395	22.63	49.80	54.42	t	t	t
4072	2	2026-03-02 19:42:04.193744	31.80	45.48	47.31	t	t	t
4074	5	2026-03-02 19:42:04.227142	38.41	71.37	57.20	t	t	t
4077	5	2026-03-02 19:42:14.197189	60.65	19.27	30.70	t	t	t
4078	3	2026-03-02 19:42:14.197344	54.10	64.94	42.66	t	t	t
4082	3	2026-03-02 19:42:24.199978	25.21	30.87	66.47	t	f	t
4083	4	2026-03-02 19:42:24.200106	16.52	21.70	46.23	t	t	t
4084	5	2026-03-02 19:42:34.215758	40.78	15.40	55.81	t	t	t
4086	3	2026-03-02 19:42:34.252953	35.48	68.52	29.85	t	t	t
4088	3	2026-03-02 19:42:44.220578	56.19	42.91	28.80	t	t	f
4089	4	2026-03-02 19:42:44.220843	58.10	67.90	60.69	t	t	t
4094	5	2026-03-02 19:42:54.267014	11.80	73.21	62.19	t	t	t
4098	4	2026-03-02 19:43:04.239002	59.80	46.44	63.37	t	t	t
4100	2	2026-03-02 19:43:14.250657	39.00	77.01	20.12	t	f	t
4102	4	2026-03-02 19:43:14.28473	67.48	17.81	52.60	t	f	t
4104	3	2026-03-02 19:43:24.262277	49.48	40.46	43.97	t	t	t
4110	5	2026-03-02 19:43:34.267877	40.21	51.38	22.21	t	t	t
4113	4	2026-03-02 19:43:44.310942	24.79	44.82	26.26	t	t	t
4116	4	2026-03-02 19:43:54.295288	77.51	21.95	68.51	t	f	f
4119	5	2026-03-02 19:43:54.327512	46.93	62.38	42.97	t	t	f
4121	3	2026-03-02 19:44:04.292668	53.70	63.20	21.56	t	t	t
4123	2	2026-03-02 19:44:04.293104	28.95	59.14	67.47	t	t	t
4125	4	2026-03-02 19:44:14.30007	42.47	44.70	54.49	t	t	t
4127	2	2026-03-02 19:44:14.300357	43.85	73.28	23.51	t	f	t
4130	4	2026-03-02 19:44:24.307084	61.76	79.36	29.19	t	t	t
4131	2	2026-03-02 19:44:24.307429	47.15	54.61	22.98	t	t	t
4132	2	2026-03-02 19:44:34.313157	43.89	10.37	31.27	t	t	t
4133	4	2026-03-02 19:44:34.31337	28.77	13.23	52.86	t	t	t
4138	4	2026-03-02 19:44:44.355187	79.87	72.53	43.43	t	t	t
4142	3	2026-03-02 19:44:54.334375	30.29	49.64	43.70	t	t	t
4145	3	2026-03-02 19:45:04.343127	65.85	70.68	28.63	t	t	t
4146	4	2026-03-02 19:45:04.377581	19.48	28.34	37.72	t	f	t
4148	4	2026-03-02 19:45:14.34016	58.02	27.98	55.41	t	t	t
4151	3	2026-03-02 19:45:14.340807	35.97	14.40	60.40	t	t	t
4152	4	2026-03-02 19:45:24.341217	57.51	77.30	52.05	t	t	t
4153	5	2026-03-02 19:45:24.341628	32.27	61.38	66.83	t	t	t
4156	3	2026-03-02 19:45:34.347407	79.19	61.71	52.53	t	t	t
4157	5	2026-03-02 19:45:34.347775	59.40	68.81	23.22	t	t	t
4162	3	2026-03-02 19:45:44.354318	34.31	66.12	42.45	f	t	t
4165	3	2026-03-02 19:45:54.403786	63.19	79.38	28.60	t	t	f
4170	4	2026-03-02 19:46:04.377122	27.77	16.84	51.20	t	t	t
4171	5	2026-03-02 19:46:04.407551	78.78	76.04	43.10	t	t	t
4172	2	2026-03-02 19:46:14.381595	28.96	28.24	34.45	t	t	t
4175	3	2026-03-02 19:46:14.38229	12.34	72.56	34.14	t	t	t
4178	5	2026-03-02 19:46:24.379561	54.03	75.39	41.27	t	t	f
4179	3	2026-03-02 19:46:24.379524	50.40	62.36	41.57	t	t	t
4180	2	2026-03-02 19:46:34.3849	10.00	45.93	29.19	t	t	t
4181	3	2026-03-02 19:46:34.385296	59.86	65.10	49.55	t	t	t
4186	5	2026-03-02 19:46:44.389483	16.19	76.78	47.81	t	t	t
4187	4	2026-03-02 19:46:44.389517	66.81	17.90	64.93	t	t	t
4189	3	2026-03-02 19:46:54.430837	32.12	69.63	62.77	t	t	t
4193	4	2026-03-02 19:47:04.410969	71.24	10.35	50.28	t	t	t
4195	5	2026-03-02 19:47:04.442005	38.32	45.09	54.17	t	t	f
4196	2	2026-03-02 19:47:14.422328	53.19	80.00	24.56	t	t	t
4199	4	2026-03-02 19:47:14.572458	64.74	30.79	68.20	t	t	f
4200	2	2026-03-02 19:47:24.434797	67.86	34.38	57.90	t	t	t
4206	5	2026-03-02 19:47:34.48559	77.52	77.42	36.12	t	t	t
4208	3	2026-03-02 19:47:44.459053	52.90	74.76	23.97	t	t	t
4214	5	2026-03-02 19:47:54.459651	56.58	13.44	68.45	t	t	t
4217	3	2026-03-02 19:48:04.503857	61.79	77.86	33.04	t	t	t
4221	4	2026-03-02 19:48:14.483424	17.63	56.05	56.90	t	t	t
4223	5	2026-03-02 19:48:14.513943	24.34	17.26	43.48	t	t	t
4224	2	2026-03-02 19:48:24.496232	12.37	46.95	55.56	t	t	t
4227	5	2026-03-02 19:48:24.531724	33.14	44.10	33.18	t	t	t
4228	2	2026-03-02 19:48:34.504384	30.68	41.58	28.38	t	t	f
4229	5	2026-03-02 19:48:34.504826	14.05	51.70	22.43	t	t	t
4235	3	2026-03-02 19:48:44.549274	39.56	10.12	43.49	t	t	t
4238	2	2026-03-02 19:48:54.511873	37.42	33.39	40.34	t	t	t
4240	2	2026-03-02 19:49:04.517591	11.91	48.51	55.63	t	f	t
4244	3	2026-03-02 19:49:14.520459	27.82	20.32	28.09	t	t	f
4250	4	2026-03-02 19:49:24.526703	27.42	73.25	31.21	t	t	t
4253	3	2026-03-02 19:49:34.534828	34.53	75.38	69.63	t	t	t
4255	5	2026-03-02 19:49:34.565713	53.10	14.75	52.82	t	f	t
4256	2	2026-03-02 19:49:44.535089	58.38	78.41	55.51	t	t	t
3958	4	2026-03-02 19:37:13.977462	60.99	17.18	63.03	t	t	t
3962	2	2026-03-02 19:37:23.983462	56.24	53.60	36.66	t	f	t
4687	5	2026-03-02 20:07:35.453791	11.81	24.39	58.60	t	t	t
4688	2	2026-03-02 20:07:45.438139	58.17	70.00	57.46	t	t	t
4755	5	2026-03-02 20:10:25.636141	10.44	68.02	32.83	f	t	t
4756	2	2026-03-02 20:10:35.566316	10.64	77.10	63.37	t	t	t
4834	5	2026-03-02 20:13:55.741639	18.93	41.25	32.54	t	t	t
4837	3	2026-03-02 20:14:05.677063	54.83	77.91	35.35	t	t	t
4842	5	2026-03-02 20:14:15.676822	34.17	69.40	20.84	t	t	t
4905	3	2026-03-02 20:16:55.854188	25.36	20.76	27.21	t	t	t
4910	4	2026-03-02 20:17:05.835351	41.25	64.13	22.81	t	t	t
4963	5	2026-03-02 20:19:15.978835	11.26	21.82	49.16	t	t	t
4964	2	2026-03-02 20:19:25.939667	43.84	41.79	27.04	t	t	t
4970	4	2026-03-02 20:19:35.950023	47.89	26.59	37.84	t	t	t
5027	4	2026-03-02 20:21:56.114491	78.00	20.10	44.70	t	t	f
5028	2	2026-03-02 20:22:06.091452	67.94	23.25	46.86	t	t	f
5035	5	2026-03-02 20:22:16.089159	14.61	76.77	38.81	t	t	t
5117	3	2026-03-02 20:25:46.288133	70.21	54.26	50.70	t	t	t
5122	4	2026-03-02 20:25:56.263503	13.53	19.16	49.52	t	f	t
5126	3	2026-03-02 20:26:06.265129	59.10	70.48	57.61	t	t	t
5129	3	2026-03-02 20:26:16.27208	35.37	17.86	38.30	t	t	t
5134	4	2026-03-02 20:26:26.273268	36.02	38.31	50.68	t	t	f
5136	3	2026-03-02 20:26:36.277469	13.63	35.14	54.23	f	t	t
5143	5	2026-03-02 20:26:46.272447	41.17	46.82	31.29	t	t	t
5144	2	2026-03-02 20:26:56.277951	61.83	60.36	45.45	t	t	t
5149	5	2026-03-02 20:27:06.27928	27.98	64.83	28.72	t	t	t
5207	4	2026-03-02 20:29:26.524208	65.14	60.62	27.40	t	t	t
5209	2	2026-03-02 20:29:36.386895	49.44	21.51	23.90	t	t	t
5271	5	2026-03-02 20:32:06.483401	41.47	25.79	65.08	t	t	t
5272	2	2026-03-02 20:32:16.473717	64.80	70.46	28.54	t	t	t
5279	5	2026-03-02 20:32:26.474122	67.93	59.15	30.16	t	t	t
5343	4	2026-03-02 20:35:06.728327	54.50	14.89	31.43	t	t	t
5345	2	2026-03-02 20:35:16.602103	66.48	52.95	58.09	f	t	f
5351	4	2026-03-02 20:35:26.607096	57.20	70.94	34.83	t	t	f
5352	2	2026-03-02 20:35:36.622241	60.84	23.05	21.58	t	t	t
5357	5	2026-03-02 20:35:46.627126	71.58	51.18	42.77	t	t	f
5415	5	2026-03-02 20:38:06.792491	75.60	38.31	59.33	t	t	t
5416	2	2026-03-02 20:38:16.766051	58.42	75.69	20.30	t	t	t
5421	4	2026-03-02 20:38:26.769853	13.22	26.85	35.58	t	t	t
5490	4	2026-03-02 20:41:16.962399	57.13	14.01	42.33	t	t	t
5494	3	2026-03-02 20:41:26.931856	42.37	40.97	69.83	t	t	t
5497	3	2026-03-02 20:41:36.93955	74.85	70.28	53.29	t	t	t
5502	4	2026-03-02 20:41:46.940493	11.06	61.46	53.93	t	f	t
5504	2	2026-03-02 20:41:56.949025	26.08	30.99	54.89	t	t	t
5553	5	2026-03-02 20:43:57.118266	16.21	69.81	21.47	t	t	t
5558	5	2026-03-02 20:44:07.101191	36.88	41.89	51.40	f	t	t
5562	4	2026-03-02 20:44:17.0976	22.24	31.77	21.64	t	t	t
5602	4	2026-03-02 20:45:57.225692	57.06	78.45	35.07	t	t	t
5606	3	2026-03-02 20:46:07.192491	35.92	68.62	65.80	t	t	t
5679	5	2026-03-02 20:49:07.345273	57.44	22.24	50.09	t	f	t
5680	3	2026-03-02 20:49:17.309455	53.48	13.25	40.40	t	t	f
5735	3	2026-03-02 20:51:27.448119	77.66	54.14	64.88	f	t	t
5736	2	2026-03-02 20:51:37.423587	76.31	17.67	20.38	t	t	t
5741	5	2026-03-02 20:51:47.424676	30.80	38.04	26.89	t	t	t
5744	2	2026-03-02 20:51:57.43476	18.82	30.73	53.04	t	t	t
5787	5	2026-03-02 20:53:37.568918	63.86	21.36	63.15	t	t	t
5788	2	2026-03-02 20:53:47.542072	16.87	44.98	33.40	t	f	t
5877	3	2026-03-02 20:57:27.729387	77.14	51.67	21.39	t	t	t
5881	4	2026-03-02 20:57:37.690496	64.81	71.56	44.73	t	t	t
5929	3	2026-03-02 20:59:37.842474	49.16	76.42	62.54	t	t	t
5934	4	2026-03-02 20:59:47.813763	34.42	21.98	67.65	t	t	t
6001	2	2026-03-02 21:02:37.91351	31.45	56.49	32.64	t	t	f
6006	4	2026-03-02 21:02:47.919277	76.39	21.45	45.53	t	t	t
6050	4	2026-03-02 21:04:38.043529	14.93	41.83	47.80	t	t	t
6053	3	2026-03-02 21:04:48.015703	41.89	65.70	47.27	t	t	t
6086	5	2026-03-02 21:06:08.129767	27.35	28.52	63.47	t	t	t
6090	3	2026-03-02 21:06:18.098202	14.72	12.18	45.60	t	t	t
6094	3	2026-03-02 21:06:28.100618	25.71	46.68	51.59	t	t	t
6141	3	2026-03-02 21:08:28.236096	63.46	38.35	65.41	t	f	t
6145	4	2026-03-02 21:08:38.204973	28.07	58.36	34.34	t	t	t
6151	4	2026-03-02 21:08:48.207103	25.06	39.14	49.05	t	f	t
6152	2	2026-03-02 21:08:58.213361	18.44	17.25	56.93	t	f	t
6191	5	2026-03-02 21:10:28.330988	12.19	78.53	28.47	t	t	t
6192	2	2026-03-02 21:10:38.297701	27.19	48.51	23.59	t	f	t
6253	4	2026-03-02 21:13:08.450615	14.57	24.16	50.64	t	t	t
6258	4	2026-03-02 21:13:18.410969	29.75	58.98	65.10	t	t	t
6260	3	2026-03-02 21:13:28.416801	29.06	32.82	20.84	t	t	t
6295	5	2026-03-02 21:14:48.511437	58.66	13.79	68.94	t	t	t
6296	2	2026-03-02 21:14:58.479876	63.73	48.73	38.21	t	t	f
6343	5	2026-03-02 21:16:48.742054	60.57	74.85	21.21	t	t	f
6344	2	2026-03-02 21:16:58.584351	28.63	31.46	35.28	t	t	t
6391	5	2026-03-02 21:18:48.799079	78.72	41.63	59.80	t	t	t
6392	2	2026-03-02 21:18:58.654413	59.30	38.85	69.83	t	t	t
6438	4	2026-03-02 21:20:48.757611	59.37	53.16	35.10	t	t	t
6440	3	2026-03-02 21:20:58.722725	47.01	37.19	45.08	t	t	t
6445	5	2026-03-02 21:21:08.724465	15.08	24.68	51.67	t	t	t
6493	3	2026-03-02 21:23:08.819231	13.76	30.27	55.83	t	f	t
6497	4	2026-03-02 21:23:18.796614	55.17	47.35	20.71	f	t	t
6547	5	2026-03-02 21:25:18.912377	76.11	71.77	27.14	t	t	t
6548	2	2026-03-02 21:25:28.887308	23.25	40.67	54.37	t	t	t
6553	5	2026-03-02 21:25:38.88738	79.96	73.16	28.50	t	t	t
6576	2	2026-03-02 21:26:38.933615	73.91	68.92	50.68	t	t	t
6583	4	2026-03-02 21:26:48.933029	75.43	33.98	57.32	t	t	t
6584	2	2026-03-02 21:26:58.96721	42.04	41.18	49.15	t	t	f
6623	5	2026-03-02 21:28:29.064418	72.06	27.32	21.77	t	t	t
6624	2	2026-03-02 21:28:39.077163	61.79	10.18	62.95	t	t	f
6625	3	2026-03-02 21:28:39.088573	22.65	42.29	62.16	t	t	t
6630	4	2026-03-02 21:28:49.058998	33.41	78.13	56.33	t	t	t
6633	3	2026-03-02 21:28:59.059319	17.50	51.38	65.04	t	t	t
6667	5	2026-03-02 21:30:19.148246	30.31	64.30	63.58	t	f	f
6668	2	2026-03-02 21:30:29.105499	76.52	32.34	29.69	t	t	t
6709	2	2026-03-02 21:32:09.21474	33.37	72.64	21.17	t	t	t
6713	4	2026-03-02 21:32:19.188726	16.64	56.31	57.29	t	t	t
6716	3	2026-03-02 21:32:29.215517	66.79	20.47	50.58	t	t	t
6737	4	2026-03-02 21:33:19.303084	42.03	70.58	56.89	t	f	t
6742	4	2026-03-02 21:33:29.276656	18.87	31.78	23.87	t	t	t
6767	4	2026-03-02 21:34:29.480681	55.45	42.12	31.50	t	t	t
3965	3	2026-03-02 19:37:34.02982	28.29	42.50	48.10	t	t	t
3968	5	2026-03-02 19:37:43.990438	78.38	42.00	57.50	t	t	t
3973	4	2026-03-02 19:37:54.030956	67.69	38.01	43.76	t	t	t
3976	4	2026-03-02 19:38:04.010286	36.12	34.86	59.98	t	t	t
3979	5	2026-03-02 19:38:04.041456	18.44	59.37	27.34	t	t	t
3981	5	2026-03-02 19:38:14.016613	71.08	64.81	64.90	t	t	t
3982	2	2026-03-02 19:38:14.016826	61.15	72.75	34.04	t	t	t
3987	3	2026-03-02 19:38:24.17274	52.88	47.14	29.64	t	t	t
3990	2	2026-03-02 19:38:34.036437	68.51	71.12	66.10	t	t	t
3994	4	2026-03-02 19:38:44.080099	45.93	53.69	43.63	t	t	t
3998	3	2026-03-02 19:38:54.052587	32.77	55.49	21.76	t	t	t
4000	3	2026-03-02 19:39:04.054458	29.11	72.76	22.88	t	t	t
4005	4	2026-03-02 19:39:14.100321	74.09	20.95	53.27	t	t	t
4011	4	2026-03-02 19:39:24.070303	65.23	57.03	25.28	t	t	f
4012	2	2026-03-02 19:39:34.084532	32.30	29.94	25.12	t	t	t
4013	3	2026-03-02 19:39:34.118375	41.23	26.44	31.88	t	t	t
4017	4	2026-03-02 19:39:44.086667	60.43	13.42	20.34	t	t	t
4018	5	2026-03-02 19:39:44.086805	60.80	39.98	41.77	t	t	t
4021	3	2026-03-02 19:39:54.127951	12.06	16.71	52.52	t	t	t
4024	4	2026-03-02 19:40:04.104439	46.16	11.59	42.69	t	t	t
4029	5	2026-03-02 19:40:14.111509	72.57	41.36	64.47	t	t	t
4035	4	2026-03-02 19:40:24.120394	35.25	78.91	50.99	t	t	f
4037	3	2026-03-02 19:40:34.169969	12.17	31.47	26.01	t	t	t
4043	3	2026-03-02 19:40:44.139628	43.45	38.75	38.57	t	t	t
4044	2	2026-03-02 19:40:54.147727	53.29	58.93	69.97	t	t	f
4045	3	2026-03-02 19:40:54.1815	46.21	64.51	38.24	t	t	t
4050	4	2026-03-02 19:41:04.156876	79.52	56.75	48.18	t	t	t
4051	5	2026-03-02 19:41:04.185307	49.22	57.63	64.09	t	t	t
4052	2	2026-03-02 19:41:14.169882	31.02	74.23	44.54	t	t	t
4055	4	2026-03-02 19:41:14.207692	61.51	30.74	42.64	t	t	t
4058	2	2026-03-02 19:41:24.16844	53.42	14.06	28.63	t	t	t
4059	5	2026-03-02 19:41:24.168727	54.35	67.32	68.14	t	t	t
4060	2	2026-03-02 19:41:34.171725	64.45	28.88	20.84	t	t	t
4063	4	2026-03-02 19:41:34.1724	59.45	29.48	48.15	t	t	t
4064	4	2026-03-02 19:41:44.175177	17.33	77.74	40.54	t	t	f
4065	5	2026-03-02 19:41:44.175691	68.57	28.68	26.30	t	t	t
4069	5	2026-03-02 19:41:54.183705	55.06	45.25	59.70	t	f	t
4071	4	2026-03-02 19:41:54.184299	34.45	37.46	58.92	t	t	t
4075	3	2026-03-02 19:42:04.339833	55.56	24.30	57.85	t	t	t
4076	2	2026-03-02 19:42:14.196902	22.11	32.70	52.47	t	t	t
4081	5	2026-03-02 19:42:24.199643	73.98	52.00	55.60	t	t	t
4087	4	2026-03-02 19:42:34.253203	30.64	27.93	23.41	t	t	t
4090	2	2026-03-02 19:42:44.221069	18.37	34.66	58.62	t	t	t
4095	4	2026-03-02 19:42:54.378781	66.81	35.13	56.23	t	t	t
4097	2	2026-03-02 19:43:04.238829	18.56	79.37	45.84	t	t	t
4103	5	2026-03-02 19:43:14.286458	72.99	75.14	60.68	t	t	t
4105	2	2026-03-02 19:43:24.262485	41.51	71.28	23.56	t	t	t
4108	3	2026-03-02 19:43:34.26751	20.52	60.44	38.95	t	t	t
4114	5	2026-03-02 19:43:44.311235	79.38	70.11	52.44	t	t	t
4117	3	2026-03-02 19:43:54.295145	38.68	40.15	50.05	t	t	t
4120	4	2026-03-02 19:44:04.292485	10.98	41.04	34.68	t	t	t
4126	5	2026-03-02 19:44:14.300143	78.51	78.47	27.16	t	t	t
4128	3	2026-03-02 19:44:24.306541	28.98	35.20	63.37	t	f	t
4135	5	2026-03-02 19:44:34.345479	12.93	74.60	44.60	t	t	t
4136	2	2026-03-02 19:44:44.320583	10.70	76.74	25.56	t	t	t
4139	5	2026-03-02 19:44:44.356214	47.31	67.35	45.81	t	t	t
4140	2	2026-03-02 19:44:54.333684	71.15	24.75	42.45	t	t	f
4147	5	2026-03-02 19:45:04.377744	19.08	75.54	46.48	t	t	t
4150	2	2026-03-02 19:45:14.340504	14.86	14.84	45.12	t	t	t
4155	3	2026-03-02 19:45:24.342093	16.02	47.74	69.27	t	t	t
4158	2	2026-03-02 19:45:34.347906	49.01	55.16	26.30	f	t	t
4161	4	2026-03-02 19:45:44.354047	77.58	63.98	55.30	t	t	t
4166	4	2026-03-02 19:45:54.405118	28.78	17.26	48.77	t	t	t
4169	3	2026-03-02 19:46:04.376917	75.33	67.08	27.43	f	t	t
4174	4	2026-03-02 19:46:14.382034	65.74	76.49	53.58	t	f	t
4177	4	2026-03-02 19:46:24.379303	52.53	27.32	25.57	t	t	t
4182	5	2026-03-02 19:46:34.414484	61.89	72.23	22.44	t	f	f
4185	3	2026-03-02 19:46:44.389398	69.68	12.46	34.28	t	t	t
4188	2	2026-03-02 19:46:54.397934	43.14	50.96	41.47	t	t	t
4190	5	2026-03-02 19:46:54.431163	33.63	52.93	68.82	t	t	t
4194	3	2026-03-02 19:47:04.411038	24.20	24.51	47.28	t	t	f
4197	3	2026-03-02 19:47:14.45296	50.41	39.52	49.18	t	t	t
4201	4	2026-03-02 19:47:24.435092	64.73	71.97	45.68	f	t	t
4203	5	2026-03-02 19:47:24.584598	41.41	53.77	30.05	t	t	t
4204	2	2026-03-02 19:47:34.449028	39.84	24.69	34.76	t	t	f
4207	4	2026-03-02 19:47:34.485713	21.93	26.13	32.46	t	f	f
4209	2	2026-03-02 19:47:44.459488	20.33	52.90	46.72	f	t	t
4215	3	2026-03-02 19:47:54.459925	79.13	79.80	63.92	t	t	f
4218	4	2026-03-02 19:48:04.507048	13.26	36.36	45.96	t	t	t
4220	3	2026-03-02 19:48:14.482947	66.40	54.95	40.86	t	t	t
4225	3	2026-03-02 19:48:24.528729	70.12	40.81	59.20	t	t	t
4231	4	2026-03-02 19:48:34.505229	33.46	70.20	55.19	t	t	t
4232	2	2026-03-02 19:48:44.511667	32.64	71.58	67.20	t	t	t
4233	4	2026-03-02 19:48:44.544643	63.06	49.56	21.23	t	t	t
4236	4	2026-03-02 19:48:54.511249	36.39	30.44	39.85	t	t	t
4237	5	2026-03-02 19:48:54.511542	58.89	76.15	60.33	t	t	t
4241	5	2026-03-02 19:49:04.517847	16.25	29.00	60.82	t	t	t
4242	4	2026-03-02 19:49:04.518048	79.81	16.39	40.72	t	t	t
4245	5	2026-03-02 19:49:14.520718	25.01	18.56	23.38	t	t	f
4246	2	2026-03-02 19:49:14.520878	15.55	71.39	67.04	t	f	t
4249	2	2026-03-02 19:49:24.526731	72.26	18.32	66.15	t	t	t
4251	5	2026-03-02 19:49:24.554181	13.49	46.64	24.14	t	t	t
4252	2	2026-03-02 19:49:34.534629	12.92	74.30	52.37	t	t	t
4257	5	2026-03-02 19:49:44.535382	65.49	34.96	63.15	t	t	t
4259	4	2026-03-02 19:49:44.535827	26.49	16.75	69.63	t	t	t
4262	3	2026-03-02 19:49:54.589333	25.91	65.80	24.11	t	t	t
4267	3	2026-03-02 19:50:04.560424	29.04	65.84	48.81	t	t	t
4268	2	2026-03-02 19:50:14.572869	28.24	34.07	63.91	t	t	t
4269	3	2026-03-02 19:50:14.603759	30.69	27.60	27.38	t	t	t
4271	5	2026-03-02 19:50:14.606941	31.68	78.00	27.42	t	t	t
4272	2	2026-03-02 19:50:24.57681	40.14	59.53	28.26	t	t	t
4273	5	2026-03-02 19:50:24.577047	67.75	72.96	62.88	f	f	t
4275	4	2026-03-02 19:50:24.577289	60.95	41.59	28.75	t	t	t
4276	2	2026-03-02 19:50:34.588299	26.26	61.78	64.09	f	t	f
4278	5	2026-03-02 19:50:34.624265	71.50	36.43	48.45	t	t	t
4281	4	2026-03-02 19:50:44.589718	53.81	68.37	24.35	t	t	t
4283	5	2026-03-02 19:50:44.590247	39.58	70.03	46.43	t	f	f
3966	4	2026-03-02 19:37:34.034565	63.26	44.84	47.35	t	t	t
3971	3	2026-03-02 19:37:43.991047	74.84	22.11	20.88	t	t	t
3972	2	2026-03-02 19:37:53.999778	33.82	11.06	42.98	t	t	t
3974	5	2026-03-02 19:37:54.032901	39.44	45.35	39.50	t	t	f
3977	2	2026-03-02 19:38:04.009943	65.88	25.64	26.61	t	t	f
3983	3	2026-03-02 19:38:14.01697	25.07	44.31	23.20	t	t	f
3984	2	2026-03-02 19:38:24.026034	26.69	57.69	59.32	t	t	t
3985	4	2026-03-02 19:38:24.05875	58.23	17.50	52.61	t	t	t
3989	4	2026-03-02 19:38:34.036362	24.33	38.98	50.29	t	t	t
3991	5	2026-03-02 19:38:34.068202	71.68	60.91	43.65	t	t	t
3992	2	2026-03-02 19:38:44.045181	51.69	77.88	56.38	t	t	f
3995	5	2026-03-02 19:38:44.081386	23.72	14.83	62.71	t	t	t
3996	2	2026-03-02 19:38:54.051492	62.38	77.16	53.96	t	t	t
4001	5	2026-03-02 19:39:04.054941	14.85	76.22	59.01	t	t	t
4006	5	2026-03-02 19:39:14.100538	43.92	50.73	31.69	t	f	t
4009	2	2026-03-02 19:39:24.070153	52.91	14.41	62.08	t	t	f
4014	4	2026-03-02 19:39:34.120945	46.89	51.35	30.61	t	t	t
4019	2	2026-03-02 19:39:44.087058	31.45	68.23	26.52	t	t	t
4020	2	2026-03-02 19:39:54.098909	33.16	72.01	30.05	t	t	f
4022	5	2026-03-02 19:39:54.247609	55.65	66.20	36.63	t	f	t
4025	5	2026-03-02 19:40:04.104706	43.83	36.86	21.89	t	t	t
4026	3	2026-03-02 19:40:04.104868	47.42	14.30	24.67	t	t	t
4028	2	2026-03-02 19:40:14.111266	14.43	76.07	30.34	t	t	f
4030	4	2026-03-02 19:40:14.111711	76.29	79.09	58.08	t	t	f
4033	5	2026-03-02 19:40:24.119689	19.05	40.02	25.82	t	f	t
4034	3	2026-03-02 19:40:24.120211	49.02	44.99	55.53	t	t	t
4036	2	2026-03-02 19:40:34.132457	49.78	77.36	59.78	t	t	f
4038	5	2026-03-02 19:40:34.171744	27.73	25.04	68.99	t	t	t
4041	4	2026-03-02 19:40:44.138972	78.10	75.39	21.83	t	t	t
4042	5	2026-03-02 19:40:44.139262	44.00	61.32	45.27	t	t	t
4046	4	2026-03-02 19:40:54.181793	56.67	66.74	44.23	t	t	t
4049	3	2026-03-02 19:41:04.156548	50.68	72.35	59.85	t	t	t
4053	3	2026-03-02 19:41:14.202331	14.99	23.49	57.29	t	f	t
4056	4	2026-03-02 19:41:24.168028	65.24	55.02	56.20	t	f	t
4061	5	2026-03-02 19:41:34.172	25.71	73.25	45.18	t	t	t
4067	2	2026-03-02 19:41:44.176216	74.16	62.75	25.64	t	t	t
4068	3	2026-03-02 19:41:54.183307	20.88	46.37	42.86	t	t	t
4073	4	2026-03-02 19:42:04.22694	54.27	46.12	36.20	t	f	f
4079	4	2026-03-02 19:42:14.197608	75.67	73.52	49.15	t	t	t
4080	2	2026-03-02 19:42:24.199468	52.79	54.56	54.59	t	t	t
4085	2	2026-03-02 19:42:34.249737	46.85	20.78	40.00	t	t	t
4091	5	2026-03-02 19:42:44.221246	44.45	44.83	39.92	t	f	t
4092	2	2026-03-02 19:42:54.234075	23.85	63.88	35.77	t	t	t
4093	3	2026-03-02 19:42:54.263806	45.92	56.77	28.29	t	t	t
4096	5	2026-03-02 19:43:04.238585	47.32	71.60	20.52	t	t	f
4099	3	2026-03-02 19:43:04.239275	46.51	41.64	40.69	t	t	t
4101	3	2026-03-02 19:43:14.284398	38.40	52.56	37.09	t	t	t
4106	4	2026-03-02 19:43:24.262634	76.26	23.66	60.73	t	f	t
4107	5	2026-03-02 19:43:24.293361	75.89	54.76	51.04	t	t	t
4109	2	2026-03-02 19:43:34.267735	18.32	21.93	40.95	t	t	t
4111	4	2026-03-02 19:43:34.268164	55.28	59.85	68.56	t	t	f
4112	2	2026-03-02 19:43:44.27734	62.46	53.71	45.02	t	f	t
4115	3	2026-03-02 19:43:44.416378	76.73	44.31	57.29	t	f	t
4118	2	2026-03-02 19:43:54.295448	21.07	33.28	45.56	t	t	t
4122	5	2026-03-02 19:44:04.292825	11.03	73.09	56.77	t	t	f
4124	3	2026-03-02 19:44:14.299771	69.73	37.70	47.32	t	t	t
4129	5	2026-03-02 19:44:24.306883	55.46	70.46	51.42	f	t	t
4134	3	2026-03-02 19:44:34.313515	36.86	69.20	36.67	t	t	t
4137	3	2026-03-02 19:44:44.352874	66.84	33.16	43.08	t	t	t
4141	4	2026-03-02 19:44:54.334121	20.82	31.30	58.09	t	t	t
4143	5	2026-03-02 19:44:54.365298	17.66	10.68	51.71	t	t	t
4144	2	2026-03-02 19:45:04.342699	46.30	69.17	42.41	t	t	t
4149	5	2026-03-02 19:45:14.340331	66.01	36.42	33.66	t	t	f
4154	2	2026-03-02 19:45:24.341784	75.34	51.72	60.40	t	t	f
4159	4	2026-03-02 19:45:34.34811	60.17	13.48	59.17	t	t	t
4160	2	2026-03-02 19:45:44.353737	25.08	43.72	50.04	t	t	t
4163	5	2026-03-02 19:45:44.387908	22.82	13.93	69.73	t	t	t
4164	2	2026-03-02 19:45:54.368125	61.29	57.19	27.67	t	t	f
4167	5	2026-03-02 19:45:54.408373	28.35	57.23	42.32	t	t	t
4168	2	2026-03-02 19:46:04.37669	32.50	28.39	39.59	t	t	f
4173	5	2026-03-02 19:46:14.381873	72.60	28.42	26.97	t	t	t
4176	2	2026-03-02 19:46:24.379163	35.34	35.79	26.65	t	t	t
4183	4	2026-03-02 19:46:34.419992	41.55	42.56	35.57	t	t	t
4184	2	2026-03-02 19:46:44.389134	54.46	32.52	63.91	t	t	t
4191	4	2026-03-02 19:46:54.549657	72.26	39.70	59.20	t	t	t
4192	2	2026-03-02 19:47:04.410509	64.56	73.24	53.97	t	t	f
4198	5	2026-03-02 19:47:14.456233	40.32	62.79	28.63	t	t	t
4202	3	2026-03-02 19:47:24.435222	47.79	26.54	46.97	t	t	t
4205	3	2026-03-02 19:47:34.479975	45.61	35.08	47.39	t	t	t
4210	4	2026-03-02 19:47:44.459782	43.53	27.03	51.96	t	t	t
4211	5	2026-03-02 19:47:44.489986	65.33	71.85	66.00	t	t	t
4212	4	2026-03-02 19:47:54.459326	72.02	45.84	37.86	t	t	t
4213	2	2026-03-02 19:47:54.459491	71.35	34.01	65.83	t	t	f
4216	2	2026-03-02 19:48:04.47024	31.20	57.40	51.36	t	t	t
4219	5	2026-03-02 19:48:04.507161	50.11	58.26	26.81	t	t	t
4222	2	2026-03-02 19:48:14.483647	79.94	68.94	45.53	t	t	f
4226	4	2026-03-02 19:48:24.531432	38.46	15.34	67.20	t	f	t
4230	3	2026-03-02 19:48:34.505034	44.19	57.60	31.54	t	f	t
4234	5	2026-03-02 19:48:44.548926	19.88	40.58	41.98	t	t	t
4239	3	2026-03-02 19:48:54.512002	53.76	29.78	38.49	t	t	t
4243	3	2026-03-02 19:49:04.518287	42.26	73.49	29.02	t	t	t
4247	4	2026-03-02 19:49:14.52121	14.22	74.34	59.01	t	t	t
4248	3	2026-03-02 19:49:24.526417	46.15	13.77	57.87	t	t	t
4254	4	2026-03-02 19:49:34.56483	13.95	46.59	35.88	t	t	t
4258	3	2026-03-02 19:49:44.535546	50.24	11.67	66.35	t	t	f
4260	5	2026-03-02 19:49:54.553101	41.31	57.23	44.12	t	t	t
4261	2	2026-03-02 19:49:54.588723	72.23	42.89	43.55	t	t	t
4263	4	2026-03-02 19:49:54.592573	19.74	18.19	57.20	t	t	f
4264	2	2026-03-02 19:50:04.559569	44.18	57.37	28.61	t	t	t
4265	5	2026-03-02 19:50:04.55992	79.48	27.60	62.90	t	t	t
4266	4	2026-03-02 19:50:04.560105	64.42	21.08	38.29	t	t	t
4270	4	2026-03-02 19:50:14.605875	57.64	25.55	54.42	t	t	t
4274	3	2026-03-02 19:50:24.577347	71.03	23.49	34.83	t	t	t
4277	3	2026-03-02 19:50:34.621749	44.11	29.76	36.21	t	t	t
4279	4	2026-03-02 19:50:34.737627	76.24	34.34	58.18	t	t	t
4280	3	2026-03-02 19:50:44.588383	45.92	73.86	40.13	t	t	t
4282	2	2026-03-02 19:50:44.590061	64.23	24.62	40.19	t	t	f
4284	3	2026-03-02 19:50:54.59688	18.79	62.47	28.49	t	t	t
4290	5	2026-03-02 19:51:04.601054	26.57	71.82	35.89	t	t	t
4689	3	2026-03-02 20:07:45.46985	58.93	36.73	36.62	t	t	t
4694	4	2026-03-02 20:07:55.443137	72.61	52.70	59.87	t	t	t
4761	2	2026-03-02 20:10:45.619646	42.03	54.89	42.79	t	t	f
4767	4	2026-03-02 20:10:55.582954	19.04	59.87	42.41	t	t	t
4768	2	2026-03-02 20:11:05.587252	13.94	30.87	28.10	t	t	t
4835	4	2026-03-02 20:13:55.850684	70.17	45.64	52.01	t	t	t
4836	2	2026-03-02 20:14:05.676867	72.29	18.47	53.67	t	t	t
4843	4	2026-03-02 20:14:15.677051	74.89	62.57	43.28	t	t	t
4844	3	2026-03-02 20:14:25.690473	49.29	37.24	21.84	t	t	t
4906	5	2026-03-02 20:16:55.856714	29.31	78.26	43.22	t	t	f
4909	3	2026-03-02 20:17:05.834434	37.28	63.88	62.07	t	t	t
4973	2	2026-03-02 20:19:45.963915	76.29	77.89	45.81	f	t	t
5031	5	2026-03-02 20:22:06.140268	66.08	70.88	67.80	t	t	t
5032	2	2026-03-02 20:22:16.088266	65.52	30.89	23.56	t	t	t
5118	5	2026-03-02 20:25:46.294291	19.00	79.49	20.78	t	t	t
5121	3	2026-03-02 20:25:56.263233	60.04	64.47	30.60	t	t	f
5125	4	2026-03-02 20:26:06.265013	10.42	24.51	43.25	t	f	t
5130	4	2026-03-02 20:26:16.272473	66.46	37.56	49.57	t	t	t
5133	3	2026-03-02 20:26:26.273007	15.39	33.41	59.00	t	t	t
5139	4	2026-03-02 20:26:36.278344	38.20	16.01	24.83	t	t	t
5140	2	2026-03-02 20:26:46.271677	40.84	52.18	57.26	t	t	t
5210	4	2026-03-02 20:29:36.421327	79.18	15.66	22.69	t	t	t
5212	2	2026-03-02 20:29:46.384091	33.03	68.64	62.73	t	f	t
5273	3	2026-03-02 20:32:16.506091	70.28	47.15	56.76	t	t	t
5278	4	2026-03-02 20:32:26.473639	67.72	39.36	35.77	t	t	t
5282	2	2026-03-02 20:32:36.474928	17.74	63.80	65.05	t	f	t
5287	4	2026-03-02 20:32:46.477909	77.59	58.57	40.14	t	f	t
5289	3	2026-03-02 20:32:56.472362	79.33	46.35	24.76	t	t	t
5346	4	2026-03-02 20:35:16.634075	70.68	46.05	27.67	t	t	t
5350	3	2026-03-02 20:35:26.606797	18.53	77.79	33.69	t	t	t
5418	3	2026-03-02 20:38:16.799848	52.41	27.24	68.46	t	t	t
5423	3	2026-03-02 20:38:26.770362	49.48	69.18	28.21	t	t	t
5491	5	2026-03-02 20:41:16.962753	55.47	16.75	64.98	t	f	t
5492	2	2026-03-02 20:41:26.931401	19.11	35.46	42.89	t	t	t
5554	4	2026-03-02 20:43:57.231992	63.25	79.18	41.92	t	t	t
5557	3	2026-03-02 20:44:07.100825	43.71	30.46	50.62	t	t	t
5603	5	2026-03-02 20:45:57.226393	15.42	76.70	64.05	t	f	t
5604	2	2026-03-02 20:46:07.192332	17.49	22.13	46.49	t	t	t
5684	2	2026-03-02 20:49:27.318084	23.40	31.36	35.82	t	t	f
5739	5	2026-03-02 20:51:37.571377	70.82	37.33	31.30	t	t	t
5740	3	2026-03-02 20:51:47.424571	79.88	38.95	29.18	t	t	t
5791	5	2026-03-02 20:53:47.573481	66.92	65.24	31.76	t	t	t
5792	2	2026-03-02 20:53:57.558752	57.01	42.06	64.15	t	f	t
5797	5	2026-03-02 20:54:07.561154	21.14	17.87	59.14	t	t	t
5802	4	2026-03-02 20:54:17.567899	76.59	48.14	50.64	t	t	t
5804	2	2026-03-02 20:54:27.571499	11.76	59.69	41.46	t	t	t
5810	4	2026-03-02 20:54:37.575471	15.33	39.11	60.77	t	t	t
5812	2	2026-03-02 20:54:47.590432	45.20	48.85	25.38	t	f	t
5878	4	2026-03-02 20:57:27.734011	55.65	60.72	30.73	t	t	t
5882	3	2026-03-02 20:57:37.690599	13.91	29.62	46.55	t	t	t
5885	2	2026-03-02 20:57:47.698572	21.71	79.50	57.18	t	t	t
5930	4	2026-03-02 20:59:37.848229	11.68	73.86	40.59	t	t	t
5933	3	2026-03-02 20:59:47.813661	76.44	15.35	44.70	t	t	t
6002	4	2026-03-02 21:02:38.065986	17.21	10.08	22.11	t	t	t
6005	3	2026-03-02 21:02:47.919164	47.34	62.33	33.47	t	t	t
6051	5	2026-03-02 21:04:38.043723	47.80	24.92	23.49	t	t	t
6052	2	2026-03-02 21:04:48.015578	24.23	22.55	69.80	t	t	f
6087	4	2026-03-02 21:06:08.229541	54.51	50.68	59.49	t	t	t
6088	2	2026-03-02 21:06:18.097969	38.39	70.87	39.57	t	t	t
6093	4	2026-03-02 21:06:28.100433	73.03	72.74	28.78	t	t	t
6142	5	2026-03-02 21:08:28.240759	23.40	38.84	28.60	t	f	t
6146	3	2026-03-02 21:08:38.205026	34.77	58.73	63.42	t	t	t
6149	3	2026-03-02 21:08:48.206769	24.83	70.89	36.35	t	t	t
6153	3	2026-03-02 21:08:58.214008	43.02	14.03	37.32	t	t	t
6199	5	2026-03-02 21:10:48.438429	74.29	21.53	24.51	t	t	f
6200	2	2026-03-02 21:10:58.307554	16.48	78.36	34.43	t	t	t
6254	3	2026-03-02 21:13:08.450759	48.23	54.86	40.25	t	t	f
6257	3	2026-03-02 21:13:18.410536	14.46	75.12	42.47	t	t	t
6299	5	2026-03-02 21:14:58.617588	24.76	37.87	40.84	t	t	t
6300	2	2026-03-02 21:15:08.493641	62.46	35.65	27.32	t	t	t
6347	5	2026-03-02 21:16:58.615668	78.92	17.78	56.03	t	t	t
6349	2	2026-03-02 21:17:08.594924	21.38	69.19	61.70	t	t	t
6354	4	2026-03-02 21:17:18.59121	11.08	53.37	30.23	t	t	t
6397	3	2026-03-02 21:19:08.700224	16.29	73.48	23.97	t	t	t
6403	4	2026-03-02 21:19:18.665323	55.05	75.71	23.16	t	t	t
6439	5	2026-03-02 21:20:48.762499	66.44	45.12	58.15	t	f	t
6442	2	2026-03-02 21:20:58.723357	21.64	35.16	27.75	t	t	t
6446	2	2026-03-02 21:21:08.724811	59.01	27.20	25.45	t	t	t
6494	5	2026-03-02 21:23:08.825925	44.00	35.35	54.19	t	t	f
6498	3	2026-03-02 21:23:18.796884	72.85	78.51	45.70	t	t	t
6549	3	2026-03-02 21:25:28.919774	29.11	21.68	58.76	t	t	t
6554	3	2026-03-02 21:25:38.887555	18.14	73.88	56.57	t	f	f
6577	3	2026-03-02 21:26:38.934042	13.24	77.92	42.10	t	t	t
6581	5	2026-03-02 21:26:48.932562	54.26	20.38	48.63	t	t	t
6626	5	2026-03-02 21:28:39.126457	74.87	36.68	50.54	t	f	t
6629	3	2026-03-02 21:28:49.058873	22.03	63.81	59.06	t	t	f
6634	4	2026-03-02 21:28:59.059617	44.42	25.19	54.95	t	t	t
6673	4	2026-03-02 21:30:39.14994	48.18	25.85	34.90	t	t	f
6678	4	2026-03-02 21:30:49.120131	12.79	63.49	52.43	t	f	t
6710	4	2026-03-02 21:32:09.2171	71.94	63.52	25.77	t	t	t
6714	2	2026-03-02 21:32:19.188816	16.79	17.90	33.64	t	t	t
6738	2	2026-03-02 21:33:19.308024	29.92	21.71	25.87	t	t	t
6743	3	2026-03-02 21:33:29.277015	49.43	35.22	35.80	t	t	t
6744	2	2026-03-02 21:33:39.288461	40.56	31.12	33.51	t	t	t
6768	2	2026-03-02 21:34:39.336829	50.51	10.28	67.14	t	t	t
6773	5	2026-03-02 21:34:49.340435	11.16	64.07	58.21	t	t	t
6777	2	2026-03-02 21:34:59.340965	72.36	12.70	30.55	t	t	t
6801	3	2026-03-02 21:35:59.428155	22.49	24.49	65.74	t	t	t
6810	5	2026-03-02 21:36:19.454376	50.05	60.51	51.13	t	t	t
6815	3	2026-03-02 21:36:29.419268	77.68	34.42	20.24	t	f	t
6816	2	2026-03-02 21:36:39.416787	18.39	68.18	51.94	t	t	t
6830	5	2026-03-02 21:37:09.494039	36.07	41.17	51.26	t	t	t
6835	3	2026-03-02 21:37:19.467099	26.62	31.34	36.01	t	t	t
6838	3	2026-03-02 21:37:29.518295	66.98	77.22	28.33	t	t	t
6840	3	2026-03-02 21:37:39.491326	74.69	22.17	65.29	t	t	f
4285	2	2026-03-02 19:50:54.596973	41.70	26.83	49.68	t	t	t
4291	4	2026-03-02 19:51:04.601351	43.25	10.85	55.86	t	t	t
4292	2	2026-03-02 19:51:14.6148	11.52	76.48	24.95	t	t	t
4690	4	2026-03-02 20:07:45.474227	32.22	33.49	23.95	t	t	t
4693	3	2026-03-02 20:07:55.442076	68.16	71.52	34.65	t	f	t
4762	4	2026-03-02 20:10:45.622541	13.73	52.99	35.07	t	t	f
4765	3	2026-03-02 20:10:55.582452	60.50	30.60	56.00	t	t	t
4771	4	2026-03-02 20:11:05.587709	25.71	63.89	48.34	t	t	t
4845	2	2026-03-02 20:14:25.726211	18.80	21.88	41.57	t	t	t
4850	4	2026-03-02 20:14:35.700861	38.64	74.49	64.91	t	t	t
4907	4	2026-03-02 20:16:55.971306	23.13	71.46	53.40	t	t	t
4908	2	2026-03-02 20:17:05.833724	26.32	62.87	61.91	t	t	t
4974	4	2026-03-02 20:19:45.996375	66.91	65.85	59.93	t	t	f
4977	3	2026-03-02 20:19:55.974285	55.87	15.50	52.90	t	t	t
5037	3	2026-03-02 20:22:26.13318	23.27	25.15	54.11	t	t	f
5042	4	2026-03-02 20:22:36.112042	61.29	58.02	25.93	t	t	t
5045	3	2026-03-02 20:22:46.113277	71.78	48.14	58.04	t	t	t
5119	4	2026-03-02 20:25:46.406218	11.64	42.90	20.29	t	t	t
5120	2	2026-03-02 20:25:56.262909	16.34	77.14	37.30	f	t	t
5127	5	2026-03-02 20:26:06.265414	25.00	14.32	31.53	t	f	t
5128	2	2026-03-02 20:26:16.271513	53.83	20.58	23.23	t	t	t
5135	5	2026-03-02 20:26:26.273521	52.65	16.32	24.14	t	t	f
5138	2	2026-03-02 20:26:36.277775	46.35	48.87	50.43	t	f	t
5141	3	2026-03-02 20:26:46.271791	56.59	72.14	55.19	t	t	t
5211	5	2026-03-02 20:29:36.426603	18.70	25.01	34.04	t	t	t
5214	3	2026-03-02 20:29:46.384424	10.34	45.46	47.44	t	t	t
5274	4	2026-03-02 20:32:16.508914	13.65	29.21	55.89	t	t	t
5277	3	2026-03-02 20:32:26.473576	27.60	36.90	22.15	t	t	t
5280	3	2026-03-02 20:32:36.474375	47.18	25.27	67.67	t	t	t
5285	5	2026-03-02 20:32:46.477424	11.80	21.66	26.39	t	t	t
5290	4	2026-03-02 20:32:56.473309	20.48	41.78	46.34	t	t	t
5347	5	2026-03-02 20:35:16.635469	42.25	16.81	32.37	t	t	t
5348	2	2026-03-02 20:35:26.605902	50.84	28.77	64.96	t	t	t
5419	4	2026-03-02 20:38:16.800509	19.32	41.92	66.32	t	t	t
5420	2	2026-03-02 20:38:26.769566	44.86	71.39	50.17	t	t	t
5499	5	2026-03-02 20:41:36.96988	25.69	20.67	44.95	t	t	f
5500	2	2026-03-02 20:41:46.939973	44.53	55.69	63.51	t	t	t
5555	3	2026-03-02 20:43:57.23235	61.53	55.18	59.25	t	t	t
5556	2	2026-03-02 20:44:07.100313	50.77	78.80	20.52	t	t	t
5560	3	2026-03-02 20:44:17.097432	37.23	19.18	45.41	t	t	t
5608	3	2026-03-02 20:46:17.204812	79.55	38.80	21.93	t	t	t
5615	4	2026-03-02 20:46:27.208809	31.79	22.85	63.93	t	t	t
5616	2	2026-03-02 20:46:37.213325	10.21	73.47	24.97	t	t	t
5623	5	2026-03-02 20:46:47.212064	58.13	27.08	28.83	t	f	f
5625	2	2026-03-02 20:46:57.226814	13.82	12.72	52.58	t	t	t
5630	4	2026-03-02 20:47:07.226018	48.63	21.87	69.97	t	t	t
5633	3	2026-03-02 20:47:17.235961	59.71	41.67	55.84	t	t	t
5685	3	2026-03-02 20:49:27.35375	11.52	47.26	36.88	t	t	t
5690	4	2026-03-02 20:49:37.327658	29.06	63.60	21.35	t	t	f
5746	4	2026-03-02 20:51:57.465039	79.88	16.18	30.68	t	t	t
5749	3	2026-03-02 20:52:07.443293	29.79	55.20	42.05	t	t	t
5793	3	2026-03-02 20:53:57.590516	59.98	14.10	21.61	t	t	t
5798	4	2026-03-02 20:54:07.561384	68.72	72.50	24.16	t	t	t
5800	2	2026-03-02 20:54:17.567208	68.32	74.25	67.63	t	t	t
5807	5	2026-03-02 20:54:27.572582	23.45	38.02	54.88	t	t	t
5808	2	2026-03-02 20:54:37.575002	51.31	73.29	25.86	t	t	f
5879	5	2026-03-02 20:57:27.737124	58.60	71.13	68.49	t	t	t
5880	2	2026-03-02 20:57:37.690289	34.92	75.73	43.96	f	t	t
5931	5	2026-03-02 20:59:37.850104	66.27	19.70	31.47	t	t	f
5932	2	2026-03-02 20:59:47.813298	58.84	48.65	35.18	t	t	f
6003	5	2026-03-02 21:02:38.06849	29.24	72.97	38.61	t	t	t
6004	2	2026-03-02 21:02:47.918945	40.58	32.31	29.71	t	f	f
6054	4	2026-03-02 21:04:48.049826	36.74	11.78	27.74	t	t	f
6056	3	2026-03-02 21:04:58.024933	60.52	14.44	53.10	t	t	t
6097	3	2026-03-02 21:06:38.14569	16.70	74.29	22.18	t	t	t
6102	4	2026-03-02 21:06:48.120081	21.06	34.29	39.98	t	t	t
6106	3	2026-03-02 21:06:58.114994	27.49	40.43	48.67	t	t	t
6143	4	2026-03-02 21:08:28.345307	35.74	43.41	59.13	t	t	t
6144	2	2026-03-02 21:08:38.204895	74.19	62.11	55.11	t	t	f
6150	5	2026-03-02 21:08:48.20685	56.00	34.84	46.16	t	t	t
6205	3	2026-03-02 21:11:08.351209	32.06	11.08	59.99	t	t	t
6208	4	2026-03-02 21:11:18.324646	52.53	26.73	30.13	t	t	f
6255	5	2026-03-02 21:13:08.454573	14.22	44.17	47.97	t	t	t
6256	2	2026-03-02 21:13:18.410331	28.72	54.21	28.21	t	t	t
6261	4	2026-03-02 21:13:28.416673	72.41	21.38	34.24	t	t	t
6301	3	2026-03-02 21:15:08.525504	46.86	55.98	37.91	t	t	f
6306	4	2026-03-02 21:15:18.510005	35.71	70.38	50.00	t	t	t
6310	3	2026-03-02 21:15:28.514732	43.91	68.16	28.01	t	t	t
6315	3	2026-03-02 21:15:38.508307	13.77	65.65	60.47	t	t	t
6317	3	2026-03-02 21:15:48.51754	41.74	69.51	25.84	t	t	t
6322	4	2026-03-02 21:15:58.515018	20.33	77.46	61.30	t	t	t
6350	4	2026-03-02 21:17:08.653286	31.56	75.97	60.00	t	t	t
6355	3	2026-03-02 21:17:18.591468	40.42	36.60	47.34	t	t	t
6356	2	2026-03-02 21:17:28.619546	29.01	79.51	34.03	t	t	t
6362	5	2026-03-02 21:17:38.604749	33.12	41.90	54.71	t	t	t
6366	3	2026-03-02 21:17:48.603645	19.61	65.03	44.32	t	t	t
6398	4	2026-03-02 21:19:08.704142	60.35	53.66	31.38	t	f	f
6402	3	2026-03-02 21:19:18.665371	44.27	38.83	67.10	t	t	t
6449	3	2026-03-02 21:21:18.768345	41.90	10.40	41.60	t	t	t
6454	4	2026-03-02 21:21:28.738713	14.73	69.76	26.85	t	f	t
6458	3	2026-03-02 21:21:38.740163	53.62	21.32	44.07	t	t	t
6462	3	2026-03-02 21:21:48.736998	43.14	74.55	23.16	t	t	t
6495	4	2026-03-02 21:23:08.826166	57.81	47.57	56.03	t	t	t
6496	2	2026-03-02 21:23:18.796249	38.32	29.19	62.32	t	t	t
6550	5	2026-03-02 21:25:28.926565	39.14	76.20	53.93	t	t	t
6555	4	2026-03-02 21:25:38.887845	37.72	50.96	48.26	t	t	t
6556	2	2026-03-02 21:25:48.896971	49.45	41.05	54.95	t	t	t
6578	4	2026-03-02 21:26:38.966173	41.20	25.18	24.21	t	t	t
6582	3	2026-03-02 21:26:48.932732	27.07	14.46	55.17	t	t	t
6627	4	2026-03-02 21:28:39.126699	55.68	56.65	58.44	t	t	t
6628	2	2026-03-02 21:28:49.058673	57.06	14.54	37.43	t	t	t
6635	5	2026-03-02 21:28:59.059794	77.72	65.42	67.61	t	t	t
6636	2	2026-03-02 21:29:09.078847	48.77	56.39	64.32	t	t	t
6641	5	2026-03-02 21:29:19.078385	28.78	22.11	48.10	t	t	t
6644	3	2026-03-02 21:29:29.077824	23.13	70.76	39.44	t	t	f
6674	5	2026-03-02 21:30:39.150787	32.46	59.83	66.97	t	t	t
6679	3	2026-03-02 21:30:49.120322	52.81	71.32	32.76	t	t	t
4398	3	2026-03-02 19:55:34.837541	77.32	43.65	32.67	t	t	t
4399	5	2026-03-02 19:55:34.951287	75.79	59.84	56.65	t	t	t
4400	2	2026-03-02 19:55:44.807587	19.68	11.67	54.14	t	t	t
4401	5	2026-03-02 19:55:44.807914	32.06	41.57	65.47	t	t	t
4402	3	2026-03-02 19:55:44.808083	65.30	36.01	21.36	t	t	t
4403	4	2026-03-02 19:55:44.808352	49.79	56.64	39.36	t	t	t
4404	2	2026-03-02 19:55:54.820395	55.79	34.16	52.34	t	t	t
4405	4	2026-03-02 19:55:54.852505	68.94	33.67	66.25	t	t	t
4406	3	2026-03-02 19:55:54.852846	20.49	52.47	65.31	t	t	t
4407	5	2026-03-02 19:55:54.855734	47.53	56.51	69.09	t	t	t
4408	4	2026-03-02 19:56:04.824373	72.83	37.03	63.59	t	t	t
4409	2	2026-03-02 19:56:04.825088	67.79	42.63	61.02	t	t	t
4410	3	2026-03-02 19:56:04.825391	13.18	23.07	31.77	t	t	t
4411	5	2026-03-02 19:56:04.825613	23.20	62.09	49.99	f	t	t
4412	2	2026-03-02 19:56:14.833951	32.31	30.25	41.35	t	t	t
4413	3	2026-03-02 19:56:14.866691	15.26	44.05	26.20	t	t	t
4414	4	2026-03-02 19:56:14.8708	57.54	63.50	34.46	t	t	t
4415	5	2026-03-02 19:56:14.871148	62.43	79.22	49.33	t	t	f
4416	3	2026-03-02 19:56:24.844009	69.11	73.71	27.77	t	t	t
4417	2	2026-03-02 19:56:24.844405	12.66	35.14	41.98	t	f	t
4418	4	2026-03-02 19:56:24.84437	79.36	69.46	62.49	t	t	t
4419	5	2026-03-02 19:56:24.874179	55.36	17.85	39.97	t	t	t
4420	2	2026-03-02 19:56:34.857715	71.44	26.19	64.55	t	t	t
4421	3	2026-03-02 19:56:34.89359	60.61	31.41	47.82	t	t	f
4422	4	2026-03-02 19:56:34.89456	61.64	33.31	30.96	t	f	t
4423	5	2026-03-02 19:56:34.897144	12.04	16.68	63.07	t	f	f
4425	2	2026-03-02 19:56:44.868647	64.51	63.16	21.47	t	t	t
4424	3	2026-03-02 19:56:44.868461	34.51	16.10	39.35	t	t	t
4426	4	2026-03-02 19:56:44.868838	44.11	30.71	24.28	t	t	t
4427	5	2026-03-02 19:56:44.899753	48.17	14.83	42.03	t	t	t
4428	3	2026-03-02 19:56:54.881755	54.31	49.31	29.66	t	t	t
4429	2	2026-03-02 19:56:54.914555	79.09	41.14	37.14	t	t	t
4430	4	2026-03-02 19:56:54.919365	14.11	19.69	50.87	t	t	t
4431	5	2026-03-02 19:56:54.920846	67.75	48.44	36.33	t	t	t
4432	2	2026-03-02 19:57:04.892404	53.50	57.60	39.36	t	t	f
4433	3	2026-03-02 19:57:04.89321	11.63	60.41	37.78	t	t	t
4434	5	2026-03-02 19:57:04.893411	69.73	15.53	24.76	t	t	t
4435	4	2026-03-02 19:57:05.034959	18.12	40.45	60.25	t	t	t
4436	2	2026-03-02 19:57:14.908632	31.32	78.35	52.37	t	t	f
4437	3	2026-03-02 19:57:14.94401	55.69	52.36	44.60	t	t	t
4438	4	2026-03-02 19:57:14.944267	47.78	38.70	48.46	t	t	t
4439	5	2026-03-02 19:57:14.946677	44.74	63.06	49.71	t	t	t
4440	3	2026-03-02 19:57:24.91565	45.85	76.57	22.93	t	t	t
4441	5	2026-03-02 19:57:24.915799	66.67	52.26	48.25	t	t	t
4442	4	2026-03-02 19:57:24.916111	15.96	55.55	46.33	t	t	t
4443	2	2026-03-02 19:57:24.916245	34.17	49.19	41.76	t	t	t
4444	3	2026-03-02 19:57:34.918127	68.29	72.99	29.40	t	t	t
4445	2	2026-03-02 19:57:34.918493	20.38	32.13	48.15	t	t	f
4446	5	2026-03-02 19:57:34.918621	66.06	25.91	61.53	t	t	t
4447	4	2026-03-02 19:57:34.919196	41.83	26.05	21.45	t	t	t
4448	2	2026-03-02 19:57:44.916884	69.06	66.79	43.89	t	t	t
4449	5	2026-03-02 19:57:44.917328	51.84	10.77	20.83	t	t	t
4450	3	2026-03-02 19:57:44.91758	33.26	53.41	55.76	t	t	t
4451	4	2026-03-02 19:57:44.917897	79.52	61.95	45.47	t	t	t
4452	2	2026-03-02 19:57:54.934192	45.78	56.29	47.08	t	t	t
4453	3	2026-03-02 19:57:54.968854	52.84	10.99	63.58	t	t	t
4454	4	2026-03-02 19:57:54.969419	74.96	17.95	23.94	t	t	t
4455	5	2026-03-02 19:57:55.093988	65.13	79.93	64.67	t	t	t
4456	4	2026-03-02 19:58:04.938804	21.40	47.53	30.35	t	t	t
4457	2	2026-03-02 19:58:04.939944	46.84	69.32	67.09	t	t	t
4458	3	2026-03-02 19:58:04.940103	24.97	68.94	42.81	t	t	t
4459	5	2026-03-02 19:58:04.940259	23.12	41.10	21.55	t	t	t
4460	3	2026-03-02 19:58:14.944011	24.32	75.08	31.37	t	t	t
4461	5	2026-03-02 19:58:14.944255	19.78	26.11	63.16	t	f	t
4462	4	2026-03-02 19:58:14.944508	18.90	12.82	54.23	f	t	t
4463	2	2026-03-02 19:58:14.944804	51.40	78.11	59.32	t	t	t
4464	2	2026-03-02 19:58:24.952902	30.66	28.06	43.52	t	t	t
4465	3	2026-03-02 19:58:24.983585	26.66	40.32	50.02	t	t	t
4466	4	2026-03-02 19:58:24.987761	26.53	60.20	66.00	t	t	t
4467	5	2026-03-02 19:58:24.990195	70.22	16.42	26.16	t	t	t
4468	2	2026-03-02 19:58:34.959123	50.08	48.01	45.44	t	t	t
4469	4	2026-03-02 19:58:34.959174	38.82	15.66	56.60	t	f	f
4470	3	2026-03-02 19:58:34.959337	26.62	18.99	54.87	t	t	t
4471	5	2026-03-02 19:58:34.988704	25.68	28.21	37.12	t	t	t
4472	2	2026-03-02 19:58:44.969567	51.19	58.76	39.84	t	t	t
4473	4	2026-03-02 19:58:44.999596	18.63	54.16	59.53	t	f	t
4474	3	2026-03-02 19:58:45.004662	14.24	57.77	50.45	t	t	t
4475	5	2026-03-02 19:58:45.006995	72.01	32.68	59.09	t	t	t
4476	2	2026-03-02 19:58:54.982777	58.92	45.01	38.85	t	t	t
4477	4	2026-03-02 19:58:54.98307	35.96	31.40	69.75	t	t	t
4478	3	2026-03-02 19:58:54.983282	55.57	21.20	41.51	t	t	t
4479	5	2026-03-02 19:58:55.013251	30.29	71.55	27.79	t	t	t
4480	2	2026-03-02 19:59:04.992245	17.68	71.23	29.61	t	t	t
4481	3	2026-03-02 19:59:05.024698	38.18	45.52	47.69	t	t	t
4482	4	2026-03-02 19:59:05.026652	54.89	44.99	33.79	t	t	t
4483	5	2026-03-02 19:59:05.027084	66.31	13.80	65.90	t	t	t
4484	2	2026-03-02 19:59:14.993448	23.82	37.17	64.50	t	f	t
4485	3	2026-03-02 19:59:14.993649	74.98	27.29	25.59	t	t	t
4486	5	2026-03-02 19:59:14.993814	70.69	18.93	44.70	f	t	t
4487	4	2026-03-02 19:59:14.994071	27.71	43.57	23.62	t	t	t
4488	2	2026-03-02 19:59:24.996887	49.01	12.20	62.37	t	f	t
4489	3	2026-03-02 19:59:24.99732	40.56	47.01	55.07	t	t	t
4491	5	2026-03-02 19:59:24.997973	45.52	42.76	47.32	t	t	t
4490	4	2026-03-02 19:59:24.99778	75.83	48.39	40.88	t	t	f
4492	2	2026-03-02 19:59:35.0016	51.92	38.65	64.55	t	t	t
4493	3	2026-03-02 19:59:35.001866	15.27	31.08	23.88	t	t	f
4494	5	2026-03-02 19:59:35.002013	53.53	64.78	50.87	t	t	f
4495	4	2026-03-02 19:59:35.002312	17.12	68.19	47.71	t	t	t
4496	4	2026-03-02 19:59:44.999707	52.80	77.83	36.40	t	t	t
4497	5	2026-03-02 19:59:44.999986	51.66	72.03	33.87	t	t	t
4498	3	2026-03-02 19:59:45.00013	57.98	46.52	68.82	t	t	f
4499	2	2026-03-02 19:59:45.000403	24.35	27.79	49.86	t	t	t
4500	2	2026-03-02 19:59:55.013587	48.91	23.29	39.64	t	t	f
4501	3	2026-03-02 19:59:55.047222	48.33	69.71	34.72	t	t	t
4502	5	2026-03-02 19:59:55.048672	76.53	59.09	59.95	t	f	f
4503	4	2026-03-02 19:59:55.048741	28.79	69.09	38.31	t	t	t
4504	3	2026-03-02 20:00:05.023741	23.25	48.50	61.59	t	t	t
4286	4	2026-03-02 19:50:54.597038	40.91	69.04	20.57	t	t	t
4288	3	2026-03-02 19:51:04.600656	72.55	52.12	25.25	t	t	t
4691	5	2026-03-02 20:07:45.474407	42.20	36.56	29.43	f	t	t
4692	2	2026-03-02 20:07:55.441443	54.35	73.26	27.15	t	t	t
4763	5	2026-03-02 20:10:45.626277	28.22	37.66	37.80	t	t	t
4764	2	2026-03-02 20:10:55.582159	77.69	58.40	50.83	t	t	t
4770	5	2026-03-02 20:11:05.587577	33.14	38.53	31.62	t	t	t
4846	4	2026-03-02 20:14:25.727923	24.26	58.47	60.58	t	f	t
4849	3	2026-03-02 20:14:35.700666	50.97	73.18	49.11	t	t	t
4911	5	2026-03-02 20:17:05.86702	58.97	63.60	67.17	t	t	t
4975	5	2026-03-02 20:19:45.996459	24.90	11.16	56.50	f	t	t
4976	2	2026-03-02 20:19:55.973796	68.92	66.08	41.18	t	t	f
5038	4	2026-03-02 20:22:26.139557	18.44	51.92	67.14	t	t	t
5041	3	2026-03-02 20:22:36.111763	23.56	32.76	60.28	t	t	t
5046	4	2026-03-02 20:22:46.113633	21.67	77.13	44.54	t	t	f
5123	5	2026-03-02 20:25:56.293895	52.71	30.81	53.74	t	t	t
5124	2	2026-03-02 20:26:06.264654	12.47	31.49	61.55	t	t	t
5131	5	2026-03-02 20:26:16.273101	13.20	71.88	65.31	t	t	t
5132	2	2026-03-02 20:26:26.272551	36.83	74.89	62.83	t	t	t
5137	5	2026-03-02 20:26:36.277639	34.81	23.81	52.26	t	t	t
5142	4	2026-03-02 20:26:46.271938	16.59	35.99	44.75	t	t	t
5215	5	2026-03-02 20:29:46.520853	68.98	15.62	49.75	t	t	t
5216	2	2026-03-02 20:29:56.392664	56.68	11.41	62.62	t	t	t
5221	4	2026-03-02 20:30:06.391642	22.59	17.50	46.13	t	t	t
5275	5	2026-03-02 20:32:16.510496	22.73	22.53	60.80	t	f	t
5276	2	2026-03-02 20:32:26.47322	71.31	29.68	66.02	t	f	t
5281	4	2026-03-02 20:32:36.474719	63.43	61.47	47.00	t	t	t
5286	3	2026-03-02 20:32:46.477682	52.14	78.86	45.31	t	t	t
5288	2	2026-03-02 20:32:56.472135	33.90	35.51	64.98	f	t	t
5353	3	2026-03-02 20:35:36.656305	31.83	78.80	68.99	f	t	t
5359	4	2026-03-02 20:35:46.627316	48.17	15.15	46.86	t	t	t
5360	2	2026-03-02 20:35:56.641567	10.44	62.40	40.71	t	t	t
5425	3	2026-03-02 20:38:36.816711	75.22	36.65	41.29	t	t	t
5430	4	2026-03-02 20:38:46.79651	41.79	68.67	27.95	t	t	t
5506	4	2026-03-02 20:41:56.979595	11.88	61.33	48.44	t	t	t
5559	4	2026-03-02 20:44:07.131821	50.66	67.36	44.81	t	t	t
5561	2	2026-03-02 20:44:17.097493	19.68	56.67	52.76	t	t	t
5609	5	2026-03-02 20:46:17.205156	30.53	75.80	39.96	t	t	f
5613	5	2026-03-02 20:46:27.208265	23.30	30.62	48.39	t	t	t
5619	4	2026-03-02 20:46:37.214055	64.42	52.77	26.50	t	t	t
5622	3	2026-03-02 20:46:47.211827	74.82	76.67	37.90	t	t	t
5686	4	2026-03-02 20:49:27.360426	26.80	13.35	64.24	t	t	t
5688	2	2026-03-02 20:49:37.326619	79.97	40.08	32.71	t	t	t
5747	5	2026-03-02 20:51:57.465764	15.90	42.64	26.33	t	f	f
5748	2	2026-03-02 20:52:07.443048	31.92	48.72	54.00	t	t	t
5794	5	2026-03-02 20:53:57.594578	36.55	30.17	36.79	t	t	f
5799	3	2026-03-02 20:54:07.561543	77.04	54.19	34.23	t	t	t
5803	3	2026-03-02 20:54:17.567713	27.46	54.06	43.25	t	t	t
5805	3	2026-03-02 20:54:27.571874	71.13	63.99	53.38	t	f	t
5809	5	2026-03-02 20:54:37.575334	20.85	44.38	38.31	t	t	f
5886	4	2026-03-02 20:57:47.729901	40.84	48.03	41.86	t	t	t
5888	2	2026-03-02 20:57:57.705643	36.23	30.90	45.18	t	t	t
5935	5	2026-03-02 20:59:47.844702	18.31	19.23	62.93	t	t	t
5936	2	2026-03-02 20:59:57.820831	44.79	31.19	38.19	t	t	t
6007	5	2026-03-02 21:02:47.949477	56.65	23.16	31.57	t	t	t
6008	2	2026-03-02 21:02:57.925722	70.70	45.84	64.39	f	t	t
6055	5	2026-03-02 21:04:48.052149	52.65	70.87	31.81	t	t	t
6057	2	2026-03-02 21:04:58.025119	42.21	70.19	66.36	t	t	t
6098	4	2026-03-02 21:06:38.152245	34.75	62.74	45.50	t	t	t
6101	3	2026-03-02 21:06:48.119736	40.55	13.30	68.11	t	t	t
6107	5	2026-03-02 21:06:58.115128	71.29	67.53	22.80	t	t	t
6108	2	2026-03-02 21:07:08.130481	68.08	18.20	39.93	f	t	t
6115	5	2026-03-02 21:07:18.133602	20.63	41.38	62.59	t	t	f
6116	2	2026-03-02 21:07:28.142088	46.77	73.37	51.95	f	t	t
6154	5	2026-03-02 21:08:58.245462	43.50	23.64	35.51	t	f	t
6157	3	2026-03-02 21:09:08.230516	73.26	64.26	39.11	t	t	t
6206	4	2026-03-02 21:11:08.358866	50.23	52.67	47.69	t	t	t
6209	3	2026-03-02 21:11:18.324501	74.02	57.76	28.36	t	t	t
6263	5	2026-03-02 21:13:28.557814	13.87	43.76	28.23	t	t	t
6264	2	2026-03-02 21:13:38.42688	34.17	51.16	43.38	t	t	t
6270	5	2026-03-02 21:13:48.432933	24.37	29.93	22.47	t	t	t
6273	4	2026-03-02 21:13:58.440238	25.05	60.79	21.47	t	t	f
6302	4	2026-03-02 21:15:08.529163	53.29	31.63	35.28	t	t	t
6305	3	2026-03-02 21:15:18.509838	79.81	61.83	56.35	t	t	t
6311	4	2026-03-02 21:15:28.51513	47.30	24.86	23.82	t	t	t
6312	2	2026-03-02 21:15:38.507511	15.25	34.36	38.57	t	t	t
6351	5	2026-03-02 21:17:08.655691	28.73	58.03	44.04	t	t	t
6352	2	2026-03-02 21:17:18.590931	33.23	50.60	49.86	t	t	t
6399	5	2026-03-02 21:19:08.704925	57.68	61.49	64.97	t	f	t
6400	2	2026-03-02 21:19:18.665229	34.95	38.41	28.06	t	t	t
6450	4	2026-03-02 21:21:18.771642	48.34	20.90	29.84	t	t	f
6453	3	2026-03-02 21:21:28.738183	46.72	43.91	58.89	t	t	t
6457	4	2026-03-02 21:21:38.739941	60.01	16.07	48.82	t	t	f
6461	4	2026-03-02 21:21:48.736604	73.75	23.95	24.10	t	t	t
6499	5	2026-03-02 21:23:18.827671	71.73	64.18	69.02	t	t	f
6500	2	2026-03-02 21:23:28.805794	16.08	47.33	33.59	t	f	f
6551	4	2026-03-02 21:25:28.926774	20.21	73.13	37.85	t	t	t
6552	2	2026-03-02 21:25:38.887097	30.96	71.10	55.28	f	t	t
6579	5	2026-03-02 21:26:38.967937	77.35	24.33	24.96	t	f	t
6580	2	2026-03-02 21:26:48.932246	22.39	44.94	51.59	t	t	t
6631	5	2026-03-02 21:28:49.091169	71.21	21.95	57.70	t	t	t
6632	2	2026-03-02 21:28:59.058873	59.44	69.74	28.58	t	t	t
6675	3	2026-03-02 21:30:39.258426	18.20	39.98	61.92	t	t	t
6676	2	2026-03-02 21:30:49.119235	77.01	72.92	52.65	t	f	t
6711	5	2026-03-02 21:32:09.217173	57.71	74.75	62.83	t	t	t
6712	3	2026-03-02 21:32:19.188591	16.52	13.76	21.16	t	t	t
6739	5	2026-03-02 21:33:19.417971	38.70	45.64	51.19	t	t	f
6740	2	2026-03-02 21:33:29.27623	19.41	46.68	61.80	t	t	t
6781	3	2026-03-02 21:35:09.38855	42.27	61.92	41.66	t	t	t
6786	4	2026-03-02 21:35:19.368629	15.64	46.08	63.83	t	t	t
6791	3	2026-03-02 21:35:29.374206	58.33	15.44	45.55	t	t	t
6792	2	2026-03-02 21:35:39.380981	68.69	38.58	52.85	t	t	t
6802	4	2026-03-02 21:35:59.429506	47.06	65.25	31.89	t	t	t
6811	4	2026-03-02 21:36:19.454663	51.62	11.37	26.36	t	t	t
6813	2	2026-03-02 21:36:29.418746	57.01	24.87	46.79	t	f	t
6819	3	2026-03-02 21:36:39.417633	56.37	66.42	21.22	t	t	t
6831	4	2026-03-02 21:37:09.605632	23.13	58.44	62.57	t	t	t
4287	5	2026-03-02 19:50:54.628447	13.27	17.16	21.59	t	f	t
4289	2	2026-03-02 19:51:04.600893	19.84	18.01	51.66	t	t	t
4293	3	2026-03-02 19:51:14.646676	40.95	43.58	68.56	t	t	t
4294	5	2026-03-02 19:51:14.651774	26.71	50.95	27.67	t	t	t
4295	4	2026-03-02 19:51:14.652098	54.96	16.70	48.67	t	t	t
4296	2	2026-03-02 19:51:24.628226	73.93	45.30	41.42	t	t	t
4297	3	2026-03-02 19:51:24.62877	74.08	74.79	59.88	t	t	t
4298	4	2026-03-02 19:51:24.628882	60.99	55.77	51.83	t	f	t
4299	5	2026-03-02 19:51:24.659404	70.32	20.17	58.80	t	t	t
4300	4	2026-03-02 19:51:34.645629	27.33	17.49	26.40	t	t	t
4301	3	2026-03-02 19:51:34.682071	64.10	74.18	63.30	t	t	t
4302	5	2026-03-02 19:51:34.683637	37.10	79.54	24.12	t	t	t
4303	2	2026-03-02 19:51:34.796603	78.13	10.74	46.07	t	t	t
4304	3	2026-03-02 19:51:44.653853	21.73	52.26	59.97	t	t	t
4305	2	2026-03-02 19:51:44.65411	26.70	23.88	30.57	t	t	f
4306	5	2026-03-02 19:51:44.654434	57.17	45.67	36.93	t	t	f
4307	4	2026-03-02 19:51:44.654509	20.20	23.08	51.07	t	f	t
4308	2	2026-03-02 19:51:54.665286	52.51	67.36	58.38	t	t	t
4309	3	2026-03-02 19:51:54.696534	59.16	62.02	50.22	t	t	t
4310	4	2026-03-02 19:51:54.698206	22.94	38.85	68.69	t	t	t
4311	5	2026-03-02 19:51:54.700733	28.41	45.99	33.93	t	t	t
4312	2	2026-03-02 19:52:04.668262	40.99	18.85	60.45	t	t	t
4313	5	2026-03-02 19:52:04.66853	30.42	47.62	66.20	t	t	t
4315	4	2026-03-02 19:52:04.668649	24.89	17.87	62.32	t	t	t
4314	3	2026-03-02 19:52:04.668629	27.81	24.99	22.02	t	t	t
4316	2	2026-03-02 19:52:14.670988	65.62	25.37	47.94	t	t	t
4317	5	2026-03-02 19:52:14.67107	62.21	56.78	43.88	t	t	t
4318	4	2026-03-02 19:52:14.671169	36.00	58.17	55.34	t	t	t
4319	3	2026-03-02 19:52:14.671293	15.58	69.86	49.27	t	f	t
4320	2	2026-03-02 19:52:24.679947	63.24	52.74	69.01	t	t	t
4321	3	2026-03-02 19:52:24.715158	63.89	50.19	63.89	t	t	t
4322	4	2026-03-02 19:52:24.715965	67.60	12.15	27.53	t	t	t
4323	5	2026-03-02 19:52:24.716659	40.17	44.51	39.65	t	t	t
4324	3	2026-03-02 19:52:34.685978	55.97	69.79	20.75	t	t	t
4325	5	2026-03-02 19:52:34.68616	18.71	45.57	37.20	t	t	f
4326	2	2026-03-02 19:52:34.686373	34.06	72.25	39.04	t	t	t
4327	4	2026-03-02 19:52:34.686508	77.61	76.56	41.96	t	t	t
4328	3	2026-03-02 19:52:44.683616	69.42	67.09	49.32	t	f	t
4329	5	2026-03-02 19:52:44.684125	29.99	10.39	49.52	t	t	f
4330	2	2026-03-02 19:52:44.684279	70.38	26.69	59.78	t	t	t
4331	4	2026-03-02 19:52:44.684491	12.67	68.21	39.27	t	t	t
4332	2	2026-03-02 19:52:54.693332	43.38	66.60	24.73	t	t	t
4333	5	2026-03-02 19:52:54.728464	12.75	21.46	24.90	t	t	t
4334	4	2026-03-02 19:52:54.728682	16.25	32.25	37.25	t	t	f
4335	3	2026-03-02 19:52:54.841616	19.57	72.37	60.19	t	t	f
4336	2	2026-03-02 19:53:04.697519	65.59	26.24	21.65	t	t	t
4337	5	2026-03-02 19:53:04.697674	37.71	55.98	50.55	t	t	t
4338	3	2026-03-02 19:53:04.697982	52.91	43.19	27.86	t	t	t
4339	4	2026-03-02 19:53:04.698102	34.12	18.86	53.09	t	t	t
4340	2	2026-03-02 19:53:14.709287	54.28	32.32	40.29	t	t	t
4341	3	2026-03-02 19:53:14.744293	43.76	76.56	37.52	t	t	f
4342	4	2026-03-02 19:53:14.74457	70.55	47.12	52.18	t	t	f
4343	5	2026-03-02 19:53:14.74592	47.33	64.61	38.75	t	t	t
4344	2	2026-03-02 19:53:24.717144	69.95	65.23	53.77	t	t	t
4345	4	2026-03-02 19:53:24.717681	46.93	63.82	36.14	t	t	t
4346	3	2026-03-02 19:53:24.717844	53.71	15.93	59.15	t	f	t
4347	5	2026-03-02 19:53:24.860439	37.84	46.28	64.18	t	t	t
4348	2	2026-03-02 19:53:34.720433	75.14	23.13	23.75	t	t	t
4349	5	2026-03-02 19:53:34.720611	35.50	71.32	28.53	t	t	t
4350	3	2026-03-02 19:53:34.720815	73.54	66.11	34.15	t	t	t
4351	4	2026-03-02 19:53:34.720955	76.72	23.82	43.66	t	t	f
4352	4	2026-03-02 19:53:44.721454	17.87	22.76	46.14	t	t	t
4353	5	2026-03-02 19:53:44.721801	30.34	59.01	25.34	t	t	t
4354	3	2026-03-02 19:53:44.722007	56.99	62.47	22.58	t	t	t
4355	2	2026-03-02 19:53:44.722321	66.56	69.62	30.37	t	t	t
4356	3	2026-03-02 19:53:54.726384	75.94	25.49	37.27	t	t	t
4357	2	2026-03-02 19:53:54.726608	31.03	70.59	37.90	t	f	t
4358	5	2026-03-02 19:53:54.726751	63.82	33.66	50.77	t	t	t
4359	4	2026-03-02 19:53:54.72704	38.12	43.70	42.76	t	t	t
4360	3	2026-03-02 19:54:04.727327	38.17	22.88	64.27	t	t	t
4361	5	2026-03-02 19:54:04.727488	36.50	75.75	35.25	t	t	t
4362	2	2026-03-02 19:54:04.727627	16.43	57.62	38.38	t	t	t
4363	4	2026-03-02 19:54:04.727907	12.93	35.01	29.85	t	t	f
4364	2	2026-03-02 19:54:14.739386	66.06	70.41	51.85	t	t	f
4365	4	2026-03-02 19:54:14.772548	74.63	73.24	26.35	t	t	t
4366	5	2026-03-02 19:54:14.77296	61.92	16.15	68.63	t	t	t
4367	3	2026-03-02 19:54:14.887574	22.98	61.66	62.35	f	t	t
4368	3	2026-03-02 19:54:24.751135	77.15	74.94	59.93	t	t	t
4369	2	2026-03-02 19:54:24.751326	46.41	15.71	32.83	t	t	t
4370	4	2026-03-02 19:54:24.751704	22.77	78.81	38.29	t	t	f
4371	5	2026-03-02 19:54:24.783763	73.91	69.90	36.10	t	t	t
4372	2	2026-03-02 19:54:34.763884	29.96	35.51	52.00	t	t	f
4373	3	2026-03-02 19:54:34.796283	45.35	45.39	24.22	t	t	f
4374	4	2026-03-02 19:54:34.796844	13.06	72.52	25.63	t	t	f
4375	5	2026-03-02 19:54:34.799332	67.68	23.12	69.44	t	t	t
4376	3	2026-03-02 19:54:44.76438	41.22	72.42	58.88	f	t	t
4377	5	2026-03-02 19:54:44.764619	26.62	77.12	66.09	t	t	t
4378	4	2026-03-02 19:54:44.764769	19.01	54.67	37.09	t	t	t
4379	2	2026-03-02 19:54:44.765065	46.67	43.83	40.14	t	t	t
4380	3	2026-03-02 19:54:54.766621	20.13	12.14	66.66	t	t	t
4381	5	2026-03-02 19:54:54.766894	41.43	63.94	26.41	t	t	t
4382	4	2026-03-02 19:54:54.767044	23.84	60.30	68.08	t	t	t
4383	2	2026-03-02 19:54:54.767317	26.29	79.36	36.43	t	t	t
4384	2	2026-03-02 19:55:04.773429	30.54	76.12	32.25	t	t	f
4385	3	2026-03-02 19:55:04.804132	47.28	46.48	69.62	t	t	t
4386	4	2026-03-02 19:55:04.806768	69.01	22.24	28.79	t	t	t
4387	5	2026-03-02 19:55:04.807892	41.73	22.80	69.81	t	t	t
4388	3	2026-03-02 19:55:14.78744	42.23	79.77	45.29	t	t	t
4389	2	2026-03-02 19:55:14.787676	66.62	11.28	62.24	t	t	t
4390	4	2026-03-02 19:55:14.787903	15.34	22.70	58.19	t	t	t
4391	5	2026-03-02 19:55:14.814354	36.31	67.41	31.79	t	t	t
4392	2	2026-03-02 19:55:24.791543	16.38	63.60	49.84	t	t	t
4393	5	2026-03-02 19:55:24.791912	29.49	15.41	57.53	t	t	t
4394	3	2026-03-02 19:55:24.792045	10.65	69.57	56.23	t	t	t
4395	4	2026-03-02 19:55:24.792334	43.27	76.72	36.72	t	t	t
4396	2	2026-03-02 19:55:34.803573	58.94	41.07	36.57	t	t	t
4397	4	2026-03-02 19:55:34.835659	56.26	78.56	35.87	t	t	t
4505	2	2026-03-02 20:00:05.024362	41.49	64.88	36.52	t	f	t
4506	4	2026-03-02 20:00:05.05248	65.92	56.52	30.28	t	t	t
4507	5	2026-03-02 20:00:05.055174	36.78	76.81	34.99	t	t	t
4508	2	2026-03-02 20:00:15.041509	10.22	33.28	42.38	t	t	t
4509	3	2026-03-02 20:00:15.042025	36.56	38.61	31.70	t	t	t
4510	4	2026-03-02 20:00:15.07084	25.54	29.08	44.17	t	t	t
4511	5	2026-03-02 20:00:15.187348	67.75	64.33	29.17	t	f	t
4512	2	2026-03-02 20:00:25.041761	47.37	39.26	58.45	t	t	f
4513	3	2026-03-02 20:00:25.042	35.94	29.21	28.76	t	t	t
4514	5	2026-03-02 20:00:25.042159	41.23	53.44	61.37	t	t	t
4515	4	2026-03-02 20:00:25.042472	79.66	72.90	46.77	t	f	t
4516	2	2026-03-02 20:00:35.048751	53.70	13.53	46.72	t	t	f
4517	3	2026-03-02 20:00:35.048987	57.99	70.75	53.58	t	t	f
4518	5	2026-03-02 20:00:35.049125	57.23	75.65	53.93	t	t	t
4519	4	2026-03-02 20:00:35.049417	59.64	64.08	45.41	t	t	t
4520	2	2026-03-02 20:00:45.061758	66.46	61.64	41.92	t	t	f
4521	3	2026-03-02 20:00:45.094683	64.39	18.38	46.24	t	f	t
4522	4	2026-03-02 20:00:45.095008	19.06	26.21	51.87	t	t	t
4523	5	2026-03-02 20:00:45.097321	25.02	18.76	44.71	t	t	t
4524	2	2026-03-02 20:00:55.074618	15.43	18.32	45.10	t	t	t
4525	4	2026-03-02 20:00:55.074834	66.12	55.73	43.45	t	t	t
4526	3	2026-03-02 20:00:55.075084	66.03	46.47	58.28	t	t	t
4527	5	2026-03-02 20:00:55.104493	55.40	41.33	22.32	t	t	t
4528	3	2026-03-02 20:01:05.079594	59.78	48.11	23.96	t	t	t
4529	5	2026-03-02 20:01:05.079949	73.12	49.12	22.62	t	t	t
4531	2	2026-03-02 20:01:05.080083	73.46	66.84	49.15	t	t	f
4530	4	2026-03-02 20:01:05.080083	46.13	55.35	38.32	t	t	t
4532	4	2026-03-02 20:01:15.079435	76.11	21.24	46.84	t	t	t
4533	5	2026-03-02 20:01:15.079781	51.39	70.92	51.64	t	t	t
4534	2	2026-03-02 20:01:15.079958	20.91	14.15	38.60	t	t	t
4535	3	2026-03-02 20:01:15.080238	28.50	11.54	35.79	t	t	f
4536	2	2026-03-02 20:01:25.081116	59.35	45.73	62.67	t	f	t
4537	4	2026-03-02 20:01:25.081775	30.77	62.54	20.14	t	t	f
4538	3	2026-03-02 20:01:25.082034	52.64	48.59	67.44	t	t	f
4539	5	2026-03-02 20:01:25.082502	30.89	33.52	40.08	t	t	t
4540	2	2026-03-02 20:01:35.09312	23.54	13.25	33.76	t	t	t
4541	3	2026-03-02 20:01:35.125602	14.74	58.29	59.18	t	t	t
4542	4	2026-03-02 20:01:35.129702	45.03	27.34	38.19	t	t	t
4543	5	2026-03-02 20:01:35.130343	47.32	45.90	58.13	t	t	t
4544	3	2026-03-02 20:01:45.107261	13.06	14.73	30.02	t	t	t
4545	2	2026-03-02 20:01:45.107454	13.60	67.07	26.13	t	t	t
4546	4	2026-03-02 20:01:45.107635	21.05	51.21	32.72	t	f	t
4547	5	2026-03-02 20:01:45.139633	50.70	41.73	67.46	t	t	t
4548	3	2026-03-02 20:01:55.120374	51.25	46.59	41.23	t	t	t
4549	2	2026-03-02 20:01:55.150411	64.58	56.95	67.37	t	f	t
4550	5	2026-03-02 20:01:55.153609	53.66	21.57	29.94	t	t	f
4551	4	2026-03-02 20:01:55.268589	11.58	48.70	34.12	t	t	t
4552	2	2026-03-02 20:02:05.130423	58.61	67.36	43.57	t	t	t
4553	4	2026-03-02 20:02:05.131316	69.97	29.19	56.95	t	t	t
4554	3	2026-03-02 20:02:05.131408	71.13	24.31	49.00	t	t	t
4555	5	2026-03-02 20:02:05.160815	79.55	13.00	68.94	t	t	t
4556	2	2026-03-02 20:02:15.141917	54.98	11.15	27.11	t	t	f
4557	4	2026-03-02 20:02:15.175552	21.45	49.02	52.92	t	t	t
4558	5	2026-03-02 20:02:15.176269	52.89	52.58	45.07	t	t	f
4559	3	2026-03-02 20:02:15.290343	68.90	67.05	38.45	t	t	f
4560	2	2026-03-02 20:02:25.153064	55.94	79.66	41.82	t	t	f
4561	4	2026-03-02 20:02:25.15338	54.30	64.50	65.32	t	t	t
4562	3	2026-03-02 20:02:25.153676	70.32	28.27	21.16	t	t	t
4563	5	2026-03-02 20:02:25.186039	44.81	47.05	49.95	t	t	t
4564	2	2026-03-02 20:02:35.163271	60.50	28.49	31.31	t	t	f
4565	4	2026-03-02 20:02:35.194063	55.05	46.38	46.49	t	t	f
4566	5	2026-03-02 20:02:35.198339	56.93	51.24	65.94	t	t	t
4567	3	2026-03-02 20:02:35.305709	24.40	44.62	65.16	t	t	t
4568	2	2026-03-02 20:02:45.175289	13.61	72.17	38.10	t	t	t
4569	4	2026-03-02 20:02:45.176139	18.49	49.53	67.76	t	f	t
4570	3	2026-03-02 20:02:45.176411	36.62	70.37	37.53	t	t	t
4571	5	2026-03-02 20:02:45.206285	74.78	36.43	47.02	t	t	f
4572	2	2026-03-02 20:02:55.1879	64.66	11.94	62.93	t	t	t
4573	3	2026-03-02 20:02:55.219112	33.68	77.99	34.54	t	t	t
4574	4	2026-03-02 20:02:55.221549	39.15	33.43	68.65	f	t	f
4575	5	2026-03-02 20:02:55.223553	26.15	62.47	54.87	t	t	f
4576	2	2026-03-02 20:03:05.194798	36.49	63.99	31.88	t	t	t
4577	3	2026-03-02 20:03:05.194896	37.39	78.60	40.48	t	f	t
4578	4	2026-03-02 20:03:05.195262	13.11	38.22	50.44	t	t	t
4579	5	2026-03-02 20:03:05.2254	29.00	21.90	45.48	t	t	f
4580	2	2026-03-02 20:03:15.202301	47.90	47.54	38.26	t	t	t
4581	4	2026-03-02 20:03:15.202639	70.93	52.51	61.64	t	t	t
4582	3	2026-03-02 20:03:15.202817	40.71	48.84	64.02	t	f	t
4583	5	2026-03-02 20:03:15.233897	16.19	19.22	62.75	t	t	t
4584	3	2026-03-02 20:03:25.202566	50.58	43.79	40.92	t	t	t
4585	2	2026-03-02 20:03:25.20314	74.45	26.28	44.91	t	t	f
4586	5	2026-03-02 20:03:25.203268	15.92	12.72	53.16	t	t	t
4587	4	2026-03-02 20:03:25.203554	53.91	76.18	27.32	t	t	t
4588	2	2026-03-02 20:03:35.214578	66.25	10.57	25.94	t	t	t
4589	3	2026-03-02 20:03:35.24796	31.76	27.90	25.25	f	t	f
4590	4	2026-03-02 20:03:35.249126	61.95	46.16	69.69	t	t	f
4591	5	2026-03-02 20:03:35.252129	61.67	74.79	51.62	t	t	t
4592	2	2026-03-02 20:03:45.224695	62.80	33.56	69.45	t	t	t
4593	4	2026-03-02 20:03:45.225019	67.34	13.77	55.46	t	t	t
4594	3	2026-03-02 20:03:45.225207	69.62	77.03	20.29	t	t	t
4595	5	2026-03-02 20:03:45.254913	20.38	43.94	69.77	t	t	t
4596	2	2026-03-02 20:03:55.227987	17.63	75.31	49.58	t	t	f
4597	3	2026-03-02 20:03:55.228232	38.38	43.37	33.55	t	t	t
4598	5	2026-03-02 20:03:55.228383	10.38	67.49	32.74	t	t	t
4599	4	2026-03-02 20:03:55.228692	27.95	62.88	33.98	t	t	t
4600	2	2026-03-02 20:04:05.235717	41.33	54.48	29.36	t	t	f
4601	5	2026-03-02 20:04:05.235885	10.22	58.73	44.34	t	f	t
4602	4	2026-03-02 20:04:05.23619	28.88	49.64	64.72	t	t	t
4603	3	2026-03-02 20:04:05.236448	73.93	63.56	54.10	t	t	t
4604	3	2026-03-02 20:04:15.239371	40.53	77.54	39.68	t	t	f
4605	5	2026-03-02 20:04:15.239543	50.38	59.56	42.72	f	t	f
4606	2	2026-03-02 20:04:15.239768	64.69	35.80	47.94	t	t	t
4607	4	2026-03-02 20:04:15.239961	44.49	20.87	51.54	t	t	t
4608	3	2026-03-02 20:04:25.23929	35.94	62.30	21.71	t	t	t
4609	4	2026-03-02 20:04:25.239474	30.11	60.27	38.55	t	t	t
4610	5	2026-03-02 20:04:25.239639	47.24	66.63	63.60	t	t	f
4611	2	2026-03-02 20:04:25.239935	44.09	14.33	50.61	t	t	t
4612	3	2026-03-02 20:04:35.247018	70.35	27.21	57.91	t	t	t
4695	5	2026-03-02 20:07:55.471429	39.35	35.01	35.22	t	t	t
4696	2	2026-03-02 20:08:05.457853	24.76	60.98	34.74	t	t	t
4773	3	2026-03-02 20:11:15.664969	57.40	48.95	27.91	t	t	t
4779	4	2026-03-02 20:11:25.605251	11.67	10.14	38.04	t	t	t
4847	5	2026-03-02 20:14:25.731367	38.94	69.43	54.32	t	t	t
4848	2	2026-03-02 20:14:35.700584	64.37	63.58	54.15	t	t	f
4912	2	2026-03-02 20:17:15.851791	31.25	41.73	65.26	t	t	t
4978	5	2026-03-02 20:19:56.005848	58.40	36.95	28.14	t	t	t
4981	4	2026-03-02 20:20:05.988054	73.27	43.37	23.92	t	t	f
4985	4	2026-03-02 20:20:15.98969	45.56	25.79	30.27	t	t	t
5039	5	2026-03-02 20:22:26.139795	75.55	72.50	69.94	t	t	t
5040	2	2026-03-02 20:22:36.111693	74.40	56.81	53.00	t	t	t
5047	5	2026-03-02 20:22:46.114078	74.08	23.92	20.18	t	t	t
5048	2	2026-03-02 20:22:56.129543	63.86	21.32	41.88	t	t	t
5145	3	2026-03-02 20:26:56.314482	74.42	66.63	33.51	t	t	t
5151	4	2026-03-02 20:27:06.279492	65.76	17.11	28.44	t	t	t
5217	3	2026-03-02 20:29:56.42717	35.61	55.08	43.31	t	t	t
5220	3	2026-03-02 20:30:06.391382	67.25	28.76	52.31	t	t	t
5225	3	2026-03-02 20:30:16.390501	40.48	62.29	29.40	t	t	f
5283	5	2026-03-02 20:32:36.506092	13.47	43.69	66.09	t	t	t
5284	2	2026-03-02 20:32:46.476918	34.04	50.58	31.05	t	t	t
5291	5	2026-03-02 20:32:56.473518	54.16	66.05	42.24	t	t	f
5292	2	2026-03-02 20:33:06.477724	55.48	43.32	58.69	t	t	t
5354	4	2026-03-02 20:35:36.658636	23.36	31.10	44.35	t	t	t
5358	3	2026-03-02 20:35:46.627195	78.62	59.32	50.55	t	t	t
5426	5	2026-03-02 20:38:36.821011	49.70	30.12	65.38	t	f	t
5429	3	2026-03-02 20:38:46.796604	12.63	69.52	48.47	t	f	f
5507	5	2026-03-02 20:41:56.980343	69.51	67.67	43.82	t	t	f
5563	5	2026-03-02 20:44:17.126096	56.57	27.48	56.28	t	t	t
5564	2	2026-03-02 20:44:27.112382	68.52	64.18	66.69	t	t	f
5610	4	2026-03-02 20:46:17.205275	64.80	22.78	34.67	t	t	t
5612	3	2026-03-02 20:46:27.208068	56.61	76.63	46.38	t	t	t
5617	5	2026-03-02 20:46:37.2135	40.31	55.31	52.73	t	t	t
5621	4	2026-03-02 20:46:47.211611	77.79	66.71	28.52	t	t	t
5624	4	2026-03-02 20:46:57.226476	45.53	43.52	69.87	t	t	t
5629	5	2026-03-02 20:47:07.225892	75.24	66.65	65.55	t	t	t
5687	5	2026-03-02 20:49:27.362719	76.91	21.82	20.01	t	t	f
5689	3	2026-03-02 20:49:37.326959	48.77	51.80	68.42	t	t	t
5750	5	2026-03-02 20:52:07.478789	48.70	49.76	57.72	t	t	t
5753	3	2026-03-02 20:52:17.46318	10.62	27.26	45.80	t	t	t
5759	4	2026-03-02 20:52:27.463505	71.04	41.89	61.33	f	t	t
5760	2	2026-03-02 20:52:37.480029	41.10	14.12	45.44	t	t	t
5767	5	2026-03-02 20:52:47.480617	68.38	50.30	50.49	t	t	t
5795	4	2026-03-02 20:53:57.711485	79.35	55.83	49.88	t	t	f
5796	2	2026-03-02 20:54:07.560793	79.77	33.27	21.51	t	f	t
5801	5	2026-03-02 20:54:17.567396	61.61	44.77	69.68	t	f	t
5806	4	2026-03-02 20:54:27.57202	79.87	71.13	55.24	t	t	t
5811	3	2026-03-02 20:54:37.575447	23.18	27.58	51.85	t	t	f
5813	3	2026-03-02 20:54:47.590519	35.99	18.70	36.66	t	t	t
5814	5	2026-03-02 20:54:47.59461	13.39	29.21	38.77	t	t	t
5887	5	2026-03-02 20:57:47.731743	59.73	74.29	52.16	t	t	t
5889	3	2026-03-02 20:57:57.706289	57.79	77.05	46.54	t	f	t
5937	3	2026-03-02 20:59:57.865258	48.89	77.31	36.28	t	t	t
5940	3	2026-03-02 21:00:07.827321	15.41	43.67	24.01	t	f	t
6009	5	2026-03-02 21:02:57.965087	47.32	53.46	24.87	t	t	t
6058	4	2026-03-02 21:04:58.058804	46.27	76.16	31.04	t	f	t
6060	2	2026-03-02 21:05:08.039346	39.48	69.31	45.13	t	t	t
6099	5	2026-03-02 21:06:38.153768	32.33	38.69	68.81	t	t	f
6100	2	2026-03-02 21:06:48.119402	60.68	63.32	51.48	t	t	t
6105	4	2026-03-02 21:06:58.114915	52.24	60.58	62.16	t	t	f
6155	4	2026-03-02 21:08:58.350936	12.02	19.25	67.88	t	t	f
6156	2	2026-03-02 21:09:08.230124	20.40	69.36	67.17	t	t	f
6207	5	2026-03-02 21:11:08.359471	55.60	59.15	45.96	t	t	t
6210	2	2026-03-02 21:11:18.325287	39.41	67.36	34.53	t	t	t
6265	3	2026-03-02 21:13:38.47505	55.52	41.65	52.05	t	t	t
6268	4	2026-03-02 21:13:48.432391	35.67	53.79	29.13	t	t	t
6303	5	2026-03-02 21:15:08.530051	65.30	38.52	38.67	t	t	t
6304	2	2026-03-02 21:15:18.509498	68.27	72.63	57.60	t	t	t
6309	5	2026-03-02 21:15:28.514335	47.30	30.82	39.25	t	t	t
6313	4	2026-03-02 21:15:38.507698	33.93	29.84	49.40	t	t	t
6357	3	2026-03-02 21:17:28.672007	64.88	64.06	38.49	t	t	t
6363	4	2026-03-02 21:17:38.604966	33.01	63.40	66.09	t	t	t
6364	2	2026-03-02 21:17:48.603335	60.35	28.12	31.18	t	t	t
6405	3	2026-03-02 21:19:28.720907	59.61	76.57	65.07	t	t	f
6411	4	2026-03-02 21:19:38.671227	56.55	53.54	49.91	t	t	t
6412	2	2026-03-02 21:19:48.681819	28.44	44.03	45.12	t	t	t
6451	5	2026-03-02 21:21:18.772552	19.88	14.28	64.45	t	t	t
6452	2	2026-03-02 21:21:28.737878	22.20	24.65	36.69	f	t	t
6459	5	2026-03-02 21:21:38.740502	39.45	45.94	64.38	t	t	t
6460	2	2026-03-02 21:21:48.736234	13.10	73.99	57.53	t	f	t
6501	3	2026-03-02 21:23:28.837539	59.44	53.21	69.97	t	t	t
6506	4	2026-03-02 21:23:38.815123	23.62	48.35	40.79	t	t	f
6511	3	2026-03-02 21:23:48.816959	34.71	56.48	61.82	t	t	t
6512	2	2026-03-02 21:23:58.821868	25.11	25.92	66.01	t	t	t
6519	5	2026-03-02 21:24:08.829344	66.38	75.21	21.31	t	t	t
6520	2	2026-03-02 21:24:18.830033	11.71	42.11	28.47	t	t	t
6557	3	2026-03-02 21:25:48.932342	57.87	69.00	26.66	t	t	t
6585	3	2026-03-02 21:26:59.011575	51.30	39.95	44.64	t	f	t
6590	5	2026-03-02 21:27:08.975818	47.11	75.32	60.80	t	t	t
6593	4	2026-03-02 21:27:18.979837	34.25	23.17	54.19	t	t	f
6598	4	2026-03-02 21:27:28.985658	73.43	46.56	58.60	t	t	t
6637	3	2026-03-02 21:29:09.116099	48.50	44.08	62.13	t	t	t
6642	4	2026-03-02 21:29:19.078502	15.01	72.18	68.07	f	t	t
6646	4	2026-03-02 21:29:29.078004	25.40	73.95	30.34	t	t	f
6680	2	2026-03-02 21:30:59.130208	71.79	56.82	23.18	t	t	t
6685	5	2026-03-02 21:31:09.137419	55.73	38.52	33.21	t	f	t
6715	5	2026-03-02 21:32:19.218554	65.97	38.87	42.76	t	t	t
6745	5	2026-03-02 21:33:39.323812	36.79	41.35	48.32	t	t	t
6749	4	2026-03-02 21:33:49.304839	47.07	20.92	37.99	t	t	t
6754	4	2026-03-02 21:33:59.310663	34.77	15.46	64.35	t	t	t
6756	2	2026-03-02 21:34:09.323221	68.01	24.36	33.12	t	t	t
6761	5	2026-03-02 21:34:19.323205	29.17	13.94	56.85	t	t	f
6782	4	2026-03-02 21:35:09.390625	49.24	41.84	21.77	t	t	t
6785	2	2026-03-02 21:35:19.368366	75.36	49.01	44.54	f	t	t
6790	4	2026-03-02 21:35:29.373889	22.56	28.94	22.07	t	f	t
6803	5	2026-03-02 21:35:59.431179	23.98	69.65	46.71	t	t	f
4613	4	2026-03-02 20:04:35.247423	39.54	71.85	22.56	t	t	f
4697	3	2026-03-02 20:08:05.490359	73.43	54.05	33.63	t	t	t
4702	4	2026-03-02 20:08:15.468966	73.97	51.29	48.02	t	t	t
4774	5	2026-03-02 20:11:15.667938	79.73	70.72	65.85	t	t	t
4777	3	2026-03-02 20:11:25.604732	10.47	79.41	21.53	t	t	t
4851	5	2026-03-02 20:14:35.731075	75.75	67.74	67.12	t	t	t
4852	3	2026-03-02 20:14:45.715892	40.29	40.65	20.71	t	t	t
4913	3	2026-03-02 20:17:15.887658	41.27	54.99	58.72	t	t	t
4917	4	2026-03-02 20:17:25.86155	51.23	78.97	53.88	t	t	t
4979	4	2026-03-02 20:19:56.115952	64.48	35.89	46.59	t	t	f
4980	3	2026-03-02 20:20:05.987316	43.07	70.09	33.15	t	f	t
4987	5	2026-03-02 20:20:15.990273	76.10	67.63	53.84	t	f	t
4988	2	2026-03-02 20:20:25.995872	28.43	24.45	44.37	t	t	t
5043	5	2026-03-02 20:22:36.141527	58.86	38.92	61.52	t	t	t
5044	2	2026-03-02 20:22:46.11303	12.41	31.06	33.81	t	t	t
5146	4	2026-03-02 20:26:56.314755	25.56	48.80	58.43	t	t	t
5150	3	2026-03-02 20:27:06.279388	40.07	59.68	50.33	t	t	f
5152	2	2026-03-02 20:27:16.294007	22.73	34.59	48.62	t	t	t
5159	5	2026-03-02 20:27:26.294682	49.71	59.32	69.41	t	t	t
5161	2	2026-03-02 20:27:36.296155	68.85	30.97	59.23	t	f	t
5166	3	2026-03-02 20:27:46.300874	68.19	79.96	52.11	t	t	t
5218	4	2026-03-02 20:29:56.428078	36.32	22.15	68.95	t	t	t
5293	3	2026-03-02 20:33:06.509581	43.99	20.42	21.28	t	t	t
5297	4	2026-03-02 20:33:16.491782	26.68	77.41	58.70	t	t	t
5355	5	2026-03-02 20:35:36.659736	47.54	72.24	41.83	t	t	t
5356	2	2026-03-02 20:35:46.626631	15.76	30.05	26.86	f	t	t
5427	4	2026-03-02 20:38:36.93501	19.09	50.12	53.92	t	t	t
5428	2	2026-03-02 20:38:46.796386	12.16	53.12	29.66	t	t	t
5508	2	2026-03-02 20:42:06.978122	15.83	50.51	60.22	t	t	t
5512	2	2026-03-02 20:42:16.992141	17.10	19.94	44.00	t	t	t
5519	4	2026-03-02 20:42:26.996401	30.16	71.94	36.63	t	t	t
5520	2	2026-03-02 20:42:37.007151	33.38	69.58	35.28	t	t	t
5565	5	2026-03-02 20:44:27.147453	71.26	67.70	61.06	f	f	t
5569	4	2026-03-02 20:44:37.122007	79.80	58.97	37.78	t	t	t
5574	4	2026-03-02 20:44:47.124565	56.70	26.57	64.50	t	t	t
5611	2	2026-03-02 20:46:17.205375	64.39	79.45	27.56	t	f	t
5614	2	2026-03-02 20:46:27.208618	56.58	16.01	42.71	t	t	t
5618	3	2026-03-02 20:46:37.213853	79.85	76.99	49.32	t	t	f
5620	2	2026-03-02 20:46:47.211471	78.96	12.11	51.64	f	t	f
5691	5	2026-03-02 20:49:37.357249	63.60	69.42	41.44	t	t	t
5692	2	2026-03-02 20:49:47.334683	59.49	75.83	40.65	t	t	t
5697	5	2026-03-02 20:49:57.33751	67.96	14.29	29.65	t	t	f
5702	4	2026-03-02 20:50:07.338612	57.05	42.94	39.83	t	t	t
5704	2	2026-03-02 20:50:17.355271	67.04	55.16	27.05	t	t	t
5709	5	2026-03-02 20:50:27.355751	55.88	57.59	34.26	t	t	t
5751	4	2026-03-02 20:52:07.587314	24.49	56.00	65.19	t	t	t
5752	2	2026-03-02 20:52:17.462711	72.73	50.25	26.13	t	t	t
5757	5	2026-03-02 20:52:27.463214	13.54	18.23	53.36	t	t	t
5815	4	2026-03-02 20:54:47.639624	23.19	10.37	49.00	t	t	f
5816	2	2026-03-02 20:54:57.605518	10.81	68.31	43.28	t	t	f
5890	4	2026-03-02 20:57:57.738555	68.76	55.71	28.89	t	t	t
5892	3	2026-03-02 20:58:07.72809	12.54	31.55	42.00	t	f	t
5898	5	2026-03-02 20:58:17.726894	14.03	49.19	52.86	t	t	t
5938	4	2026-03-02 20:59:57.87316	28.26	64.84	47.47	t	t	t
6010	4	2026-03-02 21:02:57.965243	40.45	56.49	62.49	t	t	t
6059	5	2026-03-02 21:04:58.060084	25.03	50.18	62.02	t	t	t
6103	5	2026-03-02 21:06:48.150951	34.39	72.66	47.90	f	f	t
6104	2	2026-03-02 21:06:58.114825	54.19	10.97	56.45	t	t	f
6158	4	2026-03-02 21:09:08.262905	56.84	25.53	66.68	t	t	t
6161	3	2026-03-02 21:09:18.243232	48.23	36.00	28.53	t	t	f
6167	4	2026-03-02 21:09:28.2438	48.70	54.71	61.17	f	t	f
6211	5	2026-03-02 21:11:18.355289	67.43	23.27	43.61	t	t	t
6212	2	2026-03-02 21:11:28.333961	62.95	38.54	24.19	t	t	t
6266	5	2026-03-02 21:13:38.478863	53.79	40.96	58.98	t	t	t
6271	3	2026-03-02 21:13:48.43299	45.08	37.78	44.80	t	f	t
6272	2	2026-03-02 21:13:58.440169	79.21	53.72	33.87	t	t	t
6307	5	2026-03-02 21:15:18.541775	16.00	16.21	21.80	f	t	f
6308	2	2026-03-02 21:15:28.51412	52.64	62.84	64.93	t	f	t
6314	5	2026-03-02 21:15:38.507919	46.83	11.21	59.03	t	t	f
6316	2	2026-03-02 21:15:48.517291	21.71	56.73	46.29	t	t	t
6321	5	2026-03-02 21:15:58.514933	15.64	50.55	33.05	t	t	t
6358	4	2026-03-02 21:17:28.68108	45.82	75.57	30.77	t	f	t
6361	3	2026-03-02 21:17:38.604418	16.13	46.08	34.53	t	t	t
6365	5	2026-03-02 21:17:48.603528	72.28	55.19	23.13	t	t	t
6406	4	2026-03-02 21:19:28.721132	76.61	18.65	26.43	t	f	t
6410	3	2026-03-02 21:19:38.671211	52.23	56.01	46.86	t	t	f
6465	4	2026-03-02 21:21:58.777816	31.04	71.10	63.13	t	t	f
6470	4	2026-03-02 21:22:08.756264	59.51	51.23	51.91	t	f	f
6473	3	2026-03-02 21:22:18.756037	54.20	43.78	66.73	t	t	f
6502	4	2026-03-02 21:23:28.843633	77.84	77.93	27.74	t	t	t
6505	3	2026-03-02 21:23:38.814416	75.34	23.63	47.79	t	f	t
6509	4	2026-03-02 21:23:48.816768	16.26	11.66	42.58	t	t	t
6515	3	2026-03-02 21:23:58.823075	73.81	53.79	26.77	t	t	t
6516	3	2026-03-02 21:24:08.8268	68.80	53.47	66.66	t	t	t
6523	5	2026-03-02 21:24:18.831133	57.21	72.41	64.63	t	t	f
6524	2	2026-03-02 21:24:28.836913	67.89	64.15	66.17	f	t	t
6558	4	2026-03-02 21:25:48.93585	36.11	44.27	41.79	t	t	t
6586	5	2026-03-02 21:26:59.017665	38.46	19.63	63.05	t	t	t
6589	3	2026-03-02 21:27:08.975774	48.09	64.36	30.28	t	t	t
6638	4	2026-03-02 21:29:09.116253	68.92	12.41	34.43	t	t	t
6643	3	2026-03-02 21:29:19.078746	35.59	74.08	47.03	t	t	t
6647	2	2026-03-02 21:29:29.078082	48.44	55.17	48.96	t	f	t
6648	2	2026-03-02 21:29:39.087407	72.40	40.03	31.35	t	t	t
6653	5	2026-03-02 21:29:49.083396	57.69	18.54	39.47	t	t	t
6681	3	2026-03-02 21:30:59.165403	21.20	40.04	56.83	t	t	t
6686	4	2026-03-02 21:31:09.137641	20.79	55.86	31.30	t	t	f
6688	2	2026-03-02 21:31:19.150107	55.15	54.55	38.41	t	f	t
6695	5	2026-03-02 21:31:29.152755	11.76	44.94	52.03	t	t	t
6696	2	2026-03-02 21:31:39.166799	33.17	62.17	23.13	t	t	t
6702	5	2026-03-02 21:31:49.168755	42.89	74.22	23.05	t	t	t
6704	2	2026-03-02 21:31:59.16626	27.23	76.61	24.69	t	t	t
6717	2	2026-03-02 21:32:29.216218	37.04	63.38	57.20	f	t	t
6746	3	2026-03-02 21:33:39.324079	24.07	77.25	64.15	t	t	t
6750	3	2026-03-02 21:33:49.305175	42.24	32.55	48.88	t	t	t
6753	3	2026-03-02 21:33:59.310441	17.52	75.01	60.58	t	t	t
6783	5	2026-03-02 21:35:09.392465	60.10	12.45	69.72	t	f	t
6784	3	2026-03-02 21:35:19.367762	21.58	35.97	50.71	t	t	t
4617	3	2026-03-02 20:04:45.288157	35.60	48.21	46.43	t	t	f
4622	4	2026-03-02 20:04:55.272612	29.19	61.11	37.99	t	t	t
4625	3	2026-03-02 20:05:05.28065	70.57	45.03	63.64	t	t	f
4627	4	2026-03-02 20:05:05.313116	13.93	60.29	58.62	t	t	t
4628	2	2026-03-02 20:05:15.28264	71.74	61.29	62.47	t	t	t
4629	4	2026-03-02 20:05:15.282988	55.21	62.70	67.26	f	t	t
4634	4	2026-03-02 20:05:25.287445	75.97	35.96	37.57	t	t	t
4635	3	2026-03-02 20:05:25.287739	55.94	53.53	33.10	t	t	t
4636	2	2026-03-02 20:05:35.301403	75.59	46.66	69.48	t	t	t
4641	5	2026-03-02 20:05:45.304971	15.82	13.93	32.73	t	t	t
4644	3	2026-03-02 20:05:55.308693	48.77	24.11	34.89	t	t	t
4698	4	2026-03-02 20:08:05.491563	35.59	42.16	45.38	t	f	t
4701	3	2026-03-02 20:08:15.468724	40.04	44.51	60.16	t	t	t
4775	4	2026-03-02 20:11:15.668332	24.16	68.20	47.12	t	t	t
4776	2	2026-03-02 20:11:25.604525	15.67	71.52	36.54	t	t	t
4853	2	2026-03-02 20:14:45.75019	24.33	77.36	46.84	t	t	t
4914	5	2026-03-02 20:17:15.892247	41.22	14.47	30.86	t	t	f
4918	3	2026-03-02 20:17:25.862109	34.27	24.35	34.03	t	f	t
4921	3	2026-03-02 20:17:35.869299	68.66	45.34	61.55	t	t	t
4926	4	2026-03-02 20:17:45.872253	45.53	67.78	46.63	t	f	t
4982	2	2026-03-02 20:20:05.988311	53.81	19.79	33.31	t	t	t
4986	3	2026-03-02 20:20:15.989912	48.30	22.99	62.59	t	t	t
4989	3	2026-03-02 20:20:25.996454	21.17	38.49	36.48	t	t	f
5049	3	2026-03-02 20:22:56.162259	36.46	27.02	31.75	t	t	t
5053	4	2026-03-02 20:23:06.149301	47.60	11.36	22.55	t	t	t
5058	4	2026-03-02 20:23:16.149938	16.49	58.68	56.59	t	f	t
5147	5	2026-03-02 20:26:56.316736	57.43	69.54	64.18	t	f	t
5148	2	2026-03-02 20:27:06.278384	30.92	51.99	51.41	t	t	t
5219	5	2026-03-02 20:29:56.43124	66.02	60.19	40.00	t	t	t
5222	2	2026-03-02 20:30:06.391811	44.56	57.70	66.41	t	f	t
5226	4	2026-03-02 20:30:16.390592	24.06	16.05	35.16	t	t	t
5294	4	2026-03-02 20:33:06.514825	11.00	26.19	44.59	t	t	t
5298	3	2026-03-02 20:33:16.492153	54.59	30.95	22.28	t	t	t
5361	3	2026-03-02 20:35:56.670572	74.65	10.94	22.83	t	t	t
5365	4	2026-03-02 20:36:06.650525	57.72	60.49	49.55	t	t	t
5368	2	2026-03-02 20:36:16.650315	18.72	25.98	40.51	t	t	t
5431	5	2026-03-02 20:38:46.828007	70.54	43.15	57.85	t	t	t
5432	2	2026-03-02 20:38:56.809506	37.56	69.38	41.47	t	t	t
5509	3	2026-03-02 20:42:06.978373	31.25	53.55	62.95	f	t	t
5566	4	2026-03-02 20:44:27.147787	77.99	19.12	36.42	t	t	f
5570	3	2026-03-02 20:44:37.12221	22.50	37.05	48.33	t	t	t
5572	3	2026-03-02 20:44:47.124136	28.28	54.56	33.44	t	t	t
5626	3	2026-03-02 20:46:57.256733	62.90	54.31	49.42	t	t	t
5631	2	2026-03-02 20:47:07.226252	59.64	32.66	68.38	t	t	t
5632	2	2026-03-02 20:47:17.235485	56.30	78.13	55.43	t	t	t
5693	3	2026-03-02 20:49:47.367174	16.44	63.32	58.37	t	t	t
5699	4	2026-03-02 20:49:57.337771	23.25	25.48	64.44	t	f	t
5700	2	2026-03-02 20:50:07.338001	19.54	69.69	56.87	t	t	t
5754	4	2026-03-02 20:52:17.497317	19.84	31.49	64.51	t	t	t
5758	3	2026-03-02 20:52:27.463349	55.60	28.23	44.37	t	t	t
5817	3	2026-03-02 20:54:57.637597	43.28	44.47	37.20	t	t	t
5822	2	2026-03-02 20:55:07.61893	63.58	36.65	68.07	t	t	t
5825	3	2026-03-02 20:55:17.616062	11.46	59.87	20.73	t	t	f
5831	4	2026-03-02 20:55:27.618237	62.77	33.35	40.42	t	t	t
5832	2	2026-03-02 20:55:37.630615	54.70	16.80	34.74	t	t	f
5837	5	2026-03-02 20:55:47.629255	27.06	63.31	49.57	t	t	t
5891	5	2026-03-02 20:57:57.741628	40.31	31.80	69.02	t	t	t
5893	2	2026-03-02 20:58:07.72849	20.95	66.76	69.96	f	t	t
5899	3	2026-03-02 20:58:17.727067	36.66	65.40	36.67	t	t	t
5900	2	2026-03-02 20:58:27.742446	48.57	34.32	59.01	t	t	t
5939	5	2026-03-02 20:59:57.873646	75.32	53.93	22.04	f	t	t
5941	2	2026-03-02 21:00:07.827533	19.89	76.76	54.26	t	t	t
6011	3	2026-03-02 21:02:58.064906	64.61	67.00	61.10	t	t	t
6061	3	2026-03-02 21:05:08.074242	14.31	34.19	43.25	t	t	t
6065	4	2026-03-02 21:05:18.046227	65.44	52.37	47.27	t	t	t
6109	3	2026-03-02 21:07:08.166213	71.05	67.16	61.54	t	t	t
6113	4	2026-03-02 21:07:18.133336	55.57	36.14	24.79	t	t	t
6159	5	2026-03-02 21:09:08.263433	36.23	78.41	28.63	t	t	t
6160	2	2026-03-02 21:09:18.242985	55.95	40.42	27.62	t	t	t
6165	5	2026-03-02 21:09:28.243607	68.13	27.57	30.40	t	t	t
6213	3	2026-03-02 21:11:28.369283	63.36	66.79	66.71	t	t	t
6217	4	2026-03-02 21:11:38.340674	16.35	55.28	44.00	t	t	t
6267	4	2026-03-02 21:13:38.478938	59.79	55.87	25.11	t	f	t
6269	2	2026-03-02 21:13:48.432143	53.35	71.75	63.52	t	t	t
6274	3	2026-03-02 21:13:58.440434	27.34	70.16	26.56	t	t	f
6318	5	2026-03-02 21:15:48.563812	63.74	54.90	32.67	t	t	t
6323	3	2026-03-02 21:15:58.515089	35.25	64.56	35.44	t	t	t
6324	2	2026-03-02 21:16:08.535098	52.88	62.00	32.10	t	t	t
6329	5	2026-03-02 21:16:18.539023	52.88	67.41	42.20	t	t	t
6359	5	2026-03-02 21:17:28.684935	66.71	36.24	58.45	t	t	t
6360	2	2026-03-02 21:17:38.604295	62.11	77.39	35.77	t	t	t
6367	4	2026-03-02 21:17:48.60388	15.46	56.36	59.31	t	t	f
6368	2	2026-03-02 21:17:58.612158	23.88	58.62	20.45	t	t	t
6375	5	2026-03-02 21:18:08.616354	17.30	22.56	63.95	t	t	t
6376	2	2026-03-02 21:18:18.622408	55.13	30.37	42.18	t	t	t
6407	5	2026-03-02 21:19:28.730891	57.10	52.15	54.61	t	t	t
6408	2	2026-03-02 21:19:38.670737	30.51	64.68	47.88	t	t	f
6466	5	2026-03-02 21:21:58.778108	29.56	64.10	45.85	t	t	t
6469	3	2026-03-02 21:22:08.755692	34.28	73.54	50.62	t	t	t
6475	4	2026-03-02 21:22:18.756452	42.27	74.86	67.95	t	f	t
6476	2	2026-03-02 21:22:28.772267	10.07	73.29	65.11	f	t	t
6483	5	2026-03-02 21:22:38.762327	18.74	65.48	30.48	t	t	f
6484	2	2026-03-02 21:22:48.769021	71.45	26.67	42.76	t	t	f
6503	5	2026-03-02 21:23:28.845375	31.79	39.35	41.45	f	t	f
6504	2	2026-03-02 21:23:38.814206	74.42	17.59	63.08	t	t	t
6510	5	2026-03-02 21:23:48.816823	22.09	65.69	61.82	t	t	t
6513	4	2026-03-02 21:23:58.822557	49.62	32.61	23.48	t	t	t
6518	4	2026-03-02 21:24:08.827846	25.46	67.53	68.99	t	t	t
6522	3	2026-03-02 21:24:18.830757	58.05	18.49	36.38	t	t	t
6559	5	2026-03-02 21:25:48.935952	30.22	36.53	41.87	t	t	t
6587	4	2026-03-02 21:26:59.116148	14.41	60.41	49.85	t	f	t
6588	2	2026-03-02 21:27:08.975572	40.52	50.84	53.52	t	t	f
6594	3	2026-03-02 21:27:18.979949	41.27	20.24	28.78	t	f	t
6597	3	2026-03-02 21:27:28.984887	73.68	45.37	20.44	t	t	t
6639	5	2026-03-02 21:29:09.117218	37.99	40.60	22.44	t	f	t
6640	2	2026-03-02 21:29:19.078089	78.54	26.66	37.85	t	t	t
6645	5	2026-03-02 21:29:29.077922	23.55	42.34	63.78	t	t	t
4614	2	2026-03-02 20:04:35.247575	79.72	71.33	54.37	t	t	t
4699	5	2026-03-02 20:08:05.494009	64.60	72.01	56.88	t	t	t
4700	2	2026-03-02 20:08:15.468407	25.04	73.57	45.23	t	t	t
4780	2	2026-03-02 20:11:45.623214	67.45	33.66	41.26	t	t	t
4854	4	2026-03-02 20:14:45.755239	10.48	71.52	47.92	t	t	f
4915	4	2026-03-02 20:17:15.892507	15.65	14.22	55.72	t	t	f
4916	2	2026-03-02 20:17:25.861169	24.05	24.24	47.02	t	t	t
4983	5	2026-03-02 20:20:06.019479	43.45	58.57	48.53	t	t	f
4984	2	2026-03-02 20:20:15.989401	16.42	28.84	47.58	t	t	t
5050	4	2026-03-02 20:22:56.166691	36.50	20.94	28.70	t	t	t
5054	3	2026-03-02 20:23:06.149685	62.45	10.57	20.37	t	t	t
5057	2	2026-03-02 20:23:16.149747	61.21	32.66	42.19	t	t	t
5153	3	2026-03-02 20:27:16.331	13.62	65.86	37.46	t	f	t
5158	4	2026-03-02 20:27:26.294393	62.20	78.61	61.45	t	t	f
5160	3	2026-03-02 20:27:36.29596	64.13	55.66	40.23	t	t	t
5223	5	2026-03-02 20:30:06.423081	62.46	17.99	29.56	f	t	t
5224	2	2026-03-02 20:30:16.390378	29.57	19.12	24.99	t	t	t
5295	5	2026-03-02 20:33:06.515117	62.36	41.68	55.99	t	t	f
5296	2	2026-03-02 20:33:16.491317	11.60	16.91	37.61	t	f	t
5362	5	2026-03-02 20:35:56.674239	12.82	75.97	34.69	t	t	t
5366	3	2026-03-02 20:36:06.650895	10.36	45.67	63.62	t	t	t
5433	3	2026-03-02 20:38:56.842131	53.37	53.85	42.06	t	t	t
5438	4	2026-03-02 20:39:06.820662	42.21	65.60	64.66	t	t	t
5510	4	2026-03-02 20:42:07.010875	19.58	56.93	52.82	t	t	t
5567	3	2026-03-02 20:44:27.254219	46.41	16.40	65.09	t	f	t
5568	2	2026-03-02 20:44:37.121842	65.95	37.47	39.27	t	t	t
5573	5	2026-03-02 20:44:47.124404	63.72	63.52	43.56	t	t	t
5576	2	2026-03-02 20:44:57.135648	62.12	12.63	66.83	t	t	t
5627	5	2026-03-02 20:46:57.257068	79.55	30.54	23.35	t	t	t
5628	3	2026-03-02 20:47:07.225433	73.30	74.55	31.53	t	t	t
5694	5	2026-03-02 20:49:47.369383	70.77	57.89	57.57	t	t	t
5696	3	2026-03-02 20:49:57.337098	20.22	54.07	44.04	t	t	t
5701	5	2026-03-02 20:50:07.338244	76.62	13.79	65.83	t	t	t
5755	5	2026-03-02 20:52:17.497581	24.81	52.04	58.87	t	f	t
5756	2	2026-03-02 20:52:27.462934	26.03	30.56	61.05	t	t	f
5818	4	2026-03-02 20:54:57.64284	40.23	12.77	52.35	t	f	t
5820	3	2026-03-02 20:55:07.618379	12.96	32.58	34.83	t	t	t
5827	5	2026-03-02 20:55:17.616694	42.31	13.65	37.11	t	t	t
5828	2	2026-03-02 20:55:27.617166	53.88	61.05	65.20	t	t	t
5894	4	2026-03-02 20:58:07.761593	37.79	78.06	63.68	t	f	t
5896	2	2026-03-02 20:58:17.726457	77.76	64.67	21.18	t	t	t
5942	4	2026-03-02 21:00:07.85856	67.25	24.83	32.37	t	t	t
5944	3	2026-03-02 21:00:17.841082	63.44	51.27	39.55	f	t	t
5950	5	2026-03-02 21:00:27.845471	27.87	26.22	47.21	t	f	t
5952	2	2026-03-02 21:00:37.856955	47.67	47.76	64.06	t	t	t
6012	2	2026-03-02 21:03:07.946778	44.51	23.21	59.61	t	t	t
6018	5	2026-03-02 21:03:17.947755	45.41	35.50	47.35	t	t	t
6021	2	2026-03-02 21:03:27.949888	77.22	73.88	63.22	t	t	t
6062	4	2026-03-02 21:05:08.078452	18.42	56.38	37.58	t	t	t
6066	3	2026-03-02 21:05:18.046324	34.09	25.71	32.94	t	t	t
6110	5	2026-03-02 21:07:08.170195	53.01	16.10	35.46	t	t	t
6114	3	2026-03-02 21:07:18.133417	78.63	36.29	44.31	t	t	t
6162	4	2026-03-02 21:09:18.277456	66.65	66.40	68.65	t	t	t
6166	3	2026-03-02 21:09:28.243678	33.10	62.66	37.55	t	t	t
6168	2	2026-03-02 21:09:38.258263	77.42	11.92	33.11	t	t	t
6174	5	2026-03-02 21:09:48.257159	36.99	70.67	36.36	t	t	t
6176	2	2026-03-02 21:09:58.273371	64.16	27.29	55.63	t	t	t
6214	4	2026-03-02 21:11:28.374154	50.65	10.38	47.24	t	t	t
6218	3	2026-03-02 21:11:38.340912	17.17	14.67	68.87	t	t	t
6275	5	2026-03-02 21:13:58.474321	67.78	57.98	39.65	t	t	t
6276	2	2026-03-02 21:14:08.446429	16.89	68.92	60.88	t	t	t
6319	4	2026-03-02 21:15:48.666588	69.12	78.50	44.97	t	t	t
6320	2	2026-03-02 21:15:58.514612	13.69	28.66	50.71	t	t	t
6369	3	2026-03-02 21:17:58.644158	31.29	32.54	58.88	t	t	t
6374	4	2026-03-02 21:18:08.61611	60.15	55.48	45.40	t	t	t
6413	3	2026-03-02 21:19:48.720728	42.38	36.50	65.83	t	f	t
6418	4	2026-03-02 21:19:58.692549	16.18	18.03	29.47	t	t	t
6420	3	2026-03-02 21:20:08.690738	63.48	68.68	47.16	t	t	f
6467	3	2026-03-02 21:21:58.890061	57.62	19.64	59.65	f	t	t
6468	2	2026-03-02 21:22:08.755428	33.70	24.94	39.23	t	t	t
6474	5	2026-03-02 21:22:18.756196	64.69	68.68	36.70	t	t	t
6507	5	2026-03-02 21:23:38.847214	41.53	57.83	45.52	t	t	t
6508	2	2026-03-02 21:23:48.816638	63.78	78.73	32.80	t	f	t
6514	5	2026-03-02 21:23:58.822879	53.00	73.35	42.59	t	t	t
6517	2	2026-03-02 21:24:08.826904	51.10	44.94	37.74	t	t	t
6521	4	2026-03-02 21:24:18.830502	43.60	53.94	23.41	t	t	t
6560	2	2026-03-02 21:25:58.899761	65.34	64.97	57.05	t	f	t
6565	5	2026-03-02 21:26:08.896869	57.87	23.27	58.09	t	f	t
6591	4	2026-03-02 21:27:09.119784	75.98	21.82	55.30	t	f	t
6592	2	2026-03-02 21:27:18.97973	54.75	69.85	42.67	t	t	t
6599	5	2026-03-02 21:27:28.985907	27.79	16.28	65.58	t	t	t
6600	2	2026-03-02 21:27:38.998109	52.38	28.59	44.24	t	t	t
6649	3	2026-03-02 21:29:39.120836	58.06	22.93	67.97	t	f	f
6655	4	2026-03-02 21:29:49.083593	57.70	24.61	69.20	t	t	t
6682	5	2026-03-02 21:30:59.169666	57.22	51.51	32.97	t	t	t
6687	3	2026-03-02 21:31:09.137975	61.86	39.75	40.78	t	t	t
6718	5	2026-03-02 21:32:29.250085	76.97	19.81	46.93	t	t	t
6720	5	2026-03-02 21:32:39.23069	34.77	74.30	65.29	t	t	f
6747	4	2026-03-02 21:33:39.453078	42.78	60.27	28.94	t	t	f
6748	2	2026-03-02 21:33:49.304578	53.74	68.63	66.62	t	t	t
6755	5	2026-03-02 21:33:59.310559	15.41	36.17	42.99	t	t	t
6787	5	2026-03-02 21:35:19.398114	17.71	38.52	20.53	t	t	t
6788	2	2026-03-02 21:35:29.373469	48.02	11.22	29.59	t	t	f
6804	2	2026-03-02 21:36:09.404574	45.85	67.24	49.95	t	t	t
6821	3	2026-03-02 21:36:49.467329	11.20	17.27	61.29	t	t	t
6826	2	2026-03-02 21:36:59.431428	43.63	37.82	33.84	t	t	t
6828	2	2026-03-02 21:37:09.460866	53.20	14.96	35.18	t	t	t
6832	2	2026-03-02 21:37:19.466135	10.97	37.77	22.31	t	t	t
6833	5	2026-03-02 21:37:19.46649	26.57	45.14	50.98	t	t	f
6839	5	2026-03-02 21:37:29.520233	19.88	51.30	65.57	t	t	t
6842	2	2026-03-02 21:37:39.491831	15.28	39.44	56.17	t	t	t
6845	3	2026-03-02 21:37:49.53735	12.16	73.67	33.87	t	t	t
6846	5	2026-03-02 21:37:49.540683	22.75	19.37	69.43	t	t	t
6847	4	2026-03-02 21:37:49.654064	55.31	17.35	20.06	t	t	t
6848	2	2026-03-02 21:37:59.52073	74.03	55.28	42.86	t	f	t
6849	4	2026-03-02 21:37:59.521057	40.80	22.29	45.49	t	t	t
6850	3	2026-03-02 21:37:59.521376	66.83	55.59	65.39	t	t	f
4618	4	2026-03-02 20:04:45.292983	34.62	57.65	67.61	t	t	t
4621	3	2026-03-02 20:04:55.272326	56.18	57.11	65.70	t	t	t
4637	3	2026-03-02 20:05:35.331481	41.59	66.23	64.96	t	t	t
4642	4	2026-03-02 20:05:45.305292	36.98	44.95	22.24	t	f	t
4645	2	2026-03-02 20:05:55.309193	19.38	63.46	30.70	t	t	t
4703	5	2026-03-02 20:08:15.498351	55.24	50.81	48.89	t	t	t
4704	2	2026-03-02 20:08:25.483728	20.63	78.72	44.74	t	t	f
4781	3	2026-03-02 20:11:45.660411	14.47	60.75	30.74	t	t	t
4855	5	2026-03-02 20:14:45.755438	79.76	66.72	24.47	t	t	t
4919	5	2026-03-02 20:17:25.894033	19.82	54.59	21.27	t	t	t
4920	2	2026-03-02 20:17:35.86869	35.38	66.79	36.96	t	t	t
4927	5	2026-03-02 20:17:45.872646	70.54	65.86	24.81	t	t	t
4990	4	2026-03-02 20:20:26.028386	37.40	52.21	39.97	t	t	t
4993	4	2026-03-02 20:20:36.007382	35.73	16.94	48.15	t	t	t
5051	5	2026-03-02 20:22:56.167757	19.18	75.55	62.33	t	t	f
5052	2	2026-03-02 20:23:06.147585	34.71	31.40	36.79	t	t	t
5059	5	2026-03-02 20:23:16.150601	77.89	38.91	29.84	t	t	t
5060	2	2026-03-02 20:23:26.160063	37.83	44.27	69.94	t	t	t
5065	5	2026-03-02 20:23:36.162096	34.76	34.09	37.39	t	t	f
5069	5	2026-03-02 20:23:46.166866	60.93	21.25	39.71	t	t	t
5154	4	2026-03-02 20:27:16.338977	65.49	31.48	49.24	t	t	t
5157	3	2026-03-02 20:27:26.294112	44.85	62.57	39.29	t	f	t
5163	4	2026-03-02 20:27:36.29647	55.00	73.80	62.98	t	t	t
5164	2	2026-03-02 20:27:46.300202	13.62	78.04	37.33	t	t	t
5227	5	2026-03-02 20:30:16.424021	61.64	56.24	59.01	f	f	t
5228	2	2026-03-02 20:30:26.400464	23.17	34.56	62.32	t	t	f
5299	5	2026-03-02 20:33:16.520418	11.37	28.47	23.04	t	t	t
5300	2	2026-03-02 20:33:26.504078	45.93	32.42	54.30	t	t	t
5363	4	2026-03-02 20:35:56.790119	30.10	72.16	22.56	t	t	t
5364	2	2026-03-02 20:36:06.650049	51.08	56.61	67.15	t	t	t
5369	4	2026-03-02 20:36:16.650957	16.02	29.42	55.14	t	t	f
5434	5	2026-03-02 20:38:56.846712	24.66	71.86	50.80	t	t	t
5437	3	2026-03-02 20:39:06.82046	50.96	68.33	48.32	t	t	t
5442	2	2026-03-02 20:39:16.81929	79.22	14.64	59.06	t	t	t
5447	4	2026-03-02 20:39:26.824733	67.23	32.34	69.13	t	t	t
5448	3	2026-03-02 20:39:36.823394	30.41	57.22	49.35	t	t	t
5511	5	2026-03-02 20:42:07.01306	36.49	15.42	43.35	t	t	t
5513	3	2026-03-02 20:42:16.992257	58.86	20.72	35.00	f	f	t
5518	5	2026-03-02 20:42:26.996239	17.44	24.20	23.26	t	t	t
5571	5	2026-03-02 20:44:37.151499	41.07	45.37	51.98	f	t	t
5575	2	2026-03-02 20:44:47.124889	77.02	61.07	65.12	t	t	f
5634	4	2026-03-02 20:47:17.266788	79.93	25.67	20.34	t	t	t
5637	3	2026-03-02 20:47:27.245307	58.99	63.83	60.95	t	t	t
5643	4	2026-03-02 20:47:37.252587	24.77	34.38	36.49	t	t	t
5644	2	2026-03-02 20:47:47.260663	38.35	62.94	38.79	t	t	t
5649	5	2026-03-02 20:47:57.262118	53.22	36.36	48.02	t	f	f
5695	4	2026-03-02 20:49:47.485057	29.39	55.49	63.24	t	t	t
5698	2	2026-03-02 20:49:57.337635	73.95	65.63	51.18	t	t	t
5703	3	2026-03-02 20:50:07.338822	67.13	40.72	35.97	t	t	f
5761	3	2026-03-02 20:52:37.515174	52.41	23.61	63.26	t	t	t
5766	4	2026-03-02 20:52:47.480309	50.02	20.40	67.39	t	f	t
5768	2	2026-03-02 20:52:57.495554	21.93	52.32	67.84	t	t	t
5819	5	2026-03-02 20:54:57.642935	40.51	71.96	55.88	t	t	t
5821	4	2026-03-02 20:55:07.618582	61.08	34.82	55.44	t	t	t
5826	4	2026-03-02 20:55:17.616606	37.16	45.20	61.59	t	t	t
5829	3	2026-03-02 20:55:27.617542	32.55	64.71	50.13	f	t	f
5895	5	2026-03-02 20:58:07.761736	47.45	35.76	69.90	t	t	t
5897	4	2026-03-02 20:58:17.726593	62.70	11.12	35.97	t	t	f
5943	5	2026-03-02 21:00:07.85943	36.00	36.97	36.91	t	t	t
5945	2	2026-03-02 21:00:17.841206	20.33	31.54	68.05	t	t	f
5949	4	2026-03-02 21:00:27.845395	11.60	26.98	67.93	t	t	t
6013	3	2026-03-02 21:03:07.947056	45.78	49.37	60.50	t	t	f
6019	4	2026-03-02 21:03:17.948097	60.75	25.10	24.87	t	t	f
6020	3	2026-03-02 21:03:27.949268	37.82	24.96	46.60	t	f	t
6063	5	2026-03-02 21:05:08.079207	19.19	15.34	62.89	t	t	t
6064	2	2026-03-02 21:05:18.0461	18.57	13.60	37.17	t	t	t
6111	4	2026-03-02 21:07:08.171127	17.92	46.98	60.61	t	t	f
6112	2	2026-03-02 21:07:18.133081	77.48	31.20	44.61	t	t	t
6163	5	2026-03-02 21:09:18.277556	52.46	54.64	53.81	t	t	t
6164	2	2026-03-02 21:09:28.243487	19.11	52.23	64.79	t	t	t
6215	5	2026-03-02 21:11:28.375444	11.02	79.55	57.75	t	t	t
6216	2	2026-03-02 21:11:38.339927	34.12	70.34	66.51	f	t	t
6277	3	2026-03-02 21:14:08.485714	59.67	37.52	64.34	f	t	t
6281	4	2026-03-02 21:14:18.459078	72.39	10.85	45.23	t	t	t
6325	3	2026-03-02 21:16:08.582144	61.27	16.17	32.72	t	t	t
6331	4	2026-03-02 21:16:18.539496	33.86	10.99	51.09	t	t	t
6332	2	2026-03-02 21:16:28.549818	68.50	24.88	29.55	t	t	f
6370	4	2026-03-02 21:17:58.646094	29.75	22.08	58.08	t	f	t
6373	3	2026-03-02 21:18:08.615879	46.49	27.29	22.46	t	t	t
6414	5	2026-03-02 21:19:48.726027	63.06	58.68	55.80	t	t	t
6417	3	2026-03-02 21:19:58.692089	67.94	16.18	65.89	t	t	t
6422	4	2026-03-02 21:20:08.690956	26.16	33.22	46.10	t	t	t
6471	5	2026-03-02 21:22:08.786696	45.16	71.45	61.51	t	t	t
6472	2	2026-03-02 21:22:18.755862	19.33	63.44	69.88	t	t	f
6525	3	2026-03-02 21:24:28.869292	63.73	57.14	69.56	t	t	t
6529	4	2026-03-02 21:24:38.842303	51.81	18.83	36.53	t	t	t
6534	4	2026-03-02 21:24:48.848661	24.47	58.86	53.44	t	t	t
6539	2	2026-03-02 21:24:58.843455	78.89	35.47	55.62	t	t	f
6561	3	2026-03-02 21:25:58.900045	61.34	44.97	67.62	t	t	t
6567	4	2026-03-02 21:26:08.897168	77.96	27.87	46.15	t	t	t
6568	2	2026-03-02 21:26:18.915131	43.76	34.38	59.78	t	t	t
6595	5	2026-03-02 21:27:19.074592	52.53	75.13	33.80	t	t	t
6596	2	2026-03-02 21:27:28.984669	77.11	70.64	24.01	t	t	t
6650	4	2026-03-02 21:29:39.122307	78.68	31.97	33.74	t	t	t
6654	2	2026-03-02 21:29:49.083463	18.37	12.86	53.49	t	t	f
6656	3	2026-03-02 21:29:59.104439	63.31	39.74	40.80	t	t	t
6662	4	2026-03-02 21:30:09.103008	39.83	10.52	41.63	t	t	f
6683	4	2026-03-02 21:30:59.170615	23.56	26.92	58.28	t	t	t
6684	2	2026-03-02 21:31:09.137134	72.74	35.35	59.65	t	t	t
6719	4	2026-03-02 21:32:29.370231	30.20	76.67	35.56	f	t	t
6721	2	2026-03-02 21:32:39.230926	72.99	12.72	28.07	t	t	t
6751	5	2026-03-02 21:33:49.335084	78.71	58.05	66.51	t	t	f
6752	2	2026-03-02 21:33:59.310233	13.39	45.15	69.93	t	t	t
6789	5	2026-03-02 21:35:29.373719	46.16	53.15	46.31	t	t	f
6805	3	2026-03-02 21:36:09.404838	38.05	18.01	40.35	t	t	t
6822	5	2026-03-02 21:36:49.468812	49.84	73.21	39.67	t	t	t
6827	4	2026-03-02 21:36:59.431624	40.57	36.03	28.84	t	t	f
4619	5	2026-03-02 20:04:45.293351	17.13	44.86	33.56	t	t	t
4620	2	2026-03-02 20:04:55.271989	63.81	57.12	21.47	t	t	t
4638	4	2026-03-02 20:05:35.335759	72.86	33.68	59.52	t	t	t
4643	3	2026-03-02 20:05:45.305414	72.34	50.65	21.85	t	t	t
4646	4	2026-03-02 20:05:55.309268	77.04	16.33	61.08	t	t	f
4705	4	2026-03-02 20:08:25.516492	23.11	43.37	61.25	t	t	t
4708	4	2026-03-02 20:08:35.49241	11.88	79.43	37.41	t	t	f
4713	5	2026-03-02 20:08:45.495738	41.96	60.04	36.16	t	t	t
4782	4	2026-03-02 20:11:45.661487	52.00	65.28	50.65	t	t	f
4856	2	2026-03-02 20:14:55.733455	14.56	33.84	23.38	t	f	t
4922	5	2026-03-02 20:17:35.899914	10.20	58.57	20.28	t	t	f
4925	3	2026-03-02 20:17:45.871816	19.63	41.64	50.27	t	t	t
4991	5	2026-03-02 20:20:26.032911	12.39	49.38	39.40	t	t	t
4992	2	2026-03-02 20:20:36.007205	45.11	26.06	57.39	t	t	t
5055	5	2026-03-02 20:23:06.20354	31.31	49.19	29.33	t	t	f
5056	3	2026-03-02 20:23:16.149706	22.39	64.14	68.62	t	t	t
5155	5	2026-03-02 20:27:16.33968	57.06	15.76	22.28	t	t	t
5156	2	2026-03-02 20:27:26.293843	60.96	37.73	42.14	t	t	t
5162	5	2026-03-02 20:27:36.296282	50.31	36.66	21.71	t	t	t
5165	4	2026-03-02 20:27:46.300695	34.42	36.61	54.60	t	f	t
5229	3	2026-03-02 20:30:26.431602	42.41	36.67	54.96	t	t	f
5301	4	2026-03-02 20:33:26.535938	15.97	39.47	42.04	t	t	t
5305	2	2026-03-02 20:33:36.518503	48.22	10.82	60.01	t	t	t
5311	4	2026-03-02 20:33:46.522557	37.43	68.04	31.09	t	t	f
5314	3	2026-03-02 20:33:56.519799	55.01	77.58	39.78	t	t	t
5367	5	2026-03-02 20:36:06.679736	28.44	50.10	49.86	t	t	f
5370	3	2026-03-02 20:36:16.652188	20.58	51.20	39.50	t	f	t
5435	4	2026-03-02 20:38:56.846973	56.64	43.84	44.22	t	t	f
5436	2	2026-03-02 20:39:06.820097	17.66	26.63	52.97	t	t	t
5440	5	2026-03-02 20:39:16.818865	12.18	25.12	47.48	t	t	t
5445	5	2026-03-02 20:39:26.824195	12.15	13.35	34.27	t	t	t
5450	2	2026-03-02 20:39:36.823906	23.90	52.52	61.48	t	t	t
5514	4	2026-03-02 20:42:17.024545	75.45	11.82	41.10	t	t	t
5517	3	2026-03-02 20:42:26.996112	66.86	68.98	54.80	t	t	t
5577	3	2026-03-02 20:44:57.166581	72.81	34.95	51.02	f	t	t
5582	4	2026-03-02 20:45:07.145666	68.39	29.53	61.17	t	t	f
5584	2	2026-03-02 20:45:17.161567	28.51	78.28	55.35	t	t	t
5589	5	2026-03-02 20:45:27.16297	35.48	18.60	20.76	t	t	t
5635	5	2026-03-02 20:47:17.269704	59.96	54.47	69.96	t	t	t
5636	2	2026-03-02 20:47:27.245072	67.42	53.65	34.18	t	t	f
5641	5	2026-03-02 20:47:37.252193	12.12	42.57	46.70	t	f	f
5705	3	2026-03-02 20:50:17.386929	43.86	34.79	67.67	t	t	t
5711	4	2026-03-02 20:50:27.3564	25.31	32.39	40.41	t	t	t
5712	2	2026-03-02 20:50:37.367518	29.76	26.97	66.51	t	t	t
5719	5	2026-03-02 20:50:47.370535	41.96	25.93	20.35	t	t	t
5720	2	2026-03-02 20:50:57.372213	39.09	53.90	50.98	t	t	t
5762	4	2026-03-02 20:52:37.518977	46.95	35.54	57.95	f	t	t
5765	3	2026-03-02 20:52:47.480013	77.40	33.92	68.92	t	t	t
5823	5	2026-03-02 20:55:07.652266	41.69	75.59	54.96	t	t	t
5824	2	2026-03-02 20:55:17.615191	29.93	33.04	69.60	t	t	t
5830	5	2026-03-02 20:55:27.61793	28.48	25.36	37.21	t	t	f
5901	3	2026-03-02 20:58:27.77647	62.23	47.70	30.71	t	t	f
5906	4	2026-03-02 20:58:37.754541	24.16	76.99	41.38	t	t	t
5946	4	2026-03-02 21:00:17.874723	39.32	53.11	20.89	t	t	t
5951	3	2026-03-02 21:00:27.845542	26.26	71.20	36.19	t	t	t
6014	4	2026-03-02 21:03:07.981243	79.86	44.48	45.88	t	t	t
6017	3	2026-03-02 21:03:17.947479	47.32	10.61	37.70	t	t	t
6022	4	2026-03-02 21:03:27.950465	15.17	62.89	23.29	t	t	t
6024	2	2026-03-02 21:03:37.965801	62.90	19.58	52.38	t	t	t
6067	5	2026-03-02 21:05:18.189657	44.62	67.01	27.09	t	t	t
6068	2	2026-03-02 21:05:28.059008	41.06	17.05	64.54	t	t	t
6117	3	2026-03-02 21:07:28.178075	66.42	43.06	26.27	t	t	t
6122	4	2026-03-02 21:07:38.14985	61.36	56.90	59.11	t	t	t
6124	3	2026-03-02 21:07:48.152262	61.66	20.72	60.54	t	t	t
6169	3	2026-03-02 21:09:38.290632	36.22	73.17	22.01	t	t	t
6175	4	2026-03-02 21:09:48.257231	27.07	77.15	26.26	t	t	f
6219	5	2026-03-02 21:11:38.371882	25.14	59.61	26.07	t	t	t
6220	2	2026-03-02 21:11:48.356615	47.99	39.40	59.45	t	t	t
6226	5	2026-03-02 21:11:58.358159	36.06	31.97	50.27	t	f	t
6278	5	2026-03-02 21:14:08.486614	48.47	63.45	32.34	t	t	t
6282	3	2026-03-02 21:14:18.459317	51.39	10.58	59.83	f	t	t
6326	4	2026-03-02 21:16:08.585547	34.76	56.60	20.74	t	t	t
6330	3	2026-03-02 21:16:18.539196	27.52	76.24	32.96	t	t	t
6371	5	2026-03-02 21:17:58.763815	34.80	43.47	57.85	t	t	t
6372	2	2026-03-02 21:18:08.615691	30.92	13.41	64.06	t	t	t
6415	4	2026-03-02 21:19:48.72626	36.11	59.38	66.78	t	t	t
6416	2	2026-03-02 21:19:58.691864	64.73	30.57	21.17	t	t	t
6423	5	2026-03-02 21:20:08.691006	37.05	21.16	31.11	t	t	t
6424	2	2026-03-02 21:20:18.705275	50.66	49.04	61.93	t	t	t
6477	3	2026-03-02 21:22:28.812706	79.17	61.56	68.65	t	t	t
6481	4	2026-03-02 21:22:38.762043	32.59	15.52	28.13	t	t	t
6526	4	2026-03-02 21:24:28.874242	64.72	15.55	50.45	t	t	t
6530	3	2026-03-02 21:24:38.842505	22.99	37.78	49.63	t	t	t
6533	3	2026-03-02 21:24:48.848414	21.55	79.65	41.03	t	t	t
6538	4	2026-03-02 21:24:58.843385	12.05	47.47	66.64	t	t	t
6540	2	2026-03-02 21:25:08.857421	61.16	35.08	67.64	f	t	t
6562	4	2026-03-02 21:25:58.933277	16.85	72.50	23.56	t	t	t
6566	3	2026-03-02 21:26:08.897026	18.51	21.37	67.38	t	t	t
6601	5	2026-03-02 21:27:39.032576	48.43	74.26	21.47	t	t	t
6606	4	2026-03-02 21:27:49.009731	31.71	35.40	57.58	t	t	t
6610	3	2026-03-02 21:27:59.009926	40.42	67.46	39.29	t	t	f
6651	5	2026-03-02 21:29:39.123766	55.34	77.35	52.42	t	t	t
6652	3	2026-03-02 21:29:49.083163	23.39	62.27	50.93	t	t	t
6689	3	2026-03-02 21:31:19.182497	58.19	78.20	45.79	t	t	t
6693	4	2026-03-02 21:31:29.151915	60.61	27.41	33.93	t	t	t
6722	4	2026-03-02 21:32:39.262022	74.56	71.87	61.28	t	t	t
6724	3	2026-03-02 21:32:49.246587	76.39	14.81	23.00	t	t	t
6757	3	2026-03-02 21:34:09.356405	77.91	53.46	42.31	t	t	t
6762	4	2026-03-02 21:34:19.323375	16.24	26.56	54.81	t	t	t
6764	2	2026-03-02 21:34:29.338422	30.49	69.98	30.38	t	t	t
6771	5	2026-03-02 21:34:39.337865	59.60	66.10	32.37	t	t	t
6772	2	2026-03-02 21:34:49.339971	29.64	17.32	33.57	t	f	t
6778	5	2026-03-02 21:34:59.341237	28.50	76.76	48.02	t	f	t
6793	3	2026-03-02 21:35:39.413089	17.49	17.98	20.68	t	t	t
6798	4	2026-03-02 21:35:49.390777	54.60	62.99	52.06	t	t	t
6806	4	2026-03-02 21:36:09.405045	73.10	43.94	47.92	f	t	t
6823	4	2026-03-02 21:36:49.469047	35.30	79.53	36.64	t	t	f
4615	5	2026-03-02 20:04:35.247879	15.01	61.95	43.00	f	t	f
4616	2	2026-03-02 20:04:45.257468	12.86	51.47	43.78	t	t	t
4706	5	2026-03-02 20:08:25.525786	17.58	35.14	68.13	t	t	t
4710	3	2026-03-02 20:08:35.493107	71.54	18.33	46.55	f	t	t
4715	3	2026-03-02 20:08:45.495928	64.25	36.16	25.73	t	t	t
4716	3	2026-03-02 20:08:55.507467	17.45	79.31	38.58	t	t	t
4783	5	2026-03-02 20:11:45.761325	72.25	31.54	25.33	f	t	f
4857	3	2026-03-02 20:14:55.771359	52.13	30.50	29.45	t	f	t
4862	4	2026-03-02 20:15:05.743871	31.10	57.55	58.93	t	t	t
4865	3	2026-03-02 20:15:15.749969	40.86	71.23	67.18	t	t	t
4870	4	2026-03-02 20:15:25.752826	39.59	66.92	65.56	t	t	t
4873	3	2026-03-02 20:15:35.755484	46.72	40.57	49.68	t	t	t
4923	4	2026-03-02 20:17:36.015322	29.78	54.17	48.64	t	f	t
4924	2	2026-03-02 20:17:45.871317	71.74	11.39	27.72	t	t	t
4994	3	2026-03-02 20:20:36.044813	42.91	29.03	50.53	t	t	t
5061	3	2026-03-02 20:23:26.195016	28.49	77.26	63.72	t	t	t
5067	4	2026-03-02 20:23:36.16229	45.84	70.14	47.92	t	t	t
5070	4	2026-03-02 20:23:46.167009	28.53	25.48	42.25	t	t	t
5072	2	2026-03-02 20:23:56.173457	15.83	18.32	44.50	t	t	t
5079	5	2026-03-02 20:24:06.182661	62.12	17.30	50.20	t	t	t
5080	2	2026-03-02 20:24:16.210389	70.71	60.10	43.07	t	f	t
5087	5	2026-03-02 20:24:26.213429	72.73	48.03	65.32	t	t	t
5090	2	2026-03-02 20:24:36.20459	46.07	42.15	58.42	t	t	t
5167	5	2026-03-02 20:27:46.330569	66.74	41.03	30.02	t	t	f
5168	3	2026-03-02 20:27:56.317778	63.47	42.41	42.22	t	t	f
5173	5	2026-03-02 20:28:06.319913	74.90	67.54	34.80	t	t	f
5178	4	2026-03-02 20:28:16.321733	38.46	48.56	44.09	t	t	t
5181	3	2026-03-02 20:28:26.334972	12.60	32.38	57.64	t	t	t
5186	4	2026-03-02 20:28:36.331678	34.95	27.58	57.23	t	t	t
5230	5	2026-03-02 20:30:26.436977	55.34	58.02	60.99	t	f	t
5232	2	2026-03-02 20:30:36.406443	55.43	29.00	63.75	t	t	f
5302	5	2026-03-02 20:33:26.536741	57.84	76.43	55.54	t	t	t
5304	3	2026-03-02 20:33:36.518438	52.90	28.82	26.86	t	t	t
5310	5	2026-03-02 20:33:46.522389	47.00	30.09	33.94	t	t	t
5312	2	2026-03-02 20:33:56.519538	73.37	41.62	42.83	t	t	t
5371	5	2026-03-02 20:36:16.682772	61.69	55.25	46.10	t	f	t
5372	2	2026-03-02 20:36:26.6643	53.20	53.20	45.33	t	f	t
5377	5	2026-03-02 20:36:36.663333	24.36	24.86	49.21	f	t	t
5439	5	2026-03-02 20:39:06.851561	54.29	23.75	50.37	t	t	t
5441	3	2026-03-02 20:39:16.819112	30.51	38.36	65.75	t	t	t
5446	3	2026-03-02 20:39:26.824497	39.06	35.47	36.34	t	t	t
5451	4	2026-03-02 20:39:36.824076	70.31	76.64	69.97	t	t	t
5452	2	2026-03-02 20:39:46.845412	50.46	62.03	50.10	t	t	t
5515	5	2026-03-02 20:42:17.028027	42.90	70.87	64.37	t	t	t
5516	2	2026-03-02 20:42:26.995322	71.68	10.08	64.85	t	t	t
5578	5	2026-03-02 20:44:57.171614	52.45	39.41	53.43	t	t	t
5581	3	2026-03-02 20:45:07.143901	12.32	58.28	21.96	t	t	t
5638	4	2026-03-02 20:47:27.276599	64.06	74.99	22.95	t	t	t
5642	3	2026-03-02 20:47:37.252302	26.39	71.92	22.66	t	t	t
5706	4	2026-03-02 20:50:17.387248	56.48	29.39	48.06	t	t	t
5710	3	2026-03-02 20:50:27.356	75.49	56.25	23.38	t	t	t
5763	5	2026-03-02 20:52:37.519238	31.31	79.89	68.72	t	t	t
5764	2	2026-03-02 20:52:47.479678	48.94	63.68	28.70	t	t	t
5833	3	2026-03-02 20:55:37.665815	27.10	74.95	56.77	t	t	t
5838	4	2026-03-02 20:55:47.629344	20.11	59.90	39.11	f	t	t
5841	2	2026-03-02 20:55:57.63577	44.41	64.99	22.00	t	t	t
5902	5	2026-03-02 20:58:27.782454	38.07	67.57	21.93	t	t	t
5904	2	2026-03-02 20:58:37.754205	13.65	63.62	27.23	t	t	t
5947	5	2026-03-02 21:00:17.876623	58.36	12.98	41.81	t	t	t
5948	2	2026-03-02 21:00:27.844934	76.55	65.27	61.02	t	t	t
6015	5	2026-03-02 21:03:07.98222	33.35	65.23	27.00	t	t	t
6016	2	2026-03-02 21:03:17.946615	28.83	67.87	44.60	t	t	t
6023	5	2026-03-02 21:03:27.950155	77.06	46.48	37.99	t	t	t
6025	3	2026-03-02 21:03:37.966327	13.32	63.62	48.51	t	t	t
6069	4	2026-03-02 21:05:28.094791	73.17	37.49	64.84	f	t	t
6073	3	2026-03-02 21:05:38.068579	67.90	45.18	55.08	t	t	f
6118	4	2026-03-02 21:07:28.179959	46.19	31.73	29.82	f	t	t
6121	3	2026-03-02 21:07:38.149755	54.67	35.97	21.28	t	t	t
6127	4	2026-03-02 21:07:48.153144	72.32	25.32	30.00	t	t	f
6128	2	2026-03-02 21:07:58.160198	50.14	27.71	63.28	t	t	t
6170	4	2026-03-02 21:09:38.295007	55.40	13.82	43.68	t	t	f
6173	3	2026-03-02 21:09:48.257082	27.22	10.97	49.53	t	t	t
6221	3	2026-03-02 21:11:48.39058	21.33	35.05	31.61	t	t	f
6227	4	2026-03-02 21:11:58.358509	52.67	32.54	64.10	t	t	f
6228	2	2026-03-02 21:12:08.367151	41.20	62.69	28.71	t	t	t
6279	4	2026-03-02 21:14:08.486909	75.80	23.70	56.25	t	t	f
6280	2	2026-03-02 21:14:18.458812	55.73	19.57	56.93	t	t	t
6327	5	2026-03-02 21:16:08.587833	17.65	71.51	32.21	t	t	f
6328	2	2026-03-02 21:16:18.538729	46.72	52.70	59.33	t	t	t
6377	3	2026-03-02 21:18:18.653747	15.02	75.93	30.50	t	t	t
6381	4	2026-03-02 21:18:28.634274	46.86	11.91	28.88	t	t	t
6419	5	2026-03-02 21:19:58.724574	53.61	49.42	61.49	t	t	t
6421	2	2026-03-02 21:20:08.690818	48.71	37.48	57.55	t	t	t
6478	5	2026-03-02 21:22:28.817806	28.03	45.58	60.17	t	t	t
6482	3	2026-03-02 21:22:38.762129	43.40	17.27	35.25	t	f	t
6527	5	2026-03-02 21:24:28.875602	35.49	33.94	33.23	t	t	t
6528	2	2026-03-02 21:24:38.841975	46.84	23.25	25.64	t	t	t
6563	5	2026-03-02 21:25:59.053941	19.17	48.21	55.48	t	t	f
6564	2	2026-03-02 21:26:08.89671	17.60	23.78	27.07	t	t	t
6602	3	2026-03-02 21:27:39.134375	42.23	29.10	37.29	t	t	t
6605	3	2026-03-02 21:27:49.009161	35.00	60.16	20.63	t	t	f
6609	4	2026-03-02 21:27:59.009685	10.55	48.23	29.79	t	t	t
6657	2	2026-03-02 21:29:59.14019	17.02	32.06	21.81	t	f	t
6661	3	2026-03-02 21:30:09.103129	17.44	78.90	53.71	t	t	t
6690	4	2026-03-02 21:31:19.18654	46.93	35.08	30.11	t	t	t
6694	3	2026-03-02 21:31:29.15217	41.18	73.76	45.17	t	t	f
6723	3	2026-03-02 21:32:39.385238	46.37	26.32	54.88	t	t	t
6725	2	2026-03-02 21:32:49.247734	77.53	29.12	24.56	t	t	t
6758	4	2026-03-02 21:34:09.356733	47.07	66.35	49.62	t	t	f
6763	3	2026-03-02 21:34:19.323727	48.40	42.38	68.77	t	t	t
6794	4	2026-03-02 21:35:39.414845	70.77	18.66	61.49	t	t	t
6797	3	2026-03-02 21:35:49.390849	11.95	20.56	34.81	t	t	t
6807	5	2026-03-02 21:36:09.436351	54.48	66.66	24.26	t	t	t
6808	2	2026-03-02 21:36:19.416946	76.29	34.75	68.74	t	t	t
6812	5	2026-03-02 21:36:29.418394	56.07	27.08	42.55	t	t	t
6817	5	2026-03-02 21:36:39.416964	44.24	59.41	31.18	t	t	t
6824	3	2026-03-02 21:36:59.430678	34.94	52.81	63.86	t	f	t
4623	5	2026-03-02 20:04:55.302626	14.02	10.23	35.25	t	t	t
4624	2	2026-03-02 20:05:05.280161	39.26	34.95	68.94	t	t	t
4630	5	2026-03-02 20:05:15.28316	59.97	54.00	39.24	t	t	t
4633	2	2026-03-02 20:05:25.287192	67.92	64.19	29.53	f	t	f
4639	5	2026-03-02 20:05:35.336622	64.73	59.05	57.81	t	t	t
4640	2	2026-03-02 20:05:45.304805	74.77	25.05	59.31	t	t	t
4707	3	2026-03-02 20:08:25.525832	37.23	28.76	40.12	t	t	t
4709	2	2026-03-02 20:08:35.493075	69.96	58.17	29.49	t	t	t
4714	4	2026-03-02 20:08:45.495889	61.91	37.23	23.21	t	t	t
4784	2	2026-03-02 20:11:55.615617	31.57	36.05	34.79	t	t	t
4791	5	2026-03-02 20:12:05.615463	27.88	45.09	45.52	t	t	t
4858	4	2026-03-02 20:14:55.771984	49.57	45.59	27.93	t	t	t
4861	3	2026-03-02 20:15:05.743654	46.84	14.01	63.54	t	t	t
4928	2	2026-03-02 20:17:55.87659	59.74	16.54	30.89	f	t	t
4995	5	2026-03-02 20:20:36.046183	11.12	39.53	22.37	t	t	t
5062	4	2026-03-02 20:23:26.200162	72.05	12.67	59.72	t	t	t
5064	3	2026-03-02 20:23:36.161895	27.23	30.07	27.73	t	t	f
5071	3	2026-03-02 20:23:46.167087	59.67	57.36	52.67	t	t	t
5073	3	2026-03-02 20:23:56.173758	48.51	29.86	61.09	t	t	t
5077	4	2026-03-02 20:24:06.181582	72.73	13.90	58.27	t	t	t
5169	2	2026-03-02 20:27:56.317892	12.93	26.77	36.98	t	t	t
5174	4	2026-03-02 20:28:06.320096	11.89	42.67	30.02	t	t	t
5177	3	2026-03-02 20:28:16.321332	79.91	70.02	52.62	t	t	t
5231	4	2026-03-02 20:30:26.547097	37.63	18.82	52.03	t	f	t
5303	3	2026-03-02 20:33:26.652968	12.36	61.73	37.41	t	f	t
5373	3	2026-03-02 20:36:26.697359	36.92	34.96	49.60	f	t	t
5378	4	2026-03-02 20:36:36.663512	68.64	63.24	23.82	t	t	f
5380	4	2026-03-02 20:36:46.679301	47.21	52.34	36.62	t	t	t
5443	4	2026-03-02 20:39:16.851406	19.60	46.46	48.43	t	t	t
5444	2	2026-03-02 20:39:26.823761	44.27	18.75	47.17	t	t	t
5449	5	2026-03-02 20:39:36.823579	44.44	77.18	22.09	t	t	t
5521	3	2026-03-02 20:42:37.041143	38.12	35.66	47.30	t	t	t
5525	4	2026-03-02 20:42:47.01625	71.08	43.78	33.55	t	t	t
5579	4	2026-03-02 20:44:57.171836	58.00	68.02	39.10	t	t	t
5580	2	2026-03-02 20:45:07.143457	49.17	76.96	24.65	t	t	f
5639	5	2026-03-02 20:47:27.279937	56.94	16.12	30.58	t	f	t
5640	2	2026-03-02 20:47:37.251831	68.77	37.77	43.10	t	t	f
5707	5	2026-03-02 20:50:17.511476	61.82	74.74	47.39	t	t	t
5708	2	2026-03-02 20:50:27.355256	49.59	72.27	50.18	t	t	t
5769	3	2026-03-02 20:52:57.526707	35.58	65.13	47.53	t	t	t
5774	3	2026-03-02 20:53:07.509108	13.83	11.11	38.82	t	t	t
5834	4	2026-03-02 20:55:37.667393	35.52	53.08	69.45	t	f	t
5839	3	2026-03-02 20:55:47.629418	31.66	57.40	32.54	t	t	f
5840	3	2026-03-02 20:55:57.635434	77.67	53.48	63.87	t	t	t
5846	4	2026-03-02 20:56:07.64204	55.13	51.39	21.31	t	t	t
5851	3	2026-03-02 20:56:17.644625	49.50	78.28	65.85	t	t	t
5852	2	2026-03-02 20:56:27.643313	70.08	23.80	21.01	f	t	t
5859	5	2026-03-02 20:56:37.647124	71.73	78.99	30.59	t	t	t
5860	2	2026-03-02 20:56:47.659784	43.39	36.07	45.76	t	f	t
5867	5	2026-03-02 20:56:57.6627	22.54	33.93	24.28	t	t	t
5868	2	2026-03-02 20:57:07.677257	10.58	64.04	48.17	t	f	f
5874	4	2026-03-02 20:57:17.6768	71.91	12.67	37.70	t	f	t
5876	2	2026-03-02 20:57:27.69189	33.17	18.16	37.81	t	t	t
5883	5	2026-03-02 20:57:37.690844	66.79	52.49	25.94	t	f	t
5884	3	2026-03-02 20:57:47.698477	60.19	30.81	41.24	t	f	t
5903	4	2026-03-02 20:58:27.782721	29.36	41.43	59.15	t	t	t
5905	3	2026-03-02 20:58:37.754409	40.59	59.16	69.18	t	t	t
5953	3	2026-03-02 21:00:37.890374	64.97	29.94	25.09	t	t	t
5958	4	2026-03-02 21:00:47.864182	34.57	59.64	26.79	f	t	t
5962	3	2026-03-02 21:00:57.866593	12.90	17.06	31.11	t	t	t
5964	3	2026-03-02 21:01:07.868472	72.45	55.40	53.62	t	t	f
5969	5	2026-03-02 21:01:17.871673	46.54	40.53	21.89	t	t	t
5973	4	2026-03-02 21:01:27.871932	46.98	41.48	34.88	t	f	t
6026	4	2026-03-02 21:03:37.997346	69.87	38.84	49.40	t	t	t
6029	3	2026-03-02 21:03:47.979371	15.61	39.79	69.81	t	f	t
6070	5	2026-03-02 21:05:28.095845	27.70	21.28	64.26	t	t	t
6072	2	2026-03-02 21:05:38.068457	68.68	54.06	49.81	t	t	t
6119	5	2026-03-02 21:07:28.182217	23.63	72.75	22.22	t	t	t
6120	2	2026-03-02 21:07:38.148785	43.26	25.60	28.31	t	t	t
6126	5	2026-03-02 21:07:48.153007	50.32	59.89	27.22	t	t	t
6171	5	2026-03-02 21:09:38.297813	47.36	10.42	47.69	t	t	t
6172	2	2026-03-02 21:09:48.256966	58.59	75.56	68.35	f	t	t
6222	4	2026-03-02 21:11:48.390934	75.46	37.34	61.68	t	t	t
6225	3	2026-03-02 21:11:58.357629	21.19	67.57	57.91	t	t	f
6283	5	2026-03-02 21:14:18.592017	60.38	33.98	35.71	t	t	t
6284	2	2026-03-02 21:14:28.473922	42.44	42.94	24.58	t	t	t
6291	5	2026-03-02 21:14:38.459781	22.28	66.03	59.61	t	t	t
6333	3	2026-03-02 21:16:28.585362	20.04	76.28	54.97	t	t	t
6338	4	2026-03-02 21:16:38.563112	33.58	53.08	26.48	t	t	t
6378	5	2026-03-02 21:18:18.659422	16.83	25.12	34.18	t	t	t
6380	3	2026-03-02 21:18:28.633987	67.59	45.08	24.81	t	t	t
6384	3	2026-03-02 21:18:38.639463	40.61	67.11	52.11	t	t	t
6425	3	2026-03-02 21:20:18.738855	46.00	52.88	35.71	t	t	t
6429	5	2026-03-02 21:20:28.714516	52.88	36.09	42.86	t	t	t
6435	4	2026-03-02 21:20:38.715194	54.53	56.08	42.23	t	f	t
6479	4	2026-03-02 21:22:28.818117	42.23	54.20	68.68	t	t	t
6480	2	2026-03-02 21:22:38.761742	22.16	59.18	38.97	t	f	t
6531	5	2026-03-02 21:24:38.97443	63.59	55.04	51.19	t	t	t
6532	2	2026-03-02 21:24:48.847716	13.87	74.76	30.18	t	t	t
6537	5	2026-03-02 21:24:58.843259	76.75	31.35	34.44	t	f	t
6569	3	2026-03-02 21:26:18.945678	45.44	37.96	49.51	t	t	t
6603	4	2026-03-02 21:27:39.141993	56.74	38.84	66.90	t	t	f
6604	2	2026-03-02 21:27:49.0089	30.38	73.56	39.85	t	t	t
6611	5	2026-03-02 21:27:59.010124	78.03	18.69	60.01	t	t	t
6612	2	2026-03-02 21:28:09.025223	28.40	34.79	47.44	t	f	t
6617	5	2026-03-02 21:28:19.030328	61.97	16.19	20.61	t	f	t
6621	4	2026-03-02 21:28:29.035011	45.72	74.32	20.46	t	t	t
6658	4	2026-03-02 21:29:59.14615	10.72	54.81	49.23	t	t	t
6691	5	2026-03-02 21:31:19.188243	17.38	12.77	55.05	t	t	t
6692	2	2026-03-02 21:31:29.15169	64.25	30.62	44.10	t	t	t
6726	4	2026-03-02 21:32:49.276705	71.65	79.18	22.96	t	t	t
6728	3	2026-03-02 21:32:59.258576	35.52	61.29	58.96	t	t	t
6733	4	2026-03-02 21:33:09.261523	62.77	22.03	37.40	t	t	t
6736	3	2026-03-02 21:33:19.270373	70.23	62.91	57.90	t	t	t
6741	5	2026-03-02 21:33:29.276384	56.93	43.56	58.10	t	t	t
6759	5	2026-03-02 21:34:09.360036	26.84	76.30	68.26	t	t	f
6760	2	2026-03-02 21:34:19.322926	22.12	21.44	53.92	t	t	t
4626	5	2026-03-02 20:05:05.309774	69.50	13.60	63.82	t	t	t
4631	3	2026-03-02 20:05:15.283455	22.47	48.91	56.26	t	f	f
4632	5	2026-03-02 20:05:25.28699	64.53	78.48	53.01	t	f	f
4647	5	2026-03-02 20:05:55.345049	28.70	69.30	55.67	t	t	t
4711	5	2026-03-02 20:08:35.644085	40.77	29.72	32.26	t	t	t
4712	2	2026-03-02 20:08:45.495368	75.18	28.56	55.06	t	t	t
4785	3	2026-03-02 20:11:55.651969	24.36	60.51	28.86	t	f	f
4790	4	2026-03-02 20:12:05.614761	10.29	21.50	20.37	t	t	f
4859	5	2026-03-02 20:14:55.77555	16.10	73.74	58.09	t	t	t
4860	2	2026-03-02 20:15:05.743155	13.12	17.25	59.67	t	t	t
4929	3	2026-03-02 20:17:55.876894	36.02	58.19	49.76	t	t	t
4996	2	2026-03-02 20:20:46.015888	37.08	69.61	64.70	t	t	t
5063	5	2026-03-02 20:23:26.204519	64.22	12.15	52.85	t	t	t
5066	2	2026-03-02 20:23:36.162176	24.92	22.92	52.45	t	t	t
5068	2	2026-03-02 20:23:46.166804	67.15	29.47	37.60	t	t	t
5170	4	2026-03-02 20:27:56.353657	64.11	56.70	30.26	t	t	t
5175	3	2026-03-02 20:28:06.320429	28.26	31.63	22.45	t	f	t
5176	2	2026-03-02 20:28:16.321057	75.26	33.94	64.46	t	f	t
5233	3	2026-03-02 20:30:36.407169	72.75	67.38	67.31	t	t	t
5306	4	2026-03-02 20:33:36.549757	26.23	22.85	38.56	t	t	t
5309	3	2026-03-02 20:33:46.522233	66.26	34.02	34.99	t	t	t
5313	4	2026-03-02 20:33:56.519685	61.47	78.94	42.16	t	f	t
5374	5	2026-03-02 20:36:26.700213	42.01	72.11	52.71	t	t	t
5376	3	2026-03-02 20:36:36.663098	41.95	46.62	52.76	t	f	t
5453	4	2026-03-02 20:39:46.881556	25.10	66.97	62.05	t	t	t
5457	4	2026-03-02 20:39:56.86011	54.13	34.81	52.62	t	t	t
5522	4	2026-03-02 20:42:37.045719	68.81	52.64	26.94	t	t	t
5524	3	2026-03-02 20:42:47.015539	18.26	39.91	28.49	t	t	t
5583	5	2026-03-02 20:45:07.18584	30.85	63.15	31.49	t	t	f
5645	4	2026-03-02 20:47:47.296313	76.87	38.28	51.45	t	t	f
5650	4	2026-03-02 20:47:57.262389	56.98	19.87	22.88	t	t	t
5652	2	2026-03-02 20:48:07.27016	27.09	64.73	41.83	t	t	t
5713	3	2026-03-02 20:50:37.400301	25.87	47.06	63.85	t	f	t
5717	4	2026-03-02 20:50:47.369831	13.42	25.23	44.79	t	t	t
5722	3	2026-03-02 20:50:57.372835	30.62	32.91	51.24	t	t	t
5770	4	2026-03-02 20:52:57.531761	40.07	13.48	40.52	t	t	t
5773	4	2026-03-02 20:53:07.50857	29.16	79.41	67.18	t	t	t
5835	5	2026-03-02 20:55:37.672799	44.67	33.15	55.80	t	t	t
5836	2	2026-03-02 20:55:47.628176	49.08	35.08	29.68	t	t	f
5907	5	2026-03-02 20:58:37.783073	57.29	66.49	47.85	t	t	t
5908	2	2026-03-02 20:58:47.771098	75.61	62.30	24.41	t	t	t
5954	4	2026-03-02 21:00:37.897201	60.05	30.15	42.79	t	t	t
5957	3	2026-03-02 21:00:47.863907	71.40	49.36	63.93	t	t	t
5961	4	2026-03-02 21:00:57.866414	35.22	78.45	46.09	t	f	t
5967	4	2026-03-02 21:01:07.86927	16.40	19.79	52.01	t	t	t
5968	2	2026-03-02 21:01:17.870535	15.30	48.92	24.65	t	t	t
5975	5	2026-03-02 21:01:27.872267	71.19	15.81	32.98	t	f	t
6027	5	2026-03-02 21:03:37.998916	34.03	77.16	20.48	t	t	t
6028	2	2026-03-02 21:03:47.97909	35.52	19.48	66.60	t	t	t
6071	3	2026-03-02 21:05:28.208081	29.82	67.78	20.69	t	t	t
6123	5	2026-03-02 21:07:38.180611	39.21	72.74	51.44	t	f	f
6125	2	2026-03-02 21:07:48.152817	29.70	57.77	46.97	t	t	t
6177	3	2026-03-02 21:09:58.307229	70.66	24.10	35.18	f	t	t
6181	4	2026-03-02 21:10:08.278466	62.86	33.51	53.10	t	t	t
6223	5	2026-03-02 21:11:48.392828	42.36	76.94	33.94	t	t	t
6224	2	2026-03-02 21:11:58.357445	66.02	79.43	58.25	f	t	t
6285	3	2026-03-02 21:14:28.523544	57.52	75.28	65.49	t	t	t
6289	4	2026-03-02 21:14:38.459619	77.71	38.98	57.67	t	t	t
6334	4	2026-03-02 21:16:28.5916	14.83	79.85	55.97	t	t	f
6337	3	2026-03-02 21:16:38.562916	18.13	71.65	64.21	t	t	t
6379	4	2026-03-02 21:18:18.772235	42.05	33.67	47.01	t	t	t
6382	2	2026-03-02 21:18:28.633614	27.10	18.71	37.65	t	t	t
6426	4	2026-03-02 21:20:18.74406	37.77	13.69	35.64	t	t	t
6428	3	2026-03-02 21:20:28.714104	52.35	53.19	29.80	t	t	t
6434	5	2026-03-02 21:20:38.715104	74.24	56.94	33.92	t	t	f
6436	2	2026-03-02 21:20:48.722499	47.95	37.71	67.88	t	t	t
6441	5	2026-03-02 21:20:58.723253	70.62	57.81	41.39	t	t	f
6447	4	2026-03-02 21:21:08.72503	31.10	61.05	46.08	t	t	t
6448	2	2026-03-02 21:21:18.733967	24.32	55.72	66.36	t	t	t
6455	5	2026-03-02 21:21:28.73897	63.86	61.79	22.59	t	t	t
6456	2	2026-03-02 21:21:38.739665	22.51	60.77	67.32	t	f	t
6463	5	2026-03-02 21:21:48.737535	25.64	30.60	59.94	t	t	t
6464	2	2026-03-02 21:21:58.744603	70.47	19.68	46.51	t	t	t
6485	3	2026-03-02 21:22:48.802633	47.50	34.02	57.16	t	t	t
6490	4	2026-03-02 21:22:58.778389	50.27	44.83	42.48	t	t	t
6535	5	2026-03-02 21:24:48.885084	21.39	50.32	45.19	f	t	t
6536	3	2026-03-02 21:24:58.843075	43.27	24.97	24.65	t	t	t
6570	4	2026-03-02 21:26:18.951374	34.10	23.57	44.51	t	t	t
6573	2	2026-03-02 21:26:28.933754	20.98	61.82	47.00	t	f	t
6607	5	2026-03-02 21:27:49.055507	17.28	18.51	22.09	f	t	t
6608	2	2026-03-02 21:27:59.009289	57.66	34.36	38.86	t	t	t
6659	5	2026-03-02 21:29:59.147079	76.46	39.21	27.14	t	t	t
6660	2	2026-03-02 21:30:09.102794	50.34	59.45	54.25	t	t	t
6697	3	2026-03-02 21:31:39.197319	64.04	76.27	23.70	t	t	f
6703	4	2026-03-02 21:31:49.168844	74.10	41.67	48.31	t	t	t
6705	5	2026-03-02 21:31:59.166528	31.33	56.72	30.68	t	t	t
6727	5	2026-03-02 21:32:49.279065	25.92	59.79	21.89	t	f	t
6729	2	2026-03-02 21:32:59.25899	71.01	61.06	48.89	t	t	f
6734	5	2026-03-02 21:33:09.261841	60.42	44.13	20.06	t	t	t
6765	3	2026-03-02 21:34:29.370116	76.66	42.85	50.23	t	t	t
6770	4	2026-03-02 21:34:39.337694	62.01	30.38	38.48	t	t	t
6774	4	2026-03-02 21:34:49.340761	62.17	76.07	47.52	t	t	t
6776	3	2026-03-02 21:34:59.340569	27.13	19.62	24.47	t	t	t
6795	5	2026-03-02 21:35:39.417432	48.41	42.44	36.74	t	t	t
6796	2	2026-03-02 21:35:49.390365	49.25	48.19	58.99	t	t	t
6809	3	2026-03-02 21:36:19.450094	18.93	14.90	54.11	t	t	f
6814	4	2026-03-02 21:36:29.418999	31.60	46.75	20.90	t	t	t
6818	4	2026-03-02 21:36:39.417457	79.77	73.16	45.02	t	t	t
6820	2	2026-03-02 21:36:49.434786	58.63	61.64	29.04	t	t	t
6825	5	2026-03-02 21:36:59.431301	20.02	14.01	66.51	t	t	t
6829	3	2026-03-02 21:37:09.491773	10.16	58.92	40.14	t	t	t
6834	4	2026-03-02 21:37:19.466747	17.07	75.19	33.85	t	t	t
6836	2	2026-03-02 21:37:29.482486	48.56	24.65	50.71	t	t	t
6837	4	2026-03-02 21:37:29.517831	62.68	41.56	46.44	t	t	t
6841	4	2026-03-02 21:37:39.491673	75.00	46.26	62.31	t	f	t
6843	5	2026-03-02 21:37:39.521138	47.24	35.14	61.71	t	t	t
6844	2	2026-03-02 21:37:49.506968	39.47	34.98	28.19	f	f	t
6851	5	2026-03-02 21:37:59.551476	38.65	60.95	26.17	t	t	t
6852	2	2026-03-02 21:38:09.526798	60.67	56.58	45.53	t	t	t
6972	3	2026-03-02 21:43:09.791182	68.13	77.12	60.10	t	t	t
6977	5	2026-03-02 21:43:19.794544	24.98	15.41	60.14	t	f	t
6982	4	2026-03-02 21:43:29.85083	48.95	26.23	63.33	t	t	t
6986	3	2026-03-02 21:43:39.824562	79.51	78.07	23.57	t	t	t
6989	3	2026-03-02 21:43:49.831547	21.88	32.06	65.62	t	t	t
6995	5	2026-03-02 21:43:59.99968	76.66	10.01	48.74	t	f	t
6996	2	2026-03-02 21:44:09.855817	53.92	27.38	34.78	t	t	t
7006	4	2026-03-02 21:44:29.918659	38.51	56.47	66.15	t	t	t
7011	3	2026-03-02 21:44:39.887392	10.26	12.38	69.65	t	f	t
7021	3	2026-03-02 21:45:09.945534	18.33	19.23	20.87	t	t	t
7027	4	2026-03-02 21:45:19.916569	12.44	57.02	63.38	t	t	f
7028	2	2026-03-02 21:45:29.928653	50.08	46.89	49.07	t	t	t
7031	3	2026-03-02 21:45:30.074502	63.71	46.44	22.72	f	t	t
7032	2	2026-03-02 21:45:39.936487	77.64	74.95	43.96	t	t	t
7033	5	2026-03-02 21:45:39.93673	20.98	25.16	52.28	t	t	t
7049	3	2026-03-02 21:46:20.010082	39.15	31.68	62.07	t	f	t
7055	5	2026-03-02 21:46:29.977311	75.48	25.71	22.91	t	t	t
7059	5	2026-03-02 21:46:40.028807	77.25	62.32	31.58	t	t	t
7060	2	2026-03-02 21:46:50.019307	78.35	71.97	27.40	t	f	t
7071	5	2026-03-02 21:47:10.068406	39.22	39.79	53.98	t	t	t
7072	2	2026-03-02 21:47:20.038842	31.71	29.12	30.31	t	f	t
7083	5	2026-03-02 21:47:40.101324	79.63	50.91	54.64	t	t	t
7087	2	2026-03-02 21:47:50.07468	33.34	75.80	43.09	t	t	f
7088	2	2026-03-02 21:48:00.088478	48.08	58.92	25.71	t	t	f
7101	3	2026-03-02 21:48:30.153292	25.69	42.98	40.42	t	t	t
7107	4	2026-03-02 21:48:40.126047	32.97	74.43	23.74	t	t	t
7114	4	2026-03-02 21:49:00.184092	15.56	57.40	40.38	t	t	t
7117	4	2026-03-02 21:49:10.179092	50.41	67.08	37.08	t	t	t
7121	4	2026-03-02 21:49:20.184054	48.53	31.97	38.78	t	t	t
7126	3	2026-03-02 21:49:30.336643	47.47	22.86	59.87	t	t	t
7130	3	2026-03-02 21:49:40.197771	33.02	57.82	35.04	t	t	f
7141	3	2026-03-02 21:50:10.260641	25.15	71.11	50.75	t	t	t
7146	4	2026-03-02 21:50:20.229334	28.78	17.39	51.69	t	t	t
7151	5	2026-03-02 21:50:30.279536	44.66	34.68	44.61	t	t	t
7152	2	2026-03-02 21:50:40.252518	62.88	24.07	37.21	t	t	f
7163	5	2026-03-02 21:51:00.305215	59.70	24.17	61.23	t	f	t
7164	2	2026-03-02 21:51:10.288053	72.72	60.48	56.74	t	t	t
7169	5	2026-03-02 21:51:20.292193	63.30	78.58	39.04	t	t	t
7174	4	2026-03-02 21:51:30.343744	19.58	17.95	48.95	t	t	t
7179	3	2026-03-02 21:51:40.310827	31.12	30.28	42.29	t	t	f
7189	3	2026-03-02 21:52:10.372876	39.29	56.96	41.62	t	f	t
7194	4	2026-03-02 21:52:20.340532	60.92	40.03	65.99	t	t	t
7199	4	2026-03-02 21:52:30.394486	55.65	65.00	35.57	t	t	t
7200	2	2026-03-02 21:52:40.368989	75.42	14.85	31.90	t	t	t
7217	3	2026-03-02 21:53:20.432767	13.01	56.28	27.49	t	f	f
7221	4	2026-03-02 21:53:30.416291	12.02	21.64	53.73	t	t	t
7226	5	2026-03-02 21:53:40.467132	40.82	77.84	30.14	t	t	t
7231	3	2026-03-02 21:53:50.432504	25.50	59.74	49.37	t	t	f
7234	3	2026-03-02 21:54:00.432152	61.44	66.06	42.67	t	t	f
7245	4	2026-03-02 21:54:30.491915	28.63	28.62	31.94	t	t	t
7249	2	2026-03-02 21:54:40.479449	20.09	34.13	64.06	t	t	f
7254	4	2026-03-02 21:54:50.482041	62.94	72.36	36.16	t	t	t
7256	3	2026-03-02 21:55:00.476456	19.00	19.43	20.98	t	t	t
7262	4	2026-03-02 21:55:10.529606	27.11	53.02	28.66	t	t	f
7266	3	2026-03-02 21:55:20.504215	77.77	39.01	57.46	t	t	t
7270	3	2026-03-02 21:55:30.511427	71.23	67.02	26.82	t	t	t
7275	5	2026-03-02 21:55:40.561788	28.99	34.90	63.54	t	t	f
7276	2	2026-03-02 21:55:50.53525	76.85	35.43	38.02	t	t	t
7281	5	2026-03-02 21:56:00.542105	33.60	11.15	53.08	t	t	t
7291	5	2026-03-02 21:56:20.599406	25.00	42.79	26.76	t	t	f
7292	2	2026-03-02 21:56:30.570841	19.99	68.87	36.15	t	t	t
7297	5	2026-03-02 21:56:40.573686	59.98	77.66	21.61	t	t	t
7318	4	2026-03-02 21:57:30.638905	13.35	27.05	54.15	t	t	t
7323	3	2026-03-02 21:57:40.605636	43.66	72.78	67.10	t	t	t
7331	5	2026-03-02 21:58:00.665186	62.99	30.63	63.58	t	t	f
7332	2	2026-03-02 21:58:10.664091	39.77	23.54	26.67	f	t	t
7337	5	2026-03-02 21:58:20.66514	42.67	24.73	63.76	f	t	t
7342	4	2026-03-02 21:58:30.715015	47.77	68.18	20.86	t	t	t
7346	3	2026-03-02 21:58:40.6895	24.55	51.92	67.97	t	t	t
7351	5	2026-03-02 21:58:50.73665	52.12	15.34	39.08	t	t	t
7352	2	2026-03-02 21:59:00.712984	59.44	67.13	51.06	f	t	t
7365	3	2026-03-02 21:59:30.778906	49.95	19.95	58.13	t	t	t
7371	4	2026-03-02 21:59:40.745947	14.54	15.75	32.79	t	t	f
7375	5	2026-03-02 21:59:50.797531	51.95	14.06	41.98	t	t	t
7376	2	2026-03-02 22:00:00.76606	25.90	36.03	37.93	t	t	t
7390	5	2026-03-02 22:00:30.824159	13.92	68.02	33.65	t	t	f
7392	2	2026-03-02 22:00:40.805329	48.52	53.79	50.98	t	t	t
7402	4	2026-03-02 22:01:00.866379	36.45	46.37	63.56	t	t	t
7406	2	2026-03-02 22:01:10.842243	15.89	49.71	22.16	t	t	f
7416	2	2026-03-02 22:01:40.857538	68.44	52.81	20.21	t	t	t
7427	5	2026-03-02 22:02:00.915594	29.60	23.52	42.75	t	t	t
7428	2	2026-03-02 22:02:10.888577	56.58	27.70	55.75	t	t	t
7439	5	2026-03-02 22:02:30.948364	43.38	34.01	28.04	t	t	t
7440	2	2026-03-02 22:02:40.917042	60.44	36.03	65.05	t	t	t
7445	5	2026-03-02 22:02:50.917207	77.11	65.02	27.19	t	f	t
7455	5	2026-03-02 22:03:10.979735	58.57	36.11	46.97	t	t	t
7456	2	2026-03-02 22:03:20.957572	43.86	55.09	39.04	t	f	t
7463	5	2026-03-02 22:03:30.993289	40.28	63.13	27.62	f	t	t
7464	2	2026-03-02 22:03:40.96925	37.39	25.82	65.53	t	t	t
7470	3	2026-03-02 22:03:51.137824	39.56	46.75	27.33	t	t	t
7472	3	2026-03-02 22:04:00.99487	53.72	41.05	27.80	t	t	t
7477	5	2026-03-02 22:04:10.994102	10.80	41.81	31.85	t	t	t
7480	2	2026-03-02 22:04:21.007357	14.67	15.56	45.30	t	f	t
7481	3	2026-03-02 22:04:21.039076	52.97	18.11	59.30	t	t	t
7482	4	2026-03-02 22:04:21.039351	49.85	67.71	62.95	t	t	f
7483	5	2026-03-02 22:04:21.155796	45.01	24.35	21.14	t	t	t
7484	3	2026-03-02 22:04:31.026105	68.52	73.79	69.00	t	t	t
7485	2	2026-03-02 22:04:31.026666	64.92	52.16	52.43	t	f	f
7486	4	2026-03-02 22:04:31.027018	72.09	53.23	47.10	t	t	t
7487	5	2026-03-02 22:04:31.057386	79.34	72.40	56.35	t	t	t
7488	2	2026-03-02 22:04:41.024366	24.30	69.72	26.90	f	t	t
7489	5	2026-03-02 22:04:41.024698	52.50	14.24	68.25	t	t	t
7490	4	2026-03-02 22:04:41.024897	72.93	25.53	48.66	t	t	t
7491	3	2026-03-02 22:04:41.025246	71.50	25.05	54.92	t	t	t
7492	2	2026-03-02 22:04:51.027437	47.98	74.78	46.15	t	t	f
6853	5	2026-03-02 21:38:09.52702	18.27	73.17	56.12	f	t	t
6973	4	2026-03-02 21:43:09.791424	67.20	48.73	42.86	t	t	t
6976	3	2026-03-02 21:43:19.794365	25.33	69.50	21.79	t	t	f
6983	5	2026-03-02 21:43:29.851283	52.75	79.70	30.71	t	t	t
6984	2	2026-03-02 21:43:39.824196	72.13	72.70	48.93	t	t	t
6998	5	2026-03-02 21:44:09.888814	49.81	62.83	53.52	t	t	t
7001	3	2026-03-02 21:44:19.872078	10.84	22.46	37.43	t	t	t
7007	5	2026-03-02 21:44:29.919091	22.75	44.73	52.80	t	t	t
7008	2	2026-03-02 21:44:39.886604	18.34	55.93	42.90	t	t	f
7022	5	2026-03-02 21:45:09.947948	38.55	63.29	51.57	t	t	t
7026	3	2026-03-02 21:45:19.916329	37.94	16.09	47.91	t	t	t
7037	3	2026-03-02 21:45:49.982107	37.33	23.09	21.19	t	t	t
7041	5	2026-03-02 21:45:59.961851	62.84	13.69	47.39	t	t	t
7047	4	2026-03-02 21:46:09.967286	50.12	59.08	56.52	t	t	t
7048	2	2026-03-02 21:46:19.976198	56.85	21.88	43.79	t	t	t
7050	4	2026-03-02 21:46:20.015481	46.71	53.85	40.82	t	t	t
7052	3	2026-03-02 21:46:29.976531	40.82	28.88	59.95	t	t	t
7054	4	2026-03-02 21:46:29.977009	21.81	15.28	35.30	t	t	t
7056	2	2026-03-02 21:46:39.991492	42.94	73.08	31.38	t	f	t
7063	5	2026-03-02 21:46:50.050987	24.36	35.19	56.65	t	t	t
7065	2	2026-03-02 21:47:00.024981	60.90	16.40	64.59	t	t	f
7075	5	2026-03-02 21:47:20.070401	65.72	35.52	68.96	f	t	t
7076	2	2026-03-02 21:47:30.056093	41.45	76.95	39.08	t	t	f
7089	3	2026-03-02 21:48:00.119483	29.95	37.70	40.20	t	t	f
7093	4	2026-03-02 21:48:10.09956	47.36	27.82	46.29	t	t	t
7099	4	2026-03-02 21:48:20.106288	14.78	47.06	50.77	t	t	t
7102	4	2026-03-02 21:48:30.156093	11.01	68.29	49.37	t	f	t
7104	3	2026-03-02 21:48:40.125247	40.40	60.02	28.73	t	t	t
7115	5	2026-03-02 21:49:00.309181	32.80	62.75	30.40	t	f	t
7116	2	2026-03-02 21:49:10.178841	11.10	74.37	60.40	t	t	t
7120	5	2026-03-02 21:49:20.184036	60.09	76.28	57.09	t	t	t
7127	5	2026-03-02 21:49:30.345934	19.29	30.16	32.14	t	t	t
7128	2	2026-03-02 21:49:40.197336	47.59	43.04	51.62	t	f	t
7142	4	2026-03-02 21:50:10.266234	59.91	76.69	37.14	t	t	t
7147	3	2026-03-02 21:50:20.229278	12.64	21.73	48.45	t	t	t
7148	2	2026-03-02 21:50:30.238931	53.91	23.29	51.18	t	t	t
7155	5	2026-03-02 21:50:40.28152	21.38	78.10	34.67	t	t	t
7156	2	2026-03-02 21:50:50.262508	28.40	40.68	26.09	t	t	t
7165	3	2026-03-02 21:51:10.320502	31.38	32.10	53.61	t	t	f
7171	4	2026-03-02 21:51:20.292897	40.80	10.48	37.18	t	t	t
7172	2	2026-03-02 21:51:30.307178	61.89	58.49	40.00	t	t	t
7175	5	2026-03-02 21:51:30.34406	12.63	67.13	56.00	t	t	t
7176	2	2026-03-02 21:51:40.31017	45.46	22.86	51.86	t	t	f
7177	5	2026-03-02 21:51:40.310381	53.46	39.28	42.14	t	t	t
7180	2	2026-03-02 21:51:50.322756	40.26	75.83	47.96	t	t	t
7185	5	2026-03-02 21:52:00.324408	63.90	79.50	33.99	f	t	f
7190	5	2026-03-02 21:52:10.37715	77.02	10.05	57.01	t	t	t
7192	3	2026-03-02 21:52:20.340232	15.34	75.88	38.04	t	t	t
7203	5	2026-03-02 21:52:40.401361	75.53	57.43	52.74	t	t	t
7204	2	2026-03-02 21:52:50.384941	30.01	61.66	57.41	t	t	t
7209	5	2026-03-02 21:53:00.383021	21.64	37.40	23.53	t	t	f
7212	3	2026-03-02 21:53:10.383996	35.61	63.04	50.62	t	t	t
7218	4	2026-03-02 21:53:20.438237	36.73	50.08	43.07	t	t	t
7222	3	2026-03-02 21:53:30.416467	47.11	49.36	57.22	t	t	t
7227	4	2026-03-02 21:53:40.468322	30.26	69.40	55.00	t	f	f
7228	2	2026-03-02 21:53:50.431758	75.53	13.83	67.52	t	t	t
7233	5	2026-03-02 21:54:00.431985	11.23	30.98	29.33	t	t	t
7246	3	2026-03-02 21:54:30.497239	61.23	56.55	24.05	t	t	f
7250	4	2026-03-02 21:54:40.479638	50.96	37.60	46.10	t	t	t
7255	2	2026-03-02 21:54:50.482353	16.23	22.46	38.57	t	t	t
7258	2	2026-03-02 21:55:00.476984	34.78	42.50	41.12	t	t	t
7260	2	2026-03-02 21:55:10.492302	77.19	58.86	66.28	t	t	f
7263	5	2026-03-02 21:55:10.530527	57.44	59.69	49.59	t	t	t
7265	2	2026-03-02 21:55:20.503901	32.43	73.99	62.93	t	t	t
7271	4	2026-03-02 21:55:30.511729	26.89	27.49	64.99	t	t	f
7272	2	2026-03-02 21:55:40.525051	21.50	35.57	48.67	t	t	f
7279	5	2026-03-02 21:55:50.564733	35.78	67.79	50.23	t	t	t
7280	2	2026-03-02 21:56:00.541812	74.59	70.95	67.96	t	t	t
7301	5	2026-03-02 21:56:50.620478	49.38	55.27	41.32	t	f	t
7307	3	2026-03-02 21:57:00.586821	77.66	57.96	22.19	t	t	t
7311	3	2026-03-02 21:57:10.591457	30.58	53.43	27.63	t	t	t
7315	2	2026-03-02 21:57:20.589518	29.31	54.05	56.97	t	f	f
7319	5	2026-03-02 21:57:30.641542	18.66	36.75	27.72	t	t	t
7320	2	2026-03-02 21:57:40.60481	77.65	67.30	68.88	t	t	t
7333	3	2026-03-02 21:58:10.694467	70.16	58.68	66.31	t	t	f
7339	4	2026-03-02 21:58:20.665628	76.29	21.95	40.69	t	t	t
7343	3	2026-03-02 21:58:30.82671	50.58	50.35	30.45	t	t	t
7344	2	2026-03-02 21:58:40.688704	35.28	70.20	49.27	t	t	t
7355	5	2026-03-02 21:59:00.743443	72.53	59.32	46.10	f	t	t
7356	2	2026-03-02 21:59:10.726	63.13	35.46	29.50	t	t	t
7362	5	2026-03-02 21:59:20.730853	28.80	20.66	61.87	t	t	t
7366	4	2026-03-02 21:59:30.781389	47.10	55.08	45.07	t	t	t
7369	3	2026-03-02 21:59:40.745529	58.77	48.29	51.96	t	t	f
7381	4	2026-03-02 22:00:10.807814	21.06	37.10	39.68	t	t	t
7387	4	2026-03-02 22:00:20.783294	46.84	71.95	41.54	t	t	t
7394	5	2026-03-02 22:00:40.836296	34.87	52.23	30.48	t	t	t
7397	5	2026-03-02 22:00:50.820308	45.68	44.62	28.76	t	t	t
7403	5	2026-03-02 22:01:00.868023	24.51	75.23	20.61	t	f	t
7404	3	2026-03-02 22:01:10.841684	18.88	71.13	58.20	t	t	t
7421	3	2026-03-02 22:01:50.903693	64.46	22.77	43.93	t	t	t
7425	4	2026-03-02 22:02:00.887084	19.09	32.08	28.38	t	t	f
7431	4	2026-03-02 22:02:10.889302	20.56	24.94	44.86	t	t	t
7432	3	2026-03-02 22:02:20.900795	30.42	45.68	54.23	t	t	f
7433	2	2026-03-02 22:02:20.931088	75.44	45.21	21.33	t	t	t
7437	4	2026-03-02 22:02:30.916241	17.79	39.95	37.27	t	t	t
7442	4	2026-03-02 22:02:40.917543	68.90	52.18	28.19	t	f	t
7446	3	2026-03-02 22:02:50.917382	58.82	46.40	48.81	t	t	t
7449	3	2026-03-02 22:03:00.96111	31.55	51.37	35.69	f	t	t
7454	4	2026-03-02 22:03:10.948799	48.00	57.60	60.52	t	t	t
7457	3	2026-03-02 22:03:20.988885	43.15	15.24	40.43	t	t	t
7462	4	2026-03-02 22:03:30.965178	48.73	54.31	50.92	t	t	t
7465	4	2026-03-02 22:03:40.969452	39.55	28.66	25.70	t	t	t
7466	3	2026-03-02 22:03:40.969686	67.88	62.10	31.43	t	t	f
7468	2	2026-03-02 22:03:50.978832	48.50	10.77	28.85	t	t	t
7471	4	2026-03-02 22:03:51.138247	38.15	72.46	65.69	t	t	t
7474	2	2026-03-02 22:04:00.995488	58.82	55.16	52.06	t	t	t
7478	4	2026-03-02 22:04:10.994265	66.59	57.95	66.91	t	t	t
6854	4	2026-03-02 21:38:09.527171	11.80	75.92	58.44	t	t	f
6974	5	2026-03-02 21:43:09.791656	28.19	43.81	65.84	t	t	t
6978	2	2026-03-02 21:43:19.794888	42.87	57.20	38.58	f	t	t
6987	5	2026-03-02 21:43:39.854505	49.25	52.61	46.76	t	t	t
6988	2	2026-03-02 21:43:49.831211	75.40	70.90	32.69	t	t	t
6999	4	2026-03-02 21:44:09.889049	63.91	12.32	29.69	t	t	t
7000	2	2026-03-02 21:44:19.871738	55.91	72.59	50.22	t	t	t
7013	3	2026-03-02 21:44:49.934579	13.51	26.59	45.39	t	t	t
7019	4	2026-03-02 21:44:59.903243	14.69	20.43	34.06	t	t	t
7020	2	2026-03-02 21:45:09.915505	48.62	69.84	68.59	t	t	t
7023	4	2026-03-02 21:45:10.059839	15.46	28.43	28.10	t	t	t
7024	2	2026-03-02 21:45:19.915844	24.11	50.33	63.76	f	f	t
7025	5	2026-03-02 21:45:19.916066	30.65	36.61	38.75	t	t	t
7038	5	2026-03-02 21:45:49.982452	71.36	19.06	32.08	t	t	t
7042	4	2026-03-02 21:45:59.962116	15.08	79.61	36.34	t	t	t
7046	3	2026-03-02 21:46:09.966983	42.80	59.26	23.87	t	t	t
7051	5	2026-03-02 21:46:20.015805	50.64	63.28	58.15	t	t	t
7053	2	2026-03-02 21:46:29.976817	53.97	26.33	58.54	t	t	t
7066	4	2026-03-02 21:47:00.054459	15.05	42.46	26.31	t	t	t
7069	4	2026-03-02 21:47:10.034671	48.59	78.48	27.18	t	t	t
7074	4	2026-03-02 21:47:20.040207	35.22	59.39	33.84	t	t	t
7077	3	2026-03-02 21:47:30.086915	39.84	36.49	54.26	t	t	t
7081	4	2026-03-02 21:47:40.070858	39.84	78.60	59.99	f	t	f
7086	4	2026-03-02 21:47:50.074508	63.22	73.29	68.32	t	t	f
7090	4	2026-03-02 21:48:00.120579	58.49	14.47	65.34	t	t	f
7094	3	2026-03-02 21:48:10.099906	24.62	67.49	38.86	t	f	t
7098	3	2026-03-02 21:48:20.10596	65.22	37.48	35.85	t	f	t
7100	2	2026-03-02 21:48:30.121268	51.04	56.11	58.48	t	t	t
7103	5	2026-03-02 21:48:30.157155	15.23	10.27	30.25	t	t	t
7105	5	2026-03-02 21:48:40.125537	52.46	64.34	60.10	t	t	t
7106	2	2026-03-02 21:48:40.125739	33.57	68.04	40.97	t	t	t
7108	2	2026-03-02 21:48:50.135362	54.74	77.96	37.94	t	t	t
7109	3	2026-03-02 21:48:50.135615	27.65	45.02	58.34	t	t	t
7118	3	2026-03-02 21:49:10.212244	21.12	71.63	33.63	t	t	t
7123	3	2026-03-02 21:49:20.184269	65.46	35.27	50.20	f	t	t
7133	3	2026-03-02 21:49:50.245167	72.96	18.36	33.85	t	t	t
7138	4	2026-03-02 21:50:00.217127	70.97	23.13	48.08	t	t	t
7143	5	2026-03-02 21:50:10.267034	12.50	64.30	31.51	t	t	t
7144	2	2026-03-02 21:50:20.228899	59.33	53.46	68.64	t	t	t
7157	3	2026-03-02 21:50:50.291684	58.00	57.49	30.86	t	t	t
7161	4	2026-03-02 21:51:00.275382	71.07	50.41	45.27	t	t	t
7166	5	2026-03-02 21:51:10.325952	75.94	46.82	27.48	t	t	t
7168	3	2026-03-02 21:51:20.291722	59.23	61.27	20.48	t	f	t
7181	3	2026-03-02 21:51:50.353143	27.21	14.61	27.99	t	t	t
7187	4	2026-03-02 21:52:00.324881	40.55	40.60	50.54	t	t	t
7188	2	2026-03-02 21:52:10.339892	37.31	15.65	49.20	t	t	f
7191	4	2026-03-02 21:52:10.377417	77.12	52.78	49.12	t	t	t
7193	5	2026-03-02 21:52:20.340319	58.89	11.91	67.45	t	t	t
7195	2	2026-03-02 21:52:20.340668	50.92	28.47	56.01	t	t	t
7196	2	2026-03-02 21:52:30.355992	75.97	30.25	30.08	t	t	t
7205	3	2026-03-02 21:52:50.416263	29.95	30.18	61.59	t	t	t
7210	4	2026-03-02 21:53:00.383269	41.74	68.58	45.42	t	t	t
7214	4	2026-03-02 21:53:10.38448	22.61	37.17	43.52	t	t	t
7219	5	2026-03-02 21:53:20.43851	43.80	29.75	50.73	t	f	f
7220	2	2026-03-02 21:53:30.415933	63.20	77.91	66.10	t	t	t
7237	3	2026-03-02 21:54:10.480944	51.57	62.83	25.79	t	t	t
7242	4	2026-03-02 21:54:20.447981	37.12	34.54	28.11	t	t	t
7247	5	2026-03-02 21:54:30.498171	64.71	36.60	34.03	t	t	t
7248	3	2026-03-02 21:54:40.478972	70.25	62.45	49.64	t	t	t
7253	5	2026-03-02 21:54:50.481741	14.80	37.34	39.44	t	f	t
7259	4	2026-03-02 21:55:00.477174	53.40	16.46	68.87	t	t	t
7267	5	2026-03-02 21:55:20.536302	15.15	22.60	49.12	t	t	t
7268	2	2026-03-02 21:55:30.510882	71.81	33.36	39.23	t	t	t
7285	3	2026-03-02 21:56:10.587348	29.73	58.73	52.16	t	t	t
7289	4	2026-03-02 21:56:20.568492	32.45	58.80	58.87	t	t	t
7294	4	2026-03-02 21:56:30.571146	44.08	49.39	37.03	t	t	t
7299	4	2026-03-02 21:56:40.574208	46.49	41.41	33.84	t	t	t
7300	2	2026-03-02 21:56:50.588712	57.77	48.06	49.50	t	t	f
7302	4	2026-03-02 21:56:50.621255	30.17	55.09	61.08	t	t	t
7305	5	2026-03-02 21:57:00.586639	42.14	73.58	65.33	t	t	t
7306	4	2026-03-02 21:57:00.586707	56.61	53.89	56.16	t	t	f
7309	4	2026-03-02 21:57:10.590926	19.58	44.12	48.11	t	t	t
7310	5	2026-03-02 21:57:10.5911	25.73	26.44	60.73	t	t	t
7312	3	2026-03-02 21:57:20.5886	62.90	19.70	63.52	t	t	t
7313	4	2026-03-02 21:57:20.588986	26.44	66.46	28.48	t	f	t
7325	3	2026-03-02 21:57:50.655324	65.62	63.48	69.36	t	t	t
7330	4	2026-03-02 21:58:00.634484	78.81	18.38	60.33	t	t	t
7334	4	2026-03-02 21:58:10.699586	75.92	42.70	45.46	t	t	t
7338	3	2026-03-02 21:58:20.665331	17.78	67.33	29.92	t	t	t
7340	2	2026-03-02 21:58:30.681069	64.19	62.49	58.01	t	t	f
7347	5	2026-03-02 21:58:40.719849	15.68	37.76	52.44	t	t	t
7348	2	2026-03-02 21:58:50.698679	70.04	59.46	54.19	t	t	t
7357	3	2026-03-02 21:59:10.763772	15.69	35.22	46.53	t	t	t
7361	4	2026-03-02 21:59:20.73069	49.41	56.18	27.80	t	t	t
7367	5	2026-03-02 21:59:30.781577	47.10	17.95	46.50	t	t	t
7368	2	2026-03-02 21:59:40.744815	67.13	20.62	66.69	t	t	f
7382	3	2026-03-02 22:00:10.810673	30.46	28.71	34.55	t	t	f
7386	2	2026-03-02 22:00:20.783014	20.07	67.26	68.78	t	t	t
7388	2	2026-03-02 22:00:30.794153	46.16	71.99	28.61	t	t	t
7395	4	2026-03-02 22:00:40.836612	64.47	22.20	50.41	f	t	f
7396	4	2026-03-02 22:00:50.820218	16.01	41.82	56.71	t	t	t
7409	4	2026-03-02 22:01:20.886664	19.03	76.86	30.21	t	t	t
7415	4	2026-03-02 22:01:30.856506	69.13	61.87	56.77	f	t	t
7418	3	2026-03-02 22:01:40.857962	37.34	67.36	29.50	t	t	t
7420	2	2026-03-02 22:01:50.870547	75.07	62.19	50.16	t	t	f
7422	4	2026-03-02 22:01:50.904897	51.90	48.75	33.99	t	t	t
7426	3	2026-03-02 22:02:00.887264	61.23	39.00	52.34	t	t	t
7430	3	2026-03-02 22:02:10.888955	51.69	24.12	54.56	t	t	f
7434	4	2026-03-02 22:02:20.935646	39.69	64.25	24.24	t	t	t
7438	3	2026-03-02 22:02:30.916392	76.94	62.65	38.29	t	f	t
7443	3	2026-03-02 22:02:40.917719	29.85	71.33	22.35	t	f	t
7447	4	2026-03-02 22:02:50.917673	44.03	52.15	34.30	t	f	t
7448	2	2026-03-02 22:03:00.931969	61.86	40.69	46.11	t	t	t
7450	4	2026-03-02 22:03:00.965384	66.84	18.41	44.90	t	t	t
7453	3	2026-03-02 22:03:10.94828	11.33	40.51	24.58	t	t	t
7458	5	2026-03-02 22:03:20.993626	35.38	38.26	63.38	t	t	t
7461	3	2026-03-02 22:03:30.965009	41.92	69.32	23.84	t	t	f
6964	2	2026-03-02 21:42:49.773687	17.11	16.11	32.06	t	t	t
6965	5	2026-03-02 21:42:49.774023	64.49	17.75	51.95	t	t	t
6966	4	2026-03-02 21:42:49.774111	12.88	68.38	57.56	t	t	t
6967	3	2026-03-02 21:42:49.774318	70.02	46.52	53.33	t	t	t
6968	3	2026-03-02 21:42:59.786398	20.84	41.72	42.48	t	t	t
6969	4	2026-03-02 21:42:59.816239	37.65	49.40	31.16	t	t	t
6970	2	2026-03-02 21:42:59.8224	78.98	58.53	51.97	t	t	t
6971	5	2026-03-02 21:42:59.822863	37.17	65.23	24.07	t	t	t
6975	2	2026-03-02 21:43:09.791973	33.08	36.61	69.91	f	t	t
6979	4	2026-03-02 21:43:19.795064	56.47	29.00	27.64	t	t	t
6980	2	2026-03-02 21:43:29.815385	57.37	14.74	62.71	t	t	t
6991	5	2026-03-02 21:43:49.862055	64.65	42.50	29.59	t	t	t
6992	2	2026-03-02 21:43:59.840344	17.29	78.97	31.76	t	t	f
7002	4	2026-03-02 21:44:19.904344	59.73	30.72	65.00	t	t	t
7004	3	2026-03-02 21:44:29.885933	45.83	77.04	36.88	t	f	t
7009	5	2026-03-02 21:44:39.887018	42.04	68.19	34.11	t	f	t
7014	5	2026-03-02 21:44:49.936571	70.07	21.67	63.25	t	f	t
7018	3	2026-03-02 21:44:59.902925	53.94	24.20	65.95	t	t	t
7029	4	2026-03-02 21:45:29.964587	28.23	23.98	59.12	t	t	f
7034	3	2026-03-02 21:45:39.936895	79.24	52.94	58.92	t	t	t
7036	2	2026-03-02 21:45:49.949047	61.97	79.82	61.06	t	t	t
7039	4	2026-03-02 21:45:50.09096	60.57	21.52	50.81	f	f	t
7040	3	2026-03-02 21:45:59.961621	31.46	55.30	39.77	t	t	t
7045	5	2026-03-02 21:46:09.966705	77.83	64.08	64.15	t	t	t
7057	3	2026-03-02 21:46:40.028026	14.73	55.28	51.25	t	t	f
7062	4	2026-03-02 21:46:50.019764	53.14	27.85	59.36	t	t	t
7064	3	2026-03-02 21:47:00.024786	75.07	10.62	48.36	t	t	f
7067	5	2026-03-02 21:47:00.055927	44.20	11.51	31.26	t	t	t
7068	2	2026-03-02 21:47:10.034121	43.49	75.91	52.55	t	t	f
7078	4	2026-03-02 21:47:30.088736	39.39	30.21	43.04	t	t	t
7080	3	2026-03-02 21:47:40.070707	25.33	36.43	60.00	t	t	t
7085	5	2026-03-02 21:47:50.07422	14.37	73.01	34.63	t	t	t
7091	5	2026-03-02 21:48:00.123305	11.38	25.45	38.29	t	t	t
7092	2	2026-03-02 21:48:10.099081	46.23	53.15	20.34	t	t	t
7097	5	2026-03-02 21:48:20.105667	35.28	23.18	27.53	t	t	t
7110	5	2026-03-02 21:48:50.165639	74.02	22.79	30.61	f	t	t
7113	3	2026-03-02 21:49:00.152944	17.20	66.01	23.50	t	t	t
7119	5	2026-03-02 21:49:10.214411	10.78	32.91	67.46	t	f	t
7122	2	2026-03-02 21:49:20.184036	51.77	62.91	63.37	t	t	t
7124	2	2026-03-02 21:49:30.197415	38.47	61.87	32.44	t	t	t
7129	5	2026-03-02 21:49:40.197599	53.72	49.69	49.63	t	t	t
7134	4	2026-03-02 21:49:50.247179	12.22	65.51	25.40	t	t	t
7139	3	2026-03-02 21:50:00.217141	48.90	47.73	35.95	t	t	t
7149	3	2026-03-02 21:50:30.274562	38.93	18.34	38.22	t	t	t
7153	4	2026-03-02 21:50:40.252754	27.34	60.53	20.66	t	t	f
7158	5	2026-03-02 21:50:50.29514	52.79	36.38	46.39	t	t	f
7160	3	2026-03-02 21:51:00.275033	76.80	49.55	42.12	t	f	t
7167	4	2026-03-02 21:51:10.326147	19.39	48.58	62.43	t	t	t
7170	2	2026-03-02 21:51:20.292757	46.54	66.92	41.91	t	t	t
7182	4	2026-03-02 21:51:50.36039	51.08	16.75	54.96	t	t	t
7186	3	2026-03-02 21:52:00.324691	29.94	60.65	48.97	t	t	t
7197	3	2026-03-02 21:52:30.38941	10.29	49.33	42.82	t	t	t
7201	4	2026-03-02 21:52:40.369446	26.76	78.07	47.14	t	t	t
7206	4	2026-03-02 21:52:50.417147	43.65	19.75	60.49	t	t	t
7208	3	2026-03-02 21:53:00.382812	22.99	65.52	24.68	t	t	t
7215	5	2026-03-02 21:53:10.384858	39.43	69.85	31.32	t	t	t
7216	2	2026-03-02 21:53:20.39958	79.39	38.08	22.30	t	t	t
7223	5	2026-03-02 21:53:30.448021	40.15	50.37	32.06	t	t	t
7224	2	2026-03-02 21:53:40.430704	32.06	69.56	37.58	t	t	t
7229	5	2026-03-02 21:53:50.432041	20.76	75.33	22.73	t	t	t
7235	4	2026-03-02 21:54:00.432446	79.29	16.36	28.35	t	t	f
7236	2	2026-03-02 21:54:10.448216	37.12	13.78	60.17	t	f	t
7238	4	2026-03-02 21:54:10.485252	55.95	40.85	37.17	t	t	t
7241	5	2026-03-02 21:54:20.447811	74.82	22.17	46.65	t	t	f
7243	3	2026-03-02 21:54:20.44832	19.82	47.21	46.35	t	f	t
7244	2	2026-03-02 21:54:30.460228	26.22	41.45	31.98	t	t	t
7251	5	2026-03-02 21:54:40.510008	75.71	71.02	68.57	t	t	t
7252	3	2026-03-02 21:54:50.481438	71.39	76.38	28.50	t	f	t
7257	5	2026-03-02 21:55:00.476655	75.50	42.80	20.61	t	t	f
7273	3	2026-03-02 21:55:40.555135	61.29	32.67	51.22	t	t	t
7277	4	2026-03-02 21:55:50.535764	60.91	32.22	63.78	t	t	t
7283	3	2026-03-02 21:56:00.542592	52.45	36.46	38.67	t	t	t
7284	2	2026-03-02 21:56:10.554855	28.19	64.12	27.15	t	f	t
7286	4	2026-03-02 21:56:10.588118	56.26	75.16	41.17	t	t	t
7288	3	2026-03-02 21:56:20.568154	48.68	39.58	20.56	t	t	t
7293	5	2026-03-02 21:56:30.571012	65.98	16.01	66.50	t	t	f
7298	3	2026-03-02 21:56:40.573872	48.25	70.85	32.44	t	t	f
7303	3	2026-03-02 21:56:50.730084	14.33	23.84	44.08	t	t	t
7304	2	2026-03-02 21:57:00.586485	25.85	19.00	52.17	t	t	t
7308	2	2026-03-02 21:57:10.590521	73.65	73.29	50.27	t	t	t
7314	5	2026-03-02 21:57:20.589332	62.87	60.04	28.18	t	t	f
7316	2	2026-03-02 21:57:30.603288	71.51	31.71	51.11	t	t	t
7321	5	2026-03-02 21:57:40.60503	42.60	45.84	52.05	t	t	t
7326	4	2026-03-02 21:57:50.655664	65.92	51.22	41.66	t	f	f
7329	3	2026-03-02 21:58:00.634166	25.33	21.14	53.97	t	f	t
7335	5	2026-03-02 21:58:10.700558	31.00	69.53	60.09	t	t	t
7336	2	2026-03-02 21:58:20.66487	53.80	65.11	63.98	t	t	t
7349	3	2026-03-02 21:58:50.729605	18.39	27.22	34.02	t	t	f
7353	4	2026-03-02 21:59:00.713276	59.77	28.26	64.15	t	t	t
7358	4	2026-03-02 21:59:10.765522	71.11	73.33	62.91	t	t	t
7363	3	2026-03-02 21:59:20.731065	45.81	42.92	23.68	t	t	t
7364	2	2026-03-02 21:59:30.747649	21.06	58.76	29.04	t	t	f
7370	5	2026-03-02 21:59:40.745816	30.48	52.25	67.12	t	t	t
7372	2	2026-03-02 21:59:50.760668	45.61	41.26	20.99	t	t	t
7373	3	2026-03-02 21:59:50.797029	76.67	55.92	63.20	t	t	t
7377	5	2026-03-02 22:00:00.766284	60.56	42.80	61.04	t	f	t
7378	4	2026-03-02 22:00:00.766471	19.64	29.58	32.68	f	t	t
7380	2	2026-03-02 22:00:10.775592	18.15	43.25	62.32	t	t	t
7383	5	2026-03-02 22:00:10.811721	13.02	29.67	53.01	t	t	t
7384	3	2026-03-02 22:00:20.782638	65.83	55.71	42.76	t	t	t
7385	5	2026-03-02 22:00:20.782865	55.44	39.92	67.72	t	t	t
7389	3	2026-03-02 22:00:30.794289	13.12	62.34	23.64	t	t	t
7398	2	2026-03-02 22:00:50.850468	20.98	17.75	21.05	t	t	t
7401	3	2026-03-02 22:01:00.834387	39.63	72.21	49.21	t	t	t
7405	5	2026-03-02 22:01:10.842051	39.71	10.34	33.03	t	t	t
7410	3	2026-03-02 22:01:20.886825	55.73	35.54	30.08	t	t	t
7414	3	2026-03-02 22:01:30.85624	61.02	62.94	36.53	t	t	t
6855	3	2026-03-02 21:38:09.527495	12.32	16.93	40.71	t	f	t
6856	3	2026-03-02 21:38:19.542416	59.09	30.99	66.21	t	t	t
6981	3	2026-03-02 21:43:29.847391	42.25	10.60	55.90	t	t	t
6985	4	2026-03-02 21:43:39.824421	53.91	20.81	28.42	t	t	t
6990	4	2026-03-02 21:43:49.831802	28.00	26.88	32.69	t	t	t
6993	3	2026-03-02 21:43:59.840566	24.11	11.34	58.17	t	t	t
6994	4	2026-03-02 21:43:59.869826	73.23	12.78	61.15	t	t	t
6997	3	2026-03-02 21:44:09.855962	29.24	11.12	53.62	t	t	t
7003	5	2026-03-02 21:44:19.905831	56.24	10.25	21.43	t	t	t
7005	2	2026-03-02 21:44:29.886547	45.38	49.81	41.19	t	t	t
7010	4	2026-03-02 21:44:39.887208	73.45	26.17	32.14	t	t	f
7012	2	2026-03-02 21:44:49.902734	63.47	69.42	66.39	t	f	t
7015	4	2026-03-02 21:44:49.937031	69.05	75.87	38.59	t	t	t
7016	2	2026-03-02 21:44:59.902326	12.80	16.91	49.93	t	t	t
7017	5	2026-03-02 21:44:59.902748	45.54	19.09	51.51	t	t	t
7030	5	2026-03-02 21:45:29.964874	65.80	42.13	52.00	t	t	f
7035	4	2026-03-02 21:45:39.937203	52.93	55.82	60.76	t	t	t
7043	2	2026-03-02 21:45:59.99386	60.55	33.90	37.44	t	t	t
7044	2	2026-03-02 21:46:09.966381	52.56	32.40	35.77	t	t	t
7058	4	2026-03-02 21:46:40.028465	18.43	29.90	44.08	t	f	f
7061	3	2026-03-02 21:46:50.019597	41.53	60.86	66.97	t	t	t
7070	3	2026-03-02 21:47:10.065732	63.96	14.81	69.36	t	t	t
7073	3	2026-03-02 21:47:20.039999	36.26	23.64	33.89	t	t	t
7079	5	2026-03-02 21:47:30.214599	16.56	16.06	49.21	t	f	t
7082	2	2026-03-02 21:47:40.070951	32.90	79.18	61.49	t	t	t
7084	3	2026-03-02 21:47:50.073855	50.85	52.53	50.08	t	t	f
7095	5	2026-03-02 21:48:10.131674	14.04	69.23	64.10	t	t	f
7096	2	2026-03-02 21:48:20.105094	14.88	31.12	68.20	t	f	t
7111	4	2026-03-02 21:48:50.281137	38.74	62.30	48.89	t	t	t
7112	2	2026-03-02 21:49:00.152606	77.71	78.86	52.02	t	t	t
7125	4	2026-03-02 21:49:30.22932	69.24	79.18	61.62	t	t	t
7131	4	2026-03-02 21:49:40.198086	38.99	55.54	51.50	t	t	t
7132	2	2026-03-02 21:49:50.213205	40.37	25.51	65.25	t	t	t
7135	5	2026-03-02 21:49:50.370989	31.33	49.42	58.73	t	t	t
7136	2	2026-03-02 21:50:00.216521	51.74	63.64	56.54	t	t	f
7137	5	2026-03-02 21:50:00.216951	24.54	78.13	26.28	t	t	t
7140	2	2026-03-02 21:50:10.229549	75.14	61.59	38.52	t	t	f
7145	5	2026-03-02 21:50:20.229126	35.13	29.81	32.88	t	t	f
7150	4	2026-03-02 21:50:30.277394	69.68	70.12	58.75	t	t	f
7154	3	2026-03-02 21:50:40.253027	25.94	14.36	34.13	t	t	t
7159	4	2026-03-02 21:50:50.404404	73.41	54.57	43.82	t	t	f
7162	2	2026-03-02 21:51:00.275546	51.41	58.25	47.70	t	t	t
7173	3	2026-03-02 21:51:30.339268	26.15	59.82	56.19	t	t	f
7178	4	2026-03-02 21:51:40.31066	26.03	76.67	20.81	t	t	t
7183	5	2026-03-02 21:51:50.360704	49.13	53.91	60.56	t	t	f
7184	2	2026-03-02 21:52:00.32422	13.12	24.79	65.75	t	t	f
7198	5	2026-03-02 21:52:30.394362	35.30	55.98	28.32	t	t	f
7202	3	2026-03-02 21:52:40.369721	35.32	64.99	34.46	t	t	t
7207	5	2026-03-02 21:52:50.542102	56.44	67.71	23.54	t	t	t
7211	2	2026-03-02 21:53:00.383626	29.24	21.50	58.88	t	t	t
7213	2	2026-03-02 21:53:10.384205	54.78	42.42	26.61	t	t	t
7225	3	2026-03-02 21:53:40.462107	23.36	39.45	28.51	t	t	t
7230	4	2026-03-02 21:53:50.432263	73.88	34.48	26.70	t	t	t
7232	2	2026-03-02 21:54:00.431716	71.54	40.25	50.04	t	t	t
7239	5	2026-03-02 21:54:10.485444	75.41	51.40	51.12	t	t	f
7240	2	2026-03-02 21:54:20.44743	37.79	29.84	30.36	t	t	t
7261	3	2026-03-02 21:55:10.526333	27.57	67.85	53.54	t	f	t
7264	4	2026-03-02 21:55:20.503515	29.00	52.71	60.64	t	t	t
7269	5	2026-03-02 21:55:30.511295	22.96	17.71	68.96	t	t	t
7274	4	2026-03-02 21:55:40.561343	35.80	61.45	41.61	t	t	t
7278	3	2026-03-02 21:55:50.535996	47.89	59.53	24.10	t	t	t
7282	4	2026-03-02 21:56:00.542351	30.21	68.59	59.88	t	t	f
7287	5	2026-03-02 21:56:10.59079	45.55	31.58	57.05	t	t	t
7290	2	2026-03-02 21:56:20.568827	51.46	30.81	46.49	t	t	t
7295	3	2026-03-02 21:56:30.571239	42.56	78.16	34.89	t	t	f
7296	2	2026-03-02 21:56:40.573244	32.33	26.42	57.05	t	f	f
7317	3	2026-03-02 21:57:30.635818	67.75	57.29	38.41	t	t	f
7322	4	2026-03-02 21:57:40.605295	57.58	29.70	62.18	t	t	t
7324	2	2026-03-02 21:57:50.621945	16.34	24.45	37.36	t	t	t
7327	5	2026-03-02 21:57:50.658272	29.56	43.75	49.45	t	t	t
7328	2	2026-03-02 21:58:00.633842	74.82	11.11	22.11	t	t	f
7341	5	2026-03-02 21:58:30.714674	45.30	66.98	30.92	t	t	t
7345	4	2026-03-02 21:58:40.689375	19.49	26.02	34.99	t	t	t
7350	4	2026-03-02 21:58:50.735832	40.87	14.88	63.75	t	f	t
7354	3	2026-03-02 21:59:00.713524	59.86	24.11	20.95	f	t	t
7359	5	2026-03-02 21:59:10.769435	42.80	64.94	39.06	t	t	t
7360	2	2026-03-02 21:59:20.730303	62.07	23.08	43.83	t	t	t
7374	4	2026-03-02 21:59:50.79727	25.84	18.52	32.07	t	f	t
7379	3	2026-03-02 22:00:00.766678	49.22	25.61	33.86	t	t	f
7391	4	2026-03-02 22:00:30.824435	56.75	47.53	24.28	t	t	t
7393	3	2026-03-02 22:00:40.805366	39.95	43.74	59.23	t	t	f
7399	3	2026-03-02 22:00:50.850647	41.17	10.72	55.43	t	t	t
7400	2	2026-03-02 22:01:00.834148	28.29	40.63	37.78	t	t	t
7407	4	2026-03-02 22:01:10.842598	78.57	22.02	66.33	t	t	t
7408	2	2026-03-02 22:01:20.852573	79.32	47.54	65.10	t	t	t
7411	5	2026-03-02 22:01:20.889546	45.20	17.73	54.02	t	t	t
7412	2	2026-03-02 22:01:30.855853	17.62	77.15	65.85	t	t	t
7413	5	2026-03-02 22:01:30.85609	42.15	74.71	69.35	t	f	t
7417	5	2026-03-02 22:01:40.857702	73.82	51.13	33.47	t	t	t
7419	4	2026-03-02 22:01:40.858207	71.40	33.35	26.74	t	t	t
7423	5	2026-03-02 22:01:50.905499	71.34	73.35	27.52	t	t	t
7424	2	2026-03-02 22:02:00.886934	66.18	74.09	55.19	t	t	t
7429	5	2026-03-02 22:02:10.88877	35.72	60.69	60.40	t	f	t
7435	5	2026-03-02 22:02:20.935851	14.97	78.19	69.06	t	t	t
7436	2	2026-03-02 22:02:30.916092	62.07	55.05	69.84	f	t	t
7441	5	2026-03-02 22:02:40.917331	72.89	17.95	56.46	t	t	t
7444	2	2026-03-02 22:02:50.916927	67.10	23.22	58.93	t	t	t
7451	5	2026-03-02 22:03:00.967894	24.81	24.50	50.41	t	t	t
7452	2	2026-03-02 22:03:10.947849	52.00	38.32	21.72	t	t	f
7459	4	2026-03-02 22:03:21.103463	38.08	12.60	21.47	t	t	t
7460	2	2026-03-02 22:03:30.964758	29.00	16.36	60.20	t	t	t
7467	5	2026-03-02 22:03:40.969956	17.41	61.44	66.20	t	t	t
7469	5	2026-03-02 22:03:51.008742	34.77	48.11	59.66	t	t	t
7473	4	2026-03-02 22:04:00.995177	72.75	20.08	50.65	t	t	t
7475	5	2026-03-02 22:04:01.026814	15.86	71.05	27.86	t	t	t
7476	2	2026-03-02 22:04:10.993816	54.85	68.37	53.40	t	t	t
7479	3	2026-03-02 22:04:10.994501	58.48	46.59	59.87	t	t	t
6857	2	2026-03-02 21:38:19.573738	54.39	16.52	66.34	f	t	t
6858	4	2026-03-02 21:38:19.57901	33.28	70.35	21.42	t	t	t
6859	5	2026-03-02 21:38:19.579245	54.21	79.84	23.43	t	t	t
6860	2	2026-03-02 21:38:29.555336	26.09	33.85	61.49	t	t	t
6861	4	2026-03-02 21:38:29.555376	23.22	41.24	25.29	t	t	t
6862	3	2026-03-02 21:38:29.55555	77.13	11.07	34.00	t	t	t
6863	5	2026-03-02 21:38:29.698313	49.07	66.06	67.94	t	t	t
6864	2	2026-03-02 21:38:39.557028	68.00	50.83	45.01	t	t	t
6865	5	2026-03-02 21:38:39.557323	29.34	46.18	53.49	t	t	t
6866	3	2026-03-02 21:38:39.55749	50.21	14.35	54.45	t	t	t
6867	4	2026-03-02 21:38:39.557787	27.07	27.66	29.07	t	t	t
6868	2	2026-03-02 21:38:49.573843	26.18	43.13	37.06	t	t	t
6869	3	2026-03-02 21:38:49.60388	15.91	19.68	24.79	t	t	t
6870	5	2026-03-02 21:38:49.608105	12.94	43.91	31.73	t	t	f
6871	4	2026-03-02 21:38:49.712742	65.45	73.90	68.94	t	t	t
6872	4	2026-03-02 21:38:59.568842	78.66	43.93	59.07	t	t	t
6873	3	2026-03-02 21:38:59.569124	44.19	58.44	53.64	t	t	t
6874	5	2026-03-02 21:38:59.569389	77.21	20.53	66.87	t	t	f
6875	2	2026-03-02 21:38:59.569538	64.44	55.14	35.60	t	t	f
6876	2	2026-03-02 21:39:09.585911	66.98	60.68	20.28	t	t	t
6877	3	2026-03-02 21:39:09.618744	28.60	67.37	29.00	t	t	t
6878	4	2026-03-02 21:39:09.619016	56.26	23.26	54.78	t	t	t
6879	5	2026-03-02 21:39:09.621435	48.86	65.07	43.44	t	t	t
6880	2	2026-03-02 21:39:19.593238	11.41	76.85	48.25	t	t	f
6881	5	2026-03-02 21:39:19.593454	22.96	76.27	30.75	t	f	t
6882	4	2026-03-02 21:39:19.593539	23.00	43.05	22.88	t	t	t
6883	3	2026-03-02 21:39:19.593653	47.60	50.29	42.72	t	t	f
6884	2	2026-03-02 21:39:29.603553	66.58	12.40	45.37	t	t	f
6885	4	2026-03-02 21:39:29.635369	64.14	46.95	47.53	t	t	t
6886	5	2026-03-02 21:39:29.635908	17.54	53.38	32.36	t	t	f
6887	3	2026-03-02 21:39:29.745333	25.05	53.08	21.89	t	t	t
6888	2	2026-03-02 21:39:39.605317	30.84	65.67	38.38	t	t	t
6889	5	2026-03-02 21:39:39.605519	40.89	18.25	43.45	t	t	t
6890	3	2026-03-02 21:39:39.605662	50.37	29.57	41.84	t	t	t
6891	4	2026-03-02 21:39:39.605955	11.10	21.84	66.56	t	t	t
6892	2	2026-03-02 21:39:49.624103	11.35	58.23	50.69	t	t	t
6893	3	2026-03-02 21:39:49.654729	72.29	53.26	43.12	t	t	t
6894	4	2026-03-02 21:39:49.658929	45.07	46.21	41.14	t	t	t
6895	5	2026-03-02 21:39:49.659543	75.52	41.22	51.93	t	t	f
6896	2	2026-03-02 21:39:59.628321	17.99	53.65	57.75	t	t	t
6897	4	2026-03-02 21:39:59.628617	44.30	12.32	39.57	t	t	t
6898	3	2026-03-02 21:39:59.628729	37.86	49.32	33.63	f	f	t
6899	5	2026-03-02 21:39:59.659715	24.79	38.73	63.66	t	t	t
6900	2	2026-03-02 21:40:09.634073	28.77	34.63	43.90	t	t	t
6901	4	2026-03-02 21:40:09.667192	55.74	37.49	31.61	t	t	t
6902	3	2026-03-02 21:40:09.667707	32.74	52.17	67.91	t	t	t
6903	5	2026-03-02 21:40:09.670086	21.28	63.16	32.89	t	t	f
6904	2	2026-03-02 21:40:19.636198	35.74	51.91	68.63	t	t	t
6905	5	2026-03-02 21:40:19.636461	21.34	25.09	33.94	t	t	t
6906	3	2026-03-02 21:40:19.636693	73.66	20.36	69.26	f	t	t
6907	4	2026-03-02 21:40:19.637014	46.06	40.20	66.43	t	t	f
6908	2	2026-03-02 21:40:29.650984	63.40	16.68	53.78	t	t	t
6909	3	2026-03-02 21:40:29.682778	37.20	24.59	59.43	t	t	t
6910	4	2026-03-02 21:40:29.686419	19.98	67.71	34.38	t	f	f
6911	5	2026-03-02 21:40:29.686723	51.78	42.79	37.96	t	t	f
6912	3	2026-03-02 21:40:39.66608	64.41	54.57	62.68	t	t	t
6913	4	2026-03-02 21:40:39.665979	71.60	16.87	52.38	t	f	t
6914	2	2026-03-02 21:40:39.666056	53.53	64.01	24.86	t	t	t
6915	5	2026-03-02 21:40:39.693151	71.33	14.52	29.85	t	t	f
6916	2	2026-03-02 21:40:49.680873	31.27	25.06	59.08	t	t	f
6917	3	2026-03-02 21:40:49.714156	71.81	28.11	67.64	t	t	f
6918	4	2026-03-02 21:40:49.714817	60.63	68.56	46.00	t	f	t
6919	5	2026-03-02 21:40:49.715757	21.63	69.01	60.10	t	t	t
6920	2	2026-03-02 21:40:59.682486	34.68	35.00	57.19	t	t	t
6921	5	2026-03-02 21:40:59.683254	25.50	70.06	25.21	f	t	f
6922	3	2026-03-02 21:40:59.683446	16.55	12.05	36.59	t	t	t
6923	4	2026-03-02 21:40:59.683723	65.83	67.03	35.20	t	t	t
6924	2	2026-03-02 21:41:09.699193	49.34	45.33	44.67	t	t	t
6925	3	2026-03-02 21:41:09.73185	72.67	64.37	48.82	t	t	t
6926	4	2026-03-02 21:41:09.735215	60.54	33.43	30.27	t	t	t
6927	5	2026-03-02 21:41:09.735686	59.69	74.14	22.37	t	t	t
6928	3	2026-03-02 21:41:19.695567	52.57	49.44	20.69	t	t	t
6929	4	2026-03-02 21:41:19.695746	51.30	59.75	56.88	t	t	t
6930	5	2026-03-02 21:41:19.695976	26.63	21.04	61.20	t	t	t
6931	2	2026-03-02 21:41:19.696027	72.02	32.89	60.87	f	t	t
6932	2	2026-03-02 21:41:29.709701	28.54	51.58	66.56	t	t	t
6933	3	2026-03-02 21:41:29.742812	79.75	46.09	32.01	t	t	t
6934	4	2026-03-02 21:41:29.746297	53.33	70.61	60.59	t	t	t
6935	5	2026-03-02 21:41:29.746894	61.39	24.33	67.36	t	t	t
6936	2	2026-03-02 21:41:39.725478	11.42	31.26	52.26	t	t	t
6937	4	2026-03-02 21:41:39.725855	67.69	36.60	44.14	t	t	t
6938	3	2026-03-02 21:41:39.726044	49.53	57.98	45.49	t	t	t
6939	5	2026-03-02 21:41:39.756704	58.83	48.33	25.69	t	t	t
6940	2	2026-03-02 21:41:49.734364	21.20	56.32	68.98	t	t	t
6941	5	2026-03-02 21:41:49.734534	37.90	13.90	34.98	f	t	t
6942	3	2026-03-02 21:41:49.734778	53.53	40.37	68.61	f	t	f
6943	4	2026-03-02 21:41:49.734969	20.30	74.03	62.93	t	t	t
6944	2	2026-03-02 21:41:59.743976	74.69	49.77	38.49	t	t	t
6945	3	2026-03-02 21:41:59.776315	16.52	46.47	47.04	t	f	t
6946	4	2026-03-02 21:41:59.779485	21.05	26.25	33.76	t	t	t
6947	5	2026-03-02 21:41:59.779827	46.59	14.04	42.01	t	t	t
6948	2	2026-03-02 21:42:09.746159	42.52	48.24	29.17	t	f	t
6949	5	2026-03-02 21:42:09.746514	42.72	60.84	32.59	f	t	t
6950	4	2026-03-02 21:42:09.746708	57.46	33.50	37.83	t	t	t
6951	3	2026-03-02 21:42:09.747043	28.21	72.09	24.00	t	t	f
6952	2	2026-03-02 21:42:19.745663	53.30	43.07	62.67	t	t	f
6953	5	2026-03-02 21:42:19.745793	53.91	50.00	26.82	t	t	t
6954	3	2026-03-02 21:42:19.746035	75.47	23.77	55.49	t	t	t
6955	4	2026-03-02 21:42:19.746361	13.17	23.21	42.16	t	t	t
6956	2	2026-03-02 21:42:29.761444	70.63	28.75	43.76	t	t	f
6957	4	2026-03-02 21:42:29.797435	44.03	27.22	55.25	t	t	t
6958	5	2026-03-02 21:42:29.797746	72.69	69.40	27.16	t	t	t
6959	3	2026-03-02 21:42:29.797828	71.61	64.90	63.99	t	t	t
6960	2	2026-03-02 21:42:39.773455	54.24	45.07	36.38	t	t	f
6961	3	2026-03-02 21:42:39.774249	31.52	33.87	60.43	t	t	t
6962	4	2026-03-02 21:42:39.774522	43.12	26.31	44.91	t	t	t
6963	5	2026-03-02 21:42:39.804014	65.35	59.76	62.91	t	f	t
7493	4	2026-03-02 22:04:51.02769	49.28	77.38	35.98	t	t	f
7494	3	2026-03-02 22:04:51.028171	38.24	37.65	61.18	t	t	f
7495	5	2026-03-02 22:04:51.028382	21.15	57.56	63.12	t	t	t
7496	2	2026-03-02 22:05:01.053705	15.81	26.29	59.64	t	t	f
7497	3	2026-03-02 22:05:01.086123	29.48	25.78	54.26	t	t	t
7498	4	2026-03-02 22:05:01.086444	35.58	22.87	31.50	t	t	t
7499	5	2026-03-02 22:05:01.088725	38.43	27.22	34.31	t	t	t
7500	4	2026-03-02 22:05:11.052931	54.71	32.61	51.51	t	f	t
7501	3	2026-03-02 22:05:11.053536	50.25	63.74	20.97	t	t	t
7502	2	2026-03-02 22:05:11.054303	61.79	65.55	34.42	t	t	t
7503	5	2026-03-02 22:05:11.054452	50.44	31.51	66.25	t	t	f
7504	3	2026-03-02 22:05:21.068321	40.03	53.21	54.90	t	f	f
7505	2	2026-03-02 22:05:21.100415	30.05	62.91	24.01	t	t	t
7506	4	2026-03-02 22:05:21.104367	75.19	41.03	32.61	f	t	t
7507	5	2026-03-02 22:05:21.106763	74.23	21.31	68.19	t	t	t
7508	2	2026-03-02 22:05:31.071788	53.22	49.76	66.42	t	t	f
7509	5	2026-03-02 22:05:31.07239	51.70	51.27	27.58	t	t	t
7510	4	2026-03-02 22:05:31.072565	35.62	75.44	27.89	t	t	t
7511	3	2026-03-02 22:05:31.072793	21.20	53.14	49.99	t	t	t
7512	2	2026-03-02 22:05:41.073365	31.26	55.08	32.80	t	t	t
7513	5	2026-03-02 22:05:41.073567	54.04	32.94	26.16	t	t	t
7514	4	2026-03-02 22:05:41.073875	26.45	13.19	59.51	t	t	t
7515	3	2026-03-02 22:05:41.074122	35.04	31.16	55.47	t	t	f
7516	2	2026-03-02 22:05:51.083715	62.63	77.74	47.86	t	t	t
7517	3	2026-03-02 22:05:51.115514	26.18	56.01	43.72	t	t	t
7518	5	2026-03-02 22:05:51.120847	59.56	71.17	56.83	t	t	t
7519	4	2026-03-02 22:05:51.121145	71.11	36.97	45.33	t	t	f
7520	2	2026-03-02 22:06:01.08906	79.19	38.83	25.52	t	t	t
7521	5	2026-03-02 22:06:01.089739	58.58	17.91	69.47	t	t	t
7522	3	2026-03-02 22:06:01.090095	22.26	54.96	67.46	t	t	t
7523	4	2026-03-02 22:06:01.090203	76.61	28.91	61.94	t	t	t
7524	2	2026-03-02 22:06:11.103881	15.32	18.25	42.63	t	t	t
7525	3	2026-03-02 22:06:11.135742	41.75	39.55	57.29	t	t	t
7526	5	2026-03-02 22:06:11.138769	48.33	18.03	43.54	t	t	f
7527	4	2026-03-02 22:06:11.139355	55.45	44.43	55.60	t	f	f
7528	2	2026-03-02 22:06:21.104902	48.57	69.39	30.84	t	t	t
7529	5	2026-03-02 22:06:21.105157	26.79	61.51	43.36	t	t	t
7530	3	2026-03-02 22:06:21.105316	24.33	59.27	47.62	t	t	f
7531	4	2026-03-02 22:06:21.105626	75.71	53.72	45.80	t	t	t
7532	2	2026-03-02 22:06:31.120005	60.35	26.50	61.17	t	t	t
7533	4	2026-03-02 22:06:31.150099	65.07	30.70	51.26	t	t	t
7534	3	2026-03-02 22:06:31.155373	76.92	47.56	20.49	t	t	t
7535	5	2026-03-02 22:06:31.156324	26.45	10.23	25.10	t	t	f
7536	2	2026-03-02 22:06:41.126914	26.46	59.41	45.70	t	t	f
7537	4	2026-03-02 22:06:41.127921	23.17	46.05	50.38	t	t	t
7538	3	2026-03-02 22:06:41.128445	49.33	64.34	26.53	f	f	f
7539	5	2026-03-02 22:06:41.157498	36.12	75.47	34.76	t	t	f
7540	2	2026-03-02 22:06:51.137493	50.35	77.49	42.39	t	t	t
7541	3	2026-03-02 22:06:51.169475	12.94	20.50	45.32	t	t	t
7542	4	2026-03-02 22:06:51.171483	63.82	65.19	59.92	t	t	t
7543	5	2026-03-02 22:06:51.171964	26.07	12.23	41.23	t	t	t
7544	2	2026-03-02 22:07:01.149991	59.03	27.62	53.07	t	t	f
7545	4	2026-03-02 22:07:01.150317	13.61	43.86	53.44	t	t	t
7546	3	2026-03-02 22:07:01.150542	31.40	39.92	26.96	t	t	f
7547	5	2026-03-02 22:07:01.181636	20.59	62.49	40.64	t	t	t
7548	2	2026-03-02 22:07:11.153056	77.38	21.71	55.14	f	t	t
7549	5	2026-03-02 22:07:11.153216	50.64	15.27	66.24	t	t	t
7550	4	2026-03-02 22:07:11.153461	71.89	16.72	55.15	t	t	t
7551	3	2026-03-02 22:07:11.153791	10.54	57.26	30.32	t	t	t
7552	2	2026-03-02 22:07:21.166525	46.97	42.95	61.13	t	t	t
7553	3	2026-03-02 22:07:21.198847	34.91	74.95	55.46	t	t	t
7554	4	2026-03-02 22:07:21.204201	36.34	44.79	65.56	t	t	t
7555	5	2026-03-02 22:07:21.204465	35.86	51.59	49.33	t	t	t
7556	2	2026-03-02 22:07:31.182713	37.68	25.80	47.92	f	t	t
7557	3	2026-03-02 22:07:31.183057	21.60	77.86	23.73	t	t	t
7558	4	2026-03-02 22:07:31.183288	24.27	26.44	57.16	t	t	t
7559	5	2026-03-02 22:07:31.21557	67.30	18.74	46.50	t	t	t
7560	2	2026-03-02 22:07:41.1825	33.73	72.16	32.28	t	t	t
7561	5	2026-03-02 22:07:41.182684	65.45	21.73	29.66	t	f	t
7562	3	2026-03-02 22:07:41.183181	68.26	58.62	60.37	f	t	t
7563	4	2026-03-02 22:07:41.183008	50.52	79.54	67.46	t	t	t
7564	2	2026-03-02 22:07:51.195221	35.71	36.57	24.49	t	t	f
7565	3	2026-03-02 22:07:51.226544	55.68	29.26	27.49	t	t	f
7566	5	2026-03-02 22:07:51.228762	33.03	75.29	29.28	t	t	f
7567	4	2026-03-02 22:07:51.229959	27.24	41.54	68.64	t	t	t
7568	2	2026-03-02 22:08:01.207536	31.09	55.26	46.68	t	t	f
7569	3	2026-03-02 22:08:01.207835	43.42	64.27	25.74	t	t	t
7570	4	2026-03-02 22:08:01.20802	37.54	12.57	44.56	t	t	f
7571	5	2026-03-02 22:08:01.237652	47.64	49.98	60.52	t	t	t
7572	2	2026-03-02 22:08:11.216901	25.56	45.06	60.90	t	t	t
7573	3	2026-03-02 22:08:11.249083	21.98	52.70	48.92	t	t	t
7574	4	2026-03-02 22:08:11.251189	19.71	68.27	44.84	t	t	t
7575	5	2026-03-02 22:08:11.253108	65.46	46.57	27.58	t	t	t
7576	4	2026-03-02 22:08:21.229205	65.78	17.21	33.54	t	t	t
7577	3	2026-03-02 22:08:21.229501	46.44	11.88	58.10	t	t	t
7578	2	2026-03-02 22:08:21.229381	52.71	25.42	26.07	t	t	t
7579	5	2026-03-02 22:08:21.260667	72.66	27.64	50.10	t	t	t
7580	2	2026-03-02 22:08:31.231625	42.64	20.98	41.58	t	f	f
7581	5	2026-03-02 22:08:31.231815	68.77	71.64	37.29	t	t	t
7582	4	2026-03-02 22:08:31.231961	24.31	70.24	60.96	t	t	t
7583	3	2026-03-02 22:08:31.232237	15.01	44.99	45.40	t	t	f
7584	2	2026-03-02 22:08:41.245825	48.45	45.40	56.92	t	t	t
7585	3	2026-03-02 22:08:41.278161	64.67	50.93	61.02	f	t	t
7586	4	2026-03-02 22:08:41.281246	10.12	70.70	55.41	t	t	t
7587	5	2026-03-02 22:08:41.283683	25.20	46.12	20.77	t	t	t
7588	2	2026-03-02 22:08:51.260297	71.26	12.31	44.27	t	t	f
7589	3	2026-03-02 22:08:51.260421	75.49	48.71	56.60	t	t	t
7590	4	2026-03-02 22:08:51.260655	32.44	27.92	42.62	t	t	t
7591	5	2026-03-02 22:08:51.292955	61.54	22.60	23.69	t	t	t
7592	2	2026-03-02 22:09:01.259794	45.20	76.68	22.27	t	t	t
7593	5	2026-03-02 22:09:01.259959	12.41	66.13	57.87	f	t	f
7594	3	2026-03-02 22:09:01.260295	35.82	34.07	68.65	t	t	t
7595	4	2026-03-02 22:09:01.260449	54.50	19.15	66.15	t	t	t
7596	2	2026-03-02 22:09:11.273544	55.00	17.85	58.06	t	t	t
7597	3	2026-03-02 22:09:11.307266	40.85	47.96	28.41	t	t	t
7598	4	2026-03-02 22:09:11.307624	44.24	62.18	37.17	t	f	t
7599	5	2026-03-02 22:09:11.309824	52.41	27.53	41.52	t	f	t
7600	2	2026-03-02 22:09:21.290259	39.62	45.16	48.73	t	t	t
7601	3	2026-03-02 22:09:21.290332	42.42	56.03	23.15	t	t	t
7602	4	2026-03-02 22:09:21.290476	69.54	63.09	65.86	t	t	t
7603	5	2026-03-02 22:09:21.321917	50.42	53.12	42.57	t	t	f
7604	2	2026-03-02 22:09:31.307048	78.07	49.24	61.94	t	t	t
7605	3	2026-03-02 22:09:31.338967	41.22	18.75	34.67	t	t	t
7606	5	2026-03-02 22:09:31.34317	33.40	78.82	29.33	t	t	t
7607	4	2026-03-02 22:09:31.468112	29.87	45.24	26.18	t	t	t
7608	2	2026-03-02 22:09:41.305589	50.28	70.53	51.43	t	t	t
7609	5	2026-03-02 22:09:41.30606	66.20	31.51	26.77	t	t	t
7610	3	2026-03-02 22:09:41.306293	48.44	64.56	52.21	t	t	t
7611	4	2026-03-02 22:09:41.306524	14.04	66.82	39.19	t	t	t
7612	2	2026-03-02 22:09:51.321285	59.77	28.80	40.28	t	t	t
7613	3	2026-03-02 22:09:51.356611	59.84	74.71	37.71	t	t	t
7614	4	2026-03-02 22:09:51.357161	30.84	15.13	31.49	t	f	t
7615	5	2026-03-02 22:09:51.359219	77.92	78.33	60.29	t	t	f
7616	2	2026-03-02 22:10:01.325657	26.47	44.68	66.30	t	t	t
7617	5	2026-03-02 22:10:01.325826	33.77	31.51	48.83	t	f	t
7618	3	2026-03-02 22:10:01.325965	53.09	65.07	66.99	t	t	f
7619	4	2026-03-02 22:10:01.326254	61.24	32.69	68.50	t	t	f
7620	2	2026-03-02 22:10:11.337467	57.92	36.87	27.20	t	t	f
7621	3	2026-03-02 22:10:11.36822	47.64	76.01	41.15	t	t	f
7622	4	2026-03-02 22:10:11.370296	27.15	12.63	61.36	t	t	t
7623	5	2026-03-02 22:10:11.496553	20.62	46.80	45.36	t	t	t
7624	4	2026-03-02 22:10:21.351886	40.87	15.41	66.42	t	t	t
7625	3	2026-03-02 22:10:21.352393	39.59	38.58	25.63	t	t	t
7626	2	2026-03-02 22:10:21.352578	56.78	38.90	43.67	t	t	t
7627	5	2026-03-02 22:10:21.381478	10.36	54.63	69.76	t	f	t
7628	3	2026-03-02 22:10:31.369664	47.53	54.71	44.06	t	t	t
7629	2	2026-03-02 22:10:31.402403	36.51	78.13	48.57	t	t	t
7630	5	2026-03-02 22:10:31.405957	38.81	33.19	40.61	t	t	t
7631	4	2026-03-02 22:10:31.406271	75.74	38.10	65.67	t	t	t
7632	2	2026-03-02 22:10:41.36399	57.90	47.07	37.26	t	t	t
7633	4	2026-03-02 22:10:41.364287	42.82	33.53	27.28	t	t	t
7634	3	2026-03-02 22:10:41.364467	26.42	19.33	57.36	t	t	t
7635	5	2026-03-02 22:10:41.364698	15.53	50.94	38.61	t	t	f
7636	5	2026-03-02 22:10:51.369891	14.99	65.10	36.18	t	t	t
7637	2	2026-03-02 22:10:51.369807	55.58	35.73	43.68	t	t	t
7638	4	2026-03-02 22:10:51.370071	58.15	31.60	65.09	t	t	t
7639	3	2026-03-02 22:10:51.370284	72.39	68.98	69.14	t	t	t
7640	2	2026-03-02 22:11:01.382209	46.31	71.27	55.82	t	t	t
7641	3	2026-03-02 22:11:01.414607	36.33	62.96	29.69	t	t	t
7642	4	2026-03-02 22:11:01.418154	14.49	22.85	52.25	t	f	t
7643	5	2026-03-02 22:11:01.418598	19.01	39.84	41.20	t	t	t
7644	2	2026-03-02 22:11:11.383824	79.96	11.44	65.56	t	f	t
7645	3	2026-03-02 22:11:11.384334	42.39	13.06	31.06	t	f	t
7646	4	2026-03-02 22:11:11.384557	18.36	38.56	50.68	t	t	t
7647	5	2026-03-02 22:11:11.38488	21.56	56.15	57.70	t	t	t
7648	2	2026-03-02 22:11:21.399888	77.09	78.53	66.36	t	t	t
7649	3	2026-03-02 22:11:21.430529	47.78	38.09	39.35	t	t	t
7650	5	2026-03-02 22:11:21.434154	72.46	34.09	61.14	t	t	t
7651	4	2026-03-02 22:11:21.542007	74.04	29.34	62.65	t	t	t
7652	2	2026-03-02 22:11:31.400415	73.68	29.48	35.13	t	t	t
7653	5	2026-03-02 22:11:31.400649	71.72	64.23	48.07	t	t	t
7654	4	2026-03-02 22:11:31.40081	11.46	40.53	25.95	t	t	t
7655	3	2026-03-02 22:11:31.401086	54.83	13.56	44.27	t	t	t
7656	2	2026-03-02 22:11:41.400571	66.82	42.65	67.30	t	t	t
7657	4	2026-03-02 22:11:41.401059	77.05	10.91	41.56	t	t	t
7658	5	2026-03-02 22:11:41.401488	54.43	62.20	41.61	t	t	t
7659	3	2026-03-02 22:11:41.401641	34.02	68.41	59.16	t	t	t
7660	2	2026-03-02 22:11:51.415698	22.59	55.79	22.81	t	t	t
7661	5	2026-03-02 22:11:51.448094	60.08	19.53	45.02	t	t	f
7662	3	2026-03-02 22:11:51.448676	37.39	36.85	66.73	t	t	t
7663	4	2026-03-02 22:11:51.556925	76.84	78.27	39.49	t	t	t
7664	2	2026-03-02 22:12:01.418859	41.02	24.21	66.06	t	f	f
7665	5	2026-03-02 22:12:01.419626	78.75	50.07	48.42	t	t	t
7666	3	2026-03-02 22:12:01.419831	76.04	41.55	24.26	t	t	t
7667	4	2026-03-02 22:12:01.420088	23.90	73.76	63.29	t	t	t
7668	2	2026-03-02 22:12:11.432489	28.11	17.40	43.59	t	t	t
7669	4	2026-03-02 22:12:11.468303	46.48	23.59	51.30	t	t	f
7670	5	2026-03-02 22:12:11.468581	52.41	38.94	66.47	t	t	t
7671	3	2026-03-02 22:12:11.573646	24.41	59.12	23.87	t	t	t
7672	2	2026-03-02 22:12:21.434672	68.06	73.51	44.69	t	f	t
7673	4	2026-03-02 22:12:21.435154	74.21	20.31	67.56	t	t	t
7674	3	2026-03-02 22:12:21.435455	71.49	32.97	64.68	t	t	t
7675	5	2026-03-02 22:12:21.435604	49.77	62.18	65.47	t	t	t
7676	2	2026-03-02 22:12:31.435199	46.92	70.75	66.56	t	t	f
7677	5	2026-03-02 22:12:31.435623	56.30	26.92	40.39	t	t	t
7678	4	2026-03-02 22:12:31.436094	47.46	58.96	43.32	t	t	t
7679	3	2026-03-02 22:12:31.436381	72.37	54.29	51.40	t	t	f
7680	3	2026-03-02 22:12:41.442551	36.38	15.07	41.83	t	t	t
7681	4	2026-03-02 22:12:41.472303	55.78	12.47	51.96	t	t	t
7682	5	2026-03-02 22:12:41.478068	69.60	73.76	34.79	t	f	t
7683	2	2026-03-02 22:12:41.479127	44.38	38.52	30.70	t	t	t
7684	2	2026-03-02 22:12:51.460867	58.15	34.86	53.78	t	t	f
7685	4	2026-03-02 22:12:51.461336	59.94	73.15	49.21	t	t	t
7686	3	2026-03-02 22:12:51.461512	28.72	31.15	38.56	f	t	t
7687	5	2026-03-02 22:12:51.493286	19.76	74.52	58.36	t	t	t
7688	2	2026-03-02 22:13:01.473876	54.91	50.46	63.93	t	t	t
7689	3	2026-03-02 22:13:01.507736	16.05	75.39	44.85	t	t	t
7690	4	2026-03-02 22:13:01.508352	53.94	13.16	60.41	t	t	t
7691	5	2026-03-02 22:13:01.512184	50.75	35.76	35.42	t	t	f
7692	2	2026-03-02 22:13:11.479724	14.62	24.19	53.12	t	t	t
7693	5	2026-03-02 22:13:11.479983	34.51	21.62	49.17	t	t	t
7694	4	2026-03-02 22:13:11.480146	74.91	55.16	50.96	t	f	t
7695	3	2026-03-02 22:13:11.48041	41.19	31.01	39.40	t	t	t
7696	2	2026-03-02 22:13:21.493942	22.25	43.25	61.37	t	t	f
7697	4	2026-03-02 22:13:21.529326	13.76	38.44	55.29	t	t	f
7698	3	2026-03-02 22:13:21.529561	38.76	77.02	20.41	t	t	t
7699	5	2026-03-02 22:13:21.52986	64.39	75.79	68.76	f	t	f
7700	2	2026-03-02 22:13:31.494413	11.96	50.55	23.64	t	t	t
7701	5	2026-03-02 22:13:31.494711	33.35	32.32	26.03	t	t	t
7702	3	2026-03-02 22:13:31.494878	50.30	30.04	21.11	t	t	f
7703	4	2026-03-02 22:13:31.495133	32.16	43.52	53.46	t	t	t
7704	2	2026-03-02 22:13:41.51102	28.27	10.70	61.28	t	t	t
7705	3	2026-03-02 22:13:41.541901	37.96	27.09	26.17	t	t	t
7706	4	2026-03-02 22:13:41.544077	73.40	20.21	35.39	t	t	t
7707	5	2026-03-02 22:13:41.547531	21.61	63.74	23.22	t	t	t
7708	2	2026-03-02 22:13:51.511721	62.82	63.14	37.58	t	t	t
7709	5	2026-03-02 22:13:51.512201	43.62	16.11	47.54	t	t	t
7710	3	2026-03-02 22:13:51.512608	31.82	56.64	35.41	t	f	t
7711	4	2026-03-02 22:13:51.512815	29.59	25.51	65.52	t	t	t
7712	2	2026-03-02 22:14:01.52749	47.48	33.58	67.75	f	t	t
7713	3	2026-03-02 22:14:01.55875	35.27	32.64	38.67	t	t	t
7714	4	2026-03-02 22:14:01.56304	57.30	17.78	46.82	t	f	f
7715	5	2026-03-02 22:14:01.56352	65.41	47.52	55.96	t	t	t
7716	2	2026-03-02 22:14:11.552527	21.38	24.38	32.60	t	t	t
7717	4	2026-03-02 22:14:11.552962	21.87	17.48	40.25	t	t	t
7718	3	2026-03-02 22:14:11.553292	59.88	28.57	54.24	t	f	t
7719	5	2026-03-02 22:14:11.585	35.32	19.64	29.15	t	f	t
7720	2	2026-03-02 22:14:21.557513	26.56	77.85	41.62	t	t	t
7721	5	2026-03-02 22:14:21.557971	34.53	69.15	67.62	f	t	t
7722	4	2026-03-02 22:14:21.558152	72.09	25.38	44.57	t	t	t
7723	3	2026-03-02 22:14:21.558312	11.39	15.69	65.47	t	t	t
7724	2	2026-03-02 22:14:31.566758	21.71	46.67	69.90	t	t	t
7725	3	2026-03-02 22:14:31.567147	59.40	50.25	43.88	t	t	t
7726	4	2026-03-02 22:14:31.597216	24.69	51.72	44.86	t	t	t
7727	5	2026-03-02 22:14:31.59872	38.83	67.14	35.98	t	t	t
7728	2	2026-03-02 22:14:41.574389	36.10	27.83	45.80	t	t	t
7729	3	2026-03-02 22:14:41.574598	35.74	14.20	69.08	t	t	t
7730	4	2026-03-02 22:14:41.574807	31.89	29.28	21.90	t	t	t
7731	5	2026-03-02 22:14:41.725575	71.52	15.54	48.67	t	t	t
7732	2	2026-03-02 22:14:51.583525	56.68	28.82	24.01	t	t	t
7733	3	2026-03-02 22:14:51.583755	39.17	33.38	59.18	t	t	t
7734	4	2026-03-02 22:14:51.616413	58.47	45.51	28.28	t	t	t
7735	5	2026-03-02 22:14:51.618142	40.92	20.64	57.93	t	t	f
7736	3	2026-03-02 22:15:01.590695	57.71	21.82	56.28	t	t	t
7737	5	2026-03-02 22:15:01.591275	42.68	19.39	40.67	t	t	t
7738	4	2026-03-02 22:15:01.592243	70.54	73.86	33.47	f	t	t
7739	2	2026-03-02 22:15:01.5925	21.19	24.81	58.56	t	t	t
7740	2	2026-03-02 22:15:11.602129	51.57	67.93	22.72	t	t	t
7741	3	2026-03-02 22:15:11.751149	17.66	42.47	22.71	t	t	t
7742	4	2026-03-02 22:15:11.751447	56.95	73.54	69.42	t	t	t
7743	5	2026-03-02 22:15:11.751933	27.97	15.19	38.60	t	t	t
7744	4	2026-03-02 22:15:21.605235	70.40	47.46	36.73	t	t	f
7745	5	2026-03-02 22:15:21.605585	61.91	60.39	64.14	t	t	t
7746	3	2026-03-02 22:15:21.605796	23.66	75.02	55.02	t	t	f
7747	2	2026-03-02 22:15:21.606132	29.80	79.58	53.99	t	t	f
7748	2	2026-03-02 22:15:31.620882	58.57	71.81	65.24	t	t	t
7749	3	2026-03-02 22:15:31.652412	68.62	49.97	55.57	t	t	t
7750	4	2026-03-02 22:15:31.656741	44.19	71.80	53.83	t	t	t
7751	5	2026-03-02 22:15:31.657072	38.80	41.20	37.60	t	t	t
7752	2	2026-03-02 22:15:41.624233	21.83	77.84	56.97	t	f	t
7753	5	2026-03-02 22:15:41.624429	68.37	57.71	56.54	t	t	t
7754	4	2026-03-02 22:15:41.62459	67.41	62.08	35.76	t	t	t
7755	3	2026-03-02 22:15:41.624934	40.02	66.57	24.43	t	f	t
7756	2	2026-03-02 22:15:51.636711	41.45	13.04	65.94	t	t	t
7757	4	2026-03-02 22:15:51.670237	39.30	79.33	35.56	t	t	t
7758	5	2026-03-02 22:15:51.671337	60.36	79.97	32.95	t	t	t
7759	3	2026-03-02 22:15:51.777543	54.67	43.78	27.20	t	t	t
7760	2	2026-03-02 22:16:01.648854	68.33	21.47	20.11	t	t	t
7761	3	2026-03-02 22:16:01.649356	16.36	73.31	41.26	t	t	t
7762	4	2026-03-02 22:16:01.649547	54.53	23.26	57.05	t	t	t
7763	5	2026-03-02 22:16:01.680024	64.96	11.48	21.15	t	t	f
7764	2	2026-03-02 22:16:11.651821	18.50	66.70	62.62	t	t	f
7765	4	2026-03-02 22:16:11.652015	36.60	28.33	59.83	t	t	t
7766	5	2026-03-02 22:16:11.65225	23.66	28.58	34.21	t	t	t
7767	3	2026-03-02 22:16:11.652479	52.20	61.32	34.09	t	t	f
7768	2	2026-03-02 22:16:21.662399	49.27	24.85	29.91	t	t	t
7769	3	2026-03-02 22:16:21.696054	70.25	11.81	50.85	t	t	t
7770	4	2026-03-02 22:16:21.696354	19.37	79.50	29.14	t	t	t
7771	5	2026-03-02 22:16:21.697241	17.17	21.06	27.46	t	t	t
7772	2	2026-03-02 22:16:31.671446	33.69	11.27	30.84	t	t	t
7773	3	2026-03-02 22:16:31.671951	16.88	12.31	27.80	t	t	t
7774	5	2026-03-02 22:16:31.672199	46.58	68.69	49.85	t	t	t
7775	4	2026-03-02 22:16:31.703458	13.40	39.19	34.78	t	t	t
7776	2	2026-03-02 22:16:41.682799	27.80	59.39	52.52	t	t	t
7777	3	2026-03-02 22:16:41.712442	58.18	64.33	50.13	t	t	t
7778	4	2026-03-02 22:16:41.71551	19.79	78.76	45.98	t	t	t
7779	5	2026-03-02 22:16:41.718517	53.47	37.87	50.08	t	t	t
7780	3	2026-03-02 22:16:51.698252	21.20	54.43	30.22	t	f	f
7781	4	2026-03-02 22:16:51.698629	10.17	33.74	46.51	t	f	t
7782	2	2026-03-02 22:16:51.698825	65.92	42.46	45.10	f	t	f
7783	5	2026-03-02 22:16:51.728167	41.39	73.71	37.82	t	t	f
7784	2	2026-03-02 22:17:01.698904	59.99	65.41	41.02	t	t	t
7785	4	2026-03-02 22:17:01.699172	56.30	73.48	69.67	t	t	t
7786	5	2026-03-02 22:17:01.699355	75.85	47.76	50.29	t	t	t
7787	3	2026-03-02 22:17:01.699527	52.36	72.08	48.92	t	t	t
7788	2	2026-03-02 22:17:11.709131	19.81	31.41	57.97	t	t	t
7789	3	2026-03-02 22:17:11.741507	58.75	23.56	61.81	t	t	t
7790	4	2026-03-02 22:17:11.74156	43.21	58.34	22.26	t	t	t
7791	5	2026-03-02 22:17:11.743572	16.55	74.33	49.92	t	t	t
7792	3	2026-03-02 22:17:21.724443	22.76	72.10	39.98	t	t	t
7793	2	2026-03-02 22:17:21.724569	45.12	28.21	65.49	t	t	t
7794	4	2026-03-02 22:17:21.724711	51.16	59.41	33.25	t	t	t
7795	5	2026-03-02 22:17:21.758835	66.16	61.80	60.58	t	t	t
7796	2	2026-03-02 22:17:31.745672	29.23	13.25	20.76	t	t	f
7797	3	2026-03-02 22:17:31.77965	61.18	36.35	60.83	t	t	t
7798	4	2026-03-02 22:17:31.780636	62.54	75.20	65.33	t	t	f
7799	5	2026-03-02 22:17:31.783709	72.29	44.33	62.92	t	t	f
7800	2	2026-03-02 22:17:41.759299	19.36	39.98	63.04	t	t	t
7801	4	2026-03-02 22:17:41.759603	50.15	43.46	52.41	t	f	t
7802	3	2026-03-02 22:17:41.759856	67.89	12.77	41.83	t	t	t
7803	5	2026-03-02 22:17:41.78946	29.75	77.80	65.48	t	t	t
7804	2	2026-03-02 22:17:51.761323	41.65	52.45	32.46	t	t	f
7805	4	2026-03-02 22:17:51.761756	76.89	67.96	42.50	t	t	t
7806	5	2026-03-02 22:17:51.762155	36.39	21.85	55.58	t	t	t
7807	3	2026-03-02 22:17:51.762328	43.42	79.70	62.41	t	t	t
7808	2	2026-03-02 22:18:01.772271	24.49	44.33	33.99	t	t	t
7809	3	2026-03-02 22:18:01.805549	25.84	75.60	42.90	t	t	t
7810	4	2026-03-02 22:18:01.811188	73.04	15.75	48.43	t	t	t
7811	5	2026-03-02 22:18:01.811695	56.50	58.96	43.14	t	t	t
7812	2	2026-03-02 22:18:11.777382	43.58	41.54	67.83	t	t	t
7813	4	2026-03-02 22:18:11.777667	74.75	34.97	26.61	t	t	t
7814	5	2026-03-02 22:18:11.777906	78.79	68.91	58.45	t	t	t
7815	3	2026-03-02 22:18:11.778145	25.91	45.69	44.34	t	t	t
7816	2	2026-03-02 22:18:21.795245	66.66	55.08	48.64	t	t	f
7817	3	2026-03-02 22:18:21.825296	78.16	27.51	26.25	t	t	t
7818	5	2026-03-02 22:18:21.829006	51.14	27.01	29.74	t	t	t
7819	4	2026-03-02 22:18:21.944179	29.73	75.82	56.02	t	t	t
7820	2	2026-03-02 22:18:31.797389	36.77	50.92	24.66	t	t	t
7821	3	2026-03-02 22:18:31.797672	37.38	55.40	66.41	t	t	t
7822	5	2026-03-02 22:18:31.797916	51.79	27.27	59.07	t	t	t
7824	2	2026-03-02 22:18:41.808912	76.79	57.28	69.84	t	t	t
7932	2	2026-03-02 22:23:12.044218	47.44	33.51	56.92	t	t	t
7933	5	2026-03-02 22:23:12.044873	42.98	30.99	48.51	t	t	f
7934	4	2026-03-02 22:23:12.045211	73.23	32.79	69.05	t	t	t
7935	3	2026-03-02 22:23:12.045156	46.00	32.94	32.80	t	t	t
7936	2	2026-03-02 22:23:22.055825	36.80	30.27	26.65	t	t	f
7937	3	2026-03-02 22:23:22.091078	71.44	23.15	58.57	t	t	t
7938	4	2026-03-02 22:23:22.09413	15.15	44.10	23.16	t	t	f
7939	5	2026-03-02 22:23:22.095074	66.29	12.32	41.08	t	t	t
7940	2	2026-03-02 22:23:32.070039	64.90	37.95	48.68	t	t	t
7941	4	2026-03-02 22:23:32.070216	55.30	53.78	43.79	t	t	t
7942	3	2026-03-02 22:23:32.07053	70.33	27.57	53.28	t	t	t
7943	5	2026-03-02 22:23:32.214337	76.91	63.85	54.63	t	t	t
7944	2	2026-03-02 22:23:42.084009	34.13	32.97	66.92	t	t	t
7945	3	2026-03-02 22:23:42.117222	31.69	58.64	35.80	t	t	t
7946	4	2026-03-02 22:23:42.119912	10.02	11.08	39.44	t	f	t
7947	5	2026-03-02 22:23:42.120179	20.40	11.38	50.43	t	t	t
7948	3	2026-03-02 22:23:52.091589	47.88	17.98	33.20	t	t	t
7949	4	2026-03-02 22:23:52.091845	73.43	78.92	53.78	t	t	t
7950	5	2026-03-02 22:23:52.092094	17.41	27.10	39.47	t	t	t
7951	2	2026-03-02 22:23:52.092413	14.79	40.74	22.32	t	t	f
7952	2	2026-03-02 22:24:02.09191	24.45	75.00	30.18	t	t	t
7953	5	2026-03-02 22:24:02.092364	50.15	10.73	65.29	t	t	f
7954	3	2026-03-02 22:24:02.092693	25.96	23.38	30.00	t	t	t
7955	4	2026-03-02 22:24:02.092876	22.73	62.47	35.13	t	t	t
7956	3	2026-03-02 22:24:12.10532	56.41	65.35	66.74	t	f	t
7957	2	2026-03-02 22:24:12.13481	60.91	43.12	46.66	t	t	t
7958	5	2026-03-02 22:24:12.138749	67.65	73.68	22.92	t	t	t
7959	4	2026-03-02 22:24:12.265142	12.46	73.23	20.14	t	f	t
7960	2	2026-03-02 22:24:22.120061	19.82	46.78	61.35	t	t	t
7961	3	2026-03-02 22:24:22.120571	31.30	39.46	34.08	t	t	t
7962	4	2026-03-02 22:24:22.120848	73.35	37.94	43.15	t	t	t
7963	5	2026-03-02 22:24:22.150068	78.17	35.03	49.61	t	t	t
7964	2	2026-03-02 22:24:32.134596	40.78	45.72	67.64	t	f	t
7965	3	2026-03-02 22:24:32.165767	77.95	26.13	37.44	t	t	t
7966	4	2026-03-02 22:24:32.171703	32.61	55.38	32.93	t	t	f
7967	5	2026-03-02 22:24:32.172082	29.96	54.93	62.49	t	t	t
7968	2	2026-03-02 22:24:42.137257	58.42	77.77	55.36	t	f	f
7969	3	2026-03-02 22:24:42.137875	77.82	30.62	24.37	f	t	t
7970	5	2026-03-02 22:24:42.138048	31.48	20.18	51.35	t	t	t
7971	4	2026-03-02 22:24:42.138556	72.15	13.05	23.17	f	t	t
7972	2	2026-03-02 22:24:52.148721	25.84	10.68	30.86	t	t	t
7973	3	2026-03-02 22:24:52.180828	65.41	73.55	38.05	t	t	t
7974	5	2026-03-02 22:24:52.183497	28.97	37.63	68.95	t	t	t
7975	4	2026-03-02 22:24:52.186138	72.08	42.49	24.25	t	t	t
7976	2	2026-03-02 22:25:02.161497	38.09	67.45	44.66	t	t	t
7977	3	2026-03-02 22:25:02.161654	24.78	62.46	33.39	t	t	t
7978	4	2026-03-02 22:25:02.161744	51.00	39.57	35.77	t	t	t
7979	5	2026-03-02 22:25:02.191675	61.02	47.14	67.96	t	t	t
7980	2	2026-03-02 22:25:12.16716	77.94	51.04	32.23	t	t	t
7981	5	2026-03-02 22:25:12.168639	27.44	29.93	46.35	t	t	t
7982	4	2026-03-02 22:25:12.168789	59.95	11.39	66.75	t	t	t
7983	3	2026-03-02 22:25:12.168952	44.28	18.84	29.10	t	t	t
7984	2	2026-03-02 22:25:22.182434	26.34	44.86	67.93	t	t	t
7985	3	2026-03-02 22:25:22.21372	17.38	58.83	45.95	t	t	t
7986	5	2026-03-02 22:25:22.215242	50.17	14.76	63.24	t	t	t
7987	4	2026-03-02 22:25:22.326037	65.83	43.01	55.80	t	f	t
7988	5	2026-03-02 22:25:32.185127	30.19	11.81	46.22	t	t	t
7989	4	2026-03-02 22:25:32.185193	56.79	14.13	31.61	t	t	f
7990	2	2026-03-02 22:25:32.185101	20.49	20.12	27.00	t	t	t
7991	3	2026-03-02 22:25:32.185296	79.20	73.80	24.72	t	t	t
7992	2	2026-03-02 22:25:42.197217	71.69	75.05	36.51	f	t	t
7993	3	2026-03-02 22:25:42.228544	51.13	10.93	23.11	t	f	t
7994	5	2026-03-02 22:25:42.231642	73.93	45.56	27.08	t	t	t
7995	4	2026-03-02 22:25:42.337948	49.84	37.87	28.16	t	t	t
7996	2	2026-03-02 22:25:52.210692	64.51	33.55	26.23	t	t	t
7997	4	2026-03-02 22:25:52.21208	14.76	43.15	59.75	t	t	f
7998	3	2026-03-02 22:25:52.212242	66.86	43.23	36.01	f	t	t
7999	5	2026-03-02 22:25:52.24251	39.18	27.36	54.32	t	t	t
8000	3	2026-03-02 22:26:02.216613	46.42	67.97	52.09	t	t	t
8001	5	2026-03-02 22:26:02.216813	66.43	41.89	61.39	t	t	t
8002	2	2026-03-02 22:26:02.217154	38.27	52.10	37.56	t	t	t
8003	4	2026-03-02 22:26:02.217236	53.21	45.15	41.84	t	t	t
8004	3	2026-03-02 22:26:12.230141	19.29	57.47	24.77	t	t	t
8005	2	2026-03-02 22:26:12.264534	22.71	33.37	36.41	t	t	t
8006	4	2026-03-02 22:26:12.265003	15.27	75.98	64.40	t	t	f
8007	5	2026-03-02 22:26:12.266534	52.93	70.21	28.66	t	f	t
8008	2	2026-03-02 22:26:22.233761	29.20	41.93	60.29	t	t	t
8009	5	2026-03-02 22:26:22.233955	57.54	40.48	51.86	t	t	t
8010	3	2026-03-02 22:26:22.234286	22.69	55.53	30.19	t	t	t
8011	4	2026-03-02 22:26:22.234444	67.71	59.87	33.12	t	t	t
8012	2	2026-03-02 22:26:32.243332	74.24	50.09	63.54	t	t	t
8013	3	2026-03-02 22:26:32.279048	34.33	59.86	66.45	t	t	f
8014	4	2026-03-02 22:26:32.28013	16.32	15.10	27.39	t	t	t
8015	5	2026-03-02 22:26:32.283522	62.21	57.72	48.82	t	t	t
8016	2	2026-03-02 22:26:42.258089	53.88	42.37	36.09	t	t	t
8017	4	2026-03-02 22:26:42.258652	38.25	34.52	51.83	t	t	t
8018	3	2026-03-02 22:26:42.258871	45.59	38.83	47.40	t	t	t
8019	5	2026-03-02 22:26:42.287952	13.02	21.54	45.83	t	t	t
8020	2	2026-03-02 22:26:52.261643	17.44	68.44	52.14	t	t	f
8021	5	2026-03-02 22:26:52.261834	42.54	79.00	67.52	t	t	t
8022	4	2026-03-02 22:26:52.262511	55.88	51.90	60.22	t	t	t
8023	3	2026-03-02 22:26:52.262878	10.87	67.23	43.78	t	t	t
8024	2	2026-03-02 22:27:02.2738	16.29	67.84	36.51	t	t	t
8025	3	2026-03-02 22:27:02.308084	21.20	31.26	30.68	t	f	t
8026	4	2026-03-02 22:27:02.308387	49.98	20.21	46.83	t	t	t
8027	5	2026-03-02 22:27:02.310953	14.09	40.98	48.57	t	t	t
8028	2	2026-03-02 22:27:12.279244	20.07	18.75	27.39	t	t	t
8029	4	2026-03-02 22:27:12.279617	21.08	59.32	34.12	t	t	f
8030	5	2026-03-02 22:27:12.279961	37.37	60.25	30.75	t	t	t
8031	3	2026-03-02 22:27:12.280253	34.46	57.26	23.45	t	t	t
8032	2	2026-03-02 22:27:22.292717	72.57	60.02	65.80	t	t	t
8033	3	2026-03-02 22:27:22.324243	46.32	43.08	62.42	t	t	t
8034	4	2026-03-02 22:27:22.326117	56.81	71.96	36.07	t	t	t
8035	5	2026-03-02 22:27:22.327599	54.90	35.76	38.62	t	t	t
8036	2	2026-03-02 22:27:32.308038	61.96	76.37	28.94	t	t	f
8037	3	2026-03-02 22:27:32.308338	45.26	78.77	42.31	t	t	t
8038	4	2026-03-02 22:27:32.308509	21.93	18.45	26.33	t	t	t
7823	4	2026-03-02 22:18:31.798233	23.00	58.30	24.55	t	t	t
7825	4	2026-03-02 22:18:41.840246	23.15	48.50	59.62	t	t	t
7826	5	2026-03-02 22:18:41.840531	47.14	69.77	24.78	t	t	f
7827	3	2026-03-02 22:18:41.948638	21.51	44.83	69.56	t	t	f
7828	2	2026-03-02 22:18:51.821571	61.68	42.20	47.23	t	t	t
7829	4	2026-03-02 22:18:51.822318	16.99	23.29	31.51	t	t	t
7830	3	2026-03-02 22:18:51.822665	48.18	70.56	49.30	t	t	t
7831	5	2026-03-02 22:18:51.966003	18.66	46.77	24.99	t	t	t
7832	2	2026-03-02 22:19:01.826232	27.59	18.52	24.25	t	t	f
7833	5	2026-03-02 22:19:01.826399	54.37	75.26	34.38	t	f	f
7834	3	2026-03-02 22:19:01.826662	66.70	16.07	44.87	t	t	f
7835	4	2026-03-02 22:19:01.826959	43.38	11.16	61.73	t	t	t
7836	2	2026-03-02 22:19:11.836464	54.42	77.38	57.13	t	f	t
7837	3	2026-03-02 22:19:11.867786	59.53	11.63	54.58	t	t	t
7838	5	2026-03-02 22:19:11.871773	57.61	13.98	36.89	t	t	t
7839	4	2026-03-02 22:19:11.97939	64.47	24.40	27.16	t	t	f
7840	2	2026-03-02 22:19:21.841391	26.11	40.04	30.34	t	t	t
7841	5	2026-03-02 22:19:21.841651	57.94	77.67	55.84	t	t	t
7842	3	2026-03-02 22:19:21.841807	39.05	74.30	63.83	t	t	t
7843	4	2026-03-02 22:19:21.842078	60.75	10.92	48.43	t	t	t
7844	2	2026-03-02 22:19:31.841137	28.82	63.85	43.12	t	f	t
7845	5	2026-03-02 22:19:31.841402	11.24	18.27	59.25	t	t	t
7846	3	2026-03-02 22:19:31.841606	29.22	46.61	32.98	t	t	t
7847	4	2026-03-02 22:19:31.841795	52.13	18.08	58.44	t	t	t
7848	2	2026-03-02 22:19:41.86607	34.35	25.66	28.10	t	t	t
7849	3	2026-03-02 22:19:41.900081	49.34	12.24	25.94	t	t	t
7850	4	2026-03-02 22:19:41.900399	73.84	48.34	60.43	t	t	t
7851	5	2026-03-02 22:19:41.901235	13.63	33.64	38.51	t	t	t
7852	3	2026-03-02 22:19:51.869918	47.61	27.51	22.10	t	t	t
7853	5	2026-03-02 22:19:51.870188	19.86	26.80	29.72	t	f	t
7854	4	2026-03-02 22:19:51.870409	26.08	20.23	52.01	t	t	t
7855	2	2026-03-02 22:19:51.870713	35.99	60.58	50.98	t	t	t
7856	2	2026-03-02 22:20:01.885445	64.07	21.06	23.21	t	t	t
7857	3	2026-03-02 22:20:01.917831	40.80	30.52	24.74	f	t	f
7858	4	2026-03-02 22:20:01.920094	55.24	25.89	64.88	t	t	f
7859	5	2026-03-02 22:20:01.922691	77.53	26.38	55.19	t	t	t
7860	3	2026-03-02 22:20:11.887331	35.98	68.71	68.48	t	t	t
7861	5	2026-03-02 22:20:11.887984	32.26	24.22	35.89	f	t	t
7862	2	2026-03-02 22:20:11.888157	13.35	22.85	41.20	t	t	t
7863	4	2026-03-02 22:20:11.888347	14.76	13.42	63.85	t	t	t
7864	2	2026-03-02 22:20:21.899252	25.48	41.19	34.78	t	t	t
7865	3	2026-03-02 22:20:21.931593	25.10	47.00	25.74	t	t	t
7866	4	2026-03-02 22:20:21.934432	65.15	50.19	41.23	t	f	t
7867	5	2026-03-02 22:20:22.040786	15.10	58.70	35.48	t	f	f
7868	3	2026-03-02 22:20:31.91085	35.34	76.83	51.65	t	t	f
7869	2	2026-03-02 22:20:31.911244	50.48	39.59	52.87	t	t	t
7870	4	2026-03-02 22:20:31.911508	66.49	35.11	41.68	t	t	t
7871	5	2026-03-02 22:20:31.941395	49.28	49.78	28.26	t	f	t
7872	2	2026-03-02 22:20:41.915943	45.68	29.22	40.14	t	f	t
7873	5	2026-03-02 22:20:41.916183	37.16	32.53	60.84	t	t	t
7874	3	2026-03-02 22:20:41.916281	44.24	20.39	53.86	t	t	f
7875	4	2026-03-02 22:20:41.916427	73.36	31.69	61.12	t	t	t
7876	2	2026-03-02 22:20:51.92916	16.58	67.28	23.62	t	f	t
7877	4	2026-03-02 22:20:51.959553	18.52	61.59	67.04	t	t	t
7878	5	2026-03-02 22:20:51.962859	12.35	78.07	38.72	t	t	t
7879	3	2026-03-02 22:20:52.07147	25.41	54.62	39.92	t	t	t
7880	2	2026-03-02 22:21:01.934459	38.53	61.17	60.32	t	t	t
7881	3	2026-03-02 22:21:01.934824	69.79	21.03	50.72	t	f	t
7882	5	2026-03-02 22:21:01.935108	37.32	75.14	39.42	t	t	t
7883	4	2026-03-02 22:21:01.935539	49.46	66.17	59.71	t	t	t
7884	2	2026-03-02 22:21:11.944777	48.64	35.42	35.99	t	t	t
7885	3	2026-03-02 22:21:11.974222	24.83	75.84	23.41	t	t	t
7886	5	2026-03-02 22:21:11.976777	54.66	25.80	35.37	t	t	t
7887	4	2026-03-02 22:21:12.091094	15.56	38.72	59.39	f	t	f
7888	2	2026-03-02 22:21:21.950211	41.51	77.07	41.62	t	t	t
7889	3	2026-03-02 22:21:21.9503	59.38	69.85	57.90	t	t	t
7890	4	2026-03-02 22:21:21.950483	61.21	23.01	56.93	t	t	t
7891	5	2026-03-02 22:21:22.092297	77.94	19.47	43.99	t	t	f
7892	2	2026-03-02 22:21:31.965504	50.70	27.32	34.22	f	t	t
7893	3	2026-03-02 22:21:31.997945	16.94	77.94	23.57	t	f	t
7894	4	2026-03-02 22:21:32.003439	39.35	30.12	21.55	t	t	t
7895	5	2026-03-02 22:21:32.003693	54.30	31.75	23.47	t	t	t
7896	4	2026-03-02 22:21:41.965685	60.27	56.71	53.21	t	t	t
7897	5	2026-03-02 22:21:41.966035	50.34	74.37	52.49	t	t	t
7898	2	2026-03-02 22:21:41.966256	20.80	29.05	29.13	t	t	t
7899	3	2026-03-02 22:21:41.966256	20.56	48.13	38.94	t	t	f
7900	3	2026-03-02 22:21:51.976498	64.88	14.04	55.60	t	t	t
7901	2	2026-03-02 22:21:52.008948	47.03	20.47	53.93	t	t	t
7902	4	2026-03-02 22:21:52.014022	56.51	18.04	34.04	t	t	f
7903	5	2026-03-02 22:21:52.014416	10.95	73.25	31.51	t	t	t
7904	2	2026-03-02 22:22:01.979895	41.59	52.56	54.28	t	t	t
7905	5	2026-03-02 22:22:01.980216	35.80	56.34	68.29	t	t	t
7906	3	2026-03-02 22:22:01.980457	55.85	72.33	39.85	t	t	t
7907	4	2026-03-02 22:22:01.980681	49.14	40.65	33.52	t	t	t
7908	2	2026-03-02 22:22:11.99066	18.98	50.74	50.80	t	t	t
7909	3	2026-03-02 22:22:12.024177	40.77	25.17	68.43	t	t	t
7910	4	2026-03-02 22:22:12.024891	54.86	29.25	64.28	t	f	t
7911	5	2026-03-02 22:22:12.028174	27.30	38.23	61.97	t	t	t
7912	2	2026-03-02 22:22:22.008167	18.65	80.00	53.94	t	t	f
7913	3	2026-03-02 22:22:22.008476	61.70	31.67	40.66	t	t	t
7914	4	2026-03-02 22:22:22.008717	33.78	14.81	22.38	t	t	t
7915	5	2026-03-02 22:22:22.03668	43.85	20.46	42.11	f	t	t
7916	2	2026-03-02 22:22:32.014205	29.66	25.84	28.95	t	f	f
7917	5	2026-03-02 22:22:32.014426	39.92	67.74	63.82	t	t	t
7918	3	2026-03-02 22:22:32.014579	15.09	16.96	63.60	t	t	t
7919	4	2026-03-02 22:22:32.014897	40.46	38.90	27.41	t	t	t
7920	3	2026-03-02 22:22:42.02033	50.06	45.80	49.78	t	t	t
7921	2	2026-03-02 22:22:42.02091	32.36	70.89	43.45	t	t	t
7922	4	2026-03-02 22:22:42.02137	28.95	54.67	46.71	t	t	t
7923	5	2026-03-02 22:22:42.050983	37.09	71.30	53.78	t	t	t
7924	2	2026-03-02 22:22:52.038474	39.24	12.72	22.40	t	t	t
7925	3	2026-03-02 22:22:52.068404	47.86	79.41	43.26	t	t	t
7926	4	2026-03-02 22:22:52.072743	10.02	20.14	39.34	t	t	f
7927	5	2026-03-02 22:22:52.075249	57.78	57.95	46.03	t	t	t
7928	2	2026-03-02 22:23:02.044098	12.16	33.54	44.40	t	t	t
7929	5	2026-03-02 22:23:02.044458	47.14	72.61	33.54	t	t	t
7930	3	2026-03-02 22:23:02.044546	29.08	34.24	38.78	t	t	t
7931	4	2026-03-02 22:23:02.044807	11.16	16.43	41.47	t	t	t
8039	5	2026-03-02 22:27:32.339383	70.22	40.69	50.92	t	t	t
8040	2	2026-03-02 22:27:42.310047	25.74	46.59	30.48	t	t	t
8041	5	2026-03-02 22:27:42.310322	54.86	64.59	52.31	t	t	t
8042	3	2026-03-02 22:27:42.310479	67.40	10.23	32.64	t	t	t
8045	2	2026-03-02 22:27:52.350515	36.97	38.31	67.64	t	t	t
8050	4	2026-03-02 22:28:02.337823	54.65	31.81	64.61	t	t	t
8051	5	2026-03-02 22:28:02.369304	55.09	29.53	57.71	t	t	f
8052	2	2026-03-02 22:28:12.344975	26.17	14.71	48.32	t	t	f
8055	4	2026-03-02 22:28:12.345703	39.27	41.43	43.25	t	t	f
8059	5	2026-03-02 22:28:22.393598	58.77	48.36	53.15	t	f	f
8060	2	2026-03-02 22:28:32.354847	75.37	16.19	24.56	t	t	t
8067	4	2026-03-02 22:28:42.514561	57.12	42.62	65.67	t	t	t
8068	2	2026-03-02 22:28:52.384254	23.99	78.65	34.86	t	t	f
8073	5	2026-03-02 22:29:02.387689	45.82	71.85	67.82	t	t	f
8078	5	2026-03-02 22:29:12.430966	25.84	28.39	48.32	t	t	f
8082	3	2026-03-02 22:29:22.402899	52.41	26.05	22.91	t	t	t
8085	4	2026-03-02 22:29:32.399307	12.58	54.48	22.28	t	t	t
8090	4	2026-03-02 22:29:42.401862	78.27	51.96	53.25	t	t	t
8093	3	2026-03-02 22:29:52.397239	22.16	77.71	38.15	t	t	t
8097	3	2026-03-02 22:30:02.440826	12.42	44.00	22.70	t	t	t
8103	4	2026-03-02 22:30:12.41278	54.76	34.28	35.39	t	t	f
8105	3	2026-03-02 22:30:22.457912	71.61	79.45	42.91	t	t	t
8111	5	2026-03-02 22:30:32.453684	52.47	15.43	69.52	t	t	t
8112	3	2026-03-02 22:30:42.438231	65.07	31.40	57.64	t	t	t
8115	5	2026-03-02 22:30:42.480085	56.26	21.01	47.46	t	t	t
8116	2	2026-03-02 22:30:52.451499	44.50	77.95	69.06	t	t	t
8123	5	2026-03-02 22:31:02.516596	67.14	18.40	63.17	t	t	f
8127	5	2026-03-02 22:31:12.613787	12.02	44.66	26.82	t	f	t
8129	3	2026-03-02 22:31:22.473439	37.54	56.74	54.44	t	t	t
8135	4	2026-03-02 22:31:32.478011	76.73	44.32	40.70	t	t	t
8136	2	2026-03-02 22:31:42.480413	37.29	42.47	23.50	t	t	t
8142	4	2026-03-02 22:31:52.540947	34.01	24.48	53.19	t	t	t
8145	2	2026-03-02 22:32:02.518295	24.37	54.05	45.72	t	t	f
8147	5	2026-03-02 22:32:02.551248	15.83	20.54	35.16	t	t	t
8148	2	2026-03-02 22:32:12.51515	66.96	40.73	61.81	t	f	t
8149	5	2026-03-02 22:32:12.515245	29.00	47.33	42.95	t	f	t
8155	5	2026-03-02 22:32:22.670579	70.58	41.86	24.17	t	t	f
8156	2	2026-03-02 22:32:32.532913	65.78	58.60	24.75	t	t	f
8161	5	2026-03-02 22:32:42.533724	34.47	16.10	34.09	t	t	t
8166	2	2026-03-02 22:32:52.539945	55.19	10.77	51.93	t	t	t
8168	2	2026-03-02 22:33:02.540887	79.30	13.00	62.18	t	t	f
8173	5	2026-03-02 22:33:12.536389	28.30	72.42	45.19	t	t	t
8179	4	2026-03-02 22:33:22.591547	45.15	28.63	59.11	t	t	t
8180	2	2026-03-02 22:33:32.55992	24.49	77.17	65.55	t	t	t
8186	4	2026-03-02 22:33:42.605851	33.41	44.44	36.91	t	t	t
8190	5	2026-03-02 22:33:52.571272	49.10	49.32	63.38	t	t	f
8192	2	2026-03-02 22:34:02.583856	19.60	60.58	30.96	t	t	t
8199	5	2026-03-02 22:34:12.584443	74.09	22.36	43.29	t	t	t
8200	3	2026-03-02 22:34:22.583863	59.93	51.38	40.38	t	t	t
8205	5	2026-03-02 22:34:32.587866	39.52	67.77	66.28	t	f	t
8209	2	2026-03-02 22:34:42.600491	78.27	76.49	34.62	t	t	t
8211	5	2026-03-02 22:34:42.634064	79.69	69.04	42.26	t	f	t
8213	2	2026-03-02 22:34:52.600492	38.80	37.34	55.10	t	t	t
8215	4	2026-03-02 22:34:52.600903	44.08	72.32	31.51	t	t	t
8218	3	2026-03-02 22:35:02.601412	73.39	78.25	51.19	t	t	f
8219	4	2026-03-02 22:35:02.601701	69.60	14.14	64.89	t	t	t
8221	4	2026-03-02 22:35:12.59554	45.47	70.75	37.38	t	t	t
8223	3	2026-03-02 22:35:12.595707	74.74	60.56	29.66	t	t	t
8224	2	2026-03-02 22:35:22.59812	34.11	60.51	64.72	t	t	t
8226	4	2026-03-02 22:35:22.598607	77.57	77.60	36.59	t	t	t
8229	3	2026-03-02 22:35:32.597841	36.18	15.74	57.27	f	t	t
8230	5	2026-03-02 22:35:32.598189	24.26	55.44	47.96	t	t	t
8232	3	2026-03-02 22:35:42.610616	53.90	28.27	65.86	t	t	t
8235	4	2026-03-02 22:35:42.649688	73.18	69.03	41.29	t	t	t
8237	5	2026-03-02 22:35:52.610531	27.72	66.60	49.52	t	t	f
8239	3	2026-03-02 22:35:52.610656	53.99	42.66	38.89	t	t	f
8241	3	2026-03-02 22:36:02.630967	79.59	13.79	38.43	t	t	f
8242	4	2026-03-02 22:36:02.63131	22.55	46.17	24.15	t	f	t
8244	2	2026-03-02 22:36:12.635013	29.30	76.59	35.07	t	t	f
8247	4	2026-03-02 22:36:12.635711	42.64	69.65	40.84	t	t	t
8248	2	2026-03-02 22:36:22.651588	74.32	65.08	30.95	t	t	t
8250	4	2026-03-02 22:36:22.684521	20.25	34.10	21.19	t	f	t
8252	3	2026-03-02 22:36:32.6599	15.34	38.58	40.11	t	t	t
8257	3	2026-03-02 22:36:42.707174	50.59	47.34	23.08	t	t	t
8261	4	2026-03-02 22:36:52.672413	10.47	19.25	41.48	t	t	t
8263	5	2026-03-02 22:36:52.7052	61.70	50.74	30.34	t	t	t
8264	2	2026-03-02 22:37:02.676891	69.17	26.27	64.39	t	f	t
8271	4	2026-03-02 22:37:12.680164	41.96	20.25	41.19	t	t	t
8272	5	2026-03-02 22:37:22.68329	46.09	42.74	57.14	t	t	t
8277	3	2026-03-02 22:37:32.726605	22.92	34.58	40.94	t	t	f
8281	4	2026-03-02 22:37:42.696095	26.15	59.05	22.18	t	t	t
8285	3	2026-03-02 22:37:52.754591	58.80	59.39	62.00	t	t	t
8289	4	2026-03-02 22:38:02.704398	57.63	30.22	25.29	t	t	t
8293	4	2026-03-02 22:38:12.754107	43.04	22.94	39.03	f	t	t
8298	4	2026-03-02 22:38:22.717671	42.43	73.56	56.85	t	t	t
8301	3	2026-03-02 22:38:32.763514	25.56	74.30	46.38	t	f	f
8307	4	2026-03-02 22:38:42.7363	48.57	64.18	37.98	f	t	t
8309	3	2026-03-02 22:38:52.780003	16.50	78.80	39.91	f	t	t
8312	4	2026-03-02 22:39:02.757373	66.76	55.19	20.47	t	t	t
8315	5	2026-03-02 22:39:02.788359	68.87	59.98	27.09	t	t	t
8316	2	2026-03-02 22:39:12.764393	41.75	41.03	51.57	t	t	t
8319	5	2026-03-02 22:39:12.804605	19.87	12.22	66.64	t	t	t
8322	4	2026-03-02 22:39:22.782191	71.66	18.01	53.47	t	t	t
8326	4	2026-03-02 22:39:32.827567	47.25	58.38	34.65	t	t	t
8330	3	2026-03-02 22:39:42.807366	47.52	10.99	69.22	t	t	t
8333	3	2026-03-02 22:39:52.809833	21.07	35.11	25.93	f	t	t
8335	5	2026-03-02 22:39:52.810235	41.69	76.06	65.78	t	t	t
8336	2	2026-03-02 22:40:02.819524	68.29	62.42	34.24	t	t	t
8338	4	2026-03-02 22:40:02.856437	55.83	67.92	21.79	t	f	t
8341	3	2026-03-02 22:40:12.826098	54.67	23.36	38.23	t	t	t
8343	5	2026-03-02 22:40:12.857807	41.00	16.03	46.39	t	f	t
8344	2	2026-03-02 22:40:22.838067	32.61	70.45	55.72	t	t	t
8346	4	2026-03-02 22:40:22.873603	20.82	19.59	44.37	t	t	t
8349	3	2026-03-02 22:40:32.837536	16.65	32.74	38.72	t	t	t
8351	5	2026-03-02 22:40:32.837724	57.08	16.46	46.55	t	t	t
8352	2	2026-03-02 22:40:42.838752	67.03	47.97	69.77	t	t	t
8355	4	2026-03-02 22:40:42.839508	23.27	48.41	65.83	t	t	t
8356	2	2026-03-02 22:40:52.847264	27.07	41.50	55.65	t	t	t
8357	5	2026-03-02 22:40:52.879779	25.00	24.08	29.37	t	t	t
8359	4	2026-03-02 22:40:52.991544	46.65	12.71	58.00	t	t	t
8361	5	2026-03-02 22:41:02.851321	45.23	34.87	49.41	t	t	t
8043	4	2026-03-02 22:27:42.310695	12.74	50.79	44.76	t	f	t
8044	3	2026-03-02 22:27:52.317651	63.80	39.64	23.67	t	t	t
8046	4	2026-03-02 22:27:52.354586	67.35	47.57	57.15	t	t	t
8049	3	2026-03-02 22:28:02.337722	10.64	38.34	24.98	t	t	t
8053	5	2026-03-02 22:28:12.345249	18.55	24.58	69.10	t	t	t
8057	3	2026-03-02 22:28:22.387743	53.27	38.64	38.79	t	t	t
8062	4	2026-03-02 22:28:32.35522	54.24	34.90	65.25	t	t	t
8064	2	2026-03-02 22:28:42.370494	20.59	43.91	49.31	t	t	t
8065	3	2026-03-02 22:28:42.399863	77.62	12.08	55.97	t	t	t
8069	4	2026-03-02 22:28:52.384708	61.31	65.34	69.42	t	t	t
8071	5	2026-03-02 22:28:52.413317	69.77	59.43	55.35	t	t	t
8074	3	2026-03-02 22:29:02.387849	32.72	55.84	52.37	t	t	t
8075	2	2026-03-02 22:29:02.388116	25.84	51.09	24.03	t	t	t
8076	2	2026-03-02 22:29:12.396749	50.89	26.00	60.73	t	t	t
8079	3	2026-03-02 22:29:12.542644	41.51	23.89	55.38	t	t	t
8080	2	2026-03-02 22:29:22.402398	23.66	75.18	28.17	t	t	t
8081	5	2026-03-02 22:29:22.402658	27.87	55.04	69.95	t	t	t
8086	5	2026-03-02 22:29:32.399548	57.24	56.52	68.00	f	t	f
8087	3	2026-03-02 22:29:32.399651	61.07	19.65	39.65	t	t	t
8088	2	2026-03-02 22:29:42.401455	13.88	52.51	43.36	t	t	t
8091	3	2026-03-02 22:29:42.402178	20.04	10.59	28.78	t	t	f
8094	4	2026-03-02 22:29:52.397505	36.34	75.42	42.78	t	t	f
8095	5	2026-03-02 22:29:52.397768	66.62	41.07	20.08	t	t	t
8098	4	2026-03-02 22:30:02.443492	76.83	17.91	26.52	t	t	t
8102	3	2026-03-02 22:30:12.412706	14.12	41.47	59.63	t	t	t
8104	2	2026-03-02 22:30:22.42435	12.99	78.55	67.36	t	f	f
8106	4	2026-03-02 22:30:22.458233	71.47	21.24	23.42	t	f	t
8109	2	2026-03-02 22:30:32.423497	13.69	51.50	66.35	t	t	f
8110	4	2026-03-02 22:30:32.423744	73.85	11.43	62.30	t	t	t
8113	2	2026-03-02 22:30:42.472094	70.84	35.44	48.10	t	t	t
8118	4	2026-03-02 22:30:52.452699	13.16	29.17	32.06	f	t	t
8119	5	2026-03-02 22:30:52.483419	30.97	77.24	39.45	t	t	t
8120	2	2026-03-02 22:31:02.460161	75.25	32.68	22.76	t	t	t
8121	3	2026-03-02 22:31:02.460286	33.11	70.48	48.51	t	t	t
8125	3	2026-03-02 22:31:12.464777	33.20	20.43	34.96	t	t	t
8130	4	2026-03-02 22:31:22.502786	27.74	13.08	25.14	f	t	t
8134	2	2026-03-02 22:31:32.477745	20.13	32.25	68.74	t	t	t
8139	4	2026-03-02 22:31:42.481069	12.46	22.55	24.05	t	t	t
8140	2	2026-03-02 22:31:52.508858	19.77	11.88	32.80	t	t	t
8143	5	2026-03-02 22:31:52.544196	45.69	76.54	62.59	t	t	t
8144	3	2026-03-02 22:32:02.51821	48.87	25.22	35.46	t	t	t
8151	4	2026-03-02 22:32:12.515412	42.54	66.72	37.77	t	t	f
8153	3	2026-03-02 22:32:22.563603	20.45	28.68	48.27	f	t	t
8159	4	2026-03-02 22:32:32.534125	63.43	18.08	38.71	t	t	f
8160	2	2026-03-02 22:32:42.53353	61.46	22.72	27.16	t	t	f
8165	5	2026-03-02 22:32:52.539675	78.45	70.42	55.88	f	t	t
8171	4	2026-03-02 22:33:02.541242	62.36	32.62	34.78	t	t	t
8174	3	2026-03-02 22:33:12.53649	37.32	52.60	65.97	t	t	t
8176	2	2026-03-02 22:33:22.551181	79.88	70.70	40.86	t	t	t
8177	3	2026-03-02 22:33:22.584208	45.75	68.26	22.79	f	t	t
8182	4	2026-03-02 22:33:32.56038	22.41	15.17	35.81	t	t	t
8183	5	2026-03-02 22:33:32.591285	45.21	52.62	69.05	t	t	f
8184	2	2026-03-02 22:33:42.568962	45.99	12.84	36.41	t	f	t
8187	5	2026-03-02 22:33:42.610898	46.53	39.55	49.61	f	t	f
8188	2	2026-03-02 22:33:52.570587	17.83	56.29	46.54	t	t	t
8191	4	2026-03-02 22:33:52.571291	19.62	41.93	33.66	t	t	t
8193	3	2026-03-02 22:34:02.584324	33.41	30.26	53.89	t	t	t
8194	5	2026-03-02 22:34:02.584545	37.07	68.22	42.23	t	t	t
8196	4	2026-03-02 22:34:12.582472	47.06	57.29	62.63	t	t	f
8197	2	2026-03-02 22:34:12.583335	24.26	53.07	24.56	f	t	t
8201	2	2026-03-02 22:34:22.584222	31.56	11.85	36.52	t	f	t
8203	5	2026-03-02 22:34:22.58436	73.79	47.48	40.15	t	t	t
8204	3	2026-03-02 22:34:32.587577	65.27	72.67	24.19	t	t	t
8207	4	2026-03-02 22:34:32.588303	38.90	24.57	27.41	t	t	f
8208	3	2026-03-02 22:34:42.600299	77.63	15.00	50.70	t	t	t
8214	5	2026-03-02 22:34:52.600788	25.38	70.61	32.34	t	t	t
8216	2	2026-03-02 22:35:02.601068	33.43	65.68	24.53	t	t	f
8222	5	2026-03-02 22:35:12.595658	72.55	50.96	65.18	t	t	t
8225	3	2026-03-02 22:35:22.598473	58.40	69.06	40.76	t	t	t
8231	4	2026-03-02 22:35:32.598257	79.20	61.85	33.28	t	t	t
8233	2	2026-03-02 22:35:42.644615	78.57	58.77	22.94	t	t	t
8236	4	2026-03-02 22:35:52.610319	23.52	78.20	25.69	t	t	t
8243	5	2026-03-02 22:36:02.663262	56.63	45.69	29.19	t	t	f
8246	3	2026-03-02 22:36:12.635503	37.08	75.23	39.94	t	t	t
8251	5	2026-03-02 22:36:22.805269	38.94	31.81	50.70	t	t	t
8254	2	2026-03-02 22:36:32.659834	18.17	66.37	25.67	t	t	t
8258	4	2026-03-02 22:36:42.709118	44.97	19.54	42.71	t	t	t
8262	3	2026-03-02 22:36:52.672506	78.37	18.52	28.03	t	t	t
8265	3	2026-03-02 22:37:02.676957	53.47	53.58	46.96	t	t	t
8266	4	2026-03-02 22:37:02.707939	65.75	53.06	61.74	t	t	t
8269	5	2026-03-02 22:37:12.680208	29.92	12.65	38.27	t	t	t
8270	3	2026-03-02 22:37:12.68032	33.39	48.91	41.79	t	t	t
8274	2	2026-03-02 22:37:22.683708	63.58	37.02	45.71	t	t	t
8275	4	2026-03-02 22:37:22.683913	48.02	16.05	33.38	t	t	t
8276	2	2026-03-02 22:37:32.693455	41.48	36.88	20.12	t	t	t
8278	4	2026-03-02 22:37:32.726791	20.58	20.10	43.87	t	t	t
8282	3	2026-03-02 22:37:42.696261	34.18	71.14	62.57	t	t	t
8283	5	2026-03-02 22:37:42.696433	46.16	30.49	59.72	t	t	t
8284	2	2026-03-02 22:37:52.704337	70.70	44.24	60.94	t	t	f
8286	4	2026-03-02 22:37:52.75635	26.77	12.28	64.57	t	t	t
8290	5	2026-03-02 22:38:02.704826	49.42	36.18	33.59	t	t	t
8291	3	2026-03-02 22:38:02.704893	46.46	61.25	60.70	t	t	t
8292	2	2026-03-02 22:38:12.71322	52.70	72.29	52.28	t	t	t
8294	3	2026-03-02 22:38:12.754894	51.96	13.80	47.03	t	t	f
8297	5	2026-03-02 22:38:22.7175	48.44	20.89	44.33	t	t	t
8299	3	2026-03-02 22:38:22.718615	12.51	74.33	41.93	t	t	t
8300	2	2026-03-02 22:38:32.729942	49.48	62.22	40.80	t	t	f
8302	4	2026-03-02 22:38:32.765599	36.94	49.60	57.29	t	t	t
8305	3	2026-03-02 22:38:42.735679	53.28	25.68	61.23	t	f	t
8306	5	2026-03-02 22:38:42.736062	73.64	33.31	32.95	t	t	t
8308	2	2026-03-02 22:38:52.747138	59.19	75.21	33.90	t	f	t
8310	4	2026-03-02 22:38:52.784786	70.14	24.76	35.30	t	t	t
8313	3	2026-03-02 22:39:02.757505	17.34	59.24	68.67	t	t	t
8317	4	2026-03-02 22:39:12.804318	47.75	54.58	32.11	t	t	t
8320	2	2026-03-02 22:39:22.781811	79.09	59.20	28.33	f	t	t
8323	5	2026-03-02 22:39:22.813179	52.64	69.45	65.20	t	f	f
8324	2	2026-03-02 22:39:32.790156	14.70	46.04	60.82	t	t	f
8327	5	2026-03-02 22:39:32.832282	18.23	70.26	22.53	f	t	t
8328	2	2026-03-02 22:39:42.806662	72.85	52.75	42.10	t	t	t
8047	5	2026-03-02 22:27:52.354875	47.85	55.34	26.54	t	t	t
8048	2	2026-03-02 22:28:02.337631	77.83	23.80	62.15	t	t	t
8054	3	2026-03-02 22:28:12.345421	72.68	49.77	43.81	t	t	t
8056	2	2026-03-02 22:28:22.356451	24.93	40.21	47.33	t	t	t
8058	4	2026-03-02 22:28:22.391518	64.13	57.25	59.37	f	t	t
8061	5	2026-03-02 22:28:32.355012	11.23	13.70	58.99	t	t	t
8063	3	2026-03-02 22:28:32.355447	23.15	21.67	53.34	t	t	f
8066	5	2026-03-02 22:28:42.404411	70.71	27.19	38.28	t	t	f
8070	3	2026-03-02 22:28:52.384894	14.49	39.75	58.42	t	t	t
8072	4	2026-03-02 22:29:02.387436	30.78	28.76	68.21	t	t	t
8077	4	2026-03-02 22:29:12.430177	34.54	17.57	30.06	t	t	t
8083	4	2026-03-02 22:29:22.402966	56.24	36.93	20.20	t	t	t
8084	2	2026-03-02 22:29:32.398754	73.02	10.26	26.97	t	t	t
8089	5	2026-03-02 22:29:42.401709	27.93	55.48	20.44	t	t	f
8092	2	2026-03-02 22:29:52.396817	70.31	34.81	31.49	t	t	t
8096	2	2026-03-02 22:30:02.406231	60.24	47.38	45.75	t	t	t
8099	5	2026-03-02 22:30:02.445037	78.48	48.15	57.55	t	t	t
8100	2	2026-03-02 22:30:12.412324	73.38	34.34	54.52	t	t	t
8101	5	2026-03-02 22:30:12.412503	15.41	25.52	35.20	t	f	f
8107	5	2026-03-02 22:30:22.460301	17.47	20.86	66.95	t	t	t
8108	3	2026-03-02 22:30:32.423292	31.83	76.91	41.69	t	t	t
8114	4	2026-03-02 22:30:42.477795	77.98	34.31	39.22	t	t	f
8117	3	2026-03-02 22:30:52.452593	39.33	30.21	63.89	t	t	f
8122	4	2026-03-02 22:31:02.509602	67.67	21.74	67.49	t	t	t
8124	2	2026-03-02 22:31:12.464375	16.51	28.32	31.94	t	f	t
8126	4	2026-03-02 22:31:12.497472	26.85	41.03	59.62	t	t	t
8128	2	2026-03-02 22:31:22.473269	47.51	33.39	69.37	t	f	t
8131	5	2026-03-02 22:31:22.61824	55.47	63.85	32.29	t	t	t
8132	3	2026-03-02 22:31:32.47732	13.29	58.69	33.65	t	t	t
8133	5	2026-03-02 22:31:32.477585	79.19	73.60	55.27	t	t	t
8137	5	2026-03-02 22:31:42.480843	28.84	34.22	62.01	t	t	f
8138	3	2026-03-02 22:31:42.481083	43.00	68.83	48.69	t	t	t
8141	3	2026-03-02 22:31:52.50902	13.61	10.86	65.63	t	t	t
8146	4	2026-03-02 22:32:02.550002	10.12	67.38	29.63	t	t	t
8150	3	2026-03-02 22:32:12.515354	32.73	20.17	55.53	t	t	t
8152	2	2026-03-02 22:32:22.530802	56.92	55.46	34.24	t	t	t
8154	4	2026-03-02 22:32:22.564469	24.46	46.37	65.56	t	t	t
8157	5	2026-03-02 22:32:32.533594	15.22	35.20	47.90	t	t	t
8158	3	2026-03-02 22:32:32.533938	62.13	78.65	20.78	t	t	t
8162	4	2026-03-02 22:32:42.533816	38.28	60.53	38.69	t	t	t
8163	3	2026-03-02 22:32:42.533808	72.05	22.21	50.74	t	f	t
8164	4	2026-03-02 22:32:52.539102	64.88	43.40	22.85	t	t	t
8167	3	2026-03-02 22:32:52.540031	70.91	27.67	58.12	t	t	t
8169	5	2026-03-02 22:33:02.541074	13.66	14.67	35.32	t	t	t
8170	3	2026-03-02 22:33:02.54114	67.55	67.88	26.73	t	t	t
8172	2	2026-03-02 22:33:12.536182	78.15	68.81	53.59	t	t	t
8175	4	2026-03-02 22:33:12.536488	65.99	51.80	44.40	f	t	t
8178	5	2026-03-02 22:33:22.590342	16.61	38.10	65.69	t	t	t
8181	3	2026-03-02 22:33:32.560251	61.63	73.99	31.31	t	t	t
8185	3	2026-03-02 22:33:42.605688	64.90	42.15	57.86	t	t	f
8189	3	2026-03-02 22:33:52.570924	72.07	75.08	63.53	t	t	f
8195	4	2026-03-02 22:34:02.584629	47.62	25.32	38.77	f	t	t
8198	3	2026-03-02 22:34:12.584182	13.18	50.15	55.82	t	t	t
8202	4	2026-03-02 22:34:22.58436	65.77	29.54	42.71	t	t	t
8206	2	2026-03-02 22:34:32.588024	30.82	59.84	32.45	t	t	t
8210	4	2026-03-02 22:34:42.633464	15.32	34.78	40.11	t	t	f
8212	3	2026-03-02 22:34:52.600172	48.16	32.54	40.50	t	t	t
8217	5	2026-03-02 22:35:02.601256	73.93	37.02	66.31	t	f	t
8220	2	2026-03-02 22:35:12.595445	38.45	50.54	53.35	t	t	f
8227	5	2026-03-02 22:35:22.598918	49.53	63.39	54.35	t	f	t
8228	2	2026-03-02 22:35:32.597386	33.78	43.01	61.70	t	t	f
8234	5	2026-03-02 22:35:42.647781	26.65	77.03	69.60	t	t	t
8238	2	2026-03-02 22:35:52.61063	65.98	41.31	69.23	t	t	t
8240	2	2026-03-02 22:36:02.63084	63.74	16.94	20.18	t	t	t
8245	5	2026-03-02 22:36:12.635241	10.22	28.05	53.03	t	t	t
8249	3	2026-03-02 22:36:22.681826	36.22	36.30	42.18	t	t	t
8253	4	2026-03-02 22:36:32.660004	14.05	62.92	66.33	t	t	t
8255	5	2026-03-02 22:36:32.690789	22.96	45.97	25.87	t	t	t
8256	2	2026-03-02 22:36:42.664652	28.48	12.18	51.31	t	t	t
8259	5	2026-03-02 22:36:42.710417	18.95	32.99	58.40	f	t	t
8260	2	2026-03-02 22:36:52.67211	23.43	78.76	55.19	t	t	t
8267	5	2026-03-02 22:37:02.708019	50.68	72.16	38.61	t	t	t
8268	2	2026-03-02 22:37:12.679778	65.54	32.57	38.01	t	t	t
8273	3	2026-03-02 22:37:22.683537	61.15	43.31	56.17	t	t	t
8279	5	2026-03-02 22:37:32.838328	63.51	54.50	24.70	t	t	t
8280	2	2026-03-02 22:37:42.695867	58.97	37.42	69.72	t	t	t
8287	5	2026-03-02 22:37:52.757607	69.34	63.28	41.22	t	f	t
8288	2	2026-03-02 22:38:02.704098	35.24	67.65	61.67	t	t	f
8295	5	2026-03-02 22:38:12.75557	19.65	77.89	67.92	t	t	t
8296	2	2026-03-02 22:38:22.717111	72.61	60.10	69.87	t	t	f
8303	5	2026-03-02 22:38:32.76581	12.59	40.86	30.43	t	t	t
8304	2	2026-03-02 22:38:42.735566	28.94	36.70	25.47	t	f	t
8311	5	2026-03-02 22:38:52.785436	27.92	35.54	54.61	t	t	t
8314	2	2026-03-02 22:39:02.757729	41.91	69.12	63.18	t	t	t
8318	3	2026-03-02 22:39:12.804479	79.03	32.72	42.49	t	t	t
8321	3	2026-03-02 22:39:22.782022	40.52	51.40	53.97	t	t	t
8325	3	2026-03-02 22:39:32.822676	12.38	60.25	40.18	t	t	t
8329	4	2026-03-02 22:39:42.807069	20.26	11.95	61.18	t	t	t
8331	5	2026-03-02 22:39:42.83758	28.69	29.16	57.90	t	t	t
8332	2	2026-03-02 22:39:52.809331	75.56	22.20	28.26	t	t	t
8334	4	2026-03-02 22:39:52.809964	69.25	77.68	50.76	t	t	t
8337	3	2026-03-02 22:40:02.851904	36.37	59.96	48.74	t	t	t
8339	5	2026-03-02 22:40:02.857965	23.94	25.86	35.29	t	t	f
8340	2	2026-03-02 22:40:12.825376	14.14	32.05	29.58	f	f	t
8342	4	2026-03-02 22:40:12.826329	46.52	41.86	26.29	t	t	t
8345	3	2026-03-02 22:40:22.869471	32.13	72.45	20.72	t	t	t
8347	5	2026-03-02 22:40:22.874141	53.22	32.36	54.18	f	t	t
8348	4	2026-03-02 22:40:32.836979	45.10	61.31	51.30	t	t	t
8350	2	2026-03-02 22:40:32.837477	16.12	46.72	40.14	t	t	t
8353	3	2026-03-02 22:40:42.839105	77.52	44.84	68.26	t	t	t
8354	5	2026-03-02 22:40:42.839482	31.38	30.15	30.33	t	t	t
8358	3	2026-03-02 22:40:52.978853	17.05	59.80	27.49	t	t	t
8360	2	2026-03-02 22:41:02.850756	64.55	26.69	56.75	t	t	t
8362	3	2026-03-02 22:41:02.851633	21.09	42.19	59.84	t	t	t
8363	4	2026-03-02 22:41:02.851832	27.83	17.38	24.41	t	f	t
8364	2	2026-03-02 22:41:12.860088	37.92	11.07	47.51	t	t	t
8365	4	2026-03-02 22:41:12.90167	57.97	54.46	44.56	t	t	t
8366	3	2026-03-02 22:41:12.903613	21.92	33.43	63.91	t	f	t
8367	5	2026-03-02 22:41:12.910038	52.14	51.18	24.62	t	t	t
8368	2	2026-03-02 22:41:22.856442	46.94	14.55	25.02	t	t	t
8369	3	2026-03-02 22:41:22.856902	43.91	55.18	31.25	t	f	t
8373	5	2026-03-02 22:41:32.86022	47.39	32.37	21.36	f	f	t
8374	4	2026-03-02 22:41:32.860362	62.08	34.06	24.33	t	t	f
8377	4	2026-03-02 22:41:42.862537	11.43	62.26	35.74	t	t	f
8378	3	2026-03-02 22:41:42.8626	24.95	19.95	46.00	t	t	t
8380	2	2026-03-02 22:41:52.874032	22.10	33.96	47.44	t	t	t
8381	3	2026-03-02 22:41:52.874206	25.57	56.80	66.10	t	t	t
8385	2	2026-03-02 22:42:02.88464	12.30	77.96	20.11	t	t	t
8370	5	2026-03-02 22:41:22.857274	67.66	50.25	57.27	t	t	t
8375	3	2026-03-02 22:41:32.860654	49.70	48.55	67.34	t	t	t
8376	2	2026-03-02 22:41:42.86246	28.99	44.43	52.03	t	t	t
8371	4	2026-03-02 22:41:22.857327	49.47	73.19	23.95	t	t	t
8372	2	2026-03-02 22:41:32.860007	68.20	32.00	47.48	t	t	t
8379	5	2026-03-02 22:41:42.862676	40.87	74.04	30.47	t	t	t
8382	4	2026-03-02 22:41:52.910461	62.04	62.22	52.74	t	t	t
8383	5	2026-03-02 22:41:52.912461	48.60	72.44	54.89	t	t	f
8384	3	2026-03-02 22:42:02.884496	46.71	36.50	35.31	t	t	t
8386	4	2026-03-02 22:42:02.884888	25.09	46.05	59.12	t	t	t
8387	5	2026-03-02 22:42:03.031872	42.44	38.84	46.37	f	t	t
8388	2	2026-03-02 22:42:12.897768	26.11	21.00	61.73	t	t	t
8389	3	2026-03-02 22:42:12.929828	16.96	34.81	39.75	t	t	t
8390	4	2026-03-02 22:42:12.936945	61.41	71.11	55.46	t	t	f
8391	5	2026-03-02 22:42:12.937528	18.41	38.80	57.00	f	t	t
8392	2	2026-03-02 22:42:22.905237	26.01	78.28	56.94	t	f	t
8393	3	2026-03-02 22:42:22.905404	21.69	20.26	39.14	t	t	f
8394	4	2026-03-02 22:42:22.905867	43.57	55.96	50.22	t	t	t
8395	5	2026-03-02 22:42:22.934609	79.30	20.61	24.02	t	f	t
8396	3	2026-03-02 22:42:32.929999	46.69	25.40	29.73	t	t	t
8397	2	2026-03-02 22:42:32.930204	29.04	13.68	34.55	t	t	t
8398	4	2026-03-02 22:42:32.960888	64.18	41.44	24.71	t	t	t
8399	5	2026-03-02 22:42:33.074459	32.48	24.78	41.36	t	t	f
8400	2	2026-03-02 22:42:42.93001	52.21	41.42	54.27	t	t	t
8401	4	2026-03-02 22:42:42.930153	49.07	41.74	48.54	t	t	f
8402	3	2026-03-02 22:42:42.930432	64.62	64.38	30.34	t	t	t
8403	5	2026-03-02 22:42:42.9307	53.98	74.23	54.11	t	t	t
8404	2	2026-03-02 22:42:52.943	29.27	45.39	28.73	t	t	t
8405	3	2026-03-02 22:42:52.974945	73.55	17.19	60.84	t	t	t
8406	5	2026-03-02 22:42:52.978049	59.78	17.89	44.10	t	t	t
8407	4	2026-03-02 22:42:52.980734	47.66	13.00	32.04	t	t	t
8408	3	2026-03-02 22:43:02.956534	56.69	34.93	23.86	t	t	t
8409	2	2026-03-02 22:43:02.956764	16.35	11.31	38.82	t	t	t
8410	4	2026-03-02 22:43:02.956891	47.21	57.96	61.43	t	t	t
8411	5	2026-03-02 22:43:02.987423	54.98	55.37	59.21	t	t	f
8412	2	2026-03-02 22:43:12.960341	63.69	52.40	65.20	t	t	t
8413	3	2026-03-02 22:43:12.960513	29.65	78.21	39.42	t	t	t
8414	5	2026-03-02 22:43:12.960692	70.25	25.31	49.19	t	t	t
8415	4	2026-03-02 22:43:12.960761	74.32	14.29	60.54	t	t	t
8416	2	2026-03-02 22:43:22.975374	59.13	22.41	51.29	t	t	t
8417	3	2026-03-02 22:43:23.02651	57.80	75.43	55.72	t	t	t
8418	4	2026-03-02 22:43:23.029593	42.29	76.12	40.56	t	t	t
8419	5	2026-03-02 22:43:23.030386	34.13	57.04	40.41	t	t	t
8420	2	2026-03-02 22:43:32.968618	37.00	78.32	59.35	t	t	t
8421	4	2026-03-02 22:43:32.968918	74.13	42.11	46.90	t	t	t
8422	3	2026-03-02 22:43:32.969141	66.97	27.73	27.18	t	f	t
8423	5	2026-03-02 22:43:32.969486	41.99	77.58	66.77	t	t	t
8424	2	2026-03-02 22:43:42.977199	17.00	40.32	49.10	t	t	f
8425	3	2026-03-02 22:43:43.011184	70.54	69.57	49.35	t	t	t
8426	4	2026-03-02 22:43:43.016057	23.29	32.90	28.26	t	f	t
8427	5	2026-03-02 22:43:43.016976	66.49	22.55	44.66	t	t	t
8428	2	2026-03-02 22:43:52.97791	34.86	50.19	25.99	t	t	t
8429	3	2026-03-02 22:43:52.978271	65.20	29.59	21.88	t	t	t
8430	4	2026-03-02 22:43:52.978503	70.68	25.51	69.23	t	t	f
8431	5	2026-03-02 22:43:52.978581	53.22	71.57	58.51	t	t	f
8432	2	2026-03-02 22:44:02.990867	19.89	45.22	35.04	f	t	t
8433	3	2026-03-02 22:44:03.025402	11.71	47.54	58.96	t	t	t
8434	4	2026-03-02 22:44:03.02836	39.70	50.84	33.59	t	t	t
8435	5	2026-03-02 22:44:03.031106	62.79	26.94	58.90	t	t	t
8436	2	2026-03-02 22:44:12.992946	16.68	65.28	68.35	t	t	t
8437	5	2026-03-02 22:44:12.993137	18.16	14.48	42.19	t	t	t
8438	3	2026-03-02 22:44:12.993215	76.57	67.44	31.98	t	t	t
8439	4	2026-03-02 22:44:12.99333	18.59	51.85	69.19	t	t	t
8440	5	2026-03-02 22:44:22.999763	55.56	25.32	31.43	t	f	t
8441	2	2026-03-02 22:44:23.000175	36.38	27.75	64.71	t	t	t
8442	4	2026-03-02 22:44:23.00065	42.01	25.47	41.42	t	t	t
8443	3	2026-03-02 22:44:23.030027	74.63	47.21	35.40	t	t	f
8444	2	2026-03-02 22:44:33.01549	15.97	36.41	29.07	t	t	t
8445	3	2026-03-02 22:44:33.049906	62.61	78.11	51.50	t	t	t
8446	4	2026-03-02 22:44:33.051355	69.30	54.07	63.71	t	f	t
8447	5	2026-03-02 22:44:33.161422	49.26	54.76	35.39	t	f	t
8448	3	2026-03-02 22:44:43.022014	68.42	43.26	29.22	t	t	t
8449	2	2026-03-02 22:44:43.022108	39.09	63.26	60.40	t	t	t
8450	4	2026-03-02 22:44:43.022196	48.83	67.09	47.89	t	t	t
8451	5	2026-03-02 22:44:43.051399	12.54	46.88	50.82	t	t	t
8452	2	2026-03-02 22:44:53.023726	71.48	36.18	66.27	t	t	f
8453	5	2026-03-02 22:44:53.023996	66.53	70.57	30.94	t	t	t
8454	4	2026-03-02 22:44:53.024091	27.58	21.49	55.37	t	f	t
8455	3	2026-03-02 22:44:53.024249	67.20	66.64	36.80	t	t	f
8456	2	2026-03-02 22:45:03.033966	20.82	65.28	53.16	f	t	t
8457	3	2026-03-02 22:45:03.064859	12.94	23.71	32.16	t	t	t
8458	4	2026-03-02 22:45:03.069333	38.36	48.49	62.45	t	t	t
8459	5	2026-03-02 22:45:03.070096	45.80	40.19	28.72	t	t	t
8460	4	2026-03-02 22:45:13.035883	21.24	12.69	64.67	t	t	t
8461	2	2026-03-02 22:45:13.036061	79.05	76.22	21.94	t	f	t
8462	3	2026-03-02 22:45:13.036232	75.68	54.53	52.40	t	t	t
8463	5	2026-03-02 22:45:13.036429	27.47	33.49	46.22	f	t	t
8464	2	2026-03-02 22:45:23.043267	64.46	23.40	42.47	t	t	t
8465	3	2026-03-02 22:45:23.078235	64.63	20.47	50.09	t	t	t
8466	4	2026-03-02 22:45:23.07871	78.33	41.78	24.20	t	t	t
8467	5	2026-03-02 22:45:23.080738	23.72	29.00	54.89	t	t	f
8468	2	2026-03-02 22:45:33.054285	30.13	53.43	40.03	t	t	t
8469	3	2026-03-02 22:45:33.05453	31.08	13.57	20.54	t	t	t
8470	4	2026-03-02 22:45:33.054873	68.00	24.26	43.09	t	t	f
8471	5	2026-03-02 22:45:33.084682	66.41	39.48	33.48	t	f	t
8472	2	2026-03-02 22:45:43.069322	70.02	18.52	50.15	t	t	t
8473	3	2026-03-02 22:45:43.102209	43.89	65.30	33.71	t	f	t
8474	5	2026-03-02 22:45:43.107534	68.46	73.58	20.49	t	t	t
8475	4	2026-03-02 22:45:43.107706	24.16	46.78	22.30	t	t	t
8476	2	2026-03-02 22:45:53.071688	16.42	21.25	44.19	t	t	t
8477	5	2026-03-02 22:45:53.071845	49.82	27.10	49.36	t	t	t
8478	3	2026-03-02 22:45:53.071961	77.23	74.76	25.79	t	t	t
8479	4	2026-03-02 22:45:53.072142	14.36	59.66	50.92	t	t	t
8480	2	2026-03-02 22:46:03.080157	62.02	51.25	61.47	t	t	t
8481	3	2026-03-02 22:46:03.113534	18.96	49.67	62.10	t	t	t
8482	5	2026-03-02 22:46:03.118461	35.08	55.84	29.52	t	t	t
8483	4	2026-03-02 22:46:03.226142	10.31	49.31	27.47	t	t	t
8484	2	2026-03-02 22:46:13.082658	53.38	64.46	54.48	t	t	f
8485	5	2026-03-02 22:46:13.082765	65.92	38.64	50.33	t	t	t
8486	4	2026-03-02 22:46:13.082885	23.01	62.77	55.75	t	f	t
8487	3	2026-03-02 22:46:13.08284	22.84	30.91	49.17	t	f	t
8488	2	2026-03-02 22:46:23.09931	68.88	79.43	38.57	t	t	t
8489	3	2026-03-02 22:46:23.133871	18.50	11.16	68.24	t	t	t
8490	5	2026-03-02 22:46:23.14184	66.89	37.46	44.07	t	t	t
8491	4	2026-03-02 22:46:23.142067	19.15	21.13	68.02	t	t	t
8492	2	2026-03-02 22:46:33.111697	44.75	41.36	48.05	t	t	t
8494	3	2026-03-02 22:46:33.112113	57.36	18.04	23.05	t	t	f
8493	4	2026-03-02 22:46:33.111999	15.10	27.30	57.81	t	t	t
8495	5	2026-03-02 22:46:33.139696	34.98	18.97	21.74	t	t	t
8496	2	2026-03-02 22:46:43.129884	19.62	42.62	39.67	t	t	t
8497	3	2026-03-02 22:46:43.162715	64.91	78.95	34.47	t	t	t
8498	5	2026-03-02 22:46:43.167196	56.17	75.59	44.35	t	t	t
8499	4	2026-03-02 22:46:43.167604	62.05	11.85	52.10	t	t	t
8500	2	2026-03-02 22:46:53.13745	23.93	43.83	41.19	t	t	t
8501	3	2026-03-02 22:46:53.137925	12.22	20.35	63.46	t	t	t
8502	4	2026-03-02 22:46:53.138171	47.75	24.96	25.80	t	f	f
8503	5	2026-03-02 22:46:53.167786	28.16	37.68	34.32	t	t	t
8504	2	2026-03-02 22:47:03.136819	45.22	11.31	33.25	t	t	f
8505	3	2026-03-02 22:47:03.137187	28.83	46.33	63.84	t	t	t
8506	5	2026-03-02 22:47:03.137468	24.04	13.59	27.40	t	t	t
8507	4	2026-03-02 22:47:03.13751	47.06	62.01	51.64	t	t	t
8508	2	2026-03-02 22:47:13.151661	64.66	28.43	64.76	t	t	f
8509	3	2026-03-02 22:47:13.185508	55.37	62.61	69.16	t	t	t
8510	5	2026-03-02 22:47:13.190492	52.70	41.32	39.28	t	f	t
8511	4	2026-03-02 22:47:13.294559	64.74	27.81	22.95	t	t	f
8512	2	2026-03-02 22:47:23.18132	41.57	79.95	54.11	t	t	t
8513	3	2026-03-02 22:47:23.181698	37.95	10.59	30.59	t	f	t
8514	4	2026-03-02 22:47:23.181909	32.34	51.80	50.44	t	t	t
8515	5	2026-03-02 22:47:23.21191	39.89	65.75	64.11	t	t	t
8516	2	2026-03-02 22:47:33.18159	15.14	65.49	31.14	t	t	t
8517	4	2026-03-02 22:47:33.181841	38.57	78.65	67.77	t	t	t
8518	5	2026-03-02 22:47:33.181985	20.74	42.69	46.17	t	t	t
8519	3	2026-03-02 22:47:33.182321	76.07	70.46	47.37	t	t	t
8520	2	2026-03-02 22:47:43.187871	73.95	35.28	62.96	t	t	t
8521	5	2026-03-02 22:47:43.188118	76.32	10.05	41.13	t	t	t
8522	3	2026-03-02 22:47:43.188255	73.63	27.10	59.22	t	t	t
8523	4	2026-03-02 22:47:43.188433	61.58	78.61	30.13	t	t	t
8524	2	2026-03-02 22:47:53.197823	39.70	42.46	39.73	t	t	t
8525	3	2026-03-02 22:47:53.231947	74.25	59.38	43.84	f	t	t
8526	4	2026-03-02 22:47:53.232325	51.95	23.82	43.34	t	t	t
8527	5	2026-03-02 22:47:53.233386	40.59	22.11	34.69	t	t	t
8528	2	2026-03-02 22:48:03.20317	55.32	52.21	43.03	t	t	t
8529	5	2026-03-02 22:48:03.203333	59.75	47.60	29.91	t	t	f
8530	4	2026-03-02 22:48:03.203405	13.71	36.37	52.95	t	t	t
8531	3	2026-03-02 22:48:03.203612	40.13	72.29	54.55	t	t	t
8532	2	2026-03-02 22:48:13.207127	36.55	35.59	50.86	t	f	t
8533	5	2026-03-02 22:48:13.207398	64.24	35.95	68.28	t	t	t
8534	3	2026-03-02 22:48:13.207564	50.20	20.25	21.50	t	t	t
8535	4	2026-03-02 22:48:13.207679	55.63	26.92	32.67	t	t	t
8536	3	2026-03-02 22:48:23.209573	55.21	25.93	67.71	t	t	t
8537	2	2026-03-02 22:48:23.209854	50.49	77.40	41.97	t	t	t
8538	4	2026-03-02 22:48:23.210231	41.29	18.33	68.41	t	t	t
8539	5	2026-03-02 22:48:23.210313	74.80	75.36	39.32	t	t	t
8540	2	2026-03-02 22:48:33.212993	42.99	24.25	34.43	t	t	t
8541	4	2026-03-02 22:48:33.21326	11.48	65.85	45.18	t	t	f
8542	5	2026-03-02 22:48:33.213491	38.20	74.00	64.16	t	t	t
8543	3	2026-03-02 22:48:33.213567	68.34	57.58	62.33	t	f	f
8544	2	2026-03-02 22:48:43.228661	46.57	59.40	24.70	t	t	t
8545	3	2026-03-02 22:48:43.26329	23.54	60.00	55.89	t	t	t
8546	4	2026-03-02 22:48:43.264968	65.58	37.37	55.07	t	f	t
8547	5	2026-03-02 22:48:43.265735	64.02	54.50	25.60	t	t	t
8548	2	2026-03-02 22:48:53.241321	49.38	59.37	29.77	t	t	f
8549	4	2026-03-02 22:48:53.241505	46.69	56.30	66.90	t	t	t
8550	3	2026-03-02 22:48:53.241652	47.21	54.32	67.46	t	f	f
8551	5	2026-03-02 22:48:53.283357	70.25	35.01	44.16	t	t	f
8552	2	2026-03-02 22:49:03.241057	22.55	40.65	52.49	t	t	f
8554	5	2026-03-02 22:49:03.241207	32.38	52.42	50.66	t	t	t
8553	3	2026-03-02 22:49:03.24126	46.10	61.08	55.17	t	t	t
8555	4	2026-03-02 22:49:03.241499	57.26	31.37	30.27	t	t	f
8556	2	2026-03-02 22:49:13.242581	78.73	73.00	48.97	t	t	t
8557	3	2026-03-02 22:49:13.242853	24.61	48.70	53.59	t	t	t
8558	4	2026-03-02 22:49:13.243152	28.05	20.66	43.25	t	t	t
8559	5	2026-03-02 22:49:13.243306	51.09	79.21	30.26	t	t	t
8560	2	2026-03-02 22:49:23.240905	10.97	42.33	51.69	t	t	t
8561	5	2026-03-02 22:49:23.241201	41.46	22.54	47.20	t	t	f
8562	3	2026-03-02 22:49:23.241253	17.22	31.74	55.87	t	t	t
8563	4	2026-03-02 22:49:23.241497	76.64	27.14	29.69	t	t	t
8564	3	2026-03-02 22:49:33.26027	55.40	14.07	21.30	t	t	t
8565	5	2026-03-02 22:49:33.296147	47.99	26.70	38.66	t	t	t
8566	2	2026-03-02 22:49:33.407929	34.77	62.36	31.45	t	t	t
8567	4	2026-03-02 22:49:33.408004	29.05	54.06	68.86	t	t	t
8568	2	2026-03-02 22:49:43.276831	35.50	57.51	26.86	t	t	t
8569	4	2026-03-02 22:49:43.277578	51.34	15.18	55.55	t	t	t
8570	3	2026-03-02 22:49:43.278177	41.42	12.02	20.40	t	t	t
8571	5	2026-03-02 22:49:43.34215	36.82	49.86	66.82	t	t	t
8572	2	2026-03-02 22:49:53.29973	11.91	40.35	36.10	t	t	t
8573	4	2026-03-02 22:49:53.342599	32.42	72.82	34.62	t	t	t
8574	5	2026-03-02 22:49:53.343507	49.40	17.90	20.79	t	t	t
8575	3	2026-03-02 22:49:53.443073	43.78	14.82	47.97	t	t	t
8576	2	2026-03-02 22:50:03.306931	24.65	73.38	47.44	t	t	t
8577	4	2026-03-02 22:50:03.307045	70.82	31.20	31.73	t	t	t
8578	3	2026-03-02 22:50:03.307125	27.32	57.71	31.17	t	f	t
8579	5	2026-03-02 22:50:03.337253	54.01	28.56	33.08	t	t	t
8580	2	2026-03-02 22:50:13.311227	74.95	70.79	34.06	t	t	t
8581	5	2026-03-02 22:50:13.311467	40.68	17.11	39.89	t	t	t
8582	4	2026-03-02 22:50:13.311628	25.99	31.32	60.13	t	t	t
8583	3	2026-03-02 22:50:13.311706	69.00	67.16	45.22	t	t	t
8584	2	2026-03-02 22:50:23.311838	28.27	68.37	63.46	t	t	t
8585	3	2026-03-02 22:50:23.311994	11.50	43.61	69.31	t	f	t
8586	4	2026-03-02 22:50:23.312205	17.94	33.11	25.87	t	t	t
8587	5	2026-03-02 22:50:23.312355	72.80	71.08	32.50	t	t	t
8588	2	2026-03-02 22:50:33.330976	68.25	56.07	40.14	t	t	t
8589	4	2026-03-02 22:50:33.331532	64.82	55.47	39.54	t	t	t
8590	5	2026-03-02 22:50:33.331756	74.56	26.54	68.35	t	f	t
8591	3	2026-03-02 22:50:33.331688	57.26	49.53	22.42	t	t	t
8592	2	2026-03-02 22:50:43.333655	72.43	14.51	46.42	t	t	t
8593	4	2026-03-02 22:50:43.333948	37.69	16.98	47.69	f	t	t
8594	3	2026-03-02 22:50:43.334381	11.07	19.52	59.50	t	t	t
8595	5	2026-03-02 22:50:43.334483	38.36	62.98	65.05	f	t	t
8596	2	2026-03-02 22:50:53.333362	74.97	37.06	65.92	t	t	t
8597	5	2026-03-02 22:50:53.333462	54.09	68.44	49.86	t	t	t
8598	3	2026-03-02 22:50:53.333582	57.39	50.18	46.33	t	t	t
8599	4	2026-03-02 22:50:53.333639	58.08	75.60	44.07	t	t	f
8600	3	2026-03-02 22:51:03.330543	37.33	45.72	44.53	t	t	t
8601	2	2026-03-02 22:51:03.330897	36.45	44.58	49.83	f	t	t
8602	5	2026-03-02 22:51:03.331019	63.71	56.33	42.33	t	t	t
8606	5	2026-03-02 22:51:13.336848	79.83	11.11	43.92	t	t	t
8611	5	2026-03-02 22:51:23.340713	57.68	43.83	54.47	t	f	t
8613	5	2026-03-02 22:51:33.34142	43.61	54.12	67.04	t	t	t
8605	4	2026-03-02 22:51:13.33647	35.14	11.52	40.30	t	t	t
8608	2	2026-03-02 22:51:23.339914	32.24	59.02	66.89	t	t	t
8614	4	2026-03-02 22:51:33.341748	71.72	63.35	56.06	t	t	t
8720	2	2026-03-02 22:56:03.535271	41.41	23.39	43.64	t	t	t
8721	5	2026-03-02 22:56:03.535388	78.37	56.28	55.52	t	t	t
8722	3	2026-03-02 22:56:03.535422	68.84	32.00	31.33	t	t	t
8723	4	2026-03-02 22:56:03.535525	24.82	17.88	41.57	t	t	f
8724	2	2026-03-02 22:56:13.537325	72.29	16.70	63.59	t	t	t
8725	3	2026-03-02 22:56:13.53753	71.00	11.09	60.34	t	t	t
8726	5	2026-03-02 22:56:13.537871	43.10	56.89	63.12	t	t	f
8727	4	2026-03-02 22:56:13.537668	32.94	35.36	62.83	t	f	t
8728	2	2026-03-02 22:56:23.549323	17.43	59.46	29.98	t	t	t
8729	3	2026-03-02 22:56:23.594557	50.15	66.28	27.65	t	f	t
8730	4	2026-03-02 22:56:23.599869	41.76	31.28	28.29	t	t	t
8731	5	2026-03-02 22:56:23.601735	19.62	68.86	22.74	t	t	t
8732	2	2026-03-02 22:56:33.551271	61.18	13.79	44.53	t	t	t
8733	3	2026-03-02 22:56:33.552119	68.52	64.47	23.59	t	t	t
8734	4	2026-03-02 22:56:33.55274	71.86	67.99	33.52	t	t	t
8735	5	2026-03-02 22:56:33.553058	72.90	34.61	27.69	t	t	f
8736	2	2026-03-02 22:56:43.556802	33.30	18.29	24.36	t	t	t
8737	5	2026-03-02 22:56:43.55698	45.65	34.37	21.99	t	f	t
8738	4	2026-03-02 22:56:43.55727	67.30	20.88	56.47	t	t	t
8739	3	2026-03-02 22:56:43.557439	33.98	19.30	63.28	t	t	f
8740	2	2026-03-02 22:56:53.558994	42.27	73.19	54.53	f	t	t
8741	5	2026-03-02 22:56:53.559862	12.42	55.77	25.53	t	t	t
8742	4	2026-03-02 22:56:53.560198	60.51	67.79	61.45	t	t	t
8743	3	2026-03-02 22:56:53.560505	48.44	62.59	63.59	t	t	t
8744	2	2026-03-02 22:57:03.566654	20.46	60.92	21.19	t	t	t
8745	3	2026-03-02 22:57:03.598685	70.61	21.81	29.70	t	t	t
8746	4	2026-03-02 22:57:03.600499	59.96	16.86	47.30	t	t	t
8747	5	2026-03-02 22:57:03.712415	77.91	73.84	55.84	f	t	f
8748	2	2026-03-02 22:57:13.574418	47.32	68.55	62.88	t	t	t
8749	5	2026-03-02 22:57:13.574476	44.56	14.77	36.24	t	f	t
8750	4	2026-03-02 22:57:13.574631	65.98	21.89	45.48	t	f	t
8751	3	2026-03-02 22:57:13.57475	44.57	38.90	37.67	t	t	t
8752	2	2026-03-02 22:57:23.584166	49.54	65.33	64.50	t	t	t
8753	3	2026-03-02 22:57:23.616982	36.65	30.99	35.49	t	t	t
8754	4	2026-03-02 22:57:23.62385	29.44	55.69	46.64	t	t	t
8755	5	2026-03-02 22:57:23.625479	48.03	28.16	47.41	t	t	f
8756	2	2026-03-02 22:57:33.603217	25.14	66.78	64.88	t	t	t
8757	3	2026-03-02 22:57:33.603638	71.42	77.70	28.63	t	t	t
8758	4	2026-03-02 22:57:33.603973	50.04	70.17	41.13	t	t	f
8759	5	2026-03-02 22:57:33.634943	36.02	21.95	45.56	t	t	t
8760	2	2026-03-02 22:57:43.619937	64.05	61.53	58.31	t	t	t
8761	3	2026-03-02 22:57:43.654305	27.04	22.55	63.99	t	f	t
8762	4	2026-03-02 22:57:43.654495	15.81	53.42	45.57	t	t	t
8763	5	2026-03-02 22:57:43.655426	39.26	50.21	51.81	t	t	t
8764	2	2026-03-02 22:57:53.62306	68.23	30.30	23.81	t	t	t
8765	5	2026-03-02 22:57:53.623469	36.86	44.08	47.09	t	t	t
8766	3	2026-03-02 22:57:53.62362	75.36	59.67	31.41	t	t	t
8767	4	2026-03-02 22:57:53.623958	21.49	17.14	66.81	t	t	t
8768	3	2026-03-02 22:58:03.633714	74.81	59.07	49.20	t	t	t
8769	2	2026-03-02 22:58:03.668153	57.66	46.14	48.37	t	t	t
8770	4	2026-03-02 22:58:03.670819	54.59	38.29	58.85	t	t	t
8771	5	2026-03-02 22:58:03.671209	37.24	39.92	28.25	t	t	f
8772	2	2026-03-02 22:58:13.634263	12.64	62.95	26.31	f	t	t
8773	5	2026-03-02 22:58:13.63441	51.34	26.55	41.82	t	t	t
8774	3	2026-03-02 22:58:13.634685	14.10	52.01	29.08	t	t	t
8775	4	2026-03-02 22:58:13.634838	11.11	45.99	32.63	t	t	t
8776	3	2026-03-02 22:58:23.633545	74.44	49.52	40.34	t	t	t
8777	5	2026-03-02 22:58:23.633783	46.26	47.12	25.59	t	t	t
8778	4	2026-03-02 22:58:23.633975	69.12	72.23	28.91	t	t	t
8779	2	2026-03-02 22:58:23.634209	17.51	11.61	23.60	t	t	t
8780	3	2026-03-02 22:58:33.628975	71.57	15.55	48.67	t	t	t
8781	2	2026-03-02 22:58:33.6291	70.75	54.10	28.83	t	t	t
8782	5	2026-03-02 22:58:33.629237	35.83	10.35	47.29	t	t	t
8783	4	2026-03-02 22:58:33.629314	19.21	15.85	21.98	t	t	t
8784	2	2026-03-02 22:58:43.638662	24.53	39.81	58.97	t	t	t
8785	4	2026-03-02 22:58:43.67527	34.41	23.09	25.47	t	t	f
8786	5	2026-03-02 22:58:43.676384	17.33	67.49	67.62	t	f	t
8787	3	2026-03-02 22:58:43.782436	14.33	39.90	49.37	t	t	t
8788	2	2026-03-02 22:58:53.640193	11.21	21.90	23.39	t	f	t
8789	5	2026-03-02 22:58:53.640419	19.14	75.84	45.59	t	t	f
8790	3	2026-03-02 22:58:53.640508	29.34	45.28	55.58	f	t	t
8791	4	2026-03-02 22:58:53.640637	71.54	39.99	46.05	t	t	t
8792	2	2026-03-02 22:59:03.642478	25.21	26.14	53.15	t	f	t
8793	3	2026-03-02 22:59:03.642862	62.54	57.28	53.76	t	t	t
8794	4	2026-03-02 22:59:03.643103	76.90	41.82	62.19	t	t	f
8795	5	2026-03-02 22:59:03.643811	12.34	42.92	67.28	t	t	t
8796	2	2026-03-02 22:59:13.651055	69.52	65.92	34.54	t	t	t
8797	3	2026-03-02 22:59:13.685213	32.66	27.04	65.84	t	t	t
8798	4	2026-03-02 22:59:13.687699	12.06	49.56	42.10	t	t	t
8799	5	2026-03-02 22:59:13.691381	20.96	62.58	48.98	t	t	t
8800	3	2026-03-02 22:59:23.66556	69.75	36.09	56.64	t	t	t
8801	4	2026-03-02 22:59:23.666395	73.73	41.44	67.40	t	t	f
8802	2	2026-03-02 22:59:23.666532	71.07	43.36	52.73	t	t	t
8803	5	2026-03-02 22:59:23.694973	68.82	52.40	62.12	t	t	t
8804	3	2026-03-02 22:59:33.672593	46.96	79.20	36.75	t	t	t
8805	2	2026-03-02 22:59:33.672808	45.97	76.06	23.69	t	f	t
8806	5	2026-03-02 22:59:33.672976	33.01	26.38	69.67	t	t	f
8807	4	2026-03-02 22:59:33.673268	40.42	74.30	64.59	t	t	t
8808	2	2026-03-02 22:59:43.670442	49.76	73.37	35.72	t	f	t
8809	4	2026-03-02 22:59:43.670531	10.05	19.18	37.37	t	t	t
8810	5	2026-03-02 22:59:43.670606	65.65	73.83	61.03	t	f	f
8811	3	2026-03-02 22:59:43.670689	70.30	52.84	62.75	t	t	t
8812	2	2026-03-02 22:59:53.683701	20.02	74.56	61.92	f	t	t
8813	3	2026-03-02 22:59:53.714118	23.35	13.95	28.73	t	t	t
8814	4	2026-03-02 22:59:53.718424	50.56	53.48	64.23	t	t	t
8815	5	2026-03-02 22:59:53.718922	59.43	36.16	37.31	t	t	f
8816	3	2026-03-02 23:00:03.694514	13.35	69.34	57.19	t	t	t
8817	2	2026-03-02 23:00:03.694829	63.89	10.37	67.86	f	t	t
8818	4	2026-03-02 23:00:03.725533	33.64	75.76	67.45	t	t	t
8819	5	2026-03-02 23:00:03.725849	11.88	57.27	50.42	t	t	t
8820	2	2026-03-02 23:00:13.702773	51.13	71.87	51.89	t	t	f
8821	3	2026-03-02 23:00:13.702858	24.03	47.40	32.08	t	t	t
8822	4	2026-03-02 23:00:13.736086	12.94	33.33	45.98	t	t	t
8823	5	2026-03-02 23:00:13.738061	71.89	40.62	55.36	t	t	f
8603	4	2026-03-02 22:51:03.330998	12.43	18.73	35.49	t	t	t
8604	2	2026-03-02 22:51:13.336268	47.69	28.13	69.69	t	f	t
8610	4	2026-03-02 22:51:23.340587	17.83	24.55	69.37	t	t	f
8612	2	2026-03-02 22:51:33.340853	13.31	13.63	66.85	t	t	t
8607	3	2026-03-02 22:51:13.337486	24.67	53.87	48.52	f	t	f
8609	3	2026-03-02 22:51:23.340405	72.84	12.61	45.37	t	t	t
8615	3	2026-03-02 22:51:33.342143	60.34	26.53	20.13	t	t	t
8616	2	2026-03-02 22:51:43.352965	35.32	70.23	26.30	t	t	f
8617	4	2026-03-02 22:51:43.388724	48.39	19.03	44.92	t	f	t
8618	3	2026-03-02 22:51:43.392864	41.53	79.33	34.37	t	t	f
8619	5	2026-03-02 22:51:43.395536	44.36	16.13	33.71	t	t	t
8620	2	2026-03-02 22:51:53.359346	62.15	17.57	64.56	t	t	f
8621	4	2026-03-02 22:51:53.359558	30.47	24.92	39.83	t	t	f
8622	3	2026-03-02 22:51:53.359755	47.36	46.33	22.08	t	t	t
8623	5	2026-03-02 22:51:53.359954	28.47	76.56	47.11	t	t	t
8624	2	2026-03-02 22:52:03.364857	75.28	75.31	34.17	t	t	t
8625	3	2026-03-02 22:52:03.400535	63.42	33.82	63.47	t	t	t
8626	4	2026-03-02 22:52:03.405068	42.05	40.24	37.06	t	f	t
8627	5	2026-03-02 22:52:03.405462	68.89	20.14	51.42	t	t	t
8629	4	2026-03-02 22:52:13.371781	17.24	24.23	38.72	t	t	t
8628	2	2026-03-02 22:52:13.37163	29.38	79.89	44.08	t	t	t
8630	3	2026-03-02 22:52:13.37212	24.47	61.87	39.58	f	t	f
8631	5	2026-03-02 22:52:13.403163	55.56	56.28	42.68	t	t	f
8632	2	2026-03-02 22:52:23.381702	47.01	20.18	32.83	t	t	f
8634	4	2026-03-02 22:52:23.422308	79.87	63.91	60.78	t	t	t
8633	5	2026-03-02 22:52:23.422205	43.99	52.02	64.11	t	t	t
8635	3	2026-03-02 22:52:23.525246	67.66	17.98	56.07	t	t	t
8636	2	2026-03-02 22:52:33.38082	71.72	51.76	64.75	t	t	t
8637	4	2026-03-02 22:52:33.381187	39.37	32.27	50.29	t	t	f
8638	5	2026-03-02 22:52:33.381337	34.87	30.31	40.92	t	t	f
8639	3	2026-03-02 22:52:33.381441	27.24	31.96	22.52	t	t	t
8640	2	2026-03-02 22:52:43.386155	16.28	40.88	24.04	t	t	f
8641	4	2026-03-02 22:52:43.386781	60.44	46.65	22.77	t	t	t
8642	3	2026-03-02 22:52:43.386921	36.62	13.88	68.44	t	t	t
8643	5	2026-03-02 22:52:43.416021	40.25	22.82	32.11	t	t	t
8644	2	2026-03-02 22:52:53.396796	76.95	63.64	62.02	t	t	t
8645	3	2026-03-02 22:52:53.430343	36.01	31.14	67.52	t	f	t
8647	5	2026-03-02 22:52:53.437083	76.02	13.60	23.49	t	t	t
8646	4	2026-03-02 22:52:53.436963	29.95	45.57	39.72	t	t	f
8648	3	2026-03-02 22:53:03.397625	78.71	64.52	54.90	t	f	t
8649	5	2026-03-02 22:53:03.397812	25.27	57.62	61.58	t	t	t
8650	2	2026-03-02 22:53:03.397778	67.69	36.36	22.10	t	t	t
8651	4	2026-03-02 22:53:03.397752	37.07	42.86	40.37	t	t	t
8652	2	2026-03-02 22:53:13.406314	36.64	37.92	54.02	t	t	f
8653	3	2026-03-02 22:53:13.441817	66.37	38.88	66.16	t	t	t
8654	4	2026-03-02 22:53:13.447021	37.38	24.85	49.04	t	f	t
8655	5	2026-03-02 22:53:13.447821	51.52	29.91	33.99	f	t	t
8656	2	2026-03-02 22:53:23.412297	51.36	77.89	21.00	t	t	t
8657	4	2026-03-02 22:53:23.412875	36.48	18.93	42.39	t	t	t
8658	3	2026-03-02 22:53:23.412773	38.95	52.97	62.65	t	t	t
8659	5	2026-03-02 22:53:23.440665	33.52	38.71	52.90	t	t	t
8660	2	2026-03-02 22:53:33.426909	22.35	33.89	52.81	t	t	t
8661	4	2026-03-02 22:53:33.461222	62.57	69.09	35.42	f	t	t
8662	3	2026-03-02 22:53:33.461436	34.62	49.86	52.37	t	t	t
8663	5	2026-03-02 22:53:33.577049	50.94	47.04	22.33	t	t	t
8664	2	2026-03-02 22:53:43.42478	18.58	15.07	43.81	t	t	t
8665	3	2026-03-02 22:53:43.424927	75.67	49.10	50.38	f	t	t
8666	4	2026-03-02 22:53:43.424978	72.67	70.26	31.05	t	t	t
8667	5	2026-03-02 22:53:43.425045	29.45	58.15	69.22	t	t	t
8668	2	2026-03-02 22:53:53.444468	45.18	79.95	63.39	t	f	t
8669	3	2026-03-02 22:53:53.487218	77.26	16.93	25.19	t	t	t
8670	4	2026-03-02 22:53:53.493506	22.48	67.87	26.63	t	t	t
8671	5	2026-03-02 22:53:53.495414	51.38	76.58	61.83	f	t	t
8672	2	2026-03-02 22:54:03.440503	14.92	77.67	29.61	t	f	t
8673	3	2026-03-02 22:54:03.440633	62.69	50.16	54.37	t	t	t
8674	4	2026-03-02 22:54:03.440877	76.28	65.08	28.28	t	t	t
8675	5	2026-03-02 22:54:03.441266	25.66	79.34	30.09	t	t	t
8676	2	2026-03-02 22:54:13.44324	19.12	31.50	50.87	t	t	t
8677	4	2026-03-02 22:54:13.443948	79.26	54.67	56.65	t	t	t
8678	5	2026-03-02 22:54:13.444123	22.16	12.59	56.92	t	t	t
8679	3	2026-03-02 22:54:13.444233	62.26	62.44	62.14	t	t	t
8680	2	2026-03-02 22:54:23.451355	75.95	55.24	47.85	t	t	t
8681	3	2026-03-02 22:54:23.491466	48.81	77.99	52.26	t	t	t
8682	5	2026-03-02 22:54:23.499704	12.68	31.46	67.07	t	t	t
8683	4	2026-03-02 22:54:23.500339	23.12	42.05	23.39	t	t	t
8684	2	2026-03-02 22:54:33.461833	61.68	78.04	63.50	t	t	t
8685	4	2026-03-02 22:54:33.461931	39.31	61.63	33.55	t	t	t
8686	3	2026-03-02 22:54:33.462015	61.64	73.16	62.04	t	t	t
8687	5	2026-03-02 22:54:33.49729	25.76	33.26	30.05	t	t	t
8688	2	2026-03-02 22:54:43.477476	57.55	41.53	48.38	f	t	f
8689	3	2026-03-02 22:54:43.511898	25.95	76.36	52.80	t	t	t
8690	5	2026-03-02 22:54:43.517111	25.18	30.85	34.96	t	f	t
8691	4	2026-03-02 22:54:43.518304	56.01	19.37	49.11	t	t	f
8692	4	2026-03-02 22:54:53.491456	52.67	12.32	55.00	t	t	t
8693	2	2026-03-02 22:54:53.491753	63.89	56.82	67.30	t	t	t
8694	3	2026-03-02 22:54:53.491933	24.52	44.91	49.39	t	t	t
8695	5	2026-03-02 22:54:53.522924	21.29	33.06	33.70	t	t	t
8696	2	2026-03-02 22:55:03.500844	49.64	11.34	42.38	t	t	t
8697	5	2026-03-02 22:55:03.541916	77.81	22.98	20.16	t	t	t
8698	4	2026-03-02 22:55:03.653105	30.15	63.91	68.28	t	t	t
8699	3	2026-03-02 22:55:03.654121	13.99	24.64	41.92	t	t	t
8700	2	2026-03-02 22:55:13.519875	50.43	30.17	37.00	t	t	t
8701	3	2026-03-02 22:55:13.520132	12.67	39.62	45.00	t	t	t
8702	4	2026-03-02 22:55:13.520341	47.03	15.51	26.43	t	t	t
8703	5	2026-03-02 22:55:13.573751	64.89	16.16	29.88	t	t	t
8704	2	2026-03-02 22:55:23.520512	53.93	23.08	27.03	t	t	t
8705	5	2026-03-02 22:55:23.52074	47.52	63.82	31.02	t	t	t
8706	3	2026-03-02 22:55:23.520862	27.43	73.94	43.80	t	t	t
8707	4	2026-03-02 22:55:23.521098	64.93	41.01	52.59	t	f	f
8708	2	2026-03-02 22:55:33.535765	56.59	36.48	24.73	t	t	t
8709	3	2026-03-02 22:55:33.572077	66.54	28.56	32.78	t	f	t
8710	4	2026-03-02 22:55:33.575486	77.40	67.06	38.98	t	t	t
8711	5	2026-03-02 22:55:33.575748	73.94	72.65	29.12	t	t	t
8712	2	2026-03-02 22:55:43.537829	18.48	72.24	53.88	t	f	t
8713	5	2026-03-02 22:55:43.538151	35.49	11.50	47.65	t	t	t
8714	3	2026-03-02 22:55:43.53847	12.20	58.69	34.10	t	t	t
8715	4	2026-03-02 22:55:43.53859	56.17	67.38	65.94	t	t	f
8716	4	2026-03-02 22:55:53.535482	18.39	37.27	21.20	t	t	t
8717	5	2026-03-02 22:55:53.535824	69.16	53.31	34.72	t	t	t
8718	3	2026-03-02 22:55:53.536034	38.88	49.93	34.95	t	t	t
8719	2	2026-03-02 22:55:53.536321	39.45	21.16	56.36	t	t	f
8824	2	2026-03-02 23:00:23.708659	47.87	55.62	37.23	f	t	t
8825	3	2026-03-02 23:00:23.709183	56.64	21.36	40.72	t	t	t
8826	5	2026-03-02 23:00:23.709488	63.87	27.01	36.31	t	t	t
8827	4	2026-03-02 23:00:23.710122	44.18	44.52	40.61	t	f	t
8828	2	2026-03-02 23:00:33.731051	26.19	60.75	41.85	t	t	f
8829	3	2026-03-02 23:00:33.778429	15.28	25.68	59.03	t	f	t
8830	4	2026-03-02 23:00:33.78012	42.29	76.18	26.54	t	f	f
8831	5	2026-03-02 23:00:33.78241	36.24	58.71	54.81	t	t	t
8832	3	2026-03-02 23:00:43.725387	63.52	70.28	33.10	t	t	t
8833	2	2026-03-02 23:00:43.725684	63.33	59.36	20.87	t	f	t
8834	5	2026-03-02 23:00:43.725905	46.78	34.51	28.71	t	t	t
8835	4	2026-03-02 23:00:43.726193	48.69	58.13	49.19	t	t	t
8836	2	2026-03-02 23:00:53.718867	36.60	16.75	43.46	t	t	t
8837	3	2026-03-02 23:00:53.718976	60.45	59.24	66.80	t	t	t
8838	5	2026-03-02 23:00:53.719087	73.47	39.03	55.73	t	t	t
8839	4	2026-03-02 23:00:53.719821	13.72	15.39	41.53	t	t	f
8840	2	2026-03-02 23:01:03.736298	11.54	16.21	35.94	t	t	t
8841	3	2026-03-02 23:01:03.777017	32.13	28.68	58.04	t	t	t
8842	5	2026-03-02 23:01:03.789009	68.37	17.66	40.53	t	t	t
8843	4	2026-03-02 23:01:03.789174	69.40	14.13	65.88	f	f	f
8844	2	2026-03-02 23:01:13.754756	53.48	54.30	65.23	t	t	t
8845	3	2026-03-02 23:01:13.755196	15.30	70.54	68.58	t	t	t
8846	4	2026-03-02 23:01:13.755342	64.20	70.69	62.58	t	t	t
8847	5	2026-03-02 23:01:13.796713	79.90	71.57	66.45	t	t	t
8848	2	2026-03-02 23:01:23.759073	71.64	62.32	42.75	t	t	t
8849	3	2026-03-02 23:01:23.759263	60.21	27.99	68.56	t	t	t
8850	5	2026-03-02 23:01:23.759407	25.65	69.88	32.99	t	t	t
8851	4	2026-03-02 23:01:23.7597	75.92	37.54	21.23	t	t	f
8852	4	2026-03-02 23:01:33.755182	35.02	59.15	29.40	t	t	t
8853	5	2026-03-02 23:01:33.755304	70.48	62.10	60.43	t	t	t
8854	2	2026-03-02 23:01:33.755353	19.32	40.45	21.92	t	t	f
8855	3	2026-03-02 23:01:33.755423	23.70	70.74	39.93	t	f	t
8856	3	2026-03-02 23:01:43.755164	58.56	43.46	47.90	t	t	t
8857	2	2026-03-02 23:01:43.755493	73.16	35.48	25.15	t	f	t
8858	5	2026-03-02 23:01:43.755636	14.70	18.15	28.92	t	t	t
8859	4	2026-03-02 23:01:43.755588	29.32	75.27	21.76	f	f	t
8860	2	2026-03-02 23:01:53.756486	31.84	70.86	66.14	t	t	f
8861	3	2026-03-02 23:01:53.756918	70.28	61.06	35.95	t	t	t
8862	5	2026-03-02 23:01:53.756975	37.67	59.71	50.01	f	t	f
8863	4	2026-03-02 23:01:53.757047	29.49	21.30	52.02	t	t	t
8864	2	2026-03-02 23:02:03.757285	79.73	56.68	25.29	f	t	t
8865	5	2026-03-02 23:02:03.757409	25.92	68.70	49.37	f	t	t
8866	3	2026-03-02 23:02:03.757466	55.23	23.52	34.03	t	t	t
8867	4	2026-03-02 23:02:03.757529	48.46	77.68	58.54	t	t	t
8868	2	2026-03-02 23:04:53.919746	20.49	60.90	34.72	t	f	t
8869	3	2026-03-02 23:04:53.958243	73.63	10.63	25.62	t	t	t
8870	4	2026-03-02 23:04:53.960652	24.71	51.55	38.50	t	t	t
8871	5	2026-03-02 23:04:53.961486	18.42	27.29	55.49	t	t	t
8872	2	2026-03-02 23:05:03.930512	19.20	35.61	63.02	t	t	f
8873	3	2026-03-02 23:05:03.970464	65.10	61.48	44.29	t	t	f
8874	4	2026-03-02 23:05:03.975797	13.02	54.20	67.82	t	t	t
8875	5	2026-03-02 23:05:03.976928	39.95	16.17	24.46	t	t	t
8876	3	2026-03-02 23:05:23.924273	36.24	78.81	67.70	t	f	t
8877	2	2026-03-02 23:05:23.964943	33.67	36.38	20.92	t	t	t
8878	4	2026-03-02 23:05:23.968765	61.09	47.73	46.81	t	t	f
8879	5	2026-03-02 23:05:23.970599	49.52	52.38	24.44	t	t	t
8880	2	2026-03-02 23:05:33.896334	48.81	18.94	62.10	t	t	t
8881	3	2026-03-02 23:05:33.896595	10.55	14.18	67.36	t	t	t
8882	4	2026-03-02 23:05:33.896843	21.73	58.19	63.21	t	t	t
8883	5	2026-03-02 23:05:33.89708	39.79	47.38	41.74	t	t	t
8884	2	2026-03-02 23:05:43.913566	44.69	12.03	43.91	t	t	t
8885	3	2026-03-02 23:05:43.949178	23.28	44.39	47.21	t	t	f
8886	4	2026-03-02 23:05:43.951872	53.32	41.00	58.51	t	t	f
8887	5	2026-03-02 23:05:43.954924	15.51	22.53	21.02	t	t	t
8888	2	2026-03-02 23:05:53.91526	62.21	65.27	33.17	t	t	t
8889	4	2026-03-02 23:05:53.915792	66.78	29.36	34.80	t	t	t
8890	3	2026-03-02 23:05:53.916326	75.59	49.39	46.53	t	f	t
8891	5	2026-03-02 23:05:53.917056	70.05	44.37	44.30	t	t	t
8892	2	2026-03-02 23:06:03.922143	15.51	10.30	41.59	t	t	t
8893	3	2026-03-02 23:06:03.922518	40.05	43.17	62.23	t	t	f
8894	4	2026-03-02 23:06:03.922961	65.75	53.93	49.42	t	t	t
8895	5	2026-03-02 23:06:03.953746	62.45	33.55	24.21	t	t	t
8896	2	2026-03-02 23:06:13.944417	23.01	22.60	21.61	t	t	t
8897	3	2026-03-02 23:06:13.981058	50.52	34.47	26.28	t	t	t
8898	4	2026-03-02 23:06:13.984695	17.14	48.26	61.20	t	t	f
8899	5	2026-03-02 23:06:13.985553	33.06	42.82	20.69	t	t	t
8900	2	2026-03-02 23:06:23.93939	49.86	63.57	26.23	t	t	t
8901	3	2026-03-02 23:06:23.939573	34.59	61.74	26.93	t	t	t
8902	4	2026-03-02 23:06:23.939756	50.80	64.47	23.41	t	t	f
8903	5	2026-03-02 23:06:23.971343	79.93	72.63	47.31	t	t	t
8904	2	2026-03-02 23:06:33.943599	73.01	64.55	54.57	t	t	f
8905	3	2026-03-02 23:06:33.943818	33.35	55.76	55.11	t	f	t
8906	4	2026-03-02 23:06:33.944098	68.50	54.67	34.25	t	t	t
8907	5	2026-03-02 23:06:33.944389	74.66	46.23	67.25	t	t	t
8908	2	2026-03-02 23:06:43.956781	61.90	41.98	24.58	t	t	t
8909	4	2026-03-02 23:06:44.007436	68.42	34.87	42.55	f	t	t
8910	5	2026-03-02 23:06:44.007589	57.45	77.25	30.53	t	t	t
8911	3	2026-03-02 23:06:44.109212	32.73	36.96	40.19	t	t	t
8912	2	2026-03-02 23:06:53.964206	79.07	27.72	68.55	t	t	t
8913	3	2026-03-02 23:06:53.96467	55.81	34.24	56.21	t	f	t
8914	4	2026-03-02 23:06:53.964924	21.61	16.36	59.98	t	t	t
8915	5	2026-03-02 23:06:53.996787	68.60	18.57	66.44	t	t	t
8916	2	2026-03-02 23:07:03.969788	72.59	67.55	67.69	t	t	t
8917	4	2026-03-02 23:07:03.970064	12.01	19.82	39.95	t	t	t
8918	3	2026-03-02 23:07:03.970395	40.98	77.71	39.04	t	t	t
8919	5	2026-03-02 23:07:04.007611	19.03	36.64	49.95	t	t	t
8920	2	2026-03-02 23:07:13.976553	36.66	59.87	34.15	t	t	t
8921	3	2026-03-02 23:07:13.976929	56.90	12.28	66.59	t	t	t
8922	4	2026-03-02 23:07:14.010716	67.54	71.24	57.63	t	t	t
8923	5	2026-03-02 23:07:14.011076	37.94	28.23	36.03	t	t	t
8924	2	2026-03-02 23:07:23.979816	53.34	36.66	47.50	t	t	t
8925	5	2026-03-02 23:07:23.980838	38.03	56.45	61.32	t	t	t
8926	4	2026-03-02 23:07:23.981187	39.70	17.79	66.19	t	t	t
8927	3	2026-03-02 23:07:23.981345	71.35	67.34	58.61	t	t	t
8928	2	2026-03-02 23:07:33.977704	17.53	15.98	59.56	t	t	t
8929	5	2026-03-02 23:07:33.977837	77.01	33.34	30.21	t	t	t
8931	4	2026-03-02 23:07:33.978028	34.83	55.51	69.86	t	t	t
8930	3	2026-03-02 23:07:33.977976	74.45	61.29	41.32	t	t	t
8932	2	2026-03-02 23:07:43.990912	73.78	73.48	45.85	t	t	t
8933	3	2026-03-02 23:07:44.041187	60.84	11.40	23.60	t	t	t
8934	4	2026-03-02 23:07:44.044249	20.55	26.26	40.71	t	t	t
8935	5	2026-03-02 23:07:44.055605	13.92	24.27	39.93	t	t	t
8936	2	2026-03-02 23:07:53.985149	54.24	41.14	36.92	t	t	f
8938	3	2026-03-02 23:07:53.985777	70.03	22.47	55.72	t	t	t
8942	3	2026-03-02 23:08:03.986409	75.26	68.21	54.47	t	t	t
8943	4	2026-03-02 23:08:03.987504	34.64	40.43	42.72	t	t	t
8944	2	2026-03-02 23:08:13.995417	58.63	10.33	35.70	t	t	t
8937	4	2026-03-02 23:07:53.985357	33.25	12.91	52.24	t	t	t
8941	2	2026-03-02 23:08:03.985501	30.21	52.91	53.83	t	t	t
8939	5	2026-03-02 23:07:53.986138	78.83	56.87	23.34	t	t	t
8940	5	2026-03-02 23:08:03.984392	79.61	79.92	56.52	f	t	f
8945	3	2026-03-02 23:08:14.045074	63.44	15.79	62.12	t	t	t
8946	4	2026-03-02 23:08:14.045261	51.45	32.35	69.10	t	t	t
8947	5	2026-03-02 23:08:14.048547	61.00	36.13	27.36	t	t	t
8948	2	2026-03-02 23:08:24.007684	70.88	55.43	39.31	t	t	t
8949	3	2026-03-02 23:08:24.007991	19.63	27.02	20.30	t	t	t
8950	4	2026-03-02 23:08:24.008326	58.91	34.79	68.50	t	t	t
8951	5	2026-03-02 23:08:24.045535	24.17	52.65	32.40	t	t	t
8952	2	2026-03-02 23:08:34.057806	33.36	55.01	52.76	t	t	t
8953	4	2026-03-02 23:08:34.100262	12.37	68.77	57.04	t	t	t
8954	5	2026-03-02 23:08:34.100815	51.61	43.05	57.97	t	t	f
8955	3	2026-03-02 23:08:34.197092	68.32	63.08	27.94	t	t	t
8956	2	2026-03-02 23:08:44.033986	29.59	62.59	46.78	t	t	t
8957	5	2026-03-02 23:08:44.034406	39.27	69.47	36.81	f	f	t
8958	4	2026-03-02 23:08:44.034576	49.88	20.25	64.88	t	t	t
8959	3	2026-03-02 23:08:44.034868	55.10	40.99	57.22	t	f	t
8960	2	2026-03-02 23:08:54.086805	28.81	27.35	28.45	t	t	t
8961	3	2026-03-02 23:08:54.096071	58.55	37.79	42.07	t	t	t
8962	4	2026-03-02 23:08:54.096967	64.12	22.60	42.01	t	t	t
8963	5	2026-03-02 23:08:54.097554	36.24	21.23	53.71	t	t	t
8964	2	2026-03-02 23:09:04.056535	49.46	39.68	62.87	t	t	t
8965	4	2026-03-02 23:09:04.05708	60.69	30.95	64.65	t	f	t
8966	3	2026-03-02 23:09:04.057499	76.67	45.83	67.82	t	t	t
8967	5	2026-03-02 23:09:04.057727	51.14	23.50	56.12	t	t	t
8968	2	2026-03-02 23:09:14.074694	56.60	16.62	40.25	t	t	t
8969	3	2026-03-02 23:09:14.110297	53.76	25.84	67.09	t	t	t
8970	4	2026-03-02 23:09:14.112943	30.07	51.98	27.92	t	f	t
8971	5	2026-03-02 23:09:14.113936	66.72	52.05	38.11	t	t	t
8972	2	2026-03-02 23:09:24.079025	43.76	62.43	50.21	t	t	t
8973	5	2026-03-02 23:09:24.079427	28.30	39.40	39.00	t	t	t
8974	3	2026-03-02 23:09:24.079609	62.04	22.02	46.62	t	t	t
8975	4	2026-03-02 23:09:24.080121	34.82	22.98	23.23	t	f	f
8976	2	2026-03-02 23:09:34.092041	54.64	60.30	40.97	t	t	t
8977	3	2026-03-02 23:09:34.134568	13.77	36.13	62.92	t	t	t
8978	5	2026-03-02 23:09:34.142048	43.25	49.53	48.70	t	t	t
8979	4	2026-03-02 23:09:34.142872	15.73	62.32	33.18	t	t	t
8980	2	2026-03-02 23:09:44.092531	64.67	60.45	42.97	t	t	t
8981	3	2026-03-02 23:09:44.092698	48.40	47.41	55.33	t	f	t
8982	4	2026-03-02 23:09:44.092841	23.23	21.14	20.36	t	t	f
8983	5	2026-03-02 23:09:44.092978	33.85	19.74	30.19	t	t	t
8984	2	2026-03-02 23:09:54.09748	45.81	36.33	56.17	t	t	t
8985	5	2026-03-02 23:09:54.097591	78.40	74.68	33.75	f	t	f
8986	4	2026-03-02 23:09:54.097868	13.43	51.79	35.79	t	t	t
8987	3	2026-03-02 23:09:54.098077	15.55	24.01	59.74	t	t	t
8988	2	2026-03-02 23:10:04.110964	60.31	66.61	35.70	t	t	t
8989	3	2026-03-02 23:10:04.148186	34.79	14.76	39.10	t	t	t
8990	4	2026-03-02 23:10:04.150845	45.72	51.28	56.00	t	f	f
8991	5	2026-03-02 23:10:04.154467	38.56	33.42	37.84	t	t	t
8992	2	2026-03-02 23:10:14.124054	37.77	70.11	52.10	t	t	t
8993	3	2026-03-02 23:10:14.124493	41.12	16.63	32.49	t	t	f
8994	4	2026-03-02 23:10:14.124838	12.75	56.64	27.71	t	t	f
8995	5	2026-03-02 23:10:14.156844	26.04	50.73	58.01	t	f	t
8996	2	2026-03-02 23:10:24.135638	50.98	32.32	43.96	t	t	t
8997	3	2026-03-02 23:10:24.174929	33.37	12.33	28.08	t	t	t
8998	4	2026-03-02 23:10:24.175973	10.07	41.78	64.04	t	t	t
8999	5	2026-03-02 23:10:24.179537	33.67	36.18	69.89	t	t	t
9000	2	2026-03-02 23:10:34.147482	20.60	57.59	36.99	t	t	t
9001	4	2026-03-02 23:10:34.147665	27.69	24.28	48.53	t	t	f
9002	3	2026-03-02 23:10:34.147841	33.65	14.36	57.80	t	t	f
9003	5	2026-03-02 23:10:34.177295	29.30	58.51	47.37	t	t	f
9004	2	2026-03-02 23:10:44.157477	38.73	58.96	63.11	t	t	t
9006	4	2026-03-02 23:10:44.194929	32.41	43.72	32.36	t	t	t
9005	3	2026-03-02 23:10:44.194747	22.87	61.48	55.24	t	t	t
9007	5	2026-03-02 23:10:44.303466	44.18	25.59	52.89	t	t	f
9008	2	2026-03-02 23:10:54.158088	15.71	28.67	54.49	t	t	t
9009	3	2026-03-02 23:10:54.158304	33.66	50.99	22.89	t	t	t
9010	4	2026-03-02 23:10:54.158556	15.66	63.58	47.93	t	t	f
9011	5	2026-03-02 23:10:54.158634	63.65	53.34	68.47	t	t	t
9012	2	2026-03-02 23:11:14.19451	72.78	31.02	54.32	t	t	t
9013	3	2026-03-02 23:11:14.23819	12.64	32.07	41.35	t	f	t
9014	4	2026-03-02 23:11:14.240491	11.30	10.00	21.13	t	f	t
9015	5	2026-03-02 23:11:14.24069	39.14	38.15	64.32	t	t	f
9016	2	2026-03-02 23:11:24.188411	68.03	34.60	30.80	t	t	t
9017	3	2026-03-02 23:11:24.188763	52.14	46.58	33.97	f	t	t
9018	4	2026-03-02 23:11:24.189128	69.95	69.49	67.07	t	t	t
9019	5	2026-03-02 23:11:24.189497	66.26	20.43	45.65	t	t	t
9020	3	2026-03-02 23:11:34.188165	47.51	45.77	59.33	t	t	t
9021	4	2026-03-02 23:11:34.188544	21.07	26.42	61.58	t	t	f
9022	2	2026-03-02 23:11:34.188759	53.63	29.21	27.66	t	t	f
9023	5	2026-03-02 23:11:34.22066	58.24	48.74	45.09	t	t	t
9024	2	2026-03-02 23:11:44.204121	49.27	55.67	46.01	t	t	t
9025	3	2026-03-02 23:11:44.240283	22.57	30.38	47.47	t	t	t
9026	5	2026-03-02 23:11:44.241871	70.25	64.29	67.21	t	t	t
9027	4	2026-03-02 23:11:44.242179	29.81	43.04	27.16	t	t	t
9029	3	2026-03-02 23:11:54.21302	72.37	31.02	25.47	t	t	t
9028	2	2026-03-02 23:11:54.212879	58.85	27.18	39.77	t	t	t
9030	4	2026-03-02 23:11:54.213205	17.42	12.74	57.10	t	t	f
9031	5	2026-03-02 23:11:54.355438	10.18	67.62	23.08	t	t	t
9032	2	2026-03-02 23:12:04.231779	25.85	39.53	53.10	t	t	f
9033	3	2026-03-02 23:12:04.279197	66.92	58.47	68.03	t	t	t
9034	5	2026-03-02 23:12:04.283734	56.76	25.61	47.05	t	t	t
9035	4	2026-03-02 23:12:04.283885	28.42	50.43	60.42	f	t	t
9036	2	2026-03-02 23:12:14.217984	42.06	61.41	65.38	t	t	t
9037	5	2026-03-02 23:12:14.21817	46.69	51.85	39.85	t	t	t
9038	3	2026-03-02 23:12:14.218402	49.20	15.29	66.54	t	t	t
9039	4	2026-03-02 23:12:14.21858	36.07	69.28	27.31	f	t	t
9040	2	2026-03-02 23:12:24.265544	48.98	60.34	22.49	t	t	f
9041	3	2026-03-02 23:12:24.300785	41.49	54.09	38.42	t	t	t
9042	4	2026-03-02 23:12:24.301219	34.54	47.90	41.60	t	t	t
9043	5	2026-03-02 23:12:24.305348	57.74	18.57	50.95	t	t	t
9044	2	2026-03-02 23:12:34.238542	32.63	40.21	41.91	t	t	t
9045	5	2026-03-02 23:12:34.238962	10.23	65.53	22.50	t	t	t
9046	4	2026-03-02 23:12:34.239327	32.30	73.99	40.09	t	t	t
9047	3	2026-03-02 23:12:34.240129	21.89	40.41	25.40	t	t	t
9048	2	2026-03-02 23:12:44.253578	69.41	49.67	23.01	t	t	t
9049	3	2026-03-02 23:12:44.254265	71.69	64.50	54.83	t	t	t
9050	4	2026-03-02 23:12:44.254952	44.96	12.55	40.14	f	f	f
9051	5	2026-03-02 23:12:44.286169	46.43	74.71	57.19	t	f	t
9052	2	2026-03-02 23:12:54.260563	68.40	70.51	66.89	t	t	t
9054	3	2026-03-02 23:12:54.261023	59.71	51.03	24.34	t	t	t
9058	5	2026-03-02 23:13:04.264277	75.87	79.00	53.16	t	t	t
9059	3	2026-03-02 23:13:04.264505	52.07	31.76	33.19	t	t	f
9060	2	2026-03-02 23:13:14.27254	39.52	10.34	46.90	t	t	t
9067	5	2026-03-02 23:13:24.279652	10.29	42.58	42.47	t	t	t
9068	2	2026-03-02 23:13:34.284624	41.23	30.95	20.65	t	t	f
9075	5	2026-03-02 23:13:44.290109	63.78	23.79	27.76	t	t	t
9076	2	2026-03-02 23:13:54.286067	35.56	60.25	66.06	t	t	t
9053	5	2026-03-02 23:12:54.260817	38.33	51.66	24.72	t	t	t
9057	4	2026-03-02 23:13:04.264037	27.06	57.83	67.32	t	t	t
9055	4	2026-03-02 23:12:54.261249	65.69	38.54	68.87	t	t	t
9056	2	2026-03-02 23:13:04.26378	70.12	67.83	34.82	t	t	t
9061	3	2026-03-02 23:13:14.307508	13.01	27.92	22.24	t	t	t
9062	5	2026-03-02 23:13:14.313392	24.65	54.37	54.11	t	t	t
9063	4	2026-03-02 23:13:14.313626	62.07	44.68	44.80	f	t	t
9064	2	2026-03-02 23:13:24.278452	65.58	53.81	63.02	t	t	t
9065	3	2026-03-02 23:13:24.278938	42.76	65.02	52.93	t	t	t
9066	4	2026-03-02 23:13:24.27946	50.04	73.25	61.26	t	t	t
9069	3	2026-03-02 23:13:34.284985	26.97	78.63	44.03	t	t	t
9070	4	2026-03-02 23:13:34.285536	54.83	68.94	67.98	t	t	t
9071	5	2026-03-02 23:13:34.317748	13.09	66.31	60.87	t	t	t
9072	2	2026-03-02 23:13:44.289025	27.20	69.18	54.54	t	f	t
9073	3	2026-03-02 23:13:44.289481	77.36	51.62	38.15	t	t	t
9074	4	2026-03-02 23:13:44.289797	15.82	54.47	67.93	t	t	t
9077	3	2026-03-02 23:13:54.286447	15.23	54.77	38.87	t	t	t
9078	5	2026-03-02 23:13:54.286744	28.71	13.15	35.68	t	t	t
9079	4	2026-03-02 23:13:54.286806	57.22	36.94	23.60	t	t	t
9080	2	2026-03-02 23:14:04.301563	34.89	64.33	60.60	t	t	t
9081	3	2026-03-02 23:14:04.3364	77.51	23.89	24.49	t	t	t
9082	4	2026-03-02 23:14:04.340523	47.85	23.35	53.74	t	t	t
9083	5	2026-03-02 23:14:04.340753	76.43	25.07	21.75	t	t	t
9084	2	2026-03-02 23:14:14.304842	10.30	45.74	48.71	t	t	f
9085	4	2026-03-02 23:14:14.305242	57.18	50.02	23.85	t	t	f
9086	5	2026-03-02 23:14:14.305518	62.68	13.09	49.88	t	t	t
9087	3	2026-03-02 23:14:14.305695	68.73	46.49	22.04	t	t	t
9088	2	2026-03-02 23:14:24.297905	70.79	26.99	54.90	t	t	t
9089	4	2026-03-02 23:14:24.298048	19.57	31.73	57.29	t	t	t
9090	3	2026-03-02 23:14:24.298179	46.31	30.51	38.79	t	t	t
9091	5	2026-03-02 23:14:24.298306	48.70	22.84	57.37	t	t	f
9092	2	2026-03-02 23:14:34.305642	58.60	30.62	26.37	t	t	t
9093	3	2026-03-02 23:14:34.305962	44.72	12.05	32.78	t	t	t
9094	4	2026-03-02 23:14:34.339854	30.56	50.97	69.64	t	t	t
9095	5	2026-03-02 23:14:34.339997	44.46	42.12	37.55	t	f	t
9096	2	2026-03-02 23:14:44.306799	43.61	23.66	27.41	t	t	t
9097	4	2026-03-02 23:14:44.306978	60.13	18.38	51.21	t	t	t
9098	3	2026-03-02 23:14:44.307289	48.19	72.51	21.56	t	t	t
9099	5	2026-03-02 23:14:44.307527	74.13	58.85	33.42	t	t	t
9100	2	2026-03-02 23:14:54.31007	51.92	17.26	37.52	t	t	f
9101	3	2026-03-02 23:14:54.310382	79.78	52.87	43.52	t	t	t
9102	5	2026-03-02 23:14:54.310518	15.61	15.05	66.41	t	t	t
9103	4	2026-03-02 23:14:54.310724	74.46	21.56	42.28	t	t	t
9104	2	2026-03-02 23:15:04.321416	50.25	64.50	35.77	t	t	t
9105	3	2026-03-02 23:15:04.35979	50.82	38.93	27.12	t	t	t
9106	5	2026-03-02 23:15:04.363142	20.13	46.63	40.75	t	t	t
9107	4	2026-03-02 23:15:04.36326	28.25	34.93	48.63	t	t	f
9108	2	2026-03-02 23:15:14.338619	74.45	58.69	33.61	t	t	t
9109	3	2026-03-02 23:15:14.339037	55.18	37.78	50.36	t	t	t
9110	4	2026-03-02 23:15:14.33958	13.33	24.72	24.08	t	t	t
9111	5	2026-03-02 23:15:14.475052	62.11	59.08	22.94	t	t	f
9112	2	2026-03-02 23:15:24.34899	23.34	26.55	24.88	t	t	t
9113	3	2026-03-02 23:15:24.383559	63.87	27.42	34.89	t	t	f
9114	4	2026-03-02 23:15:24.38896	60.32	72.66	38.09	t	t	t
9115	5	2026-03-02 23:15:24.389383	47.18	30.43	51.81	t	t	f
9116	2	2026-03-02 23:15:34.363072	44.95	18.73	22.07	t	t	f
9117	3	2026-03-02 23:15:34.36351	56.62	57.87	67.67	t	t	t
9118	4	2026-03-02 23:15:34.364938	47.10	64.26	52.99	t	t	t
9119	5	2026-03-02 23:15:34.502863	28.72	24.22	68.06	t	t	f
9120	2	2026-03-02 23:15:44.366541	72.94	57.05	60.47	t	t	t
9121	3	2026-03-02 23:15:44.366947	77.18	70.99	39.51	t	t	t
9122	4	2026-03-02 23:15:44.367057	14.59	51.07	57.30	t	t	t
9123	5	2026-03-02 23:15:44.367189	76.82	66.98	37.88	t	t	t
9124	2	2026-03-02 23:15:54.364644	43.31	52.05	51.08	t	t	t
9125	3	2026-03-02 23:15:54.364543	21.65	47.49	57.46	t	t	t
9126	4	2026-03-02 23:15:54.364666	67.31	28.29	68.20	t	t	t
9127	5	2026-03-02 23:15:54.36522	30.35	28.61	33.19	t	t	f
9128	2	2026-03-02 23:16:04.365762	41.24	23.86	67.12	t	f	f
9129	5	2026-03-02 23:16:04.365972	22.95	59.28	63.74	t	t	t
9130	4	2026-03-02 23:16:04.366213	59.52	17.64	49.46	f	f	f
9131	3	2026-03-02 23:16:04.366213	47.55	13.74	54.00	t	t	t
9132	3	2026-03-02 23:16:14.369938	52.92	66.51	62.09	t	t	t
9133	2	2026-03-02 23:16:14.370167	73.74	61.04	60.01	t	t	t
9134	4	2026-03-02 23:16:14.370514	26.81	73.51	23.27	t	t	t
9135	5	2026-03-02 23:16:14.370423	63.82	49.96	63.48	t	f	t
9136	3	2026-03-02 23:16:24.379178	61.79	69.42	59.48	t	t	t
9137	4	2026-03-02 23:16:24.415284	51.26	30.15	28.63	t	t	t
9138	5	2026-03-02 23:16:24.415891	19.56	23.35	67.97	t	t	t
9139	2	2026-03-02 23:16:24.510401	31.50	52.60	38.26	t	t	f
9140	2	2026-03-02 23:16:34.378215	51.68	18.26	62.91	t	t	t
9141	4	2026-03-02 23:16:34.378359	32.43	58.57	36.51	t	f	t
9142	5	2026-03-02 23:16:34.378477	49.90	11.40	38.13	t	t	t
9143	3	2026-03-02 23:16:34.378659	26.93	75.13	42.92	t	t	t
9144	3	2026-03-02 23:16:44.397179	58.29	71.28	61.85	t	t	t
9145	4	2026-03-02 23:16:44.433329	76.64	16.98	60.14	t	t	t
9146	5	2026-03-02 23:16:44.43901	15.80	26.39	27.42	t	t	t
9147	2	2026-03-02 23:16:44.439257	44.04	34.78	62.78	t	t	t
9148	2	2026-03-02 23:16:54.40008	70.59	29.12	31.42	t	t	t
9149	3	2026-03-02 23:16:54.400671	14.94	43.24	52.99	t	t	f
9150	4	2026-03-02 23:16:54.400973	47.36	34.93	54.76	t	f	t
9151	5	2026-03-02 23:16:54.401401	67.65	44.96	37.91	f	t	t
9152	2	2026-03-02 23:17:04.397341	72.35	79.33	24.84	t	t	t
9153	5	2026-03-02 23:17:04.397565	17.00	34.37	49.81	t	t	t
9154	4	2026-03-02 23:17:04.397728	79.74	33.27	59.88	f	t	t
9155	3	2026-03-02 23:17:04.39794	29.41	47.54	32.76	t	t	t
9156	2	2026-03-02 23:17:14.397252	33.55	26.81	67.59	t	t	t
9157	5	2026-03-02 23:17:14.397314	67.76	36.47	57.39	t	t	t
9158	4	2026-03-02 23:17:14.397433	48.37	24.06	44.88	f	t	t
9159	3	2026-03-02 23:17:14.397496	71.07	19.16	67.90	t	t	t
9160	2	2026-03-02 23:17:24.402475	46.19	79.82	26.48	t	t	t
9161	3	2026-03-02 23:17:24.402631	10.46	17.70	38.28	t	t	t
9162	5	2026-03-02 23:17:24.435093	77.00	11.51	47.49	t	t	t
9163	4	2026-03-02 23:17:24.531532	33.49	53.82	59.78	t	t	t
9164	2	2026-03-02 23:17:34.405669	72.83	59.96	65.46	t	t	t
9165	3	2026-03-02 23:17:34.405932	16.19	11.29	43.29	t	t	f
9166	4	2026-03-02 23:17:34.405785	26.73	71.96	36.82	t	t	t
9167	5	2026-03-02 23:17:34.405903	50.00	48.58	48.64	t	t	t
9168	2	2026-03-02 23:17:44.403544	46.63	26.90	59.51	t	t	t
9169	5	2026-03-02 23:17:44.403736	25.64	40.68	44.36	t	t	f
9170	3	2026-03-02 23:17:44.403868	76.21	14.63	42.25	t	t	t
9173	3	2026-03-02 23:17:54.403973	51.20	53.14	25.61	t	t	t
9178	4	2026-03-02 23:18:04.407166	39.83	20.06	24.81	t	t	t
9180	4	2026-03-02 23:18:14.408005	19.72	18.74	60.00	t	t	t
9171	4	2026-03-02 23:17:44.403987	71.06	73.71	50.58	t	t	t
9172	2	2026-03-02 23:17:54.403447	59.82	10.41	38.20	t	t	t
9177	5	2026-03-02 23:18:04.406964	18.83	76.49	32.46	t	t	t
9182	3	2026-03-02 23:18:14.408271	57.53	54.94	48.48	f	t	t
9174	5	2026-03-02 23:17:54.40421	61.58	52.28	20.91	t	t	t
9179	2	2026-03-02 23:18:04.407206	62.04	51.87	53.72	t	t	t
9181	2	2026-03-02 23:18:14.408133	40.78	78.24	59.43	t	t	t
9175	4	2026-03-02 23:17:54.404391	39.47	79.83	61.91	t	t	t
9176	3	2026-03-02 23:18:04.406828	60.06	55.25	38.97	t	f	t
9183	5	2026-03-02 23:18:14.408431	70.36	25.24	35.69	f	t	t
9184	2	2026-03-02 23:18:24.421277	53.05	35.32	39.81	t	t	t
9190	5	2026-03-02 23:18:34.427402	67.56	43.69	37.71	f	t	t
9185	3	2026-03-02 23:18:24.456056	52.66	56.22	56.29	t	t	t
9186	4	2026-03-02 23:18:24.459862	61.27	76.63	68.60	t	t	t
9187	5	2026-03-02 23:18:24.46126	17.40	27.53	38.19	t	t	t
9188	2	2026-03-02 23:18:34.426481	30.02	77.95	26.62	t	t	t
9189	3	2026-03-02 23:18:34.426986	46.66	11.65	61.51	t	t	t
9191	4	2026-03-02 23:18:34.427629	51.41	11.29	30.83	t	t	t
9192	2	2026-03-02 23:18:44.440767	47.31	29.97	52.18	t	t	t
9193	3	2026-03-02 23:18:44.477391	30.56	52.15	58.51	t	t	t
9194	4	2026-03-02 23:18:44.483269	53.40	50.90	35.15	t	t	t
9195	5	2026-03-02 23:18:44.486494	75.72	62.63	52.12	t	t	t
9196	2	2026-03-02 23:18:54.439843	73.18	24.22	43.98	t	t	t
9197	5	2026-03-02 23:18:54.440003	11.87	11.32	26.50	t	f	t
9198	4	2026-03-02 23:18:54.440155	10.43	57.57	47.52	t	t	f
9199	3	2026-03-02 23:18:54.440155	59.10	35.75	23.74	f	t	t
9200	2	2026-03-02 23:19:04.452374	40.24	31.51	54.52	t	t	t
9201	3	2026-03-02 23:19:04.494376	27.72	43.40	24.80	t	t	t
9202	5	2026-03-02 23:19:04.500385	10.67	38.25	42.88	t	t	f
9203	4	2026-03-02 23:19:04.501759	65.68	45.45	54.32	t	f	t
9204	3	2026-03-02 23:19:14.45373	16.28	69.17	39.44	t	t	f
9205	2	2026-03-02 23:19:14.454332	70.68	56.92	43.41	t	t	t
9206	4	2026-03-02 23:19:14.489468	32.13	51.37	66.28	t	t	t
9207	5	2026-03-02 23:19:14.489778	76.16	67.93	60.50	t	t	t
9208	2	2026-03-02 23:19:24.459293	72.01	12.91	57.23	f	t	f
9209	3	2026-03-02 23:19:24.459855	28.65	46.12	42.98	t	t	f
9210	5	2026-03-02 23:19:24.460136	20.43	68.86	61.22	t	t	t
9211	4	2026-03-02 23:19:24.460402	10.42	75.38	59.14	t	t	t
9212	2	2026-03-02 23:19:34.460684	32.71	38.23	31.75	t	t	t
9213	3	2026-03-02 23:19:34.460919	56.80	48.83	58.63	f	t	t
9214	5	2026-03-02 23:19:34.461359	74.98	24.62	54.73	t	t	t
9215	4	2026-03-02 23:19:34.46157	50.66	75.96	52.99	t	t	f
9216	2	2026-03-02 23:19:44.472127	61.16	56.80	30.96	t	t	t
9218	5	2026-03-02 23:19:44.509798	62.16	41.28	20.87	t	t	t
9217	4	2026-03-02 23:19:44.509713	37.86	50.34	57.20	t	t	t
9219	3	2026-03-02 23:19:44.609843	53.59	12.82	65.59	t	t	t
9220	2	2026-03-02 23:19:54.480619	34.63	10.02	40.57	t	t	t
9221	3	2026-03-02 23:19:54.480794	39.17	78.89	24.38	t	t	t
9222	4	2026-03-02 23:19:54.480911	57.77	14.69	37.00	t	t	t
9223	5	2026-03-02 23:19:54.512912	79.56	41.02	22.29	t	t	t
9224	4	2026-03-02 23:20:04.485058	52.49	47.89	57.96	t	t	t
9225	3	2026-03-02 23:20:04.485118	54.07	37.20	54.18	t	t	t
9226	2	2026-03-02 23:20:04.485239	46.03	16.58	32.94	t	t	t
9227	5	2026-03-02 23:20:04.485315	13.42	71.33	45.26	t	t	t
9228	3	2026-03-02 23:20:14.497471	39.99	70.26	53.87	t	t	t
9229	5	2026-03-02 23:20:14.541076	75.65	65.76	60.87	t	t	t
9230	4	2026-03-02 23:20:14.541192	43.16	76.66	31.83	t	t	t
9231	2	2026-03-02 23:20:14.638751	67.00	21.69	44.03	t	t	t
9232	2	2026-03-02 23:20:24.510871	14.04	59.37	67.68	t	t	t
9233	4	2026-03-02 23:20:24.511211	76.63	41.41	25.35	t	t	t
9234	3	2026-03-02 23:20:24.511256	78.89	45.68	49.32	t	t	t
9235	5	2026-03-02 23:20:24.540507	55.54	27.74	54.70	t	t	t
9236	3	2026-03-02 23:20:34.511807	12.97	41.53	60.35	t	t	t
9237	5	2026-03-02 23:20:34.512469	74.90	43.40	63.77	t	t	t
9238	4	2026-03-02 23:20:34.512594	29.02	56.28	55.44	f	t	t
9239	2	2026-03-02 23:20:34.512683	10.49	23.98	64.14	t	t	t
9240	2	2026-03-02 23:20:44.522024	79.51	41.47	23.66	t	t	t
9241	3	2026-03-02 23:20:44.560566	56.29	24.66	35.86	t	t	t
9242	4	2026-03-02 23:20:44.564115	11.18	66.71	47.21	t	t	t
9243	5	2026-03-02 23:20:44.568311	18.20	20.39	38.47	t	t	t
9244	2	2026-03-03 12:40:27.703429	\N	\N	\N	\N	\N	\N
9245	3	2026-03-03 12:40:27.719746	\N	\N	\N	\N	\N	\N
9246	4	2026-03-03 12:40:27.722435	\N	\N	\N	\N	\N	\N
9247	5	2026-03-03 12:40:27.726083	\N	\N	\N	\N	\N	\N
\.


--
-- TOC entry 5379 (class 0 OID 17190)
-- Dependencies: 232
-- Data for Name: gates; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.gates (id, gate_name, entrance_id, ip_address, device_serial, is_active) FROM stdin;
3	SGR-001	3	192.168.1.102	DEV-SGR-001	t
4	NORA-001	4	192.168.1.103	DEV-NORA-001	t
2	MGR-001	2	192.168.1.7	DEV-MGR-001	t
5	MGR-002	2	192.168.1.8	DEV-MGR-002	t
\.


--
-- TOC entry 5421 (class 0 OID 17596)
-- Dependencies: 275
-- Data for Name: host_projects; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.host_projects (id, host_id, project_id, assigned_at) FROM stdin;
15	3	2	2026-02-26 18:18:51.171345
16	5	12	2026-03-03 23:20:40.941327
17	2	12	2026-03-03 23:20:57.848711
18	4	12	2026-03-03 23:21:08.878651
\.


--
-- TOC entry 5375 (class 0 OID 17161)
-- Dependencies: 228
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.hosts (id, host_name, phone, email, department_id, is_active, created_at) FROM stdin;
3	Lt. Meera Nair	9876543211	meera.nair@navy.mil	2	t	2026-02-23 11:56:08.304865
5	Jai Kumar	1234567890	jai@example.com	7	t	2026-02-26 17:58:34.160906
2	Cmdr. Arjun Rao	9876543210	arjun.rao@navy.mil	7	t	2026-02-23 11:56:08.304865
4	Capt. Vivek Sharma	9876543212	vivek.sharma@navy.mil	7	t	2026-02-23 11:56:08.304865
\.


--
-- TOC entry 5399 (class 0 OID 17401)
-- Dependencies: 252
-- Data for Name: labour_manifests; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.labour_manifests (id, supervisor_id, manifest_date, printed_at, signed, pdf_path) FROM stdin;
1	1002	2026-02-25	\N	f	\N
2	1003	2026-02-25	\N	f	\N
5	1002	2026-02-25	\N	f	\N
4	1002	2026-02-25	\N	t	\N
55	1012	2026-03-04	2026-03-04 13:24:00.071692	t	uploads/manifest_MF-20260303-000055.pdf
6	1002	2026-02-25	\N	f	\N
8	1002	2026-02-25	\N	t	\N
9	1002	2026-02-25	\N	f	\N
10	1002	2026-02-25	\N	f	\N
11	1002	2026-02-25	\N	f	\N
12	1002	2026-02-25	\N	f	\N
14	1003	2026-02-25	\N	f	\N
56	1012	2026-03-04	2026-03-04 13:26:31.92222	t	uploads/manifest_MF-20260303-000056.pdf
15	1005	2026-02-25	\N	t	\N
16	1006	2026-02-25	\N	t	\N
57	1012	2026-03-04	2026-03-04 13:34:58.154733	t	uploads/manifest_MF-20260303-000057.pdf
18	1002	2026-02-27	\N	t	\N
19	1006	2026-02-27	\N	t	\N
20	1002	2026-02-27	\N	f	\N
23	1008	2026-02-27	\N	f	\N
24	1003	2026-02-28	\N	f	\N
26	1004	2026-02-28	2026-02-28 10:38:13.703256	t	uploads/manifest_MF-20260227-000026.pdf
27	1004	2026-02-28	2026-02-28 10:40:07.769466	t	uploads/manifest_MF-20260227-000027.pdf
25	1004	2026-02-28	2026-02-28 10:43:58.353882	t	uploads/manifest_MF-20260227-000025.pdf
3	1004	2026-02-25	2026-02-28 10:44:02.669448	t	uploads/manifest_MF-20260224-000003.pdf
22	1002	2026-02-27	2026-02-28 10:48:19.543481	t	uploads/manifest_MF-20260226-000022.pdf
7	1002	2026-02-25	2026-02-28 10:48:34.221186	t	uploads/manifest_MF-20260224-000007.pdf
13	1002	2026-02-25	2026-02-28 10:48:39.721204	t	uploads/manifest_MF-20260224-000013.pdf
17	1002	2026-02-26	2026-02-28 10:48:44.108051	t	uploads/manifest_MF-20260225-000017.pdf
21	1002	2026-02-27	2026-02-28 10:48:56.305598	t	uploads/manifest_MF-20260226-000021.pdf
28	1002	2026-02-28	2026-02-28 16:39:01.699273	t	uploads/manifest_MF-20260227-000028.pdf
29	1009	2026-03-02	2026-03-02 17:34:59.284655	t	uploads/manifest_MF-20260301-000029.pdf
30	1009	2026-03-02	2026-03-02 20:48:19.702824	t	uploads/manifest_MF-20260301-000030.pdf
31	1005	2026-03-03	2026-03-03 13:16:55.811618	t	uploads/manifest_MF-20260302-000031.pdf
32	1006	2026-03-03	2026-03-03 13:25:13.531085	t	uploads/manifest_MF-20260302-000032.pdf
33	1007	2026-03-03	2026-03-03 14:36:53.716493	t	uploads/manifest_MF-20260302-000033.pdf
34	1008	2026-03-03	2026-03-03 18:26:44.702593	t	uploads/manifest_MF-20260302-000034.pdf
35	1007	2026-03-03	2026-03-03 18:31:28.72198	t	uploads/manifest_MF-20260302-000035.pdf
36	1010	2026-03-03	2026-03-03 21:48:52.704218	t	uploads/manifest_MF-20260302-000036.pdf
37	1015	2026-03-03	2026-03-03 21:55:49.566165	t	uploads/manifest_MF-20260302-000037.pdf
38	1016	2026-03-03	2026-03-03 22:00:35.985105	t	uploads/manifest_MF-20260302-000038.pdf
39	1017	2026-03-03	2026-03-03 22:04:39.548855	t	uploads/manifest_MF-20260302-000039.pdf
40	1018	2026-03-03	2026-03-03 22:06:57.728268	t	uploads/manifest_MF-20260302-000040.pdf
41	1019	2026-03-03	2026-03-03 22:09:27.055969	t	uploads/manifest_MF-20260302-000041.pdf
42	1018	2026-03-03	2026-03-03 22:15:01.990974	t	uploads/manifest_MF-20260302-000042.pdf
43	1012	2026-03-03	2026-03-03 23:07:28.685793	t	uploads/manifest_MF-20260302-000043.pdf
44	1012	2026-03-04	2026-03-04 12:31:21.054082	t	uploads/manifest_MF-20260303-000044.pdf
45	1012	2026-03-04	2026-03-04 12:35:17.122922	t	uploads/manifest_MF-20260303-000045.pdf
46	1012	2026-03-04	2026-03-04 12:40:04.772776	t	uploads/manifest_MF-20260303-000046.pdf
47	1012	2026-03-04	2026-03-04 12:48:24.424525	t	uploads/manifest_MF-20260303-000047.pdf
48	1012	2026-03-04	2026-03-04 12:53:31.11692	t	uploads/manifest_MF-20260303-000048.pdf
49	1012	2026-03-04	2026-03-04 12:55:36.739722	t	uploads/manifest_MF-20260303-000049.pdf
50	1012	2026-03-04	2026-03-04 12:57:51.727348	t	uploads/manifest_MF-20260303-000050.pdf
51	1012	2026-03-04	2026-03-04 13:01:54.096449	t	uploads/manifest_MF-20260303-000051.pdf
52	1012	2026-03-04	2026-03-04 13:10:44.775602	t	uploads/manifest_MF-20260303-000052.pdf
53	1012	2026-03-04	2026-03-04 13:15:06.620265	t	uploads/manifest_MF-20260303-000053.pdf
54	1012	2026-03-04	2026-03-04 13:17:34.525892	t	uploads/manifest_MF-20260303-000054.pdf
58	1012	2026-03-04	2026-03-04 13:42:33.201652	t	uploads/manifest_MF-20260303-000058.pdf
59	1012	2026-03-04	2026-03-04 13:45:03.852725	t	uploads/manifest_MF-20260303-000059.pdf
60	1012	2026-03-04	2026-03-04 13:47:32.635727	t	uploads/manifest_MF-20260303-000060.pdf
61	1012	2026-03-04	2026-03-04 13:49:54.884098	t	uploads/manifest_MF-20260303-000061.pdf
62	1012	2026-03-04	2026-03-04 13:55:00.50263	t	uploads/manifest_MF-20260303-000062.pdf
63	1012	2026-03-04	2026-03-04 13:57:45.520134	t	uploads/manifest_MF-20260303-000063.pdf
64	1012	2026-03-04	2026-03-04 14:01:47.830443	t	uploads/manifest_MF-20260303-000064.pdf
65	1012	2026-03-04	2026-03-04 14:18:20.791685	t	uploads/manifest_MF-20260303-000065.pdf
66	1012	2026-03-04	2026-03-04 14:20:48.77716	t	uploads/manifest_MF-20260303-000066.pdf
67	1012	2026-03-04	2026-03-04 14:23:45.574461	t	uploads/manifest_MF-20260303-000067.pdf
68	1012	2026-03-04	2026-03-04 14:25:05.94133	t	uploads/manifest_MF-20260303-000068.pdf
69	1012	2026-03-04	2026-03-04 14:26:52.957381	t	uploads/manifest_MF-20260303-000069.pdf
70	1012	2026-03-04	2026-03-04 14:27:59.445809	t	uploads/manifest_MF-20260303-000070.pdf
71	1012	2026-03-04	\N	f	\N
72	1012	2026-03-04	2026-03-04 14:32:58.374368	t	uploads/manifest_MF-20260303-000072.pdf
73	1012	2026-03-04	2026-03-04 14:33:59.294933	t	uploads/manifest_MF-20260303-000073.pdf
74	1012	2026-03-04	\N	f	\N
75	1012	2026-03-04	2026-03-04 14:41:34.550732	t	uploads/manifest_MF-20260303-000075.pdf
76	1012	2026-03-04	2026-03-04 15:08:59.642305	t	uploads/manifest_MF-20260303-000076.pdf
77	1012	2026-03-04	2026-03-04 15:11:09.751821	t	uploads/manifest_MF-20260303-000077.pdf
78	1012	2026-03-04	2026-03-04 15:12:04.509324	t	uploads/manifest_MF-20260303-000078.pdf
79	1012	2026-03-04	2026-03-04 15:13:18.196249	t	uploads/manifest_MF-20260303-000079.pdf
80	1012	2026-03-04	2026-03-04 15:14:14.169031	t	uploads/manifest_MF-20260303-000080.pdf
81	1012	2026-03-04	2026-03-04 15:19:55.747558	t	uploads/manifest_MF-20260303-000081.pdf
82	1012	2026-03-04	2026-03-04 15:21:35.134408	t	uploads/manifest_MF-20260303-000082.pdf
83	1012	2026-03-04	2026-03-04 15:23:45.014943	t	uploads/manifest_MF-20260303-000083.pdf
84	1012	2026-03-04	2026-03-04 15:27:26.440933	t	uploads/manifest_MF-20260303-000084.pdf
85	1012	2026-03-04	2026-03-04 15:29:09.389546	t	uploads/manifest_MF-20260303-000085.pdf
86	1012	2026-03-04	2026-03-04 15:38:25.480197	t	uploads/manifest_MF-20260303-000086.pdf
87	1115	2026-03-04	2026-03-04 17:33:59.228631	t	uploads/manifest_MF-20260303-000087.pdf
88	1115	2026-03-04	2026-03-04 19:11:00.70269	t	uploads/manifest_MF-20260303-000088.pdf
89	1115	2026-03-05	2026-03-05 20:13:28.914131	t	uploads/manifest_MF-20260304-000089.pdf
90	1115	2026-03-06	2026-03-06 15:08:22.719662	t	uploads/manifest_MF-20260305-000090.pdf
91	1115	2026-03-06	2026-03-06 17:14:24.185598	t	uploads/manifest_MF-20260305-000091.pdf
92	1116	2026-03-06	2026-03-06 17:43:15.60269	t	uploads/visitors/1116/manifests/manifest_MF-20260305-000092.pdf
93	1016	2026-03-06	2026-03-06 18:01:34.09299	t	uploads/visitors/1016/manifests/manifest_MF-20260305-000093.pdf
94	1116	2026-03-06	2026-03-06 19:00:33.496527	t	uploads/visitors/1116/manifests/manifest_MF-20260305-000094.pdf
95	1116	2026-03-08	2026-03-08 19:13:29.816543	t	uploads/visitors/1116/manifests/manifest_MF-20260307-000095.pdf
96	1115	2026-03-09	2026-03-09 12:12:11.486357	t	uploads/visitors/1115/manifests/manifest_MF-20260308-000096.pdf
97	1115	2026-03-09	2026-03-09 15:08:52.721823	t	uploads/visitors/1115/manifests/manifest_MF-20260308-000097.pdf
\.


--
-- TOC entry 5397 (class 0 OID 17387)
-- Dependencies: 250
-- Data for Name: labour_tokens; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.labour_tokens (id, labour_id, token_uid, assigned_date, valid_until, status) FROM stdin;
6009	5010	\N	2026-02-25	\N	ACTIVE
6010	5011	\N	2026-02-25	\N	ACTIVE
6011	5012	\N	2026-02-25	\N	ACTIVE
6012	5013	\N	2026-02-25	\N	ACTIVE
6015	5016	RFID0003	2026-02-27	2026-02-27 00:00:00	INACTIVE
6014	5015	RFID0002	2026-02-27	2026-02-27 00:00:00	INACTIVE
6013	5014	RFID0001	2026-02-27	2026-02-28 00:00:00	INACTIVE
6016	5017	RFID0004	2026-02-27	2026-02-27 23:59:59.999	INACTIVE
6004	5005	100111	2026-02-25	2026-02-26 20:27:00	INACTIVE
6003	5004	11765	2026-02-24	2026-02-24 23:10:00	INACTIVE
6002	5003	100011	2026-02-24	2026-02-24 23:59:00	INACTIVE
6017	5018	RFID0001	2026-02-27	2026-02-27 23:59:59.999	INACTIVE
6006	5007	100345	2026-02-25	2026-02-26 20:30:00	INACTIVE
6005	5006	13454	2026-02-25	2026-02-26 20:30:00	INACTIVE
6019	5020	RFID0002	2026-02-27	2026-02-27 23:59:59.999	INACTIVE
6007	5008	\N	2026-02-25	\N	INACTIVE
6008	5009	\N	2026-02-25	\N	INACTIVE
6021	5026	RFID0003	2026-02-28	2026-02-28 23:59:59.999	INACTIVE
6022	5027	RFID0004	2026-02-28	2026-02-28 23:59:59.999	INACTIVE
6023	5028	RFID0009	2026-02-28	2026-02-28 23:59:59.999	INACTIVE
6024	5029	RFID0012	2026-02-28	2026-02-28 23:59:59.999	INACTIVE
6025	5030	RFID0013	2026-02-28	2026-02-28 23:59:59.999	INACTIVE
6026	5031	RFID0007	2026-02-28	2026-02-28 23:59:59.999	INACTIVE
6020	5025	RFID0002	2026-02-28	2026-02-28 23:59:59.999	INACTIVE
6028	5033	RFID0005	2026-02-28	2026-02-28 23:59:59.999	INACTIVE
6027	5032	RFID0002	2026-02-28	2026-02-28 23:59:59.999	INACTIVE
6031	5036	RFID0004	2026-03-02	2026-03-02 23:59:59.999	INACTIVE
6030	5035	RFID0003	2026-03-02	2026-03-02 23:59:59.999	INACTIVE
6029	5034	RFID0002	2026-03-02	2026-03-02 23:59:59.999	INACTIVE
6038	5043	RFID0008	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6037	5042	RFID0007	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6036	5041	RFID0006	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6035	5040	RFID0005	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6039	5044	RFID0005	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6040	5045	RFID0006	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6043	5048	RFID0007	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6042	5047	RFID0006	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6041	5046	RFID0005	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6032	5037	RFID0002	2026-03-02	2026-03-02 23:59:59.999	INACTIVE
6033	5038	RFID0003	2026-03-02	2026-03-02 23:59:59.999	INACTIVE
6034	5039	RFID0004	2026-03-02	2026-03-02 23:59:59.999	INACTIVE
6048	5053	RFID0004	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6047	5052	RFID0008	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6018	5019	RFID0001	2026-02-27	2026-02-27 23:59:59.999	INACTIVE
6044	5049	RFID0002	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6045	5050	RFID0003	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6046	5051	RFID0005	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6062	5067	RFID0014	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6063	5068	RFID0015	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6064	5069	RFID0016	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6065	5070	RFID0017	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6066	5071	RFID0018	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6067	5072	RFID0019	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6068	5073	RFID0020	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6061	5066	RFID0013	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6059	5064	RFID0011	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6060	5065	RFID0012	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6050	5055	RFID0002	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6049	5054	RFID0001	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6053	5058	RFID0005	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6052	5057	RFID0004	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6051	5056	RFID0003	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6054	5059	RFID0006	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6055	5060	RFID0007	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6056	5061	RFID0008	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6057	5062	RFID0009	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6058	5063	RFID0010	2026-03-03	2026-03-03 23:59:59.999	INACTIVE
6070	5075	RFID0002	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6071	5076	RFID0003	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6072	5077	RFID0004	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6073	5078	RFID0005	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6074	5079	RFID0006	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6075	5080	RFID0007	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6077	5082	RFID0009	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6078	5083	RFID0010	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6079	5084	RFID0011	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6080	5085	RFID0012	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6081	5086	RFID0013	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6082	5087	RFID0014	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6084	5089	RFID0016	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6085	5090	RFID0017	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6086	5091	RFID0018	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6087	5092	RFID0019	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6088	5093	RFID0020	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6089	5094	RFID0021	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6091	5096	RFID0023	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6092	5097	RFID0024	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6093	5098	RFID0025	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6094	5099	RFID0026	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6095	5100	RFID0027	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6096	5101	RFID0028	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6098	5103	RFID0030	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6099	5104	RFID0031	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6069	5074	RFID0001	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6076	5081	RFID0008	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6083	5088	RFID0015	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6090	5095	RFID0022	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6097	5102	RFID0029	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6100	5105	RFID0032	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6101	5106	RFID0033	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6102	5107	RFID0043	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6103	5108	RFID0034	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6104	5109	RFID0035	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6105	5110	RFID0036	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6106	5111	RFID0037	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6107	5112	RFID0038	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6108	5113	RFID0039	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6109	5114	RFID0040	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6110	5115	RFID0041	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6111	5116	RFID0042	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6112	5117	RFID0044	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6113	5118	RFID0045	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6114	5119	RFID0046	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6115	5120	RFID0047	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6116	5121	RFID0048	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6117	5122	RFID0001	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6118	5123	RFID0002	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6119	5124	RFID0003	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6120	5125	RFID0004	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6121	5126	RFID0005	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6122	5127	RFID0009	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6123	5128	RFID0006	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6124	5129	RFID0007	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6125	5130	RFID0008	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6126	5131	RFID0010	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6127	5132	RFID0011	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6128	5133	RFID0012	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6129	5134	RFID0013	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6130	5135	RFID0014	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6131	5136	RFID0015	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6132	5137	RFID0016	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6133	5138	RFID0017	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6134	5139	RFID0018	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6135	5140	RFID0019	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6136	5141	RFID0020	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6137	5142	RFID0021	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6138	5143	RFID0022	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6139	5144	RFID0023	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6140	5145	RFID0024	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6141	5146	RFID0025	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6142	5147	RFID0026	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6143	5148	RFID0027	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6144	5149	RFID0037	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6145	5150	RFID0038	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6146	5151	RFID0039	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6147	5152	RFID0040	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6148	5153	RFID0028	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6149	5154	RFID0029	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6150	5155	RFID0030	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6151	5156	RFID0031	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6152	5157	RFID0032	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6153	5158	RFID0033	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6154	5159	RFID0034	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6155	5160	RFID0001	2026-03-04	2026-03-04 23:59:59.999	INACTIVE
6156	5161	RFID0001	2026-03-05	2026-03-05 23:59:59.999	INACTIVE
6157	5162	RFID0002	2026-03-05	2026-03-05 23:59:59.999	INACTIVE
6159	5164	RFID0002	2026-03-06	2026-03-06 23:59:59.999	INACTIVE
6158	5163	RFID0001	2026-03-06	2026-03-06 23:59:59.999	INACTIVE
6162	5167	RFID0003	2026-03-06	2026-03-06 23:59:59.999	INACTIVE
6163	5168	RFID0004	2026-03-06	2026-03-06 23:59:59.999	INACTIVE
6164	5169	RFID0005	2026-03-06	2026-03-06 23:59:59.999	INACTIVE
6161	5166	RFID0002	2026-03-06	2026-03-06 23:59:59.999	INACTIVE
6160	5165	RFID0001	2026-03-06	2026-03-06 23:59:59.999	INACTIVE
6166	5171	RFID0002	2026-03-06	2026-03-06 23:59:59.999	INACTIVE
6165	5170	RFID0001	2026-03-06	2026-03-06 23:59:59.999	INACTIVE
6168	5173	RFID0002	2026-03-06	2026-03-06 23:59:59.999	INACTIVE
6167	5172	RFID0001	2026-03-06	2026-03-06 23:59:59.999	INACTIVE
6170	5175	RFID0002	2026-03-08	2026-03-08 23:59:59.999	INACTIVE
6169	5174	RFID0001	2026-03-08	2026-03-08 23:59:59.999	INACTIVE
6172	5177	RFID0002	2026-03-09	2026-03-09 23:59:59.999	INACTIVE
6171	5176	RFID0001	2026-03-09	2026-03-09 23:59:59.999	INACTIVE
6173	5178	RFID0001	2026-03-09	2026-03-09 23:59:59.999	ACTIVE
6174	5179	RFID0002	2026-03-09	2026-03-09 23:59:59.999	ACTIVE
\.


--
-- TOC entry 5395 (class 0 OID 17371)
-- Dependencies: 248
-- Data for Name: labours; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.labours (id, supervisor_id, full_name, phone, aadhaar_encrypted, aadhaar_last4, created_at) FROM stdin;
5002	1002	\N	\N	5c7f3fd5ca7f66ff145c669907b46589:9aded51684b93bb34a50d866ee9235c9	9012	2026-02-24 17:41:29.39617
5003	1002	vinod	1234567890	8275df2b0220f747c675de29dc447ffc:e2d9a7066d056cc517a9eb3658575391	9012	2026-02-24 20:05:33.130035
5004	1002	hp	1234567890	a4bafdab3d5d50e20df7d0726a1bc9c6:e9dc09bb54e6df2ce67a62f29442a73b	9012	2026-02-24 20:10:46.850462
5005	1002	vin	1234567890	ef45712fa0d5c04f434c8f62ac1404fb:50c5fca3f4a0bf8bb13f0d3d280a9700	9012	2026-02-25 20:27:38.389977
5006	1003	ghjj	1234567890	f25a3d18abb34f1b04c757dc5e2f6929:ee2ed349a7dd6726b50917b96057e551	9012	2026-02-25 20:30:55.37737
5007	1003	ghjuy	1234567890	0980bfec187b67144489b73a6545e920:329df969f7c80065e8789e0ad7ab160f	9012	2026-02-25 20:30:55.389378
5008	1004	hjuil	123456789012	786f3d520a84e26f21b60eab1d1a4b07:a3f75a8467de7421330a7047b77efb5b	0011	2026-02-25 20:40:54.023617
5009	1004	hp	1234567890	fed184e41416cf80f8528eef45949c61:a830ea62ad88590782bba8c1e19defe8	7654	2026-02-25 20:40:54.037661
5010	1005	ghyuu	123456789012	dd97f89fc14436d4cba97ce8f26e5c37:347825084dac0c69d2211b6eb4b9aa4a	0011	2026-02-25 20:43:18.634266
5011	1006	binay	1234567890	de82677661584d868473ee6c285cd93d:8b315533bd40d2cb94a813867ded01bc	9012	2026-02-25 21:25:22.896686
5012	1006	singh	1234567890	37a29983eb2c171faa937444ea861a4d:fcce8bed2845610f6d311a30795213c9	9012	2026-02-25 21:25:22.912673
5013	1006	honey	1234567890	7b3e7733c382f06ba3709785f36ea152:36a8f1187a9d7ea47942b3d68438e02d	9012	2026-02-25 21:27:25.918418
5014	1002	Vinod Reddy M N	1234567890	9c40a0443913d251072063e2b61ced39:629fe14398c305f90344943a2a4f4358	9012	2026-02-27 17:28:40.343342
5015	1006	RAHUL SINGH	1234567890	2905ead159536b5cbcce919c04cf9703:d37ed3def086ee5a8e31ef0604d96bc3	9012	2026-02-27 17:31:36.129734
5016	1006	SINGH RAHUL	1234567890	6a74f396038ef7f37d66b4cf3625f25f:75653a2ca9cd26568c606f6af1857cb2	9012	2026-02-27 17:31:36.147655
5017	1002	NAISS	1004	fec14af3ac40dae6b64013288b9be9a9:2145f6fceae6d357dc03d7ec25319674	7890	2026-02-27 17:50:21.893319
5018	1002	VINOD	1234567890	1dfc6b83038e4cf3870b36610ff9cbf7:bc1bd57a0b4bf4a725ebc76e3c24686c	9012	2026-02-27 18:03:59.252087
5019	1008	VINOD	1234567890	e5d66cc25cff59b704caf2491db72147:67ad9bbccb510819de2627f70c7af8f5	9012	2026-02-27 18:10:56.470858
5020	1004	Suresh YAdav 1	1234567890	a526dfb72cc242ffbc9b7874e661a527:a15eb1f253fca49daed7344416384c3d	9012	2026-02-27 18:27:21.427129
5021	1004	Suresh Yadav 2	1234567890	d8bcf0c0dd8dcd1738a516ccb40c8587:b3e0fb564e825ba791d1ba3602dd1216	9012	2026-02-27 18:27:21.445189
5022	1004	Suresh YAdav 1	1234567890	2bee1cad00059c18c23235d27668c648:29cd9f98068ae9a4f1c1510361cbf0c8	9012	2026-02-27 18:27:32.02582
5023	1004	Suresh YAdav 	1234567890	dc72811677744567b5bdf49fcbaefa87:5f9caa161edeff4e87a3f03baa50e312	9012	2026-02-27 18:27:54.22934
5024	1004	Suresh YAdav 	1234567890	eb7d0f5b7f50979d507e70fd7f57c5b7:5750ff44fdceef21e4837e4862d3eae2	9012	2026-02-27 18:27:54.650719
5025	1006	vinod	123	c47b2beb87d616aa2f8c803589e489f0:32ec65ac59eb3a478fbef140597c4ecb	1234	2026-02-28 10:34:40.666982
5026	1004	Suresh YAdav 	1234567890	46ab51864504e595ca20a11ab0dac5ab:d0bbb09935ccb82cf9465b31a95e0621	9012	2026-02-28 10:36:35.806986
5027	1004	Suresh Yadav 	1234567890	57f83827d632f33f0d1e3ad07221d206:ecb0e3b3d2570c83a5c3b2a0216ca134	9012	2026-02-28 10:36:35.83579
5028	1004	Suresh YAdav 	1234567890	671f1df3393e5b35cd76fa688a840b21:ba63600f040015108dae3dc9f967afb3	9012	2026-02-28 10:38:13.57253
5029	1004	Suresh Yadav 	1234567890	554fc083cf95dcf1053193fac97443cf:0ab8f9c20dd26103fcd65634dc5dec47	9012	2026-02-28 10:38:13.600369
5030	1004	fghuyt	1234	bd4197efd71d08ca712306d07cd5678d:0019bae77062ea0b37c0c441c251621c	1234	2026-02-28 10:40:07.691357
5031	1004	yhgtred	1234	9f658a56e66cdff2613a879f7f1ad8f3:71f062aa6436767b7c913ea42c647c02	1234	2026-02-28 10:40:07.715489
5032	1002	VINOD	1234567890	744cdb69100f4d792f1e481f58966ebb:dd65b2834d1ba835c0bb4769a93f1a17	9012	2026-02-28 16:39:01.642782
5033	1002	REDDY	1234567890	3e56221122d37a08285ec3990314d792:7eb2bb933800b9619a6e2ef362a9acd8	9012	2026-02-28 16:39:01.657588
5034	1009	Vinod1	1234567890	2b259364b83b4296e38183467b704994:03f8776d03016cf71461bd9ab8995f97	9012	2026-03-02 17:34:59.198076
5035	1009	Vinod2	1234567890	a3603b403f2b855262f5c5fb3f7707d3:7b15ed2b198b4425e08256dee8530d1d	9012	2026-03-02 17:34:59.222401
5036	1009	Vinod3	1234567890	5f5a8c56108ef07d8e299930fada40c6:52ed82fddbfb41f61f7a56d47ec6eb54	9012	2026-03-02 17:34:59.230504
5037	1009	DIVYA1	1234567890	a0b8e60177da14c62779f6baca3d45ce:10ed26fa55e85b14a6c6304f897cf99b	9012	2026-03-02 20:48:19.64113
5038	1009	DIVYA2	1234567890	0f9f1e01827eb8d3dbc9ada8995cce79:88efc9d437a263084791bcdd6b2a9721	9012	2026-03-02 20:48:19.654737
5039	1009	DIVYA3	1234567890	e8fc0e0cedee0350a517e60ed7ffa7f9:71cb569d26939b3bbf9ae80c1e4706e3	9012	2026-03-02 20:48:19.661856
5040	1005	MEENA	1234567890	51f13e0a086dd35db64913745f1af7bc:828b37356102da1281a57afa7ee81f17	1234	2026-03-03 13:16:55.623656
5041	1005	MEENA1	1234567890	c93f2439e878f6d154e84c8f07b4974e:5cf99a64c7d244c098d17a0a3c26953b	1234	2026-03-03 13:16:55.650545
5042	1005	MEENA2	1234567890	c9a4959c407222b6ff4341eff5f3a03f:78cf3dbd56ac926d9ba6bdc2c780fd1f	1234	2026-03-03 13:16:55.671192
5043	1005	MEENA3	1234567890	28ea3cc1146dabb23e2f041f7047adab:bf315009dcf857d9809a5527b700990f	1234	2026-03-03 13:16:55.692039
5044	1006	RAHUL1	123	c6f0255dc71cfbc027332ce1b0b3c687:39764e331c4b3fc8f6028436ad80ede6	1234	2026-03-03 13:25:13.409692
5045	1006	RAHUL2	123	493a06ea5fabbc8cfa03285d3fb4ab38:d49525cc2dc8e3103431157a2691ab87	1234	2026-03-03 13:25:13.430364
5046	1007	PRIYA1	1234	379104d45fde0b26cf2b02bbe03a73f4:67035c7f30b4efda3a2ca629cda5b708	1234	2026-03-03 14:36:53.64688
5047	1007	PRIYA2	1234	15f1589a8fbbaa13113eb79a33317d1d:349eeb5ca9cc536ca58549100f0edb22	1234	2026-03-03 14:36:53.660203
5048	1007	PRIYA3	1234	15fee940d1ad846917e0872ea4538566:80bfa853774a9f8f9ee9cd005a3baeba	1234	2026-03-03 14:36:53.671326
5049	1008	MANOJ1	1234567890	e98d783d72b101f6b44bb690b16d0151:ca1b422c83e83e2340a0609bc82e69ac	9012	2026-03-03 18:26:44.540041
5050	1008	MANOJ2	1234567890	57010d132d27198c6c340356366d4ab3:955b35df65332258a18e227dbf29c558	9012	2026-03-03 18:26:44.55084
5051	1008	MANOJ3	1234567890	8e0347e04f6aca315c87759c071d6574:1b5177cb3ef3d8e173cbc80f1f9e9986	9012	2026-03-03 18:26:44.559248
5052	1008	MANOJ4	1234567890	aaf6aceb10e8286a73bb931230ce9901:9110f22b8ec96a49607a59941ca022ca	9012	2026-03-03 18:26:44.572537
5053	1007	PRIYA1	1234567890	fe7ba967be8a5ecae47e0e0f4040e420:b73a24bd222d61b6ce3ed79670eecd74	9012	2026-03-03 18:31:28.571186
5054	1010	KIRAN1	1234567890	6a818961cb62a64a6ffe5bd825912173:ed1927080a6fb841a67dda90cbdf293e	9010	2026-03-03 21:48:52.541761
5055	1010	KIRAN2	1234567891	fe1e5528c9472c064f55f880b893fc91:c757b6215866d8cb68be6f2b63c98d18	9011	2026-03-03 21:48:52.560422
5056	1015	VINOD	1234567890	0fd92992273ed3b274391de7d942549d:fc145c5b952abee4af7f0d9be61bbb95	9012	2026-03-03 21:55:49.408286
5057	1015	REDDY	1234567891	98bcbcd46987d7cc34c375fc5f8f3e2d:d89abc60f35a6d8280afca1e6120cf62	9013	2026-03-03 21:55:49.421152
5058	1015	MN VINOD REDDY	1234567892	438a70ff37d28e20476dbddad270dd35:75dd7e27138d9339a0b439f9cd23d4b6	9014	2026-03-03 21:55:49.433228
5059	1016	DEEPANKAR	1234567890	968cabbdf3b82901e89b417ee0e765fe:2c36789a40c84e375478a78d8b921b59	9012	2026-03-03 22:00:35.778321
5060	1016	AMIT KUMAR	1234567891	e6d84e2f9b898894d0d7f6aaf37ddb19:741236ae7d8e44e166359e632d62f2e8	9013	2026-03-03 22:00:35.791617
5061	1016	PRANABH JANA	1234567892	db2036aa173a0de90689ffc73a634d2a:266713c103263d56264a2cc6b78e2271	9014	2026-03-03 22:00:35.79943
5062	1016	REEGAN AKISH	1234567893	25461befe44a1324636eb820e23c1d85:468bace6ba83c2b244f5d9d271bc8084	9015	2026-03-03 22:00:35.807957
5063	1017	VIJAY KUMAR	1234567890	8888469bb55363c98d4c5933f578bb28:be5ab63c28a2fe1986ce8974c05120c0	9012	2026-03-03 22:04:39.414066
5064	1018	JAY KUMAR	1234567890	da09f5f08595876c7fdc03023a8d08b6:afdd80ac06450542798aed1bd344bf20	9012	2026-03-03 22:06:57.566839
5065	1019	VISITOR1	1234567890	a5c56d46f92ad771f46d637bd8cb1713:cef4f14fac8a2028d1d2c9aaea37bf53	9012	2026-03-03 22:09:26.91961
5066	1018	AJAY	1234567890	d9c0f9b1a96949187845b7eb22e707da:ae0bfd3bfd704955015bfd572fd78411	9012	2026-03-03 22:15:01.865041
5067	1012	DEEPANKAR MAITY	1234567890	941b91d83994c43421a0652a7bd3c987:0ca299175c05c45d352e6b3497e5e9e8	9012	2026-03-03 23:07:28.233231
5068	1012	AMIT BHAGARI	1234567891	e5a3ac80f2d3ae8199ee50c022fedf3a:5be90853cb10b62d6cfe80a805ac37d3	9013	2026-03-03 23:07:28.25827
5069	1012	PRANABH JANA	1234567892	aef91118bf30faf71a7d580603c3d2cb:2fb25d3607ac964d6d0de698fa42f1b1	9014	2026-03-03 23:07:28.278439
5070	1012	REEGAN AKISH	1234567893	32d07e7617facd9180194eb6cb41dbc4:d06ba4fae2d20cd81d07684cb4ccb66f	9015	2026-03-03 23:07:28.301158
5071	1012	MARUTHI V	1234567894	4d28ca5a939e6e9bea7a053dc1038522:257ab86f207857fde99f9e806de7c911	9016	2026-03-03 23:07:28.321623
5072	1012	SHARAT KUMAR S	1234567895	402ab7228457f2c978257c8d4d28dacb:57ed9e82d022f2f274718e9bac77a1bc	9017	2026-03-03 23:07:28.346222
5073	1012	SHOBAN RAJ	1234567896	25812e200cf476f080541d5a289dec87:2a561552cd4d19d50caee88c8f315c69	9018	2026-03-03 23:07:28.366018
5074	1012	LABOUR NO 1	1234567890	ba628a9b2e4fb40b6d8047f118d76feb:fbf7a43dce3c194de5ec2b85bab551bb	9001	2026-03-04 12:31:20.858415
5075	1012	LABOUR NO 2	1234567891	ac745cf0255660e4aa625629d10da041:ba1970a0ef41f9c0621c56a2aa5ed0a2	9002	2026-03-04 12:31:20.88161
5076	1012	LABOUR NO 3	1234567892	b57331b276f5b6ee78ce3a913f7e6c98:b9cd711d81e1899e07103ced04b7b43c	9003	2026-03-04 12:31:20.894187
5077	1012	LABOUR NO 4	1234567893	6102288f007f483f41637d5ab927842b:f12eefeabc348ab570714d6a9999af78	9004	2026-03-04 12:31:20.902073
5078	1012	LABOUR NO 5	1234567894	c1b1841e8f97b2b406181df551901cdd:b41cc211990186be1a062eb575a17d03	9005	2026-03-04 12:31:20.911988
5079	1012	LABOUR NO 6	1234567896	ec13e419c2c4020f847db40b3b474761:313e1fc50c0bd50ba5f5db2740c9abe5	9006	2026-03-04 12:35:16.942988
5080	1012	LABOUR NO 7	1234567897	29339d23181036cfa33b4bc5a47748f1:0cd9e529a1295a650048e19e44d8fb31	9007	2026-03-04 12:40:04.640528
5081	1012	LABOUR NO 8	1234567890	d4562c24ea00e3e3a2c09eeb5f0f245b:75611a77bd64cb5d31a5e89053622774	9001	2026-03-04 12:48:24.277268
5082	1012	VINOD REDDY MN 	1234567890	bdb05df8ce32b02a386964ec169cd2d4:39b89fae7d34dd94d137e49976679b95	9012	2026-03-04 12:53:30.984921
5083	1012	VINOD REDDY M N	1234567890	edf23fd42fc8a4de8dc3a26e87155c34:f2d29aabf5d5ae749953e40b168ae4d4	9012	2026-03-04 12:55:36.615763
5084	1012	VINOD	1234	ea4a2188037a5a2463a2fe176a1c555a:b500bdf3bd5bb06f996883869bd5f9ba	1234	2026-03-04 12:57:51.590375
5085	1012	VINOD M N	1234	4c4cab2582b33046032a30f1bd796c8a:f099d2d8a0b152b411191a5d70f62a96	1234	2026-03-04 13:01:53.967889
5086	1012	VINOD M N	1234	dd736ab2cf57d484121b8bb0bc11cf17:da8d328285e8432a67a6f62bb77d11c8	1234	2026-03-04 13:10:44.627649
5087	1012	VINOD REDDY M N	1234	7513f301fcb3b2e92f3fad44a172ef63:437a5838e94318b52f7c4bd7a2a5d989	1234	2026-03-04 13:15:06.494847
5088	1012	VINOD	1234	a79ca9a60237239aa5326eac888aba55:87b28da10230d149effa4a2ebbee49cb	1234	2026-03-04 13:17:34.391701
5089	1012	VINOD M N	1234	13debc8da3e8e8e5de1942d347a8606a:33d31294174e9b1ff16ac227cd69b116	1234	2026-03-04 13:23:59.927962
5090	1012	VINOD	1234	34ca8136be29367da0384539b0bea0e9:e48d4bb6c19b280e32b9133fcabee50f	1234	2026-03-04 13:26:31.780079
5091	1012	VINOD	1234	e33b1b30c8f336e2162fdb9407365f3a:0b3e50dd47f3430262ce6f69b5887684	1234	2026-03-04 13:34:57.995721
5092	1012	VINOD	1234	42c2f574330fc714a143995ff1e868c8:60c9029b2b3986781dfb3924e4c948bb	1234	2026-03-04 13:42:33.053604
5093	1012	VINOD	1234	33587f6e1c468af35768e8ffa5fc4a6e:445b6c0a104cd1c5965e55145a049034	1234	2026-03-04 13:45:03.709374
5094	1012	VINOD	1234	20e0d8e4a63bfc84ba30bce50b06f04f:28a3c8c04e271790d65e5c910151d4d2	1234	2026-03-04 13:47:32.479702
5095	1012	VINOD	1234	de2720cf1c62f8cc9e4aece0c8e13d43:5e8e4847cc09a6cb71e6948f5c914b84	1234	2026-03-04 13:49:54.733917
5096	1012	VNOD	1234	c70fd1835403d6088c4c4e65b70c8bc6:3b06b078ef73ba65fb7f37554c1da436	1234	2026-03-04 13:55:00.345043
5097	1012	VINOD	1234	aac3b091524146542a385c2023882352:00e7d84c56b5f29e23ab225da7fa5dc1	1234	2026-03-04 13:57:45.394871
5098	1012	LABOUR 1	1234	2c19134f2fbf8510662b6d85af01393d:4c80be787a9d8200e38862006f3d13be	1234	2026-03-04 14:01:47.651391
5099	1012	LABOUR 2	1234	543e8d8715de92e7e3129164b1040d4d:0aee1f48ef5decc5cf058e36b5b578a9	1234	2026-03-04 14:01:47.677608
5100	1012	LABOUR 3	1234	92547e97c850cd369f007e03772fc620:694b1bb1c4cebdb59191e522d17242c0	1234	2026-03-04 14:01:47.686084
5101	1012	LABOUR 4	1234	7776eaefd16321c240eb9256272a8221:eb7f6bb80b0dc79c523efcb9858a1779	1234	2026-03-04 14:01:47.697029
5102	1012	LABOUR 5	1234	96735962a006346de2091468b948e9a0:2bde31561a38b09fc0d3cd27345d42c2	1234	2026-03-04 14:01:47.704126
5103	1012	LABOUR 6	1234	c854e1edc823e5160a09cc099b83bdc4:1424c5aaf5c7ad2d92c75887b4331689	1234	2026-03-04 14:01:47.713775
5104	1012	LABOUR 7	1234	a6995f0d5fe2bf97fae64f2f915e0908:884c4614f715ea92287eb770527c6f35	1234	2026-03-04 14:01:47.721109
5105	1012	LABOUR 8	1234	4c2a6b60a17868a37bf9cd2759689dc4:c61a9f7577d283545477fe1c680d29f5	1234	2026-03-04 14:01:47.730692
5106	1012	LABOUR 9	1234	fa0264e7d5af4e0a2a01118a9233520b:75ef8f014387a164a32c9b0fece6a999	1234	2026-03-04 14:01:47.739265
5107	1012	LABOUR 10	1234	3094d1a81d090e8891ea0e609a0ba3c2:ce47ff972a41f46eebc8c166264b7c74	1234	2026-03-04 14:01:47.748931
5108	1012	VINOD M N	1234	bc77fdc973c553cda005af66220a1bd4:7062ff4a2f3d7708417029b28e329d14	1234	2026-03-04 14:18:20.632355
5109	1012	VINOD REDDY M N	1234	d3fea7fc2db208ebe8d215c321038e33:dac23e8d3077a5fbc3d88e69e7db6c32	1234	2026-03-04 14:18:20.648763
5110	1012	VINOD	1234	bef27f14ef84648b535892dc46583539:d160c5e3e36f6307325308eb36014562	1234	2026-03-04 14:20:48.644015
5111	1012	VINOD REDDY M N	1234	95dc50f7d4722bf57494c23448b7b980:2c5ce4cfce9bfb4e95653d2755a9427e	1234	2026-03-04 14:20:48.656134
5112	1012	VINOD	1234	9a59e77d965d1d57fa66219bf1e774e0:4da49ec78d95f1b9badf296f793e74c3	1234	2026-03-04 14:23:45.410797
5113	1012	M N VINOD	1234	cf02b976bffc2b5927179a16692d4a68:ca900ef5609024465831534442c1d961	1234	2026-03-04 14:23:45.424879
5114	1012	VINOD M N	1234	c971ac290ce2616092c36d022da4dc96:23d4acaa3639afeb8e16a255e062b4f7	1234	2026-03-04 14:25:05.810881
5115	1012	VINOD	1234	a87d8749ca9eaf9e14031abda33f9d6e:b73ca0f45deedf9e77cee9df34015f28	1234	2026-03-04 14:26:52.828305
5116	1012	VINOD	1234	618fd7afe5a573961879fc691c8dafba:88830efe94cbdeda9243bb47801c4ab7	1234	2026-03-04 14:27:59.314937
5117	1012	VINOD	1234	0e5b9360e462c6b234ce3d8a48f3dd25:7a993201df46b4eb5a18ec10bf3e0593	1234	2026-03-04 14:30:15.291289
5118	1012	VINOD	1234	cad30ce8c34b237fdf092b0e56434ffd:e70f87b53dc7e04a0d455e0141eb27f1	1234	2026-03-04 14:32:58.230552
5119	1012	VINOD	1234	d897a1e0859dd4365ed9ec361c821a2e:13b601ffa11c91e43a0ec0ed209f5a05	1234	2026-03-04 14:33:59.173935
5120	1012	VINOD	1234	d25898c8bbdfa0e0d3f3b433747c6661:5a648656350db73999ebc24fdc7dea27	1234	2026-03-04 14:38:27.869003
5121	1012	VINOD	1234	b0b194e0f53cbe3ca1b2c66e2b0976e5:f904a8e6f516532c8bd73e4871d7ec98	1234	2026-03-04 14:41:34.424336
5122	1012	VINOD	1234	2071031f3e665a130ffc5dc9b5b8f6c9:fe81dbc1eba14f951a0eef8e1756d895	1234	2026-03-04 15:08:59.49181
5123	1012	VINO	1234	014c89246f7af05935a11f478441f406:6e7db9015f7f08b95c1a5badb67a5254	1234	2026-03-04 15:11:09.580384
5124	1012	VIN	123	416a033ef4838638f48ce0f4af1dbf1e:342f3af7d938a53b0de8b315dc1b6caf	123	2026-03-04 15:12:04.260485
5125	1012	VIN	123	a0dc0f4999121370ca7332c3e5c4de46:6548d69f13d54ac5f998060311c13d15	123	2026-03-04 15:13:18.033128
5126	1012	VIN	123	264287cda55dcf17b4ee9703f9600d6e:1d2291d79c6792192a1b13520df1f569	123	2026-03-04 15:14:14.003073
5127	1012	VINOD	1234	6d3f8612e9db8e32589cad0e39f8d8c5:ca2dd8de593acf93a0eb29a6a506a2c9	1234	2026-03-04 15:14:14.016985
5128	1012	LABOUR NO 1	1234567890	017ba7bc6a940ca0c017b92f9c39ca4a:c3e3b37b78a25d26ecfe1cf7a903f22b	9001	2026-03-04 15:19:55.605034
5129	1012	LABOUR NO 2	1234567891	287941f63c76d900044c52465669344d:1ca630220c6bd8c1c8d8268dc6b84c31	9002	2026-03-04 15:19:55.616617
5130	1012	LABOUR NO 3	1234567892	4a7c7ae4f87b4a9b1bb006fef21f4e39:5b8ccc2c56cd4cab100315ad833cd3f7	9003	2026-03-04 15:19:55.624129
5131	1012	LABOUR NO 4	1234567893	cc1bc357156d90966ad1c20036371e95:ce195af09e7f1426b94668cdccee01f9	9004	2026-03-04 15:19:55.633985
5132	1012	LABOUR NO 5	1234567894	46122ef3db35cc00aeb21798cd713ea2:c67adf44dd54964f44591f7c62125dd4	9005	2026-03-04 15:19:55.64128
5133	1012	LABOUR NO 6	1234567895	256e698ca876771e2f76b4ae54567ffd:21b75600c67dd594ef537ae1f1d7dae0	9006	2026-03-04 15:19:55.651095
5134	1012	LABOUR NO 7	1234567896	7d34123f2a86a9a7f1e79300504cf30a:97fbbaadf17bdba999f46fa9aabc2fa5	9007	2026-03-04 15:19:55.658274
5135	1012	LABOUR NO 8	1234567897	b5c7629734ed72f8c1ffe3f8d0f7fc4e:31121fe8d483bab112c2912569b62dc6	9008	2026-03-04 15:19:55.668131
5136	1012	LABOUR NO 9	1234567898	435afb5f2527457e46777651b8c0d9c5:096cde2f410640d2844fc70e1b581522	9009	2026-03-04 15:19:55.67459
5137	1012	LABOUR NO 10	1234567899	941ad7f1fb0f66ad20bc8d16183dca04:6494260d0097f5b74e1abe67ad9175f6	9010	2026-03-04 15:19:55.683655
5138	1012	VIN	123	b1a15e5a56588a35cebb4cd2a50c7d3b:14399b6ba7afc31f4724b32555f87b0b	123	2026-03-04 15:21:35.01345
5139	1012	VIN	123	e3981c9529bc09f29111672ac07a9c20:4bac99f8ca0ec5416c2eb6f3e47c2bbc	123	2026-03-04 15:23:44.840125
5140	1012	VIN	123	5651857378f27df750ac72c89a1c91d7:0348aee869ecbabb53e6659bf6ad37d0	123	2026-03-04 15:27:26.302001
5141	1012	VIN	123	0e48e4d74718144fe487b2948c53fcf5:40eb3cf5396c699300ee00737b456e9c	123	2026-03-04 15:29:09.256776
5142	1012	LABOUR NO 1	1234500001	7c53bb2121e30f2cafb7f1a790c4ce6e:f9bbcd48d07a638ba5076b44c65e3b71	0001	2026-03-04 15:38:25.281992
5143	1012	LABOUR NO 2	1234500002	828b1881abab410dff79bacaeb712d7b:73dd6c11d94a994d22c3a86430fd3f17	0002	2026-03-04 15:38:25.296027
5144	1012	LABOUR NO 3	1234500003	5effc6841cd5e8237475261580d81ad3:f98c9341e2120370b5bdabaffd8f279f	0003	2026-03-04 15:38:25.306236
5145	1012	LABOUR NO 4	1234500004	0001559c1d8e4d2dc12f1586675284a5:e5ef2a75814009319f086a46cacc0b27	0004	2026-03-04 15:38:25.318429
5146	1012	LABOUR NO 5	1234500005	40a14d0deb7f4abf9fe6674eae8c26f9:38efc415125bcb48acfedb15f94685a5	0005	2026-03-04 15:38:25.331238
5147	1012	LABOUR NO 6	1234500006	30f1f4e6882b318cf3ea80ee14199974:2a6c7284462fda22f89b04f0eeac7589	0006	2026-03-04 15:38:25.342121
5148	1012	LABOUR NO 7	1234500007	c24e83c0ae5ef5920a5544180cbcba1b:161a21ba42352a8187ae37180a146535	0007	2026-03-04 15:38:25.353311
5149	1012	LABOUR NO 8	1234500008	5d4bb5551ff9bdff47398bf99bcca9a3:609c8ce5d03d7b7f72fdae4fcad5be3b	0008	2026-03-04 15:38:25.366884
5150	1012	LABOUR NO 9	1234500009	2463605d339b6ef088ea643463f7f05a:8d350ce64c19f22d5de09661e4254015	0009	2026-03-04 15:38:25.37654
5151	1012	LABOUR NO 10	1234500010	b57e7774cd81d034773ccad95679e76d:30a18d0ea7bdeb874fa985f436386cd1	0010	2026-03-04 15:38:25.383892
5152	1012	LABOUR NO 11	1234500011	c1f76c36f2f12e709073e80f7024e7df:4fb4afb8b78d146a1e44fee72839b25d	0011	2026-03-04 15:38:25.393198
5153	1115	VINOD M N	9876540001	15433636fd15ce6ae68ff2dfcf3f3ce6:31866c3dbb76d0a490d83dacd48fd0cf	0001	2026-03-04 17:33:59.010422
5154	1115	REEGAN AKISH	9876540002	61006545fafd984a088f501a3ea8deb9:d69220ceb4e0fd60c023591bd2027e90	0002	2026-03-04 17:33:59.040605
5155	1115	AMIT BHAGARI	9876540003	ab0256520b1168d6b9a485762a6b57cd:0d3e8957334183bc5b250fc35b6ef350	0003	2026-03-04 17:33:59.095386
5156	1115	PRANABH JANA	9876540004	a7a31113eb9b5ce8387bdaaa51442891:628b3a875fe54c30e968fb85a9f105e4	0004	2026-03-04 17:33:59.112303
5157	1115	MARUTHI V	9876540005	0fcbceb8db6330104f6877913088e10d:318402fff1e83b107cfcb08e53c39e7c	0005	2026-03-04 17:33:59.122475
5158	1115	SHARAT KUMAR	9876540006	94e9b5722f23497f7dd161f0be106051:d2aee1aa5907426b96a14238a3dc7113	0006	2026-03-04 17:33:59.136188
5159	1115	SHOBAN RAJ	9876540007	474cfc9c8759590175f973ff35cde9b7:cae25ffda483f04238111c1500d0bf11	0007	2026-03-04 17:33:59.148198
5160	1115	VINOD	1234567890	4edcc9c64fa0fb5aa99cf7a0eb68672d:14ecaff0eabb2bf89e51ca1a13cd26f9	1234	2026-03-04 19:11:00.590381
5161	1115	AMIT BHGARI	1234	a5cfbe426d15f5c1888c79386b21ce4d:30d0210e65eac936d836f52481a3cff1	1234	2026-03-05 20:13:28.782096
5162	1115	PRANABH JANA	1234	c5fb7aa4f014648bae1efa782ddfe794:cc9f54b0c8749588895f79881808b153	1234	2026-03-05 20:13:28.796772
5163	1115	VINOD	1234	c645cf1acf50dddffbe2ca7cf0c59a7a:786505acb7eba685a9945614a587b17d	1234	2026-03-06 15:08:22.349727
5164	1115	REDDY	1234	a07f51822325d63541cd40e274b0ba12:b6fef48dca3ef35fab925fbb44364ad7	1234	2026-03-06 15:08:22.384652
5165	1115	AMIT	1234	edc9ced37864b09313c4b3db4531e492:16d06bbbadcc5bd181fd62e95729d7ad	1234	2026-03-06 17:14:23.852158
5166	1115	KUMAR	1234	bbf2ca855d7622b2f3a50ad5c4d79dce:bd0d5b116ec579fa100af4605ff11be6	1234	2026-03-06 17:14:23.883557
5167	1116	VINOD	1234	9b028ca12ba382ebdec5066ed053bbc1:31acd298b3248034b1c2ab3fc7bd6acc	1234	2026-03-06 17:43:15.181059
5168	1116	VINOD REDDY	1234	9cc9505650df6515ef0b3aaa052cb469:f0ed4de6841a82b0e755b7ae04904ae6	1234	2026-03-06 17:43:15.210509
5169	1116	VINOD REDDY M N	1234	be8df3217930af6e40156e2c6ad8060d:c8a2cfe9784f3c2d9e147b778f986d49	1234	2026-03-06 17:43:15.231605
5170	1016	LABOUR NO 1	1234	34b106463c8fb1c4b5b754c8b63279bf:8c0f4f49177aeee097c84e964f0a0319	1234	2026-03-06 18:01:33.608964
5171	1016	LABOUR NO 2	1234	f657036f9330e1151d29be0ab8a625e9:bc65d6890e814b4551eecba174b40b4d	1234	2026-03-06 18:01:33.637534
5172	1116	VINOD	1234	acfed6095c98bc27e643f2cfb1e04eb8:d11301cf3dbd31b83773a35960e4001d	1234	2026-03-06 19:00:33.287341
5173	1116	VINOD REDDY	1234	fd125bd45d49785b66b7f0feb2842871:2583fa5c90ae17897cc846b1afa56cab	1234	2026-03-06 19:00:33.298937
5174	1116	VINOD	1234	8a4d0a3be4565ace1470bd07e0c51da1:fb20ee92885cfd0aa62958c4d7d7aa6a	1234	2026-03-08 19:13:29.647305
5175	1116	AMIT	1234	8735bdcfe4cf45e680199103e378603d:f7b32db2c9366a09f3e0812a65db1700	1234	2026-03-08 19:13:29.66184
5176	1115	VINOD	1234	e4381b6d706b6610394ef2d09f9d71bb:9076d9fdfc648e776da2a3e0c0747545	1234	2026-03-09 12:12:11.119508
5177	1115	AMIT	1234	ee210d9c1e2f412721927b4debe8bf8e:0587ca37707a95343ad4d439d3d906b8	1234	2026-03-09 12:12:11.157827
5178	1115	VINOD	1234	32c33260344a8833b8700d5e18881a76:76c0b5a62d830c3118086d7ea10bcfaf	1234	2026-03-09 15:08:52.544709
5179	1115	AMIT	1234	1fe4860c1860ba7121ab97442b1caed7:d0a9a64ec74015a32320ef977b9ac3c5	1234	2026-03-09 15:08:52.555888
\.


--
-- TOC entry 5400 (class 0 OID 17416)
-- Dependencies: 253
-- Data for Name: manifest_labours; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.manifest_labours (manifest_id, labour_id) FROM stdin;
1	5005
2	5006
2	5007
3	5009
3	5008
4	5005
4	5004
4	5003
4	5002
5	5005
5	5004
5	5003
5	5002
6	5005
6	5004
6	5003
6	5002
7	5005
7	5004
7	5003
7	5002
8	5005
8	5004
8	5003
8	5002
9	5005
9	5004
9	5003
9	5002
10	5005
10	5004
10	5003
10	5002
11	5005
11	5004
11	5003
11	5002
12	5005
12	5004
12	5003
12	5002
13	5005
13	5004
13	5003
13	5002
14	5007
14	5006
15	5010
16	5012
16	5011
17	5005
17	5004
17	5003
17	5002
18	5014
18	5005
18	5004
18	5003
18	5002
19	5016
19	5015
19	5013
19	5012
19	5011
20	5017
21	5017
21	5014
21	5005
21	5004
21	5003
21	5002
22	5018
23	5019
24	5007
24	5006
25	5026
25	5027
26	5028
26	5029
27	5030
27	5031
28	5032
28	5033
29	5034
29	5035
29	5036
30	5037
30	5038
30	5039
31	5040
31	5041
31	5042
31	5043
32	5044
32	5045
33	5046
33	5047
33	5048
34	5049
34	5050
34	5051
34	5052
35	5053
36	5054
36	5055
37	5056
37	5057
37	5058
38	5059
38	5060
38	5061
38	5062
39	5063
40	5064
41	5065
42	5066
43	5067
43	5068
43	5069
43	5070
43	5071
43	5072
43	5073
44	5074
44	5075
44	5076
44	5077
44	5078
45	5079
46	5080
47	5081
48	5082
49	5083
50	5084
51	5085
52	5086
53	5087
54	5088
55	5089
56	5090
57	5091
58	5092
59	5093
60	5094
61	5095
62	5096
63	5097
64	5098
64	5099
64	5100
64	5101
64	5102
64	5103
64	5104
64	5105
64	5106
64	5107
65	5108
65	5109
66	5110
66	5111
67	5112
67	5113
68	5114
69	5115
70	5116
71	5117
72	5118
73	5119
74	5120
75	5121
76	5122
77	5123
78	5124
79	5125
80	5126
80	5127
81	5128
81	5129
81	5130
81	5131
81	5132
81	5133
81	5134
81	5135
81	5136
81	5137
82	5138
83	5139
84	5140
85	5141
86	5142
86	5143
86	5144
86	5145
86	5146
86	5147
86	5148
86	5149
86	5150
86	5151
86	5152
87	5153
87	5154
87	5155
87	5156
87	5157
87	5158
87	5159
88	5160
89	5161
89	5162
90	5163
90	5164
91	5165
91	5166
92	5167
92	5168
92	5169
93	5170
93	5171
94	5172
94	5173
95	5174
95	5175
96	5176
96	5177
97	5178
97	5179
\.


--
-- TOC entry 5406 (class 0 OID 17473)
-- Dependencies: 260
-- Data for Name: material_transactions; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.material_transactions (id, visitor_id, material_id, quantity, direction, transaction_time) FROM stdin;
\.


--
-- TOC entry 5404 (class 0 OID 17463)
-- Dependencies: 258
-- Data for Name: materials; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.materials (id, category, make, model, serial_number, description) FROM stdin;
7001	TOOLS	Stanley	TIM-100	SN123456	Power Drill
\.


--
-- TOC entry 5371 (class 0 OID 17134)
-- Dependencies: 224
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.projects (id, project_name, is_active, created_at, department_id) FROM stdin;
2	Radar Modernization	t	2026-02-23 11:55:54.082506	2
4	Access Control System	f	2026-02-23 11:55:54.082506	4
5	Naval Airfield Integrated Security System (NAISS)	\N	2026-02-26 14:55:56.121932	2
3	Dockyard Automation	\N	2026-02-23 11:55:54.082506	2
6	Naval Airfield Integrated Security System (NAISS)	\N	2026-02-26 16:05:36.292798	3
7	Naval Airfield Integrated Security System (NAISS)	\N	2026-02-26 16:37:45.715102	5
8	Naval Airfield Integrated Security System (NAISS)	\N	2026-02-26 16:38:07.24198	6
9	Naval Airfield Integrated Security System (NAISS)	\N	2026-02-26 16:46:18.699347	3
10	NAISS	\N	2026-02-26 16:53:13.883931	6
11	NAISS	\N	2026-02-26 16:54:14.52097	6
12	NAVAL AIR FIELD INTEGRATED SECURITY SYSTEM (NAISS)	t	2026-02-26 16:56:56.098049	7
\.


--
-- TOC entry 5391 (class 0 OID 17320)
-- Dependencies: 244
-- Data for Name: rfid_cards; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.rfid_cards (id, visitor_id, card_uid, qr_code, issue_date, expiry_date, card_status, replaced_by, created_at) FROM stdin;
4006	1013	RFID0002	RFID0002	2026-02-28	2026-03-14	INACTIVE	\N	2026-02-28 11:52:15.845346
4009	1013	RFID0003	RFID0003	2026-02-28	2026-03-14	INACTIVE	\N	2026-02-28 12:01:31.078026
4010	1013	CARD0002	CARD0002	2026-02-27	2026-03-13	ACTIVE	\N	2026-02-28 16:37:23.005018
4004	1012	RFID0001	RFID0001	2026-02-28	2026-09-28	INACTIVE	\N	2026-02-28 11:49:17.942406
4011	1012	CARD0004	CARD0004	2026-02-27	2026-09-27	ACTIVE	\N	2026-02-28 16:43:43.275428
4012	1011	CARD0005	CARD0005	2026-02-28	2026-03-14	ACTIVE	\N	2026-02-28 17:35:20.556187
4013	1006	CARD0006	CARD0006	2026-02-28	2026-03-14	ACTIVE	\N	2026-02-28 17:35:50.33872
4014	1007	CARD0007	CARD0007	2026-02-28	2026-03-14	ACTIVE	\N	2026-02-28 19:13:34.931287
4002	1014	6cfd6d16-42a4-459c-86ef-4e556ba90b61	6cfd6d16-42a4-459c-86ef-4e556ba90b61	2026-02-27	2026-05-28	INACTIVE	\N	2026-02-28 11:38:53.985642
4015	1014	CARD0008	CARD0008	2026-02-26	2026-05-27	ACTIVE	\N	2026-02-28 20:43:26.343098
4016	1009	CARD0009	CARD0009	2026-03-02	2026-03-07	ACTIVE	\N	2026-03-02 17:36:46.384934
4017	1024	CARD0010	CARD0010	2026-03-03	2026-03-04	ACTIVE	\N	2026-03-03 12:52:02.447274
4018	1088	CARD0011	CARD0011	2026-03-03	2026-04-11	ACTIVE	\N	2026-03-03 12:52:28.633929
4019	1094	CARD0012	CARD0012	2026-03-03	2026-04-11	ACTIVE	\N	2026-03-03 12:52:52.30656
4020	1044	CARD0013	CARD0013	2026-03-03	2026-04-11	ACTIVE	\N	2026-03-03 12:53:12.184079
4021	1077	CARD0014	CARD0014	2026-03-03	2026-04-11	ACTIVE	\N	2026-03-03 12:53:29.785121
4022	1016	CARD0015	CARD0015	2026-03-03	2026-03-28	ACTIVE	\N	2026-03-03 12:53:52.513236
4023	1115	CARD0016	CARD0016	2026-03-04	2026-04-30	ACTIVE	\N	2026-03-04 17:30:21.722323
4024	1116	CARD0017	CARD0017	2026-03-05	2026-03-30	ACTIVE	\N	2026-03-06 17:41:16.225202
4025	1117	CARD0018	CARD0018	2026-03-08	2026-03-31	ACTIVE	\N	2026-03-08 10:35:41.606005
\.


--
-- TOC entry 5423 (class 0 OID 17623)
-- Dependencies: 277
-- Data for Name: rfid_cards_stock; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.rfid_cards_stock (id, uid, status, created_at, updated_at, removed_reason) FROM stdin;
2	CARD0002	ASSIGNED	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
4	CARD0004	ASSIGNED	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
5	CARD0005	ASSIGNED	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
6	CARD0006	ASSIGNED	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
7	CARD0007	ASSIGNED	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
1	CARD0001	ASSIGNED	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
3	CARD0003	ASSIGNED	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
19	CARD0019	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
20	CARD0020	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
21	CARD0021	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
22	CARD0022	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
23	CARD0023	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
24	CARD0024	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
25	CARD0025	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
26	CARD0026	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
27	CARD0027	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
28	CARD0028	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
29	CARD0029	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
30	CARD0030	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
31	CARD0031	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
32	CARD0032	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
33	CARD0033	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
34	CARD0034	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
35	CARD0035	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
36	CARD0036	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
37	CARD0037	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
38	CARD0038	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
39	CARD0039	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
40	CARD0040	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
41	CARD0041	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
42	CARD0042	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
43	CARD0043	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
44	CARD0044	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
45	CARD0045	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
46	CARD0046	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
47	CARD0047	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
48	CARD0048	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
49	CARD0049	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
50	CARD0050	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
51	CARD0051	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
52	CARD0052	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
53	CARD0053	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
54	CARD0054	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
55	CARD0055	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
56	CARD0056	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
57	CARD0057	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
58	CARD0058	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
59	CARD0059	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
60	CARD0060	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
61	CARD0061	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
62	CARD0062	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
63	CARD0063	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
64	CARD0064	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
65	CARD0065	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
66	CARD0066	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
67	CARD0067	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
68	CARD0068	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
69	CARD0069	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
70	CARD0070	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
71	CARD0071	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
72	CARD0072	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
73	CARD0073	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
74	CARD0074	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
75	CARD0075	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
76	CARD0076	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
77	CARD0077	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
78	CARD0078	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
79	CARD0079	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
80	CARD0080	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
81	CARD0081	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
82	CARD0082	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
83	CARD0083	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
84	CARD0084	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
85	CARD0085	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
86	CARD0086	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
87	CARD0087	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
88	CARD0088	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
89	CARD0089	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
90	CARD0090	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
91	CARD0091	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
92	CARD0092	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
93	CARD0093	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
94	CARD0094	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
95	CARD0095	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
96	CARD0096	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
97	CARD0097	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
98	CARD0098	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
99	CARD0099	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
100	CARD0100	AVAILABLE	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
8	CARD0008	ASSIGNED	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
9	CARD0009	ASSIGNED	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
10	CARD0010	ASSIGNED	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
11	CARD0011	ASSIGNED	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
12	CARD0012	ASSIGNED	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
13	CARD0013	ASSIGNED	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
14	CARD0014	ASSIGNED	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
15	CARD0015	ASSIGNED	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
16	CARD0016	ASSIGNED	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
17	CARD0017	ASSIGNED	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
18	CARD0018	ASSIGNED	2026-02-28 11:48:03.297708	2026-02-28 16:35:52.395988	\N
\.


--
-- TOC entry 5419 (class 0 OID 17585)
-- Dependencies: 273
-- Data for Name: rfid_stock; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.rfid_stock (id, uid, status, removed_reason, created_at, updated_at) FROM stdin;
3	RFID0003	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
4	RFID0004	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
5	RFID0005	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
1	RFID0001	ASSIGNED	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
2	RFID0002	ASSIGNED	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
9	RFID0009	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
6	RFID0006	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
7	RFID0007	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
8	RFID0008	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
10	RFID0010	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
49	RFID0049	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
50	RFID0050	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
51	RFID0051	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
52	RFID0052	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
53	RFID0053	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
54	RFID0054	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
55	RFID0055	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
56	RFID0056	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
57	RFID0057	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
58	RFID0058	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
59	RFID0059	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
60	RFID0060	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
61	RFID0061	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
62	RFID0062	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
63	RFID0063	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
64	RFID0064	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
65	RFID0065	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
66	RFID0066	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
67	RFID0067	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
68	RFID0068	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
69	RFID0069	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
70	RFID0070	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
71	RFID0071	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
72	RFID0072	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
73	RFID0073	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
74	RFID0074	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
75	RFID0075	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
76	RFID0076	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
77	RFID0077	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
78	RFID0078	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
79	RFID0079	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
80	RFID0080	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
81	RFID0081	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
82	RFID0082	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
83	RFID0083	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
84	RFID0084	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
85	RFID0085	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
86	RFID0086	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
87	RFID0087	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
88	RFID0088	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
89	RFID0089	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
90	RFID0090	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
91	RFID0091	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
92	RFID0092	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
93	RFID0093	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
94	RFID0094	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
95	RFID0095	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
96	RFID0096	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
97	RFID0097	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
98	RFID0098	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
99	RFID0099	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
100	RFID0100	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
11	RFID0011	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
12	RFID0012	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
13	RFID0013	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
14	RFID0014	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
15	RFID0015	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
16	RFID0016	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
17	RFID0017	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
18	RFID0018	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
19	RFID0019	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
20	RFID0020	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
21	RFID0021	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
22	RFID0022	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
23	RFID0023	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
24	RFID0024	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
25	RFID0025	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
26	RFID0026	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
27	RFID0027	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
37	RFID0037	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
38	RFID0038	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
39	RFID0039	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
40	RFID0040	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
28	RFID0028	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
29	RFID0029	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
30	RFID0030	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
31	RFID0031	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
32	RFID0032	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
33	RFID0033	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
34	RFID0034	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
43	RFID0043	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
35	RFID0035	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
36	RFID0036	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
41	RFID0041	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
42	RFID0042	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
44	RFID0044	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
45	RFID0045	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
46	RFID0046	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
47	RFID0047	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
48	RFID0048	AVAILABLE	\N	2026-02-28 12:18:23.365552	2026-02-28 12:18:23.367079
\.


--
-- TOC entry 5367 (class 0 OID 17099)
-- Dependencies: 220
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.roles (id, role_name, can_export_pdf, can_export_excel, created_at) FROM stdin;
1	SUPER_ADMIN	t	t	2026-02-23 00:16:02.150516
4	REGULATING_OFFICER	t	t	2026-03-07 15:31:44.064505
2	REGULATING_PETTY_OFFICER	t	f	2026-02-23 00:16:02.150516
5	ENROLLMENT_STAFF_LABOURS	f	f	2026-03-07 15:34:44.279969
3	ENROLLMENT_STAFF_VISITORS	t	f	2026-02-23 00:16:02.150516
6	ADMIN	t	t	2026-03-07 15:38:36.621164
\.


--
-- TOC entry 5410 (class 0 OID 17503)
-- Dependencies: 264
-- Data for Name: sms_logs; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.sms_logs (id, recipient, message, event_type, related_entity_id, sent_at, status) FROM stdin;
10001	9876543210	Test SMS	TEST	1001	2026-02-23 00:16:02.150516	SENT
10002	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 11:40:00.357122	SENT
10003	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 11:40:00.369916	SENT
10004	9876543210	No-Show Alert: Vinod Reddy M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 11:50:00.34605	SENT
10005	9876543210	No-Show Alert: NAISS has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 11:50:00.357744	SENT
10006	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 11:50:00.367037	SENT
10007	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 11:50:00.376119	SENT
10008	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 11:50:00.383618	SENT
10009	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 11:50:00.392284	SENT
10010	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 11:50:00.400291	SENT
10011	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 11:50:00.409525	SENT
10012	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 11:50:00.419563	SENT
10013	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 11:50:00.428758	SENT
10014	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 11:50:00.437493	SENT
10015	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 11:50:00.445712	SENT
10016	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 11:50:00.454562	SENT
10017	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 11:50:00.464468	SENT
10018	9876543210	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 11:50:00.473704	SENT
10019	9876543211	No-Show Alert: hjuil has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 11:50:00.482946	SENT
10020	9876543211	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 11:50:00.491911	SENT
10021	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 11:50:00.500245	SENT
10022	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 11:50:00.510913	SENT
10023	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 11:50:00.520181	SENT
10024	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 11:50:00.529381	SENT
10025	9876543211	No-Show Alert: fghuyt has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 11:50:00.538301	SENT
10026	9876543211	No-Show Alert: yhgtred has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 11:50:00.548837	SENT
10027	9876543210	No-Show Alert: Vinod Reddy M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:00:00.647868	SENT
10028	9876543210	No-Show Alert: NAISS has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:00:00.65966	SENT
10029	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:00:00.669281	SENT
10030	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:00:00.680948	SENT
10031	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:00:00.692281	SENT
10032	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:00:00.701136	SENT
10033	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:00:00.711838	SENT
10034	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:00:00.721188	SENT
10035	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:00:00.730569	SENT
10036	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:00:00.739927	SENT
10037	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:00:00.749738	SENT
10038	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:00:00.759627	SENT
10039	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:00:00.769322	SENT
10040	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:00:00.776295	SENT
10041	9876543210	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:00:00.784798	SENT
10042	9876543211	No-Show Alert: hjuil has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:00:00.793914	SENT
10043	9876543211	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:00:00.802092	SENT
10044	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:00:00.811051	SENT
10045	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:00:00.819706	SENT
10046	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:00:00.826387	SENT
10047	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:00:00.83435	SENT
10048	9876543211	No-Show Alert: fghuyt has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:00:00.844231	SENT
10049	9876543211	No-Show Alert: yhgtred has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:00:00.854026	SENT
10050	9876543210	No-Show Alert: Vinod Reddy M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:10:00.15345	SENT
10051	9876543210	No-Show Alert: NAISS has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:10:00.169367	SENT
10052	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:10:00.181771	SENT
10053	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:10:00.194009	SENT
10054	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:10:00.205495	SENT
10055	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:10:00.215035	SENT
10056	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:10:00.225762	SENT
10057	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:10:00.236601	SENT
10058	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:10:00.247718	SENT
10059	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:10:00.260253	SENT
10060	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:10:00.2701	SENT
10061	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:10:00.280328	SENT
10062	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:10:00.292114	SENT
10063	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:10:00.303667	SENT
10064	9876543210	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:10:00.315839	SENT
10065	9876543211	No-Show Alert: hjuil has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:10:00.32869	SENT
10066	9876543211	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:10:00.339991	SENT
10067	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:10:00.349758	SENT
10068	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:10:00.361866	SENT
10069	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:10:00.371223	SENT
10070	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:10:00.380982	SENT
10071	9876543211	No-Show Alert: fghuyt has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:10:00.392633	SENT
10072	9876543211	No-Show Alert: yhgtred has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:10:00.404614	SENT
10073	9876543210	No-Show Alert: Vinod Reddy M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:20:00.695975	SENT
10074	9876543210	No-Show Alert: NAISS has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:20:00.701803	SENT
10075	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:20:00.70698	SENT
10076	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:20:00.711702	SENT
10077	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:20:00.715479	SENT
10078	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:20:00.719233	SENT
10079	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:20:00.72334	SENT
10080	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:20:00.727544	SENT
10081	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:20:00.731387	SENT
10082	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:20:00.735217	SENT
10083	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:20:00.739758	SENT
10084	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:20:00.743915	SENT
10085	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:20:00.747109	SENT
10086	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:20:00.750653	SENT
10087	9876543210	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:20:00.755017	SENT
10088	9876543211	No-Show Alert: hjuil has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:20:00.760325	SENT
10089	9876543211	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:20:00.764906	SENT
10090	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:20:00.769031	SENT
10091	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:20:00.773729	SENT
10092	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:20:00.778292	SENT
10093	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:20:00.782712	SENT
10094	9876543211	No-Show Alert: fghuyt has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:20:00.787126	SENT
10095	9876543211	No-Show Alert: yhgtred has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:20:00.791822	SENT
10096	9876543210	No-Show Alert: Vinod Reddy M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:30:00.966514	SENT
10097	9876543210	No-Show Alert: NAISS has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:30:00.972163	SENT
10098	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:30:00.976881	SENT
10099	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:30:00.981848	SENT
10100	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:30:00.986177	SENT
10101	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:30:00.991069	SENT
10102	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:30:00.996964	SENT
10103	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:30:01.004398	SENT
10104	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:30:01.009224	SENT
10105	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:30:01.012996	SENT
10106	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:30:01.017516	SENT
10107	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:30:01.022357	SENT
10108	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:30:01.026024	SENT
10109	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:30:01.030083	SENT
10110	9876543210	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:30:01.034285	SENT
10111	9876543211	No-Show Alert: hjuil has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:30:01.038524	SENT
10112	9876543211	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:30:01.042114	SENT
10113	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:30:01.046385	SENT
10114	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:30:01.049908	SENT
10115	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:30:01.055428	SENT
10116	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:30:01.060218	SENT
10117	9876543211	No-Show Alert: fghuyt has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:30:01.065437	SENT
10118	9876543211	No-Show Alert: yhgtred has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:30:01.069538	SENT
10119	9876543210	No-Show Alert: Vinod Reddy M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:40:00.964024	SENT
10120	9876543210	No-Show Alert: NAISS has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:40:00.968329	SENT
10121	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:40:00.971998	SENT
10122	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:40:00.975707	SENT
10123	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:40:00.979178	SENT
10124	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:40:00.983008	SENT
10125	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:40:00.986395	SENT
10126	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:40:00.990052	SENT
10127	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:40:00.993252	SENT
10128	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:40:00.996676	SENT
10129	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:40:01.000295	SENT
10130	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:40:01.004212	SENT
10131	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:40:01.008065	SENT
10132	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:40:01.011631	SENT
10133	9876543210	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:40:01.014896	SENT
10134	9876543211	No-Show Alert: hjuil has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:40:01.018031	SENT
10135	9876543211	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:40:01.021278	SENT
10136	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:40:01.025272	SENT
10137	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:40:01.028304	SENT
10138	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:40:01.031118	SENT
10139	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:40:01.034771	SENT
10140	9876543211	No-Show Alert: fghuyt has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:40:01.037769	SENT
10141	9876543211	No-Show Alert: yhgtred has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:40:01.040662	SENT
10142	9876543210	No-Show Alert: Vinod Reddy M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:50:00.807949	SENT
10143	9876543210	No-Show Alert: NAISS has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:50:00.812411	SENT
10144	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:50:00.81639	SENT
10145	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:50:00.820782	SENT
10146	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:50:00.825337	SENT
10147	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:50:00.828602	SENT
10148	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:50:00.832145	SENT
10149	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:50:00.837143	SENT
10150	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:50:00.841472	SENT
10151	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:50:00.845048	SENT
10152	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:50:00.848633	SENT
10153	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:50:00.852164	SENT
10154	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:50:00.855926	SENT
10155	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:50:00.860341	SENT
10156	9876543210	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:50:00.864504	SENT
10157	9876543211	No-Show Alert: hjuil has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:50:00.86867	SENT
10158	9876543211	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:50:00.872969	SENT
10159	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:50:00.877023	SENT
10160	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:50:00.880868	SENT
10161	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:50:00.88546	SENT
10162	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:50:00.890313	SENT
10163	9876543211	No-Show Alert: fghuyt has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:50:00.894727	SENT
10164	9876543211	No-Show Alert: yhgtred has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 12:50:00.898827	SENT
10165	9876543210	No-Show Alert: Vinod Reddy M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:00:00.879119	SENT
10166	9876543210	No-Show Alert: NAISS has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:00:00.883045	SENT
10167	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:00:00.886521	SENT
10168	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:00:00.890292	SENT
10169	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:00:00.894088	SENT
10170	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:00:00.897626	SENT
10171	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:00:00.901551	SENT
10172	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:00:00.905222	SENT
10173	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:00:00.909079	SENT
10174	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:00:00.912925	SENT
10175	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:00:00.916872	SENT
10176	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:00:00.921801	SENT
10177	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:00:00.92554	SENT
10178	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:00:00.929413	SENT
10179	9876543210	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:00:00.933245	SENT
10180	9876543211	No-Show Alert: hjuil has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:00:00.939597	SENT
10181	9876543211	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:00:00.9457	SENT
10182	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:00:00.950776	SENT
10183	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:00:00.955457	SENT
10184	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:00:00.959585	SENT
10185	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:00:00.963849	SENT
10186	9876543211	No-Show Alert: fghuyt has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:00:00.969413	SENT
10187	9876543211	No-Show Alert: yhgtred has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:00:00.974499	SENT
10188	9876543210	No-Show Alert: Vinod Reddy M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:10:00.872254	SENT
10189	9876543210	No-Show Alert: NAISS has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:10:00.876822	SENT
10190	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:10:00.880803	SENT
10191	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:10:00.884904	SENT
10192	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:10:00.888968	SENT
10193	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:10:00.8923	SENT
10194	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:10:00.895776	SENT
10195	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:10:00.899413	SENT
10196	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:10:00.902982	SENT
10197	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:10:00.906868	SENT
10198	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:10:00.910607	SENT
10199	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:10:00.914339	SENT
10200	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:10:00.91828	SENT
10201	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:10:00.921702	SENT
10202	9876543210	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:10:00.925535	SENT
10203	9876543211	No-Show Alert: hjuil has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:10:00.929476	SENT
10204	9876543211	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:10:00.933738	SENT
10205	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:10:00.937662	SENT
10206	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:10:00.940843	SENT
10207	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:10:00.943906	SENT
10208	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:10:00.947261	SENT
10209	9876543211	No-Show Alert: fghuyt has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:10:00.950437	SENT
10210	9876543211	No-Show Alert: yhgtred has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:10:00.953681	SENT
10211	9876543210	No-Show Alert: Vinod Reddy M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:20:00.112975	SENT
10212	9876543210	No-Show Alert: NAISS has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:20:00.118484	SENT
10213	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:20:00.121572	SENT
10214	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:20:00.125518	SENT
10215	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:20:00.128859	SENT
10216	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:20:00.132102	SENT
10217	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:20:00.135275	SENT
10218	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:20:00.13827	SENT
10219	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:20:00.141186	SENT
10220	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:20:00.14485	SENT
10221	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:20:00.147971	SENT
10222	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:20:00.150727	SENT
10223	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:20:00.153309	SENT
10224	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:20:00.156264	SENT
10225	9876543210	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:20:00.160227	SENT
10226	9876543211	No-Show Alert: hjuil has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:20:00.163421	SENT
10227	9876543211	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:20:00.166606	SENT
10228	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:20:00.169843	SENT
10229	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:20:00.172698	SENT
10230	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:20:00.177045	SENT
10231	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:20:00.180175	SENT
10232	9876543211	No-Show Alert: fghuyt has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:20:00.183174	SENT
10233	9876543211	No-Show Alert: yhgtred has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:20:00.186358	SENT
10234	9876543210	No-Show Alert: Vinod Reddy M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:30:00.040444	SENT
10235	9876543210	No-Show Alert: NAISS has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:30:00.04707	SENT
10236	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:30:00.052115	SENT
10237	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:30:00.056324	SENT
10238	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:30:00.060633	SENT
10239	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:30:00.06454	SENT
10240	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:30:00.068688	SENT
10241	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:30:00.073023	SENT
10242	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:30:00.077205	SENT
10243	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:30:00.081578	SENT
10244	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:30:00.08608	SENT
10245	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:30:00.090742	SENT
10246	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:30:00.095301	SENT
10247	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:30:00.100045	SENT
10248	9876543210	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:30:00.103957	SENT
10249	9876543211	No-Show Alert: hjuil has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:30:00.108026	SENT
10250	9876543211	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:30:00.112063	SENT
10251	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:30:00.115409	SENT
10252	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:30:00.119473	SENT
10253	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:30:00.12353	SENT
10254	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:30:00.127367	SENT
10255	9876543211	No-Show Alert: fghuyt has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:30:00.13156	SENT
10256	9876543211	No-Show Alert: yhgtred has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:30:00.135938	SENT
10257	9876543210	No-Show Alert: Vinod Reddy M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:40:00.182349	SENT
10258	9876543210	No-Show Alert: NAISS has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:40:00.188894	SENT
10259	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:40:00.193706	SENT
10260	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:40:00.198062	SENT
10261	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:40:00.202061	SENT
10262	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:40:00.207952	SENT
10263	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:40:00.212099	SENT
10264	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:40:00.216416	SENT
10265	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:40:00.220596	SENT
10266	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:40:00.224891	SENT
10267	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:40:00.229588	SENT
10268	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:40:00.233788	SENT
10269	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:40:00.237994	SENT
10270	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:40:00.242075	SENT
10271	9876543210	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:40:00.245944	SENT
10272	9876543211	No-Show Alert: hjuil has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:40:00.250513	SENT
10273	9876543211	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:40:00.254826	SENT
10274	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:40:00.258185	SENT
10275	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:40:00.261872	SENT
10276	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:40:00.265654	SENT
10277	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:40:00.269818	SENT
10278	9876543211	No-Show Alert: fghuyt has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:40:00.273927	SENT
10279	9876543211	No-Show Alert: yhgtred has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:40:00.278331	SENT
10280	9876543210	No-Show Alert: Vinod Reddy M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:50:00.070643	SENT
10281	9876543210	No-Show Alert: NAISS has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:50:00.078978	SENT
10282	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:50:00.083714	SENT
10283	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:50:00.087815	SENT
10284	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:50:00.093466	SENT
10285	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:50:00.09832	SENT
10286	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:50:00.10276	SENT
10287	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:50:00.107081	SENT
10288	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:50:00.111669	SENT
10289	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:50:00.11624	SENT
10290	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:50:00.12019	SENT
10291	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:50:00.124414	SENT
10292	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:50:00.128551	SENT
10293	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:50:00.132678	SENT
10294	9876543210	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:50:00.137389	SENT
10295	9876543211	No-Show Alert: hjuil has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:50:00.141048	SENT
10296	9876543211	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:50:00.145182	SENT
10297	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:50:00.149857	SENT
10298	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:50:00.153545	SENT
10299	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:50:00.157703	SENT
10300	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:50:00.161857	SENT
10301	9876543211	No-Show Alert: fghuyt has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:50:00.166165	SENT
10302	9876543211	No-Show Alert: yhgtred has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 13:50:00.170179	SENT
10303	9876543210	No-Show Alert: Vinod Reddy M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:00:00.890466	SENT
10304	9876543210	No-Show Alert: NAISS has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:00:00.894907	SENT
10305	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:00:00.89891	SENT
10306	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:00:00.90332	SENT
10307	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:00:00.907461	SENT
10308	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:00:00.911822	SENT
10309	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:00:00.916011	SENT
10310	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:00:00.920402	SENT
10311	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:00:00.924033	SENT
10312	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:00:00.927694	SENT
10313	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:00:00.931382	SENT
10314	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:00:00.935939	SENT
10315	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:00:00.940381	SENT
10316	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:00:00.945	SENT
10317	9876543210	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:00:00.948985	SENT
10318	9876543211	No-Show Alert: hjuil has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:00:00.953229	SENT
10319	9876543211	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:00:00.95685	SENT
10320	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:00:00.960732	SENT
10321	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:00:00.964558	SENT
10322	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:00:00.969285	SENT
10323	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:00:00.972919	SENT
10324	9876543211	No-Show Alert: fghuyt has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:00:00.977074	SENT
10325	9876543211	No-Show Alert: yhgtred has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:00:00.981031	SENT
10326	9876543210	No-Show Alert: Vinod Reddy M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:10:00.751878	SENT
10327	9876543210	No-Show Alert: NAISS has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:10:00.756543	SENT
10328	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:10:00.759575	SENT
10329	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:10:00.763559	SENT
10330	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:10:00.765993	SENT
10331	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:10:00.768437	SENT
10332	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:10:00.770692	SENT
10333	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:10:00.772889	SENT
10334	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:10:00.77512	SENT
10335	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:10:00.777764	SENT
10336	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:10:00.780119	SENT
10337	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:10:00.782238	SENT
10338	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:10:00.785213	SENT
10339	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:10:00.787664	SENT
10340	9876543210	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:10:00.789779	SENT
10341	9876543211	No-Show Alert: hjuil has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:10:00.792105	SENT
10342	9876543211	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:10:00.794229	SENT
10343	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:10:00.796339	SENT
10344	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:10:00.798397	SENT
10345	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:10:00.801647	SENT
10346	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:10:00.804748	SENT
10347	9876543211	No-Show Alert: fghuyt has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:10:00.807797	SENT
10348	9876543211	No-Show Alert: yhgtred has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:10:00.810061	SENT
10349	9876543210	No-Show Alert: Vinod Reddy M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:20:00.604854	SENT
10350	9876543210	No-Show Alert: NAISS has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:20:00.611718	SENT
10351	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:20:00.615331	SENT
10352	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:20:00.619063	SENT
10353	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:20:00.622908	SENT
10354	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:20:00.626597	SENT
10355	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:20:00.63011	SENT
10356	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:20:00.634001	SENT
10357	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:20:00.637954	SENT
10358	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:20:00.641792	SENT
10359	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:20:00.646014	SENT
10360	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:20:00.650083	SENT
10361	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:20:00.656807	SENT
10362	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:20:00.662348	SENT
10363	9876543210	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:20:00.665731	SENT
10364	9876543211	No-Show Alert: hjuil has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:20:00.669441	SENT
10365	9876543211	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:20:00.67316	SENT
10366	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:20:00.676893	SENT
10367	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:20:00.680366	SENT
10368	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:20:00.684717	SENT
10369	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:20:00.689082	SENT
10370	9876543211	No-Show Alert: fghuyt has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:20:00.693237	SENT
10371	9876543211	No-Show Alert: yhgtred has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:20:00.697437	SENT
10372	9876543210	No-Show Alert: Vinod Reddy M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:30:00.450023	SENT
10373	9876543210	No-Show Alert: NAISS has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:30:00.456441	SENT
10374	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:30:00.46059	SENT
10375	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:30:00.464731	SENT
10376	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:30:00.469	SENT
10377	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:30:00.47317	SENT
10378	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:30:00.477188	SENT
10379	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:30:00.481273	SENT
10380	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:30:00.485915	SENT
10381	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:30:00.49057	SENT
10382	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:30:00.494713	SENT
10383	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:30:00.498672	SENT
10384	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:30:00.503027	SENT
10385	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:30:00.506515	SENT
10386	9876543210	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:30:00.510255	SENT
10387	9876543211	No-Show Alert: hjuil has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:30:00.514348	SENT
10388	9876543211	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:30:00.518462	SENT
10389	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:30:00.522776	SENT
10390	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:30:00.526268	SENT
10391	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:30:00.530748	SENT
10490	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:20:00.836468	SENT
10392	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:30:00.534731	SENT
10393	9876543211	No-Show Alert: fghuyt has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:30:00.538	SENT
10394	9876543211	No-Show Alert: yhgtred has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:30:00.541267	SENT
10395	9876543210	No-Show Alert: Vinod Reddy M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:40:00.385691	SENT
10396	9876543210	No-Show Alert: NAISS has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:40:00.393358	SENT
10397	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:40:00.397693	SENT
10398	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:40:00.401432	SENT
10399	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:40:00.405587	SENT
10400	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:40:00.409493	SENT
10401	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:40:00.41328	SENT
10402	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:40:00.417207	SENT
10403	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:40:00.421291	SENT
10404	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:40:00.425201	SENT
10405	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:40:00.429908	SENT
10406	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:40:00.433884	SENT
10407	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:40:00.437949	SENT
10408	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:40:00.441882	SENT
10409	9876543210	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:40:00.446053	SENT
10410	9876543211	No-Show Alert: hjuil has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:40:00.449975	SENT
10411	9876543211	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:40:00.455255	SENT
10412	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:40:00.459618	SENT
10413	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:40:00.46335	SENT
10414	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:40:00.466881	SENT
10415	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:40:00.470713	SENT
10416	9876543211	No-Show Alert: fghuyt has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:40:00.474498	SENT
10417	9876543211	No-Show Alert: yhgtred has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:40:00.478566	SENT
10418	9876543210	No-Show Alert: Vinod Reddy M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:50:00.525512	SENT
10419	9876543210	No-Show Alert: NAISS has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:50:00.535583	SENT
10420	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:50:00.542263	SENT
10421	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:50:00.546629	SENT
10422	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:50:00.550821	SENT
10423	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:50:00.554781	SENT
10424	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:50:00.55861	SENT
10425	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:50:00.562163	SENT
10426	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:50:00.565955	SENT
10427	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:50:00.570199	SENT
10428	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:50:00.574152	SENT
10429	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:50:00.577815	SENT
10430	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:50:00.581228	SENT
10431	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:50:00.585052	SENT
10432	9876543210	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:50:00.58924	SENT
10433	9876543211	No-Show Alert: hjuil has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:50:00.592693	SENT
10434	9876543211	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:50:00.596497	SENT
10435	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:50:00.600172	SENT
10436	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:50:00.603791	SENT
10437	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:50:00.607541	SENT
10438	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:50:00.61129	SENT
10439	9876543211	No-Show Alert: fghuyt has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:50:00.615013	SENT
10440	9876543211	No-Show Alert: yhgtred has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 14:50:00.619153	SENT
10441	9876543210	No-Show Alert: Vinod Reddy M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:00:00.542455	SENT
10442	9876543210	No-Show Alert: NAISS has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:00:00.54895	SENT
10443	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:00:00.552873	SENT
10444	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:00:00.556919	SENT
10445	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:00:00.561154	SENT
10446	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:00:00.564561	SENT
10447	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:00:00.568507	SENT
10448	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:00:00.572748	SENT
10449	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:00:00.576016	SENT
10450	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:00:00.579673	SENT
10451	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:00:00.583226	SENT
10452	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:00:00.5869	SENT
10453	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:00:00.59139	SENT
10454	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:00:00.594486	SENT
10455	9876543210	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:00:00.597894	SENT
10456	9876543211	No-Show Alert: hjuil has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:00:00.601353	SENT
10457	9876543211	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:00:00.605283	SENT
10458	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:00:00.608906	SENT
10459	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:00:00.612784	SENT
10460	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:00:00.616531	SENT
10461	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:00:00.620431	SENT
10462	9876543211	No-Show Alert: fghuyt has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:00:00.623829	SENT
10463	9876543211	No-Show Alert: yhgtred has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:00:00.627735	SENT
10464	9876543210	No-Show Alert: Vinod Reddy M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:10:00.037657	SENT
10465	9876543210	No-Show Alert: NAISS has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:10:00.041874	SENT
10466	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:10:00.04495	SENT
10467	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:10:00.049061	SENT
10468	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:10:00.051891	SENT
10469	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:10:00.054826	SENT
10470	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:10:00.058003	SENT
10471	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:10:00.061656	SENT
10472	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:10:00.065486	SENT
10473	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:10:00.069168	SENT
10474	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:10:00.073076	SENT
10475	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:10:00.076343	SENT
10476	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:10:00.07914	SENT
10477	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:10:00.083085	SENT
10478	9876543210	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:10:00.085841	SENT
10479	9876543211	No-Show Alert: hjuil has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:10:00.088895	SENT
10480	9876543211	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:10:00.091645	SENT
10481	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:10:00.094501	SENT
10482	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:10:00.09803	SENT
10483	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:10:00.101563	SENT
10484	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:10:00.104722	SENT
10485	9876543211	No-Show Alert: fghuyt has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:10:00.107926	SENT
10486	9876543211	No-Show Alert: yhgtred has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:10:00.111614	SENT
10487	9876543210	No-Show Alert: Vinod Reddy M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:20:00.823679	SENT
10488	9876543210	No-Show Alert: NAISS has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:20:00.828352	SENT
10489	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:20:00.832266	SENT
10491	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:20:00.840556	SENT
10492	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:20:00.847272	SENT
10493	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:20:00.852114	SENT
10494	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:20:00.856087	SENT
10495	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:20:00.859677	SENT
10496	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:20:00.865473	SENT
10497	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:20:00.870783	SENT
10498	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:20:00.875053	SENT
10499	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:20:00.879313	SENT
10500	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:20:00.883295	SENT
10501	9876543210	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:20:00.887402	SENT
10502	9876543211	No-Show Alert: hjuil has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:20:00.89158	SENT
10503	9876543211	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:20:00.895606	SENT
10504	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:20:00.89925	SENT
10505	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:20:00.903318	SENT
10506	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:20:00.906397	SENT
10507	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:20:00.909743	SENT
10508	9876543211	No-Show Alert: fghuyt has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:20:00.913413	SENT
10509	9876543211	No-Show Alert: yhgtred has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:20:00.917597	SENT
10510	9876543210	No-Show Alert: Vinod Reddy M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:30:00.788474	SENT
10511	9876543210	No-Show Alert: NAISS has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:30:00.79504	SENT
10512	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:30:00.799001	SENT
10513	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:30:00.803218	SENT
10514	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:30:00.807202	SENT
10515	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:30:00.811148	SENT
10516	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:30:00.814946	SENT
10517	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:30:00.819005	SENT
10518	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:30:00.822652	SENT
10519	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:30:00.826599	SENT
10520	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:30:00.830603	SENT
10521	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:30:00.83466	SENT
10522	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:30:00.838309	SENT
10523	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:30:00.842023	SENT
10524	9876543210	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:30:00.845969	SENT
10525	9876543211	No-Show Alert: hjuil has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:30:00.849169	SENT
10526	9876543211	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:30:00.853668	SENT
10527	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:30:00.858469	SENT
10528	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:30:00.862731	SENT
10529	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:30:00.866615	SENT
10530	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:30:00.870608	SENT
10531	9876543211	No-Show Alert: fghuyt has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:30:00.87423	SENT
10532	9876543211	No-Show Alert: yhgtred has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:30:00.87815	SENT
10533	9876543210	No-Show Alert: Vinod Reddy M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:40:00.469244	SENT
10534	9876543210	No-Show Alert: NAISS has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:40:00.473563	SENT
10535	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:40:00.476326	SENT
10536	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:40:00.478652	SENT
10537	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:40:00.480898	SENT
10538	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:40:00.48292	SENT
10539	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:40:00.485134	SENT
10540	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:40:00.487158	SENT
10541	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:40:00.489467	SENT
10542	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:40:00.491372	SENT
10543	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:40:00.493398	SENT
10544	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:40:00.495542	SENT
10545	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:40:00.497464	SENT
10546	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:40:00.499282	SENT
10547	9876543210	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:40:00.501115	SENT
10548	9876543211	No-Show Alert: hjuil has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:40:00.502952	SENT
10549	9876543211	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:40:00.505278	SENT
10550	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:40:00.507321	SENT
10551	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:40:00.509959	SENT
10552	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:40:00.512792	SENT
10553	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:40:00.515583	SENT
10554	9876543211	No-Show Alert: fghuyt has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:40:00.518625	SENT
10555	9876543211	No-Show Alert: yhgtred has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:40:00.521359	SENT
10556	9876543210	No-Show Alert: Vinod Reddy M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:50:00.229317	SENT
10557	9876543210	No-Show Alert: NAISS has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:50:00.23713	SENT
10558	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:50:00.241461	SENT
10559	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:50:00.245243	SENT
10560	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:50:00.249184	SENT
10561	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:50:00.252982	SENT
10562	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:50:00.25711	SENT
10563	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:50:00.260954	SENT
10564	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:50:00.264877	SENT
10565	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:50:00.268858	SENT
10566	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:50:00.273064	SENT
10567	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:50:00.276673	SENT
10568	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:50:00.282671	SENT
10569	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:50:00.287152	SENT
10570	9876543210	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:50:00.291436	SENT
10571	9876543211	No-Show Alert: hjuil has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:50:00.295212	SENT
10572	9876543211	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:50:00.299101	SENT
10573	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:50:00.303063	SENT
10574	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:50:00.306556	SENT
10575	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:50:00.310577	SENT
10576	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:50:00.314555	SENT
10577	9876543211	No-Show Alert: fghuyt has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:50:00.318469	SENT
10578	9876543211	No-Show Alert: yhgtred has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 15:50:00.322559	SENT
10579	9876543210	No-Show Alert: Vinod Reddy M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:00:00.833466	SENT
10580	9876543210	No-Show Alert: NAISS has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:00:00.84012	SENT
10581	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:00:00.844021	SENT
10582	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:00:00.848471	SENT
10583	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:00:00.852319	SENT
10584	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:00:00.856532	SENT
10585	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:00:00.860506	SENT
10586	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:00:00.86471	SENT
10587	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:00:00.868752	SENT
10588	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:00:00.873632	SENT
10589	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:00:00.877708	SENT
10590	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:00:00.881712	SENT
10591	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:00:00.885575	SENT
10592	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:00:00.888963	SENT
10593	9876543210	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:00:00.892635	SENT
10594	9876543211	No-Show Alert: hjuil has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:00:00.896531	SENT
10595	9876543211	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:00:00.900239	SENT
10596	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:00:00.904004	SENT
10597	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:00:00.907869	SENT
10598	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:00:00.911684	SENT
10599	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:00:00.916026	SENT
10600	9876543211	No-Show Alert: fghuyt has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:00:00.920072	SENT
10601	9876543211	No-Show Alert: yhgtred has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:00:00.924115	SENT
10602	9876543210	No-Show Alert: Vinod Reddy M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:10:00.660121	SENT
10603	9876543210	No-Show Alert: NAISS has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:10:00.667067	SENT
10604	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:10:00.67133	SENT
10605	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:10:00.675277	SENT
10606	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:10:00.679127	SENT
10607	9876543210	No-Show Alert: vin has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:10:00.68311	SENT
10608	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:10:00.686971	SENT
10609	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:10:00.690723	SENT
10610	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:10:00.694278	SENT
10611	9876543210	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:10:00.699389	SENT
10612	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:10:00.703509	SENT
10613	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:10:00.707316	SENT
10614	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:10:00.711032	SENT
10615	9876543210	No-Show Alert: vinod has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:10:00.714809	SENT
10616	9876543210	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:10:00.718868	SENT
10617	9876543211	No-Show Alert: hjuil has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:10:00.722455	SENT
10618	9876543211	No-Show Alert: hp has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:10:00.725832	SENT
10619	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:10:00.729783	SENT
10620	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:10:00.732854	SENT
10621	9876543211	No-Show Alert: Suresh YAdav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:10:00.73679	SENT
10622	9876543211	No-Show Alert: Suresh Yadav  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:10:00.74009	SENT
10623	9876543211	No-Show Alert: fghuyt has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:10:00.743918	SENT
10624	9876543211	No-Show Alert: yhgtred has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-02-28 16:10:00.747855	SENT
10625	9876543210	No-Show Alert: Vinod3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 18:40:00.310745	SENT
10626	9876543210	No-Show Alert: Vinod3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 18:50:00.923149	SENT
10627	9876543210	No-Show Alert: Vinod3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 19:00:00.527138	SENT
10628	9876543210	No-Show Alert: Vinod3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 19:10:00.316267	SENT
10629	9876543210	No-Show Alert: Vinod3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 19:20:00.822468	SENT
10630	9876543210	No-Show Alert: Vinod3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 19:30:00.570158	SENT
10631	9876543210	No-Show Alert: Vinod3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 19:40:00.568701	SENT
10632	9876543210	No-Show Alert: Vinod3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 19:50:00.320694	SENT
10633	9876543210	No-Show Alert: Vinod3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 20:00:00.123656	SENT
10634	9876543210	No-Show Alert: Vinod3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 20:10:00.067951	SENT
10635	9876543210	No-Show Alert: Vinod3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 20:20:00.132331	SENT
10636	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 21:50:00.977222	SENT
10637	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 21:50:00.98706	SENT
10638	9876543210	No-Show Alert: DIVYA3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 21:50:00.993577	SENT
10639	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 22:00:00.874688	SENT
10640	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 22:00:00.882038	SENT
10641	9876543210	No-Show Alert: DIVYA3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 22:00:00.887552	SENT
10642	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 22:10:00.410778	SENT
10643	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 22:10:00.420222	SENT
10644	9876543210	No-Show Alert: DIVYA3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 22:10:00.433537	SENT
10645	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 22:20:00.06731	SENT
10646	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 22:20:00.078083	SENT
10647	9876543210	No-Show Alert: DIVYA3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 22:20:00.085567	SENT
10648	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 22:30:00.819414	SENT
10649	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 22:30:00.823355	SENT
10650	9876543210	No-Show Alert: DIVYA3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 22:30:00.826652	SENT
10651	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 22:40:00.072826	SENT
10652	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 22:40:00.075721	SENT
10653	9876543210	No-Show Alert: DIVYA3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 22:40:00.078256	SENT
10654	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 22:50:00.314196	SENT
10655	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 22:50:00.318424	SENT
10656	9876543210	No-Show Alert: DIVYA3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 22:50:00.321358	SENT
10657	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 23:00:00.504075	SENT
10658	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 23:00:00.51401	SENT
10659	9876543210	No-Show Alert: DIVYA3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 23:00:00.522017	SENT
10660	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 23:10:00.696857	SENT
10661	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 23:10:00.703777	SENT
10662	9876543210	No-Show Alert: DIVYA3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 23:10:00.707419	SENT
10663	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 23:20:00.024749	SENT
10664	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-02 23:20:00.029521	SENT
10665	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 12:50:00.093365	SENT
10666	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 12:50:00.10437	SENT
10667	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 13:00:00.485906	SENT
10668	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 13:00:00.50607	SENT
10669	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 13:10:00.999726	SENT
10670	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 13:10:01.009995	SENT
10671	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 13:20:00.295226	SENT
10672	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 13:20:00.305527	SENT
10673	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 13:40:00.212867	SENT
10674	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 13:40:00.221278	SENT
10675	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 13:50:00.986176	SENT
10676	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 13:50:00.995728	SENT
10677	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 14:00:00.688041	SENT
10678	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 14:00:00.695516	SENT
10679	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 14:10:00.507789	SENT
10680	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 14:10:00.514675	SENT
10681	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 14:20:00.028669	SENT
10682	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 14:20:00.038162	SENT
10683	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 14:30:00.972015	SENT
10684	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 14:30:00.980109	SENT
10685	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 14:40:00.444723	SENT
10686	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 14:40:00.456677	SENT
10687	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 14:50:00.488485	SENT
10688	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 14:50:00.493507	SENT
10689	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 15:00:00.185116	SENT
10690	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 15:00:00.19585	SENT
10691	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 15:10:00.768417	SENT
10692	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 15:10:00.776652	SENT
10693	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 15:20:00.77099	SENT
10694	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 15:20:00.777434	SENT
10695	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 15:30:00.481308	SENT
10696	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 15:30:00.490298	SENT
10697	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 15:40:00.299879	SENT
10698	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 15:40:00.30783	SENT
10699	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 15:50:00.059468	SENT
10700	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 15:50:00.066017	SENT
10701	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 16:00:00.893609	SENT
10702	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 16:00:00.899194	SENT
10703	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 16:10:00.595588	SENT
10704	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 16:10:00.606744	SENT
10705	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 16:20:00.241894	SENT
10706	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 16:20:00.248582	SENT
10707	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 16:30:00.914452	SENT
10708	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 16:30:00.919923	SENT
10709	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 16:40:00.579264	SENT
10710	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 16:40:00.590415	SENT
10711	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 16:50:00.427634	SENT
10712	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 16:50:00.433554	SENT
10713	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 17:00:00.990295	SENT
10714	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 17:00:00.994707	SENT
10715	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 17:10:00.56516	SENT
10716	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 17:10:00.574744	SENT
10717	9876543210	No-Show Alert: DIVYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 17:20:00.030411	SENT
10718	9876543210	No-Show Alert: DIVYA2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 17:20:00.034729	SENT
10719	9876543211	No-Show Alert: MANOJ1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 19:30:00.412544	SENT
10720	9876543211	No-Show Alert: MANOJ2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 19:30:00.417527	SENT
10721	9876543211	No-Show Alert: MANOJ3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 19:30:00.420541	SENT
10722	9876543211	No-Show Alert: MANOJ4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 19:30:00.423641	SENT
10723	9876543211	No-Show Alert: MANOJ1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 19:40:00.88525	SENT
10724	9876543211	No-Show Alert: MANOJ2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 19:40:00.890434	SENT
10725	9876543211	No-Show Alert: MANOJ3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 19:40:00.89312	SENT
10726	9876543211	No-Show Alert: MANOJ4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 19:40:00.896423	SENT
10727	9876543210	No-Show Alert: PRIYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 19:40:00.903258	SENT
10728	9876543211	No-Show Alert: MANOJ1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 19:50:00.419734	SENT
10729	9876543211	No-Show Alert: MANOJ2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 19:50:00.430654	SENT
10730	9876543211	No-Show Alert: MANOJ3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 19:50:00.438076	SENT
10731	9876543211	No-Show Alert: MANOJ4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 19:50:00.44462	SENT
10732	9876543210	No-Show Alert: PRIYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 19:50:00.450568	SENT
10733	9876543211	No-Show Alert: MANOJ1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 20:00:00.05066	SENT
10734	9876543211	No-Show Alert: MANOJ2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 20:00:00.057242	SENT
10735	9876543211	No-Show Alert: MANOJ3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 20:00:00.060001	SENT
10736	9876543211	No-Show Alert: MANOJ4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 20:00:00.062397	SENT
10737	9876543210	No-Show Alert: PRIYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 20:00:00.065759	SENT
10738	9876543211	No-Show Alert: MANOJ1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 20:10:00.891727	SENT
10739	9876543211	No-Show Alert: MANOJ2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 20:10:00.90205	SENT
10740	9876543211	No-Show Alert: MANOJ3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 20:10:00.91024	SENT
10741	9876543211	No-Show Alert: MANOJ4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 20:10:00.918217	SENT
10742	9876543210	No-Show Alert: PRIYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 20:10:00.925319	SENT
10743	9876543211	No-Show Alert: MANOJ1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 20:20:00.878603	SENT
10744	9876543211	No-Show Alert: MANOJ2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 20:20:00.888904	SENT
10745	9876543211	No-Show Alert: MANOJ3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 20:20:00.897048	SENT
10746	9876543211	No-Show Alert: MANOJ4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 20:20:00.903406	SENT
10747	9876543210	No-Show Alert: PRIYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 20:20:00.908189	SENT
10748	9876543211	No-Show Alert: MANOJ1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 20:30:00.864186	SENT
10749	9876543211	No-Show Alert: MANOJ2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 20:30:00.871263	SENT
10750	9876543211	No-Show Alert: MANOJ3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 20:30:00.875138	SENT
10751	9876543211	No-Show Alert: MANOJ4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 20:30:00.880672	SENT
10752	9876543210	No-Show Alert: PRIYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 20:30:00.884702	SENT
10753	9876543211	No-Show Alert: MANOJ1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 20:40:00.786731	SENT
10754	9876543211	No-Show Alert: MANOJ2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 20:40:00.794395	SENT
10755	9876543211	No-Show Alert: MANOJ3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 20:40:00.797987	SENT
10756	9876543211	No-Show Alert: MANOJ4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 20:40:00.801371	SENT
10757	9876543210	No-Show Alert: PRIYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 20:40:00.804103	SENT
10758	9876543211	No-Show Alert: MANOJ1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 20:50:00.626508	SENT
10759	9876543211	No-Show Alert: MANOJ2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 20:50:00.634683	SENT
10760	9876543211	No-Show Alert: MANOJ3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 20:50:00.642405	SENT
10761	9876543211	No-Show Alert: MANOJ4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 20:50:00.649907	SENT
10762	9876543210	No-Show Alert: PRIYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 20:50:00.657338	SENT
10763	9876543211	No-Show Alert: MANOJ1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 21:00:00.548493	SENT
10764	9876543211	No-Show Alert: MANOJ2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 21:00:00.55861	SENT
10765	9876543211	No-Show Alert: MANOJ3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 21:00:00.565854	SENT
10766	9876543211	No-Show Alert: MANOJ4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 21:00:00.573189	SENT
10767	9876543210	No-Show Alert: PRIYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 21:00:00.580259	SENT
10768	9876543211	No-Show Alert: MANOJ1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 21:10:00.393285	SENT
10769	9876543211	No-Show Alert: MANOJ2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 21:10:00.401992	SENT
10770	9876543211	No-Show Alert: MANOJ3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 21:10:00.40828	SENT
10771	9876543211	No-Show Alert: MANOJ4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 21:10:00.414566	SENT
10772	9876543210	No-Show Alert: PRIYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 21:10:00.420862	SENT
10773	9876543211	No-Show Alert: MANOJ1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 21:20:00.156595	SENT
10774	9876543211	No-Show Alert: MANOJ2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 21:20:00.16715	SENT
10775	9876543211	No-Show Alert: MANOJ3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 21:20:00.173456	SENT
10776	9876543211	No-Show Alert: MANOJ4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 21:20:00.177139	SENT
10777	9876543210	No-Show Alert: PRIYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 21:20:00.183993	SENT
10778	9876543211	No-Show Alert: MANOJ1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 21:30:00.209737	SENT
10779	9876543211	No-Show Alert: MANOJ2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 21:30:00.216209	SENT
10780	9876543211	No-Show Alert: MANOJ3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 21:30:00.219989	SENT
10781	9876543211	No-Show Alert: MANOJ4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 21:30:00.223873	SENT
10782	9876543210	No-Show Alert: PRIYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 21:30:00.227332	SENT
10783	9876543211	No-Show Alert: MANOJ1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 21:40:00.556567	SENT
10784	9876543211	No-Show Alert: MANOJ2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 21:40:00.564779	SENT
10785	9876543211	No-Show Alert: MANOJ3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 21:40:00.572902	SENT
10786	9876543211	No-Show Alert: MANOJ4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 21:40:00.581338	SENT
10787	9876543210	No-Show Alert: PRIYA1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 21:40:00.588695	SENT
10788	9876543211	No-Show Alert: KIRAN1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 22:50:01.019162	SENT
10789	9876543211	No-Show Alert: KIRAN2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 22:50:01.027588	SENT
10790	9876543210	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 23:00:00.381246	SENT
10791	9876543211	No-Show Alert: KIRAN1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 23:00:00.387099	SENT
10792	9876543210	No-Show Alert: MN VINOD REDDY has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 23:00:00.394361	SENT
10793	9876543211	No-Show Alert: KIRAN2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 23:00:00.402205	SENT
10794	9876543210	No-Show Alert: REDDY has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 23:00:00.414057	SENT
10795	9876543210	No-Show Alert: VISITOR1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 23:10:00.529887	SENT
10796	9876543211	No-Show Alert: KIRAN1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 23:10:00.542614	SENT
10797	9876543210	No-Show Alert: MN VINOD REDDY has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 23:10:00.551545	SENT
10798	9876543210	No-Show Alert: PRANABH JANA has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 23:10:00.559933	SENT
10799	9876543210	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 23:10:00.567846	SENT
10800	9876543210	No-Show Alert: DEEPANKAR has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 23:10:00.575423	SENT
10801	9876543210	No-Show Alert: VIJAY KUMAR has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 23:10:00.583806	SENT
10802	9876543210	No-Show Alert: AMIT KUMAR has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 23:10:00.593604	SENT
10803	9876543210	No-Show Alert: JAY KUMAR has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 23:10:00.602845	SENT
10804	9876543211	No-Show Alert: KIRAN2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 23:10:00.611359	SENT
10805	9876543210	No-Show Alert: REDDY has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 23:10:00.622374	SENT
10806	9876543210	No-Show Alert: REEGAN AKISH has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-03 23:10:00.633274	SENT
10807	9876543212	No-Show Alert: LABOUR NO 5 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 13:40:00.157482	SENT
10808	9876543212	No-Show Alert: LABOUR NO 1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 13:40:00.168228	SENT
10809	9876543212	No-Show Alert: LABOUR NO 2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 13:40:00.176044	SENT
10810	9876543212	No-Show Alert: LABOUR NO 4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 13:40:00.181083	SENT
10811	9876543212	No-Show Alert: LABOUR NO 3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 13:40:00.184189	SENT
10812	9876543212	No-Show Alert: LABOUR NO 6 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 13:40:00.191384	SENT
10813	9876543212	No-Show Alert: LABOUR NO 5 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 13:50:00.392101	SENT
10814	9876543212	No-Show Alert: LABOUR NO 8 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 13:50:00.401263	SENT
10815	9876543212	No-Show Alert: LABOUR NO 7 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 13:50:00.407076	SENT
10816	9876543212	No-Show Alert: LABOUR NO 1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 13:50:00.412187	SENT
10817	9876543212	No-Show Alert: LABOUR NO 2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 13:50:00.419724	SENT
10818	9876543212	No-Show Alert: LABOUR NO 4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 13:50:00.425782	SENT
10819	9876543212	No-Show Alert: LABOUR NO 3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 13:50:00.430396	SENT
10820	9876543212	No-Show Alert: LABOUR NO 6 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 13:50:00.439208	SENT
10821	9876543212	No-Show Alert: VINOD REDDY MN  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:00:00.036766	SENT
10822	9876543212	No-Show Alert: LABOUR NO 5 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:00:00.042649	SENT
10823	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:00:00.048131	SENT
10824	9876543212	No-Show Alert: LABOUR NO 8 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:00:00.053494	SENT
10825	9876543212	No-Show Alert: LABOUR NO 7 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:00:00.057899	SENT
10826	9876543212	No-Show Alert: LABOUR NO 1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:00:00.061482	SENT
10827	9876543212	No-Show Alert: LABOUR NO 2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:00:00.066238	SENT
10828	9876543212	No-Show Alert: LABOUR NO 4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:00:00.072665	SENT
10829	9876543212	No-Show Alert: VINOD REDDY M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:00:00.078002	SENT
10830	9876543212	No-Show Alert: LABOUR NO 3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:00:00.083102	SENT
10831	9876543212	No-Show Alert: LABOUR NO 6 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:00:00.086737	SENT
10832	9876543212	No-Show Alert: LABOUR NO 1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:10:00.345359	SENT
10833	9876543212	No-Show Alert: LABOUR NO 2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:10:00.357647	SENT
10834	9876543212	No-Show Alert: LABOUR NO 3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:10:00.36602	SENT
10835	9876543212	No-Show Alert: LABOUR NO 4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:10:00.372149	SENT
10836	9876543212	No-Show Alert: LABOUR NO 5 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:10:00.379829	SENT
10837	9876543212	No-Show Alert: LABOUR NO 6 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:10:00.387621	SENT
10838	9876543212	No-Show Alert: LABOUR NO 7 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:10:00.394076	SENT
10839	9876543212	No-Show Alert: LABOUR NO 8 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:10:00.401326	SENT
10840	9876543212	No-Show Alert: VINOD REDDY MN  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:10:00.408509	SENT
10841	9876543212	No-Show Alert: VINOD REDDY M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:10:00.414124	SENT
10842	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:10:00.419777	SENT
10843	9876543212	No-Show Alert: VINOD M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:10:00.422933	SENT
10844	9876543212	No-Show Alert: LABOUR NO 1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:20:00.722541	SENT
10845	9876543212	No-Show Alert: LABOUR NO 2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:20:00.728237	SENT
10846	9876543212	No-Show Alert: LABOUR NO 3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:20:00.731907	SENT
10847	9876543212	No-Show Alert: LABOUR NO 4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:20:00.735394	SENT
10848	9876543212	No-Show Alert: LABOUR NO 5 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:20:00.738859	SENT
10849	9876543212	No-Show Alert: LABOUR NO 6 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:20:00.743389	SENT
10850	9876543212	No-Show Alert: LABOUR NO 7 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:20:00.747795	SENT
10851	9876543212	No-Show Alert: LABOUR NO 8 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:20:00.751978	SENT
10852	9876543212	No-Show Alert: VINOD REDDY MN  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:20:00.755429	SENT
10853	9876543212	No-Show Alert: VINOD REDDY M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:20:00.759346	SENT
10854	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:20:00.763439	SENT
10855	9876543212	No-Show Alert: VINOD M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:20:00.766879	SENT
10856	9876543212	No-Show Alert: VINOD M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:20:00.770026	SENT
10857	9876543212	No-Show Alert: VINOD REDDY M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:20:00.773194	SENT
10858	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:20:00.778206	SENT
10859	9876543212	No-Show Alert: LABOUR NO 1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:30:01.021307	SENT
10860	9876543212	No-Show Alert: LABOUR NO 2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:30:01.028409	SENT
10861	9876543212	No-Show Alert: LABOUR NO 3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:30:01.034821	SENT
10862	9876543212	No-Show Alert: LABOUR NO 4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:30:01.039043	SENT
10863	9876543212	No-Show Alert: LABOUR NO 5 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:30:01.042102	SENT
10864	9876543212	No-Show Alert: LABOUR NO 6 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:30:01.046416	SENT
10865	9876543212	No-Show Alert: LABOUR NO 7 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:30:01.053889	SENT
10866	9876543212	No-Show Alert: LABOUR NO 8 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:30:01.060975	SENT
10867	9876543212	No-Show Alert: VINOD REDDY MN  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:30:01.066476	SENT
10868	9876543212	No-Show Alert: VINOD REDDY M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:30:01.072668	SENT
10869	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:30:01.077778	SENT
10870	9876543212	No-Show Alert: VINOD M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:30:01.083586	SENT
10871	9876543212	No-Show Alert: VINOD M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:30:01.091616	SENT
10872	9876543212	No-Show Alert: VINOD REDDY M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:30:01.097549	SENT
10873	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:30:01.103169	SENT
10874	9876543212	No-Show Alert: VINOD M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:30:01.110329	SENT
10875	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:30:01.115763	SENT
10876	9876543212	No-Show Alert: LABOUR NO 1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:40:00.767384	SENT
10877	9876543212	No-Show Alert: LABOUR NO 2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:40:00.777847	SENT
10878	9876543212	No-Show Alert: LABOUR NO 3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:40:00.78362	SENT
10879	9876543212	No-Show Alert: LABOUR NO 4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:40:00.790522	SENT
10880	9876543212	No-Show Alert: LABOUR NO 5 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:40:00.797618	SENT
10881	9876543212	No-Show Alert: LABOUR NO 6 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:40:00.806368	SENT
10882	9876543212	No-Show Alert: LABOUR NO 7 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:40:00.814672	SENT
10883	9876543212	No-Show Alert: LABOUR NO 8 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:40:00.82235	SENT
10884	9876543212	No-Show Alert: VINOD REDDY MN  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:40:00.829254	SENT
10885	9876543212	No-Show Alert: VINOD REDDY M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:40:00.834701	SENT
10886	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:40:00.843501	SENT
10887	9876543212	No-Show Alert: VINOD M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:40:00.848239	SENT
10888	9876543212	No-Show Alert: VINOD M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:40:00.852706	SENT
10889	9876543212	No-Show Alert: VINOD REDDY M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:40:00.856739	SENT
10890	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:40:00.859711	SENT
10891	9876543212	No-Show Alert: VINOD M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:40:00.863993	SENT
10892	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:40:00.869919	SENT
10893	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:40:00.874186	SENT
10894	9876543212	No-Show Alert: LABOUR NO 1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:50:00.078012	SENT
10895	9876543212	No-Show Alert: LABOUR NO 2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:50:00.08868	SENT
10896	9876543212	No-Show Alert: LABOUR NO 3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:50:00.096448	SENT
10897	9876543212	No-Show Alert: LABOUR NO 4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:50:00.102617	SENT
10898	9876543212	No-Show Alert: LABOUR NO 5 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:50:00.109846	SENT
10899	9876543212	No-Show Alert: LABOUR NO 6 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:50:00.116808	SENT
10900	9876543212	No-Show Alert: LABOUR NO 7 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:50:00.124109	SENT
10901	9876543212	No-Show Alert: LABOUR NO 8 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:50:00.131458	SENT
10902	9876543212	No-Show Alert: VINOD REDDY MN  has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:50:00.13814	SENT
10903	9876543212	No-Show Alert: VINOD REDDY M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:50:00.14575	SENT
10904	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:50:00.153424	SENT
10905	9876543212	No-Show Alert: VINOD M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:50:00.160278	SENT
10906	9876543212	No-Show Alert: VINOD M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:50:00.166525	SENT
10907	9876543212	No-Show Alert: VINOD REDDY M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:50:00.172816	SENT
10908	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:50:00.177329	SENT
10909	9876543212	No-Show Alert: VINOD M N has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:50:00.180658	SENT
10910	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:50:00.184438	SENT
10911	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:50:00.189711	SENT
10912	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:50:00.193991	SENT
10913	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:50:00.197328	SENT
10914	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:50:00.200093	SENT
10915	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 14:50:00.204457	SENT
10916	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:10:00.233618	SENT
10917	9876543212	No-Show Alert: LABOUR NO 10 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:20:00.358446	SENT
10918	9876543212	No-Show Alert: LABOUR NO 6 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:20:00.36669	SENT
10919	9876543212	No-Show Alert: LABOUR NO 9 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:20:00.371867	SENT
10920	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:20:00.380464	SENT
10921	9876543212	No-Show Alert: LABOUR NO 1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:20:00.388028	SENT
10922	9876543212	No-Show Alert: LABOUR NO 2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:20:00.395439	SENT
10923	9876543212	No-Show Alert: LABOUR NO 3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:20:00.402406	SENT
10924	9876543212	No-Show Alert: VINO has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:20:00.407115	SENT
10925	9876543212	No-Show Alert: LABOUR NO 5 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:20:00.411383	SENT
10926	9876543212	No-Show Alert: LABOUR NO 8 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:20:00.418816	SENT
10927	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:20:00.425856	SENT
10928	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:20:00.432125	SENT
10929	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:20:00.439143	SENT
10930	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:20:00.444485	SENT
10931	9876543212	No-Show Alert: LABOUR NO 4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:20:00.447224	SENT
10932	9876543212	No-Show Alert: LABOUR NO 7 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:20:00.454458	SENT
10933	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:30:00.722216	SENT
10934	9876543212	No-Show Alert: LABOUR NO 10 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:30:00.728767	SENT
10935	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:30:00.733262	SENT
10936	9876543212	No-Show Alert: LABOUR NO 6 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:30:00.73638	SENT
10937	9876543212	No-Show Alert: LABOUR NO 9 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:30:00.740622	SENT
10938	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:30:00.745199	SENT
10939	9876543212	No-Show Alert: LABOUR NO 1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:30:00.748241	SENT
10940	9876543212	No-Show Alert: LABOUR NO 2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:30:00.750662	SENT
10941	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:30:00.753108	SENT
10942	9876543212	No-Show Alert: LABOUR NO 3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:30:00.755461	SENT
10943	9876543212	No-Show Alert: VINO has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:30:00.758017	SENT
10944	9876543212	No-Show Alert: LABOUR NO 5 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:30:00.76426	SENT
10945	9876543212	No-Show Alert: LABOUR NO 8 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:30:00.769421	SENT
10946	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:30:00.77398	SENT
10947	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:30:00.778248	SENT
10948	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:30:00.78194	SENT
10949	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:30:00.78588	SENT
10950	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:30:00.789068	SENT
10951	9876543212	No-Show Alert: LABOUR NO 4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:30:00.793396	SENT
10952	9876543212	No-Show Alert: LABOUR NO 7 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:30:00.799718	SENT
10953	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:00.941025	SENT
10954	9876543212	No-Show Alert: LABOUR NO 10 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:00.950347	SENT
10955	9876543212	No-Show Alert: LABOUR NO 10 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:00.954748	SENT
10956	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:00.962052	SENT
10957	9876543212	No-Show Alert: LABOUR NO 6 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:00.968997	SENT
10958	9876543212	No-Show Alert: LABOUR NO 1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:00.974571	SENT
10959	9876543212	No-Show Alert: LABOUR NO 9 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:00.97822	SENT
10960	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:00.98188	SENT
10961	9876543212	No-Show Alert: LABOUR NO 2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:00.985234	SENT
10962	9876543212	No-Show Alert: LABOUR NO 1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:00.988671	SENT
10963	9876543212	No-Show Alert: LABOUR NO 5 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:00.994019	SENT
10964	9876543212	No-Show Alert: LABOUR NO 8 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:01.000549	SENT
10965	9876543212	No-Show Alert: LABOUR NO 2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:01.005619	SENT
10966	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:01.00958	SENT
10967	9876543212	No-Show Alert: LABOUR NO 11 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:01.012451	SENT
10968	9876543212	No-Show Alert: LABOUR NO 4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:01.018499	SENT
10969	9876543212	No-Show Alert: LABOUR NO 3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:01.026343	SENT
10970	9876543212	No-Show Alert: VINO has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:01.03348	SENT
10971	9876543212	No-Show Alert: LABOUR NO 5 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:01.038504	SENT
10972	9876543212	No-Show Alert: LABOUR NO 9 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:01.044413	SENT
10973	9876543212	No-Show Alert: LABOUR NO 8 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:01.048864	SENT
10974	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:01.05228	SENT
10975	9876543212	No-Show Alert: LABOUR NO 7 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:01.054996	SENT
10976	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:01.059058	SENT
10977	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:01.063289	SENT
10978	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:01.067816	SENT
10979	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:01.07133	SENT
10980	9876543212	No-Show Alert: LABOUR NO 6 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:01.07661	SENT
10981	9876543212	No-Show Alert: LABOUR NO 4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:01.086022	SENT
10982	9876543212	No-Show Alert: LABOUR NO 3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:01.092568	SENT
10983	9876543212	No-Show Alert: LABOUR NO 7 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:40:01.097024	SENT
10984	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:00.951302	SENT
10985	9876543212	No-Show Alert: LABOUR NO 10 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:00.957439	SENT
10986	9876543212	No-Show Alert: LABOUR NO 10 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:00.961196	SENT
10987	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:00.964252	SENT
10988	9876543212	No-Show Alert: LABOUR NO 6 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:00.967231	SENT
10989	9876543212	No-Show Alert: LABOUR NO 1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:00.974114	SENT
10990	9876543212	No-Show Alert: LABOUR NO 9 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:00.98069	SENT
10991	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:00.985608	SENT
10992	9876543212	No-Show Alert: LABOUR NO 2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:00.992893	SENT
10993	9876543212	No-Show Alert: LABOUR NO 1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:00.999457	SENT
10994	9876543212	No-Show Alert: LABOUR NO 5 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:01.006438	SENT
10995	9876543212	No-Show Alert: LABOUR NO 8 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:01.012164	SENT
10996	9876543212	No-Show Alert: LABOUR NO 2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:01.019898	SENT
10997	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:01.02572	SENT
10998	9876543212	No-Show Alert: LABOUR NO 11 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:01.032857	SENT
10999	9876543212	No-Show Alert: LABOUR NO 4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:01.040679	SENT
11000	9876543212	No-Show Alert: LABOUR NO 3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:01.047381	SENT
11001	9876543212	No-Show Alert: VINO has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:01.05288	SENT
11002	9876543212	No-Show Alert: LABOUR NO 5 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:01.060311	SENT
11003	9876543212	No-Show Alert: LABOUR NO 9 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:01.065203	SENT
11004	9876543212	No-Show Alert: LABOUR NO 8 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:01.069299	SENT
11005	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:01.072612	SENT
11006	9876543212	No-Show Alert: LABOUR NO 7 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:01.075362	SENT
11007	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:01.078259	SENT
11008	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:01.081044	SENT
11009	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:01.084276	SENT
11010	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:01.088171	SENT
11011	9876543212	No-Show Alert: LABOUR NO 6 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:01.090901	SENT
11012	9876543212	No-Show Alert: LABOUR NO 4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:01.097621	SENT
11013	9876543212	No-Show Alert: LABOUR NO 3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:01.101203	SENT
11014	9876543212	No-Show Alert: LABOUR NO 7 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 16:50:01.106116	SENT
11015	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.501234	SENT
11016	9876543212	No-Show Alert: LABOUR NO 10 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.506958	SENT
11017	9876543212	No-Show Alert: LABOUR NO 10 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.514831	SENT
11018	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.518468	SENT
11019	9876543212	No-Show Alert: LABOUR NO 6 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.522291	SENT
11020	9876543212	No-Show Alert: LABOUR NO 1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.527147	SENT
11021	9876543212	No-Show Alert: LABOUR NO 9 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.5304	SENT
11022	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.532945	SENT
11023	9876543212	No-Show Alert: LABOUR NO 2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.535358	SENT
11024	9876543212	No-Show Alert: LABOUR NO 1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.537746	SENT
11025	9876543212	No-Show Alert: LABOUR NO 5 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.541049	SENT
11026	9876543212	No-Show Alert: LABOUR NO 8 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.543888	SENT
11027	9876543212	No-Show Alert: LABOUR NO 2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.548842	SENT
11028	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.551284	SENT
11029	9876543212	No-Show Alert: LABOUR NO 11 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.553667	SENT
11030	9876543212	No-Show Alert: LABOUR NO 4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.556446	SENT
11031	9876543212	No-Show Alert: LABOUR NO 3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.559188	SENT
11032	9876543212	No-Show Alert: VINO has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.56502	SENT
11033	9876543212	No-Show Alert: LABOUR NO 5 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.567526	SENT
11034	9876543212	No-Show Alert: LABOUR NO 9 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.570007	SENT
11035	9876543212	No-Show Alert: LABOUR NO 8 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.572676	SENT
11036	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.57525	SENT
11037	9876543212	No-Show Alert: LABOUR NO 7 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.577887	SENT
11038	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.580837	SENT
11039	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.584064	SENT
11040	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.587295	SENT
11041	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.590069	SENT
11042	9876543212	No-Show Alert: LABOUR NO 6 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.592957	SENT
11043	9876543212	No-Show Alert: LABOUR NO 4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.59622	SENT
11044	9876543212	No-Show Alert: LABOUR NO 3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.602113	SENT
11045	9876543212	No-Show Alert: LABOUR NO 7 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:00:00.606983	SENT
11046	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.660756	SENT
11047	9876543212	No-Show Alert: LABOUR NO 10 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.667876	SENT
11048	9876543212	No-Show Alert: LABOUR NO 10 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.6715	SENT
11049	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.675422	SENT
11050	9876543212	No-Show Alert: LABOUR NO 6 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.678451	SENT
11051	9876543212	No-Show Alert: LABOUR NO 1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.682099	SENT
11052	9876543212	No-Show Alert: LABOUR NO 9 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.685537	SENT
11053	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.689096	SENT
11054	9876543212	No-Show Alert: LABOUR NO 2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.695651	SENT
11055	9876543212	No-Show Alert: LABOUR NO 1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.702267	SENT
11056	9876543212	No-Show Alert: LABOUR NO 5 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.705043	SENT
11057	9876543212	No-Show Alert: LABOUR NO 8 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.711228	SENT
11058	9876543212	No-Show Alert: LABOUR NO 2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.715825	SENT
11059	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.720312	SENT
11060	9876543212	No-Show Alert: LABOUR NO 11 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.724758	SENT
11061	9876543212	No-Show Alert: LABOUR NO 4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.727794	SENT
11062	9876543212	No-Show Alert: LABOUR NO 3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.734905	SENT
11063	9876543212	No-Show Alert: VINO has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.741952	SENT
11064	9876543212	No-Show Alert: LABOUR NO 5 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.747104	SENT
11065	9876543212	No-Show Alert: LABOUR NO 9 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.750616	SENT
11066	9876543212	No-Show Alert: LABOUR NO 8 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.753533	SENT
11067	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.756237	SENT
11068	9876543212	No-Show Alert: LABOUR NO 7 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.76346	SENT
11069	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.769115	SENT
11070	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.774114	SENT
11071	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.78091	SENT
11072	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.78755	SENT
11073	9876543212	No-Show Alert: LABOUR NO 6 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.794637	SENT
11074	9876543212	No-Show Alert: LABOUR NO 4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.799328	SENT
11075	9876543212	No-Show Alert: LABOUR NO 3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.803437	SENT
11076	9876543212	No-Show Alert: LABOUR NO 7 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:10:00.810194	SENT
11077	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:00.834204	SENT
11078	9876543212	No-Show Alert: LABOUR NO 10 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:00.841777	SENT
11079	9876543212	No-Show Alert: LABOUR NO 10 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:00.846229	SENT
11080	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:00.849639	SENT
11081	9876543212	No-Show Alert: LABOUR NO 6 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:00.852536	SENT
11082	9876543212	No-Show Alert: LABOUR NO 1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:00.856023	SENT
11083	9876543212	No-Show Alert: LABOUR NO 9 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:00.862966	SENT
11084	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:00.87056	SENT
11085	9876543212	No-Show Alert: LABOUR NO 2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:00.87805	SENT
11086	9876543212	No-Show Alert: LABOUR NO 1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:00.882103	SENT
11087	9876543212	No-Show Alert: LABOUR NO 5 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:00.887157	SENT
11088	9876543212	No-Show Alert: LABOUR NO 8 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:00.893036	SENT
11089	9876543212	No-Show Alert: LABOUR NO 2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:00.899564	SENT
11090	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:00.902703	SENT
11091	9876543212	No-Show Alert: LABOUR NO 11 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:00.90814	SENT
11092	9876543212	No-Show Alert: LABOUR NO 4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:00.915324	SENT
11093	9876543212	No-Show Alert: LABOUR NO 3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:00.922922	SENT
11094	9876543212	No-Show Alert: VINO has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:00.929064	SENT
11095	9876543212	No-Show Alert: LABOUR NO 5 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:00.936379	SENT
11096	9876543212	No-Show Alert: LABOUR NO 9 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:00.943931	SENT
11097	9876543212	No-Show Alert: LABOUR NO 8 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:00.950592	SENT
11098	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:00.956218	SENT
11099	9876543212	No-Show Alert: LABOUR NO 7 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:00.961152	SENT
11100	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:00.967996	SENT
11101	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:00.972571	SENT
11102	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:00.975887	SENT
11103	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:00.981977	SENT
11104	9876543212	No-Show Alert: LABOUR NO 6 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:00.988649	SENT
11105	9876543212	No-Show Alert: LABOUR NO 4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:00.994835	SENT
11106	9876543212	No-Show Alert: LABOUR NO 3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:01.000771	SENT
11107	9876543212	No-Show Alert: LABOUR NO 7 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:20:01.005729	SENT
11108	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.511512	SENT
11109	9876543212	No-Show Alert: LABOUR NO 10 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.519363	SENT
11110	9876543212	No-Show Alert: LABOUR NO 10 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.526181	SENT
11111	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.53353	SENT
11112	9876543212	No-Show Alert: LABOUR NO 6 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.541685	SENT
11113	9876543212	No-Show Alert: LABOUR NO 1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.54593	SENT
11114	9876543212	No-Show Alert: LABOUR NO 9 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.551917	SENT
11115	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.556481	SENT
11116	9876543212	No-Show Alert: LABOUR NO 2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.560082	SENT
11117	9876543212	No-Show Alert: LABOUR NO 1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.564439	SENT
11118	9876543212	No-Show Alert: LABOUR NO 5 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.567235	SENT
11119	9876543212	No-Show Alert: LABOUR NO 8 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.569831	SENT
11120	9876543212	No-Show Alert: LABOUR NO 2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.572527	SENT
11121	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.575364	SENT
11122	9876543212	No-Show Alert: LABOUR NO 11 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.582233	SENT
11123	9876543212	No-Show Alert: LABOUR NO 4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.587983	SENT
11124	9876543212	No-Show Alert: LABOUR NO 3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.596492	SENT
11125	9876543212	No-Show Alert: VINO has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.600394	SENT
11126	9876543212	No-Show Alert: LABOUR NO 5 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.605721	SENT
11127	9876543212	No-Show Alert: LABOUR NO 9 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.609614	SENT
11128	9876543212	No-Show Alert: LABOUR NO 8 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.614938	SENT
11129	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.618971	SENT
11130	9876543212	No-Show Alert: LABOUR NO 7 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.622305	SENT
11131	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.625508	SENT
11132	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.630552	SENT
11133	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.634133	SENT
11134	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.63691	SENT
11135	9876543212	No-Show Alert: LABOUR NO 6 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.639659	SENT
11136	9876543212	No-Show Alert: LABOUR NO 4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.643383	SENT
11137	9876543212	No-Show Alert: LABOUR NO 3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.647717	SENT
11138	9876543212	No-Show Alert: LABOUR NO 7 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:30:00.650698	SENT
11139	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.172674	SENT
11140	9876543212	No-Show Alert: LABOUR NO 10 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.178591	SENT
11141	9876543212	No-Show Alert: LABOUR NO 10 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.18374	SENT
11142	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.188875	SENT
11143	9876543212	No-Show Alert: LABOUR NO 6 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.192124	SENT
11144	9876543212	No-Show Alert: LABOUR NO 1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.195664	SENT
11145	9876543212	No-Show Alert: LABOUR NO 9 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.198839	SENT
11146	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.201761	SENT
11147	9876543212	No-Show Alert: LABOUR NO 2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.208325	SENT
11148	9876543212	No-Show Alert: LABOUR NO 1 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.211976	SENT
11149	9876543212	No-Show Alert: LABOUR NO 5 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.216301	SENT
11150	9876543212	No-Show Alert: LABOUR NO 8 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.219387	SENT
11151	9876543212	No-Show Alert: LABOUR NO 2 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.222581	SENT
11152	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.225715	SENT
11153	9876543212	No-Show Alert: LABOUR NO 11 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.229345	SENT
11154	9876543212	No-Show Alert: LABOUR NO 4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.232215	SENT
11155	9876543212	No-Show Alert: LABOUR NO 3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.235232	SENT
11156	9876543212	No-Show Alert: VINO has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.239563	SENT
11157	9876543212	No-Show Alert: LABOUR NO 5 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.244373	SENT
11158	9876543212	No-Show Alert: LABOUR NO 9 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.247629	SENT
11159	9876543212	No-Show Alert: LABOUR NO 8 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.250459	SENT
11160	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.253265	SENT
11161	9876543212	No-Show Alert: LABOUR NO 7 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.256251	SENT
11162	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.259907	SENT
11163	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.26321	SENT
11164	9876543212	No-Show Alert: VIN has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.266348	SENT
11165	9876543212	No-Show Alert: VINOD has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.269254	SENT
11166	9876543212	No-Show Alert: LABOUR NO 6 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.272117	SENT
11167	9876543212	No-Show Alert: LABOUR NO 4 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.276562	SENT
11168	9876543212	No-Show Alert: LABOUR NO 3 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.280873	SENT
11169	9876543212	No-Show Alert: LABOUR NO 7 has not entered the facility within 60 minutes of manifest printing.	NO_SHOW_ALERT	\N	2026-03-04 17:40:00.283527	SENT
\.


--
-- TOC entry 5412 (class 0 OID 17514)
-- Dependencies: 266
-- Data for Name: sync_queue; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.sync_queue (id, gate_id, payload, created_at, synced) FROM stdin;
\.


--
-- TOC entry 5369 (class 0 OID 17113)
-- Dependencies: 222
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.users (id, username, password_hash, full_name, phone, role_id, is_active, created_at) FROM stdin;
2	security_head	$2b$10$27KskdK.1kMAhAC5YuZoEeIPyYc6xsndt5jc3Ij756OFFLytkKbTm	Security Head	9888888888	2	t	2026-02-23 00:16:02.150516
3	enrollment	$2b$10$QFORAL9V8MAQ0Hf7y6txo.gJa2pX1wmUcy5cbMzd61qLu7MeG3XF.	Enrollment Staff	9777777777	3	t	2026-02-23 00:16:02.150516
6	vinodreddymn	$2b$10$9MERJTG8Ajn0XAeF.zz1tOcTNmxiij4ZUI6DBSGwtxHN6UYUvyne6	Vinod Reddy M N	1234567890	1	t	2026-02-26 15:47:58.998054
5	vinod	india123	Vinod Reddy	1234567890	3	t	2026-02-26 15:32:52.149931
1	admin	$2b$10$c4xso0h5xcOSSYTCx/IWjebRGyz2Fn40uNQcdD.qbH2czB8.AlQq6	Admin User	9999999999	1	t	2026-02-23 00:16:02.150516
\.


--
-- TOC entry 5385 (class 0 OID 17270)
-- Dependencies: 238
-- Data for Name: visitor_documents; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.visitor_documents (id, visitor_id, doc_type, doc_number, expiry_date, file_path, uploaded_at) FROM stdin;
2002	1003	OTHER	123456789012	2026-02-28	uploads\\1afbb7f3a1c4737e6ce363ca74775755	2026-02-24 19:10:57.247958
2003	1012	AADHAAR	123456789012	2026-10-29	uploads\\0f44755a734aaa351ac65427974ef0b0	2026-02-27 19:17:04.791792
2004	1013	AADHAAR	123456789012	2026-05-28	uploads\\3c654434987784d08e900f7b296bd19f	2026-02-27 23:48:07.094298
2006	1116	AADHAAR	123412341234	2026-03-31	uploads/visitors/1116/documents/document_1772799119251_948144296.pdf	2026-03-06 17:41:59.265314
2007	1115	COMPANY_ID	1234	2026-05-09	uploads/visitors/1115/documents/document_1772983960367_573805583.pdf	2026-03-08 21:02:40.379181
\.


--
-- TOC entry 5425 (class 0 OID 17665)
-- Dependencies: 279
-- Data for Name: visitor_gate_permissions; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.visitor_gate_permissions (id, visitor_id, gate_id, valid_from, valid_to, created_at) FROM stdin;
1	1117	2	2026-03-07	2026-03-31	2026-03-07 23:55:01.523953
2	1117	3	2026-03-07	2026-03-31	2026-03-07 23:55:01.523953
\.


--
-- TOC entry 5417 (class 0 OID 17557)
-- Dependencies: 271
-- Data for Name: visitor_status_audit; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.visitor_status_audit (id, visitor_id, old_status, new_status, changed_by, reason, changed_at) FROM stdin;
1	1003	ACTIVE	ACTIVE	1	Manual status update	2026-02-24 19:12:28.19549
2	1009	ACTIVE	ACTIVE	1	Manual status update	2026-02-24 19:12:50.948385
3	1009	ACTIVE	ACTIVE	1	Manual status update	2026-02-26 14:37:22.270703
4	1012	ACTIVE	ACTIVE	1	Manual status update	2026-02-27 19:24:18.260879
5	1012	ACTIVE	ACTIVE	1	Manual status update	2026-02-27 19:26:12.295517
6	1012	ACTIVE	ACTIVE	1	Manual status update	2026-02-27 19:26:47.623625
7	1013	ACTIVE	ACTIVE	1	Manual status update	2026-02-28 22:39:52.671963
8	1013	ACTIVE	ACTIVE	1	Manual status update	2026-02-28 22:40:29.078263
9	1006	ACTIVE	ACTIVE	6	Manual status update	2026-03-02 22:50:44.910942
10	1013	ACTIVE	ACTIVE	6	Manual status update	2026-03-02 22:51:46.476636
11	1012	ACTIVE	ACTIVE	1	Manual status update	2026-03-03 22:18:32.311317
12	1012	ACTIVE	ACTIVE	1	Manual status update	2026-03-03 22:18:48.022998
13	1012	ACTIVE	ACTIVE	1	Manual status update	2026-03-03 22:21:19.920691
14	1012	ACTIVE	ACTIVE	1	Manual status update	2026-03-03 22:22:20.36522
15	1012	ACTIVE	ACTIVE	1	Manual status update	2026-03-03 22:24:13.21374
16	1012	ACTIVE	ACTIVE	1	Manual status update	2026-03-03 22:24:42.93288
17	1012	ACTIVE	ACTIVE	1	Manual status update	2026-03-03 22:26:13.19488
18	1012	ACTIVE	ACTIVE	1	Manual status update	2026-03-03 22:32:37.273432
19	1012	ACTIVE	ACTIVE	1	Manual status update	2026-03-03 22:38:11.540145
20	1012	ACTIVE	ACTIVE	1	Manual status update	2026-03-03 22:41:01.968205
21	1012	ACTIVE	ACTIVE	1	Manual status update	2026-03-03 22:44:32.17238
22	1012	ACTIVE	ACTIVE	1	Manual status update	2026-03-03 22:49:22.662806
23	1012	ACTIVE	ACTIVE	1	Manual status update	2026-03-03 22:57:55.239562
24	1012	ACTIVE	ACTIVE	1	Manual status update	2026-03-03 22:58:33.063152
25	1012	ACTIVE	ACTIVE	1	Manual status update	2026-03-03 23:00:47.445167
26	1012	ACTIVE	ACTIVE	1	Manual status update	2026-03-03 23:03:49.592019
27	1012	ACTIVE	ACTIVE	1	Manual status update	2026-03-04 12:28:50.541132
28	1012	ACTIVE	ACTIVE	1	Manual status update	2026-03-04 18:32:31.803919
29	1013	ACTIVE	ACTIVE	1	Manual status update	2026-03-04 19:19:44.026486
30	1011	ACTIVE	ACTIVE	6	Manual status update	2026-03-06 17:23:25.839995
31	1116	ACTIVE	ACTIVE	6	Manual status update	2026-03-07 16:01:22.932318
32	1116	ACTIVE	ACTIVE	6	Manual status update	2026-03-07 16:23:22.386146
33	1116	ACTIVE	ACTIVE	6	Manual status update	2026-03-07 20:42:25.063423
34	1101	ACTIVE	ACTIVE	6	Manual status update	2026-03-07 22:43:32.857541
35	1101	ACTIVE	ACTIVE	6	Manual status update	2026-03-07 22:45:27.204043
36	1101	ACTIVE	ACTIVE	6	Manual status update	2026-03-07 23:00:19.948548
37	1101	ACTIVE	ACTIVE	6	Manual status update	2026-03-07 23:01:00.857871
38	1117	ACTIVE	ACTIVE	6	Manual status update	2026-03-08 10:36:25.919762
39	1117	ACTIVE	ACTIVE	6	Manual status update	2026-03-08 10:46:32.440744
40	1116	ACTIVE	ACTIVE	6	Manual status update	2026-03-08 11:10:51.912598
41	1046	ACTIVE	ACTIVE	6	Manual status update	2026-03-08 12:15:46.419376
42	1046	ACTIVE	ACTIVE	6	Manual status update	2026-03-08 12:16:24.28905
43	1117	ACTIVE	ACTIVE	6	Manual status update	2026-03-08 20:16:58.697259
44	1117	SOFT_LOCK	SOFT_LOCK	6	Manual status update	2026-03-08 20:34:34.873866
45	1046	SOFT_LOCK	SOFT_LOCK	6	Manual status update	2026-03-08 21:01:04.58683
\.


--
-- TOC entry 5381 (class 0 OID 17204)
-- Dependencies: 234
-- Data for Name: visitor_types; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.visitor_types (id, type_name, allows_labour, is_internal) FROM stdin;
1	Officer	f	t
2	Supervisor	t	f
3	Sailor	f	t
4	DSC	f	t
5	Agniveer	f	t
6	Contractor	f	f
7	Vendor	f	f
8	Shop Keeper	f	f
9	Operator	f	f
\.


--
-- TOC entry 5383 (class 0 OID 17217)
-- Dependencies: 236
-- Data for Name: visitors; Type: TABLE DATA; Schema: public; Owner: svr_user
--

COPY public.visitors (id, visitor_type_id, pass_no, first_name, last_name, designation, company_name, company_address, project_id, department_id, host_id, primary_phone, alternate_phone, email, date_of_birth, blood_group, height_cm, visible_marks, temp_address, perm_address, aadhaar_encrypted, aadhaar_last4, entrance_id, smartphone_allowed, smartphone_expiry, laptop_allowed, laptop_make, laptop_model, laptop_serial, laptop_expiry, ops_area_permitted, status, valid_from, valid_to, enrollment_photo_path, created_by, created_at, updated_at, can_register_labours, gender, work_order_no, work_order_expiry, police_verification_certificate_number, pvc_expiry) FROM stdin;
1009	1	PASS008	Divya	Reddy	Project Manager	Infosys	Bangalore, Karnataka	2	2	2	9000000008	9000001008	divya.reddy@example.com	1989-04-12	O+	168	\N	OMR, Chennai	Hyderabad, Telangana	enc_aadhaar_008	8901	2	t	2026-12-31	t	Apple	MacBook Pro	MBPSN008	2026-12-31	t	ACTIVE	2026-02-24	2026-12-31	uploads\\1ad4d14ce8fa17aa752efe41a9f5d39c	1	2026-02-24 16:59:08.580235	2026-03-02 20:49:10.866281	t	\N	\N	\N	\N	\N
1006	2	PASS005	Rahul	Das	Technician	BEL	Bangalore, Karnataka	2	2	2	9000000005	9000001005	rahul.das@example.com	1993-07-19	O-	170	\N	Perungalathur, Chennai	Bangalore, Karnataka	enc_aadhaar_005	5678	3	f	\N	f	\N	\N	\N	\N	t	ACTIVE	2026-02-24	2026-09-30	/photos/rahul.jpg	1	2026-02-24 16:59:08.580235	2026-03-02 22:50:44.916328	t	\N	\N	\N	\N	\N
1002	1	PASS001	Ravi	Kumar	Site Engineer	L&T	Chennai, Tamil Nadu	2	2	2	9000000001	9000001001	ravi.kumar@example.com	1990-05-10	O+	172	Mole on left cheek	Adyar, Chennai	Bangalore, Karnataka	enc_aadhaar_001	1234	2	t	2026-12-31	t	Dell	Latitude 5420	DL5420SN001	2026-12-31	t	ACTIVE	2026-02-24	2026-12-31	uploads/visitors/1002/photo_1772992488561_243709300.jpg	1	2026-02-24 16:59:08.580235	2026-03-08 23:24:48.568467	t	\N	\N	\N	\N	\N
1004	2	PASS003	Suresh	Yadav	Supervisor	ABC Constructions	Hyderabad, Telangana	3	3	3	9000000003	9000001003	suresh.yadav@example.com	1985-03-15	B+	178	Scar on right hand	Tambaram, Chennai	Hyderabad, Telangana	enc_aadhaar_003	3456	3	f	\N	f	\N	\N	\N	\N	t	ACTIVE	2026-02-24	2026-08-31	/photos/suresh.jpg	1	2026-02-24 16:59:08.580235	2026-02-24 16:59:08.580235	t	\N	\N	\N	\N	\N
1005	1	PASS004	Meena	Iyer	Auditor	KPMG	Chennai, Tamil Nadu	4	4	4	9000000004	\N	meena.iyer@example.com	1992-11-02	AB+	160	\N	Mylapore, Chennai	Chennai, Tamil Nadu	enc_aadhaar_004	4567	2	t	2026-10-31	t	HP	EliteBook 840	HPE840SN004	2026-10-31	f	ACTIVE	2026-02-24	2026-10-31	/photos/meena.jpg	1	2026-02-24 16:59:08.580235	2026-02-24 16:59:08.580235	t	\N	\N	\N	\N	\N
1007	1	PASS006	Priya	Nair	Research Analyst	DRDO	Delhi	2	2	2	9000000006	\N	priya.nair@example.com	1991-01-25	B-	162	\N	Anna Nagar, Chennai	Kochi, Kerala	enc_aadhaar_006	6789	2	t	2026-12-15	t	Lenovo	ThinkPad T14	LNVTSN006	2026-12-15	t	ACTIVE	2026-02-24	2026-12-15	/photos/priya.jpg	1	2026-02-24 16:59:08.580235	2026-02-24 16:59:08.580235	t	\N	\N	\N	\N	\N
1008	2	PASS007	Manoj	Singh	Electrician	XYZ Services	Pune, Maharashtra	3	3	3	9000000007	\N	manoj.singh@example.com	1987-09-09	A-	175	Tattoo on right arm	Chromepet, Chennai	Pune, Maharashtra	enc_aadhaar_007	7890	3	f	\N	f	\N	\N	\N	\N	t	ACTIVE	2026-02-24	2026-07-31	/photos/manoj.jpg	1	2026-02-24 16:59:08.580235	2026-02-24 16:59:08.580235	t	\N	\N	\N	\N	\N
1010	2	PASS009	Kiran	Patel	Welder	Marine Works	Surat, Gujarat	3	3	3	9000000009	\N	kiran.patel@example.com	1986-06-30	B+	180	\N	Guindy, Chennai	Surat, Gujarat	enc_aadhaar_009	9012	3	f	\N	f	\N	\N	\N	\N	t	ACTIVE	2026-02-24	2026-06-30	/photos/kiran.jpg	1	2026-02-24 16:59:08.580235	2026-02-24 16:59:08.580235	t	\N	\N	\N	\N	\N
1014	4	PASS013	RAJA	RAO	DSC	NAVY	ARAKKONAM	12	6	4	9591959085		vinodreddymn@gmail.com	2025-09-02	A+	168		A1, FIRST FLOOR, CHIDANIDHI, NO 22, 11TH MAIN	CHINTAMANI TALUK	e2dceb2e8b40f87357490a32aabf3701:3556b4d72eca77c2941ba052d68d7460	7890	\N	f	\N	f				\N	f	ACTIVE	2026-02-26	2026-04-29	uploads\\7d32a5170c23370c00dc9cac1aad67ec	1	2026-02-27 23:58:54.228761	2026-02-27 23:59:07.992332	f	\N	\N	\N	\N	\N
1012	6	PASS011	VINOD	M N	Project Manager	GEE BEE NETWORK PVT LTD	DHRUVAN BUILDING, 9TH CROSS, BRINDAVAN NAGR, MATHIKERE	12	6	4	9591959085	9591959085	vinodreddymn@gmail.com	1996-01-05	A+	168	a mole	DHRUVAN BUILDING, 9TH CROSS, BRINDAVAN NAGR, MATHIKERE	NEAR MORE SUPER MARKET, OPP JP PARK	4af316632de764d436003a6dadf5bef1:43bf2a8fd0ca4086f09ef774a0b3e38f	9012	\N	t	2026-03-24	f	\N	\N	\N	\N	t	ACTIVE	2026-02-24	2026-05-24	uploads\\38c180b8678890c099da2b15a289cd64	1	2026-02-27 19:16:22.998725	2026-03-04 18:33:17.585904	t	\N	\N	\N	\N	\N
1011	1	PASS010	Sneha	Kulkarni	Safety Officer	Reliance	Mumbai, Maharashtra	2	2	4	9000000010	\N	sneha.kulkarni@example.com	1994-02-17	A+	167	\N	Porur, Chennai	Mumbai, Maharashtra	enc_aadhaar_010	0123	\N	t	2026-11-14	f	\N	\N	\N	\N	f	ACTIVE	2026-02-23	2026-11-14	/photos/sneha.jpg	1	2026-02-24 16:59:08.580235	2026-03-06 17:23:25.844081	t	\N	\N	\N	\N	\N
1015	1	PASS201	Visitor1	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000001	\N	visitor1@example.com	1990-01-01	O+	170	\N	Temporary Address 1	Permanent Address 1	enc_aadhaar_1	0001	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1016	1	PASS202	Visitor2	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000002	\N	visitor2@example.com	1990-01-01	O+	170	\N	Temporary Address 2	Permanent Address 2	enc_aadhaar_2	0002	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1017	1	PASS203	Visitor3	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000003	\N	visitor3@example.com	1990-01-01	O+	170	\N	Temporary Address 3	Permanent Address 3	enc_aadhaar_3	0003	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1018	1	PASS204	Visitor4	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000004	\N	visitor4@example.com	1990-01-01	O+	170	\N	Temporary Address 4	Permanent Address 4	enc_aadhaar_4	0004	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1019	1	PASS205	Visitor5	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000005	\N	visitor5@example.com	1990-01-01	O+	170	\N	Temporary Address 5	Permanent Address 5	enc_aadhaar_5	0005	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1020	1	PASS206	Visitor6	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000006	\N	visitor6@example.com	1990-01-01	O+	170	\N	Temporary Address 6	Permanent Address 6	enc_aadhaar_6	0006	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1021	1	PASS207	Visitor7	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000007	\N	visitor7@example.com	1990-01-01	O+	170	\N	Temporary Address 7	Permanent Address 7	enc_aadhaar_7	0007	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1022	1	PASS208	Visitor8	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000008	\N	visitor8@example.com	1990-01-01	O+	170	\N	Temporary Address 8	Permanent Address 8	enc_aadhaar_8	0008	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1023	1	PASS209	Visitor9	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000009	\N	visitor9@example.com	1990-01-01	O+	170	\N	Temporary Address 9	Permanent Address 9	enc_aadhaar_9	0009	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1024	1	PASS210	Visitor10	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000010	\N	visitor10@example.com	1990-01-01	O+	170	\N	Temporary Address 10	Permanent Address 10	enc_aadhaar_10	0010	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1025	1	PASS211	Visitor11	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000011	\N	visitor11@example.com	1990-01-01	O+	170	\N	Temporary Address 11	Permanent Address 11	enc_aadhaar_11	0011	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1026	1	PASS212	Visitor12	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000012	\N	visitor12@example.com	1990-01-01	O+	170	\N	Temporary Address 12	Permanent Address 12	enc_aadhaar_12	0012	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1027	1	PASS213	Visitor13	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000013	\N	visitor13@example.com	1990-01-01	O+	170	\N	Temporary Address 13	Permanent Address 13	enc_aadhaar_13	0013	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1028	1	PASS214	Visitor14	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000014	\N	visitor14@example.com	1990-01-01	O+	170	\N	Temporary Address 14	Permanent Address 14	enc_aadhaar_14	0014	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1013	5	PASS012	ARJUN	REDDY	PROJECT MANAGER	BEL	BENGALURU	12	6	2	9591959085	9591959085	vmn@gmail.com	1996-03-11	A+	168	a mole	ARAKKONAM	BENGALURU	6eee06797d9579b7dc2b74c832e84d6b:7aa33a5429db985c20d3f47e054ce5fb	7890	\N	t	2026-03-27	t	HP	G12	1234	2026-03-13	f	ACTIVE	2026-02-26	2026-05-27	uploads\\a27d8e6b9d666195f4f5677553358021	1	2026-02-27 23:47:06.04325	2026-03-04 19:19:44.027775	f	\N	\N	\N	\N	\N
1003	1	PASS002	Anita	Sharma	Consultant	TCS	Mumbai, Maharashtra	3	3	3	9000000002	\N	anita.sharma@example.com	1988-08-21	A+	165	\N	Velachery, Chennai	Mumbai, Maharashtra	enc_aadhaar_002	2345	2	t	2026-11-30	f	\N	\N	\N	\N	f	SOFT_LOCK	2026-02-24	2026-11-30	/photos/anita.jpg	1	2026-02-24 16:59:08.580235	2026-02-24 19:12:28.199376	t	\N	\N	\N	\N	\N
1029	1	PASS215	Visitor15	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000015	\N	visitor15@example.com	1990-01-01	O+	170	\N	Temporary Address 15	Permanent Address 15	enc_aadhaar_15	0015	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1030	1	PASS216	Visitor16	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000016	\N	visitor16@example.com	1990-01-01	O+	170	\N	Temporary Address 16	Permanent Address 16	enc_aadhaar_16	0016	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1031	1	PASS217	Visitor17	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000017	\N	visitor17@example.com	1990-01-01	O+	170	\N	Temporary Address 17	Permanent Address 17	enc_aadhaar_17	0017	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1032	1	PASS218	Visitor18	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000018	\N	visitor18@example.com	1990-01-01	O+	170	\N	Temporary Address 18	Permanent Address 18	enc_aadhaar_18	0018	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1033	1	PASS219	Visitor19	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000019	\N	visitor19@example.com	1990-01-01	O+	170	\N	Temporary Address 19	Permanent Address 19	enc_aadhaar_19	0019	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1034	1	PASS220	Visitor20	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000020	\N	visitor20@example.com	1990-01-01	O+	170	\N	Temporary Address 20	Permanent Address 20	enc_aadhaar_20	0020	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1035	1	PASS221	Visitor21	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000021	\N	visitor21@example.com	1990-01-01	O+	170	\N	Temporary Address 21	Permanent Address 21	enc_aadhaar_21	0021	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1036	1	PASS222	Visitor22	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000022	\N	visitor22@example.com	1990-01-01	O+	170	\N	Temporary Address 22	Permanent Address 22	enc_aadhaar_22	0022	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1037	1	PASS223	Visitor23	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000023	\N	visitor23@example.com	1990-01-01	O+	170	\N	Temporary Address 23	Permanent Address 23	enc_aadhaar_23	0023	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1038	1	PASS224	Visitor24	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000024	\N	visitor24@example.com	1990-01-01	O+	170	\N	Temporary Address 24	Permanent Address 24	enc_aadhaar_24	0024	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1039	1	PASS225	Visitor25	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000025	\N	visitor25@example.com	1990-01-01	O+	170	\N	Temporary Address 25	Permanent Address 25	enc_aadhaar_25	0025	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1040	1	PASS226	Visitor26	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000026	\N	visitor26@example.com	1990-01-01	O+	170	\N	Temporary Address 26	Permanent Address 26	enc_aadhaar_26	0026	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1041	1	PASS227	Visitor27	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000027	\N	visitor27@example.com	1990-01-01	O+	170	\N	Temporary Address 27	Permanent Address 27	enc_aadhaar_27	0027	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1042	1	PASS228	Visitor28	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000028	\N	visitor28@example.com	1990-01-01	O+	170	\N	Temporary Address 28	Permanent Address 28	enc_aadhaar_28	0028	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1043	1	PASS229	Visitor29	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000029	\N	visitor29@example.com	1990-01-01	O+	170	\N	Temporary Address 29	Permanent Address 29	enc_aadhaar_29	0029	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1044	1	PASS230	Visitor30	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000030	\N	visitor30@example.com	1990-01-01	O+	170	\N	Temporary Address 30	Permanent Address 30	enc_aadhaar_30	0030	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1045	1	PASS231	Visitor31	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000031	\N	visitor31@example.com	1990-01-01	O+	170	\N	Temporary Address 31	Permanent Address 31	enc_aadhaar_31	0031	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1047	1	PASS233	Visitor33	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000033	\N	visitor33@example.com	1990-01-01	O+	170	\N	Temporary Address 33	Permanent Address 33	enc_aadhaar_33	0033	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1048	1	PASS234	Visitor34	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000034	\N	visitor34@example.com	1990-01-01	O+	170	\N	Temporary Address 34	Permanent Address 34	enc_aadhaar_34	0034	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1049	1	PASS235	Visitor35	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000035	\N	visitor35@example.com	1990-01-01	O+	170	\N	Temporary Address 35	Permanent Address 35	enc_aadhaar_35	0035	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1050	1	PASS236	Visitor36	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000036	\N	visitor36@example.com	1990-01-01	O+	170	\N	Temporary Address 36	Permanent Address 36	enc_aadhaar_36	0036	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1051	1	PASS237	Visitor37	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000037	\N	visitor37@example.com	1990-01-01	O+	170	\N	Temporary Address 37	Permanent Address 37	enc_aadhaar_37	0037	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1052	1	PASS238	Visitor38	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000038	\N	visitor38@example.com	1990-01-01	O+	170	\N	Temporary Address 38	Permanent Address 38	enc_aadhaar_38	0038	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1053	1	PASS239	Visitor39	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000039	\N	visitor39@example.com	1990-01-01	O+	170	\N	Temporary Address 39	Permanent Address 39	enc_aadhaar_39	0039	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1054	1	PASS240	Visitor40	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000040	\N	visitor40@example.com	1990-01-01	O+	170	\N	Temporary Address 40	Permanent Address 40	enc_aadhaar_40	0040	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1055	1	PASS241	Visitor41	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000041	\N	visitor41@example.com	1990-01-01	O+	170	\N	Temporary Address 41	Permanent Address 41	enc_aadhaar_41	0041	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1056	1	PASS242	Visitor42	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000042	\N	visitor42@example.com	1990-01-01	O+	170	\N	Temporary Address 42	Permanent Address 42	enc_aadhaar_42	0042	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1057	1	PASS243	Visitor43	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000043	\N	visitor43@example.com	1990-01-01	O+	170	\N	Temporary Address 43	Permanent Address 43	enc_aadhaar_43	0043	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1058	1	PASS244	Visitor44	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000044	\N	visitor44@example.com	1990-01-01	O+	170	\N	Temporary Address 44	Permanent Address 44	enc_aadhaar_44	0044	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1059	1	PASS245	Visitor45	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000045	\N	visitor45@example.com	1990-01-01	O+	170	\N	Temporary Address 45	Permanent Address 45	enc_aadhaar_45	0045	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1060	1	PASS246	Visitor46	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000046	\N	visitor46@example.com	1990-01-01	O+	170	\N	Temporary Address 46	Permanent Address 46	enc_aadhaar_46	0046	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1061	1	PASS247	Visitor47	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000047	\N	visitor47@example.com	1990-01-01	O+	170	\N	Temporary Address 47	Permanent Address 47	enc_aadhaar_47	0047	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1062	1	PASS248	Visitor48	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000048	\N	visitor48@example.com	1990-01-01	O+	170	\N	Temporary Address 48	Permanent Address 48	enc_aadhaar_48	0048	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1063	1	PASS249	Visitor49	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000049	\N	visitor49@example.com	1990-01-01	O+	170	\N	Temporary Address 49	Permanent Address 49	enc_aadhaar_49	0049	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1064	1	PASS250	Visitor50	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000050	\N	visitor50@example.com	1990-01-01	O+	170	\N	Temporary Address 50	Permanent Address 50	enc_aadhaar_50	0050	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1065	1	PASS251	Visitor51	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000051	\N	visitor51@example.com	1990-01-01	O+	170	\N	Temporary Address 51	Permanent Address 51	enc_aadhaar_51	0051	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1066	1	PASS252	Visitor52	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000052	\N	visitor52@example.com	1990-01-01	O+	170	\N	Temporary Address 52	Permanent Address 52	enc_aadhaar_52	0052	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1067	1	PASS253	Visitor53	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000053	\N	visitor53@example.com	1990-01-01	O+	170	\N	Temporary Address 53	Permanent Address 53	enc_aadhaar_53	0053	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1068	1	PASS254	Visitor54	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000054	\N	visitor54@example.com	1990-01-01	O+	170	\N	Temporary Address 54	Permanent Address 54	enc_aadhaar_54	0054	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1069	1	PASS255	Visitor55	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000055	\N	visitor55@example.com	1990-01-01	O+	170	\N	Temporary Address 55	Permanent Address 55	enc_aadhaar_55	0055	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1070	1	PASS256	Visitor56	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000056	\N	visitor56@example.com	1990-01-01	O+	170	\N	Temporary Address 56	Permanent Address 56	enc_aadhaar_56	0056	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1071	1	PASS257	Visitor57	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000057	\N	visitor57@example.com	1990-01-01	O+	170	\N	Temporary Address 57	Permanent Address 57	enc_aadhaar_57	0057	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1072	1	PASS258	Visitor58	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000058	\N	visitor58@example.com	1990-01-01	O+	170	\N	Temporary Address 58	Permanent Address 58	enc_aadhaar_58	0058	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1073	1	PASS259	Visitor59	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000059	\N	visitor59@example.com	1990-01-01	O+	170	\N	Temporary Address 59	Permanent Address 59	enc_aadhaar_59	0059	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1074	1	PASS260	Visitor60	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000060	\N	visitor60@example.com	1990-01-01	O+	170	\N	Temporary Address 60	Permanent Address 60	enc_aadhaar_60	0060	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1075	1	PASS261	Visitor61	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000061	\N	visitor61@example.com	1990-01-01	O+	170	\N	Temporary Address 61	Permanent Address 61	enc_aadhaar_61	0061	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1076	1	PASS262	Visitor62	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000062	\N	visitor62@example.com	1990-01-01	O+	170	\N	Temporary Address 62	Permanent Address 62	enc_aadhaar_62	0062	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1077	1	PASS263	Visitor63	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000063	\N	visitor63@example.com	1990-01-01	O+	170	\N	Temporary Address 63	Permanent Address 63	enc_aadhaar_63	0063	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1078	1	PASS264	Visitor64	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000064	\N	visitor64@example.com	1990-01-01	O+	170	\N	Temporary Address 64	Permanent Address 64	enc_aadhaar_64	0064	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1079	1	PASS265	Visitor65	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000065	\N	visitor65@example.com	1990-01-01	O+	170	\N	Temporary Address 65	Permanent Address 65	enc_aadhaar_65	0065	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1080	1	PASS266	Visitor66	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000066	\N	visitor66@example.com	1990-01-01	O+	170	\N	Temporary Address 66	Permanent Address 66	enc_aadhaar_66	0066	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1081	1	PASS267	Visitor67	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000067	\N	visitor67@example.com	1990-01-01	O+	170	\N	Temporary Address 67	Permanent Address 67	enc_aadhaar_67	0067	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1082	1	PASS268	Visitor68	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000068	\N	visitor68@example.com	1990-01-01	O+	170	\N	Temporary Address 68	Permanent Address 68	enc_aadhaar_68	0068	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1083	1	PASS269	Visitor69	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000069	\N	visitor69@example.com	1990-01-01	O+	170	\N	Temporary Address 69	Permanent Address 69	enc_aadhaar_69	0069	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1084	1	PASS270	Visitor70	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000070	\N	visitor70@example.com	1990-01-01	O+	170	\N	Temporary Address 70	Permanent Address 70	enc_aadhaar_70	0070	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1085	1	PASS271	Visitor71	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000071	\N	visitor71@example.com	1990-01-01	O+	170	\N	Temporary Address 71	Permanent Address 71	enc_aadhaar_71	0071	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1086	1	PASS272	Visitor72	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000072	\N	visitor72@example.com	1990-01-01	O+	170	\N	Temporary Address 72	Permanent Address 72	enc_aadhaar_72	0072	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1087	1	PASS273	Visitor73	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000073	\N	visitor73@example.com	1990-01-01	O+	170	\N	Temporary Address 73	Permanent Address 73	enc_aadhaar_73	0073	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1088	1	PASS274	Visitor74	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000074	\N	visitor74@example.com	1990-01-01	O+	170	\N	Temporary Address 74	Permanent Address 74	enc_aadhaar_74	0074	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1089	1	PASS275	Visitor75	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000075	\N	visitor75@example.com	1990-01-01	O+	170	\N	Temporary Address 75	Permanent Address 75	enc_aadhaar_75	0075	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1090	1	PASS276	Visitor76	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000076	\N	visitor76@example.com	1990-01-01	O+	170	\N	Temporary Address 76	Permanent Address 76	enc_aadhaar_76	0076	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1091	1	PASS277	Visitor77	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000077	\N	visitor77@example.com	1990-01-01	O+	170	\N	Temporary Address 77	Permanent Address 77	enc_aadhaar_77	0077	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1092	1	PASS278	Visitor78	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000078	\N	visitor78@example.com	1990-01-01	O+	170	\N	Temporary Address 78	Permanent Address 78	enc_aadhaar_78	0078	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1093	1	PASS279	Visitor79	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000079	\N	visitor79@example.com	1990-01-01	O+	170	\N	Temporary Address 79	Permanent Address 79	enc_aadhaar_79	0079	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1094	1	PASS280	Visitor80	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000080	\N	visitor80@example.com	1990-01-01	O+	170	\N	Temporary Address 80	Permanent Address 80	enc_aadhaar_80	0080	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1095	1	PASS281	Visitor81	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000081	\N	visitor81@example.com	1990-01-01	O+	170	\N	Temporary Address 81	Permanent Address 81	enc_aadhaar_81	0081	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1096	1	PASS282	Visitor82	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000082	\N	visitor82@example.com	1990-01-01	O+	170	\N	Temporary Address 82	Permanent Address 82	enc_aadhaar_82	0082	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1097	1	PASS283	Visitor83	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000083	\N	visitor83@example.com	1990-01-01	O+	170	\N	Temporary Address 83	Permanent Address 83	enc_aadhaar_83	0083	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1098	1	PASS284	Visitor84	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000084	\N	visitor84@example.com	1990-01-01	O+	170	\N	Temporary Address 84	Permanent Address 84	enc_aadhaar_84	0084	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1099	1	PASS285	Visitor85	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000085	\N	visitor85@example.com	1990-01-01	O+	170	\N	Temporary Address 85	Permanent Address 85	enc_aadhaar_85	0085	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1100	1	PASS286	Visitor86	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000086	\N	visitor86@example.com	1990-01-01	O+	170	\N	Temporary Address 86	Permanent Address 86	enc_aadhaar_86	0086	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1102	1	PASS288	Visitor88	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000088	\N	visitor88@example.com	1990-01-01	O+	170	\N	Temporary Address 88	Permanent Address 88	enc_aadhaar_88	0088	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1103	1	PASS289	Visitor89	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000089	\N	visitor89@example.com	1990-01-01	O+	170	\N	Temporary Address 89	Permanent Address 89	enc_aadhaar_89	0089	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1104	1	PASS290	Visitor90	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000090	\N	visitor90@example.com	1990-01-01	O+	170	\N	Temporary Address 90	Permanent Address 90	enc_aadhaar_90	0090	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1105	1	PASS291	Visitor91	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000091	\N	visitor91@example.com	1990-01-01	O+	170	\N	Temporary Address 91	Permanent Address 91	enc_aadhaar_91	0091	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1106	1	PASS292	Visitor92	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000092	\N	visitor92@example.com	1990-01-01	O+	170	\N	Temporary Address 92	Permanent Address 92	enc_aadhaar_92	0092	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1107	1	PASS293	Visitor93	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000093	\N	visitor93@example.com	1990-01-01	O+	170	\N	Temporary Address 93	Permanent Address 93	enc_aadhaar_93	0093	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1108	1	PASS294	Visitor94	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000094	\N	visitor94@example.com	1990-01-01	O+	170	\N	Temporary Address 94	Permanent Address 94	enc_aadhaar_94	0094	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1109	1	PASS295	Visitor95	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000095	\N	visitor95@example.com	1990-01-01	O+	170	\N	Temporary Address 95	Permanent Address 95	enc_aadhaar_95	0095	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1110	1	PASS296	Visitor96	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000096	\N	visitor96@example.com	1990-01-01	O+	170	\N	Temporary Address 96	Permanent Address 96	enc_aadhaar_96	0096	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1111	1	PASS297	Visitor97	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000097	\N	visitor97@example.com	1990-01-01	O+	170	\N	Temporary Address 97	Permanent Address 97	enc_aadhaar_97	0097	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1112	1	PASS298	Visitor98	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000098	\N	visitor98@example.com	1990-01-01	O+	170	\N	Temporary Address 98	Permanent Address 98	enc_aadhaar_98	0098	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1113	1	PASS299	Visitor99	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000099	\N	visitor99@example.com	1990-01-01	O+	170	\N	Temporary Address 99	Permanent Address 99	enc_aadhaar_99	0099	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1114	1	PASS300	Visitor100	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000100	\N	visitor100@example.com	1990-01-01	O+	170	\N	Temporary Address 100	Permanent Address 100	enc_aadhaar_100	0100	2	t	2026-12-31	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-12-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-03 12:50:10.437027	t	\N	\N	\N	\N	\N
1116	6	PASS202602	VIJAY	KUMAR R	PROJECT ENGINEER	BHARAT ELECTRONICS LIMITED	BENGALURU	12	7	5	9876543210	9876543210	vijay@example.com	1996-01-05	AB+	160	A MOLE	ARAKKONAM	BENGALURU	30e9c5ca6baf7c90a9771103411f9dbd:31e442e3aedbe4747ffc538e34982378	1234	\N	t	2026-03-27	t	HP	G12	1234	2026-03-31	t	ACTIVE	2026-03-02	2026-04-01	uploads/visitors/1116/photo_1772799029039_103757336.jpg	6	2026-03-06 17:39:49.750799	2026-03-08 11:10:51.918014	t	MALE	NAISS123	2026-03-30	NAISS123	2026-03-30
1115	2	PASS202601	DEEPANKAR	MAITY	PROJECT ENGINEER	GEE BEE NETWORK PVT LTD	105, VINOBHA BHAVA ROAD, KOLKATA	12	7	5	9876543210	9876543211	DEEPANKAR@EXAMPLE.COM	1995-03-28	A+	157	A MOLE	ARAKKONAM	KOLKATA	b094914a2f5cc5fe5a6a0efa97c88971:57643aba239404983806a39f4f05dc0d	1234	\N	t	2026-04-30	f				\N	t	ACTIVE	2026-03-04	2026-04-30	uploads/visitors/1115/photo_1772819071349_186647466.jpg	1	2026-03-04 17:27:36.090011	2026-03-06 23:14:31.360907	t	\N	\N	\N	\N	\N
1117	4	PASS202603	MURUGESHAN	\N	COMMANDER	INADIAN NAVY	ARAKKONAM	12	7	5	9876543210	9876543210	murugeshan@example.com	1983-06-01	AB-	156	A MOLE	ARAKKONAM	BANGALORE	48561b224116ef5f913f368c7ae270a6:93dedcbc972c9ee8fce5918bb2bd9160	1234	\N	t	2026-03-27	f	\N	\N	\N	\N	t	ACTIVE	2026-03-03	2026-03-31	uploads/visitors/1117/photo_1772947053015_509315999.jpg	3	2026-03-07 20:49:39.242376	2026-03-08 20:34:34.875579	t	MALE	DSC	2026-03-27	DSC	2026-03-27
1101	1	PASS287	Visitor87	Test	Engineer	Test Company	Bangalore, Karnataka	12	7	4	9000000087	\N	visitor87@example.com	1989-12-28	O+	170	A MOLE	Temporary Address 87	Permanent Address 87	enc_aadhaar_87	0087	\N	t	2026-12-27	t	HP	G12	1234	2026-03-31	t	ACTIVE	2026-02-27	2026-12-27	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-07 23:01:00.861848	t	MALE	\N	\N	\N	\N
1046	9	PASS232	Visitor32	Test	Engineer	Test Company	Bangalore, Karnataka	2	2	2	9000000032	\N	visitor32@example.com	1989-12-29	O+	170	\N	Temporary Address 32	Permanent Address 32	enc_aadhaar_32	0032	\N	t	2026-12-28	f	\N	\N	\N	\N	t	ACTIVE	2026-02-28	2026-03-31	/photos/default.jpg	1	2026-03-03 12:50:10.437027	2026-03-08 21:01:04.590019	t	\N	\N	\N	\N	\N
\.


--
-- TOC entry 5460 (class 0 OID 0)
-- Dependencies: 254
-- Name: access_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svr_user
--

SELECT pg_catalog.setval('public.access_logs_id_seq', 256, true);


--
-- TOC entry 5461 (class 0 OID 0)
-- Dependencies: 239
-- Name: biometric_data_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svr_user
--

SELECT pg_catalog.setval('public.biometric_data_id_seq', 3005, true);


--
-- TOC entry 5462 (class 0 OID 0)
-- Dependencies: 241
-- Name: biometric_match_audit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svr_user
--

SELECT pg_catalog.setval('public.biometric_match_audit_id_seq', 1, false);


--
-- TOC entry 5463 (class 0 OID 0)
-- Dependencies: 261
-- Name: blacklist_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svr_user
--

SELECT pg_catalog.setval('public.blacklist_id_seq', 9002, true);


--
-- TOC entry 5464 (class 0 OID 0)
-- Dependencies: 245
-- Name: card_reissue_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svr_user
--

SELECT pg_catalog.setval('public.card_reissue_log_id_seq', 1, false);


--
-- TOC entry 5465 (class 0 OID 0)
-- Dependencies: 225
-- Name: departments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svr_user
--

SELECT pg_catalog.setval('public.departments_id_seq', 11, true);


--
-- TOC entry 5466 (class 0 OID 0)
-- Dependencies: 229
-- Name: entrances_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svr_user
--

SELECT pg_catalog.setval('public.entrances_id_seq', 4, true);


--
-- TOC entry 5467 (class 0 OID 0)
-- Dependencies: 268
-- Name: gate_health_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svr_user
--

SELECT pg_catalog.setval('public.gate_health_logs_id_seq', 9247, true);


--
-- TOC entry 5468 (class 0 OID 0)
-- Dependencies: 231
-- Name: gates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svr_user
--

SELECT pg_catalog.setval('public.gates_id_seq', 5, true);


--
-- TOC entry 5469 (class 0 OID 0)
-- Dependencies: 274
-- Name: host_projects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svr_user
--

SELECT pg_catalog.setval('public.host_projects_id_seq', 18, true);


--
-- TOC entry 5470 (class 0 OID 0)
-- Dependencies: 227
-- Name: hosts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svr_user
--

SELECT pg_catalog.setval('public.hosts_id_seq', 5, true);


--
-- TOC entry 5471 (class 0 OID 0)
-- Dependencies: 251
-- Name: labour_manifests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svr_user
--

SELECT pg_catalog.setval('public.labour_manifests_id_seq', 97, true);


--
-- TOC entry 5472 (class 0 OID 0)
-- Dependencies: 249
-- Name: labour_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svr_user
--

SELECT pg_catalog.setval('public.labour_tokens_id_seq', 6174, true);


--
-- TOC entry 5473 (class 0 OID 0)
-- Dependencies: 247
-- Name: labours_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svr_user
--

SELECT pg_catalog.setval('public.labours_id_seq', 5179, true);


--
-- TOC entry 5474 (class 0 OID 0)
-- Dependencies: 259
-- Name: material_transactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svr_user
--

SELECT pg_catalog.setval('public.material_transactions_id_seq', 8001, true);


--
-- TOC entry 5475 (class 0 OID 0)
-- Dependencies: 257
-- Name: materials_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svr_user
--

SELECT pg_catalog.setval('public.materials_id_seq', 7001, true);


--
-- TOC entry 5476 (class 0 OID 0)
-- Dependencies: 223
-- Name: projects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svr_user
--

SELECT pg_catalog.setval('public.projects_id_seq', 12, true);


--
-- TOC entry 5477 (class 0 OID 0)
-- Dependencies: 243
-- Name: rfid_cards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svr_user
--

SELECT pg_catalog.setval('public.rfid_cards_id_seq', 4025, true);


--
-- TOC entry 5478 (class 0 OID 0)
-- Dependencies: 276
-- Name: rfid_cards_stock_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svr_user
--

SELECT pg_catalog.setval('public.rfid_cards_stock_id_seq', 100, true);


--
-- TOC entry 5479 (class 0 OID 0)
-- Dependencies: 272
-- Name: rfid_stock_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svr_user
--

SELECT pg_catalog.setval('public.rfid_stock_id_seq', 100, true);


--
-- TOC entry 5480 (class 0 OID 0)
-- Dependencies: 219
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svr_user
--

SELECT pg_catalog.setval('public.roles_id_seq', 6, true);


--
-- TOC entry 5481 (class 0 OID 0)
-- Dependencies: 263
-- Name: sms_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svr_user
--

SELECT pg_catalog.setval('public.sms_logs_id_seq', 11169, true);


--
-- TOC entry 5482 (class 0 OID 0)
-- Dependencies: 265
-- Name: sync_queue_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svr_user
--

SELECT pg_catalog.setval('public.sync_queue_id_seq', 11001, true);


--
-- TOC entry 5483 (class 0 OID 0)
-- Dependencies: 221
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svr_user
--

SELECT pg_catalog.setval('public.users_id_seq', 6, true);


--
-- TOC entry 5484 (class 0 OID 0)
-- Dependencies: 237
-- Name: visitor_documents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svr_user
--

SELECT pg_catalog.setval('public.visitor_documents_id_seq', 2008, true);


--
-- TOC entry 5485 (class 0 OID 0)
-- Dependencies: 278
-- Name: visitor_gate_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svr_user
--

SELECT pg_catalog.setval('public.visitor_gate_permissions_id_seq', 2, true);


--
-- TOC entry 5486 (class 0 OID 0)
-- Dependencies: 270
-- Name: visitor_status_audit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svr_user
--

SELECT pg_catalog.setval('public.visitor_status_audit_id_seq', 45, true);


--
-- TOC entry 5487 (class 0 OID 0)
-- Dependencies: 233
-- Name: visitor_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svr_user
--

SELECT pg_catalog.setval('public.visitor_types_id_seq', 9, true);


--
-- TOC entry 5488 (class 0 OID 0)
-- Dependencies: 235
-- Name: visitors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svr_user
--

SELECT pg_catalog.setval('public.visitors_id_seq', 1117, true);


--
-- TOC entry 5141 (class 2606 OID 17442)
-- Name: access_logs access_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.access_logs
    ADD CONSTRAINT access_logs_pkey PRIMARY KEY (id, scan_time);


--
-- TOC entry 5143 (class 2606 OID 17454)
-- Name: access_logs_default access_logs_default_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.access_logs_default
    ADD CONSTRAINT access_logs_default_pkey PRIMARY KEY (id, scan_time);


--
-- TOC entry 5123 (class 2606 OID 17297)
-- Name: biometric_data biometric_data_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.biometric_data
    ADD CONSTRAINT biometric_data_pkey PRIMARY KEY (id);


--
-- TOC entry 5125 (class 2606 OID 17313)
-- Name: biometric_match_audit biometric_match_audit_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.biometric_match_audit
    ADD CONSTRAINT biometric_match_audit_pkey PRIMARY KEY (id);


--
-- TOC entry 5149 (class 2606 OID 17501)
-- Name: blacklist blacklist_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.blacklist
    ADD CONSTRAINT blacklist_pkey PRIMARY KEY (id);


--
-- TOC entry 5131 (class 2606 OID 17349)
-- Name: card_reissue_log card_reissue_log_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.card_reissue_log
    ADD CONSTRAINT card_reissue_log_pkey PRIMARY KEY (id);


--
-- TOC entry 5102 (class 2606 OID 17154)
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- TOC entry 5106 (class 2606 OID 17188)
-- Name: entrances entrances_entrance_code_key; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.entrances
    ADD CONSTRAINT entrances_entrance_code_key UNIQUE (entrance_code);


--
-- TOC entry 5108 (class 2606 OID 17186)
-- Name: entrances entrances_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.entrances
    ADD CONSTRAINT entrances_pkey PRIMARY KEY (id);


--
-- TOC entry 5157 (class 2606 OID 17550)
-- Name: gate_health_logs gate_health_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.gate_health_logs
    ADD CONSTRAINT gate_health_logs_pkey PRIMARY KEY (id);


--
-- TOC entry 5155 (class 2606 OID 17536)
-- Name: gate_health gate_health_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.gate_health
    ADD CONSTRAINT gate_health_pkey PRIMARY KEY (gate_id);


--
-- TOC entry 5110 (class 2606 OID 17197)
-- Name: gates gates_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.gates
    ADD CONSTRAINT gates_pkey PRIMARY KEY (id);


--
-- TOC entry 5167 (class 2606 OID 17605)
-- Name: host_projects host_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.host_projects
    ADD CONSTRAINT host_projects_pkey PRIMARY KEY (id);


--
-- TOC entry 5104 (class 2606 OID 17171)
-- Name: hosts hosts_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.hosts
    ADD CONSTRAINT hosts_pkey PRIMARY KEY (id);


--
-- TOC entry 5137 (class 2606 OID 17410)
-- Name: labour_manifests labour_manifests_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.labour_manifests
    ADD CONSTRAINT labour_manifests_pkey PRIMARY KEY (id);


--
-- TOC entry 5135 (class 2606 OID 17394)
-- Name: labour_tokens labour_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.labour_tokens
    ADD CONSTRAINT labour_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 5133 (class 2606 OID 17380)
-- Name: labours labours_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.labours
    ADD CONSTRAINT labours_pkey PRIMARY KEY (id);


--
-- TOC entry 5139 (class 2606 OID 17422)
-- Name: manifest_labours manifest_labours_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.manifest_labours
    ADD CONSTRAINT manifest_labours_pkey PRIMARY KEY (manifest_id, labour_id);


--
-- TOC entry 5147 (class 2606 OID 17480)
-- Name: material_transactions material_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.material_transactions
    ADD CONSTRAINT material_transactions_pkey PRIMARY KEY (id);


--
-- TOC entry 5145 (class 2606 OID 17471)
-- Name: materials materials_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.materials
    ADD CONSTRAINT materials_pkey PRIMARY KEY (id);


--
-- TOC entry 5100 (class 2606 OID 17143)
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- TOC entry 5127 (class 2606 OID 17333)
-- Name: rfid_cards rfid_cards_card_uid_key; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.rfid_cards
    ADD CONSTRAINT rfid_cards_card_uid_key UNIQUE (card_uid);


--
-- TOC entry 5129 (class 2606 OID 17331)
-- Name: rfid_cards rfid_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.rfid_cards
    ADD CONSTRAINT rfid_cards_pkey PRIMARY KEY (id);


--
-- TOC entry 5175 (class 2606 OID 17634)
-- Name: rfid_cards_stock rfid_cards_stock_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.rfid_cards_stock
    ADD CONSTRAINT rfid_cards_stock_pkey PRIMARY KEY (id);


--
-- TOC entry 5177 (class 2606 OID 17636)
-- Name: rfid_cards_stock rfid_cards_stock_uid_key; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.rfid_cards_stock
    ADD CONSTRAINT rfid_cards_stock_uid_key UNIQUE (uid);


--
-- TOC entry 5163 (class 2606 OID 17592)
-- Name: rfid_stock rfid_stock_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.rfid_stock
    ADD CONSTRAINT rfid_stock_pkey PRIMARY KEY (id);


--
-- TOC entry 5165 (class 2606 OID 17594)
-- Name: rfid_stock rfid_stock_uid_key; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.rfid_stock
    ADD CONSTRAINT rfid_stock_uid_key UNIQUE (uid);


--
-- TOC entry 5092 (class 2606 OID 17109)
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- TOC entry 5094 (class 2606 OID 17111)
-- Name: roles roles_role_name_key; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_role_name_key UNIQUE (role_name);


--
-- TOC entry 5151 (class 2606 OID 17512)
-- Name: sms_logs sms_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.sms_logs
    ADD CONSTRAINT sms_logs_pkey PRIMARY KEY (id);


--
-- TOC entry 5153 (class 2606 OID 17524)
-- Name: sync_queue sync_queue_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.sync_queue
    ADD CONSTRAINT sync_queue_pkey PRIMARY KEY (id);


--
-- TOC entry 5171 (class 2606 OID 17607)
-- Name: host_projects uq_host_project; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.host_projects
    ADD CONSTRAINT uq_host_project UNIQUE (host_id, project_id);


--
-- TOC entry 5179 (class 2606 OID 17676)
-- Name: visitor_gate_permissions uq_visitor_gate; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.visitor_gate_permissions
    ADD CONSTRAINT uq_visitor_gate UNIQUE (visitor_id, gate_id);


--
-- TOC entry 5096 (class 2606 OID 17125)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 5098 (class 2606 OID 17127)
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- TOC entry 5121 (class 2606 OID 17279)
-- Name: visitor_documents visitor_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.visitor_documents
    ADD CONSTRAINT visitor_documents_pkey PRIMARY KEY (id);


--
-- TOC entry 5181 (class 2606 OID 17674)
-- Name: visitor_gate_permissions visitor_gate_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.visitor_gate_permissions
    ADD CONSTRAINT visitor_gate_permissions_pkey PRIMARY KEY (id);


--
-- TOC entry 5159 (class 2606 OID 17566)
-- Name: visitor_status_audit visitor_status_audit_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.visitor_status_audit
    ADD CONSTRAINT visitor_status_audit_pkey PRIMARY KEY (id);


--
-- TOC entry 5112 (class 2606 OID 17213)
-- Name: visitor_types visitor_types_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.visitor_types
    ADD CONSTRAINT visitor_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5114 (class 2606 OID 17215)
-- Name: visitor_types visitor_types_type_name_key; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.visitor_types
    ADD CONSTRAINT visitor_types_type_name_key UNIQUE (type_name);


--
-- TOC entry 5117 (class 2606 OID 17238)
-- Name: visitors visitors_pass_no_key; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.visitors
    ADD CONSTRAINT visitors_pass_no_key UNIQUE (pass_no);


--
-- TOC entry 5119 (class 2606 OID 17236)
-- Name: visitors visitors_pkey; Type: CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.visitors
    ADD CONSTRAINT visitors_pkey PRIMARY KEY (id);


--
-- TOC entry 5168 (class 1259 OID 17618)
-- Name: idx_hp_host_id; Type: INDEX; Schema: public; Owner: svr_user
--

CREATE INDEX idx_hp_host_id ON public.host_projects USING btree (host_id);


--
-- TOC entry 5169 (class 1259 OID 17619)
-- Name: idx_hp_project_id; Type: INDEX; Schema: public; Owner: svr_user
--

CREATE INDEX idx_hp_project_id ON public.host_projects USING btree (project_id);


--
-- TOC entry 5172 (class 1259 OID 17637)
-- Name: idx_rfid_cards_stock_status; Type: INDEX; Schema: public; Owner: svr_user
--

CREATE INDEX idx_rfid_cards_stock_status ON public.rfid_cards_stock USING btree (status);


--
-- TOC entry 5173 (class 1259 OID 17638)
-- Name: idx_rfid_cards_stock_uid; Type: INDEX; Schema: public; Owner: svr_user
--

CREATE INDEX idx_rfid_cards_stock_uid ON public.rfid_cards_stock USING btree (uid);


--
-- TOC entry 5160 (class 1259 OID 17643)
-- Name: idx_rfid_stock_status; Type: INDEX; Schema: public; Owner: svr_user
--

CREATE INDEX idx_rfid_stock_status ON public.rfid_stock USING btree (status);


--
-- TOC entry 5161 (class 1259 OID 17644)
-- Name: idx_rfid_stock_uid; Type: INDEX; Schema: public; Owner: svr_user
--

CREATE INDEX idx_rfid_stock_uid ON public.rfid_stock USING btree (uid);


--
-- TOC entry 5115 (class 1259 OID 17653)
-- Name: idx_visitors_can_register_labours; Type: INDEX; Schema: public; Owner: svr_user
--

CREATE INDEX idx_visitors_can_register_labours ON public.visitors USING btree (can_register_labours);


--
-- TOC entry 5182 (class 0 OID 0)
-- Name: access_logs_default_pkey; Type: INDEX ATTACH; Schema: public; Owner: svr_user
--

ALTER INDEX public.access_logs_pkey ATTACH PARTITION public.access_logs_default_pkey;


--
-- TOC entry 5218 (class 2620 OID 17621)
-- Name: host_projects trg_validate_host_project; Type: TRIGGER; Schema: public; Owner: svr_user
--

CREATE TRIGGER trg_validate_host_project BEFORE INSERT OR UPDATE ON public.host_projects FOR EACH ROW EXECUTE FUNCTION public.validate_host_project_department();


--
-- TOC entry 5206 (class 2606 OID 17443)
-- Name: access_logs access_logs_gate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE public.access_logs
    ADD CONSTRAINT access_logs_gate_id_fkey FOREIGN KEY (gate_id) REFERENCES public.gates(id);


--
-- TOC entry 5194 (class 2606 OID 17298)
-- Name: biometric_data biometric_data_visitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.biometric_data
    ADD CONSTRAINT biometric_data_visitor_id_fkey FOREIGN KEY (visitor_id) REFERENCES public.visitors(id) ON DELETE CASCADE;


--
-- TOC entry 5195 (class 2606 OID 17314)
-- Name: biometric_match_audit biometric_match_audit_gate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.biometric_match_audit
    ADD CONSTRAINT biometric_match_audit_gate_id_fkey FOREIGN KEY (gate_id) REFERENCES public.gates(id);


--
-- TOC entry 5197 (class 2606 OID 17360)
-- Name: card_reissue_log card_reissue_log_aso_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.card_reissue_log
    ADD CONSTRAINT card_reissue_log_aso_document_id_fkey FOREIGN KEY (aso_document_id) REFERENCES public.visitor_documents(id);


--
-- TOC entry 5198 (class 2606 OID 17355)
-- Name: card_reissue_log card_reissue_log_new_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.card_reissue_log
    ADD CONSTRAINT card_reissue_log_new_card_id_fkey FOREIGN KEY (new_card_id) REFERENCES public.rfid_cards(id);


--
-- TOC entry 5199 (class 2606 OID 17350)
-- Name: card_reissue_log card_reissue_log_old_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.card_reissue_log
    ADD CONSTRAINT card_reissue_log_old_card_id_fkey FOREIGN KEY (old_card_id) REFERENCES public.rfid_cards(id);


--
-- TOC entry 5200 (class 2606 OID 17365)
-- Name: card_reissue_log card_reissue_log_reissued_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.card_reissue_log
    ADD CONSTRAINT card_reissue_log_reissued_by_fkey FOREIGN KEY (reissued_by) REFERENCES public.users(id);


--
-- TOC entry 5214 (class 2606 OID 17608)
-- Name: host_projects fk_hp_host; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.host_projects
    ADD CONSTRAINT fk_hp_host FOREIGN KEY (host_id) REFERENCES public.hosts(id) ON DELETE CASCADE;


--
-- TOC entry 5215 (class 2606 OID 17613)
-- Name: host_projects fk_hp_project; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.host_projects
    ADD CONSTRAINT fk_hp_project FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- TOC entry 5216 (class 2606 OID 17682)
-- Name: visitor_gate_permissions fk_vgp_gate; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.visitor_gate_permissions
    ADD CONSTRAINT fk_vgp_gate FOREIGN KEY (gate_id) REFERENCES public.gates(id) ON DELETE CASCADE;


--
-- TOC entry 5217 (class 2606 OID 17677)
-- Name: visitor_gate_permissions fk_vgp_visitor; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.visitor_gate_permissions
    ADD CONSTRAINT fk_vgp_visitor FOREIGN KEY (visitor_id) REFERENCES public.visitors(id) ON DELETE CASCADE;


--
-- TOC entry 5210 (class 2606 OID 17537)
-- Name: gate_health gate_health_gate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.gate_health
    ADD CONSTRAINT gate_health_gate_id_fkey FOREIGN KEY (gate_id) REFERENCES public.gates(id);


--
-- TOC entry 5211 (class 2606 OID 17551)
-- Name: gate_health_logs gate_health_logs_gate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.gate_health_logs
    ADD CONSTRAINT gate_health_logs_gate_id_fkey FOREIGN KEY (gate_id) REFERENCES public.gates(id);


--
-- TOC entry 5186 (class 2606 OID 17198)
-- Name: gates gates_entrance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.gates
    ADD CONSTRAINT gates_entrance_id_fkey FOREIGN KEY (entrance_id) REFERENCES public.entrances(id);


--
-- TOC entry 5185 (class 2606 OID 17172)
-- Name: hosts hosts_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.hosts
    ADD CONSTRAINT hosts_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- TOC entry 5203 (class 2606 OID 17411)
-- Name: labour_manifests labour_manifests_supervisor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.labour_manifests
    ADD CONSTRAINT labour_manifests_supervisor_id_fkey FOREIGN KEY (supervisor_id) REFERENCES public.visitors(id);


--
-- TOC entry 5202 (class 2606 OID 17395)
-- Name: labour_tokens labour_tokens_labour_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.labour_tokens
    ADD CONSTRAINT labour_tokens_labour_id_fkey FOREIGN KEY (labour_id) REFERENCES public.labours(id);


--
-- TOC entry 5201 (class 2606 OID 17381)
-- Name: labours labours_supervisor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.labours
    ADD CONSTRAINT labours_supervisor_id_fkey FOREIGN KEY (supervisor_id) REFERENCES public.visitors(id);


--
-- TOC entry 5204 (class 2606 OID 17428)
-- Name: manifest_labours manifest_labours_labour_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.manifest_labours
    ADD CONSTRAINT manifest_labours_labour_id_fkey FOREIGN KEY (labour_id) REFERENCES public.labours(id);


--
-- TOC entry 5205 (class 2606 OID 17423)
-- Name: manifest_labours manifest_labours_manifest_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.manifest_labours
    ADD CONSTRAINT manifest_labours_manifest_id_fkey FOREIGN KEY (manifest_id) REFERENCES public.labour_manifests(id);


--
-- TOC entry 5207 (class 2606 OID 17486)
-- Name: material_transactions material_transactions_material_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.material_transactions
    ADD CONSTRAINT material_transactions_material_id_fkey FOREIGN KEY (material_id) REFERENCES public.materials(id);


--
-- TOC entry 5208 (class 2606 OID 17481)
-- Name: material_transactions material_transactions_visitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.material_transactions
    ADD CONSTRAINT material_transactions_visitor_id_fkey FOREIGN KEY (visitor_id) REFERENCES public.visitors(id);


--
-- TOC entry 5184 (class 2606 OID 17578)
-- Name: projects projects_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id) ON DELETE CASCADE;


--
-- TOC entry 5196 (class 2606 OID 17334)
-- Name: rfid_cards rfid_cards_visitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.rfid_cards
    ADD CONSTRAINT rfid_cards_visitor_id_fkey FOREIGN KEY (visitor_id) REFERENCES public.visitors(id);


--
-- TOC entry 5209 (class 2606 OID 17525)
-- Name: sync_queue sync_queue_gate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.sync_queue
    ADD CONSTRAINT sync_queue_gate_id_fkey FOREIGN KEY (gate_id) REFERENCES public.gates(id);


--
-- TOC entry 5183 (class 2606 OID 17128)
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- TOC entry 5193 (class 2606 OID 17280)
-- Name: visitor_documents visitor_documents_visitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.visitor_documents
    ADD CONSTRAINT visitor_documents_visitor_id_fkey FOREIGN KEY (visitor_id) REFERENCES public.visitors(id) ON DELETE CASCADE;


--
-- TOC entry 5212 (class 2606 OID 17572)
-- Name: visitor_status_audit visitor_status_audit_changed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.visitor_status_audit
    ADD CONSTRAINT visitor_status_audit_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES public.users(id);


--
-- TOC entry 5213 (class 2606 OID 17567)
-- Name: visitor_status_audit visitor_status_audit_visitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.visitor_status_audit
    ADD CONSTRAINT visitor_status_audit_visitor_id_fkey FOREIGN KEY (visitor_id) REFERENCES public.visitors(id);


--
-- TOC entry 5187 (class 2606 OID 17264)
-- Name: visitors visitors_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.visitors
    ADD CONSTRAINT visitors_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- TOC entry 5188 (class 2606 OID 17249)
-- Name: visitors visitors_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.visitors
    ADD CONSTRAINT visitors_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- TOC entry 5189 (class 2606 OID 17259)
-- Name: visitors visitors_entrance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.visitors
    ADD CONSTRAINT visitors_entrance_id_fkey FOREIGN KEY (entrance_id) REFERENCES public.entrances(id);


--
-- TOC entry 5190 (class 2606 OID 17254)
-- Name: visitors visitors_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.visitors
    ADD CONSTRAINT visitors_host_id_fkey FOREIGN KEY (host_id) REFERENCES public.hosts(id);


--
-- TOC entry 5191 (class 2606 OID 17244)
-- Name: visitors visitors_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.visitors
    ADD CONSTRAINT visitors_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- TOC entry 5192 (class 2606 OID 17239)
-- Name: visitors visitors_visitor_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: svr_user
--

ALTER TABLE ONLY public.visitors
    ADD CONSTRAINT visitors_visitor_type_id_fkey FOREIGN KEY (visitor_type_id) REFERENCES public.visitor_types(id);


-- Completed on 2026-03-10 21:24:13

--
-- PostgreSQL database dump complete
--

\unrestrict JFgQKx13EBmmTqzfnMIuZbQwUW207d8TUG8fW6GB8npM0nA28JtrQOKHx8KzrDX

