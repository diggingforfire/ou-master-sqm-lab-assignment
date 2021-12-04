module Analyser

import IO;
import Metrics::Volume;
import Metrics::Complexity;
import lang::java::m3::AST;

public void analyseProjects() {

	loc smallsql = |project://smallsql0.21_src/|;
	
	int projectLineCount = lineCount(smallsql);
	println("smallsql\n----");
	println("lines of code: <projectLineCount>");
	
	map[RiskLevel, int] complexity = unitComplexity(smallsql, projectLineCount);
	printComplexity(complexity);
	
	
	loc hsqldb = |project://hsqldb/|;
	println("hsqldb\n----");
	projectLineCount = lineCount(hsqldb);
	println("lines of code: <projectLineCount>");
	
	complexity = unitComplexity(hsqldb, projectLineCount);
	printComplexity(complexity);
 
	
	//printComplexityyData(smallsql);
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