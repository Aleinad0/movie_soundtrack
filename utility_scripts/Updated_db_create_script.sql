-- 1. Drop all tables
DROP TABLE IF EXISTS movies_recordings;
DROP TABLE IF EXISTS artists;
DROP TABLE IF EXISTS recordings;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS raw_data;

-- 2. CREATE RAW DATA TABLE
CREATE TABLE IF NOT EXISTS raw_data(
	id SERIAL PRIMARY KEY,
	movie_title VARCHAR(1000) NOT NULL,
	year INT,
	song_title VARCHAR(1000),
	performed_by VARCHAR(500)
);

--- 3. import raw data
COPY raw_data (movie_title, year, song_title, performed_by) 
FROM 'C:\Users\DanielaBarreraPachec\Documents\Soundtrack project\movie_soundtrack\utility_scripts\data\filtered_movie_songs_no_idx.csv' 
DELIMITER ',' 
CSV HEADER;

-- 4. CREATE MOVIES TABLE

CREATE TABLE IF NOT EXISTS movies (
movie_id SERIAL PRIMARY KEY,
movie_name VARCHAR (1000),
release_year INT);

-- 5. POPULATE MOVIE TABLE WITH DISTINCT NAME AND YEAR

insert into movies (movie_name, release_year)
select distinct movie_title, year
FROM raw_data;

-- UPDATE NAME SERIES/MOVIES WITH SAME NAME (not done - optional)

-- 6. CREATE ARTIST TABLE

CREATE TABLE IF NOT EXISTS artists(
	artist_id SERIAL PRIMARY KEY,
	artist_name VARCHAR (1000)	
);

-- 7.POPULATE ARTISTS TABLE
insert into artists (artist_name)
select distinct performed_by
FROM raw_data;

-- 7.a Added Unknown Artist

insert into artists (artist_name)
values ('Unknown Artist');

-- 8.CREATE RECORDINGS TABLE 

CREATE TABLE IF NOT EXISTS recordings(
	recording_id SERIAL PRIMARY KEY,
	song_name VARCHAR (1000),
	artist_id INT	
);

-- 9. POPULATE RECORDINGS TABLE WITH DISTINCT NAME AND ARTIST
insert into recordings (song_name, artist_id)
select distinct r.song_title, a.artist_id
FROM raw_data r
JOIN artists a on coalesce(r.performed_by, 'Unknown Artist') = a.artist_name; 
--Each time performed_by is null it replaces it with Unknown Artist

--10. Bridge table movies_recordings

CREATE TABLE IF NOT EXISTS movies_recordings(
movie_id INT,
recording_id INT
);

-- 11. Populate movies_recordings

INSERT into movies_recordings 
select movie_id, recording_id
FROM raw_data r
join movies m on r.movie_title = m.movie_name and r.year = m.release_year
join recordings rec on r.song_title =rec.song_name 
join artists a on rec.artist_id = a.artist_id and a.artist_name = r.performed_by;


drop table raw_data;

-- tests

/*SELECT * FROM movies;
select * from artists;
select * from recordings;
select * from movies_recordings;*/

/*SELECT m.movie_name, r.song_name, a.artist_name
FROM movies m
JOIN movies_recordings mr ON mr.movie_id = m.movie_id
JOIN recordings r ON r.recording_id = mr.recording_id
JOIN artists a ON a.artist_id = r.artist_id
WHERE a.artist_name like '%Elton John%';*/

/*SELECT m.movie_name, r.song_name, a.artist_name
FROM movies m
JOIN movies_recordings mr ON mr.movie_id = m.movie_id
JOIN recordings r ON r.recording_id = mr.recording_id
JOIN artists a ON a.artist_id = r.artist_id
WHERE m.movie_name = 'The Lion King';*/
