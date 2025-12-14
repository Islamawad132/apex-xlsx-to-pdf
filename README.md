# APEX XLSX to PDF Plugin

Convert Excel (XLSX) files to PDF directly from Oracle APEX with a single click.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![APEX](https://img.shields.io/badge/APEX-19.1%2B-green.svg)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20Mac-lightgrey.svg)

---

## Try It Now! (Demo API)

We provide a **free demo API** for testing. Limited to **5 requests per IP per day**.

| Endpoint | URL |
|----------|-----|
| **API Base** | `http://34.60.184.196:5000` |
| **Convert** | `http://34.60.184.196:5000/convert` |
| **Health Check** | `http://34.60.184.196:5000/health` |
| **Check Usage** | `http://34.60.184.196:5000/usage` |

### Quick Test with cURL

```bash
curl -X POST -F "file=@your_file.xlsx" http://34.60.184.196:5000/convert --output output.pdf
```

### Quick Test in APEX

Add this JavaScript to a button's Dynamic Action:

```javascript
fetch('#APP_FILES#your_file.xlsx')
  .then(res => res.blob())
  .then(blob => {
    var formData = new FormData();
    formData.append('file', blob, 'file.xlsx');
    return fetch('http://34.60.184.196:5000/convert', {
      method: 'POST',
      body: formData
    });
  })
  .then(res => res.blob())
  .then(blob => {
    var url = window.URL.createObjectURL(blob);
    var a = document.createElement('a');
    a.href = url;
    a.download = 'report.pdf';
    a.click();
  });
```

> **Note:** For production use, deploy your own server for unlimited conversions.

---

## Features

- Convert Excel files to PDF with full formatting preservation
- Supports images, Arabic text (RTL), merged cells, and complex layouts
- Works with any Oracle APEX version (19.1+)
- Easy to use Dynamic Action plugin
- Cross-platform support (Windows, Linux, Mac)
- Docker support for easy deployment

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Oracle APEX                             │
│                   (Your Application)                        │
│                                                             │
│  ┌─────────────┐    ┌─────────────────────────────────┐    │
│  │   Button    │───►│  XLSX to PDF Plugin (JS)        │    │
│  └─────────────┘    │  - Fetches Excel from APEX      │    │
│                     │  - Sends to Converter API       │    │
│                     │  - Downloads resulting PDF      │    │
│                     └──────────────┬──────────────────┘    │
└────────────────────────────────────┼────────────────────────┘
                                     │ HTTP POST
                                     ▼
┌─────────────────────────────────────────────────────────────┐
│                   Converter API Server                      │
│                  (Python + LibreOffice)                     │
│                                                             │
│  - Receives Excel file                                      │
│  - Converts to PDF using LibreOffice                        │
│  - Returns PDF to client                                    │
│                                                             │
│  Can run on: localhost, internal server, cloud, Docker      │
└─────────────────────────────────────────────────────────────┘
```

---

## Quick Start

### 1. Setup the Converter API

#### Option A: Run Locally

```bash
# Install LibreOffice
# Ubuntu/Debian
sudo apt install libreoffice

# Mac
brew install libreoffice

# Windows: Download from https://www.libreoffice.org/download

# Install Python dependencies
cd server
pip install -r requirements.txt

# Run the server
python converter.py
```

#### Option B: Run with Docker

```bash
cd server
docker build -t xlsx-to-pdf-converter .
docker run -p 5000:5000 xlsx-to-pdf-converter
```

### 2. Install the APEX Plugin

#### Method 1: Import Plugin File (Recommended)

1. Download `xlsx_to_pdf_plugin.sql` from the `dist` folder
2. Go to **Shared Components** → **Plug-ins** → **Import**
3. Upload the file and click **Next** → **Install**

#### Method 2: Manual Installation

1. Go to **Shared Components** → **Plug-ins** → **Create**
2. Choose **Dynamic Action** plugin type
3. Copy the code from `src/plsql/xlsx_to_pdf_plugin.sql`
4. Upload `src/js/xlsx-to-pdf.js` as plugin file

### 3. Use in Your Application

1. Create a **Button** on your page
2. Create a **Dynamic Action** on button click
3. Choose **XLSX to PDF Converter** from the plugin list
4. Configure the attributes:

| Attribute | Description | Example |
|-----------|-------------|---------|
| **API URL** | URL of your converter API | `http://localhost:5000/convert` |
| **Excel File URL** | Path to your Excel file | `#APP_FILES#report.xlsx` |
| **Output Filename** | Name for downloaded PDF | `report.pdf` |
| **Loading Message** | Message during conversion | `Converting to PDF...` |

---

## Configuration

### Plugin Attributes

| Attribute | Required | Default | Description |
|-----------|----------|---------|-------------|
| API URL | Yes | `http://localhost:5000/convert` | Converter API endpoint |
| Excel File URL | Yes | `#APP_FILES#` | Source Excel file URL |
| Output Filename | No | `report.pdf` | Downloaded file name |
| Loading Message | No | `Converting to PDF...` | Progress message |

### API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/convert` | POST | Convert Excel to PDF |
| `/health` | GET | Health check |
| `/` | GET | API information |

---

## Usage Examples

### Basic Usage (JavaScript)

```javascript
XlsxToPdf.convert({
    apiUrl: 'http://localhost:5000/convert',
    fileUrl: '#APP_FILES#report.xlsx',
    outputFilename: 'my-report.pdf'
});
```

### With Callbacks

```javascript
XlsxToPdf.convert({
    apiUrl: 'http://localhost:5000/convert',
    fileUrl: '#APP_FILES#report.xlsx',
    outputFilename: 'report.pdf',
    loadingMessage: 'Please wait...',
    onSuccess: function() {
        console.log('PDF downloaded!');
    },
    onError: function(error) {
        console.error('Error:', error);
    }
});
```

### Using with Dynamic URL

```javascript
var fileUrl = apex.item('P1_FILE_NAME').getValue();
XlsxToPdf.convert({
    apiUrl: 'http://localhost:5000/convert',
    fileUrl: '#APP_FILES#' + fileUrl
});
```

---

## Deployment Options

### Local Development

```bash
python converter.py
# Server runs on http://localhost:5000
```

### Production with Gunicorn

```bash
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 converter:app
```

### Docker

```bash
docker build -t xlsx-converter ./server
docker run -d -p 5000:5000 --name xlsx-converter xlsx-converter
```

### Docker Compose

```yaml
version: '3'
services:
  xlsx-converter:
    build: ./server
    ports:
      - "5000:5000"
    restart: always
```

### Systemd Service (Linux)

```ini
# /etc/systemd/system/xlsx-converter.service
[Unit]
Description=XLSX to PDF Converter API
After=network.target

[Service]
User=www-data
WorkingDirectory=/opt/xlsx-converter
ExecStart=/usr/bin/python3 converter.py
Restart=always

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl enable xlsx-converter
sudo systemctl start xlsx-converter
```

---

## Project Structure

```
apex-xlsx-to-pdf-plugin/
├── README.md                    # This file
├── LICENSE                      # MIT License
├── src/
│   ├── js/
│   │   └── xlsx-to-pdf.js      # JavaScript plugin code
│   └── plsql/
│       └── xlsx_to_pdf_plugin.sql  # PL/SQL plugin definition
├── server/
│   ├── converter.py            # Flask API server
│   ├── requirements.txt        # Python dependencies
│   └── Dockerfile              # Docker configuration
└── dist/
    └── xlsx_to_pdf_plugin.sql  # Ready-to-import plugin file
```

---

## Requirements

### Converter API Server

- Python 3.8+
- LibreOffice 6.0+
- Flask 2.0+

### Oracle APEX

- APEX 19.1 or later
- Modern browser (Chrome, Firefox, Edge, Safari)

---

## Troubleshooting

### Common Issues

**1. CORS Error**
```
Access to fetch has been blocked by CORS policy
```
Solution: Make sure `flask-cors` is installed and CORS is enabled in the API.

**2. Conversion Failed**
```
Conversion failed: LibreOffice not found
```
Solution: Install LibreOffice and make sure it's in the system PATH.

**3. File Not Found**
```
Failed to fetch Excel file: 404
```
Solution: Check that the file exists in APEX Static Application Files.

**4. API Not Reachable**
```
Error: Failed to fetch
```
Solution: Verify the API URL and that the server is running.

### Debug Mode

Enable debug logging in the browser console:

```javascript
// Check API health
fetch('http://localhost:5000/health')
    .then(r => r.json())
    .then(console.log);
```

---

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Author

**Islam**

---

## Acknowledgments

- [LibreOffice](https://www.libreoffice.org/) - The Document Foundation
- [Flask](https://flask.palletsprojects.com/) - Pallets Projects
- [Oracle APEX](https://apex.oracle.com/) - Oracle Corporation
