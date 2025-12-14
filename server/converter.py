"""
XLSX to PDF Converter API
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

app = Flask(__name__)
CORS(app)


@app.route('/convert', methods=['POST'])
def convert():
    """
    Convert uploaded Excel file to PDF

    Expects:
        - POST request with 'file' in form-data

    Returns:
        - PDF file as attachment
    """
    try:
        # Check if file is present
        if 'file' not in request.files:
            return jsonify({'error': 'No file provided'}), 400

        file = request.files['file']

        if file.filename == '':
            return jsonify({'error': 'No file selected'}), 400

        # Create unique filenames to handle concurrent requests
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
        ], capture_output=True, text=True)

        # Check if conversion was successful
        if not os.path.exists(output_path):
            # Clean up input file
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

        # Clean up files after sending
        @response.call_on_close
        def cleanup():
            if os.path.exists(input_path):
                os.remove(input_path)
            if os.path.exists(output_path):
                os.remove(output_path)

        return response

    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'ok',
        'service': 'xlsx-to-pdf-converter',
        'version': '1.0.0'
    })


@app.route('/', methods=['GET'])
def index():
    """API information"""
    return jsonify({
        'name': 'XLSX to PDF Converter API',
        'version': '1.0.0',
        'endpoints': {
            '/convert': 'POST - Convert Excel to PDF',
            '/health': 'GET - Health check'
        }
    })


if __name__ == '__main__':
    print("=" * 50)
    print("XLSX to PDF Converter API")
    print("=" * 50)
    print("Server running on http://localhost:5000")
    print("")
    print("Endpoints:")
    print("  POST /convert - Convert Excel to PDF")
    print("  GET  /health  - Health check")
    print("=" * 50)
    app.run(host='0.0.0.0', port=5000, debug=False)
