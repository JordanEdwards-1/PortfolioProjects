/* Completed "SQL Murder Mystery" game */


-- game found at mystery.knightlab.com


-- queries used to 'find the murderer' from the databases provided by SQL City PD





------------------------------------------------------------------

/***** Part 1: Police Report *****/




Select * From crime_scene_report
where type = 'murder'
and date = '20180115'
and city = 'SQL City'

-- crime report: Security footage shows that there were 2 
-- witnesses. The first witness lives at the last house 
-- on "Northwestern Dr". The second witness, named Annabel, 
-- lives somewhere on "Franklin Ave".





------------------------------------------------------------------

/***** Part 2.1: Witness #1 *****/

-- "lives at the last house on 'Northwestern Dr' "



Select * From person
	where address_street_name = 'Northwestern Dr'
	order by address_number desc

-- witness name is Morty Schapiro, and is ID in database 
-- is 14887



Select * from interview
	where person_ID = 14887

-- I heard a gunshot and then saw a man run out. He had a 
-- "Get Fit Now Gym" bag. The membership number on the bag 
-- started with "48Z". Only gold members have those bags. The
-- man got into a car with a plate that included "H42W".



select * from get_fit_now_member
	where id like '48z%'
	and membership_status = 'gold'

-- two members have '48z' in there member id and have gold
-- status, Joe Germuska and Jeremy Bower



select * from drivers_license
	where plate_number like '%h42w%'
	and gender = 'male'

-- two cars come up with partial plate match



select person.name, drivers_license.plate_number from drivers_license
	join person
	on drivers_license.id = person.license_id
	where drivers_license.plate_number like '%h42w%'
	and drivers_license.gender = 'male'

-- one of vehicles is owned by Jeremy Bowers




------------------------------------------------------------------

/***** Part 2.2: Witness #2 *****/

-- The second witness, named Annabel, lives somewhere 
-- on "Franklin Ave".



select * from person
	where address_street_name = 'Franklin Ave'
	and name like 'Annabel%'

-- Annabel's id number is 16371



select * from interview
	where person_id = 16371

-- I saw the murder happen, and I recognized the killer from my 
-- gym when I was working out last week on January the 9th.



select * from get_fit_now_member
	where person_id = 16371

select * from get_fit_now_check_in
	where check_in_date = 20180109

-- two others were in the gym at the same time as annabel, one of which
-- was someone with the member id of 48Z55, Jeremy Bowers. confirms this 
-- is the same guy as the other witness






------------------------------------------------------------------

/***** Part 3: Solve the mystery? *****/




INSERT INTO solution VALUES (1, 'Jeremy Bowers');
        
        SELECT value FROM solution;

-- Congrats, you found the murderer! But wait, there's more... If you 
-- think you're up for a challenge, try querying the interview transcript 
-- of the murderer to find the real villain behind this crime. If you 
-- feel especially confident in your SQL skills, try to complete this 
-- final step with no more than 2 queries. Use this same INSERT statement 
-- with your new suspect to check your answer.






------------------------------------------------------------------

/***** Part 4: Jeremy's side of the story *****/




select * from person
	where name = 'Jeremy Bowers'

select * from interview
	where person_id = 67318

-- I was hired by a woman with a lot of money. I don't know her name 
-- but I know she's around 5'5" (65") or 5'7" (67"). She has red hair 
-- and she drives a Tesla Model S. I know that she attended the SQL 
-- Symphony Concert 3 times in December 2017.





------------------------------------------------------------------

/***** Part 5: Mastermind in 2 queries *****/



select person.name, person.id, height, hair_color, gender, car_make, 
car_model, income.annual_income 
from drivers_license
	join person
		on drivers_license.id = person.license_id
	join income
		on person.ssn = income.ssn
	where height between 65 and 67
	and hair_color = 'red'
	and gender = 'female'
	and car_make = 'Tesla'
	and car_model = 'Model S'

-- Two people match description and matching vehicle, Red Korb with 
-- id of 78881 and Miranda Priestly with id of 99716



select * from facebook_event_checkin
	where event_name = 'SQL Symphony Concert'
	and date like '201712%'
	and person_id = 78881 or person_id = 99716

-- Looks like Miranda Priestly went to the Symphony 3 times in December
-- of 2017, matching the description





------------------------------------------------------------------

/***** Part 6: Solving the mystery *****/



INSERT INTO solution VALUES (1, 'Miranda Priestly');
        
        SELECT value FROM solution;

-- Congrats, you found the brains behind the murder! Everyone in SQL 
-- City hails you as the greatest SQL detective of all time. Time to 
-- break out the champagne!






/***** Final Thoughts *****/

-- Honestly pretty fun, had to think on a few of these and rewrite lots of 
-- qweries to make it work, but glad I got it figured out in the end