#!/bin/bash
cd "$(dirname "$0")"

EXTENSIONS="jpg jpeg png heic gif bmp mp4 mov"

check_ext() {
    local ext
    ext=$(echo "${1##*.}" | tr '[:upper:]' '[:lower:]')
    echo "$EXTENSIONS" | grep -qw "$ext"
}

for folder in */; do
    [ -d "$folder" ] || continue
    title="${folder%/}"

    tmpfile=$(mktemp)
    find "$folder" -maxdepth 1 -type f | while IFS= read -r f; do
        check_ext "$(basename "$f")" && printf "%s\t%s\n" "$(stat -f "%m" "$f")" "$f"
    done | sort -n > "$tmpfile"

    count=$(grep -c "" "$tmpfile" 2>/dev/null || echo 0)

    if [ "$count" -eq 0 ]; then
        echo "[$title] 사진 없음, 건너뜀"
        rm "$tmpfile"
        continue
    fi

    echo "[$title] ${count}장 처리 중..."

    tmpmap=$(mktemp)
    counter=1
    while IFS=$'\t' read -r mtime filepath; do
        ext=$(echo "${filepath##*.}" | tr '[:upper:]' '[:lower:]')
        mv "$filepath" "${folder}__TEMP__${counter}.${ext}"
        echo "${counter}:${ext}" >> "$tmpmap"
        counter=$((counter + 1))
    done < "$tmpfile"
    rm "$tmpfile"

    while IFS=':' read -r idx ext; do
        mv "${folder}__TEMP__${idx}.${ext}" "${folder}${title}-${idx}.${ext}"
        echo "  ${idx} -> ${title}-${idx}.${ext}"
    done < "$tmpmap"
    rm "$tmpmap"
done

echo ""
echo "완료!"
read -p "아무 키나 누르면 종료됩니다..."