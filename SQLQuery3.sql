use r1
select * from [dbo].[netflix_raw] order by title

drop table [dbo].[netflix_raw]

-- so we are changining all columns data type to  nvarchar
--all datatypes size are max . so more memeory is wasting and taking time to load.
--so  created a new table.
create TABLE [dbo].[netflix_raw](
	[show_id] [varchar](10) primary key,
	[type] [varchar](10) NULL,
	[title] [nvarchar](200) NULL,
	[director] [varchar](250) NULL,
	[cast] [varchar](1000) NULL,
	[country] [varchar](150) NULL,
	[date_added] [varchar](20) NULL,
	[release_year] [int] NULL,
	[rating] [varchar](10) NULL,
	[duration] [varchar](10) NULL,
	[listed_in] [varchar](100) NULL,
	[description] [varchar](500) NULL
);;

select * from netflix_raw;;

--checking any duplicates in show_id  and taking this column as primary key
select show_id,COUNT(*) 
from netflix_raw
group by show_id 
having COUNT(*)>1


select title,COUNT(*) 
from netflix_raw
group by title
having COUNT(*)>1


--see duplicates rows
select * from netflix_raw
where concat(upper(title),type)  in (
select concat(upper(title),type) 
from netflix_raw
group by upper(title) ,type
having COUNT(*)>1
)
order by title

--handle duplicates
with cte as (
select * 
,ROW_NUMBER() over(partition by title , type order by show_id) as rn
from netflix_raw
)
select show_id,type,title,cast(date_added as date) as date_added,release_year
,rating,case when duration is null then rating else duration end as duration,description
into netflix
from cte  

select * from netflix

--new table for comma seperated values have this in different rows
select show_id , trim(value) as director
into netflix_director
from netflix_raw
cross apply string_split(director,',')

select show_id , trim(value) as cast
into netflix_cast
from netflix_raw
cross apply string_split(cast,',')

select show_id , trim(value) as country
into netflix_country
from netflix_raw
cross apply string_split(country,',')

select show_id , trim(value) as genre
into netflix_genre
from netflix_raw
cross apply string_split(listed_in,',')


--populate missing values in country,duration columns
insert into netflix_country
select  show_id,m.country 
from netflix_raw nr
inner join (
select director,country
from  netflix_country nc
inner join netflix_director nd on nc.show_id=nd.show_id
group by director,country
) m on nr.director=m.director
where nr.country is null


--data analysis


select nd.director 
,COUNT(distinct case when n.type='Movie' then n.show_id end) as no_of_movies
,COUNT(distinct case when n.type='TV Show' then n.show_id end) as no_of_tvshow
from netflix n
inner join netflix_director nd on n.show_id=nd.show_id
group by nd.director
having COUNT(distinct n.type)>1






select  top 1 nc.country , COUNT(distinct ng.show_id ) as no_of_movies
from netflix_genre ng
inner join netflix_country nc on ng.show_id=nc.show_id
inner join netflix n on ng.show_id=nc.show_id
where ng.genre='Comedies' and n.type='Movie'
group by  nc.country
order by no_of_movies desc




with cte as (
select nd.director,YEAR(date_added) as date_year,count(n.show_id) as no_of_movies
from netflix n
inner join netflix_director nd on n.show_id=nd.show_id
where type='Movie'
group by nd.director,YEAR(date_added)
)
, cte2 as (
select *
, ROW_NUMBER() over(partition by date_year order by no_of_movies desc, director) as rn
from cte
)
select * from cte2 where rn=1





select ng.genre , avg(cast(REPLACE(duration,' min','') AS int)) as avg_duration
from netflix n
inner join netflix_genre ng on n.show_id=ng.show_id
where type='Movie'
group by ng.genre





select nd.director
, count(distinct case when ng.genre='Comedies' then n.show_id end) as no_of_comedy 
, count(distinct case when ng.genre='Horror Movies' then n.show_id end) as no_of_horror
from netflix n
inner join netflix_genre ng on n.show_id=ng.show_id
inner join netflix_director nd on n.show_id=nd.show_id
where type='Movie' and ng.genre in ('Comedies','Horror Movies')
group by nd.director
having COUNT(distinct ng.genre)=2;




select * from netflix_genre where show_id in 
(select show_id from netflix_director where director='Steve Brill')
order by genre