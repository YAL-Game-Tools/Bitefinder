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
	public var title:String;
	public var label:String;
	public var url:String;
	public var level:Null<Int>;
	
	public static var checkCommon = false;
	public static var commonLinks:Map<String, String> = new Map();
	
	static var rxShorthands = new RegExp("^(.+?)\\s*(<|>|=)\\s*(.+)$");
	static var rxSelfRef = new RegExp("\\s*@", "g");
	
	public function new(name:String, ?url:String, ?level) {
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
		if (url != null && !url.contains("://")) {
			this.title = url;
			url = null;
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
		var hasTitle = name != label || title != null;
		var out:Element = if (url != null) {
			var a = document.createAnchorElement();
			a.append(label);
			if (hasTitle) a.title = name;
			a.href = url;
			a;
		} else {
			var span:Element = document.createElement(hasTitle ? "abbr" : "span");
			if (hasTitle) span.title = title ?? name;
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
	public function gatherNames(out:Array<String>) {
		out.push(name);
	}
	@:keep public function toString() {
		return 'WikiLink("$name")';
	}
}
@:native("WikiLinkMulti")
class WikiLinkMulti extends WikiLinkImpl {
	public var links:Array<WikiLinkImpl>;
	public function new(n:Int, ?links:Array<WikiLinkImpl>) {
		super('$n of');
		this.links = links ?? [];
	}
	override function gatherNames(out:Array<String>) {
		for (link in links) link.gatherNames(out);
	}
	override function toElement():Element {
		var out:Element = document.createSpanElement();
		out.append(name + " (");
		for (i => link in links) {
			if (i > 0) out.append(", ");
			out.append(link.toElement());
		}
		out.append(")");
		return out;
	}
}