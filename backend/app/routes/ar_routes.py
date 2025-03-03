from flask import Blueprint, jsonify, request

ar_bp = Blueprint("ar", __name__)

@ar_bp.route("/", methods=["GET"])
def ar_home():
    return jsonify({"message": "AR API Home"})