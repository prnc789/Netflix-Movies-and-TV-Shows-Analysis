---Netflix project

create table netflix(
    show_id varchar(6),
	type varchar(10),
    title varchar(150),
    director varchar(208),
    casts varchar(1000),
    country varchar(150),
    date_added varchar(50),
    release_year int,
	rating varchar(10),
    duration varchar(15),
    listed_in varchar(100),
    description varchar(250)
);

select * from netflix;

-- 15 Business Problems

1. count the number of movies vs tv shows

select type, count(*) as total_content
from netflix
group by type;

2. Find the most common rating for movies and TV shows

select 
  type, 
  rating
from
(
 select 
  type, rating,
  count(*),
  rank() over(partition by type order by count(*) desc) as ranking
 from netflix
 group by 1, 2
) as t1
where ranking = 1;

3. List all movies released in a specific year (e.g., 2020)

select *
from netflix
where type = 'Movie' and release_year = 2020;

4. Find the top 5 countries with the most content on netflix

select 
 UNNEST(string_to_array(country, ',')) as new_country,
 count(show_id) as total_content
from netflix
group by 1
order by 2 desc
limit 5;

5. Identify the longest movie

select * from netflix
where type = 'Movie'
      and
	  duration = (select max(duration) from netflix);

6. Find the content added in the last 5 years

select *
from netflix
where
  To_DATE(date_added, 'Month, DD, YYYY') >= Current_Date - Interval '5years';

7. Find all the movies / TV shows by director 'Rajiv Chilaka'

select * 
from netflix
where director ilike '%Rajiv Chilaka%';

8. List all the TV shows with more than 5 seasons

select 
     *
from netflix
where 
     type = 'TV Show'
     and
     SPLIT_PART(duration, ' ', 1)::numeric > 5; 

9. Count the number of contents items in each genre 

select
unnest(STRING_TO_ARRAY(listed_in, ',')) as genre,
count(show_id) as total_content
from netflix
group by 1;

10. Find each year and the average number of content release by india on netflix
    return the top 5 year with highest avg content release

select
    extract(year from TO_DATE(date_added, 'Month, DD, YYYY')) as year,
	count(*) as yearly_content,
	round(
    count(*)::numeric/(select count(*) from netflix where country = 'India')::numeric * 100
	,2) as avg_content_per_year
from netflix
where country = 'India'
group by 1;

11. List all movies that are documentaries

select * from netflix
where listed_in ILIKE '%documentaries%';

12. Find all content without a director

select *
from netflix
where director is null;

13. Find how many movies actor salman khan appeared in last 10 years

select * from netflix
where 
  casts ILIKE '%Salman Khan%'
  and
  release_year > extract(year from current_date) - 10;

14. Find the top 10 actors who have appeared in the highest number of movies produced in india

select 
unnest(STRING_TO_ARRAY(casts, ',')) as actors,
count(*) as total_content
from netflix
where country ILIKE '%India' 
group by 1
order by 2 desc
limit 10;

15. Categorise the content based on the presence of the keywords 'kill' and 'violence'
in the description field. label content containing these keywords as 'bad' and all other 
content as 'good'. count how many items fall into each category

with new_table
as
(select *,
case when description ILIKE '%kill%'
     or
          description ILIKE '%violence%' then 'Bad_Content'
	 else 'Good Content' end category
from netflix)
select
category,
count(*) as total_content
from new_table
group by 1;