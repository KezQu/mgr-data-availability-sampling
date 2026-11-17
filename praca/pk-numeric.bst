%% pk-numeric.bst
%% Numeryczny styl bibliografii (BibTeX) zgodny z „Propozycją 2” z wytycznych
%% dla autorów prac dyplomowych (kierunek Informatyka, PK):
%%   - odwołania w tekście: [1], [1-5], [1, 3, 5],
%%   - pozycje w kolejności pierwszego cytowania (jak unsrt),
%%   - zapis: Nazwisko I., Nazwisko I., Tytuł, Czasopismo, vol. 4 nr 2, 2023, s. 100-110.
%%   - źródła internetowe: ..., \url{...} (data dostępu DD.MM.RRRR r.).
%% Pole urldate może mieć postać RRRR-MM-DD (eksport Zotero) lub DD.MM.RRRR.

ENTRY
  { address archiveprefix author booktitle doi edition editor eprint
    howpublished institution journal note number organization pages
    publisher school title type url urldate volume year }
  {}
  { label }

INTEGERS { output.state before.all mid.sentence nameptr namesleft numnames len }

STRINGS { s t longest.label thesis.type }

FUNCTION {init.state.consts}
{ #0 'before.all :=
  #1 'mid.sentence :=
}

FUNCTION {not}
{   { #0 }
    { #1 }
  if$
}

FUNCTION {and}
{   'skip$
    { pop$ #0 }
  if$
}

FUNCTION {or}
{   { pop$ #1 }
    'skip$
  if$
}

FUNCTION {output.nonnull}
{ 's :=
  output.state mid.sentence =
    { ", " * write$ }
    { output.state before.all =
        'write$
        { add.period$ " " * write$ }
      if$
      mid.sentence 'output.state :=
    }
  if$
  s
}

FUNCTION {output}
{ duplicate$ empty$
    'pop$
    'output.nonnull
  if$
}

FUNCTION {output.bibitem}
{ newline$
  "\bibitem{" write$
  cite$ write$
  "}" write$
  newline$
  ""
  before.all 'output.state :=
}

FUNCTION {fin.entry}
{ add.period$
  write$
  newline$
}

FUNCTION {field.or.null}
{ duplicate$ empty$
    { pop$ "" }
    'skip$
  if$
}

FUNCTION {format.names}
{ 's :=
  #1 'nameptr :=
  s num.names$ 'numnames :=
  numnames 'namesleft :=
  ""
    { namesleft #0 > }
    { s nameptr "{vv~}{ll}{, jj}{~f.}" format.name$ 't :=
      nameptr #1 >
        { t "others" =
            { " i~in." * }
            { ", " * t * }
          if$
        }
        { t * }
      if$
      nameptr #1 + 'nameptr :=
      namesleft #1 - 'namesleft :=
    }
  while$
}

FUNCTION {format.authors}
{ author empty$
    { organization field.or.null }
    { author format.names }
  if$
}

FUNCTION {format.editors}
{ editor empty$
    { "" }
    { editor format.names " (red.)" * }
  if$
}

FUNCTION {format.authors.or.editors}
{ author empty$
    { editor empty$
        { organization field.or.null }
        { format.editors }
      if$
    }
    { author format.names }
  if$
}

FUNCTION {n.dashify}
{ 't :=
  ""
    { t empty$ not }
    { t #1 #1 substring$ "-" =
        { t #1 #2 substring$ "--" = not
            { "--" *
              t #2 global.max$ substring$ 't :=
            }
            {   { t #1 #1 substring$ "-" = }
                { "-" *
                  t #2 global.max$ substring$ 't :=
                }
              while$
            }
          if$
        }
        { t #1 #1 substring$ *
          t #2 global.max$ substring$ 't :=
        }
      if$
    }
  while$
}

FUNCTION {format.pages}
{ pages empty$
    { "" }
    { "s.~" pages n.dashify * }
  if$
}

FUNCTION {format.vol.num}
{ volume empty$
    { number empty$
        { "" }
        { "nr~" number * }
      if$
    }
    { "vol.~" volume *
      number empty$
        'skip$
        { " nr~" * number * }
      if$
    }
  if$
}

FUNCTION {format.edition}
{ edition empty$
    { "" }
    { "wyd.~" edition * }
  if$
}

FUNCTION {format.booktitle}
{ booktitle empty$
    { "" }
    { "W:~" booktitle * }
  if$
}

FUNCTION {format.eprint}
{ eprint empty$
    { "" }
    { archiveprefix empty$
        { "arXiv:" eprint * }
        { archiveprefix ":" * eprint * }
      if$
    }
  if$
}

% RRRR-MM-DD -> DD.MM.RRRR; inne zapisy pozostają bez zmian
FUNCTION {format.urldate}
{ urldate text.length$ #10 =
  urldate #5 #1 substring$ "-" = and
    { urldate #9 #2 substring$ "."
      * urldate #6 #2 substring$ *
      "." * urldate #1 #4 substring$ *
    }
    { urldate }
  if$
}

FUNCTION {format.url}
{ url empty$
    { "" }
    { "\url{" url * "}" *
      urldate empty$
        'skip$
        { " (data dost\k{e}pu " * format.urldate * " r.)" * }
      if$
    }
  if$
}

% Jeśli pozycja ma DOI, podawany jest tylko DOI (bez powielania adresu URL).
FUNCTION {format.doi.url}
{ doi empty$
    { format.url }
    { "DOI:~\url{https://doi.org/" doi * "}" * }
  if$
}

FUNCTION {article}
{ output.bibitem
  format.authors output
  title output
  journal output
  format.vol.num output
  year output
  format.pages output
  note output
  format.doi.url output
  fin.entry
}

FUNCTION {book}
{ output.bibitem
  format.authors.or.editors output
  title output
  format.edition output
  publisher output
  address output
  year output
  note output
  format.doi.url output
  fin.entry
}

FUNCTION {inproceedings}
{ output.bibitem
  format.authors output
  title output
  format.booktitle output
  format.editors output
  publisher output
  address output
  year output
  format.pages output
  note output
  format.doi.url output
  fin.entry
}

FUNCTION {incollection} { inproceedings }
FUNCTION {conference} { inproceedings }
FUNCTION {inbook} { inproceedings }

FUNCTION {techreport}
{ output.bibitem
  format.authors output
  title output
  institution output
  type empty$
    { number empty$ 'skip$ { "nr~" number * output } if$ }
    { number empty$
        { type output }
        { type " nr~" * number * output }
      if$
    }
  if$
  year output
  note output
  format.doi.url output
  fin.entry
}

FUNCTION {thesis.common}
{ 'thesis.type :=
  output.bibitem
  format.authors output
  title output
  type empty$ { thesis.type } { type } if$ output
  school output
  address output
  year output
  note output
  format.doi.url output
  fin.entry
}

FUNCTION {mastersthesis} { "praca magisterska" thesis.common }
FUNCTION {phdthesis} { "rozprawa doktorska" thesis.common }

FUNCTION {misc}
{ output.bibitem
  format.authors output
  title output
  howpublished output
  author empty$
    'skip$
    { organization output }
  if$
  publisher output
  format.eprint output
  year output
  note output
  format.doi.url output
  fin.entry
}

FUNCTION {online} { misc }
FUNCTION {electronic} { misc }
FUNCTION {www} { misc }
FUNCTION {manual} { misc }
FUNCTION {unpublished} { misc }
FUNCTION {booklet} { misc }
FUNCTION {software} { misc }
FUNCTION {default.type} { misc }

READ

FUNCTION {initialize.longest.label}
{ "" 'longest.label :=
  #1 'len :=
}

FUNCTION {longest.label.pass}
{ len int.to.str$ 'label :=
  len #1 + 'len :=
  label width$ longest.label width$ >
    { label 'longest.label := }
    'skip$
  if$
}

EXECUTE {initialize.longest.label}

ITERATE {longest.label.pass}

FUNCTION {begin.bib}
{ preamble$ empty$
    'skip$
    { preamble$ write$ newline$ }
  if$
  "\providecommand{\url}[1]{\texttt{#1}}" write$ newline$
  "\begin{thebibliography}{" longest.label * "}" * write$ newline$
}

EXECUTE {begin.bib}

EXECUTE {init.state.consts}

ITERATE {call.type$}

FUNCTION {end.bib}
{ newline$
  "\end{thebibliography}" write$ newline$
}

EXECUTE {end.bib}
