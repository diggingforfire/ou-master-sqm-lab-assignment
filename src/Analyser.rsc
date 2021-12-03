module Analyser

import IO;
import Metrics::Volume;
import Metrics::Duplication;

public void analyseProjects()
{
	loc project = |project://smallsql0.21_src/|;
	println("smallsql\n----");
	
	//println("lines of code: <lineCount(project)>");
	println("duplication: <codeDuplicationPercentage(project)>");

	project = |project://hsqldb/|;
	println("hsqldb\n----");
	//println("lines of code: <lineCount(project)>");
	println("duplication: <codeDuplicationPercentage(project)>");
}