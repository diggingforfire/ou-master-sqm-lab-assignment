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
	Metrics metrics = importProjectMetrics(|project://smallsql0.21_src|, "smallsql");
	lrel[Statement, str] methodStatements = getProjectMethodsStatementsWithName(|project://smallsql0.21_src|);
	rows = [text("\u2022 smallsql (<metrics.projectCyclomaticComplexity>)", left(), font("Consolas"), fontSize(8))];
 		
	bool sortFileByMetricValue(MethodsByFile a, MethodsByFile b){ return a.metricValue > b.metricValue; }
	bool sortMethodByMetricValue(MetricsByMethod a, MetricsByMethod b){ return a.metricValue > b.metricValue; }
	for (complexityForFile <- sort(metrics.complexityPerFile, sortFileByMetricValue)) {
		tmpPath = complexityForFile.path; // prevent closure capturing binding to variable instead of value
		textFigure = text("  \u2022 <tmpPath> (<complexityForFile.metricValue>)", left(), font("Consolas"), fontSize(8), onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) { edit(|project://smallsql0.21_src/<tmpPath>|); return true;} ));
 		rows += [textFigure];
 		
 		for (method <- sort(complexityForFile.methods, sortMethodByMetricValue)) {		
 			loc editableLocation = convertToEditableLocation(method.location);
 			
 			methodNames = [ methodName | <methodStatement, methodName> <- methodStatements, methodStatement.src == editableLocation];
 			if(isEmpty(methodNames)) {
 				continue;
 			}
 			
 			rows += [text("    \u25E6 <methodNames[0]> (<method.metricValue>)", left(), font("Consolas"), fontSize(8), onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) { edit(editableLocation); return true;} ))];	
		}
	} 
	
	render("smallsql", vcat(rows, vgap(5)));
}