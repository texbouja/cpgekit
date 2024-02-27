\def\filedate{2023/10/01}
\def\fileversion{v0.3alpha}
\def\fileauthor{Sadik Boujaida}

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{igdoc}[\filedate\space\fileversion]

%%% Initiation Code
\RequirePackage{pgfopts}
\RequirePackage{etoolbox}
\def\igcurrentclass{igdoc}

\newif\ifconvert

\@ifundefined{ifsubdoc}{
	\newif\ifigweb
	\newif\ifsingleimage
	\newif\ifthisfile
	\newif\ifcours
	\newif\ifserie
	\newif\ifcolle
	\newif\ifsoutien 
	\newif\ifdraft
	\newif\ifprint
	\newif\ifnocolors
	\newif\ifdark
	\newif\ifcompact
	\newif\ifstriptitle
	\newif\ifsolution
	\newif\ifproof
	\newif\ifsolutiondelayed
	\newif\ifproofdelayed
	\newif\ifwritetosolfile
	\def\class@options{}
}{}

\pgfkeys{IGCS/.is family, IGCS/.cd,
	draft/.is if=draft,
	solution/.is if=solution,
	solution*/.is if=solutiondelayed,
	proof/.is if=proof,
	proof*/.is if=proofdelayed,
	wsf/.is if=writetosolfile
	compact/.is if=compact,
	nocolor/.is if=nocolor, 
	web/.code=\compacttrue\igwebtrue\def\convert@options{}
		\def\igcomment@list{quiz,notations,#1},
	web/.default={},
	singleimage/.is if=singleimage,
	thisfile/.is if=thisfile,
	cours/.code={%
		\courstrue
		\ifundef{\ig@class}{\def\ig@class{book}}{}
	},
	serie/.code={%
		\serietrue
		\ifundef{\ig@class}{\def\ig@class{article}}{}
	},
	soutien/.code={
		\soutientrue\courstrue
		\ifundef{\ig@class}{\def\ig@class{article}}{}
	},
	article/.code={
		\def\ig@class{article}
	},
	report/.code={
		\def\ig@class{report}
	},
	book/.code={
		\def\ig@class{book}
	},
	.search also=/IGC,
}
\pgfkeys{IGC/.is family, IGC/.cd,
	.unknown/.code={%
		\expandafter\appto\expandafter\class@options\expandafter		
		{\pgfkeyscurrentname,}
	},
	convert/.code=\ifundef\igcomment@list{\pgfkeysalso{web}}{}\appto\convert@options{,convert={#1}},
	convert/.default=true,
	draft/.style={},	
	soutien/.style={},
	compact/.style={},
	solution/.style={},
	proof/.style={},
	wsf/.style={},
	cours/.style={},
	serie/.style={},
	article/.style={},
	report/.style={},
	book/.style={},
}
\@ifundefined{ifsubdoc}
	{\ProcessPgfOptions{/IGCS}}
	{\ProcessPgfOptions{/IGC}}

\ifundef\ig@class{\def\ig@class{article}}{}
\ifdraft\appto\class@options{draft}\fi
\begingroup
\edef\ig@tmpa{\endgroup%
	\noexpand\LoadClass[\class@options]{\ig@class}
}
\ig@tmpa
\ifdraft
		\PassOptionsToPackage{draft}{pgf}
		\PassOptionsToPackage{draft}{hyperref}
		\PassOptionsToPackage{draft}{igcours}
\fi
\AtEndPreamble{%
	\ifnocolors\selectcolormodel{gray}\fi
}

\newtoks\toks@sol
\newtoks\toks@prv 

\newif\ifchapter@in@class
\ifundef\c@chapter{}{\chapter@in@classtrue}
\ifundef\NewDocumentCommand
	{\RequirePackage{xparse}}
	{}

%%%% Packages du projet 
\RequirePackage{igbase}
%\RequirePackage{igsubdoc}
\RequirePackage{igmath}
\RequirePackage{igcommon}
\ifbool{igweb}
	{\RequirePackage{standalone}\endinput}
	{\RequirePackage{igsubdoc}}
\RequirePackage{igcours}

\newif\ifrecord@active
\ifsolutiondelayed\solutiontrue\fi%
\ifproofdelayed\prooftrue\fi% 
\AtBeginDocument{%
	\ifsolutiondelayed
		\tcbstartrecording[\jobname.rec]
		\record@activetrue
	\else
		\ifproofdelayed
			\tcbstartrecording[\jobname.rec]
			\record@activetrue
		\fi 
	\fi	
}



%%%% Chargement des differents packages 
\RequirePackage{tcolorbox}
\tcbuselibrary{skins,hooks}
\usetikzlibrary{calc}
\tikzset{
    every picture/.prefix style={
        execute at begin picture=\shorthandoff{;}
    }
}
\RequirePackage[unicode,naturalnames]{hyperref}
\hypersetup{colorlinks,linkcolor=linkcol}
\pdfstringdefDisableCommands{%
	\def\({}%
	\def\){}%
}
\let\ToP\texorpdfstring
\AtEndPreamble{
	\ifdefempty{\load@thefonts}{\igusefont{rm}}{} 
	\load@thefonts
}
\def\disable@pageanchor{%
	\ifx\hypersetup\@undefined\else\hypersetup{pageanchor=false}\fi%
	}

% %%%% Gestion des themes
% \newdimen\ig@ttlw
% \ig@ttlw=3cm
% \igset[theme]{%
% 	.search also={/ig/colors},
% 	dark/.is if=dark,
% 	colors/.code=\pgfkeysalso{/ig/colors/.cd,#1},
% 	no colors/.is if=nocolors,
% 	font/.code=\igusefont{#1},
% 	rm/.style={font=rm},
% 	sf/.style={font=sf},
% 	title page/.is if=titlepage,
% 	title format/.code=\igdeftitleformat{#1},
% 	title format*/.code=\igdeftitleformat*{#1},
% 	scale title/.code=
% 		\AtEndPreamble{\pgfmathsetlength\ig@ttlw{\ig@ttlw/#1}} 
% }
% \igset[title]{%
% 	scale/.code=\AtEndPreamble{\pgfmathsetlength\ig@ttlw{\ig@ttlw/#1}}
% }
\DeclareDocumentCommand\igusetheme{O{} m}{%
	\igset[theme]{#1}
	\unless\ifdraft
		\IfFileExists{#2.sty}
			{\AtEndPreamble{\RequirePackage{#2}}}{}%
	\fi%
	\reloadcolors%
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% styles pour les titres de sections %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	   
\igdeflabel{chapter}{|1|}
\igdeflabel{section}{|I|}
\igdeflabel{subsection}{|S|.|1|}	   
	   
\tcbset{chapter style/.style={}}
\tikzset{chapter label style/.style={}}
\tcbset{section style/.style={}}
\tikzset{section label style/.style={}}

\igset{sections/.is family, sections,
	chapter style/.code={\tcbset{chapter style/.style={#1}}},
	chapter label style/.code={\tikzset{chapter label style/.style={#1}}},
	chapter label decoration/.store in=\chapter@label@deco,
	section style/.code={\tcbset{section style/.style={#1}}},
	section label style/.code={\tikzset{section label style/.style={#1}}},
	subsection label style/.code={\tikzset{subsection label style/.style={#1}}},
	after section hook/.store in=\aftersection@hook,
	chapter label anchor/.store in=\ig@chapter@anchor,
	chapter label anchor=north east,
	section label anchor/.store in=\ig@section@anchor,
	section label anchor=west,
}
\igdeflabel{chapter}{|1|}
\igset[sections]{%
chapter style={%
	colback=bgcol,
	coltext=fgcol,
	boxrule=0pt,
	lowerbox=ignored,
   },
chapter label style={},
section style={%
    boxrule=0pt,
    coltext=fgcol,
    colback=bgcol,
    fontupper=\itshape,
    },
section label style={},
subsection label style={}
}
\ifchapter@in@class
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
           at (frame.\ig@chapter@anchor)
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
\fi
\titleformat{\section}[block]
     {\sffamily\Large\scshape}
     {}
     {0pt}
     {%
       \begin{tcolorbox}[
         section style,
         overlay={
           \node (section) [section label style] 
           at (frame.\ig@section@anchor)
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

\def\fakebox#1{#1}
%%%% Decoration des maths. La base est definie dans igmath.sty  
\fadjwidth=6pt 
\igset{%
	math box style/.code={%
		\tikzset{math box style/.style={%
			fill=bgcol!90,
			draw=tcbcolbacktitle,
			text=fgcol,
			#1,
			line width=.4pt,
			inner ysep=2pt,
			inner xsep=.5\fadjwidth-0.2pt
	}}},%
math box style={}
}
\def\rslt@box#1{
	\tikz [anchor=base, baseline] 
		\node (formula)
			[math box style] {#1};%
}
\igdefdeco{formule}{\rslt@box{#1}}
\igdefdeco{formula}{\rslt@box{#1}}
\igdefdeco{result}{\rslt@box{#1}}

\endinput




