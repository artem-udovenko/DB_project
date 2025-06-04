import psycopg2
import random
from faker import Faker
from datetime import timedelta
import os
from dotenv import load_dotenv

fake = Faker()
load_dotenv()

DB_CONFIG = {
    'dbname': os.getenv('DB_NAME'),
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD'),
    'host': os.getenv('DB_HOST'),
    'port': os.getenv('DB_PORT')
}

OCCUPATIONS = [
    'Журналист', 'Редактор', 'Корреспондент', 'Фотограф',
    'Видеооператор', 'Аналитик', 'Дизайнер', 'IT-специалист'
]

SOCIAL_MEDIA = [
    'Официальный сайт', 'Telegram', 'VKontakte', 'YouTube',
    'Twitter', 'Facebook', 'Instagram', 'Odnoklassniki'
]

using_mediasets = dict()

def get_author_to_employee_mapping() -> dict:
    """Возвращает словарь соответствия author_id → employee_id"""
    mapping = {}
    conn = None
    try:
        conn = get_connection()
        with conn.cursor() as cur:
            cur.execute("SELECT author_id, employee_id FROM author")
            mapping = dict(cur.fetchall())
    except psycopg2.Error as e:
        print(f"Ошибка при получении соответствия авторов: {e}")
    finally:
        if conn:
            conn.close()
    return mapping

def get_connection():
    return psycopg2.connect(**DB_CONFIG)

def populate_resources(num=100):
    conn = get_connection()
    with conn.cursor() as cur:
        data = []
        for i in range(1, num + 1):
            name = fake.company() + random.choice([' Media', ' News', ' Press'])
            href = f'https://www.{fake.domain_name()}'
            verified = random.choice([True, False])
            data.append((i, name, href, verified))

        cur.executemany("""
            INSERT INTO resource (resource_id, name, href, verified)
            VALUES (%s, %s, %s, %s)
            ON CONFLICT DO NOTHING
        """, data)
        conn.commit()
    conn.close()

def populate_employees(num_per_resource=15):
    conn = get_connection()
    with conn.cursor() as cur:
        cur.execute("SELECT resource_id FROM resource")
        resource_ids = [r[0] for r in cur.fetchall()]

        employee_id = 1
        for res_id in resource_ids:
            for _ in range(random.randint(int(num_per_resource * 0.6), int(num_per_resource * 2.2))):
                name = fake.name()
                occupation = random.choice(OCCUPATIONS)
                cur.execute("""
                    INSERT INTO employee (employee_id, resource_id, name, occupation)
                    VALUES (%s, %s, %s, %s)
                """, (employee_id, res_id, name, occupation))
                employee_id += 1
        conn.commit()
    conn.close()

def populate_authors():
    conn = get_connection()
    with conn.cursor() as cur:
        cur.execute("SELECT employee_id FROM employee")
        employee_ids = [e[0] for e in cur.fetchall()]

        author_id = 1
        for emp_id in employee_ids:
            if random.random() < 0.7:  # 70% сотрудников становятся авторами
                old_status = random.choice([
                    'Стажер', 'Фрилансер', 'Младший сотрудник', None
                ])
                new_status = random.choice([
                    'Штатный автор', 'Старший корреспондент', 'Ведущий редактор'
                ])
                cur.execute("""
                    INSERT INTO author (author_id, employee_id, old_info, new_info)
                    VALUES (%s, %s, %s, %s)
                """, (author_id, emp_id, old_status, new_status))
                author_id += 1
        conn.commit()
    conn.close()

def populate_registry_status():
    conn = get_connection()
    with conn.cursor() as cur:
        cur.execute("SELECT resource_id, verified FROM resource")
        for res_id, verified in cur.fetchall():
            if verified:
                platforms = random.sample(SOCIAL_MEDIA, 1)
                if random.random() < 0.5:
                    platforms[0] = SOCIAL_MEDIA[0]
                platform = platforms[0]
                cur.execute("""
                    INSERT INTO registry_status (resource_id, social_media)
                    VALUES (%s, %s)
                    ON CONFLICT DO NOTHING
                """, (res_id, platform))
        conn.commit()
    conn.close()

