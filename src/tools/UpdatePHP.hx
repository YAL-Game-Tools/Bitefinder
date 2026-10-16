package tools;
import haxe.io.Bytes;
import haxe.io.Path;
import sys.io.File;
import haxe.macro.Context;
import haxe.macro.Compiler;
import sys.FileSystem;
using StringTools;

class UpdatePHP {
	public static macro function run():Void {
		Context.onAfterGenerate(() -> {
			var dir = Path.directory(Compiler.getOutput());
			var now = Date.now();
			var nowStr = DateTools.format(Date.now(), "%F");
			var indexHTML = File.getContent(Path.join([dir, "index.html"]));
			indexHTML = indexHTML.replace("BUILD_DATE", nowStr);
			File.saveContent(Path.join([dir, "index.php"]), indexHTML);
		});
	}
}