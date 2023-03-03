# mayors2

Repozitář pro stahování [Orgánů veřejné moci](https://data.gov.cz/datov%C3%A1-sada?iri=https://data.gov.cz/zdroj/datov%C3%A9-sady/00007064/44a9d6abacd4d0e83a0694e74d028f51) v [Registru práv a povinností](https://data.gov.cz/datov%C3%A9-sady?str%C3%A1nka=3&kl%C3%AD%C4%8Dov%C3%A1-slova=registr%20pr%C3%A1v%20a%20povinnost%C3%AD)
a extrakci současných hejtmanů a starostů. 

Repository for downloading [Public Authorities](https://data.gov.cz/datov%C3%A1-sada?iri=https://data.gov.cz/zdroj/datov%C3%A9-sady/00007064/44a9d6abacd4d0e83a0694e74d028f51) in the [Register of Rights and Obligations](https://data.gov.cz/datov%C3%A9-sady?str%C3%A1nka=3&kl%C3%AD%C4%8Dov%C3%A1-slova=registr%20pr%C3%A1v%20a%20povinnost%C3%AD) and extraction of current governors and mayors.

## Content
- `output/`
  - `rds/` - pre-processed list of Public Authorities saved as .rds file
  - `soucasni_starostove_hejtmani.csv` - Current mayors and regional governors
- `R/`
  - `scrape_rpp.R` - script for downloading and processing the data
  
## More info
- [https://www.mvcr.cz/clanek/poskytnuti-informace-seznam-soucasnych-i-minulych-starostu-a-primatoru-vsech-obci-cr.aspx](https://www.mvcr.cz/clanek/poskytnuti-informace-seznam-soucasnych-i-minulych-starostu-a-primatoru-vsech-obci-cr.aspx)
