module Metrics::Scores

import util::Math;
import List;

public data RiskLevel = Simple() | Moderate() | High() | VeryHigh();

public data Ranking = Lowest() | Low() | Medium() | High() | Highest();

public str rankingAsString(Ranking ranking) {
	visit(ranking) {
		case Lowest(): return "--";
		case Low(): return "-";
		case Medium(): return "o";
		case High(): return "+";
		case Highest(): return "++";
	}
	throw "unknown ranking <ranking>";
}

public Ranking averageRanking(list[Ranking] rankings) {
	int average = round(sum([rankingAsNumber(x) | x <- rankings]) / size(rankings));
	return numberAsRanking(average);
}

private num rankingAsNumber(Ranking ranking) {
	visit(ranking) {
		case Lowest(): return 1;
		case Low(): return 2;
		case Medium(): return 3;
		case High(): return 4;
		case Highest(): return 5;
	}
	throw "unknown ranking <ranking>";
}

private Ranking numberAsRanking(int ranking) {
	visit(ranking) {
		case 1: return Lowest();
		case 2: return Low();
		case 3: return Medium();
		case 4: return High();
		case 5: return Highest();
	}
	throw "unknown ranking <ranking>";
}