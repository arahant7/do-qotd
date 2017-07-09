from wtforms import Form, BooleanField, StringField, IntegerField, validators, FieldList
from wtforms.fields.html5 import EmailField

class BaseForm(Form):

    def __init__(self, *args, **kwargs):
        self.global_errors = []
        super(BaseForm, self).__init__(*args, **kwargs)

    def add_global_error(self, error_msg):
        self.global_errors.append(error_msg)

class LoginForm(BaseForm):
    username = StringField('Username', [validators.DataRequired()])
    password = StringField('Password', [validators.DataRequired()])

class RegisterForm(BaseForm):
    username = StringField('Username', [validators.DataRequired(), validators.Length(min=2, max=32)])
    password = StringField('Password', [validators.DataRequired(), validators.Length(min=8, max=64)])
    email = EmailField('Email address', [validators.DataRequired(), validators.Email()])
    name = StringField('Name', [validators.DataRequired(), validators.Length(min=2, max=64)])

class VoteForm(BaseForm):
    answer_id = IntegerField('Answer', [validators.DataRequired()])

