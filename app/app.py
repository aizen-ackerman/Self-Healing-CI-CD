import os
from flask import Flask, jsonify


def create_app():
    app = Flask(__name__)

    @app.route("/")
    def home():
        return jsonify(
            {
                "message": "Self-healing CI/CD pipeline is running",
                "version": os.getenv("APP_VERSION", "1.0.0"),
                "status": "healthy",
            }
        )

    @app.route("/health")
    def health():
        return jsonify({"status": "ok"}), 200

    return app


app = create_app()


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
