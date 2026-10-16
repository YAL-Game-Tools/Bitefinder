package attacks;
import tools.ShareButton;
import js.html.URLSearchParams;
import js.html.Console;
import haxe.Json;
import js.Browser;
import js.Browser.window;
import columns.*;
import table.*;
using tools.HtmlTools;

class AttackTable extends PersistentTable<Attack> {
	override function initColumns() {
		storageKey = "yal.pf2e.bite.filters";
		basePath = 'https://yal.cc/game-tools/pf2e/bite/';
		
		var rarity = new LinkColumn("R", (a:Attack) -> a.rarity);
		rarity.fullName = "Rarity";
		rarity.addValueAbbr("Common", "C", ["rarity", "common"]);
		rarity.addValueAbbr("Uncommon", "U", ["rarity", "uncommon"]);
		rarity.addValueAbbr("Rare", "R", ["rarity", "rare"]);
		rarity.show = false;
		columns.push(rarity);
		
		columns.push(new LinkColumn("Ancestry", (a:Attack) -> a.ancestry));
		var size = new MultiLinkColumn("Ancestry Size", (a:Attack) -> a.ancestrySizes);
		size.show = false;
		columns.push(size);
		
		columns.push(new LinkColumn("Heritage", (a:Attack) -> a.heritage));
		columns.push(new MultiLinkColumn("Feats", (a:Attack) -> a.feats));
		//
		var attack = new LinkColumn("Attack", (a:Attack) -> a.name);
		attack.addExpandValue("Any Teeth", ["Jaws", "Fangs", "Tusk", "Tusks", "Teeth", "Beak", "Mandible", "Proboscis"]);
		attack.addExpandValue("Any Claws", ["Claw", "Talon", "Pincer"]);
		attack.addExpandValue("Any Horns", ["Horn", "Horns", "Antler"]);
		columns.push(attack);
		
		var dieSize = new NumberColumn("Die", (a:Attack) -> a.dieSize);
		dieSize.fullName = "Die Size";
		dieSize.prefix = "d";
		columns.push(dieSize);
		
		var damageType = new MultiLinkColumn("Type", (a:Attack) -> a.damageTypes);
		damageType.fullName = "Damage Type";
		columns.push(damageType);
		
		var traits = new MultiLinkColumn("Traits", (a:Attack) -> a.traits);
		traits.prepareValueForComparison = s -> {
			if (StringTools.endsWith(s, "*")) {
				return s.substring(0, s.length - 1);
			} else return s;
		};
		traits.hideValue("Ranged");
		columns.push(traits);
		
		var weaponGroup = new LinkColumn("Group", (a:Attack) -> a.weaponGroup);
		weaponGroup.fullName = "Weapon Group";
		columns.push(weaponGroup);
		//
		super.initColumns();
		//
		damageType.addComplexValue("SpriteSpark", [
			"Mental",
			"Fire",
			"Sonic",
			"Poison"
		], "Depending on the chosen heritage, <values>", "Elemental");
		damageType.addComplexValue("SpriteSpark2", [
			"Bludgeoning",
			"Vitality",
			"Fire",
			"Piercing",
			"Slashing",
		], "Versatile damage with trait based on element: <values>");
		damageType.addComplexValue("ElementalCurrent", [
			"Electricity",
			"Cold",
			"Fire",
			"Piercing",
			"Bludgeoning",
			"Slashing",
		], "Depending on the cantrip you've chosen, this can be: <values>", "Elemental");
	}
}