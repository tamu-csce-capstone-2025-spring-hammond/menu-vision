from flask import Blueprint, jsonify, request
from app.database import db
from app.models import User

user_bp = Blueprint("user", __name__)

@user_bp.route("/", methods=["GET"])
def user_home():
    return jsonify({"message": "User API Home"})

@user_bp.route("/<int:user_id>", methods=["GET"])
def get_user(user_id):
    try:
        user = User.query.get(user_id)
        if user is None:
            return jsonify({"message": "User not found"}), 404

        return jsonify({
            "user_id": user.user_id,
            "user_type": user.user_type,
            "first_name": user.first_name,
            "last_name": user.last_name,
            "user_name": user.user_name,
            "email": user.email,
            "age": user.age,
            "food_restrictions": user.food_restrictions,
            "total_points": user.total_points,
            "created_at": user.created_at.strftime("%Y-%m-%d %H:%M:%S")
        })
    except Exception as e:
        return jsonify({"message": "Error fetching user", "error": str(e)}), 500

@user_bp.route("/create", methods=["POST"])
def create_user():
    try:
        data = request.get_json()
        
        if not data.get("user_name") or not data.get("email") or not data.get("hashed_password"):
            return jsonify({"message": "Missing required fields"}), 400
        
        new_user = User(
            user_type=data.get("user_type"),
            first_name=data["first_name"],
            last_name=data["last_name"],
            user_name=data["user_name"],
            hashed_password=["hashed_password"],  
            email=data["email"],
            age=data.get("age"),
            food_restrictions=data.get("food_restrictions"),
            total_points=data.get("total_points", 0)
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
        user.user_type = data.get("user_type", user.user_type)
        user.first_name = data.get("first_name", user.first_name)
        user.last_name = data.get("last_name", user.last_name)
        user.user_name = data.get("user_name", user.user_name)
        user.email = data.get("email", user.email)
        user.age = data.get("age", user.age)
        user.food_restrictions = data.get("food_restrictions", user.food_restrictions)
        user.total_points = data.get("total_points", user.total_points)
        
        db.session.commit()
        return jsonify({"message": "User updated successfully"})
    except Exception as e:
        return jsonify({"message": "Error updating user", "error": str(e)}), 500