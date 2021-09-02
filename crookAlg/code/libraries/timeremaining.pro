; Estimates Time remaining in performing something
; using a 4th order polynomial fit

; Call like:
; TimeRemaining, 0, /RESET 
; to start. Then:
; TimeRemaining, FractionDone
; To update...

; Call as often as you like - it automatically adapts so that it only
; processes ~once every second at most

; Auto Resets if the FractionDone is less than previous call

; ECO = 100 - ignores 99 out of 100 calls

FUNCTION CalcPoly, x, coeff, ZEROTERM=zeroterm
   ; Returns y(x)=Poly(x) with coefficients coeff
   
   Result = FLTARR(N_ELEMENTS(x))

   Power = KEYWORD_SET(zeroterm) ? 0 : 1

   FOR i = 0, N_ELEMENTS(coeff)-1 DO BEGIN
       Result = Result + (coeff[i]*(x^(i+Power)))
   ENDFOR

   RETURN, Result

END

PRO FitPoly, x, A, F, pder
   ; Function describing time: polynomial centered on zero

   ; Linear for MAX(x) < 0.2

   COMMON PolyOrderFit, pOrder

   CASE pOrder OF
       3: BEGIN
           F = A[0]*x + A[1]*x^2 + A[2]*x^3
           IF N_PARAMS() GE 4 THEN pder=[[x], [x^2], [x^3]]   
       END
       2: BEGIN
           F = A[0]*x + A[1]*x^2
           IF N_PARAMS() GE 4 THEN pder=[[x], [x^2]]
       END
       1: BEGIN
           F = A[0]*x
           IF N_PARAMS() GE 4 THEN pder=[[x]]   
       END
   ENDCASE
END

PRO TimeRemaining_Reset

   COMMON TimeRemainingShare, TimeRemainingStart, $
     TimeRemainingTimes, TimeRemainingFractions, $
     TimeRemainingSkip, TimeRemainingSkipCount, $
     TimeRemainingEvaluationTime, TimeRemainingLostTime, $
     TimeRemainingEcoCount

   TimeRemainingTimes = FLTARR(1)
   TimeRemainingFractions = FLTARR(1)
   TimeRemainingStart = SYSTIME(1)
   TimeRemainingSkipCount = 0
   TimeRemainingSkip = 0
   TimeRemainingEvaluationTime = 0.
   TimeRemainingLostTime = 0.
   TimeRemainingEcoCount = 0

   SavePlot
   IF !D.WINDOW NE 9 THEN WINDOW, 9, XSIZE=300, YSIZE=250
   RestorePlot

END


PRO TimeRemaining, FractionDone, RESET = reset, ECO = eco

   COMMON TimeRemainingShare, TimeRemainingStart, $
     TimeRemainingTimes, TimeRemainingFractions, $
     TimeRemainingSkip, TimeRemainingSkipCount, $
     TimeRemainingEvaluationTime, TimeRemainingLostTime, $
     TimeRemainingEcoCount

   COMMON PolyOrderFit, pOrder
   
   IF KEYWORD_SET(reset) OR (N_ELEMENTS(TimeRemainingStart) EQ 0) OR (FractionDone EQ 0) THEN TimeRemaining_Reset

   IF N_ELEMENTS(eco) GT 0 THEN BEGIN
       TimeRemainingEcoCount++
       IF TimeRemainingEcoCount LT eco THEN RETURN
       TimeRemainingEcoCount = 0
   ENDIF


   MinPointsForFit = 10 ; Require at least this many points for a linear fit
   CallFreq = 1. ; Initial Desired # calls per sec
   AutoCallTimeFrac = 0.01  ; Specify Desired Overhead Fraction - i.e. Will adjust CallFreq so that the processing time used in computing time remaining is this fraction of the total time spent on the operation.
   MaxWait = 30.   ; (max seconds to wait between calls) - In case the procedure is not called uniformly, don't give up!

   IF NOT KEYWORD_SET(reset) THEN BEGIN
       CurrentTime = SYSTIME(1) - TimeRemainingStart
       Points = N_ELEMENTS(TimeRemainingTimes)+1

       IF N_ELEMENTS(TimeRemainingSkip) GT 0 THEN BEGIN
           TimeRemainingSkipCount++
           ; If more than T seconds since last execution, force run:
           IF CurrentTime-TimeRemainingTimes(Points-2) GT MaxWait THEN TimeRemainingSkip = 0

           IF TimeRemainingSkipCount LT TimeRemainingSkip THEN RETURN
       ENDIF


       IF TimeRemainingFractions(Points-2) GT FractionDone THEN BEGIN
           TimeRemaining_Reset
           Points = N_ELEMENTS(TimeRemainingTimes)+1
       ENDIF

       TimeRemainingTimes = [TimeRemainingTimes, CurrentTime]
       TimeRemainingFractions = [TimeRemainingFractions, FractionDone]

       IF Points GE 5 THEN BEGIN
           IF N_ELEMENTS(TimeRemainingSkip) GT 0 THEN $
             Denominator = MAX([TimeRemainingSkip,1]) ELSE $
             Denominator = 1

           IF TimeRemainingEvaluationTime GT 0.0 THEN BEGIN
               CallFreq = AutoCallTimeFrac/TimeRemainingEvaluationTime
           ENDIF

           Delay = (CurrentTime - TimeRemainingTimes(Points-2))/Denominator
           TimeRemainingSkip = MAX([FLOOR(1./(Delay*CallFreq)),0])
           TimeRemainingSkipCount = 0


;           ; Polynomial Fit - No longer used

