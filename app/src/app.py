from datetime import datetime
from flask import Flask

current_version = '1.0'
app = Flask(__name__)


@app.route('/')
def home():
    return f"Welcome to my Sayari Flask App. Routes available: /now and /version"


@app.route('/now')
def cur_time():
    return f"system's current time : {str(datetime.now())[:19]}"


@app.route('/version')
def cur_version():
    return current_version


if __name__ == '__main__':
    app.run('0.0.0.0', '5000')
