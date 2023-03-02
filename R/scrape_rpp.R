#' Script for downloading 
#' "Orgány veřejné moci evidované v Registru práv a povinností 
#' ve smyslu § 51 zákona č. 111/2009 Sb. o základních registrech."

library(here)
library(dplyr)
library(jsonlite)

ovm <- fromJSON("https://rpp-opendata.egon.gov.cz/odrpp/datovasada/ovm.jsonld", 
                simplifyVector = FALSE)

pravni_forma <- fromJSON("https://rpp-opendata.egon.gov.cz/odrpp/datovasada/cis_pravnich_forem.json")
pravni_forma_df <- pravni_forma$položky %>% 
  select(id, popis) %>% 
  mutate(nazev_pravni_formy = popis$cs) %>% 
  select(-popis)

parse_osoba_v_cele <- function(x){
  purrr::map_dfr(x, function(i) {
    tibble(
      osoba_type = i$type, 
      osoba_jmeno = i$jméno
    )
  })
}

parse_ovm <- function(x){
  tibble(
    # type = x$type, 
    # id = x$id, 
    identifikator = x$identifikátor, 
    nazev = x$název$cs,
    # vnitrni_organizacni_jednotka = x$`vnitřní-organizační-jednotka`,
    ico = x$ičo, 
    n_osoba_v_cele = length(x$`osoba-v-čele`), 
    osoba_v_cele = list(parse_osoba_v_cele(x$`osoba-v-čele`)),
    # osoba_v_cele_jmeno = x$`osoba-v-čele`[[1]]$jméno, 
    # zahajeni = x$zahájení, 
    pravni_forma = x$`právní-forma`
  )
}

ovm_parsed_df <- purrr::map_dfr(ovm$položky, ~parse_ovm(.x)) %>% 
  left_join(., pravni_forma_df, by = c("pravni_forma"="id"))

TODAY <- as.character(Sys.Date())
saveRDS(ovm_parsed_df, here("output", "rds", glue::glue("ovm_parsed_{TODAY}.rds")))

starostove_hejtmani <- ovm_parsed_df %>% 
  filter(nazev_pravni_formy %in% c("Obec", "Kraj", "Městská část, městský obvod")) %>% 
  tidyr::unnest(., osoba_v_cele, keep_empty = TRUE)

saveRDS(starostove_hejtmani, here("output", "rds", glue::glue("starostove_hejtmani_{TODAY}.rds")))
write.csv(starostove_hejtmani, here("output", "soucasni_starostove_hejtmani.csv"), 
          row.names = FALSE)
