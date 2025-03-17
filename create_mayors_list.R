library(rvest)
library(dplyr)
library(statnipokladna)

files <- list.files(
  path = "output/rpp", 
  pattern = "starostove_hejtmani_*", 
  full.names = TRUE
)

starostove_df <- purrr::map_df(files, function(x) { 
  date <- as.Date(stringr::str_extract(x, "[0-9]{4}-[0-9]{2}-[0-9]{2}"))
  readRDS(x) %>% 
    mutate(date = date)
}) %>% 
  filter(!(pravni_forma == "právní-forma/804" & nazev != "HLAVNÍ MĚSTO PRAHA")) %>% 
  filter(!grepl("Vojenský újezd", nazev))

starostove_funkcni_obdobi <- starostove_df %>% 
  group_by(ico, nazev, osoba_jmeno) %>%
  summarise(min_date = min(date), 
            max_date = max(date), .groups = "drop") %>% 
  arrange(ico, min_date)

# ID obce
ucjed <- sp_get_codelist("ucjed", dest_dir = "data/budget_data")

id_obce <- ucjed %>% 
  filter(druhuj_id == 4) %>% 
  group_by(ico) %>% 
  filter(start_date == max(start_date)) %>% 
  ungroup() %>% 
  select(ico, obec, kod_obec = zuj_id) %>% 
  filter(obec != "Městská část Praha 13") %>% 
  mutate(kod_obec = case_when(
    is.na(kod_obec) & ico == "04498682" & obec == "Bražec" ~ "500101",
    is.na(kod_obec) & ico == "04498691" & obec == "Doupovské Hradiště" ~ "500127",
    is.na(kod_obec) & ico == "04521811" & obec == "Kozlov" ~ "	500135",
    is.na(kod_obec) & ico == "04498712" & obec == "Luboměř pod Strážnou" ~ "500151",
    is.na(kod_obec) & ico == "04498704" & obec == "Libavá" ~ "500160",
    is.na(kod_obec) & ico == "04498356" & obec == "Polná na Šumavě" ~ "500194", 
    TRUE ~ kod_obec
  ))

stopifnot(id_obce %>% 
  filter(is.na(kod_obec)) %>% 
  nrow() == 0)

# ID městské části
ciselnik_mestske_casti <- read.csv(
  "data/ciselnik_mestskych_casti/CIS0044_CS.csv") %>% 
  select(kod_mc = chodnota, 
         text) %>% 
  mutate(text = paste0("Městská část ", text))

mestske_casti <- starostove_funkcni_obdobi %>% 
  filter(grepl("Městská část", nazev)) %>% 
  select(ico, nazev) %>% 
  unique() %>% 
  left_join(., ciselnik_mestske_casti, by = c("nazev"="text")) %>% 
  select(ico, obec = nazev, kod_obec = kod_mc) %>% 
  mutate(kod_obec = as.character(kod_obec))

id_obce_mc <- bind_rows(id_obce, mestske_casti)

starostove_final <- left_join(starostove_funkcni_obdobi, id_obce_mc, by = "ico")

TODAY <- as.Date(Sys.Date())
saveRDS(starostove_final, glue::glue("output/final/rpp_starostove_funkcni_obdobi_{TODAY}.rds"))