;           coeff = [CurrentTime/FractionDone,REPLICATE(0,2)]
;           weights = replicate(1.0, Points)
;           
;           CASE 1 OF
;               FractionDone LT 0.3: pOrder = 1
;               FractionDone LT 0.6: pOrder = 2
;               ELSE: pOrder = 3
;           ENDCASE

;           coeff = coeff(0:pOrder-1)

;           Result = CURVEFIT(TimeRemainingFractions,TimeRemainingTimes, weights, coeff, SIGMA, FUNCTION_NAME='FitPoly')
          

           ; Linear Fit:

           indUse = WHERE(TimeRemainingFractions GT FractionDone - 0.1)
           IF WhereSize(indUse) LT MinPointsForFit THEN BEGIN
               ; Not enough points in the region
               NumPointsToUse = MIN([MinPointsForFit, N_ELEMENTS(TimeRemainingFractions)])
               indUse = N_ELEMENTS(TimeRemainingFractions) - NumPointsToUse + FINDGEN(NumPointsToUse)
           ENDIF

           coeff = LINFIT(TimeRemainingFractions(indUse), TimeRemainingTimes(indUse))
           


           FinishTime = TOTAL(coeff) ; Sum coefficients to get y(x=1)
           TimeLeft = FinishTime - CurrentTime

           TimeLeftHrs = STRTRIM(LONG(TimeLeft / 3600),2)
           TimeLeftMin = FIXLENGTH(FIX((TimeLeft MOD 3600) / 60),2)
           TimeLeftSec = FIXLENGTH(FIX(TimeLeft MOD 60),2)

           CurrentTimeHrs = STRTRIM(LONG(CurrentTime / 3600),2)
           CurrentTimeMin = FIXLENGTH(FIX((CurrentTime MOD 3600) / 60),2)
           CurrentTimeSec = FIXLENGTH(FIX(CurrentTime MOD 60),2)

           TotalTimeHrs = STRTRIM(LONG(FinishTime / 3600),2)
           TotalTimeMin = FIXLENGTH(FIX((FinishTime MOD 3600) / 60),2)
           TotalTimeSec = FIXLENGTH(FIX(FinishTime MOD 60),2)

           LostTimeHrs = STRTRIM(LONG(TimeRemainingLostTime / 3600),2)
           LostTimeMin = FIXLENGTH(FIX((TimeRemainingLostTime MOD 3600) / 60),2)
           LostTimeSec = FIXLENGTH(FIX(TimeRemainingLostTime MOD 60),2)
           LostTimeFrac = TimeRemaininglostTime / CurrentTime


;           PRINT, STRING(FractionDone*100, format="(F4.1)"), $
;             "% (Elapsed: ",CurrentTimeHrs,":",CurrentTimeMin,":",CurrentTimeSec," - Remaining: ", TimeLeftHrs,":",TimeLeftMin,":",TimeLeftSec,")"

           x = FLOAT(FINDGEN(1000))/1000
;           y = CalcPoly(x, coeff)  ; For Poly Fit
           y = CalcPoly(x, coeff, /ZEROTERM) ; For Linear Fit with y-Offset

           ; Save Current Plot Variables
           SavePlot

           WSET, 9
           !P.MULTI=0

           IF MAX(y) GT 18000 THEN BEGIN
               ScaleFactor = 3600
               UnitStr = "hours"               
           ENDIF ELSE IF MAX(y) GT 300 THEN BEGIN
               ScaleFactor = 60
               UnitStr = "mins"
           ENDIF ELSE BEGIN
               ScaleFactor = 1
               UnitStr = "secs"
           ENDELSE

           PLOT, TimeRemainingFractions*100, TimeRemainingTimes/ScaleFactor, PSYM=7, $
             XRANGE=[0,100], YRANGE=[0,MAX(y/ScaleFactor)], $
             XTITLE = "Percent Complete", YTITLE="Time Taken ("+UnitStr+")", COL=RGB(255,255,255), TITLE="Progress Indicator"
           OPLOT, x*100, y/ScaleFactor, COL=255

           TextX = 40.
           TextY = MAX(y/ScaleFactor)/15
           Gap = TextY
           XYOUTS, TextX, TextY+Gap*0, "Elapsed: " + CurrentTimeHrs+":"+CurrentTimeMin+":"+CurrentTimeSec + "/" + TotalTimeHrs+":"+TotalTimeMin+":"+TotalTimeSec, COLOR=RGB(255,0,0)
           XYOUTS, TextX, TextY+Gap*1, "Remaining: " + TimeLeftHrs+":"+TimeLeftMin+":"+TimeLeftSec, COLOR=RGB(0,255,0)
           XYOUTS, TextX, TextY+Gap*2, "Progress: " + STRING(FractionDone*100, format="(F5.1)") + "%", COLOR=RGB(255,255,0)

;           XYOUTS, TextX, TextY+Gap*0, "Overheads: " + LostTimeHrs+":"+LostTimeMin+":"+LostTimeSec+" ("+STRING(LostTimeFrac*100, format="(F4.1)") + "%)", COLOR=RGB(0,255,255)



           ; Restore Plot Variables
           RestorePlot
           
           WAIT, 0.001 ; Update Screen

           TimeRemainingEvaluationTime = SYSTIME(1) - TimeRemainingStart - CurrentTime
       ENDIF

;if currenttime gt 35 then stop

       TimeRemainingLostTime = TimeRemainingLostTime + SYSTIME(1) - TimeRemainingStart - CurrentTime

   ENDIF
 
END
