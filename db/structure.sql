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
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sms_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sms_messages (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    phone_number character varying(15) NOT NULL,
    message text NOT NULL,
    message_id character varying(50),
    status character varying,
    status_code integer,
    total_tries integer,
    url_domain character varying,
    url_path character varying,
    tsv tsvector,
    discarded_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sms_messages sms_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sms_messages
    ADD CONSTRAINT sms_messages_pkey PRIMARY KEY (id);


--
-- Name: index_sms_messages_on_message_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sms_messages_on_message_id ON public.sms_messages USING gin (message_id public.gin_trgm_ops);


--
-- Name: index_sms_messages_on_phone_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sms_messages_on_phone_number ON public.sms_messages USING gin (phone_number public.gin_trgm_ops);


--
-- Name: index_sms_messages_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sms_messages_on_status ON public.sms_messages USING gin (status public.gin_trgm_ops);


--
-- Name: index_sms_messages_on_status_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sms_messages_on_status_code ON public.sms_messages USING btree (status_code);


--
-- Name: index_sms_messages_on_tsv; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sms_messages_on_tsv ON public.sms_messages USING gin (tsv);


--
-- Name: index_sms_messages_on_url_domain; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sms_messages_on_url_domain ON public.sms_messages USING gin (url_domain public.gin_trgm_ops);


--
-- Name: index_sms_messages_on_url_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sms_messages_on_url_path ON public.sms_messages USING gin (url_path public.gin_trgm_ops);


--
-- Name: sms_messages tsvectorupdate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE ON public.sms_messages FOR EACH ROW EXECUTE FUNCTION tsvector_update_trigger('tsv', 'pg_catalog.english', 'message');


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20200930004856'),
('20201004050205'),
('20201004050211');


