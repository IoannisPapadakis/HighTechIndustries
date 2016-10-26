/* configuration file for QWI-HT */

/* adjust to where public-use QWI can be found */
%let basedir=/data/clean/qwipu/state/;
%let qwibase=&basedir./data.R2016Q3/;
%let qwibasewy=&basedir./data.R2014Q4/; /* should be later but for now...*/
%let qwibasemi=&basedir./data.R2014Q4/; /* should be later but for now...*/
%let schema=4.1-rc2;

/* adjust to where the HT indicators are */
%let htbase=../data;
libname HTBASE "&htbase.";
/* where does intermediate data live */
%let interwrk=/scratch/htqwi;
x "[[ -d &interwrk. ]] || mkdir -p &interwrk.";
libname INTERWRK "&interwrk.";

options sasautos= ( !SASAUTOS "./" );
