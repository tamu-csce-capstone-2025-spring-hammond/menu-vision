from flask import Blueprint, jsonify, request
import requests
import os

general_bp = Blueprint("general", __name__)

@general_bp.route("/", methods=["GET"])
def general_home():
    return jsonify({"message": "General API Home"})

@general_bp.route("/nearby-restaurants/<longitude>/<latitude>", methods=["POST"])
def get_nearby_restaurants(longitude=None, latitude=None):
    # If parameters aren't provided, try to get them from request args
    if longitude is None:
        longitude = request.args.get('longitude')
    if latitude is None:
        latitude = request.args.get('latitude')
    
    if not longitude or not latitude:
        return jsonify({"error": "Missing longitude or latitude parameters"}), 400
        
    url = "https://places.googleapis.com/v1/places:searchNearby"
    headers = {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': os.getenv("GOOGLE_MAPS_API_KEY"),
        'X-Goog-FieldMask': 'places.id,places.displayName,places.formattedAddress,places.priceLevel,places.rating,places.currentOpeningHours,places.generativeSummary.description,places.generativeSummary.overview'
    }
    data = {
        "includedTypes": ["restaurant"],
        "maxResultCount": 20,
        "locationRestriction": {
            "circle": {
                "center": {
                    "latitude": float(latitude),
                    "longitude": float(longitude)
                },
                "radius": 500
            }
        }
    }
    
    response = requests.post(url, headers=headers, json=data)
    return jsonify(response.json())
