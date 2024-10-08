\def\filedate{2024/04/10}
\def\fileversion{v0.1alpha}
\def\fileauthor{Sadik Boujaida}

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{cpgecol}[\filedate\space\fileversion]
\RequirePackage{pgfopts} %Pour la gestion des options de la classe
\RequirePackage{etoolbox}
\RequirePackage{cpgebase}
\def\cpgecurrentclass{col} 

\@ifundefined{ifsubdoc}{%
	\newif\ifweb
	\newif\ifsingleimage
	\newif\ifdraft
	\newif\ifprint
	\newif\ifnocolors
	\newif\ifdark
	\newif\ifcompact
	\newif\ifstriptitle
}{}

\newif\ifconvert
\newif\ifsuivi
\newif\ifnomarks

\let\class@options\relax
\pgfkeys{/IGD/.is family, /IGD/.cd,
	article/.code={\def\cpge@class{article}},
	report/.code={\def\cpge@class{report}},
	book/.code={\def\cpge@class{book}\cspreto\class@options{oneside,}},
	draft/.style={},
	compact/.style={},
	dark/.style={},
	nocolors/.style={},
	web/.style={},
	convert/.style={},
}
\pgfkeys{/IGDC/.is family, /IGDC/.cd,
   suivi/.is if=suivi,
   nomarks/.is if=nomarks, 
	draft/.is if=draft,	
	compact/.is if=compact,
	dark/.is if=dark,
	nocolors/.is if=nocolors, 
	web/.code=\compacttrue\webtrue%
		\ifundef\convert@option{\def\convert@options{}}{}
		\def\cpgecomment@list{#1},
	web/.default={planche},
	convert/.code=\appto\convert@options{,#1},
	singleimage/.is if=singleimage,
	.search also=/IGD
}
\pgfkeys{/IGD/.unknown/.code=%
	{\csveadd\class@options{\pgfkeyscurrentname}}
}
%
\def\cpge@mkdir#1{%
	\IfFileExists{/dev/null}
		{\immediate\write18{mkdir -p #1}}
		{\immediate\write18{md  "#1"}}%
}
\def\cpge@class{article}
\ifundef\ifsubdoc
	{\ProcessPgfOptions{/IGDC}}
	{\ProcessPgfOptions{/IGD}}

\let\@xp\expandafter
\let\@nx\noexpand
\let\@xo\expandonce
\begingroup
\edef\cpge@tmp{\endgroup
	\@nx\LoadClass[\class@options]{\cpge@class}
}
\cpge@tmp


\newdimen\hma
\newdimen\tma 
\newdimen\bma
\AtBeginDocument{%
   \hma=\Gm@rmargin
   \ifsuivi
      \tma=\bigskipamount 
   \else 
      \tma=-\headsep \bma=\footskip
   \fi
}

%%%%% Packages du projet 
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
\RequirePackage{csvsimple}
\cpgeloadpackage[shapes.misc]{tikz}
\cpgeloadpackage[skins]{tcolorbox}

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
\cpgedefcounter{week}{|1|}
\cpgedefcounter{sheet}{|1|}
\cpgedefcounter{problem}{|1|}[sheet](Y)
\cpgedefcounter{exercice}{|1|}[sheet]
\cpgedefcounter{mcours}{|1|}[sheet]
\cpgesetdeco{sheet}{Planche #1}
\ifsuivi 
    \titleclass{\week}[0]{top}
    \titleclass{\sheet}{straight}[\week]
    \titleclass{\problem}{straight}[\sheet] % -> {question de cours}, {exercise}, ...
    \titleformat\week[display]
      {\Huge\filcenter\vfill}
      {\color{titletextcol}\semaine@label}
      {\z@}
      {\bfseries #1}
      [\vfill\clearpage]
    \titlespacing*\week{\z@}{*1}{*1}
    \ttl@setifthe{week}
\else 
    \titleclass{\sheet}[0]{top} % -> \devoir 
    \titleclass{\problem}{straight}[\sheet] % -> {question de cours}, {exercise}, ...
\fi 
\titleformat\sheet[display]{\Large\bfseries\filcenter}
   {\unless\ifsuivi{\cpge@pretitle}\\[\medskipamount]\fi
      \larger\color{titlestrokecol}
      \csuse{deco@sheet}{\label@sheet}
      \ifundef\cpge@semaine{}{\smaller/\cpge@semaine}
   }
   {-.25\baselineskip}{#1}
\titleformat\problem[hang]{\large\color{titletextcol}}{\csuse{deco@problem}{\problem@label}}{.5em}{#1}
\titlespacing*\sheet{\z@}{.5\tma}{*2}
\titlespacing*\problem{\z@}{*1}{*1}
\def\cpge@pretitle{
   \deco@pretitle{%
      \scshape\mdseries%
      {\smaller[2] Classe \cpge@classe} \\[-.25\baselineskip] 
      \itshape \cpge@document@format 
   }
}
\let\deco@pretitle\@firstofone

\let\weektitle\relax
\let\sheettitle\relax
\let\problemtitle\relax 
\let\ttl@savemark\relax
\ifsuivi
   \def\toclevel@week{0}
   \def\toclevel@sheet{1}
   \def\toclevel@problem{2}
\else 
   \def\toclevel@sheet{0}
   \def\toclevel@problem{1}
\fi 
\ttl@setifthe{sheet}
\ttl@setifthe{problem}

\NewDocumentCommand\mcours{sD(){}}{
    \stepcounter{mcours}
    \def\problem@label{Maîtrise du cours}
    \problem{#2}
}
\NewDocumentCommand\exercice{sD(){}}{
    \IfBooleanTF{#1}
        {\def\problem@label{Exercice}}
        {\stepcounter{exercice}\edef\problem@label{Exercice \label@exercice}}
    \problem{#2}
}
\def\weeknumber#1{%
  \ifnum#1<10\relax0#1\else#1\fi%
}
\ifsuivi
    \NewDocumentCommand\semaine{mD(){}}{%
        \xdef\cpge@semaine{\weeknumber{#1}}
        \xdef\semaine@label{Semaine~\cpge@semaine}
        \set@currentschedule{schedule@#1}
        \def\week@theme{#2}
        \week{#2}
    }
\else
    \NewDocumentCommand\semaine{mD(){}}{%
        \xdef\cpge@semaine{\weeknumber{#1}}
        \xdef\semaine@label{Semaine~\cpge@semaine}
        \set@currentschedule{schedule@#1}
        \def\week@theme{#2}
    }
\fi 
\NewDocumentEnvironment{planche}{mD(){\csuse{week@theme}}}{%
    \set@studentid{#1}%
    \sheet{#2}%
    \ifundef\studentname{}{\deco@student{\studentname}}%
}{}
\cpgesetdeco{student}{{\large\scshape Élève : \color{titletextcol}#1\par}\medskip}
%%% Gestion des élèves
%%% acquisition de la liste des élèves et des semaines
\cpgesetup[students]{
   .unknown/.code n args={3}{
   \csvxadd\studentlist{\pgfkeyscurrentname}
   \csvcsxadd{group@#3}{\pgfkeyscurrentname}
   \csgdef{student@name@\pgfkeyscurrentname}{#1}
   \csgdef{student@firstname@\pgfkeyscurrentname}{#2}
  }
}
\def\sched@for#1#2{%
   \csvcsxadd{schedule@#1}{\csname group@#2\endcsname}}
\cpgesetup[schedule]{
   .unknown/.code=
      \forcsvlist{\sched@for{\pgfkeyscurrentname}}{#1}
}
\def\setstudents{\pgfqkeys{/cpge/students}}
\def\setschedule{\pgfqkeys{/cpge/schedule}}

\def\set@currentschedule#1{%
   \undef\currentschedule%
   \begingroup
   \edef\cpge@tmp{\endgroup% 
      \noexpand\forcsvlist%
         {\noexpand\listeadd\noexpand\currentschedule}{\csname#1\endcsname}%
   }%
   \cpge@tmp%
}
\def\for@sched#1{\def\studentid{#1}\listbreak}
\def\pop@schedule{%
   \ifdefvoid{\currentschedule}{}{
   \forlistloop\for@sched\currentschedule
   \expandafter\listgremove\expandafter\currentschedule
      \expandafter{\studentid}
   \setup@student}%
}
\def\dig@schedule#1#2{
   \ifinlist{#1}{\currentschedule}
      {\def\studentid{#1}\listgremove\currentschedule{#1}#2}
      {\def\studentid{#1}\def\studentname{#1}}
}
\def\set@studentid#1{
   \ifblank{#1}
      {\pop@schedule}
      {\ifstrequal{#1}{*}{}{\dig@schedule{#1}\setup@student}}
}
\def\setup@student{
    \edef\cpge@name{\csuse{student@name@\studentid}}
    \edef\cpge@firstname{\csuse{student@firstname@\studentid}}
    \edef\studentname{\cpge@name\ \cpge@firstname}
}
\let\studentid\relax
\let\studentname\relax

%%
\ifsuivi 
    \NewDocumentEnvironment{evaluation}{+b}
      {\unless\ifnomarks\mini{Évaluation}\mbox{}\par#1\fi}
      {
         \unless\ifnomarks
            \ifundef\cpge@mark{}
               {\deco@note{\cpge@mark}}
         \endmini%
         \fi%
      } 
\else 
   \NewDocumentEnvironment{evaluation}{+b}
      {\unless\ifnomarks\null\vfill\mini{Évaluation}\mbox{}\par#1\fi}
      {
         \unless\ifnomarks
            \ifundef\cpge@mark{}
               {\deco@note{\cpge@mark}}
         \endmini%
         \fi%
      } 
\fi 
\cpgesetdeco{note}{\par\medskip{\scshape\large\bfseries\color{titletextcol}note : {#1}\smaller[2]/20}}
\def\Competence{\par\medskip%
   \textsc{\bfseries\color{titlestrokecol} Compétences générales : }%
}
\def\Prestation{\par\smallskip 
   \textsc{\bfseries\color{titlestrokecol} Prestation : }%
}
\def\Note#1{\def\cpge@mark{#1}}
\def\MC{\par\textsc{\bfseries mc~:~}}
\def\EX{\par\textsc{\bfseries ex~:~}}

 


%%% Styles des numérotation 
\def\setup@enumstyle{%
	\cpgesetlabel{enumi}{|1|}
	\cpgesetlabel{enumii}{|Q|.|1|}
	\cpgesetlabel{enumiii}{|Q|.|q|.|1|}
	\cpgesetdeco{enumi}{\bfseries##1.}
	\cpgesetdeco{enumii}{\bfseries##1.}
	\cpgesetdeco{enumiii}{\bfseries##1.}
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
\def\endpreamble@hook{\pagestyle{colle}}

%\def\exercice{Exercice \\}
%\def\mcours{Cours \\}