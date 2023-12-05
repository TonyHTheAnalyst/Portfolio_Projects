--data source: Spotify songs
--date: 22/10/2023
--purpose:Get the data in the question as requested
--author: Huang Jixiang

-- Music Popularity Analysis:
-- Which songs are the most popular?
select DISTINCT track_name, track_popularity
FROM ProtfolioProject..spotify_songs
WHERE track_name is not null
order by track_popularity desc

-- Which artist belongs to the most popular song?
SELECT track_name, track_artist, track_popularity
FROM ProtfolioProject..spotify_songs
WHERE track_popularity = 
(select max(track_popularity)
from ProtfolioProject..spotify_songs
where track_name is not null
)

-- Which albums contain the most popular songs?
SELECT track_album_name,track_name, track_artist, track_popularity
FROM ProtfolioProject..spotify_songs
WHERE track_popularity = 
(select max(track_popularity)
from ProtfolioProject..spotify_songs
where track_name is not null)

-- Music genre and popularity£º
-- Which genre of music performed best in terms of popularity
select playlist_genre,ROUND(avg(track_popularity),2) as avg_popularity
FROM ProtfolioProject..spotify_songs
WHERE track_name is not null
group by playlist_genre
order by avg_popularity desc

-- Which songs are most popular in a particular subgenre?
select ROUND(avg(track_popularity),2) as avg_popularity, playlist_subgenre
FROM ProtfolioProject..spotify_songs
WHERE track_name is not null
group by playlist_subgenre
order by avg_popularity desc

--Playlist Analysis:
--Which playlists contain the most popular songs?
SELECT playlist_name,track_name, track_artist, track_popularity
FROM ProtfolioProject..spotify_songs
WHERE track_popularity = 
(select max(track_popularity)
from ProtfolioProject..spotify_songs
where track_name is not null)

SELECT top 5 playlist_name,track_name, track_artist, track_popularity
FROM ProtfolioProject..spotify_songs
WHERE track_name is not null
order by track_popularity desc

-- Which playlists belong to a specific genre or subgenre?
SELECT DISTINCT playlist_name, playlist_genre, playlist_subgenre
FROM ProtfolioProject..spotify_songs
WHERE track_name is not null
order by playlist_genre ,playlist_subgenre

--Artist Analysis:
--Which artist has the highest average popularity of songs?
SELECT TOP 1 track_artist, ROUND(avg(track_popularity), 2)as avg_popularity
FROM ProtfolioProject..spotify_songs
WHERE track_name is not null
group by track_artist
order by avg_popularity desc

-- Average popularity ranking of songs by artists with the same number of albums?
SELECT 
  track_artist, 
  COUNT(DISTINCT track_album_id) as album_count,
  ROUND(AVG(track_popularity), 2) as avg_popularity
FROM ProtfolioProject..spotify_songs
WHERE track_name IS NOT NULL
GROUP BY track_artist
HAVING COUNT(DISTINCT track_album_id) = (
    SELECT COUNT(DISTINCT track_album_id)
    FROM ProtfolioProject..spotify_songs
    WHERE track_name IS NOT NULL
	GROUP BY track_artist
    HAVING COUNT(DISTINCT track_album_id) > 1
)
ORDER BY avg_popularity DESC;

SELECT 
  track_artist, 
  COUNT(DISTINCT track_album_id) as album_count,
  AVG(track_popularity) as avg_popularity,
  DENSE_RANK() OVER (PARTITION BY COUNT(DISTINCT track_album_id) ORDER BY AVG(track_popularity) DESC) as popularity_rank
FROM ProtfolioProject..spotify_songs
WHERE track_name IS NOT NULL
GROUP BY track_artist
HAVING COUNT(DISTINCT track_album_id) > 1
ORDER BY album_count, avg_popularity DESC;

--Which artist has the highest danceability in their music?
SELECT TOP 1 track_artist, danceability
FROM ProtfolioProject..spotify_songs
WHERE track_name is not null
order by danceability desc

--The most popular songs from each album
SELECT track_album_name, track_name,max(track_popularity) as Top1_inthe_album
FROM ProtfolioProject..spotify_songs
WHERE track_name is not null
group by track_album_name,track_name
