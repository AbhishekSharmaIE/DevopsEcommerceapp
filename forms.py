from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField
from wtforms.validators import DataRequired, Length

class CheckoutForm(FlaskForm):
    street = StringField('Street Address', validators=[DataRequired(), Length(min=5, max=100)])
    city = StringField('City', validators=[DataRequired(), Length(min=2, max=50)])
    state = StringField('State/Province', validators=[DataRequired(), Length(min=2, max=50)])
    zip_code = StringField('ZIP/Postal Code', validators=[DataRequired(), Length(min=3, max=20)])
    country = StringField('Country', validators=[DataRequired(), Length(min=2, max=50)])
    submit = SubmitField('Place Order') 