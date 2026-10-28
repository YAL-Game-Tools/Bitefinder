package weapons;

import columns.*;
import table.*;

class WeaponTable extends PersistentTable<Weapon> {
	override function initColumns() {
		storageKey = "yal.pf2e.pike.filters";
		basePath = 'https://yal.cc/game-tools/pf2e/pike/';
		
		function wl(getter:Weapon->String):Weapon->WikiLink {
			return (wep) -> getter(wep);
		}
		function wlx(getter:Weapon->Array<String>):Weapon->Array<WikiLink> {
			return (wep) -> getter(wep).map(s -> (s:WikiLink));
		}
		function wv<T>(getter:Weapon->T) return getter;
		var rarity = new LinkColumn("R", wl(w -> w.rarity));
		rarity.fullName = "Rarity";
		rarity.addValueAbbr("Common", "C", ["rarity", "common"]);
		rarity.addValueAbbr("Uncommon", "U", ["rarity", "uncommon"]);
		rarity.addValueAbbr("Rare", "R", ["rarity", "rare"]);
		columns.push(rarity);
		//
		var name = new LinkColumn("Name", wl(w -> w.name));
		columns.push(name);
		//
		var cat = new LinkColumn("Ct", wl(w -> w.category));
		cat.fullName = "Category";
		cat.addValueAbbr("Advanced", "A", ["category", "advanced"]);
		cat.addValueAbbr("Martial", "M", ["category", "martial"]);
		cat.addValueAbbr("Simple", "S", ["category", "simple"]);
		columns.push(cat);
		//
		var weaponType = new LinkColumn("Type", wl(w -> w.range != null ? "Ranged" : "Melee"));
		weaponType.fullName = "Weapon Type";
		columns.push(weaponType);
		//
		var range = new NumberColumn("R#", wv(w -> w.range ?? 0));
		range.fullName = "Range (ft)";
		range.hideWhen = i -> i == 0;
		columns.push(range);
		//
		var group = new LinkColumn("Group", wv(w -> {
			var cc = WikiLink.checkCommon;
			WikiLink.checkCommon = false;
			var link = new WikiLink(w.group.capitalize());
			WikiLink.checkCommon = cc;
			return link;
		}));
		columns.push(group);
		//
		var usage = new LinkColumn("H#", wl(w -> w.usage.toShort()));
		usage.fullName = "Hands/usage";
		columns.push(usage);
		//
		var dieSize = new NumberColumn("Die", wv(w -> w.damageDie));
		dieSize.fullName = "Die Size";
		dieSize.prefix = "d";
		columns.push(dieSize);
		//
		var damageTypes = new MultiLinkColumn("dTy", wlx(w -> w.damageTypes));
		damageTypes.fullName = "Damage Types";
		damageTypes.valueMultiSep = "/";
		damageTypes.addValueAbbr("Bludgeoning", "B");
		damageTypes.addValueAbbr("Slashing", "S");
		damageTypes.addValueAbbr("Piercing", "P");
		columns.push(damageTypes);
		//
		var traits = new MultiLinkColumn("Traits", wlx(w -> w.traits.map(t -> t.getLabel())));
		function expandTraits(name, arr:Array<WeaponTrait>) {
			traits.addExpandValue(name, arr.map(t -> t.getLabel()));
		}
		expandTraits("Deadly", [DeadlyD4, DeadlyD6, DeadlyD8, DeadlyD10, DeadlyD12]);
		expandTraits("Fatal", [FatalD8, FatalD10, FatalD12]);
		columns.push(traits);
		//
		var ancestries = new MultiLinkColumn("Ancestries", wlx(w -> w.ancestries));
		columns.push(ancestries);
		//
		super.initColumns();
	}
}