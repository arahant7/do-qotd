from model import *

import os
import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import datetime
from datetime import timedelta
from collections import namedtuple
import bcrypt

DB_CONN_PSYCOPG_LOCAL="dbname=democon user=kurtrips host=localhost"

    
SQL_GET_CURRENT_POLL = """
SELECT * FROM poll WHERE NOW() < end_ts AND NOW() > start_ts
"""

SQL_GET_ANSWERS_FOR_QUESTION = """
SELECT a.*, p.poll_id FROM answer a 
INNER JOIN poll p ON a.question_id = p.question_id
WHERE a.question_id = %s 
ORDER BY a.answer_id
"""

SQL_GET_NUM_VOTES_FOR_POLL = """
SELECT COUNT(*) as nv FROM vote WHERE poll_id = %s
"""

#This query is written like this so that even if there are 0 votes for an answer, it is still returned. a1 is all answers for question, a2 is the count of votes for that answer
SQL_GET_VOTES_FOR_POLL = """
SELECT 
    a1.answer_id, 
    COALESCE(a2.anv,0) as answer_net_votes, 
    v.vote_id IS NOT NULL as has_user_voted
FROM answer a1
LEFT JOIN (SELECT answer_id, COUNT(*) as anv FROM vote WHERE poll_id = %s GROUP BY answer_id) as a2 ON a1.answer_id = a2.answer_id
LEFT JOIN vote v ON a1.answer_id = v.answer_id AND v.usr_id = %s
WHERE a1.question_id = (SELECT question_id FROM poll WHERE poll_id = %s) 
ORDER BY a1.answer_id;
"""

SQL_GET_POLL_VOTE_FOR_USER = """
SELECT answer_id FROM vote WHERE usr_id = %s AND poll_id = %s
"""

SQL_INSERT_POLL = """
INSERT INTO poll(start_ts, end_ts, question_id) values (%s, %s, %s) 
ON CONFLICT DO NOTHING
"""

SQL_GET_USER_BY_USERNAME = """
SELECT * FROM usr WHERE username = %s
"""

SQL_GET_USER_BY_EMAIL = """
SELECT * FROM usr WHERE email = %s
"""

SQL_INSERT_USER = """
INSERT INTO usr(username, password, email, name) VALUES(%s, %s, %s, %s)
"""

SQL_INSERT_VOTE = """
INSERT INTO vote(poll_id, usr_id, answer_id) VALUES(%s, %s, %s)
ON CONFLICT (poll_id, usr_id) DO UPDATE SET answer_id = %s, create_ts = NOW()
"""

SQL_INSERT_UPDOWNVOTE = """
INSERT INTO updownvote(usr_id, on_key, on_id, amount) VALUES(%s, %s, %s, %s)
ON CONFLICT (usr_id, on_key, on_id) DO UPDATE SET amount = %s, create_ts = NOW()
"""

SQL_GET_UPDOWNVOTES = """
SELECT COALESCE(SUM(amount),0) as net_vote FROM updownvote 
WHERE on_key = %s AND on_id = %s
"""

SQL_GET_UPDOWNVOTES_FOR_USR = """
SELECT on_id, amount FROM updownvote 
WHERE on_key = %s AND on_id IN %s AND usr_id = %s
"""

SQL_INSERT_COMMENT = """
INSERT INTO comment(usr_id, question_id, comment, in_reply_to) VALUES(%s, %s, %s, %s)
"""

SQL_INSERT_REFERENCE = """
INSERT INTO reference(usr_id, question_id, title, url) VALUES(%s, %s, %s, %s)
"""

SQL_INSERT_QUESTION = """
INSERT INTO question(creator_id, question) VALUES(%s, %s) RETURNING question_id
"""

SQL_INSERT_ANSWER = """
INSERT INTO answer(usr_id, question_id, answer) VALUES(%s, %s, %s)
"""


# data should be a dict
DaoResult = namedtuple('DaoResult', ['success', 'message', 'data'])

   
def get_votd(usr_id):
    if usr_id is None:
        usr_id = 0

    conn = psycopg2.connect(DB_CONN_PSYCOPG_LOCAL)
    cur = conn.cursor(cursor_factory=RealDictCursor)

    q = get_current_poll_with_question()

    cur.execute(SQL_GET_NUM_VOTES_FOR_POLL, (q['poll_id'], ))
    nv = cur.fetchone()
    q.update(nv)

    #answers
    cur.execute(SQL_GET_ANSWERS_FOR_QUESTION, (q['question_id'], ))
    a = cur.fetchall()
    av = []
    if usr_id > 0:
        #get the votes currently for display
        cur.execute(SQL_GET_VOTES_FOR_POLL, (q['poll_id'], usr_id, q['poll_id']))
        av = cur.fetchall()

    #reference
    r = get_references(usr_id, q['question_id'], cur=cur)

    #comments
    c = get_comments(usr_id, q['question_id'], cur=cur)

    #questions created between current qotd's start_ts and end_ts are questions for tomorrow
    qft = get_questions_between(q['start_ts'], q['end_ts'], usr_id, cur=cur)

    conn.close()
    return {'q':q, 'a':a, 'r':r, 'c':c, 'qft':qft, 'av':av}

