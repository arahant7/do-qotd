--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 9.6.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: answer_id_seq; Type: SEQUENCE; Schema: public; Owner: kurtrips
--

CREATE SEQUENCE answer_id_seq
    START WITH 37
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE answer_id_seq OWNER TO kurtrips;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: answer; Type: TABLE; Schema: public; Owner: kurtrips
--

CREATE TABLE answer (
    answer_id bigint DEFAULT nextval('answer_id_seq'::regclass) NOT NULL,
    answer character varying(128) NOT NULL,
    question_id bigint NOT NULL
);


ALTER TABLE answer OWNER TO kurtrips;

--
-- Name: answer_id; Type: SEQUENCE; Schema: public; Owner: kurtrips
--

CREATE SEQUENCE answer_id
    START WITH 37
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE answer_id OWNER TO kurtrips;

--
-- Name: comment_id_seq; Type: SEQUENCE; Schema: public; Owner: kurtrips
--

CREATE SEQUENCE comment_id_seq
    START WITH 37
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE comment_id_seq OWNER TO kurtrips;

--
-- Name: comment; Type: TABLE; Schema: public; Owner: kurtrips
--

CREATE TABLE comment (
    comment_id bigint DEFAULT nextval('comment_id_seq'::regclass) NOT NULL,
    usr_id bigint NOT NULL,
    question_id bigint NOT NULL,
    comment character varying(512) NOT NULL,
    in_reply_to bigint
);


ALTER TABLE comment OWNER TO kurtrips;

--
-- Name: configuration_id_seq; Type: SEQUENCE; Schema: public; Owner: kurtrips
--

CREATE SEQUENCE configuration_id_seq
    START WITH 87
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE configuration_id_seq OWNER TO kurtrips;

--
-- Name: configuration; Type: TABLE; Schema: public; Owner: kurtrips
--

CREATE TABLE configuration (
    configuration_id bigint DEFAULT nextval('configuration_id_seq'::regclass) NOT NULL,
    key character varying(64) NOT NULL,
    value character varying(4096) NOT NULL
);


ALTER TABLE configuration OWNER TO kurtrips;

--
-- Name: poll_id_seq; Type: SEQUENCE; Schema: public; Owner: kurtrips
--

CREATE SEQUENCE poll_id_seq
    START WITH 11
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE poll_id_seq OWNER TO kurtrips;

--
-- Name: poll; Type: TABLE; Schema: public; Owner: kurtrips
--

CREATE TABLE poll (
    poll_id bigint DEFAULT nextval('poll_id_seq'::regclass) NOT NULL,
    start_ts timestamp(0) without time zone NOT NULL,
    end_ts timestamp(0) without time zone NOT NULL,
    question_id bigint NOT NULL
);


ALTER TABLE poll OWNER TO kurtrips;

--
-- Name: question_id_seq; Type: SEQUENCE; Schema: public; Owner: kurtrips
--

CREATE SEQUENCE question_id_seq
    START WITH 29
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE question_id_seq OWNER TO kurtrips;

--
-- Name: question; Type: TABLE; Schema: public; Owner: kurtrips
--

CREATE TABLE question (
    question_id bigint DEFAULT nextval('question_id_seq'::regclass) NOT NULL,
    question character varying(512) NOT NULL,
    creator_id bigint NOT NULL,
    create_ts timestamp(0) without time zone NOT NULL
);


ALTER TABLE question OWNER TO kurtrips;

--
-- Name: reference_id_seq; Type: SEQUENCE; Schema: public; Owner: kurtrips
--

CREATE SEQUENCE reference_id_seq
    START WITH 23
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE reference_id_seq OWNER TO kurtrips;

--
-- Name: reference; Type: TABLE; Schema: public; Owner: kurtrips
--

CREATE TABLE reference (
    reference_id bigint DEFAULT nextval('reference_id_seq'::regclass) NOT NULL,
    title character varying(128) NOT NULL,
    url character varying(4096) NOT NULL,
    question_id bigint NOT NULL,
    usr_id bigint NOT NULL,
    create_ts timestamp without time zone DEFAULT now()
);


ALTER TABLE reference OWNER TO kurtrips;

--
-- Name: topic_id_seq; Type: SEQUENCE; Schema: public; Owner: kurtrips
--

CREATE SEQUENCE topic_id_seq
    START WITH 19
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE topic_id_seq OWNER TO kurtrips;

--
-- Name: topic; Type: TABLE; Schema: public; Owner: kurtrips
--

