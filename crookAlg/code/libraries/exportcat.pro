PRO ExportCat, fileSelect, fileMaster, fileWrite, $
               SELECTCOLUMN=SelectColumn, MASTERCOLUMN=MasterColumn, $
               HEADERLINES=HeaderLines, REMOVE=remove


   IF N_PARAMS() LT 3 THEN BEGIN
       PRINT, "Syntax: Export, <fileselect>, <filemaster>, <filewrite>, [SELECTCOLUMN=#], MASTERCOLUMN=#], [HEADERLINES=#], [/REMOVE]"
   ENDIF

   ObjectList = STRARR(1)

   IF N_ELEMENTS(MasterColumn) EQ 0 THEN MasterColumn=1
   IF N_ELEMENTS(SelectColumn) EQ 0 THEN SelectColumn=1
   IF N_ELEMENTS(HeaderLines) EQ 0 THEN HeaderLines=1

   OPENR, lunSelect, fileSelect, /GET_LUN
   IF (headerlines GE 1) THEN BEGIN
      header = STRARR(headerlines)
      READF, lunSelect, header
   ENDIF
 
   currentline = ""
   LineCount = -1

   ; Read Select File into array

   WHILE NOT EOF(lunSelect) DO BEGIN
      READF, lunSelect, currentline
      TrimmedLine = STRTRIM(currentline, 2)
      IF TrimmedLine NE "" THEN BEGIN
          IF STRMID(TrimmedLine, 0,1) NE "#" THEN BEGIN
              ; Not commented out
              SplitPoints = STRSPLIT(TrimmedLine)

              IF N_ELEMENTS(SplitPoints) GE SelectColumn THEN BEGIN
                  IF N_ELEMENTS(SplitPoints) GT 1 THEN BEGIN
                      CurrentObj = STRTRIM(STRMID(TrimmedLine, SplitPoints(SelectColumn-1), SplitPoints(SelectColumn)-SplitPoints(SelectColumn-1)),2)
                  ENDIF ELSE BEGIN
                      CurrentObj = TrimmedLine
                  ENDELSE
                  
                  IF LineCount GE 0 THEN BEGIN
                      ObjectList = [ObjectList(0:LineCount),CurrentObj]
                      LineCount = LineCount+1
                  ENDIF ELSE BEGIN
                      LineCount = 0
                      ObjectList(LineCount) = CurrentObj
                  ENDELSE
              ENDIF ELSE PRINT, "Not enough columns: ", currentline
          ENDIF
      ENDIF       
   ENDWHILE

   CLOSE, lunSelect
   FREE_LUN, lunSelect

   FoundLine = INTARR(N_ELEMENTS(ObjectList))

   ; Read Master File & Write new one:

   OPENW, lunWrite, fileWrite, /GET_LUN

   OPENR, lunMaster, fileMaster, /GET_LUN
   
   currentline = ""
   WHILE NOT EOF(lunMaster) DO BEGIN
      FoundCurrentLine = 0
      READF, lunMaster, currentline
      TrimmedLine = STRTRIM(currentline, 2)
      IF TrimmedLine NE "" THEN BEGIN
          IF STRMID(TrimmedLine, 1,1) NE "#" THEN BEGIN
              ; Not commented out
              SplitPoints = STRSPLIT(TrimmedLine)

              IF N_ELEMENTS(SplitPoints) GE MasterColumn THEN BEGIN
                  IF N_ELEMENTS(SplitPoints) GT 1 THEN BEGIN
                      CurrentObj = STRTRIM(STRMID(TrimmedLine, SplitPoints(MasterColumn-1), SplitPoints(MasterColumn)-SplitPoints(MasterColumn-1)),2)
                  ENDIF ELSE BEGIN
                      CurrentObj = TrimmedLine
                  ENDELSE

                  ; Read in object - check if in Select File (array)
                  
                  indFound = WHERE(ObjectList EQ CurrentObj)
                  
                  IF indFound(0) GE 0 THEN BEGIN
                      ; Found an occurance:
                                            
                      PRINT, "Matched ", CurrentObj
                      
                      IF N_ELEMENTS(indFound) GT 1 THEN BEGIN
                          PRINT, "Found ", N_ELEMENTS(indFound)," Occurrances of " + CurrentObj
                      ENDIF
                      
                      FoundCurrentLine = 1
                      FoundLine(indFound) = 1
                     
                  ENDIF
              ENDIF ELSE PRINT, "Not enough Columns: ", CurrentLine
          ENDIF       
      ENDIF

      IF ((FoundCurrentLine EQ 1) AND NOT KEYWORD_SET(remove)) OR $
        ((FoundCurrentLine EQ 0) AND KEYWORD_SET(remove)) THEN BEGIN
          PRINTF, lunWrite, CurrentLine
      ENDIF

   ENDWHILE

   CLOSE, lunMaster
   FREE_LUN, lunMaster

   CLOSE, lunWrite
   FREE_LUN, lunWrite

   IF N_ELEMENTS(FoundLine) EQ TOTAL(FoundLine) THEN BEGIN
       PRINT, "All records found successfully."
   ENDIF ELSE BEGIN
       PRINT, N_ELEMENTS(FoundLine)-TOTAL(FoundLine), " records not found:"
       PRINT, ObjectList(WHERE(FoundLine EQ 0))
   ENDELSE

END
