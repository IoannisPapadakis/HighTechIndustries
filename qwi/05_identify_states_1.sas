/* This tabulates the state-level, all-all employment - 
   an easy way to get at availability by state */

%include "config.sas"/source2;


%let qwisuffix=sa_f_gs_n4_op_u;

proc sql;
	select Variable 
	into :qwi_ids separated by " "
	from INTERWRK.ids
;
quit;
%put LEHD IDS: &qwi_ids.;

proc summary data=INTERWRK.qwi_us_&qwisuffix.
(where=(geo_level="S" and ind_level="A" and ownercode="A05" and sex="0" and  agegrp ="A00" and race ="A0" and ethnicity = "A0" and education="E0" and firmage = "0" and firmsize ="0" )) nway;
class &qwi_ids.;
var e;
output out=HTBASE.states_&qwisuffix. sum=e ;
run;

proc export data=HTBASE.states_&qwisuffix. 
 outfile="&htbase./states_&qwisuffix..csv" dbms=csv replace;
run;


