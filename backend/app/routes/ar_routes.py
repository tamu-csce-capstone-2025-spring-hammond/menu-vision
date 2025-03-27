from flask import Blueprint, jsonify, request
from app.models import Restaurant, DishItem, ARModel
from app.database import db

ar_bp = Blueprint("ar", __name__)

@ar_bp.route("/", methods=["GET"])
def ar_home():
    return jsonify({"message": "AR API Home"})


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
                all_models.append({
                    "model_id": model.model_id,
                    "model_rating": model.model_rating,
                    "dish_id": model.dish_id,
                    "uploaded_by": model.uploaded_by,
                    "uploaded_at": model.uploaded_at.strftime("%Y-%m-%d %H:%M:%S")
                })

        return jsonify({
            "restaurant_id": restaurant.restaurant_id,
            "name": restaurant.name,
            "created_at": restaurant.created_at.strftime("%Y-%m-%d %H:%M:%S"),
            "models": all_models
        })

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
            uploaded_by=uploaded_by
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
            model_rating=0,
            dish_id=dish_id,
            uploaded_by=uploaded_by
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


# update model rating
@ar_bp.route("/model/<string:model_id>", methods=["PUT"])
def update_model(model_id):
    try:
        data = request.get_json()

        model = ARModel.query.get(model_id)
        if not model:
            return jsonify({"message": "Model not found"}), 404

        if "model_rating" in data:
            model.model_rating = data["model_rating"]

        db.session.commit()

        return jsonify({
            "message": "Model updated successfully",
            "model_rating": model.model_rating,
        }), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500
