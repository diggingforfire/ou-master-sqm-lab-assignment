module Utils::MethodUtils

import Metrics::Volume;
import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import analysis::m3::Core;

public list[Statement] getProjectMethodsStatements(loc project) {
	M3 model = createM3FromEclipseProject(project);
 	set[loc] projectFiles = { file | file <- files(model) } ;
 	set[Declaration] declarations = createAstsFromFiles(projectFiles, false);
	return getMethodStatements(declarations);
}
 
private list[Statement] getMethodStatements(set[Declaration] declarations) {
 	list[Statement] result = [];
 	
 	visit(declarations) {
 		case \method(_, _, _, _, implementation): result += implementation;
 		case \constructor(_, _, _, implementation): result += implementation;
	}
	
 	return result;
}