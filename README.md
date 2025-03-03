# Menu Vision

## Backend Server

### **1. Create Virtual Environment**
```sh
cd backend
python -m venv venv 
```

### **2. Activate Virtual Environment**
```sh
source venv/bin/activate  # Mac/Linux
venv\Scripts\activate  # Windows
```

### **3. Install Dependencies**
```sh
pip install -r requirements.txt
```

### **4. Set Up Environment Variables**
Create a `.env` file in the project root and add your **PostgreSQL database URL**:
```
DATABASE_URL=postgresql://your_user:your_password@your_host:5432/your_database?sslmode=require
FLASK_ENV=development
```

### **5. Run the Flask App**
```sh
python run.py
```
The server should start at **http://127.0.0.1:5000** 

### **6. Deactivate Virtual Environment**
```sh
deactivate
```


## **Project Structure**
```sh
/backend
│── /app
│   │── __init__.py        # Initialize Flask app
│   │── database.py        # PostgreSQL connection
│   │── models.py          # SQLAlchemy models
│   ├── /routes
│   │   │── ar_routes.py   # AR model routes
│   │   │── ocr_routes.py  # OCR processing routes
│   │   └── user_routes.py # User management routes
│── /config
│   │── config.py          # App configuration
│── .env                   # Environment variables
│── requirements.txt       # Python dependencies
│── run.py                 # Start Flask server
```