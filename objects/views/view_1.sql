-- Начинающие авторы с единственной публикацией
CREATE OR REPLACE VIEW beginner_authors AS
SELECT
    a.author_id,
    e.name,
    CAST(MAX(n.publication_time) AS DATE) AS publication_date
FROM
    author a
        JOIN
    employee e ON a.employee_id = e.employee_id
        JOIN
    news n ON a.author_id = n.author_id
GROUP BY
    a.author_id, e.name
HAVING
    COUNT(n.news_id) = 1
ORDER BY
    publication_date;