CREATE TABLE topic (
    topic_id bigint DEFAULT nextval('topic_id_seq'::regclass) NOT NULL,
    topic character varying(32) NOT NULL
);


ALTER TABLE topic OWNER TO kurtrips;

--
-- Name: usr_id_seq; Type: SEQUENCE; Schema: public; Owner: kurtrips
--

CREATE SEQUENCE usr_id_seq
    START WITH 3
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE usr_id_seq OWNER TO kurtrips;

--
-- Name: usr; Type: TABLE; Schema: public; Owner: kurtrips
--

CREATE TABLE usr (
    usr_id bigint DEFAULT nextval('usr_id_seq'::regclass) NOT NULL,
    name character varying(45)
);


ALTER TABLE usr OWNER TO kurtrips;

--
-- Name: vote_id_seq; Type: SEQUENCE; Schema: public; Owner: kurtrips
--

CREATE SEQUENCE updownvote_id_seq
    START WITH 67
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE updownvote_id_seq OWNER TO kurtrips;

--
-- Name: vote; Type: TABLE; Schema: public; Owner: kurtrips
--

CREATE TABLE updownvote (
    updownvote_id bigint DEFAULT nextval('updownvote_id_seq'::regclass) NOT NULL,
    usr_id bigint NOT NULL,
    on_key character varying(16) NOT NULL,
    on_id bigint NOT NULL,
    amount smallint NOT NULL
);


ALTER TABLE vote OWNER TO kurtrips;

--
-- Name: vote_seq; Type: SEQUENCE; Schema: public; Owner: kurtrips
--

CREATE SEQUENCE vote_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE vote_seq OWNER TO kurtrips;

--
-- Name: answer answer_pkey; Type: CONSTRAINT; Schema: public; Owner: kurtrips
--

ALTER TABLE ONLY answer
    ADD CONSTRAINT answer_pkey PRIMARY KEY (answer_id);


--
-- Name: comment comment_pkey; Type: CONSTRAINT; Schema: public; Owner: kurtrips
--

ALTER TABLE ONLY comment
    ADD CONSTRAINT comment_pkey PRIMARY KEY (comment_id);


--
-- Name: configuration configuration_pkey; Type: CONSTRAINT; Schema: public; Owner: kurtrips
--

ALTER TABLE ONLY configuration
    ADD CONSTRAINT configuration_pkey PRIMARY KEY (configuration_id);


--
-- Name: poll poll_pkey; Type: CONSTRAINT; Schema: public; Owner: kurtrips
--

ALTER TABLE ONLY poll
    ADD CONSTRAINT poll_pkey PRIMARY KEY (poll_id);


--
-- Name: question question_pkey; Type: CONSTRAINT; Schema: public; Owner: kurtrips
--

ALTER TABLE ONLY question
    ADD CONSTRAINT question_pkey PRIMARY KEY (question_id);


--
-- Name: reference reference_pkey; Type: CONSTRAINT; Schema: public; Owner: kurtrips
--

ALTER TABLE ONLY reference
    ADD CONSTRAINT reference_pkey PRIMARY KEY (reference_id);


--
-- Name: topic topic_pkey; Type: CONSTRAINT; Schema: public; Owner: kurtrips
--

ALTER TABLE ONLY topic
    ADD CONSTRAINT topic_pkey PRIMARY KEY (topic_id);


--
-- Name: poll unq_question_id; Type: CONSTRAINT; Schema: public; Owner: kurtrips
--

ALTER TABLE ONLY poll
    ADD CONSTRAINT unq_question_id UNIQUE (question_id);


--
-- Name: usr usr_pkey; Type: CONSTRAINT; Schema: public; Owner: kurtrips
--

ALTER TABLE ONLY usr
    ADD CONSTRAINT usr_pkey PRIMARY KEY (usr_id);


--
-- Name: vote vote_pkey; Type: CONSTRAINT; Schema: public; Owner: kurtrips
--

ALTER TABLE ONLY vote
    ADD CONSTRAINT vote_pkey PRIMARY KEY (vote_id);


--
-- Name: fk_answer_1_idx; Type: INDEX; Schema: public; Owner: kurtrips
--

CREATE INDEX fk_answer_1_idx ON answer USING btree (question_id);


--
-- Name: fk_comment_1_idx; Type: INDEX; Schema: public; Owner: kurtrips
--

CREATE INDEX fk_comment_1_idx ON comment USING btree (usr_id);


--
-- Name: fk_comment_2_idx; Type: INDEX; Schema: public; Owner: kurtrips
--

