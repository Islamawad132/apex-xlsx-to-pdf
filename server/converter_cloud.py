"""
XLSX to PDF Converter API (Cloud Version with Rate Limiting)
Flask server that converts Excel files to PDF using LibreOffice

@author Islam
@version 1.0.0
@license MIT
"""

from flask import Flask, request, send_file, jsonify
from flask_cors import CORS
import subprocess
import os
import tempfile
import uuid
from functools import wraps
from collections import defaultdict
import time

app = Flask(__name__)
CORS(app)

# Rate limiting: 5 requests per IP per day
MAX_REQUESTS_PER_IP = 5
request_counts = defaultdict(lambda: {"count": 0, "reset_time": time.time() + 86400})


def get_client_ip():
    """Get client IP address"""
    if request.headers.get('X-Forwarded-For'):
        return request.headers.get('X-Forwarded-For').split(',')[0].strip()
    return request.remote_addr


def rate_limit(f):
    """Rate limiting decorator"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        ip = get_client_ip()
        current_time = time.time()

        # Reset count if 24 hours passed
        if current_time > request_counts[ip]["reset_time"]:
            request_counts[ip] = {"count": 0, "reset_time": current_time + 86400}

        # Check limit
        if request_counts[ip]["count"] >= MAX_REQUESTS_PER_IP:
            remaining_time = int(request_counts[ip]["reset_time"] - current_time)
            hours = remaining_time // 3600
            minutes = (remaining_time % 3600) // 60
            return jsonify({
                "error": "Rate limit exceeded",
                "message": f"You have used all {MAX_REQUESTS_PER_IP} free requests for today.",
                "reset_in": f"{hours}h {minutes}m",
                "tip": "Deploy your own server for unlimited usage!"
            }), 429

        # Increment count
        request_counts[ip]["count"] += 1

        return f(*args, **kwargs)
    return decorated_function


@app.route('/convert', methods=['POST'])
@rate_limit
def convert():
    """
    Convert uploaded Excel file to PDF
    Limited to 5 requests per IP per day
    """
    try:
        if 'file' not in request.files:
            return jsonify({'error': 'No file provided'}), 400

        file = request.files['file']

        if file.filename == '':
            return jsonify({'error': 'No file selected'}), 400

        # Create unique filenames
        unique_id = str(uuid.uuid4())
        input_filename = f'input_{unique_id}.xlsx'
        output_filename = f'input_{unique_id}.pdf'

        input_path = os.path.join(tempfile.gettempdir(), input_filename)
        output_path = os.path.join(tempfile.gettempdir(), output_filename)

        # Save uploaded file
        file.save(input_path)

        # Convert using LibreOffice
        result = subprocess.run([
            'libreoffice',
            '--headless',
            '--convert-to', 'pdf',
            '--outdir', tempfile.gettempdir(),
            input_path
        ], capture_output=True, text=True, timeout=120)

        # Check if conversion was successful
        if not os.path.exists(output_path):
            if os.path.exists(input_path):
                os.remove(input_path)
            return jsonify({
                'error': 'Conversion failed',
                'details': result.stderr
            }), 500

        # Send the PDF file
        response = send_file(
            output_path,
            as_attachment=True,
            download_name='report.pdf',
            mimetype='application/pdf'
        )

        @response.call_on_close
        def cleanup():
            if os.path.exists(input_path):
                os.remove(input_path)
            if os.path.exists(output_path):
                os.remove(output_path)

        return response

    except subprocess.TimeoutExpired:
        return jsonify({'error': 'Conversion timeout'}), 500
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'ok',
        'service': 'xlsx-to-pdf-converter',
        'version': '1.0.0',
        'rate_limit': f'{MAX_REQUESTS_PER_IP} requests per IP per day'
    })


@app.route('/usage', methods=['GET'])
def usage():
    """Check remaining requests for current IP"""
    ip = get_client_ip()
    current_time = time.time()

    if current_time > request_counts[ip]["reset_time"]:
        request_counts[ip] = {"count": 0, "reset_time": current_time + 86400}

    remaining = MAX_REQUESTS_PER_IP - request_counts[ip]["count"]
    reset_time = int(request_counts[ip]["reset_time"] - current_time)
    hours = reset_time // 3600
    minutes = (reset_time % 3600) // 60

    return jsonify({
        'ip': ip,
        'used': request_counts[ip]["count"],
        'remaining': remaining,
        'limit': MAX_REQUESTS_PER_IP,
        'reset_in': f'{hours}h {minutes}m'
    })


@app.route('/', methods=['GET'])
def index():
    """API information"""
    return jsonify({
        'name': 'XLSX to PDF Converter API (Demo)',
        'version': '1.0.0',
        'rate_limit': f'{MAX_REQUESTS_PER_IP} requests per IP per day',
        'endpoints': {
            '/': 'GET - API information',
            '/convert': 'POST - Convert Excel to PDF',
            '/health': 'GET - Health check',
            '/usage': 'GET - Check your remaining requests'
        },
        'github': 'https://github.com/Islamawad132/apex-xlsx-to-pdf',
        'note': 'This is a demo server. Deploy your own for unlimited usage!'
    })


if __name__ == '__main__':
    print("=" * 60)
    print("XLSX to PDF Converter API (Demo Server)")
    print("=" * 60)
    print(f"Rate Limit: {MAX_REQUESTS_PER_IP} requests per IP per day")
    print("Server running on http://0.0.0.0:5000")
    print("=" * 60)
    app.run(host='0.0.0.0', port=5000, debug=False)
