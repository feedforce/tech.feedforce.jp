#!/bin/sh

#
# <!--more--> を持たない記事は NG なので標準出力に出力
#

cd $HOME/$CIRCLE_PROJECT_REPONAME/source/posts

errors=""

for md in *.md; do
  if ! fgrep -q '<!--more-->' $md; then
    errors="$errors $md"
  fi
done

if [ "$errors" ]; then
  echo "# The following file(s) doesn't have <!--more-->.\n"
  for i in $errors; do echo $i; done
  echo
fi

#
# 幅 1024 pixel 以上の画像は大きすぎるので標準出力に出力
#

cd $HOME/$CIRCLE_PROJECT_REPONAME/source/images

image_width_errors=""

for i in $(find . -type f ! -name ".*"); do
  if [ $(identify -format "%w" $i) -gt 1024 ]; then
    image_width_errors="$image_width_errors\n$(identify -format "%M (width=%w)" $i)"
  fi
done

if [ "$image_width_errors" ]; then
  echo "# The following image(s) width are greater than 1024."
  echo $image_width_errors
fi

#
# 戻り値
#

if [ "$errors" -o "$image_width_errors" ]; then
  exit 1
fi

exit 0

# Local Variables:
# sh-basic-offset: 2
# sh-indentation: 2
# indent-tabs-mode: nil
# End:
