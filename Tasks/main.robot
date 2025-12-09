*** Settings ***
Documentation     Real website scraping + validation + reporting workflow
Resource          scrape.robot
Resource          reporting.robot
Resource          category_scraper.robot

*** Variables ***
${EXCEL_FILE}    ${CURDIR}/../data/books.xlsx

*** Tasks ***

# Task 1: Basic scraping (hanya homepage) - SIMPLIFIED
#Run Homepage Scraping
#    Open Book Store Website
#    ${data_count}=    Get Length    ${data}
#    Log    Extracted ${data_count} books from homepage
#    
    # Process dan save sederhana
#   @{processed}=    Process Book Data    ${data}
#    ${all_books}=    Set Variable    ${processed}[0]
    
    # Save ke Excel (single sheet)
#    Save Books To Excel Single    ${all_books}    ${EXCEL_FILE}
    
#    Close Browser
#    Log    Homepage scraping completed!

# Task 2: Simple category scraping

Run SimpleCategoryScraping
    Scrape FantasyAndBiographyCategories
    Generate Excel Report

# Task 3: Analysis only
#Run AnalysisOnly
#    File Should Exist    ${EXCEL_FILE}
#    #Generate Excel Report