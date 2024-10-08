\def\filedate{2023/10/01}
\def\fileversion{v0.3alpha}
\def\fileauthor{Sadik Boujaida}

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{cpgedoc}[\filedate\space\fileversion]

%%% Initiation Code
\RequirePackage{pgfopts}
\RequirePackage{etoolbox}
\def\cpgecurrentclass{doc}

\newif\ifconvert

\@ifundefined{ifsubdoc}{
	\newif\ifdraft
	\newif\ifweb
	\newif\ifsingleimage
	\newif\ifdark
	\newif\ifprint
	\newif\ifnocolors
	\newif\ifcompact
	\newif\ifstraight
	\newif\ifstriptitle
	\newif\ifsolution
	\newif\ifproof
	\newif\ifsolutiondelayed
	\newif\ifproofdelayed
	\def\class@options{}
}{}

\pgfkeys{IGCS/.is family, IGCS/.cd,
	draft/.is if=draft,
	solution/.code=\csname solution#1\endcsname\solutiondelayedfalse,%
	solution/.default=true,
	solution*/.is if=solutiondelayed,
	proof/.code=\csname proof#1\endcsname\proofdelayedfalse,%
	proof/.default=true,
	proof*/.is if=proofelayed,
	compact/.is if=compact,
	nocolor/.is if=nocolor, 
	web/.code=\compacttrue\webtrue%
		\ifundef\convert@option{\def\convert@options{}}{}
		\def\cpgecomment@list{#1},
	web/.default={theo,exer},
	convert/.code=\appto\convert@options{,#1},
	singleimage/.is if=singleimage,
	.search also=/IGC,
}
\pgfkeys{IGC/.is family, IGC/.cd,
	report/.code={\def\cpge@class{report}},
	book/.code={\def\cpge@class{book}\cspreto\class@options{oneside}},
	.unknown/.code={%
		\expandafter\appto\expandafter\class@options\expandafter
		{\pgfkeyscurrentname,}
	},
	draft/.style={},
	compact/.style={},
	solution/.style={},
	solution*/.style={},
	proof/.style={},
	proof*/.style={},
	web/.style={},
	convert/.style={},
}
\@ifundefined{ifsubdoc}
	{\ProcessPgfOptions{/IGCS}}
	{\ProcessPgfOptions{/IGC}}

\ifundef\cpge@class{\def\cpge@class{report}}{}
\def\class@options{11pt}
\ifdraft\appto\class@options{,draft}\fi
\begingroup
\edef\cpge@tmpa{\endgroup%
	\noexpand\LoadClass[\class@options]{\cpge@class}
}
\cpge@tmpa

\ifundef\NewDocumentCommand
	{\RequirePackage{xparse}}
	{}

\ifdraft
	\PassOptionsToPackage{draft}{pgf}
	\PassOptionsToPackage{draft}{hyperref}
\fi

%%%% Packages du projet 
\RequirePackage{cpgebase}
\RequirePackage{cpgesubdoc}
\RequirePackage{cpgemath}

%%%%%% Basculement vers la conversion en images %%%%%%	
\ifbool{web}
	{\RequirePackage{cpgeweb}\endinput}{}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage{cpgecommon}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% style d'enumerations dans les theorem %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\def\setup@enumstyle{%
	\let\thecurrent@counter\@gobble%
	\cpgesetenum{1}{marge}
	\cpgesetenum{2}{marge*}
	\cpgesetlabel{unite}{|X|.|1|}%
	\cpgesetlabel{enumi}{|X|.|1|}%
	\cpgesetlabel{enumii}{|Q|.|a|}
	\cpgesetdeco{unite}{\textcolor{thmcol}{\sffamily\small\scshape\bfseries##1.}}
	\cpgesetdeco{enumi}{\bfseries ##1.}%
	\cpgesetdeco{enumii}{\bfseries ##1.}
	\cpgesetdeco{itemtitle}{{\scshape\sffamily##1~:~}}
	\cpgesetdeco{unitetitle}{\textcolor{thmcol}{\sffamily\scshape\small##1~:~}}
	\cpgesetlabel{equation}{|C|.|1|}
	\makethetolabel{equation}
}
\def\setup@enumspaces{
	\ifcompact
		\cpgesetenum*{1}{marge*}
		\cpgesetenum*{2}{marge*=1pc}
		\cpgesetenum*{3}{marge*=1pc}
	\else	
		\cpgesetenum*{1}{marge+}
		\cpgesetenum*{2}{marge*}
		\cpgesetenum*{3}{marge+}
	\fi
	\ifprint 
		\cpgesetenum{0}{align=l}
	\fi 
}

\newtoks\toks@sol
\newtoks\toks@prv
\cpgedefcounter{theo}{|C|.|1|}[chapter]
\cpgedefcounter{defi}{|C|.|1|}[chapter]
\cpgedefcounter{rema}{|C|.|1|}[chapter]
\cpgedefcounter{exem}{|C|.|1|}[chapter]
\cpgedefcounter{exer}{|C|.|1|}[chapter]
\cpgedefcounter{genthm}{|C|.|1|}[chapter]

\RequirePackage{cpgethm}

\let\solu\cpge@dummy@
\let\preuve\cpge@dummy@
\newif\ifdelayedprooforsolution
\def\setup@solproofmode{%
	\unless\ifdraft%
		\ifsolution\def\solu{\solution@push*}\fi%
		\ifproof\def\preuve{\proof@push*}\fi%
		\ifsolutiondelayed%
			\solutiontrue%
			\delayedprooforsolutiontrue%
			\let\solu\solution@push%
		\fi%
		\ifproofdelayed%
			\prooftrue%
			\delayedprooforsolutiontrue%
			\let\preuve\proof@push%
		\fi%
		\ifdelayedprooforsolution%
			\unless\ifcpgerecordfileopen%
				\cpgestartrecording%
			\fi%
		\fi%
	\fi%
}
\def\setup@straightmode{%
	\ifstraight
		\ifsolution
			\def\solution{\draft@solution}%
		\fi
		\ifproof
			\def\proof{\draft@proof}%
		\fi%
	\fi%
}
\AtBeginDocument{%
	\setup@draftmode
	%\setup@straightmode%
	\setup@solproofmode%
}


%%%%% Other package initialisation
%\RequirePackage{currfile}
\RequirePackage{lastpage}
\RequirePackage{fontawesome}

%\RequirePackage{bookmark}


%%%% Strategie d'inclusion de fichier
\newif\ifincluded 
\cpgesetup[include]{
	solution/.code=\csname solution#1\endcsname\solutiondelayedfalse,
	solution*/.is if=solutiondelayed,
	proof/.code=\csname proof#1\endcsname\proofdelayedfalse,
	proof*/.is if=proofdelayed,
	% straight/.code=\csname straight#1\endcsname,
	before solutions/.code=\def\before@solutions@hook{#1},
	only/.code=\csvtolistadd\eno@list{#1},%
	solution section/.code 2 args=\def\sol@section{#1}\def\sol@title{#2},
	solution section/.default={\section}{Solutions des exercices},
	proof section/.code 2 args=\def\prv@section{#1}\def\prv@title{#2},
	proof section/.default={\section}{Démonstrations des résultats},
	solution section, proof section 
}
\DeclareDocumentCommand\cpgeinclude{om}{%%
	\begingroup%
	\toks@sol{}%
	\toks@prv{}%
	\includedtrue
	\def\current@file{#2}
		%\RenewDocumentCommand\titre{s e\op +d()}{}%
		\ifdraft
			\subdoc{#2}
		\else
			\IfValueT{#1}{\cpgesetup[solutions]{#1}}%
			\setup@solproofmode%
			\subdoc{#2}%
			\processproofs%
			\processsolutions%
		\fi%
	\endgroup%
}
\def\processproofs{
	\unless\ifdraft%
		\ifproofdelayed%
			\edef\cpge@tmpe{\the\toks@prv}%
			\unless\ifcpgerecordfileopen\cpgestartrecording\fi%
			\ifdefvoid\cpge@tmpe{}{%
				\protected@edef\cpge@tmpa{\proofsection{\prv@title\space du \chaptername\space\thechapter}}%
				\cpgerecord{\expandonce\cpge@tmpa}
				\cpgerecord{\the\toks@prv}%
			}%
		\fi%
	\fi%
}
\def\processsolutions{%
	\unless\ifdraft%
		\ifsolutiondelayed%
			\edef\cpge@tmpe{\the\toks@sol}%
			\unless\ifcpgerecordfileopen\cpgestartrecording\fi%
			\ifdefvoid\cpge@tmpe{}{%
				\protected@edef\cpge@tmpa{\solutionsection{\sol@title\space du \chaptername\space\thechapter}}%
				\cpgerecord{\expandonce\cpge@tmpa}%
				\cpgerecord{\the\toks@sol}% 
			}%
		\fi%
	\fi%
}
\newrobustcmd\proofsection[1]{
	\ifx\preuve\proof@push\prv@section{#1}\fi
}
\newrobustcmd\solutionsection[1]{
	\ifx\solu\solution@push\sol@section{#1}\fi
}
\def\typeout@solutions{%
	\clearpage%
	\sol@section{\sol@title}%
	\let\solu\solution@push%
	\cpge@tmpe%
	\let\solu\cpge@dummy@%
}
\def\typeout@proofs{%
	\clearpage%
	\prv@section{\prv@title}%
	\let\preuve\proof@push%
	\cpge@tmpe%
	\let\preuve\cpge@dummy@%
}

\def\solutions{%
	\ifsolutiondelayed%
		\ifcpgerecordfileopen%
			\cpgestoprecording%
		\fi%
		\let\preuve@\preuve%
		\let\preuve\cpge@dummy%
		\InputIfFileExists{\jobname.rec}{}{}
		\let\preuve\preuve@%
	\fi%
}
\def\proofs{%
	\ifproofdelayed
		\ifcpgerecordfileopen%
			\cpgestoprecording%
		\fi%
		\let\solu@\solu%
		\let\solu\cpge@dummy%
		\InputIfFileExists{\jobname.rec}{}{}
		\let\solu\solu@%
		% {
		% 	\input{\jobname.rec}%
		% }
	\fi%
}
\AtEndDocument{\ifcpgerecordfileopen\cpgestoprecording\fi}

\def\cpgeincludeweb#1{} 

%% Formats par defaut des titres
\cpgesettitle{|document| \\ |theme| \\ |periode|}
\cpgesettitle*{|document| \\ |theme| \\ |periode|}

%%%% Chargement des differents packages 
\usetikzlibrary{calc}
\tikzset{
    every picture/.prefix style={
        execute at begin picture=\shorthandoff{;}
    }
}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% styles pour les titres de sections %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	   
\cpgesetlabel{chapter}{|1|}
\cpgesetlabel{section}{|I|}
\cpgesetlabel{subsection}{|S|.|1|}	   
	   
\cpgesetuptcb{chapter style/.style={}}
\tikzset{chapter label style/.style={}}
\cpgesetuptcb{section style/.style={}}
\tikzset{section label style/.style={}}

\cpgesetup{sectiontitle/.is family, sectiontitle,
	chapter style/.code={\cpgesetuptcb{chapter style/.style={#1}}},
	chapter label style/.code={\tikzset{chapter label style/.style={#1}}},
	chapter label decoration/.store in=\chapter@label@deco,
	section style/.code={\cpgesetuptcb{section style/.style={#1}}},
	section label style/.code={\tikzset{section label style/.style={#1}}},
	subsection label style/.code={\tikzset{subsection label style/.style={#1}}},
	after section hook/.store in=\aftersection@hook,
	chapter label anchor/.store in=\cpge@chapter@anchor,
	chapter label anchor=north east,
	section label anchor/.store in=\cpge@section@anchor,
	section label anchor=west,
}
\cpgesetlabel{chapter}{|1|}
\cpgesetup[sectiontitle]{%
chapter style={%
	colback=pagecol,
	coltext=textcol,
	boxrule=0pt,
	lowerbox=ignored,
   },
chapter label style={},
section style={%
    boxrule=0pt,
    coltext=textcol,
    colback=pagecol,
    fontupper=\itshape,
    },
section label style={},
subsection label style={}
}
\titleformat{name=\chapter}[display]
     {\normalfont\huge\scshape}
     {}
     {0pt}
     {%
       \begin{tcolorbox}[
				 enhanced,
         chapter style,
         overlay={
           \node (chapter label) [chapter label style] 
           at (frame.\cpge@chapter@anchor)
           {\label@chapter};
					 \csuse{chapter@label@deco}
         } 
       ]
      #1
       \end{tcolorbox}%
     }
\titleformat{name=\chapter,numberless}[display]
     {\normalfont\huge}
     {}
     {0pt}
     {%
       \begin{tcolorbox}[chapter style]
       \filright #1
       \end{tcolorbox}%
     }
%\titlespacing*{\chapter}{\z@}{-2cm}{*-2}
\titleformat{\section}[block]
     {\sffamily\Large\scshape}
     {}
     {0pt}
     {%
       \begin{tcolorbox}[
         section style,
         overlay={
           \node (section) [section label style] 
           at (frame.\cpge@section@anchor)
           {\label@section};
         },
         force nobeforeafter,
		 overlay={\csuse{aftersection@hook}}
       ]
       \vphantom{(}#1
       \end{tcolorbox}%
     }
\titleformat{name=\section,numberless}
     {\sffamily\Large\scshape}
     {}
     {0pt}
     {%
       \begin{tcolorbox}[%
       		section style,
			force nobeforeafter
		]
       \vphantom{(}#1
       \end{tcolorbox}%
     }
\titleformat{\subsection}
	{\sffamily\large\scshape} 
	{\tikz[baseline=(S.base)]\node(S)[subsection label style] {\label@subsection};}
	{3pt}
	{\itshape#1}

\let\fakebox\@iden 



\cpgesetup{simple deco/.code={%
			\cpgesetdeco{simple}{\simple@label@font#1}%
			\let\deco@lrmargin\deco@simple},
	   simple label font/.code={\def\simple@label@font{#1\vphantom{(}}},
}
\cpgesetup{%
	simple deco=\textcolor{thmcol}{\fbox{#1}}\enskip,
	simple label font=\scshape\sffamily\footnotesize,
}
\cpgesetup[mini]{
	left margin=1pc,
	right margin=0pt,
	font=\sffamily\footnotesize
	}
%%% Boite tikz générique pour différentes décorations (notamment pour les formules)
\NewDocumentCommand\genboxcmd{O{}m}{\fbox{#2}}
\cpgesetdeco{indication}{\textbf{#1 :}\kern4pt}
\unless\ifdraft
	\tikzset{generic style/.style={fill=none, draw=framestrokecol, inner sep = 3pt, rounded corners=3pt}}
	\RenewDocumentCommand\genboxcmd{O{} +m}{%
		\tikz [baseline=(T.base)] \node (T) [generic style, #1] {\strut #2};
}
\fi


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Gestion des demos et des solutions %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Enregistrement des demo/solutions dans des fichiers individuels 
%%% et creation des hyperliens.
%%% Une token list contient la liste des commandes d'inclusion 
%%% des fichiers crées. 
%%% si les fichiers doivent être inclu en fin du fichier en cours
%%% la token list est exécutée (et vidée) sinon son contenu
%%% est ajouté à un fichier record. Celui-ci peut être inclu ensuite
%%% par l'utilisateur à un endroit de son choix.  

\def\out@dir{output}
\def\aux@dir{tmp}
\def\draft@solution{%
	\exit\closeunite%
	\tcbsubtitle[default subtitle]{Solution}%
	\set@defaultforlistsinsideunite%
}
\def\draft@proof{%
	\exit\closeunite%
	\tcbsubtitle[default subtitle]{Démonstration}%
	\set@defaultforlistsinsideunite%
}
\cpgesetuptcb{default subtitle/.style={%
		spartan,
		coltext=white,
		colback=thmcol,
		colbacktitle=thmcol,
		boxrule=0pt,
		boxsep=0pt,
		top=.8pt,
		bottom=.8pt
	}
}
\IfFileExists{/dev/null}
		{\immediate\write18{mkdir -p \aux@dir}}
		{\immediate\write18{md  "\aux@dir"}}%

%% Styles des hyperliens demo/solution
\def\set@demolink{
	\ifprint
	   \cpgesetuptcb{
	   		@demolink/.style n args={3}{
				size=##1, arc=##2,
				demolink,
				colframe=linkstrokecol, coltext=linktextcol, colback=pagecol,
				##3
			}
	   }
	\else
		\cpgesetuptcb{
	   		@demolink/.style n args ={3}{
				size=##1, arc=##2,
				demolink,
				colframe=linkstrokecol, coltext=white, colback=linkbackcol,
				##3
			}
	   }
	\fi 
}
\cpgesetuptcb{demolink/.style={}}
\appto\endpreamble@hook{\set@demolink}
%%% Lien vers demo/solution en bas d'un énoncé.  
\let\current@prv\relax
\let\current@sol\relax
\def\cpge@theorem@label{}%
\def\curr@counter{}
\def\@demolink#1#2{%
	\par\nopagebreak\vskip-\baselineskip%
	\vbox to\z@{\null\hfill\tcbox[
			enhanced, nobeforeafter,
			@demolink={tight}{2.4pt}{},
			hyperlink={#1@\thetcbcounter}, 
		]
		{\null\hskip5pt\sffamily\fontsize{8}{8}\scshape\vphantom{(}%
			#2 \ref*{#1:\cpge@theorem@label},
			page \pageref*{#1:\cpge@theorem@label}
			\hskip5pt\null%
		}
}}
\def\@titledemolink{
	\@ifstar\@titledemolink@\@titledemolink@@
}
\def\@titledemolink@@#1#2#3#4#5#6{
		\@hangfrom{
			\tcbox[
				enhanced,tcbox raise base,
				enlarge left by=-14pt,
				left=6pt, right=6pt,
				@demolink={small}{8pt}{},
				hyperlink={#1@#2},
				hypertarget={#4@#2},
  				%phantomlabel={#4@#2},
  			]
			{\null\hskip6pt\sffamily\scshape\small\vphantom{)}%
				#5 #3~#2\hskip6pt\null}\enskip}%
	\ifblank{#6}{}{({\scshape\footnotesize #6})}%
		\protected@edef\@currentlabel{#2}%
		\ifblank{#6}{}{\protected@edef\@currentlabelname{#6}}%
		\@xp\@xp\@xp\Hy@MakeCurrentHrefAuto\@xp\@xp\@xp	
			{\csname#4name\endcsname}%
		\Hy@raisedlink{\hyper@anchorstart{\@currentHref}\hyper@anchorend}%
		\label{#4:\cpge@theorem@label}%
	\vrule width \z@  depth\bigskipamount%
	\par\penalty\@M%
}
\def\@titledemolink@#1#2#3#4#5#6{
		\@hangfrom{
			\tcbox[
				enhanced,tcbox raise base,
				enlarge left by=-14pt,
				left=6pt, right=6pt,
				@demolink={small}{8pt}{colframe=strokecol, colback=pagecol, coltext=textcol}
  			]
			{\null\hskip6pt\sffamily\scshape\small\vphantom{)}%
				#5 #3~#2\hskip6pt\null}\enskip}%
	\vrule width \z@  depth\bigskipamount%
	\par\penalty\@M%
}
\def\@recsol{%
	\protected@edef\current@sol{%
		\noexpand\solu%
			{\cpge@theorem@envname}
			{\thetcbcounter}
			{\cpge@theorem@label}
			{\cpge@@theorem@prefixedname}
			{\cpge@theorem@title}
			{\aux@dir/sol-\thetcbcounter}%
	}%
	\ifsolutiondelayed
		\edef\cpge@tmpe{\the\toks@sol^^J\expandonce\current@sol}
		\global\@xp\toks@sol\@xp{\cpge@tmpe}
	\else
	   \ifsolution%
	   		\global\cslet{sol@\thetcbcounter}\current@sol%
		\fi%
	\fi% 
}
\def\@recprv{%
	\protected@edef\current@prv{%
		\noexpand\preuve
			{\cpge@theorem@envname}
			{\thetcbcounter}
			{\cpge@theorem@label}
			{\cpge@@theorem@prefixedname}
			{\cpge@theorem@title}
			{\aux@dir/prv-\thetcbcounter}%
	}%
	\ifproofdelayed
		\edef\cpge@tmpe{\the\toks@prv^^J\expandonce\current@prv}
		\global\@xp\toks@prv\@xp{\cpge@tmpe}
	\else
	   \ifproof%
	   		\global\cslet{prv@\thetcbcounter}\current@prv%
		\fi%
	\fi% 
}
\cpgesetuptcb{
	before eapp/.code={\eappto\kvtcb@beforebox{#1}},%
  	before epre/.code={\epreto\kvtcb@beforebox{#1}},%
  	after eapp/.code={\eappto\kvtcb@afterbox{#1}},%
  	after epre/.code={\epreto\kvtcb@afterbox{#1}},%
}
\def\setup@draftmode{
	\ifdraft
		\let\solution\draft@solution
		\let\proof\draft@proof
		\cpgesetuptcb{%
			with@solu/.style={},
			with@proof/.style={},
			def@label/.style={}, 
			with proof/.style={},
			with solution/.style={}
		}
	\else 
		\def\proof@link{\ifproofdelayed\@demolink{proof}{démonstration}\fi}
		\def\solution@link{\ifsolutiondelayed\@demolink{solution}{solution}\fi}
		\cpgesetuptcb{%
			with solution/.style={%
				lowerbox=ignored,
				before upper app=\edef\cpge@theorem@label{%
					\ifdefvoid\cpge@theorem@label
						{\thetcbcounter}
						{\cpge@theorem@label}%
					}%
					\xdef\curr@counter{\thetcbcounter}%
					\def\solution{\solution@link\@recsol\tcblower},
				savelowerto=\aux@dir/sol-\thetcbcounter.tex,
				after app=\csuse{sol@\curr@counter}
			},
			with proof/.style={%
				lowerbox=ignored,
				before upper app=\edef\cpge@theorem@label{%
					\ifdefvoid\cpge@theorem@label
						{\thetcbcounter}
						{\cpge@theorem@label}%
					}%
					\xdef\curr@counter{\thetcbcounter}%
					\def\proof{\proof@link\@recprv\tcblower},
				savelowerto=\aux@dir/prv-\thetcbcounter.tex,
				after app=\csuse{prv@\curr@counter}
			},
		}
	\fi 
}
%%%%% commandes de traitement  des demos/solutions
\newrobustcmd\solutionname{solution}
\newrobustcmd\proofname{d\'emonstration}
\def\cpge@thmlabel@prefix{}
\newrobustcmd\solution@push{\file@push{solution}}
\newrobustcmd\proof@push{\file@push{proof}}
\DeclareDocumentCommand{\file@push}{msmmmmmm}{%
\begin{trivlist}%
	\def\cpge@thmlabel@prefix{#1}
	\def\cpge@theorem@label{#5}%
	\IfBooleanTF{#2}
		{\item[]\@titledemolink*{#3}{#4}{#6}{\cpge@thmlabel@prefix}{\csname #1name\endcsname}{#7}}
		{\item[]\@titledemolink{#3}{#4}{#6}{\cpge@thmlabel@prefix}{\csname #1name\endcsname}{#7}}
	\edef\thecurrent@counter{#4}
	\set@defaultforlistsinsideunite
 		\input{#8}%
	\exit%
	\closeunite%
\end{trivlist}%
}

\def\cpge@dummy@#1#2#3#4#5#6{}
\let\preuve\cpge@dummy@
\let\solu\cpge@dummy@

%%% Systeme des réfeŕences croisées
\def\solutionautorefname{\solutionname}
\def\proofautorefname{\proofname}
\cpgesetdeco{pageref}{\sffamily\smaller{}[p. #1]}
\def\set@pageref#1#2{%
	\ifcsdef{r@#2}%
		{\def\pageref@eno{%
			\space\deco@pageref{\pageref*{#2}}}%
		}{}%
	\ifcsdef{r@#1:#2}%
		{\def\pageref@cor{%
			\space\deco@pageref{\pageref*{#1:#2}}}%
		}{}%
}
\NewDocumentCommand\xref{s t\n t\e t\c t\p t\t m}{%
	\IfBooleanTF{#2}
		{\def\xref@ref{\ref}}
		{\def\xref@ref}{\autoref}
	\IfBooleanTF{#1}
		{\def\x@ref{\xref@ref*}}
		{\def\x@ref{\xref@ref}}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% redefinition des environements pour theoremes %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\cpgerenewtheorem[use counter=theo, number within=chapter]{theo}
	{Théorème}
	{théorème}
	{du\space}
	{theorem}
	{titled items, with proof}	
\cpgerenewtheorem[use counter from=theo]{theodef}
	{Théorème et définition}
	{théorème}
	{du\space}
	{theorem}
	{titled items, with proof}
\cpgerenewtheorem[use counter from=theo]{propdef}
	{Proposition et définition}
	{proposition}
	{de la\space}
	{theorem}
	{titled items, with proof}
\cpgerenewtheorem[use counter from=theo]{prop}
	{Proposition}
	{proposition}
	{de la\space}
	{theorem}
	{titled items, with proof}
\cpgerenewtheorem[use counter from=theo]{lemm}
	{Lemme}
	{lemme}
	{du\space}
	{theorem}
	{with proof}
\cpgerenewtheorem[use counter from=theo]{ppte}
	{Propriétés}
	{propriétés}
	{des\space}
	{theorem}
	{titled items, with proof}
\cpgerenewtheorem[use counter from=theo]{coro}
	{Corollaire}
	{corollaire}
	{du\space}
	{theorem}
	{titled items, with proof}
\cpgerenewtheorem[use counter=exer, number within=chapter]{exer}
	{Exercice}
	{exercice}
	{de l'}
	{exercise}
	{titled items, with solution}
\cpgerenewtheorem[use counter from=exer]{exerappli}
	{Exercice d'application}
	{exercice}
	{de l'}
	{exercise}
	{titled items}
\cpgerenewtheorem[use counter from=exer]{exerappro}
	{Exercice d'approfondissement}
	{exercice}
	{de l'}
	{exercise}
	{titled items, with solution}
\cpgerenewtheorem[use counter from=exer]{prob}
	{Problème}
	{problème}
	{du\space}
	{exercise}
	{titled items, with solution}

\endinput




