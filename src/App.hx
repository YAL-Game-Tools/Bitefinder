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
	static function loadShared() {
		for (line in AutoData.shared.split("\n")) {
			line = line.trim();
			if (line == "") continue;
			if (line.startsWith("#")) continue;
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
	public static function main() {
		loadShared();
		loadSizes();
		for (a in AttackTableParser.run(AutoData.heritage, false)) attacks.push(a);
		for (a in AttackTableParser.run(AutoData.versatile, true)) attacks.push(a);
		//Console.log(attacks);
		table = new AttackTable(
			document.querySelectorAuto("#table"),
			attacks,
			document.querySelectorAuto("#filters"),
			document.querySelectorAuto("#match-count"),
		);
	}
}