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
	public static function main() {
		loadShared();
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