module Metrics::Complexity

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import analysis::m3::Core;
import util::Math;
import IO;

import Metrics::Volume;
import Utils::MethodUtils;

data RiskLevel = Simple() | Moderate() | High() | VeryHigh();

/*
 * Cyclomatic complexity for a single unit (method)
 */
public int cyclomaticComplexity(Statement implementation) {
	int cyclomaticComplexity = 1;
	
	visit(implementation) {
		/* statements */
		case \do(_,_):				cyclomaticComplexity += 1; // do-while loop						 
		case \foreach(_,_,_):		cyclomaticComplexity += 1; // for-each loop
		case \for(_,_,_):			cyclomaticComplexity += 1; // for-loop without incrementer
		case \for(_,_,_,_):			cyclomaticComplexity += 1; // for-loop with incrementer           
		case \if(_,_): 				cyclomaticComplexity += 1; // if-then                             
		case \if(_,_,_):			cyclomaticComplexity += 1; // if-then-else                         
		case \case(_):			    cyclomaticComplexity += 1; // switch-case                         
		case \catch(_,_):			cyclomaticComplexity += 1; // try-catch                            
		case \while(_,_):			cyclomaticComplexity += 1; // while-loop                          
		case \conditional(_,_,_):	cyclomaticComplexity += 1; // conditional '?' operator			 
		//case \defaultCase():		cyclomaticComplexity += 1; // treat as 'else'             
		//case \throw(_):			cyclomaticComplexity += 1; // already count +1 for catch                  
		
		/* expressions */
		case \infix(_,"||",_):		cyclomaticComplexity += 1; // logical or                          
		case \infix(_,"&&",_):		cyclomaticComplexity += 1; // logical and                          
	}
	
	return cyclomaticComplexity;
}

 /*
 * Unit complexity rating based on risk levels
 */
public str unitComplexityRating(map[RiskLevel, int] unitComplexity) {
	if (unitComplexity[VeryHigh()] == 0 && unitComplexity[High()] == 0 && unitComplexity[Moderate()] <= 25) return "++";
	if (unitComplexity[VeryHigh()] == 0 && unitComplexity[High()] <= 5 && unitComplexity[Moderate()] <= 30) return "+";
	if (unitComplexity[VeryHigh()] == 0 && unitComplexity[High()] <= 10 && unitComplexity[Moderate()] <= 40) return "+/-";
	if (unitComplexity[VeryHigh()] <= 5 && unitComplexity[High()] <= 15 && unitComplexity[Moderate()] <= 50) return "-";
	
	return "--";
}

/*
 * Relative unit complexity where risk level percentages indicate the amount of unic LOC that falls within that category
 */
public map[RiskLevel, int] unitComplexity(loc project, num projectLineCount) {

	lrel[str, Statement] methodStatements = getProjectMethodsStatements(project);
	
	map[RiskLevel, int] riskLevelLineCount = (Simple(): 0, Moderate(): 0, High(): 0, VeryHigh(): 0);
		
 	for ( <_, implementation> <- methodStatements) {
 		int complexity = cyclomaticComplexity(implementation);
 		RiskLevel risk = getRiskLevel(complexity);
		str sourceText = readFile(implementation.src);
		riskLevelLineCount[risk] += lineCount(sourceText);
 	}

 	return ( risk : floor((riskLevelLineCount[risk] / projectLineCount) * 100) | risk <- riskLevelLineCount);
}
 
private RiskLevel getRiskLevel(int cyclomaticComplexity) {
 	if (cyclomaticComplexity >= 1 && cyclomaticComplexity <= 10) return Simple();
 	if (cyclomaticComplexity >= 11 && cyclomaticComplexity <= 20) return Moderate();
 	if (cyclomaticComplexity >= 21 && cyclomaticComplexity <= 50) return High();
 	if (cyclomaticComplexity > 50) return VeryHigh();
 	
 	throw "Unknown cyclomatic complexity value: <cyclomaticComplexity>";
 }