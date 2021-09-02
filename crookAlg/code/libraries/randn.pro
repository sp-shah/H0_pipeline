; RANDN -- Like RANDOMN, but more random...

FUNCTION RANDN, N

   COMMON RandomNumberGeneratorSeed, seed

   IF N_ELEMENTS(seed) EQ 0 THEN seed = LONG(SYSTIME(1))

   Values = RANDOMN(seed, N)

   RETURN, Values

END
