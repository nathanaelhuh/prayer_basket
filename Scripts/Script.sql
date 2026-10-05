
CREATE TABLE IF NOT EXISTS prayer_instances (
    id TEXT PRIMARY KEY,
    request_id TEXT,
    guided_theme_id TEXT,
    notes TEXT,
    duration_seconds INTEGER DEFAULT 0,
    is_confidential INTEGER NOT NULL DEFAULT 0,
    created_at INTEGER NOT NULL,
    FOREIGN KEY (request_id) REFERENCES prayer_requests (id) ON DELETE SET NULL
);
