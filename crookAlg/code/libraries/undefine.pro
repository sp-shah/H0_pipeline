; Removes a variable from IDL's memory

PRO Undefine, VarName  
   IF N_ELEMENTS(VarName) GT 0 THEN TempVar = SIZE(TEMPORARY(VarName))
END
