\def\filedate{2023/10/01}
\def\fileversion{v0.3alpha}
\def\fileauthor{Sadik Boujaida}

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{cpgedoc}[\filedate\space\fileversion]

%%% Initiation Code
\RequirePackage{pgfopts}
\RequirePackage{etoolbox}
\def\cpgecurrentclass{cpgedoc}

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
\ifbool{web}{\endinput}{}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Basculement vers la conversion en images %%%%%%	
\ifbool{web}
	{\RequirePackage{cpgeweb}\endinput}{}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\ifdraft
		\PassOptionsToPackage{draft}{pgf}
		\PassOptionsToPackage{draft}{hyperref}
\fi
\AtEndPreamble{%
	\ifnocolors\selectcolormodel{gray}\fi
}

\newtoks\toks@sol
\newtoks\toks@prv 
\def\setup@solproofmode{%
	\unless\ifdraft
		\ifsolutiondelayed\solutiontrue\fi
		\ifproofdelayed\prooftrue\fi
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
	\setup@straightmode%
	\setup@solproofmode%
}


%%%%% Other package initialisation
%\RequirePackage{currfile}
\RequirePackage{lastpage}
\RequirePackage{fontawesome}
\RequirePackage[pdfencoding=auto,psdextra]{hyperref}
\hypersetup{colorlinks,linkcolor=linkcol,breaklinks,raiselinks}
\pdfstringdefDisableCommands{%
	\def\({}%
	\def\){}%
}
\let\ToP\texorpdfstring
%\RequirePackage{bookmark}


%%%% Strategie d'inclusion de fichier
\newif\ifincluded 
\cpgesetup[include]{
	solution/.code=\csname solution#1\endcsname\solutiondelayedfalse,
	solution*/.is if=solutiondelayed,
	proof/.code=\csname proof#1\endcsname\proofdelayedfalse,
	proof*/.is if=proofdelayed,
	straight/.code=\csname straight#1\endcsname,
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
		\RenewDocumentCommand\titre{sod()}{}%
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
		\edef\cpge@tmpe{\the\toks@prv}
		\ifincluded
			\ifproofdelayed
				\ifcpgerecordfileopen\else\cpgestartrecording\fi%
				\eappto\prv@section{{\prv@title du \chaptername\space\thechapter}}%
				\cpgerecord{\expandonce\prv@section^^J}
				\cpgerecord{\the\toks@prv}
			\else
				\ifproof
					\ifdefvoid\cpge@tmpe{}{\typeout@proofs}
				\fi
			\fi
		\else 
			\ifproof
				\ifdefvoid\cpge@tmpe{}{\typeout@proofs}
			\fi
		\fi 
	\fi
}
\def\processsolutions{%
	\unless\ifdraft
		\edef\cpge@tmpe{\the\toks@sol}
		\ifincluded
			\ifsolutiondelayed
				\ifcpgerecordfileopen\else\cpgestartrecording\fi%
				\eappto\sol@section{{\sol@title\space du \chaptername\space\thechapter}}%
				\cpgerecord{\expandonce\sol@section^^J}
				\cpgerecord{\the\toks@sol}
			\else
				\ifsolution
					\ifdefvoid\cpge@tmpe{}{\typeout@solutions}
				\fi
			\fi
		\else 
			\ifsolution
				\ifdefvoid\cpge@tmpe{}{\typeout@solutions}
			\fi
		\fi
	\fi 
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
	\unless\ifdraft
		\cpgestoprecording%
		\let\solu\solution@push%
		\input{\jobname.rec}%
		\let\solu\cpge@dummy@%
	\fi
}
\def\proofs{%
	\ifcpgerecordfileopen%
		\cpgestoprecording%
	\fi%
	\IfFileExists{\jobname.rec}
		{
			\let\preuve\proof@push%
			\input{\jobname.rec}%
			\let\preuve\cpge@dummy@%
		}
}
\AtEndDocument{\ifcpgerecordfileopen\cpgestoprecording\fi}

