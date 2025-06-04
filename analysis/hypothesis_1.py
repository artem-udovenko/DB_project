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

def plot_author_percentage():
    engine = get_alchemy_engine()

    query = """
    SELECT 
        r.name AS resource_name,
        COUNT(DISTINCT e.employee_id) AS total_employees,
        COUNT(DISTINCT a.author_id) AS total_authors,
        ROUND(COUNT(DISTINCT a.author_id) * 100.0 / GREATEST(COUNT(DISTINCT e.employee_id), 1), 2) AS author_percentage
    FROM resource r
    LEFT JOIN employee e ON r.resource_id = e.resource_id
    LEFT JOIN author a ON e.employee_id = a.employee_id
    GROUP BY r.resource_id
    ORDER BY author_percentage DESC;
    """

    try:
        df = pd.read_sql(query, engine)

        mean_val = df['author_percentage'].mean()
        std_dev = df['author_percentage'].std()

        print("\nСтатистика по доле авторов:")
        print(f"Среднее значение: {mean_val:.2f}%")
        print(f"Стандартное отклонение: {std_dev:.2f}%")
        print(f"Минимальное значение: {df['author_percentage'].min():.2f}%")
        print(f"Максимальное значение: {df['author_percentage'].max():.2f}%")
        print(f"Количество ресурсов: {len(df)}")

        plt.figure(figsize=(14, 8))
        bars = plt.bar(df['resource_name'], df['author_percentage'], color='#4c72b0')

        plt.title('Доля авторов среди сотрудников по медиаресурсам', fontsize=16)
        plt.xlabel('Ресурс', fontsize=12)
        plt.ylabel('Доля авторов (%)', fontsize=12)
        plt.xticks(rotation=45, ha='right', fontsize=10)
        plt.ylim(0, 100)
        plt.grid(axis='y', alpha=0.5)

        for bar in bars:
            height = bar.get_height()
            plt.text(bar.get_x() + bar.get_width()/2., height,
                     f'{height:.1f}%',
                     ha='center', va='bottom',
                     fontsize=9)

        plt.tight_layout()

        plt.savefig('../docs/charts/authors_percentage.png', dpi=500, bbox_inches='tight')
        print("График успешно сохранен как authors_percentage.png")

    except Exception as e:
        print(f"Ошибка: {e}")
    finally:
        plt.close()

if __name__ == "__main__":
    plot_author_percentage()