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


public void Visualise() {
	Visualise(|project://smallsql0.21_src|, "smallsql");
}

private void Visualise(loc project, str projectName) {
	Metrics metrics = importProjectMetrics(project, projectName);
	
	rowsCyclomaticComplexity = [text("\u2022 <projectName> (cyclomatic complexity: <metrics.projectCyclomaticComplexity>)", left(), font("Consolas"), fontSize(8))];
	rowsCyclomaticComplexity += GenerateRows(project, metrics.complexityPerFile);
	
	rowslineCount = [text("\u2022 <projectName> (line count: <metrics.projectLineCount>)", left(), font("Consolas"), fontSize(8))];
	rowslineCount += GenerateRows(project, metrics.lineCountByFile);
	
	render(projectName, hcat([
		vcat(rowsCyclomaticComplexity, vgap(5), halign(0.1)),
		vcat(rowslineCount, vgap(5), halign(0.6))
		]));
}

private list[Figure] GenerateRows(loc project, set[MethodsByFile] metric) {
	list[Figure] rows = [];
	lrel[Statement, str] methodStatements = getProjectMethodsStatementsWithName(project);
 		
	bool sortFileByMetricValue(MethodsByFile a, MethodsByFile b){ return a.metricValue > b.metricValue; }
	bool sortMethodByMetricValue(MetricsByMethod a, MetricsByMethod b){ return a.metricValue > b.metricValue; }
	for (lineCountForFile <- sort(metric, sortFileByMetricValue)) {
		tmpPath = lineCountForFile.path; // prevent closure capturing binding to variable instead of value
		textFigure = text("  \u2022 <tmpPath> (<lineCountForFile.metricValue>)", left(), font("Consolas"), fontSize(8), mouseOver(text("hi")), onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) { edit(|project://smallsql0.21_src/<tmpPath>|); return true;} ));
 		rows += [textFigure];
 		
 		for (method <- sort(lineCountForFile.methods, sortMethodByMetricValue)) {		
 			loc editableLocation = convertToEditableLocation(method.location);
 			
 			methodNames = [ methodName | <methodStatement, methodName> <- methodStatements, methodStatement.src == editableLocation];
 			if(isEmpty(methodNames)) {
 				continue;
 			}
 			
 			rows += [text("    \u25E6 <methodNames[0]> (<method.metricValue>)", left(), font("Consolas"), fontSize(8), onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) { edit(editableLocation); return true;} ))];	
		}
	} 
	
	return rows;
}