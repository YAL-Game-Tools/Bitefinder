import js.Browser.document;
import js.html.Element;
import js.lib.RegExp;
using tools.NativeString;
using StringTools;

@:forward
@:forwardStatics
@:forward.new
@:native("WikiLinkTools")
abstract WikiLink(WikiLinkImpl) from WikiLinkImpl to WikiLinkImpl {
	@:from static inline function fromString(s:String):WikiLink {
		return s != null ? parseOne(s) : null;
	}
	
	public static inline function parseOne(s:String) {
		return parse(s)[0];
	}
	public static inline function parse(s:String) {
		return WikiLinkParser.run(s);
	}
}

@:native("WikiLink")
class WikiLinkImpl {
	public var name:String;
	public var label:String;
	public var url:String;
	public var level:Null<Int>;
	
	public static var checkCommon = false;
	public static var commonLinks:Map<String, String> = new Map();
	
	static var rxShorthands = new RegExp("^(.+?)\\s*(<|>|=)\\s*(.+)$");
	static var rxSelfRef = new RegExp("\\s*@", "g");
	
	public function new(name:String, ?url, ?level) {
		var label = name;
		//
		var mt = rxShorthands.exec(name);
		if (mt != null) {
			var left = mt[1];
			var right = mt[3];
			switch (mt[2]) {
				case ">": label = left; name = '$left $right';
				case "<": label = right; name = '$left $right';
				default: label = left; name = right;
			}
		} else {
			label = name.mapRegExp(rxSelfRef, function(_) {
				return "";
			});
		}
		//
		this.name = name;
		this.label = label;
		if (url == "") url = null;
		if (url == null && checkCommon) url = commonLinks[name];
		this.url = url;
		this.level = level;
	}
	public function toElement() {
		var hasTitle = name != label;
		var out:Element = if (url != null) {
			var a = document.createAnchorElement();
			a.append(label);
			if (hasTitle) a.title = name;
			a.href = url;
			a;
		} else {
			var span:Element = document.createElement(hasTitle ? "abbr" : "span");
			if (hasTitle) span.title = name;
			span.append(label);
			span;
		}
		if (level != null && level != 0) {
			var ctr = document.createSpanElement();
			ctr.append(out);
			var sup = document.createElement("sup");
			sup.append("" + level);
			ctr.append(sup);
			out = ctr;
		}
		return out;
	}
	@:keep public function toString() {
		return 'WikiLink("$name")';
	}
}