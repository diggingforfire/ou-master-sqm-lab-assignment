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

/*
* Count of lines of code for project without empty lines and comments
*/
public int lineCount(loc project) {
	return size(linesOfCode(project));
}

/*
* Count of lines of code for file without empty lines and comments
*/
public int lineCount(str file) {
	return size(linesOfCode([file]));
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

public str filterComments(str file){
	return visit(file){
		/*
		Select part that starts with
		Followed by 0 or more *
		And ends with * and /
		including linebreaks or newlines using sinle-line mode (/s)
		*/
		case /\/\*.*?\*\//s => ""
		/*
		* empty string or starts with (^) space, tab or line break (\s) till the end ($)
		*/
		case /\/\/.*/ => ""
	}
}

/*
* empty string or start with (^) space, tab or linebreak (\s) till the end ($) of the string
*/
public bool isEmptyOrWhiteSpaceLine(str line){
	return line == "" || /^\s+$/ := line;
}