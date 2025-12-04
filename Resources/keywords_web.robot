*** Settings ***
Library    BuiltIn
Library    Collections
Library    String
Library    RPA.Browser.Selenium

*** Variables ***
${TITLE_LOCATOR}=    .//h3/a
${PRICE_LOCATOR}=    .//p[@class="price_color"]
${STOCK_LOCATOR}=    .//p[contains(@class,"instock")]

*** Keywords ***
Open Book Store Website
    Open Available Browser    https://books.toscrape.com/    maximized=True

Extract Books From First Page
    @{books}=    Create List
    ${elements}=    Get WebElements    css:.product_pod

    FOR    ${el}    IN    @{elements}
        ${title_el}=    Call Method    ${el}    find_element    xpath    ${TITLE_LOCATOR}
        ${title}=       Get Text    ${title_el}

        ${price_el}=    Call Method    ${el}    find_element    xpath    ${PRICE_LOCATOR}
        ${price}=       Get Text    ${price_el}

        ${stock_el}=    Call Method    ${el}    find_element    xpath    ${STOCK_LOCATOR}
        ${stock}=       Get Text    ${stock_el}

        &{item}=    Create Dictionary
        ...    title=${title}
        ...    price=${price}
        ...    stock=${stock}

        Append To List    ${books}    ${item}
    END

    RETURN    ${books}

