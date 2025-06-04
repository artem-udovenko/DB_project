TRUNCATE TABLE
    news,
    correspondence,
    mediaset,
    media,
    topic,
    registry_status,
    author,
    employee,
    resource;

DROP FUNCTION calculate_author_activity(author_id integer);
DROP FUNCTION get_news_count_by_resource();
DROP FUNCTION count_non_author_employees(p_resource_id integer);

DROP PROCEDURE generate_topic_report(topic_name varchar, start_date timestamp, end_date timestamp);
DROP PROCEDURE resource_analysis_report(p_resource_id integer);

DROP INDEX
    idx_correspondence_media,
    idx_correspondence_mediaset_media,
    idx_registry_status_resource_social,
    idx_registry_status_social_media,
    idx_topic_reports_date;

DROP TRIGGER author_upsert_trigger ON author;
DROP FUNCTION author_upsert_trigger();

DROP TRIGGER media_upsert_trigger ON media;
DROP FUNCTION media_upsert_trigger();

DROP TRIGGER news_after_insert ON news;
DROP FUNCTION news_after_insert_trigger();

DROP TRIGGER registry_status_after_insert ON registry_status;
DROP FUNCTION registry_status_after_insert_trigger();

DROP TRIGGER registry_status_after_delete ON registry_status;
DROP FUNCTION registry_status_after_delete_trigger();


DROP TABLE
    news,
    correspondence,
    mediaset,
    media,
    topic,
    registry_status,
    author,
    employee,
    resource;
