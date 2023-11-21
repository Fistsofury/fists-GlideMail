CREATE TABLE mailboxes (
    char_identifier VARCHAR(255),
    mailbox_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(255),
    last_name VARCHAR(255)
);

CREATE TABLE mailbox_messages (
    from_char VARCHAR(255),
    to_char VARCHAR(255),
    message TEXT,
    subject VARCHAR(255),
    location VARCHAR(255),
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);
