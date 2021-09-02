FUNCTION ReNumberGroups, Group, REMOVESINGLES=removesingles, DONOTREMOVE=KeepList, START=GroupOne

   ; Procedure to renumber the groups from 1 -->
   ; without missing out numbers in between
   ; If /REMOVESINGLES is set, then any groups with
   ; only 1 member will be returned as zero.
   ; Group number 0 is not processed.
   ; KeepList is a list of indexes that should NOT be removed as singles
   ; groupOne is lowest non-zero group # to use


   IF N_ELEMENTS(GroupOne) EQ 0 THEN GroupOne = 1

   NonZeroInd = WHERE(Group GT 0)
   IF NonZeroInd(0) LT 0 THEN RETURN, -1

   SortedGroupInd = SORT(Group(NonZeroInd))

   SortedGroups = Group(NonZeroInd(SortedGroupInd))

   GroupNumberInd = RemoveDuplicate(SortedGroups, FREQUENCY=NumInGroup)
   GroupList = SortedGroups(GroupNumberInd)  
   
   ; Create Master Group ID List
   MasterGroupList = LONARR(MAX(GroupList)+1)

   IF KEYWORD_SET(removesingles) THEN BEGIN

       KeepGroup = (NumInGroup GT 1)

       IF N_ELEMENTS(KeepList) GT 0 THEN BEGIN

           SortLocation = LONARR(N_ELEMENTS(Group))
;           SortLocation(*) = -1
           SortLocation(NonZeroInd(SortedGroupInd(GroupNumberInd))) = FINDGEN(N_ELEMENTS(GroupNumberInd))
           KeepGroup(SortLocation(KeepList)) = 1
       ENDIF
       
       KeepGroups = WHERE(KeepGroup)
       IF KeepGroups(0) GE 0 THEN MasterGroupList(GroupList(KeepGroups)) = FINDGEN(N_ELEMENTS(KeepGroups))+GroupOne
   ENDIF ELSE BEGIN
       MasterGroupList(GroupList) = FINDGEN(N_ELEMENTS(GroupList))+GroupOne
   ENDELSE

   OutputGroup = MasterGroupList(Group)

   RETURN, OutputGroup

END
