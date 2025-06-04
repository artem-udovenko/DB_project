import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sqlalchemy import create_engine
import os
from dotenv import load_dotenv
from scipy.stats import linregress

load_dotenv()

def get_alchemy_engine():
    return create_engine(
        f"postgresql+psycopg2://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
        f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
    )

def plot_mediasets_vs_employees():
    engine = get_alchemy_engine()

    query = """
    WITH resource_stats AS (
        SELECT 
            r.resource_id,
            COUNT(DISTINCT e.employee_id) AS employees_count,
            COUNT(DISTINCT n.mediaset_id) FILTER (WHERE n.mediaset_id IS NOT NULL) AS mediasets_count
        FROM resource r
        LEFT JOIN employee e ON r.resource_id = e.resource_id
        LEFT JOIN author a ON e.employee_id = a.employee_id
        LEFT JOIN news n ON a.author_id = n.author_id
        GROUP BY r.resource_id
        HAVING COUNT(DISTINCT e.employee_id) > 0  -- Исключаем ресурсы без сотрудников
    )
    SELECT * FROM resource_stats WHERE mediasets_count > 0;  -- Исключаем ресурсы без медиасетов
    """

    try:
        df = pd.read_sql(query, engine)

        if not df.empty:
            plt.figure(figsize=(12, 8))

            # Построение точечного графика
            scatter = sns.scatterplot(
                x='employees_count',
                y='mediasets_count',
                data=df,
                s=100,
                color='#2980b9',
                alpha=0.7
            )

            # Добавление линии регрессии
            slope, intercept, r_value, p_value, std_err = linregress(
                df['employees_count'],
                df['mediasets_count']
            )
            sns.lineplot(
                x=df['employees_count'],
                y=slope * df['employees_count'] + intercept,
                color='#e74c3c',
                linewidth=2,
                label=f'Тренд (R²={r_value**2:.2f})'
            )

            # Настройки графика
            plt.title('Зависимость количества медиасетов от числа сотрудников', fontsize=16)
            plt.xlabel('Количество сотрудников', fontsize=12)
            plt.ylabel('Использовано медиасетов', fontsize=12)
            plt.grid(alpha=0.3)
            plt.legend()

            plt.tight_layout()
            plt.savefig('../docs/charts/mediasets_per_employees.png', dpi=300)
            print("График сохранен как mediasets_per_employees.png")

        else:
            print("Нет данных для построения графика")

    except Exception as e:
        print(f"Ошибка: {e}")
    finally:
        plt.close()

if __name__ == "__main__":
    plot_mediasets_vs_employees()