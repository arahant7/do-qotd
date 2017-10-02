import os
import json
from datetime import datetime

import dao
import helper
from forms import *
from model import *

from urllib.parse import urlparse, urljoin
from flask import Flask, Response, render_template, request, redirect, jsonify, session, flash, url_for, abort, make_response
from apscheduler.schedulers.background import BackgroundScheduler

app = Flask(__name__)
app.secret_key = "HYm5jULmutLUKCB2"
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://kurtrips@localhost:5432/democon'

#methods that are needed by jinja
app.add_template_global(json.dumps, "json_dumps")
app.add_template_global(helper.human_friendly_time, "human_friendly_time")

SESSION_KEY = "user"
STR_NOT_AUTHENTICATED="You are not authenticated. Please login first."
STR_INVALID_UDV_AMOUNT="Invalid updownvote amount"

def create_next_poll_task():
    dao.create_next_poll()

@app.before_first_request
def app_initialize():
    scheduler = BackgroundScheduler()
    scheduler.add_job(create_next_poll_task, 'interval', minutes=1)
    scheduler.start()


@app.route('/')
def home_view():
    if SESSION_KEY in session:
        usr_id = session[SESSION_KEY]['usr_id']
    else:
        usr_id = 0

    data = dao.get_poll_detail(usr_id=usr_id, question_id=None)
    return render_template('main.html', data=data)


@app.route('/register', methods=['GET'])
def register_view():
    return render_template('register.html')
    
@app.route('/register', methods=['POST'])
def register():
    form = RegisterForm(request.form)
    
    if not form.validate():
        return render_template('register.html', form=form)

    # save user
    res = dao.register_user(form.username.data, form.password.data, form.email.data, form.name.data)
    if not res.success:
        form.add_global_error(res.message)
        return render_template('register.html', form=form)

    flash('Registered successfully.')
    return redirect('/login')

@app.route('/login', methods=['GET'])
def login_view():
    return render_template('login.html')

@app.route('/login', methods=['POST'])
def login():
    form = LoginForm(request.form)
    
    if not form.validate():
        return render_template('login.html', form=form)

    # check login details
    res = dao.validate_login(form.username.data, form.password.data)
    if not res.success:
        form.add_global_error(res.message)
        return render_template('login.html', form=form)

    # what is the next page? and is it safe?
    next_url = request.args.get('next')
    if not is_safe_url(next_url):
        return flask.abort(400)
    
    session[SESSION_KEY] = res.data
    return redirect(next_url or '/')


@app.route('/logout', methods=['POST'])
def logout():
    session.pop(SESSION_KEY, None)
    return redirect('/')


@app.route('/polls/<int:poll_id>/vote/<int:answer_id>', methods=['POST'])
def vote(poll_id, answer_id):

    if SESSION_KEY not in session:
        abort(make_response(jsonify(message=STR_NOT_AUTHENTICATED), 401))
    u = session[SESSION_KEY]
    
    # write vote to db
    res = dao.save_vote(u['usr_id'], poll_id, answer_id)

    if not res.success:
        abort(make_response(jsonify(message=res.message), 400))

    return jsonify(res.data) 


@app.route('/questions/<int:question_id>/updownvote/<amt>', methods=['POST'])
def updownvote_question(question_id, amt):
    return updownvote('Question', question_id, amt)

@app.route('/references/<int:reference_id>/updownvote/<amt>', methods=['POST'])
def updownvote_reference(reference_id, amt):
    return updownvote('Reference', reference_id, amt)

@app.route('/comments/<int:comment_id>/updownvote/<amt>', methods=['POST'])
def updownvote_comment(comment_id, amt):
    return updownvote('Comment', comment_id, amt)


def updownvote(on_key, on_id, amt):
    try:
        amount = int(amt)
    except ValueError:
        abort(make_response(jsonify(message=STR_INVALID_UDV_AMOUNT), 400))

    if SESSION_KEY not in session:
        abort(make_response(jsonify(message=STR_NOT_AUTHENTICATED), 401))
    u = session[SESSION_KEY]

    # write updownvote to db
    res = dao.save_updownvote(u['usr_id'], on_key, on_id, amount)

    if not res.success:
        abort(make_response(jsonify(message=res.message), 400))

    return jsonify(res.data)


@app.route('/questions/<int:question_id>/comments', methods=['GET'])
def view_comments(question_id):
    if SESSION_KEY not in session:
        return redirect("/login?next={}".format(request.path))
    u = session[SESSION_KEY]

    sort_on = request.args.get('sort_on')
    if sort_on not in ['create_ts', 'net_vote']:
        sort_on = 'create_ts'
    
    c = dao.get_comments(u['usr_id'], question_id, sort_on=sort_on, limit=10)
    data = {'c':c, 'question_id':question_id}

    return render_template("comments.html", data=data)