\def\cpgeincludeweb#1{} 

%%%% Chargement des differents packages 
\RequirePackage{cpgecommon}
%% Formats par defaut des titres
\cpgesettitle{|document| \\ |theme| \\ |periode|}
\cpgesettitle*{|document| \\ |theme| \\ |periode|}

\RequirePackage{tcolorbox}
\tcbuselibrary{skins,hooks,breakable,theorems,xparse}
\usetikzlibrary{calc}
\tikzset{
    every picture/.prefix style={
        execute at begin picture=\shorthandoff{;}
    }
}
\tcbset{maincol/.code=\colorlet{maincol}{#1}}
\DeclareDocumentCommand\cpgetheme{O{} m}{%
	\unless\ifdraft
		\cpgesetup[theme]{#1}
		\IfFileExists{#2doc.sty}
			{\AtEndPreamble{\RequirePackage{#2doc}}\reloadcolors}
			{}%
	\fi%
}



































%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% styles pour les titres de sections %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	   
\cpgesetlabel{chapter}{|1|}
\cpgesetlabel{section}{|I|}
\cpgesetlabel{subsection}{|S|.|1|}	   
	   
\tcbset{chapter style/.style={}}
\tikzset{chapter label style/.style={}}
\tcbset{section style/.style={}}
\tikzset{section label style/.style={}}

\cpgesetup{sections/.is family, sections,
	chapter style/.code={\tcbset{chapter style/.style={#1}}},
	chapter label style/.code={\tikzset{chapter label style/.style={#1}}},
	chapter label decoration/.store in=\chapter@label@deco,
	section style/.code={\tcbset{section style/.style={#1}}},
	section label style/.code={\tikzset{section label style/.style={#1}}},
	subsection label style/.code={\tikzset{subsection label style/.style={#1}}},
	after section hook/.store in=\aftersection@hook,
	chapter label anchor/.store in=\cpge@chapter@anchor,
	chapter label anchor=north east,
	section label anchor/.store in=\cpge@section@anchor,
	section label anchor=west,
}
\cpgesetlabel{chapter}{|1|}
\cpgesetup[sections]{%
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

\def\fakebox#1{#1}
%%%% Decoration des maths. La base est definie dans cpgemath.sty  
\fadjwidth=6pt 
\cpgesetup{%
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
\cpgesetdeco{formule}{\rslt@box{#1}}
\cpgesetdeco{formula}{\rslt@box{#1}}
\cpgesetdeco{result}{\rslt@box{#1}}


\tcbset{%
	primary box/.style={%
		breakable,
		lines before break=1,
		height fixed for=first and middle,
		title style if break,
		fonttitle=\TitlingFont\footnotesize\vphantom{(},
		description font=\scshape\footnotesize\vphantom{(},
		colback=bgcol,coltext=fgcol
	},
	secondary box/.style={%
		reset, blank,
		notitle,
		colback=bgcol,
		coltext=fgcol
	}
}
\tcbset{%
	every box on layer 1/.style={primary box},
	every box on layer 2/.style={secondary box},
	every box on layer 3/.style={secondary box},
	every box on layer 4/.style={secondary box}
}
%\tcbsetmanagedlayers{2}

\cpgesetup{simple deco/.code={%
			\cpgesetdeco{simple}{\simple@label@font#1}%
			\let\deco@lrmargin\deco@simple},
	   simple label font/.code={\def\simple@label@font{#1\vphantom{(}}},
}
\cpgesetup{%
	simple deco=\textcolor{maincol}{\fbox{#1}}\enskip,
	simple label font=\scshape\sffamily\footnotesize,
}
\cpgesetup[mini]{
	left margin=1pc,
	right margin=0pt,
	font=\sffamily\footnotesize
	}


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
\tcbset{theorem type/.is choice,
	 theorem type/exercise/.code={\exo@typetrue},
	 theorem type/theorem/.code={\theo@typetrue},
	 theorem type/definition/.code={\def@typetrue},
	 theorem type/remark/.code={\rem@typetrue},
	 theorem type/proof/.code={\proof@typetrue},
 }
\cpge@cnt@shortcut{*X}{current@counter}
\cpgesetup[theorems]{%
	theorem style/.code=%
		\tcbset{theorem style/.style={%
			maincol=warmcol,colbacktitle=maincol,#1,current counter=\thetcbcounter}},
	definition style/.code=%
		\tcbset{definition style/.style={%
			maincol=coldcol,colbacktitle=maincol,#1,current counter=\thetcbcounter}},
	remark style/.code=%
		\tcbset{remark style/.style={%
			maincol=neutralcol, colbacktitle=maincol,#1,current counter=\thetcbcounter}},
	}

\cpgesetup[theorems]{
	exercise style/.code=%
		\tcbset{exercise style/.style={maincol=importantcol, colbacktitle=maincol,#1}}
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
\tcbset{basic subtitle/.style={%
		spartan,
		coltext=white,
		colback=maincol,
		colbacktitle=maincol,
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
\AtBeginDocument{
	\ifprint
	\tcbset{demolink/.style n args={3}{% 
		size=#1, arc=#2, boxrule=2pt,
		colframe=bgcol, coltext=linkcol!75!black, colback=bgcol, #3}}
	\else
	\tcbset{demolink/.style n args={3}{%
		size=#1, arc=#2, boxrule=2pt,
		colframe=bgcol, coltext=white, colback=linkcol!75!black, #3
		}}
	\fi
}
%%% Lien vers demo/solution en bas d'un \'enonc\'e.  
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
				enlarge left by=-.5\Gm@littlemargin,
				demolink={small}{8pt}{colframe=linkcol, boxrule=.4pt},
				hyperlink={#1:#2},
				hypertarget={#4@#2},
  				phantomlabel={#4@#2},
  			]
	{\null\hskip6pt\sffamily\scshape\small\vphantom{)}#5 #3~#2\hskip6pt\null}\enskip}%
	\ifblank{#6}{}{\textsc{\small (#6)}}%
	\vrule width \z@  depth\medskipamount%
	\par\penalty\@M%
}
\def\@recsol{%
	\protected@edef\cpgec@@tmpe{%
		\the\toks@sol%
		\noexpand\solu%
			{\cpge@theorem@prefix}%
			{\thetcbcounter}%
			{\cpgedu@@theorem@name}%
			{\@theotitle}%
			{\aux@dir/sol-\thetcbcounter}^^J%
	}
	\expandafter\global\expandafter\toks@sol\expandafter{\cpgec@@tmpe}%
}
\def\@recprv{%
	\protected@edef\cpgec@@tmpe{%
		\the\toks@prv%
		\noexpand\preuve%
			{\cpge@theorem@prefix}%
			{\thetcbcounter}%
			{\cpgedu@@theorem@name}%
			{\@theotitle}%
			{\aux@dir/prv-\thetcbcounter}^^J%
	}%
	\expandafter\global\expandafter\toks@prv\expandafter{\cpgec@@tmpe}%
}
\def\setup@draftmode{
	\ifdraft
		\let\solution\draft@solution
		\let\proof\draft@proof
		\tcbset{%
			with@solu/.style={},
			with@proof/.style={},
		}
	\else 
		\def\proof@link{\ifproof\@demolink{proof}{d\'emonstration}\fi}
		\def\solution@link{\ifsolution\@demolink{solution}{solution}\fi}
		\tcbset{%
			with@solu/.style={%
				lowerbox=ignored,
				before upper app=\def\solution{\@recsol\solution@link\tcblower},
				savelowerto=\aux@dir/sol-\thetcbcounter.tex,
			},
			with@proof/.style={%
				lowerbox=ignored,
				before upper app=\def\proof{\@recprv\proof@link\tcblower},
				savelowerto=\aux@dir/prv-\thetcbcounter.tex,
			},
		}
	\fi 
}
\tcbset{%
	proof or solution/.code=%
		\ifexo@type\tcbset{with@solu}\fi
		\iftheo@type\tcbset{with@proof}\fi
	}

%%%%% Boites pour les demo/solutions	
\NewDocumentCommand{\solution@push}{mmmmm}{%
	\@titledemolink{#1}{#2}{#3}{solution}{solution}{#4}
  	\begingroup%
		\set@defaultforlistsinsideunite
 		\input{#5}%
		\closeunite%
	\endgroup%
}
\NewDocumentCommand{\proof@push}{mmmmm}{%
	\@titledemolink{#1}{#2}{#3}{proof}{d\'emonstration}{#4}
  	\begingroup%
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
\tcbset{%
	font app/.code 2 args={\csappto{kvtcb@font#1}{#2}},
	font reset/.code 2 args={\csdef{kvtcb@font#1}{#2}}
}
\def\kvtbc@titlewho{\ifdefempty{\kvtcb@title}{\tcbtitletext}{\kvtcb@title}}
\tcbset{title style if break/.style={%%
	title after break={\MakeLowercase{\kvtbc@titlewho}~(suite)},
	extras title after break={%
		halign title=right,
		coltitle=maincol,
		colbacktitle=bgcol,
		colback=bgcol,
		boxsep=0pt, top =0pt, bottom=0pt, left=3pt,right=3pt,
		font app={title}{\fontsize{7}{7}\mdseries\itshape}
		},
	extras middle and last={colbacktitle=bgcol},
	bottomrule=1pt, 
	bottomrule at break=1pt,
	toprule at break=0pt,
	titlerule=0pt
}}

\tcbset{%
		@theoprefix/.store in=\cpge@theorem@prefix,
		@theoname/.store in=\cpge@theorem@name,
		du@theoname/.store in=\cpgedu@@theorem@name,
		@demoname/.store in=\cpge@demo@name
	}
\ifdraft
\tcbset{description path/.style={
		after title={\enskip\mdseries\scshape\itshape\small (#1)},
	}}
\else
\tikzset{description path style/.style={%
				fill=maincol,
				draw=none,
				font=\smaller{-2}\vphantom{(},
				text=tcbcoltitle,
				#1}}
\tcbset{description path/.style={%
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
\tcbset{
	important/.style={%
		maincol=importantcol,
		bottom=10pt,
		underlay unbroken and last={\node at (frame.south west) 
			[text=maincol, 
			font=\fontsize{7}{8}\selectfont, 
			anchor=south west, 
			yshift=2pt
			] 
			{#1};}
		},
	important/.default=\important@message
}
\cpgesetup[math]{
	formula/.code=\cpgesetdeco{formula}{#1},
	result/.code=\cpgesetdeco{result}{#1},
	formula={\fcolorbox{maincol}{tcbcolback}{#1}},
	result={\fcolorbox{maincol}{tcbcolback!95!maincol}{#1}}
}
%%% Environnement butineur : tous les environnement 
%%% de theoreme l'utilisent en interne
\def\cpge@theo@form@namenumber#1#2{\hbox{#1~#2}}
\def\cpge@theo@form@numbername#1#2{\hbox{#2~#1}}
\def\cpge@theo@form@name#1#2{\hbox{#1}}
\tcbset{%
	theorem name and number/.code={\let\tcb@theo@form=\cpge@theo@form@namenumber},
	theorem number and name/.code={\let\tcb@theo@form=\cpge@theo@form@numbername},
	theorem name/.code={\let\tcb@theo@form=\cpge@theo@form@name},
	new/@labelformat/.code 2 args=\labelformat{#1}{#2}
}
\def\@theotitle{}
\NewDocumentCommand{\cpge@new@tcbtheorem}{O{} mmmmm}{%
  \cpgesetup{theorem type=#5}%
  \unless\ifrem@type
  \@@newtcolorbox[auto counter, list inside=theo,#1]{#2}{E{\op}{{}} d() d<>}{%
  	@theoname={#3},
	du@theoname={#4},
    theorem type=#5,
    #5 style,
    theorem name and number,
	@theoprefix=#2,
    title={\cpge@tcb@theo@title{#3}{\thetcbcounter}},%
    IfValueT={##2}{list entry=%
    	{\protect\numberline{\thetcbcounter}#3~:~##2}},%
    IfValueT={##2}{nameref={##2},description path={##2}, code=\def\@theotitle{##2}},%
    IfValueT={##3}{phantom={\MakeLinkTarget[#3]{tcb@cnt@theo}\label{##3}}},%
	hypertarget={\cpge@theorem@prefix:\thetcbcounter},
	proof or solution,
    #6,##1}%
    \fi
    \ifrem@type
    \@@newtcolorbox[auto counter, list inside=theo,#1]{#2}{E{\op}{{}} d() d<>}{%
    remark style, 
    theorem name and number,
	@theoprefix=#2,
    title={\cpge@tcb@theo@title{#3}{\thetcbcounter}
    		\IfValueTF{##2}{\enskip\mdseries\itshape({##2})}{}},%
    IfValueT={##2}{list entry=%
    	{\protect\numberline{\thetcbcounter}#3~:~##2}},%
    IfValueT={##2}{nameref={##2}},%
    IfValueT={##3}{phantom={\MakeLinkTarget[#3]{tcb@cnt@rema}\label{##3}}},%
    #6,##1,
    colframe=maincol
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
	title={#1},
	IfValueT={#3}{description path={#3}},
	IfValueT={#4}{nameref={#3}},
	maincol=coldcol,
	theorem style,
	theorem name,
	titled items,
	#2}
\NewTColorBox[use counter=genthm]{genthm}{ m E{\op}{{}} d() d<>}{%
	IfValueT={#1}{title={\cpge@tcb@theo@title{#1}{\thetcbcounter}}},
	IfValueT={#3}{nameref={#3}, description path={#3}},
	IfValueT={#4}{label={#4}},
	IfValueT={#3}{list entry=%
    	{\protect\numberline{\thetcbcounter}#2~:~#3}},%
	maincol=coldcol,
	theorem style,
	theorem name,
	titled items,
	#2}
\tcbset{marge/.style={left=#1,right=#1}}	
	
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

\tcbset{minimal/.style=blanker}

\tcbset{simple/.style={%
	colframe=maincol,
	boxrule=.4pt,
	top=3pt,bottom=3pt,
	left=5pt,right=5pt
	}}
	
\tcbset{basic/.style={%
	spartan,
  	top=3pt,bottom=3pt,
	left=5pt,right=5pt,
	boxrule=.4pt, 
}}
\tcbset{
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
\tcbset{%
	basicrmk/.style={
		blankest, 
		coltitle=maincol,
		top=3pt, bottomtitle=5pt, 
		left=20pt, before title={\hskip-14pt},
		borderline west={.6pt}{.6pt}{maincol}
	}
}
\tcbset{rounded/.style={
	arc=5pt,
    colframe=maincol,
    boxrule=-1pt,
	left=8pt,right=8pt
 }}
\tcbset{roundedthm/.style={%
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
\tcbset{uphill/.style={
    	colframe=maincol,
		left=5pt,right=5pt,
    	arc=.2cm,
    	sharp corners=uphill
 }}
\tcbset{uphillthm/.style={%
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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% style d'enumerations dans les theorem %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\let\thecurrent@counter\@gobble
\cpgesetenum{1}{marge}
\cpgesetenum{2}{marge*}
\cpgesetlabel{unite}{|X|.|1|}%
\cpgesetlabel{enumi}{|X|.|1|}%
\cpgesetdeco{enumi}{\deco@simple{#1}}%
\cpgesetlabel{enumii}{|Q|\itshape|a|}
\cpgesetdeco{enumii}{\bfseries #1.}
\cpgesetlabel{equation}{|1|}
\cpgesetdeco{itemtitle}{{\scshape\sffamily#1~:~}}
\cpgesetdeco{unitetitle}{\textcolor{maincol}{\sffamily\scshape\small#1~:~}}
\makethetolabel{equation}
\tcbset{%
	current counter/.code=\def\thecurrent@counter{#1}
	}	
\tcbset{%
	titled items/.code={%
		\tcbset{after upper pre=\closeunite}%
		\set@defaultforlistsinsideunite%
}}
\cpgesetdeco{unite}{\textcolor{maincol}{\sffamily\small\scshape\bfseries#1.}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% exemples d'environement pour theoremes %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\cpgenewtheorem[number within=chapter]{theo}
	{Th\'eor\`eme}
	{du th\'eor\`eme}
	{theorem}
	{titled items}	
\cpgenewtheorem[use counter from=theo]{theodef}
	{Th\'eor\`eme et d\'efinition}
	{du th\'eor\`eme}
	{theorem}
	{titled items}
\cpgenewtheorem[use counter from=theo]{propdef}
	{Proposition et d\'efinition}
	{de la proposition}
	{theorem}
	{titled items}
\cpgenewtheorem[use counter from=theo]{prop}
	{Proposition}
	{de la proposition}
	{theorem}
	{titled items}
\cpgenewtheorem[use counter from=theo]{lemm}
	{Lemme}
	{du lemme}
	{theorem}
	{}
\cpgenewtheorem[use counter from=theo]{ppte}
	{Propri\'et\'es}
	{des propri\'et\'es}
	{theorem}
	{titled items}
\cpgenewtheorem[use counter from=theo]{coro}
	{Corollaire}
	{du corollaire}
	{theorem}
	{titled items}
\cpgenewtheorem[number within=chapter]{defi}
	{D\'efinition}
	{}
	{definition}
	{titled items}
\cpgenewtheorem[use counter from=defi]{voca}
	{Vocabulaire}
	{}
	{definition}
	{theorem name, titled items}
\cpgenewtheorem[use counter from=defi]{nota}
	{Notations}
	{}
	{definition}
	{theorem name,titled items}
\cpgenewtheorem[number within=chapter]{rema}
	{Remarque}
	{}
	{remark}
	{}
\cpgenewtheorem[use counter from=rema]{remas}
	{Remarques}
	{}
	{remark}
	{titled items}
\cpgenewtheorem[use counter from=rema]{remap}
	{Remarques pratiques}
	{}
	{remark}
	{titled items}
\cpgenewtheorem[number within=chapter]{exem}
	{Exemples}
	{}
	{remark}
	{titled items}
\cpgenewtheorem[use counter from=exem]{exemf}
	{Exemples fondamentaux}
	{}
	{remark}
	{titled items}
\cpgenewtheorem[use counter from=exem]{exema}
	{Exemple d'application}
	{}
	{remark}
	{titled items}
\cpgenewtheorem[use counter from=exem]{exemp}
	{Exemple pratique}
	{}
	{remark}
	{titled items}
\cpgenewtheorem[no counter]{demo}
	{D\'emonstration}
	{}
	{proof}
	{titled items, current counter=\@gobble}
\cpgenewtheorem[number within=chapter]{float}
	{Figure}
	{}
	{remark}
	{float, halign title=flush center}
\tcbset{floatplacement=tbp}

\cpgenewtheorem[number within=chapter,@labelformat={tcb@cnt@exer}{l'exercice}]{exer}
	{Exercice}
	{de l'exercice}
	{exercise}
	{titled items}
\cpgenewtheorem[number within=chapter]{exerappli}
	{Exercice d'application}
	{de l'exercice}
	{exercise}
	{titled items}
\cpgenewtheorem[number within=chapter]{exerappro}
	{Exercice d'approfondissement}
	{de l'exercice}
	{exercise}
	{titled items}
\cpgenewtheorem[number within=chapter]{prob}
	{Probl\`eme}
	{du probl\`eme}
	{exercise}
	{titled items}


\endinput




