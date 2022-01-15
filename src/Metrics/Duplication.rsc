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

import Metrics::Scores;
import Utils::LineUtils;

/*
* returns the number of duplicated lines for a project
*/
public num duplicationDensityForProject(loc project, num numberOfLinesOfCode) {
	return duplicatedLinesDensity(
		numberOfLinesOfCode,
		sum([lineCount | <_, lineCount> <- numberOfDuplicatedLinesPerFile(sanitizedLinesOfCodePerFile(project))])
		);
}

private num duplicatedLinesDensity(num numberOfLinesOfCode, num numberOfDuplicatedLines) {
	return (numberOfDuplicatedLines / numberOfLinesOfCode) * 100;
}

public rel[str path, int lineCount] numberOfDuplicatedLinesPerFile(loc project) {
	return numberOfDuplicatedLinesPerFile(sanitizedLinesOfCodePerFile(project));
}

public rel[str path, int lineCount] numberOfDuplicatedLinesPerFile(lrel[loc, list[str]] linesOfCodePerFile) {
	map[str, rel[loc location, int offset]] occurrencesPerFile = mapOccurrencesPerFile(linesOfCodePerFile);
	
	rel[loc location, int offset] duplicates = {
		locationAndOffsets |
			codeBlock <- occurrencesPerFile,
			size(occurrencesPerFile[codeBlock]) > 1,
			locationAndOffsets <- occurrencesPerFile[codeBlock]			
	};	
	
	return numberOfDuplicatedLinesPerFile(mapDuplicatesPerFile(duplicates));
}

private lrel[loc, list[str]] sanitizedLinesOfCodePerFile(loc project) {
	return [
		<fileLocation, [
			trim(line) | 
				line <- split("\n", filterComments(readFile(fileLocation))), 
				!isEmptyOrWhiteSpaceLine(line)
		]> | fileLocation <- files(createM3FromEclipseProject(project))
	];
}

private map[str, rel[loc location, int offset]] mapOccurrencesPerFile(lrel[loc, list[str]] linesOfCodePerFile) {
	map[str, rel[loc location, int offset]] occurrencesPerFile = ();
	for (<fileLocation, linesOfCode> <- linesOfCodePerFile)
	for (<str codeBlock, int offset> <- concatenateToCodeBlocks(linesOfCode)) {
		if(codeBlock in occurrencesPerFile) {
			occurrencesPerFile[codeBlock] += {<fileLocation, offset>};
		}
		else {
			occurrencesPerFile += (codeBlock: {<fileLocation, offset>});
		}
	}
	return occurrencesPerFile;
}

private map[loc location, set[int] offsets] mapDuplicatesPerFile(rel[loc location, int offset] duplicates) {
	map[loc location, set[int] offsets] duplicatesPerFile = ();
	for (<location, offset> <- duplicates) {
		if(location in duplicatesPerFile) {
			duplicatesPerFile[location] += {offset};
		}
		else {
			duplicatesPerFile += (location: {offset});
		}
	}
	return duplicatesPerFile;
}

private rel[str path, int lineCount] numberOfDuplicatedLinesPerFile(map[loc location, set[int] offsets] duplicatesPerFile)
{
	rel[str path, int metricValue] perFile = {};
	for (loc file <- duplicatesPerFile) {
	    int numberOfDuplicates = 0;
		list[int] offsetsForFile = sort(duplicatesPerFile[file]);
		for (int i <- [0..size(offsetsForFile)]) {
			int offset = offsetsForFile[i];
			if(i + 1 < size(offsetsForFile)) {
				int nextOffset = offsetsForFile[i + 1];
				numberOfDuplicates += min(nextOffset - offset, codeBlockSize);
			}
			else {
				numberOfDuplicates += codeBlockSize;
			}
		}
		perFile += <file.path, numberOfDuplicates>;
	}
	return perFile;
}

public Ranking getDuplicationRanking(num density) {
	if(density <= 3) return Highest();
	if(density <= 5) return High();
	if(density <= 10) return Medium();
	if(density <= 20) return Low();
	return Lowest();
}