@app.route('/questions/<int:question_id>/comments/create', methods=['GET'])
def view_new_comment(question_id):
    if SESSION_KEY not in session:
        return redirect("/login?next={}".format(request.path))
    u = session[SESSION_KEY]
    
    #Check if user has already commented on this poll 
    uc = dao.get_user_comment_for_question(u['usr_id'], question_id)

    data = {'uc': uc}
    return render_template("new-comment.html", data=data)


@app.route('/questions/<int:question_id>/comments/create', methods=['POST'])
def comment(question_id):
    comment = request.values['comment']
    in_reply_to = request.values['in_reply_to'] if 'in_reply_to' in request.values else None

    if SESSION_KEY not in session:
        return redirect("/login?next={}".format(request.path))
    u = session[SESSION_KEY]
    
    #Check if user has already commented on this poll 
    uc = dao.get_user_comment_for_question(u['usr_id'], question_id)
    if uc:
        abort(make_response(jsonify(message="You can comment only once for a question."), 400))

    # write comment to db
    res = dao.save_comment(u['usr_id'], question_id, comment, in_reply_to)

    if not res.success:
        abort(make_response(jsonify(message=res.message), 400))

    return redirect("/questions/{}/comments".format(question_id)) 


@app.route('/questions/<int:question_id>/references', methods=['GET'])
def view_references(question_id):
    if SESSION_KEY not in session:
        return redirect("/login?next={}".format(request.path))
    u = session[SESSION_KEY]
    
    r = dao.get_references(u['usr_id'], question_id, sort_on='create_ts', limit=10)
    data = {'r':r, 'question_id':question_id}
    return render_template("references.html", data=data)

@app.route('/questions/<int:question_id>/references/create', methods=['GET'])
def view_new_reference(question_id):
    if SESSION_KEY not in session:
        return redirect("/login?next={}".format(request.path))
    u = session[SESSION_KEY]
    
    #Check if user has already added reference on this poll 
    ur = dao.get_user_reference_for_question(u['usr_id'], question_id)

    data = {'ur': ur}
    return render_template("new-reference.html", data=data)

@app.route('/questions/<int:question_id>/references/create', methods=['POST'])
def create_reference(question_id):
    title = request.values['title']
    url = request.values['url']
    if not is_url(url):
        return render_template("new-reference.html", errors=["The reference link is not a valid url"]) 
     
    if SESSION_KEY not in session:
        return redirect("/login?next={}".format(request.path))
    u = session[SESSION_KEY]
    
    #Check if user has already added reference on this poll 
    ur = dao.get_user_reference_for_question(u['usr_id'], question_id)
    if ur:
        abort(make_response(jsonify(message="You can add reference only once for a question."), 400))

    # write reference to db
    res = dao.save_reference(u['usr_id'], question_id, title, url)

    if not res.success:
        abort(make_response(jsonify(message=res.message), 400))

    return redirect("questions/{}/references".format(question_id)) 

@app.route('/questions/create', methods=['GET'])
def view_create_question():
    if SESSION_KEY not in session:
        return redirect("/login?next={}".format(request.path))
    u = session[SESSION_KEY]
   
    #Check if user has already added question for tomorrow
    uqft = dao.get_user_qft(u['usr_id'])

    data = {'uqft': uqft}
    return render_template("new-question.html", data=data)

@app.route('/questions/create', methods=['POST'])
def create_question():
    if SESSION_KEY not in session:
        return redirect("/login?next={}".format(request.path))
    u = session[SESSION_KEY]
    
    #It's a pain to get this working on WTForms. So fuck it.
    question = request.values['question']
    answers = request.values.getlist('answer')
    titles = request.values.getlist('title')
    links = request.values.getlist('link')
    references = list(zip(titles, links))

    #remove empty elements from answers
    answers = [a.strip() for a in answers if a != "" and not a.isspace()]
    #remove empty elements from references (removed if both title and link are empty)
    references = [r for r in references if r[0] != "" and not r[0].isspace() and r[1] != "" and not r[1].isspace()]
    errors = validate_create_question(question, answers, references)
    if errors:
        return render_template("new-question.html", errors=errors, data={'q':question, 'a':answers, 'r':references})

    #Check if user has already added question for tomorrow
    uqft = dao.get_user_qft(u['usr_id'])
    if uqft:
        abort(make_response(jsonify(message="You can ask only one question for tomorrow."), 400))
        
    # write question to db
    res = dao.save_question(u['usr_id'], question, answers, references)
    
    if not res.success:
        abort(make_response(jsonify(message=res.message), 400))
    
    return redirect("questions/tomorrow")

def validate_create_question(question, answers, references):
    errors = []
    if len(question) < 10:
        errors.append("Question cannot be shorter than 10 characters")
    if len(question) > 512:
        errors.append("Question cannot be longer than 512 characters")
    if len(answers) < 2:
        errors.append("Please enter at least 2 answers")
    if len(references) < 3:
        errors.append("Please enter at least 3 references")
    if any('' == r[0] or r[0].isspace() for r in references):
        errors.append("Reference title cannot be empty")
    if any('' == r[1] or r[1].isspace() for r in references):
        errors.append("Reference links cannot be empty")
    return errors

