#!/bin/sh

cd source/posts

errors=""

for md in *.md; do
  if ! fgrep -q '<!--more-->' $md; then
    errors="$errors $md"
  fi
done

if [ -z "$errors" ]; then
  exit 0
fi

echo "The following file(s) doesn't have <!--more-->.\n"
for i in $errors; do echo $i; done
exit 1

# Local Variables:
# sh-basic-offset: 2
# sh-indentation: 2
# indent-tabs-mode: nil
# End:
