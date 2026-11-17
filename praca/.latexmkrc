# latexmk: LuaLaTeX + BibTeX (styl pk-numeric.bst)
$pdf_mode = 4;
$lualatex = 'lualatex -interaction=nonstopmode -file-line-error -synctex=1 %O %S';
$bibtex_use = 2;
$clean_ext = 'synctex.gz synctex.gz(busy) run.xml lol';
