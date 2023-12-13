-- Drop tables
DROP TABLE IF EXISTS artists;
DROP TABLE IF EXISTS movies_recordings;
DROP TABLE IF EXISTS recordings;
DROP TABLE IF EXISTS recordings_temp;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS movies_temp;
DROP TABLE IF EXISTS original_data;

-- Create table for the original data
CREATE TABLE IF NOT EXISTS original_data(
	id SERIAL PRIMARY KEY,
	movie_name VARCHAR(255) NOT NULL,
	year INT,
	song_name VARCHAR(255),
	performed_by VARCHAR(500)
);

-- Import from csv file
COPY original_data(movie_name, year, song_name, performed_by) 
FROM 'C:\projekt_2\soundtrack_proj\movie_soundtrack\simon\data\filtered_movie_songs_no_idx.csv' 
DELIMITER ',' 
CSV HEADER;

-- Create table with unique moives
SELECT DISTINCT movie_name
INTO movies_temp
FROM original_data;

-- Create a movie_id based on the movies (into a new table) 
SELECT ROW_NUMBER() OVER (ORDER BY movie_name) AS movie_id, movie_name
INTO movies
FROM movies_temp;

-- Add PK and release_year column to movies
ALTER TABLE movies 
ADD COLUMN release_year INT,
ADD PRIMARY KEY (movie_id);

-- Insert corresponding year to movies
UPDATE movies
SET release_year = original_data.year
FROM original_data
WHERE movies.movie_name = original_data.movie_name;

-- Drop table movies_temp
DROP TABLE movies_temp;


-- Create table with unique recordings
SELECT DISTINCT song_name, performed_by AS artist_name
INTO recordings_temp
FROM original_data;

SELECT * FROM recordings_temp;


-- KLAR HIT
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