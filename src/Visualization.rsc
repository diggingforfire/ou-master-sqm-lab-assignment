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
private int itemGroupCount = 5;

private map[MethodsByFile methods, int expansions] fileExpansionCount = ();
private map[str path, int expansions] methodExpansionCount = ();
private map[str path, bool expanded] fileExpandedStates = ();

public void Visualise() {
	Visualise(|project://smallsql0.21_src|, "smallsql");
}

private void Visualise(loc project, str projectName) {
	Metrics metrics = importProjectMetrics(project, projectName);
	
	//rowsCyclomaticComplexity = [text("<regularBullet> <projectName> (cyclomatic complexity: <metrics.projectCyclomaticComplexity>)", left(), font("Consolas"), fontSize(8))];
	//rowsCyclomaticComplexity += generateRows(project, metrics.complexityPerFile);
	
	//rowslineCount = [text("<regularBullet> <projectName> (line count: <metrics.projectLineCount>)", left(), font("Consolas"), fontSize(8))];
	//rowslineCount += generateRows(project, metrics.lineCountByFile);
	
	render(projectName, computeFigure(Figure() { return indentedTree(project, projectName, metrics.complexityPerFile, "Cyclomatic complexity", metrics.projectCyclomaticComplexity); }  ));
}

private str getExpandCollapseSign(str path) {
	return isExpanded(path) ? "-" : "+";
}

private bool isExpanded(str path) {
	return (path notin fileExpandedStates) ? false : fileExpandedStates[path];
}

private Figure indentedTree(loc project, str projectName, set[MethodsByFile] metric, str projectLevelMetricLabel, num projectLevelMetric) {
	list[Figure] rows = [text("<regularBullet> <projectName> (<projectLevelMetricLabel>: <projectLevelMetric>)", left(), font("Consolas"), fontSize(8))];;
	lrel[Statement, str] methodStatements = getProjectMethodsStatementsWithName(project);
 		
	bool sortFileByMetricValue(MethodsByFile a, MethodsByFile b){ return a.metricValue > b.metricValue; }
	bool sortMethodByMetricValue(MetricsByMethod a, MetricsByMethod b){ return a.metricValue > b.metricValue; }

	for (metricForFile <- take(3, sort(metric, sortFileByMetricValue))) {
		println(methodExpansionCount);
		
		tmpPath = metricForFile.path; // prevent closure capturing binding to variable instead of value
		textFigure = text(" <tmpPath> (<metricForFile.metricValue>)",  font("Consolas"), fontSize(8), onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) { edit(project + tmpPath); return true;} ));
 		expandSign = text("  <getExpandCollapseSign(tmpPath)>", font("Consolas"), fontSize(8), onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) { 
 		
 			if (tmpPath notin fileExpandedStates) {
				fileExpandedStates += (tmpPath: false);
			}
				
			fileExpandedStates[tmpPath] = !fileExpandedStates[tmpPath];
 			return true;
 		} ));
 		
 		rows += [hcat([expandSign, textFigure], std(left()), resizable(false))];
 		
 		if (isExpanded(tmpPath)) {
	 		int methodCount = (tmpPath in methodExpansionCount) ? methodExpansionCount[tmpPath] * itemGroupCount : itemGroupCount;
	 		for (method <- take(methodCount, sort(metricForFile.methods, sortMethodByMetricValue))) {		
	 			loc editableLocation = convertToEditableLocation(method.location);
	 			
	 			methodNames = [ methodName | <methodStatement, methodName> <- methodStatements, methodStatement.src == editableLocation];
	 			
	 			if(isEmpty(methodNames)) {
	 				println("No methods found for <method>, error in export?");
	 				continue;
	 			}
	 			
	 			rows += [text("    <whiteBullet> <methodNames[0]> (<method.metricValue>)", left(), font("Consolas"), fontSize(8), onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) { edit(editableLocation); return true;} ))];	
			}
			
			int methodsRemaining = size(metricForFile.methods) - methodCount;		
			if (methodsRemaining > 0) {
				showMoreMethodsText = text("      Show <itemGroupCount> more (<methodsRemaining> remaining)", fontBold(true), fontItalic(true), left(), fontColor("Peru"), font("Consolas"), fontSize(8), onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) { 
				
					if (tmpPath notin methodExpansionCount) {
						methodExpansionCount += (tmpPath: 1);
					}
					
					methodExpansionCount[tmpPath] = methodExpansionCount[tmpPath] + 1;
					return true;
				} ));
				
				rows += [showMoreMethodsText];
			}
 		}	
	} 
	
	return vcat(rows, vgap(5), halign(0.1), vresizable(false), std(top()));
}