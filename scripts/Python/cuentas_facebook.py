import pandas as pd
import time
from search_engine_parser.core.engines.bing import Search as BingSearch
from search_engine_parser.core.engines.yahoo import Search as YahooSearch
from search_engine_parser.core.engines.duckduckgo import Search as DuckSearch

# A veces los buscadores bloquean el script, entonces cambiar de buscador
# Cambiar a: BingSearch(), YahooSearch(), DuckSearch()
dsearch = DuckSearch()

# Obtener la lista de gobernantes y agregar palabra clave
data_url = "https://raw.githubusercontent.com/lab-tecnosocial/sinoptico-del-poder/main/data/datos_limpios.csv"
palabra_clave = " facebook"
df_gobernantes = pd.read_csv(data_url)
lista_nombres = pd.Series.tolist(df_gobernantes["nombre"] + palabra_clave)


# Buscar
df = pd.DataFrame(columns=["query", "titles", "links", "descriptions"])
for i in range(len(lista_nombres)):
    resultado = dsearch.search(lista_nombres[i], 1)
    time.sleep(2)
    resultado_df = pd.DataFrame.from_dict(resultado.__dict__["results"])
    resultado_df["query"] = lista_nombres[i]
    df = df.append(resultado_df, ignore_index=True)

# Guardar en CSV
df.to_csv("data/resultados_facebook.csv")
