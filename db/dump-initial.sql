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
-- Name: answer_id_seq; Type: SEQUENCE; Schema: public; Owner: democonuser
--

CREATE SEQUENCE answer_id_seq
    START WITH 37
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE answer_id_seq OWNER TO democonuser;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: answer; Type: TABLE; Schema: public; Owner: democonuser
--

CREATE TABLE answer (
    answer_id bigint DEFAULT nextval('answer_id_seq'::regclass) NOT NULL,
    answer character varying(128) NOT NULL,
    question_id bigint NOT NULL,
    usr_id bigint
);


ALTER TABLE answer OWNER TO democonuser;

--
-- Name: comment_id_seq; Type: SEQUENCE; Schema: public; Owner: democonuser
--

CREATE SEQUENCE comment_id_seq
    START WITH 37
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE comment_id_seq OWNER TO democonuser;

--
-- Name: comment; Type: TABLE; Schema: public; Owner: democonuser
--

CREATE TABLE comment (
    comment_id bigint DEFAULT nextval('comment_id_seq'::regclass) NOT NULL,
    usr_id bigint NOT NULL,
    question_id bigint NOT NULL,
    comment character varying(512) NOT NULL,
    in_reply_to bigint,
    create_ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE comment OWNER TO democonuser;

--
-- Name: configuration_id_seq; Type: SEQUENCE; Schema: public; Owner: democonuser
--

CREATE SEQUENCE configuration_id_seq
    START WITH 87
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE configuration_id_seq OWNER TO democonuser;

--
-- Name: configuration; Type: TABLE; Schema: public; Owner: democonuser
--

CREATE TABLE configuration (
    configuration_id bigint DEFAULT nextval('configuration_id_seq'::regclass) NOT NULL,
    key character varying(64) NOT NULL,
    value character varying(4096) NOT NULL
);


ALTER TABLE configuration OWNER TO democonuser;

--
-- Name: poll_id_seq; Type: SEQUENCE; Schema: public; Owner: democonuser
--

CREATE SEQUENCE poll_id_seq
    START WITH 11
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE poll_id_seq OWNER TO democonuser;

--
-- Name: poll; Type: TABLE; Schema: public; Owner: democonuser
--

CREATE TABLE poll (
    poll_id bigint DEFAULT nextval('poll_id_seq'::regclass) NOT NULL,
    start_ts timestamp(0) without time zone NOT NULL,
    end_ts timestamp(0) without time zone NOT NULL,
    question_id bigint NOT NULL
);


ALTER TABLE poll OWNER TO democonuser;

--
-- Name: question_id_seq; Type: SEQUENCE; Schema: public; Owner: democonuser
--

CREATE SEQUENCE question_id_seq
    START WITH 29
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE question_id_seq OWNER TO democonuser;

--
-- Name: question; Type: TABLE; Schema: public; Owner: democonuser
--

CREATE TABLE question (
    question_id bigint DEFAULT nextval('question_id_seq'::regclass) NOT NULL,
    question character varying(512) NOT NULL,
    creator_id bigint NOT NULL,
    create_ts timestamp(0) without time zone DEFAULT now() NOT NULL
);


ALTER TABLE question OWNER TO democonuser;

--
-- Name: reference_id_seq; Type: SEQUENCE; Schema: public; Owner: democonuser
--

CREATE SEQUENCE reference_id_seq
    START WITH 23
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE reference_id_seq OWNER TO democonuser;

--
-- Name: reference; Type: TABLE; Schema: public; Owner: democonuser
--

CREATE TABLE reference (
    reference_id bigint DEFAULT nextval('reference_id_seq'::regclass) NOT NULL,
    title character varying(128) NOT NULL,
    url character varying(4096) NOT NULL,
    question_id bigint NOT NULL,
    usr_id bigint NOT NULL,
    create_ts timestamp without time zone DEFAULT now()
);


ALTER TABLE reference OWNER TO democonuser;

--
-- Name: topic_id_seq; Type: SEQUENCE; Schema: public; Owner: democonuser
--

CREATE SEQUENCE topic_id_seq
    START WITH 19
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE topic_id_seq OWNER TO democonuser;

--
-- Name: topic; Type: TABLE; Schema: public; Owner: democonuser
--

CREATE TABLE topic (
    topic_id bigint DEFAULT nextval('topic_id_seq'::regclass) NOT NULL,
    topic character varying(32) NOT NULL
);


ALTER TABLE topic OWNER TO democonuser;

--
-- Name: updownvote_id_seq; Type: SEQUENCE; Schema: public; Owner: democonuser
--

CREATE SEQUENCE updownvote_id_seq
    START WITH 67
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE updownvote_id_seq OWNER TO democonuser;

--
-- Name: updownvote; Type: TABLE; Schema: public; Owner: democonuser
--

CREATE TABLE updownvote (
    updownvote_id bigint DEFAULT nextval('updownvote_id_seq'::regclass) NOT NULL,
    usr_id bigint NOT NULL,
    on_key character varying(16) NOT NULL,
    on_id bigint NOT NULL,
    amount smallint NOT NULL,
    create_ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE updownvote OWNER TO democonuser;

--
-- Name: usr_id_seq; Type: SEQUENCE; Schema: public; Owner: democonuser
--

CREATE SEQUENCE usr_id_seq
    START WITH 3
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE usr_id_seq OWNER TO democonuser;

--
-- Name: usr; Type: TABLE; Schema: public; Owner: democonuser
--

CREATE TABLE usr (
    usr_id bigint DEFAULT nextval('usr_id_seq'::regclass) NOT NULL,
    name character varying(45) NOT NULL,
    username character varying(32) NOT NULL,
    password bytea NOT NULL,
    email character varying(256) NOT NULL,
    create_ts timestamp without time zone
);


ALTER TABLE usr OWNER TO democonuser;

--
-- Name: vote_id_seq; Type: SEQUENCE; Schema: public; Owner: democonuser
--

CREATE SEQUENCE vote_id_seq
    START WITH 67
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE vote_id_seq OWNER TO democonuser;

--
-- Name: vote; Type: TABLE; Schema: public; Owner: democonuser
--

CREATE TABLE vote (
    vote_id bigint DEFAULT nextval('vote_id_seq'::regclass) NOT NULL,
    poll_id bigint NOT NULL,
    usr_id bigint NOT NULL,
    answer_id bigint NOT NULL,
    create_ts timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE vote OWNER TO democonuser;

--
-- Data for Name: answer; Type: TABLE DATA; Schema: public; Owner: democonuser
--

COPY answer (answer_id, answer, question_id, usr_id) FROM stdin;
37	Good	33	\N
38	Bad	33	\N
39	Don't know	33	\N
40	Yes	35	\N
41	No	35	\N
42	Don't know	35	\N
43	Yes	36	\N
44	No	36	\N
45	Don't know	36	\N
46	good	41	6
47	bad	41	6
48	ugly	41	6
49	They will die	42	6
50	They will get sold	42	6
51	They will survive until they IPO	42	6
52	Yes	43	6
53	No	43	6
\.


--
-- Name: answer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: democonuser
--

SELECT pg_catalog.setval('answer_id_seq', 53, true);


--
-- Data for Name: comment; Type: TABLE DATA; Schema: public; Owner: democonuser
--

COPY comment (comment_id, usr_id, question_id, comment, in_reply_to, create_ts) FROM stdin;
37	1	33	Hi Comment	\N	2017-06-29 22:01:42.044857
38	1	33	The problem with these filter bubbles is the fact that entities like Facebook encourage them and they are fundamental to their platform. To increase engagement in these platorms makes it really easy to just create a filter bubble. When Facebook becomes your primary information source you begin to unfollow or shut off topics.	\N	2017-06-29 22:01:42.044857
39	6	36	So-hi-this-is-a-comment	\N	2017-06-29 22:03:11.781806
40	6	36	Let's just hope this works!!!	\N	2017-06-29 22:17:07.205028
41	6	36	Let's try on more	\N	2017-06-29 22:20:02.194216
42	6	36	And again!!!!	\N	2017-06-29 22:20:12.263837
43	6	36	Jhantu jhaata lal!!	\N	2017-07-06 05:48:07.661427
44	6	36	Let's say that this is a comment with <script>alert('H')</script>	\N	2017-07-06 18:07:30.180131
45	6	36	Let's see if the <script>alert('Hi')</script> script fucks us up.	\N	2017-07-06 19:06:46.546836
\.


--
-- Name: comment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: democonuser
--

SELECT pg_catalog.setval('comment_id_seq', 45, true);


--
-- Data for Name: configuration; Type: TABLE DATA; Schema: public; Owner: democonuser
--

COPY configuration (configuration_id, key, value) FROM stdin;
\.


--
-- Name: configuration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: democonuser
--

SELECT pg_catalog.setval('configuration_id_seq', 87, false);


--
-- Data for Name: poll; Type: TABLE DATA; Schema: public; Owner: democonuser
--

COPY poll (poll_id, start_ts, end_ts, question_id) FROM stdin;
18	2017-06-13 06:33:00	2017-07-10 06:33:00	36
78	2017-06-23 06:33:00	2017-07-11 06:33:00	37
13	2017-06-07 00:00:00	2017-06-19 06:33:00	33
\.


--
-- Name: poll_id_seq; Type: SEQUENCE SET; Schema: public; Owner: democonuser
--

SELECT pg_catalog.setval('poll_id_seq', 82, true);


--
-- Data for Name: question; Type: TABLE DATA; Schema: public; Owner: democonuser
--

COPY question (question_id, question, creator_id, create_ts) FROM stdin;
33	How are you doing?	1	2017-06-03 00:47:00
35	Do you think democracy is the best system for electing government?	1	2017-06-08 01:45:00
36	Are trolls taking over the internet?	1	2017-06-08 08:48:00
37	Is Violence In Darjeeling A Failure Of Bengal’s Legacy?	1	2017-06-20 09:54:00
41	How is this question?	6	2017-07-05 06:45:29
42	What is Shopclues' future given that Amazon and Flipkart are 2 big stalwarts in the industry?	6	2017-07-05 19:28:44
43	Will GST solve our nation's tax problems?	6	2017-07-06 19:23:59
\.


--
-- Name: question_id_seq; Type: SEQUENCE SET; Schema: public; Owner: democonuser
--

SELECT pg_catalog.setval('question_id_seq', 43, true);


--
-- Data for Name: reference; Type: TABLE DATA; Schema: public; Owner: democonuser
--

COPY reference (reference_id, title, url, question_id, usr_id, create_ts) FROM stdin;
23	Democracy Never Faced a Threat Like Facebook	https://www.bloomberg.com/view/articles/2017-06-08/democracy-never-faced-a-threat-like-facebook	33	1	2017-06-08 19:27:04.402435
25	Powering Twitch and Medium, search startup Algolia raises $53 million	https://venturebeat.com/2017/06/08/powering-twitch-and-medium-search-startup-algolia-raises-53-million/	33	1	2017-06-08 19:27:04.402435
26	Sharad Sharma is a troll	https://medium.com/@jackerhack/inside-the-mind-of-indias-chief-tech-stack-evangelist-ca01e7a507a9	36	7	2017-06-18 13:56:00
27	Troll word was coined by leftists!	http://rightlog.in/2017/03/phogat-sisters-freedom-expression/	36	7	2017-06-18 13:59:00
28	Main Rules of the Internet	http://rulesoftheinternet.com/	36	6	2017-06-30 21:05:57.295483
29	t1	l1	41	6	2017-07-05 06:45:28.589382
30	t2	l2	41	6	2017-07-05 06:45:28.589382
31	t3	l3	41	6	2017-07-05 06:45:28.589382
32	negative integer division surprsing result	https://stackoverflow.com/q/5535206/354448	36	6	2017-07-05 19:19:29.328392
33	After two death traps, ShopClues finds a distinct space among lower-income Indians	https://factordaily.com/shopclues-sanjay-sethi-radhika-ghai-market-profit/	42	6	2017-07-05 19:28:43.833113
34	Amazon, Flipkart, Shopclues rush to make sellers GST compliant	http://www.financialexpress.com/industry/amazon-flipkart-shopclues-rush-to-make-sellers-gst-compliant/730118/	42	6	2017-07-05 19:28:43.833113
35	Heavy discounting by sc	http://www.jagran.com/technology/tech-news-shopclues-is-offering-heavy-discount-on-smartphones-16299952.html	42	6	2017-07-05 19:28:43.833113
36	Google's material color palette	https://material.io/guidelines/style/color.html#color-color-palette	36	6	2017-07-06 18:37:56.386019
37	Should you kill 5% of the most evil people?	https://www.quora.com/You-have-a-button-that-once-pressed-will-instantly-kill-5-of-the-population-formed-by-the-most-evil-people-on-earth-would-you-press-it	36	6	2017-07-06 19:05:14.365863
38	GST make in china	http://www.hindustantimes.com/analysis/with-gst-make-in-india-may-soon-become-make-in-china/story-uPRD98wchNU7mlF2vBJoaP.html	43	6	2017-07-06 19:23:58.934327
39	More than half of India not aware of GST: Survey	http://economictimes.indiatimes.com/news/economy/policy/more-than-half-of-people-in-india-not-aware-of-gst-survey/articleshow/59462641.cms	43	6	2017-07-06 19:23:58.934327
40	GST may dampen gold demand: WGC	http://www.thehindu.com/business/Economy/gst-may-dampen-gold-demand-wgc/article19225260.ece	43	6	2017-07-06 19:23:58.934327
\.


--
-- Name: reference_id_seq; Type: SEQUENCE SET; Schema: public; Owner: democonuser
--

SELECT pg_catalog.setval('reference_id_seq', 40, true);


--
-- Data for Name: topic; Type: TABLE DATA; Schema: public; Owner: democonuser
--

COPY topic (topic_id, topic) FROM stdin;
19	#Budget2017
\.


--
-- Name: topic_id_seq; Type: SEQUENCE SET; Schema: public; Owner: democonuser
--

SELECT pg_catalog.setval('topic_id_seq', 19, true);


--
-- Data for Name: updownvote; Type: TABLE DATA; Schema: public; Owner: democonuser
--

COPY updownvote (updownvote_id, usr_id, on_key, on_id, amount, create_ts) FROM stdin;
124	8	Question	36	1	2017-06-22 02:40:21.316861
125	8	Question	37	1	2017-06-22 02:40:47.99633
81	6	Reference	27	-1	2017-06-23 00:11:45.345683
80	6	Reference	26	1	2017-06-29 17:20:49.058214
132	6	Comment	39	-1	2017-06-29 22:04:00.083872
133	6	Comment	41	-1	2017-06-29 22:21:18.434349
134	6	Question	41	-1	2017-07-05 06:55:16.130602
67	6	Question	36	-1	2017-06-21 17:58:43.911126
69	6	Question	37	1	2017-06-21 18:26:32.961845
\.


--
-- Name: updownvote_id_seq; Type: SEQUENCE SET; Schema: public; Owner: democonuser
--

SELECT pg_catalog.setval('updownvote_id_seq', 134, true);


--
-- Data for Name: usr; Type: TABLE DATA; Schema: public; Owner: democonuser
--

COPY usr (usr_id, name, username, password, email, create_ts) FROM stdin;
6	Kabir	democonuser	\\x243262243132244359476434414475422e67396b53754b426a6c494b6567745576436f6362723363654c584b3757704e514241547254675648543861	democonuser@gmail.com	\N
1	aiman	aiman	\\x243262243132244359476434414475422e67396b53754b426a6c494b6567745576436f6362723363654c584b3757704e514241547254675648543861	aiman@democon.org	\N
3	Joe Smith	joe-smith	\\x243262243132244359476434414475422e67396b53754b426a6c494b6567745576436f6362723363654c584b3757704e514241547254675648543861	joesimith@democon.org	\N
7	Arahant Kumar	arahant7	\\x243262243132247457484e2e723475573161423364584770386334327551462f754b5539334d7a345448302f393177676e534e4e39306f70535a722e	arahant7@gmail.com	\N
8	Sameena	sameen7	\\x243262243132246b66324b6239503877683269753664532e7a4a55584f54613042675849392e426659737677494e76357371644a7a73673739334865	sameena42@hotmail.com	\N
9	Sameena	angrygirl	\\x2432622431322463544a6e5448692e30684559675470794e366844304f2f44594777626d776177666e6741512e6a38507746436c5374384331616b69	sameena@ubc.ca	\N
\.


--
-- Name: usr_id_seq; Type: SEQUENCE SET; Schema: public; Owner: democonuser
--

SELECT pg_catalog.setval('usr_id_seq', 9, true);


--
-- Data for Name: vote; Type: TABLE DATA; Schema: public; Owner: democonuser
--

COPY vote (vote_id, poll_id, usr_id, answer_id, create_ts) FROM stdin;
67	18	7	43	2017-06-19 22:43:36.308762
69	18	8	44	2017-06-19 22:43:36.308762
70	18	6	44	2017-06-29 18:55:14.893827
\.


--
-- Name: vote_id_seq; Type: SEQUENCE SET; Schema: public; Owner: democonuser
--

SELECT pg_catalog.setval('vote_id_seq', 107, true);


--
-- Name: answer answer_pkey; Type: CONSTRAINT; Schema: public; Owner: democonuser
--

ALTER TABLE ONLY answer
    ADD CONSTRAINT answer_pkey PRIMARY KEY (answer_id);


--
-- Name: comment comment_pkey; Type: CONSTRAINT; Schema: public; Owner: democonuser
--

ALTER TABLE ONLY comment
    ADD CONSTRAINT comment_pkey PRIMARY KEY (comment_id);


--
-- Name: configuration configuration_pkey; Type: CONSTRAINT; Schema: public; Owner: democonuser
--

ALTER TABLE ONLY configuration
    ADD CONSTRAINT configuration_pkey PRIMARY KEY (configuration_id);


--
-- Name: poll poll_pkey; Type: CONSTRAINT; Schema: public; Owner: democonuser
--

ALTER TABLE ONLY poll
    ADD CONSTRAINT poll_pkey PRIMARY KEY (poll_id);


--
-- Name: question question_pkey; Type: CONSTRAINT; Schema: public; Owner: democonuser
--

ALTER TABLE ONLY question
    ADD CONSTRAINT question_pkey PRIMARY KEY (question_id);


--
-- Name: reference reference_pkey; Type: CONSTRAINT; Schema: public; Owner: democonuser
--

ALTER TABLE ONLY reference
    ADD CONSTRAINT reference_pkey PRIMARY KEY (reference_id);


--
-- Name: topic topic_pkey; Type: CONSTRAINT; Schema: public; Owner: democonuser
--

ALTER TABLE ONLY topic
    ADD CONSTRAINT topic_pkey PRIMARY KEY (topic_id);


--
-- Name: poll unq_question_id; Type: CONSTRAINT; Schema: public; Owner: democonuser
--

ALTER TABLE ONLY poll
    ADD CONSTRAINT unq_question_id UNIQUE (question_id);


--
-- Name: updownvote unq_updown_vote1; Type: CONSTRAINT; Schema: public; Owner: democonuser
--

ALTER TABLE ONLY updownvote
    ADD CONSTRAINT unq_updown_vote1 UNIQUE (usr_id, on_key, on_id);


--
-- Name: usr unq_usr_email; Type: CONSTRAINT; Schema: public; Owner: democonuser
--

ALTER TABLE ONLY usr
    ADD CONSTRAINT unq_usr_email UNIQUE (email);


--
-- Name: usr unq_usr_username; Type: CONSTRAINT; Schema: public; Owner: democonuser
--

ALTER TABLE ONLY usr
    ADD CONSTRAINT unq_usr_username UNIQUE (username);


--
-- Name: vote unq_vote_1; Type: CONSTRAINT; Schema: public; Owner: democonuser
--

ALTER TABLE ONLY vote
    ADD CONSTRAINT unq_vote_1 UNIQUE (poll_id, usr_id);


--
-- Name: usr usr_pkey; Type: CONSTRAINT; Schema: public; Owner: democonuser
--

ALTER TABLE ONLY usr
    ADD CONSTRAINT usr_pkey PRIMARY KEY (usr_id);


--
-- Name: vote vote_pkey; Type: CONSTRAINT; Schema: public; Owner: democonuser
--

ALTER TABLE ONLY vote
    ADD CONSTRAINT vote_pkey PRIMARY KEY (vote_id);


--
-- Name: fk_answer_1_idx; Type: INDEX; Schema: public; Owner: democonuser
--

CREATE INDEX fk_answer_1_idx ON answer USING btree (question_id);


--
-- Name: fk_comment_1_idx; Type: INDEX; Schema: public; Owner: democonuser
--

CREATE INDEX fk_comment_1_idx ON comment USING btree (usr_id);


--
-- Name: fk_comment_2_idx; Type: INDEX; Schema: public; Owner: democonuser
--

CREATE INDEX fk_comment_2_idx ON comment USING btree (question_id);


--
-- Name: fk_comment_3_idx; Type: INDEX; Schema: public; Owner: democonuser
--

CREATE INDEX fk_comment_3_idx ON comment USING btree (in_reply_to);


--
-- Name: fk_poll_2_idx; Type: INDEX; Schema: public; Owner: democonuser
--

CREATE INDEX fk_poll_2_idx ON poll USING btree (question_id);


--
-- Name: fk_question_2_idx; Type: INDEX; Schema: public; Owner: democonuser
--

CREATE INDEX fk_question_2_idx ON question USING btree (creator_id);


--
-- Name: answer fk_answer_1; Type: FK CONSTRAINT; Schema: public; Owner: democonuser
--

ALTER TABLE ONLY answer
    ADD CONSTRAINT fk_answer_1 FOREIGN KEY (question_id) REFERENCES question(question_id);


--
-- Name: comment fk_comment_1; Type: FK CONSTRAINT; Schema: public; Owner: democonuser
--

ALTER TABLE ONLY comment
    ADD CONSTRAINT fk_comment_1 FOREIGN KEY (usr_id) REFERENCES usr(usr_id);


--
-- Name: comment fk_comment_2; Type: FK CONSTRAINT; Schema: public; Owner: democonuser
--

ALTER TABLE ONLY comment
    ADD CONSTRAINT fk_comment_2 FOREIGN KEY (question_id) REFERENCES question(question_id);


--
-- Name: comment fk_comment_3; Type: FK CONSTRAINT; Schema: public; Owner: democonuser
--

ALTER TABLE ONLY comment
    ADD CONSTRAINT fk_comment_3 FOREIGN KEY (in_reply_to) REFERENCES comment(comment_id);


--
-- Name: poll fk_poll_2; Type: FK CONSTRAINT; Schema: public; Owner: democonuser
--

ALTER TABLE ONLY poll
    ADD CONSTRAINT fk_poll_2 FOREIGN KEY (question_id) REFERENCES question(question_id);


--
-- Name: question fk_question_2; Type: FK CONSTRAINT; Schema: public; Owner: democonuser
--

ALTER TABLE ONLY question
    ADD CONSTRAINT fk_question_2 FOREIGN KEY (creator_id) REFERENCES usr(usr_id);


--
-- Name: reference fk_reference_1; Type: FK CONSTRAINT; Schema: public; Owner: democonuser
--

ALTER TABLE ONLY reference
    ADD CONSTRAINT fk_reference_1 FOREIGN KEY (usr_id) REFERENCES usr(usr_id);


--
-- Name: reference fk_reference_2; Type: FK CONSTRAINT; Schema: public; Owner: democonuser
--

ALTER TABLE ONLY reference
    ADD CONSTRAINT fk_reference_2 FOREIGN KEY (question_id) REFERENCES question(question_id);


--
-- Name: vote fk_vote_1; Type: FK CONSTRAINT; Schema: public; Owner: democonuser
--

ALTER TABLE ONLY vote
    ADD CONSTRAINT fk_vote_1 FOREIGN KEY (usr_id) REFERENCES usr(usr_id);


--
-- Name: vote fk_vote_2; Type: FK CONSTRAINT; Schema: public; Owner: democonuser
--

ALTER TABLE ONLY vote
    ADD CONSTRAINT fk_vote_2 FOREIGN KEY (answer_id) REFERENCES answer(answer_id);


--
-- Name: vote fk_vote_3; Type: FK CONSTRAINT; Schema: public; Owner: democonuser
--

ALTER TABLE ONLY vote
    ADD CONSTRAINT fk_vote_3 FOREIGN KEY (poll_id) REFERENCES poll(poll_id);


--
-- PostgreSQL database dump complete
--

