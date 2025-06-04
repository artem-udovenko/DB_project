CREATE OR REPLACE FUNCTION media_upsert_trigger()
    RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM media WHERE media_id = NEW.media_id) THEN
        UPDATE media
        SET old_copyright = new_copyright,
            new_copyright = NEW.new_copyright,
            old_path = new_path,
            new_path = NEW.new_path
        WHERE media_id = NEW.media_id;
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER media_upsert_trigger
    BEFORE INSERT ON media
    FOR EACH ROW
EXECUTE FUNCTION media_upsert_trigger();

