import os

from dotenv import load_dotenv
from sqlalchemy import create_engine

from core.olist_data_extractor import OlistDataExtractor
from core.olist_data_loader import OlistDataLoader

load_dotenv()


def main():
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    DATA_DIR = os.path.join(BASE_DIR, "data")
    DATA_RAW = os.path.join(DATA_DIR, "raw")
    ZIP_FILE = "olist_data.zip"

    try:
        CONNECTION_STRING = os.environ.get("CONNECTION_STRING")
        DB = create_engine(CONNECTION_STRING)

        olist_extractor = OlistDataExtractor(
            zip_file=ZIP_FILE, data_dir=DATA_DIR, output_path=DATA_RAW
        )

        olist_extractor.extract_data()

        olist_loader = OlistDataLoader(datasets_path=DATA_RAW, database_engine=DB)

        olist_loader.load_data()
    except KeyError:
        print("A variável de Ambinete `CONNECTION_STRING` não está definida...")
    except Exception as err:
        print(f"Ocorreu um erro inesperado: {err}")


if __name__ == "__main__":
    main()
