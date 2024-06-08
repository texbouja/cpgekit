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
	\newif\ifsoutien 
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
	web/.code=\compacttrue\webtrue\def\convert@options{}
		\def\cpgecomment@list{exer,theo,#1},
	web/.default={},
	singleimage/.is if=singleimage,
	soutien/.code={
		\soutientrue\courstrue
		\ifundef{\cpge@class}{\def\cpge@class{article}}{}
	},
	report/.code={
		\def\cpge@class{report}
	},
	book/.code={
		\def\cpge@class{book}
	},
	.search also=/IGC,
}
\pgfkeys{IGC/.is family, IGC/.cd,
	.unknown/.code={%
		\expandafter\appto\expandafter\class@options\expandafter
		{\pgfkeyscurrentname,}
	},
	convert/.code=\ifundef\cpgecomment@list{\pgfkeysalso{web}}{}\appto\convert@options{,convert={#1}},
	convert/.default=true,
	draft/.style={},
	soutien/.style={},
	compact/.style={},
	solution/.style={},
	solution*/.style={},
	proof/.style={},
	proof*/.style={},
	article/.style={},
	report/.style={},
	book/.style={},
}
\@ifundefined{ifsubdoc}
	{\ProcessPgfOptions{/IGCS}}
	{\ProcessPgfOptions{/IGC}}

\ifundef\cpge@class{\def\cpge@class{article}}{}
\ifdraft\appto\class@options{draft}\fi
\begingroup
\edef\cpge@tmpa{\endgroup%
	\noexpand\LoadClass[\class@options]{\cpge@class}
}
\cpge@tmpa
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

%%%%% Geometrie du document

\RequirePackage{geometry}
\RequirePackage{cuted}


% patch de la commande qui contrôle le format de papier
\newdimen\Gm@littlemargin
\Gm@littlemargin\z@
\dimdef\compactlimit{127mm}
\preto\Gm@adjustpaper{%
 	\ifdim\linewidth<\compactlimit\relax
 		\compacttrue%
 	\fi}

% ajout de formats, reconnaissables par la commande \goemetry
\@namedef{Gm@sc16x9}#1{\Gm@setsize{#1}(135,240){truemm}}
\@namedef{Gm@sc19x9}#1{\Gm@setsize{#1}(135,285){truemm}}
\@namedef{Gm@sc16x10}#1{\Gm@setsize{#1}(180,288){truemm}}
\@namedef{Gm@sc4x3}#1{\Gm@setsize{#1}(180,240){truemm}}
\@namedef{Gm@sc4x3b}#1{\Gm@setsize{#1}(128,96){truemm}}
%\define@key{Gm}{a4paper}[true]{\Gm@setpaper@ifpre{a4paper}}%
\define@key{Gm}{sc16x9}[true]{\Gm@setpaper@ifpre{sc16x9}}
\define@key{Gm}{sc19x9}[true]{\Gm@setpaper@ifpre{sc19x9}}
\define@key{Gm}{sc16x10}[true]{\Gm@setpaper@ifpre{sc16x10}}
\define@key{Gm}{sc4x3}[true]{\Gm@setpaper@ifpre{sc4x3}}
\define@key{Gm}{sc4x3beamer}[true]{\Gm@setpaper@ifpre{sc4x3b}}
% ajout de la cl\'e Gm@littlemargin
\define@key{Gm}{littlemargin}{%
        \Gm@setlength\Gm@littlemargin{#1}
        \Gm@setlength\marginparwidth{#1}%
        \Gm@setlength\marginparsep\z@%
}
\appto\Gm@save{\Gm@savelength{Gm@littlemargin}}
%\appto\Gm@save{\Gm@saveboolean{compact}}

% interface pgfkeys pour geometry
\newif\ifforced@geometry
\newif\ifactivated@geometry
\def\geom@options{reversemp}

\cpgesetup[@geometry]{%
	print/.code=%
		\printtrue%
		\darkfalse%
		\compactfalse%
		\geometry{%
			a4paper,
			inner=3.6cm, outer=2.4cm,
			vmargin={2.4cm,3.6cm}, 
			littlemargin=4pc
		}, 
	2print/.code=%
		\printtrue%
		\darkfalse%
		\compacttrue%
		\striptitletrue
		\geometry{%
			a4paper,
			twocolumn, columnsep=20truept,
			%mag=830,
			inner=1truecm, outer=1truecm,
			vmargin={2.4truecm,2.4truecm},
			littlemargin=3.2pc%
		},
	lsprint/.code=%
		\printtrue%
		\darkfalse%
		\compactfalse%
		\striptitlefalse%
		\geometry{%
			a4paper,
			landscape,
			twocolumn, columnsep=1truecm,
			%mag=870,
			inner=1.8truecm, outer=1.8truecm,
			vmargin={1.5truecm,1.5truecm},
			littlemargin=3.2pc
		},
	draft/.code=%
		\printfalse%
		\compacttrue%
		\titlepagetrue%
		\geometry{%
			a5paper,
			inner=1.5cm, outer=1.5cm,
			vmargin={1.8cm,2.4cm},
			littlemargin=4pc 
		}, 
	phone/.code=%
		\printfalse%
		\darktrue%
		\compacttrue%
		\titlepagetrue%
		\geometry{%
			sc16x9,
			mag=1100,
			hmargin={1cm,.5cm},
			vmargin={1.2cm,1.4cm},
			littlemargin=3.2pc,
		},%
	phone 19x9/.code=%
		\printfalse%
		\darktrue%
		\compacttrue%
		\titlepagetrue%
		\geometry{%
			sc19x9,
			hmargin={1cm,.5cm},
			vmargin={1.4cm,1.8cm},
			littlemargin=2.4em
		},%
	beamer/.code=%
		\printfalse%
		\darkfalse%
		\compactfalse%
		\titlepagetrue%
		\geometry{%
			sc4x3beamer,
			hmargin={1cm,.5cm},
			vmargin={.4cm,1.2cm},
			littlemargin=4pc
		},%
	tablet/.code=%
		\printfalse%
		\darkfalse%
		\compactfalse%
		\titlepagetrue%
		\geometry{%
			sc4x3,
			hmargin={1.8cm,1.8cm},
			vmargin={1.5cm,2cm},
			%mag=1100,
			littlemargin=4pc
		},%
	lstablet/.code=%
		\printfalse%
		\compacttrue%
		\darkfalse%
		\titlepagetrue%
		\geometry{%
			sc4x3,
			landscape,
			twocolumn, columnsep=24pt,
			hmargin={.5cm,.5cm},
			vmargin={1.2cm,1.4cm},
			%mag=880,
			littlemargin=3.2pc
		},%
	tablet 16x10/.code=%
		\printfalse%
		\darkfalse%
		\compactfalse%
		\titlepagetrue%
		\geometry{%
			sc16x10,
			hmargin={1cm,1cm},
			vmargin={1.5cm,2cm},
			%mag=1100,
			littlemargin=4pc
		},%
	lstablet 16x10/.code=%
		\printfalse%
		\compacttrue%
		\darkfalse%
		\titlepagetrue%
		\geometry{%
			sc16x10,
			landscape,
			twocolumn, columnsep=32pt,
			hmargin={.8cm,.8cm},
			vmargin={1.2cm,1.4cm},
			%mag=880,
			littlemargin=3.2pc
		},%
}
\cpgesetup[geometry]{%
	.unknown/.code=\edef\tmp@value{#1}\ifdefvoid{\tmp@value}{\eappto\geom@options{%
		\pgfkeyscurrentname,}}{\eappto\geom@options{%
		\pgfkeyscurrentname={\tmp@value},}}, 
	force compact/.is if=compact,
	force geometry/.is if=forced@geometry,
	draft/.is if=draft,
	dark/.is if=dark
}
\NewDocumentCommand\cpgegeometry{O{}m}{%
	\unless\ifdraft%
			\forced@geometrytrue%
	\fi%
	\cpgesetup[geometry]{#1}
	\ifactivated@geometry\else%
		\activated@geometrytrue%
		\ifforced@geometry
			\cpgesetup[@geometry]{#2}
		\else
			\ifdraft
				\cpgesetup[@geometry]{draft}
			\fi
		\fi 
	\fi
	\ifdefempty{\geom@options}{}{
		\@xp\geometry\@xp{\geom@options}
	}%
}
\AtEndPreamble{%
	\unless\ifactivated@geometry
			\cpgesetup[@geometry]{draft}
	\fi% 
	\def\multicols#1{\relax}
	\csdef{multicols*}#1{\relax}
	\let\endumlticols\relax 
	\cslet{endmulticols*}{\relax}
	\unless\if@twocolumn
		\unless\ifcompact\RequirePackage{multicol}\fi
	\fi
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Titre du document %%%%%
\AtEndPreamble{%
	\ifdim\paperwidth>127mm\relax
		\def\cpge@relsize{\relsize{2}}
	\else
		\def\cpge@relsize{\relsize{1}}%
	\fi%
}
\newif\iftitlepage
\newdimen\cpge@ttlw
\cpge@ttlw=3cm
%% Ajout des mots cles du titre
\DeclareDocumentCommand\cpgenewtitlekeyword{mm}{%
   \cpgeaddkeyword{title}{#1}{%
      {#2\cpge@relsize\csuse{cpge@#1@format}%
      \global\cpge@dima\baselineskip}%
      \baselineskip\cpge@dima%
   }
}
\cpgenewtitlekeyword{centre}{\normalsize\scshape}
\cpgenewtitlekeyword{classe}{\normalsize\scshape}
\cpgenewtitlekeyword{document}{\Large\scshape}
\cpgenewtitlekeyword{epreuve}{\large\bfseries}
\cpgenewtitlekeyword{theme}{\Large\scshape}
\cpgenewtitlekeyword{subtheme}{\large\scshape\itshape}
\cpgenewtitlekeyword{texte}{\tiny\sffamily\slshape} 
\cpgenewtitlekeyword{periode}{\small\itshape}
\cpgenewtitlekeyword{auteur}{\small\textit{\cpge@preauthor}~}
\cpgenewtitlekeyword{email}{\small\ttfamily}
\cpgenewtitlekeyword{website}{\small\ttfamily}


\NewDocumentCommand\renew@title@format{O{1}mm}{
	\ifcase #1\relax	
			\or \csdef{title@#2}{%
		\resizebox{\hsize}{!}{%
			\parbox{3\cpge@ttlw}{%
				\fil@inner@titlepage\linespread{.8}%
				#3\csuse{cpge@#2@format}\strut%
				\global\cpge@dima\baselineskip%
			}%
		}\baselineskip1.2\cpge@dima%
	}
			 \or 
			 \csdef{title@#2}{%
		\resizebox{\hsize}{!}{%
			\parbox{2\cpge@ttlw}{%
				\fil@inner@titlepage\linespread{.8}%
				#3\csuse{cpge@#2@format}\strut%
				\global\cpge@dima\baselineskip%
			}%
		}\baselineskip1.2\cpge@dima%
	}
			  \or \csdef{title@#2}{%
		\resizebox{\hsize}{!}{%
			\parbox{1.5\cpge@ttlw}{%
				\fil@inner@titlepage\linespread{.8}%
				#3\csuse{cpge@#2@format}\strut%
				\global\cpge@dima\baselineskip%
			}%
		}\baselineskip1.2\cpge@dima%
	}
				 \or \csdef{title@#2}{%
		\resizebox{\hsize}{!}{%
			\parbox{\cpge@ttlw}{%
				\fil@inner@titlepage\linespread{.8}%
				#3\csuse{cpge@#2@format}\strut%
				\global\cpge@dima\baselineskip%
			}%
		}\baselineskip1.2\cpge@dima%
	}
	\fi 
} 
\def\titlepage@formats{%
		\renew@title@format[3]{matiere}{\bfseries}%
		\renew@title@format[4]{document}{\scshape}%
		\renew@title@format[3]{theme}{\scshape}%
		\renew@title@format[2]{subtheme}{\scshape\itshape}%
		\renew@title@format{periode}{\itshape}%
		%\renew@title@format{\footnotesize\textit{\cpge@preauthor}\small~}{auteur}%
		%\renew@title@format{\small\ttfamily}{email}%
		%\renew@title@format{\small\ttfamily}{website}%
}

%% Commande \title@parser qui traduit les mots cles 
%% pour le titre. Le resultat
%% est stocke dans la macro \title@contents
\long\def\title@change#1{%
   \StrSubstitute{\title@contents}
     {|#1|}{\csname title@#1\endcsname}[\title@string]%
     \global\let\title@contents\title@string
 }
\long\def\title@parser#1{\begingroup%
    \gdef\title@contents{#1}%
    \exploregroups\expandarg%
    \forlistloop{\title@change}{\list@title}%
    \endgroup%
}

%% Commande qui specifie le format du titre.
%% Elle utilise \title@contents pour formater
%% la macro \cpgetitlecontents (titre normal) 
%% ou \cpgetitlepagecontents, si * (page de garde)
\DeclareDocumentCommand\cpgesettitle{s+m}{%
	\title@parser{#2}%
	\IfBooleanTF{#1}
		{%
			\@xp\long\@xp\gdef
				\@xp\cpgetitlepagecontents\@xp
					{\title@contents}
		}{%
			\@xp\long\@xp\gdef
				\@xp\cpgetitlecontents\@xp
					{\title@contents}
		}%
}

%% commande qui prend en charge
%% une eventuelle description
%% du format par l'utilisateur
%% (argument entre () de la commande \titre)
\DeclareDocumentCommand\cpge@localtitle{s+m}{%
	\title@parser{#2}%
	\IfBooleanTF{#1}
		{%
			\@xp\long\@xp\def
				\@xp\cpgetitlepagecontents\@xp
					{\title@contents}
		}{%
			\@xp\long\@xp\def
				\@xp\cpgetitlecontents\@xp
					{\title@contents}
		}%
}

%% Formats par defaut
\cpgesettitle{|document| \\ |theme| \\ |periode|}
\cpgesettitle*{|document| \\ |theme| \\ |periode|}

%% Options du formatage 
\def\cpgesetuptitle{\cpgesetup[title]}
\cpgesetuptitle{
	inner align/.is choice, %alignement interne 
	inner align/l/.code=\let\fil@inner\raggedright, 
	inner align/r/.code=\let\fil@inner\raggedleft,
	inner align/c/.code=\let\fil@inner\centering,
   	inner align*/.is choice, %alignement interne dans titlepage
	inner align*/c/.code=\let\fil@inner@titlepage\centering,
	inner align*/l/.code=\let\fil@inner@titlepage\raggedright, 
	inner align*/r/.code=\let\fil@inner@titlepage\raggedleft,
   	outer align/.is choice, % alignement externe
	outer align/l/.code=\let\fil@outer\raggedright,
	outer align/r/.code=\let\fil@outer\raggedleft,
	outer align/c/.code=\let\fil@outer\centering,
	before/.code=\def\hook@beforetitle{#1}, % hook avant titre normal 
	after/.code=\def\hook@aftertitle{#1}, % hook apres titre normal 
	before*/.code=\def\hook@beforetitlepage{#1}, % hook avant titre, titlepage
	after*/.code=\def\hook@aftertitlepage{#1}, % hook apres titre, titlepage
	before title/.code=\title@parser{#1}%
               \@xp\def\@xp 
		          \hook@titlebeforetitle\@xp
                {\title@contents}, % prefix au format
	after title/.code=\title@parser{#1}%
               \@xp\def\@xp
		         \hook@titleaftertitle\@xp
               {\title@contents}, % postfix au format 
	before title*/.code=\title@parser{#1}
               \@xp\def\@xp 
		         \hook@titlebeforetitlepage\@xp
               {\title@contents}, % prefix au format
	after title*/.code=\title@parser{#1}%
               \@xp\def\@xp
		         \hook@titleaftertitlepage\@xp
               {\title@contents}, % postfix au format 
	late after/.code=\def\hook@lateaftertitle{#1},
	early before*/.code=\def\hook@earlybeforetitlepage{#1}, 
	late after*/.code=\def\hook@lateaftertitlepage{#1},
	width/.code=\dimdef\title@width{#1}, % largeur du titre 
	format/.code=\cpgesettitle{#1}, % specification du format normal 
	format*/.code=\cpgesettitle*{#1}, % specification du format titlepage 
	afterskip/.code=\dimdef\aftertitleskip{\bigskipamount*#1}
         % saut apres titre
}
\cpgesetuptitle{
	inner align/.default=c,
	inner align*/.default=l,
	outer align/.default=c,
	width/.default=\columnwidth,
	afterskip/.default=3,
	inner align, 
	inner align*, 
	outer align, 
	width,
	before=\minipage{\title@width},
	after=\endminipage,
	afterskip
	}

%% La commande utilisateur qui produit le titre
%% titre normal sans *, page de garde avec *
%% option [] pour \cpgesetup[title]{}, sinon option par defaut 
%% option () pour le format, sinon format par defaut
\NewDocumentCommand\titre{s+e\op+d()}{%
   \IfBooleanT{#1}{\titlepagetrue}
   \begingroup%
	\IfValueT{#2}{\cpgesetup[title]{#2}}%
	\IfValueT{#3}{%
		\iftitlepage\cpge@localtitle*{#3}\else\cpge@localtitle{#3}\fi%
		}%
	\iftitlepage%
		\if@twocolumn
			\@restonecoltrue\onecolumn
 		\else
			\@restonecolfalse\newpage
 		 \fi
  		\thispagestyle{empty}%
  		\setcounter{page}\@ne
				\titlepage@formats%
				\csuse{hook@earlybeforetitlepage}%
				\ifbackground\def\back@code{}\fi%
            	\fil@inner@titlepage%
				\csuse{hook@beforetitlepage}%
				\csuse{hook@title@beforetitlepage}%
            		\csuse{cpgetitlepagecontents}%
				\csuse{hook@titleaftertitlepage}%
           		\csuse{hook@aftertitlepage}%
			\csuse{hook@lateaftertitlepage}
		\if@restonecol\twocolumn \else \newpage \fi
     	\if@twoside\else
        	\setcounter{page}\@ne
     	\fi
	\else%
			\thispagestyle{plain}%
			\begingroup\par%
				\fil@outer
            	\csuse{hook@beforetitle}%
				\fil@inner
				\csuse{hook@titlebeforetitle}
					\csuse{cpgetitlecontents}%
				\csuse{hook@titleaftertitle}%
				\csuse{hook@aftertitle}%
			\endgroup%
			\csuse{hook@lateaftertitle}
			\par\addvspace{\aftertitleskip}%
	\fi%
   \endgroup%
   \RenewDocumentCommand\titre{sod()}{}%
}

\AfterEndPreamble{%
	\cpgesetup[title]{%
		early before*={%
				\null\vskip 1cm plus .1fill 
				\begin{center}\minipage{.8\linewidth}%
		},
		late after*={%
			\endminipage
			\end{center}
			\vskip \z@ plus 1fill\null
			\pagecolor{pagecol}%
		},
	}%
}

%%%%% tikz et tcolorbox sont est utilis\'es pour les decorations

\RequirePackage[svgnames]{xcolor}
\ifundef\mathcolor{%
	\def\mathcolor#1#{\@mathcolor{#1}}
	\def\@mathcolor#1#2#3{%
	\protect\leavevmode
	\begingroup
		\color#1{#2}#3%
	\endgroup
	}
}{}
% \unless\ifdraft
% 	\RequirePackage{tikz} %%
% 	\usetikzlibrary{calc}
% \fi

%%%% Chargement des differents packages 
\RequirePackage{tcolorbox}
\tcbuselibrary{skins,hooks,breakable,theorems,xparse}
\usetikzlibrary{calc}
\tikzset{
    every picture/.prefix style={
        execute at begin picture=\shorthandoff{;}
    }
}
\tcbset{maincol/.code=\colorlet{maincol}{#1}}
% \RequirePackage[unicode,naturalnames]{hyperref}
% \hypersetup{colorlinks,linkcolor=linkcol}
% \pdfstringdefDisableCommands{%
% 	\def\({}%
% 	\def\){}%
% }
% \let\ToP\texorpdfstring

%%% Gestions des couleurs
%%%
\pgfkeys{/handlers/.colorlet/.code=
	\pgfkeysalso{\pgfkeyscurrentpath/.code=\colorlet{#1}{##1}}
}
\pgfkeys{/handlers/.colordef/.code=
	\pgfkeysalso{\pgfkeyscurrentpath/.code=\preparecolor{#1}{named}{##1}}
}
\def\cpgeset@colors#1#2#3{%
	\csdef{cpge@#1col}{\ifdark #3\else #2\fi}
}
\cpgesetup[colors]{
	warm/.code 2 args=\cpgeset@colors{warm}{#1}{#2},
	cold/.code 2 args=\cpgeset@colors{cold}{#1}{#2},
	neutral/.code 2 args=\cpgeset@colors{neutral}{#1}{#2},
	main/.code 2 args=\cpgeset@colors{main}{#1}{#2},
	important/.code 2 args=\cpgeset@colors{important}{#1}{#2},
	link/.code 2 args=\cpgeset@colors{link}{#1}{#2},
	fg/.code 2 args=\cpgeset@colors{fg}{#1}{#2},
	bg/.code 2 args=\cpgeset@colors{bg}{#1}{#2},
	page/.code 2 args=\cpgeset@colors{page}{#1}{#2},
	warmcol/.colorlet=warmcol,
    coldcol/.colorlet=coldcol,
    neutralcol/.colorlet=neutralcol,
    linkcol/.colorlet=linkcol,
	maincol/.colorlet=maincol, 
	importantcol/.colorlet=importantcol, 
    fgcol/.colorlet=fgcol,
    bgcol/.colorlet=bgcol,
    pagecol/.colorlet=pagecol,
	default colors/.style={
    	warmcol=\cpge@warmcol,
    	coldcol=\cpge@coldcol,
    	neutralcol=\cpge@neutralcol,
		maincol=\cpge@maincol,
		importantcol=\cpge@importantcol,
    	linkcol=\cpge@linkcol,
    	fgcol=\cpge@fgcol,
    	bgcol=\cpge@bgcol,
    	pagecol=\cpge@pagecol,
	},
	tcbtext/.code=\def\cpge@coltext{#1},
	tcbback/.code=\def\cpge@colback{#1},
	tcbframe/.code=\def\cpge@colframe{#1},
	tcbtitle/.code=\def\cpge@coltitle{#1},
	tcbbacktitle/.code=\def\cpge@colbacktitle{#1},
	coltext/.colorlet=tcbcoltext,
	colback/.colorlet=tcbcolback,
	colframe/.colorlet=tcbcolframe,
	coltitle/.colorlet=tcbcoltitle,
	colbacktitle/.colorlet=tcbcolbacktitle,
	default tcbcolors/.style={
		coltext=\cpge@coltext,
		colback=\cpge@colback,
		colframe=\cpge@colframe,
		coltitle=\cpge@coltitle,
		colbacktitle=\cpge@colbacktitle
	}
   }

\definecolor{cpgeblue}{HTML}{373A73}
\definecolor{cpgealtblue}{HTML}{007AFF}
\definecolor{cpgegreen}{HTML}{8CBA30}
\definecolor{cpgeblack}{HTML}{1F1F1F}
   
\cpgesetup[colors]{    
	   warm={cpgegreen!85!black}{cpgegreen},
	   cold={cpgeblue}{cpgealtblue},
	   main={cpgegreen!85!black}{cpgegreen},
	   important={DarkRed}{DarkOrange},
	   link={cpgeblue}{cpgealtblue},
	   page={white}{cpgeblack},
	   fg={black}{white},
	   bg={white}{cpgeblack!90!black},
	   neutral={gray}{gray},
	   tcbtext=fgcol,
	   tcbframe=warmcol,
	   tcbback=bgcol,
	   tcbtitle=white, 
	   tcbbacktitle=warmcol,
   }

\AtEndPreamble{\ifnocolors\selectcolormodel{gray}\fi}
\def\reloadcolors{
	\AtEndPreamble{%
		\cpgesetup[colors]{default colors}%
		\cpgesetup[colors]{default tcbcolors}
		\pagecolor{pagecol}%
		\color{fgcol}%
	}%
	\AtBeginDocument{\color{fgcol}\pagecolor{pagecol}}%
}%
\reloadcolors


%%%% Fonts loading. 
\RequirePackage{ifxetex}
\cpgesetup[font]{%
	libertine/.code={%
		\def\load@thefonts{
			\ifxetex
				\RequirePackage{fontspec}
				\let\lsstyle\relax
			\else 
				\RequirePackage[T1]{fontenc}
				\RequirePackage{microtype}
			\fi
			\RequirePackage[french]{babel}
			\RequirePackage[tt=false]{libertine}
			\RequirePackage[%
				libertine,smallerops,bigdelims,upint,vvarbb
			]{newtxmath}
			\RequirePackage[scaled=.85]{FiraMono}
			\useosf
			\def\TitlingFont{\sffamily\scshape}
	}},
	lmodern/.code={%
		\def\load@thefonts{
			\ifxetex
				\RequirePackage{fontspec}
				\let\lsstyle\relax
			\else 
				\RequirePackage[T1]{fontenc}
				\RequirePackage{microtype}
			\fi
		\usepackage{lmodern}
		\RequirePackage[french]{babel}
		\def\TitlingFont{\sffamily\scshape}
	}},
	utopia/.code={%
		\def\load@thefonts{
			\ifxetex
				\RequirePackage{fontspec}
				\let\lsstyle\relax
			\else 
				\RequirePackage[T1]{fontenc}
				\RequirePackage{microtype}
			\fi
		\RequirePackage[french]{babel}
		\usepackage[p,scaled=.98,space]{erewhon}
		\usepackage[varqu,varl]{inconsolata} % typewriter
		\usepackage[type1,scaled=.95]{cabin} % sans serif like Gill Sans
		\usepackage[utopia,vvarbb]{newtxmath}
		\useosf
		\def\TitlingFont{\sffamily\scshape}
	}},
	palatino/.code={%
		\def\load@thefonts{
			\ifxetex
				\RequirePackage{fontspec}
				\let\lsstyle\relax
			\else 
				\RequirePackage[T1]{fontenc}
				\RequirePackage{microtype}
			\fi
		\RequirePackage[french]{babel}
		\usepackage{newpxtext}
		\usepackage[vvarbb]{newpxmath}
		\useosf
		\def\TitlingFont{\sffamily\scshape}
	}},
	fira/.code={%
		\def\load@thefonts{%
			\ifxetex
				\RequirePackage{fontspec}
				\let\lsstyle\relax
			\else 
				\RequirePackage[T1]{fontenc}
				\RequirePackage{microtype}

			\fi
			\RequirePackage[french]{babel}
			\RequirePackage[sfdefault, scaled=.92]{FiraSans}
			\RequirePackage[scaled=.88]{FiraMono}
			\RequirePackage[smallerops,upint]{newtxsf}
			\firaoldstyle
			\def\TitlingFont{\scshape}
	}},
	load/.code={%
		\def\load@thefonts{%
			\RequirePackage[T1]{fontenc}
			\RequirePackage[french]{babel}
			\RequirePackage{#1}
			\RequirePackage{microtype}
	}},
	none/.code={\def\load@thefonts{}},
	titling font/.store in=\TitlingFont,
}
\DeclareDocumentCommand\cpgefont{m}{%
	\cpgesetup[font]{#1}
}
\AtEndPreamble{
	\ifundef\load@thefonts
		{\ifprint\cpgefont{libertine}\else\cpgefont{fira}\fi}
		{}%
	\load@thefonts
	\ifundef\hypersetup{}{%
	\pdfstringdefDisableCommands{%
		\def\({}%
		\def\){}%
	}
	\let\ToP\texorpdfstring}
	\def\label@itemi{\relsize{-2}$\mathcolor{tcbcolbacktitle}\xdiamond$}
	\def\label@itemii{\relsize{-2}$\mathcolor{tcbcolbacktitle}\xsquare$}
	\def\label@itemiii{\relsize{-2}$\mathcolor{tcbcolbacktitle}\xbullet$}
	\def\ccsi{\textcolor{tcbcolbacktitle}\xheadarrowright}
	\def\ccalors{\textcolor{tcbcolbacktitle}\xheadarrowleft}	
	\def\ccneutre{\relsize{-2}$\mathcolor{tcbcolbacktitle}\xbullet$}
}
\let\xdocument\document
\let\endsxdocument\enddocument


%%%% Gestion des themes
\newdimen\cpge@ttlw
\cpge@ttlw=3cm

\cpgesetup[theme]{%
	.search also={/cpge/colors,/cpge/tcb},
	dark/.is if=dark,
	draft/.is if=draft,
	colors/.code=\pgfkeysalso{/cpge/colors/.cd,#1},
	no colors/.is if=nocolors,
	font/.code=\cpgefont{#1},
	libertine/.style={font=libertine},
	fira/.style={font=fira},
	utopia/.style={font=utopia},
	palatino/.style={font=palatino},
	title page/.is if=titlepage,
	title format/.code=\cpgesettitle{#1},
	title format*/.code=\cpgesettitle*{#1},
	scale title/.code=
		\AtEndPreamble{\pgfmathsetlength\cpge@ttlw{\cpge@ttlw/#1}},
	logo/.code=\def\cpge@logo{#1},
}
\cpgesetup[title]{%
	scale/.code=\AtEndPreamble{\pgfmathsetlength\cpge@ttlw{\cpge@ttlw/#1}}
}
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




