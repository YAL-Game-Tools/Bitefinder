import haxe.io.Bytes;
import haxe.io.Path;
import sys.io.File;
import haxe.macro.Context;
import haxe.macro.Compiler;
import sys.FileSystem;
using StringTools;

class PostBuild {
	public static macro function run():Void {
		function compileDataFile(dir) {
			var buf = new StringBuf();
			var inDir = "data";
			buf.add("// " + DateTools.format(Date.now(), "%Y-%m-%d_%H:%M:%S") + "\n");
			buf.add('window.yalAttackData ??= {};');
			for (rel in FileSystem.readDirectory(inDir)) {
				if (Path.extension(rel) != "md") continue;
				var name = Path.withoutExtension(rel);
				var md = File.getContent('$inDir/$rel').replace("\r", "");
				buf.add('\n' + 'yalAttackData.$name = `$md`;');
			}
			//
			var jsBytes = Bytes.ofString(buf.toString());
			var jsBytesBOM = Bytes.alloc(jsBytes.length + 3);
			for (i => b in [0xEF, 0xBB, 0xBF]) {
				jsBytesBOM.set(i, b);
			}
			jsBytesBOM.blit(3, jsBytes, 0, jsBytes.length);
			File.saveBytes('$dir/data.js', jsBytesBOM);
		}
		Context.onAfterGenerate(() -> {
			var dir = Path.directory(Compiler.getOutput());
			compileDataFile(dir);
			//
			var now = Date.now();
			var nowStr = DateTools.format(Date.now(), "%F");
			var indexHTML = File.getContent(Path.join([dir, "index.html"]));
			indexHTML = indexHTML.replace("BUILD_DATE", nowStr);
			File.saveContent(Path.join([dir, "index.php"]), indexHTML);
		});
	}
}