SQL_GET_CURRENT_POLL_WITH_QUESTION = """
SELECT p.*, q.* FROM poll p 
INNER JOIN question q ON p.question_id = q.question_id
WHERE p.start_ts < NOW() AND p.end_ts > NOW() 
ORDER BY p.end_ts LIMIT 1
"""

def get_current_poll_with_question(cur=None):
    new_conn = None
    if not cur:
        new_conn = psycopg2.connect(DB_CONN_PSYCOPG_LOCAL)
        cur = new_conn.cursor(cursor_factory=RealDictCursor)

    cur.execute(SQL_GET_CURRENT_POLL_WITH_QUESTION)
    q = cur.fetchone()
    
    if new_conn:
        new_conn.close()

    return q
 
SQL_GET_COMMENTS = """ 
SELECT c.*, u.name as user_name, COALESCE(net_udv_vote, 0) as net_vote, COALESCE(net_udv_vote_user, 0) as net_vote_user  
FROM comment c  
INNER JOIN usr u ON c.usr_id = u.usr_id  
LEFT JOIN (SELECT on_id, SUM(amount) as net_udv_vote FROM updownvote WHERE on_key = 'Comment' GROUP BY on_id) as cv ON c.comment_id = cv.on_id 
LEFT JOIN (SELECT on_id, SUM(amount) as net_udv_vote_user FROM updownvote WHERE usr_id = %s AND on_key = 'Comment' GROUP BY on_id) as cvu ON cvu.on_id = cv.on_id 
WHERE question_id = %s ORDER BY {} {} LIMIT {} 
""" 

def get_comments(usr_id, question_id, limit=3, sort_on='net_vote', sort_dir='DESC', cur=None):
    query = SQL_GET_COMMENTS.format(sort_on, sort_dir, limit) 

    new_conn = None
    if not cur:
        new_conn = psycopg2.connect(DB_CONN_PSYCOPG_LOCAL)
        cur = new_conn.cursor(cursor_factory=RealDictCursor)

    cur.execute(query, (usr_id, question_id))
    c = cur.fetchall()

    if new_conn:
        new_conn.close()

    return c

SQL_GET_REFERENCES = """
SELECT r.*, u.name as user_name, COALESCE(net_udv_vote, 0) as net_vote, COALESCE(net_udv_vote_user, 0) as net_vote_user 
FROM reference r 
INNER JOIN usr u ON r.usr_id = u.usr_id
LEFT JOIN (SELECT on_id, SUM(amount) as net_udv_vote FROM updownvote WHERE on_key = 'Reference' GROUP BY on_id) as rv ON r.reference_id = rv.on_id
LEFT JOIN (SELECT on_id, SUM(amount) as net_udv_vote_user FROM updownvote WHERE usr_id = %s AND on_key = 'Reference' GROUP BY on_id) as rvu ON rvu.on_id = rv.on_id
WHERE question_id = %s ORDER BY {} {} LIMIT {}
""" 

def get_references(usr_id, question_id, limit=3, sort_on='net_vote', sort_dir='DESC', cur=None):
    query = SQL_GET_REFERENCES.format(sort_on, sort_dir, limit) 

    new_conn = None
    if not cur:
        new_conn = psycopg2.connect(DB_CONN_PSYCOPG_LOCAL)
        cur = new_conn.cursor(cursor_factory=RealDictCursor)

    cur.execute(query, (usr_id, question_id))
    r = cur.fetchall()

    if new_conn:
        new_conn.close()

    return r

SQL_GET_QUESTIONS_BETWEEN = """
SELECT q.*, COALESCE(net_udv_vote, 0) as net_vote, COALESCE(net_udv_vote_user, 0) as net_vote_user 
FROM question q
LEFT JOIN (SELECT on_id, SUM(amount) as net_udv_vote FROM updownvote WHERE on_key = 'Question' GROUP BY on_id) as qv ON q.question_id = qv.on_id
LEFT JOIN (SELECT on_id, SUM(amount) as net_udv_vote_user FROM updownvote WHERE usr_id = %s AND on_key = 'Question' GROUP BY on_id) as qvu ON qvu.on_id = qv.on_id
WHERE q.create_ts > %s and q.create_ts < %s ORDER BY {} {} LIMIT {}
""" 

def get_questions_between(start_ts, end_ts, usr_id=0, limit=3, sort_on='net_vote', sort_dir='DESC', cur=None):
    query = SQL_GET_QUESTIONS_BETWEEN.format(sort_on, sort_dir, limit) 

    new_conn = None
    if not cur:
        new_conn = psycopg2.connect(DB_CONN_PSYCOPG_LOCAL)
        cur = new_conn.cursor(cursor_factory=RealDictCursor)

    cur.execute(query, (usr_id, start_ts, end_ts))
    r = cur.fetchall()

    if new_conn:
        new_conn.close()

    return r


def create_next_poll():
    conn = psycopg2.connect(DB_CONN_PSYCOPG_LOCAL)
    cur = conn.cursor(cursor_factory=RealDictCursor)
    cur.execute(SQL_GET_CURRENT_POLL)
    p = cur.fetchone()
    #TODO - what if p is null

    #next poll is created roughly 5 minutes before the end of current poll
    timeleft = p['end_ts'] - datetime.utcnow()
    if not (timeleft.days == 0 and timeleft.seconds < 300):
        conn.close()
        return

    #get highest rated question for tomorrow
    qft = get_questions_between(q['start_ts'], q['end_ts'], limit=1)
    np = cur.fetchone()
    #TODO - what if np is null

    #insert the entry into poll
    cur.execute(SQL_INSERT_POLL,
        (p['end_ts'], p['end_ts'] + timedelta(days=1), np['question_id']))

    conn.commit()
    conn.close()

def validate_login(username, password):
    pwbytes = password.encode('utf-8')

    conn = psycopg2.connect(DB_CONN_PSYCOPG_LOCAL)
    cur = conn.cursor(cursor_factory=RealDictCursor)
    cur.execute(SQL_GET_USER_BY_USERNAME, (username, ))
    u = cur.fetchone()
    if u is None:
        conn.close()
        return DaoResult(False, "Invalid username or password", None)

    conn.close()
    pwhashed_from_db = bytes(u['password'])
    del u['password']
    res = DaoResult(bcrypt.checkpw(pwbytes, pwhashed_from_db), "", u)
    return res;


def register_user(username, password, email, name):
    pwbytes = password.encode('utf-8')
    pwhashed = bcrypt.hashpw(pwbytes, bcrypt.gensalt())

    conn = psycopg2.connect(DB_CONN_PSYCOPG_LOCAL)
    cur = conn.cursor(cursor_factory=RealDictCursor)

    #check for username already existing
    cur.execute(SQL_GET_USER_BY_USERNAME, (username, ))
    u = cur.fetchone()
    if u is not None:
        conn.close()
        return DaoResult(False, "This username is already taken", None)

    #check for email already existing
    cur.execute(SQL_GET_USER_BY_EMAIL, (email, ))
    u = cur.fetchone()
    if u is not None:
        conn.close()
        return DaoResult(False, "User with this email already exists", None)
    
    cur.execute(SQL_INSERT_USER, (username, pwhashed, email, name, ))
    conn.commit()
    conn.close()
    return DaoResult(True, "", None)
 
def save_vote(usr_id, poll_id, answer_id):
    conn = psycopg2.connect(DB_CONN_PSYCOPG_LOCAL)
    cur = conn.cursor(cursor_factory=RealDictCursor)
    
    #Check if poll is live
    p = get_current_poll_with_question()
    if p['poll_id'] != poll_id:
        conn.close()
        return DaoResult(False, "This poll is closed for voting.", None)

    #Check if answer does belong to poll question
    cur.execute(SQL_GET_ANSWERS_FOR_QUESTION, (p['question_id'],))
    al = cur.fetchall()
    if answer_id not in (a['answer_id'] for a in al):
        conn.close()
        return DaoResult(False, "This answer is not associated with poll", None)

    #insert the votes
    cur.execute(SQL_INSERT_VOTE, (poll_id, usr_id, answer_id, answer_id))
    
    #get the votes currently for display
    cur.execute(SQL_GET_VOTES_FOR_POLL, (poll_id, usr_id, poll_id))
    res= cur.fetchall()

    conn.commit()
    conn.close()
    return DaoResult(True, "", res)


def save_updownvote(usr_id, on_key, on_id, amount):
    if amount not in [-1,1]:
        return DaoResult(False, "Invalid updownvote amount", None)
    
    conn = psycopg2.connect(DB_CONN_PSYCOPG_LOCAL)
    cur = conn.cursor(cursor_factory=RealDictCursor)
    
    #save the updownvote
    cur.execute(SQL_INSERT_UPDOWNVOTE, (usr_id, on_key, on_id, amount, amount))

    #get how many votes there are currently on the given item
    cur.execute(SQL_GET_UPDOWNVOTES, (on_key, on_id))
    res = cur.fetchone()

    conn.commit()
    conn.close()
    return DaoResult(True, "", res)



