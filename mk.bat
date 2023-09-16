fbc -e mine.bas -x mine.exe
fbc -e tools/combine.bas -x combine.exe
combine.exe -y -i mine.bas -o minefind.bas
fbc minefind.bas -x minefind.exe
