import os
import pandas as pd


class OlistDataLoader:
    """
    Procedimento para carregamento dos dados no banco de dados e
    transformação dos nomes das tabelas
    """

    def __init__(self, datasets_path, database_engine):
        self.dataset_path = datasets_path
        self.database_engine = database_engine

    def load_data(self):
        """..."""
        for csv_file in os.listdir(self.dataset_path):
            df_temp = pd.read_csv(os.path.join(self.dataset_path, csv_file))
            table_names = "tb_" + csv_file.strip(".csv").replace("olist_", "").replace(
                "_dataset", ""
            )
            print(f"==> Importando {csv_file} para tabela {table_names}...")
            df_temp.to_sql(
                table_names, con=self.database_engine, if_exists="replace", index=False
            )
            print("==> ok")
