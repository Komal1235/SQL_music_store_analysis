/* Q1: Who is the senior most employee based on job title? */
select * from employee
order by levels desc
limit 1;

/* Q2: Which countries have the most Invoices? */

select billing_country,count(*) as No_of_invoice from invoice
group by billing_country
order by count(*) desc;

/* Q3: What are top 3 values of total invoice? */

select total 
from invoice
order by total desc
limit 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select billing_city,sum(total) as invoiceTotal from invoice 
group by billing_city
order by invoiceTotal desc
limit 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select c.customer_id, first_name, last_name, SUM(total) AS total_spending
from customer c
join invoice i on c.customer_id = i.customer_id
group by c.customer_id
order by total_spending desc
limit 1;


/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select  distinct c.email,c.first_name,c.last_name from customer c
join invoice i on c.customer_id= i.customer_id
join invoice_line il  on il.invoice_id= i.invoice_id
where il.track_id in ( select track_id from track t
                      join genre g on t.genre_id = g.genre_id
                       where g.name like 'Rock')
order by email;


/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select ar.artist_id, ar.name,COUNT(ar.artist_id) AS number_of_songs
from track t
join album2  a on a.album_id = t.album_id
join artist ar on ar.artist_id = a.artist_id
Join genre g on g.genre_id = t.genre_idwhere g.name like 'Rock'
group by ar.artist_id
order by  number_of_songs desc
LIMIT 10;

/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name,milliseconds
from track
where milliseconds > (
	select avg(milliseconds) as avg_track_length
	from track )
order by milliseconds desc;




/* Q9: Find how much amount spent by each customer on beset selling artists? Write a query to return customer name, artist name and total spent */

with  best_selling_artist as (
	select ar.artist_id as artist_id, ar.name as artist_name, SUM(il.unit_price*il.quantity) as total_sales
	from invoice_line il
	join track t on t.track_id = il.track_id
	join album2 a on a.album_id = t.album_id
	join artist ar on ar.artist_id = a.artist_id
	group by 1
	order by total_sales desc
	limit 1
    )
select c.first_name,c.last_name,b.artist_name, sum(il.unit_price* il.quantity) as amount_spent 
from customer c
join invoice i on c.customer_id = i.customer_id
join invoice_line il  on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album2 a on a.album_id = t.album_id
join best_selling_artist b on b.artist_id = a.artist_id
group by c.first_name,c.last_name,b.artist_name
order by amount_spent desc;


/* Q10: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with cte as(
           select c.customer_id,c.first_name,c.last_name,i.billing_country,sum(total) as total_spent,
           row_number() over(partition by billing_country order by SUM(total) desc) as RowNo 
           from customer c
           join invoice i on c.customer_id = i.customer_id
           group by c.customer_id,c.first_name,c.last_name,i.billing_country
           order by i.billing_country,sum(total) desc
           )
select * from cte 
where RowNo=1