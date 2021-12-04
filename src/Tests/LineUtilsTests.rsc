module Tests::LineUtilsTests

import Utils::LineUtils;

//isEmptyOrWhiteSpaceLine tests

public test bool isEmptyOrWhiteSpaceLine_EmptyString() {
	return isEmptyOrWhiteSpaceLine("");
}

public test bool isEmptyOrWhiteSpaceLine_OnlySpaces() {
	return isEmptyOrWhiteSpaceLine("   ");
}

public test bool isEmptyOrWhiteSpaceLine_OnlyTabs() {
	return isEmptyOrWhiteSpaceLine("\t\t\t");
}

public test bool isEmptyOrWhiteSpaceLine_OnlyNewLines() {
	return isEmptyOrWhiteSpaceLine("\n");
}

// filterComments tests

public test bool filterComments_No_Comment() {
	return filterComments("Foo();") == "Foo();";
}

public test bool filterComments_SingleLineComment() {
	return filterComments("// hi") == "";
}

public test bool filterComments_SingleLineComment_On_Multiple_Lines() {
	// currently fails
	return filterComments("// hi\n// hi") == "";
}

public test bool filterComments_SingleLineComment_Space_Prefix() {
	return filterComments(" // hi") == " "; //
}

public test bool filterComments_SingleLineComment_Non_Space_Prefix() {
	return filterComments("Foo(); // hi") == "Foo(); ";
}

public test bool filterComments_SingleLineComment_In_String() {
	// currently fails
	return filterComments("Foo(\"//not a comment\"") == "Foo(\"//not a comment\"";
}

// code block tests

public test bool concatenateToCodeBlocks_givenEightLines_createsThreeCodeBlocks() {
	linesOfCode = ["1", "2", "3", "4", "5", "6", "7", "8"];

	codeBlocks = concatenateToCodeBlocks(linesOfCode);
	return codeBlocks == ["345678", "234567", "123456"];
}