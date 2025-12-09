*** Settings ***
Library    BuiltIn
Library    Collections
Library    String
Library    RPA.Browser.Selenium

*** Variables ***
${TITLE_LOCATOR}=    .//h3/a
${PRICE_LOCATOR}=    .//p[@class="price_color"]
${STOCK_LOCATOR}=    .//p[contains(@class,"instock")]
${CATEGORY_LOCATOR}=    .//div[@class="image_container"]/following-sibling::p[1]/a
${FANTASY_LOCATOR}=    //a[contains(normalize-space(.), 'Fantasy')]
${BIOGRAPHY_LOCATOR}=    //a[contains(normalize-space(.), 'Biography')]
${CATEGORY_SIDEBAR}=    css:.nav-list ul li ul li a

*** Keywords ***
Open Book Store Website
    Open Available Browser    https://books.toscrape.com/    maximized=True
    Sleep    2s

*** Keywords ***
Extract Books From FirstPage
    @{books}=    Create List
    ${elements}=    Get WebElements    css:.product_pod
    
    FOR    ${el}    IN    @{elements}
        ${title_el}=    Get Element    ${el}    ${TITLE_LOCATOR}
        ${title}=       Get Text    ${title_el}
        
        ${price_el}=    Get Element    ${el}    ${PRICE_LOCATOR}
        ${price}=       Get Text    ${price_el}
        
        ${stock_el}=    Get Element    ${el}    ${STOCK_LOCATOR}
        ${stock}=       Get Text    ${stock_el}
        
        # PERBAIKAN: Try-catch untuk kategori (kadang tidak ada)
        ${category}=    Set Variable    Unknown
        ${has_category}=    Run Keyword And Return Status
        ...    Get Element    ${el}    ${CATEGORY_LOCATOR}
        
        IF    ${has_category}
            ${category_el}=    Get Element    ${el}    ${CATEGORY_LOCATOR}
            ${category}=       Get Text    ${category_el}
        END
        
        &{item}=    Create Dictionary
        ...    title=${title}
        ...    price=${price}
        ...    stock=${stock}
        ...    category=${category}
        
        Append To List    ${books}    ${item}
        Log    Extracted book: ${title} (Category: ${category})
    END
    
    RETURN    ${books}

Extract Books From HomepageAllPages
    @{all_books}=    Create List
    ${page_count}=    Set Variable    1
    
    Log To Console    \n=== STARTING HOMEPAGE SCRAPING ===
    
    WHILE    ${True}
        Log To Console    Extracting books from homepage page ${page_count}...
        
        # Extract buku dari halaman saat ini
        ${current_books}=    Extract Books From FirstPage
        ${current_count}=    Get Length    ${current_books}
        
        Append To List    ${all_books}    @{current_books}
        
        Log To Console    Extracted ${current_count} books from page ${page_count}
        
        # Cek apakah ada next page di homepage
        ${next_page_exists}=    Run Keyword And Return Status
        ...    Element Should Be Visible    css:.next a
        
        IF    not ${next_page_exists}
            Log To Console    No more pages found on homepage
            BREAK
        END
        
        # Klik next page
        Click Element    css:.next a
        Sleep    3s
        ${page_count}=    Evaluate    ${page_count} + 1
    END
    
    ${total_extracted}=    Get Length    ${all_books}
    Log To Console    Total extracted from homepage: ${total_extracted} books from ${page_count} pages
    RETURN    ${all_books}

Extract Books From FantasyCategory
    @{fantasy_books}=    Create List
    
    Log    Navigating to Fantasy category...
    
    # Coba beberapa locator untuk Fantasy link
    ${fantasy_found}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${FANTASY_LOCATOR}    timeout=10s
    
    IF    not ${fantasy_found}
        Log    WARNING: Fantasy locator not found with ${FANTASY_LOCATOR}
        Log    Trying alternative: Looking for 'Fantasy' in sidebar...
        
        ${elements}=    Get WebElements    ${CATEGORY_SIDEBAR}
        ${fantasy_clicked}=    Set Variable    ${FALSE}
        
        FOR    ${element}    IN    @{elements}
            ${text}=    Get Text    ${element}
            ${is_fantasy}=    Run Keyword And Return Status
            ...    Should Contain    ${text}    Fantasy
            
            IF    ${is_fantasy}
                Log    Found Fantasy link: ${text}
                Click Element    ${element}
                ${fantasy_clicked}=    Set Variable    ${TRUE}
                Sleep    3s
                Exit For Loop
            END
        END
        
        IF    not ${fantasy_clicked}
            Log    ERROR: Could not find Fantasy category link
            RETURN    ${fantasy_books}  # Return empty list
        END
    ELSE
        Click Element    ${FANTASY_LOCATOR}
        Sleep    3s
    END
    
    # Extract Fantasy books dari semua halaman
    ${fantasy_books}=    Extract Books From CategoryAllPages    Fantasy
    
    # Kembali ke homepage
    Go To    https://books.toscrape.com/
    Sleep    2s
    
    ${fantasy_count}=    Get Length    ${fantasy_books}
    Log    Successfully extracted ${fantasy_count} Fantasy books
    RETURN    ${fantasy_books}

