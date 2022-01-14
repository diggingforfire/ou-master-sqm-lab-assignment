module Visualization

import List;
import ListRelation;
import Set;
import util::Math;
import IO;
import Importer;
import Exporter;
import util::Editors;
import lang::java::m3::Core;
import lang::java::m3::AST;
import Metrics::Complexity;
import Metrics::Scores;
import String;
import Utils::MethodUtils;
import ValueIO;
import vis::Figure;
import vis::KeySym;
import vis::Render;
import Metrics::Scores;

private str regularBullet = "\u2022";
private str openBullet = "\u25E6";
private int itemGroupCount = 5;

private int fileExpansionCount = 1;
private map[str path, int expansions] methodExpansionCount = ();
private map[str path, bool expanded] fileExpandedStates = ();

public void Visualise() {
	Visualise(|project://smallsql0.21_src|, "smallsql");
}

private void Visualise(loc project, str projectName) {
	Metrics metrics = importProjectMetrics(project, projectName);
	
	//rowsCyclomaticComplexity = [text("<regularBullet> <projectName> (cyclomatic complexity: <metrics.projectCyclomaticComplexity>)", left(), font("Consolas"), fontSize(9))];
	//rowsCyclomaticComplexity += generateRows(project, metrics.complexityPerFile);
	
	//rowslineCount = [text("<regularBullet> <projectName> (line count: <metrics.projectLineCount>)", left(), font("Consolas"), fontSize(9))];
	//rowslineCount += generateRows(project, metrics.lineCountByFile);
	
	render(projectName, computeFigure(Figure() { return indentedTree(project, projectName, metrics.complexityPerFile, "Cyclomatic complexity", metrics.projectCyclomaticComplexity); }  ));
}

private str getExpandCollapseSign(str path) {
	return isExpanded(path) ? "-" : "+";
}

private bool isExpanded(str path) {
	return (path notin fileExpandedStates) ? false : fileExpandedStates[path];
}

private Figure getExpandSignFigure(str path) {
	expandClicked = onMouseDown(bool (_, _) { 
		collapseOrExpand(path);
		return true;
	} );
	
	return text("  <getExpandCollapseSign(path)>", font("Consolas"), fontSize(9), expandClicked);
}

private void collapseOrExpand(str path) {
	if (path notin fileExpandedStates) fileExpandedStates += (path: false);
	fileExpandedStates[path] = !fileExpandedStates[path];
}

private Figure getPathFigure(loc project, str path, num metricValue) {
	pathClicked = onMouseDown(bool (_, _) { edit(project + path); return true; });
	return text(" <path> (<metricValue>)", font("Consolas"), fontSize(9), pathClicked);
}

private Figure getMethodFigure(str methodName, num metricValue, loc location) {
	methodClicked = onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) { edit(location); return true;} );
	return text(" <methodName> (<metricValue>)", left(), font("Consolas"), fontSize(9), methodClicked);
}

private Figure getMethodBulletFigure(int cyclomaticComplexity) {
	return text("    <regularBullet>", left(), font("Consolas"), fontSize(9), fontColor(getColorForCyclomaticComplexity(cyclomaticComplexity)));
}

private Figure getShowMoreMethodsFigure(str path, int methodsRemaining) {
	methodClicked = onMouseDown(bool (_, _) { 	
		if (path notin methodExpansionCount) methodExpansionCount += (path: 1);
		methodExpansionCount[path] = methodExpansionCount[path] + 1;
		return true;
	} );
	
	return text("      Show <itemGroupCount> more methods (<methodsRemaining> remaining)", fontBold(true), fontItalic(true), left(), fontColor("Peru"), font("Consolas"), fontSize(9), methodClicked);
}

private Figure getShowMoreFilesFigure(int filesRemaining) {
	fileClicked = onMouseDown(bool (_, _) {
		fileExpansionCount = fileExpansionCount + 1;
		return true;
	});
	
	return text("    Show <itemGroupCount> more files (<filesRemaining> remaining)", fontBold(true), fontItalic(true), left(), fontColor("Peru"), font("Consolas"), fontSize(9), fileClicked);
}

private str getColorForCyclomaticComplexity(int cyclomaticComplexity) {
	RiskLevel riskLevel = getRiskLevelCyclomaticComplexity(cyclomaticComplexity);
	if (riskLevel == VeryHigh()) return "red";
	if (riskLevel == High()) return "orange";
	if (riskLevel == Moderate()) return "yellow";
	return "green";
}

private Figure indentedTree(loc project, str projectName, set[MethodsByFile] metric, str projectLevelMetricLabel, num projectLevelMetric) {
	list[Figure] rows = [text("<regularBullet> <projectName> (<projectLevelMetricLabel>: <projectLevelMetric>)", left(), font("Consolas"), fontSize(9))];;
	lrel[Statement, str] methodStatements = getProjectMethodsStatementsWithName(project);
 		
	bool sortFileByMetricValue(MethodsByFile a, MethodsByFile b) { return a.metricValue > b.metricValue; }
	bool sortMethodByMetricValue(MetricsByMethod a, MetricsByMethod b) { return a.metricValue > b.metricValue; }

	int showFileCount = fileExpansionCount * itemGroupCount;
	list[MethodsByFile] files = take(showFileCount, sort(metric, sortFileByMetricValue));
	
	// expand the first file by default
	if (files[0].path notin fileExpandedStates) fileExpandedStates += (files[0].path: true);
	
	for (metricForFile <- files) {	
		// prevent closure capturing binding to variable instead of value
		tmpPath = metricForFile.path; 
		
		expandSignFigure = getExpandSignFigure(tmpPath);
		pathFigure = getPathFigure(project, tmpPath, metricForFile.metricValue);
 		rows += [hcat([expandSignFigure, pathFigure], std(left()), resizable(false))];
 		
 		if (isExpanded(tmpPath)) {
	 		int showMethodCount = (tmpPath in methodExpansionCount) ? methodExpansionCount[tmpPath] * itemGroupCount : itemGroupCount;
	 		
	 		for (method <- take(showMethodCount, sort(metricForFile.methods, sortMethodByMetricValue))) {		
	 			loc editableLocation = convertToEditableLocation(method.location); 			
	 			methodNames = [ methodName | <methodStatement, methodName> <- methodStatements, methodStatement.src == editableLocation];
	 			
	 			if(isEmpty(methodNames)) {
	 				println("No methods found for <method>, error in export?");
	 				continue;
	 			}
	 			
	 			bulletFigure = getMethodBulletFigure(method.metricValue);
	 			methodFigure = getMethodFigure(methodNames[0], method.metricValue, editableLocation);
	 			
	 			rows += [hcat([bulletFigure, methodFigure], std(left()), resizable(false))];	
			}
			
			int methodsRemaining = size(metricForFile.methods) - showMethodCount;		
			if (methodsRemaining > 0) rows += [getShowMoreMethodsFigure(tmpPath, methodsRemaining)];		
 		}	
	}
	
	int filesRemaining = size(metric) - showFileCount;
	if (filesRemaining > 0)	rows += [getShowMoreFilesFigure(filesRemaining)];
		
	return vcat(rows, vgap(5), halign(0.1), vresizable(false), std(center()));
}