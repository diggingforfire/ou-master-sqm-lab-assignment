module Metrics::Coverage

import Metrics::Complexity;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import IO;
import List;
import Set;
import String;
import util::ShellExec;

/*
 * Method coverage expessed as <coveredMethodCount, totalMethodCount>
 */
public tuple[int, int] getMethodCoverage(loc project) {

	M3 model = createM3FromEclipseProject(project);
	set[loc] allMethods = methods(model);
	
	// 1. Add instrumentation to the project source files
	addInstrumentationToMethods(project, allMethods);

	// 2. Run the project unit tests
	exec("C:\\Dev\\ou-master-sqm-lab-assignment\\src\\Utils\\run_unit_tests.bat", workingDir=|tmp:///|);
 
	// 3. Interpret the results 
	set[str] coveredMethods = toSet([ line | 
		line <- readFileLines(|file:///C:/Dev/ou-master-sqm-lab-assignment/src/Utils/result.txt|), /^smallsql.+\.java:\d+\)$/ := line]);
	
	int coveredMethodCount = size(coveredMethods);
	int totalMethodCount = size(allMethods);
	
	return <coveredMethodCount, totalMethodCount>;
}

private void addInstrumentationToMethods(loc project, set[loc] allMethods) {
	for (loc l <- allMethods) {
		str source = readFile(l);
		source = getInstrumentedMethod(source);
		writeFile(l, source);
	}
}

/*
 * get the instrumented method source
 * instrumentation is injected at the start of the method
 */
public str getInstrumentedMethod(str source) {
	return visit (source) {
			case /\{/ => "{ System.out.println(new Throwable().getStackTrace()[0]);"
		}
}