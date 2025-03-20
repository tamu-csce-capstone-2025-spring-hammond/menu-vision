from flask import Blueprint, jsonify, request
from app.database import db
from app.models import ARModel
from openai import OpenAI
from PIL import Image
import io
import base64
import json
import os

ocr_bp = Blueprint("ocr", __name__)

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

EXTRACTION_PROMPT = """
Accurately extract all relevant details from the menu image in **strict JSON format** while ensuring **dish names are exactly as written** and sizes include **weight (oz, g, lb) or volume (fl oz, ml) if specified**:
{
  "restaurant": {
    "name": "<Extract Restaurant Name exactly as written, otherwise null>",
    "address": "<Extract full address exactly as written if present, otherwise null>"
  },
  "menu": {
    "<Category Name>": [
      {
        "name": "<Dish Name (Preserve exact spelling and formatting as in image)>",
        "sizes": [
          {
            "size": "<Extract exact size label (Small/Medium/Large) OR specific weight/volume if available (e.g., '8 oz', '12 fl oz', '500g')>",
            "price": <Price>
          }
        ],
        "description": "<Extract full description exactly as written, including ingredients if mentioned>",
        "spiciness": "<Mild/Medium/Spicy if listed, otherwise null>",
        "allergens": ["<Extract only if explicitly listed under 'Allergens', otherwise leave empty>"],
        "dietary_info": ["<List dietary tags such as 'Vegan', 'Vegetarian', 'Gluten-Free', 'Dairy-Free' if explicitly stated, otherwise leave empty>"],
        "calories": "<Extract if explicitly listed, otherwise null>",
        "popularity": "<Bestseller/Chef's Recommendation/Seasonal Special if mentioned, otherwise null>",
        "availability": "<All day/Lunch only/Weekends only if specified, otherwise null>",
        "addons": [
          {
            "name": "<Add-on name (Preserve exact spelling)>",
            "price": <Price>
          }
        ]
      }
    ]
  }
}

### **Extraction Rules (STRICT COMPLIANCE REQUIRED):**
1. **Output strict JSON—no extra text, comments, or formatting deviations.**
2. **Extract ONLY explicitly stated attributes**:
   - If a field is missing, set it to `null`—do NOT infer.
3. **Dish Names MUST be spelled EXACTLY as in the image. No changes, no corrections, no interpretations.**
4. **All text in 'description' must be extracted EXACTLY as written. No summarization.**
5. **Extract restaurant name and address EXACTLY as written**:
   - Address should maintain original punctuation, spacing, and formatting.
   - If no address is found, set `"address": null`.
6. **Handle dish sizes and prices correctly**:
   - If multiple sizes exist, list them in `"sizes"`.
   - If no sizes are provided, assume `"size": "Regular"`.
   - If prices vary without explicit size labels, order them as `"Small", "Large"`.
7. **If an item has weight (oz, g, lb) or volume (fl oz, ml), it MUST be included in the 'sizes' field.**
   - Example: `"size": "12 oz"` for drinks or `"size": "500g"` for a dish.
8. **Include add-ons if available**:
   - Example: `"Add extra cheese for $1"` → `{ "name": "Cheese", "price": 1 }`
9. **Think about hidden or implied information in footnotes, symbols, or acronyms    for dietary info (e.g., 'GF' = 'Gluten-Free', 'VG/VGN' = 'Vegan') but only extract if explicitly stated.**
"""

def encode_image(image):
    buffered = io.BytesIO()
    image.save(buffered, format=image.format)
    return base64.b64encode(buffered.getvalue()).decode()

@ocr_bp.route("/", methods=["GET"])
def ocr_home():
    return jsonify({"message": "OCR API Home"})


@ocr_bp.route("/extract-menu", methods=["POST"])
def extract_menu():
    if "image" not in request.files:
        return jsonify({"error": "No image uploaded"}), 400

    image_file = request.files["image"]
    image = Image.open(image_file)
    base64_image = encode_image(image)

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {"role": "system", "content": "You are an AI that extracts structured menu details from images."},
            {"role": "user", "content": EXTRACTION_PROMPT},
            {"role": "user", "content": [
                {"type": "text", "text": EXTRACTION_PROMPT},  
                {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{base64_image}"}}
            ]}
        ],
        response_format={"type": "json_object"},
        max_tokens=2000
    )

    try:
        structured_data = json.loads(response.choices[0].message.content)
    except json.JSONDecodeError:
        structured_data = {"error": "Invalid JSON returned"}

    return jsonify(structured_data)