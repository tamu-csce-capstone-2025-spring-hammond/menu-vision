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
            "user_name": user.user_name,
            "email": user.email,
            "age": user.age,
            "food_restrictions": user.food_restrictions,
            "total_points": user.total_points,
            "created_at": user.created_at.strftime("%Y-%m-%d %H:%M:%S")
        })
    except Exception as e:
        return jsonify({"message": "Error fetching user", "error": str(e)}), 500