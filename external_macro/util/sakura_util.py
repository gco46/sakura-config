from typing import List
from typing import Optional
import sys
from pathlib import Path
import argparse
import re
import json


class ToggleSrc():
    COMMENT_SET: dict = {
        ".c": "// ",
        ".h": "// "
    }

    def __init__(self,
                 tgt_path: str,
                 start_word: str = "#pragma asm",
                 end_word: str = "#pragma endasm",
                 code_flag: str = "DISABLED:") -> None:
        # 対象ファイル or ディレクトリのpath
        self.tgt_path = tgt_path
        # 対象行の判定用キーワード
        self.start_word = start_word
        self.end_word = end_word
        # 本クラスの処理による編集箇所を明示するためのコードフラグ
        self.code_flag = code_flag

    def exe_toggle(self) -> bool:
        """
        ソースファイルのトグル実行
        Return:
            成功 or 失敗
        """
        target = Path(self.tgt_path)

        if target.is_file():
            self._scan_src_file(target)
            return True
        elif target.is_dir():
            for file in target.glob("**/*.*"):
                self._scan_src_file(file)
            return True
        return False

    def _scan_src_file(self, file: Path) -> None:
        """
        ソースファイルを走査し、対象行を変更して上書き保存する
        Args:
            file: 対象のテキストファイル
        """
        # 対象ソースに含まれない場合はスキップ
        extension: str = file.suffix
        if extension not in list(ToggleSrc.COMMENT_SET.keys()):
            return

        result_buf: List[str] = []
        is_tgt_line: bool = False
        update_file: bool = False

        # デコード不能なマルチバイト文字を含むファイルは無視
        # error="ignore"
        with open(file, mode="r", encoding="shift-jis", errors="ignore") as f:
            for line in f.readlines():
                if self.start_word in line:
                    is_tgt_line = True

                if is_tgt_line:
                    # 対象Lineが見つかった時点でファイル更新実施を決定
                    update_file = True
                    line_buf = self._toggle_tgt_line(line, extension)
                else:
                    line_buf = line

                if self.end_word in line:
                    is_tgt_line = False

                result_buf.append(line_buf)

        if update_file:
            with open(file, mode="w", encoding="shift-jis", errors="ignore") as f:
                f.write("".join(result_buf))

    def _toggle_tgt_line(self, line: str, ext: str) -> str:
        """
        対象行をコメントアウト or コメント解除する
        Args:
            line: ファイルから抽出した行
            ext: 対象ファイルの拡張子
        Return:
            コメントアウト or コメント解除した行
        """
        if self.code_flag in line:
            result_line = line.replace(ToggleSrc.COMMENT_SET[ext] + self.code_flag, "")
        else:
            result_line = ToggleSrc.COMMENT_SET[ext] + self.code_flag + line
        return result_line


class SearchSrc():
    # TODO: 対象拡張子の情報は設定ファイルに持たせる
    SRC_EXT = [
        ".c",
        ".h",
        ".s",
        ".asm"
    ]

    def __init__(self, tgt_dir: str):
        self.tgt_dir: Path = Path(tgt_dir)
        ext_or = "|".join(SearchSrc.SRC_EXT).replace(".", "")
        self.re_ptn: str = r"/*\.(" + ext_or + ")"

    def search(self, pattern: str) -> Optional[str]:
        """
        ファイル名がpatternにマッチするファイルを検索する
        ヒットしたファイルのうち昇順で先頭のファイルのパスを返す
        Args:
            pattern: ファイル名(先頭から部分一致)
        Return:
            str: ファイルの絶対パス
        """
        if not self.tgt_dir.exists():
            return None
        elif pattern == "":
            return None

        # UNIX系ではファイルパスの大文字小文字区別があるためマッチしない可能性あり
        # サクラエディタでの使用を想定しているためケアしない
        # 念の為patternを小文字にしてから検索
        pattern = pattern.lower()
        hit_files = [p for p in self.tgt_dir.glob("**/" + pattern + "*")
                     if re.search(self.re_ptn, str(p))]

        if len(hit_files) == 0:
            return None

        hit_files.sort()
        return str(hit_files[0])


class SakuraJson():
    import os
    JSON_PATH: Path = Path(os.path.abspath(__file__)).parent / "macro_config.json"

    def __init__(self):
        with open(SakuraJson.JSON_PATH, "r") as f:
            self.json_load: dict = json.load(f)

    def get_dir_path_from_file(self, tgt_path) -> str:
        projects = self.json_load["project"]
        for proj_name in projects.keys():
            if projects[proj_name]["dir_path"] in tgt_path:
                return projects[proj_name]["dir_path"]
        return ""

    def get_project_list(self) -> List[str]:
        return list(self.json_load["project"].keys())

    def get_project_info(self, pattern: str) -> List[str]:
        projects = self.json_load["project"]
        for proj in projects.keys():
            if pattern.lower() in proj.lower():
                return [projects[proj]["dir_path"], projects[proj]["start_file"]]
        return ["", ""]


def toggle_src_main(tgt_path: str):
    sakura = SakuraJson()
    TglObj = ToggleSrc(sakura.get_dir_path_from_file(tgt_path))
    succeed = TglObj.exe_toggle()
    if succeed:
        sys.exit(0)
    else:
        sys.exit(1)


def search_src_main(tgt_path: str, pattern: str):
    sakura = SakuraJson()
    SearchObj = SearchSrc(sakura.get_dir_path_from_file(tgt_path))
    path = SearchObj.search(pattern)
    if path is None:
        sys.exit(1)
    else:
        sys.stdout.write(path)
        sys.exit(0)


def get_project_main(proj_name: str):
    sakura = SakuraJson()
    if proj_name == "":
        csv_proj = ",".join(sakura.get_project_list())
        sys.stdout.write(csv_proj)
        sys.exit(0)
    else:
        tgt_path, start_file = sakura.get_project_info(proj_name)
        search_src_main(tgt_path, start_file)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--command", help="execute command", type=str, default="")
    parser.add_argument(
        "--tgt_path", help="target project (directory or file)", type=str, default="")
    parser.add_argument("--pattern", help="search pattern", type=str, default="")
    parser.add_argument("--proj_name", help="project name", type=str, default="")
    args = parser.parse_args()

    if args.command == "toggle":
        toggle_src_main(args.tgt_path)
    elif args.command == "search":
        search_src_main(args.tgt_path, args.pattern)
    elif args.command == "project":
        get_project_main(args.proj_name)
