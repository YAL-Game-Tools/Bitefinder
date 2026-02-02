import js.Browser;
import js.html.TableRowElement;

class Attack extends table.TableValue {
	public var rarity:String;
	public var ancestry:WikiLink;
	public var heritage:WikiLink = null;
	public var feats:Array<WikiLink> = [];
	public var dieSize = 0;
	public var damageTypes:Array<WikiLink> = [];
	public var weaponGroup = "Brawling";
	
	public var traits:Array<WikiLink> = [];
	public static var knownTraits:Array<String> = [];
}