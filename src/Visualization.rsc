module Visualization

import analysis::graphs::Graph;
import Relation;
import vis::Figure;
import vis::Render;
import List;
import Set;
import util::Math;
import IO;

import Importer;
import Exporter;

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