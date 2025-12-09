*** Settings ***
Resource    ../resources/keywords_web.robot
Resource    ../resources/utils.robot
Resource    ../resources/keywords_excel.robot

*** Keywords ***
Scrape Book Data
    Open Book Store Website
    ${data}=    Extract Books From HomepageAllPages  # Ganti ke HomepageAllPages
    @{processed_data}=    Process Book Data    ${data}
    
    # Unpack return values
    ${all_books}=    Set Variable    ${processed_data}[0]
    ${fantasy_books}=    Set Variable    ${processed_data}[1]
    ${biography_books}=    Set Variable    ${processed_data}[2]

    Log    First book sample: ${all_books}[0]
    Log    Book keys: ${all_books}[0].keys()
    Save Books To Excel    ${all_books}    ${fantasy_books}    ${biography_books}    ${CURDIR}/../data/books.xlsx
    Close Browser