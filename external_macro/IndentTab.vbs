Option Explicit

call main()

sub main()
	' 矩形選択時は考慮しない
	if Editor.IsTextSelected() then
		dim start_line
		dim end_line
		start_line = Editor.GetSelectLineFrom()
		end_line = Editor.GetSelectLineTo()
		if start_line = end_line then
			' 改行含めて選択しないとインデントできないため行選択
			Editor.SelectLine()
		end if
	else
		' カーソル位置をインデントするために行選択
		Editor.SelectLine()
	end if
	Editor.IndentTab()

end sub