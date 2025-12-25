\def\filedate{2024/04/10}
\def\fileversion{v0.1alpha}
\def\fileauthor{Sadik Boujaida}

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{cpgenote}[\filedate\space\fileversion]
\RequirePackage{pgfopts} %Pour la gestion des options de la classe
\RequirePackage{etoolbox}
\RequirePackage{cpgebase}
\RequirePackage{pgfpages}
\RequirePackage{eso-pic}
\def\cpgecurrentclass{note} 

\@ifundefined{ifsubdoc}{%
	\newif\ifweb
	\newif\ifdraft
	\newif\ifprint
	\newif\ifnocolors
	\newif\ifdark
	\newif\ifcompact
	\newif\ifstriptitle
	\newif\ifserie
}{}

\newif\ifcolle
\newif\ifnote
\newif\ifsuivi
\newif\ifnomarks
\newif\ifincluded
\newbox\backbox


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
	note/.code=\notetrue\collefalse,
	colle/.code=\colletrue\notefalse,
	suivi/.code=\colletrue\suivitrue\notefalse,
	nomarks/.code=\colletrue\nomarkstrue, 
	draft/.is if=draft,	
	compact/.is if=compact,
	dark/.is if=dark,
	nocolors/.is if=nocolors, 
	.search also=/IGD
}
\pgfkeys{/IGD/.unknown/.code=%
	{\csveadd\class@options{\pgfkeyscurrentname}}
}
%

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
   \hma=\Gm@rmargin\relax%
   \parindent\z@
   \ifsuivi
      \tma=\bigskipamount 
   \else 
      \tma=\headsep \bma=\footskip
   \fi
}

%%%% Pages virtuelles pour impression sur A4
\pgfpagesdeclarelayout{colle on a4}
{
  \edef\pgfpageoptionheight{\the\paperwidth} % landscaped by default
  \edef\pgfpageoptionwidth{\the\paperheight}
  \def\pgfpageoptionborder{0pt}
  \def\pgfpageoptionfirstshipout{1}
}
{
  \pgfpagesphysicalpageoptions
  {%
    logical pages=2,%
    physical height=\pgfpageoptionheight,%
    physical width=\pgfpageoptionwidth,%
    current logical shipout=\pgfpageoptionfirstshipout%
  }
  \ifdim\paperheight>\paperwidth\relax
    % put side-by-side
    \pgfpageslogicalpageoptions{1}
    {%
      border shrink=\pgfpageoptionborder,%
      resized width=.48\pgfphysicalwidth,%
      resized height=.96\pgfphysicalheight,%
      center=\pgfpoint{.25\pgfphysicalwidth}{.5\pgfphysicalheight}%
    }%
    \pgfpageslogicalpageoptions{2}
    {%
      border shrink=\pgfpageoptionborder,%
      resized width=.48\pgfphysicalwidth,%
      resized height=.96\pgfphysicalheight,%
      center=\pgfpoint{.75\pgfphysicalwidth}{.5\pgfphysicalheight}%
    }%
  \else
    % stack on top of one another
    \pgfpageslogicalpageoptions{1}
    {%
      border shrink=\pgfpageoptionborder,%
      resized width=\pgfphysicalwidth,%
      resized height=.5\pgfphysicalheight,%
      center=\pgfpoint{.5\pgfphysicalwidth}{.75\pgfphysicalheight}%
    }%
    \pgfpageslogicalpageoptions{2}
    {%
      border shrink=\pgfpageoptionborder,%
      resized width=\pgfphysicalwidth,%
      resized height=.5\pgfphysicalheight,%
      center=\pgfpoint{.5\pgfphysicalwidth}{.25\pgfphysicalheight}%
    }%
  \fi    
}
% \geometry{
%     paperwidth=135mm, paperheight=240mm,
% 		hmargin=\hma,
% 		vmargin={\tma,\bma},
% 		headsep=.5\tma,
% 		marginparsep=\mps,
% 		marginparwidth=\mpw}

