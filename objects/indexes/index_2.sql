-- Index Only Scan по упомянутым соцсетям
CREATE INDEX idx_registry_status_social_media
    ON registry_status (social_media);

-- Для быстрого JOIN по resource_id
CREATE INDEX idx_registry_status_resource_social
    ON registry_status (resource_id, social_media);