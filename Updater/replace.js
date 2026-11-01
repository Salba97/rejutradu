// Usage: cscript //nologo replace.js file constant value

var file     = WScript.Arguments.Item(0);
var constant = WScript.Arguments.Item(1);
var value    = WScript.Arguments.Item(2);

var fso = new ActiveXObject("Scripting.FileSystemObject");
var text = fso.OpenTextFile(file, 1).ReadAll();

var pattern = new RegExp("^" + constant + " = '.*'$", "gm");
text = text.replace(pattern, constant + " = '" + value + "'");

var out = fso.OpenTextFile(file, 2, true);
out.Write(text);
out.Close();
