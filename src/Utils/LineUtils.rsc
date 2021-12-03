module Utils::LineUtils

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