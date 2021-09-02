; Computation of Weighted Mean

FUNCTION WeightedMean, x, Weight
   WeightedValues = x * Weight
   wMean = TOTAL(WeightedValues) / TOTAL(Weight)
   RETURN, wMean
END
