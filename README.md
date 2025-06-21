# Text Technology Project

This project involves the encoding of textual data found in the TEI XML Edition of the Helsinki Corpus of English Texts[1], which consists of excerpts from works spanning from circa 730 to 1710. To give a brief description of the work performed:
- the XML file of the corpus was imported,
- the corpus was thoroughly analyzed using XQuery,
- relevant resources from the corpus were selected,
- encoding of the resources was performed in XQuery,
- the outputs were exported as several CSV files, and
- the CSV files were uploaded to several relations in a PostgreSQL database.

## Project Structure

The project is structured into the following subdirectories:

- **1.Collect**:
	- HC_XML_Master_v9f.xml: The XML file of the Helsinki Corpus
- **2.Prepare**:
	- headers.xq: XQuery to output the headers (chapter headings, for eg.) found in each section, along with relevant metadata
	- sections.xq: XQuery to output metadata about excerpts for the selected texts (please note that since actual works may have been much longer, the corpus itself was designed to include one or more samples from the texts)
	- texts.xq: XQuery to output metadata about the selected texts (such as a chapter in a novel, or a scene in a drama) (please note that only handful texts were picked from each work for the creating the Helsinki corpus)
	- tokenized_words.xq: XQuery to output the tokenized words from the selected texts, along with some relevant metadata
	- works.xq: XQuery to output the source name of the selected works (such as novels, journals or travelogues), along with some relevant metadata
- **3.Access**:
	- database_pg_dump.sql: The output of the pg_dump shell command to export the created database
	- db_creation_queries.sql: All the queries necessary to create the database and import the CSV files into relations in the database
	- headers.csv: Output of the headers.xq query, saved as a .CSV file
	- sections.csv: Output of the sections.xq query, saved as a .CSV file
	- texts.csv: Output of the texts.xq query, saved as a .CSV file
	- tokenized_words.csv: Output of the tokenized_words.xq query, saved as a .CSV file
	- works.csv: Output of the works.xq query, saved as a .CSV file
- **Documentation**:
	- **Post-Submission**:
		- corpus_sample_structure.xml: An XML file that shows a rough structure of how the Corpus looks like
		- Final Schema.jpg: A view of the final PostgreSQL Database schema created for the Access phase of the project
		- **Prepare_Stage_Analysis.pdf**: Documentation of analysis and observations during the Prepare phase of the Project
	- **Pre-Submission**:
		- Left-Brained Written Word_PreFinal_Documentation.pdf: Previously submitted Documentation during the Pre-final version submission
		- Left-BrainedWrittenWord_Presentation.pdf: Previously submitted and presented Presentation Deck, discussing the details of the project
		- Potential Schema.jpg: A view of how the PostgreSQL database schema was ideated
		- Text_Technology_Project_Topic_Sushma_Rishi: Previously submitted Project Topic proposal

## Database Schema

The database consists of several tables to store information about works, texts, sections, headers, and tokenized words.

### Tables

1. **Works**
   - `id`: Primary key (auto-increment)
   - `work_id`: Unique identifier for each work
   - `era_code`: Era classification
   - `title`: Title of the work
   - `author`: Author of the work
   - `measure_quantity`: Quantity measure of the work
   - `measure_unit`: Unit of measurement
   - `creation_dates`: Dates of creation
   - `text_type`: Type of text

2. **Texts**
   - `id`: Primary key (auto-increment)
   - `text_id`: Unique identifier for each text
   - `title`: Title of the text
   - `work_id`: Foreign key referencing `works(work_id)`
   - `reference`: Reference identifier

3. **Sections**
   - `id`: Primary key (auto-increment)
   - `reference`: Foreign key referencing `texts(reference)`
   - `section_id`: Unique identifier for each section
   - `section_type`: Type of the section

4. **Headers**
   - `id`: Primary key (auto-increment)
   - `reference`: Foreign key referencing `sections(reference)`
   - `section_id`: Foreign key referencing `sections(section_id)`
   - `header`: Header text
   - `header_index`: Index of the header

5. **Tokenized Words**
   - `id`: Primary key (auto-increment)
   - `reference`: Foreign key referencing `sections(reference)`
   - `section_id`: Foreign key referencing `sections(section_id)`
   - `page_index`: Page index
   - `header_index`: Index of the nearest header (can join with headers(header_index to find the header text))
   - `paragraph_index`: Index of the paragraph
   - `speaker`: Speaker of the text (if applicable)
   - `line_index`: Line index
   - `word_index`: Index of the word in the line
   - `word`: The word text

## Prerequisites

- **XQuery**: To test the XQuery codes, or to run your own queries on the XML Corpus, please ensure an XQuery processor like BaseX or Saxon is installed on your machine. This project was developed and tested with the JAR version of BaseX 11.0 GUI.
- **PostgreSQL**: Please ensure PostgreSQL is installed on your machine. This project was developed and tested with PostgreSQL 16.
- **Database Setup**: Please ensure having requisite permissions to create databases and tables on your PostgreSQL instance.
- **Project Path**: Please note the path to this Project's root directory, i.e., the path the project folder is stored in on your machine. This will be helpful to you in case you may be interested in setting up the database, as all the shell commands have been written assuming that the Project's root is the current working directory.
- **PostgreSQL Username**: 

## Setup Instructions

### Creating and Restoring the Database using the Database Dump (Easy Method)

1. **Navigate to the Project's root directory**:
   ```bash
   cd /path/to/LeftBrainedWrittenWord```

2. **Create the Database and Restore Relations**:
   Execute the following command to create a new database named `lbww` and restore the Project's relations inside `lbww`:
   ```bash
   psql -U your_username --command="create database lbww" && pg_restore -U your_username -d lbww -v /path/to/LeftBrainedWrittenWord/3.Access/database_pg_dump.sql```

### Creating the Database from scratch using the Queries (Manual Method)

1. **Navigate to the Project's root directory**:
   ```bash
   cd /path/to/LeftBrainedWrittenWord```
   
2. **Connect to a PostgreSQL server**:
   ```bash
   psql -U your_username -d postgres```

3. **Create the Database, the Tables, and import their data by running the Queries**:
   Copy the queries from the 3.Access/db_creation_queries.sql and run them in the command line
   **Please make sure to mention the path to the Project's root directory in the COPY FROM queries to ensure that the PostgreSQL engine knows where to reference the .CSV files**

## References

[1]	Helsinki Corpus TEI XML Edition. 2011. First edition. Designed by Alpo Honkapohja, Samuli Kaislaniemi, Henri Kauhanen, Matti Kilpiö, Ville Marttila, Terttu Nevalainen, Arja Nurmi, Matti Rissanen and Jukka Tyrkkö. Implemented by Henri Kauhanen and Ville Marttila. Based on The Helsinki Corpus of English Texts (1991). Helsinki: The Research Unit for Variation, Contacts and Change in English (VARIENG), University of Helsinki.
