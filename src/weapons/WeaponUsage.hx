package weapons;

@:using(weapons.WeaponUsage.WeaponUsageTools)
enum abstract WeaponUsage(String) to String {
	var HeldInOneHand = "held-in-one-hand";
	var HeldInOnePlusHands = "held-in-one-plus-hands";
	var HeldInTwoHands = "held-in-two-hands";
	var WornGloves = "worngloves";
}
class WeaponUsageTools {
	public static function toShort(u:WeaponUsage) {
		return switch (u) {
			case HeldInOneHand: "1";
			case HeldInOnePlusHands: "1+";
			case HeldInTwoHands: "2";
			case WornGloves: "0";
			default: u;
		}
	}
}