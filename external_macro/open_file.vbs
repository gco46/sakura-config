Option Explicit
const COMMAND = "util/command.vbs"
dim fso
set fso = CreateObject("Scripting.FileSystemObject")
dim vbs_lib
vbs_lib = fso.GetParentFolderName(Editor.ExpandParameter("$I")) & "/" & COMMAND

Include(vbs_lib)

call main()

sub main()
	dim tgt_file_name
	tgt_file_name = InputBox("Input file name:")
	if tgt_file_name = "" then
		exit sub
	end if


	dim tgt_path
	tgt_path = replace(Editor.GetFileName, "\", "/")

	dim file_path
	file_path = search_command(tgt_path, tgt_file_name)
	if file_path <> "" then
		Editor.FileOpen(file_path)
	else
		MsgBox "No file was found."
	end if
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