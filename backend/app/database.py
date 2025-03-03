from flask_sqlalchemy import SQLAlchemy
from config.config import Config
from flask import Flask

db = SQLAlchemy()

def init_db(app):
    app.config.from_object(Config)
    db.init_app(app)