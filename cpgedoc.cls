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

%%%% Packages du projet 
\RequirePackage{cpgebase}
\RequirePackage{cpgesubdoc}
\RequirePackage{cpgemath}

%%%%%% Basculement vers la conversion en images %%%%%%	
\ifbool{web}
	{\RequirePackage{cpgeweb}\endinput}{}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage{cpgecommon}
\cpgeloadpackage[skins, breakable, hooks, theorems, xparse]{tcolorbox}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% style d'enumerations dans les theorem %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\def\setup@enumstyle{%
	\let\thecurrent@counter\@gobble
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
\cpgesetuptcb{%
	current counter/.code=\def\thecurrent@counter{#1}%
}	
\cpgesetuptcb{%
	titled items/.code={%
		\cpgesetuptcb{after upper pre=\closeunite}%
		\set@defaultforlistsinsideunite%
}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


\ifdraft
		\PassOptionsToPackage{draft}{pgf}
		\PassOptionsToPackage{draft}{hyperref}
\fi

\newtoks\toks@sol
\newtoks\toks@prv 
\let\solu\cpge@dummy@
\let\preuve\cpge@dummy@
\def\setup@solproofmode{%
	\unless\ifdraft
		\ifsolutiondelayed\solutiontrue\fi
		\ifproofdelayed\prooftrue\fi
		\ifsolution\let\solu\solution@push\fi%
		\ifproof\let\preuve\proof@push\fi%
		\ifsolutiondelayed
			\unless\ifcpgerecordfileopen
				\cpgestartrecording%
			\fi
		\else
			\ifproofdelayed
				\unless\ifcpgerecordfileopen
					\cpgestartrecording%
				\fi 
			\fi 
		\fi
	\fi 
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
	\ifx\preuve@\proof@push\prv@section{#1}\fi
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

%%% Gestion des thèmes
\cpgesetuptcb{thmcol/.colorlet=thmcol}

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

%%% \footnote en dehors des boites tcolorbox
\cpgesetuptcb{
  every box/.style={
    before title pre=\cpge@footnote@restore,
    before upper pre=\cpge@footnote@restore,
    before lower pre=\cpge@footnote@restore,
  },
  every box on layer 1/.append style={
    after pre=\cpge@footnote@use
  }
}
% Fin du hack


%%%% Initialisation de la machinerie tcolorbox
\cpgesetuptcb{%
	primary box/.style={%
		breakable,
		lines before break=1,
		height fixed for=first and middle,
		title style if break,
		fonttitle=\TitlingFont\footnotesize\vphantom{(},
		description font=\scshape\footnotesize\vphantom{(},
		colback=framebackcol,coltext=frametextcol,
	},
	secondary box/.style={%
		reset, blank,
		notitle,
		colback=buttonbackcol,
		coltext=buttontextcol
	}
}
\cpgesetuptcb{%
	every box on layer 1/.append style={primary box},
	every box on layer 2/.prefix style={secondary box},
	every box on layer 3/.prefix style={secondary box},
	every box on layer 4/.prefix style={secondary box}
}
%%%%%


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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Mise en place des differents types de theoremes %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\newif\ifexo@type
\newif\iftheo@type
\newif\ifdef@type
\newif\ifrem@type
\newif\ifproof@type
\cpgesetup{theorem type/.is choice,
	 theorem type/exercise/.code={\rem@typefalse},
	 theorem type/theorem/.code={\rem@typefalse},
	 theorem type/definition/.code={\rem@typefalse},
	 theorem type/remark/.code={\rem@typetrue},
	 theorem type/proof/.code={\rem@typetrue}
 }
\cpgesetuptcb{theorem type/.is choice,
	 theorem type/exercise/.code={\exo@typetrue},
	 theorem type/theorem/.code={\theo@typetrue},
	 theorem type/definition/.code={\def@typetrue},
	 theorem type/remark/.code={\rem@typetrue},
	 theorem type/proof/.code={\proof@typetrue},
 }
\cpge@cnt@shortcut{*X}{current@counter}
\cpgesetup[theorems]{%
	theorem style/.code=%
		\cpgesetuptcb{theorem style/.style={%
			thmcol=cpgegreen,
			colbacktitle=framebackcol,#1,current counter=\thetcbcounter}},
	definition style/.code=%
		\cpgesetuptcb{definition style/.style={%
			thmcol=cpgeblue,
			colbacktitle=framebackcol,#1,current counter=\thetcbcounter}},
	remark style/.code=%
		\cpgesetuptcb{remark style/.style={%
			thmcol=neutralcol, colbacktitle=thmcol,#1,current counter=\thetcbcounter}},
	}

\cpgesetup[theorems]{
	exercise style/.code=%
		\cpgesetuptcb{exercise style/.style={thmcol=importantcol, colbacktitle=thmcol,#1}}
}
\def\cpgesetuptheoremstyle{\pgfqkeys{/cpge/theorems}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Gestion des demos et des solutions %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Enregistrement des demo/solutions dans des fichiers individuels 
%%% et creation des hyperliens.
%%% Une token list contient la liste des commandes d'inclusion 
%%% des fichiers cr\'ees. 
%%% si les fichiers doivent être inclu en fin du fichier en cours
%%% la token list est ex\'ecut\'ee (et vid\'ee) sinon son contenu
%%% est ajout\'e à un fichier record. Celui-ci peut être inclu ensuite
%%% par l'utilisateur à un endroit de son choix.  

\def\out@dir{output}
\def\aux@dir{tmp}
\def\draft@solution{%
	\closeunite%
	\tcbsubtitle[basic subtitle]{Solution}%
	\set@defaultforlistsinsideunite%
}
\def\draft@proof{%
	\closeunite%
	\tcbsubtitle[basic subtitle]{D\'emonstration}%
	\set@defaultforlistsinsideunite%
}
\cpgesetuptcb{basic subtitle/.style={%
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
\appto\endpreamble@hook{
	\ifprint
	\cpgesetuptcb{demolink/.style n args={3}{% 
		size=#1, arc=#2, boxrule=2pt,
		colframe=pagecol, coltext=linktextcol!75!black, colback=pagecol, #3}}
	\else
	\cpgesetuptcb{demolink/.style n args={3}{%
		size=#1, arc=#2, boxrule=2pt,
		colframe=pagecol, coltext=white, colback=linkbackcol!75!black, #3
		}}
	\fi
}
%%% Lien vers demo/solution en bas d'un \'enonc\'e.  
\let\current@prv\relax
\let\current@sol\relax
\def\curr@counter{}
\def\@demolink#1#2{%
	\par\nopagebreak\vskip-\baselineskip%
	\vbox to\z@{\null\hfill\tcbox[
			reset, enhanced, nobeforeafter,
			demolink={tight}{3.2pt}{},
			hyperlink={#1@\thetcbcounter}, 
		]
		{\null\hskip10pt\sffamily\fontsize{8}{8}\scshape\vphantom{(3} #2 \thetcbcounter, page \pageref*{#1@\thetcbcounter}\hskip10pt\null}
}}
\def\@titledemolink#1#2#3#4#5#6{
	\par\penalty-999\bigskip
		\@hangfrom{
			\tcbox[
				enhanced,tcbox raise base,
				enlarge left by=-14pt,
				left=6pt, right=6pt,
				demolink={small}{8pt}{colframe=linkstrokecol, boxrule=.4pt},
				hyperlink={#1:#2},
				hypertarget={#4@#2},
  				phantomlabel={#4@#2},
  			]
			{\null\hskip6pt\sffamily\scshape\small\vphantom{)}%
				#5 #3~#2\hskip6pt\null}\enskip}%
	\ifblank{#6}{}{({\scshape\footnotesize #6})}%
	%\vrule width \z@  depth\medskipamount%
	\par\penalty\@M%
}
\def\@recsol{%
	\protected@edef\current@sol{%
		\noexpand\solu%
			{\cpge@theorem@countername}%
			{\thetcbcounter}%
			{\cpge@@theorem@prefixedname}%
			{\@theotitle}%
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
		\noexpand\preuve%
			{\cpge@theorem@countername}%
			{\thetcbcounter}%
			{\cpge@@theorem@prefixedname}%
			{\@theotitle}%
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
		}
	\else 
		\def\proof@link{\ifproofdelayed\@demolink{proof}{d\'emonstration}\fi}
		\def\solution@link{\ifsolutiondelayed\@demolink{solution}{solution}\fi}
		\cpgesetuptcb{%
			with@solu/.style={%
				lowerbox=ignored,
				before upper app=\xdef\curr@counter{\thetcbcounter}%
					\def\solution{\@recsol\solution@link\tcblower},
				savelowerto=\aux@dir/sol-\thetcbcounter.tex,
				after app=\csuse{sol@\curr@counter}
			},
			with@proof/.style={%
				lowerbox=ignored,
				before upper app=\xdef\curr@counter{\thetcbcounter}%
					\def\proof{\@recprv\proof@link\tcblower},
				savelowerto=\aux@dir/prv-\thetcbcounter.tex,
				after app=\csuse{prv@\curr@counter}
			},
		}
	\fi 
}
\cpgesetuptcb{%
	proof or solution/.code=%
		\ifexo@type\cpgesetuptcb{with@solu}\fi
		\iftheo@type\cpgesetuptcb{with@proof}\fi
	}

%%%%% Boites pour les demo/solutions
\newrobustcmd\solutionname{solution}
\newrobustcmd\proofname{démonstration}
\NewDocumentCommand{\solution@push}{mmmmm}{%
	\@titledemolink{#1}{#2}{#3}{solution}{\solutionname}{#4}
  	\begingroup%
		\edef\thecurrent@counter{#2}
		\set@defaultforlistsinsideunite
 		\input{#5}%
		\closeunite%
	\endgroup%
}
\NewDocumentCommand{\proof@push}{mmmmm}{%
	\@titledemolink{#1}{#2}{#3}{proof}{\proofname}{#4}
  	\begingroup%
		\edef\thecurrent@counter{#2}%
		\set@defaultforlistsinsideunite
 		\input{#5}%
		\closeunite%
	\endgroup%
}
\def\cpge@dummy@#1#2#3#4#5{}
\let\preuve\cpge@dummy@
\let\solu\cpge@dummy@



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% D\'efinition des environnements pour th\'eroremes %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% macros et cles principales de creation de theorem
\cpgesetuptcb{%
	font app/.code 2 args={\csappto{kvtcb@font#1}{#2}},
	font reset/.code 2 args={\csdef{kvtcb@font#1}{#2}}
}
\def\kvtbc@titlewho{\ifdefempty{\kvtcb@title}{\tcbtitletext}{\kvtcb@title}}
\cpgesetuptcb{title style if break/.style={%%
	title after break={\MakeLowercase{\kvtbc@titlewho}~(suite)},
	extras title after break={%
		halign title=right,
		coltitle=thmcol,
		colbacktitle=backcol,
		colback=backcol,
		boxsep=0pt, top =0pt, bottom=0pt, left=3pt,right=3pt,
		font app={title}{\fontsize{7}{7}\mdseries\itshape}
		},
	extras middle and last={colbacktitle=backcol},
	bottomrule=1pt, 
	bottomrule at break=1pt,
	toprule at break=0pt,
	titlerule=0pt
}}

\cpgesetuptcb{%
		@theocountername/.store in=\cpge@theorem@countername,
		@theoName/.store in=\cpge@theorem@Name,
		@theoname/.code=\def\cpge@theorem@name{#1}\csdef{\cpge@theorem@countername autorefname}{#1},
		@theoprefix/.code=\edef\cpge@@theorem@prefixedname{#1\cpge@theorem@name},
		@demoname/.store in=\cpge@demo@name,
	}
\ifdraft
\cpgesetuptcb{description path/.style={
		after title={\enskip\mdseries\scshape\itshape\small (#1)},
	}}
\else
\tikzset{description path style/.style={%
				fill=thmcol,
				draw=none,
				font=\smaller{-2}\vphantom{(},
				text=tcbcoltitle,
				#1}}
\cpgesetuptcb{description path/.style={%
	overlay unbroken and first={%
    	\path let \p1=(title.north east), \p2=([xshift=-12pt]frame.north east) in
			node (description) [%
        		anchor=west ,
				xshift=2pt , inner ysep=1pt ,
				text width=\x2-\x1 ,
				description path style
				] 
			at (title.east) {#1} ;
  		}
}}
\fi 

\def\important@message{\ifexo@type exercice \else r\'esultat\fi{} important}
\cpgesetuptcb{
	important/.style={%
		thmcol=importantcol,
		bottom=10pt,
		underlay unbroken and last={\node at (frame.south west) 
			[text=thmcol, 
			font=\fontsize{7}{8}\selectfont, 
			anchor=south west, 
			yshift=2pt
			] 
			{#1};}
		},
	important/.default=\important@message
}
%%% Environnement butineur : tous les environnement 
%%% de theoreme l'utilisent en interne
\def\cpge@theo@form@namenumber#1#2{\hbox{#1~#2}}
\def\cpge@theo@form@numbername#1#2{\hbox{#2~#1}}
\def\cpge@theo@form@name#1#2{\hbox{#1}}
\cpgesetuptcb{%
	theorem name and number/.code={\let\tcb@theo@form=\cpge@theo@form@namenumber},
	theorem number and name/.code={\let\tcb@theo@form=\cpge@theo@form@numbername},
	theorem name/.code={\let\tcb@theo@form=\cpge@theo@form@name},
	new/@labelformat/.code 2 args=\labelformat{#1}{#2}
}
\def\@theotitle{}
\NewDocumentCommand{\cpge@new@tcbtheorem}{O{} mmmmmm}{%
  \cpgesetup{theorem type=#6}%
  \unless\ifrem@type
  \@@newtcolorbox[auto counter, list inside=theo,#1]{#2}{E{\op}{{}} d() d<>}{%
  	@theocountername=#2,
  	@theoName={#3},
	@theoname={#4},
	@theoprefix={#5},
    theorem type=#6,
    #6 style,
    theorem name and number,
    title={\cpge@tcb@theo@title{#3}{\thetcbcounter}},%
    IfValueT={##2}{list entry=%
    	{\protect\numberline{\thetcbcounter}#3~:~##2}},%
    IfValueT={##2}{nameref={##2},description path={##2}, code=\def\@theotitle{##2}},%
    IfValueT={##3}{phantom={\MakeLinkTarget[#4]{tcb@cnt@theo}\label{##3}}},%
	hypertarget={\cpge@theorem@countername:\thetcbcounter},
	proof or solution,
    #7,##1}%
    \fi
    \ifrem@type
    \@@newtcolorbox[auto counter, list inside=theo,#1]{#2}{E{\op}{{}} d() d<>}{%
    remark style, 
    theorem name and number,
	@theocountername=#2,
    title={\cpge@tcb@theo@title{#3}{\thetcbcounter}
    		\IfValueTF{##2}{\enskip\mdseries\itshape({##2})}{}},%
    IfValueT={##2}{list entry=%
    	{\protect\numberline{\thetcbcounter}#3~:~##2}},%
    IfValueT={##2}{nameref={##2}},%
    IfValueT={##3}{phantom={\MakeLinkTarget[#4]{tcb@cnt@rema}\label{##3}}},%
    #7,##1,
    colframe=thmcol
    }%
	\fi
	\ifrem@type\else
    \DeclareDocumentEnvironment{#2+}{}
    	{\csname #2\endcsname}
		{\csname end#2\endcsname}
	\fi
	\DeclareDocumentEnvironment{#2*}{E{\op}{{}} d() d<>}
    	{\csname #2\endcsname [##1,theorem name](##2)<##3>}
		{\csname end#2\endcsname}
	\rem@typefalse
	}
	
\newcounter{genthm}[chapter]
\NewTColorBox[use counter=genthm]{genthm*}{ m E{\op}{{}} d() d<>}{%
	thmcol=framestrokecol,
	title={#1},
	IfValueT={#3}{description path={#3}},
	IfValueT={#4}{nameref={#3}},
	theorem style,
	theorem name,
	titled items,
	#2}
\NewTColorBox[use counter=genthm]{genthm}{ m E{\op}{{}} d() d<>}{%
	thmcol=framestrokecol,
	IfValueT={#1}{title={\cpge@tcb@theo@title{#1}{\thetcbcounter}}},
	IfValueT={#3}{nameref={#3}, description path={#3}},
	IfValueT={#4}{label={#4}},
	IfValueT={#3}{list entry=%
    	{\protect\numberline{\thetcbcounter}#2~:~#3}},%
	theorem style,
	#2,
	theorem name,
	titled items
}
\cpgesetuptcb{marge/.style={left=#1,right=#1}}	
	
%%%%%%%% Tables des th\'eor\`emes 
\def\cpge@tcb@theo@title#1#2{%
	\ifdefempty{#2}
		{\setbox\z@=\color@hbox#1~\color@endbox}
  		{\setbox\z@=\tcb@theo@form{#1}{#2}}%
	\unhbox\z@%
}

\def\cpge@addcontentsline#1#2{%
	\ifx\kvtcb@listentry\@empty\else
    	\addcontentsline{#1}{#2}{\kvtcb@listentry}%
	\fi%
}

\def\cpgenewtheorem{\let\tcb@addcontentsline\cpge@addcontentsline%
	\let\@@newtcolorbox\NewTColorBox%
	\cpge@new@tcbtheorem}

\def\cpgerenewtheorem{\let\@@newtcolorbox\RenewTColorBox%
  \cpge@new@tcbtheorem}
  
\ProvideDocumentCommand\tableofresults%
	{O{\section*} D(){Liste des r\'esultats remarquables}}{%
		\tcblistof[#1]{theo}{#2}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% jeu de styles tcolorbox %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\cpgesetuptcb{minimal/.style=blanker}

\cpgesetuptcb{simple/.style={%
	colframe=thmcol,
	boxrule=.4pt,
	top=3pt,bottom=3pt,
	left=5pt,right=5pt
	}}
	
\cpgesetuptcb{basic/.style={%
	spartan,
  	top=3pt,bottom=3pt,
	left=5pt,right=5pt,
	boxrule=.4pt, 
}}
\cpgesetuptcb{
	basicthm/.style={%
		empty, 
		basic, 
		attach boxed title to top left={xshift=3pt,yshift*=-\tcboxedtitleheight+.1pt},
		boxed title style={%
					boxrule=0pt,
			boxsep=0pt,
			top=2pt,bottom=1pt,left=3pt,right=3pt,
		}
	}
}
\cpgesetuptcb{%
	basicrmk/.style={
		blankest, 
		coltitle=thmcol,
		top=3pt, bottomtitle=5pt, 
		left=20pt, before title={\hskip-14pt},
		borderline west={.6pt}{.6pt}{thmcol}
	}
}
\cpgesetuptcb{rounded/.style={
	arc=5pt,
    colframe=thmcol,
    boxrule=-1pt,
	left=8pt,right=8pt
 }}
\cpgesetuptcb{roundedthm/.style={%
	rounded,
    attach boxed title to top left={yshift=-\tcboxedtitleheight/2-1pt,xshift=3pt},
    boxed title style={%
    	arc=5pt,
        boxsep=0pt,
        top=2pt,bottom=1pt,left=6pt,right=6pt,
        boxrule=1pt,
        colframe=pagecol
        },
        bottomrule=.8pt
}}
\cpgesetuptcb{uphill/.style={
    	colframe=thmcol,
		left=5pt,right=5pt,
    	arc=.2cm,
    	sharp corners=uphill
 }}
\cpgesetuptcb{uphillthm/.style={%
	uphill,
    attach boxed title to top left={yshift=-\tcboxedtitleheight},
    boxed title style={%
        boxsep=0pt,
        top=2pt,bottom=1pt,left=6pt,right=6pt,
        arc=.2cm,
        sharp corners=uphill
        },
        boxrule=.4pt,
 }}



%%% Theme par defaut (basic)		
\cpgesetuptheoremstyle{%
	theorem style=basicthm,
	definition style=basicthm,
	exercise style=basicthm,
	remark style=basicrmk 
}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% exemples d'environement pour theoremes %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\cpgenewtheorem[number within=chapter]{theo}
	{Th\'eor\`eme}
	{th\'eor\`eme}
	{du\space}
	{theorem}
	{titled items}	
\cpgenewtheorem[use counter from=theo]{theodef}
	{Th\'eor\`eme et d\'efinition}
	{th\'eor\`eme}
	{du\space}
	{theorem}
	{titled items}
\cpgenewtheorem[use counter from=theo]{propdef}
	{Proposition et d\'efinition}
	{proposition}
	{de la\space}
	{theorem}
	{titled items}
\cpgenewtheorem[use counter from=theo]{prop}
	{Proposition}
	{proposition}
	{de la\space}
	{theorem}
	{titled items}
\cpgenewtheorem[use counter from=theo]{lemm}
	{Lemme}
	{lemme}
	{du\space}
	{theorem}
	{}
\cpgenewtheorem[use counter from=theo]{ppte}
	{Propri\'et\'es}
	{propri\'et\'es}
	{des\space}
	{theorem}
	{titled items}
\cpgenewtheorem[use counter from=theo]{coro}
	{Corollaire}
	{corollaire}
	{du\space}
	{theorem}
	{titled items}
\cpgenewtheorem[number within=chapter]{defi}
	{D\'efinition}
	{}{}
	{definition}
	{titled items}
\cpgenewtheorem[use counter from=defi]{voca}
	{Vocabulaire}
	{}{}
	{definition}
	{theorem name, titled items}
\cpgenewtheorem[use counter from=defi]{nota}
	{Notations}
	{}{}
	{definition}
	{theorem name,titled items}
\cpgenewtheorem[number within=chapter]{rema}
	{Remarque}
	{}{}
	{remark}
	{}
\cpgenewtheorem[use counter from=rema]{remas}
	{Remarques}
	{}{}
	{remark}
	{titled items}
\cpgenewtheorem[use counter from=rema]{remap}
	{Remarques pratiques}
	{}{}
	{remark}
	{titled items}
\cpgenewtheorem[number within=chapter]{exem}
	{Exemples}
	{}{}
	{remark}
	{titled items}
\cpgenewtheorem[use counter from=exem]{exemf}
	{Exemples fondamentaux}
	{}{}
	{remark}
	{titled items}
\cpgenewtheorem[use counter from=exem]{exema}
	{Exemple d'application}
	{}{}
	{remark}
	{titled items}
\cpgenewtheorem[use counter from=exem]{exemp}
	{Exemple pratique}
	{}{}
	{remark}
	{titled items}
\cpgenewtheorem[use counter from=exem]{appl}
	{Application}
	{}{}
	{remark}
	{}
\cpgenewtheorem[use counter from=exem]{appls}
	{Application}
	{}{}
	{remark}
	{titled items}
\cpgenewtheorem[no counter]{demo}
	{D\'emonstration}
	{}{}
	{proof}
	{titled items, current counter=\@gobble}
\cpgenewtheorem[number within=chapter]{float}
	{Figure}
	{}{}
	{remark}
	{float, halign title=flush center}
\cpgesetuptcb{floatplacement=tbp}

\cpgenewtheorem[number within=chapter,@labelformat={tcb@cnt@exer}{l'exercice}]{exer}
	{Exercice}
	{exercice}
	{de l'}
	{exercise}
	{titled items}
\cpgenewtheorem[number within=chapter]{exerappli}
	{Exercice d'application}
	{exercice}
	{de l'}
	{exercise}
	{titled items}
\cpgenewtheorem[number within=chapter]{exerappro}
	{Exercice d'approfondissement}
	{exercice}
	{de l'}
	{exercise}
	{titled items}
\cpgenewtheorem[number within=chapter]{prob}
	{Probl\`eme}
	{probl\`eme}
	{du\space}
	{exercise}
	{titled items}


\endinput




