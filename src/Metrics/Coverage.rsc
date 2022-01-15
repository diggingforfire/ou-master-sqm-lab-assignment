module Metrics::Coverage

import Metrics::Complexity;
import Metrics::Scores;
import lang::java::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::Core;
import lang::java::jdt::m3::Core;
import lang::java::\syntax::Java15;
import IO;
import List;
import Set;
import String;
import ParseTree;
import Type;

/*
 * Method coverage expessed as <coveredMethodCount, totalMethodCount>
 */
public tuple[int covered, int total] getMethodCoverage(loc project, str projectName) {

	M3 model = createM3FromEclipseProject(project);

	loc coverageResultFile = |project://ou-master-sqm-lab-assignment/<projectName>_coverage.txt|;
	if (!exists(coverageResultFile)) {
	
		// 1. Add instrumentation to the project source files
		addInstrumentationToProject(model);
	
		// 2. Run the project unit tests
		exec("C:\\Dev\\ou-master-sqm-lab-assignment\\run_unit_tests_<projectName>.bat", workingDir=|home:///|);	
		println("testS");
	} else {
	
		// 3. Interpret the results 
		set[str] coveredMethods = toSet([ line | 
			line <- readFileLines(coverageResultFile), /^<projectName>.+\.java:\d+\)$/ := line]);
		
		set[loc] allMethods = methods(model);
			
		int coveredMethodCount = size(coveredMethods);
		int totalMethodCount = size(allMethods);
		return <coveredMethodCount, totalMethodCount>;
	}
	
	return <0, 0>;
}

private void addInstrumentationToProject(M3 model) {
 	set[loc] projectFiles = { file | file <- files(model)} ;
 	
 	for (projectFile <- projectFiles) {
 		try CompilationUnit compilationUnit = parse(#CompilationUnit, projectFile); catch: { println("Could not parse <projectFile.path>"); continue; }

		newCompilationUnit = visit(compilationUnit) { 
 			case (MethodBody) `{<BlockStm* post>}` 
 				=> (MethodBody) `{
 				'System.out.println(new Throwable().getStackTrace()[0]);
 				'<BlockStm* post>
 				'}`
		}
				
		writeFile(projectFile, newCompilationUnit);
 	}
}

public Ranking getCoverageRanking(num percentage) {
	if(percentage < 20) return Lowest();
	if(percentage < 60) return Low();
	if(percentage < 80) return Medium();
	if(percentage < 95) return High();
	return Highest();
}

public num testCoveragePercentage(num coveredMethods, num allMethods) {
	return (coveredMethods / allMethods) * 100;
}