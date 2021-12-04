module Tests::ComplexityTests

import Metrics::Complexity;
import lang::java::m3::AST;
import List;

public test bool cyclomaticComplexity_IfThen() {
	implementation = getMethodImplementation(|java+compilationUnit:///src/smallsql/database/Logger.java|, "println");
	return cyclomaticComplexity(implementation) == 2;
}

public test bool cyclomaticComplexity_IfThenElse() {
	implementation = getMethodImplementation(|java+compilationUnit:///src/smallsql/database/Scrollable.java|, "relative");
	return cyclomaticComplexity(implementation) == 2;
}

public test bool cyclomaticComplexity_ForWithIncrement() {
	implementation = getMethodImplementation(|java+compilationUnit:///src/smallsql/database/Columns.java|, "copy");
	return cyclomaticComplexity(implementation) == 2;
}

public test bool cyclomaticComplexity_Do() {
	implementation = getMethodImplementation(|java+compilationUnit:///src/smallsql/database/Where.java|, "next");
	return cyclomaticComplexity(implementation) == 5;
}

public test bool cyclomaticComplexity_While() {
	implementation = getMethodImplementation(|java+compilationUnit:///src/smallsql/database/CommandDelete.java|, "executeImpl");
	return cyclomaticComplexity(implementation) == 2;
}

public test bool cyclomaticComplexity_Case() {
	implementation = getMethodImplementation(|java+compilationUnit:///src/smallsql/database/JoinScrollIndex.java|, "next");
	return cyclomaticComplexity(implementation) == 2;
}

public test bool cyclomaticComplexity_Case_Multiple() {
	implementation = getMethodImplementation(|java+compilationUnit:///src/smallsql/database/ExpressionFunctionConvert.java|, "getPrecision");
	// currently fails, counts empty cases
	return cyclomaticComplexity(implementation) == 2;
}

public test bool cyclomaticComplexity_Catch() {
	implementation = getMethodImplementation(|java+compilationUnit:///src/smallsql/database/SSDatabaseMetaData.java|, "getCrossReference");
	return cyclomaticComplexity(implementation) == 2;
}

public test bool cyclomaticComplexity_LogicalOr() {
	implementation = getMethodImplementation(|java+compilationUnit:///src/smallsql/database/MemoryResult.java|, "isBeforeFirst");
	return cyclomaticComplexity(implementation) == 2;
}

public test bool cyclomaticComplexity_LogicalAnd() {
	implementation = getMethodImplementation(|java+compilationUnit:///src/smallsql/database/MemoryResult.java|, "isFirst");
	return cyclomaticComplexity(implementation) == 2;
}

public test bool cyclomaticComplexity_Conditional() {
	implementation = getMethodImplementation(|java+compilationUnit:///src/smallsql/database/StoreImpl.java|, "writeBoolean");
	return cyclomaticComplexity(implementation) == 3;
}

// can't handle overloads (yet)
private Statement getMethodImplementation(loc file, str method) {
	lrel[str, Statement] ast = getFileMethodsASTs(file);
	return top([ impl | <name, impl> <- ast, name == method ]);
}