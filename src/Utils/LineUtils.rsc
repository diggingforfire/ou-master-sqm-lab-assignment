module Utils::LineUtils

import List;

/*
* empty string or start with (^) space, tab or linebreak (\s) till the end ($) of the string
*/
public bool isEmptyOrWhiteSpaceLine(str line) {
	return line == "" || /^\s+$/ := line;
}

public str filterComments(str file) {
	return visit(file) {
		/*
		Select part that starts with
		Followed by 0 or more *
		And ends with * and /
		including linebreaks or newlines using sinle-line mode (/s)
		*/
		case /\/\*.*?\*\//s => ""
		/*
		* matches the character / followed by another / followed by as many / mathes it can find (greedy) 
		*/
		case /\/\/.*/ => ""
	}
}

public int codeBlockSize = 6;

/*
* Concatenates lines of code in blocks of {codeBlockSize}
* blocks overlap each other
*/
public lrel[str codeblock, int offset] concatenateToCodeBlocks(list[str] linesOfCode) {
	lrel[str codeblock, int offset] codeBlocks = [];
	if(size(linesOfCode) < 6) {
		return codeBlocks;
	}
	
	int offset = size(linesOfCode) - codeBlockSize;
	for(end <- [size(linesOfCode) .. 5]) {
		str codeBlock = "";
		for(int i <- [offset .. end]) {
			codeBlock += linesOfCode[i];
		}
		
		codeBlocks+= <codeBlock, offset>;
		
		offset -= 1;
	}
	return codeBlocks;
}