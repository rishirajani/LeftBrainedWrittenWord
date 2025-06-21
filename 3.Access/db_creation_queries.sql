-- Create the database
CREATE DATABASE lbbw;

-- Connect to the newly created database
\c lbbw;

-- Create the 'works' table

CREATE TABLE works (
    id SERIAL PRIMARY KEY,
    work_id VARCHAR(255) UNIQUE NOT NULL,
    era_code VARCHAR(255),
    title VARCHAR(255),
    author VARCHAR(255),
    measure_quantity VARCHAR(255),
    measure_unit VARCHAR(255),
    creation_dates VARCHAR(255),
    text_type VARCHAR(255)
);

-- Create the 'texts' table
CREATE TABLE texts (
    id SERIAL PRIMARY KEY,
    text_id VARCHAR(255) UNIQUE NOT NULL,
    title VARCHAR(255),
    work_id VARCHAR(255) NOT NULL,
    reference VARCHAR(255) UNIQUE,
    FOREIGN KEY (work_id) REFERENCES works(work_id)
);

-- Create the 'sections' table with unique constraint on (reference, section_id)
CREATE TABLE sections (
    id SERIAL PRIMARY KEY,
    reference VARCHAR(255) NOT NULL,
    section_id VARCHAR(255) NOT NULL,
    section_type VARCHAR(255),
    FOREIGN KEY (reference) REFERENCES texts(reference),
    UNIQUE (reference, section_id)
);

-- Create the 'headers' table with unique constraint on (reference, section_id, header_index)
CREATE TABLE headers (
    id SERIAL PRIMARY KEY,
    reference VARCHAR(255) NOT NULL,
    section_id VARCHAR(255) NOT NULL,
    header VARCHAR(255),
    header_index VARCHAR(255),
    FOREIGN KEY (reference, section_id) REFERENCES sections(reference, section_id)
);

-- Create the 'tokenized_words' table
CREATE TABLE tokenized_words (
    id SERIAL PRIMARY KEY,
    reference VARCHAR(255) NOT NULL,
    section_id VARCHAR(255) NOT NULL,
    page_index VARCHAR(255),
    header_index VARCHAR(255),
    paragraph_index VARCHAR(255),
    speaker VARCHAR(255),
    line_index VARCHAR(255),
    word_index VARCHAR(255),
    word VARCHAR(255),
    FOREIGN KEY (reference, section_id) REFERENCES sections(reference, section_id)
    -- Did not add a Foreign Key constraint to headers(header_index) as the header_index may not be necessarily unique 
);

-- Please paste the corret path to the project

-- Copy data from CSV to 'works' table
COPY works(work_id, era_code, title, author, measure_quantity, measure_unit, creation_dates, text_type)
FROM '/path/to/LeftBrainedWrittenWord/3.Access/works.csv'
DELIMITER ',' CSV HEADER;

-- Copy data from CSV to 'texts' table
COPY texts(text_id, title, work_id, reference)
FROM '/path/to/LeftBrainedWrittenWord/3.Access/texts.csv'
DELIMITER ',' CSV HEADER;

-- Copy data from CSV to 'sections' table
COPY sections(reference, section_id, section_type)
FROM '/path/to/LeftBrainedWrittenWord/3.Access/sections.csv'
DELIMITER ',' CSV HEADER;

-- Copy data from CSV to 'headers' table
COPY headers(reference, section_id, header, header_index)
FROM '/path/to/LeftBrainedWrittenWord/3.Access/headers.csv'
DELIMITER ',' CSV HEADER;

-- Copy data from CSV to 'tokenized_words' table
COPY tokenized_words(reference, section_id, page_index, header_index, paragraph_index, speaker, line_index, word_index, word)
FROM '/path/to/LeftBrainedWrittenWord/3.Access/tokenized_words.csv'
DELIMITER ',' CSV HEADER;