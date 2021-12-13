module Analyser

import IO;
import util::Math;
import lang::java::m3::AST;
import List;

import Metrics::Volume;
import Metrics::Complexity;
import Metrics::Duplication;
import Metrics::Maintainability;
import Utils::MethodUtils;

public void analyseProjects() {
	println("smallsql\n----");
	analyseProject(|project://smallsql0.21_src/|);

	println("hsqldb\n----");
	analyseProject(|project://hsqldb/|);
}

private void analyseProject(loc project) {
	int projectLineCount = lineCount(project);
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
	println("volume score: ??");
	println("unit size score: <maintainabilityRating((risk:maintainability[risk].unitSizeComplexityPercentage | risk <- maintainability))>");
	println("unit complexity score: <maintainabilityRating(complexity)>");
	println("duplication score: ??");
	
	println();
	println("analysability score: ??");
	println("changability score: ??");
	println("testability score: ??");
	
	println();
	println("overall maintainability score: ??");
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