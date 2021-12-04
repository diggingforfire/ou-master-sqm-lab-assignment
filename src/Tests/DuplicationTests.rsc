module Tests::DuplicationTests

import IO;

import Metrics::Duplication;

public test bool concatenateToCodeBlocks_givenEightLines_createsThreeCodeBlocks() {
	linesOfCode = ["1", "2", "3", "4", "5", "6", "7", "8"];

	codeBlocks = concatenateToCodeBlocks(linesOfCode);
	println(codeBlocks);
	return codeBlocks == ["345678", "234567", "123456"];
}