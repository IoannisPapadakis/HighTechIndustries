/* run some basic stats by high-tech industries */
%include "config.sas"/source2;


%let qwivars=b e f ca cs jc jd;
/*%let qwistates=ca wi ny;*/
%let qwisuffix=sa_f_gs_n4_op_u;
/* select a specific year */
%let fyear=1995;
%let fq=1;

/* read ID vars */

proc sql;
	select Variable 
	into :qwi_ids separated by " "
	from INTERWRK.ids
;
quit;
%put LEHD IDS: &qwi_ids.;

/* get states in 1998Q1 */
data states(keep=geography state);
 set HTBASE.states_&qwisuffix. (where=(year=&fyear. and quarter=&fq.));
 length state $ 2;
 state=fipstate(geography);
run;

proc print;
run;

proc sort data=states;
by geography;
run;

proc sort data=INTERWRK.qwi_us_&qwisuffix.(where=(geo_level="S"))
	out=sum_input;
by geography;
run;

/* work around */
data sum_input ;
	merge sum_input
	      states(in=_b);
	by geography;
	if _b;
        /* the geography will say that 00=US is the relevant geocode
           we leave geo_level=S to indicate that this is based off
           a state-level file, and is not a true national-level file */
        /* 98 = 1998 */
        /* 95 = 1995 */
	if geo_level="S" then geography = "%substr(&fyear.,3,2)";
run;

/* this sum creates a file at the national level, naics=naics4, by all the 
   variables on the file (see IDs).
*/
proc summary data=sum_input(where=(geo_level="S" and ind_level="4")) nway;
class &qwi_ids.;
var &qwivars.;
output out=INTERWRK.sum_qwi_us_y&fyear.q&fq. sum=&qwivars. ;
run;


