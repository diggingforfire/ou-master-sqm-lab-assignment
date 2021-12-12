module Tests::CoverageTests

import Metrics::Coverage;

public test bool getInstrumentedMethod_NoBraces() {
	str noBraces = "System.out.println(\"Hello world\");";
	return getInstrumentedMethod(noBraces) == noBraces;
}

public test bool getInstrumentedMethod_MethodWithOneOpeningBrace() {
	str method = "protected Object clone() throws CloneNotSupportedException{
		return super.clone();
	}";
	
	str expected = "protected Object clone() throws CloneNotSupportedException{ System.out.println(new Throwable().getStackTrace()[0]);
		return super.clone();
	}";
	
	return getInstrumentedMethod(method) == expected;
}

public test bool getInstrumentedMethod_MethodWithMultipleOpeningBraces() {
	str method = "protected Object clone() throws CloneNotSupportedException{
		if (someCondition) {
			System.out.println(\"Cloning\");
		}
		return super.clone();
	}";
	
	str expected = "protected Object clone() throws CloneNotSupportedException{ System.out.println(new Throwable().getStackTrace()[0]);
		if (someCondition) {
			System.out.println(\"Cloning\");
		}
		return super.clone();
	}";
	
	return getInstrumentedMethod(method) == expected;
}