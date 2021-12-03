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
public int numberOfDuplicatesForProject(loc project) {
	map[str, int] codeBlocksAndNumberOfOccurrences = FindDuplicates(project);
	
	int numberOfDuplicates = 0;
	for(codeBlock <- codeBlocksAndNumberOfOccurrences) {
		numberOfDuplicates += codeBlocksAndNumberOfOccurrences[codeBlock];
	}
	
	return numberOfDuplicates;
}

int numberOfConsecutiveDuplicateLines = 6;

private map[str, int] FindDuplicates(loc project)
{
	rel[loc, list[str]] sanitizedLinesOfCodePerLocation =	
	{ 
		<fileLocation, [trim(line) | 
			line <- split("\n", filterComments(readFile(fileLocation))), 
			!isEmptyOrWhiteSpaceLine(line)
		]> | fileLocation <- files(createM3FromEclipseProject(project))
	};
	
	map[str, int] mappedLines = ();
	for (<filelocation, linesOfCode> <- sanitizedLinesOfCodePerLocation)
	{
		int end = size(linesOfCode);
		int begin = max(0, end - numberOfConsecutiveDuplicateLines);
		
		while(begin != 0)
		{
			str codeBlock = "";
			for(int i <- [begin .. end])
			{
				codeBlock += linesOfCode[i];
			}
			if(sixLines in mappedLines)
			{
				mappedLines[codeBlock] += 1;
			}
			else
			{
				mappedLines += (codeBlock: 0);
			}
			end = max(0, end - numberOfConsecutiveDuplicateLines);
			begin = max(0, end - numberOfConsecutiveDuplicateLines);
		}
	}
	
	return mappedLines;
}