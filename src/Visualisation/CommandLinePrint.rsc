module Visualisation::CommandLinePrint

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
	
	map[RiskLevel, tuple[num cyclomaticComplexityPercentage, num unitSizeComplexityPercentage]] maintainability = unitMaintainability(methods);
	
	map[RiskLevel, num] unitSize = (risk:maintainability[risk].unitSizeComplexityPercentage | risk <- maintainability);
	map[RiskLevel, num] unitComplexity = (risk:maintainability[risk].cyclomaticComplexityPercentage | risk <- maintainability);
	
	println("unit size:");
	printUnitMetrics(unitSize);
	
	println("unit complexity:");
	printUnitMetrics(unitComplexity);
	
	num duplicationDensity = duplicationDensityForProject(project, projectLineCount);	
	println("duplication: <round(duplicationDensity, 0.01)>%");
	
	tuple[int covered, int total] coverage = getMethodCoverage(project, projectName);
	num CoveragePercentage = testCoveragePercentage(coverage.covered, coverage.total);
	Ranking coverageRanking = getCoverageRanking(CoveragePercentage);

	println();
	Ranking volumeRanking = getVolumeRanking(projectLineCount);
	println("volume score: <rankingAsString(volumeRanking)>");
	Ranking unitSizeRanking = getMaintainabilityRanking((risk:maintainability[risk].unitSizeComplexityPercentage | risk <- maintainability));
	println("unit size score: <rankingAsString(unitSizeRanking)>");
	Ranking unitComplexityRanking = getMaintainabilityRanking(unitComplexity);
	println("unit complexity score: <rankingAsString(unitComplexityRanking)>");
	Ranking duplicationRanking = getDuplicationRanking(duplicationDensity);
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

private void printUnitMetrics(map[RiskLevel, num] complexity) {
	println(" * simple: <round(complexity[Simple()], 0.1)>%");
	println(" * moderate: <round(complexity[Moderate()], 0.1)>%");
	println(" * high: <round(complexity[High()], 0.1)>%");
	println(" * very high: <round(complexity[VeryHigh()], 0.1)>%");
}