/****************************** Mini Project***********************/

LIBNAME Sherin "C:\D Drive\Data Science\7. Advanced SAS\Project";

/*Importing data from text file*/

Title 'Import data to SAS';
Data Root_Customer;
 INFILE 'C:\D Drive\Data Science\7. Advanced SAS\Project\New_Wireless_Fixed.txt' truncover;
 INPUT Acctno $ 1-14 Actdt mmddyy10. +1  Deactdt mmddyy10. DeactReason $ 38-48 GoodCredit 53 
       RatePlan 62 DealerType $ 65-67 Age 74-76 Province $ 80-82 +1 Sales DOLLAR12.2;  
 format Sales DOLLAR12.2 Actdt Deactdt mmddyy10.;
 label 	Acctno		= "Account Number"
       	Actdt		= "Activation Date"
		Deactdt		= "Deactivation Date"
		DeactReason	= "Deactivation Reason"
		GoodCredit	= "Good Credit"
		RatePlan	= "Rate Plan"
		DealerType	= "Dealer Type"
		Age			= "Customer Age"
		Province	= "Province"
		Sales		= "Sales Amount"
        ;
RUN;
proc print data=Root_Customer;run;
/*Information on descriptor portion of the data set*/
proc contents data=Root_Customer;run;


*Result;
proc sql;
 select count(*) as Total_Observations from Root_Customer;
quit;
proc print data=Root_Customer (obs=10);
run;
proc print data=Root_Customer (obs=102255 firstobs=102246);
run;

******************************************************* Familiarizing Data **********************************************;

/*1.Account Number Unique*/
proc sql;
	select Count(*) as Total_AccNo,count(distinct Acctno) as Unique_AccNo from Customer;
quit;

/*Creating new data set with new variable "Active_Customer"*/
Data Customer;
  set Root_Customer;
  length Active_Customer $15;
  If missing(Deactdt) then Active_Customer = "Active";
  else Active_Customer = "Deactivated";
Run;

proc sql;
select count(Actdt) as Activated_Count, count(Deactdt) as Deactivated_Count from Root_Customer;
quit;
proc Freq data= Customer;
table Active_Customer/nocum;
Run;

/*Analysis 1.1*/

/*Find if there are duplicate entries in Account Number*/
proc sql;
select count(*) as Total_Obs,count(distinct Acctno) as Unique_AccNo from Customer;
title "Total OBS vs Duplicated Account Number";
quit;

/*Find the number of actived and deactivated accounts*/
Proc freq data=Customer;
	table Active_Customer /NOCUM;
	title "Activated and Deactivated Customer Frequency";
Run;


/*Count of Customers on Earliest and Latest Activation Date*/

proc sql;
    create table temp_customer1 as
	select count(Acctno) as Total_Customers,min(Actdt) as Earliest_Date from Customer
	where Actdt = select min(Actdt) from Customer;
    ; 

	create table temp_customer2 as
	select count(Acctno) as Total_Customers,max(Actdt) as Latest_Date from Customer
	where Actdt = select max(Actdt) from Customer;
    ; 
quit;

proc print data=temp_customer1;
 format Earliest_Date date9.;
 title "Earliest Activation Date and Count";
run;
proc print data=temp_customer2;
 format Latest_Date date9.;
 title "Latest Activation Date and Count";
run;

proc sql;
    create table temp_customer as
	select count(Acctno) as Total_Customers,
	min(Actdt) as Earliest_Activation_Date,
	max(Actdt) as Latest_Activation_Date,
    min(Deactdt) as Earliest_Deactivation_Date,
	max(Deactdt) as Latest_Deactivation_Date
	from Customer; 
quit;

proc print data=temp_customer;
 format Earliest_Activation_Date Latest_Activation_Date Earliest_Deactivation_Date Latest_Deactivation_Date date9.;
 title "Earliest Activation and Deactivation Date";
run;

