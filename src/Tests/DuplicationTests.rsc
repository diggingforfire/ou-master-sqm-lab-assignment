module Tests::DuplicationTests

import IO;

import Metrics::Duplication;

loc fooLoc = |project://fooLoc/|;
public test bool findDuplicates_givenOneUniqueBlock_givesNoDuplicates() {
	
	linesOfCode = [<fooLoc,["1", "2", "3", "4", "5", "6"]>];
	return numberOfDuplicatedLines(linesOfCode) == 0;
}

public test bool findDuplicates_givenTwoDuplicateBlocks_givesTwelveDuplicates() {
	linesOfCode = [<fooLoc,["1", "2", "3", "4", "5", "6", "Some other code", "1", "2", "3", "4", "5", "6"]>];
	println("expected: 12, actual<numberOfDuplicatedLines(linesOfCode)>");
	return numberOfDuplicatedLines(linesOfCode) == 12;
}

public test bool findDuplicates_givenThreeDuplicateBlocks_givesEighteenDuplicates() {
	linesOfCode = [<fooLoc,["1", "2", "3", "4", "5", "6", "Some other code", "1", "2", "3", "4", "5", "6", "1", "2", "3", "4", "5", "6"]>];
	println("expected: 18, actual<numberOfDuplicatedLines(linesOfCode)>");
	return numberOfDuplicatedLines(linesOfCode) == 18;
}

public test bool findDuplicates_givenTwoDuplicateBlocksInSeperateFiles_givesTwelveDuplicates() {
	linesOfCode = [
		<fooLoc,["1", "2", "3", "4", "5", "6", "Some other code"]>, 
		<|project://fooLoc2/|,["Some other code", "1", "2", "3", "4", "5", "6"]>
	];
	println("expected: 12, actual<numberOfDuplicatedLines(linesOfCode)>");
	return numberOfDuplicatedLines(linesOfCode) == 12;
}

public test bool findDuplicates_givenTwoDuplicateBlocksOfLenght5InSeperateFiles_givesNoDuplicates() {
	linesOfCode = [
		<fooLoc,["1", "2", "3", "4", "5", "Some other code"]>, 
		<fooLoc,["Some other code", "1", "2", "3", "4", "5"]>
	];
	return numberOfDuplicatedLines(linesOfCode) == 0;
}

public test bool findDuplicates_givenThreeDuplicateBlocksOfLenght5InSeperateFiles_givesEighteenDuplicates() {
	linesOfCode = [
		<fooLoc,["1", "2", "3", "4", "5", "6", "Some other code"]>, 
		<|project://fooLoc2/|,["Some other code", "1", "2", "3", "4", "5", "6"]>,
		<|project://fooLoc3/|,["1", "2", "3", "4", "5", "6"]>,
		<|project://fooLoc4/|,["Some other code", "a", "b", "c", "d", "e", "Some other code"]>
	];
	println("expected: 18, actual<numberOfDuplicatedLines(linesOfCode)>");
	return numberOfDuplicatedLines(linesOfCode) == 18;
}