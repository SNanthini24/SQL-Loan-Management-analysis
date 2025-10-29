##LOAN MANAGEMENT SYSTEM##

create database Loan_Management;
use Loan_Management;
set autocommit=0;
set sql_safe_updates=0;
##load customer_income##
select*from customer_income;
##1 Customer criteria based on applicant income,2 Monthly interest ##

create table customer_Criteria as select*,
case
when ApplicantIncome > 15000 then 'Grade A'
when ApplicantIncome > 9000 then 'Grade B'
when ApplicantIncome > 5000 then 'Middle class customer'
else 'Low class customer'
end as Income_Status,
case
when ApplicantIncome < 5000 and Property_Area="Rural" then 3.0
when ApplicantIncome < 5000 and Property_Area="SemiRural" then 3.5
when ApplicantIncome < 5000 and Property_Area="Urban" then 5.0
when ApplicantIncome < 5000 and Property_Area="SemiUrban" then 2.5
else 7.0
end as Monthly_Interest
from customer_income;
select*from customer_criteria;

##3 creating monthly interest amt and annual interest amount using join##
##load loan_status here##
create table customer_interest_analysis as 
select cc.Loan_ID,ls.LoanAmount,round(ls.LoanAmount*cc.Monthly_Interest)as Monthly_Interest_Amt,round(ls.LoanAmount*cc.Monthly_Interest*12)as Annual_Interest_Amt
from customer_criteria cc
join loan_status ls on ls.Loan_ID=cc.Loan_ID;
select*from customer_interest_analysis;

select*from loan_status;

##4loan status update using trigger##

create table loan_status_import (Loan_ID TEXT,Customer_id TEXT,LoanAmount TEXT,Loan_Amount_Term INT,Cibil_Score INT);

DELIMITER $$
create trigger loan_amt_trig
before insert on loan_status_import
for each row 
begin
	if new.LoanAmount is null then
    set new.LoanAmount='Loan Still Processing';
    end if;
end ;
$$
Delimiter ;

insert into loan_status_import select * from loan_status;

delete from loan_status_import where LoanAmount='Loan Still Processing';
select*from loan_status;
select*from loan_status_import;
##Cibil status update##

alter table loan_status_import
add column status_msg varchar(50);

create table loan_cibil_score_status (Loan_ID TEXT,Customer_id TEXT,LoanAmount TEXT,
Loan_Amount_Term INT,Cibil_Score INT,status_msg varchar(50));

delimiter ##
create trigger cibil_trig 
before insert on loan_cibil_score_status
for each row
begin
	if new.Cibil_Score >900 then
        set new.status_msg ='High CIBIL Score';
    elseif new.Cibil_Score >750 then
        set new.status_msg = 'No Penalty';
    elseif new.Cibil_Score >0 then
        set new.status_msg ='Penalty Customer';
    else
        set new.status_msg ='Rejected - Cannot Apply for Loan';
    end if;
end
##
delimiter ;
delete from loan_status_import where Cibil_Score <= 0;

insert into loan_cibil_score_status select*from loan_status_import;

alter table loan_status_import modify LoanAmount int;
select*from loan_cibil_score_status;

alter table loan_cibil_score_status
add column Gender text;

alter table loan_cibil_score_status
add column Age int;

create table customer_det_import(Customer_ID text,Customer_Name text,Gender text,Age int,Married text,Education text,Self_Employed text,Loan_ID text,Region_ID double);
##load customer_det##
insert into customer_det_import select*from customer_det;
##updating gender and age##
update loan_cibil_score_status as l
join customer_det_import as c on l.Customer_id = c.Customer_id
set
  l.Gender = c.Gender,l.Age = c.Age;

select*from loan_cibil_score_status;
##load country_state and region##

##joining all the table##

select lcs.Loan_ID,lcs.Customer_id,lcs.LoanAmount,lcs.Loan_Amount_Term,lcs.Cibil_Score,lcs.status_msg,lcs.Gender,lcs.Age,
  cc.ApplicantIncome,cc.CoapplicantIncome,cc.Property_Area,cc.Loan_Status,cc.Income_Status,cc.Monthly_Interest,
  cia.Monthly_Interest_Amt,cia.Annual_Interest_Amt,
  cdi.Customer_Name,cdi.Married,cdi.Education,cdi.Self_Employed,cdi.Region_ID,
  cs.Postal_code,cs.Segment,cs.State
from loan_cibil_score_status lcs
join customer_criteria cc on lcs.Loan_ID = cc.Loan_ID
join customer_interest_analysis cia on lcs.Loan_ID = cia.Loan_ID
join customer_det_import cdi on lcs.Customer_id = cdi.Customer_ID
join country_state cs on lcs.Loan_ID=cs.Load_ID;


##High cibil score using filter##
delimiter ##
create procedure High_Cibil_Score()
begin
  select l.Loan_ID,l.Customer_id,l.Cibil_Score,l.status_msg,c.Customer_Name,c.Gender,c.Age
  from loan_cibil_score_status l
  inner join customer_det_import c on l.Customer_id = c.Customer_id
  where l.Cibil_Score > 900;
end;
##
delimiter ;
call High_Cibil_Score();

select*from country_state;
##Filter##

delimiter ^^
create procedure HomeOffice_Corporate()
begin
  select 
    c.Customer_id,c.Customer_Name,c.Gender,c.Age,c.Married,c.Education,c.Self_Employed,c.Loan_ID,c.Region_ID,
    cs.Segment
  from customer_det_import c
  join country_state cs on c.Customer_ID= cs.Customer_Id
  where cs.Segment in ('Home Office', 'Corporate');
end;
^^
delimiter ;
call HomeOffice_Corporate;

##Miss match columns##
select lcs.Loan_ID,lcs.Customer_id,lcs.Cibil_Score,lcs.status_msg
from loan_cibil_score_status lcs
left join customer_criteria cc on lcs.Loan_ID = cc.Loan_ID
left join customer_interest_analysis cia on lcs.Loan_ID = cia.Loan_ID
left join customer_det_import cdi on lcs.Customer_id = cdi.Customer_ID
left join country_state cs on lcs.Loan_ID = cs.Load_ID
where cc.Loan_ID IS NULL or cia.Loan_ID IS NULL or cdi.Customer_ID IS NULL or cs.Load_ID IS NULL;

##Store Procedure##
delimiter //
create procedure CustomerLoanDetails()
begin
  select 
    lcs.Loan_ID, lcs.Customer_id, lcs.LoanAmount, lcs.Loan_Amount_Term, lcs.Cibil_Score, lcs.status_msg, lcs.Gender, lcs.Age,
    cc.ApplicantIncome, cc.CoapplicantIncome, cc.Property_Area, cc.Loan_Status, cc.Income_Status, cc.Monthly_Interest,
    cia.Monthly_Interest_Amt, cia.Annual_Interest_Amt,
    cdi.Customer_Name, cdi.Married, cdi.Education, cdi.Self_Employed, cdi.Region_ID,
    cs.Postal_code, cs.Segment, cs.State
  from loan_cibil_score_status lcs
  join customer_criteria cc on lcs.Loan_ID = cc.Loan_ID
  join customer_interest_analysis cia on lcs.Loan_ID = cia.Loan_ID
  join customer_det_import cdi on lcs.Customer_id = cdi.Customer_ID
  join country_state cs on lcs.Loan_ID = cs.Load_ID;
end;
//
delimiter ;
call CustomerLoanDetails;

delimiter //
create procedure GetCustomerCriteria()
begin
  select * from customer_Criteria;
end;
//
delimiter ;
call GetCustomerCriteria;



