module Metrics::Coverage

import Metrics::Complexity;
import lang::java::m3::Core;
import lang::java::jdt::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import IO;
import List;
import Set;
import String;
import ParseTree;
import lang::java::\syntax::Java15;
import Type;

/*
 * Method coverage expessed as <coveredMethodCount, totalMethodCount>
 */
public tuple[int, int] getMethodCoverage(loc project, str projectName) {

	M3 model = createM3FromEclipseProject(project);

	if (!exists(|file://C:/Dev/ou-master-sqm-lab-assignment/<projectName>_coverage.txt|)) {
	
		// 1. Add instrumentation to the project source files
		addInstrumentationToProject(model);
	
		// 2. Run the project unit tests
		exec("C:\\Dev\\ou-master-sqm-lab-assignment\\run_unit_tests_<projectName>.bat", workingDir=|home:///|);	
		println("testS");
	} else {
	
		// 3. Interpret the results 
		set[str] coveredMethods = toSet([ line | 
			line <- readFileLines(|file://C:/Dev/ou-master-sqm-lab-assignment/<projectName>_coverage.txt|), /^<projectName>.+\.java:\d+\)$/ := line]);
		
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

		println("Instrumenting <projectFile.path>");
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