-- Q1
SELECT 'movie' AS table_name, COUNT(*) FROM movie
UNION ALL
SELECT 'genre', COUNT(*) FROM genre
UNION ALL
SELECT 'director_mapping', COUNT(*) FROM director_mapping
UNION ALL
SELECT 'role_mapping', COUNT(*) FROM role_mapping
UNION ALL
SELECT 'names', COUNT(*) FROM names
UNION ALL
SELECT 'ratings', COUNT(*) FROM ratings;

-- Q2
SELECT 
SUM(title IS NULL) AS title_nulls,
SUM(year IS NULL) AS year_nulls,
SUM(date_published IS NULL) AS date_nulls,
SUM(duration IS NULL) AS duration_nulls,
SUM(country IS NULL) AS country_nulls,
SUM(worlwide_gross_income IS NULL) AS income_nulls,
SUM(languages IS NULL) AS languages_nulls,
SUM(production_company IS NULL) AS production_company_nulls
FROM movie;

-- Q3
SELECT year, COUNT(*) FROM movie GROUP BY year ORDER BY year;

SELECT MONTH(date_published) AS month_num, COUNT(*) 
FROM movie GROUP BY month_num ORDER BY month_num;

-- Q4
SELECT COUNT(*) 
FROM movie
WHERE year = 2019 AND (country LIKE '%USA%' OR country LIKE '%India%');

-- Q5
SELECT DISTINCT genre FROM genre;

-- Q6
SELECT genre, COUNT(*) AS movie_count
FROM genre
GROUP BY genre
ORDER BY movie_count DESC
LIMIT 1;

-- Q7
SELECT COUNT(*) FROM (
SELECT movie_id FROM genre GROUP BY movie_id HAVING COUNT(*) = 1
) t;

-- Q8
SELECT g.genre, AVG(m.duration) AS avg_duration
FROM genre g
JOIN movie m ON g.movie_id = m.id
GROUP BY g.genre;

-- Q9
SELECT genre, movie_count,
RANK() OVER (ORDER BY movie_count DESC) AS genre_rank
FROM (
SELECT genre, COUNT(*) AS movie_count
FROM genre GROUP BY genre
) t
WHERE genre = 'Thriller';

-- Q10
SELECT 
MIN(avg_rating), MAX(avg_rating),
MIN(total_votes), MAX(total_votes),
MIN(median_rating), MAX(median_rating)
FROM ratings;

-- Q11
SELECT title, avg_rating,
RANK() OVER (ORDER BY avg_rating DESC) AS movie_rank
FROM movie m
JOIN ratings r ON m.id = r.movie_id
LIMIT 10;

-- Q12
SELECT median_rating, COUNT(*) AS movie_count
FROM ratings
GROUP BY median_rating
ORDER BY median_rating;

-- Q13
SELECT production_company, COUNT(*) AS movie_count,
RANK() OVER (ORDER BY COUNT(*) DESC) AS prod_rank
FROM movie m
JOIN ratings r ON m.id = r.movie_id
WHERE avg_rating > 8
GROUP BY production_company;

-- Q14
SELECT g.genre, COUNT(*) AS movie_count
FROM movie m
JOIN genre g ON m.id = g.movie_id
JOIN ratings r ON m.id = r.movie_id
WHERE YEAR(date_published)=2017 
AND MONTH(date_published)=3
AND country LIKE '%USA%'
AND total_votes > 1000
GROUP BY g.genre;

-- Q15
SELECT m.title, r.avg_rating, g.genre
FROM movie m
JOIN ratings r ON m.id = r.movie_id
JOIN genre g ON m.id = g.movie_id
WHERE m.title LIKE 'The%' AND avg_rating > 8;

-- Q16
SELECT COUNT(*)
FROM movie m
JOIN ratings r ON m.id = r.movie_id
WHERE date_published BETWEEN '2018-04-01' AND '2019-04-01'
AND median_rating = 8;

-- Q17
SELECT 
SUM(CASE WHEN country LIKE '%Germany%' THEN total_votes END) AS german_votes,
SUM(CASE WHEN country LIKE '%Italy%' THEN total_votes END) AS italian_votes
FROM movie m
JOIN ratings r ON m.id = r.movie_id;

-- Q18
SELECT 
SUM(name IS NULL),
SUM(height IS NULL),
SUM(date_of_birth IS NULL),
SUM(known_for_movies IS NULL)
FROM names;

-- Q19
SELECT n.name, COUNT(*) AS movie_count
FROM director_mapping d
JOIN names n ON d.name_id = n.id
JOIN movie m ON d.movie_id = m.id
JOIN ratings r ON m.id = r.movie_id
WHERE avg_rating > 8
GROUP BY n.name
ORDER BY movie_count DESC
LIMIT 3;

-- Q20
SELECT n.name, COUNT(*) AS movie_count
FROM role_mapping rm
JOIN names n ON rm.name_id = n.id
JOIN ratings r ON rm.movie_id = r.movie_id
WHERE median_rating >= 8
GROUP BY n.name
ORDER BY movie_count DESC
LIMIT 2;

-- Q21 FIXED
SELECT 
    production_company,
    vote_count,
    RANK() OVER (ORDER BY vote_count DESC) AS prod_comp_rank
FROM (
    SELECT 
        m.production_company,
        SUM(r.total_votes) AS vote_count
    FROM movie m
    JOIN ratings r ON m.id = r.movie_id
    GROUP BY m.production_company
) AS t
LIMIT 3;

-- Q22 FIXED
SELECT 
    name,
    total_votes,
    movie_count,
    avg_rating,
    RANK() OVER (ORDER BY avg_rating DESC, total_votes DESC) AS actor_rank
FROM (
    SELECT 
        n.name,
        SUM(r.total_votes) AS total_votes,
        COUNT(*) AS movie_count,
        SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes) AS avg_rating
    FROM role_mapping rm
    JOIN names n ON rm.name_id = n.id
    JOIN movie m ON rm.movie_id = m.id
    JOIN ratings r ON m.id = r.movie_id
    WHERE m.country LIKE '%India%'
    GROUP BY n.name
    HAVING COUNT(*) >= 5
) AS t;

-- Q23 FIXED
SELECT 
    name,
    total_votes,
    movie_count,
    avg_rating,
    RANK() OVER (ORDER BY avg_rating DESC, total_votes DESC) AS actress_rank
FROM (
    SELECT 
        n.name,
        SUM(r.total_votes) AS total_votes,
        COUNT(*) AS movie_count,
        SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes) AS avg_rating
    FROM role_mapping rm
    JOIN names n ON rm.name_id = n.id
    JOIN movie m ON rm.movie_id = m.id
    JOIN ratings r ON m.id = r.movie_id
    WHERE m.country LIKE '%India%'
      AND m.languages LIKE '%Hindi%'
    GROUP BY n.name
    HAVING COUNT(*) >= 3
) AS t
LIMIT 5;