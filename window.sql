# В компании работают сотрудники из Москвы и Самары. Предположим, мы хотим разбить их на две группы по зарплате в каждом из городов
select ntile(2) over (partition by city order by salary) as tile, name, 
city, salary
from employees
order by city;

#Предположим, мы хотим узнать самых высокооплачиваемых людей по каждому департаменту
with CTE as
(select id, name, department, salary,
dense_rank() over (partition by department order by salary desc) as rnk
from employees)

select id, name, department, salary
from CTE
where rnk = 1;

#Предположим, мы хотим для каждого сотрудника увидеть зарплаты предыдущего и следующего коллеги
select name, department, 
lag(salary, 1) over (order by salary) as prev, 
salary,
lead(salary, 1) over (order by salary) as next
from employees
order by salary

#Предположим, мы хотим для каждого сотрудника увидеть, сколько процентов составляет его зарплата от максимальной в городе
with CTE as (
select name, city, salary,
last_value(salary) over (partition by city order by salary
rows between unbounded preceding and unbounded following) as mx
from employees
)

select name, city, salary, 
round(salary*100/mx,0) as percent
from CTE
order by city, salary

#Предположим, мы хотим для каждого сотрудника увидеть, сколько процентов составляет его зарплата от общего фонда труда по городу
with CTE as (
select name, city, salary,
sum(salary) over (partition by city) as fund
from employees
)

select name, city, salary, fund,
round(salary*100/fund, 0) as perc
from CTE
order by city, salary

#Предположим, мы хотим для каждого сотрудника увидеть:

#сколько человек трудится в его отделе (emp_cnt);
#какая средняя зарплата по отделу (sal_avg);
#на сколько процентов отклоняется его зарплата от средней по отделу (diff).

with CTE as (
select name, department, salary,
count(name) over (partition by department) as emp_cnt,
avg(salary) over (partition by department) as sal_avg
from employees
)

select name, department, salary, emp_cnt, round(sal_avg, 0) as sal_avg,
round(((salary - sal_avg)*100)/sal_avg, 0) as diff
from CTE
order by department, salary


#Предположим, мы хотим рассчитать скользящее среднее по доходам за предыдущий и текущий месяц
select year, month, income,
avg(income) over (order by income rows between 1 preceding and current row) as roll_avg
from expenses

#Предположим, мы хотим посчитать фонд оплаты труда нарастающим итогом независимо для каждого департамента

select id, name, department, salary,
sum(salary) over (partition by department order by salary rows between unbounded preceding and current row) as total
from employees



#Напишите запрос, который для каждого сотрудника выведет:

#размер з/п предыдущего по зарплате сотрудника (среди коллег по департаменту);
#максимальную з/п по департаменту.

select id, name, department, salary,
first_value(salary) over (partition by department rows between 1 preceding and current row) as prev_salary,
max(salary) over (partition by department) as max_salary
from employees

#Есть таблица сотрудников employees. Предположим, для каждого человека мы хотим посчитать количество сотрудников, которые получают такую же или большую зарплату (ge_cnt)
select id, name, salary,
count(*) over (order by salary groups between current row and unbounded following) as ge_cnt
from employees
order by salary

#Есть таблица сотрудников employees. Предположим, для каждого человека мы хотим увидеть ближайшую большую зарплату (next_salary):
select id, name, salary,
nth_value(salary, 1) over (order by salary groups between 1 following and unbounded following) as next_salary
from employees
order by salary, next_salary

#Есть таблица сотрудников employees. Предположим, для каждого человека мы хотим посчитать количество сотрудников, которые получают такую же или большую зарплату, но не более чем +10 тыс. ₽ (p10_cnt):
select id, name, salary,
count(*) over (order by salary range between current row and 10 following) as p10_cnt
from employees
order by salary

#Есть таблица сотрудников employees. Предположим, для каждого человека мы хотим определить максимальную зарплату среди тех, у кого зарплата на 10–30 тыс. ₽ меньше чем у него
select id, name, salary,
max(salary) over (order by salary range between 30 preceding and 10 preceding) as lower_sal
from employees
order by salary

#Есть таблица сотрудников employees. Предположим, для каждого человека мы хотим посчитать среднюю зарплату сотрудников, которые получают столько же или больше, чем он — но не более чем +20 тыс. ₽ (p20_sal). При этом зарплату самого сотрудника учитывать не следует
select id, name, salary,
round(avg(salary) over (order by salary range between current row and 20 following exclude current row), 0) as p20_sal 
from employees
order by salary

#А теперь еще хотим посчитать, сколько процентов составляет зарплата сотрудника от средней по Москве и средней по Самаре.
select
  id, name, salary,
  round(salary * 100 / avg(salary) over ()) as "perc",
  round(salary * 100/ avg(salary) filter(where city <> 'Самара') over ()) as 'msk',
  round(salary * 100/ avg(salary) filter(where city <> 'Москва') over ()) as 'sam'
from employees
order by id;


#Посчитайте выручку для тарифа gold по месяцам 2020 года. Для каждого месяца дополнительно укажите:

#выручку за предыдущий месяц (prev);
#процент, который составляет выручка текущего месяца от prev (perc).
#Процент округлите до целого.
with CTE as (
select year, month, revenue,
nth_value(revenue, 1) over (order by month rows between 1 preceding and 1 preceding) as 'prev'
from 
(
select year, month, revenue
from sales
where plan = 'gold' and year = 2020
) as t
order by month
)

select year, month, revenue, prev,
round(revenue * 100  /prev, 0) as 'perc'
from CTE







