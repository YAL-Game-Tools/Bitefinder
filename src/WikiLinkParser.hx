import js.Browser.document;
import js.html.Element;
import js.lib.RegExp;
using tools.NativeString;
using StringTools;

class WikiLinkParser {
	static inline var superscript = "⁰¹²³⁴⁵⁶⁷⁸⁹";
	static inline function unSuper(c:String) {
		return superscript.indexOf(c);
	}
	//
	static var rxSuperDigit = new RegExp('[$superscript]', "g");
	static var heritageMark = "ᴴ";
	static var rxAoN = new RegExp('\\[(.+?)\\]' // -> text
		+ '\\((.*?)\\)' // -> url
		+ '([$superscript$heritageMark]*)' // -> flags
	, "g");
	public static function run(req:String) {
		req = req.trim();
		//
		var results = [];
		for (mt in req.matchAll(rxAoN)) {
			var flags = mt[3];
			if (flags == heritageMark) {
				results.push(new WikiLink(mt[1], mt[2], 0));
			} else {
				var level:Null<Int> = null;
				if (flags != "") {
					var levelStr = flags.mapRegExp(rxSuperDigit, function(d) {
						return "" + unSuper(d);
					});
					level = Std.parseInt(levelStr);
				}
				results.push(new WikiLink(mt[1], mt[2], level));
			}
		}
		if (results.length == 0 && req != "" && req != "-") {
			for (term in req.split(",").map((s) -> s.trim())) {
				term = term.charAt(0).toUpperCase() + term.substr(1);
				var levelStr = "";
				term = term.mapRegExp(rxSuperDigit, (c) -> {
					levelStr += unSuper(c);
					return "";
				});
				var level = levelStr != null ? Std.parseInt(levelStr) : null;
				results.push(new WikiLink(term, null, level));
			}
		}
		return results;
	}
	
}