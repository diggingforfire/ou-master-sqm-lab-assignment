module Utils::LineUtils

import List;

/*
* empty string or start with (^) space, tab or linebreak (\s) till the end ($) of the string
*/
public bool isEmptyOrWhiteSpaceLine(str line){
	return line == "" || /^\s+$/ := line;
}

public str filterComments(str file){
	return visit(file){
		/*
		Select part that starts with
		Followed by 0 or more *
		And ends with * and /
		including linebreaks or newlines using sinle-line mode (/s)
		*/
		case /\/\*.*?\*\//s => ""
		/*
		* empty string or starts with (^) space, tab or line break (\s) till the end ($)
		*/
		case /\/\/.*/ => ""
	}
}

int codeBlockSize = 6;

/*
* Concatenates lines of code in blocks of {codeBlockSize}
* blocks overlap each other
*/
public list[str] concatenateToCodeBlocks(list[str] linesOfCode)
{
	list[str] codeBlocks = [];
	if(size(linesOfCode) < 6) 
	{
		return codeBlocks;
	}
	
	int begin = size(linesOfCode) - codeBlockSize;
	for(end <- [size(linesOfCode) .. 5])
	{
		str codeBlock = "";
		for(int i <- [begin .. end])
		{
			codeBlock += linesOfCode[i];
		}
		
		codeBlocks+= codeBlock;
		
		begin -= 1;
	}
	return codeBlocks;
}