/*Deactivation Reason*/

Data deactivated_customer;
  set Customer;
  where Deactdt is not MISSING;
Run;

%UNI_ANALYSIS_CAT_HBAR(deactivated_customer,DeactReason);

proc sql;
 select count(*) as Deactivated_Count from deactivated_customer;
quit;

Proc freq data=deactivated_customer; 
table DeactReason;
title "DEACTIVATION REASON";
Run;

%MACRO UNI_ANALYSIS_NUM_HIST_DENSITY(DATA,VAR);
 TITLE "THIS IS HISTOGRAM FOR &VAR";
 PROC SGPLOT DATA=&DATA;
  HISTOGRAM &VAR;
  DENSITY &VAR;
  DENSITY &VAR/type=kernel ;
    STYLEATTRS 
    BACKCOLOR=CYAN 
    WALLCOLOR=BILG
     ;
  keylegend / location=inside position=topright;
 RUN;
 QUIT;
TITLE "THIS IS UNIVARIATE ANALYSIS FOR &VAR IN &DATA";
proc means data=&DATA  N NMISS MIN Q1 MEDIAN MEAN Q3 MAX qrange cv clm maxdec=2 ;
var &var;
run;
%MEND;
%MACRO UNI_ANALYSIS_NUM_HBOX(DATA,VAR);
 TITLE "THIS IS HORIZONTAL BOXPLOT FOR &VAR";
 PROC SGPLOT DATA=&DATA;
  HBOX &VAR;
    STYLEATTRS 
    BACKCOLOR=DARKGREY 
    WALLCOLOR=LIGHTPINK
     ;
 RUN;
TITLE "THIS IS UNIVARIATE ANALYSIS FOR &VAR IN &DATA";
proc means data=&DATA  N NMISS MIN Q1 MEDIAN MEAN Q3 MAX qrange cv clm maxdec=2 ;
var &var;
run;
%MEND;
%MACRO UNI_ANALYSIS_NUM_VBOX(DATA,VAR);
 TITLE "THIS IS VERTICAL BOXPLOT FOR &VAR";
 PROC SGPLOT DATA=&DATA;
  VBOX &VAR;
    STYLEATTRS 
    BACKCOLOR=DARKGREY 
    WALLCOLOR=LIGHTPINK
     ;
 RUN;
TITLE "THIS IS UNIVARIATE ANALYSIS FOR &VAR IN &DATA";
proc means data=&DATA  N NMISS MIN Q1 MEDIAN MEAN Q3 MAX qrange cv clm maxdec=2 ;
var &var;
run;
%MEND;
%MACRO UNI_ANALYSIS_CAT_PIE(DATA,VAR);
 TITLE "THIS IS FREQUENCY OF &VAR FOR &DATA";
  PROC FREQ DATA=&DATA;
  TABLE &VAR;
 RUN;

TITLE "THIS IS PIECHART OF &VAR FOR &DATA";
PROC GCHART DATA=&DATA;
  PIE3D &VAR/discrete 
             value=inside
             percent=outside
             EXPLODE=ALL
			 SLICE=OUTSIDE
			 RADIUS=20
		
;

RUN;
%MEND;
%MACRO UNI_ANALYSIS_CAT_VBAR(DATA,VAR);
 TITLE "THIS IS FREQUENCY OF &VAR FOR &DATA";
  PROC FREQ DATA=&DATA;
  TABLE &VAR;
 RUN;

TITLE "THIS IS VERTICAL BARCHART OF &VAR FOR &DATA";
PROC SGPLOT DATA = &DATA;
 VBAR &VAR;
    STYLEATTRS 
    BACKCOLOR=DARKGREY 
    WALLCOLOR=TAN
     ;
 RUN;

%MEND;

%MACRO UNI_ANALYSIS_CAT_HBAR(DATA,VAR);
 TITLE "THIS IS FREQUENCY OF &VAR FOR &DATA";
  PROC FREQ DATA=&DATA;
  TABLE &VAR;
 RUN;

