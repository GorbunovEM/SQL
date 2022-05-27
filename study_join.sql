/*How can you produce a list of the start times for bookings by members named 'David Farrell'?*/

select starttime from cd.bookings
left join cd.members on
cd.bookings.memid = cd.members.memid
where (cd.members.surname = 'Farrell') and (cd.members.firstname = 'David');

/*How can you produce a list of the start times for bookings for tennis courts, for the date '2012-09-21'? Return a list of start time and facility name pairings, 
ordered by the time.*/

SELECT starttime, name
FROM cd.bookings
INNER JOIN cd.facilities ON cd.facilities.facid = cd.bookings.facid
WHERE name LIKE '%Tennis Court%' AND starttime BETWEEN '2012-09-21 00:00:00' AND '2012-09-21 23:59:59' 
ORDER BY starttime;

/*How can you output a list of all members who have recommended another member? Ensure that there are no duplicates in the list, and that results 
are ordered by (surname, firstname).*/

select distinct t1.firstname, t1.surname
from cd.members as t1
join cd.members as t2 on t1.memid = t2.recommendedby
where t2.recommendedby <> 0
order by surname, firstname;

/*How can you output a list of all members, including the individual who recommended them (if any)? Ensure that results are ordered by (surname, firstname).*/

select m1.firstname as memfname, m1.surname as memsname,
m2.firstname as recfname, m2.surname as recsname
from cd.members as m1
left outer join cd.members as m2
on m2.memid = m1.recommendedby
order by m1.surname, m1.firstname;

/*How can you produce a list of all members who have used a tennis court? Include in your output the name of the court, and the name of the member 
formatted as a single column. Ensure no duplicate data, and order by the member name followed by the facility name.*/

select distinct concat(firstname,' ',surname) as member, name as facility
from cd.members
left join cd.bookings using(memid)
left join cd.facilities using(facid)
where name in ('Tennis Court 1', 'Tennis Court 2')
order by member, name

/*How can you produce a list of bookings on the day of 2012-09-14 which will cost the member (or guest) more than $30? Remember that guests have different costs 
to members (the listed costs are per half-hour 'slot'), and the guest user is always ID 0. Include in your output the name of the facility, the name of the member 
formatted as a single column, and the cost. Order by descending cost, and do not use any subqueries.*/

select concat(firstname,' ',surname) as member, name as facility,
CASE WHEN cd.bookings.memid = 0 THEN cd.bookings.slots * cd.facilities.guestcost ELSE cd.bookings.slots * cd.facilities.membercost END AS cost
from cd.members
left join cd.bookings using(memid)
left join cd.facilities using(facid)
where (CASE WHEN cd.bookings.memid = 0 THEN cd.bookings.slots * cd.facilities.guestcost ELSE cd.bookings.slots * cd.facilities.membercost END) > 30 and
(starttime BETWEEN '2012-09-14 00:00:00' AND '2012-09-14 23:59:59')
order by cost desc


/*How can you output a list of all members, including the individual who recommended them (if any), without using any joins? 
Ensure that there are no duplicates in the list, and that each firstname + surname pairing is formatted as a column and ordered.*/

SELECT DISTINCT concat(one.firstname,' ',one.surname) as member,
(SELECT concat(two.firstname,' ',two.surname) FROM cd.members AS two
WHERE two.memid=one.recommendedby) AS recommender 
FROM cd.members as one
ORDER BY
member;
