module Utils::MethodUtils

import Metrics::Volume;
import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import analysis::m3::Core;

public lrel[str, Statement] getProjectMethodsStatements(loc project) {
	M3 model = createM3FromEclipseProject(project);
 	set[loc] projectFiles = { file | file <- files(model) } ;
 	set[Declaration] declarations = createAstsFromFiles(projectFiles, false);
	return getMethodStatements(declarations);
}
 
private lrel[str, Statement] getMethodStatements(set[Declaration] declarations) {
 	lrel[str, Statement] result = [];
 	
 	visit(declarations) {
 		case \method(_, name, _, _, implementation): result += <name, implementation>;
 		case \constructor(name, _, _, implementation): result += <name, implementation>;
	}
	
 	return result;
}