module Metrics::Duplication

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
* returns the number of duplicated lines for a project
*/
public int numberOfDuplicatedLinesForProject(loc project) {
	map[str, int] mappedLines = findDuplicates(sanitizedLinesOfCodePerFile(project));
	return sum([mappedLines[line] | line <- mappedLines]);
}

private list[list[str]] sanitizedLinesOfCodePerFile(loc project) {
	return [
		[
			trim(line) | 
				line <- split("\n", filterComments(readFile(fileLocation))), 
				!isEmptyOrWhiteSpaceLine(line)
		] | fileLocation <- files(createM3FromEclipseProject(project))
	];
}

/*
* takes lines of code per file and returns the number of duplicates per code block
*/
public map[str, int] findDuplicates(list[list[str]] linesOfCodePerFile) {	
	map[str, int] mappedLines = ();
	for (linesOfCode <- linesOfCodePerFile)
	for (codeBlock <- concatenateToCodeBlocks(linesOfCode))
	{
		if(codeBlock in mappedLines)
		{
			if(mappedLines[codeBlock] == 0)
			{
				// first found duplication should count both lines
				mappedLines[codeBlock] += 2; 
			}
			else
			{
				// all successive duplicates  
				mappedLines[codeBlock] += 1;
			}
		}
		else
		{
			// first occurence, no duplicates yet
			mappedLines += (codeBlock: 0);
		}
	}
	return mappedLines;
}