module Exporter

import lang::json::IO;
import List;
import lang::java::m3::AST;
import IO;
import util::Math;

import Metrics::Volume;
import Metrics::Complexity;
import Metrics::Duplication;
import Metrics::Scores;
import Metrics::Maintainability;
import Metrics::Coverage;
import Utils::MethodUtils;

data MethodsByFile = file(str path, num metricValue, list[MetricsByMethod] methods);
data MetricsByMethod = method(loc location, num metricValue);
data RankingAndMetric = rankingAndMetric(str ranking, str metricValue);
 
data Metrics = metrics(
	str overallMaintainability, 
	RankingAndMetric volume, 
	str unitSizeRanking, 
	RankingAndMetric cyclomaticComplexity, 
	RankingAndMetric duplication,
	set[MethodsByFile] lineCountByFile, 
	set[MethodsByFile] complexityPerFile,
	set[MethodsByFile] duplicationPerFile
);

public void exportProjects() {
	exportProjectMetrics(|project://smallsql0.21_src/|, "smallsql");
	exportProjectMetrics(|project://hsqldb/|, "hsqldb");
}

public void exportProjectMetrics(loc project, str projectName) {
	int projectLineCount = getLineCount(project);
	int projectCyclomaticComplexity = getCyclomaticComplexity(project);
	
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
	
	list[Statement] methods = getProjectMethodsStatements(project);
	
	map[RiskLevel, tuple[int cyclomaticComplexityPercentage, int unitSizeComplexityPercentage]] maintainability = unitMaintainability(projectLineCount, methods);
	map[RiskLevel, int] complexity = (risk:maintainability[risk].cyclomaticComplexityPercentage | risk <- maintainability);
	
	num duplicationDensity = duplicationDensityForProject(project, projectLineCount);
	
	tuple[int covered, int total] coverage = getMethodCoverage(project, projectName);
	num CoveragePercentage = testCoveragePercentage(coverage.covered, coverage.total);
	
	Ranking coverageRanking = getCoverageRanking(CoveragePercentage);
	Ranking volumeRanking = getVolumeRanking(projectLineCount);
	Ranking unitSizeRanking = getMaintainabilityRanking((risk:maintainability[risk].unitSizeComplexityPercentage | risk <- maintainability));
	Ranking unitComplexityRanking = getMaintainabilityRanking(complexity);
	Ranking duplicationRanking = getDuplicationRanking(duplicationDensity);
	
	analysabilityScore = averageRanking([volumeRanking, duplicationRanking, unitSizeRanking, coverageRanking]); 
	changabilityScore = averageRanking([unitComplexityRanking, duplicationRanking]);
	stabilityScore = averageRanking([coverageRanking]); 
	testabilityScore = averageRanking([unitComplexityRanking, unitSizeRanking, coverageRanking]); 
	
	Metrics export = metrics(
		rankingAsString(averageRanking([analysabilityScore, changabilityScore, testabilityScore, stabilityScore])),
		rankingAndMetric(rankingAsString(volumeRanking), toString(projectLineCount)),
		rankingAsString(unitSizeRanking), 
		rankingAndMetric(rankingAsString(unitComplexityRanking), toString(projectCyclomaticComplexity)), 
		rankingAndMetric(rankingAsString(duplicationRanking), toString(round(duplicationDensity, 0.01))),
		methodLineCountPerFileMetrics, 
		methodComplexityPerFileMetrics,
		methodDuplicationPerFileMetrics
		);
		
	writeJSON(|project://ou-master-sqm-lab-assignment/<projectName>_metrics.json|, export, unpackedLocations = true);
	println("<projectName> exported");
}
