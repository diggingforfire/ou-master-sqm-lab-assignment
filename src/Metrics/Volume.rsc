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

/*
* Count of lines of code for project without empty lines and comments
*/
public int lineCount(loc project) {
	return size(linesOfCode(project));
}

/*
* Lines of code for project without empty lines and comments
*/
private list[str] linesOfCode(loc project)
{
	M3 model = createM3FromEclipseProject(project);
	list[str] codeFiles = [ readFile(fileLocation) | fileLocation <- files(model) ];
	return [ line | 
		codeFile <- codeFiles, 
		line <- split("\n", filterComments(codeFile)), 
		!isEmptyOrWhiteSpaceLine(line)
	];
}