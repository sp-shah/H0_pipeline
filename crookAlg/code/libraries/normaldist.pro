; Create a Normal Distribution & Evaluate at points specifed

FUNCTION NormalDist, nMean, nStdDev, Eval
   RETURN, (1/(nStdDev*SQRT(2*!PI)) * EXP(-((Eval-nMean)^2)/(2*nStdDev^2))
END
