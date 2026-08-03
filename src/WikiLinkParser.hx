import WikiLink.WikiLinkMulti;
import js.Browser.document;
import js.html.Element;
import js.lib.RegExp;
using tools.NativeString;
using StringTools;

class WikiLinkParser {
	static inline var superscriptDigits = "⁰¹²³⁴⁵⁶⁷⁸⁹";
	static inline function unSuper(c:String) {
		return superscriptDigits.indexOf(c);
	}
	//
	static var rxSuperDigit = new RegExp('[$superscriptDigits]', "g");
	static var heritageMark = "ᴴ";
	static var rxAoN = new RegExp('\\[(.+?)\\]' // -> text
		+ '\\((.*?)\\)' // -> url
		+ '([$superscriptDigits$heritageMark]*)' // -> flags
	, "g");
	static var rxSomeOf = new RegExp('(?:,\\s+)?'
		+ '(\\d+)\\s+of\\s+'
		+ '(?:' + [
			'\\(' + '([^(]+)' + '\\)',
			'\\{' + '(.+?)' + '\\}',
		].join("|") + ')'
	, "g");
	public static function run(req:String) {
		req = req.trim();
		//
		var someOf = [];
		req = req.mapRegExp(rxSomeOf, function(_, mCount:String, mGroup1:String, mGroup2:String) {
			var mGroup = mGroup1 ?? mGroup2;
			var subLinks = run(mGroup);
			var link = new WikiLinkMulti(Std.parseInt(mCount), subLinks);
			someOf.push(link);
			return "";
		});
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
		for (link in someOf) results.push(link);
		return results;
	}
	
}