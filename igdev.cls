\def\filedate{2023/10/12}
\def\fileversion{v0.3alpha}
\def\fileauthor{Sadik Boujaida}

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{igdev}[\filedate\space\fileversion]
\RequirePackage{pgfopts} %Pour la gestion des options de la classe
\RequirePackage{etoolbox}
\def\igcurrentclass{igdev}

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
	inpath/.code = \iginpathtoquiz{#1},
	outpath/.code = \igoutpathtoquiz{#1},
	inpath/.default = {../quizes},
	outpath/.default = {\jobname-quizes},
	convert/.code=\ifundef\igcomment@list{\pgfkeysalso{web}}{}\appto\convert@options{,convert={#1}},
	convert/.default=true,
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
		\def\igcomment@list{quiz,notations,#1},
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
\def\iginpathtoquiz#1{%
	\in@{/*}{#1*}%
	\ifin@%
		\xdef\ig@inpathtoquiz{#1}%
	\else%
		\xdef\ig@inpathtoquiz{#1/}%
	\fi%
}
\def\igoutpathtoquiz#1{%
	\in@{/*}{#1*}%
	\ifin@%
		\xdef\ig@outpathtoquiz{#1}%
	\else%
		\xdef\ig@outpathtoquiz{#1/}%
	\fi%
}
\pgfkeys{/IGD/.cd, inpath, outpath}
\@onlypreamble\iginpathtoquiz
\@onlypreamble\igoutpathtoquiz
\def\ig@mkdir#1{%
	\IfFileExists{/dev/null}
		{\immediate\write18{mkdir -p #1}}
		{\immediate\write18{md  "#1"}}%
}
\@ifundefined{ifsubdoc}
	{\ProcessPgfOptions{/IGDS}}
	{\ProcessPgfOptions{/IGD}}


\expandafter\LoadClass\expandafter[\class@options]{article}

%% Declarations 
\newcount\ig@counta
\newcount\ig@countb 
\newcounter{tmpdo}
\newcounter{saved@quiz}


\newif\ifinsolutions
\newif\ifnofootimage
\newif\ifquiz
\newif\ifig@withsol % vrai si le numero de la question courante doit être un hyperlien 
\newif\ifig@withhint % vrai s'il y a au moins une indication dans le sujet en cours
\newif\ifholed@jscore
\newif\ifig@tmpswa
\newif\ifig@tmpswb

\newtoks\toks@sol % retient la solution de la question en cours
\newtoks\toks@hint % retient l'indication de la question en cours

%%%% switches utilisés localement  

\newif\ifig@tmpa
\newif\ifig@tmpb
\newbox\trash@box



%%%%% Packages du projet 
\RequirePackage[customtitles]{igbase}
\RequirePackage{igsubdoc}
\RequirePackage{igmath}
\RequirePackage{igcommon}

%%%%%%%%%%%%%%%%%%



%%%% Fonctions expl3 pour le tri, 
%%%% adaptation d'un exemple de  la documentation officielle
\ExplSyntaxOn
\clist_new:N \l_ig_clist
\NewDocumentCommand\sortintlist{ m }
  { 
  	\clist_set:NV \l_ig_clist #1
	\clist_remove_duplicates:N \l_ig_clist
    \clist_sort:Nn \l_ig_clist
      {
        \int_compare:nNnTF { ##1 } > { ##2 }
          { \sort_return_swapped: }
          { \sort_return_same: }
      }
     \clist_set:NV #1 \l_ig_clist
  }
\def\ig@naive#1=#2\@nil{#1}
\NewDocumentCommand\sortequallist{m}
  {
  	\clist_set:NV \l_ig_clist #1
	\clist_remove_duplicates:N \l_ig_clist
    \clist_sort:Nn \l_ig_clist
      {
        \int_compare:nNnTF {\ig@naive##1\@nil} > {\ig@naive ##2\@nil}
          { \sort_return_swapped: }
          { \sort_return_same: }
      }
    \clist_set:NV #1 \l_ig_clist
  }
\NewDocumentCommand\removeduplicatefromlist{m}
  {
  	\clist_set:NV \l_ig_clist #1
	\clist_remove_duplicates:N \l_ig_clist
    \clist_set:NV #1 \l_ig_clist
  }
\NewDocumentCommand{\prettyprintlist}{m}
  {
    \clist_set:Nn \l_ig_clist {#1}
    \clist_sort:Nn \l_ig_clist
      { \int_compare:nTF { ##1 > ##2 } 
      	{ \sort_return_swapped: } 
		{ \sort_return_same: } }
    \clist_use:Nnnn \l_ig_clist { ~ et ~ } { , ~ } {  ~ et ~ }
  }
\ExplSyntaxOff 
\def\three@digits#1{%
	\ifnum#1<10 00\number#1\else%
	 \ifnum#1<100 0\fi\number#1%
	\fi
	}
%%%%%
\igset[input]{%
	lignes/.code=\def\ig@rigid@lignes{#1},
	qscore/.code=\def\ig@rigid@qscore{#1},
	jscore/.code=\ifjustification%
		\def\ig@tempa{#1}%
		\sortequallist\ig@tempa%
		\def\ig@rigid@jscorelist{}%
		\expandafter\csvtolistadd\expandafter\ig@rigid@jscorelist
			\expandafter{\ig@tempa}\fi,
	choices/.code=%
		\def\ig@tempa{#1}%
		\removeduplicatefromlist\ig@tempa%
		\def\ig@rigid@choicelist{}%
		\expandafter\csvtolistadd\expandafter\ig@rigid@choicelist%
			\expandafter{\ig@tempa}
}
\def\ifig@rigid#1{\ifcsdef{ig@rigid@#1}}
\def\ifig@inchoicelist#1{\xifinlist{#1}{\ig@choicelist}}

\def\iginputopt{\pgfqkeys{/ig/input}}
\DeclareDocumentCommand\inputquiz{O{}mmd()}{\begingroup%
	\iginputopt{#1}
	\IfValueT{#4}{\def\ig@rigid@title{#4}}
	\def\input@quiz{\input{\ig@inpathtoquiz#2/quiz-#3}\endgroup}
	\input@quiz
}
\DeclareDocumentCommand\savequiz{m}{%
\stepcounter{saved@quiz}%
	\ig@mkdir{\ig@outpathtoquiz#1}%
	\xdef\lastquiz{%
			\ig@outpathtoquiz#1/quiz-tmp-\expandafter\two@digits\c@saved@quiz}%
	\filecontents[force,nosearch,noheader]{\lastquiz}%
}
\let\endsavequiz\endfilecontents
\DeclareDocumentCommand\inputlastquiz{O{}}{\begingroup%
	\igset[input]{#1}%
	 \edef\inputlast@quiz{\noexpand\input{\lastquiz}\endgroup}%
	  \inputlast@quiz%
	}
\def\saveallquizzes{%
	\def\quiz{\savequiz{allquizzes}}
	\let\endquiz\endfilecontents
}
\def\ig@prechoicedo#1{
	\ifquiz
		\ifig@rigid{choicelist}
			{
				\xifinlist{#1}{\ig@rigid@choicelist}
					{\listxadd\ig@choicelist{#1}}
					{}%
			}
			{\listxadd\ig@choicelist{#1}}%
	\else
		\listxadd\ig@choicelist{#1}
	\fi
}
\def\reprocess@choicelist{\begingroup%
	\ifquiz
		\def\ig@tempa{}%
		\ifig@rigid{choicelist}%
			{%
				\def\do##1{%
					\ifinlist{##1}{\ig@choicelist}%
						{\listadd\ig@tempa{##1}}{}%
					}%
				\dolistloop{\ig@rigid@choicelist}%
				\global\let\ig@choicelist\ig@tempa%
			}{}%
	\fi%
\endgroup}	

%%%% Commande qui récupère les différentes parties de la question 
%%%% l'énoncé dans une macros, l'indication et la solution dans des token lists 
\long\def\preprocess@genbody#1{\begingroup%
	\get@quessol#1\solution\@nil
\endgroup}
\long\def\get@quessol#1\solution#2\@nil{%
	\get@queshint#1\hint\@nil%
	\ifblank{#2}
		{\global\toks@sol{}}
		{%
			\ifig@withsol\else
				\global\ig@withsoltrue%
			\fi%
			\global\expandafter\toks@sol\expandafter{\zap@sol#2}%
		}%
}
\long\def\zap@sol#1\solution{#1}
\long\def\get@queshint#1\hint#2\@nil{%
	\long\gdef\gen@upper{#1}%
	\ifblank{#2}
		{\global\toks@hint{}}
		{\global\ig@withhinttrue%
			\global\expandafter\toks@hint\expandafter{\zap@hint#2}}%
}
\long\def\zap@hint#1\hint{#1}

\ifbool{web}{\endinput}{}

\AtBeginDocument{
	\ifsolutiondelayed\tcbstartrecording[\jobname.rec]\fi
}

%%%% Strategie d'inclusion de fichier
%%%% utilise sur une version modifiée de subfile.sty renommé en igsubdoc.sty
%%%  

\igset[include]{
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

\NewDocumentCommand\iginclude{ om }{
	\RenewDocumentCommand\titre{sod()}{}%
	\begingroup
		\IfFileExists{#2-cor.tex}{\def\solfilename{#2-cor}}{}
		\IfValueT{#1}{\igset[include]{#1}}%
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

\DeclareDocumentCommand\igusetheme{O{} m}{%
	\igset[theme]{#1}
	\unless\ifdraft
		\IfFileExists{q#2.sty}
			{\AtEndPreamble{\RequirePackage{q#2}}}{}%
	\fi%
	\reloadcolors%
}

\pgfkeys{/ig/@title/.is family}
\def\igtset{\pgfqkeys{/ig/@title}}
\igtset{
 align/.is choice,
 align/c/.code=\def\@lign{center},
 align/l/.code=\def\@lign{left},
 align/r/.code=\def\@lign{right}
}

\def\igt@align#1#2#3{\csletcs{#1@align}{fil#2}\csletcs{#1label@align}{fil#3}}
\let\fildefault\relax

\DeclareDocumentCommand\igt@shape{mmoo}{%
 \csdef{#2@shape}{#1}
 \IfValueTF{#4}
  {\igt@align{#2}{#3}{#4}}
  {\IfValueT{#3}{\igt@align{#2}{#3}{#3}}}
}
\def\ig@format#1{%
 \begingroup\def\ig@tmpa{\endgroup\igtformat{#1}}%
 \expandafter\ig@tmpa\expandafter%
}










%%% Les differentes boites tcolorbox pour
%%% le contenu dans les fichiers quiz 
\tcbset{
	only top and bottom rules/.style= {%
			boxrule=0pt, toprule=#1, bottomrule=#1},
	only top and bottom rules/.default = {.6pt}
}
\tcbset{
	generic box/.style={% 
		boxrule=.4pt,
		boxsep=0pt, top=8pt, bottom=8pt, left=6pt, right=6pt, 
		toptitle=3pt, bottomtitle=3pt,
		fonttitle=\sffamily\scshape\bfseries,
}}

\NewDocumentCommand\genboxcmd{O{} m}{\tcbox[reset,on line, size=fbox, #1]{#2}}
\newtcolorbox[no counter]{fake@box}[1][]{%
	blankest, 
	boxsep=\z@, left=\z@, right=\z@, top=\z@, bottom=\z@, 
	bottomtitle=5pt,
	after=\medskip,#1
}
\NewDocumentCommand\DeclareNewBox{ mmom }{
	\NewDocumentEnvironment{#1}{O{}d()#2}
		{
			\IfValueTF{##2}
				{\tcolorbox[generic box,#3,##1, title=##2, savedelimiter=#1]}
				{\tcolorbox[generic box,#3,##1, savedelimiter=#1]}
				#4
		}
		{\exit\endtcolorbox}
}
\DeclareNewBox{genbox}{}[]{}
\DeclareNewBox{notations}{}[only top and bottom rules]{}

\newtcbox\rslt@box{boxrule=.6pt, colframe=tcbcolbacktitle, colback=neutralcol!33}	
\igdefdeco{formula}{\rslt@box{#1}}
\let\deco@result\deco@formula
\let\deco@formule\deco@formula
% L'environnement intermédiaire quiz@body qui decore le corps d'un quiz
% le titre du quiz est decore par \deco@quiz 
\tcbset{quiz body/.style={
	boxsep=0pt, left=4pt, right=4pt,
	boxrule=.4pt,
}}
\DeclareDocumentEnvironment{quiz@body}{O{}}{%
	\tcolorbox[
		savedelimiter=quiz@body,
		quiz body
		]%
	\igset@firstcharsyntaxforcolprop{colnumber}%
	\ifquiz\renewcommand{\arraystretch}{.3}\fi%
	\tcbraster[
		raster columns=\ig@colnumber,
		raster valign=top,
		raster column skip=4pt,
		raster row skip=6pt,
		raster every box/.style={blankest, 
			left=\Gm@littlemargin,halign=left
		},
		#1,
		]%
	\igset@firstcharsyntaxforcolprop{multicols}
	}{\endtcbraster\endtcolorbox}
\igdefdeco{quiz}{\begingroup%
	\setbox\ig@boxa\hbox{#1}%
	\hskip-\Gm@littlemargin\rule{\wd\ig@boxa+\Gm@littlemargin}{.4pt}\\*[-2pt]%
	\usebox\ig@boxa%
\endgroup}


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
%\igdefcounter est définie dans igbase.sty 
\igdefcounter{@devoir}{}(D)
\igdefcounter{section}{}[@devoir](*S) % (*S) pour écraser le raccourci S
\igdefcounter{@problem}{}[@devoir](Y)%[@devoir,section](*X)
\igdefcounter{solution}{}
\igdefcounter{parti}{}[@problem](P)
\igdefcounter{partii}{}[parti](p)
\igdefcounter{quiz}{}[section,@problem](Z)
\igdefcounter{ch@ice}{}[quiz]
\igdefcounter{fake@choice}{}[quiz]
\newcounter{score}[@devoir]
\igdefcounter{score@tmp}{}[quiz,@problem]
\ig@labelformat{score}{#1}
\ig@cnt@shortcut{*X}{current@counter}



%%% Commandes utilitaires
\def\ig@indexdo#1#2#3{%
	\ifnumcomp{#1}>{#3}
		{\stepcounter{#2}}
		{\ifnumcomp{#1}<{#3}{\stepcounter{#2}}{\listbreak}}%
}
\def\ig@listcount#1#2{\begingroup%
	\setcounter{#1}{0}%
	\def\do##1{\stepcounter{#1}}%
	\dolistloop{#2}%
	\endgroup%
}	
\def\ig@indexset#1#2#3{%
	\setcounter{#2}{1}%
	\forlistloop{\ig@indexdo{#1}{#2}}{#3}%
}
\tcbset{ifvaluetf/.code n args =
	{3}{\IfValueTF{#1}{\pgfkeysalso{#2}}{\pgfkeysalso{#3}}}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Création des divisons de document \devoir, \section, \problem...  %%%
%%% repose sur igtitle.sty qui fusionne titlesec, titleps et titletoc %%%

%%% Résiliation des commandes de titrage usuelles
\undef\section
\undef\subsection
\undef\parapgraph
\undef\subparagraph

%%% La nouvelle architecture de titrage
\igtclass{\@devoir}[0]{top} % -> \devoir 
\igtclass{\section}{straight}[\@devoir]
\igtclass{\@problem}{straight}[\section] % -> {probleme}, {exercise}, ...
\igtclass{\parti}{straight}[\@problem] 
\igtclass{\partii}{straight}[\parti]

\DeclareRobustCommand\dnstl{%
		D%
		\kern-.08em\relsize{-2}\textit{NS}%
		\relsize{2}\kern-.15em T\kern-.15em\raisebox{-.2em}{L}%
	}
%%% Styles des versions internes des commandes de titre 

\igt@shape{display}{devoir}[center]
\ig@format{\@devoir}[display]
	{\csundef@afterexec{hook@beforedevtitle}}
	{\devoirlabel@align%
		\ifig@tmpswb
			\addtocounter{@devoir}{-1}%
			\deco@devoirlabelnumberless{}%
		\else
			\deco@devoirlabel{\devoir@name}{\label@@devoir}
		\fi
	}
	{\z@}
	{\devoir@align\deco@devoir{\cnt@name}{#1}}
	[\csundef@afterexec{hook@afterdevtitle}]

\ig@format{name=\@devoir, numberless}[display]
	{\csundef@afterexec{hook@beforedevtitle}}
	{\devoirlabel@align%
		\deco@devoirlabelnumberless}
	{\z@}
	{\devoir@align\deco@devoir{#1}}
	[\csundef@afterexec{hook@afterdevtitle}]
\igtspacing*{\@devoir}{\z@}{-1cm}{*6}



%%%%% L'équivalent de \section
\igt@shape{hang}{section}[default]
\ig@format{\section}[\section@shape]
  {\LARGE\scshape}
  {\sectionlabel@align\deco@sectionlabel{\label@section}}
  {1pc}
  {\section@align\deco@section{#1}}
\igtspacing*{\section}{-1pc}{*3}{*2}

%%%%% version interne des titres pour les sujets
\def\after@problemtitle{
	\csundef@afterexec{hook@afterprobtitle}%
	\ifdef{\problem@name}
		{
			\edef\ig@tmpe{\usevalue{problemscore:\the@problem}}%
	 		\ifdefvoid{\ig@tmpe}{}
	 			{\mbox{}\\\normalsize\textit{(sur \ig@tmpe{} points)}}
		}{}%
}
\igt@shape{display}{problem}[center]
\def\link@problemlabel#1{
	\ifsolution
		\ifisasolution
			\hypersetup{pdfborder=0 0 0}%
			\hypertarget{\ig@current@id:cor}
				{\hyperlink{\ig@current@id:eno}{\deco@problemlabel{#1}}}%
		\else
			\hypersetup{pdfborder=0 0 0}%
			\hypertarget{\ig@current@id:eno}
				{\hyperlink{\ig@current@id:cor}{\deco@problemlabel{#1}}}%
		\fi
	\else
		\deco@problemlabel{#1}
	\fi
}
\ig@format{\@problem}[\problem@shape]
  {\LARGE}
  {\problemlabel@align
  	\link@problemlabel{\cnt@name}}
  {\z@}
  {\problem@align\deco@problem{#1}}
  [\after@problemtitle]
\ig@format{name=\@problem, numberless}[\problem@shape]
  {\LARGE}
  {\problemlabel@align\deco@problemlabelnumberless{}}
  {\z@}
  {\problem@align\deco@problem{#1}}
  [\after@problemtitle]
\igtspacing*{\@problem}{\z@}{*3}{*3}

%%%%%%

%%% \parti, à utiliser dans \problem ou \exercise
\setcounter{secnumdepth}{4}
\igtformat{\parti}
  {\large\scshape}
  {\deco@partilabel{\label@parti}}
  {.5em}
  {\protect\boldmath\bfseries\deco@parti{#1}}
\igtspacing*{\parti}{\z@}{*3}{*1.5}

%%% \partii, soupartie, subdivision de \parti
\igtformat{\partii}
  {\scshape}
  {\deco@partiilabel{\label@partii}}
  {6pt}
  {\protect\boldmath\bfseries\deco@partii{#1}}
\igtspacing*{\partii}{\z@}{*3}{*1.5}

%%%%%%%%

%%%%%% Surcouches des commandes de titrages

%% Ajout d'une métadonnée devoir pour une utilisation avec \titre 
\def\Devoir#1{\gdef\ig@devoir{#1}}
\let\ig@devoir\relax

\igaddkeyword{title}{devoir}{{\LARGE\scshape\deco@devoir{\csuse{ig@devoir}}%
                  \global\ig@dima\baselineskip}\baselineskip\ig@dima}

\def\deco@devoir#1#2{{\huge#1} \\ #2}
\def\deco@devoirlabel#1#2{#1\ #2}
\igdefdeco{devoirlabelnumberless}{}

\igset[@devoir]{%
	name/.store in=\devoir@name,
	name=sujet,
	number/.code=\setcounter{@devoir}{\numexpr#1-1},
	alt title/.store in=\alt@devname,
	alt/.style={alt title=#1},
	after title/.code=\title@parser{\begingroup#1\endgroup}%
		\expandafter\def\expandafter\hook@afterdevtitle\expandafter{\title@contents},
	before title/.code=\title@parser{\begingroup#1\endgroup\par}%
		\expandafter\def\expandafter\hook@beforedevtitle\expandafter{\title@contents},
	title deco/.code=\igdefdeco{devoir}{#1},
	label deco/.code=\igdefdeco{devoirlabel}{#1},
}

\NewDocumentCommand\devoir{sO{}md()}{%
	\IfBooleanT{#1}{\ig@tmpswbtrue}
	\def\cnt@name{#3}%
	\igset[@devoir]{#2}%
	\ifdefvoid{\alt@devname}
	  	{%
			\IfValueTF{#4}
				{\ig@tmpswafalse\@devoir[\textsc{#3~:}~#4]{#4}}
				{\ig@tmpswatrue\@devoir[#3]{}}%
		}%
		{%
			\IfValueTF{#4}
				{\ig@tmpswafalse\@devoir[\textsc{#3~:}~\undef@afterexec\alt@devname]{#4}}
				{\ig@tmpswatrue\@devoir[\textsc{#3~:}~\undef@afterexec\alt@devname]{}}%
		}
	\IfBooleanT{#1}{\ig@tmpswbfalse}
}

%%%%%%

\igdefdeco{sectionlabel}{\llap{\hb@xt@\Gm@littlemargin{%
	\genboxcmd[tcbox width=forced center,width=\Gm@littlemargin-6pt]
		{\normalsize\bfseries#1}}}\kern4pt
	}
\igdefdeco{section}{\protect\boldmath\bfseries #1}

%%%%%%%

\igdefdeco{problem}{{#1 }}
\igdefdeco{problemlabel}{%
	{\Large\scshape\bfseries%
	\deco@lpattern\enskip#1\enskip\deco@rpattern}%
}
\igdefdeco*{lpattern}{\ig@square}
\igdefdeco*{rpattern}{\ig@square}

\igset[@problem]{%
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
	title deco/.code=\igdefdeco{problem}{#1},
	label deco/.code=\igdefdeco{problemlabel}{#1},
	corrige/.code=\csgdef{\ig@current@id @opts}{#1}, 
}
\igset[solution]{
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
				\ifcsundef{\ig@current@id @list}{}
					{\edef\queslist{\csuse{\ig@current@id @list}}}%
			\fi% 
		\else%
			\ifcsdef{label@@\ig@current@id}
				{\ClassError{igdev}{\problem@name\space\arabic{\problem@name}\space:\space
				  Identifiant\space \ig@current@id\space déjà\space utilisé}{}}
				{\csxdef{label@@\ig@current@id}{%
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
			{\ig@tmpswafalse\ifdef{\alt@problem}
				{\@problem[\textsc{\cnt@name~:~}\alt@problem]{#4}}
				{\@problem[\textsc{\cnt@name~:~}#4]{#4}}%
			}{\ig@tmpswatrue\@problem[\textsc{\cnt@name~:}]{}}%
	}	
\def\dudela#1{\csuse{dudela@#1}}

\NewDocumentEnvironment{@corrige}{
	m % #1 current@id 
	o % #2 options 
	d() % #3 current optional title
	d<> % #4 currunt optional label for refercing
}
			{%
				\def\ig@current@id{#1}%
				\IfValueT{#2}{\igset[solution]{#2}}%
				\isasolutiontrue\setup@xsol%
				\csuse{hook@beforeprobtitle}
				\problemtitle*{\csuse{#1@@label}}{}(#3)<#4>%
				\csuse{hook@afterprobtitle}
				\setup@id%
				\csuse{hook@beforeproblem}%
			}{%
				\endxsol%
				\csuse{hook@afterproblem}%
			}
\NewDocumentEnvironment{@writecorrige}{
	m 		% #1 current@id 
	!O{} 	% #2 saving the options
	!d() 	% #3 savins the optional title
	!d<> 	% #4 saving the optional label for referencing
}
	{%
		\csgdef{#1@}{}%
		\csgdef{#1@opts}{#2}%
		\IfValueT{#3}{\csgdef{#1@title}{#3}}%
		\IfValueT{#4}{\csgdef{#1@label}{#4}}%
		\igwriteonce{\aux@dir/#1-cor}%
	}
	{\endigwriteonce}
\NewDocumentEnvironment{@enonce}{mmm O{} d() d<>}{%
			\def\ig@current@id{#3}%
			\csedef{\ig@current@id @opts}
				{\expandonce\corr@common@opt}%
			\igset[@problem]{current counter=#1,#4}%
			\ifcsundef{#3@title}{\csdef{#3@title}{#5}}{}%
			\problemtitle{#1}{#2}(#5)<#6>
			\setup@id%
			\setup@sol%
			\setup@hint%
			\csuse{hook@beforeproblem}%
		}{%
			\exit%
			\csuse{hook@afterproblem}%
			\close@problem{#1}%
		}
\DeclareDocumentCommand\ignewexeprobtwo{
		s %* corrige or enonce
		m %2 counter name
		m %3 printed name
		m %4 solution title prefix
		m %5 counter label format
		m %6 counter shortcut
		}{
	\ifblank{#6}
		{\igdefcounter{#2}{#5}[@devoir]}
		{\igdefcounter{#2}{#5}[@devoir](#6)}%
	\csdef{dudela@#2}{#4}%
	\IfBooleanT{#1}{%
		\csdef{#2}{%
			\def\problemtitle{\problemtitle}
			\ifstraight
				\cslet{end#2}\end@corrige%
				\@corrige%
			\else
				\cslet{end#2}\endigwriteonce
				\@writecorrige
			\fi}
		\cslet{end#2}\end@corrige@
		\csdef{#2*}{%
			\def\problemtitle{\problemtitle*}
			\ifstraight
				\@corrige
			\else
				\@writecorrige
			\fi}
	}
	\IfBooleanT{#1}{%
		\NewDocumentEnvironment{#2*}{m o d() d<>}
			{%
				\def\ig@current@id{##1}%
				\IfValueT{##2}{\igset[solution]{##2}}%
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
			\def\ig@current@id{##1}%
			\csedef{\ig@current@id @opts}{\expandonce\corr@common@opt}%
			\igset[@problem]{current counter=#2,##2}%
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
			\def\ig@current@id{##1}%
			\csedef{\ig@current@id @opts}{\expandonce\corr@common@opt}%
			\igset[@problem]{current counter=#2,##2}%
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
\DeclareDocumentCommand\ignewexeprob{
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
		{\igdefcounter{#2}{#5}[@devoir](#7)}
		{\igdefcounter{#2}{#5}[@devoir]}%
	\csdef{dudela@#2}{#6}%
	\IfBooleanT{#1}{%
		\NewDocumentEnvironment{#2}{m o d() d<>}
			{%
				\def\ig@current@id{##1}%
				\IfValueT{##2}{\igset[solution]{##2}}%
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
				\def\ig@current@id{##1}%
				\IfValueT{##2}{\igset[solution]{##2}}%
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
			\def\ig@current@id{##1}%
			\csedef{\ig@current@id @opts}{\expandonce\corr@common@opt}%
			\igset[@problem]{current counter=#2,##2}%
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
			\def\ig@current@id{##1}%
			\csedef{\ig@current@id @opts}{\expandonce\corr@common@opt}%
			\igset[@problem]{current counter=#2,##2}%
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
\igdefdeco{pattern}{}
\ignewexeprob{probleme}{Problème}{}{Problème |1| }{du}(R)
\ignewexeprob{exercice}{Exercice}{}{Exercice |1| }{de l'\ignorespaces}(E)
\ignewexeprob*{cours}{Questions de cours}{}{Questions de cours |1|}{des}(K)
\ignewexeprob*{qcm}{Quiz}{}{|M| quiz}{du}(k)
\ignewexeprob{epreuve}{}{}{}{}
\ignewexeprob{enonce}{}{}{}{}
\ignewexeprob*{Corrige}{}{\isasolutiontrue\setup@xsol}{}{}
\def\label@epreuve{\ifsolution\'Enonc\'e\else\deco@pattern\fi}
\def\label@enonce{\ifsolution\'Enonc\'e\else\deco@pattern\fi}
\def\label@Corrige{Corrig\'e \csuse{label@@\ig@current@id}}

%%%%%%%%%%%%%%

\igdeflabel{parti}{|I|}
\igdefdeco{partilabel}{\bfseries#1.}
\igdefdeco{parti}{#1}
\igdeflabel{partii}{|P|.|A|}
\igdefdeco{partiilabel}{\bfseries#1.}
\igdefdeco{partii}{#1}

%%% table des matières
\let\igt@savemark\relax
\def\toclevel@@devoir{0}
\def\toclevel@section{1}
\def\toclevel@@problem{2}
\def\toclevel@parti{3}
\def\toclevel@partii{4}
\igtcontents{@devoir}[0em]{}{\Large}{\Large}{\hfill\igtcontentspage}
\igtcontents{section}[0em]{\bigskip}{\Large}{\Large}{\hfill\igtcontentspage}
\igtcontents{@problem}[1em]{\medskip}{\bfseries\boldmath}{\scshape}{\hfill\igtcontentspage}
\igtcontents{parti}[3em]{}{}{}{}
\igtcontents{partii}[4em]{}{}{}{}

%%% Entrées pour pagestyles
 
\let\@devoirtitle\@empty
\let\sectiontitle\@empty
\let\@problemtitle\@empty
\let\partititle\@empty
\let\partiititle\@empty
\igt@setifthe{@devoir}
\igt@setifthe{section}
\igt@setifthe{@problem}
\igt@setifthe{parti}
\igt@setifthe{partii}

% les divisions qui seront marquées pour une utilisation dans pagestyles    
\igtsettitlemarks{@devoir,section,@problem,parti}
% Ajout des mots clés section et problem pour utilisation avec \idefghead et \idefgfoot.
\igaddkeyword*{hf}{devoir}
	{\ifthe@devoir{\MakeLowercase{\@devoirtitle}}{}}
\igaddkeyword*{hf}{section}
	{\ifthesection{\MakeLowercase{\sectiontitle}}{}}
\igaddkeyword*{hf}{problem}
	{\ifthe@problem{\MakeLowercase{\@problemtitle}}{}}
\igaddkeyword*{hf}{parti}
	{\iftheparti{\MakeLowercase{\partititle}}{}}
\igaddkeyword{hf}{pages}{page\enskip\thepage{} / \pageref*{LastPage}}
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Finalisation du barème %%%

\NewDocumentCommand\setscore{O{0}}{%
		\addtocounter{score}{#1}%
		 \@expandtwoargs\defvalue{globalscore}{\thescore}%
 }
\def\showscore{\usevalue{globalscore}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Interface clé/valeur pour la configuration %%%
%%% repose sur \pgfkeys                        %%%

\def\igqset{\igset[quiz]}
% Clés de configuration utilisateurs de différents aspects du document
\igqset{%
	quiz name/.code = \igxname{quiz}{#1},
	question name/.code = \igxname{question}{#1},
	justification name/.code = \igname{justification}{#1},
	solution name/.code = \igname{solution}{#1},
	justification end space name/.code = \igname{justificationendspace}{#1},
	score unity name/.code = \igname{unity}{#1},
	rules name/.code = \igname{rules}{#1},
	question style/.code = \igdefdeco{quiz}{#1},
	question label style/.code = \igdefdeco{questionlabel}{#1},
	question title style/.code = \igdefdeco{questiontitle}{#1},
	score style/.code = \igdefdeco{unite}{#1},
	justification style/.code = \igdefdeco{justification}{#1},
	solution style/.code = \igdefdeco{solhead}{#1},
	note style/.code = \igdefdeco{note}{#1},
	choice style/.code = \igdefdeco{choice}{#1},
	solution choice style/.code = \igdefdeco{solchoice}{#1},
	vadjust choice position/.code = \dimdef{\choice@dv}{#1},
	hadjust choice position/.code = \dimdef{\choice@dh}{#1},
	default columns number/.code =\def\ig@dcn{#1},
	justification lineskip/.code =\setlength\ligneskip{\baselineskip*\real{#1}},
	dots line pattern/.code = \igdefdeco{pointille}{#1}
}
\igqset{%
	quiz name = Quiz,
	question name = Question, 
	justification name = Justifications,
	solution name = Justifications,
	justification end space name = Espace suppl\'ementaire de justification,
	score unity name = points, 
	rules name = R\`egles du qcm, 
	score style = {{\kern1em\vrule \;\bfseries #1 \name@unity}},
	note style = {#1\par\vskip-.66\baselineskip\hrulefill},
	question label style = {{\bfseries\scshape #1}},
	question title style = {{\itshape #1}},
	justification style = {{\scshape\bfseries \itshape #1~}},
	solution style = {{\scshape\bfseries \itshape #1~}},
	choice style = {\genboxcmd[boxsep=.4pt]{#1}},
	solution choice style = {\genboxcmd[notitle,boxsep=1.5pt]{#1}},
	default columns number = 2,
	justification lineskip =.35, 
}
\AtBeginDocument{%
	\ifcompact%
		\igqset{default columns number = 1}%
	\fi}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% L'environnement quiz %%%

%%% le contenu des quiz est traité en 2 passes
%%% la première passe récupère dans des macros numérotées
%%% le contenu des questions et des solutions,
%%% le but est de rendre possible l'utilisation d'une
%%% partie des questions/solutions et/ou de les réordonner.
%%% La deuxième passe restitue le contenu sélectionné après
%%% une phase de traitement des données.

\igdeflabel{quiz}{\igthe{@devoir}\igthe{section}\igthe{@problem}|1|}

\def\ig@jscorelist{}
\def\ig@jscorecsv{}

\def\choice@undef{%
	\gdef\ig@choicelist{}%
	\gdef\ig@qscore{0}%
	\gdef\ig@jscorecsv{}%
	\gdef\ig@jscorelist{}%
	\gdef\ig@scorelist{}%
	}
	
\def\ig@colnumber{\ig@dcn}
\def\ig@multicols{1}
\tcbset{column number/.code=\def\ig@colnumber{#1}}
\tcbset{multicols/.style={raster multicolumn=#1}}
\def\igset@firstcharsyntaxforcolprop#1{%
	\pgfkeys{
		/handlers/first char syntax=true,
		/handlers/first char syntax/the character 1/.initial=\csuse{igset@#1},
		/handlers/first char syntax/the character 2/.initial=\csuse{igset@#1},
		/handlers/first char syntax/the character 3/.initial=\csuse{igset@#1},
		/handlers/first char syntax/the character 4/.initial=\csuse{igset@#1},
		/handlers/first char syntax/the character 5/.initial=\csuse{igset@#1},
}}
\def\igset@colnumber#1{\pgfkeysalso{column number=#1}}
\def\igset@multicols#1{\pgfkeysalso{multicols=#1}}



%%% Les commandes environnement de la première passe %%%%

\long\def\intro#1\endintro{#1}
\long\def\collect@intro#1\endintro{%
	\gdef\intro@body{#1}}
\let\intro@body\relax

\DeclareDocumentCommand\thin@vrule{O{.2pt}}{\vrule width #1}
\DeclareDocumentCommand\thin@hrule{O{.2pt}}{\hrule height #1}

\def\choice@b#1#2{\advance\ig@dimb by-4pt\relax%
	\hb@xt@0.65\ig@dimb{\hfil\bfseries#1\hfil}%
	\thin@vrule%
	\tabular{@{}p{.35\ig@dimb}@{}} 
		\thin@vrule[\z@] height 1ex\\ 
		\thin@hrule\thin@vrule[\z@] height 1ex
		\tiny\bfseries\centering#2
	\endtabular%
}
\def\ques@b#1#2{\advance\ig@dimb by-4pt\relax%
	\hb@xt@\ig@dimb{\hfil\vphantom{)}\bfseries\thequiz.#2\hfil}%
}
\def\set@choicerenderer{%
	\ifquiz%
		\def\@renderer{\choice@b}%
	\else%
		\def\@renderer{\ques@b}%
	\fi%
}
\def\choice@renderer#1#2{%
	\llap{%
		\raise\choice@dv\hb@xt@\ig@dimb{%
			\smash{%
				\deco@choice{\@renderer{#1}{#2}\hss}%
	}}\strut\enskip}%
}			
\DeclareDocumentCommand\rawchoice{t+ t- O{} D<>{} m+m}{%
	\begin{tcolorbox}[raster multicolumn=\ig@multicols,#3]%
	\ifblank{#4}
		{\stepcounter{ch@ice}}
	    {\refstepcounter{ch@ice}}%
	\IfBooleanT{#1}{\csgdef{choice@#5}{V}}%
	\IfBooleanT{#2}{\csgdef{choice@#5}{F}}%
	\ig@dimb=\dimexpr\Gm@littlemargin-\choice@dh\relax%
	\leavevmode\choice@renderer{\csuse{choice@#5}}{\thech@ice}%
	\ifblank{#4}{}{\label{#4}}%
	\ignorespaces%
	#6
	\end{tcolorbox}%
   }
\DeclareDocumentCommand\firstpass@cmd{t+ t- m O{ }  D<>{ } E{\br}{{}}}{%
	\stepcounter{fake@choice}%
	\ig@prechoicedo{\thefake@choice}
	\ifig@rigid{jscorelist}{}{\ig@postjscoredo{\thefake@choice}{#6}}
	\csgdef{choice@body\thefake@choice}{\rawchoice}%
	\ifquiz\ifsolution%
	    	\IfBooleanT{#1}{\csgappto{choice@body\thefake@choice}{+}}%
		     \IfBooleanT{#2}{\csgappto{choice@body\thefake@choice}{-}}%
	\fi\fi%
	\csgappto{choice@body\thefake@choice}{[#4] <#5>}%
	\csxappto{choice@body\thefake@choice}{{\thefake@choice}}%
	\csname collect@#3\endcsname
}
\def\ig@postjscoredo#1#2{%
	\ifjustification%
	\ifblank{#2}{}
		{%
			\csvxadd{\ig@jscorecsv}{#1=#2}%
			 \addtocounter{score}{#2}%
			  \addtocounter{score@tmp}{#2}
			   \csnumgdef{score@#1}{#2}
		}
	\fi%
}
\def\ig@prejscoredo#1=#2\@nil{%
\ifjustification%
	\xifinlist{#1}{\ig@rigid@choicelist}
		{%
			\listxadd{\ig@jscorelist}{#1=#2}
			 \addtocounter{score}{#2}
			  \addtocounter{score@tmp}{#2}
			   \csnumgdef{score@#1}{#2}
		}{}%
	\fi%
}
\long\def\collect@choice#1\endchoice{%
	\preprocess@genbody{#1}%
	\csxappto{choice@body\thefake@choice}{{\expandonce\gen@upper}}%
	\ifsolution%
		\edef\ig@tmpe{\the\toks@sol}%
		\ifdefvoid{\ig@tmpe}{}
			{%
				\csgdef{sol@body\thefake@choice}{\rawsol}%
				\csxappto{sol@body\thefake@choice}{{\thefake@choice}}%
				\csxappto{sol@body\thefake@choice}{\expandonce\ig@tmpe}%
			}%
	\fi%
	\ifhint%
		\edef\ig@tmpe{\the\toks@hint}%
		\ifdefvoid{\ig@tmpe}{}
			{%
				\csgdef{hint@body\thefake@choice}{\rawhint}%
				\csxappto{hint@body\thefake@choice}{{\thefake@choice}}%
				\csxappto{hint@body\thefake@choice}{\expandonce\ig@tmpe}%
				\csgappto{hint@body\thefake@choice}{\enskip}%
			}%
	\fi%
	}
\long\def\collect@ques#1\endques{%
	\preprocess@genbody{#1}%
	\csxappto{choice@body\thefake@choice}{{\expandonce\gen@upper}}
	\ifsolution
		\edef\ig@tmpe{\the\toks@sol}
		\ifdefvoid{\ig@tmpe}{}
			{
				\csgdef{sol@body\thefake@choice}{\rawsol}
				\csxappto{sol@body\thefake@choice}{{\thefake@choice}}
				\csxappto{sol@body\thefake@choice}{\expandonce\ig@tmpe}
			}
	\fi%
	\ifhint%
		\edef\ig@tmpe{\the\toks@hint}%
		\ifdefvoid{\ig@tmpe}{}
			{%
				\csgdef{hint@body\thefake@choice}{\rawhint}%
				\csxappto{hint@body\thefake@choice}{{\thefake@choice}}%
				\csxappto{hint@body\thefake@choice}{\expandonce\ig@tmpe}%
				\csgappto{hint@body\thefake@choice}{\enskip}
			}%
	\fi%
}

%%%% Traitement des barèmes et des listes de choix

\def\preprocess@scores#1{%
	\ifquiz%
		\ifig@rigid{qscore}%
			{\numgdef\ig@qscore{\ig@rigid@qscore}}%
			{\ifblank{#1}{\gdef\ig@qscore{0}}{\numgdef\ig@qscore{#1}}}%
		\addtocounter{score}{\ig@qscore}
	\fi%
	\def\do##1{\ig@prejscoredo##1\@nil}
	\ifig@rigid{jscorelist}
	 	{\dolistloop{\ig@rigid@jscorelist}}
		{\def\ig@jscorelist{}}
}

\def\postprocess@scores{\begingroup%
	\ig@countb\z@\relax
	\def\ig@tempc{}
	\global\holed@jscoretrue%
	\ifquiz\else\numgdef\ig@score{\value{score@tmp}}\fi
	\ifig@rigid{jscorelist}{}
    	{\csvtolisteadd*\ig@jscorelist{\ig@jscorecsv}}
	\ifdefvoid{\ig@jscorelist}{}
		{%
			\forlistloop{\jscore@parse}{\ig@jscorelist}%
			 \xdef\justif@expr{%
			 	\expandafter\prettyprintlist\expandafter{\ig@tempc}}%
		 	  \sortequallist\ig@scorelist%
			  \xdef\ig@scorelist{\ig@scorelist}
		}%
\endgroup}
\def\jscore@parse#1{\jscore@parse@#1\@nil}
\def\jscore@parse@#1=#2\@nil{%
	\ifig@inchoicelist{#1}
		{
			\advance\ig@countb by\@ne\relax%
		 	\ig@indexset{#1}{tmpdo}{\ig@choicelist}%
		  	\csveadd{\ig@scorelist}{\thetmpdo=#2}%
		   	\csveadd{\ig@tempc}{\thetmpdo}%
		}{}%
}
\def\test@completejscore{\begingroup
	\ig@listcount{tmpdo}{\ig@choicelist}
	\edef\ig@tempd{\thetmpdo}
	\ig@listcount{tmpdo}{\ig@jscorelist}
	\ifnum\ig@tempd=\value{tmpdo}\relax\global\holed@jscorefalse\fi
\endgroup}		
\def\text@justifier{%
	\ifquiz\ifjustification%
		\ifdefvoid{\justif@expr}{}
			{%
				\par%
				\test@completejscore%
				\ifholed@jscore%
					\ifnum\value{tmpdo}=\@ne\just@\else\just@@\fi%
				 	\csundef@afterexec{justif@expr}.%
				\else%
					\just@@@.%
				\fi%
			}%
	\fi\fi%
}
\def\just@{Justifier l'\'enonc\'e~}
\def\just@@{Justifier les \'enonc\'es~:~}
\def\just@@@{Justifier tous les \'enonc\'es}
\def\render@scorelist{%
	\ifdefvoid{\ig@scorelist}{}%
		{%
			\def\do{\enskip\genboxcmd}%
		    \expandafter\docsvlist\expandafter{\ig@scorelist}%
		}%
}
% Traitement des solutions dans les environnements quiz et similaire
\DeclareDocumentCommand\firstpass@sol{d()}{%
	\IfValueTF{#1}
				{\setcounter{fake@choice}{#1}}
				{\stepcounter{fake@choice}}
	\ifcsdef{sol@body\thefake@choice}{}
		{%
			\csgdef{sol@body\thefake@choice}{\rawsol}
			\csxappto{sol@body\thefake@choice}{{\thefake@choice}}
			\collect@sol%
		}
	}
\long\def\collect@sol#1\endchoice{%
	\ifblank{#1}{}{\ifig@withsol\else\global\ig@withsoltrue\fi}%
	\csgappto{sol@body\thefake@choice}{#1}
	}
\def\rawsol#1{
	\par\smallskip\leavevmode%
	\ifcsdef{score@#1}
		{\llap{\hb@xt@\Gm@littlemargin{\ttfamily\footnotesize(\csundef@afterexec{score@#1}pt)\hss}}}%
		{}%
	\setcounter{tmpdo}{1}%
	\forlistloop{\ig@indexdo{#1}{tmpdo}}{\ig@choicelist}%
	\solchoice@q{\textbf{\thetmpdo}~\vrule%
			 \textsubscript{~\csundef@afterexec{choice@#1}}}%
}
\def\rawhint#1{%
	\setcounter{tmpdo}{1}%
	\forlistloop{\ig@indexdo{#1}{tmpdo}}{\ig@choicelist}%
	\solchoice@q{\textbf{\thetmpdo}~\vrule%
			 \textsubscript{~\csundef@afterexec{choice@#1}}}%
}
\def\solchoice@q#1{\deco@solchoice{\makebox[2em]{#1}}~}
\def\firstpass@solution{}{
	\ifsolution
		\setcounter{fake@choice}{0}%
		\def\choice{\firstpass@sol}%
	\else
		\let\choice=\iffalse%
		\let\endchoice=\fi%
	\fi
}
\igdefdeco{jscore}{{\kern1em\vrule \;\bfseries #1 \name@unity}}
\def\hintsol@head#1{%
	\deco@solhead{#1}%
	\ifig@withsol
	\ifnum\value{score@tmp}>\z@\relax\deco@jscore{\thescore@tmp}\fi%
	\else
		\ifig@withhint% 
			\ifnum\value{score@tmp}>\z@\relax\deco@jscore{\thescore@tmp}\fi%
	 	 \else
			\render@scorelist%
		\fi
	\fi%
	\par\nopagebreak%
}
\def\for@cmd#1#2{\csundef@afterexec{#1@body#2}}
	
%%% L'environnement quiz et similaires %%%

\long\def\firstpass@quiz#1{\begingroup%
	\def\ques{\firstpass@cmd{ques}}%
	\def\choice{\firstpass@cmd{choice}}%
	\def\tchoice{\firstpass@cmd+{choice}}%
	\def\fchoice{\firstpass@cmd-{choice}}%
	\let\intro\collect@intro%
	\DeclareDocumentCommand\justification{O{} D(){}}{
		\gdef\just@cmd{\justification[##1] (##2)}}%
	%\ifhint\solutiontrue\fi
	\let\solution\firstpass@solution%
	\setbox\trash@box\vbox{#1}%
	\numgdef\choice@count{\thefake@choice}%
\endgroup}
\let\just@cmd\relax
\def\tofs{%
	\ifcompact%
		\@secondoftwo%
	\else%
		\texorpdfstring%
	\fi}
\DeclareDocumentEnvironment{meta@quiz}{mm O{} d() d<> E{\br}{{}} +b}{%
	\csuse{quiz#1}%
	\igxname{quiz}{#2}%
	\IfValueTF{#5}{\refstepcounter{quiz}}{\stepcounter{quiz}}%
	\def\ig@tempb{\deco@questionlabel{\name@quiz{} \label@quiz}}%
	\ifig@rigid{title}
		{\appto\ig@tempb{~:~\deco@questiontitle{\ig@rigid@title}}}
		{\IfValueT{#4}{\appto\ig@tempb{~:~\deco@questiontitle{#4}}}}%
	\preprocess@scores{#6}%
	\firstpass@quiz{#7}%
	\ifnum\ig@qscore>\z@%
		\appto\ig@tempb{\deco@unite{\ig@qscore}}%
	\fi%
	\ifig@rigid{choicelist}{\reprocess@choicelist}{}%
	\postprocess@scores%
	% début de l'insertion des différentes parties
	% bizarrement le code suivant refuse de fonctionner s'il n'est pas
	% encadré par une boite tcolorbox, ici fake@box
    \begin{fake@box}[title=\deco@quiz{\ig@tempb}]%
	%	\par\bigskip\deco@quiz{\ig@tempb}\par\nobreak
    	\IfValueT{#5}{\label{#5}}%
		\begingroup%
		\ifdefvoid\intro@body{}%
			{\lrmargin{.5\Gm@littlemargin}{.5\Gm@littlemargin}%
    			\csundef@afterexec{intro@body}%
			\endlrmargin}%
		\ifdefvoid\justif@expr{}%
			{\lrmargin{.5\Gm@littlemargin}{.5\Gm@littlemargin}%
    			\text@justifier%
			\endlrmargin}%
		\endgroup% 
		\set@choicerenderer%
    	\begin{quiz@body}[#3]%
    		\forlistloop{\for@cmd{choice}}\ig@choicelist
    	\end{quiz@body}%
	\end{fake@box}
    	\ifjustification\csundef@afterexec{just@cmd}\fi%
    	\ifhint%
			\ifig@withhint%
				\ifcompact\lrmargin{}{}\else\lrmargin{\Gm@littlemargin}{}\fi
					\hintsol@head{Justifications}%
    				\forlistloop{\for@cmd{hint}}\ig@choicelist%
				\endlrmargin%
    			\fi%
			\fi%
    	\ifsolution%
			\ifig@withsol%
				\ifcompact\lrmargin{}{}\else\lrmargin{\Gm@littlemargin}{}\fi
					\hintsol@head{Solutions}%
    				\forlistloop{\for@cmd{sol}}\ig@choicelist%
				\endlrmargin%
    		\fi%
		\fi%
}{%
	\choice@undef%
	\global\ig@withhintfalse%
	\global\ig@withsolfalse%
}
\def\quiz{\meta@quiz{true}{\name@quiz}}
\let\endquiz\endmeta@quiz
\def\genquiz#1{
	\ifblank{#1}{\meta@quiz{true}{\name@question}}{\meta@quiz{true}{#1}}%
}
\let\endgenquiz\endmeta@quiz
	
\csdef{genquiz*}#1{%
	\ifblank{#1}{\meta@quiz{false}{\name@question}}{\meta@quiz{false}{#1}}%
}
\cslet{endgenquiz*}\endmeta@quiz
\def\exer{\meta@quiz{false}{Exercice}}
\let\endexer\endmeta@quiz   

%%%%%%%%%% Justifications %%%%%%%%%%%%%%
 
\DeclareDocumentCommand\justification{O{4} D(){}}{%
	\exit%
	\ifjustification\par
		\deco@justification{\name@justification}%
		\ifblank{#2}{}{(#2)}% 
		\ifnum\value{score@tmp}>\z@\relax\deco@jscore{\thescore@tmp}\fi%
		\ifig@rigid{lignes}
			{\expandafter\lignes\expandafter{\ig@rigid@lignes}}
			{\lignes{#1}}%
	\fi%
	}
\NewDocumentCommand\justifcationspace{s O{35} D(){\name@justificationendspace}}{%
  \exit%
   \ifjustification%
	 \IfBooleanTF{#1}{\vfill\eject\pagestyle{empty}}{}
	  \par\bigskip\bigskip%
	   \deco@justification{#3}\\*[.66\baselineskip]%
	  \pgfmathparse{#2}%
	   \expandafter\lignes\expandafter{\pgfmathresult}%
	\fi%
	}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Gestion des questions et des solution	%%% 
%%% dans un probleme ou un exercice 			%%%

\unless\ifdraft\ifhintocg
	\RequirePackage[tikz]{ocgx2}
\fi\fi

\def\setup@hint{%
	\long\def\hint##1{}%
	\ifdraft
		\def\hint##1{\mini(ind)##1\endmini}%
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
\long\def\hint@box#1{%
	\par
  	\begin{tikzpicture}
		\begin{scope}[ocg={ref=\csuse{label@\ig@listctr}, status=invisible, name=HINT\arabic{\ig@listctr}}]
  			\node[hintbox] (hint) 
			{\null\hskip2.8em\parbox{\linewidth-2.8em}{#1}};%
		\end{scope}%
  		\node at ([xshift=1pt]hint.west) 
				[overlay, hintradiobox, switch ocg=\csuse{label@\ig@listctr}]
				{ind} ;%
  \end{tikzpicture}%
}
\def\hintradio{%
  \tikz \node [hintradiobox] {ind} ;%
}
\def\ques@hint#1{\@bsphack
	\long\edef\ig@tmpe{\the\toks@hint}
	\eappto\ig@tmpe{\noexpand\xhint{\csuse{label@\ig@listctr}}}
	\eappto\ig@tmpe{\unexpanded{#1}\noexpand\par}
	\expandafter\global\expandafter\toks@hint\expandafter{\ig@tmpe}
\@esphack}
\def\xhint#1{%
	\hypersetup{pdfborder=0 0 0}%
	\hypertarget{hint:\ig@current@id:#1}%
		{\hyperlink{eno:\ig@current@id:#1}%
			{\deco@linksol{#1}\enskip}}%
}
\def\x@hint{%
	\hypersetup{pdfborder=0 0 0}%
	\hyperlink{hint:\ig@current@id:\csuse{label@\ig@listctr}}{\hintradio}%
	}

%%% Patch de la commande \item pour qu'elle supporte 
%%% sa présence dans un environnement. 
\def\item@ques{%
  \@inmatherr\item
  \@ifnextchar[\@item@ques{\@noitemargtrue \@item@ques[\@itemlabel]}%
}

\def\@item@ques[#1]{%
 \@hyper@itemtrue %appliquer d'avance le patch hyperref normal
  \if@noparitem
    \@donoparitem
  \else
    \if@inlabel
      \indent \par
    \fi
    \ifhmode
      \unskip\unskip \par
    \fi
    \if@newlist
      \if@nobreak
        \@nbitem
      \else
        \addpenalty\@beginparpenalty
        \addvspace\@topsep
        \addvspace{-\parskip}%
      \fi
    \else
      \addpenalty\@itempenalty
      \addvspace\itemsep
    \fi
    \global\@inlabeltrue
  \fi
  \everypar{%
    \@minipagefalse
    \global\@newlistfalse
%    \if@inlabel %%% Le patch en question
      \global\@inlabelfalse
      {\setbox\z@\lastbox
       \ifvoid\z@
         \kern-\itemindent
       \fi}%
      \box\@labels
      \penalty\z@
%    \fi %%% Le patch en question
    \if@nobreak
      \@nobreakfalse
      \clubpenalty \@M
    \else
      \clubpenalty \@clubpenalty
      \everypar{}%
    \fi}%
  \if@noitemarg
    \@noitemargfalse
    \if@nmbrlist
      \refstepcounter\@listctr
    \fi
  \fi
  \sbox\@tempboxa{\makelabel{#1}}%
  \global\setbox\@labels\hbox{%
    \unhbox\@labels
    \hskip \itemindent
    \hskip -\labelwidth
    \hskip -\labelsep
    \ifdim \wd\@tempboxa >\labelwidth
      \box\@tempboxa
    \else
      \hbox to\labelwidth {\unhbox\@tempboxa}%
    \fi
    \hskip \labelsep}%
  \ignorespaces}
  
%% Fin du patch

% Adaptation de \xit pour les problèmes avec solutions
\def\switch@to@ques{\csletcs{deco@\ig@listctr}{deco@\ig@listctr @}}
\NewDocumentCommand\startques{t\r E{\op}{{}}}{%
	\IfBooleanTF{#1}
		{\begin{xenum}[r,#2]}
		{\begin{xenum}[#2]}%
	\switch@to@ques%
}
\NewDocumentCommand\init@ques{m t- t- t- t\r t+  E{\op}{{}} }{
	\IfBooleanTF{#5}%
        {\startques\r\op{#7}}
        {\IfBooleanT{#6}{\startques\op{#7}}}%
	\IfBooleanT{#2}{\exit-\IfBooleanT{#3}{\exit-\IfBooleanT{#4}{\exit-}}}%
	#1%
}
\NewDocumentCommand\x@ques{o E{\bar\zap}{{}{@}} d() d<>}{%
	\ifblank{#2}{}{%
		\addtocounter{score@tmp}{#2}%
		\addtocounter{score}{#2}%
		\def\ig@tmpscore{\ttfamily\footnotesize(#2pt)}%
	}%
	\ifstrequal{#3}{@}{}
            {\addtocounter{\ig@listctr}{#3}}%
	\IfValueTF{#1}
		{\item@ques[#1]}%
		{\item@ques}
	\IfValueT{#4}{\deco@itemtitle{#4}}%
	\IfValueT{#5}{\label{\ig@enumlabelprefix#5}}%
}
\def\xques{\init@ques{\ig@withsoltrue\x@ques}}
\def\zques{\init@ques{\ig@withsolfalse\x@ques}}
\NewDocumentEnvironment{ques}{}{\ig@withsoltrue\x@ques}{} 
\def\stopques{\exit}
\def\draft@solution{\par\medskip\textbf{\scshape solution :}\newline\nopagebreak}

\def\save@solution{%\
	\let\endques\close@ques%
	\igprotected@iwrite\solhandle@file{}{\string\xsol}%
	\igfilesave{solhandle}%
}
\def\close@ques{%
		\endigfilesave%
}
\newenvironment{writetosol}{\igfilesave{solhandle}}{\endigfilesave}
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
				\ifcsundef{\ig@current@id @}{
					\igopenfile{solhandle}[\aux@dir/\ig@current@id-cor]%
				}{}%
			%\else%
			%	\igopenfile{solhandle}[/dev/null]%
			\fi%
			\let\solution\save@solution%
		\fi%
}
\NewDocumentEnvironment{igwrite}{mm !O{} !d() !d<>}
	{%
		\csgdef{#2@}{}%
		\csgdef{#2@opts}{#3}%
		\IfValueT{#4}{\csgdef{#1@title}{#4}}%
		\IfValueT{#5}{\csgdef{#1@label}{#5}}%
		\igwriteonce{\aux@dir/#2-#1}%
	}
	{\endigwriteonce}
\def\corrige{\igwrite{cor}}
\let\endcorrige\engigwrite
\ignewexeprob*{corrige*}{}{\isasolutiontrue\setup@xsol}{}{}

\def\queslist{}
\def\close@problem#1{%
	\ifnum\c@score@tmp>\z@%
			\@expandtwoargs\defvalue{problemscore:\label@@#1}{\thescore@tmp}
	\fi%
	\ifstraight%
		\csxdef{\ig@current@id @list}{\queslist}%
	\fi
	\edef\ig@tmpe{\the\toks@hint}
	\ifdefempty\ig@tmpe{}{\parti*{Indications}\ig@tmpe}%
	\unless\ifdraft%
		\ifsolution%
			\igclosefile{solhandle}
			\ifsolutiondelayed
				\ifdefempty{\queslist}{}{%
					\tcbrecord{%
						\string\Solution
							{\ig@current@id} % identifiant
							{\expandafter\expandonce\csname \ig@current@id @title\endcsname} % titre (de l'énoncé) 
							{\expandafter\expandonce\csname \ig@current@id @opts\endcsname} % options passées avec "corrige=..."
							{\queslist}% liste des questions avec solutions
					}%
				}%
			\else	
				\ifdefempty\queslist{}{%
					\begingroup%
					\edef\ig@tmpa{\endgroup%
						\noexpand\Solution%
							{\ig@current@id} % identifiant
							{\expandafter\expandonce\csname \ig@current@id @title\endcsname} % titre (de l'énoncé) 
							{\expandafter\expandonce\csname \ig@current@id @opts\endcsname} % options passées avec "corrige=..."
							{\queslist}% liste des questions avec solutions
					}%
					\ig@tmpa%
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
		\ifdef\ig@tmpscore%
			{%
				\llap{\smash{\hb@xt@\dimexpr#1\relax{\ig@tmpscore}\hss}}%
			}{}%
	\fi%
	\csuse{deco@nolink\ig@listctr}{#2}%
	}	
\def\outer@ques@link#1#2{%
	\ifdef\ig@tmpscore%
		{%
			\llap{\smash{\hb@xt@\dimexpr#1\relax{\ig@tmpscore}\hss}}%
		}{}%
	\ifig@withsol%
		\hypersetup{pdfborder=0 0 0}%
		\hypertarget%
			{eno:\ig@current@id:#2}%
			{\hyperlink{cor:\ig@current@id:#2}{\csuse{deco@link\ig@listctr}{#2}}}%
		\xappto\queslist{#2,}%
	\else%
		\csuse{deco@nolink\ig@listctr}{#2}%
	\fi%
	}
\def\outer@sol@deco#1{%
	\hypersetup{pdfborder=0 0 0}%
	\hypertarget{cor:\ig@current@id:#1}%
		{\hyperlink{eno:\ig@current@id:#1}%
			{\deco@linksol{#1}}}%
}
\ifdraft
	\igdefdeco{linkenumi}{\bfseries #1.}
	\igdefdeco{linkenumii}{\bfseries #1.}
	\igdefdeco{nolinkenumi}{\bfseries #1.}
	\igdefdeco{nolinkenumii}{\bfseries #1.}
	\igdefdeco{linksol}{\bfseries #1.}
	\igdefdeco{indication}{\textbf{#1 :}\kern4pt}
\else
	\igdefdeco{linkenumi}{\genboxcmd[enodeco,collink]{#1}}
	\igdefdeco{linkenumii}{\genboxcmd[enodeco,collink]{#1}}
	\igdefdeco{nolinkenumi}{\genboxcmd[enodeco]{#1}}
	\igdefdeco{nolinkenumii}{\genboxcmd[enodeco]{#1}}
	\igdefdeco{linksol}{\genboxcmd[soldeco]{#1}}
	\igdefdeco{indication}{\textbf{#1 :}\kern4pt}
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

\def\terminate@questlist@pop#1\ig@nil{
	\in@{,}{#1}
	\ifin@
		\queslist@pop#1\ig@nil%
	\else
		\def\curr@item{#1}
	\fi%
}
\def\queslist@pop#1,#2\ig@nil{%
	\def\curr@item{#1}%
	 \def\queslist{#2}%
	}
\def\tmp@queslist@pop#1{\terminate@questlist@pop#1\ig@nil}
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
			\edef\ig@tempa{\noexpand\xzapsol[\number\numexpr#1-1]}
			\expandafter\ig@tempa
		\fi
		}
	}	
\AtBeginDocument{
	\ifcompact
		\igsetenum{1}{marge*}
		\igsetenum{2}{marge*}
	\else	
		\igsetenum{1}{marge}
		\igsetenum{2}{marge*}
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
\igdeflabel{enumi}{|X|.|1|}
\igdeflabel{enumii}{|X|.|Q|.|1|}
\igdeflabel{enumiii}{|X|.|Q|.|q|.|1|}

%%%% Décoration du label pour mini
\igset[mini]{%
	mini deco=#1.\kern1ex
}
\ifcompact
	\igset[mini]{left margin=16pt, 
		font=\sffamily\footnotesize, 
		label font=\sffamily\scshape\bfseries\footnotesize}
\else
	\igset[mini]{left margin=30pt}
\fi

%%%% Différents réglages
\AtBeginDocument{%
	\ifx\Hy@steplink\@undefined\else
	\hypersetup{pdftitle=\csuse{ig@theme}, 
				pdfauthor=\csuse{ig@auteur},
				pdfsubject=\csuse{ig@document},
			}
	\fi}
\igset[background]{%
	position = tb,
	code = {\tikz[overlay]\draw[rounded corners=10pt] 
	(-\Gm@littlemargin-20pt,-\footskip+10pt) rectangle 
	(\textwidth+28pt,\textheight+\headsep-4pt);}
}
\AtEndPreamble{%
	\ig@mkdir{\ig@outpathtoquiz}%
}

\endinput


%%%%%%%%%%%%%%%%%%%%%%
%%%% Page de garde %%%

%%%% besoin d'une réécriture complète : done

\DeclareDocumentEnvironment{infoseleve}{+b}
	{\long\gdef\info@body{#1}}{}

\tcbset{%
	student infos/.style={%
		only top and bottom rules,
		}
	}
\igaddkeyword{title}{infoseleve}{%
	\ifdef{\info@body}
		{%
		\begin{genbox}[student infos, 
			sidebyside, 
			righthand width=3.6cm, 
			lower separated=false, 
			sidebyside align=top
		 ]
				\bfseries\info@body%
				\tcblower
				\genboxcmd[arc=4pt, boxsep=.3cm]
					{\parbox[t][3.8cm]{2.7cm}{\bfseries\centering
		  		  		\deco@note{Note sur \usevalue{globalscore}}}}
			\end{genbox}
		}{}%
}

\igset[rules]{%
	question number/.code=\gdef\ig@quesnumber{#1},
	quiz number/.code=\gdef\ig@quiznumber{#1}, 
	title/.code=\igname*{rules}{#1},
	question number=4,
	quiz number=6,
	title={R\`egles du \textsc{qcm}},
}

\DeclareDocumentEnvironment{regles}{O{}+b}
	{\igset[rules]{#1}\long\gdef\rules@body{#2}}{}

\igaddkeyword{title}{regles}{%
	\ifdef{\rules@body}
		{%
			\begin{genbox}[only top and bottom rules](\csuse{name@rules})
				\igsetenum{1}{marge*}
				\igdefdeco{enumi}{\color{warmcol}\deco@rpattern}
				\rules@body
			\end{genbox}
		}{}%
}
\DeclareDocumentEnvironment{webregles}{O{}+b}{}{}

\igaddkeyword{title}{bareme}{%
	{\Large\bfseries Bar\`eme sur \usevalue{globalscore}%
		\global\ig@dima\baselineskip}\baselineskip\ig@dima}

\ifjustification
    \igdeftitleformat*{%
    	\null
		|centre|\par
    	\addvspace{\medskipamount}
    	|classe|\par
    	\vskip\z@ plus .25fill
    	|document|\par
		\addvspace{\medskipamount}
    	|theme|\par
		\addvspace{\bigskipamount}
    	|periode|\par
    	\vskip\z@ plus .25fill
    	|infoseleve|\par
    	\vfil
    	|regles|
    	\vfill 
    }
	\igdeftitleformat{%
    	|centre|\par
    	\addvspace{\medskipamount}
    	|classe|\par
    	\addvspace{2*\bigskipamount}
    	|document|\par
		\addvspace{\medskipamount}
    	|theme|\par
		\addvspace{\bigskipamount}
    	|periode|
    }
    \ifdef{\info@body}
    {\igset[title]{
    	after title={%
			\vfill
    		|infoseleve|\par\addvspace{\bigskipamount}
    		|regles|
			\vfill}{}
	}}
\fi

\ifsolution
    \igdeftitleformat*{%
    	\null
    	|centre|\par
    	\addvspace{\medskipamount}
    	|classe|\par
    	\vskip\z@ plus .33fill
    	|document|\par
		\addvspace{\medskipamount}
    	|theme|\par
		\addvspace{\bigskipamount}
    	|periode|\par
    	\vfill
    }
    \igdeftitleformat{%
    	|centre|\par
    	\addvspace{2*\bigskipamount}
    	|document|\par
    	\addvspace{\medskipamount}
		|theme|\par
		\addvspace{\bigskipamount}
    	|periode|
    }
\fi

\ifhint
    \igdeftitleformat*{%
    	\null
		|centre|\par
    	\addvspace{\bigskipamount}
    	|classe|\par
    	\vskip\z@ plus .33fill
    	|document|\par
		\addvspace{\medskipamount}
    	|theme|\par
		\addvspace{\bigskipamount}
    	|periode|\par
    	\vfill
    }
    \igdeftitleformat{%
    	|centre|\par
    	\addvspace{2*\bigskipamount}
    	|document|\par
		\addvspace{\medskipamount}
    	|theme|\par
		\addvspace{\bigskipamount}
    	|periode|
    }
\fi
