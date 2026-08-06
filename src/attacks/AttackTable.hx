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

class AttackTable extends Table<Attack> {
	override function initColumns() {
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
		columns.push(new LinkColumn("Attack", (a:Attack) -> a.name));
		
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
	
	override function build() {
		super.build();
		var shareButton = tools.ShareButton.create(
			() -> Json.stringify(saveFilters()),
			(type, text) -> {
				var base = (Browser.location.hostname != "localhost"
					? 'https://yal.cc/game-tools/pf2e/bite/'
					: Browser.location.origin + Browser.location.pathname
				);
				var url = '$base?filters-${type}=$text';
				if (Bitefinder.sf2e) {
					if (Bitefinder.pf2e) {
						url += '&both';
					} else url += '&sf2e';
				}
				return url;
			}
		);
		rootFilterPicker.appendMixed(" ", shareButton);
	}
	
	static final lsKey = "yal.pf2e.bite.filters";
	override function afterBuild() {
		var params = new URLSearchParams(Browser.location.search);
		var p:String;
		function then(str) {
			Console.log("Loading", str);
			loadFilters(Json.parse(str));
		}
		if ((p = params.get("filters-e")) != null) {
			ShareButton.decode("e", p, then);
		} else if ((p = params.get("filters-b")) != null) {
			ShareButton.decode("b", p, then);
		} else if ((p = params.get("filters-c")) != null) {
			ShareButton.decode("c", p, then);
		} else try {
			var text = window.localStorage.getItem(lsKey);
			if (text != null && text != "") {
				var array = Json.parse(text);
				loadFilters(array);
			}
		} catch (e:Dynamic) {
			Console.error("Load error:", e);
		}
		super.afterBuild();
		canAutoSave = true;
		window.addEventListener("beforeunload", (_) -> {
			if (autoSaveTimeout != null) {
				window.clearTimeout(autoSaveTimeout);
				autoSave();
			}
		});
	}
	var canAutoSave = false;
	var autoSaveTimeout:Null<Int> = null;
	var freshlySaved:Null<Int> = null;
	var saveInterval = 5_000;
	function autoSave() {
		autoSaveTimeout = null;
		var filters = saveFilters();
		window.localStorage.setItem(lsKey, Json.stringify(filters));
		Console.log('Saved ${filters.length} filter(s)!');
		freshlySaved = window.setTimeout(() -> {
			freshlySaved = null;
		}, saveInterval);
	}
	override function updateFilters() {
		super.updateFilters();
		if (canAutoSave) {
			if (freshlySaved == null) {
				autoSave();
			} else if (autoSaveTimeout == null) {
				autoSaveTimeout = window.setTimeout(autoSave, saveInterval);
			}
		}
	}
}