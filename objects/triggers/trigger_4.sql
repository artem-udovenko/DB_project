CREATE OR REPLACE FUNCTION registry_status_after_insert_trigger()
    RETURNS TRIGGER AS $$
BEGIN
    UPDATE resource
    SET verified = TRUE
    WHERE resource_id = NEW.resource_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER registry_status_after_insert
    AFTER INSERT ON registry_status
    FOR EACH ROW
EXECUTE FUNCTION registry_status_after_insert_trigger();

CREATE OR REPLACE FUNCTION registry_status_after_delete_trigger()
    RETURNS TRIGGER AS $$
BEGIN
    UPDATE resource
    SET verified = FALSE
    WHERE resource_id = OLD.resource_id;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER registry_status_after_delete
    AFTER DELETE ON registry_status
    FOR EACH ROW
EXECUTE FUNCTION registry_status_after_delete_trigger();
