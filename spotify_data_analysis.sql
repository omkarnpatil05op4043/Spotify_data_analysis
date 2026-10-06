-- SPOTIFY DATA ANALYSIS --

CREATE DATABASE spotify_db;

-- create table

CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);


-- EDA --

SELECT COUNT(*) FROM cleaned_dataset;

SELECT COUNT(DISTINCT artist) FROM cleaned_dataset;

SELECT DISTINCT album_type FROM cleaned_dataset;

SELECT duration_min FROM cleaned_dataset;

SELECT MAX(duration_min) FROM cleaned_dataset;

SELECT MIN(duration_min) FROM cleaned_dataset;

SELECT * FROM cleaned_dataset
WHERE duration_min = 0;

SELECT DISTINCT channel FROM cleaned_dataset;

SELECT DISTINCT most_playedon FROM cleaned_dataset;


-- data analysis --

-- Q.1 Retrieve the names of all tracks that have more than 1 billion streams.

SELECT * FROM cleaned_dataset
WHERE stream > 1000000000;

-- Q.2 List all albums along with their respective artists.

SELECT
    album, artist
FROM cleaned_dataset
ORDER BY 1;

-- Q.3 Get the total number of comments for tracks where licensed = TRUE.

SELECT SUM(comments) AS total_comments
FROM cleaned_dataset
WHERE licensed = 'true';

-- Q.4 Find all tracks that belong to the album type single.

SELECT * FROM cleaned_dataset
WHERE album_type = 'single';

-- Q.5 Count the total number of tracks by each artist.

SELECT
    artist,
    COUNT(*) AS total_no_songs
FROM cleaned_dataset
GROUP BY artist;


-- Q.6 Calculate the average danceability of tracks in each album.
SELECT
    album,
    AVG(danceability) AS avg_danceability
FROM cleaned_dataset
GROUP BY album
ORDER BY avg_danceability DESC;

-- Q.7 Find the top 5 tracks with the highest energy values.
SELECT
    track,
    MAX(energy) AS highest_energy
FROM cleaned_dataset
GROUP BY track
ORDER BY highest_energy DESC
LIMIT 5;

-- Q.8 List all tracks along with their views and likes where official_video = TRUE.
SELECT
    track,
    views,
    likes
FROM cleaned_dataset
WHERE official_video = 1;

-- Q.9 For each album, calculate the total views of all associated tracks.
SELECT
    album,
    SUM(views) AS total_views
FROM cleaned_dataset
GROUP BY album
ORDER BY total_views DESC;


-- Q.10 Retrieve the track names that have been streamed on Spotify more than YouTube.
SHOW COLUMNS FROM cleaned_dataset;
SELECT DISTINCT most_playedon FROM cleaned_dataset;


SELECT DISTINCT official_video FROM cleaned_dataset;

SELECT most_playedon, COUNT(*) 
FROM cleaned_dataset
GROUP BY most_playedon;

SELECT track, COUNT(*) AS cnt
FROM cleaned_dataset
GROUP BY track
HAVING COUNT(*) > 1
LIMIT 20;


-- Q.10 Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT *
FROM (
    SELECT
        track,
        COALESCE(SUM(CASE WHEN most_playedon = 'Youtube' THEN stream END), 0) AS streamed_on_youtube,
        COALESCE(SUM(CASE WHEN most_playedon = 'Spotify' THEN stream END), 0) AS streamed_on_spotify
    FROM cleaned_dataset
    GROUP BY track
) AS t1
WHERE streamed_on_spotify > streamed_on_youtube;


-- Q.11 Find the top 3 most-viewed tracks for each artist using window functions.
WITH ranking_artist AS (
    SELECT
        artist,
        track,
        SUM(views) AS total_view,
        DENSE_RANK() OVER (PARTITION BY artist ORDER BY SUM(views) DESC) AS rank_no
    FROM cleaned_dataset
    GROUP BY artist, track
)
SELECT *
FROM ranking_artist
WHERE rank_no <= 3;

-- Q.12 Write a query to find tracks where the liveness score is above the average.
SELECT
    track,
    artist,
    liveness
FROM cleaned_dataset
WHERE liveness > (SELECT AVG(liveness) FROM cleaned_dataset);

-- Q.13 Use a WITH clause to calculate the difference between the highest and lowest
--      energy values for tracks in each album.
WITH energy_range AS (
    SELECT
        album,
        MAX(energy) AS highest_energy,
        MIN(energy) AS lowest_energy
    FROM cleaned_dataset
    GROUP BY album
)
SELECT
    album,
    highest_energy,
    lowest_energy,
    highest_energy - lowest_energy AS energy_diff
FROM energy_range
ORDER BY energy_diff DESC;

-- Q.14 Find tracks where the energy-to-liveness ratio is greater than 1.2.
SELECT
    track,
    artist,
    energy,
    liveness,
    energy / liveness AS energy_liveness_ratio
FROM cleaned_dataset
WHERE liveness > 0
  AND energy / liveness > 1.2;

-- Q.15 Calculate the cumulative sum of likes for tracks ordered by the number of views,
--      using window functions.
SELECT
    track,
    views,
    likes,
    SUM(likes) OVER (ORDER BY views) AS cumulative_likes
FROM cleaned_dataset
ORDER BY views;


-- END OF PROJECT --