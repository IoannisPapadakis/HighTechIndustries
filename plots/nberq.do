/* non-functional code - needs to be adjusted */
twoway (
        (function y=`max',range(164 167) xvarformat(%tq) recast(area) color(gs12) base(`min'))
        (function y=`max',range(191 197) recast(area) color(gs12) base(`min'))
        (line `1' qtime if sex =="`sex'", lcolor(navy) lwidth(medium))
        (line `2' qtime if sex =="`sex'", lcolor(cranberry) lwidth(medium))
        (line `3' qtime if sex =="`sex'", 
                lcolor(black) lwidth(medium) yaxis(2) 
          ,legend(cols(2) order( 2 "Recessions" 5 3 4 ) title("Sex=`sex'")) yt("Avg. rate (full-quarter flows)") 
                /* yscale(range(`ymin'(.2)`ymax') axis(2))*/
        )

/* notes: the local macro `max' needs to be computed first from the data.
   the local macro `min' can be set - it's there to capture negative trends */

foreach var in `plotvars' {;
 qui sum `var';
 local maxi=r(max);
 local mini=r(min);
 if ( `max' < `maxi' ) {;
 local max=`maxi';
 };
 if ( `min' > `mini' ) {;
 local min=`mini';
 };
 };


