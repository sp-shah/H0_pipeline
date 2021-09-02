PRO KSOneNormal, data, normmean, normstdev, d, prob, PLOT = plot, _EXTRA = extra

;
; NAME:
;       KSONENormal - modified KSone for Normal distribution comparison

 On_error, 2

 if ( N_params() LT 4 ) then begin
    print,'Syntax - ksonenormal, data, mean, stdev, D, [prob ,/PLOT]'
    return
 endif

 N = N_elements( data )
 if N LT 3 then message, $
   'ERROR - Input data values (first param) must contain at least 3 values'


 sortdata = data[ sort( data ) ]                                   

 f0 = findgen(N)/ N
 fn = ( findgen( N ) +1. ) / N


 ff = 0.5*(1 + ERF((DOUBLE(sortdata) - normmean) / (SQRT(2)*normstdev)) )

 D = max( [ max( abs(f0-ff), sub0 ), max( abs(fn-ff), subn ) ], msub )

 if keyword_set(plot) then begin

     if msub EQ 0 then begin 
        plot, sortdata,f0,psym=10,_EXTRA = extra 
        plots, [sortdata[sub0], sortdata[sub0]], [0,1]
     endif else begin
        plot, sortdata,fn,psym=10,_EXTRA = extra
        plots, [sortdata[subn], sortdata[subn]], [0,1]
    endelse 
    oplot,sortdata,ff,linestyle=1
endif

 PROB_KS, D, N, prob           ;Compute significance of K-S statistic

 return

END
