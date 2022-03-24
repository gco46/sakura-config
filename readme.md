# Config / Macro for Sakura Editor

## Description

サクラエディタ用の設定ファイル、マクロ集です。

設定ファイルは以下を含みます。

- キー割り当て (`config.key`)
- C/C++用設定 (`c_cpp/`)

マクロは以下のコマンドを実装しています。

- Insert Line Below (`InsearLine.vbs`)
- Indent Line / Outdent Line (`IndentTab.vbs`, `UnindentTab.vbs`)
- Search Files by Name (`open_file.vbs`)
- Open Registered File (`open_project.vbs`)

## Requirement

- Sakura Editor == 2.4.1
- python >= 3.8.10

## Install

設定ファイルは設定->共通設定->キー割り当て、及びタイプ別設定一覧からインポートできます。

マクロは`external_macro/`以下のファイルをサクラエディタ設定ファイル(`sakura.ini`)の同階層に配置することで利用できます。

## Usage

以下マクロは`util/`内を参照します。

- Search Files by Name
- Open Registered File

これらのマクロを使用する際は`util/macro_config.json`を設定してください

```json
{
    "project": {
        "proj_name": {
            "dir_path": "absolute/path/to/project/directory",
            "start_file": "startfile.c"
        }
    }
}
```

- `proj_name`: Open Registered File使用時、プロジェクト一覧表示に使用されます。
	key名は任意であり、複数設定可能です。valueは`dir_path`と`start_file`を取ります。
	- `dir_path`: valueにプロジェクトディレクトリの絶対パスを指定します。
	- `start_file`: valueにプロジェクトディレクトリ内で最初に開くファイルを指定します。(現状、`.c`, `.h`, `.s`, `.asm`のみ指定可能)
