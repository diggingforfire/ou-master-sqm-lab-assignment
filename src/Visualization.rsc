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

public void Visualise(){
	Metrics metrics = importProjectMetrics(|project://smallsql0.21_src/|, "smallsql");
	
	list[Figure] figures = [];
			
	int maxValue = max({toInt(x.metricValue) | x <- metrics.lineCountByFile});
	num segmentSize = maxValue / 4;
	
	for (lineCountForFile <- metrics.lineCountByFile){
		int boxSize = 200;
		str boxColor = "Red";
		
		int segment = toInt(lineCountForFile.metricValue / segmentSize);
		
		if(segment < 1){
			continue;
		}
		else if(segment < 2){
			boxSize = 100;
			boxColor = "yellow";
		}
		else if(segment < 3){
			boxSize = 150;
			boxColor = "Orange";
		}
		
		figures += box(
			text("<lineCountForFile.path>\nnumber of lines: <lineCountForFile.metricValue>"), 
			size(boxSize, boxSize), 
			fillColor(boxColor)
			);
	}
	
	figures += box(
			text("Modules that have less than <segmentSize> lines of code"), 
			size(50, 50), 
			fillColor("Green")
			);
	
	render(pack(figures, std(gap(10))));
}

public void tree() {
	Metrics metrics = importProjectMetrics(|project://smallsql0.21_src|, "smallsql");
	lrel[Statement, str] methodStatements = getProjectMethodsStatementsWithName(|project://smallsql0.21_src|);
	rows = [text("\u2022 smallsql (<metrics.projectCyclomaticComplexity>)", left(), font("Consolas"), fontSize(8))];
 		
	for (lineCountForFile <- metrics.lineCountByFile) {
		tmpPath = lineCountForFile.path; // prevent closure capturing binding to variable instead of value
		textFigure = text("  \u2022 <tmpPath> (<lineCountForFile.metricValue>)", left(), font("Consolas"), fontSize(8), mouseOver(text("hi")), onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) { edit(|project://smallsql0.21_src/<tmpPath>|); return true;} ));
 		rows += [textFigure];
 		
 		for (method <- lineCountForFile.methods) {		
 			loc editableLocation = convertToEditableLocation(method.location);
 
 			methodName = [ methodName | <methodStatement, methodName> <- methodStatements, methodStatement.src == editableLocation][0];
 			rows += [text("    \u25E6 <methodName> (<method.metricValue>)", left(), font("Consolas"), fontSize(8), onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) { edit(editableLocation); return true;} ))];	
		}
	} 
	
	render(vcat(rows, vgap(5)));
}