from flask import Flask, render_template, jsonify
import random

app = Flask(__name__)

# Boundaries of Rajalakshmi Engineering College (Latitude, Longitude)
REC_BOUNDARIES = {
    "min_lat": 13.0328, "max_lat": 13.0350,
    "min_lon": 80.0415, "max_lon": 80.0450
}

# Generate random IoT devices
def generate_iot_devices(count=10):
    devices = []
    for i in range(count):
        lat = random.uniform(REC_BOUNDARIES["min_lat"], REC_BOUNDARIES["max_lat"])
        lon = random.uniform(REC_BOUNDARIES["min_lon"], REC_BOUNDARIES["max_lon"])
        status = random.choice(["active", "inactive"])
        devices.append({"id": f"Device_{i+1}", "lat": lat, "lon": lon, "status": status})
    return devices

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/get_devices")
def get_devices():
    return jsonify(generate_iot_devices())

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0")
