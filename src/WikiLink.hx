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
	public var url:String;
	public var level:Null<Int>;
	
	public static var checkCommon = false;
	public static var commonLinks:Map<String, String> = new Map();
	
	public function new(name:String, ?url, ?level) {
		this.name = name;
		if (url == null && checkCommon) url = commonLinks[name];
		this.url = url;
		this.level = level;
	}
	public function toElement() {
		var out:Element = if (url != null) {
			var a = document.createAnchorElement();
			a.append(name);
			a.href = url;
			a;
		} else {
			var span = document.createSpanElement();
			span.append(name);
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