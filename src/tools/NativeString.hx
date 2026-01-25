package tools;
import haxe.Constraints.Function;
import js.lib.HaxeIterator;
import js.lib.RegExp;
import js.lib.Iterator;

class NativeString {
	public static function matchAll(s:String, rx:RegExp) {
		var jsIter:Iterator<Array<String>> = (cast s).matchAll(rx);
		var hxIter = new HaxeIterator(jsIter);
		return [for (m in hxIter) m];
	}
	public static inline function mapRegExp(s:String, rx:RegExp, fn:Function) {
		return (cast s).replaceAll(rx, fn);
	}
}