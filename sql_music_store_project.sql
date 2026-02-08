CREATE DATABASE MUSIC_STORE_MANAGEMENT;

USE MUSIC_STORE_MANAGEMENT;

-- 1. Genre and MediaType
CREATE TABLE Genre (
	genre_id INT PRIMARY KEY,
	name VARCHAR(120)
);

CREATE TABLE MediaType (
	media_type_id INT PRIMARY KEY,
	name VARCHAR(120)
);

-- 2. Employee
CREATE TABLE Employee (
	employee_id INT PRIMARY KEY,
	last_name VARCHAR(120),
	first_name VARCHAR(120),
	title VARCHAR(120),
	reports_to INT,
    levels VARCHAR(255),
	birthdate DATE,
	hire_date DATE,
	address VARCHAR(255),
	city VARCHAR(100),
	state VARCHAR(100),
	country VARCHAR(100),
	postal_code VARCHAR(20),
	phone VARCHAR(50),
	fax VARCHAR(50),
	email VARCHAR(100)
);

-- 3. Customer
CREATE TABLE Customer (
	customer_id INT PRIMARY KEY,
	first_name VARCHAR(120),
	last_name VARCHAR(120),
	company VARCHAR(120),
	address VARCHAR(255),
	city VARCHAR(100),
	state VARCHAR(100),
	country VARCHAR(100),
	postal_code VARCHAR(20),
	phone VARCHAR(50),
	fax VARCHAR(50),
	email VARCHAR(100),
	support_rep_id INT,
	FOREIGN KEY (support_rep_id) REFERENCES Employee(employee_id)
    ON UPDATE CASCADE ON DELETE SET NULL
);

-- 4. Artist
CREATE TABLE Artist (
	artist_id INT PRIMARY KEY,
	name VARCHAR(120)
);

-- 5. Album
CREATE TABLE Album (
	album_id INT PRIMARY KEY,
	title VARCHAR(160),
	artist_id INT,
	FOREIGN KEY (artist_id) REFERENCES Artist(artist_id)
    ON UPDATE CASCADE ON DELETE CASCADE
);

