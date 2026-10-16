package weapons;

class WeaponTraitTools {
	public static function getLabel(t:WeaponTrait):String {
		var info = WeaponTrait.map[t];
		return info?.label ?? t;
	}
}