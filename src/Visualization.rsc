module Visualization

import analysis::graphs::Graph;
import Relation;
import vis::Figure;
import vis::Render;
import List;
import ListRelation;
import Set;
import util::Math;
import IO;
import vis::KeySym;
import Importer;
import Exporter;
import util::Editors;
import lang::java::m3::Core;
import lang::java::m3::AST;
import String;
import Utils::MethodUtils;
import ValueIO;

private str regularBullet = "\u2022";
private str whiteBullet = "\u25E6";

public void Visualise() {
	Visualise(|project://smallsql0.21_src|, "smallsql");
}

private void Visualise(loc project, str projectName) {
	Metrics metrics = importProjectMetrics(project, projectName);
	
	rowsCyclomaticComplexity = [text("<regularBullet> <projectName> (cyclomatic complexity: <metrics.projectCyclomaticComplexity>)", left(), font("Consolas"), fontSize(8))];
	rowsCyclomaticComplexity += generateRows(project, metrics.complexityPerFile);
	
	rowslineCount = [text("<regularBullet> <projectName> (line count: <metrics.projectLineCount>)", left(), font("Consolas"), fontSize(8))];
	rowslineCount += generateRows(project, metrics.lineCountByFile);
	
	render(projectName, hcat([
		vcat(rowsCyclomaticComplexity, vgap(5), halign(0.1)),
		vcat(rowslineCount, vgap(5), halign(0.6))
		]));
}

private list[Figure] generateRows(loc project, set[MethodsByFile] metric) {
	list[Figure] rows = [];
	lrel[Statement, str] methodStatements = getProjectMethodsStatementsWithName(project);
 		
	bool sortFileByMetricValue(MethodsByFile a, MethodsByFile b){ return a.metricValue > b.metricValue; }
	bool sortMethodByMetricValue(MetricsByMethod a, MetricsByMethod b){ return a.metricValue > b.metricValue; }
	
	for (metricForFile <- sort(metric, sortFileByMetricValue)) {
		tmpPath = metricForFile.path; // prevent closure capturing binding to variable instead of value
		textFigure = text("  <regularBullet> <tmpPath> (<metricForFile.metricValue>)", left(), font("Consolas"), fontSize(8), onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) { edit(project + tmpPath); return true;} ));
 		rows += [textFigure];
 		
 		for (method <- sort(metricForFile.methods, sortMethodByMetricValue)) {		
 			loc editableLocation = convertToEditableLocation(method.location);
 			
 			methodNames = [ methodName | <methodStatement, methodName> <- methodStatements, methodStatement.src == editableLocation];
 			
 			if(isEmpty(methodNames)) {
 				println("No methods found for <method>, error in export?");
 				continue;
 			}
 			
 			rows += [text("    <whiteBullet> <methodNames[0]> (<method.metricValue>)", left(), font("Consolas"), fontSize(8), onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) { edit(editableLocation); return true;} ))];	
		}
	} 
	
	return rows;
}