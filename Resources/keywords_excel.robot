*** Settings ***
Library    RPA.Excel.Files

*** Keywords ***
Save Books To Excel
    [Arguments]    ${data}    ${file}
    Create Workbook    ${file}
    Append Rows To Worksheet    ${data}    header=True
    Save Workbook
    Log    Data saved to Excel: ${file}

Read Excel As Table
    [Arguments]    ${file}
    Open Workbook    ${file}
    ${table}=    Read Worksheet As Table    header=True
    Close Workbook
    Log    Excel file read: ${file}
    RETURN    ${table}