library(dplyr)
library(jsonlite)

ovm <- fromJSON("https://rpp-opendata.egon.gov.cz/odrpp/datovasada/ovm.json", 
                simplifyVector = FALSE)

pravni_forma <- fromJSON("https://rpp-opendata.egon.gov.cz/odrpp/datovasada/cis_pravnich_forem.json")
pravni_forma_df <- pravni_forma$položky

parse_ovm <- function(x){
  tibble(
    type = x$type, 
    id = x$id, 
    identifikator = x$identifikátor, 
    nazev = x$název$cs,
    vnitrni_organizacni_jednotka = x$`vnitřní-organizační-jednotka`,
    ico = x$ičo, 
    n_osoba_v_cele = length(x$`osoba-v-čele`), 
    osoba_v_cele_type = x$`osoba-v-čele`[[1]]$type,
    osoba_v_cele_jmeno = x$`osoba-v-čele`[[1]]$jméno, 
    zahajeni = x$zahájení, 
    pravni_forma = x$`právní-forma`
  )
}

starostove <- purrr::map_dfr(ovm$položky, ~parse_ovm(.x))

