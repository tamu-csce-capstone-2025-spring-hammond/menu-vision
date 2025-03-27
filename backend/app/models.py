from app.database import db
from datetime import datetime

class Restaurant(db.Model):
    __tablename__ = "restaurants"
    
    restaurant_id = db.Column(db.String, primary_key=True)
    name = db.Column(db.String, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    dishes = db.relationship('DishItem', backref='restaurant', lazy=True)

class DishItem(db.Model):
    __tablename__ = "dish_items"

    dish_id = db.Column(db.Integer, primary_key=True)
    dish_name = db.Column(db.String, nullable=False)
    description = db.Column(db.Text)
    ingredients = db.Column(db.Text)
    price = db.Column(db.Numeric(10,2), nullable=False)
    nutritional_info = db.Column(db.Text)
    allergens = db.Column(db.Text)
    restaurant_id = db.Column(db.String, db.ForeignKey("restaurants.restaurant_id"), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    ar_models = db.relationship("ARModel", backref="dish", lazy=True, foreign_keys="[ARModel.dish_id]")

class ARModel(db.Model):
    __tablename__ = "ar_models"
    
    model_id = db.Column(db.String, primary_key=True)
    model_rating = db.Column(db.Integer, default=0)
    dish_id = db.Column(db.Integer, db.ForeignKey("dish_items.dish_id"), nullable=False)
    uploaded_by = db.Column(db.Integer, db.ForeignKey("users.user_id"), nullable=False)
    uploaded_at = db.Column(db.DateTime, default=datetime.utcnow)

    reports = db.relationship("ModelReport", backref="model", lazy=True)

class ModelReport(db.Model):
    __tablename__ = "model_reports"
    
    report_id = db.Column(db.Integer, primary_key=True)
    model_id = db.Column(db.String, db.ForeignKey("ar_models.model_id"), nullable=False)
    reported_by = db.Column(db.Integer, db.ForeignKey("users.user_id"), nullable=False)
    report_reason = db.Column(db.Text, nullable=False)
    additional_comments = db.Column(db.Text)
    status = db.Column(db.String, default="pending")
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class User(db.Model):
    __tablename__ = "users"
    
    user_id = db.Column(db.Integer, primary_key=True)
    first_name = db.Column(db.String, nullable=False)
    last_name = db.Column(db.String, nullable=False)
    user_name = db.Column(db.String, unique=True, nullable=False)
    hashed_password = db.Column(db.String, nullable=False)
    email = db.Column(db.String, unique=True, nullable=False)
    age = db.Column(db.Integer)
    food_restrictions = db.Column(db.JSON)
    food_preferences = db.Column(db.JSON)
    total_points = db.Column(db.Integer, default=0)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    uploaded_models = db.relationship("ARModel", backref="uploader", lazy=True)
    reports = db.relationship("ModelReport", backref="reporter", lazy=True)