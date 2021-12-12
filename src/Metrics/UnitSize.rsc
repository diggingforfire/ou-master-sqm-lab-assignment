module Metrics::UnitSize

import Metrics::Scores;

public RiskLevel getRiskLevelUnitSizeComplexity(int lineCountMethod) {
	if (lineCountMethod > 74) return VeryHigh();
	if (lineCountMethod >= 44) return High();
	if (lineCountMethod >= 40) return Moderate();
 	
 	return Simple();
 }