@app.route('/questions/tomorrow', methods=['GET'])
def view_qft():
    if SESSION_KEY not in session:
        return redirect("/login?next={}".format(request.path))
    u = session[SESSION_KEY]
    
    p = dao.get_current_poll_with_question()

    qft = dao.get_questions_between(p['start_ts'], p['end_ts'], u['usr_id'], sort_on='create_ts', limit=10)

    data = {'qft':qft}
    return render_template("qft.html", data=data)

@app.route('/questions/history', methods=['GET'])
def view_polls_history():
    if SESSION_KEY not in session:
        return redirect("/login?next={}".format(request.path))
    u = session[SESSION_KEY]
    
    qh = dao.get_polls(limit=10)

    data = {'qh':qh}
    return render_template("qh.html", data=data)

@app.route('/questions/tomorrow/<int:question_id>', methods=['GET'])
def view_one_qft(question_id):
    if SESSION_KEY not in session:
        return redirect("/login?next={}".format(request.path))
    u = session[SESSION_KEY]
    
    oqft = dao.get_question_detail(question_id)

    return render_template("oqft.html", data=oqft)

@app.route('/questions/history/<int:question_id>', methods=['GET'])
def view_poll_detail(question_id):
    if SESSION_KEY not in session:
        return redirect("/login?next={}".format(request.path))
    u = session[SESSION_KEY]
    
    data = dao.get_poll_detail(u['usr_id'], question_id)

    return render_template("poll-detail.html", data=data)

def is_safe_url(target):
    if target is None:
        return True
    ref_url = urlparse(request.host_url)
    test_url = urlparse(urljoin(request.host_url, target))
    return test_url.scheme in ('http', 'https') and ref_url.netloc == test_url.netloc

def is_url(target):
    up = urlparse(target)
    return up.scheme in ('http', 'https') and up.netloc


####Admin code post this###
#from sqlalchemy import *
#from flask_sqlalchemy import SQLAlchemy
#from flask_admin import Admin
#from flask_admin.contrib.sqla import ModelView
#
#db = SQLAlchemy(app)
#
#class Usr(db.Model):
#    usr_id = db.Column(Integer, primary_key=True)
#    name = db.Column(String(80))
#
#class Question(db.Model):
#    question_id = db.Column(Integer, Sequence('question_id_seq'), primary_key=True)
#    question = db.Column(String(512))
#    creator_id = db.Column(Integer)
#    create_ts = db.Column(DateTime)
#
#class Comment(db.Model):
#    comment_id = db.Column(Integer, Sequence('comment_id_seq'), primary_key=True)
#    comment = db.Column(String(512))
#    usr_id = db.Column(Integer)
#    question_id = db.Column(Integer)
#    in_reply_to = db.Column(Integer)
#
#class Answer(db.Model):
#    answer_id = db.Column(Integer, Sequence('answer_id_seq'), primary_key=True)
#    answer = db.Column(String(32))
#    question_id = db.Column(Integer)
#
#class Poll(db.Model):
#    poll_id = db.Column(Integer, Sequence('poll_id_seq'), primary_key=True)
#    name = db.Column(String(64))
#    start_ts = db.Column(DateTime)
#    end_ts = db.Column(DateTime)
#    question_id = db.Column(Integer)
#
#class Reference(db.Model):
#    reference_id = db.Column(Integer, Sequence('reference_id_seq'), primary_key=True)
#    title = db.Column(String(128))
#    url = db.Column(String(4096))
#    question_id = db.Column(Integer)
#    usr_id = db.Column(Integer)
#    create_ts = db.Column(DateTime)
#
#class Updownvote(db.Model):
#    updownvote_id = db.Column(Integer, Sequence('updownvote_id_seq'), primary_key=True)
#    usr_id = db.Column(Integer)
#    on_key = db.Column(String(16))
#    on_id = db.Column(Integer)
#    amount = db.Column(Integer)
#
#class Vote(db.Model):
#    vote_id = db.Column(Integer, Sequence('vote_id_seq'), primary_key=True)
#    poll_id = db.Column(Integer)
#    usr_id = db.Column(Integer)
#    answer_id = db.Column(Integer)
#    rank = db.Column(Integer)
#
#admin = Admin(app)
#admin.add_view(ModelView(Usr, db.session))
#admin.add_view(ModelView(Question, db.session))
#admin.add_view(ModelView(Answer, db.session))
#admin.add_view(ModelView(Comment, db.session))
#admin.add_view(ModelView(Poll, db.session))
#admin.add_view(ModelView(Reference, db.session))
#admin.add_view(ModelView(Updownvote, db.session))
#admin.add_view(ModelView(Vote, db.session))

