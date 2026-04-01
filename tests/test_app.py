import unittest

from app.app import create_app


class AppTestCase(unittest.TestCase):
    def setUp(self):
        self.client = create_app().test_client()

    def test_home_returns_healthy_payload(self):
        response = self.client.get("/")

        self.assertEqual(response.status_code, 200)
        payload = response.get_json()
        self.assertEqual(payload["status"], "healthy")
        self.assertEqual(payload["message"], "Self-healing CI/CD pipeline is running")

    def test_health_endpoint(self):
        response = self.client.get("/health")

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.get_json(), {"status": "ok"})


if __name__ == "__main__":
    unittest.main()