TITLE "THIS IS VERTICAL BARCHART OF &VAR FOR &DATA";
PROC SGPLOT DATA = &DATA;
 HBAR &VAR;
    STYLEATTRS 
    BACKCOLOR=SALMON 
    WALLCOLOR=TAN
     ;
 RUN;

%MEND;

%MACRO UNI_ANALYSIS_CAT_FORMAT_PIE(DATA,VAR,FORMAT);
 TITLE "THIS IS FREQUENCY OF &VAR FOR &DATA";
  PROC FREQ DATA=&DATA;
  TABLE &VAR;
  FORMAT &VAR &FORMAT;
 RUN;

TITLE "THIS IS PIECHART OF &VAR FOR &DATA";
PROC GCHART DATA=&DATA;
  PIE3D &VAR/discrete 
             value=outside
             percent=inside
             EXPLODE=ALL
			 SLICE=OUTSIDE
			 RADIUS=20
		
;
  FORMAT &VAR &FORMAT;

RUN;
%MEND;

%MACRO UNI_ANALYSIS_CAT_FORMAT_VBAR(DATA,VAR,FORMAT);
 TITLE "THIS IS FREQUENCY OF &VAR FOR &DATA";
  PROC FREQ DATA=&DATA;
  TABLE &VAR;
  FORMAT &VAR &FORMAT;
 RUN;

TITLE "THIS IS VERTICAL BARCHART OF &VAR FOR &DATA";
PROC SGPLOT DATA = &DATA;
 VBAR &VAR;
 FORMAT &VAR &FORMAT;
    STYLEATTRS 
    BACKCOLOR=DARKGREY 
    WALLCOLOR=TAN
     ;
 RUN;

%MEND;
/*Good or Bad Credit*/

PROC FORMAT;
 VALUE credit
           1= "Good" 
		   0= "Bad";
RUN;

%UNI_ANALYSIS_CAT_FORMAT_PIE(Customer,GoodCredit,credit.);


/*Rate Plan*/
proc sql;
 select distinct rateplan from Customer;
quit;
PROC FORMAT;
 VALUE plan
           1= "Low" 
		   2= "Medium"
		   3= "High";
RUN;

%UNI_ANALYSIS_CAT_FORMAT_VBAR (CUSTOMER,RATEPLAN,plan.);


/*Dealer Type*/

proc options option=macro;
run;
%UNI_ANALYSIS_CAT_HBAR(CUSTOMER,DEALERTYPE);


/*Age*/

%UNI_ANALYSIS_NUM_HIST_DENSITY(CUSTOMER,AGE);


/*Province*/

%UNI_ANALYSIS_CAT_PIE(CUSTOMER,PROVINCE);

/*Sales*/

%UNI_ANALYSIS_NUM_HIST_DENSITY(CUSTOMER,SALES);


PROC MEANS DATA=Customer N NMISS MIN Q1 MEDIAN MEAN Q3 MAX QRANGE STD maxdec=2;
	var sales;
	title "SALES";
RUN;

Data Customer_Sales;
  set Customer;
  If missing(Sales) then Sales = 0;
Run;

Proc freq data=Customer_Sales;
	table sales /NOCUM;
	format sales salesgroup.;
	title "SALES";
Run;



/* 1.2 age and province distributions of active and deactivated customers*/

****************** Age Distribution;

proc sort data=Customer;
by Active_Customer;
Run;

TITLE "AGE DISTRIBUTION OF CUSTOMERS OF ACTIVE AND DEACTIVATED CUSTOMERS";
Proc univariate data=Customer normal plot freq;
	var age;
	by Active_Customer;
	output out=activedata
	n=n nmiss=missing min=mininum
	mean=mean std=standard_dev
	median=median max=maximum
	;
Run;
proc print data=activedata;
run;

*province distribution;

