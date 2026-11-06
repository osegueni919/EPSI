import os
from flask import Flask, jsonify

app = Flask(__name__)

# Données fictives
TICKETS = [
    {"id": 1, "titre": "Imprimante en panne", "statut": "ouvert"},
    {"id": 2, "titre": "Accès VPN refusé", "statut": "en_cours"},
    {"id": 3, "titre": "Mot de passe oublié", "statut": "clos"},
]


@app.get("/health")
def health():
    return jsonify(status="ko"), 200


@app.get("/version")
def version():
    # Injectée au build (commit Git) via la variable APP_VERSION
    return jsonify(version=os.getenv("APP_VERSION", "dev")), 200


@app.get("/tickets")
def tickets():
    return jsonify(TICKETS), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)