def save_comment(usr_id, question_id, comment, in_reply_to):
    conn = psycopg2.connect(DB_CONN_PSYCOPG_LOCAL)
    cur = conn.cursor(cursor_factory=RealDictCursor)
    
    #Check if poll is live
    p = get_current_poll_with_question()
    if p['question_id'] != question_id:
        conn.close()
        return DaoResult(False, "This poll is closed for comments.", None)

    #insert the comment
    cur.execute(SQL_INSERT_COMMENT, (usr_id, question_id, comment, in_reply_to))
    
    conn.commit()
    conn.close()
    return DaoResult(True, "", None)

def save_reference(usr_id, question_id, title, url):
    conn = psycopg2.connect(DB_CONN_PSYCOPG_LOCAL)
    cur = conn.cursor(cursor_factory=RealDictCursor)
    
    #Check if poll is live
    cur.execute(SQL_GET_CURRENT_POLL_WITH_QUESTION)
    p = cur.fetchone()
    if p['question_id'] != question_id:
        conn.close()
        return DaoResult(False, "This poll is closed for references.", None)

    #insert the reference
    cur.execute(SQL_INSERT_REFERENCE, (usr_id, question_id, title, url))
    
    conn.commit()
    conn.close()
    return DaoResult(True, "", None)

def save_question(usr_id, question, answers, references):
    conn = psycopg2.connect(DB_CONN_PSYCOPG_LOCAL)
    cur = conn.cursor(cursor_factory=RealDictCursor)
    
    #insert the question
    cur.execute(SQL_INSERT_QUESTION, (usr_id, question))
    question_id = cur.fetchone()['question_id']
    for a in answers:
        cur.execute(SQL_INSERT_ANSWER, (usr_id, question_id, a))
    for r in references:
        cur.execute(SQL_INSERT_REFERENCE, (usr_id, question_id, r[0], r[1]))
    
    conn.commit()
    conn.close()
    return DaoResult(True, "", None)


SQL_GET_USER_COMMENT_ON_QUESTION  = """ 
SELECT c.*, u.name as user_name, COALESCE(net_udv_vote, 0) as net_vote
FROM comment c  
INNER JOIN usr u ON c.usr_id = u.usr_id  
LEFT JOIN (SELECT on_id, SUM(amount) as net_udv_vote FROM updownvote WHERE on_key = 'Comment' GROUP BY on_id) as cv ON c.comment_id = cv.on_id 
WHERE c.usr_id = %s AND c.question_id = %s
""" 

def get_user_comment_for_question(usr_id, question_id):
    conn = psycopg2.connect(DB_CONN_PSYCOPG_LOCAL)
    cur = conn.cursor(cursor_factory=RealDictCursor)
    
    #get the comment
    cur.execute(SQL_GET_USER_COMMENT_ON_QUESTION, (usr_id, question_id))
    c = cur.fetchone()
    
    conn.close()
    return c 

SQL_GET_USER_REFERENCE_ON_QUESTION  = """ 
SELECT r.*, u.name as user_name, COALESCE(net_udv_vote, 0) as net_vote
FROM reference r 
INNER JOIN usr u ON r.usr_id = u.usr_id
LEFT JOIN (SELECT on_id, SUM(amount) as net_udv_vote FROM updownvote WHERE on_key = 'Reference' GROUP BY on_id) as rv ON r.reference_id = rv.on_id
WHERE r.usr_id = %s AND r.question_id = %s
""" 

def get_user_reference_for_question(usr_id, question_id):
    conn = psycopg2.connect(DB_CONN_PSYCOPG_LOCAL)
    cur = conn.cursor(cursor_factory=RealDictCursor)
    
    #get the reference
    cur.execute(SQL_GET_USER_REFERENCE_ON_QUESTION, (usr_id, question_id))
    r = cur.fetchone()
    
    conn.close()
    return r 

SQL_GET_USER_QUESTIONS_BETWEEN = """
SELECT q.*, COALESCE(net_udv_vote, 0) as net_vote
FROM question q
LEFT JOIN (SELECT on_id, SUM(amount) as net_udv_vote FROM updownvote WHERE on_key = 'Question' GROUP BY on_id) as qv ON q.question_id = qv.on_id
WHERE q.create_ts > %s and q.create_ts < %s AND q.creator_id = %s 
""" 

def get_user_qft(usr_id):
    conn = psycopg2.connect(DB_CONN_PSYCOPG_LOCAL)
    cur = conn.cursor(cursor_factory=RealDictCursor)
    
    q = get_current_poll_with_question()

    #get the user qft
    cur.execute(SQL_GET_USER_QUESTIONS_BETWEEN, (q["start_ts"], q["end_ts"], usr_id, ))
    uqft = cur.fetchone()
    
    conn.close()
    return uqft

