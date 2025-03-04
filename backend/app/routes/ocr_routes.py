from flask import Blueprint, jsonify, request
from app.database import db
from app.models import ARModel
from app.database import get_dishes_with_ar_models
from google.cloud import vision
import os

os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = '../../menuvision-452619-57ee7ca28a05.json'

ocr_bp = Blueprint("ocr", __name__)

@ocr_bp.route("/", methods=["GET"])
def ocr_home():
    return jsonify({"message": "OCR API Home"})

def perform_ocr_with_google_vision(image_bytes):
    try:
        client = vision.ImageAnnotatorClient()
        image = vision.Image(content=image_bytes)
        
        response = client.text_detection(image=image)
        print(f"API Response: {response}")  # Add this line
        texts = response.text_annotations
        
        if texts:
            return texts[0].description  # The first element contains the full text
        else:
            print("No text found in image")
            return ""
    except Exception as e:
        print(f"Google Cloud Vision API error: {e}")
        return None

def parse_menu_text(text):
    """Parse the extracted text into a structured menu format."""
    # Split the text into lines
    lines = text.split('\n')
    
    # Initialize variables
    current_category = None
    menu = {}
    
    # Common category headers in menus
    category_keywords = [
        "APPETIZERS", "PRIX FIXE", "SALADS AND SOUPS", "STEAK CUTS", 
        "ENTREES", "DESSERTS", "DRINKS", "SIDES", "MENU"
    ]
    
    # Process each line
    for line in lines:
        line = line.strip()
        if not line:
            continue
            
        # Check if this line is a category header
        if any(keyword in line.upper() for keyword in category_keywords) or line.isupper():
            current_category = line
            menu[current_category] = []
        elif current_category is not None:
            # Try to separate item name and price
            if '..' in line or '...' in line or '. . .' in line:
                parts = line.split('.')
                item_name = parts[0].strip()
                # Join all parts except the last one (which should be the price)
                price = parts[-1].strip() if len(parts) > 1 else ""
                
                # Clean up the price
                price = price.strip('.')
                
                menu[current_category].append({
                    "name": item_name,
                    "price": price
                })
            else:
                # If no clear price separator, just add the line as an item
                menu[current_category].append({
                    "name": line,
                    "price": ""
                })
    
    return menu

@ocr_bp.route('/parse_menu', methods=['POST'])
def process_image():
    if 'image' not in request.files:
        return jsonify({'error': 'No image provided'}), 400
    
    file = request.files['image']
    
    try:
        image_bytes = file.read()
        
        # Perform OCR using Google Cloud Vision API
        extracted_text = perform_ocr_with_google_vision(image_bytes)
        
        if extracted_text is None:
            return jsonify({
                'success': False,
                'error': 'Failed to extract text from image'
            }), 500
        
        # Get dishes with AR models for restaurant_id 1
        dishes_with_ar_models = get_dishes_with_ar_models(1)  # Hardcoded restaurant_id
        
        # Parse the extracted text into a structured format
        structured_menu = parse_menu_text(extracted_text)
        
        return jsonify({
            'success': True,
            'menu': structured_menu,
            'dishes_with_ar_models': dishes_with_ar_models,
            'raw_text': extracted_text  # Keep the raw text for reference
        })
    except Exception as e:
        print(f"Error processing image: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500