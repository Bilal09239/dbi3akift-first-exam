PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;

CREATE TABLE accounts (
    id                  INTEGER PRIMARY KEY,
    name                TEXT NOT NULL,
    smtp_user           TEXT NOT NULL,
    smtp_host           TEXT NOT NULL,
    smtp_port           INTEGER NOT NULL DEFAULT 587,
    smtp_keyring_ref    TEXT NOT NULL,
    imap_user           TEXT NOT NULL,
    imap_host           TEXT NOT NULL,
    imap_port           INTEGER NOT NULL DEFAULT 993,
    imap_keyring_ref    TEXT NOT NULL,
    created_at          TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE mailboxes (
    id              INTEGER PRIMARY KEY,
    account_id      INTEGER NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    name            TEXT NOT NULL,
    uidvalidity     INTEGER,
    UNIQUE (account_id, name)
);

-- An IMAP UID is unique only within its mailbox and UIDVALIDITY generation.
-- One local message can therefore have several mailbox/UID links.
CREATE TABLE sync (
    mailbox_id      INTEGER NOT NULL REFERENCES mailboxes(id) ON DELETE CASCADE,
    uid             INTEGER NOT NULL,
    message_id      INTEGER NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
    PRIMARY KEY (mailbox_id, uid)
);

CREATE TABLE messages (
    id              INTEGER PRIMARY KEY,
    account_id      INTEGER NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    rfc_identifier  TEXT,
    sender          INTEGER REFERENCES contacts(id),
    sender_address_id INTEGER REFERENCES addresses(id) ON DELETE SET NULL,
    sent_at         TEXT,
    subject         TEXT,
    body            TEXT,
    read            INTEGER NOT NULL DEFAULT 0,
    flagged         INTEGER NOT NULL DEFAULT 0,
    deleted         INTEGER NOT NULL DEFAULT 0,
    created_at      TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT NOT NULL DEFAULT (datetime('now')),
    UNIQUE (account_id, rfc_identifier)
);

CREATE TABLE attachments (
    id              INTEGER PRIMARY KEY,
    message_id      INTEGER NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
    filename        TEXT,
    mimetype        TEXT,
    size            INTEGER,
    path            TEXT NOT NULL
);

CREATE TABLE log (
    id              INTEGER PRIMARY KEY,
    account_id      INTEGER NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    occurred_at     TEXT NOT NULL DEFAULT (datetime('now')),
    error           TEXT
);

CREATE TABLE contacts (
    id              INTEGER PRIMARY KEY,
    name            TEXT,
    first_name      TEXT NOT NULL DEFAULT '',
    last_name       TEXT NOT NULL DEFAULT '',
    created_at      TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE addresses (
    id              INTEGER PRIMARY KEY,
    email           TEXT NOT NULL UNIQUE,
    contact_id      INTEGER NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    display_name    TEXT
);

CREATE TABLE address_tags (
    address_id  INTEGER NOT NULL REFERENCES addresses(id) ON DELETE CASCADE,
    tag_id      INTEGER NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (address_id, tag_id)
);

-- Wildcard email patterns collect concrete sender addresses under any contact.
-- Each matching sender address is still retained as an independent record.
CREATE TABLE contact_patterns (
    id              INTEGER PRIMARY KEY,
    contact_id      INTEGER NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    address_pattern TEXT NOT NULL UNIQUE,
    created_at      TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE conversations (
    id                      INTEGER PRIMARY KEY,
    account_id              INTEGER NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    contact_id              INTEGER NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    status                  TEXT CHECK (status IN ('done', 'irrelevant')),
    last_message_at         TEXT,
    last_message_direction  TEXT CHECK (last_message_direction IN ('incoming', 'outgoing')),
    updated_at              TEXT NOT NULL DEFAULT (datetime('now')),
    UNIQUE (account_id, contact_id)
);

CREATE TABLE messages_conversations (
    message_id      INTEGER NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
    conversation_id INTEGER NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    PRIMARY KEY (message_id, conversation_id)
);

CREATE TABLE tags (
    id      INTEGER PRIMARY KEY,
    name    TEXT NOT NULL UNIQUE
);

CREATE TABLE tag_relation_types (
    id              INTEGER PRIMARY KEY,
    name            TEXT NOT NULL UNIQUE,
    inverse_type_id INTEGER REFERENCES tag_relation_types(id)
);

CREATE TABLE tag_relations (
    id                  INTEGER PRIMARY KEY,
    tag_id              INTEGER NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    related_tag_id      INTEGER NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    relation_type_id    INTEGER NOT NULL REFERENCES tag_relation_types(id) ON DELETE CASCADE,
    UNIQUE (tag_id, related_tag_id, relation_type_id),
    CHECK (tag_id != related_tag_id)
);

CREATE TABLE message_tags (
    message_id  INTEGER NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
    tag_id      INTEGER NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (message_id, tag_id)
);

CREATE TABLE contact_tags (
    contact_id  INTEGER NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    tag_id      INTEGER NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (contact_id, tag_id)
);