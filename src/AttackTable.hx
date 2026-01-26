import js.html.Console;
import haxe.Json;
import js.Browser;
import columns.*;
import table.*;

class AttackTable extends Table<Attack> {
	override function initColumns() {
		columns.push(new LinkColumn("Ancestry", (a:Attack) -> a.ancestry));
		columns.push(new LinkColumn("Heritage", (a:Attack) -> a.heritage));
		columns.push(new MultiLinkColumn("Feats", (a:Attack) -> a.feats));
		//
		columns.push(new NameColumn("Attack"));
		
		var dieSize = new NumberColumn("Die", (a:Attack) -> a.dieSize);
		dieSize.filterName = "Die Size";
		dieSize.prefix = "d";
		columns.push(dieSize);
		
		var damageType = new MultiLinkColumn("Type", (a:Attack) -> a.damageTypes);
		damageType.filterName = "Damage Type";
		columns.push(damageType);
		
		columns.push(new MultiLinkColumn("Traits", (a:Attack) -> a.traits));
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
	
	static final lsKey = "yal.pf2e.bite.filters";
	override function afterBuild() {
		try {
			var text = Browser.window.localStorage.getItem(lsKey);
			if (text != null && text != "") {
				var array = Json.parse(text);
				loadFilters(array);
			}
		} catch (e:Dynamic) {
			Console.error("Load error:", e);
		}
		super.afterBuild();
		autoSave = true;
	}
	var autoSave = false;
	override function updateFilters() {
		super.updateFilters();
		if (autoSave) {
			var filters = saveFilters();
			Browser.window.localStorage.setItem(lsKey, Json.stringify(filters));
		}
	}
}