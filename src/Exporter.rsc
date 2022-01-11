module Exporter

import lang::json::IO;
import IO;
import Metrics::Volume;
import Metrics::Complexity;
import Metrics::Duplication;
import Map;
import List;

data MethodsByFile = file(str path, num metricValue, list[MetricsByMethod] methods);
data MetricsByMethod = method(loc location, num metricValue);
 
data Metrics = metrics(
	int projectLineCount, 
	int projectCyclomaticComplexity, 
	int projectDuplicatedLinesCount, 
	set[MethodsByFile] lineCountByFile, 
	set[MethodsByFile] complexityPerFile,
	set[MethodsByFile] duplicationPerFile);

public void exportProjects() {
	exportProjectMetrics(|project://smallsql0.21_src/|, "smallsql");
}

public void exportProjectMetrics(loc project, str projectName) {
	int projectLineCount = getLineCount(project);
	int projectCyclomaticComplexity = getCyclomaticComplexity(project);
	int projectDuplicatedLinesCount = numberOfDuplicatedLinesForProject(project);
	
	map[str path, map[loc location, int lineCount] methods] methodLineCountPerFile = getMethodLineCountPerFile(project);
	map[str path, map[loc location, int cyclomaticComplexity] methods] complexityPerFile = getCyclomaticComplexityPerFile(project);
	rel[str path, int lineCount] duplicatesPerFile = numberOfDuplicatedLinesPerFile(project);
	
	methodLineCountPerFileMetrics = { file(
		path, 
		sum([ methodLineCountPerFile[path][location] | location <- methodLineCountPerFile[path] ]),
		[ method(location, methodLineCountPerFile[path][location]) | location <- methodLineCountPerFile[path]]) | path <- methodLineCountPerFile};
		
	methodComplexityPerFileMetrics = { file(
		path, 
		sum([ complexityPerFile[path][location] | location <- complexityPerFile[path] ]),
		[ method(location, complexityPerFile[path][location]) | location <- complexityPerFile[path]]) | path <- complexityPerFile};
		
	methodDuplicationPerFileMetrics = { file(path, lineCount, []) | <path, lineCount> <- duplicatesPerFile};
	

	Metrics export = metrics(
		projectLineCount, 
		projectCyclomaticComplexity, 
		projectDuplicatedLinesCount, 
		methodLineCountPerFileMetrics, 
		methodComplexityPerFileMetrics,
		methodDuplicationPerFileMetrics
		);
		
	writeJSON(|project://ou-master-sqm-lab-assignment/<projectName>_metrics.json|, export, unpackedLocations = true);
}