title "PROVINCE DISTRIBUTION OF CUSTOMERS OF ACTIVE AND DEACTIVATED CUSTOMERS";

Proc freq data=Customer;
	table Active_Customer * province / NOCOL  NOROW;
Run;

PROC SGPLOT DATA= Customer;
VBAR PROVINCE/GROUP=Active_Customer groupdisplay=cluster;
RUN;
QUIT;



/*Analysis 1.3 customers based on age, province and sales amount*/
PROC FORMAT;
 VALUE salesgroup
	    low-<101 ='<=$100'
		101- <501 ='$100-500'
		501- <801 ='$500-800'
		801-high ='>=$800'
	    ;

 VALUE agegroupfmt
        low-<21 ='<=20'
		21- <41 ='21-40'
		41- <61 ='41-60'
		61-high ='Senior'
        ;
RUN;

%UNI_ANALYSIS_CAT_FORMAT_VBAR(CUSTOMER,AGE,agegroupfmt.);

%UNI_ANALYSIS_CAT_FORMAT_PIE (CUSTOMER,SALES,salesgroup.);

%UNI_ANALYSIS_CAT_HBAR(CUSTOMER, PROVINCE);


******Bivariate Analysis********;

title "Age Vs SALES WITHOUT SEGMENTATION";

/*Creating new table by removing the null values is age and Sales*/
Data Age_Sales_DS;
 set Customer;
 where age is not missing and sales is not missing and province is not null;
 format age agegroupfmt.
Run;
Proc freq data=Age_Sales_DS;
	table age sales province;
    format age agegroupfmt. sales salesgroup.;
Run;*No missing values in the table;

PROC SGPLOT DATA =Age_Sales_DS;
HBOX sales/GROUP =age;
RUN;
QUIT;
PROC SGPLOT DATA =Age_Sales_DS;
VBOX sales/GROUP =province;
RUN;
QUIT;
PROC SGPANEL DATA =Age_Sales_DS;
 PANELBY province/ SPACING =5;
 SCATTER X= age Y=Sales/GROUP= province;
 RUN;
 QUIT;

 PROC SGPLOT DATA =Age_Sales_DS;
HISTOGRAM Sales / GROUP =age;
RUN;
 PROC SGPLOT DATA =Age_Sales_DS;
HISTOGRAM Sales / GROUP =province;
RUN;


title "AGE Vs SALES";
Proc freq data=Customer;
	table age * Sales / NOCOL  NOROW MISSING;
    format age agegroupfmt. sales salesgroup.;
Run;

PROC SGPLOT DATA= Customer;
VBAR Sales/GROUP=Age;
format age agegroupfmt. sales salesgroup.;
RUN;
QUIT;

**Chi-square Test;
proc freq data=Customer;
	table age * Sales/chisq;
	format age agegroupfmt. sales salesgroup.;
run;

title "PROVINCE Vs SALES";
Proc freq data=Customer;
	table province * Sales / NOCOL  NOROW MISSING nocum;
    format sales salesgroup.;
Run;


PROC SGPLOT DATA= Customer;
VBAR Sales/GROUP=province groupdisplay=cluster;
format sales salesgroup.;
RUN;
QUIT;

***Multi Variate Analysis***;



/***1.4.Statistical Analysis:***/

/*1) Calculate the tenure in days for each account and give its simple statistics.*/

data customer_tenure_years;
set Customer;
lastDate = "20JAN2001"D;
if Active_Customer = "Active" then 
   Tenure = INTCK("DAY",Actdt ,lastDate);
else if Active_Customer = "Deactivated" then 
   Tenure = INTCK("DAY",Actdt ,Deactdt);
run;

%UNI_ANALYSIS_NUM_HIST_DENSITY (customer_tenure_years,Tenure);

*****Correlation between Tenure and Sales;

