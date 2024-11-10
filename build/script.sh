#!/bin/bash

set -euo pipefail

# 第一引数は最新ファイル、第二引数は古いファイル
# 例） `bash script.sh ./new ./old > diff.txt`
# を実行することで差分ファイルの抽出と差分ファイル一覧テキストが出力されます。

# diffの戻り値が1でビルドジョブが止まるので、一時的にpipefailを無効化
{
    set +o pipefail
    diff -qr "$1" "$2" -x .DS_Store || true
} |
(
    while IFS= read -r line; do
        status=$(echo "$line" | awk '{print $1}')
        if [[ "$status" == "Only" ]]; then
            path=$(echo "$line" | awk '{print $3}' | sed -e "s/:/\//")
            file_name=$(echo "$line" | awk '{print $4}')
            full_path="$path$file_name"
            site_root_path_name=$(echo "$full_path" | sed -e "s|$1||; s|$2||")

            if [[ "$path" == "$1"* ]]; then
                rsync -aR "$full_path" ./release
                echo "新規: $site_root_path_name"
            elif [[ "$path" == "$2"* ]]; then
                echo "削除: $site_root_path_name"
            fi
        else
            full_path=$(echo "$line" | awk '{print $2}')
            site_root_path_name=$(echo "$full_path" | sed -e "s|$1||; s|$2||")
            rsync -aR "$full_path" ./release
            echo "差分: $site_root_path_name"
        fi
    done
)|
LC_COLLATE=C sort -r
