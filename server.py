from __future__ import print_function

import json
import os
import tempfile
import uuid

from flask import Flask
from flask import Response
from flask import request

from bin.ingredient_phrase_tagger.training import utils

app = Flask(__name__)
modelFilename = os.path.join(os.path.dirname(__file__), "./tmp/model_file")
print("model file = %s" % modelFilename)


@app.route("/parse", methods=['GET'])
def parse_ingredients():
    """
    This endpoint takes a url-encoded ingredient string and runs it through the
    tagger. Requests should be in the form of:
        http://example.com/parse?ingredient=some%20ingredient%20here

    Multiple ingredients can be delimited with a newline character. (%0A url-encoded)

    :return: JSON containing the tagged ingredient data
    """

    ingredient_input = request.args.get("ingredient").split('\n')
    input_ok, bad_resp = validate_input(ingredient_input)
    json_result_fname = "%s.txt" % str(uuid.uuid4())
    if not input_ok:
        return bad_resp

    _, tmp_file = tempfile.mkstemp()
    with open(tmp_file, 'w') as input_file:
        input_file.write(utils.export_data(ingredient_input))
        input_file.flush()
        input_file.close()

    os.system("crf_test -v 1 -m %s %s > %s" % (modelFilename, tmp_file, json_result_fname))
    os.remove(tmp_file)

    json_output = json.dumps(utils.import_data(open(json_result_fname)), indent=4)
    os.remove(json_result_fname)

    resp = Response(u'%s' % json_output)
    resp.headers['Content-Type'] = 'application/json; charset=utf-8'

    return resp


def validate_input(input):
    """
    Check if the user's
    :param str input: the user's input
    :return bool:
        - True if the input is OK, otherwise False.
        - A response if the input is illegal, otherwise None.
    """
    if input is None:
        resp = Response(u'Missing parameter')
        resp.status_code = 400
        return False, resp

    return True, None


if __name__ == '__main__':
    app.run(host='0.0.0.0')