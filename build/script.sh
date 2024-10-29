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
    # サイトのルート相対パスに合わせる
    fullPathName=$(echo "$fullPath" | sed -e 's|.*\(/enjoy.*\)|\1|')

    if [[ "$path" == "$1"* ]]; then
        rsync -aR "$fullPath" ./release
        array+=("新規: $fullPathName")
    elif [[ "$path" == "$2"* ]]; then
        array+=("削除: $fullPathName")
    fi
  else
    fullPath=$(echo "$line" | awk '{print $2}')
    # サイトのルート相対パスに合わせる
    fullPathName=$(echo "$fullPath" | sed -e 's|.*\(/enjoy.*\)|\1|')
    rsync -aR "$fullPath" ./release
    array+=("差分: $fullPathName")
  fi
done <<< "$output"

# 結果をソートして出力
IFS=$'\n'
arraySort=($(echo "${array[*]}" | sort))
echo "${arraySort[*]}"
