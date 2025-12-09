*** Settings ***
Library    RPA.Excel.Files

*** Keywords ***
Save Books To Excel
    [Arguments]    ${all_books}    ${fantasy_books}    ${biography_books}    ${file}
    
    Create Workbook    ${file}
    
    # Sheet 1: All Books (buat dulu minimal satu sheet)
    Create Worksheet    name=All_Books
    Append Rows To Worksheet    ${all_books}    header=True
    
    # Hapus sheet default jika ada (setelah membuat sheet lain)
    Remove Default Sheet
    
    # Sheet 2: Fantasy Books
    Create Worksheet    name=Fantasy_Books
    Append Rows To Worksheet    ${fantasy_books}    header=True
    
    # Sheet 3: Biography Books (ganti dari Other_Books)
    Create Worksheet    name=Biography_Books
    Append Rows To Worksheet    ${biography_books}    header=True
    
    Save Workbook
    Log    Data saved to Excel with multiple sheets: ${file}

# ... (sisanya tetap sama)

Save Books To Excel Single
    [Arguments]    ${data}    ${file}
    Create Workbook    ${file}
    
    # Buat worksheet dengan nama yang diinginkan
    Create Worksheet    name=Books_Data
    Append Rows To Worksheet    ${data}    header=True
    
    # Hapus sheet default jika ada (setelah membuat sheet lain)
    Remove Default Sheet
    
    Save Workbook
    Log    Data saved to Excel: ${file}

Remove Default Sheet
    ${sheets}=    List Worksheets
    ${has_default}=    Evaluate    "Sheet" in ${sheets}
    
    IF    ${has_default}
        Remove Worksheet    name=Sheet
        Log    Removed default 'Sheet' worksheet
    END

Read Excel As Table
    [Arguments]    ${file}    ${sheet_name}=All_Books
    Open Workbook    ${file}
    ${table}=    Read Worksheet As Table    header=True    name=${sheet_name}
    ${columns}=    Set Variable    ${table.columns}
    Log    Columns in ${sheet_name}: ${columns}
    Close Workbook
    RETURN    ${table}

Read All Sheets
    [Arguments]    ${file}
    Open Workbook    ${file}
    ${sheets}=    List Worksheets
    &{tables}=    Create Dictionary
    
    FOR    ${sheet}    IN    @{sheets}
        ${table}=    Read Worksheet As Table    header=True    name=${sheet}
        Set To Dictionary    ${tables}    ${sheet}=${table}
        Log    Sheet ${sheet}: ${${table}.__len__()} rows
    END
    
    Close Workbook
    RETURN    ${tables}