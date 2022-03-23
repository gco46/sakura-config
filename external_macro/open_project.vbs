Option Explicit
const COMMAND = "util/command.vbs"
dim fso
set fso = CreateObject("Scripting.FileSystemObject")
dim vbs_lib
vbs_lib = fso.GetParentFolderName(Editor.ExpandParameter("$I")) & "/" & COMMAND

Include(vbs_lib)

call main()

sub main()
	dim proj_csv
	' プロジェクト一覧を取得(引数空文字)
	proj_csv = project_command("")
	
	dim message
	message = replace(proj_csv, ",", vbcr & "  ")
	message = "Choose project:" & vbcr & "  " & message
	
	dim tgt_proj
	tgt_proj = InputBox(message)
	if tgt_proj = "" then
		exit sub
	end if

	dim file_path
	file_path = project_command(tgt_proj)
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