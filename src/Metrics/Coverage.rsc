module Metrics::Coverage

import Metrics::Complexity;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import List;
import String;
import util::ShellExec;

public void methodCoverage(loc project) {

	// 1. Add instrumentation to the project source files
	addInstrumentation(project);
	
	// 2. Run the project run unit tests
	exec("C:\\Dev\\ou-master-sqm-lab-assignment\\src\\Utils\\run_unit_tests.bat");
	
	// 3. Interpret the results 
	set[str] coveredMethods = toSet([ line | 
		line <- readFileLines(|file:///C:/Dev/ou-master-sqm-lab-assignment/src/Utils/result.txt|), startsWith(line, "smallsql")]);
	
	for (line <- coveredMethods) {
		println(line);
	}
}

private void addInstrumentation(loc project) {
	// add instrumentation to methods for method coverage	
	// add instrumentation to branching paths for branch coverage
}

 