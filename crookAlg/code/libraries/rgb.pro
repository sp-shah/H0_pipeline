FUNCTION RGB, red, green, blue
   ; Returns the colour-index of a given Red/Green/Blue combination
   RETURN, LONG(red) + 256*(LONG(green) + 256*LONG(blue))
END
