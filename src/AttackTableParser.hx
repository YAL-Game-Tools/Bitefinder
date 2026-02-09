import WikiLink;
import js.lib.RegExp;
import js.html.Console;
import haxe.DynamicAccess;
using StringTools;
using tools.NativeString;

class AttackTableParser {
	static function splitTableRow(md:String) {
		md = md.trim();
		if (md.startsWith("|")) md = md.substring(1).ltrim();
		if (md.endsWith("|")) md = md.substring(0, md.length - 1).rtrim();
		return md.split("|").map(s -> s.trim());
	}
	public static function run(md:String, isVersatile:Bool) {
		var lines = md.trim().split("\n");
		// pop the header
		var header = splitTableRow(lines.shift());
		lines.shift();
		//
		var rxDamage = new RegExp("\\d*d(\\d+)ʺ\\s*(.+)");
		//
		var attacks = [];
		for (line in lines) {
			var item = new DynamicAccess();
			var lineCells = splitTableRow(line);
			for (i in 0 ... header.length) {
				item[header[i]] = lineCells[i] ?? "";
			}
			//
			var ancestry = item["Ancestry"] ?? "Any";
			var heritage = item["Heritage"];
			var attack = new Attack(item["Attack"] ?? "???");
			attack.rarity = item["Rarity"];
			attack.ancestry = ancestry;
			attack.heritage = heritage;
			//
			var damageText = item["Damage"];
			var damageParts = damageText.split("/").map(part -> part.trim());
			for (part in damageParts) {
				var dieSize = 0;
				var damageType = "";
				var mt = rxDamage.exec(part);
				if (mt != null) {
					dieSize = Std.parseInt(mt[1]);
					damageType = mt[2];
				} else damageType = part;
				
				switch (damageType) {
					case "P": damageType = "Piercing";
					case "S": damageType = "Slashing";
					case "B": damageType = "Bludgeoning";
				}
				if (dieSize == 0) {
					//
				} else if (attack.dieSize != 0 && attack.dieSize != dieSize) {
					Console.warn('Die size redefinition in "$line" from ${attack.dieSize} to $dieSize');
				} else attack.dieSize = dieSize;
				attack.damageTypes.push(damageType);
			}
			//
			var traits = WikiLink.parse(item["Traits"]);
			for (trait in traits) {
				if (trait.name.startsWith("G:")) {
					if (trait.name == "G:Crit") {
						trait.name = "CritSpec";
						attack.traits.push(trait);
					} else {
						var group = trait.name.substr(2);
						//if (group == "?") group = "Unspecified";
						attack.weaponGroup = group;
					}
				} else {
					attack.traits.push(trait);
				}
			}
			//
			var selfName = isVersatile ? heritage : ancestry;
			var feats = WikiLink.parse(item["Requirements"]);
			for (link in feats) {
				link.name = link.name.replace("@", selfName);
				if (link.level == 0) {
					heritage = link.name;
					attack.heritage = link;
				} else {
					attack.feats.push(link);
				}
			}
			
			//
			if (isVersatile) {
				for (size in ["Tiny", "Small", "Medium", "Large"]) {
					attack.ancestrySizes.push(size);
				}
			} else {
				var sizes = App.ancestrySizes[ancestry];
				if (sizes != null) {
					for (item in sizes) {
						var sizeHeritage = item.heritage;
						if (heritage != null && sizeHeritage != null) {
							sizeHeritage = sizeHeritage.replace("@", selfName);
							if ((heritage == sizeHeritage) == item.not) continue;
						}
						attack.ancestrySizes.push(item.size);
					}
				} else {
					Console.warn('Attack ${attack.name} references ancestry ${attack.ancestry} without a known size.');
				}
			}
			//
			attacks.push(attack);
		}
		return attacks;
	}
}