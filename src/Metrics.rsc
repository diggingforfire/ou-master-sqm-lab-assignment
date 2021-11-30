module Metrics

import IO;
import Metrics::Volume;

public void analyseProjects()
{
	println("smallsql\n----");
	printNumberOfLinesOfCode(|project://smallsql0.21_src/|);
	println("hsqldb\n----");
	printNumberOfLinesOfCode(|project://hsqldb/|);
}