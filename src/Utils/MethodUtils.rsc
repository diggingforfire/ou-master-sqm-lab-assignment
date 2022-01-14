module Utils::MethodUtils

import Metrics::Volume;
import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import analysis::m3::Core;
import ValueIO;
import String;

public list[Statement] getProjectMethodsStatements(loc project) {
 	set[Declaration] declarations = getProjectMethodDeclarations(project);
	return [ statement | <statement, _> <- getMethodStatements(declarations)];
}

public lrel[Statement, str] getProjectMethodsStatementsWithName(loc project) {
 	set[Declaration] declarations = getProjectMethodDeclarations(project);
	return getMethodStatements(declarations);
}

public loc convertToEditableLocation(loc location) {
	return readTextValueString(#loc, replaceFirst("<location>", "file", "java+compilationUnit"));
}

private set[Declaration] getProjectMethodDeclarations(loc project) {
	M3 model = createM3FromEclipseProject(project);
 	set[loc] projectFiles = { file | file <- files(model) } ;
 	set[Declaration] declarations = createAstsFromFiles(projectFiles, false);
 	return declarations;
}
 
private lrel[Statement, str] getMethodStatements(set[Declaration] declarations) {
 	lrel[Statement, str] result = [];
 	
 	visit(declarations) {
 		case \method(_, name, _, _, implementation): result += <implementation, name>;
 		case \constructor(name, _, _, implementation): result += <implementation, name>;
	}
	
 	return result;
}