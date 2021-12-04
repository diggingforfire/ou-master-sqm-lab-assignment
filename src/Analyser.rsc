module Analyser

import IO;
import util::Math;

import Metrics::Volume;
import Metrics::Duplication;

public void analyseProjects()
{
	println("smallsql\n----");
	analyseProject(|project://smallsql0.21_src/|);

	println("hsqldb\n----");
	analyseProject(|project://hsqldb/|);
}

private void analyseProject(loc project)
{
	numberOfLinesOfCode = lineCount(project);
	println("lines of code: <numberOfLinesOfCode>");
	duplicatedDensity = duplicatedLinesDensity(numberOfLinesOfCode, numberOfDuplicatedLinesForProject(project));
	println("duplication: <round(duplicatedDensity, 0.01)>%");
}

private real duplicatedLinesDensity(int numberOfLinesOfCode, int numberOfDuplicatedLines)
{
	return toReal(numberOfDuplicatedLines) / toReal(numberOfLinesOfCode) * 100;
}