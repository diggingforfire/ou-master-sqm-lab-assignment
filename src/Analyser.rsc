module Analyser

import IO;
import Metrics::Volume;

public void analyseProjects()
{
	println("smallsql\n----");
	println("lines of code: <lineCount(|project://smallsql0.21_src/|)>");

	println("hsqldb\n----");
	println("lines of code: <lineCount(|project://hsqldb/|)>");
}