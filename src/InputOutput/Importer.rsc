module InputOutput::Importer

import lang::json::IO;
import InputOutput::Exporter;

public Metrics importProjectMetrics(str projectName) {
	return readJSON(#Metrics, |project://ou-master-sqm-lab-assignment/<projectName>_metrics.json|);
}
