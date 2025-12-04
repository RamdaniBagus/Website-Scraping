*** Settings ***
Documentation     Real website scraping + validation + reporting workflow
Resource          scrape.robot
Resource          reporting.robot   # Pastikan ini yang aktif

*** Tasks ***
Run Real Price Monitoring Workflow
    Scrape Book Data           # Langkah 1-3: Scrape dan save
    Generate Excel Report      # Langkah 4-6: Baca Excel dan buat report
    # Sekarang akan memanggil Generate Excel Report dari reporting.robot