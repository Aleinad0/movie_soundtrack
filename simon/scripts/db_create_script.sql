-- Drop tables
DROP TABLE IF EXISTS movies_songs;
DROP TABLE IF EXISTS songs;
DROP TABLE IF EXISTS songs_temp;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS movies_temp;
DROP TABLE IF EXISTS original_data;

-- Create table for the original data
CREATE TABLE IF NOT EXISTS original_data(
	id SERIAL PRIMARY KEY,
	movie_title VARCHAR(255) NOT NULL,
	year INT,
	song_title VARCHAR(255),
	performed_by VARCHAR(500)
);

-- Import from csv file
COPY original_data(movie_title, year, song_title, performed_by) 
FROM 'C:\projekt_2\soundtrack_proj\data\filtered_movie_songs_no_idx.csv' 
DELIMITER ',' 
CSV HEADER;

-- Create table with unique moives
SELECT DISTINCT movie_title
INTO movies_temp
FROM original_data;

-- Create a movie_id based on the movies (into a new table) 
SELECT ROW_NUMBER() OVER (ORDER BY movie_title) AS id, movie_title
INTO movies
FROM movies_temp;

-- Add PK to movies
ALTER TABLE movies ADD PRIMARY KEY (id);

-- Drop table movies_temp
DROP TABLE movies_temp;

--create the rest of the tables and populate the junction tables
-- Create table with unique songs
SELECT DISTINCT song_title
INTO songs_temp
FROM original_data;

-- Create a song_id based on the songs (into a new table) 
SELECT ROW_NUMBER() OVER (ORDER BY song_title) AS id, song_title
INTO songs
FROM songs_temp;

-- Add PK to songs
ALTER TABLE songs ADD PRIMARY KEY (id);

-- Drop table songs_temp
DROP TABLE songs_temp;

-- Create junction table movies_songs
CREATE TABLE movies_songs(
	movie_id BIGINT REFERENCES movies(id),
	song_id BIGINT REFERENCES songs(id),
	PRIMARY KEY (movie_id, song_id)
);

-- Populate junction table based on original_data
INSERT INTO movies_songs(movie_id, song_id)
SELECT m.id AS movie_id, s.id AS song_id
FROM original_data o
JOIN movies m ON o.movie_title = m.movie_title
JOIN songs s ON o.song_title = s.song_title
ON CONFLICT (movie_id, song_id) DO NOTHING;


SELECT m.movie_title, s.song_title
FROM movies m
JOIN movies_songs ms ON ms.movie_id = m.id
JOIN songs s ON s.id = ms.song_id;


-- SELECT * FROM songs;

-- SELECT * FROM movies;

-- SELECT * FROM original_data;