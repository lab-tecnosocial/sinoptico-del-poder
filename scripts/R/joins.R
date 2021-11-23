library(tidyverse)
library(googledrive)
library(googlesheets4)

# ids de archivos
principal_id <- "1jhLNmKuGNVEeknep26TFnMs_OeUjAb8p2sG1Yz26d_E"
denuncias_id <- "1wlt91AMqvQg076aHtpczzllSPJtxLz4QAK4_qvhdLeQ"
fb_nal_dep_id <- "1cfgImvxonshkyOjbGy0gHpYIiizfnCZLGujFOvj3WD8"
fb_mun_id <- "1LbOhlNrofMNc8joj5Sk8qmNREovCkuEx46KVbSjWxS0"
declara_id <- "declaraciones\ contraloria/declaraciones.csv"
declara_proc_id <- "declaraciones\ contraloria/processed_declaraciones.csv"

# cargar archivos en dfs
principal <- read_sheet(principal_id, sheet = "general")
denuncias <- read_sheet(denuncias_id)
fb_nal_dep <- read_sheet(fb_nal_dep_id)
fb_mun <- read_sheet(fb_mun_id)
declara <- read_csv(drive_read_string(declara_id))
declara_proc <- read_csv(drive_read_string(declara_proc_id))

# tidying declaraciones

declara_wide <- declara_proc %>%
  select(!c(unidad, fecha)) %>%
  pivot_wider(names_from = campo_declaracion, values_from = declara)
names(declara_wide) = c("codigo", "cantidad_bienes_rubro", "total_bienes_rubro", "total_rentas", "total_deudas1", "total_deudas2", "patrimonio_neto")

declara_full <- declara %>%
  left_join(declara_wide, by = "codigo")

# joins

fb_mun_found <- fb_mun %>%
  filter(es_cuenta == "Si") %>%
  mutate(nombre = str_remove(query, " facebook")) %>%
  rename(`pagina-fb` = results, name = nombre)

fb_cuentas<- fb_nal_dep %>%
  bind_rows(fb_mun_found)

declara_full <- declara_full %>%
  mutate(nombre = str_to_title(nombre))

principal_full <- principal %>%
  left_join(denuncias, by = "nombre") %>%
  left_join(fb_cuentas, by = c("nombre" = "name")) %>%
  left_join(declara_full, by = "nombre")

sheet_write(principal_full, principal_id, "gen_enrich")

# unir cuentas de fb en una sola columna
corr <- read_sheet(principal_id, sheet = "gen_enrich")
corr2 <- corr %>%
  unite("facebook", c("perfil_facebook", "pagina_facebook", "perfil_fb", "pagina-fb"), sep = ", ", na.rm = T)
