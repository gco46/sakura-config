Option Explicit
const COMMAND = "util/command.vbs"
dim fso
set fso = CreateObject("Scripting.FileSystemObject")
dim vbs_lib
vbs_lib = fso.GetParentFolderName(Editor.ExpandParameter("$I")) & "/" & COMMAND

Include(vbs_lib)

call main()

sub main()
	dim tgt_path
	tgt_path = replace(Editor.GetFileName, "\", "/")

	dim is_err
	is_err = toggle_command(tgt_path)
	if is_err then
		MsgBox "toggling failed"
		exit sub
	end if
	
	Editor.TagMake()

	toggle_command(tgt_path)
	
end sub

' 外部vbsファイルinclude関数--------------------------------
Function Include(strFile)
	'strFile：読み込むvbsファイルパス
 
	Dim objFso, objWsh, strPath
	Set objFso = CreateObject("Scripting.FileSystemObject")
	
	'外部ファイルの読み込み
	Set objWsh = objFso.OpenTextFile(strFile)
	ExecuteGlobal objWsh.ReadAll()
	objWsh.Close
 
	Set objWsh = Nothing
	Set objFso = Nothing
 
End Function