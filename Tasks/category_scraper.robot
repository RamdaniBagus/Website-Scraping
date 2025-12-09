*** Settings ***
Resource    ../resources/keywords_web.robot
Resource    ../resources/utils.robot
Resource    ../resources/keywords_excel.robot

*** Keywords ***
Sync BookCategories
    [Arguments]    ${homepage_books}    ${fantasy_books}    ${biography_books}
    
    @{synced_books}=    Create List
    
    # Buat dictionary untuk mapping title -> category dari Fantasy dan Biography
    &{fantasy_map}=    Create Dictionary
    &{biography_map}=    Create Dictionary
    
    # Map Fantasy books
    FOR    ${book}    IN    @{fantasy_books}
        ${title}=    Get From Dictionary    ${book}    title
        ${category}=    Get From Dictionary    ${book}    category
        Set To Dictionary    ${fantasy_map}    ${title}=${category}
    END
    
    # Map Biography books
    FOR    ${book}    IN    @{biography_books}
        ${title}=    Get From Dictionary    ${book}    title
        ${category}=    Get From Dictionary    ${book}    category
        Set To Dictionary    ${biography_map}    ${title}=${category}
    END
    
    Log To Console    \n=== SYNCING CATEGORIES ===
    Log To Console    Fantasy books in map: ${fantasy_map.keys()}
    Log To Console    Biography books in map: ${biography_map.keys()}
    
    # Update kategori di homepage books berdasarkan judul
    FOR    ${book}    IN    @{homepage_books}
        ${title}=    Get From Dictionary    ${book}    title
        
        # Cek apakah buku ini ada di Fantasy map
        ${is_in_fantasy}=    Run Keyword And Return Status
        ...    Dictionary Should Contain Key    ${fantasy_map}    ${title}
        
        # Cek apakah buku ini ada di Biography map  
        ${is_in_biography}=    Run Keyword And Return Status
        ...    Dictionary Should Contain Key    ${biography_map}    ${title}
        
        IF    ${is_in_fantasy}
            ${correct_category}=    Get From Dictionary    ${fantasy_map}    ${title}
            Set To Dictionary    ${book}    category=${correct_category}
            Log To Console    Updated ${title}: Unknown -> ${correct_category} (from Fantasy)
        ELSE IF    ${is_in_biography}
            ${correct_category}=    Get From Dictionary    ${biography_map}    ${title}
            Set To Dictionary    ${book}    category=${correct_category}
            Log To Console    Updated ${title}: Unknown -> ${correct_category} (from Biography)
        END
        
        Append To List    ${synced_books}    ${book}
    END
    
    RETURN    ${synced_books}

Scrape FantasyAndBiographyCategories
    Open Book Store Website
    
    Log To Console    \n=== STARTING SCRAPING PROCESS ===
    
    # 1. Ambil SEMUA buku dari homepage (semua halaman)
    Log    Step 1: Extracting ALL books from homepage (all pages)...
    ${homepage_books}=    Extract Books From HomepageAllPages
    
    ${homepage_count}=    Get Length    ${homepage_books}
    Log To Console    Homepage books extracted (ALL PAGES): ${homepage_count}
    
    # 2. Ambil buku khusus dari kategori Fantasy (semua halaman)
    Log    Step 2: Extracting Fantasy books...
    ${fantasy_books}=    Extract Books From FantasyCategory
    
    ${fantasy_count}=    Get Length    ${fantasy_books}
    Log To Console    Fantasy books extracted: ${fantasy_count}
    
    # 3. Ambil buku khusus dari kategori Biography (semua halaman)
    Log    Step 3: Extracting Biography books...
    ${biography_books}=    Extract Books From BiographyCategory
    
    ${biography_count}=    Get Length    ${biography_books}
    Log To Console    Biography books extracted: ${biography_count}
    
    # 4. Process data Fantasy (tanpa homepage)
    @{processed_fantasy_data}=    Process Book Data    ${fantasy_books}
    ${processed_fantasy_books}=    Set Variable    ${processed_fantasy_data}[1]  # Index 1 untuk Fantasy
    
    # 5. Process data Biography (tanpa homepage)
    @{processed_biography_data}=    Process Book Data    ${biography_books}
    ${processed_biography_books}=    Set Variable    ${processed_biography_data}[2]  # Index 2 untuk Biography
    
    # 6. Sync categories untuk homepage books
    ${synced_homepage_books}=    Sync BookCategories
    ...    ${homepage_books}
    ...    ${fantasy_books}    # Raw Fantasy books (belum diproses)
    ...    ${biography_books}  # Raw Biography books (belum diproses)
    
    # 7. Process homepage books setelah sync
    @{processed_homepage_data}=    Process Book Data    ${synced_homepage_books}
    ${processed_homepage_books}=    Set Variable    ${processed_homepage_data}[0]
    
    # 8. Hitung hasil setelah sync
    ${synced_count}=    Get Length    ${synced_homepage_books}
    ${homepage_final_count}=    Get Length    ${processed_homepage_books}
    ${fantasy_final_count}=    Get Length    ${processed_fantasy_books}
    ${biography_final_count}=    Get Length    ${processed_biography_books}
    
    # 9. Hitung berapa banyak kategori yang diperbarui
    ${updated_count}=    Evaluate    ${synced_count} - ${homepage_count}
    IF    ${updated_count} > 0
        Log To Console    \n=== CATEGORY UPDATES ===
        Log To Console    Updated categories for ${updated_count} books
    END
    
    Log To Console    \n=== FINAL COUNTS ===
    Log To Console    All_Books (Homepage with synced categories): ${homepage_final_count}
    Log To Console    Fantasy_Books: ${fantasy_final_count}
    Log To Console    Biography_Books: ${biography_final_count}
    
    # 10. Save to Excel
    Save Books To Excel    
    ...    ${processed_homepage_books}    # All_Books: dari homepage dengan kategori sync
    ...    ${processed_fantasy_books}     # Fantasy_Books: hanya dari kategori Fantasy  
    ...    ${processed_biography_books}   # Biography_Books: hanya dari kategori Biography
    ...    ${CURDIR}/../data/books.xlsx
    
    Close Browser
    Log    Scraping completed successfully!