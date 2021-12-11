module Metrics::Coverage

import Metrics::Complexity;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import List;
import String;
import util::ShellExec;

public void methodCoverage(loc project) {

	addInstrumentation(project);
	str runUnitTestsCommand = "C:\\Dev\\smallsql0.21_src\\run_unit_tests.bat";
	PID unitTestsProcess = createProcess(runUnitTestsCommand);
	str response = readEntireStream(unitTestsProcess);
	killProcess(unitTestsProcess);
	
	// interpret results 
}

private void addInstrumentation(loc project) {
	// add instrumentation to methods for method coverage	
	// add instrumentation to branching paths for branch coverage
}