import os
import sys
import cv2
import numpy as np
import easyocr

def basic_easyOCR_parse(image_path):
    reader = easyocr.Reader(['en'])
    result = reader.readtext(image_path, detail=0)
    return result

class MenuParser:
    """
    Extremely simplified parser specifically for the dosa menu format
    """
    
    def __init__(self):
        """Initialize parser with English language"""
        self.reader = easyocr.Reader(['en'])
    
    def parse_menu(self, image_path):
        """Parse the dosa menu image"""
        print(f"Processing image: {image_path}")
        
        # Load image
        image = cv2.imread(image_path)
        if image is None:
            print(f"Error: Could not read image at {image_path}")
            return []
        
        # Get image dimensions
        height, width, _ = image.shape
        print(f"Image dimensions: {width}x{height}")
        
        # Run OCR on the image
        print("Running OCR...")
        results = self.reader.readtext(image_path)
        print(f"Found {len(results)} text elements")
        
        # Print all detected text for debugging
        print("\nAll detected text:")
        for i, (bbox, text, conf) in enumerate(results):
            print(f"{i+1}. '{text}' (confidence: {conf:.2f})")
        
        # Process the results to extract menu items
        menu_items = []
        
        # For this specific menu format, we know:
        # 1. Item names are on the left
        # 2. Prices are on the right (just numbers)
        # 3. The layout is very consistent
        
        # First, find the title "DOSA"
        title_found = False
        for bbox, text, conf in results:
            if "DOSA" in text.upper() and conf > 0.5:
                title_found = True
                print(f"\nFound menu title: {text}")
                break
        
        if not title_found:
            print("Warning: Could not find 'DOSA' title in the menu")
        
        # Extract items and prices
        # For this specific menu, we'll use a simple approach:
        # - Look for text elements that are likely item names (longer text)
        # - Look for nearby numbers that are likely prices
        
        # Group by approximate y-coordinate (same line)
        y_groups = {}
        for bbox, text, conf in results:
            # Skip very low confidence results
            if conf < 0.4:
                continue
                
            # Calculate center y-coordinate
            center_y = int((bbox[0][1] + bbox[2][1]) / 2)
            
            # Group with tolerance of 10 pixels
            group_key = center_y // 10
            if group_key not in y_groups:
                y_groups[group_key] = []
            y_groups[group_key].append((bbox, text, conf))
        
        # Process each group (line)
        for group_key in sorted(y_groups.keys()):
            elements = y_groups[group_key]
            
            # Skip lines with less than 2 elements (need at least item + price)
            if len(elements) < 2:
                continue
            
            # Sort elements by x-coordinate (left to right)
            elements.sort(key=lambda x: x[0][0][0])
            
            # Check if the last element looks like a price (just digits)
            last_text = elements[-1][1].strip()
            if last_text.isdigit():
                # Combine all previous elements as the item name
                item_name = " ".join([e[1] for e in elements[:-1]])
                price = last_text
                
                # Clean up the item name
                item_name = item_name.strip()
                
                # Skip preparation time and other non-items
                if "preparation" in item_name.lower() or "minute" in item_name.lower() or "tax" in item_name.lower():
                    continue
                
                # Add to menu items
                if item_name and price:
                    menu_items.append({
                        "name": item_name,
                        "price": price
                    })
        
        # Print the structured menu
        if menu_items:
            print("\nExtracted Menu Items:")
            print("-" * 50)
            for item in menu_items:
                print(f"{item['name']:<40} {item['price']}")
            print("-" * 50)
            print(f"Total items found: {len(menu_items)}")
        else:
            print("\nNo menu items were detected.")
        
        return menu_items

# Example usage
if __name__ == "__main__":
    # # Initialize parser
    # parser = MenuParser()
    
    # # Check if the user provided an image path as an argument
    # if len(sys.argv) > 1:
    #     image_path = sys.argv[1]
    # else:
    #     # Default to the current directory
    #     script_dir = os.path.dirname(os.path.abspath(__file__))
    #     image_path = os.path.join(script_dir, "3_jpg.rf.96eb491a624df19bdc1cc9fc43b5ebca.jpg")
        
    #     # Check if file exists
    #     if not os.path.exists(image_path):
    #         print(f"Error: Could not find '{image_path}'")
    #         print("Please provide a valid menu image path as a command-line argument.")
    #         sys.exit(1)
    
    # # Parse the menu
    # menu_items = parser.parse_menu(image_path)

    if len(sys.argv) > 1:
        image_path = sys.argv[1]
    result = basic_easyOCR_parse(image_path)
    for item in result:
        print(item)