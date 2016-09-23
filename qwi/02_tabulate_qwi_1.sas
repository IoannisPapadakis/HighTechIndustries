/* run some basic stats by high-tech industries */
%include "config.sas"/source2;


%let qwivars=b e f ca cs jc jd;
%let qwistates=ca wi ny;
%let qwisuffix=sa_f_gs_n4_op_u;

/* read ID vars */
filename testurl url "http://lehd.ces.census.gov/data/schema/V&schema./lehd_identifiers_qwi.csv";

proc import file=testurl out=INTERWRK.ids dbms=csv;run;
proc sql;
	select Variable 
	into :qwi_ids separated by " "
	from INTERWRK.ids
;
quit;
%put LEHD IDS: &qwi_ids.;

%create_rename(vars=&qwivars.,schema=&schema.);
%create_rates(vars=&qwivars.,schema=&schema.);


/* create national view */
*options mprint symbolgen;

%mk_qwi_us(states=all,qwibase=&qwibase.);
%mk_qwi_us_dataset(states=all,view=yes,qwilib=qwi_us,suffix=&qwisuffix.);

data INTERWRK.qwi_us_&qwisuffix.
	(keep=&qwi_ids &qwivars.);
	set qwi_us_&qwisuffix.;
	rename
	%include "frag_rename_qwi.sas"/source2;
	;
run;

proc contents data=INTERWRK.qwi_us_&qwisuffix.;
run;

/* work around */
data sum_input / view=sum_input;
	set INTERWRK.qwi_us_&qwisuffix.;
	if geo_level="S" then geography = "S";
run;


proc summary data=sum_input(where=(geo_level="S")) nway;
class &qwi_ids.;
var &qwivars.;
output out=INTERWRK.sum_qwi_us mean=&qwivars. ;
run;

/* create rates */
options ERRORS=1;
data INTERWRK.qwir_us_&qwisuffix.;
	set INTERWRK.qwi_us_&qwisuffix.;
	drop Emp EmpEnd &qwivars.;
	Emp=B;
	EmpEnd=E;
	weight=(b+e)/2;
	%include "frag_rates_qwi.sas"/source2;
	;
run;

/* sum up the rates */
/* work around */
data sum_input / view=sum_input;
	set INTERWRK.qwir_us_&qwisuffix.;
	if geo_level="S" then geography = "S";
run;
proc summary data=sum_input nway;
class &qwi_ids.;
var jcr jdr csr car;
weight weight;
output out=INTERWRK.sum_qwir_us mean=jcr jdr csr car std=std_jcr std_jdr std_csr std_car;
run;



