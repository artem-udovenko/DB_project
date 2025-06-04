-- Составной индекс для частых запросов по связке mediaset_id + media_id
CREATE INDEX idx_correspondence_mediaset_media
    ON correspondence (mediaset_id, media_id);

-- Отдельный индекс для медиа, если нужен поиск по media_id без mediaset_id
CREATE INDEX idx_correspondence_media
    ON correspondence (media_id);