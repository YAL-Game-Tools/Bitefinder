package weapons;

import haxe.DynamicAccess;

class Weapon extends table.TableValue {
	public var nameLQ:String;
	public var category:WeaponCategory;
	public var group:WeaponGroup;
	public var level:Int;
	public var damage:String;
	public var damageDie:Int;
	public var damageType:WeaponDamageType;
	public var damageTypes:Array<WeaponDamageType>;
	public var range:Int;
	public var reload:Int;
	public var traits:Array<WeaponTrait>;
	public var rarity:WeaponRarity;
	public var usage:WeaponUsage;
	public var notes:String;
	//
	public var ancestries:Array<String>;
	//
	public function assignRaw(wep:Weapon) {
		for (key in Reflect.fields(wep)) {
			var val = Reflect.field(wep, key);
			Reflect.setField(this, key, val);
		}
	}
	public inline function hasTrait(t:WeaponTrait) {
		return traits.contains(t);
	}
	public function getDamageTypes() {
		var damageTypes = [damageType];
		inline function add(damageType:WeaponDamageType) {
			if (!damageTypes.contains(damageType)) {
				damageTypes.push(damageType);
			}
		}
		if (hasTrait(VersatileB)) add(Bludgeoning);
		if (hasTrait(VersatileP)) add(Piercing);
		if (hasTrait(VersatileS)) add(Slashing);
		if (hasTrait(Modular)) {
			add(Bludgeoning);
			add(Piercing);
			add(Slashing);
		}
		return damageTypes;
	}
}