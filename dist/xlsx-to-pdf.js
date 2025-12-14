/**
 * APEX XLSX to PDF Converter
 * Version: 1.0.0
 * Author: Islam
 * GitHub: https://github.com/Islamawad132/apex-xlsx-to-pdf
 */
var XlsxToPdf = (function() {
    'use strict';

    function convert(options) {
        var config = {
            apiUrl: options.apiUrl || 'http://34.60.184.196:5000/convert',
            fileUrl: options.fileUrl || '',
            outputFilename: options.outputFilename || 'report.pdf',
            loadingMessage: options.loadingMessage || 'Converting to PDF...',
            onSuccess: options.onSuccess || function() {},
            onError: options.onError || function(err) { console.error(err); }
        };

        // Show spinner
        if (typeof apex !== 'undefined' && apex.util && apex.util.showSpinner) {
            var spinner = apex.util.showSpinner();
        }

        // Show message
        if (typeof apex !== 'undefined' && apex.message) {
            apex.message.showPageSuccess(config.loadingMessage);
        }

        // Fetch Excel file
        fetch(config.fileUrl)
            .then(function(response) {
                if (!response.ok) throw new Error('Failed to fetch file: ' + response.status);
                return response.blob();
            })
            .then(function(blob) {
                var formData = new FormData();
                formData.append('file', blob, 'file.xlsx');
                return fetch(config.apiUrl, {
                    method: 'POST',
                    body: formData
                });
            })
            .then(function(response) {
                if (!response.ok) throw new Error('Conversion failed: ' + response.status);
                return response.blob();
            })
            .then(function(pdfBlob) {
                // Download PDF
                var url = window.URL.createObjectURL(pdfBlob);
                var a = document.createElement('a');
                a.style.display = 'none';
                a.href = url;
                a.download = config.outputFilename;
                document.body.appendChild(a);
                a.click();
                window.URL.revokeObjectURL(url);
                document.body.removeChild(a);

                // Hide spinner
                if (spinner) spinner.remove();

                // Success message
                if (typeof apex !== 'undefined' && apex.message) {
                    apex.message.clearErrors();
                    apex.message.showPageSuccess('PDF downloaded successfully!');
                }

                config.onSuccess();
            })
            .catch(function(error) {
                if (spinner) spinner.remove();

                if (typeof apex !== 'undefined' && apex.message) {
                    apex.message.clearErrors();
                    apex.message.showErrors([{
                        type: 'error',
                        location: 'page',
                        message: 'Error: ' + error.message
                    }]);
                }

                config.onError(error);
            });
    }

    return { convert: convert };
})();
