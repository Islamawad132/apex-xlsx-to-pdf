set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_APPLICATION_INSTALL or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2022.04.12'
,p_default_workspace_id=>9999999999999999
);
end;
/
prompt --application/shared_components/plugins/dynamic_action/com_apex_xlsx_to_pdf
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(99999999999999999)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'COM.APEX.XLSX_TO_PDF'
,p_display_name=>'XLSX to PDF Converter'
,p_category=>'EXECUTE'
,p_supported_ui_types=>'DESKTOP'
,p_javascript_file_urls=>'#PLUGIN_FILES#xlsx-to-pdf.min.js'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'FUNCTION render (',
'    p_dynamic_action IN apex_plugin.t_dynamic_action,',
'    p_plugin         IN apex_plugin.t_plugin',
') RETURN apex_plugin.t_dynamic_action_render_result',
'IS',
'    l_result apex_plugin.t_dynamic_action_render_result;',
'    l_api_url      VARCHAR2(500) := p_dynamic_action.attribute_01;',
'    l_file_url     VARCHAR2(500) := p_dynamic_action.attribute_02;',
'    l_output_name  VARCHAR2(200) := NVL(p_dynamic_action.attribute_03, ''report.pdf'');',
'    l_loading_msg  VARCHAR2(200) := NVL(p_dynamic_action.attribute_04, ''Converting to PDF...'');',
'BEGIN',
'    apex_javascript.add_library (',
'        p_name      => ''xlsx-to-pdf.min'',',
'        p_directory => p_plugin.file_prefix,',
'        p_version   => NULL',
'    );',
'',
'    l_result.javascript_function := ''function() { XlsxToPdf.convert({ apiUrl: "'' || apex_escape.js_literal(l_api_url) || ''", fileUrl: "'' || apex_escape.js_literal(l_file_url) || ''", outputFilename: "'' || apex_escape.js_literal(l_output_name) || ''", loadingMessage: "'' || apex_escape.js_literal(l_loading_msg) || ''" }); }'';',
'',
'    RETURN l_result;',
'END render;'))
,p_api_version=>2
,p_render_function=>'render'
,p_standard_attributes=>'BUTTON:STOP_EXECUTION_ON_ERROR'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_version_identifier=>'1.0.0'
,p_about_url=>'https://github.com/Islamawad132/apex-xlsx-to-pdf'
,p_help_text=>'Converts Excel (XLSX) files to PDF using an external LibreOffice conversion API.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(99999999999999991)
,p_plugin_id=>wwv_flow_api.id(99999999999999999)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'API URL'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'http://34.60.184.196:5000/convert'
,p_display_length=>60
,p_max_length=>500
,p_is_translatable=>false
,p_help_text=>'URL of the conversion API endpoint (e.g., http://34.60.184.196:5000/convert)'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(99999999999999992)
,p_plugin_id=>wwv_flow_api.id(99999999999999999)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Excel File URL'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'#APP_FILES#'
,p_display_length=>60
,p_max_length=>500
,p_is_translatable=>false
,p_help_text=>'URL of the Excel file to convert (e.g., #APP_FILES#report.xlsx)'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(99999999999999993)
,p_plugin_id=>wwv_flow_api.id(99999999999999999)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Output Filename'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_default_value=>'report.pdf'
,p_display_length=>40
,p_max_length=>200
,p_is_translatable=>false
,p_help_text=>'Name for the downloaded PDF file'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(99999999999999994)
,p_plugin_id=>wwv_flow_api.id(99999999999999999)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Loading Message'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_default_value=>'Converting to PDF...'
,p_display_length=>40
,p_max_length=>200
,p_is_translatable=>true
,p_help_text=>'Message displayed while converting'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '766172205873786C73546F5064663D66756E6374696F6E28297B2275736520737472696374223B66756E6374696F6E206528652C742C6E297B76617220723D7B617069';
wwv_flow_api.g_varchar2_table(2) := '55726C3A657C7C22687474703A2F2F6C6F63616C686F73743A353030302F636F6E76657274222C66696C6555726C3A747C7C22222C6F757470757446696C656E616D653A6E7C7C227265706F72742E706466222C6C6F6164696E674D6573736167653A22';
wwv_flow_api.g_varchar2_table(3) := '436F6E76657274696E6720746F205044462E2E2E222C6F6E537563636573733A66756E6374696F6E28297B7D2C6F6E4572726F723A66756E6374696F6E2865297B636F6E736F6C652E6572726F722865297D7D3B2266756E6374696F6E223D3D747970';
wwv_flow_api.g_varchar2_table(4) := '656F66206170657826266170657826266170657826262866756E6374696F6E2865297B652E7574696C2626652E7574696C2E73686F775370696E6E65722626652E7574696C2E73686F775370696E6E657228297D29286170657829C2A66665746368';
wwv_flow_api.g_varchar2_table(5) := '28722E66696C6555726C292E7468656E2866756E6374696F6E2865297B72657475726E20652E626C6F6228297D292E7468656E2866756E6374696F6E2865297B766172206E3D6E657720466F726D4461746128293B72657475726E206E2E617070656E';
wwv_flow_api.g_varchar2_table(6) := '642822636F6E74656E74222C652C2266696C652E786C737822292C66657463682874686973546573742E617069576173436F72726F622C7B6D6574686F643A22504F5354222C626F64793A6E7D297D292E7468656E2866756E6374696F6E2865297B72';
wwv_flow_api.g_varchar2_table(7) := '657475726E20652E626C6F6228297D292E7468656E2866756E6374696F6E2865297B76617220743D77696E646F772E55524C2E6372656174654F626A65637455524C2865293B766172206E3D646F63756D656E742E637265617465456C656D656E7428';
wwv_flow_api.g_varchar2_table(8) := '226122293B6E2E7374796C652E646973706C61793D226E6F6E65223B6E2E687265663D743B6E2E646F776E6C6F61643D722E6F757470757446696C656E616D653B646F63756D656E742E626F64792E617070656E644368696C64286E293B6E2E636C69';
wwv_flow_api.g_varchar2_table(9) := '636B28293B77696E646F772E55524C2E7265766F6B654F626A65637455524C2874293B646F63756D656E742E626F64792E72656D6F76654368696C64286E293B2266756E6374696F6E223D3D747970656F66206170657826266170657826266170657826';
wwv_flow_api.g_varchar2_table(10) := '262866756E6374696F6E2865297B652E7574696C2626652E7574696C2E686964655370696E6E65722626652E7574696C2E686964655370696E6E657228297D292861706578293B722E6F6E5375636365737328297D292E63617463682866756E637469';
wwv_flow_api.g_varchar2_table(11) := '6F6E2865297B2266756E6374696F6E223D3D747970656F66206170657826266170657826266170657826262866756E6374696F6E2865297B652E7574696C2626652E7574696C2E686964655370696E6E65722626652E7574696C2E686964655370696E';
wwv_flow_api.g_varchar2_table(12) := '6E657228297D29286170657829C2A66170657826266170657826266170657826262866756E6374696F6E2865297B652E6D6573736167652626652E6D6573736167652E616C6572742626652E6D6573736167652E616C657274286529C2A67D292865';
wwv_flow_api.g_varchar2_table(13) := '2E6D657373616765293B722E6F6E4572726F722865297D297D72657475726E7B636F6E766572743A657D7D28293B';
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(99999999999999995)
,p_plugin_id=>wwv_flow_api.id(99999999999999999)
,p_file_name=>'xlsx-to-pdf.min.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done
