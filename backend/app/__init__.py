from flask import Flask
from flask_cors import CORS
from app.database import db, init_db

def create_app():
    app = Flask(__name__)
    CORS(app)
    init_db(app)

    from app.routes.ar_routes import ar_bp
    from app.routes.ocr_routes import ocr_bp
    from app.routes.user_routes import user_bp
    from app.routes.general_routes import general_bp

    app.register_blueprint(ar_bp, url_prefix="/ar")
    app.register_blueprint(ocr_bp, url_prefix="/ocr")
    app.register_blueprint(user_bp, url_prefix="/user")
    app.register_blueprint(general_bp, url_prefix="/general")

    return app