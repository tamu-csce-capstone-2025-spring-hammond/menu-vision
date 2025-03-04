from flask import Blueprint, jsonify, request
import google.generativeai as genai
from PIL import Image
import os
import io
import json

ocr_bp = Blueprint("ocr", __name__)

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
                'error': f'Failed to decode JSON: {e}'
            }), 500

        # Return the structured menu
        return jsonify({
            'success': True,
            'menu': menu
        })
    except Exception as e:
        print(f"Error calling Gemini API: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500