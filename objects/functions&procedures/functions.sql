-- Статистика автора
CREATE OR REPLACE FUNCTION calculate_author_activity(author_id INT)
    RETURNS TABLE (
                      total_news BIGINT,
                      last_publication TIMESTAMP,
                      avg_media_per_news NUMERIC
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT
            COUNT(n.news_id),
            MAX(n.publication_time),
            AVG(media_count)::NUMERIC(10,2)
        FROM news n
                 LEFT JOIN (
            SELECT mediaset_id, COUNT(*) AS media_count
            FROM correspondence
            GROUP BY mediaset_id
        ) c ON n.mediaset_id = c.mediaset_id
        WHERE n.author_id = $1
        GROUP BY n.author_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM calculate_author_activity(1);

-- Количество новостей
CREATE OR REPLACE FUNCTION get_news_count_by_resource()
    RETURNS TABLE (
                      resource_id INT,
                      resource_name VARCHAR,
                      verified BOOLEAN,
                      news_count BIGINT
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT
            r.resource_id,
            r.name,
            r.verified,
            COUNT(n.news_id)::BIGINT AS news_count
        FROM resource r
                 LEFT JOIN employee e ON e.resource_id = r.resource_id
                 LEFT JOIN author a ON a.employee_id = e.employee_id
                 LEFT JOIN news n ON n.author_id = a.author_id
        GROUP BY r.resource_id, r.name, r.verified
        ORDER BY news_count DESC;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM get_news_count_by_resource();

-- Подсчет сотрудников, не являющихся авторами
CREATE OR REPLACE FUNCTION count_non_author_employees(p_resource_id INT)
    RETURNS BIGINT AS $$
DECLARE
    non_author_count BIGINT;
BEGIN
    SELECT COUNT(*)
    INTO non_author_count
    FROM employee e
    WHERE e.resource_id = p_resource_id
      AND e.employee_id NOT IN (
        SELECT a.employee_id FROM author a
    );

    RETURN non_author_count;
END;
$$ LANGUAGE plpgsql;

SELECT count_non_author_employees(1);

CREATE TABLE IF NOT EXISTS topic_reports(
    report_date TIMESTAMP,
    content TEXT
);

-- Отчет
CREATE OR REPLACE FUNCTION f_generate_topic_report(
    topic_name VARCHAR,
    start_date TIMESTAMP DEFAULT '1990-01-01 00:00:00',
    end_date TIMESTAMP DEFAULT NOW()
)
    RETURNS VOID
AS $$
DECLARE
    report_text TEXT;
BEGIN
    SELECT
        STRING_AGG(
                FORMAT(
                        'Новость: %s (Автор: %s, Медиа: %s)',
                        n.headline,
                        e.name,
                        COALESCE(m.media_count::TEXT, 'нет')
                ),
                E'\n'
        )
    INTO report_text
    FROM news n
             JOIN author a ON n.author_id = a.author_id
             JOIN employee e ON a.employee_id = e.employee_id
             LEFT JOIN (
        SELECT mediaset_id, COUNT(*) AS media_count
        FROM correspondence
        GROUP BY mediaset_id
    ) m ON n.mediaset_id = m.mediaset_id
             JOIN topic t ON n.topic_id = t.topic_id
    WHERE t.name = $1
      AND n.publication_time BETWEEN $2 AND $3;

    INSERT INTO topic_reports(report_date, content)
    VALUES (NOW(), report_text);
END;
$$ LANGUAGE plpgsql;