PROC CORR DATA = customer_tenure_years pearson spearman PLOTS(MAXPOINTS=NONE)
          PLOTS= matrix(histogram);
 VAR Tenure Sales ;
RUN;


/*2) Calculate the number of accounts deactivated for each month.*/

data customer_deactivated_month;
 set customer;
 length Month $15;
 if not missing(Deactdt) then Month = put(Deactdt, monname.);
Run;


%UNI_ANALYSIS_CAT_VBAR(customer_deactivated_month,Month);



Data Customer1;
  set Root_Customer;
  lastDate = "20JAN2001"D;
  length Customer_Status $15 Tenure $25 ;
  If missing(Deactdt) then 
    do;
	   Customer_Status = "Active";
	   Tenure_Days = INTCK("DAY",Actdt ,lastDate);
	   if Tenure_Days < 30 then Tenure = "< 30 days";
	   else if 31 <= Tenure_Days < 60 then Tenure = "31 - 60 days";
	   else if 61 <= Tenure_Days < 365 then Tenure = "61 Days - 1 year";
	   else Tenure = "Over 1 year";
	end;
  else if not missing (Deactdt) then
	do;
	   Customer_Status = "Deactivated";
	   Tenure_Days = INTCK("DAY",Actdt ,Deactdt);
	   if Tenure_Days < 30 then Tenure = "< 30 days";
	   else if 31 <= Tenure_Days < 60 then Tenure = "31 - 60 days";
	   else if 61 <= Tenure_Days < 365 then Tenure = "61 Days - 1 year";
	   else Tenure = "Over 1 year";
	end;
	Age_Group = age;
	if missing (sales) then sales=0;
	format Age_Group agegroupfmt.;
	drop lastDate;
Run;

proc print data=Customer1 (obs=20);run;
TITLE "TENURE VS ACCOUNT STATUS";
proc freq data=Customer1;
	table Customer_Status * Tenure/norow nocol;
run;
PROC SGPLOT DATA= Customer1;
HBAR Tenure/GROUP=Customer_Status groupdisplay=cluster;
RUN;
QUIT;



/*4) Test the general association between the tenure segments and “Good Credit” “RatePlan ” and “DealerType.” */

/*tenure segments and “Good Credit”*/
TITLE "TENURE SEGMENT VS GOOD CREDIT";
proc freq data = Customer1;
 table Tenure * GoodCredit / norow nocol chisq;
run;
PROC SGPLOT DATA= Customer1;
VBAR Tenure/GROUP=GoodCredit;
RUN;
QUIT;

/*tenure segments and “RatePlan”*/

TITLE "TENURE SEGMENT VS RATE PLAN";
proc freq data = Customer1;
 table Tenure * RatePlan / norow nocol chisq;
run;
PROC SGPLOT DATA= Customer1;
HBAR Tenure/GROUP=RatePlan;
RUN;
QUIT;

/*tenure segments and “DealerType*/

TITLE "TENURE SEGMENT VS DEALER TYPE";
proc freq data = Customer1;
 table Tenure * DealerType / norow nocol chisq;
run;
PROC SGPLOT DATA= Customer1;
VBAR Tenure/GROUP=DealerType groupdisplay=cluster;
STYLEATTRS BACKCOLOR=LIBG WALLCOLOR=CREAM;
RUN;
QUIT;

/*5) Is there any association between the account status and the tenure segments?
Could you find out a better tenure segmentation strategy that is more associated
with the account status?*/

**Chi-square Test;
TITLE "CUSTOMER STATUS VS TENURE SEGMENTS";
proc freq data=Customer1;
	table Customer_Status * Tenure/norow nocol chisq;
run;


TITLE "TENURE DAYS DISTRIBUTION";
PROC SGPLOT DATA =Customer1;
	HISTOGRAM Tenure_Days/GROUP =Customer_Status transparency=0.25;
	STYLEATTRS BACKCOLOR=VPAB WALLCOLOR=WHITE;
RUN;

