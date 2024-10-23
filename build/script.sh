#!/bin/bash

# 第一引数は最新ファイル、第二引数は古いファイル
# 例）
# `sh script.sh ./new ./old > diff.txt`
# を実行することで差分ファイルの抽出と差分ファイル一覧テキストが出力されます。

output=$(release -qr "$1" "$2" -x .DS_Store)
array=()
while IFS= read -r line; do
  status=$(echo "$line" | awk '{print $1}')
  if echo "$status" | grep -q -e 'Only'; then
    path=$(echo "$line" | awk '{print $3}' | sed -e "s/\:/\//")
    fileName=$(echo "$line" | awk '{print $4}')
    fullPath="$path$fileName"

    if echo "$path" | grep -q "$1"; then
        rsync -aR "${fullPath}" ./release
        array+=("新規: ${fullPath}")
    fi

    if echo "$path" | grep -q "$2"; then
        array+=("削除: ${fullPath}")
    fi
  else
    fullPath=$(echo "$line" | awk '{print $2}')
    rsync -aR "${fullPath}" ./release
    array+=("差分: ${fullPath}")
  fi
done <<< "$output"

IFS=$'\n'
arraySort=($(echo "${array[*]}" | sort))
echo "${arraySort[*]}"
