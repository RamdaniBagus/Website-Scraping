*** Settings ***
Library    BuiltIn
Library    Collections
Library    String
Library    RPA.Browser.Selenium

*** Keywords ***
Process Book Data
    [Arguments]    ${books}
    @{result}=    Create List

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

        # CONDITION FIX 2
        #${stock_str}=    Set Variable    ${b}[stock]
        #IF    "In stock" not in "${stock_str}"
        #    ${status}=    Set Variable    LOW_STOCK
        #END

        &{new}=    Create Dictionary
        ...    title=${b}[title]
        ...    price=${price_num}
        ...    stock=${b}[stock]
        ...    status=${status}

        Append To List    ${result}    ${new}
    END

    RETURN    ${result}

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