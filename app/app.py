from flask import Flask, request, jsonify
from datetime import datetime

app = Flask(__name__)

@app.route("/", methods=["GET"])
def get_time_and_ip():
    current_time = datetime.utcnow().isoformat() + "Z"
    visitor_ip = request.headers.get('X-Forwarded-For', request.remote_addr)
    
    return jsonify({
        "timestamp": current_time,
        "ip": visitor_ip
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
