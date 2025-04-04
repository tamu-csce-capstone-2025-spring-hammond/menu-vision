from flask import Blueprint, jsonify, request
import google.generativeai as genai
from PIL import Image
import io
import json
import os
from pydantic import BaseModel, Field, RootModel, ValidationError
from typing import List, Optional, Dict, Union
from app.models import User

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
    calories: Optional[str] = Field(None, description="Calories if explicitly listed (e.g., '840-1080' or '530'), otherwise null")
    popularity: Optional[str] = Field(None, description="Bestseller/Chef's Recommendation/Seasonal Special if mentioned, otherwise null")
    availability: Optional[str] = Field(None, description="All day/Lunch only/Weekends only if specified, otherwise null")
    addons: List[Addon] = Field(default_factory=list, description="List of add-ons for the dish")

class MenuCategory(RootModel):
    root: List[MenuItem]

class Menu(BaseModel):
    menu: Dict[str, List[MenuItem]] = Field(..., description="Dictionary of menu categories with a list of menu items")

@ocr_bp.route("/", methods=["GET"])
def ocr_home():
    return jsonify({"message": "OCR API Home"})

@ocr_bp.route("/extract-menu/<int:user_id>", methods=["POST"])
def extract_menu(user_id):
    user = User.query.get(user_id)
    if not user:
        return jsonify({"error": "User not found"}), 404

    if "image" not in request.files:
        return jsonify({"error": "No image uploaded"}), 400

    file = request.files["image"]

    try:
        image_bytes = file.read()
        image = Image.open(io.BytesIO(image_bytes))

        model = genai.GenerativeModel('gemini-1.5-flash-8b')

        example_json = {
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
            "You are an AI assistant that extracts structured menu details from images of menu."
            "It is of the highest priority that you preserve exact spelling and formatting from the image."
            "Extract ALL relevant details from the menu image in strict JSON format, matching the schema exactly.\n"
            f"Here's an example of the desired JSON structure:\n{json.dumps(example_json, indent=2)}\n\n"
            "It is CRUCIAL to extract every menu category and all items within each category.\n"
            "NOTE: The 'dietary_info' field must always be a list. If there's nothing, return an empty list []."
            "IMPORTANT: The `price` must always be inside the `sizes` list as a dictionary with both `size` and `price` keys."
            "If the size is not specified, use a default value like `Regular`"
            "DO NOT place the `price` as a top-level field in the menu item."
            "IMPORTANT: For prices, extract ONLY the numerical value with exactly two decimal places"
            "For example, if you see '$10.89 840-1080 Cal.', the price should be 10.89.\n"
            "Ensure dish names are exactly as written, and sizes include "
            "weight (oz, g, lb) or volume (fl oz, ml) if specified.\n"
            "Output MUST be valid JSON. If a field is not present in the image, "
            "its value should be 'null' if nullable, or an empty list/string when appropriate.\n"
            "Do NOT hallucinate. Only output JSON. Do NOT explain or include text outside the JSON structure."
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
        
        restrictions = ', '.join(user.food_restrictions) if user.food_restrictions else "None"
        preferences = ', '.join(user.food_preferences) if user.food_preferences else "None"

        recommendation_prompt = f"""
        You are a helpful food assistant recommending 3 dishes to a customer based on their user profile.

        User profile:
        - Age: {user.age}
        - Allergens and dietary restrictions: {restrictions}
        - Preferences: {preferences}

        Your strict instructions:
        1. Top Priority: Recommend ONLY dishes that fully avoid the user's allergens and dietary restrictions. If a dish commonly contains a restricted ingredient (e.g., dairy in gelato), exclude it—even if not explicitly listed.
        2. Favor dishes that explicitly match the user's cuisine or dietary preferences (e.g., Chinese, Korean, Vegan). DO NOT make assumptions. If no dish matches preferences, pick the safest and most neutral options.
        3. Do NOT say a dish matches a cuisine preference unless the connection is explicitly clear.
        4. Do NOT fabricate or hallucinate non-existent reasons for recommendation (e.g., do not say espresso is “Asian cuisine”).
        5. Rank the dishes by relevance and provide a match score from 1 to 100%.
        6. Ignore dish categories entirely.

        Return ONLY valid JSON in this format:
        {{
        "recommendations": [
            {{
            "name": "<Dish Name>",
            "match_score": "<Match Score from 1 to 100>",
            "reason": "<Why this dish suits the user based on their profile>"
            }},
            ...
        ]
        }}

        Menu:
        {json.dumps(structured_data['menu'], indent=2)}
        """

        recommendation_response = model.generate_content(
            [recommendation_prompt],
            generation_config=genai.types.GenerationConfig(
                response_mime_type="application/json"
            ),
        )

        try:
            recommendation_json = json.loads(recommendation_response.text.strip())
        except json.JSONDecodeError as e:
            print("Recommendation JSON error:", e)
            recommendation_json = {"recommendations": []}

        return jsonify({
            "menu": structured_data["menu"],
            "recommendations": recommendation_json.get("recommendations", [])
        })

    except Exception as e:
        print(f"Error calling Gemini API: {e}")
        return jsonify({"error": str(e)}), 500