import sqlite3
import json 
from flask import Flask, request, jsonify, render_template # <-- Added render_template
from flask_cors import CORS
from datetime import datetime

app = Flask(_name_)
CORS(app)  # Allows your dashboard to connect

def init_db():
    """Initializes the SQLite database and creates the 'logs' table if it doesn't exist."""
    conn = sqlite3.connect('audit.db')
    c = conn.cursor()
    c.execute('''
        CREATE TABLE IF NOT EXISTS logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            client_id TEXT,
            hostname TEXT,
            timestamp TEXT,
            login_history TEXT,
            usb_history TEXT,
            network_info TEXT,
            software_list TEXT,
            process_list TEXT,
            os_details TEXT,
            ports_list TEXT
        )
    ''')
    conn.commit()
    conn.close()

@app.route('/audit', methods=['POST'])
def receive_audit():
    """Receives audit data from the agent and stores it in the database."""
    data = request.get_json()
    if not data:
        return jsonify({"status": "error", "message": "No data received"}), 400

    try:
        conn = sqlite3.connect('audit.db')
        c = conn.cursor()
        
        # --- THIS IS THE CRITICAL FIX ---
        # We must serialize the complex JSON data into simple strings for the TEXT database column.
        # We use json.dumps() to do this.
        
        c.execute('''
            INSERT INTO logs (
                client_id, hostname, timestamp, login_history, usb_history, network_info,
                software_list, process_list, os_details, ports_list
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            data.get('client_id'),
            data.get('hostname'),
            data.get('timestamp'),
            json.dumps(data.get('login_history')),  # Serialize
            json.dumps(data.get('usb_history')),      # Serialize
            json.dumps(data.get('network_info')),     # Serialize
            json.dumps(data.get('software_list')),    # Serialize
            json.dumps(data.get('process_list')),     # Serialize
            json.dumps(data.get('os_details')),       # Serialize
            json.dumps(data.get('ports_list')),       # Serialize
        ))
        conn.commit()
    except Exception as e:
        print(f"Database error: {e}")
        return jsonify({"status": "error", "message": f"Database error: {e}"}), 500
    finally:
        if conn:
            conn.close()
            
    return jsonify({'status': 'success', 'message': 'Data logged successfully'})

@app.route('/logs', methods=['GET'])
def get_logs():
    """Retrieves all logs from the database, formatted as proper JSON."""
    try:
        conn = sqlite3.connect('audit.db')
        # This makes the cursor return dictionaries instead of tuples, which is much better
        conn.row_factory = sqlite3.Row 
        c = conn.cursor()
        c.execute('SELECT * FROM logs ORDER BY timestamp DESC')
        rows = c.fetchall()
        conn.close()
        
        data = []
        for row in rows:
            # --- THIS IS THE SECOND CRITICAL FIX ---
            # We must deserialize the strings from the DB (using json.loads)
            # to send proper JSON to the user.
            log_entry = {
                'id': row['id'],
                'client_id': row['client_id'],
                'hostname': row['hostname'],
                'timestamp': row['timestamp'],
                'login_history': json.loads(row['login_history'] or '[]'), # Deserialize (with fallback)
                'usb_history': json.loads(row['usb_history'] or '[]'),     # Deserialize (with fallback)
                'network_info': json.loads(row['network_info'] or '[]'),   # Deserialize (with fallback)
                'software_list': json.loads(row['software_list'] or '[]'), # Deserialize (with fallback)
                'process_list': json.loads(row['process_list'] or '[]'),   # Deserialize (with fallback)
                'os_details': json.loads(row['os_details'] or '{}'),       # Deserialize (with fallback)
                'ports_list': json.loads(row['ports_list'] or '[]'),       # Deserialize (with fallback)
            }
            data.append(log_entry)
            
    except Exception as e:
        print(f"Error fetching logs: {e}")
        return jsonify({"status": "error", "message": f"Error fetching logs: {e}"}), 500

    return jsonify(data)

# --- NEW SECTION ---
# This new route will serve your main dashboard UI
@app.route('/')
def dashboard():
    """Serves the main HTML dashboard."""
    # This tells Flask to look for 'index.html' in a folder named 'templates'
    return render_template('index.html')
# --- END NEW SECTION ---

# This line is crucial: It runs the init_db function once when the server starts
init_db()

if _name_ == '_main_':
    print("Starting audit server on http://0.0.0.0:5000")
    app.run(host='0.0.0.0', port=5000, debug=True)