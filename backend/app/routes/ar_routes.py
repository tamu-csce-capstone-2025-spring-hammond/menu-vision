from flask import Blueprint, jsonify, request
from app.models import Restaurant, DishItem, ARModel
from app.database import db
from datetime import datetime
from math import log
from duckduckgo_search import DDGS

ar_bp = Blueprint("ar", __name__)

@ar_bp.route("/", methods=["GET"])
def ar_home():
    return jsonify({"message": "AR API Home"})

def fetch_duckduckgo_image(query):
    with DDGS() as ddgs:
        results = ddgs.images(query, max_results=1)
        if results:
            return results[0]['image']
    return None

@ar_bp.route("/get_image", methods=["GET"])
def get_image():
    dish_name = request.args.get("dish_name")
    if not dish_name:
        return jsonify({"error": "Dish name is required"}), 400

    image_url = fetch_duckduckgo_image(dish_name)
    if image_url:
        return jsonify({"dish_name": dish_name, "image_url": image_url})
    else:
        return jsonify({"error": "Image not found"}), 404

# get all models for a restaurant
@ar_bp.route("/restaurant/<string:restaurant_id>/models", methods=["GET"])
def ar_models(restaurant_id):
    try:
        restaurant = Restaurant.query.get(restaurant_id)

        if restaurant is None:
            return jsonify({"message": "Restaurant was not found"}), 404

        all_models = []
        for dish in restaurant.dishes:
            for model in dish.ar_models:
                all_models.append(
                    {
                        "dish_id": model.dish_id,
                        "dish_name": dish.dish_name,
                        "description": dish.description,
                        "ingredients": dish.ingredients,
                        "price": dish.price,
                        "nutritional_info": dish.nutritional_info,
                        "allergens": dish.allergens,
                        "model_id": model.model_id,
                        "model_rating": model.model_rating,
                        "up_votes": model.up_votes,
                        "down_votes": model.down_votes,
                        "uploaded_at": model.uploaded_at.isoformat()
                        if model.uploaded_at
                        else None,
                    }
                )

        return jsonify(
            {
                "restaurant_id": restaurant.restaurant_id,
                "name": restaurant.name,
                "created_at": restaurant.created_at.strftime("%Y-%m-%d %H:%M:%S"),
                "models": all_models,
            }
        )

    except Exception as e:
        return jsonify({"message": "Error fetching restaurant or models", "error": str(e)}), 500


# update restaurant name
@ar_bp.route("/restaurant/<string:restaurant_id>", methods=["PUT"])
def update_restaurant(restaurant_id):
    try:
        data = request.get_json()

        restaurant = Restaurant.query.get(restaurant_id)
        if not restaurant:
            return jsonify({"message": "Model not found"}), 404

        if "name" in data:
            restaurant.name = data["name"]

        db.session.commit()

        return jsonify({
            "message": "Restaurant updated successfully",
            "name": restaurant.name,
        }), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500


# add a new restaurant
@ar_bp.route("/restaurant", methods=["POST"])
def add_restaurant():
    try:
        data = request.get_json()
        restaurant_id = data["restaurant_id"]
        name = data["name"]

        existing = Restaurant.query.get(restaurant_id)
        if existing:
            return jsonify({"message": "Restaurant already exists"}), 409

        new_restaurant = Restaurant(restaurant_id=restaurant_id, name=name)
        db.session.add(new_restaurant)
        db.session.commit()

        return jsonify({
            "message": "Restaurant added successfully",
            "restaurant_id": new_restaurant.restaurant_id
        }), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# add new dish AND model
@ar_bp.route("/dish_with_model", methods=["POST"])
def add_dish_with_model():
    try:
        data = request.get_json()

        restaurant_id = data["restaurant_id"]
        dish_name = data["dish_name"]
        description = data.get("description")
        ingredients = data.get("ingredients")
        price = data["price"]
        nutritional_info = data.get("nutritional_info")
        allergens = data.get("allergens")
        model_id = data["model_id"]
        uploaded_by = data["uploaded_by"]

        new_dish = DishItem(
            dish_name=dish_name,
            description=description,
            ingredients=ingredients,
            price=price,
            nutritional_info=nutritional_info,
            allergens=allergens,
            restaurant_id=restaurant_id
        )
        db.session.add(new_dish)
        db.session.flush()

        new_model = ARModel(
            model_id=model_id,
            dish_id=new_dish.dish_id,
            uploaded_by=uploaded_by,
            up_votes=0,
            down_votes=0,
            uploaded_at=datetime.now(),
            model_rating=hot(0, 0, datetime.now())
        )
        db.session.add(new_model)
        db.session.commit()

        return jsonify({
            "message": "Dish and model added",
            "dish_id": new_dish.dish_id,
            "model_id": new_model.model_id
        }), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500


# add new model to an existing dish
@ar_bp.route("/dish/<int:dish_id>/add_model", methods=["POST"])
def add_model_to_dish(dish_id):
    try:
        data = request.get_json()
        model_id = data["model_id"]
        uploaded_by = data["uploaded_by"]

        dish = DishItem.query.get(dish_id)
        if not dish:
            return jsonify({"message": "Dish not found"}), 404

        new_model = ARModel(
            model_id=model_id,
            model_rating=hot(0, 0, datetime.now()),
            dish_id=dish_id,
            uploaded_by=uploaded_by,
            up_votes=0,
            down_votes=0,
            uploaded_at=datetime.now(),
        )
        db.session.add(new_model)
        db.session.commit()

        return jsonify({"message": "Model added", "model_id": new_model.model_id}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500


# delete a model by ID
@ar_bp.route("/model/<string:model_id>", methods=["DELETE"])
def delete_model(model_id):
    try:
        model = ARModel.query.get(model_id)

        if not model:
            return jsonify({"message": "Model not found"}), 404

        db.session.delete(model)
        db.session.commit()

        return jsonify({"message": f"Model {model_id} deleted successfully"}), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500


def hot(ups, downs, date):
    # Calculate net score
    net_score = ups - downs
    
    # Calculate time score (decreasing with age)
    days_old = (datetime.now() - date).days + 1
    time_score = 1000 / days_old  # Higher for newer items
    
    # Weighted average (90% votes, 10% time)
    VOTE_WEIGHT = 0.9
    TIME_WEIGHT = 0.1
    
    return (net_score * VOTE_WEIGHT * 100) + (time_score * TIME_WEIGHT)


# upvote a model
@ar_bp.route("/model/<string:model_id>/upvote", methods=["POST"])
def upvote_model(model_id):
    try:
        model = ARModel.query.get(model_id)
        if not model:
            return jsonify({"message": "Model not found"}), 404

        model.up_votes += 1
        model.model_rating = hot(model.up_votes, model.down_votes, model.uploaded_at)

        db.session.commit()

        return jsonify(
            {
                "message": "Model upvoted successfully",
                "model_id": model.model_id,
                "model_rating": model.model_rating,
                "up_votes": model.up_votes,
                "down_votes": model.down_votes,
            }
        ), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500


# downvote a model
@ar_bp.route("/model/<string:model_id>/downvote", methods=["POST"])
def downvote_model(model_id):
    try:
        model = ARModel.query.get(model_id)
        if not model:
            return jsonify({"message": "Model not found"}), 404

        model.down_votes += 1
        model.model_rating = hot(model.up_votes, model.down_votes, model.uploaded_at)

        db.session.commit()

        return jsonify(
            {
                "message": "Model downvoted successfully",
                "model_id": model.model_id,
                "model_rating": model.model_rating,
                "up_votes": model.up_votes,
                "down_votes": model.down_votes,
            }
        ), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500