module Visualization::Graph

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


public void visualiseGraph() {
	visualiseGraph(|project://smallsql0.21_src|, "smallsql");
}

private void visualiseGraph(loc project, str projectName) {
	Metrics metrics = importProjectMetrics(project, projectName);
	
	bool openTree (int _, map[KeyModifier,bool] _) { 
		render("tree", box(text("tree")));
		return true;
	}
	
	rows = [ 
		ellipse(ellipse(text("Volume: --\n<metrics.projectLineCount>")), top(), left(), fillColor("red"), size(150), resizable(false), onMouseDown(openTree)),
     	ellipse(ellipse(text("Unit size: --")), top(), right(), fillColor("red"), size(150), resizable(false), onMouseDown(openTree)),
 		ellipse(ellipse(text("Unit \ncomplexity: -")), bottom(), right(), fillColor("orange"), size(150), resizable(false), onMouseDown(openTree)),
     	ellipse(ellipse(text("Duplication: -\n11.81%")), bottom(), left(), fillColor("orange"), size(150), resizable(false), onMouseDown(openTree))
 	];
 	composedGraph = overlay(
 		[
 			overlay(rows, shapeConnected(true), shapeClosed(true)), 
 			ellipse(ellipse(text("overall \nmaintainability: -")), fillColor("orange"), center(), size(200), resizable(false))
		], 
 		size(450), resizable(false));
 	
	render(projectName, composedGraph);
}