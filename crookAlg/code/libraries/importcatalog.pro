FUNCTION ImportCatalog, str_filename, FORMAT=strformat, HEADERLENGTH=int_header, SEPCHAR=sepchar, MAXSEP=int_charsep, MAXLINECOUNT=maxlinecount, LINESEPARATOR=linesep, HEADERLINES=HeaderStr, IMPORTCOMMENTS=importcomments, FASTIMPORT=fastimport, FAILED=failed, QUIET=quiet

   ; Procedure to Open an ASCII file in Table form that has the format
   ; specified by str_Format. (This format may only include A## and ##X
   ; types.  Returns the contents of the table in the form of an array.
   ; Skips #int_header lines.

   ; Count number of A's in str_format to determine size of array

   ; If SEPCHAR is set, then FORMAT is ignored and this variable is used
   ; as the separator between values
   ; int_charsep: If > 0,
   ; It will extract strings separated by the contents of sepchar
   ; up to a maximum of int_charsep

   ; If LineSeparator is non-null string then
   ; each line is a separate column
   ; And the string LineSep signifies the next row
   ; Only the left part of the read string is compared

   ; If /IMPORTCOMMENTS is set, lines
   ; beginning with # will NOT be ignored

   ; If /FASTIMPORT is set, many of the
   ; other options are ignored, but the procedure is much faster

   ; /QUIET will suppress screen output

   ; failed will be set to 1 if failure occurred

   colMax = 30   ; Max Number of entries wide (if not specified otherwise)
   failed = 0

   IF N_ELEMENTS(maxlinecount) EQ 0 THEN BEGIN
       maxlinecount = 0
       ArraySizeIncrement = 50000
   ENDIF ELSE IF maxlinecount EQ 0 THEN BEGIN
       ArraySizeIncrement = 50000
   ENDIF ELSE ArraySizeIncrement = maxlinecount

   IF N_ELEMENTS(int_header) EQ 0 THEN int_header = 0

   IF N_ELEMENTS(strformat) EQ 0 THEN strformat = "(A)"

   IF N_ELEMENTS(sepchar) GT 0 THEN BEGIN
       IF sepchar NE "" THEN BEGIN
           str_format = sepchar
           sepbychar = 1
       ENDIF ELSE BEGIN
           str_format=strformat
           sepbychar = 0
       ENDELSE
   ENDIF ELSE BEGIN
       str_format=strformat
       sepbychar = 0
   ENDELSE

   IF sepbychar EQ 0 THEN BEGIN
      col = 0
      FOR i=0, STRLEN(str_format)-1 DO BEGIN
          IF (STRMID(str_format, i, 1) EQ "A") OR $
            (STRMID(str_format, i, 1) EQ "a") THEN col = col + 1
      ENDFOR
      ; Redefine Array Size
   ENDIF ELSE BEGIN
       IF N_ELEMENTS(int_charsep) EQ 0 THEN int_charsep = colMax
       col = int_charsep
   ENDELSE

   colSize = 0

   IF NOT KEYWORD_SET(quiet) THEN PRINT, "Computing # Lines in file..."

   TotalLines = FILE_LINES(str_filename)

   IF NOT KEYWORD_SET(quiet) THEN PRINT, "Importing ", TotalLines, " lines..."

   TotalLines = TotalLines - int_header
   IF TotalLines EQ 0 THEN BEGIN
       failed = 1
       RETURN, -1
   ENDIF


   OPENR, lun, str_filename, /GET_LUN
   IF (int_header GT 0) THEN BEGIN
       HeaderStr = STRARR(int_header)
       READF, lun, HeaderStr
   ENDIF
   
 
   LastLineSep = -1
   LineSepRow = 0

   CurrentArraySize = TotalLines

   IF KEYWORD_SET(fastimport) THEN BEGIN
       str_return = STRARR(CurrentArraySize)
       READF, lun, str_return, FORMAT=str_format
       RETURN, str_return
   ENDIF ELSE str_return = STRARR(CurrentArraySize, col)

   currentline = "" 
   filecontents = STRARR(TotalLines)

   READF, lun, filecontents

   linecount = LONG(0)
   inputlinecount = LONG(0)

   str_returnrow = STRARR(col)

   IF NOT KEYWORD_SET(quiet) THEN PRINT, "Splitting strings..."

   WHILE ((inputlinecount LT TotalLines) AND ((linecount LE maxlinecount) OR (maxlinecount EQ 0))) DO BEGIN

       IF NOT KEYWORD_SET(quiet) THEN TimeRemaining, FLOAT(inputlinecount)/TotalLines

       currentline = filecontents(inputlinecount)
     
;      IF linecount MOD 20000 EQ 0 AND linecount GT 0 THEN PRINT, "Read in ", linecount, " lines..."       
     

      IF STRMID(STRTRIM(currentline, 2), 0, 1) EQ "#" AND NOT KEYWORD_SET(importcomments) THEN comment = 1 ELSE comment = 0

      IF N_ELEMENTS(linesep) GT 0 THEN BEGIN
          IF STRMID(currentline,0, STRLEN(linesep)) EQ linesep THEN BEGIN
              ; Found Line Separator
              IF LineSepRow EQ 0 THEN BEGIN
                  IF linecount EQ 0 THEN LineSepRow-- ELSE BEGIN
                      StoreArray = STRARR(LineSepRow+1, linecount-LastLineSep-1)
                      StoreArray(LineSepRow, *) = str_return(LastLineSep+1:linecount-1)
                  ENDELSE
              ENDIF ELSE BEGIN
                  arraywidth = MAX([N_ELEMENTS(StoreArray(0,*)), linecount-LastLineSep-1])
                  NewStoreArray = STRARR(LineSepRow+1, arraywidth)
                  NewStoreArray(0:LineSepRow-1, 0:N_ELEMENTS(StoreArray(0,*))-1 ) = StoreArray(*,*)
                  NewStoreArray(LineSepRow, 0:linecount-LastLineSep-2) = str_return(LastLineSep+1:linecount-1)
                  StoreArray = TEMPORARY(NewStoreArray)
              ENDELSE
              LastLineSep = linecount
              LineSepRow++
          ENDIF

      ENDIF

      IF STRTRIM(currentline, 2) NE "" AND comment EQ 0 THEN BEGIN
          IF linecount GE CurrentArraySize THEN BEGIN
              ; Array not big enough - enlarge it
              
              NewArray = STRARR(CurrentArraySize+ArraySizeIncrement, col)
              NewArray(0:CurrentArraySize-1,*) = str_return
              
              CurrentArraySize = CurrentArraySize + ArraySizeIncrement
              
              str_return = NewArray

          ENDIF
          
          IF NOT KEYWORD_SET(sepbychar) THEN BEGIN
              READS, currentline, str_returnrow, FORMAT=str_format
              str_return(linecount, *) = str_returnrow      
          ENDIF ELSE BEGIN
              arrayextract = STRSPLIT(currentline, str_format, /EXTRACT)
              maxarray = MIN([N_ELEMENTS(arrayextract), int_charsep])
              colSize = MAX([maxarray, colSize])
              str_return(linecount, 0:maxarray-1) = arrayextract(0:maxarray-1)
          ENDELSE

          linecount++

      ENDIF
      inputlinecount++

   ENDWHILE

   CLOSE, lun
   FREE_LUN, lun

   IF N_ELEMENTS(linesep) GT 0 AND linecount-LastLineSep GT 1 THEN BEGIN
       linecount--
       arraywidth = MAX([N_ELEMENTS(StoreArray(0,*)), linecount-LastLineSep-1])
       NewStoreArray = STRARR(LineSepRow+1, arraywidth)
       NewStoreArray(0:LineSepRow-1, 0:N_ELEMENTS(StoreArray(0,*))-1 ) = StoreArray(*,*)
       NewStoreArray(LineSepRow, 0:linecount-LastLineSep-2) = str_return(LastLineSep+1:linecount-1)
       StoreArray = TEMPORARY(NewStoreArray)

       str_return = StoreArray
   ENDIF ELSE IF colSize GT 0 THEN BEGIN
       str_return = str_return(0:linecount-1,0:colSize-1)
   ENDIF ELSE str_return = str_return(0:linecount-1,0:col-1)

   RETURN, str_return

END
