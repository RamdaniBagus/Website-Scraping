*** Settings ***
Library    OperatingSystem
Library    Collections
Library    RPA.Excel.Files

*** Keywords ***
Generate Excel Report
    ${file}=    Set Variable    ${CURDIR}/../data/books.xlsx
    
    # 1. Check if file exists
    File Should Exist    ${file}
    
    # 2. Read Excel
    Open Workbook    ${file}
    ${books}=    Read Worksheet As Table    header=True
    Close Workbook
    
    # 3. Get total count
    ${total}=    Get Length    ${books}
    
    # 4. Count by status - PERBAIKAN LOGIC
    ${premium}=    Set Variable    0
    ${low}=    Set Variable    0
    ${ok}=    Set Variable    0
    
    FOR    ${book}    IN    @{books}
        ${status}=    Get From Dictionary    ${book}    status
        
        # LOGIC YANG BENAR:
        IF    '${status}' == 'PREMIUM'
            ${premium}=    Evaluate    ${premium} + 1
        ELSE IF    '${status}' == 'LOW_STOCK'
            ${low}=    Evaluate    ${low} + 1
        ELSE IF    '${status}' == 'OK'  # TAMBAHKAN INI
            ${ok}=    Evaluate    ${ok} + 1
        END
    END
    
    # 5. Show report - FIXED WITH CATENATE
    Log To Console    \n
    Log To Console    =====================================
    Log To Console    REPORT SUMMARY
    Log To Console    =====================================
    
    # Gunakan Catenate untuk pastikan variabel diekspansi
    ${line1}=    Catenate    SEPARATOR=    Total Books     :    ${total}
    ${line2}=    Catenate    SEPARATOR=    Premium Books   :    ${premium}
    ${line3}=    Catenate    SEPARATOR=    OK Books        :    ${ok}
    #${line4}=    Catenate    SEPARATOR=    Low Stock       :    ${low}
    
    Log To Console    ${line1}
    Log To Console    ${line2}
    Log To Console    ${line3}
    #Log To Console    ${line4}
    
    Log To Console    =====================================
    Log To Console    \n