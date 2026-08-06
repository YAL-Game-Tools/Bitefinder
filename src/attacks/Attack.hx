package attacks;
import js.lib.RegExp;
import js.Browser;
import js.html.TableRowElement;
using StringTools;
using tools.NativeString;

class Attack extends table.TableValue {
	public var rarity:String;
	public var ancestry:WikiLink;
	public var ancestrySizes:Array<WikiLink> = [];
	public var heritage:WikiLink = null;
	public var feats:Array<WikiLink> = [];
	public var dieSize = 0;
	public var damageTypes:Array<WikiLink> = [];
	public var weaponGroup = "Brawling";
	
	public var traits:Array<WikiLink> = [];
	public static var knownTraits:Array<String> = [];
	
	public static var traitNoteMap:Map<String, String> = new Map();
	public static var traitNoteMatchers:Array<{ regexp:RegExp, note:String }> = [];
	public static function loadTraitNotes(source:String) {
		var rxTrait = new RegExp("^\\s*-\\s*(.+?)\\s*:\\s*(.+)$");
		var rxEsc = new RegExp("[()\\[\\]{}+?]", "g");
		var rxGroups = new RegExp("[#@]", "g");
		for (line in source.split("\n")) {
			var mt = rxTrait.exec(line);
			if (mt == null) continue;
			var name = mt[1];
			var text = mt[2];
			if (rxGroups.test(name)) {
				var rs = name;
				rs = rs.mapRegExp(rxEsc, s -> "\\" + s);
				rs = rs.mapRegExp(rxGroups, s -> {
					return switch (s) {
						case "@": "(.+?)";
						case "#": "(\\d+)";
						default: throw "???";
					}
				});
				rs = "^" + rs + "$";
				traitNoteMatchers.push({
					regexp: new RegExp(rs),
					note: text
				});
			} else {
				traitNoteMap[name] = text;
			}
		}
	}
}