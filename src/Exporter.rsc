module Exporter

import lang::json::IO;
import IO;
import Metrics::Coverage;
import Metrics::Volume;

public void exportProjects() {
	exportProjectMetrics(|project://smallsql0.21_src/|, "smallsql");
}

public void exportProjectMetrics(loc project, str projectName) {
	map[str, map[str, value]] metrics = ();
	
 	metrics["complexity"] = getComplexityMetrics(project);
 	metrics["duplication"] = getDuplicationMetrics(project);
	metrics["volume"] = getVolumeMetrics(project);

	writeJSON(|project://ou-master-sqm-lab-assignment/<projectName>_metrics.json|, metrics, unpackedLocations = true);
}

private map[str, value] getComplexityMetrics(loc project) {
	map[str, value] complexityMetrics = ();
	
	complexityMetrics["projectCyclomaticComplexity"] = 100;
	
	return complexityMetrics;
}

private map[str, value] getDuplicationMetrics(loc project) {
	map[str, value] duplicationMetrics = ();
	
	duplicationMetrics["projectDuplication"] = 100;
	
	return duplicationMetrics;
}

private map[str, value] getVolumeMetrics(loc project) {
	map[str, value] volumeMetrics = ();
	
	projectLineCount = getLineCount(project);
	volumeMetrics["projectLineCount"] = projectLineCount;
	
	map[str path, map[loc location, int lineCount] methods] methodLineCountPerFile = getMethodLineCountPerFile(project);
	volumeMetrics["files"] = toList(methodLineCountPerFile); // a list (toList) yields an array in json, a map yields an object
	
	return volumeMetrics;
}
