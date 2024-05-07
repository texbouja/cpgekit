\def\filedate{2023/10/12}
\def\fileversion{v0.3alpha}
\def\fileauthor{Sadik Boujaida}

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{cpgedev}[\filedate\space\fileversion]
\RequirePackage{pgfopts} %Pour la gestion des options de la classe
\RequirePackage{etoolbox}
\def\cpgecurrentclass{cpgedev}

\@ifundefined{ifsubdoc}{
	\newif\ifweb
	\newif\ifsingleimage
	\newif\ifthisfile
	\newif\ifsoutien 
	\newif\ifdraft
	\newif\ifstraight
	\newif\ifnolinks
	\newif\ifprint
	\newif\ifnocolors
	\newif\ifdark
	\newif\ifcompact
	\newif\ifstriptitle
	\newif\ifsolution
	\newif\ifsolutiondelayed
	\newif\ifproof
	\newif\ifproofdelayed
	\newif\ifjustification\justificationtrue
	\newif\ifhint
	\newif\ifhintocg
}{}

\newif\ifconvert

\let\startcsvrecording\relax
\let\stopcsvrecording\relax

\def\class@options{11pt}
\pgfkeys{/IGD/.is family, /IGD/.cd,
	web/.style={},
	draft/.style={},
	straight/.style={},	
	soutien/.style={},
	compact/.style={},
	dark/.style={},
	nocolors/.style={},
	solution/.style={},
	solution*/.style={},
	nojustification/.style={},
	hint/.style={},
}
\pgfkeys{/IGDS/.is family, /IGDS/.cd,
	draft/.is if=draft,	
	straight/.is if=straight,
	soutien/.is if=soutien,
	compact/.is if=compact,
	dark/.is if=dark,
	nocolors/.is if=nocolors, 
	nolinks/.is if=nolinks,
	web/.code=\compacttrue\webtrue\def\convert@options{}
		\def\cpgecomment@list{quiz,notations,#1},
	web/.default={},
	singleimage/.is if=singleimage,
	thisfile/.is if=thisfile,
	solution/.code=\solutiontrue\solutiondelayedfalse%
			\justificationfalse,
	solution*/.code=\solutiontrue\solutiondelayedtrue%
			\justificationfalse,
	hint/.code=\csuse{hint#1}\csuse{hintocg#1}\justificationfalse,
	hint/.default=true,
	hint*/.code=\csuse{hint#1}\hintocgfalse\justificationfalse,
	hint*/.default=true, 
	nojustification/.code=\justificationfalse,
	.search also=/IGD
}
\pgfkeys{/IGD/.unknown/.code=%
	{\edef\class@options{\class@options,\pgfkeyscurrentname}}
}
%
\def\cpge@mkdir#1{%
	\IfFileExists{/dev/null}
		{\immediate\write18{mkdir -p #1}}
		{\immediate\write18{md  "#1"}}%
}
\@ifundefined{ifsubdoc}
	{\ProcessPgfOptions{/IGDS}}
	{\ProcessPgfOptions{/IGD}}


\expandafter\LoadClass\expandafter[\class@options]{article}

%% Declarations 
\newcount\cpge@counta
\newcount\cpge@countb 
\newcounter{tmpdo}


\newif\ifinsolutions
\newif\ifnofootimage
\newif\ifcpge@withsol % vrai si le numero de la question courante doit être un hyperlien 
\newif\ifcpge@withhint % vrai s'il y a au moins une indication dans le sujet en cours
\newif\ifholed@jscore
\newif\ifcpge@tmpswa
\newif\ifcpge@tmpswb

\newtoks\toks@sol % retient la solution de la question en cours
\newtoks\toks@hint % retient l'indication de la question en cours

%%%% switches utilisés localement  

\newif\ifcpge@tmpa
\newif\ifcpge@tmpb
\newbox\trash@box



%%%%% Packages du projet 
\RequirePackage[customtitles]{cpgebase}
\RequirePackage{cpgesub}
\RequirePackage{cpgemath}
\RequirePackage{cpgecommon}

%%%%%%%%%%%%%%%%%%



%%%% Strategie d'inclusion de fichier
%%%% utilise sur une version modifiée de subfile.sty renommé en cpgesub.sty
%%%  

\cpgeset[include]{
	solution/.code=\csname solution#1\endcsname\solutiondelayedfalse,
	solution*/.is if=solutiondelayed,
	straight/.is if=straight,
	hint/.is if=hint,
	before solutions/.code=\gdef\before@solutions@hook{#1},
	solution file/.code=\def\solfilename{#1},
	corrige/.store in=\corr@common@opt,
	only/.code=\csvtolistadd\eno@list{#1}%
}
\def\corr@common@opt{}
\def\straightmode@include{%
	\def\corrige{\Corrige}%
	\let\endcorrige\endCorrige%
}
\AtBeginDocument{%
	\ifdraft\straighttrue\fi
	\ifstraight\straightmode@include\fi
}

\NewDocumentCommand\cpgeinclude{ om }{
	\RenewDocumentCommand\titre{sod()}{}%
	\begingroup
		\IfFileExists{#2-cor.tex}{\def\solfilename{#2-cor}}{}
		\IfValueT{#1}{\cpgeset[include]{#1}}%
		\unless\ifstraight\ifsolution
			\ifundef\solfilename{}{\subdoc{\solfilename}}%
		\fi\fi%
		\IfFileExists{#2-eno.tex}
			{\subdoc{#2-eno}}
			{\subdoc{#2}}
		\ifstraight\ifundef\solfilename{}{\subdoc{\solfilename}}\fi%
	\endgroup%
	\undef\eno@list%
}

\DeclareDocumentCommand\cpgetheme{O{} m}{%
	\cpgeset[theme]{#1}
	\unless\ifdraft
		\IfFileExists{#2dev.sty}
			{\AtEndPreamble{\RequirePackage{#2dev}}}{}%
	\fi%
	\reloadcolors%
}

\pgfkeys{/cpge/@title/.is family}
\def\cpgetset{\pgfqkeys{/cpge/@title}}
\cpgetset{
 align/.is choice,
 align/c/.code=\def\@lign{center},
 align/l/.code=\def\@lign{left},
 align/r/.code=\def\@lign{right}
}

\def\cpget@align#1#2#3{\csletcs{#1@align}{fil#2}\csletcs{#1label@align}{fil#3}}
\let\fildefault\relax

\DeclareDocumentCommand\cpget@shape{mmoo}{%
 \csdef{#2@shape}{#1}
 \IfValueTF{#4}
  {\cpget@align{#2}{#3}{#4}}
  {\IfValueT{#3}{\cpget@align{#2}{#3}{#3}}}
}
\def\cpge@format#1{%
 \begingroup\def\cpge@tmpa{\endgroup\cpgetformat{#1}}%
 \expandafter\cpge@tmpa\expandafter%
}


%%%%%%%%%%%%%%%%%%


		
%%%%% Other package initialisation
\RequirePackage{currfile}
\RequirePackage{lastpage}
\RequirePackage[pdfencoding=auto,psdextra]{hyperref}
\hypersetup{colorlinks,linkcolor=linkcol}
\pdfstringdefDisableCommands{%
	\def\({}%
	\def\){}%
}
\let\ToP\texorpdfstring
%\RequirePackage{bookmark}

%%%%%%%%%%%%%%%%%%%%%%%%
%%% Les declarations %%%

% Les constantes									
\dimdef\choice@dv{\z@}
\dimdef\choice@dh{4pt}
\def\choice@char{\phantom{V}}
\def\mlform#1{$\let\\\relax#1$}

% Les variables globales
% quelque soit la configuration, les questions auront chacune un numéro unique.
%\cpgedefcounter est définie dans cpgebase.sty 
\cpgedefcounter{@devoir}{}(D)
\cpgedefcounter{section}{}[@devoir](*S) % (*S) pour écraser le raccourci S
\cpgedefcounter{@problem}{}[@devoir](Y)%[@devoir,section](*X)
\cpgedefcounter{solution}{}
\cpgedefcounter{parti}{}[@problem](P)
\cpgedefcounter{partii}{}[parti](p)
\ifltxcounter{score}{}{\newcounter{score}[@devoir]}
\ifltxcounter{score@tmp}{}{\cpgedefcounter{score@tmp}{}[@problem]}
\cpge@labelformat{score}{#1}
\cpge@cnt@shortcut{*X}{current@counter}



%%% Commandes utilitaires
\def\cpge@indexdo#1#2#3{%
	\ifnumcomp{#1}>{#3}
		{\stepcounter{#2}}
		{\ifnumcomp{#1}<{#3}{\stepcounter{#2}}{\listbreak}}%
}
\def\cpge@listcount#1#2{\begingroup%
	\setcounter{#1}{0}%
	\def\do##1{\stepcounter{#1}}%
	\dolistloop{#2}%
	\endgroup%
}	
\def\cpge@indexset#1#2#3{%
	\setcounter{#2}{1}%
	\forlistloop{\cpge@indexdo{#1}{#2}}{#3}%
}
\tcbset{ifvaluetf/.code n args =
	{3}{\IfValueTF{#1}{\pgfkeysalso{#2}}{\pgfkeysalso{#3}}}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Création des divisons de document \devoir, \section, \problem...  %%%
%%% repose sur cpgetitle.sty qui fusionne titlesec, titleps et titletoc %%%

%%% Résiliation des commandes de titrage usuelles
\undef\section
\undef\subsection
\undef\parapgraph
\undef\subparagraph

%%% La nouvelle architecture de titrage
\cpgetclass{\@devoir}[0]{top} % -> \devoir 
\cpgetclass{\section}{straight}[\@devoir]
\cpgetclass{\@problem}{straight}[\section] % -> {probleme}, {exercise}, ...
\cpgetclass{\parti}{straight}[\@problem] 
\cpgetclass{\partii}{straight}[\parti]

\DeclareRobustCommand\dnstl{%
		D%
		\kern-.08em\relsize{-2}\textit{NS}%
		\relsize{2}\kern-.15em T\kern-.15em\raisebox{-.2em}{L}%
	}
%%% Styles des versions internes des commandes de titre 

\cpget@shape{display}{devoir}[center]
\cpge@format{\@devoir}[display]
	{\csundef@afterexec{hook@beforedevtitle}}
	{\devoirlabel@align%
		\ifcpge@tmpswb
			\addtocounter{@devoir}{-1}%
			\deco@devoirlabelnumberless{}%
		\else
			\deco@devoirlabel{\devoir@name}{\label@@devoir}
		\fi
	}
	{\z@}
	{\devoir@align\deco@devoir{\cnt@name}{#1}}
	[\csundef@afterexec{hook@afterdevtitle}]

\cpge@format{name=\@devoir, numberless}[display]
	{\csundef@afterexec{hook@beforedevtitle}}
	{\devoirlabel@align%
		\deco@devoirlabelnumberless}
	{\z@}
	{\devoir@align\deco@devoir{#1}}
	[\csundef@afterexec{hook@afterdevtitle}]
\cpgetspacing*{\@devoir}{\z@}{-1cm}{*6}



%%%%% L'équivalent de \section
\cpget@shape{hang}{section}[default]
\cpge@format{\section}[\section@shape]
  {\LARGE\scshape}
  {\sectionlabel@align\deco@sectionlabel{\label@section}}
  {1pc}
  {\section@align\deco@section{#1}}
\cpgetspacing*{\section}{-1pc}{*3}{*2}

%%%%% version interne des titres pour les sujets
\def\after@problemtitle{%
	\csundef@afterexec{hook@afterprobtitle}%
	\ifdef{\problem@name}
		{
			\edef\cpge@tmpe{\usevalue{problemscore:\the@problem}}%
	 		\ifdefvoid{\cpge@tmpe}{}
	 			{\mbox{}\\\normalsize\textit{(sur \cpge@tmpe{} points)}}
		}{}%
}
\cpget@shape{display}{problem}[center]
\def\link@problemlabel#1{%
	\ifsolution%
		\ifisasolution%
			\hypersetup{pdfborder=0 0 0}%
			\hypertarget{\cpge@current@id:cor}
				{\hyperlink{\cpge@current@id:eno}{\deco@problemlabel{#1}}}%
		\else%
			\hypersetup{pdfborder=0 0 0}%
			\hypertarget{\cpge@current@id:eno}
				{\hyperlink{\cpge@current@id:cor}{\deco@problemlabel{#1}}}%
		\fi%
	\else%
		\deco@problemlabel{#1}%
	\fi%
}
\cpge@format{\@problem}[\problem@shape]
  {\LARGE}
  {\problemlabel@align
  	\link@problemlabel{\cnt@name}}
  {\z@}
  {\unless\ifcpge@tmpswa\problem@align\deco@problem{#1}\fi}
  [\after@problemtitle]
\cpge@format{name=\@problem, numberless}[\problem@shape]
  {\LARGE}
  {\problemlabel@align\deco@problemlabelnumberless{}}
  {\z@}
  {\unless\ifcpge@tmpswa\problem@align\deco@problem{#1}\fi}
  [\after@problemtitle]
\cpgetspacing*{\@problem}{\z@}{*3}{*3}

%%%%%%

%%% \parti, à utiliser dans \problem ou \exercise
\setcounter{secnumdepth}{4}
\cpgetformat{\parti}
  {\large\scshape}
  {\deco@partilabel{\label@parti}}
  {.5em}
  {\protect\boldmath\bfseries\deco@parti{#1}}
\cpgetspacing*{\parti}{\z@}{*3}{*1.5}

%%% \partii, soupartie, subdivision de \parti
\cpgetformat{\partii}
  {\scshape}
  {\deco@partiilabel{\label@partii}}
  {6pt}
  {\protect\boldmath\bfseries\deco@partii{#1}}
\cpgetspacing*{\partii}{\z@}{*3}{*1.5}

%%%%%%%%

%%%%%% Surcouches des commandes de titrages

%% Ajout d'une métadonnée devoir pour une utilisation avec \titre 
\def\Devoir#1{\gdef\cpge@devoir{#1}}
\let\cpge@devoir\relax

\cpgeaddkeyword{title}{devoir}{{\LARGE\scshape\deco@devoir{\csuse{cpge@devoir}}%
                  \global\cpge@dima\baselineskip}\baselineskip\cpge@dima}

\def\deco@devoir#1#2{{\huge#1} \\ #2}
\def\deco@devoirlabel#1#2{#1\ #2}
\cpgedefdeco{devoirlabelnumberless}{}

\cpgeset[@devoir]{%
	name/.store in=\devoir@name,
	name=sujet,
	number/.code=\setcounter{@devoir}{\numexpr#1-1},
	alt title/.store in=\alt@devname,
	alt/.style={alt title=#1},
	after title/.code=\title@parser{\begingroup#1\endgroup}%
		\expandafter\def\expandafter\hook@afterdevtitle\expandafter{\title@contents},
	before title/.code=\title@parser{\begingroup#1\endgroup\par}%
		\expandafter\def\expandafter\hook@beforedevtitle\expandafter{\title@contents},
	title deco/.code=\cpgedefdeco{devoir}{#1},
	label deco/.code=\cpgedefdeco{devoirlabel}{#1},
}

\NewDocumentCommand\devoir{sO{}md()}{%
	\IfBooleanT{#1}{\cpge@tmpswbtrue}
	\def\cnt@name{#3}%
	\cpgeset[@devoir]{#2}%
	\ifdefvoid{\alt@devname}
	  	{%
			\IfValueTF{#4}
				{\cpge@tmpswafalse\@devoir[\textsc{#3~:}~#4]{#4}}
				{\cpge@tmpswatrue\@devoir[#3]{}}%
		}%
		{%
			\IfValueTF{#4}
				{\cpge@tmpswafalse\@devoir[\textsc{#3~:}~\undef@afterexec\alt@devname]{#4}}
				{\cpge@tmpswatrue\@devoir[\textsc{#3~:}~\undef@afterexec\alt@devname]{}}%
		}
	\IfBooleanT{#1}{\cpge@tmpswbfalse}
}

%%%%%%

\cpgedefdeco{sectionlabel}{\llap{\hb@xt@\Gm@littlemargin{%
	\genboxcmd[tcbox width=forced center,width=\Gm@littlemargin-6pt]
		{\normalsize\bfseries#1}}}\kern4pt
	}
\cpgedefdeco{section}{\protect\boldmath\bfseries #1}

%%%%%%%

\cpgedefdeco{problem}{{#1 }}
\cpgedefdeco{problemlabel}{%
	{\Large\scshape\bfseries%
	\deco@lpattern\enskip#1\enskip\deco@rpattern}%
}
\cpgedefdeco*{lpattern}{\cpge@square}
\cpgedefdeco*{rpattern}{\cpge@square}

\cpgeset[@problem]{%
	solution/.code=\csuse{solution#1}\solutiondelayedfalse,
	solution*/.is if=solutiondelayed,
	hint/.is if=hint,
	hint*/.is if=hintocg,
	solution/.default=true,
	current counter/.code=\letcs\thecurrent@counter{the#1},
	alt title/.store in=\alt@problem,
	alt/.style={alt title=#1},
	before/.store in=\hook@beforeproblem,
	after/.store in=\hook@afterproblem,
	before title/.code=\title@parser{#1}%
		\expandafter\long\expandafter\def\expandafter
		 \hook@beforeprobtitle\expandafter{\title@contents},
	after title/.code=\title@parser{#1}%
		\expandafter\long\expandafter\def\expandafter\hook@afterprobtitle
		 \expandafter{\title@contents},
	title deco/.code=\cpgedefdeco{problem}{#1},
	label deco/.code=\cpgedefdeco{problemlabel}{#1},
	corrige/.code=\csgpreto{\cpge@current@id @opts}{#1,}, 
}
\cpgeset[solution]{
	before/.store in=\hook@beforeproblem,
	after/.store in=\hook@afterproblem,
	before title/.code=\title@parser{#1}%
		\expandafter\long\expandafter\def\expandafter
		 \hook@beforeprobtitle\expandafter{\title@contents},
	after title/.code=\title@parser{#1}%
		\expandafter\long\expandafter\def\expandafter\hook@afterprobtitle
		 \expandafter{\title@contents},
	question list/.store in=\queslist,
	.unknown/.code={},
}
\def\noqueslistmessage{%
	\begin{lrmargin}{3em}{3em}%
		\itshape\Large\color{DarkRed}%
		Aucune liste de numéros de questions n'est disponible (voir la documentation).
	\end{lrmargin}
}
\def\setup@id{%
		\ifisasolution%
			\ifstraight%
				\ifcsundef{\cpge@current@id @list}{}
					{\edef\queslist{\csuse{\cpge@current@id @list}}}%
			\fi% 
		\else%
			\ifcsdef{label@@\cpge@current@id}
				{\ClassError{cpgedev}{\problem@name\space\arabic{\problem@name}\space:\space
				  Identifiant\space \cpge@current@id\space déjà\space utilisé}{}}
				{\csxdef{label@@\cpge@current@id}{%
					\csuse{dudela@\problem@name}\ 
				  	 \csuse{label@\problem@name}%
					}%
				}%
		\fi%
}

\DeclareDocumentCommand\problemtitle{
		s % #* numbered or not
		m % #2 counter name
		m % #3 printed name
		d() % #4 optional title
		d<> % #5 optional label for referencing
	}{%
		\def\problem@name{#2}%
		\IfBooleanF{#1}{%
			\IfValueTF{#5}
				{\refstepcounter{#2}}
				{\stepcounter{#2}}%
			}%
		\IfValueT{#5}{\label{#5}}%
		\IfBooleanTF{#1}
			{\def\cnt@name{#3}}
			{\def\cnt@name{\csuse{label@#2}}}%
		\IfValueTF{#4}%
			{\cpge@tmpswafalse%
				\ifdef{\alt@problem}
					{\@problem[\textsc{\cnt@name~:~}\alt@problem]{#4}}
					{\@problem[\textsc{\cnt@name~:~}#4]{#4}}%
			}{\cpge@tmpswatrue\@problem[\textsc{\cnt@name}]{}}%
	}	
\def\dudela#1{\csuse{dudela@#1}}
\DeclareDocumentCommand\gentitle{
		m % #3 printed name
		d() % #4 optional title
	}{%
		\def\cnt@name{#1}
		\IfValueTF{#2}%
			{\cpge@tmpswafalse\ifdef{\alt@problem}
				{\@problem[\textsc{\cnt@name~:~}\alt@problem]{#2}}
				{\@problem[\textsc{\cnt@name~:~}#2]{#2}}%
			}{\cpge@tmpswatrue\@problem[\textsc{\cnt@name~:}]{}}%
	}

\DeclareDocumentCommand\cpgenewexeprob{
		s %* corrige or enonce
		m %2 counter name
		m %3 printed name
		m %4 before hook for the solution title
		m %5 counter label format
		m %6 solution title prefix
		d() %7 counter shortcut
		}{
	\csdef{hook@precor@#2}{#4}
	\IfValueTF{#7}
		{\cpgedefcounter{#2}{#5}[@devoir](#7)}
		{\cpgedefcounter{#2}{#5}[@devoir]}%
	\csdef{dudela@#2}{#6}%
	\IfBooleanT{#1}{%
		\NewDocumentEnvironment{#2}{m o d() d<>}
			{%
				\def\cpge@current@id{##1}%
				\IfValueT{##2}{\cpgeset[solution]{##2}}%
				\csuse{hook@precor@#2}%
				\csuse{hook@beforeprobtitle}
				\problemtitle{#2}{#3}(##3)<##4>%
				\csuse{hook@afterprobtitle}
				\setup@id%
				\csuse{hook@beforeproblem}%
			}{%
				\endxsol%
				\csuse{hook@afterproblem}%
			}%
	}
	\IfBooleanT{#1}{%
		\NewDocumentEnvironment{#2*}{m o d() d<>}
			{%
				\def\cpge@current@id{##1}%
				\IfValueT{##2}{\cpgeset[solution]{##2}}%
				\csuse{hook@precor@#2}%
				\csuse{hook@beforeprobtitle}
				\problemtitle*{#2}{#3}(##3)<##4>%
				\csuse{hook@afterprobtitle}
				\setup@id%
				\csuse{hook@beforeproblem}%
			}{%
				\endxsol%
				\csuse{hook@afterproblem}%
			}%
	}
	\IfBooleanF{#1}{%
		\NewDocumentEnvironment{#2}{m O{} d() d<>}{%
			\def\cpge@current@id{##1}%
			\csepreto{\cpge@current@id @opts}{\expandonce\corr@common@opt,}%
			\cpgeset[@problem]{current counter=#2,##2}%
			\ifcsundef{##1@title}{\csdef{##1@title}{##3}}{}%
			\problemtitle{#2}{#3}(##3)<##4>
			\setup@id%
			\setup@sol%
			\setup@hint%
			\csuse{hook@beforeproblem}%
		}{%
			\exit%
			\csuse{hook@afterproblem}%
			\close@problem{#2}%
		}
	}
	\IfBooleanF{#1}{%
		\NewDocumentEnvironment{#2*}{m O{} d() d<>}{%
			\def\cpge@current@id{##1}%
			\csepreto{\cpge@current@id @opts}{\expandonce\corr@common@opt,}%
			\cpgeset[@problem]{current counter=#2,##2}%
			\ifcsundef{##1@title}{\csdef{##1@title}{##3}}{}%
			\problemtitle*{#2}{#3}(##3)<##4>
			\setup@id%
			\setup@sol%
			\setup@hint%
			\csuse{hook@beforeproblem}%
		}{%
			\exit%
			\csuse{hook@afterproblem}%
			\close@problem{#2}%
		}
	}
}

\newif\ifisasolution
\cpgedefdeco{pattern}{}
\cpgenewexeprob{probleme}{Problème}{}{Problème |1| }{du}(R)
\cpgenewexeprob{exercice}{Exercice}{}{Exercice |1| }{de l'\ignorespaces}(E)
\cpgenewexeprob{cours}{Questions de cours}{}{Questions de cours |1|}{des}(K)
\cpgenewexeprob{epreuve}{\ifsolution\'Enonc\'e\fi}{}{}{}
\cpgenewexeprob{enonce}{\ifsolution\'Enonc\'e\fi}{}{}{}
\cpgenewexeprob*{Corrige}{}{\isasolutiontrue\setup@xsol}{}{}
%\def\label@epreuve{\ifsolution\'Enonc\'e\fi}
%\def\label@enonce{\ifsolution\'Enonc\'e\fi}
\def\label@Corrige{Corrig\'e \csuse{label@@\cpge@current@id}}

%%%%%%%%%%%%%%

\cpgedeflabel{parti}{|I|}
\cpgedefdeco{partilabel}{\bfseries#1.}
\cpgedefdeco{parti}{#1}
\cpgedeflabel{partii}{|P|.|A|}
\cpgedefdeco{partiilabel}{\bfseries#1.}
\cpgedefdeco{partii}{#1}

%%% table des matières
\let\cpget@savemark\relax
\def\toclevel@@devoir{0}
\def\toclevel@section{1}
\def\toclevel@@problem{2}
\def\toclevel@parti{3}
\def\toclevel@partii{4}
\cpgetcontents{@devoir}[0em]{}{\Large}{\Large}{\hfill\cpgetcontentspage}
\cpgetcontents{section}[0em]{\bigskip}{\Large}{\Large}{\hfill\cpgetcontentspage}
\cpgetcontents{@problem}[1em]{\medskip}{\bfseries\boldmath}{\scshape}{\hfill\cpgetcontentspage}
\cpgetcontents{parti}[3em]{}{}{}{}
\cpgetcontents{partii}[4em]{}{}{}{}

%%% Entrées pour pagestyles
 
\let\@devoirtitle\@empty
\let\sectiontitle\@empty
\let\@problemtitle\@empty
\let\partititle\@empty
\let\partiititle\@empty
\cpget@setifthe{@devoir}
\cpget@setifthe{section}
\cpget@setifthe{@problem}
\cpget@setifthe{parti}
\cpget@setifthe{partii}

% les divisions qui seront marquées pour une utilisation dans pagestyles    
\cpgetsettitlemarks{@devoir,section,@problem,parti}
% Ajout des mots clés section et problem pour utilisation avec \idefghead et \idefgfoot.
\cpgeaddkeyword*{hf}{devoir}
	{\ifthe@devoir{\MakeLowercase{\@devoirtitle}}{}}
\cpgeaddkeyword*{hf}{section}
	{\ifthesection{\MakeLowercase{\sectiontitle}}{}}
\cpgeaddkeyword*{hf}{problem}
	{\ifthe@problem{\MakeLowercase{\@problemtitle}}{}}
\cpgeaddkeyword*{hf}{parti}
	{\iftheparti{\MakeLowercase{\partititle}}{}}
\cpgeaddkeyword{hf}{pages}{page\enskip\thepage{} / \pageref*{LastPage}}
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Finalisation du barème %%%

\NewDocumentCommand\setscore{O{0}}{%
		\addtocounter{score}{#1}%
		 \@expandtwoargs\defvalue{globalscore}{\thescore}%
 }
\def\showscore{\usevalue{globalscore}}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Gestion des questions et des solution	%%% 
%%% dans un probleme ou un exercice 			%%%

\unless\ifdraft\ifhintocg
	\RequirePackage[tikz]{ocgx2}
\fi\fi

\def\setup@hint{%
	\long\def\hint##1{}%
	\ifdraft
		\long\def\hint##1{\mini(ind)##1\endmini}%
	\else%
		\ifhint%
			\ifhintocg%
				\let\hint\hint@box%
			\else%
				\global\toks@hint{}%
				\def\hint{\x@hint\ques@hint}%
			\fi%
		\fi%
	\fi%
}

\tikzset{
	hintbox/.style={rounded corners=2pt,
		inner xsep=5pt, inner ysep=3pt,
		text width=\linewidth-10pt-2\pgflinewidth,
		%align=justify,
		draw=linkcol,
		fill=yellow!20,
		font=\sffamily\small
	},
	hintradiobox/.style={
		rounded corners=2pt, 
		text width=2em, 
		align=center, anchor=west,
		fill=linkcol, text=white,
		draw=none, inner xsep=.2em, inner ysep=2pt,
		font=\sffamily\footnotesize\scshape\bfseries,
	}
}
\newcounter{fakecounter}
\def\set@xhint{
	\ifundef\cpge@listctr
	{\stepcounter{fakecounter}%
	  \def\hintctr{fakecounter}%
	  \def\label@hintctr{\arabic{fakecounter}}%
	}{\def\hintctr{\cpge@listctr}}%
}
\long\def\hint@box#1{%
	\par
	\set@xhint%
  	\begin{tikzpicture}
		\begin{scope}[ocg={ref=\csuse{label@\hintctr}, status=invisible, name=HINT\arabic{\hintctr}}]
  			\node[hintbox] (hint) 
			{\null\hskip2.8em\parbox{\linewidth-2.8em}{#1}};%
		\end{scope}%
  		\node at ([xshift=1pt]hint.west) 
				[overlay, hintradiobox, switch ocg=\csuse{label@\hintctr}]
				{ind} ;%
  \end{tikzpicture}%
}
\def\hintradio{%
  \tikz \node [hintradiobox] {ind} ;%
}
\def\ques@hint#1{\@bsphack
	\long\edef\cpge@tmpe{\the\toks@hint}
	\eappto\cpge@tmpe{\noexpand\xhint{\csuse{label@\hintctr}}}
	\eappto\cpge@tmpe{\unexpanded{#1}\noexpand\par}
	\expandafter\global\expandafter\toks@hint\expandafter{\cpge@tmpe}
\@esphack}
\def\xhint#1{%
	\hypersetup{pdfborder=0 0 0}%
	\hypertarget{hint:\cpge@current@id:#1}%
		{\hyperlink{eno:\cpge@current@id:#1}%
			{\deco@linksol{#1}\enskip}}%
}
\def\x@hint{%
	\set@xhint%
	\hypersetup{pdfborder=0 0 0}%
	\hyperlink{hint:\cpge@current@id:\csuse{label@\hintctr}}{\hintradio}%
	}

% Adaptation de \xit pour les problèmes avec solutions
\def\switch@to@ques{\csletcs{deco@\cpge@listctr}{deco@\cpge@listctr @}}
% \NewDocumentCommand\startques{t\r E{\op}{{}}}{%
% 	\IfBooleanTF{#1}
% 		{\begin{xenum}[r,#2]}
% 		{\begin{xenum}[#2]}%
% 	\switch@to@ques%
% }
% \NewDocumentCommand\init@ques{m t- t- t- t\r t+  E{\op}{{}} }{
% 	\IfBooleanTF{#5}%
%         {\startques\r\op{#7}}
%         {\IfBooleanT{#6}{\startques\op{#7}}}%
% 	\IfBooleanT{#2}{\exit-\IfBooleanT{#3}{\exit-\IfBooleanT{#4}{\exit-}}}%
% 	#1%
% }
% \NewDocumentCommand\x@ques{o e{\bar\zap} d() d<>}{%
% 	\IfValueT{#2}{%
% 		\addtocounter{score@tmp}{#2}%
% 		\addtocounter{score}{#2}%
% 		\def\cpge@tmpscore{\ttfamily\footnotesize(#2pt)}%
% 	}%
% 	\IfValueT{#3}
%             {\ifblank{#3}{\stepcounter{\cpge@listctr}}{\addtocounter{\cpge@listctr}{#3}}}%
% 	\IfValueTF{#1}
% 		{\item@ques[#1]%
% 			\ifblank{#1}{\stepcounter{\cpge@listctr}\hskip-\labelsep}{}}%
% 		{\item@ques}
% 	\IfValueT{#4}{\deco@itemtitle{#4}}%
% 	\IfValueT{#5}{\label{\cpge@enumlabelprefix#5}}%
% }
\def\xques{\init@ques{\cpge@withsoltrue\x@ques}}
\def\zques{\init@ques{\cpge@withsolfalse\x@ques}}
\NewDocumentEnvironment{ques}{}{\cpge@withsoltrue\x@ques}{} 
% \def\stopques{\exit}
\def\draft@solution{\par\medskip\textbf{\scshape solution :}\newline\nopagebreak}

\def\save@solution{%\
	\let\endques\close@ques%
	\cpgeprotected@iwrite\solhandle@file{}{\string\xsol}%
	\cpgefilesave{solhandle}%
}
\def\close@ques{%
		\endcpgefilesave%
}
\newenvironment{writetosol}{\cpgefilesave{solhandle}}{\endcpgefilesave}
\def\aux@dir{tmp}
\def\setup@sol{%
	\setupsolutionslinks%
	\ifsolution\hinttrue\fi%
	\let\solution\draft@solution
	\open@solfile%
}
\def\open@solfile{%
		\unless\ifdraft
			\ifsolution%
				\ifcsundef{\cpge@current@id @}{
					\cpgeopenfile{solhandle}[\aux@dir/\cpge@current@id-cor]%
				}{}%
			%\else%
			%	\cpgeopenfile{solhandle}[/dev/null]%
			\fi%
			\let\solution\save@solution%
		\fi%
}
\NewDocumentEnvironment{cpgewrite}{mm !o !d() !d<>}
	{%
		\csgdef{#2@}{}%
		\IfValueT{#3}{\csgdef{#2@opts}{#3}}% \cpge@current@id @opts
		%\csshow{#2@opts}
		\IfValueT{#4}{\csgdef{#2@title}{#4}}%
		\IfValueT{#5}{\csgdef{#2@label}{#5}}%
		\cpgewriteonce{\aux@dir/#2-#1}%
	}
	{\endcpgewriteonce}
\def\corrige{\cpgewrite{cor}}
\let\endcorrige\endcpgewrite
\csdef{corrige*}{\cpgewrite{cor}}
\cslet{endcorrige*}\endcpgewrite
\cpgenewexeprob*{immediatcorrige}{}{\isasolutiontrue\setup@xsol}{}{}

\def\queslist{}
\def\close@problem#1{%
	\ifnum\c@score@tmp>\z@%
			\@expandtwoargs\defvalue{problemscore:\label@@#1}{\thescore@tmp}
	\fi%
	\ifstraight%
		\csxdef{\cpge@current@id @list}{\queslist}%
	\fi
	\edef\cpge@tmpe{\the\toks@hint}
	\ifdefempty\cpge@tmpe{}{\parti*{Indications}\cpge@tmpe}%
	\unless\ifdraft%
		\ifsolution%
			\cpgeclosefile{solhandle}
			\ifsolutiondelayed
				\ifdefempty{\queslist}{}{%
					\tcbrecord{%
						\string\Solution
							{\cpge@current@id} % identifiant
							{\expandafter\expandonce\csname \cpge@current@id @title\endcsname} % titre (de l'énoncé) 
							{\expandafter\expandonce\csname \cpge@current@id @opts\endcsname} % options passées avec "corrige=..."
							{\queslist}% liste des questions avec solutions
					}%
				}%
			\else	
				\ifdefempty\queslist{}{%
					\begingroup%
					\edef\cpge@tmpa{\endgroup%
						\noexpand\Solution%
							{\cpge@current@id} % identifiant
							{\expandafter\expandonce\csname \cpge@current@id @title\endcsname} % titre (de l'énoncé) 
							{\expandafter\expandonce\csname \cpge@current@id @opts\endcsname} % options passées avec "corrige=..."
							{\queslist}% liste des questions avec solutions
					}%
					%\show\cpge@tmpa%
					\cpge@tmpa%
				}%
			\fi%
		\fi%		
	\fi%
	\gdef\queslist{}%
}
\def\shipoutsolutions{%
	\unless\ifstraight\ifsolutiondelayed%
		\tcbstoprecording%
		\csuse{before@solutions@hook}%
		\input{\jobname.rec}
	\fi\fi
}	
\let\corriges\shipoutsolutions
\NewDocumentCommand\Solution{ mmmm }{
	\IfFileExists{\aux@dir/#1-cor.tex}{%
	\begin{Corrige}{#1}[#3](#2)
		\ifdefempty\queslist{\def\queslist{#4}}{}
		\ifdefempty\queslist{\noqueslistmessage}{}%
		\input{\aux@dir/#1-cor}
	\end{Corrige}}{}
}
%%% Style des numérotations pour les questions et les solutions  
%%% selon disponibilité de la solution ou non.
\AtBeginDocument{
	\tcbset{%
		font/.style={fontupper=#1},
		collink/.style={%
			colback=linkcol, 
			colframe=linkcol, 
			coltext=white, 
			font=\sffamily\small\bfseries\vphantom{19}},
		soldeco/.style={%
			collink,
			tcbox width=forced left,
			text width=2.6em,
			sharp corners=west,
			arc=5pt,
			boxsep=2pt,
			font=\sffamily\footnotesize\bfseries\vphantom{19}},
			enodeco/.style={
			tcbox width=forced right,
			text width=2.4em,
			sharp corners=east,
			arc=4.6pt,
			boxsep=0pt, top=2pt, bottom=2pt, right=2pt,
			font=\sffamily\small\bfseries\vphantom{19}}
	}
}
\def\outer@ques@nolink#1#2{%
	\ifhint%
		\ifdef\cpge@tmpscore%
			{%
				\llap{\smash{\hb@xt@\dimexpr#1\relax{\cpge@tmpscore}\hss}}%
			}{}%
	\fi%
	\csuse{deco@nolink\cpge@listctr}{#2}%
	}	
\def\outer@ques@link#1#2{%
	\ifdef\cpge@tmpscore%
		{%
			\llap{\smash{\hb@xt@\dimexpr#1\relax{\cpge@tmpscore}\hss}}%
		}{}%
	\ifcpge@withsol%
		\hypersetup{pdfborder=0 0 0}%
		\hypertarget%
			{eno:\cpge@current@id:#2}%
			{\hyperlink{cor:\cpge@current@id:#2}{\csuse{deco@link\cpge@listctr}{#2}}}%
		\xappto\queslist{#2,}%
	\else%
		\csuse{deco@nolink\cpge@listctr}{#2}%
	\fi%
	}
\def\outer@sol@deco#1{%
	\hypersetup{pdfborder=0 0 0}%
	\hypertarget{cor:\cpge@current@id:#1}%
		{\hyperlink{eno:\cpge@current@id:#1}%
			{\deco@linksol{#1}}}%
}
\ifdraft
	\cpgedefdeco{linkenumi}{\bfseries #1.}
	\cpgedefdeco{linkenumii}{\bfseries #1.}
	\cpgedefdeco{nolinkenumi}{\bfseries #1.}
	\cpgedefdeco{nolinkenumii}{\bfseries #1.}
	\cpgedefdeco{linksol}{\bfseries #1.}
	\cpgedefdeco{indication}{\textbf{#1 :}\kern4pt}
\else
	\cpgedefdeco{linkenumi}{\genboxcmd[enodeco,collink]{#1}}
	\cpgedefdeco{linkenumii}{\genboxcmd[enodeco,collink]{#1}}
	\cpgedefdeco{nolinkenumi}{\genboxcmd[enodeco]{#1}}
	\cpgedefdeco{nolinkenumii}{\genboxcmd[enodeco]{#1}}
	\cpgedefdeco{linksol}{\genboxcmd[soldeco]{#1}}
	\cpgedefdeco{indication}{\textbf{#1 :}\kern4pt}
\fi 

%%% \xsol, quand \xques est utilisée, solution écrite séparément   
\def\xsol@env{%
	\insolutionstrue
	\@itemdepth\@ne%
   	\list\relax%
        {%
         \listparindent\z@%
		   \labelwidth\z@%
		    \itemindent\labelsep%
			\itemsep\medskipamount%
		     \leftmargin\z@%
			  \let\makelabel\outer@sol@deco%
        }%
 }
\def\endxsol{\ifinsolutions\endlist\fi}
\def\setup@xsol{\let\xsol\first@xsol}

\def\terminate@questlist@pop#1\cpge@nil{
	\in@{,}{#1}
	\ifin@
		\queslist@pop#1\cpge@nil%
	\else
		\def\curr@item{#1}
	\fi%
}
\def\queslist@pop#1,#2\cpge@nil{%
	\def\curr@item{#1}%
	 \def\queslist{#2}%
	}
\def\tmp@queslist@pop#1{\terminate@questlist@pop#1\cpge@nil}
\def\first@xsol{%
	\ifdefempty\queslist%
		{\def\xsol{\fake@xsol}}
		{\def\xsol{\true@xsol}}%
	\xsol@env\xsol%
}
\DeclareDocumentCommand\fake@xsol{od()d<>}{%
	\IfValueTF{#1}
		{
			\item[#1]%
			\IfValueT{#3}{%
				\def\@currentlabel{#1}%
 				\phantomsection\label{#3}%
			}%
		}%
		{\item[\scshape fixme]}%
	\IfValueT{#2}{\deco@unitetitle{#2}\par\nobreak}%
}
\DeclareDocumentCommand\true@xsol{od()d<>}{%
	\expandafter\tmp@queslist@pop\expandafter{\queslist}
	\IfValueTF{#1}
		{\item[#1]}
		{\item[\curr@item]}%
	\IfValueT{#3}{
		\def\@currentlabel{\curr@item}%
 		\phantomsection\label{#3}%
	}
	\IfValueT{#2}{\deco@unitetitle{#2}\par\nobreak}%
}
\NewDocumentCommand\xzapsol{o}{%
	\IfValueF{#1}{\expandafter\tmp@queslist@pop\expandafter{\queslist}}
	\IfValueT{#1}{%
		\ifnum#1>\z@
			\expandafter\tmp@queslist@pop\expandafter{\queslist}%
			\edef\cpge@tempa{\noexpand\xzapsol[\number\numexpr#1-1]}
			\expandafter\cpge@tempa
		\fi
		}
	}	
\AtBeginDocument{
	\ifcompact
		\cpgesetenum{1}{marge*}
		\cpgesetenum{2}{marge*}
	\else	
		\cpgesetenum{1}{marge}
		\cpgesetenum{2}{marge*}
	\fi
}
\def\setupsolutionslinks{\@bsphack%
	\ifsolution
		\newcommand{\deco@enumi@}[1]{%
			\outer@ques@link
				{\Gm@littlemargin}
				{##1}%
		}
		\newcommand{\deco@enumii@}[1]{%
			\outer@ques@link
				{\Gm@littlemargin+\leftmargini}
				{##1}%
		}
		\newcommand{\deco@enumiii@}[1]{%
			\outer@ques@link
				{\Gm@littlemargin+\leftmargini+\leftmarginii}
				{##1}%
		}
	\else
		\newcommand{\deco@enumi@}[1]{%
			\outer@ques@nolink
				{\Gm@littlemargin}
				{##1}%
		}
		\newcommand{\deco@enumii@}[1]{%
			\outer@ques@nolink%
				{\Gm@littlemargin+\leftmargini}
				{##1}%
		}
		\newcommand{\deco@enumiii@}[1]{%
			\outer@ques@nolink%
				{\Gm@littlemargin+\leftmargini+\leftmarginii}
				{##1}%
		}
	\fi
\@esphack%
}
\cpgedeflabel{enumi}{|X|.|1|}
\cpgedeflabel{enumii}{|X|.|Q|.|1|}
\cpgedeflabel{enumiii}{|X|.|Q|.|q|.|1|}

%%%% Décoration du label pour mini
\cpgeset[mini]{%
	mini deco=#1.\kern1ex
}
\ifcompact
	\cpgeset[mini]{left margin=16pt, 
		font=\sffamily\footnotesize, 
		label font=\sffamily\scshape\bfseries\footnotesize}
\else
	\cpgeset[mini]{left margin=30pt}
\fi

%%%% Différents réglages
\AtBeginDocument{%
	\ifx\Hy@steplink\@undefined\else
	\hypersetup{pdftitle=\csuse{cpge@theme}, 
				pdfauthor=\csuse{cpge@auteur},
				pdfsubject=\csuse{cpge@document},
			}
	\fi}
\cpgeset[background]{%
	position = tb,
	code = {\tikz[overlay]\draw[rounded corners=10pt] 
	(-\Gm@littlemargin-20pt,-\footskip+10pt) rectangle 
	(\textwidth+28pt,\textheight+\headsep-4pt);}
}

\endinput



