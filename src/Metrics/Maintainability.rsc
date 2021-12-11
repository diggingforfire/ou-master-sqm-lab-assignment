module Metrics::Maintainability

import IO;
import util::Math;
import lang::java::m3::AST;

import Metrics::Volume;
import Metrics::Complexity;
import Metrics::UnitSize;
import Utils::MethodUtils;

public data RiskLevel = Simple() | Moderate() | High() | VeryHigh();

 /*
 * Unit complexity rating based on risk levels
 */
public str maintainabilityRating(map[RiskLevel, int] unitComplexity) {
	if (unitComplexity[VeryHigh()] == 0 && unitComplexity[High()] == 0 && unitComplexity[Moderate()] <= 25) return "++";
	if (unitComplexity[VeryHigh()] == 0 && unitComplexity[High()] <= 5 && unitComplexity[Moderate()] <= 30) return "+";
	if (unitComplexity[VeryHigh()] == 0 && unitComplexity[High()] <= 10 && unitComplexity[Moderate()] <= 40) return "+/-";
	if (unitComplexity[VeryHigh()] <= 5 && unitComplexity[High()] <= 15 && unitComplexity[Moderate()] <= 50) return "-";
	
	return "--";
}

/*
 * Relative unit maintainability scores where risk level percentages indicate the amount of unic LOC that falls within that category
 */
public map[RiskLevel, tuple[int cyclomaticComplexityPercentage, int unitSizeComplexityPercentage]] unitMaintainability(num projectLineCount, list[Statement] methodStatements) {
	
	map[RiskLevel, tuple[int lineCountCyclomaticComplexity, int lineCountUnitSizeComplexity]] riskLevelLineCount = (Simple(): <0,0>, Moderate(): <0,0>, High(): <0,0>, VeryHigh(): <0,0>);
		
 	for (methodStatement <- methodStatements) {
 		str sourceText = readFile(methodStatement.src);
 		int lineCountMethod = lineCount(sourceText);
 		
 		RiskLevel cyclomaticComplexityrisk = getRiskLevelCyclomaticComplexity(methodStatement);
		riskLevelLineCount[cyclomaticComplexityrisk].lineCountCyclomaticComplexity += lineCountMethod;
		
		RiskLevel unitSizeRisk = getRiskLevelUnitSizeComplexity(lineCountMethod);
		riskLevelLineCount[unitSizeRisk].lineCountUnitSizeComplexity += lineCountMethod;
 	}

 	return ( 
 		risk : <PercentageOf(riskLevelLineCount[risk].lineCountCyclomaticComplexity, projectLineCount), PercentageOf(riskLevelLineCount[risk].lineCountUnitSizeComplexity, projectLineCount)> | 
 		risk <- riskLevelLineCount
 		);
}

private int PercentageOf(num lineCount, num projectLineCount) {
	return floor((lineCount / projectLineCount) * 100);
}