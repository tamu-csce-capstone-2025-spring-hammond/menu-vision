from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import text
from config.config import Config
from flask import Flask

db = SQLAlchemy()

def init_db(app):
    app.config.from_object(Config)
    db.init_app(app)

def get_dishes_with_ar_models(restaurant_id):
    # Wrap the raw SQL query in text()
    query = text("""
    SELECT d.dish_id, d.dish_name, COUNT(ar.model_id) as model_count
    FROM dish_items d
    LEFT JOIN ar_models ar ON d.dish_id = ar.dish_id
    WHERE d.restaurant_id = :restaurant_id
    GROUP BY d.dish_id, d.dish_name
    HAVING COUNT(ar.model_id) > 0
    ORDER BY d.dish_name
    """)
    
    # Execute the query with the provided restaurant_id
    results = db.session.execute(query, {"restaurant_id": restaurant_id}).fetchall()
    
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