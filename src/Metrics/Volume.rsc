module Metrics::Volume

import IO;
import String;
import List;
import Set;
import String;
import util::Math;

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import analysis::m3::Core;

import Utils::LineUtils;
import Utils::MethodUtils;
import Metrics::Scores;

/*
* Count of lines of code for project without empty lines and comments
*/
public int getLineCount(loc project) {
	return size(linesOfCode(project));
}

/*
* Count of lines of code for file without empty lines and comments
*/
public int getLineCount(str file) {
	return size(linesOfCode([file]));
}

/*
* Count of lines of code per file for all project methods without empty lines and comments
*/
public map[str path, map[loc location, int lineCount] methods] getMethodLineCountPerFile(loc project) {
	map[str path, map[loc location, int lineCount] methods] methodLineCountPerFile = ();
	
	list[Statement] methodStatements = getProjectMethodsStatements(project);
	
	for (methodStatement <- methodStatements) {
		str sourceText = readFile(methodStatement.src);
 		int lineCountMethod = getLineCount(sourceText);
 		
 		if (methodStatement.src.path notin methodLineCountPerFile) {
 			methodLineCountPerFile[methodStatement.src.path] = ();
 		}
 		
	 	methodLineCountPerFile[methodStatement.src.path][methodStatement.src] = lineCountMethod;
	}
	
	return methodLineCountPerFile;
}

/*
* Lines of code for project without empty lines and comments
*/
private list[str] linesOfCode(loc project) {
	M3 model = createM3FromEclipseProject(project);
	list[str] codeFiles = [ readFile(fileLocation) | fileLocation <- files(model) ];
	return linesOfCode(codeFiles);
}

private list[str] linesOfCode(list[str] codeFiles) {
	return [ line | 
		codeFile <- codeFiles, 
		line <- split("\n", filterComments(codeFile)), 
		!isEmptyOrWhiteSpaceLine(line)
	];
}

public Ranking getVolumeRanking(int lineCount) {
	if(lineCount <= 66000) return Highest();
	if(lineCount <= 246000) return Ranking::High();
	if(lineCount <= 665000) return Medium();
	if(lineCount <= 1310000) return Low();
	return Lowest();
}