
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);

select *
from netflix

#1. **Count the number of Movies vs TV Shows:**

select type, count(type)
from netflix
group by type

#2. **Find the most common rating for movies and TV shows:**

with cte as
(
select type, rating, count(*) as cnt
from netflix
group by type,rating
order by type, cnt desc
), cte_2 as
(
select *, rank() over(partition by type order by cnt desc) as rn
from cte
)
select type,rating
from cte_2
where rn = 1

#3. **List all movies released in a specific year (e.g., 2020):**

select title,release_year
from netflix
where release_year = '2020'

#4. **Find the top 5 countries with the most content on Netflix:**

SELECT * 
FROM
(SELECT 
		UNNEST(STRING_TO_ARRAY(country, ',')) as country,
		COUNT(*) as total_content
	FROM netflix
	GROUP BY 1
)as t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5

#5. **Identify the longest movie:**

select *
from netflix
where type = 'Movie'
order by split_part(duration,' ',1)::int desc

#6. Find content added in the last 5 years

SELECT
*
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'

#7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select *
from netflix
where director = 'Rajiv Chilaka'

#8. List all TV shows with more than 5 seasons

select *
from netflix
where type = 'TV Show' and split_part(duration,' ',1)::int > 5

#9. Count the number of content items in each genre

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(*) as total_content
FROM netflix
GROUP BY 1

#10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

SELECT country,release_year,
COUNT(show_id) as total_release,ROUND(COUNT(show_id)::numeric/(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100 ,2)
as avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5

#11. List all movies that are documentaries

select title
from netflix
where type = 'Movie' and listed_in = 'Documentaries'

#12. Find all content without a director

select *
from netflix
where director is null

#13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * FROM netflix
WHERE 
	casts LIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

#14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select unnest(string_to_array(casts,',')) as actors, count(*) as cnt
from netflix
where country = 'India'
group by actors
order by cnt desc
limit 10

#15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.

SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2