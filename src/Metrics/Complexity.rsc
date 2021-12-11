module Metrics::Complexity

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;

import Metrics::Maintainability;

/*
 * Cyclomatic complexity for a single unit (method)
 */
public int getCyclomaticComplexity(Statement implementation) {
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

public RiskLevel getRiskLevelCyclomaticComplexity(Statement implementation) {
	int cyclomaticComplexity = getCyclomaticComplexity(implementation);

	if (cyclomaticComplexity > 50) return VeryHigh();
	if (cyclomaticComplexity >= 21) return High();
	if (cyclomaticComplexity >= 11) return Moderate();
 	
 	return Simple();
 }