/**
 * APEX XLSX to PDF Plugin
 * Converts Excel files to PDF using external LibreOffice API
 *
 * @author Islam
 * @version 1.0.0
 * @license MIT
 */

var XlsxToPdf = (function() {
    'use strict';

    /**
     * Convert Excel file to PDF
     * @param {Object} options - Configuration options
     * @param {string} options.apiUrl - URL of the conversion API
     * @param {string} options.fileUrl - URL of the Excel file (e.g., #APP_FILES#file.xlsx)
     * @param {string} options.outputFilename - Name for the downloaded PDF file
     * @param {string} options.loadingMessage - Message to show during conversion
     * @param {function} options.onSuccess - Callback on successful conversion
     * @param {function} options.onError - Callback on error
     */
    function convert(options) {
        var config = {
            apiUrl: options.apiUrl || 'http://localhost:5000/convert',
            fileUrl: options.fileUrl || '',
            outputFilename: options.outputFilename || 'report.pdf',
            loadingMessage: options.loadingMessage || 'Converting to PDF...',
            onSuccess: options.onSuccess || function() {},
            onError: options.onError || function(err) { console.error(err); }
        };

        // Show loading spinner
        if (typeof apex !== 'undefined' && apex.util && apex.util.showSpinner) {
            var spinner = apex.util.showSpinner();
        }

        // Show processing message
        if (typeof apex !== 'undefined' && apex.message) {
            apex.message.showPageSuccess(config.loadingMessage);
        }

        // Fetch the Excel file
        fetch(config.fileUrl)
            .then(function(response) {
                if (!response.ok) {
                    throw new Error('Failed to fetch Excel file: ' + response.status);
                }
                return response.blob();
            })
            .then(function(blob) {
                // Prepare form data
                var formData = new FormData();
                formData.append('file', blob, 'file.xlsx');

                // Send to conversion API
                return fetch(config.apiUrl, {
                    method: 'POST',
                    body: formData
                });
            })
            .then(function(response) {
                if (!response.ok) {
                    throw new Error('Conversion failed: ' + response.status);
                }
                return response.blob();
            })
            .then(function(pdfBlob) {
                // Download the PDF
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
                if (spinner) {
                    spinner.remove();
                }

                // Clear message and show success
                if (typeof apex !== 'undefined' && apex.message) {
                    apex.message.clearErrors();
                    apex.message.showPageSuccess('PDF downloaded successfully!');
                }

                // Call success callback
                config.onSuccess();
            })
            .catch(function(error) {
                // Hide spinner
                if (spinner) {
                    spinner.remove();
                }

                // Show error message
                if (typeof apex !== 'undefined' && apex.message) {
                    apex.message.clearErrors();
                    apex.message.showErrors([{
                        type: 'error',
                        location: 'page',
                        message: 'Error: ' + error.message
                    }]);
                }

                // Call error callback
                config.onError(error);
            });
    }

    /**
     * APEX Dynamic Action handler
     * Called automatically by APEX when using the plugin
     */
    function apexDaHandler() {
        var da = this;
        var options = {
            apiUrl: da.action.attribute01,
            fileUrl: da.action.attribute02,
            outputFilename: da.action.attribute03 || 'report.pdf',
            loadingMessage: da.action.attribute04 || 'Converting to PDF...',
            onSuccess: function() {
                apex.da.resume(da.resumeCallback, false);
            },
            onError: function(error) {
                apex.da.resume(da.resumeCallback, true);
            }
        };

        convert(options);
    }

    // Public API
    return {
        convert: convert,
        apexDaHandler: apexDaHandler
    };

})();
