--Netflix Project--

--Creating Table
CREATE TABLE netflix(
show_id VARCHAR(50),
type VARCHAR(100),
title VARCHAR(500),
director VARCHAR(1000),
cast VARCHAR(1050),
country VARCHAR(500),
date_added DATE,
release_date INT,
rating VARCHAR(250),
duration VARCHAR(250),
listed_in VARCHAR(500),
description VARCHAR(1500)
);

SELECT * FROM netflix;


-- 15 Business Problems & Solutions

--1. Count the number of Movies vs TV Shows
SELECT type, COUNT(*) AS counts
FROM netflix
GROUP BY 1;

--2. Find the most common rating for movies and TV shows
	WITH ratingcounts AS (
 SELECT type, rating, COUNT(*) AS rating_count
 FROM netflix
 GROUP BY 1,2
),
ranked_rating AS (
SELECT type , rating ,rating_count,
RANK() OVER (PARTITION BY type  ORDER BY rating_count DESC) AS ranking
FROM ratingcounts
)
SELECT type , rating
FROM ranked_rating
WHERE ranking = 1;

-- 3. List all movies released in a specific year (e.g., 2020)
SELECT * 
FROM netflix
WHERE release_year = 2020;
      
-- 4. Find the top 5 countries with the most content on Netflix
WITH cte AS (
SELECT UNNEST(STRING_TO_ARRAY(country,',')) AS country,
COUNT(*) AS total_count
FROM netflix
GROUP BY 1
)
SELECT * 
FROM cte
WHERE country IS NOT NULL	
ORDER BY total_count DESC
LIMIT 5;

-- 5. Identify the longest movie
SELECT 
    title , duration
FROM netflix
WHERE type = 'Movie' and duration is not null
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC; 
--SPLIT_PART is a PostgreSQL function that splits a string into an array of substrings based on a delimiter.

-- 6. Find content added in the last 5 years
SELECT *
FROM netflix
WHERE TO_DATE(date_added,'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'
WITH CTE AS (
SELECT type ,title,UNNEST (STRING_TO_ARRAY (director,',')) AS director
FROM netflix n)
SELECT type ,title,director
FROM cte 
WHERE director = 'Rajiv Chilaka';


-- 8. List all TV shows with more than 5 seasons
SELECT type , title,duration
FROM netflix
WHERE type = 'TV Show' AND SPLIT_PART(duration , ' ', 1)::INT > 5;

-- 9. Count the number of content items in each genre
SELECT UNNEST(STRING_TO_ARRAY(listed_in,',') )AS genre,
COUNT(*) AS content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC;

-- 10.Find each year and the average numbers of content release in India on netflix
    -- return top 5 year with highest avg content release!
SELECT country,release_year ,COUNT(*) AS total_realease,
	ROUND(COUNT(show_id)::numeric / (SELECT COUNT(show_id) FROM netflix WHERE country = 'India') ::numeric *100 ,2 )AS avg
FROM netflix
WHERE country='India'
GROUP BY 1,2
ORDER BY 4 DESC
LIMIT 5

-- 11. List all movies that are documentaries
SELECT title, listed_in
FROM netflix
WHERE listed_in LIKE '%Documentaries';

-- 12. Find all content without a director
SELECT title, director
FROM netflix
WHERE director IS NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
  
-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT UNNEST (STRING_TO_ARRAY(casts,',')) AS actors ,COUNT(*)
FROM netflix
WHERE country='India'
GROUP BY actors
ORDER BY 2 DESC
LIMIT 10;

-- 15.
-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.
 
SELECT category , COUNT(*) AS content_count
FROM ( SELECT 
	       CASE 
	         WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'  --ILIKE - case-insensitive of LIKE
           ELSE 'Good'
	       END AS category
	  FROM netflix 
) AS categorized_content
GROUP BY category;


