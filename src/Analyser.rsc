module Analyser

import IO;
import util::Math;
import lang::java::m3::AST;
import List;

import Metrics::Volume;
import Metrics::Complexity;
import Metrics::Duplication;
import Metrics::Maintainability;
import Metrics::Scores;
import Utils::MethodUtils;

public void analyseProjects() {
	println("smallsql");
	analyseProject(|project://smallsql0.21_src/|);

	println("hsqldb");
	analyseProject(|project://hsqldb/|);
}

private void analyseProject(loc project) {
	println("----");
	int projectLineCount = getLineCount(project);
	println("lines of code: <projectLineCount>");
	
	list[Statement] methods = getProjectMethodsStatements(project);
	println("number of units: <size(methods)>");
	
	map[RiskLevel, tuple[int cyclomaticComplexityPercentage, int unitSizeComplexityPercentage]] maintainability = unitMaintainability(projectLineCount, methods);
	map[RiskLevel, int] complexity = (risk:maintainability[risk].cyclomaticComplexityPercentage | risk <- maintainability);
	printComplexities(complexity);
	
	int numberOfDuplicatedLines = numberOfDuplicatedLinesForProject(project);	
	duplicatedDensity = duplicatedLinesDensity(projectLineCount, numberOfDuplicatedLines);
	println("duplication: <round(duplicatedDensity, 0.01)>%");
	
	println();
	Ranking volumeRanking = getVolumeRanking(projectLineCount);
	println("volume score: <rankingAsString(volumeRanking)>");
	Ranking unitSizeRanking = getMaintainabilityRanking((risk:maintainability[risk].unitSizeComplexityPercentage | risk <- maintainability));
	println("unit size score: <rankingAsString(unitSizeRanking)>");
	Ranking unitComplexityRanking = getMaintainabilityRanking(complexity);
	println("unit complexity score: <rankingAsString(unitComplexityRanking)>");
	Ranking duplicationRanking = getDuplicationRanking(duplicatedDensity);
	println("duplication score: <rankingAsString(duplicationRanking)>");
	
	println();
	
	analysabilityScore = averageRanking([volumeRanking, duplicationRanking, unitSizeRanking]); // TODO: add unit testing ranking
	println("analysability score: <rankingAsString(analysabilityScore)>"); 
	changabilityScore = averageRanking([unitComplexityRanking, duplicationRanking]);
	println("changability score: <rankingAsString(changabilityScore)>");
	//stabilityScore = averageRanking([]); // TODO: add unit testing ranking
	testabilityScore = averageRanking([unitComplexityRanking, unitSizeRanking]); // TODO: add unit testing ranking
	println("testability score: <rankingAsString(testabilityScore)>");
	
	println();
	println("overall maintainability score: <rankingAsString(averageRanking([analysabilityScore, changabilityScore, testabilityScore]))>"); // TODO: add stabilityScore
	println();
}

private void printComplexities(map[RiskLevel, int] complexity) {
	println("unit complexity:");
	println(" * simple: <complexity[Simple()]>%");
	println(" * moderate: <complexity[Moderate()]>%");
	println(" * high: <complexity[High()]>%");
	println(" * very high: <complexity[VeryHigh()]>%");
}

private num duplicatedLinesDensity(num numberOfLinesOfCode, num numberOfDuplicatedLines) {
	return (numberOfDuplicatedLines / numberOfLinesOfCode) * 100;
}