import qrcode
from flask import Flask, render_template, request, jsonify

app = Flask(__name__)

# Generate a Fixed QR Code (Run Once)
def generate_fixed_qr():
    url = "http://localhost:5000/scan"
    qr = qrcode.make(url)
    qr.save("static/qr_code.png")  # Save the QR code

# Generate the QR code initially
generate_fixed_qr()

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/scan", methods=["GET", "POST"])
def scan_qr():
    if request.method == "POST":
        location = request.json["location"]
        return jsonify({"message": "Location received!", "location": location})
    return render_template("scan.html")

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0")
