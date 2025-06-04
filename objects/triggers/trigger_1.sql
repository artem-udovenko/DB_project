CREATE OR REPLACE FUNCTION author_upsert_trigger()
    RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM author WHERE author_id = NEW.author_id) THEN
        UPDATE author
        SET employee_id = NEW.employee_id,
            old_info = new_info,
            new_info = NEW.new_info
        WHERE author_id = NEW.author_id;
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER author_upsert_trigger
    BEFORE INSERT ON author
    FOR EACH ROW
EXECUTE FUNCTION author_upsert_trigger();
