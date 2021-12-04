module Metrics::UnitSize

import Metrics::Volume;
import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import analysis::m3::Core;
import util::Math;
import IO;

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import analysis::m3::Core;
import util::Math;
import IO;

import Metrics::Volume;
import Utils::MethodUtils;

data RiskLevel = Simple() | Moderate() | High() | VeryHigh();

