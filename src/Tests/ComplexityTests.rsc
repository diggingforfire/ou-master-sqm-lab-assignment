module Tests::ComplexityTests

import lang::java::m3::AST;
import List;

import Metrics::Complexity;
import Utils::MethodUtils;

public test bool cyclomaticComplexity_IfThen() {
	implementation = getMethodImplementation(|java+compilationUnit:///src/smallsql/database/Logger.java|, "println");
	return getCyclomaticComplexity(implementation) == 2;
}

public test bool cyclomaticComplexity_IfThenElse() {
	implementation = getMethodImplementation(|java+compilationUnit:///src/smallsql/database/Scrollable.java|, "relative");
	return getCyclomaticComplexity(implementation) == 2;
}

public test bool cyclomaticComplexity_ForWithIncrement() {
	implementation = getMethodImplementation(|java+compilationUnit:///src/smallsql/database/Columns.java|, "copy");
	return getCyclomaticComplexity(implementation) == 2;
}

public test bool cyclomaticComplexity_Do() {
	implementation = getMethodImplementation(|java+compilationUnit:///src/smallsql/database/Where.java|, "next");
	return getCyclomaticComplexity(implementation) == 5;
}

public test bool cyclomaticComplexity_While() {
	implementation = getMethodImplementation(|java+compilationUnit:///src/smallsql/database/CommandDelete.java|, "executeImpl");
	return getCyclomaticComplexity(implementation) == 2;
}

public test bool cyclomaticComplexity_Case() {
	implementation = getMethodImplementation(|java+compilationUnit:///src/smallsql/database/JoinScrollIndex.java|, "next");
	return getCyclomaticComplexity(implementation) == 2;
}

public test bool cyclomaticComplexity_Case_Multiple() {
	implementation = getMethodImplementation(|java+compilationUnit:///src/smallsql/database/ExpressionFunctionConvert.java|, "getPrecision");
	// currently fails, counts empty cases
	return getCyclomaticComplexity(implementation) == 2;
}

public test bool cyclomaticComplexity_Catch() {
	implementation = getMethodImplementation(|java+compilationUnit:///src/smallsql/database/SSDatabaseMetaData.java|, "getCrossReference");
	return getCyclomaticComplexity(implementation) == 2;
}

public test bool cyclomaticComplexity_LogicalOr() {
	implementation = getMethodImplementation(|java+compilationUnit:///src/smallsql/database/MemoryResult.java|, "isBeforeFirst");
	return getCyclomaticComplexity(implementation) == 2;
}

public test bool cyclomaticComplexity_LogicalAnd() {
	implementation = getMethodImplementation(|java+compilationUnit:///src/smallsql/database/MemoryResult.java|, "isFirst");
	return getCyclomaticComplexity(implementation) == 2;
}

public test bool cyclomaticComplexity_Conditional() {
	implementation = getMethodImplementation(|java+compilationUnit:///src/smallsql/database/StoreImpl.java|, "writeBoolean");
	return getCyclomaticComplexity(implementation) == 3;
}

// can't handle overloads (yet)
private Statement getMethodImplementation(loc file, str method) {
	lrel[Statement, str] ast = getProjectMethodsStatementsWithName(file);
	return top([ impl | <impl, name> <- ast, name == method ]);
}