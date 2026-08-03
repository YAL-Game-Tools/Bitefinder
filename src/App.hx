import js.Browser;
import js.html.URLSearchParams;
import WikiLink;
import js.lib.RegExp;
import js.html.Console;
import haxe.DynamicAccess;
import js.Browser.document;
using StringTools;
using tools.NativeString;
using tools.HtmlTools;

class App {
	public static var attacks:Array<Attack> = [];
	public static var table:AttackTable;
	public static var ancestrySizes:Map<String, Array<{size: String, heritage: String, not:Bool }>> = new Map();
	static function loadShared(source:String) {
		for (line in source.split("\n")) {
			line = line.trim();
			if (line == "") continue;
			if (line.startsWith("#")) continue;
			if (line.startsWith("-")) line = line.substring(1).ltrim();
			for (link in WikiLink.parse(line)) {
				WikiLinkImpl.commonLinks[link.name] = link.url;
			}
		}
		WikiLinkImpl.checkCommon = true;
	}
	static function loadSizes() {
		var rxSplit = new RegExp("^(.+):\\s*(.+)$");
		var rxCond = new RegExp("^(.+?)\\s*\\((!)?(.+)\\)");
		for (line in AutoData.ancestrySizes.split("\n")) {
			line = line.trim();
			if (line == "") continue;
			if (line.startsWith("#")) continue;
			var mt = rxSplit.exec(line);
			if (mt != null) {
				ancestrySizes[mt[1]] = mt[2].split(",").map(s -> {
					s = s.trim();
					var mtCond = rxCond.exec(s);
					if (mtCond != null) {
						return {
							size: mtCond[1],
							not: mtCond[2] == "!",
							heritage: mtCond[3],
						}
					} else return { size: s, heritage: null, not: false };
				});
			}
		}
	}
	public static var pf2e = true;
	public static var sf2e = false;
	public static function main() {
		loadSizes();
		//
		var params = new URLSearchParams(Browser.location.search);
		pf2e = !params.has("sf2e");
		sf2e = params.has("sf2e") || params.has("both");
		//
		function addAttacks(source:String, isVersatile:Bool) {
			for (a in AttackTableParser.run(source, isVersatile)) attacks.push(a);
		}
		if (pf2e) {
			loadShared(AutoData.shared);
			addAttacks(AutoData.heritage, false);
			addAttacks(AutoData.versatile, true);
		}
		if (sf2e) {
			loadShared(AutoData.shared_sf2e);
			addAttacks(AutoData.heritage_sf2e, false);
			addAttacks(AutoData.versatile_sf2e, true);
		}
		//Console.log(attacks);
		table = new AttackTable(
			document.querySelectorAuto("#table"),
			attacks,
			document.querySelectorAuto("#filters"),
			document.querySelectorAuto("#match-count"),
			document.querySelectorAuto("#reset-order"),
		);
	}
}