FUNCTION CrossRefPoints, RA1, Dec1, RA2, Dec2, Z1=z1, Z2=z2, $
                         THETA=theta, ZDIFF=zDiff

   ; Returns an array the size of List1
   ; each element contains the index of the object in List2 
   ; that was matched

   ; Searches radius theta (arcsec) & (if provided) velocity difference zDiff

   IF N_ELEMENTS(theta) EQ 0 THEN theta = 1. 
   theta_rad = theta * !DTOR / 3600

   indReturn = LONARR(N_ELEMENTS(RA1))
   indReturn(*) = -1

   FOR i = 0, N_ELEMENTS(RA1)-1 DO BEGIN
       IF N_ELEMENTS(zDiff) GT 0 THEN BEGIN
           indCompare = WHERE(ABS(z1(i)-z2) LE zDiff)
       ENDIF ELSE indCompare = FINDGEN(N_ELEMENTS(RA2))
       
       IF indCompare(0) GE 0 THEN BEGIN
           Sep = AngSep(RA1(i), Dec1(i), RA2(indCompare), Dec2(indCompare))
           
           indMatch = WHERE(Sep LE theta_rad)
           IF indMatch(0) GE 0 THEN BEGIN
               ; Found match(es)
               MatchID = indCompare(indMatch)
               
               IF N_ELEMENTS(MatchID) GT 1 THEN BEGIN
                   PRINT, "Multiple matches found: Using closest"
                   ClosestSep = MIN(Sep, indClosest)
                   IF N_ELEMENTS(indClosest) GT 1 THEN $
                     PRINT, "Still multiple matches: pick first!"

                   MatchID = indCompare(indClosest(0))
               ENDIF

               indReturn(i) = MatchID

           ENDIF

       ENDIF
       
   ENDFOR

   RETURN, indReturn
   
END
