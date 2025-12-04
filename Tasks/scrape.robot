*** Settings ***
Resource    ../resources/keywords_web.robot
Resource    ../resources/utils.robot
Resource    ../resources/keywords_excel.robot

*** Keywords ***
Scrape Book Data
    Open Book Store Website
    ${data}=    Extract Books From First Page
    ${processed}=    Process Book Data    ${data}
    Save Books To Excel    ${processed}    ${CURDIR}/../data/books.xlsx
    Close Browser
