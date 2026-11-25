"""Flask app served only inside the Docker network.

Nginx is the only container published on the host. It forwards requests
to this process using the container name flask.
"""

from flask import Flask, jsonify

app = Flask(__name__)


@app.get("/")
def index():
    # Plain text so curl shows the app is the one answering.
    return "flask ok\n"


@app.get("/health")
def health():
    # The assignment check curls this route through Nginx, not directly.
    return jsonify(status="ok")


if __name__ == "__main__":
    # 0.0.0.0 accepts connections from the Nginx container.
    # 127.0.0.1 would only accept connections from inside this container.
    app.run(host="0.0.0.0", port=5000)
