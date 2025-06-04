CREATE OR REPLACE FUNCTION news_after_insert_trigger()
    RETURNS TRIGGER AS $$
DECLARE
    topic_name VARCHAR;
BEGIN
    SELECT name INTO topic_name FROM topic WHERE topic_id = NEW.topic_id;

    PERFORM f_generate_topic_report(topic_name);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER news_after_insert
    AFTER INSERT ON news
    FOR EACH ROW
EXECUTE FUNCTION news_after_insert_trigger();
