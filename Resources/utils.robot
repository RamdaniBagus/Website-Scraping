*** Settings ***
Library    BuiltIn
Library    Collections
Library    String
Library    RPA.Browser.Selenium

*** Keywords ***
Process Book Data With Sync
    [Arguments]    ${books}    ${fantasy_books}=${EMPTY}    ${biography_books}=${EMPTY}
    
    @{result}=    Create List
    @{fantasy_list}=    Create List
    @{biography_list}=    Create List
    
    # Buat mapping jika ada data Fantasy/Biography
    &{category_map}=    Create Dictionary
    
    IF    ${fantasy_books} != ${EMPTY}
        FOR    ${book}    IN    @{fantasy_books}
            ${title}=    Get From Dictionary    ${book}    title
            ${category}=    Get From Dictionary    ${book}    category
            Set To Dictionary    ${category_map}    ${title}=${category}
        END
    END
    
    IF    ${biography_books} != ${EMPTY}
        FOR    ${book}    IN    @{biography_books}
            ${title}=    Get From Dictionary    ${book}    title
            ${category}=    Get From Dictionary    ${book}    category
            Set To Dictionary    ${category_map}    ${title}=${category}
        END
    END
    
    FOR    ${b}    IN    @{books}
        # Convert price
        ${price_str}=    Set Variable    ${b}[price]
        ${price_num}=    Replace String    ${price_str}    £    ${EMPTY}
        ${price_num}=    Convert To Number    ${price_num}
        
        ${status}=    Set Variable    OK
        
        # CONDITION FIX 1
        IF    ${price_num} > 40
            ${status}=    Set Variable    PREMIUM
        END
        
        # Tentukan kategori
        ${title}=    Set Variable    ${b}[title]
        ${original_category}=    Set Variable    ${b}[category]
        ${final_category}=    Set Variable    ${original_category}
        
        # Cek apakah ada di mapping
        ${has_mapping}=    Run Keyword And Return Status
        ...    Dictionary Should Contain Key    ${category_map}    ${title}
        
        IF    ${has_mapping}
            ${final_category}=    Get From Dictionary    ${category_map}    ${title}
            IF    '${original_category}' != '${final_category}'
                Log To Console    Category updated: ${title} -> ${original_category} to ${final_category}
            END
        END
        
        &{new}=    Create Dictionary
        ...    title=${title}
        ...    price=${price_num}
        ...    stock=${b}[stock]
        ...    category=${final_category}
        ...    status=${status}
        
        Append To List    ${result}    ${new}
        
        # Pisahkan berdasarkan kategori final
        IF    'fantasy' in '${final_category}'.lower()
            Append To List    ${fantasy_list}    ${new}
        END
        
        IF    'biography' in '${final_category}'.lower()
            Append To List    ${biography_list}    ${new}
        END
    END
    
    # RETURN multiple lists
    @{return_data}=    Create List    ${result}    ${fantasy_list}    ${biography_list}
    RETURN    @{return_data}

# Fungsi original tetap ada untuk kompatibilitas
Process Book Data
    [Arguments]    ${books}
    @{result}=    Create List
    @{fantasy_books}=    Create List
    @{biography_books}=    Create List
    
    FOR    ${b}    IN    @{books}
        # Convert price
        ${price_str}=    Set Variable    ${b}[price]
        ${price_num}=    Replace String    ${price_str}    £    ${EMPTY}
        ${price_num}=    Convert To Number    ${price_num}
        
        ${status}=    Set Variable    OK
        
        # CONDITION FIX 1
        IF    ${price_num} > 40
            ${status}=    Set Variable    PREMIUM
        END
        
        &{new}=    Create Dictionary
        ...    title=${b}[title]
        ...    price=${price_num}
        ...    stock=${b}[stock]
        ...    category=${b}[category]
        ...    status=${status}
        
        Append To List    ${result}    ${new}
        
        # Pisahkan berdasarkan kategori
        ${category}=    Set Variable    ${b}[category]
        
        # Cek untuk Fantasy
        IF    'fantasy' in '${category}'.lower()
            Append To List    ${fantasy_books}    ${new}
        END
        
        # Cek untuk Biography
        IF    'biography' in '${category}'.lower()
            Append To List    ${biography_books}    ${new}
        END
    END
    
    # RETURN multiple lists
    @{return_data}=    Create List    ${result}    ${fantasy_books}    ${biography_books}
    RETURN    @{return_data}

Count Items Where
    [Arguments]    ${table}    ${field}    ${value}
    ${count}=    Set Variable    0

    FOR    ${row}    IN    @{table}
        ${field_value}=    Set Variable    ${row}[${field}]
        IF    '${field_value}' == '${value}'
            ${count}=    Evaluate    ${count} + 1
        END
    END

    RETURN    ${count}

Filter By Category
    [Arguments]    ${books}    ${category_filter}
    @{filtered}=    Create List
    
    FOR    ${book}    IN    @{books}
        ${category}=    Get From Dictionary    ${book}    category
        IF    '${category_filter}' in '${category}'.lower()
            Append To List    ${filtered}    ${book}
        END
    END
    
    RETURN    ${filtered}