\AtEndPreamble{
\ifprint
    \pgfpagesuselayout{colle on a4}[
    	a4paper,
    	landscape,
    	]
    \nofiles
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
\cpgedefcounter{cycle}{|1|}
\cpgedefcounter{sheet}{|1|}[cycle] 
\cpgedefcounter{problem}{|1|}[sheet](Y)
\cpgedefcounter{exercice}{|1|}[sheet]
\cpgedefcounter{mcours}{|1|}[sheet]
\ifsuivi 
    \titleclass{\cycle}[0]{top}
    \titleclass{\sheet}{straight}[\cycle]
    \titleclass{\problem}{straight}[\sheet] % -> {question de cours}, {exercise}, ...
    \titleformat\cycle[display]
      {\Huge\filcenter\vfill}
      {\color{titletextcol}\cycle@label}
      {\z@}
      {\bfseries #1}
      [\vfill\clearpage]
   \titlespacing*\cycle{\z@}{*1}{*1}
   \titleformat\sheet[hang]
      {\Large}
      {\color{buttonstrokecol}\csuse{deco@sheet}{\label@sheet}}
      {.5em}
      {#1\color{titlestrokecol}\hfill\deco@topbutton{\studentname}}
   \titlespacing*\sheet{\z@}{*1}{*1}
   \ttl@setifthe{cycle}
\else 
   \titleclass{\sheet}[0]{top} % -> \devoir 
   \titleclass{\problem}{straight}[\sheet] % -> {question de cours}, {exercise}, ...
   \titleformat\sheet[display]{\Large\bfseries\filcenter}
      {\cpge@presheettitle%
         \larger\color{buttonstrokecol}
         \csuse{deco@sheet}{\label@sheet}
         \ifundef\cpge@cycle{}{\smaller/\cpge@cycle}
      }
      {-.25\baselineskip}{#1}
   \titlespacing*\sheet{\z@}{.5\tma}{*2}
\fi 
\titleformat\problem[hang]{\large\color{titletextcol}}{\csuse{deco@problem}{\problem@label}}{.5em}{#1}
\titlespacing*\problem{\z@}{*1}{*1}
\ifcolle
	\def\cpge@presheettitle{
		\deco@pretitle{%
			{\scshape\mdseries \cpge@document@format \\ \cpge@periode@format}\\[\medskipamount]
		}
	}
\else 
	\let\cpge@presheettitle\relax
\fi
\let\deco@pretitle\@firstofone

\cpgedefcounter{partie}{|1|}[problem]
\titleclass{\partie}{straight}[\problem]
\titleformat\partie[hang]
	{\large\scshape}
	{\color{titlestrokecol}\csuse{deco@partie}{\label@partie}}
	{.5em}
	{\color{titletextcol}#1}
\titlespacing*\partie{\z@}{*1}{*1}
\cpgesetdeco{partie}{#1.}

\let\cycletitle\relax
\let\sheettitle\relax
\let\problemtitle\relax 
\let\partietitle\relax
\let\ttl@savemark\relax
\ifsuivi
   \def\toclevel@cycle{0}
   \def\toclevel@sheet{1}
   \def\toclevel@problem{2}
   \def\toclevel@partie{3}
\else 
   \def\toclevel@sheet{0}
   \def\toclevel@problem{1}
   \def\toclevel@partie{2}
\fi 
\ttl@setifthe{sheet}
\ttl@setifthe{problem}
\ttl@setifthe{partie}

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
\def\cyclenumber#1{%
  \ifnum#1<10\relax0#1\else#1\fi%
}
\let\sheetname\relax 
\cpgesetdeco{sheet}{\sheetname\space #1}
\ifsuivi
   \NewDocumentCommand\session{mmD(){}}{%
      \gdef\cycle@number{#2}
      \listxadd\cyclelist{#2}
      \xdef\cpge@cycle{\cyclenumber{#2}}
      \xdef\cycle@label{#1~\cpge@cycle}
      \set@currentschedule{schedule@#2}
      \def\cycle@theme{#3}
      \cycle{#3}
    }
    \NewDocumentEnvironment{fiche}{mmD(){}}{%
		\def\sheetname{#1}
       	\global\let\print@mark\relax%
       	\global\let\studentname\relax%
       	\set@studentid{#2}%
       	\sheet{#3}%
   }{\ifundef\print@mark{}{\csuse{deco@mark}{\print@mark}}}
\else
    \NewDocumentCommand\session{mmD(){}}{%
      \gdef\cycle@number{#2}
      \xdef\cpge@cycle{\cyclenumber{#2}}
      \xdef\cycle@label{#1~\cpge@cycle}
      \set@currentschedule{schedule@#2}
      \def\cycle@theme{#3}
      \setcounter{sheet}{0}
    }
    \NewDocumentEnvironment{fiche}{mmD(){\csuse{cycle@theme}}}{%
	  \def\sheetname{#1}
      \global\let\print@mark\relax%
      \global\let\studentname\relax%
      \sheet{#3}%
      \set@studentid{#2}%
   }{
      \ifundef\studentname
         {\global\let\topbutton@deco\relax}
         {\xdef\topbutton@deco{\noexpand\deco@topbutton{\studentname}}}
      \ifundef\print@mark
         {\global\let\bottombutton@deco\relax}
         {\xdef\bottombutton@deco{\noexpand\deco@bottombutton{\print@mark}}}
   }
\fi 

\def\semaine{\session{Semaine}}
\def\colle{\fiche{Planche de colle}}
\let\endcolle\endfiche

\NewDocumentCommand\theme{mD(){}}{%
	\gdef\cycle@number{#1}
	\xdef\cpge@cycle{\cyclenumber{#1}}
	\xdef\cycle@label{Semaine~\cpge@cycle}
	\def\cycle@theme{#2}
	\setcounter{sheet}{0}
	}
\def\current@notepage{
	(\the\numexpr\c@page-\current@page+1\relax/\note@pagenumber)
	}
\def\notename{\csuse{deco@sheet}{\note@number}}
\NewDocumentEnvironment{note}{mD(){}}{%
	\setcounter{equation}{0}%
	\def\sheetname{Thème}
	\gdef\note@number{#1}%
	\setcounter{sheet}{\numexpr\note@number-1}%
	\sheet{#2}%
	\ifdefvoid\note@number{\xdef\note@number{\label@sheet}}{}%
	\numgdef\current@page{\c@page}%
	\numgdef\note@pagenumber{\csuse{lastnotepage@\note@number}-\current@page+1}%
	\xdef\topbutton@deco{\noexpand\deco@topbutton{\notename\space\noexpand\current@notepage}}%
	\xdef\bottombutton@deco{\noexpand\deco@bottombutton{\cpge@classe}}%
}{
	\immediate\write\@auxout{\string\lastnotepage{\note@number}{\the\c@page}}%
}
\def\lastnotepage#1#2{\csgdef{lastnotepage@#1}{#2}}



\cpgesetdeco{topbutton}{{\large\scshape\bfseries\color{titletextcol}#1}}
\cpgesetdeco{bottombutton}{\par\nobreak\hfill
   {\scshape\large\bfseries note : \textcolor{titletextcol}{#1}\smaller[2]/20\par}
   \vspace*{3pt}\color{titlestrokecol}\hrule}
%%% Gestion des élèves
%%% acquisition de la liste des élèves et des semaines
\cpgesetup[students]{
   .unknown/.code n args={3}{
   \listxadd\studentlist{\pgfkeyscurrentname}
   \csvcsxadd{group@#3}{\pgfkeyscurrentname}
   \csgdef{student@name@\pgfkeyscurrentname}{#1}
   \csgdef{student@firstname@\pgfkeyscurrentname}{#2}
  }
}
\def\csvnames{
	\def\do##1{\tcbrecord{\csuse{student@name@##1} \csuse{student@firstname@##1}}}
	\dolistloop\studentlist
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
\def\set@studentid#1{
   \ifblank{#1}
      {\pop@schedule}
      {\ifstrequal{#1}{*}{}{\dig@schedule{#1}\setup@student}}
}
\def\for@sched#1{\def\studentid{#1}\listbreak}
\def\pop@schedule{%
   \ifdefvoid{\currentschedule}
      {}
      {
         \forlistloop\for@sched\currentschedule
         \expandafter\listgremove\expandafter\currentschedule
            \expandafter{\studentid}
         \setup@student%
      }%
}
\def\dig@schedule#1#2{
   \ifdefvoid\currentschedule
      {
        \dig@mainlist{#1}{#2}
      }{
         \ifinlist{#1}{\currentschedule}
            {\def\studentid{#1}\listgremove\currentschedule{#1}#2}
            {\dig@mainlist{#1}{#2}}
      }
}
\def\dig@mainlist#1#2{
   \ifinlist{#1}\studentlist
      {\def\studentid{#1}#2}
      {\def\studentid{#1}\gdef\studentname{#1}}
}
\def\setup@student{
    \edef\cpge@name{\csuse{student@name@\studentid}}
    \edef\cpge@firstname{\csuse{student@firstname@\studentid}}
    \xdef\studentname{\cpge@name\ \cpge@firstname}
}
\let\studentid\relax
%%
\ifsuivi 
    \NewDocumentEnvironment{evaluation}{+b}
      {\unless\ifnomarks\mini{Évaluation}\mbox{}\par#1\fi}
      {
         \unless\ifnomarks\endmini\fi%
      } 
\else 
   \NewDocumentEnvironment{evaluation}{+b}
      {\unless\ifnomarks\null\vfill\mini{Évaluation}\mbox{}\par#1\fi}
      {\unless\ifnomarks\endmini\fi} 
\fi 
\def\Competence{\par\medskip%
   \textsc{\bfseries\color{titlestrokecol} Compétences générales : }%
}
\def\Prestation{\par\smallskip 
   \textsc{\bfseries\color{titlestrokecol} Prestation : }%
}
\def\Note#1{%
   \par%
   \unless\ifnomarks%
      \gdef\student@mark{#1}%
	  \gdef\print@mark{{note : \textcolor{buttonstrokecol}{#1}/20}}
      \csvcsxadd{cyclemarks@\cycle@number}{(\studentname,\student@mark)}
	  %\csvcsxadd{studentmarks@\studentid}{(\cycle@number,\student@mark)}
   \fi%
}
\def\MC{\par\textsc{\bfseries mc~:~}}
\def\EX{\par\textsc{\bfseries ex~:~}}

 
%%%
\ifcolle
	\def\notefilename{planches}
\else 
	\def\notefilename{notes}
\fi
\def\notefiledir{Semaine}
\DeclareDocumentCommand\cpgeinclude{om}{%%
	\begingroup%
	\includedtrue%
    \undef\cycle@number%
   \IfFileExists{\notefiledir#2/\notefilename.tex}
      {\subdoc{\notefiledir#2/\notefilename}}
	   {\IfFileExists{#2/\notefilename.tex}
			{\subdoc{#2/\notefilename}}
         	{\IfFileExists{#2.tex}
				{\subdoc{#2}}
				{\ClassError{cpgenote}{Aucun fichier #2 trouvé}{}}
			}
      	}
    \ifsuivi
         \ifcsundef{cyclemarks@\cycle@number}{}
            {%
				\immediate\write\@auxout{\string\cyclemarks{\cycle@number}{\csuse{cyclemarks@\cycle@number}}}
			}
      \fi
	\endgroup%
}

\def\cyclemarks#1#2{
	\cpgerecord{%
		Semaine #1 : #2 \string\newline
	}
}
\AtBeginDocument{%
	\ifsuivi
		\InputIfFileExists{\jobname.rec}{\eject}{}
		\cpgestartrecording
	\fi
}
\AfterEndDocument{%
	\ifsuivi
		\cpgestoprecording
	\fi
}
\def\do@student@marks{}

%%% Background deco and 
\let\topbutton@deco\relax
\let\bottombutton@deco\relax
\setbox\backbox\hbox{}
\AtBeginDocument{
   \AddToShipoutPictureBG{%
      \AtPageLowerLeft{\copy\backbox}
   }%
   \AddToShipoutPictureFG{%
      \AtPageUpperLeft{\topbutton@deco}
      \AtPageLowerLeft{\bottombutton@deco}
   }%
}

%%%%%%%% Environnements basique pour théorèmes et similaire
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
\dimdef\inner@border@xsep{0pt}
\dimdef\inner@border@ysep{0pt}
\dimdef\outer@border@xsep{0pt}
\dimdef\outer@border@ysep{0pt}
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
\fi%

\ifdraft
	\dimdef\head@sep{5pt}
	\long\def\xframe@deco#1{%
			%\trivlist\item[]\fboxsep=6pt
				\fbox{\parbox{\textwidth-12.8pt}{\cpge@footnote@restore #1}}
			%\endtrivlist%
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
\cpgenewtheorem{algo}{Algorithme}{algorithme}
\cpgenewtheorem{exer}{Exercice}{exercice}


\cpgesetlabel{theo}{|1|}
\cpgesetlabel{prop}{|1|}
\cpgesetlabel{lemm}{|1|}
\cpgesetlabel{defi}{|1|}
\cpgesetlabel{rema}{|1|}
\cpgesetlabel{algo}{|1|}
\cpgesetlabel{exer}{|1|}

%%% Styles des numérotation 
\def\numcol{\color{titlestrokecol}}
\def\setup@enumstyle{%
	\cpgesetlabel{enumi}{|1|}
	\cpgesetlabel{enumii}{|Q|.|1|}
	\cpgesetlabel{enumiii}{|Q|.|q|.|1|}
	\cpgesetdeco{enumi}{\numcol\bfseries##1.}
	\cpgesetdeco{enumii}{\numcol\bfseries##1.}
	\cpgesetdeco{enumiii}{\numcol\bfseries##1.}
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
\ifsuivi
	\def\endpreamble@hook{}
\else 
	\def\endpreamble@hook{\pagestyle{void}}
\fi 

\AfterEndDocument{

}

%%% Lecture du fichier csv
\csvset{every csv/.style={no head}}
\def\wbf{\color{white}\bfseries\scshape}
\def\tablesuivi{
\IfFileExists{\jobname.csv}
    {\csvreader[%
        table head=%
            \rowcolor{colone}
            & \strut \wbf name et pr\'ename & \wbf Date & \wbf Note\\
            \hline,
        tabular=r|>{\scshape}lcp{.5\linewidth-1cm},
        late after line=%
          \csvifoddrow{\\ }{\\ \rowcolor{coltwo!75}},
        late after last line=\\ \hline,
        before reading=\inputencoding{latin1},
        after reading=\inputencoding{utf8}
      ]{\jobname.csv}
        {1=\name,2=\firstname,3=\Date,4=\AVIS}
        {\thecsvrow &
          \hyperlink{\firstname\name}{\name~\firstname} & \Date & \AVIS}
    }	
    {}
}
\ifsuivi
   \AtBeginDocument{
      \tcbstartrecording[\jobname.csv]

   }
\fi

\endinput 