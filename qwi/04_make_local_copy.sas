/* Make a local copy of the SAS file */
%include "config.sas";
proc export data=HTBASE.qwiht outfile="&htbase./qwiht.csv" dbms=csv replace;
run;

x "gzip -f &htbase./qwiht.csv";