CREATE INDEX fk_comment_2_idx ON comment USING btree (question_id);


--
-- Name: fk_comment_3_idx; Type: INDEX; Schema: public; Owner: kurtrips
--

CREATE INDEX fk_comment_3_idx ON comment USING btree (in_reply_to);


--
-- Name: fk_poll_2_idx; Type: INDEX; Schema: public; Owner: kurtrips
--

CREATE INDEX fk_poll_2_idx ON poll USING btree (question_id);


--
-- Name: fk_question_2_idx; Type: INDEX; Schema: public; Owner: kurtrips
--

CREATE INDEX fk_question_2_idx ON question USING btree (creator_id);


--
-- Name: fk_vote_1_idx; Type: INDEX; Schema: public; Owner: kurtrips
--

CREATE INDEX fk_vote_1_idx ON vote USING btree (usr_id);


--
-- Name: answer fk_answer_1; Type: FK CONSTRAINT; Schema: public; Owner: kurtrips
--

ALTER TABLE ONLY answer
    ADD CONSTRAINT fk_answer_1 FOREIGN KEY (question_id) REFERENCES question(question_id);


--
-- Name: comment fk_comment_1; Type: FK CONSTRAINT; Schema: public; Owner: kurtrips
--

ALTER TABLE ONLY comment
    ADD CONSTRAINT fk_comment_1 FOREIGN KEY (usr_id) REFERENCES usr(usr_id);


--
-- Name: comment fk_comment_2; Type: FK CONSTRAINT; Schema: public; Owner: kurtrips
--

ALTER TABLE ONLY comment
    ADD CONSTRAINT fk_comment_2 FOREIGN KEY (question_id) REFERENCES question(question_id);


--
-- Name: comment fk_comment_3; Type: FK CONSTRAINT; Schema: public; Owner: kurtrips
--

ALTER TABLE ONLY comment
    ADD CONSTRAINT fk_comment_3 FOREIGN KEY (in_reply_to) REFERENCES comment(comment_id);


--
-- Name: poll fk_poll_2; Type: FK CONSTRAINT; Schema: public; Owner: kurtrips
--

ALTER TABLE ONLY poll
    ADD CONSTRAINT fk_poll_2 FOREIGN KEY (question_id) REFERENCES question(question_id);


--
-- Name: question fk_question_2; Type: FK CONSTRAINT; Schema: public; Owner: kurtrips
--

ALTER TABLE ONLY question
    ADD CONSTRAINT fk_question_2 FOREIGN KEY (creator_id) REFERENCES usr(usr_id);


--
-- Name: reference fk_reference_1; Type: FK CONSTRAINT; Schema: public; Owner: kurtrips
--

ALTER TABLE ONLY reference
    ADD CONSTRAINT fk_reference_1 FOREIGN KEY (usr_id) REFERENCES usr(usr_id);


--
-- Name: reference fk_reference_2; Type: FK CONSTRAINT; Schema: public; Owner: kurtrips
--

ALTER TABLE ONLY reference
    ADD CONSTRAINT fk_reference_2 FOREIGN KEY (question_id) REFERENCES question(question_id);


--
-- Name: vote fk_vote_1; Type: FK CONSTRAINT; Schema: public; Owner: kurtrips
--

ALTER TABLE ONLY vote
    ADD CONSTRAINT fk_vote_1 FOREIGN KEY (usr_id) REFERENCES usr(usr_id);


--
-- PostgreSQL database dump complete
--





CREATE SEQUENCE vote_id_seq
    START WITH 67
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE vote (
    vote_id bigint DEFAULT nextval('vote_id_seq'::regclass) NOT NULL,
    poll_id bigint NOT NULL,
    usr_id bigint NOT NULL,
    answer_id bigint NOT NULL,
    rank smallint NOT NULL DEFAULT 1,
    PRIMARY KEY (vote_id)
);

ALTER TABLE vote
    ADD CONSTRAINT fk_vote_1 FOREIGN KEY (usr_id) REFERENCES usr(usr_id);

ALTER TABLE vote
    ADD CONSTRAINT fk_vote_2 FOREIGN KEY (answer_id) REFERENCES answer(answer_id);

ALTER TABLE vote
    ADD CONSTRAINT fk_vote_3 FOREIGN KEY (poll_id) REFERENCES poll(poll_id);

ALTER TABLE vote
    ADD CONSTRAINT unq_vote_1 UNIQUE (usr_id, answer_id);

