#!/bin/zsh  

mkdir -p ~/Library/texmf/tex/luatex/markdown
mkdir -p ~/Library/texmf/tex/latex/markdown
mkdir -p ~/Library/texmf/scripts/markdown
mkdir -p ~/Library/texmf/tex/generic/markdown 
mkdir -p ~/Library/texmf/tex/context/third/markdown

make base
cd ./libraries
make
cd ..

cp ./markdown.lua 						~/Library/texmf/tex/luatex/markdown
cp ./libraries/markdown-tinyyaml.lua 	~/Library/texmf/tex/luatex/markdown
cp ./markdown-cli.lua 					~/Library/texmf/scripts/markdown
cp ./markdown.tex						~/Library/texmf/tex/generic/markdown 		
cp *.sty								~/Library/texmf/tex/latex/markdown
cp ./t-markdown.tex					~/Library/texmf/tex/context/third/markdown

rm ./markdown.lua 						
rm ./libraries/markdown-tinyyaml.lua 
rm ./markdown-cli.lua 					
rm ./markdown.tex								
rm *.sty								
rm ./t-markdown.tex					
