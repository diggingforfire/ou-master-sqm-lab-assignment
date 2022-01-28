module Visualisation::Graph

import String;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import util::Editors;
import Importer;
import Exporter;
import Visualisation::IndentedTree;

public void visualiseGraphs() {
	visualiseGraph(|project://smallsql0.21_src|, "smallsql");
	visualiseGraph(|project://hsqldb|, "org.hsqldb");
}

private void visualiseGraph(loc project, str projectName) {
	Metrics metrics = importProjectMetrics(projectName);
	
	rows = [ 
		ellipse(
			ellipse(text("Volume: <metrics.volume.ranking>\n<metrics.volume.metricValue>")), 
			top(), left(), fillColor(rankingAsColor(metrics.volume.ranking)), size(150), resizable(false), 
 			onMouseDown(bool (_, _) { 
 				render("<projectName> volume", visualiseTree(project, projectName, "Volume", metrics.lineCountByFile, toInt(metrics.volume.metricValue))); 
			})
		),
     	ellipse(
     		ellipse(text("Unit size: <metrics.unitSizeRanking>")), 
     		top(), right(), fillColor(rankingAsColor(metrics.unitSizeRanking)), size(150), resizable(false), 
 			onMouseDown(bool (_, _) { 
 				render("<projectName> volume", visualiseTree(project, projectName, "Volume", metrics.lineCountByFile, toInt(metrics.volume.metricValue))); 
			})
 		),
 		ellipse(ellipse(text("Unit \ncomplexity: <metrics.cyclomaticComplexity.ranking>")), 
 			bottom(), right(), fillColor(rankingAsColor(metrics.cyclomaticComplexity.ranking)), size(150), resizable(false), 
 			onMouseDown(bool (_, _) { 
 				render("<projectName> complexity", visualiseTree(project, projectName, "Cyclomatic complexity", metrics.complexityPerFile, toInt(metrics.cyclomaticComplexity.metricValue))); 
			})
		),
     	ellipse(
     		ellipse(text("Duplication: <metrics.duplication.ranking>\n<metrics.duplication.metricValue>%")), 
     		bottom(), left(), fillColor(rankingAsColor(metrics.duplication.ranking)), size(150), resizable(false), 
 			onMouseDown(bool (_, _) { 
 				render("<projectName> duplication (%)", visualiseTree(project, projectName, "Duplication (%)", metrics.duplicationPerFile, toReal(metrics.duplication.metricValue))); 
			})
 		)
 	];
 	composedGraph = overlay(
 		[
 			overlay(rows, shapeConnected(true), shapeClosed(true)), 
 			ellipse(
 				ellipse(text("overall \nmaintainability: <metrics.overallMaintainability>")), 
 				center(), fillColor(rankingAsColor(metrics.overallMaintainability)), size(200), resizable(false)
			)
		], 
 		size(450), resizable(false)
	);
 	
	render(projectName, composedGraph);
}

private str rankingAsColor(str ranking) {
	visit(ranking) {
		case "--": return "red";
		case "-": return "orange";
		case "o": return "yellow";
		case "+": return "yellowgreen";
		case "++": return "green";
	}
	throw "unknown ranking <ranking>";
}