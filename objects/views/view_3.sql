-- Полная информация о новостях
CREATE OR REPLACE VIEW news_full AS
SELECT
    n.news_id,
    n.headline,
    e.name AS author_name,
    t.name AS topic,
    r.name AS resource_name,
    n.publication_time
FROM news n
         JOIN author a ON n.author_id = a.author_id
         JOIN employee e ON a.employee_id = e.employee_id
         JOIN topic t ON n.topic_id = t.topic_id
         JOIN resource r ON e.resource_id = r.resource_id
ORDER BY n.publication_time DESC;