# В компании работают сотрудники из Москвы и Самары. Предположим, мы хотим разбить их на две группы по зарплате в каждом из городов
select ntile(2) over (partition by city order by salary) as tile, name, 
city, salary
from employees
order by city;

