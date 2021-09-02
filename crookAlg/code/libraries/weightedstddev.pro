; Computes the Weighted Standard Deviation

FUNCTION WeightedStdDev, x, Weights

   ; Sample Standard Deviation (not population)

   wMean = WeightedMean(x, Weights)
   Variance = TOTAL((x-wMean)^2 * Weights) / TOTAL(Weights)
   RETURN, SQRT(Variance)
END
