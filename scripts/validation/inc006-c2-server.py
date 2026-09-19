#!/usr/bin/env python3
"""INC-006 lab-only HTTP C2 simulator.

Usage: python3 inc006-c2-server.py --bind 172.16.0.11 --port 8080
Target host: Kali (172.16.0.11); private lab network only.

This server accepts beacon metadata and returns one fixed, harmless task:
"status". It never executes commands received over HTTP.
"""

import argparse
import json
import logging
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


TOKEN = "inc006-lab-only"


class C2Handler(BaseHTTPRequestHandler):
    server_version = "INC006-Lab-C2/1.0"

    def _authorized(self) -> bool:
        return self.headers.get("X-INC006-Token") == TOKEN

    def _json_response(self, status: int, payload: dict) -> None:
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_POST(self) -> None:
        if not self._authorized():
            self._json_response(403, {"error": "forbidden"})
            return

        length = int(self.headers.get("Content-Length", "0"))
        try:
            payload = json.loads(self.rfile.read(length))
        except (ValueError, json.JSONDecodeError):
            self._json_response(400, {"error": "invalid-json"})
            return

        if self.path == "/beacon":
            logging.info("beacon agent=%s host=%s", payload.get("agent_id"), payload.get("hostname"))
            self._json_response(200, {"accepted": True, "next": "/task"})
            return

        if self.path == "/result":
            logging.info("result agent=%s task=%s", payload.get("agent_id"), payload.get("task"))
            self._json_response(200, {"accepted": True})
            return

        self._json_response(404, {"error": "not-found"})

    def do_GET(self) -> None:
        if not self._authorized():
            self._json_response(403, {"error": "forbidden"})
            return

        if self.path == "/task":
            self._json_response(200, {"task_id": "inc006-status-001", "task": "status"})
            return

        self._json_response(404, {"error": "not-found"})

    def log_message(self, format: str, *args: object) -> None:
        logging.info("%s - %s", self.address_string(), format % args)


def main() -> None:
    parser = argparse.ArgumentParser(description="INC-006 lab-only HTTP C2 simulator")
    parser.add_argument("--bind", default="172.16.0.11")
    parser.add_argument("--port", type=int, default=8080)
    args = parser.parse_args()

    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
    server = ThreadingHTTPServer((args.bind, args.port), C2Handler)
    logging.info("INC-006 simulator listening on http://%s:%s", args.bind, args.port)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        logging.info("INC-006 simulator stopped")
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
