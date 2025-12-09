*** Settings ***
Library    OperatingSystem
Library    Collections
Library    RPA.Excel.Files

*** Keywords ***
Generate Excel Report
    ${file}=    Set Variable    ${CURDIR}/../data/books.xlsx
    
    File Should Exist    ${file}
    
    # Debug: Baca workbook langsung
    Open Workbook    ${file}
    ${sheets}=    List Worksheets
    Log To Console    \nDEBUG: Sheets found: ${sheets}
    Close Workbook
    
    # PERBAIKAN: Hitung sheet_count
    ${sheet_count}=    Get Length    ${sheets}
    
    Log To Console    \n
    Log To Console    =====================================
    Log To Console    FILE ANALYSIS
    Log To Console    =====================================
    Log To Console    File: ${file}
    Log To Console    Total Sheets: ${sheet_count}
    
    FOR    ${sheet}    IN    @{sheets}
        # Buka workbook untuk setiap sheet
        Open Workbook    ${file}
        
        # Periksa apakah sheet ada
        ${sheet_exists}=    Run Keyword And Return Status
        ...    Worksheet Exists    name=${sheet}
        
        IF    not ${sheet_exists}
            Log To Console    ---
            Log To Console    Sheet: ${sheet}
            Log To Console    SHEET NOT FOUND (but in list?)
            Close Workbook
            Continue For Loop
        END
        
        # Baca data dari sheet
        ${table}=    Read Worksheet As Table    header=True    name=${sheet}
        Close Workbook
        
        ${row_count}=    Get Length    ${table}
        
        IF    ${row_count} > 0
            # Debug: Lihat kolom apa yang ada
            ${columns}=    Set Variable    ${table.columns}
            Log To Console    \nDEBUG - Sheet ${sheet}:
            Log To Console    Columns: ${columns}
            
            # Cek apakah ada kolom 'category' - PERBAIKAN CARA CEKNYA
            ${has_category}=    Run Keyword And Return Status
            ...    Evaluate    'category' in ${columns}
            
            IF    ${has_category}
                ${categories_in_sheet}=    Create List
                FOR    ${row}    IN    @{table}
                    ${cat}=    Get From Dictionary    ${row}    category
                    ${already_in_list}=    Run Keyword And Return Status
                    ...    Should Contain    ${categories_in_sheet}    ${cat}
                    IF    not ${already_in_list}
                        Append To List    ${categories_in_sheet}    ${cat}
                    END
                END
                
                Log To Console    ---
                Log To Console    Sheet: ${sheet}
                Log To Console    Rows: ${row_count}
                Log To Console    Categories found: ${categories_in_sheet}
            ELSE
                # Tampilkan beberapa baris data untuk debugging
                Log To Console    ---
                Log To Console    Sheet: ${sheet}
                Log To Console    Rows: ${row_count}
                Log To Console    Available columns: ${columns}
                
                # Tampilkan 2 baris pertama untuk debugging
                IF    ${row_count} >= 1
                    ${first_row}=    Set Variable    ${table}[0]
                    Log To Console    First row keys: ${first_row.keys()}
                    Log To Console    First row data: ${first_row}
                END
                
                Log To Console    No 'category' column found
            END
        ELSE
            Log To Console    ---
            Log To Console    Sheet: ${sheet}
            Log To Console    EMPTY SHEET
        END
    END
    
    Log To Console    =====================================
    Log To Console    \n