def populate_topics():
    conn = get_connection()
    with conn.cursor() as cur:
        cur.execute("SELECT employee_id FROM employee")
        employee_ids = [e[0] for e in cur.fetchall()]
        num = len(employee_ids)
    conn.close()
    conn = get_connection()
    topic_ids = []
    with conn.cursor() as cur:
        for i in range(1, num + 1):
            name = fake.catch_phrase()
            location = fake.city() if random.random() > 0.5 else None
            start_date = fake.date_between(start_date='-2y', end_date='today')
            end_date = start_date + timedelta(days=random.randint(30, 365)) if random.random() > 0.7 else None

            cur.execute("""
                INSERT INTO topic (topic_id, name, location, start_date, end_date)
                VALUES (%s, %s, %s, %s, %s)
            """, (i, name[:50], location, start_date, end_date))
            topic_ids.append(i)
        conn.commit()
    conn.close()
    random.shuffle(topic_ids)
    for employee_id in employee_ids:
        using_mediasets[employee_id] = topic_ids.pop()

def populate_media(num=200):
    conn = get_connection()
    with conn.cursor() as cur:
        for i in range(1, num + 1):
            old_copyright = fake.company() if random.random() > 0.5 else None
            new_copyright = fake.company()
            old_path = f"/archive/{fake.file_path()}"
            new_path = f"/media/{fake.file_name()}"

            cur.execute("""
                INSERT INTO media (media_id, old_copyright, new_copyright, old_path, new_path)
                VALUES (%s, %s, %s, %s, %s)
            """, (i, old_copyright, new_copyright, old_path, new_path))
        conn.commit()
    conn.close()

def populate_mediasets(num=100):
    conn = get_connection()
    with conn.cursor() as cur:
        for i in range(1, num + 1):
            description = fake.sentence() if random.random() > 0.3 else None
            cur.execute("""
                INSERT INTO mediaset (mediaset_id, description)
                VALUES (%s, %s)
            """, (i, description))
        conn.commit()
    conn.close()

def populate_correspondence():
    conn = get_connection()
    with conn.cursor() as cur:
        cur.execute("SELECT media_id FROM media")
        media_ids = [m[0] for m in cur.fetchall()]

        cur.execute("SELECT mediaset_id FROM mediaset")
        mediaset_ids = [m[0] for m in cur.fetchall()]

        pair_id = 1
        for ms_id in mediaset_ids:
            num_media = random.randint(1, 5)
            selected_media = random.sample(media_ids, num_media)
            for media_id in selected_media:
                cur.execute("""
                    INSERT INTO correspondence (pair_id, mediaset_id, media_id)
                    VALUES (%s, %s, %s)
                """, (pair_id, ms_id, media_id))
                pair_id += 1
        conn.commit()
    conn.close()

def populate_news(num=1000):
    conn = get_connection()
    with conn.cursor() as cur:
        cur.execute("SELECT author_id FROM author")
        author_ids = [a[0] for a in cur.fetchall()]

        cur.execute("SELECT topic_id FROM topic")
        topic_ids = [t[0] for t in cur.fetchall()]

        cur.execute("SELECT mediaset_id FROM mediaset")
        mediaset_ids = [m[0] for m in cur.fetchall()]

        mediasets = dict()
        for author_id in author_ids:
            mediasets[author_id] = random.choice(mediaset_ids)

        for i in range(1, num + 1):
            author_id = random.choice(author_ids)
            topic_id = random.choice(topic_ids)
            mediaset_id = using_mediasets[get_author_to_employee_mapping()[author_id]]
            headline = fake.sentence()[:-1]
            content = fake.text(max_nb_chars=1000)
            pub_date = fake.date_time_between(start_date='-1y', end_date='now')

            cur.execute("""
                INSERT INTO news (news_id, author_id, topic_id, mediaset_id, headline, content, publication_time)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """, (i, author_id, topic_id, mediaset_id, headline[:50], content, pub_date))
        conn.commit()
    conn.close()

if __name__ == "__main__":
    print("Заполнение ресурсов...")
    populate_resources()

    print("Создание сотрудников...")
    populate_employees()

    print("Назначение авторов...")
    populate_authors()

    print("Регистрация статусов...")
    populate_registry_status()

    print("Генерация тем...")
    populate_topics()

    print("Создание медиа...")
    populate_media()

    print("Формирование медианаборов...")
    populate_mediasets()

    print("Связывание медиа с наборами...")
    populate_correspondence()

    print("Публикация новостей...")
    populate_news()

    print("База данных успешно заполнена!")