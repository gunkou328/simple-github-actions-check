#!/bin/bash

# 第一引数は最新ファイル、第二引数は古いファイル
# 例）
# `bash script.sh ./new ./old > diff.txt`
# を実行することで差分ファイルの抽出と差分ファイル一覧テキストが出力されます。

# 差分を取得
output=$(diff -qr "$1" "$2" -x .DS_Store)
array=()

# 差分を解析
while IFS= read -r line; do
  status=$(echo "$line" | awk '{print $1}')
  if [[ "$status" == "Only" ]]; then
    path=$(echo "$line" | awk '{print $3}' | sed -e "s/:/\//")
    fileName=$(echo "$line" | awk '{print $4}')
    fullPath="$path$fileName"
    siteRootPathName=$(echo "$fullPath" | sed -e "s|$1||; s|$2||")

    if [[ "$path" == "$1"* ]]; then
        rsync -aR "$fullPath" ./release
        array+=("新規: $siteRootPathName")
    elif [[ "$path" == "$2"* ]]; then
        array+=("削除: $siteRootPathName")
    fi
  else
    fullPath=$(echo "$line" | awk '{print $2}')
    siteRootPathName=$(echo "$fullPath" | sed -e "s|$1||; s|$2||")
    rsync -aR "$fullPath" ./release
    array+=("差分: $siteRootPathName")
  fi
done <<< "$output"

# 結果をソートして出力
IFS=$'\n'
arraySort=($(echo "${array[*]}" | sort))
echo "${arraySort[*]}"
