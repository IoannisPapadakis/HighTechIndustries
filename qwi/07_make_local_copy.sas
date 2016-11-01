/* Make a local copy of the SAS file */
%include "config.sas";
%let qwisuffix=sa_f_gs_n4_op_u;
/* select a specific year */
%let fyear=1998;
%let fq=1;

proc export data=INTERWRK.sum_qwi_us_y&fyear.q&fq. outfile="&htbase./sum_qwi_us_y&fyear.q&fq..csv" dbms=csv replace;
run;

x "gzip -f &htbase./sum_qwi_us_y&fyear.q&fq..csv";


