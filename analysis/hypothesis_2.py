import pandas as pd
import matplotlib.pyplot as plt
from sqlalchemy import create_engine
import os
from dotenv import load_dotenv

load_dotenv()

def get_alchemy_engine():
    return create_engine(
        f"postgresql+psycopg2://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
        f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
    )

def plot_social_media_distribution():
    engine = get_alchemy_engine()

    query = """
    WITH all_platforms AS (
        SELECT 'Нет соцсетей' AS platform
        UNION
        SELECT unnest(ARRAY[
            'Официальный сайт', 'Telegram', 'VKontakte', 
            'YouTube', 'Twitter', 'Facebook', 'Instagram', 
            'Odnoklassniki'
        ]) AS platform
    ),
    resources_with_platforms AS (
        SELECT 
            ap.platform,
            COUNT(DISTINCT r.resource_id) AS total_resources
        FROM all_platforms ap
        LEFT JOIN registry_status rs ON ap.platform = rs.social_media
        LEFT JOIN resource r ON rs.resource_id = r.resource_id
        GROUP BY ap.platform
    ),
    no_social_resources AS (
        SELECT COUNT(*) AS total
        FROM resource
        WHERE resource_id NOT IN (SELECT resource_id FROM registry_status)
    )
    
    SELECT 
        CASE 
            WHEN rwp.platform = 'Нет соцсетей' THEN '1. Нет соцсетей'
            ELSE rwp.platform 
        END AS platform,
        CASE 
            WHEN rwp.platform = 'Нет соцсетей' THEN nsr.total
            ELSE rwp.total_resources 
        END AS total
    FROM resources_with_platforms rwp
    CROSS JOIN no_social_resources nsr
    ORDER BY platform = '1. Нет соцсетей' DESC, total DESC;
    """

    try:
        df = pd.read_sql(query, engine)

        if not df.empty:
            plt.figure(figsize=(14, 8))

            bars = plt.bar(df['platform'], df['total'], color='#3498db')

            plt.title('Распределение ресурсов по социальным сетям', fontsize=16)
            plt.xlabel('Платформа', fontsize=12)
            plt.ylabel('Количество ресурсов', fontsize=12)
            plt.xticks(rotation=45, ha='right', fontsize=10)
            plt.grid(axis='y', alpha=0.3)

            for bar in bars:
                height = bar.get_height()
                plt.text(bar.get_x() + bar.get_width()/2., height,
                         f'{height}',
                         ha='center', va='bottom',
                         fontsize=10)

            plt.tight_layout()
            plt.savefig('../docs/charts/social_media_distribution.png', dpi=300, bbox_inches='tight')
            print("График успешно сохранен как social_media_distribution.png")

        else:
            print("Нет данных для визуализации")

    except Exception as e:
        print(f"Ошибка: {e}")
    finally:
        plt.close()

if __name__ == "__main__":
    plot_social_media_distribution()