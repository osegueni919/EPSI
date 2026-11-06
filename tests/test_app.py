import pytest
from app import app


@pytest.fixture
def client():
    return app.test_client()


def test_health(client):
    r = client.get("/health")
    assert r.status_code == 200
    assert r.get_json()["status"] == "ok"


def test_tickets(client):
    r = client.get("/tickets")
    assert r.status_code == 200
    data = r.get_json()
    assert isinstance(data, list)
    assert len(data) == 3
    assert {"id", "titre", "statut"} <= set(data[0])


def test_route_inexistante(client):
    assert client.get("/nimportequoi").status_code == 404


def test_version(client):
    r = client.get("/version")
    assert r.status_code == 200
    assert "version" in r.get_json()