module Metrics

import IO;
import Metrics::Volume;

public void analyseProjects()
{
	println("smallsql\n----");
	printLinesOfCode(|project://smallsql0.21_src/|);
	println("hsqldb\n----");
	printLinesOfCode(|project://hsqldb/|);
}