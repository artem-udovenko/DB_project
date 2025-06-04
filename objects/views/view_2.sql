-- Относительная хронология публикаций
CREATE OR REPLACE VIEW news_chronology AS
SELECT
    headline,
    publication_time,
    LAG(publication_time) OVER (ORDER BY publication_time) AS prev_publication,
    LEAD(publication_time) OVER (ORDER BY publication_time) AS next_publication
FROM news
ORDER BY publication_time
LIMIT 20 OFFSET 10;
