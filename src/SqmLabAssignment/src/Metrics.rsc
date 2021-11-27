module Metrics

import IO;
import Metrics::Volume;

public void analyseProjects()
{
	println("smallsql\n----");
	printLinesOfCode(|project://smallsql/|);
	println("hsqldb\n----");
	printLinesOfCode(|project://hsqldb/|);
}