module Tests::DuplicationTests

import List;

import Metrics::Duplication;

public test bool findDuplicates_givenOneUniqueBlock_givesNoDuplicates() {
	linesOfCode = [["1", "2", "3", "4", "5", "6"]];
	mappedLines = findDuplicates(linesOfCode);
	return sum([mappedLines[line] | line <- mappedLines]) == 0;
}

public test bool findDuplicates_givenTwoDuplicateBlocks_givesTwoDuplicates() {
	linesOfCode = [["1", "2", "3", "4", "5", "6", "Some other code", "1", "2", "3", "4", "5", "6"]];
	mappedLines = findDuplicates(linesOfCode);
	return sum([mappedLines[line] | line <- mappedLines]) == 2;
}

public test bool findDuplicates_givenThreeDuplicateBlocks_givesThreeDuplicates() {
	linesOfCode = [["1", "2", "3", "4", "5", "6", "Some other code", "1", "2", "3", "4", "5", "6", "1", "2", "3", "4", "5", "6"]];
	mappedLines = findDuplicates(linesOfCode);
	return sum([mappedLines[line] | line <- mappedLines]) == 3;
}

public test bool findDuplicates_givenTwoDuplicateBlocksInSeperateFiles_givesTwoDuplicates() {
	linesOfCode = [
		["1", "2", "3", "4", "5", "6", "Some other code"], 
		["Some other code", "1", "2", "3", "4", "5", "6"]
	];
	mappedLines = findDuplicates(linesOfCode);
	return sum([mappedLines[line] | line <- mappedLines]) == 2;
}

public test bool findDuplicates_givenTwoDuplicateBlocksOfLenght5InSeperateFiles_givesNoDuplicates() {
	linesOfCode = [
		["1", "2", "3", "4", "5", "Some other code"], 
		["Some other code", "1", "2", "3", "4", "5"]
	];
	mappedLines = findDuplicates(linesOfCode);
	return sum([mappedLines[line] | line <- mappedLines]) == 0;
}

public test bool findDuplicates_givenThreeDuplicateBlocksOfLenght5InSeperateFiles_givesThreeDuplicates() {
	linesOfCode = [
		["1", "2", "3", "4", "5", "6", "Some other code"], 
		["Some other code", "1", "2", "3", "4", "5", "6"],
		["1", "2", "3", "4", "5", "6"],
		["Some other code", "a", "b", "c", "d", "e", "Some other code"]
	];
	mappedLines = findDuplicates(linesOfCode);
	return sum([mappedLines[line] | line <- mappedLines]) == 3;
}