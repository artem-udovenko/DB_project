CREATE TABLE IF NOT EXISTS resource (
    resource_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    href VARCHAR(50) NOT NULL,
    verified BOOLEAN
);

CREATE TABLE IF NOT EXISTS employee (
   employee_id INT PRIMARY KEY,
   resource_id INT REFERENCES resource(resource_id),
   name VARCHAR(50) NOT NULL,
   occupation public.occupation
);

CREATE TABLE IF NOT EXISTS author (
    author_id INT PRIMARY KEY,
    employee_id INT REFERENCES employee(employee_id),
    old_info VARCHAR(50),
    new_info VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS registry_status (
    resource_id INT PRIMARY KEY REFERENCES resource(resource_id),
    social_media VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS topic (
    topic_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    location VARCHAR(50),
    start_date DATE,
    end_date DATE
);

CREATE TABLE IF NOT EXISTS media (
    media_id INT PRIMARY KEY,
    old_copyright VARCHAR(50),
    new_copyright VARCHAR(50),
    old_path VARCHAR(50),
    new_path VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS mediaset (
    mediaset_id INT PRIMARY KEY,
    description TEXT
);

CREATE TABLE IF NOT EXISTS correspondence (
    pair_id INT PRIMARY KEY,
    mediaset_id INT NOT NULL,
    media_id INT NOT NULL
);

CREATE TABLE IF NOT EXISTS news (
    news_id INT PRIMARY KEY,
    author_id INT REFERENCES author(author_id),
    topic_id INT REFERENCES topic(topic_id),
    mediaset_id INT,
    headline VARCHAR(50),
    content TEXT,
    publication_time TIMESTAMP
);