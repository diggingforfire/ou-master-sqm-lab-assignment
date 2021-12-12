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
	if(lineCount <= 66) return Highest();
	if(lineCount <= 246) return High();
	if(lineCount <= 665) return Medium();
	if(lineCount <= 1310) return Low();
	return Lowest();
}