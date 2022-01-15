module Importer

import lang::json::IO;
import Exporter;

public Metrics importProjectMetrics(str projectName) {
	return readJSON(#Metrics, |project://ou-master-sqm-lab-assignment/<projectName>_metrics.json|);
}
