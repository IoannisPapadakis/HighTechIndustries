/* Make a local copy of the SAS file */
%include "config.sas";
proc export data=HTBASE.qwiht_us outfile="&htbase./qwiht_us.csv" dbms=csv replace;
run;

x "gzip -f &htbase./qwiht_us.csv";


