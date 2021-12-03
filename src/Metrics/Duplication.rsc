module Metrics::Duplication

import IO;
import String;
import List;
import Map;
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
public int codeDuplicationPercentage(loc project) {
	tuple[rel[loc, list[str]] codeFiles, map[str, rel[loc, int]] mappedLines] normalized = linesOfCode(project);
	
	int totalNumberOfDuplicates = 0;
	for(line <- normalized.mappedLines) {
		rel[loc, int] occurrences = normalized.mappedLines[line];
		int numberOfDuplicates = size(occurrences) - 1;
		totalNumberOfDuplicates += numberOfDuplicates;
		//if(numberOfDuplicates > 0)
		//{		
		//	//println("number of duplicates:");
		//	//println(numberOfDuplicates);
		//	//println(line);
		//}
	}
	return totalNumberOfDuplicates;
}

/*
* Lines of code for project without empty lines
*/
private tuple[rel[loc, list[str]] codeFiles, map[str, rel[loc, int]] mappedLines] linesOfCode(loc project)
{
	M3 model = createM3FromEclipseProject(project);
	map[str, rel[loc, int]] mappedLines = ();
	
	rel[loc, list[str]] codeFiles =	{ 
		<fileLocation, [line | line <- readFileLines(fileLocation), !isEmptyOrWhiteSpaceLine(line)]> | 
		fileLocation <- files(model) 
	};
	for(<fileLocation, fileLines> <- codeFiles)
	{
		for(int lineNumber <- [0..size(fileLines)])
		{
			str line = fileLines[lineNumber]; 
			
			if(line in mappedLines)
			{
				mappedLines[line] += {<fileLocation, lineNumber>};
			}
			else
			{
				mappedLines += (line: {<fileLocation, lineNumber>});
			}
		}
	}
	return <codeFiles, mappedLines>;
}