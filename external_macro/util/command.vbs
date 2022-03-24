Option Explicit

const SAKURA_UTIL = "util/sakura_util.py"

function search_command(tgt_path, pattern)
	' SAKURA_UTILの searchコマンド実行
	' tgt_path (str): 検索対象フォルダ or ファイルの絶対パス
	'		ファイルパスが渡された場合はプロジェクト登録されている親フォルダ内を検索する
	' pattern (str): 探したいファイル名(先頭一致)
	'
	' return (str): ファイルの絶対パス
	' 		該当なしの場合は空文字

	' TODO: RunでのファイルI/Oのオーバーヘッド確認, Execとの比較検討

	dim wsh
	set wsh = CreateObject("WScript.Shell")
	dim fso
	set fso = CreateObject("Scripting.FileSystemObject")

	dim command
	command = "--command=search"
	dim script
	script = fso.GetParentFolderName(Editor.ExpandParameter("$I")) & "/" & SAKURA_UTIL
	tgt_path = "--tgt_path=" & tgt_path
	pattern = "--pattern=" & pattern

	dim cl_input
	cl_input = join(array("cmd.exe /c python", script, command, tgt_path, pattern), " ")

	search_command = wsh.Exec(cl_input).StdOut.ReadLine
end function


function project_command(tgt_proj)
	' SAKURA_UTILのprojectコマンド実行
	' tgt_proj (str): 対象プロジェクト名 or 空文字
	'
	' return (str): 該当プロジェクトのstart_file絶対パス
	'		tgt_proj==""の場合はプロジェクト一覧をカンマ区切りで返す

	dim wsh
	set wsh = CreateObject("WScript.Shell")
	dim fso
	set fso = CreateObject("Scripting.FileSystemObject")

	dim command
	command = "--command=project"
	dim script
	script = fso.GetParentFolderName(Editor.ExpandParameter("$I")) & "/" & SAKURA_UTIL
	dim proj_name
	proj_name = "--proj_name=" & tgt_proj

	dim cl_input
	cl_input = join(array("cmd.exe /c python", script, command, proj_name), " ")

	project_command = wsh.Exec(cl_input).StdOut.ReadLine
end function


function toggle_command(tgt_path)
	' SAKURA_UTILのtoggleコマンド実行
	' tgt_path (str): 対象プロジェクトのフォルダ or ファイル絶対パス
	' 
	' return (int): 成功 or 失敗
	dim wsh
	set wsh = CreateObject("WScript.Shell")
	dim fso 
	set fso = CreateObject("Scripting.FileSystemObject")

	dim script
	script = fso.GetParentFolderName(Editor.ExpandParameter("$I")) & "/" & SAKURA_UTIL
	dim command
	command = "--command=toggle"
	tgt_path = "--tgt_path=" & tgt_path

	dim cl_input
	cl_input = join(array("cmd.exe /c python", script, command, tgt_path), " ")

	dim is_err
    ' コマンドプロンプト非表示で同期実行
    is_err = wsh.Run(cl_input, 0, True)

	toggle_command = is_err
end function