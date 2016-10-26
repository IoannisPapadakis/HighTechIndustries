/* run some basic stats by high-tech industries */
%include "config.sas"/source2;


%let qwivars=b e f ca cs jc jd;
%let qwistates=ca wi ny;
%let qwisuffix=sa_f_gs_n4_op_u;
%let us=us;
*let us=sample;


filename testurl url "http://lehd.ces.census.gov/data/schema/V&schema./lehd_identifiers_qwi.csv";

proc import file=testurl out=INTERWRK.ids dbms=csv;run;
proc sql;
	select Variable 
	into :qwi_ids separated by " "
	from INTERWRK.ids
;
quit;
%put LEHD IDS: &qwi_ids.;

/* Levels:
   INTERWRK.sum_qwi_sample (for testing)
   INTERWRK.sum_qwi_us

   Rates:
   INTERWRK.sum_qwir_sample (for testing)
   INTERWRK.sum_qwir_us
*/

/* show the industry level on the file */

proc freq data=INTERWRK.sum_qwi_&us.;
table ind_level;
run;

proc sort data=INTERWRK.sum_qwi_&us.(where=(ind_level="4")) out=sum_qwi_by_naics4;
by industry;
run;


data qwiht;
	merge sum_qwi_by_naics4(in=_qwi)
              INTERWRK.htindustries(in=_ht)
	;
	by industry;
	_merge=_qwi+2*_ht;
	/* this selects all levels */
	ht=(oes12htlvl ne "");
	/* recode some others */
	length female agenum 3;
	female=(sex="2");
	agenum=substr(agegrp,3,1);
	fem_age=female*10+agenum;
run;

proc freq data=qwiht;
title "Should be no 2s";
table _merge;
run;

proc print data=qwiht(where=(_merge=2));
run;

data HTBASE.qwiht_us;
	set qwiht(where=(_merge ne 2));
run;

title;
proc means data=HTBASE.qwiht_us(where=(sex ne "0" and agegrp="A00"));
title "Means of select variables, by HT status";
class ht;
var &qwivars. female;
run;

proc freq data=HTBASE.qwiht_us(where=(sex = "0" and agegrp ne "A00"));
title "Distribution of age groups, weighted by employment, by HT status";
table agegrp*ht;
weight b;
run;

proc freq data=HTBASE.qwiht_us(where=(sex ne "0" and agegrp ne "A00"));
title "Distribution of sex-age groups, weighted by employment, by HT status";
table fem_age*ht;
weight b;
run;


