-- Drop tables
DROP TABLE IF EXISTS artists;
DROP TABLE IF EXISTS movies_recordings;
DROP TABLE IF EXISTS recordings;
DROP TABLE IF EXISTS recordings_temp;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS movies_temp;
DROP TABLE IF EXISTS original_data;


-- STEP 1
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


-- STEP 2
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


-- STEP 3
-- Create table with unique recordings
SELECT DISTINCT song_name, performed_by AS artist_name
INTO recordings_temp
FROM original_data;

-- Create a recording_id based on the recordings (into a new table) 
SELECT ROW_NUMBER() OVER (ORDER BY song_name, artist_name) AS recording_id, song_name, artist_name
INTO recordings
FROM recordings_temp;

-- Add PK to songs
ALTER TABLE recordings 
ADD PRIMARY KEY (recording_id);

-- Drop table songs_temp
DROP TABLE recordings_temp;


-- STEP 4
-- Create junction table movies_recordings
CREATE TABLE movies_recordings(
	movie_id BIGINT REFERENCES movies(movie_id),
	recording_id BIGINT REFERENCES recordings(recording_id),
	PRIMARY KEY (movie_id, recording_id)
);

-- Populate junction table based on original_data
INSERT INTO movies_recordings(movie_id, recording_id)
SELECT m.movie_id, r.recording_id
FROM original_data o
JOIN movies m ON o.movie_name = m.movie_name
JOIN recordings r ON o.song_name = r.song_name 
AND (o.performed_by = r.artist_name 
OR (o.performed_by IS NULL AND r.artist_name IS NULL))
ON CONFLICT (movie_id, recording_id) DO NOTHING;

-- Test SELECT statement
/*SELECT m.movie_name, r.song_name
FROM movies m
JOIN movies_recordings mr ON mr.movie_id = m.movie_id
JOIN recordings r ON r.recording_id = mr.recording_id
WHERE m.movie_name = 'The Lion King';*/

/*SELECT m.movie_id, r.recording_id, m.movie_name, r.artist_name, r.song_name 
FROM original_data o
JOIN movies m ON o.movie_name = m.movie_name
JOIN recordings r ON o.song_name = r.song_name 
AND (o.performed_by = r.artist_name 
OR (o.performed_by IS NULL AND r.artist_name IS NULL))
ORDER BY r.song_name;*/



