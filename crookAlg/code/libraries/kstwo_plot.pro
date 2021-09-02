FUNCTION KSTwo_Plot, data1, data2, D=D, PLOT = plot, OPLOT=oplot, $
                     VERTLINE=VertLine, LINESTYLE1=linestyle1, LINESTYLE2=linestyle2, $
                     _EXTRA = extra
; Returns the P-value


; NB Plots line jump in center, rather than at edge!

;+
; NAME:
;       KSTWO_PLOT
; PURPOSE:
;       Return the two-sided Kolmogorov-Smirnov statistic
; EXPLANATION:
;       Returns the Kolmogorov-Smirnov statistic and associated probability 
;       that two arrays of data values are drawn from the same distribution
;       Algorithm taken from procedure of the same name in "Numerical
;       Recipes" by Press et al., 2nd edition (1992), Chapter 14
;
; CALLING SEQUENCE:
;       kstwo, data1, data2, D, prob, [ /PLOT, /OPLOT ]
;
; INPUT PARAMATERS:
;       data1 -  vector of data values, at least 4 data values must be included
;               for the K-S statistic to be meaningful
;       data2 -  second set of data values, does not need to have the same 
;               number of elements as data1
;
; OUTPUT PARAMETERS:
;       D - floating scalar giving the Kolmogorov-Smirnov statistic.   It
;               specifies the maximum deviation between the cumulative 
;               distribution of the data and the supplied function 
;       prob - floating scalar between 0 and 1 giving the significance level of
;               the K-S statistic.   Small values of PROB show that the 
;               cumulative distribution function of DATA1 is significantly 
;               different from DATA2
; OPTIONAL INPUT KEYWORD:
;       PLOT - If this keyword is set and non-zero, then KSTWO_PLOT will display a
;               plot of the CDF of the 2 data sets
;               superposed.   The data value where the K-S statistic is 
;               computed (i.e. at the maximum difference between the data CDF 
;               and the function) is indicated by a vertical line.
;               KSRWO_PLOT accepts the _EXTRA keyword, so that most plot keywords
;               (e.g. TITLE, XTITLE, XSTYLE) can also be passed to KSTWO.
;
; EXAMPLE:
;       Test whether two vectors created by the RANDOMN function likely came
;       from the same distribution
;
;       IDL> data1 = randomn(seed,40)        ;Create data vectors to be 
;       IDL> data2 = randomn(seed,70)        ;compared
;       IDL> kstwo, data1, data2, D, prob   & print,D,prob
;
; PROCEDURE CALLS
;       procedure PROB_KS - computes significance of K-S distribution
;
; REVISION HISTORY:
;       Written     W. Landsman                August, 1992
;       FP computation of N_eff      H. Ebeling/W. Landsman  March 1996
;       Converted to IDL V5.0   W. Landsman   September 1997
;       Fix for arrays containing equal values J. Ballet/W. Landsman Oct. 2001
;-

;  On_error, 2

 if ( N_params() LT 2 ) then begin
    print,'Syntax - P = KSTWO_PLOT(data1, data2, [/PLOT], [D=d], [VERTLINE=VertLine]"'
    return, 0
 endif

 n1 = N_elements( data1 )
 if ( N1 LE 3 ) then message, $
   'ERROR - Input data values (first param) must contain at least 4 values'

 n2 = N_elements( data2 )
 if ( n2 LE 3 ) then message, $
   'ERROR - Input data values (second param) must contain at least 4 values'

 sortdata1 = data1[ sort( data1 ) ]        ;Sort input arrays into 
 sortdata2 = data2[ sort( data2 ) ]        ;ascending order

 Frac1 = FINDGEN(n1+1) / n1
 Frac2 = FINDGEN(n2+1) / n2

 yPlot1 = FLTARR(n1+n2)
 yPlot2 = FLTARR(n1+n2)
 xPlot = FLTARR(n1+n2)

 ind1 = 0L
 ind2 = 0L
 i = 0L
 Complete = 0

 WHILE Complete EQ 0 DO BEGIN

     d1 = sortdata1(MIN([ind1,n1-1]))
     d2 = sortdata2(MIN([ind2,n2-1]))

     xPlot(i) = MIN([d1,d2])

     IF d1 LE d2 THEN BEGIN
         IF ind1 LT n1 THEN ind1++ ELSE BEGIN
             xPlot(i) = d2
             IF ind2 LT n2 THEN ind2++
         ENDELSE
     ENDIF
  
     IF d2 LE d1 THEN BEGIN
         IF ind2 LT n2 THEN ind2++ ELSE BEGIN
             xPlot(i) = d1
             IF ind1 LT n1 THEN ind1++
         ENDELSE
     ENDIF

     yPlot1(i) = Frac1(ind1)
     yPlot2(i) = Frac2(ind2)
     
     IF yPlot1(i) EQ 1 AND yPlot2(i) EQ 1 THEN Complete = 1

     i++
 ENDWHILE

 xPlot = xPlot(0:i-1)
 yPlot1 = yPlot1(0:i-1)
 yPlot2 = yPlot2(0:i-1)
 

; The K-S statistic D is the maximum difference between the two distribution
; funtions

 D = max( abs(yPlot1 - yPlot2), MaxInd ) 

 VertLine = (xPlot(MaxInd) + xPlot(MaxInd+1)) / 2

 if keyword_set(plot) OR keyword_set(oplot) then begin

     IF N_ELEMENTS(LineStyle1) EQ 0 THEN LineStyle1 = 0
     IF N_ELEMENTS(LineStyle2) EQ 0 THEN LineStyle2 = 2

     BoxGraph, xPlot, yPlot1, xBox1, yBox1
     BoxGraph, xPlot, yPlot2, xBox2, yBox2
     
     if keyword_set(plot) then begin
         PLOT, xBox1, yBox1, LINESTYLE=linestyle1,YRANGE=[0,1], $
           _EXTRA = extra
         
     ENDIF ELSE IF KEYWORD_SET(oplot) THEN BEGIN

;         oplot, sortdata1[id1],fn1[id1],psym=10,_EXTRA = extra
         OPLOT,  xBox1, yBox1, LINESTYLE=linestyle1,_EXTRA = extra
         
     ENDIF

;     oplot, sortdata2[id2],fn2[id2],psym=10, LINESTYLE=10
     OPLOT,  xBox1, yBox2, LINESTYLE=linestyle2, _EXTRA = extra
   
     plots, [VertLine, VertLine], [yPlot1(MaxInd),yPlot2(MaxInd)], THICK=2
   
 endif

 N_eff =  n1*n2/ float(n1 + n2) ;Effective # of data points

 PRINT, "Neff = ", N_eff, n1, n2


 PROB_KS, D, N_eff, prob        ;Compute significance of statistic

 return, prob

 end
