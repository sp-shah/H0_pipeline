; If ind are numbers >= 0 then SetTo sets Array(ind) to SetToWhat

PRO SetTo, ind, Array, SetToWhat
   IF ind(0) GE 0 THEN Array(ind) = SetToWhat
END
