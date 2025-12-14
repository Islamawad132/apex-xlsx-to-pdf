/*
 * APEX XLSX to PDF Plugin
 * Dynamic Action Plugin for converting Excel files to PDF
 *
 * @author Islam
 * @version 1.0.0
 * @license MIT
 */

PROMPT Installing XLSX to PDF Plugin...

-- Plugin Definition
BEGIN
    -- Delete existing plugin if exists
    DELETE FROM apex_appl_plugins WHERE name = 'COM.APEX.XLSX_TO_PDF';

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

-- Create Plugin
DECLARE
    l_plugin_id NUMBER;
BEGIN
    l_plugin_id := APEX_PLUGIN.create_plugin (
        p_application_id          => :APP_ID,
        p_plugin_type             => 'DYNAMIC ACTION',
        p_name                    => 'COM.APEX.XLSX_TO_PDF',
        p_display_name            => 'XLSX to PDF Converter',
        p_category                => 'Execute',
        p_supported_ui_types      => 'DESKTOP:JQM_SMARTPHONE',
        p_plsql_code              => q'[
FUNCTION render (
    p_dynamic_action IN apex_plugin.t_dynamic_action,
    p_plugin         IN apex_plugin.t_plugin
) RETURN apex_plugin.t_dynamic_action_render_result
IS
    l_result apex_plugin.t_dynamic_action_render_result;
BEGIN
    -- Add JavaScript file
    apex_javascript.add_library (
        p_name      => 'xlsx-to-pdf',
        p_directory => p_plugin.file_prefix,
        p_version   => NULL
    );

    -- Set JavaScript function to call
    l_result.javascript_function := 'XlsxToPdf.apexDaHandler';

    RETURN l_result;
END render;
]',
        p_render_function         => 'render',
        p_standard_attributes     => 'WAIT_FOR_RESULT',
        p_substitute_attributes   => TRUE,
        p_subscribe_plugin_settings => TRUE,
        p_version_identifier      => '1.0.0',
        p_about_url               => 'https://github.com/your-repo/apex-xlsx-to-pdf-plugin',
        p_help_text               => 'Converts Excel (XLSX) files to PDF using an external LibreOffice conversion API.'
    );

    -- Attribute 1: API URL
    APEX_PLUGIN_API.create_plugin_attribute (
        p_id                      => NULL,
        p_plugin_id               => l_plugin_id,
        p_attribute_scope         => 'COMPONENT',
        p_attribute_sequence      => 1,
        p_display_sequence        => 10,
        p_prompt                  => 'API URL',
        p_attribute_type          => 'TEXT',
        p_is_required             => TRUE,
        p_default_value           => 'http://localhost:5000/convert',
        p_display_length          => 60,
        p_max_length              => 500,
        p_is_translatable         => FALSE,
        p_help_text               => 'URL of the conversion API endpoint (e.g., http://localhost:5000/convert)'
    );

    -- Attribute 2: File URL
    APEX_PLUGIN_API.create_plugin_attribute (
        p_id                      => NULL,
        p_plugin_id               => l_plugin_id,
        p_attribute_scope         => 'COMPONENT',
        p_attribute_sequence      => 2,
        p_display_sequence        => 20,
        p_prompt                  => 'Excel File URL',
        p_attribute_type          => 'TEXT',
        p_is_required             => TRUE,
        p_default_value           => '#APP_FILES#',
        p_display_length          => 60,
        p_max_length              => 500,
        p_is_translatable         => FALSE,
        p_help_text               => 'URL of the Excel file to convert (e.g., #APP_FILES#report.xlsx)'
    );

    -- Attribute 3: Output Filename
    APEX_PLUGIN_API.create_plugin_attribute (
        p_id                      => NULL,
        p_plugin_id               => l_plugin_id,
        p_attribute_scope         => 'COMPONENT',
        p_attribute_sequence      => 3,
        p_display_sequence        => 30,
        p_prompt                  => 'Output Filename',
        p_attribute_type          => 'TEXT',
        p_is_required             => FALSE,
        p_default_value           => 'report.pdf',
        p_display_length          => 40,
        p_max_length              => 200,
        p_is_translatable         => FALSE,
        p_help_text               => 'Name for the downloaded PDF file'
    );

    -- Attribute 4: Loading Message
    APEX_PLUGIN_API.create_plugin_attribute (
        p_id                      => NULL,
        p_plugin_id               => l_plugin_id,
        p_attribute_scope         => 'COMPONENT',
        p_attribute_sequence      => 4,
        p_display_sequence        => 40,
        p_prompt                  => 'Loading Message',
        p_attribute_type          => 'TEXT',
        p_is_required             => FALSE,
        p_default_value           => 'Converting to PDF...',
        p_display_length          => 40,
        p_max_length              => 200,
        p_is_translatable         => TRUE,
        p_help_text               => 'Message displayed while converting'
    );

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Plugin created successfully!');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error creating plugin: ' || SQLERRM);
        RAISE;
END;
/

PROMPT XLSX to PDF Plugin installed successfully!
