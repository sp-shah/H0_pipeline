; RANDU -- Like RANDOMU, but more random...

FUNCTION RANDU, N

   COMMON RandomNumberGeneratorSeed, seed

   IF N_ELEMENTS(seed) EQ 0 THEN seed = LONG(SYSTIME(1))

   Values = RANDOMU(seed, N)

   RETURN, Values

END
