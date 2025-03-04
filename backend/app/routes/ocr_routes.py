from flask import Blueprint, jsonify, request
import google.generativeai as genai
from PIL import Image
import os
import io
import json
from app.database import db
from sqlalchemy import text

ocr_bp = Blueprint("ocr", __name__)

# Initialize Gemini
api_key = os.getenv('GOOGLE_API_KEY')
if not api_key:
    raise ValueError("No GOOGLE_API_KEY set.")
genai.configure(api_key=api_key)

def get_dishes_with_ar_models(restaurant_id, dish_names):
    # Wrap the raw SQL query in text()
    query = text("""
    SELECT d.dish_id, d.dish_name, COUNT(ar.model_id) as model_count
    FROM dish_items d
    LEFT JOIN ar_models ar ON d.dish_id = ar.dish_id
    WHERE d.restaurant_id = :restaurant_id AND d.dish_name IN :dish_names
    GROUP BY d.dish_id, d.dish_name
    HAVING COUNT(ar.model_id) > 0
    ORDER BY d.dish_name
    """)
    
    # Execute the query with the provided restaurant_id and dish names
    results = db.session.execute(query, {"restaurant_id": restaurant_id, "dish_names": tuple(dish_names)}).fetchall()
    
    # Format the results into a list of dictionaries
    dishes_data = [
        {
            "dish_id": row.dish_id,
            "dish_name": row.dish_name,
            "model_count": row.model_count
        }
        for row in results
    ]
    
    return dishes_data

@ocr_bp.route('/parse_menu', methods=['POST'])
def process_image():
    if 'image' not in request.files:
        return jsonify({'error': 'No image provided'}), 400

    file = request.files['image']

    try:
        # Read the image
        image_bytes = file.read()
        image = Image.open(io.BytesIO(image_bytes))

        # Load the Gemini Pro Vision model
        model = genai.GenerativeModel('gemini-1.5-flash')

        # Define the prompt
        prompt = """
        You are an AI assistant that reads restaurant menu images and extracts structured information. 
        The menu contains categories like "Appetizers", "Main Courses", "Desserts", and "Drinks". 
        For each category, extract the dish names and their prices, and return the result as a JSON object.
        """

        # Generate content with the image and prompt
        response = model.generate_content([prompt, image])

        # Check for errors
        if response.prompt_feedback and response.prompt_feedback.block_reason:
            print(f"Blocked reason: {response.prompt_feedback.block_reason}")
            return jsonify({
                'success': False,
                'error': f'Blocked reason: {response.prompt_feedback.block_reason}'
            }), 400

        # Print the raw text returned by the Gemini API
        print(f"Gemini API Response: {response.text}")

        # Remove the backticks and "json" from the response
        json_string = response.text.replace('```json', '').replace('```', '').strip()

        # Parse the JSON string into a Python dictionary
        try:
            menu = json.loads(json_string)
        except json.JSONDecodeError as e:
            print(f"Error decoding JSON: {e}")
            return jsonify({
                'success': False,
                'error': f'Failed to decode JSON: {e}',
                'raw_response': response.text  # Include the raw response for debugging
            }), 500

        # Extract dish names from the menu
        dish_names = []
        for category, items in menu.items():
            if isinstance(items, list):
                for item in items:
                    dish_names.append(item['dish'])
            elif isinstance(items, dict):
                for key, value in items.items():
                    if isinstance(value, str):
                        dish_names.append(value)

        # Get dishes with AR models
        dishes_with_ar_models = get_dishes_with_ar_models(1, dish_names)  # Hardcoded restaurant_id

        # Return the structured menu and dishes with AR models
        return jsonify({
            'success': True,
            'menu': menu,
            'dishes_with_ar_models': dishes_with_ar_models
        })
    except Exception as e:
        print(f"Error calling Gemini API: {e}")
        return jsonify({
            'success': False,
            'error': str(e),
        }), 500
    