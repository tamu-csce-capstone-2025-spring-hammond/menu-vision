from flask import Blueprint, jsonify, request
import google.generativeai as genai
from PIL import Image
import io
import json
import os
from pydantic import BaseModel, Field, RootModel, ValidationError
from typing import List, Optional, Dict

ocr_bp = Blueprint("ocr", __name__)

genai.configure(api_key=os.getenv("GOOGLE_API_KEY"))

# Define Pydantic models for the JSON schema
class Addon(BaseModel):
    name: Optional[str] = Field(None, description="Add-on name (Preserve exact spelling)")
    price: Optional[float] = Field(None, description="Price of the add-on")

class Size(BaseModel):
    size: Optional[str] = Field(None, description="Exact size label (Small/Medium/Large) OR specific weight/volume if available (e.g., '8 oz', '12 fl oz', '500g')")
    price: Optional[float] = Field(None, description="Price for the given size")

class MenuItem(BaseModel):
    name: Optional[str] = Field(None, description="Dish Name (Preserve exact spelling and formatting as in image)")
    sizes: List[Size] = Field(default_factory=list, description="List of sizes and prices for the dish")
    description: Optional[str] = Field(None, description="Full description exactly as written, including ingredients if mentioned")
    spiciness: Optional[str] = Field(None, description="Mild/Medium/Spicy if listed, otherwise null")
    allergens: List[str] = Field(default_factory=list, description="List of allergens explicitly listed under 'Allergens', otherwise leave empty")
    dietary_info: List[str] = Field(default_factory=list, description="List of dietary tags such as 'Vegan', 'Vegetarian', 'Gluten-Free', 'Dairy-Free' if explicitly stated, otherwise leave empty")
    calories: Optional[str] = Field(None, description="Calories if explicitly listed, otherwise null")
    popularity: Optional[str] = Field(None, description="Bestseller/Chef's Recommendation/Seasonal Special if mentioned, otherwise null")
    availability: Optional[str] = Field(None, description="All day/Lunch only/Weekends only if specified, otherwise null")
    addons: List[Addon] = Field(default_factory=list, description="List of add-ons for the dish")

class MenuCategory(RootModel):
    root: List[MenuItem]

class Restaurant(BaseModel):
    name: Optional[str] = Field(None, description="Extract Restaurant Name exactly as written, otherwise null")
    address: Optional[str] = Field(None, description="Extract full address exactly as written if present, otherwise null")

class Menu(BaseModel):
    restaurant: Optional[Restaurant] = Field(None, description="Restaurant details")
    menu: Dict[str, List[MenuItem]] = Field(..., description="Dictionary of menu categories with a list of menu items")

@ocr_bp.route("/", methods=["GET"])
def ocr_home():
    return jsonify({"message": "OCR API Home"})

@ocr_bp.route("/extract-menu", methods=["POST"])
def extract_menu():
    if "image" not in request.files:
        return jsonify({"error": "No image uploaded"}), 400

    file = request.files["image"]

    try:
        image_bytes = file.read()
        image = Image.open(io.BytesIO(image_bytes))

        model = genai.GenerativeModel('gemini-1.5-flash-8b')

        # Example of the JSON structure
        example_json = {
            "restaurant": {"name": "Example Restaurant", "address": "123 Main St"},
            "menu": {
                "APPETIZERS": [
                    {"name": "Shrimp Cocktail", "sizes": [{"size": "Regular", "price": 12.0}], "description": "Chilled shrimp with cocktail sauce", "spiciness": None, "allergens": [], "dietary_info": [], "calories": None, "popularity": None, "availability": None, "addons": []}
                ],
                "MAIN COURSES": [
                    {"name": "Grilled Salmon", "sizes": [{"size": "Regular", "price": 25.0}], "description": "Grilled salmon with roasted vegetables", "spiciness": None, "allergens": [], "dietary_info": [], "calories": None, "popularity": None, "availability": None, "addons": []},
                    {"name": "Pasta Carbonara", "sizes": [], "description": "Creamy pasta with pancetta and egg", "spiciness": None, "allergens": ["dairy", "gluten"], "dietary_info": [], "calories": "600", "popularity": "Chef's Recommendation", "availability": "All day", "addons": [{"name": "Add Chicken", "price": 5.0}]}
                ],
                "DRINKS": [
                    {"name": "Coke", "sizes": [{"size": "12 oz", "price": 2.5}]}
                ]
            }
        }

        prompt = (
            "You are an AI assistant that extracts structured menu details "
            "from images. Extract ALL relevant details from the menu image "
            "in strict JSON format, matching the schema as closely as possible.\n"
            "It is CRUCIAL to extract every menu category and all items within each category.\n"
            "Ensure dish names are exactly as written, and sizes include "
            "weight (oz, g, lb) or volume (fl oz, ml) if specified.\n"
            "Output MUST be valid JSON. If a field is not present in the image, "
            "its value should be 'null' if nullable, or an empty list/string if appropriate.\n"
            "Preserve exact spelling and formatting from the image.\n\n"
            f"Here's an example of the desired JSON structure:\n{json.dumps(example_json, indent=2)}\n\n"
            "Now, extract the menu details from the given image."
        )
        
        response = model.generate_content(
            [prompt, image],
            generation_config=genai.types.GenerationConfig(
                response_mime_type="application/json"
            ),
        )

        if response.prompt_feedback and response.prompt_feedback.block_reason:
            print(f"Blocked reason: {response.prompt_feedback.block_reason}")
            return jsonify({
                'success': False,
                'error': f'Blocked reason: {response.prompt_feedback.block_reason}'
            }), 400

        try:
            json_string = response.text.strip()
            structured_data = json.loads(json_string)

            # Validate the output against the Pydantic model
            Menu.model_validate(structured_data)

        except json.JSONDecodeError as e:
            print(f"JSON Decode Error: {e}\nResponse Text: {response.text}")
            return jsonify({
                'success': False,
                'error': f'Failed to decode JSON: {e}'
            }), 500
        except ValidationError as e:
            print(f"Pydantic Validation Error: {e}\nData: {structured_data}")
            return jsonify({
                'success': False,
                'error': f'Data validation failed: {e}'
            }), 400

        return jsonify(structured_data)

    except Exception as e:
        print(f"Error calling Gemini API: {e}")
        return jsonify({"error": str(e)}), 500
