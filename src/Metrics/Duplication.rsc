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
* 
*/
public int numberOfDuplicatesForProject(loc project) {
	map[str, int] mappedLines = findDuplicates(sanitizedLinesOfCodePerFile(project));
	return sum([mappedLines[line] | line <- mappedLines]);
}

private list[list[str]] sanitizedLinesOfCodePerFile(loc project)
{
	return [
		[
			trim(line) | 
				line <- split("\n", filterComments(readFile(fileLocation))), 
				!isEmptyOrWhiteSpaceLine(line)
		] | fileLocation <- files(createM3FromEclipseProject(project))
	];
}

public map[str, int] findDuplicates(list[list[str]] linesOfCodePerFile)
{	
	map[str, int] mappedLines = ();
	for (linesOfCode <- linesOfCodePerFile)
	for (codeBlock <- concatenateToCodeBlocks(linesOfCode))
	{
		if(codeBlock in mappedLines)
		{
			mappedLines[codeBlock] += 1;
		}
		else
		{
			mappedLines += (codeBlock: 0);
		}
	}
	return mappedLines;
}