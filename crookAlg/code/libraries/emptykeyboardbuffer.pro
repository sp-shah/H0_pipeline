; Empties the Keyboard Buffer so get_kbrd(1) will contain keypresses

PRO EmptyKeyboardBuffer
   repeat begin
      ans = get_kbrd(0)
   endrep until ans eq ""
   return
END
