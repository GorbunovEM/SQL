/* For our first foray into aggregates, we're going to stick to something simple. We want to know how many facilities exist - simply produce a total count. */
select count(distinct name) as count
from cd.facilities

/* Produce a count of the number of facilities that have a cost to guests of 10 or more. */
select count(name) as count
from cd.facilities
where guestcost > 10

/* Produce a count of the number of recommendations each member has made. Order by member ID. */
select recommendedby, count(firstname)
from cd.members
group by recommendedby
having recommendedby <> 0
order by recommendedby;

/* Produce a list of the total number of slots booked per facility. For now, just produce an output table consisting of facility id and slots, sorted by facility id. */
select facid, sum(slots) as Total_Slots
from cd.bookings
group by facid
order by facid

/* Produce a list of the total number of slots booked per facility in the month of September 2012. Produce an output table consisting of facility id and slots, 
sorted by the number of slots. */
select facid, sum(slots) as Total_Slots
from cd.bookings
where to_char(starttime, 'YYYY-MM') = '2012-09'
group by facid
order by Total_Slots
