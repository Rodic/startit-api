--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id bigint NOT NULL,
    start_latitude numeric(9,7) NOT NULL,
    start_longitude numeric(10,7) NOT NULL,
    start_time timestamp with time zone NOT NULL,
    description character varying(500) NOT NULL,
    title character varying(150) DEFAULT NULL::character varying,
    type character varying(25) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    creator_id bigint,
    CONSTRAINT events_start_latitude_check CHECK (((start_latitude >= ((-90))::numeric) AND (start_latitude <= (90)::numeric))),
    CONSTRAINT events_start_longitude_check CHECK (((start_longitude >= ((-180))::numeric) AND (start_longitude <= (180)::numeric))),
    CONSTRAINT events_start_time_check CHECK ((start_time > now())),
    CONSTRAINT events_type_check CHECK (((type)::text = ANY ((ARRAY['Run'::character varying, 'BikeRide'::character varying])::text[])))
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id bigint NOT NULL,
    provider character varying(25) NOT NULL,
    uid character varying(256) NOT NULL,
    username character varying(100) NOT NULL,
    email character varying(150) DEFAULT NULL::character varying,
    latitude numeric(9,7) DEFAULT NULL::numeric,
    longitude numeric(10,7) DEFAULT NULL::numeric,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT users_latitude_check CHECK (((latitude >= ((-90))::numeric) AND (latitude <= (90)::numeric))),
    CONSTRAINT users_longitude_check CHECK (((longitude >= ((-180))::numeric) AND (longitude <= (180)::numeric))),
    CONSTRAINT users_provider_check CHECK (((provider)::text = ANY ((ARRAY['facebook'::character varying, 'google'::character varying])::text[])))
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: provider_uid_unique; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX provider_uid_unique ON users USING btree (provider, uid);


--
-- Name: start_latitude_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX start_latitude_idx ON events USING btree (start_latitude);


--
-- Name: start_longitude_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX start_longitude_idx ON events USING btree (start_longitude);


--
-- Name: start_time_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX start_time_idx ON events USING btree (start_time);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: events_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20150923140740');

INSERT INTO schema_migrations (version) VALUES ('20151001074257');

INSERT INTO schema_migrations (version) VALUES ('20151002085949');

