from flask import Flask, request, jsonify, send_file, render_template_string
import boto3
import psycopg2
import os

app = Flask(__name__)

S3_BUCKET = os.environ.get("S3_BUCKET")
REGION = os.environ.get("AWS_REGION", "us-east-1")

# S3 client
s3 = boto3.client("s3", region_name=REGION)

# HTML template for upload & file listing
html_template = """
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Flask File Manager</title>
    <style>
      body { font-family: Arial, sans-serif; background: #f9f9f9; text-align: center; margin: 0; padding: 0; }
      h1 { color: #2c3e50; margin-top: 20px; }
      form { margin: 20px auto; padding: 20px; background: #fff; border-radius: 10px; box-shadow: 0 0 10px rgba(0,0,0,0.1); width: 400px; }
      input[type=file] { padding: 10px; width: 80%; margin-bottom: 15px; }
      button { padding: 10px 20px; background-color: #3498db; color: white; border: none; border-radius: 5px; cursor: pointer; }
      button:hover { background-color: #2980b9; }
      .files { margin: 20px auto; padding: 20px; width: 400px; background: #fff; border-radius: 10px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
      a { text-decoration: none; color: #3498db; }
      a:hover { text-decoration: underline; }
    </style>
  </head>
  <body>
    <h1>Flask File Manager</h1>
    <form method="POST" enctype="multipart/form-data" action="/upload">
      <input type="file" name="file" required>
      <br><br>
      <button type="submit">Upload File</button>
    </form>
    <div class="files">
      <h3>Available Files</h3>
      {% if files %}
        <ul style="list-style: none; padding: 0;">
          {% for file in files %}
            <li>
              <a href="/file/{{ file }}" target="_blank">{{ file }}</a>
            </li>
          {% endfor %}
        </ul>
      {% else %}
        <p>No files uploaded yet.</p>
      {% endif %}
    </div>
  </body>
</html>
"""

@app.route("/up")
def up():
    return "App is running", 200

@app.route("/upload", methods=["GET", "POST"])
def upload():
    if request.method == "GET":
        # Fetch all files from S3
        try:
            objects = s3.list_objects_v2(Bucket=S3_BUCKET)
            files = [obj["Key"] for obj in objects.get("Contents", [])]
        except Exception:
            files = []
        return render_template_string(html_template, files=files)

    # Handle file upload
    if "file" not in request.files:
        return jsonify({"error": "No file provided"}), 400
    f = request.files["file"]
    try:
        s3.upload_fileobj(f, S3_BUCKET, f.filename)
        return jsonify({"message": "Uploaded successfully", "filename": f.filename}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/file/<name>", methods=["GET"])
def get_file(name):
    try:
        path = f"/tmp/{name}"
        s3.download_file(S3_BUCKET, name, path)
        return send_file(path, as_attachment=True)
    except Exception as e:
        return jsonify({"error": f"Failed to download file: {str(e)}"}), 500

@app.route("/db")
def db():
    try:
        conn = psycopg2.connect(
            host=os.environ.get("POSTGRES_HOST"),
            database="flaskdb",
            user="flaskuser",
            password=os.environ.get("POSTGRES_PASSWORD"),
        )
        cur = conn.cursor()
        cur.execute("SELECT NOW();")
        result = cur.fetchone()
        cur.close()
        conn.close()
        return jsonify({"db_time": str(result[0])})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    # Enable production-friendly logging & binding
    app.run(host="0.0.0.0", port=5000, debug=False)

