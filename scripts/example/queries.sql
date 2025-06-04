-- Найти авторов, опубликовавших более одной новости
SELECT a.author_id, e.name, COUNT(n.news_id) AS news_count
FROM author a
         JOIN employee e ON a.employee_id = e.employee_id
         JOIN news n ON a.author_id = n.author_id
GROUP BY a.author_id, e.name
HAVING COUNT(n.news_id) > 1
ORDER BY news_count DESC;

-- Рейтинг новостей по темам
SELECT
    t.name AS topic,
    n.headline,
    n.publication_time,
    RANK() OVER (PARTITION BY t.topic_id ORDER BY n.publication_time DESC) AS news_rank
FROM news n
         JOIN topic t ON n.topic_id = t.topic_id
WHERE t.end_date IS NULL
ORDER BY t.name, news_rank;

-- Найти сотрудников, которые не являются авторами
SELECT e.employee_id, e.name
FROM employee e
WHERE NOT EXISTS (
    SELECT 1 FROM author a
    WHERE a.employee_id = e.employee_id
)
ORDER BY e.name;

-- Найти медиа с измененным copyright
SELECT
    m.media_id,
    m.old_copyright,
    m.new_copyright,
    m.new_path
FROM media m
WHERE m.old_copyright IS NOT NULL
  AND m.old_copyright <> m.new_copyright;

-- Количество медиа по типам в каждом наборе
SELECT
    ms.mediaset_id,
    COUNT(CASE WHEN c.media_id BETWEEN 1 AND 30 THEN 1 END) AS photos,
    COUNT(CASE WHEN c.media_id BETWEEN 31 AND 60 THEN 1 END) AS videos,
    COUNT(CASE WHEN c.media_id BETWEEN 61 AND 80 THEN 1 END) AS graphics,
    COUNT(*) AS total_media
FROM mediaset ms
         JOIN correspondence c ON ms.mediaset_id = c.mediaset_id
GROUP BY ms.mediaset_id
HAVING COUNT(*) > 1
ORDER BY total_media DESC;

-- Новости с медиа, содержащими видео
SELECT n.news_id, n.headline, n.publication_time
FROM news n
WHERE n.mediaset_id IN (
    SELECT DISTINCT c.mediaset_id
    FROM correspondence c
    WHERE c.media_id BETWEEN 31 AND 60
)
ORDER BY n.publication_time DESC
LIMIT 10;

-- Сравнение дат публикации новостей
SELECT
    news_id,
    headline,
    publication_time,
    LAG(publication_time) OVER (ORDER BY publication_time) AS prev_publication,
    LEAD(publication_time) OVER (ORDER BY publication_time) AS next_publication
FROM news
WHERE topic_id = 1  -- Политика
ORDER BY publication_time
LIMIT 10;

-- Все ресурсы и их статус в реестре
SELECT
    r.resource_id,
    r.name,
    r.verified,
    rs.social_media
FROM resource r
         FULL JOIN registry_status rs ON r.resource_id = rs.resource_id
ORDER BY r.verified DESC, r.name;

-- Самые популярные темы (по количеству новостей)
SELECT t.topic_id, t.name, COUNT(n.news_id) AS news_count
FROM topic t
         JOIN news n ON t.topic_id = n.topic_id
GROUP BY t.topic_id, t.name
HAVING COUNT(n.news_id) >= ALL (
    SELECT COUNT(news_id)
    FROM news
    GROUP BY topic_id
)
ORDER BY news_count DESC;

-- Полная информация о новостях
SELECT
    n.news_id,
    n.headline,
    a.author_id,
    e.name AS author_name,
    t.name AS topic,
    r.name AS resource_name,
    n.publication_time
FROM news n
         JOIN author a ON n.author_id = a.author_id
         JOIN employee e ON a.employee_id = e.employee_id
         JOIN topic t ON n.topic_id = t.topic_id
         JOIN resource r ON e.resource_id = r.resource_id
WHERE n.publication_time BETWEEN '2023-01-01' AND '2023-12-31'
ORDER BY n.publication_time DESC
LIMIT 10 OFFSET 20;