-- 6. Track
CREATE TABLE Track (
	track_id INT PRIMARY KEY,
	name VARCHAR(200),
	album_id INT,
	media_type_id INT,
	genre_id INT,
	composer VARCHAR(220),
	milliseconds INT,
	bytes INT,
	unit_price DECIMAL(10,2),
	FOREIGN KEY (album_id) REFERENCES Album(album_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (media_type_id) REFERENCES MediaType(media_type_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (genre_id) REFERENCES Genre(genre_id)
    ON UPDATE CASCADE ON DELETE CASCADE
);

-- 7. Invoice
CREATE TABLE Invoice (
	invoice_id INT PRIMARY KEY,
	customer_id INT,
	invoice_date DATE,
	billing_address VARCHAR(255),
	billing_city VARCHAR(100),
	billing_state VARCHAR(100),
	billing_country VARCHAR(100),
	billing_postal_code VARCHAR(20),
	total DECIMAL(10,2),
	FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
    ON UPDATE CASCADE ON DELETE SET NULL
);

-- 8. InvoiceLine
CREATE TABLE InvoiceLine (
	invoice_line_id INT PRIMARY KEY,
	invoice_id INT,
	track_id INT,
	unit_price DECIMAL(10,2),
	quantity INT,
	FOREIGN KEY (invoice_id) REFERENCES Invoice(invoice_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (track_id) REFERENCES Track(track_id)
    ON UPDATE CASCADE ON DELETE SET NULL
);

-- 9. Playlist
CREATE TABLE Playlist (
 	playlist_id INT PRIMARY KEY,
	name VARCHAR(255)
);

-- 10. PlaylistTrack
CREATE TABLE PlaylistTrack (
	playlist_id INT,
	track_id INT,
	PRIMARY KEY (playlist_id, track_id),
	FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (track_id) REFERENCES Track(track_id)
    ON UPDATE CASCADE ON DELETE CASCADE
);

SELECT * FROM GENRE;

SELECT * FROM MediaType;
/*
SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE  ''
INTO TABLE  Employee
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(employee_id,last_name,first_name,title,@reports_to,levels,birthdate,hire_date,address,city,state,country,postal_code,phone,fax,email)
SET reports_to=NULLIF(@reports_to,'');
*/
SELECT * FROM Employee;

SELECT * FROM Customer;

SELECT * FROM Artist;

SELECT * FROM Album;
/*
LOAD DATA INFILE  ''
INTO TABLE  track
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(track_id, name, album_id, media_type_id, genre_id, composer, milliseconds, bytes, unit_price);
*/
SELECT * FROM Track;

SELECT * FROM Invoice;
/*
LOAD DATA INFILE  ''
INTO TABLE  InvoiceLine
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(invoice_line_id, invoice_id, track_id, unit_price, quantity);
*/
SELECT * FROM InvoiceLine;

SELECT * FROM Playlist;
/*
LOAD DATA INFILE  ''
INTO TABLE  PlaylistTrack
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(playlist_id, track_id);
*/
SELECT * FROM PlaylistTrack;

-- 1 Who is the senior most employee based on job title?

SELECT EMPLOYEE_ID,FIRST_NAME,LAST_NAME,TITLE FROM EMPLOYEE
ORDER BY LEVELS DESC
LIMIT 1;

-- 2 Which countries have the most Invoices?
SELECT BILLING_COUNTRY,COUNT(*) AS MOSTINVOICES FROM INVOICE
GROUP BY BILLING_COUNTRY
ORDER BY MOSTINVOICES DESC
LIMIT 1;

-- 3 What are the top 3 values of total invoice?
SELECT * FROM INVOICE
ORDER BY TOTAL DESC
LIMIT 3;

-- 4 Which city has the best customers? - We would like to throw a promotional Music Festival in the city we made the most money.
-- Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals

SELECT BILLING_CITY,SUM(TOTAL) AS HIGHESTINVOICE FROM INVOICE
GROUP BY BILLING_CITY
ORDER BY HIGHESTINVOICE DESC
LIMIT 1;

-- 5 Who is the best customer? - The customer who has spent the most money will be declared the best customer.
-- Write a query that returns the person who has spent the most money

SELECT CUSTOMER.CUSTOMER_ID,CUSTOMER.FIRST_NAME,CUSTOMER.LAST_NAME,SUM(INVOICE.TOTAL) AS MOSTSPENT FROM CUSTOMER
INNER JOIN INVOICE ON CUSTOMER.CUSTOMER_ID=INVOICE.CUSTOMER_ID
GROUP BY CUSTOMER.CUSTOMER_ID
ORDER BY MOSTSPENT DESC
LIMIT 1;

-- 6 Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A

SELECT DISTINCT CUSTOMER.EMAIL,CUSTOMER.FIRST_NAME,CUSTOMER.LAST_NAME,GENRE.NAME AS GENRE FROM CUSTOMER
INNER JOIN INVOICE ON CUSTOMER.CUSTOMER_ID=INVOICE.CUSTOMER_ID
INNER JOIN INVOICELINE ON INVOICE.INVOICE_ID=INVOICELINE.INVOICE_ID
INNER JOIN TRACK ON INVOICELINE.TRACK_ID=TRACK.TRACK_ID
INNER JOIN GENRE ON TRACK.GENRE_ID=GENRE.GENRE_ID
WHERE GENRE.NAME='Rock'
ORDER BY CUSTOMER.EMAIL ASC;

-- 7 Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands 

SELECT ARTIST.NAME,COUNT(TRACK.TRACK_ID) AS TOTALROCKMUSICS FROM ARTIST
INNER JOIN ALBUM ON ARTIST.ARTIST_ID=ALBUM.ARTIST_ID
INNER JOIN TRACK ON ALBUM.ALBUM_ID=TRACK.ALBUM_ID
INNER JOIN GENRE ON TRACK.GENRE_ID=GENRE.GENRE_ID
WHERE GENRE.NAME='Rock'
GROUP BY ARTIST.ARTIST_ID
ORDER BY TOTALROCKMUSICS DESC
LIMIT 10;

-- 8  Return all the track names that have a song length longer than the average song length.
-- Return the Name and Milliseconds for each track. Order by the song length, with the longest songs listed first 

SELECT NAME,MILLISECONDS FROM TRACK
WHERE MILLISECONDS > ( SELECT AVG(MILLISECONDS) FROM TRACK)
ORDER BY MILLISECONDS DESC;

-- 9  Find how much amount is spent by each customer on artists? Write a query to return customer name, artist name and total spent 

SELECT CUSTOMER.FIRST_NAME,CUSTOMER.LAST_NAME,ARTIST.NAME AS ARTISTNAME,SUM(INVOICELINE.UNIT_PRICE*INVOICELINE.QUANTITY) AS TOTALSPENT FROM CUSTOMER 
INNER JOIN INVOICE ON CUSTOMER.CUSTOMER_ID=INVOICE.CUSTOMER_ID 
INNER JOIN INVOICELINE ON INVOICE.INVOICE_ID=INVOICELINE.INVOICE_ID 
INNER JOIN TRACK ON INVOICELINE.TRACK_ID=TRACK.TRACK_ID 
INNER JOIN ALBUM ON TRACK.ALBUM_ID=ALBUM.ALBUM_ID 
INNER JOIN ARTIST ON ALBUM.ARTIST_ID=ARTIST.ARTIST_ID 
GROUP BY CUSTOMER.CUSTOMER_ID,ARTIST.ARTIST_ID 
ORDER BY TOTALSPENT DESC;

-- 10 We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases.
-- Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared, return all Genres

WITH POPULARGENRE AS (
SELECT CUSTOMER.COUNTRY AS COUNTRY,GENRE.NAME AS GENRENAME,COUNT(INVOICELINE.INVOICE_LINE_ID) AS TOTALQUANTITY,
DENSE_RANK() OVER (PARTITION BY CUSTOMER.COUNTRY ORDER BY COUNT(INVOICELINE.INVOICE_LINE_ID) DESC) AS TOTALRANK FROM CUSTOMER
INNER JOIN INVOICE ON CUSTOMER.CUSTOMER_ID = INVOICE.CUSTOMER_ID
INNER JOIN INVOICELINE ON INVOICE.INVOICE_ID = INVOICELINE.INVOICE_ID
INNER JOIN TRACK ON INVOICELINE.TRACK_ID = TRACK.TRACK_ID
INNER JOIN GENRE ON TRACK.GENRE_ID = GENRE.GENRE_ID
GROUP BY COUNTRY,GENRENAME
)
SELECT COUNTRY,GENRENAME,TOTALQUANTITY FROM POPULARGENRE
WHERE TOTALRANK = 1
ORDER BY COUNTRY ASC;

-- 11 Write a query that determines the customer that has spent the most on music for each country.
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount

WITH TOPCUSTOMER AS (
SELECT CUSTOMER.CUSTOMER_ID AS ID,CUSTOMER.COUNTRY AS COUNTRY,CUSTOMER.FIRST_NAME AS FIRSTNAME,CUSTOMER.LAST_NAME AS LASTNAME,
SUM(INVOICE.TOTAL) AS TOTALSPENT,
DENSE_RANK() OVER (PARTITION BY CUSTOMER.COUNTRY ORDER BY SUM(INVOICE.TOTAL) DESC) AS SPENDRANK
FROM CUSTOMER
INNER JOIN INVOICE ON CUSTOMER.CUSTOMER_ID = INVOICE.CUSTOMER_ID
GROUP BY COUNTRY,ID
)
SELECT COUNTRY,ID, FIRSTNAME, LASTNAME, TOTALSPENT
FROM TOPCUSTOMER
WHERE SPENDRANK = 1
ORDER BY COUNTRY ASC;
