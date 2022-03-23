function CompareString(a, b) {
	var compval = function (d) {
		// 小文字を大文字の文字コードに変換して比較
		if (d >= 0x61 && d <= 0x7a) {
			return d - 0x20;
		} else if (d >= 0xff41 && d <= 0xff5a) {
			return d - 0x20;
		}
		return d;
	}
	var len = a.length < b.length ? a.length : b.length;
	var i = 0;
	while (i < len) {
		var ad = compval(a.charCodeAt(i));
		var bd = compval(b.charCodeAt(i));
		if (ad != bd) {
			return ad - bd;
		}
		i++;
	}
	if (a.length < b.length) {
		return -1;
	} else if (b.length < a.length) {
		return 1;
	}
	return 0;
}
function CompCTags() {
	var fileName = Editor.GetFileName();
	if (fileName == "") {
		return;
	}
	var word = Complement.GetCurrentWord();
	var bIgnoreCase = (Complement.GetOption() & 0x01 == 0x01);
	var fso = new ActiveXObject("Scripting.FileSystemObject");
	var tagfile = "tags";
	var upFolders = 0;
	fileName.replace(/\\/g, function (s) { upFolders++; return s; });
	var re = /^[^\t]+/;
	do {
		var file = null;
		try {
			file = fso.OpenTextFile(tagfile, 1, false);
			do {
				var strLine = file.ReadLine();
				var keyword = re.exec(strLine)[0];
				if (word.length <= keyword.length &&
					(bIgnoreCase ? 0 == CompareString(word, keyword.substring(0, word.length)) :
						word == keyword.substring(0, word.length))) {
					Complement.AddList(keyword);
				}
			} while (file.AtEndOfStream == false);
			file.Close();
			file = null;
		} catch (e) {
			file = null;
		}
		tagfile = "..\\" + tagfile;
		upFolders--;
	} while (0 <= upFolders);
}
CompCTags();
