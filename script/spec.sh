#!/bin/sh

set -eu

#
# <!--more--> を持たない記事は NG なので標準エラー出力に出力
#

cd $HOME/$CIRCLE_PROJECT_REPONAME/source/posts

errors=""

for md in *.md; do
  if ! fgrep -q '<!--more-->' $md; then
    errors="$errors $md"
  fi
done

if [ "$errors" ]; then
  echo "# The following file(s) doesn't have <!--more-->.\n" >&2
  for i in $errors; do echo $i >&2; done
  echo >&2
fi

#
# 記事画像の幅は 1024 pixel 以下とする。
# それより大きな画像は標準エラー出力に出力。
#

cd $HOME/$CIRCLE_PROJECT_REPONAME/source/images

image_width_errors=""

for i in $(find . -type f ! -name ".*"); do
  if [ $(identify -format "%w" $i) -gt 1024 ]; then
    image_width_errors="$image_width_errors\n$(identify -format "%M (width=%w)" $i)"
  fi
done

if [ "$image_width_errors" ]; then
  echo "# The following image(s) width are greater than 1024." >&2
  echo $image_width_errors >&2
  echo >&2
fi

#
# プロフィール画像の幅は 300 pixel 以下とする。
# それより大きな画像は標準エラー出力に出力。
#

cd $HOME/$CIRCLE_PROJECT_REPONAME/source/images/authors

image_width_errors2=""

for i in *; do
  if [ $(identify -format "%w" $i) -gt 300 ]; then
    image_width_errors2="$image_width_errors2\n$(identify -format "%M (width=%w)" $i)"
  fi
done

if [ "$image_width_errors2" ]; then
  echo "# The following image(s) width are greater than 300." >&2
  echo $image_width_errors2 >&2
  echo >&2
fi

#
# 戻り値
#

if [ "$errors" -o "$image_width_errors" -o "$image_width_errors2" ]; then
  exit 1
fi

exit 0

# Local Variables:
# sh-basic-offset: 2
# sh-indentation: 2
# indent-tabs-mode: nil
# End:
