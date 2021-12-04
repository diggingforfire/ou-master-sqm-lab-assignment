module Analyser

import IO;
import util::Math;
import lang::java::m3::AST;

import Metrics::Volume;
import Metrics::Complexity;
import Metrics::Duplication;

public void analyseProjects() {
	println("smallsql\n----");
	analyseProject(|project://smallsql0.21_src/|);

	println("hsqldb\n----");
	analyseProject(|project://hsqldb/|);
}

private void analyseProject(loc project) {
	projectLineCount = lineCount(project);
	println("lines of code: <projectLineCount>");
	
	printComplexity(unitComplexity(project, projectLineCount));
	
	duplicatedDensity = duplicatedLinesDensity(projectLineCount, numberOfDuplicatedLinesForProject(project));
	println("duplication: <round(duplicatedDensity, 0.01)>%");
}

private real duplicatedLinesDensity(int numberOfLinesOfCode, int numberOfDuplicatedLines) {
	return toReal(numberOfDuplicatedLines) / toReal(numberOfLinesOfCode) * 100;
}

public void printComplexity(map[RiskLevel, int] complexity) {
	println("unit complexity:");
	println(" * simple: <complexity[Simple()]>%");
	println(" * moderate: <complexity[Moderate()]>%");
	println(" * high: <complexity[High()]>%");
	println(" * very high: <complexity[VeryHigh()]>%");
	println();
	println("unit complexity score: <unitComplexityRating(complexity)>");
}

// just some diagnostics
public void printComplexityDiagnosticData(loc project) {
	lrel[str, Statement] methodStatements = getProjectMethodsStatements(project);

	for ( <name, implementation> <- methodStatements) {
		int complexity = cyclomaticComplexity(implementation);
		println("CC: <complexity> - Method: <name> - Source: (<implementation.src>)");
 	}
} 