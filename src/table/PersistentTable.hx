package table;

import haxe.Json;
import js.Browser;
import js.html.URLSearchParams;
import tools.ShareButton;
import table.TableValue;

class PersistentTable<T:TableValue> extends Table<T> {
	public var storageKey = "yal.pf2e.what";
	public var basePath = 'https://yal.cc/game-tools/pf2e/bite/';
	
	override function build() {
		super.build();
		var shareButton = tools.ShareButton.create(
			() -> Json.stringify(saveFilters()),
			(type, text) -> {
				var base = (Browser.location.hostname != "localhost"
					? basePath
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
			var text = window.localStorage.getItem(storageKey);
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
	public var canAutoSave = false;
	public var autoSaveTimeout:Null<Int> = null;
	public var freshlySaved:Null<Int> = null;
	public var saveInterval = 5_000;
	function autoSave() {
		autoSaveTimeout = null;
		var filters = saveFilters();
		window.localStorage.setItem(storageKey, Json.stringify(filters));
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