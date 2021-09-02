; Returns the Mean using the central Percentile% of the data

FUNCTION PercentileMean, data, Percentile
   RETURN, MEAN(data(CentralPercentile(data,Percentile)))
END
