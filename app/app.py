from flask import Flask, jsonify
from db import get_db_connection

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({"message": "Flask API running on port 8080!"})

@app.route('/users')
def get_users():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT userid, username FROM users;")
    users = cur.fetchall()
    cur.close()
    conn.close()
    
    return jsonify([{"id": user[0], "username": user[1]} for user in users])

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)