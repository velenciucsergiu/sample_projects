from flask import Flask, Response
import json

app = Flask(__name__)

@app.errorhandler(404)
def page_not_found():
    return Response(status=404, response=json.dumps("Not found"), mimetype="application/json")


@app.route("/greeting", methods=["GET"])
def hello():
    return Response(status=200, response=json.dumps("Hello pal. Nice to meet you"), mimetype="application/json")