Data Customer4;
  set Root_Customer;
  lastDate = "20JAN2001"D;
  length Customer_Status $15 Tenure $25 ;
  If missing(Deactdt) then 
    do;
	   Customer_Status = "Active";
	   Tenure_Days = INTCK("DAY",Actdt ,lastDate);
	         if 0 <= Tenure_Days < 90 or 366 <= Tenure_Days < 455 then Tenure = "Q1";
		else if 90 <= Tenure_Days < 180 or 455 <= Tenure_Days < 545 then Tenure = "Q2";
		else if 180 <= Tenure_Days < 270 or 545 <= Tenure_Days < 635 then Tenure = "Q3";
		else if 270 <= Tenure_Days <= 365 or 635 <= Tenure_Days <= 731 then Tenure = "Q4";
	end;
  else if not missing (Deactdt) then
	do;
	   Customer_Status = "Deactivated";
	   Tenure_Days = INTCK("DAY",Actdt ,Deactdt);
	         if 0 <= Tenure_Days < 90 or 366 <= Tenure_Days < 455 then Tenure = "Q1";
		else if 90 <= Tenure_Days < 180 or 455 <= Tenure_Days < 545 then Tenure = "Q2";
		else if 180 <= Tenure_Days < 270 or 545 <= Tenure_Days < 635 then Tenure = "Q3";
		else if 270 <= Tenure_Days <= 365 or 635 <= Tenure_Days <= 731 then Tenure = "Q4";
	end;
	drop lastDate;
Run;

proc freq data=Customer4;
	table Customer_Status * Tenure/norow nocol chisq;
run;


/*6) Does Sales amount differ among different account status, GoodCredit, and
customer age segments?*/

/*a. Does sales amount differ among different account status*/
TITLE ' ';
proc means data=Customer1 mean clm sum;
var sales;
class Customer_Status;
run;

*Test for equality of variances;
proc glm data=Customer1;
class Customer_Status;
model sales = Customer_Status;
means Customer_Status / hovtest=levene(type=abs) welch;
run;

***Form the Levenes test, The P-value = 0.0520 > 0.05 and take normal(Pooled) ttest result;

proc ttest data=Customer1;
var sales;
class Customer_Status;
run;

*** Pooled p-val = 0.3845 > 0.05. Hence at 5% significant level we fail to reject null hypotesis that sales amount across account status are the same;

/*b. Does sales amount differ among different GoodCredit*/

proc means data=Customer1 mean clm sum;
var sales;
class GoodCredit;
run;

*Test for equality of variances;
proc glm data=Customer1;
class GoodCredit;
model sales = GoodCredit;
means GoodCredit / hovtest=levene(type=abs) welch;
lsmeans GoodCredit /pdiff adjust=tukey plot=meanplot(connect cl) lines;
run;

***Form the Levenes test, The P-value = 0.7540 > 0.05 and hence use normal(Pooled) ttest result;

proc ttest data=Customer1;
var sales;
class GoodCredit;
run;


*** pooled t-test p-val = 0.8844 > 0.05. Hence at 5% significant level we fail to reject null hypotesis that sales amount for Good Credit are the same;

/*c. Does sales amount differ among different customer age segments*/
proc means data=Customer1 mean clm sum;
var sales;
class Age_Group;
run;

*Test for equality of variances and independence;
proc glm data=Customer1;
class Age_Group;
model sales = Age_Group;
means Age_Group / hovtest=levene(type=abs) welch;
lsmeans Age_Group /pdiff adjust=tukey plot=meanplot(connect cl) lines;
run;
quit;

*The p-val for levenes test = 0.0686 > 0.05 and hence we use the standard one-way ANOVA results ie, p-val = 0.4770 is considered
 Since 0.4770 > 0.05, we conclude that at 5% significant level, we fail to reject the null hypothesis that sales amount for customer age segments are similar;

*********************************************************************************************************************************************************************;
























 






