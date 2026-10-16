import js.lib.RegExp;
import WikiLink.WikiLinkImpl;
import weapons.*;
using StringTools;

class Pikefinder {
	public static var table:WeaponTable;
	static function loadShared(source:String) {
		for (line in source.replace("\r", "").split("\n")) {
			line = line.trim();
			if (line == "") continue;
			if (line.startsWith("#")) continue;
			if (line.startsWith("-")) line = line.substring(1).ltrim();
			for (link in WikiLink.parse(line)) {
				static var rx = new RegExp("(.+?)\\s+\\(" + "(Melee|Ranged)" + "\\)$");
				var name = link.name;
				var mt = rx.exec(name);
				if (mt != null) name = mt[1];
				WikiLinkImpl.commonLinks[name] = link.url;
			}
		}
		WikiLinkImpl.checkCommon = true;
	}
	static function tagAncestry(weapon:Weapon, ancestry:String) {
		weapon.ancestries ??= [];
		if (!weapon.ancestries.contains(ancestry)) {
			weapon.ancestries.push(ancestry);
		}
	}
	static function loadAncestryTags(source:String, rawWeapons:Array<Weapon>) {
		var lines = source.replace("\r", "").split("\n");
		lines.shift();
		for (line in lines) {
			var parts = line.trim().split("\t");
			if (parts.length < 2) continue;
			var ancestry = parts[0];
			var weaponName = parts[1];
			if (weaponName == "N/A") continue;
			if (weaponName == "Any 1 Sword (can be changed each day)") {
				for (weapon in rawWeapons) if (weapon.group == Sword) {
					tagAncestry(weapon, ancestry);
				}
				continue;
			}
			if (weaponName == "Any 1 Common Axe or Hammer" ) {
				for (weapon in rawWeapons) if (weapon.group == Axe || weapon.group == Hammer) {
					tagAncestry(weapon, ancestry);
				}
				continue;
			}
			var weaponNameLQ = weaponName.toLowerCase();
			//
			var weapon = rawWeapons.find(wep -> wep.nameLQ == weaponNameLQ);
			if (weapon == null && weaponNameLQ.endsWith("s")) {
				var weaponNameSingular = weaponNameLQ.substring(0, weaponNameLQ.length - 1);
				weapon = rawWeapons.find(wep -> wep.nameLQ == weaponNameSingular);
			}
			//
			if (weapon != null) {
				tagAncestry(weapon, ancestry);
			} else {
				Console.warn('Could not find weapon "$weaponName" to tag for $ancestry');
			}
		}
	}
	static function stripAncestryTraits(weapons:Array<Weapon>) {
		var traits:Array<WeaponTrait> = [
			Azarketi,
			Catfolk,
			Conrasu,
			Dwarf,
			Elf,
			Geniekin,
			Ghoran,
			Gnome,
			Goblin,
			Halfling,
			Hobgoblin,
			Jotunborn,
			Kholo,
			Kobold,
			Orc,
			Tengu,
			Tripkee,
			Vanara,
			Vishkanya,
		];
		for (trait in traits) {
			var ancestry = WeaponTrait.map[trait].label;
			for (wep in weapons) {
				if (wep.traits.remove(trait)) tagAncestry(wep, ancestry);
			}
		}
	}
	public static function main() {
		loadShared((cast window).aonTweaks);
		loadShared((cast window).aonLinks);
		var weapons:Array<Weapon> = (cast window).pf2eWeapons;
		for (wep in weapons) {
			wep.nameLQ = wep.name.toLowerCase();
		}
		//
		loadAncestryTags((cast window).pf2eWeaponTags, weapons);
		stripAncestryTraits(weapons);
		
		// strip non-ancestry weapons:
		weapons = weapons.filter(wep -> wep.ancestries != null);
		
		//
		weapons = weapons.map(raw -> {
			var wep = new Weapon(raw.name);
			wep.assignRaw(raw);
			wep.damageTypes = wep.getDamageTypes();
			//
			static var rxDieSize = new RegExp("^d(\\d+)");
			var mt = rxDieSize.exec(wep.damage);
			if (mt != null) wep.damageDie = Std.parseInt(mt[1]);
			//
			return wep;
		});
		table = new WeaponTable(
			document.querySelectorAuto("#table"),
			weapons,
			document.querySelectorAuto("#filters"),
			document.querySelectorAuto("#match-count"),
			document.querySelectorAuto("#reset-order"),
		);
	}
}