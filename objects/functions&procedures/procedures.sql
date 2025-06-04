-- Отчет для темы
CREATE OR REPLACE PROCEDURE generate_topic_report(
    topic_name VARCHAR,
    start_date TIMESTAMP DEFAULT '1990-01-01 00:00:00',
    end_date TIMESTAMP DEFAULT NOW()
) AS $$
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
    WHERE t.name = topic_name
      AND n.publication_time BETWEEN $2 AND $3;

    CREATE TABLE IF NOT EXISTS topic_reports(
        report_date TIMESTAMP,
        content TEXT
    );

    INSERT INTO topic_reports(report_date, content)
    VALUES (NOW(), report_text);
    COMMIT;
END;
$$ LANGUAGE plpgsql;

CALL generate_topic_report('Политика');

-- Анализ ресурса
CREATE OR REPLACE PROCEDURE resource_analysis_report(p_resource_id INT)
AS $$
DECLARE
    total_employees INT;
    author_employees INT;
    non_author_employees INT;
    total_news BIGINT;
    resource_name VARCHAR;
    resource_verified BOOLEAN;
BEGIN
    SELECT name, verified
    INTO resource_name, resource_verified
    FROM resource
    WHERE resource_id = p_resource_id;

    IF NOT FOUND THEN
        RAISE NOTICE 'Ресурс с ID % не найден.', p_resource_id;
        RETURN;
    END IF;

    SELECT COUNT(*)
    INTO total_employees
    FROM employee
    WHERE resource_id = p_resource_id;

    SELECT COUNT(DISTINCT a.employee_id)
    INTO author_employees
    FROM author a
             JOIN employee e ON a.employee_id = e.employee_id
    WHERE e.resource_id = p_resource_id;

    non_author_employees := total_employees - author_employees;

    SELECT COUNT(n.news_id)
    INTO total_news
    FROM news n
             JOIN author a ON n.author_id = a.author_id
             JOIN employee e ON a.employee_id = e.employee_id
    WHERE e.resource_id = p_resource_id;

    RAISE NOTICE 'Отчёт по ресурсу "%":', resource_name;
    RAISE NOTICE ' - Проверен: %', resource_verified;
    RAISE NOTICE ' - Общее количество сотрудников: %', total_employees;
    RAISE NOTICE ' - Сотрудников-авторов: %', author_employees;
    RAISE NOTICE ' - Сотрудников без авторства: %', non_author_employees;
    RAISE NOTICE ' - Общее количество новостей: %', total_news;
END;
$$ LANGUAGE plpgsql;

CALL resource_analysis_report(2);