Extract Books From BiographyCategory
    @{biography_books}=    Create List
    
    Log    Navigating to Biography category...
    
    # Cari link Biography
    ${biography_found}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${BIOGRAPHY_LOCATOR}    timeout=10s
    
    IF    not ${biography_found}
        Log    WARNING: Biography locator not found with ${BIOGRAPHY_LOCATOR}
        Log    Trying alternative: Looking for 'Biography' in sidebar...
        
        ${elements}=    Get WebElements    ${CATEGORY_SIDEBAR}
        ${biography_clicked}=    Set Variable    ${FALSE}
        
        FOR    ${element}    IN    @{elements}
            ${text}=    Get Text    ${element}
            ${is_biography}=    Run Keyword And Return Status
            ...    Should Contain    ${text}    Biography
            
            IF    ${is_biography}
                Log    Found Biography link: ${text}
                Click Element    ${element}
                ${biography_clicked}=    Set Variable    ${TRUE}
                Sleep    3s
                Exit For Loop
            END
        END
        
        IF    not ${biography_clicked}
            Log    ERROR: Could not find Biography category link
            RETURN    ${biography_books}  # Return empty list
        END
    ELSE
        Click Element    ${BIOGRAPHY_LOCATOR}
        Sleep    3s
    END
    
    # Extract Biography books dari semua halaman
    ${biography_books}=    Extract Books From CategoryAllPages    Biography
    
    # Kembali ke homepage
    Go To    https://books.toscrape.com/
    Sleep    2s
    
    ${biography_count}=    Get Length    ${biography_books}
    Log    Successfully extracted ${biography_count} Biography books
    RETURN    ${biography_books}

Extract Books From CategoryAllPages
    [Arguments]    ${category_name}=Unknown
    @{all_books}=    Create List
    ${page_count}=    Set Variable    1
    
    Log To Console    \n=== STARTING ${category_name.upper()} CATEGORY SCRAPING ===
    
    WHILE    ${True}
        Log To Console    Extracting books from ${category_name} page ${page_count}...
        
        # Extract buku dari halaman saat ini
        ${current_books}=    Extract Books From CurrentCategory    ${category_name}
        ${current_count}=    Get Length    ${current_books}
        
        Append To List    ${all_books}    @{current_books}
        
        Log To Console    Extracted ${current_count} books from page ${page_count}
        
        # Cek apakah ada next page
        ${next_page_exists}=    Run Keyword And Return Status
        ...    Element Should Be Visible    css:.next a
        
        IF    not ${next_page_exists}
            Log To Console    No more pages found in ${category_name} category
            BREAK
        END
        
        # Klik next page
        Click Element    css:.next a
        Sleep    3s
        ${page_count}=    Evaluate    ${page_count} + 1
    END
    
    ${total_extracted}=    Get Length    ${all_books}
    Log To Console    Total extracted from ${category_name}: ${total_extracted} books from ${page_count} pages
    RETURN    ${all_books}

Extract Books From CurrentCategory
    [Arguments]    ${category_name}=Unknown
    @{category_books}=    Create List
    
    # Cek apakah ada elements dengan cara yang benar
    ${elements}=    Get WebElements    css:.product_pod
    ${elements_count}=    Get Length    ${elements}
    
    IF    ${elements_count} == 0
        Log    WARNING: No books found on ${category_name} page
        RETURN    ${category_books}
    END
    
    Log To Console    Found ${elements_count} books on ${category_name} page
    
    ${count}=    Set Variable    0
    FOR    ${el}    IN    @{elements}
        ${count}=    Evaluate    ${count} + 1
        
        ${title_el}=    Get Element    ${el}    ${TITLE_LOCATOR}
        ${title}=       Get Text    ${title_el}
        
        ${price_el}=    Get Element    ${el}    ${PRICE_LOCATOR}
        ${price}=       Get Text    ${price_el}
        
        ${stock_el}=    Get Element    ${el}    ${STOCK_LOCATOR}
        ${stock}=       Get Text    ${stock_el}
        
        &{item}=    Create Dictionary
        ...    title=${title}
        ...    price=${price}
        ...    stock=${stock}
        ...    category=${category_name}  # Set category dari parameter
        
        Append To List    ${category_books}    ${item}
        Log    Extracted ${category_name} book: ${title}
    END
    
    Log To Console    Extracted ${count} ${category_name} books
    RETURN    ${category_books}

# Helper function untuk Get Element dengan try-catch
Get Element
    [Arguments]    ${parent}    ${locator}
    ${element}=    Call Method    ${parent}    find_element    xpath    ${locator}
    RETURN    ${element}