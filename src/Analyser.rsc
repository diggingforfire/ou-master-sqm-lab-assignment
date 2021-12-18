module Analyser

import IO;
import util::Math;
import lang::java::m3::AST;
import List;

import Metrics::Volume;
import Metrics::Complexity;
import Metrics::Coverage;
import Metrics::Duplication;
import Metrics::Maintainability;
import Metrics::Scores;
import Utils::MethodUtils;

public void analyseProjects() {
	analyseProject(|project://smallsql0.21_src/|, "smallsql");
	analyseProject(|project://hsqldb/|, "org.hsqldb");
}

private void analyseProject(loc project, str projectName) {
	println(projectName);
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
	
	tuple[int covered, int total] coverage = getMethodCoverage(project, projectName);
	num testCoveragePercentage = testCoveragePercentage(coverage.covered, coverage.total);
	Ranking coverageRanking = getCoverageRanking(testCoveragePercentage);
	println(testCoveragePercentage);
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
	
	analysabilityScore = averageRanking([volumeRanking, duplicationRanking, unitSizeRanking, coverageRanking]); 
	println("analysability score: <rankingAsString(analysabilityScore)>"); 
	changabilityScore = averageRanking([unitComplexityRanking, duplicationRanking]);
	println("changability score: <rankingAsString(changabilityScore)>");
	stabilityScore = averageRanking([coverageRanking]); 
	println("stability score: <rankingAsString(stabilityScore)>");
	testabilityScore = averageRanking([unitComplexityRanking, unitSizeRanking, coverageRanking]); 
	println("testability score: <rankingAsString(testabilityScore)>");
	
	println();
	println("overall maintainability score: <rankingAsString(averageRanking([analysabilityScore, changabilityScore, testabilityScore, stabilityScore]))>");
	println();
}

private void printComplexities(map[RiskLevel, int] complexity) {
	println("unit complexity:");
	println(" * simple: <complexity[Simple()]>%");
	println(" * moderate: <complexity[Moderate()]>%");
	println(" * high: <complexity[High()]>%");
	println(" * very high: <complexity[VeryHigh()]>%");
}

private num testCoveragePercentage(num coveredMethods, num allMethods) {
	return (coveredMethods / allMethods) * 100;
}
private num duplicatedLinesDensity(num numberOfLinesOfCode, num numberOfDuplicatedLines) {
	return (numberOfDuplicatedLines / numberOfLinesOfCode) * 100;
}