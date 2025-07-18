# from flask import Flask, request, jsonify
# from datetime import datetime

# app = Flask(__name__)

# @app.route("/", methods=["GET"])
# def get_time_and_ip():
#     current_time = datetime.utcnow().isoformat() + "Z"
#     visitor_ip = request.headers.get('X-Forwarded-For', request.remote_addr)
    
#     return jsonify({
#         "timestamp": current_time,
#         "ip": visitor_ip
#     })

# if __name__ == "__main__":
#     app.run(host="0.0.0.0", port=5000)




from flask import Flask, request, jsonify
from datetime import datetime
import pytz

app = Flask(__name__)

@app.route("/", methods=["GET"])
def get_time_and_ip():
    # IST Timezone
    ist = pytz.timezone('Asia/Kolkata')
    now_ist = datetime.now(ist)

    # Format time
    formatted_time = now_ist.strftime("%d-%b-%Y %I:%M:%S %p IST")

    # Get IP
    visitor_ip = request.headers.get('X-Forwarded-For', request.remote_addr)

    return jsonify({
        "timestamp": formatted_time,
        "ip": visitor_ip
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
