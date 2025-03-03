from flask import Blueprint, jsonify, request
from app.database import db
from app.models import ARModel

ocr_bp = Blueprint("ocr", __name__)

@ocr_bp.route("/", methods=["GET"])
def ocr_home():
    return jsonify({"message": "OCR API Home"})