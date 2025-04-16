from flask import Blueprint, jsonify, request
from app.database import db
from app.models import User
import requests
import os

user_bp = Blueprint("user", __name__)

@user_bp.route("/", methods=["GET"])
def user_home():
    return jsonify({"message": "User API Home"})


@user_bp.route("/login", methods=["POST"])
def login():
    try:
        data = request.get_json()
        email = data.get("email")
        plain_password = data.get("password")

        if not email or not plain_password:
            return jsonify({"message": "Email and password are required"}), 400

        user = User.query.filter_by(email=email).first()
        if not user:
            return jsonify({"message": "User not found"}), 404

        crypto_base_url = os.environ.get("HASH_API_KEY")
        validate_url = f"{crypto_base_url}validate"

        params = {
            "plain": plain_password,
            "hashed": user.hashed_password
        }
        response = requests.get(validate_url, params=params)
        validation_data = response.json()

        if validation_data.get("valid"):
            return jsonify({
                "message": "Login successful",
                "user_id": user.user_id,
                "email": user.email,
                "first_name": user.first_name,
                "last_name": user.last_name,
                "age": user.age,
                "food_restrictions": user.food_restrictions,
                "food_preferences": user.food_preferences
            })
        else:
            return jsonify({"message": "Invalid credentials"}), 401

    except Exception as e:
        return jsonify({"message": "Login failed", "error": str(e)}), 500
    

@user_bp.route("/<int:user_id>", methods=["GET"])
def get_user(user_id):
    try:
        user = User.query.get(user_id)
        if user is None:
            return jsonify({"message": "User not found"}), 404

        return jsonify({
            "user_id": user.user_id,
            "first_name": user.first_name,
            "last_name": user.last_name,
            "email": user.email,
            "age": user.age,
            "food_restrictions": user.food_restrictions,
            "food_preferences": user.food_preferences,
            "total_points": user.total_points,
            "created_at": user.created_at.strftime("%Y-%m-%d %H:%M:%S")
        })
    except Exception as e:
        return jsonify({"message": "Error fetching user", "error": str(e)}), 500

@user_bp.route("/signup", methods=["POST"])
def signup():
    try:
        data = request.get_json()
        
        if not data.get("email") or not data.get("hashed_password"):
            return jsonify({"message": "Missing required fields"}), 400
        
        new_user = User(
            first_name=data["first_name"],
            last_name=data["last_name"],
            email=data["email"],
            hashed_password=data["hashed_password"],
            age=data.get("age"),
            food_restrictions=data.get("food_restrictions"),
            food_preferences=data.get("food_preferences"),
        )

        db.session.add(new_user)
        db.session.commit()
        return jsonify({"message": "User created successfully", "user_id": new_user.user_id}), 201

    except Exception as e:
        db.session.rollback() 
        return jsonify({"message": "Error creating user", "error": str(e)}), 500

@user_bp.route("/<int:user_id>", methods=["PUT"])
def update_user(user_id):
    try:
        user = User.query.get(user_id)
        if user is None:
            return jsonify({"message": "User not found"}), 404
        
        data = request.get_json()
        user.first_name = data.get("first_name", user.first_name)
        user.last_name = data.get("last_name", user.last_name)
        user.email = data.get("email", user.email)
        user.age = data.get("age", user.age)
        user.food_restrictions = data.get("food_restrictions", user.food_restrictions)
        user.food_preferences = data.get("food_preferences", user.food_preferences)
        user.total_points = data.get("total_points", user.total_points)
        
        db.session.commit()
        return jsonify({"message": "User updated successfully"})
    except Exception as e:
        return jsonify({"message": "Error updating user", "error": str(e)}), 500