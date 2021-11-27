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

private str filterComments(str file){
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
private bool isEmptyLine(str line){
	return line == "" || /^\s+$/ := line;
}

private int linesOfCode(loc project)
{
	M3 model = createM3FromEclipseProject(project);
	list[str] codeFiles = [ readFile(fileLocation) | fileLocation <- files(model) ];
	list[str] linesOfCode = [ line | 
		codeFile <- codeFiles, 
		line <- split("\n", filterComments(codeFile)), 
		!isEmptyLine(line)
	];

	return size(linesOfCode);
}

public void printLinesOfCode(loc project)
{
	print("lines of code: ");
	println(linesOfCode(project));
}