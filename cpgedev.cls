\def\filedate{2023/10/12}
\def\fileversion{v0.3alpha}
\def\fileauthor{Sadik Boujaida}

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{cpgedev}[\filedate\space\fileversion]
\RequirePackage{pgfopts} %Pour la gestion des options de la classe
\RequirePackage{etoolbox}
\def\cpgecurrentclass{dev} 



\@ifundefined{ifsubdoc}{%
	\newif\ifweb
	\newif\ifsingleimage
	\newif\ifthisfile
	\newif\ifdraft
	\newif\ifstraight
	\newif\ifnolinks
	\newif\ifprint
	\newif\ifserie
	\newif\ifquiz
	\newif\ifnocolors
	\newif\ifdark
	\newif\ifcompact
	\newif\ifstriptitle
	\newif\ifsolution 
	\newif\ifsolutiondelayed
	\newif\ifhint
	\newif\ifscore
	\newif\ifhintocg
}{}

\newif\ifconvert
\newif\iflocalscore

\def\class@options{11pt}
\pgfkeys{/IGD/.is family, /IGD/.cd,
	article/.code={\def\cpge@class{article}},
	report/.code={\def\cpge@class{report}},
	book/.code={\def\cpge@class{book}\cspreto\class@options{oneside,}},
	draft/.style={},
	straight/.style={},	
	serie/.style={},
	compact/.style={},
	dark/.style={},
	nocolors/.style={},
	solution/.style={},
	solution*/.style={},
	hint/.style={},
	hint*/.style={},
	web/.style={},
	convert/.style={},
	score/.style={},
}
\pgfkeys{/IGDS/.is family, /IGDS/.cd,
	draft/.is if=draft,	
	straight/.is if=straight,
	compact/.is if=compact,
	serie/.is if=serie,
	dark/.is if=dark,
	nocolors/.is if=nocolors, 
	nolinks/.is if=nolinks,
	web/.code=\compacttrue\webtrue%
		\ifundef\convert@option{\def\convert@options{}}{}
		\def\cpgecomment@list{#1},
	web/.default={exercice},
	convert/.code=\appto\convert@options{,#1},
	singleimage/.is if=singleimage,
	solution/.code=\csname solution#1\endcsname\solutiondelayedfalse,%
	solution/.default=true,
	solution*/.is if=solutiondelayed,
	hint/.code=\csuse{hint#1}\csuse{hintocg#1},
	hint/.default=true,
	hint*/.code=\csuse{hint#1}\hintocgfalse,
	hint*/.default=true,
	score/.is if=score,
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
\def\cpge@class{article}
\@ifundefined{ifsubdoc}
	{\ProcessPgfOptions{/IGDS}}
	{\ProcessPgfOptions{/IGD}}

\let\@xp\expandafter
\let\@nx\noexpand
\let\@xo\expandonce

\begingroup
\edef\cpge@tmp{\endgroup
	\@nx\LoadClass[\@xo\class@options]{\cpge@class}
}
\cpge@tmp




%%%%% Packages du projet 
\RequirePackage{cpgebase}
\RequirePackage{cpgesubdoc}
\RequirePackage{cpgemath}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Basculement vers la conversion en images %%%%%%	
\ifbool{web}
	{\RequirePackage{cpgeweb}\endinput}{}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\RequirePackage[customtitles]{cpgecommon}
\unless\ifdraft
	\cpgeloadpackage[calc,backgrounds]{tikz}
\fi


%% Declarations 
\newcounter{tmpdo}
\def\aux@dir{tmp}
\newif\ifsolutionlist
\newif\ifcpge@withsol % vrai si le numero de la question courante doit être un hyperlien 
\newif\ifincluded%
\newif\ifisasolution%
\newif\ifcpge@tmpswa
\newif\ifcpge@tmpswb

\newtoks\toks@hint % retient l'indication de la question en cours
\newtoks\cpge@toks % token list générique pour multiple usage

\ifscore\localscoretrue\fi 
\def\setup@solutionmode{%
	\ifstraight%
		\solutiondelayedfalse%
		\ifsolution%
			\hinttrue%
			\def\Solution{\Real@Solution}%
			\def\corrige{\Corrige}%
			\let\endcorrige\endCorrige%
		\fi%
	\else
		\ifsolutiondelayed\solutiontrue\fi%
		\ifsolution\hinttrue\fi%
		\ifsolution%
			\def\Solution{\Real@Solution}%
		\fi%
		\ifsolutiondelayed%
			\cpgestartrecording%
		\fi%
	\fi%
}
\def\setup@draftmode{%
	\ifdraft
		\solutiontrue
		\straighttrue
		\setup@solutionmode
	\fi%
}
\AtBeginDocument{%
	\setup@solutionmode% %
	\setup@draftmode%
}
\def\c@rrige{
	\ifsolution\@xp\Corrige\else\@xp\comment\fi%
}
\def\endc@rrige{%
	\ifsolution\@xp\endCorrige\else\@xp\endcomment\fi%
}

%%%%% Other package initialisation
\RequirePackage{currfile}
\RequirePackage{lastpage}
\RequirePackage{fontawesome}
%\RequirePackage{bookmark}


%%%% Strategie d'inclusion de fichier
%%%%  une version modifiée de subfile.sty renommée en cpgesubdoc.sty
%%%  
\cpgesetup[include]{
	solution/.code=\csname solution#1\endcsname\solutiondelayedfalse,
	solution*/.code=\csname solutiondelayed#1\endcsname,
	draft/.is if=draft,
	hint/.is if=hint,
	before solutions/.code=\def\before@solutions@hook{#1},
	solution file/.code=\def\solfilename{#1},
	corrige/.store in=\cor@commonopts,
	only/.code=\csvtolistadd\eno@list{#1},
	before/.code=\appto\include@beforehook{#1},
	after/.code=\preto\include@afterhook{#1}
}
\def\cor@commonopts{}
\def\include@beforehook{}
\def\include@afterhook{}
\NewDocumentCommand\cpgeinclude{ om }{%
	%\RenewDocumentCommand\titre{s e\op +d()}{}%
	\begingroup
		\includedtrue%
		\let\shipoutsolutions\relax
		\IfFileExists{#2-cor.tex}{\def\solfilename{#2-cor}}{}
		\IfValueT{#1}{\cpgesetup[include]{#1}}%
		\setup@solutionmode% %
		\setup@draftmode%
		\unless\ifstraight
			\ifundef\solfilename{}
			{%
				\typeout{====================================^^J%
					^^J%
					Inclusion en aval des fichiers de solutions \solfilename^^J%
					^^J%
					====================================}
				\forcsvlist\subdoc\solfilename%
			}%
		\fi% 
		\include@beforehook%
		\IfFileExists{#2-eno.tex}
			{%
				\subdoc{#2-eno}%
				\typeout{====================================^^J%
				^^J%
				Inclusion du fichier #2-eno.tex^^J%
				^^J%
				====================================}%
			}{%
				\subdoc{#2}%
				\typeout{====================================^^J%
				^^J%
				Inclusion du fichier #2.tex^^J%
				^^J%
				====================================}%
			}
		\include@afterhook%
		\ifstraight
			\ifundef\solfilename{}
			{%
				\typeout{====================================^^J%
					^^J%
					Inclusion en amont des fichiers de solutions \solfilename^^J%
					^^J%
					====================================}
				\forcsvlist\subdoc{\solfilename}%
			}%
		\fi%
	\endgroup%
	\undef\eno@list%
}

\def\cpgeincludeweb#1{} 

%% Formats par defaut des titres 
\cpgesettitle{
	\ifdefmeta{document}{|document| \\}{}
	\ifdefmeta{theme}{|theme| \\}{} 
	|periode|%
}
\cpgesettitle*{%
	|document|  
	|theme|  
	|periode|%
}
\let\xdocument\document
\let\endsxdocument\enddocument



%%%%%%%%%%%%%%%%%%%%%%%%
%%% Les declarations %%%

% Les variables globales
% quelque soit la configuration, les questions auront chacune un numéro unique.
%\cpgedefcounter est définie dans cpgebase.sty 
\cpgedefcounter{@devoir}{}(D)
\cpgedefcounter{section}{}[@devoir](*S) % (*S) pour écraser le raccourci S
\cpgedefcounter{problem}{}[@devoir](Y) 
\cpgedefcounter{parti}{}[problem](P)<partie>
\cpgedefcounter{partii}{}[parti](p)<partie>
\cpgedefcounter{bigques}{|I|}[partii](B)<question>
\cpgedefcounter{solution}{}
\cpgedefcounter{question}{}
\def\theHquestion{\theHItem}
\def\theHsolution{\theHItem}
\ifltxcounter{score}{}{\newcounter{score}[@devoir]}
\ifltxcounter{score@tmp}{}{\cpgedefcounter{score@tmp}{}[problem]}
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Création des divisons de document \devoir, \section, \problem...  %%%
%%% repose sur cpgetitle.sty qui fusionne titlesec, titleps et titletoc %%%

%%% Résiliation des commandes de titrage usuelles
\undef\chapter
\undef\section
\undef\subsection
\undef\parapgraph
\undef\subparagraph

%%% La nouvelle architecture de titrage
\titleclass{\@devoir}[0]{top} % -> \devoir 
\titleclass{\section}{straight}[\@devoir]
\titleclass{\problem}{straight}[\section] % -> {probleme}, {exercise}, ...
\titleclass{\parti}{straight}[\problem] 
\titleclass{\partii}{straight}[\parti]
\titleclass{\bigques}{straight}[\partii]

\def\chapter{\@devoir}

\def\cpgesetupsectiontitle{\cpgesetup[sectiontitle]}
\cpgesetupsectiontitle{
	label/.code 2 args=\cpgesetlabel{\@xp\@gobble\string#1}{#2},
	fill/.code 2 args=\csdef{\@xp\@gobble\string#1@align}{\csuse{fil#2}},
	label fill/.code 2 args=\csdef{\@xp\@gobble\string#1label@align}{\csuse{fil#2}},
	shape/.code 2 args=\csdef{\@xp\@gobble\string#1@shape}{#2},
	deco/.code 2 args=\cpgesetdeco{\@xp\@gobble\string#1}{#2},
	label deco/.code 2 args=\cpgesetdeco{\@xp\@gobble\string#1label}{#2},
	spacing/.code n args={4}{\cpgetitle@spacing{#1}{#2}{#3}{#4}},	
	set/.code=\cpgetitle@setformat{\@xp\@gobble\string#1},
	devoir/.is family,
	devoir/label/.code=\cpgesetlabel{@devoir}{#1},
	devoir/fill/.code=\def\@devoir@align{\csuse{fil#1}},
	devoir/label fill/.code=\def\@devoirlabel@align{\csuse{fil#1}},
	devoir/shape/.code=\def\@devoir@shape{#1}\cpge@tmpswatrue,
	devoir/deco/.code=\cpgesetdeco{@devoir}{#1},
	devoir/label deco/.code=\cpgesetdeco{@devoirlabel}{#1},
	devoir/numberless label deco/.code=\cpgesetdeco{@devoirlabelnumberless}{#1},
	devoir/spacing/.code n args={3}{\cpgetitle@spacing{\@devoir}{#1}{#2}{#3}},
	devoir/.code=\pgfqkeys{/cpge/sectiontitle/devoir}{#1}
				 \ifcpge@tmpswa
				 	\cpgetitle@setformat{@devoir}
				     \cpge@tmpswafalse\fi
				 \cpgetitle@setspacing{\@devoir},
	problem/.is family,
	problem/font/.code=\def\problem@font{#1},
	problem/label/.code=\cpgesetlabel{problem}{#1},
	problem/fill/.code=\def\problem@align{\csuse{fil#1}},
	problem/label fill/.code=\def\problemlabel@align{\csuse{fil#1}},
	problem/shape/.code=\def\problem@shape{#1}\cpge@tmpswatrue,
	problem/deco/.code=\cpgesetdeco{problem}{#1},
	problem/label deco/.code=\cpgesetdeco{problemlabel}{#1},
	problem/spacing/.code n args={3}{\cpgetitle@spacing{\problem}{#1}{#2}{#3}},
	problem/.code=\pgfqkeys{/cpge/sectiontitle/problem}{#1}
				 \ifcpge@tmpswa
				 	\cpgetitle@setformat{problem}
				     \cpge@tmpswafalse\fi
				 \cpgetitle@setspacing{\problem},
	section/.is family,
	section/font/.code=\def\section@font{#1},
	section/label/.code=\cpgesetlabel{section}{#1},
	section/fill/.code=\def\section@align{\csuse{fil#1}},
	section/shape/.code=\def\section@shape{#1}\cpge@tmpswatrue,
	section/deco/.code=\cpgesetdeco{section}{#1},
	section/label deco/.code=\cpgesetdeco{sectionlabel}{#1},
	section/spacing/.code n args={3}{\cpgetitle@spacing{\section}{#1}{#2}{#3}},
	section/.code=\pgfqkeys{/cpge/sectiontitle/section}{#1}
				 \ifcpge@tmpswa
				 	\cpgetitle@setformat{section}
				     \cpge@tmpswafalse\fi
				 \cpgetitle@setspacing{\section},
	parti/.is family,
	parti/font/.code=\def\parti@font{#1},
	parti/label/.code=\cpgesetlabel{parti}{#1},
	parti/fill/.code=\def\parti@align{\csuse{fil#1}},
	parti/shape/.code=\def\parti@shape{#1}\cpge@tmpswatrue,
	parti/deco/.code=\cpgesetdeco{parti}{#1},
	parti/label deco/.code=\cpgesetdeco{partilabel}{#1},
	parti/spacing/.code n args={3}{\cpgetitle@spacing{\parti}{#1}{#2}{#3}},
	parti/.code=\pgfqkeys{/cpge/sectiontitle/parti}{#1}
				 \ifcpge@tmpswa
				 	\cpgetitle@setformat{parti}
				     \cpge@tmpswafalse\fi
				 \cpgetitle@setspacing{\parti},
	partii/.is family,
	partii/font/.code=\def\partii@font{#1},
	partii/label/.code=\cpgesetlabel{partii}{#1},
	partii/fill/.code=\def\partii@align{\csuse{fil#1}},
	partii/shape/.code=\def\partii@shape{#1}\cpge@tmpswatrue,
	partii/deco/.code=\cpgesetdeco{partii}{#1},
	partii/label deco/.code=\cpgesetdeco{partiilabel}{#1},
	partii/spacing/.code n args={3}{\cpgetitle@spacing{\partii}{#1}{#2}{#3}},
	partii/.code=\pgfqkeys{/cpge/sectiontitle/partii}{#1}
				 \ifcpge@tmpswa
				 	\cpgetitle@setformat{partii}
				     \cpge@tmpswafalse\fi
				  \cpgetitle@setspacing{\partii},
	bigques/.is family,
	bigques/font/.code=\def\bigques@font{#1},
	bigques/label/.code=\cpgesetlabel{bigques}{#1},
	bigques/fill/.code=\def\bigques@align{\csuse{fil#1}},
	bigques/shape/.code=\def\bigques@shape{#1}\cpge@tmpswatrue,
	bigques/deco/.code=\cpgesetdeco{bigques}{#1},
	bigques/label deco/.code=\cpgesetdeco{bigqueslabel}{#1},
	bigques/spacing/.code n args={3}{\cpgetitle@spacing{\bigques}{#1}{#2}{#3}},
	bigques/.code=\pgfqkeys{/cpge/sectiontitle/bigques}{#1}
				 \ifcpge@tmpswa
				 	\cpgetitle@setformat{bigques}
				     \cpge@tmpswafalse\fi
				  \cpgetitle@setspacing{\bigques},
}

\def\cpgetitle@align#1#2#3{%
	\csletcs{#1@align}{fil#2}
	\csletcs{#1label@align}{fil#3}%
}
\let\fildefault\relax
\DeclareDocumentCommand\cpgetitle@shape{mmoo}{%
 \csdef{#2@shape}{#1}
 \IfValueTF{#4}
  {\cpgetitle@align{#2}{#3}{#4}}
  {\IfValueT{#3}{\cpgetitle@align{#2}{#3}{#3}}}
}
\def\cpgetitle@format#1{%
 \begingroup\def\cpge@tmpa{\endgroup\titleformat{#1}}%
 \@xp\cpge@tmpa\@xp%
}
\def\cpgetitle@setformat#1{\csuse{#1@format}}
\def\cpgetitle@spacing#1#2#3#4{%
	\csdef{\@xp\@gobble\string#1@leftspace}{#2}
	\csdef{\@xp\@gobble\string#1@beforeskip}{#3}
	\csdef{\@xp\@gobble\string#1@afterskip}{#4}
}
\def\cpgetitle@setspacing#1{%
	\titlespacing*{#1}
		{\csuse{\@xp\@gobble\string#1@leftspace}}
		{\csuse{\@xp\@gobble\string#1@beforeskip}}
		{\csuse{\@xp\@gobble\string#1@afterskip}}
}
%%%%%%%%%%%%%%%%%%

%%% Styles des versions internes des commandes de titre 
\cpgesetupsectiontitle{devoir={numberless label deco={}, deco=#1}}
\cpgetitle@shape{display}{@devoir}[default]
\def\@devoir@format{
	\cpgetitle@format{\@devoir}[\@devoir@shape]
		{\csundef@afterexec{hook@beforedevtitle}}
		{\@devoirlabel@align%
			\ifcpge@tmpswb
				\addtocounter{@devoir}{-1}%
				\deco@@devoirlabelnumberless{}%
			\else
				\deco@@devoirlabel{\@devoir@name}{\label@@devoir}
			\fi
		}
		{\z@}
		{\@devoir@align\deco@@devoir{\cnt@name}{##1}}
		[\csundef@afterexec{hook@afterdevtitle}]
	\cpgetitle@format{name=\@devoir, numberless}[\@devoir@shape]
		{\csundef@afterexec{hook@beforedevtitle}}
		{\@devoirlabel@align%
			\deco@@devoirlabelnumberless}
		{\z@}
		{\@devoir@align\deco@@devoir{##1 \\ \csundef@afterexec{hook@afterdevtitle}}}
		%[\@devoirlabel@align]
}
\@devoir@format
\cpgetitle@spacing{\@devoir}{\z@}{-1cm}{*6}
\cpgetitle@setspacing{\@devoir}

%%%%% L'équivalent de \section
\cpgetitle@shape{display}{section}[center]
\def\section@font{\LARGE\scshape}
\def\section@format{
	\cpgetitle@format{\section}[\section@shape]
  		{\csuse{section@align}\csuse{section@font}}
  		{\deco@sectionlabel{\label@section}}
  		{\z@}
  		{\deco@section{##1}}
}
\section@format
\cpgetitle@spacing{\section}{\z@}{*6}{*3}
\cpgetitle@setspacing{\section}

%%%%% version interne des titres pour les sujets
\def\after@problemtitle{%
	\csundef@afterexec{hook@afterproblemtitle}%
	\iflocalscore%
		\ifdef{\problemcounter@name}
			{
				\edef\cpge@tmpe{\usevalue{score:\cpge@problem@id}}%
				\ifdefvoid{\cpge@tmpe}{}
					{\par\normalsize\textit{(sur \cpge@tmpe\space points)}}%
			}{}%
	\fi%
}
\ifserie 
	\cpgetitle@shape{hang}{problem}[right]
	\def\problem@font{\Large}
\else 
	\cpgetitle@shape{display}{problem}[center]
	\def\problem@font{\LARGE}
\fi 
\def\parti@font{\large}
\def\partii@font{\normalsize}
\def\set@linkcol{\unless\ifx\listbox\default@listbox\hypersetup{linkcolor=mainone}\fi}
\def\link@problemlabel#1{%
	\edef\cpge@tmpa{#1}%
	\unless\ifx\cpge@tmpa\space%
		\ifsolution%
			\ifisasolution%
				\set@linkcol%
				\Hy@raisedlink{\hypertarget{\cpge@problem@id:cor}{}}%
				\hyperlink{\cpge@problem@id:eno}{\deco@problemlabel{#1}}%
			\else%
				\set@linkcol%
				\Hy@raisedlink{\hypertarget{\cpge@problem@id:eno}{}}%
				\hyperlink{\cpge@problem@id:cor}{\deco@problemlabel{#1}}%
			\fi%
		\else%
			\deco@problemlabel{#1}%
		\fi%
	\fi}%
\def\problem@format{%
	\cpgetitle@format{\problem}[\problem@shape]
  		{\problem@font}
  		{\problemlabel@align
  			\link@problemlabel{\cnt@name}}
  		{\z@}
  		{\problem@align\ifcpge@tmpswa\deco@problem{}\else\deco@problem{##1}\fi}
  		[\after@problemtitle]
	\cpgetitle@format{name=\problem, numberless}[\problem@shape]
  		{\problem@font}
  		{\problemlabel@align\deco@problemlabelnumberless{}}
  		{\z@}
  		{\problem@align\ifcpge@tmpswa\deco@problem{}\else\deco@problem{##1}\fi}
  		[\after@problemtitle]
}
\problem@format
\ifserie 
	\cpgetitle@spacing{\problem}{\z@}{*2}{*1}
\else
	\cpgetitle@spacing{\problem}{\z@}{*3}{*3}
\fi 
\cpgetitle@setspacing{\problem}

%%%%%%

%%% \parti, à utiliser dans {probleme} ou {exercice}
\setcounter{secnumdepth}{5}
\cpgetitle@shape{block}{parti}[right]
\def\parti@format{%
	\cpgetitle@format{\parti}[\parti@shape]
  		{\csuse{parti@align}\parti@font}
		{\deco@partilabel{\label@parti}}
		{\z@}
  		{\protect\boldmath\deco@parti{##1}}
}
\parti@format
\ifserie 
	\cpgetitle@spacing{\parti}{\z@}{*2}{*1}
\else 
	\cpgetitle@spacing{\parti}{\z@}{*4}{*2}
\fi
\cpgetitle@setspacing{\parti}

%%% \partii,  subdivision de \parti
\cpgetitle@shape{block}{partii}[right]
\def\partii@font{\bfseries}
\def\partii@format{
	\cpgetitle@format{\partii}[\partii@shape]
		{\csuse{partii@align}\partii@font}
		{\deco@partiilabel{\label@partii}}
		{\z@}
		{\protect\boldmath\deco@partii{##1}}
}
\partii@format
\ifserie 
	\cpgetitle@spacing{\partii}{\z@}{*1}{*1}
\else 
	\cpgetitle@spacing{\partii}{\z@}{*3}{*1.5}
\fi 
\cpgetitle@setspacing{\partii}

%%% \bigques, pour certains sujets de concours (Centrale) 
\cpgetitle@shape{runin}{bigques}[left]
\def\bigques@font{\bfseries}
\def\bigques@format{
	\cpgetitle@format{\bigques}[\bigques@shape]
		{\csuse{bigques@align}\bigques@font}
		{\deco@bigqueslabel{\label@bigques}}
		{\z@}
		{\protect\deco@bigques{##1}}
}
\bigques@format
\cpgetitle@spacing{\bigques}{\z@}{*1}{*1}
\cpgetitle@setspacing{\bigques}


%%% Variantes de \parti et \partii pour ecrire en plus
%%% les titres dans le ficheir de corrigé
\NewDocumentCommand\wparti{om}{
    \unless\ifstraight
        \cpgeprotected@iwrite\solhandle@file{}
            {\string\parti\IfValueT{#1}{[#1]}{#2}}
    \fi
    \IfValueTF{#1}{\parti[#1]{#2}}{\parti{#2}}
}
\NewDocumentCommand\wpartii{om}{
    \unless\ifstraight
        \cpgeprotected@iwrite\solhandle@file{}
            {\string\partii\IfValueT{#1}{[#1]}{#2}}
    \fi
    \IfValueTF{#1}{\partii[#1]{#2}}{\partii{#2}}
}
\NewDocumentCommand\wbigques{om}{%
    \unless\ifstraight
        \cpgeprotected@iwrite\solhandle@file{}
            {\string\bigques\IfValueT{#1}{[#1]}{#2}}%
    \fi%
    \IfValueTF{#1}{\bigques[#1]{#2}}{\bigques{#2}}
}

%%% Wrappers pour \parti et \partie conforme à l'interface commune
%%% des commandes qui produisent des titres. Gèrent la possibilité
%%% d'ecrire le tire dans le fichier de corrigé sous forme d'option.
\RequirePackage{tokcycle}
\settcEscapechar{&}
\NewDocumentCommand\partie{ s t\w e{\op} o D(){} d<> }{
	\IfValueT{#3}{\cpgesetupsectiontitle{parti={#3}}}%
	\def\@tmptitle{\parti}%
	\IfBooleanT{#1}{\appto\@tmptitle*}%
	\IfValueT{#4}{\appto\@tmptitle{[#4]}}%
	\appto\@tmptitle{{#5}}%
	\@tmptitle
	\IfValueF{#1}{\IfValueT{#6}{\label{eno:\cpge@problem@id:#6}}}%
	\unless\ifstraight%
		\IfBooleanT{#2}{%
			\IfValueT{#3}{%
				\tokcyclexpress{\cpgesetupsectiontitle{parti={#3}}}%
				\cpgeprotected@iwrite\solhandle@file{}{\the\cytoks}%
			}%
        	\cpgeprotected@iwrite\solhandle@file{}{\@xp\string\@tmptitle}%
			\IfValueT{#6}
				{\cpgeprotected@iwrite\solhandle@file{}%
            		{\string\label{cor:\cpge@problem@id:#6}}}%
		}%
    \fi%
}
\NewDocumentCommand\souspartie{ s t\w e{\op} o D(){} d<> }{
	\IfValueT{#3}{\cpgesetupsectiontitle{partii={#3}}}%
	\def\@tmptitle{\partii}%
	\IfBooleanT{#1}{\appto\@tmptitle*}%
	\IfValueT{#4}{\appto\@tmptitle{[#4]}}%
	\appto\@tmptitle{{#5}}%
	\@tmptitle%
	\IfValueF{#1}{\IfValueT{#6}{\label{eno:\cpge@problem@id:#6}}}%
	\unless\ifstraight%
		\IfBooleanT{#2}{%
			\IfValueT{#3}{%
				\tokcyclexpress{\cpgesetupsectiontitle{partii={#3}}}%
				\cpgeprotected@iwrite\solhandle@file{}{\the\cytoks}%
			}%
        	\cpgeprotected@iwrite\solhandle@file{}{\@xp\string\@tmptitle}%
			\IfValueT{#6}%
				{\cpgeprotected@iwrite\solhandle@file{}%
            		{\string\label{cor:\cpge@problem@id:#6}}}%
		}%
    \fi%
}
\NewDocumentCommand\gques{ s t\w e{\op} o D(){} d<> }{
	\IfValueT{#3}{\cpgesetupsectiontitle{bigques={#3}}}%
	\def\@tmptitle{\bigques}%
	\IfBooleanT{#1}{\appto\@tmptitle*}%
	\IfValueT{#4}{\appto\@tmptitle{[#4]}}%
	\appto\@tmptitle{{#5}}%
	\@tmptitle%
	\IfValueF{#1}{\IfValueT{#6}{\label{eno:\cpge@problem@id:#6}}}%
	\unless\ifstraight%
		\IfBooleanT{#2}{%
			\IfValueT{#3}{%
				\tokcyclexpress{\cpgesetupsectiontitle{bigques={#3}}}%
				\cpgeprotected@iwrite\solhandle@file{}{\the\cytoks}%
			}%
        	\cpgeprotected@iwrite\solhandle@file{}{\@xp\string\@tmptitle}%
			\IfValueT{#6}%
				{\cpgeprotected@iwrite\solhandle@file{}%
            		{\string\label{cor:\cpge@problem@id:#6}}}%
		}%
    \fi%
}


%%%%%% Surcouches des commandes de titrages

%% Ajout d'une métadonnée devoir pour une utilisation avec \titre 

\cpgeaddkeyword{title}{devoir}{{\LARGE\scshape\csuse{deco@devoir}{\csuse{cpge@devoir}}%
                  \global\cpge@dima\baselineskip}\baselineskip\cpge@dima}

\def\deco@@devoir#1#2{{\huge#1} \\ #2}
\def\deco@@devoirlabel#1#2{#1\ #2}
\cpgesetdeco{@devoirlabelnumberless}{}

\cpgesetup[@devoir]{%
	name/.store in=\@devoir@name,
	name=sujet,
	number/.code=\setcounter{@devoir}{\numexpr#1-1},
	after title/.code=\title@parser{\begingroup#1\endgroup}%
		\@xp\def\@xp\hook@afterdevtitle\@xp{\title@contents},
	before title/.code=\title@parser{\begingroup#1\endgroup\par}%
		\@xp\def\@xp\hook@beforedevtitle\@xp{\title@contents},
	title deco/.code=\cpgesetdeco{@devoir}{#1},
	label deco/.code=\cpgesetdeco{@devoirlabel}{#1},
}

\NewDocumentCommand\devoir{s E\op{{}} m o d() d<>}{%
	\IfBooleanT{#1}{\cpge@tmpswbtrue}
	\def\cnt@name{#3}%
	\cpgesetup[@devoir]{#2}%
	\IfNoValueTF{#4}
	  	{%
			\IfValueTF{#5}
				{\cpge@tmpswafalse\@devoir[\textsc{#3~:}~#5]{#5}}
				{\cpge@tmpswatrue\@devoir[#3]{}}%
		}%
		{%
			\IfValueTF{#5}
				{\cpge@tmpswafalse\@devoir[\textsc{#3~:}~#4]{#5}}
				{\cpge@tmpswatrue\@devoir[\textsc{#3~:}~#4]{}}%
		}
	\IfBooleanT{#1}{\cpge@tmpswbfalse}
}

%%% Boite tikz générique pour différentes déorations
\NewDocumentCommand\genboxcmd{O{}m}{\fbox{#2}}
\cpgesetdeco{indication}{\textbf{#1 :}\kern4pt}
\unless\ifdraft
	\tikzset{generic style/.style={fill=none, draw=framestrokecol, inner sep = 3pt, rounded corners=3pt}}
	\RenewDocumentCommand\genboxcmd{O{} +m}{%
		\tikz [baseline=(T.base)] \node (T) [generic style, #1] {\strut #2};
}
\fi

%%
\cpgesetlabel{section}{|I|}
\cpgesetdeco{sectionlabel}{-- #1 -- }
\cpgesetdeco{section}{\protect\boldmath\bfseries #1}
\cpgesetlabel{parti}{|1|}
\cpgesetdeco{partilabel}{\bfseries#1.\enskip}
\cpgesetdeco{parti}{#1}
\cpgesetlabel{partii}{|P|.|A|}
\cpgesetdeco{partiilabel}{\bfseries#1.\enskip}
\cpgesetdeco{partii}{#1}
\cpgesetdeco{bigqueslabel}{#1 --\enskip}
\cpgesetdeco{bigques}{#1.}

\def\partiautorefname{partie}
\def\partiiautorefname{partie}
\def\bigquesautorefname{partie}
\def\questionautorefname{question}
\def\solutionautorefname{solution}

%%%%%%%
\cpgesetdeco{problem}{{#1 }}
\cpgesetdeco{problemlabel}{%
	{\Large\scshape\bfseries%
	\deco@lpattern\enskip#1\enskip\deco@rpattern}%
}
\ifserie 
	\cpgesetdeco{problem}{\ifblank{#1}{~:\space}{(#1)~:\space}}
	\cpgesetdeco{problemlabel}{{\scshape\bfseries#1\space}}%
	\cpgetitle@spacing{\problem}{\z@}{*3}{*1}
	\cpgetitle@setspacing{\problem}
\fi 
\cpgesetdeco*{lpattern}{\cpgesquare}
\cpgesetdeco*{rpattern}{\cpgesquare}
\newif\ifnonumber
\cpgesetup[@problem]{%
	nonumber/.is if=nonumber,
	solution/.code=\csuse{solution#1}\solutiondelayedfalse,
	solution/.default=true,
	solution*/.is if=solutiondelayed,
	hint/.is if=hint,
	hint*/.is if=hintocg,
	score/.is if=localscore,
	current counter/.code=\letcs\thecurrent@counter{the#1},
	before/.store in=\hook@beforeproblem,
	after/.store in=\hook@afterproblem,
	before title/.code=\title@parser{#1}%
		\@xp\long\@xp\def\@xp
		 \hook@beforeproblemtitle\@xp{\title@contents},
	after title/.code=\title@parser{#1}%
		\@xp\long\@xp\def\@xp\hook@afterproblemtitle
		 \@xp{\title@contents},
	label/.code=\@xp\cpgesetlabel\@xp{\problemcounter@name}{#1},
	title deco/.code=\cpgesetdeco{problem}{#1},
	label deco/.code=\cpgesetdeco{problemlabel}{#1},
	corrige/.code=\def\cor@curropts{#1}, 
}
\cpgesetup[solution]{
	nonumber/.is if=nonumber,
	alt title/.code=\def\alt@title{#1}, 
	before/.store in=\hook@beforeproblem,
	after/.store in=\hook@afterproblem,
	before title/.code=\title@parser{#1}%
		\@xp\long\@xp\def\@xp
		 \hook@beforeproblemtitle\@xp{\title@contents},
	after title/.code=\title@parser{#1}%
		\@xp\long\@xp\def\@xp\hook@afterproblemtitle
		 \@xp{\title@contents},
	questions list/.store in=\queslist,
	.unknown/.code={},
}
\def\noqueslistmessage{%
	\typeout{%
		====================================^^J%
		^^J%
		 	\problemcounter@name\space\arabic{\problemcounter@name} :
			Aucune liste de questions n'est disponible ^^J%
		^^J%
		====================================}
} 
\def\setup@id{%
		\ifisasolution%
			\ifstraight%
				\ifcsundef{\cpge@problem@id @queslist}{}
					{\edef\queslist{\csuse{\cpge@problem@id @queslist}}}%
			\fi% 
			\def\xref{\xref@cor}%
		\else%
			\ifcsdef{eno@\cpge@problem@id}
				{\ClassError{cpgedev}{\problemcounter@name\space
					\arabic{\problemcounter@name}\space:\space
				  	Identifiant \cpge@problem@id\space 
					déjà utilisé}{}}
				{\csgdef{eno@\cpge@problem@id}{}%
					\csxdef{prefixedname@\cpge@problem@id}{%
						\csuse{dudela@\problemcounter@name}\space
				  		 \csuse{label@\problemcounter@name}%
					}%
					\csxdef{label@@\cpge@problem@id}{%
				  		 \csuse{label@\problemcounter@name}%
					}%
				}%
			\def\xref{\xref@eno}%
		\fi%
}
%%% commande responsable de la formation du titre dans un environnment 
%%% un problème/exercice. Elle a une version * pour produire un titre 
%%% sans numéro mais doit dans tous les cas inscrire une entrée dans
%%% la table des matières et préparer le contexte pour un éventuel 
%%% \label. La difficulté vient du fait que les environnements 
%%% problème/exercice ont des compteurs individuels que le titre 
%%% doit afficher tout en utilisant en interne le compteur problem 
%%% en commun pour tous les environnements pour que la table des 
%%%% matières continue à fonctionner comme il se doit. 
\DeclareDocumentCommand\@problemtitle{
		s % #* numbered or not
		m % #2 counter name
		m % #3 printed name
		o % #4 alternative title
		D(){} % #5 optional title
		d<> % #6 optional label for referencing
	}{%
		\IfBooleanF{#1}{%
			\IfValueTF{#6}
				{\refstepcounter{#2}}
				{\stepcounter{#2}}%
			}%
		\IfBooleanTF{#1}
			{\edef\cnt@name{#3}}
			{\edef\cnt@name{#3 \csuse{label@#2}}}%
			%\show\cnt@name%
		\LinkTargetOff
		\ifblank{#5}% 
			{\cpge@tmpswatrue%
				\@xp\problem\@xp[\@xp{\@xp\textsc\@xp{\cnt@name}\IfValueT{#4}{\ifblank{#4}{}{:\space#4}}}]{}}%
			{\cpge@tmpswafalse%
			\@xp\problem\@xp[{\@xp\textsc\@xp{\cnt@name}\IfValueTF{#4}{\ifblank{#4}{}{:\space#4}}{:\space#5}}]{#5}%
			}%
		\LinkTargetOn%
		\IfValueT{#6}{%
			\ifblank{#5}
				{\IfValueT{#4}{\protected@edef\@currentlabelname{#4}}}%
				{\protected@edef\@currentlabelname{#5}}%
			\MakeLinkTarget[#2]{problem}%
			\label{\cpge@labelprefix#6}%
		}%
	}	
\DeclareDocumentCommand\genericproblemtitle{
		m % #1 printed name
		o % #2 alternative title
		d() % #3 optional title
		d<> % #4 optional label
	}{%
		\def\cnt@name{#1}%
		\IfValueTF{#3}%
			{\cpge@tmpswafalse%
				\problem[{\textsc{\cnt@name}\IfValueTF{#2}{~:~#2}{~:~#3}}]{#3}}
			{\cpge@tmpswatrue%
				\problem[{\textsc{\cnt@name}\IfValueT{#2}{~:~#2}}]{}}%
		\IfValueT{#4}{%
			\IfValueTF{#3}
				{\protected@edef\@currentlabelname{#3}}
				{\IfValueTF{#2}{\protected@edef\@currentlabelname{#2}}}%
			\MakeLinkTarget[#1]{problem}%
			\csgdef{#1autorefname}{#1}%
			\label{eno:\cpge@problem@id:#4}%
		}%
	}
\def\cpge@problem@id{Unnamed}
\DeclareDocumentCommand\cpgenewproblem{%sudo apt update
		s %1 corrige or enonce
		m %2 counter name
		m %3 printed name
		o %4 autorefname to be used (hyperref)
		m %5 counter label format
		m %6 solution title prefix
		d() %7 counter shortcut
		}{%
	\IfValueTF{#7}
		{\cpgedefcounter{#2}{#5}[@devoir](#7)}
		{\cpgedefcounter{#2}{#5}[@devoir]}%
	\IfValueTF{#4}
		{\csgdef{#2autorefname}{#4}}
		{\csxdef{#2autorefname}{\MakeLowercase{#3}}}
	\csgdef{dudela@#2}{#6}
	\IfBooleanT{#1}{%
		\NewDocumentEnvironment{#2}{m +e{\op} o d() d<>}
			{%
				\def\cpge@problem@id{##1}%
				\isasolutiontrue%
				\def\problemcounter@name{#2}%
				\IfValueT{##2}{\cpgesetup[solution]{##2}}%
				\csdef{label@#2}{%
					\csuse{prefixedname@\cpge@problem@id}%
				}%
				\edef\cpge@labelprefix{cor:\cpge@problem@id:}%
				\csuse{hook@beforeproblemtitle}%
				\ifnonumber
					\@problemtitle*{#2}{#3}[##3](##4)<##5>%
				\else%
					\@problemtitle{#2}{#3}[##3](##4)<##5>
				\fi%
				\csuse{hook@afterproblemtitle}%
				\setup@id%
				\setup@xsol%
				\csuse{hook@beforeproblem}%
			}{
				\endxsol%
				\csuse{hook@afterproblem}%
			}%
		\@xp\NewDocumentCommand\csname #2*\endcsname{ m +E{\op}{{}}}
			{\csname #2\endcsname{##1}\op{nonumber,##2}}
		\csletcs{end#2*}{end#2}
	}
	\IfBooleanF{#1}{%
		\NewDocumentEnvironment{#2}{m +E{\op}{{}} o d() d<>}{%
			\ifblank{##1}
				{\edef\cpge@problem@id{#2-\the\numexpr\value{#2}+1}}
				{\def\cpge@problem@id{##1}}%
			\def\problemcounter@name{#2}%
			\cpgesetup[@problem]{current counter=#2,##2}%
			\edef\cor@curropts{\@xo\cor@commonopts}%
			\ifnonumber\appto\cor@curropts{,nonumber}\fi%
			\setup@solutionmode%
			\ifcsundef{##1@param}{%
				\csxdef{##1@param}{{\@xo\cor@curropts}}%
				\IfValueT{##3}{\csgappto{##1@param}{[##3]}}%
				\IfValueT{##4}{\csgappto{##1@param}{(##4)}}%
				\IfValueT{##5}{\csgappto{##1@param}{<##5>}}%
			}{}%
			\edef\cpge@labelprefix{eno:\cpge@problem@id:}%
			\csuse{hook@beforeproblemtitle}%
			\ifnonumber
				\@problemtitle*{#2}{#3}[##3](##4)<##5>%
			\else 
				\@problemtitle{#2}{#3}[##3](##4)<##5>%
			\fi
			\csuse{hook@afterproblemtitle}%
			\setup@id%
			\setup@sol%
			\setup@hint%
			\csuse{hook@beforeproblem}%
		}{%
			\exit%
			\csuse{hook@afterproblem}%
			\close@problem{#2}%
		}
		\@xp\NewDocumentCommand\csname #2*\endcsname{ m +E{\op}{{}}}
			{\csname #2\endcsname{##1}\op{nonumber,##2}}
		\csletcs{end#2*}{end#2}
	}
}
\cpgesetdeco{pattern}{}
\cpgenewproblem{probleme}
	{Problème}
	[problème]
	{|1|}
	{du problème}
	(R)
\cpgenewproblem{exercice}
	{Exercice}
	[exercice]
	{|1|}
	{de l'exercice}
	(E)
\cpgenewproblem{cours}
	{Questions de cours}
	[q. de cours]
	{|1|}
	{des questions de cours}
	(K)
\cpgenewproblem{epreuve}
	{\ifsolution Énoncé\fi}
	[sujet]
	{*}
	{}
\cpgenewproblem{enonce}
	{\ifsolution Énoncé\fi}
	[sujet]
	{*}
	{}
\cpgenewproblem*{Corrige}
	{\solutionname}
	[corrigé]
	{}
	{}

\def\solutionname{Corrigé}

%%%%%%%%%%%%%%%%%%%%%%
%%% table des matières
\let\ttl@savemark\relax
\def\toclevel@@devoir{0}
\def\toclevel@section{1}
\def\toclevel@problem{2}
\def\toclevel@parti{3}
\def\toclevel@partii{4}
\def\toclevel@bigques{5}
\titlecontents{@devoir}[0em]{}{\Large}{\Large}{\hfill\contentspage}
\titlecontents{section}[0em]{\bigskip}{\Large}{\Large}{\hfill\contentspage}
\titlecontents{problem}[1em]{\medskip}{\bfseries\boldmath}{\scshape}{\null\hfill\contentspage}
\titlecontents{parti}[3em]{}{}{\scshape}{\hfill\contentspage}
\titlecontents{partii}[4em]{}{}{}{}
\titlecontents{bigques}[6em]{}{}{}{}

%%% Entrées pour pagestyles
 
\let\@devoirtitle\@empty
\let\sectiontitle\@empty
\let\problemtitle\@empty
\let\partititle\@empty
\let\partiititle\@empty
\let\bigquestitle\@empty
\ttl@setifthe{@devoir}
\ttl@setifthe{section}
\ttl@setifthe{problem}
\ttl@setifthe{parti}
\ttl@setifthe{partii}
\ttl@setifthe{bigques}

% les divisions qui seront marquées pour une utilisation dans pagestyle    
\settitlemarks{@devoir,section,problem,parti}
% Ajout des mots clés section et problem pour utilisation avec \cpgesethead et \cpgesetfoot.
\cpgeaddkeyword*{hf}{devoir}
	{\ifthe@devoir{\MakeLowercase{\@devoirtitle}}{}}
\cpgeaddkeyword*{hf}{section}
	{\ifthesection{\MakeLowercase{\sectiontitle}}{}}
\cpgeaddkeyword*{hf}{problem}
	{\iftheproblem{\MakeLowercase{\problemtitle}}{}}
\cpgeaddkeyword*{hf}{parti}
	{\iftheparti{\MakeLowercase{\partititle}}{}}
\cpgeaddkeyword{hf}{pages}{page\enskip\thepage{} / \pageref*{LastPage}}
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Finalisation du barème %%%

\def\addtoscore#1{\addtocounter{score}{#1}}
\def\showscore{\usevalue{score:global}}
\AtEndDocument{\defvalue{score:global}{\thescore}}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Gestion des questions et des solutions	%%% 
%%% dans un probleme ou un exercice 		%%%
\long\def\hint@draft#1{\mini(ind)#1\endmini}%
\def\setup@hint{%
	\long\def\hint##1{}%
	\ifstraight
		\let\hint\hint@draft%
	\else%
		\ifhint%
			\ifhintocg%
				\let\hint\hint@ocg%
			\else%
				\global\toks@hint{}%
				\def\hint{\x@hint\ques@hint}%
			\fi%
		\fi%
	\fi%
}
\unless\ifstraight\ifhintocg
	\RequirePackage[tikz]{ocgx2}
	\tikzset{
		hintbox/.style={rounded corners=2pt,
			inner xsep=5pt, inner ysep=3pt,
			text width=\linewidth-10pt-2\pgflinewidth,
			%align=justify,
			draw=linkstrokecol,
			fill=yellow!20,
			font=\sffamily\small
		},
		hintradiobox/.style={
			rounded corners=2pt, 
			text width=2em, 
			align=center, anchor=west,
			fill=linkbackcol, text=white,
			draw=none, inner xsep=.2em, inner ysep=2pt,
			font=\sffamily\footnotesize\bfseries,
		}
	}
	\long\def\hint@ocg#1{%
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
	\fi\fi 
\newcounter{fakecounter}
\def\set@xhint{
	\ifundef\cpge@listctr
	{\stepcounter{fakecounter}%
	  \def\hintctr{fakecounter}%
	  \def\label@hintctr{\arabic{fakecounter}}%
	}{\def\hintctr{\cpge@listctr}}%
}
\def\ques@hint#1{\@bsphack
	\long\edef\cpge@tmpe{\the\toks@hint}
	\eappto\cpge@tmpe{\@nx\xhint{\csuse{label@\hintctr}}}
	\appto\cpge@tmpe{#1\par}
	\@xp\global\@xp\toks@hint\@xp{\cpge@tmpe}
\@esphack}
\def\xhint#1{%
	\Hy@raisedlink{\hypertarget{hint:\cpge@problem@id:#1}{}}%
	\hyperlink{eno:\cpge@problem@id:#1}{\deco@link@sol{#1}\enskip}%
}
\def\x@hint{%
	\set@xhint%
	\hyperlink{hint:\cpge@problem@id:\csuse{label@\hintctr}}{\hintradio}%
	}

%%%%%%%%%%%%% Le style des numeros de questions %%%%%%%%%%%%%
\cpgesetup[listbox]{
	enodeco/.code=\def\boxing@item##1{\hb@xt@\curr@textwidth{\left@listfil##1\right@listfil}},
	soldeco/.code=\def\boxing@item##1{##1\kern.25em},
	.unknown/.code=\relax
}
\let\boxing@item\@iden
\NewDocumentCommand\default@listbox{O{}m}{%
	\cpgesetup[listbox]{#1}%
	\boxing@item{#2}%
}
\let\listbox\default@listbox
\appto\endpreamble@hook{%
	\unless\ifdraft\unless\ifprint%
		\RenewDocumentCommand\listbox{O{}m}{%
			\tikz [anchor=base, baseline, yshift=.25ex]  
				\node [
						generic style, 
						font=\sffamily\footnotesize\bfseries\strut, 
						rounded corners=2.4\p@, 
						inner xsep=4\p@, 
						inner ysep=\p@,  
						#1
					] {#2};%
		}
		\tikzset{%
			collink/.style={%
				fill=linkbackcol, 
				draw=none, 
				text=white},
			enodeco/.style={}
		}
	\fi\fi
}
\let\show@quesscore\relax
\cpgesetdeco{link@}{%
	\show@quesscore%
	\ifsolution%
		\ifcpge@withsol%
			\set@linkcol%
			\Hy@raisedlink{\hypertarget{hyeno:\cpge@problem@id:\csuse{label@\cpge@listctr}}{}}%
			\hyperlink{hysol:\cpge@problem@id:\csuse{label@\cpge@listctr}}{%
						\listbox[enodeco, collink, text width=\curr@textwidth, align=right]{#1}%
					}%
		\else% 
			\listbox[enodeco, align=center]{#1}%
		\fi%
	\else%
		\listbox[enodeco, align=center]{#1}%
	\fi%
}
\cpgesetdeco{nolink@}{%
	\show@quesscore\listbox[enodeco, align=center, text width=\curr@textwidth,]{#1}%
}
\cpgesetdeco{emptylabel}{\listbox{#1}}
%%%%% hyperlien ou pas
\cpgesetdeco{score}{#1\kern\p@\vrule}
\def\score#1{\marginpar{\null\hfill\deco@score{\strut #1}\kern6\p@}}
\def\set@solutionslinks{
	\edef\score@width{\dimexpr\score@placement\@enumdepth\relax}%
	\def\outerdeco@list{%
		\ifcpge@withsol%
			\@xp\deco@link@%
		\else%
			\@xp\deco@nolink@%
		\fi%
	}%
}
\preto\outerdeco@init{\cpge@withsolfalse}

%%%% placement du barême 
\def\score@placement#1{%
	\ifcase#1%
			\or \Gm@littlemargin%
			 \or \Gm@littlemargin+\leftmargini%
			  \or \Gm@littlemargin+\leftmargini+\leftmarginii%
	\fi%
}
\def\cpge@tab@row#1{\ifblank{#1}{}{#1\\}}
\def\cpge@tab@score#1{%
	\ttfamily\footnotesize%
	\def\arraystretch{.58}%
	\raisebox{\fntht 1}{\tabular[t]{@{}c@{}}\in@parser\cpge@tab@row{#1}\endtabular}%
}
\cpgesetdeco{quesscore}{#1\kern\p@\vrule\kern3\p@}
\def\print@eno@score#1{\ifscore%
	\llap{\smash{\hb@xt@\score@width{\hb@xt@\Gm@littlemargin{\hss\deco@quesscore{\cpge@tab@score{#1}}}\hss}}}%
	\global\let\show@quesscore\relax%
\fi}

%%%%% l'environnement et les commandes des questions
\cpgesetuplists{
	preload/switchdeco/.code=\let\outeremptydeco@list\deco@emptylabel,
	switchdeco/.code=\relax
}
\NewDocumentCommand\questions{!t\r E{\op}{{}}}{%
	\IfBooleanTF{#1}%
		{\xenum\op{switchdeco,r,#2}}%
		{\xenum\op{switchdeco,#2}}%%
	\set@solutionslinks%
	}
\let\endquestions\endxenum
\NewDocumentCommand\startques{!t\r E{\op}{{}} }{%
	\IfBooleanTF{#1}%
		{\begin{xenum}\op{switchdeco,r,#2}}%
		{\begin{xenum}\op{switchdeco,#2}}%
	\set@solutionslinks%
}
\NewDocumentCommand\init@ques{m !t- !t- !t- !t\r !t+  E{\op}{{}} }{%
	\IfBooleanT{#2}{\exit-\IfBooleanT{#3}{\exit-\IfBooleanT{#4}{\exit-}}}%
	\IfBooleanTF{#5}%
        {\startques\r\op{#7}}%
        {\IfBooleanT{#6}{\startques\op{#7}}}%
	#1%
}
\NewDocumentCommand\x@ques{o E{\sc}{{}} d() d<>}{%
	\def\ques@score@{#2}%
	\ifblank{#2}{}{%
		\global\c@score@tmp=\numexpr\c@score@tmp+#2\relax%
		\def\show@quesscore{\print@eno@score{#2}}%
	}%
	\IfValueTF{#1}%
		{\if@staratend{#1}
		   {\cpgeref@setcounter{\cpge@listctr}{\x@arg-1}\cpge@item}
		   {\if@plusatend{#1}
			  {\cpgeref@addtocounter{\cpge@listctr}{\x@arg-1}\pcge@item}
			  {\cpge@item[#1]}%
		   }
			\ifblank{#1}%
				{\stepcounter{\cpge@listctr}}%
				{}%
		}%
		{\cpge@item}%
	\refstepcounter{question}%
	\edef\@currentlabel{\csuse{label@\cpge@listctr}}
	\ifcpge@withsol%
		\IfValueTF{#4}{\gdef\ques@label@{#4}}{\gdef\ques@label@{}}%
		\xappto\queslist{{\cpge@listctr}{\csuse{label@\cpge@listctr}}{\ques@label@}{\ques@score@},}
	\fi%
	\begingroup%
	\IfValueT{#3}{\protected@edef\@currentlabelname{#4}\deco@itemtitle{#3}}%
	\IfValueT{#4}{%
		\MakeLinkTarget[question]{Item}%
		\ifblank{#4}%
			{\label{eno:\cpge@problem@id:\csuse{label@\cpge@listctr}}}%
			{\label{eno:\cpge@problem@id:#4}}%
	}%
	\endgroup%
}
%%% Les commandes utilisateurs 
\def\xques{\init@ques{\cpge@withsoltrue\x@ques}}
\def\zques{\init@ques{\cpge@withsolfalse\x@ques}}
\def\stopques{\exit}

%%%%%%%%%%%%%%%%%%% mécanisme d'écriture des solutions dans un fichier %%%%%%%%%%%
%%% gestion d'une réinsertion immédiate ou différée
%%% du contenu de ce fichier selon les options de la classe.


\def\handtorightlink#1{%
	\ifsolution%
		\ifhmode\par\nobreak\noindent\fi%%
		\set@linkcol%
		\Hy@raisedlink{\hypertarget{hyeno:#1}{}}
		\ifcompact%
			\hyperlink{hysol:#1}{%
				\deco@link@{\fontsize{12}{10}\normalfont\faHandORight}}%
			\hskip\labelsep%
		\else
			\vskip-\baselineskip%
			\llap{%
					\hyperlink{hysol:#1}{%
						\deco@link@{\fontsize{12}{10}\normalfont\faHandORight}}%
					\hskip\labelsep
			}%
		\fi%
	\fi%
	}
\def\handtoleftlink#1{%
	\set@linkcol
	\Hy@raisedlink{\hypertarget{hysol:#1}{}}%
			\hyperlink{hyeno:#1}{%
				\deco@link@sol{\fontsize{12}{12}\selectfont\faHandOLeft}}
			\hskip\labelsep%
}

\NewDocumentCommand\draft@save{o d() d<>}{% 
	\par\medskip
	\def\endsolution{\par\medskip}%
	\strut\textbf{\scshape solution~:~}%
	\isasolutiontrue%
	\def\xref{\xref@cor}%
	\IfValueTF{#3}%
		{\label{cor:\cpge@problem@id:#3}}%
		{\ifdefvoid\ques@label@{}{
			\MakeLinkTarget[solution]{Item}%
			\edef\@currentlabel{\csuse{label@\cpge@listctr}}%
 			\phantomsection%
			\label{cor:\cpge@problem@id:\ques@label@}%
		}}
}
\NewDocumentCommand\real@save{!o}{%
	\let\endsolution\endcpgefilesave%
	\IfValueTF{#1}
		{\handtorightlink{#1}%
			\cpgeprotected@iwrite\solhandle@file{}{\string\par\string\handtoleftlink{#1}}%
		}{%
			\let\endques\endcpgefilesave%
			\cpgeprotected@iwrite\solhandle@file{}{\string\xsol}%
		}%
	\cpgefilesave{solhandle}%
}
\NewDocumentCommand\draft@write{o}{%
	\slshape%
	\csdef{endsolution*}{\aftergroup\par}%
}
\NewDocumentCommand\real@write{!o}{%
	\cslet{endsolution*}\endcpgefilesave%
	\cpgefilesave{solhandle}
}
\long\def\writetosol#1{%
    \ifstraight
		#1%
	\else
        \cpgeprotected@iwrite\solhandle@file{}{\unexpanded{Commande #1}}
    \fi
}
\def\setup@sol{%
	\ifdraft%
		\let\solution\draft@save%
		\cslet{solution*}\draft@write%
	\else%
		\open@solfile%
	\fi%
}
\def\open@solfile{%
	\cpgeopenfile{solhandle}[\aux@dir/\cpge@problem@id-live]%
	\ifsolution
		\let\solution\real@save%
		\cslet{solution*}\real@write%
	\else%
		\let\solution\comment\let\endsolution\endcomment%
		\cslet{solution*}\comment\cslet{endsolution*}\endcomment %
	\fi%
}
\NewDocumentEnvironment{cpgewrite}{mom !e\op !o !d() !d<>}
	{%%
		\IfValueTF{#2}
			{\IfValueTF{#4}{\csgdef{#3@param}{{#4,#2}}}{\csgdef{#3@param}{{#2}}}}
			{\IfValueTF{#4}{\csgdef{#3@param}{{#4}}}{\csgdef{#3@param}{{}}}}
		\IfValueT{#5}{\csgappto{#3@param}{[#5]}}%
		\IfValueT{#6}{\csgappto{#3@param}{(#6)}}%
		\IfValueT{#7}{\csgappto{#3@param}{<#7>}}%
		\cpgewriteonce{\aux@dir/#3-#1}%
	}
	{\endcpgewriteonce}
\def\corrige{\cpgewrite{cor}}
\csdef{corrige*}{\cpgewrite{cor}[nonumber]}
\def\endcorrige{\endcpgewriteonce\csuse{Solution@\cpge@problem@id}}
\cslet{endcorrige*}\endcorrige

\def\queslist{}
\def\setqueslist#1#2{\csdef{#1@queslist}{#2}}
\def\close@problem#1{%
	\ifnum\c@score@tmp>\z@%
		\defvalue{score:\cpge@problem@id}{\thescore@tmp}%
		\global\c@score=\numexpr\c@score+\c@score@tmp\relax%
	\fi%
	\ifsolution%
		\immediate\write\@auxout{\string\setqueslist{\cpge@problem@id}{\queslist}}%
	\fi%
	\ifstraight%
		\csxdef{\cpge@problem@id @queslist}{\queslist}%
	\fi%
	\csxdef{\cpge@problem@id @maxlabelwidth}{\the\@maxlabelwidth}%
	\global\@maxlabelwidth\z@%
	\long\edef\cpge@tmpe{\the\toks@hint}%
	\ifdefempty\cpge@tmpe{}{\parti*{Indications}\cpge@tmpe}%
	\cpgeclosefile{solhandle}%
	\edef\current@corrige{%
		\@nx\Solution{\cpge@problem@id}\@xp\@xo\csname\cpge@problem@id @param\endcsname{\queslist}}
	\gdef\queslist{}%
	\ifsolutiondelayed
		\cpgerecord{\@xo\current@corrige}
	\else\ifsolution\unless\ifstraight%
		\global\cslet{Solution@\cpge@problem@id}\current@corrige%
		\@xp\aftergroup\csname Solution@\cpge@problem@id\endcsname%
	\fi\fi\fi%
}
\def\shipoutsolutions{%
	\ifsolutiondelayed%
		\cpgestoprecording%
		\csuse{before@solutions@hook}%
		\InputIfFileExists{\cpge@recordfile}{}{}%
	\fi% 
}	
\def\corriges{\shipoutsolutions}
\def\solutions{\shipoutsolutions}
\newif\iflocalfilenotempty
\def\first@filesuffix{live}
\def\second@filesuffix{cor}
\DeclareDocumentCommand\Real@Solution{mm o d() d<> m }{%
	\IfFileEmpty{\aux@dir/#1-\first@filesuffix.tex}
		{%
			\IfFileEmpty{\aux@dir/#1-\second@filesuffix.tex}%
				{\def\local@file{}}%
				{\edef\local@file{\aux@dir/#1-\second@filesuffix}}%
		}{%
			\edef\local@file{\aux@dir/#1-\first@filesuffix}%
		}%
	\ifdefempty\local@file{}{%
		\csgundef{Solution@\cpge@problem@id}%
		\begin{Corrige}{#1}\op{#2}[#3](#4)<#5>
			\ifdefempty\queslist{\def\queslist{#6}}{}%
			\ifdefempty\queslist{\noqueslistmessage}{}%
			\csedef{the\problemcounter@name}{\csuse{label@@\cpge@problem@id}}
			\input{\local@file}%
		\end{Corrige}%
	}%
}
\DeclareDocumentCommand\Dummy@Solution{m o d() d<> mm }{}
\def\Solution{\Dummy@Solution}


%%%% Références croisées %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% \xref pour gestion des référence croisées des questions, parties, ....
\cpgesetdeco{pageref}{\sffamily\smaller{}[p. #1]}
\def\set@pageref{\@ifstar{\set@pageref@eno}{\set@pageref@cor}}
\def\set@pageref@eno#1{%
	\ifcsdef{r@eno:\problem@id:#1}%
		{\def\pageref@eno{%
			\space\deco@pageref{\pageref*{eno:\problem@id:#1}}}%
		}{}%
}
\def\set@pageref@cor#1{%
	\ifcsdef{r@eno:\problem@id:#1}%
		{\def\pageref@eno{%
			\space\deco@pageref{\pageref*{eno:\problem@id:#1}}}%
		}{}%
	\ifcsdef{r@cor:\problem@id:#1}%
		{\def\pageref@cor{%
			\space\deco@pageref{\pageref*{cor:\problem@id:#1}}}%
		}{}%
}
\NewDocumentCommand\xref@eno{s t\r t\n t\e t\c t\p t\t O{\cpge@problem@id} m}{%
	\edef\problem@id{#8}%
	\IfBooleanTF{#3}{\def\xref@ref@{\ref}}{\def\xref@ref@{\autoref}}%
	\IfBooleanTF{#1}{\def\xref@ref{\xref@ref@*}}{\def\xref@ref{\xref@ref@}}%
	\IfBooleanT{#2}%
		{\IfBooleanTF{#3}%
			{\def\xref@ref{\xref@numeno\n}}%
			{\def\xref@ref{\xref@numeno}}%
		}%
	\def\pageref@eno{}%
	\IfBooleanF{#2}{%
		\ifdraft\set@pageref*{#9}\fi%
		\ifprint\set@pageref*{#9}\fi%%
		\IfValueT{#6}{\set@pageref*{#9}}%
	}%
	\ignorespaces%
	\IfBooleanTF{#2}%
		{\xref@ref{#9}}%
		{\ifcsdef{r@eno:\problem@id:#9}{%
			\xref@ref{eno:\problem@id:#9}\pageref@eno%
			\IfBooleanT{#7}{\ (\nameref*{eno:\problem@id:#9})}%
		}{}}%
}
\NewDocumentCommand\xref@cor
	{s t\r t\n t\e t\c t\p t\t O{\cpge@problem@id} m}
{%
	\edef\problem@id{#8}%
	\IfBooleanTF{#3}{\def\xref@ref@{\ref}}{\def\xref@ref@{\autoref}}%
	\IfBooleanTF{#1}{\def\xref@ref{\xref@ref@*}}{\def\xref@ref{\xref@ref@}}%
	\IfBooleanT{#2}%
		{\IfBooleanTF{#3}%
			{\def\xref@ref{\xref@numcor\n}}%
			{\def\xref@ref{\xref@numcor}}%
		}%
	\let\x@ref\relax%
	\def\pageref@eno{}%
	\def\pageref@cor{}%
	\IfBooleanF{#2}{%
		\ifdraft\set@pageref{#9}\fi%
		\ifprint\set@pageref{#9}\fi%%
		\IfValueT{#6}{\set@pageref{#9}}%
	}%
	\IfBooleanT{#2}%
		{%
			\IfBooleanTF{#4}{%
				\IfBooleanTF{#5}%
					{\def\x@ref{\ignorespaces\xref@ref\a{#9}}}%
					{\def\x@ref{\ignorespaces\xref@ref\e{#9}}}%
			}{%
				\IfBooleanTF{#5}%
					{\def\x@ref{\ignorespaces\xref@ref\s{#9}}}%
					{\def\x@ref{\ignorespaces\xref@ref\a{#9}}}%
			}%
		}%
	\IfBooleanF{#2}%
		{%
			\IfBooleanT{#4}{%
				\ifcsdef{r@eno:\problem@id:#9}{%
					\def\x@ref{\ignorespaces%
						\xref@ref{eno:\problem@id:#9}\pageref@eno}%
				}{}%
			}%
			\IfBooleanT{#5}{%
				\ifcsdef{r@cor:\problem@id:#9}{%
					\ifx\x@ref\relax%
						\def\x@ref{\ignorespaces%
							\xref@ref{cor:\problem@id:#9}\pageref@cor}%
					\else%
						\appto\x@ref{\space(\xref@ref{cor:\problem@id:#9}\pageref@cor)}%
					\fi%
				}{}%
			}%
			\IfBooleanF{#4}{%
				\IfBooleanF{#5}{%
					\ifcsdef{r@eno:\problem@id:#9}
						{\def\x@ref{\ignorespaces%
							\xref@ref{eno:\problem@id:#9}\pageref@eno%
							\space}}{}%
					\ifcsdef{r@cor:\problem@id:#9}
						{\appto\x@ref{(\xref@ref{cor:\problem@id:#9}\pageref@cor)}}{}%
				}%
			}%
		}%
		\x@ref%
		\IfBooleanT{#7}{%
			\ifcsdef{r@eno:\problem@id:#9}%
				{\ (\nameref*{eno:\problem@id:#9})}%
				{%
					\ifcsdef{r@cor:\problem@id:#9}%
						{\ (\nameref*{cor:\problem@id:#9})}{}%
				}%
			}%
}
\def\poorref{\xref\r}
\NewDocumentCommand\xref@numeno{t\n t\e t\c t\a m}{%
	\IfBooleanTF{#1}{\let\ques@arn\relax}{\let\ques@arn\questionautorefname}%
	\hyperlink{hyeno:\problem@id:#5}{\ques@arn\space#5}%
}
\NewDocumentCommand\xref@numcor{t\n t\e t\c t\a m}{%
	\IfBooleanTF{#1}%
		{\def\ques@arn{}\def\sol@arn{sol.\space}}%
		{\def\ques@arn{\questionautorefname\space}\def\sol@arn{\solutionautorefname\space}}%
	\IfBooleanT{#2}%
		{\hyperlink{hyeno:\problem@id:#5}{\ques@arn#5}}%
	\IfBooleanT{#3}%
		{\hyperlink{hysol:\problem@id:#5}{\sol@arn#5}}%
	\IfBooleanT{#4}%
		{\hyperlink{hyeno:\problem@id:#5}{\ques@arn#5}\space%
			(\hyperlink{hysol:\problem@id:#5}{\sol@arn#5})}%
}

%%% Références croisées des équations. 
%%% transféré vers cpgemath.sty 


%%%%%%%% Environnements pour le rendu des solutions %%%%%%%%%
%%% \xsol la commande magique pour numéroter les 
%%% questions dans le fichier de solutions
\def\xsol@env{%
	\begingroup\@listdepth\z@
   	\list\relax%
        {%
         %\usecounter{solution}%
		\listparindent\parindent%
		  \labelwidth\z@%
		   \itemindent\labelsep%
			\itemsep\medskipamount%
		     \leftmargin\z@%
			  \let\makelabel\outer@sol@deco%
        }%
	\solutionlisttrue
 }
\def\endxsol{\ifsolutionlist\endlist\endgroup\fi}
\def\setup@xsol{\let\xsol\first@xsol}
\let\curr@deco\@iden
\def\get@itemlabelscore#1#2#3#4\@nil{%
	\letcs\curr@deco{deco@#1}%
	\def\curr@item{#2}%
	\def\curr@label{#3}%
	\def\curr@score{#4}%
}
\def\queslist@pop#1\cpge@nil{
	\in@{,}{#1}
	\ifin@
		\queslist@pop@#1\cpge@nil%
	\else
		\ifblank{#1}{\def\curr@item{FixMe}}{\get@itemlabelscore#1\@nil}%
	\fi%
}
\def\queslist@pop@#1,#2\cpge@nil{%
	\get@itemlabelscore#1\@nil%	
	\def\queslist{#2}%
}
\def\first@xsol{%
	\ifdefempty\queslist%
		{
			\setbox\z@\hbox{FixMe}
			\csdimdef{\cpge@problem@idFixMe @maxlabelwidth}{\the\wd\z@}
			\def\xsol{\alt@xsol}
		}
		{\def\xsol{\real@xsol}}%
	\xsol@env\xsol%
}
\DeclareDocumentCommand\alt@xsol{od()d<>}{%
	\@nmbrlisttrue%
	\IfValueTF{#1}
		{\item[#1]\def\@currenlabel{#1}}
		{\item[FixMe]\def\@currenlabel{FixMe:\theItem}}%
	\begingroup%
	\IfValueT{#2}{\protected@edef\@currentlabelname{#2}\deco@unitetitle{#2}\par\nobreak}%
	\IfValueT{#3}{%
		\MakeLinkTarget[solution]{Item}%	
 		\label{cor:\cpge@problem@id:#3}%
	}%
	\endgroup%
}
\DeclareDocumentCommand\real@xsol{od()d<>}{%
	\IfValueTF{#1}
		{\def\curr@item{#1}\def\curr@score{}}
		{\@xp\queslist@pop\queslist\cpge@nil}%
	\ifdefempty\curr@score{}{\let\show@quesscore\print@cor@score}%
	\item[\curr@item]%
	\edef\@currentlabel{\curr@item}%
	\Hy@MakeCurrentHrefAuto{solution}%
  	\Hy@raisedlink{\hyper@anchorstart{\@currentHref}\hyper@anchorend}%
	\begingroup%
	%\MakeLinkTarget[solution]{Item}
	\IfValueT{#2}{\protected@edef\@currentlabelname{#2}\deco@unitetitle{#2}\par\nobreak}%
	\IfValueTF{#3}{%
		%\edef\@currentlabel{\curr@item}%
		\ifblank{#3}
			{\label{cor:\cpge@problem@id:\curr@item}}
			{\label{cor:\cpge@problem@id:#3}}%
	}{%
		\ifdefvoid{\curr@label}{}{%
			%\def\@currentlabel{\curr@item}%
			\label{cor:\cpge@problem@id:\curr@label}%
		}%
	}%
	\endgroup
}
\def\print@cor@score{%
	\ifscore%
		\llap{\smash{\hb@xt@\Gm@littlemargin{\@xp\hss\@xp\deco@quesscore\@xp{\@xp\cpge@tab@score\@xp{\curr@score}}}\hss}}%
		\global\let\show@quesscore\relax%
	\fi}
\NewDocumentCommand\xzapsol{o}{%
	\IfValueF{#1}{\@xp\tmp@queslist@pop\@xp{\queslist}}
	\IfValueT{#1}{%
		\ifnum#1>\z@
			\@xp\tmp@queslist@pop\@xp{\queslist}%
			\edef\cpge@tempa{\@nx\xzapsol[\number\numexpr#1-1]}
			\@xp\cpge@tempa
		\fi
		}
	}	
\def\outer@sol@deco#1{%
	\show@quesscore%
	\set@linkcol%
	\Hy@raisedlink{\hypertarget{hysol:\cpge@problem@id:#1}{}}%
	\hyperlink{hyeno:\cpge@problem@id:#1}{\deco@link@sol{\curr@deco{#1}}}%
}
\unless\ifdraft
	\tikzset{soldeco/.style={}}
\fi%
\cpgesetdeco{link@sol}
	{\listbox[soldeco, collink, text width=\csuse{\cpge@problem@id @maxlabelwidth}, align=left]{#1}}




%%%% Markup des questions par défaut  %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% styles des compteurs par défaut 
\def\setup@enumstyle{%
	\cpgesetlabel{enumi}{|X|.|1|}
	\cpgesetlabel{enumii}{|X|.|Q|.|1|}
	\cpgesetlabel{enumiii}{|X|.|Q|.|q|.|1|}
	\cpgesetdeco{enumi}{\bfseries##1.}
	\cpgesetdeco{enumii}{\bfseries##1.}
	\cpgesetdeco{enumiii}{\bfseries##1.}
	\unless\ifdraft
		\unless\ifprint 
			\cpgesetdeco{enumi}{\bfseries##1}
			\cpgesetdeco{enumii}{\bfseries##1}
			\cpgesetdeco{enumiii}{\bfseries##1}
		\fi 
	\fi
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

%%%% Décoration du label pour mini
\ifcompact
	\cpgesetup[mini]{left margin=\z@, 
		font=\sffamily\footnotesize, 
		label font=\scshape\bfseries\footnotesize}
\else
	\cpgesetup[mini]{left margin=30pt,
	font=\sffamily\small, 
	label font=\scshape\bfseries\small
	}
\fi
%%% environnement mini
\ifdraft
\cpgesetup[mini]{%
	deco=#1.\kern1ex
}
\else
\def\miniarrow#1{\textcolor{#1}{\xaltarrow}}
\cpgesetup[mini]{%
	deco=\llap{\miniarrow{cpgeneutral}}%
		\textcolor{cpgeneutral}{#1.}\kern1ex%
}
\fi

%%%%%%%% Environnements basique pour théorèmes et Cie
\RequirePackage{amsthm}
\newdimen\thmboxheight
\newdimen\thmboxdepth
\newdimen\thmboxwidth
\newbox\cpge@thmbox
%%% Patch des commandes de base de amsthm pour qu'elles
%%% prennent en charge les labels à la cpgekit et la commande \unite
\patchcmd\@thm{the#2}{label#2}{}{}
%\patchcmd\@begintheorem{\ignorespaces}{\set@defaultforlistsinsideunite\ignorespaces}{}{}
%\preto\@endtheorem{\closeunite}{}{}
%%% Fin des patch
\unless\ifdraft
	\cpgesetup[theorem]{%
		frame style/.code=\appto\thm@frame@style{,background={#1}},%
		frame borderlines/.code=\appto\thm@frame@style{,#1},%
		outer xsep/.code=\appto\thm@frame@style{,outer frame xsep=#1}
								 \dimdef\outer@border@xsep{#1},
		outer ysep/.code=\appto\thm@frame@style{,outer frame ysep=#1}
								 \dimdef\outer@border@ysep{#1},
		outer sep/.style={outer xsep=#1, outer ysep=#1},
		inner xsep/.code=\dimdef\inner@border@xsep{#1},
		inner ysep/.code=\dimdef\inner@border@ysep{#1},
		inner sep/.style={inner xsep=#1, inner ysep=#1},
		inner sep/.default=10pt, inner sep,%
		title style/.store in=\thm@title@style,%
		title style*/.code=\let\thm@title@overlay\relax\def\thm@title@style{#1},%
		title style+/.code=\appto\thm@title@style{,#1},%
		title sep/.code=\dimdef\head@sep{#1},%
		title sep/.default=5pt, title sep,%
		title overlay/.store in=\thm@title@overlay
	}
	\tikzset{%
		none/.style={draw=none,fill=none,text=textcol},%
		background/.style={framed, background rectangle/.style={#1}},%
		t/.style={background top/.style={#1}, show background top},%
		t/.default=draw,
		b/.style={background bottom/.style={#1}, show background bottom},%
		b/.default=draw,
		l/.style={background left/.style={#1}, show background left},%
		l/.default=draw,
		r/.style={background right/.style={#1}, show background right},%
		r/.default=draw,
		frame border sep/.style = {inner xsep=\inner@border@xsep,inner ysep=\inner@border@ysep},%
		title sep/.style = {inner ysep=2pt, inner xsep=\head@sep},%
	}
	\def\thm@frame@style{background={draw, rounded corners=3pt}}
	\def\thm@title@style{fill=backcol}
	\dimdef\outer@border@xsep{0pt}
	\dimdef\outer@border@ysep{0pt}
\fi%
\ifdraft
	\long\def\xframe@deco#1{%
			\trivlist\item[]\fboxep=6pt
				\fbox{\parbox{\textwidth-12.8pt}{\cpge@footnote@restore #1}}
			\endtrivlist%
			\aftergroup\cpge@footnote@restore%
	}
	\def\thmhead@deco#1{\fboxsep\z@\colorbox{pagecol}{\kern\head@sep#1\kern\head@sep}}
\else%
	\long\def\xframe@deco#1{%
		\@xp\tikzpicture\@xp[\thm@frame@style]
			\ifblank{#1}
				{\node [frame border sep] {};}
				{\node (frame) [frame border sep, text width=\textwidth-\thmboxwidth] {\cpge@footnote@restore #1};}
		\endtikzpicture%
		\aftergroup\cpge@footnote@use%
	}
	\def\thmhead@deco#1{%
		\begin{tikzpicture} [baseline, anchor=base] 
			\@xp\node\@xp[\thm@title@style, title sep] (title) {#1};
			\thm@title@overlay
		\end{tikzpicture}%
	}
\fi
\let\thm@title@overlay\relax
\cpgesetup[theorem]{%
	label/.code = \if@staratend{\cpge@thmcounter}
					{\cpgesetlabel*{\x@arg}{#1}}
					{\cpgesetlabel*{\x@arg}{#1}},%
	theo label/.code=\cpgesetlabel{theo}{#1},%
	prop label/.code=\cpgesetlabel{prop}{#1},%
	lemm label/.code=\cpgesetlabel{lemm}{#1},%
	defi label/.code=\cpgesetlabel{defi}{#1},
	body font/.code=\def\cpge@bodyfont{#1},
	body font=\upshape\mdseries,
	title font/.code=\def\cpge@headfont{#1},
	title font=\bfseries\scshape,
	note style/.code=\def\thm@notestyle##1{#1},
	note style={\textit{(#1)}},
	beforeskip/.code=\dimdef\thm@beforeskip{#1},
	beforeskip=6pt,
	afterskip/.code=\dimdef\thm@afterskip{#1},
	afterskip=3pt, 
	raise title/.code=\dimdef\raise@title{#1},
	raise title=\z@,
	common options/.code=\pgfkeysalso{#1},
	common options/.default={},
}
\newtheoremstyle{cpgecustom}
	{\thm@beforeskip} 	% space above
	{\thm@afterskip} 	% space below
	{\ifdef\cpge@thmcounter{\cpge@bodyfont}{\itshape}} 	% body font
	{-\head@sep} 					% indent amount 
	{\cpge@headfont\strut}	% title font
	{\ifdef\cpge@thmcounter{\newline}{~:}}					% punct
	{\z@}				% space after head
	{%
		\ifdef\cpge@thmcounter%
			{\thmhead@deco{\thmname{#1}\thmnumber{ #2}\thmnote{ \thm@notestyle{#3}}}}%
			{\thmname{#1}\thmnumber{ #2}\thmnote{ \thm@notestyle{#3}}}%
	}					% head specs
\theoremstyle{cpgecustom}
\newtheorem{theodef}{Th\'eor\`eme et d\'efinition}[problem]
\newtheorem*{theodef*}{Th\'eor\`eme et d\'efinition}
%%%%
\theoremstyle{remark}
\newtheorem{rema}{Remarque}[problem]
\newtheorem*{rema*}{Remarque}
\newtheorem{voca}{Vocabulaire}[problem]
\newtheorem*{voca*}{Vocabulaire}

%%%% Frame générique pour théorème et similaire
%%%% Reglages du theorème preeatblit dans une \trivlist externe 
%%%% car le contenu est mis dans une \parbox qui annule ses reglages. 

\NewDocumentEnvironment{xframe}{ >{\TrimSpaces}e{\op} d() d<> +b}{%
	\IfValueT{#1}{\cpgesetup[theorem]{#1}}%
	\setbox\cpge@thmbox\hbox{\xframe@deco{}}%
	\thmboxheight\ht\cpge@thmbox\relax%
	\thmboxdepth\dp\cpge@thmbox\relax%
	\thmboxwidth\wd\cpge@thmbox\relax%
	\ifundef\cpge@thmcounter
		{\trivlist\item[]\leavevmode\xframe@deco{#4}\endtrivlist}
		{%
			\trivlist%
			\thm@headsep 5\p@ plus\p@ minus\p@\relax%
			\thm@space@setup%
			\th@cpgecustom% 
			\@topsep\dimexpr\thm@beforeskip+\raise@title\relax%            
			\@topsepadd\thm@postskip% 
			\item[]\vrule height\z@ width\linewidth\linebreak%
			\setbox\cpge@thmbox\hbox{\thmhead@deco{\cpge@thmname}}%
			\xframe@deco{%
				\IfValueTF{#2}
					{\IfValueTF{#3}
						{\csname\cpge@thmcounter\endcsname[#2]\relax\label{\cpge@labelprefix#3}}
						{\csname\cpge@thmcounter\endcsname[#2]\relax}}
					{\IfValueTF{#3}
						{\csname\cpge@thmcounter\endcsname\relax\label{\cpge@labelprefix#3}}
						{\csname\cpge@thmcounter\endcsname\relax}}%
					\vspace*{\dimexpr-\thmboxheight-.5\ht\cpge@thmbox-.5\dp\cpge@thmbox-\raise@title\ifdim\dimexpr\outer@border@ysep>\z@+\outer@border@ysep\fi\relax}%
					\leavevmode%
					\vskip\dimexpr\inner@border@ysep-\baselineskip\relax%
						#4
				\@endtheorem%
			}%
			\endtrivlist%
		}%
}{}
\NewDocumentCommand\cpgenewtheorem{ mmm O{} }{%
	\ifcsundef{#1}{
		\theoremstyle{cpgecustom}
		\newtheorem{#1}{#2}[problem]
		\newtheorem*{#1*}{#2}
	}{}
	\csdef{#1autorefname}{#3}
	\cpgesetup[theorem]{
		#1 options/.code=\pgfkeysalso{##1},
		#1 options/.default={#4}
	}
	\@xp\NewDocumentCommand\csname x#1\endcsname{E{\op}{{}}}
		{\def\cpge@thmcounter{#1}\def\cpge@thmname{#2}\xframe\op{common options,#1 options,##1}}
	\@xp\NewDocumentCommand\csname x#1*\endcsname{E{\op}{{}}}
		{\def\cpge@thmcounter{#1*}\def\cpge@thmname{#2}\xframe\op{common options,#1 options,##1}}
	\cslet{endx#1}\endxframe
	\cslet{endx#1*}\endxframe
}
\cpgenewtheorem{theo}{Théorème}{théorème}
\cpgenewtheorem{prop}{Proposition}{proposition}
\cpgenewtheorem{ppte}{Propriété}{propriété}
\cpgenewtheorem{lemm}{Lemme}{lemme}
\cpgenewtheorem{obje}{Objectif}{objectif}
\cpgenewtheorem{defi}{Définition}{définition}
\cpgenewtheorem{voca}{Vocabulaire}{vocabulaire}
\cpgenewtheorem{rema}{Remarque}{remarque}

\cpgesetlabel{theo}{|1|}
\cpgesetlabel{prop}{|1|}
\cpgesetlabel{lemm}{|1|}
\cpgesetlabel{defi}{|1|}
\cpgesetlabel{rema}{|1|}


%%%% Différents réglages
\newcommand\cpgehypersetup[2]{
	\ifcsdef{cpge@#2}{\hypersetup{pdf#1=\csuse{cpge@#2}}}{}
}
\appto\endpreamble@hook{%
	\ifdef{\hypersetup}{
		\cpgehypersetup{title}{document}
		\cpgehypersetup{subject}{theme}
		\cpgehypersetup{author}{auteur}
		\hypersetup{pdfcreator=LaTeX with cpgekit}
	}{}}
\cpgesetup[background]{%
	position = tb,
	code = {\tikz[overlay]\draw[rounded corners=10pt] 
	(-\Gm@littlemargin-20pt,-\footskip+10pt) rectangle 
	(\textwidth+28pt,\textheight+\headsep-4pt);}
}

\endinput



