module Metrics::Coverage

import Metrics::Complexity;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import IO;
import List;
import String;
import util::ShellExec;

public void methodCoverage(loc project) {

	// 1. Add instrumentation to the project source files
	addInstrumentationToMethods(project);

	// 2. Run the project unit tests
	exec("C:\\Dev\\ou-master-sqm-lab-assignment\\src\\Utils\\run_unit_tests.bat", workingDir=|tmp:///|);
 
	// 3. Interpret the results 
	 set[str] coveredMethods = toSet([ line | 
		line <- readFileLines(|file:///C:/Dev/ou-master-sqm-lab-assignment/src/Utils/result.txt|), startsWith(line, "smallsql")]);
	
	for (line <- coveredMethods) {
		println(line);
	} 
}

private void addInstrumentationToMethods(loc project) {
	M3 model = createM3FromEclipseProject(project);
	
	for (loc l <- methods(model), contains(l.path, "createStatement")) {
		println(l.path);
		str source = readFile(l);
		source = getInstrumentedMethod(source);
		writeFile(l, source);
	}
}

private str getInstrumentedMethod(str source) {
	return visit (source) {
			case /\{/ => "{ System.out.println(new Throwable().getStackTrace()[0]);"
		}
}