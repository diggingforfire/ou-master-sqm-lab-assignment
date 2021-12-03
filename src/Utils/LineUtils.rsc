module Utils::LineUtils

/*
* empty string or start with (^) space, tab or linebreak (\s) till the end ($) of the string
*/
public bool isEmptyOrWhiteSpaceLine(str line){
	return line == "" || /^\s+$/ := line;
}