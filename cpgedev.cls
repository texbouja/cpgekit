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
	compact/.style={},
	dark/.style={},
	nocolors/.style={},
	solution/.style={},
	solution*/.style={},
	hint/.style={},
}
\pgfkeys{/IGDS/.is family, /IGDS/.cd,
	draft/.is if=draft,	
	straight/.is if=straight,
	compact/.is if=compact,
	dark/.is if=dark,
	nocolors/.is if=nocolors, 
	nolinks/.is if=nolinks,
	web/.code=\compacttrue\webtrue\def\convert@options{}
		\def\cpgecomment@list{exercice,probleme,#1},
	web/.default={},
	singleimage/.is if=singleimage,
	thisfile/.is if=thisfile,
	solution/.code=\solutiontrue\solutiondelayedfalse,%
	solution*/.code=\solutiontrue\solutiondelayedtrue,%
	hint/.code=\csuse{hint#1}\csuse{hintocg#1},
	hint/.default=true,
	hint*/.code=\csuse{hint#1}\hintocgfalse,
	hint*/.default=true, 
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
\newcounter{tmpdo}

\newif\ifinsolutions
\newif\ifnofootimage
\newif\ifcpge@withsol % vrai si le numero de la question courante doit être un hyperlien 
\newif\ifcpge@withhint % vrai s'il y a au moins une indication dans le sujet en cours
\newif\ifcpge@tmpswa
\newif\ifcpge@tmpswb

\newtoks\toks@sol % retient la solution de la question en cours
\newtoks\toks@hint % retient l'indication de la question en cours
\newbox\trash@box



%%%%% Packages du projet 
\RequirePackage[customtitles]{cpgebase}
\RequirePackage{cpgesubfile}
\RequirePackage{cpgemath}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Basculement vers la conversion en images %%%%%%	
\ifbool{web}
	{\RequirePackage{cpgeweb}\endinput}{}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

\AtBeginDocument{
	\ifsolutiondelayed\cpgestartrecording[\jobname.rec]\fi
}
%%%%%%%%%%%%%%%%%%



%%%% Strategie d'inclusion de fichier
%%%%  une version modifiée de subfile.sty renommée en cpgesub.sty
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
	\ifsolution%
		\def\corrige{\Corrige}%
		\let\endcorrige\endCorrige%
	\fi%
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


\def\cpgeincludeweb#1{} 

%%%%% Geometrie du document

\RequirePackage{geometry}
\RequirePackage{cuted}


% patch de la commande qui contrôle le format de papier
\newdimen\Gm@littlemargin
\Gm@littlemargin\z@
\dimdef\compactlimit{131mm}
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
% ajout de la clé Gm@littlemargin
\define@key{Gm}{littlemargin}{%
        \Gm@setlength\Gm@littlemargin{#1}
        \Gm@setlength\marginparwidth{#1}%
        \Gm@setlength\marginparsep\z@%
}
\appto\Gm@save{\Gm@savelength{Gm@littlemargin}}
%\appto\Gm@save{\Gm@saveboolean{compact}}

% interface pgfkeys pour geometry
\newif\iftitlepage@exception
\newif\ifforced@geometry
\newif\ifactivated@geometry
\def\geom@options{}

\cpgeset[@geometry]{%
	print/.code=%
		\printtrue%
		\darkfalse%
		\compactfalse%
		\geometry{%
			a4paper,
			inner=3.6cm, outer=2.4cm,
			vmargin={2.4cm,3.6cm}, 
			littlemargin=3em
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
			littlemargin=2.4em
		},
	lsprint/.code=%
		\printtrue%
		\darkfalse%
		\compactfalse%
		\striptitlefalse%
		\geometry{%
			a4paper,
			landscape,
			twocolumn, columnsep=24truept,
			%mag=870,
			inner=1.8truecm, outer=1.8truecm,
			vmargin={1.5truecm,1.5truecm},
			littlemargin=3em
		},
	draft/.code=%
		\printfalse%
		\compacttrue%
		\titlepagetrue%
		\geometry{%
			a5paper,
			inner=1.5cm, outer=1.5cm,
			vmargin={1.8cm,2.4cm},
			littlemargin=2.4em 
		}, 
	phone/.code=%
		\printfalse%
		\darktrue%
		\compacttrue%
		\titlepagetrue%
		\geometry{%
			sc16x9,
			mag=1100,
			hmargin={.5cm,.5cm},
			vmargin={1.2cm,1.4cm},
			littlemargin=2.4em,
		},%
	phone 19x9/.code=%
		\printfalse%
		\darktrue%
		\compacttrue%
		\titlepagetrue%
		\geometry{%
			sc19x9,
			hmargin={.5cm,.5cm},
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
			hmargin={.4cm,.4cm},
			vmargin={.4cm,1.2cm},
			littlemargin=3em
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
			littlemargin=3em
		},%
	lstablet/.code=%
		\printfalse%
		\compacttrue%
		\darkfalse%
		\titlepagetrue%
		\titlepage@exceptiontrue%
		\geometry{%
			sc4x3,
			landscape,
			twocolumn, columnsep=24pt,
			hmargin={.5cm,.5cm},
			vmargin={1.2cm,1.4cm},
			%mag=880,
			littlemargin=2.4em
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
			littlemargin=3em
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
			littlemargin=2.4em
		},%
}
\cpgeset[geometry]{%
	.unknown/.code=\expandafter\appto\expandafter\geom@options\expandafter{%
		\pgfkeyscurrentname=#1,}, 
	force compact/.is if=compact,
	force geometry/.is if=forced@geometry,
	draft/.is if=draft,
	dark/.is if=dark
}
\NewDocumentCommand\cpgegeometry{O{}m}{%
	\unless\ifdraft%
			\forced@geometrytrue%
	\fi%
	\cpgeset[geometry]{#1}
	\ifactivated@geometry\else%
		\activated@geometrytrue%
		\ifforced@geometry
			\cpgeset[@geometry]{#2}
		\else
			\ifdraft
				\cpgeset[@geometry]{draft}
			\fi
		\fi 
	\fi
	\ifdefempty{\geom@options}{}{
		\expandafter\geometry\expandafter{\geom@options}
	}%
}
\AtEndPreamble{%
	\unless\ifactivated@geometry
			\cpgeset[@geometry]{draft}
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
\DeclareDocumentCommand\cpgeaddkeyword@title{D(){}m}{%
   \cpgeaddkeyword{title}{#2}{%
      {#1\cpge@relsize\csuse{cpge@#2@format}%
      \global\cpge@dima\baselineskip}%
      \baselineskip\cpge@dima%
   }
}
\cpgeaddkeyword@title(\normalsize\scshape){centre}
\cpgeaddkeyword@title(\normalsize\scshape){classe}
\cpgeaddkeyword@title(\Large\bfseries){document}
\cpgeaddkeyword@title(\Large\bfseries){devoir}
\cpgeaddkeyword@title(\Large\bfseries){epreuve}
\cpgeaddkeyword@title(\Large\bfseries){concours}
\cpgeaddkeyword@title(\Large\scshape){theme}
\cpgeaddkeyword@title(\scshape\itshape){subtheme} 
\cpgeaddkeyword@title(\small\itshape){periode}
\cpgeaddkeyword@title(\small\itshape){duree}
\cpgeaddkeyword@title(\small\itshape){session}
\cpgeaddkeyword@title(\small){auteur}
\cpgeaddkeyword@title(\small\ttfamily){email}
\cpgeaddkeyword@title(\small\ttfamily){website}

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
%% ou \titlepagecontents, si * (page de garde)
\DeclareDocumentCommand\cpgedeftitleformat{s+m}{%
	\title@parser{#2}%
	\IfBooleanTF{#1}
		{%
			\expandafter\long\expandafter\gdef
				\expandafter\titlepagecontents\expandafter
					{\title@contents}
		}{%
			\expandafter\long\expandafter\gdef
				\expandafter\cpgetitlecontents\expandafter
					{\title@contents}
		}%
}
\def\cpgenewtitle{\cpgedeftitleformat}

%% commande qui prend en charge
%% une eventuelle description
%% du format par l'utilisateur
%% (argument entre () de la commande \titre)
\DeclareDocumentCommand\cpge@localtitle{s+m}{%
	\title@parser{#2}%
	\IfBooleanTF{#1}
		{%
			\expandafter\long\expandafter\def
				\expandafter\titlepagecontents\expandafter
					{\title@contents}
		}{%
			\expandafter\long\expandafter\def
				\expandafter\cpgetitlecontents\expandafter
					{\title@contents}
		}%
}

%% Formats par defaut
\cpgedeftitleformat{|document| \\ |theme| \\ |periode|}
\cpgedeftitleformat*{|document| \\ |theme| \\ |periode|}

%% Options du formatage 
\cpgeset[title]{
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
               \expandafter\def\expandafter 
		          \hook@titlebeforetitle\expandafter
                {\title@contents}, % prefix au format
	after title/.code=\title@parser{#1}%
               \expandafter\def\expandafter
		         \hook@titleaftertitle\expandafter
               {\title@contents}, % postfix au format 
	before title*/.code=\title@parser{#1}
               \expandafter\def\expandafter 
		         \hook@titlebeforetitlepage\expandafter
               {\title@contents}, % prefix au format
	after title*/.code=\title@parser{#1}%
               \expandafter\def\expandafter
		         \hook@titleaftertitlepage\expandafter
               {\title@contents}, % postfix au format 
	early before*/.code=\def\hook@earlybeforetitlepage{#1}, 
	late after*/.code=\def\hook@lateaftertitlepage{#1},
	width/.code=\dimdef\title@width{#1}, % largeur du titre 
	format/.code=\cpgedeftitleformat{#1}, % specification du format normal 
	format*/.code=\cpgedeftitleformat*{#1}, % specification du format titlepage 
	afterskip/.code=\dimdef\aftertitleskip{\bigskipamount*#1}
         % saut apres titre
}
\cpgeset[title]{
	inner align/.default=c,
	inner align*/.default=l,
	outer align/.default=c,
	width/.default=\linewidth,
	afterskip/.default=3,
	inner align, 
	inner align*, 
	outer align, 
	before=\minipage{\title@width},
	after=\endminipage,
	width,
	afterskip
	}

%% La commande utilisateur qui produit le titre
%% titre normal sans *, page de titre avec *
%% option [] pour \cpgeset[title]{}, sinon option par defaut 
%% option () pour le format, sinon format par defaut
\newif\iftitlepage@used
\NewDocumentCommand\titre{so+d()}{%
   \IfBooleanT{#1}{\titlepagetrue}
   \begingroup%
	\IfValueT{#2}{\cpgeset[title]{#2}}%
	\IfValueT{#3}{%
		\iftitlepage\cpge@localtitle*{#3}\else\cpge@localtitle{#3}\fi%
		}%
	\iftitlepage%
      \unless\iftitlepage@used%
			\csuse{hook@earlybeforetitlepage}%
			\begin{titlepage}%
				\ifbackground\def\back@code{}\fi%
            	\fil@inner@titlepage%
				\csuse{hook@beforetitlepage}%
				\csuse{hook@title@beforetitlepage}%
            		\csuse{titlepagecontents}%
				\csuse{hook@titleaftertitlepage}%
           		\csuse{hook@aftertitlepage}%
			\end{titlepage}%
			\csuse{hook@lateaftertitlepage}\clearpage%
      \fi%
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
			\par\addvspace{\aftertitleskip}%
	\fi%
   \endgroup%
   \iftitlepage\titlepage@usedtrue\fi%
}

%%% Commandes utilitaires pour switcher vers 
%%% une geometrie particuliere (en 4x3)
%%% pour la page de garde
%%% Par defaut, la page de garde n'est
%%% generee que pour les versions pour ecran
%%% mais peut etre activee ou desactivee avec
%%% l'option "title page" de \cpgetheme 

\AtEndPreamble{%
	\dimdef\paperheight@origin{\paperheight}%
	\dimdef\paperheight@titlepage{.75\paperwidth}%
	\savegeometry{cpge@orcpgein@geom}%
}
\def\titlepage@geometry{%
		\newgeometry{%
			hmargin=\z@, vmargin=\z@,
		} 
		%\textheight=\textheight@titlepage
}
\colorlet{pagecol}{white}
\def\restore@geometry{%
	\pdfpageheight=\paperheight@origin%
	\restoregeometry%
}
\AfterEndPreamble{%
	\cpgeset[title]{%
		early before*={%
			\unless\iftitlepage@exception%
				\pdfpageheight=\paperheight@titlepage%
				\titlepage@geometry%
			\fi%
		},
		late after*={%
			\pagecolor{pagecol}%
			\unless\iftitlepage@exception%
				\restore@geometry%
			\fi%
		},
		before*=\null\vskip \z@ plus .1fill \begin{center}\minipage{.8\linewidth},
		after*=\endminipage\end{center}\vskip \z@ plus 1fill\null%
	}%
}
\NewDocumentCommand\renew@title@format{O{1}D(){}m}{
	\ifcase #1\relax	
			\or \csdef{title@#3}{%
		\resizebox{\hsize}{!}{%
			\parbox{3\cpge@ttlw}{%
				\fil@inner@titlepage\linespread{.8}%
				#2\csuse{cpge@#3@format}\strut%
				\global\cpge@dima\baselineskip%
			}%
		}\baselineskip1.2\cpge@dima%
	}
			 \or 
			 \csdef{title@#3}{%
		\resizebox{\hsize}{!}{%
			\parbox{2\cpge@ttlw}{%
				\fil@inner@titlepage\linespread{.8}%
				#2\csuse{cpge@#3@format}\strut%
				\global\cpge@dima\baselineskip%
			}%
		}\baselineskip1.2\cpge@dima%
	}
			  \or \csdef{title@#3}{%
		\resizebox{\hsize}{!}{%
			\parbox{1.5\cpge@ttlw}{%
				\fil@inner@titlepage\linespread{.8}%
				#2\csuse{cpge@#3@format}\strut%
				\global\cpge@dima\baselineskip%
			}%
		}\baselineskip1.2\cpge@dima%
	}
				 \or \csdef{title@#3}{%
		\resizebox{\hsize}{!}{%
			\parbox{\cpge@ttlw}{%
				\fil@inner@titlepage\linespread{.8}%
				#2\csuse{cpge@#3@format}\strut%
				\global\cpge@dima\baselineskip%
			}%
		}\baselineskip1.2\cpge@dima%
	}
	\fi 
} 
\AtEndPreamble{%
	\iftitlepage
		\renew@title@format[3](\bfseries){matiere}%
		\renew@title@format[4](\bfseries){document}%
		\renew@title@format[3](\bfseries){concours}%
		\renew@title@format[3](\scshape){theme}%
		\renew@title@format[2](\scshape){subtheme}%
		\renew@title@format[3](\scshape){epreuve}%
		\renew@title@format[2](\scshape\itshape){subtheme}%
		\renew@title@format(\itshape){periode}%
		\renew@title@format[2](\itshape){session}%
		\renew@title@format(\small){auteur}%
		\renew@title@format(\small\ttfamily){email}%
		\renew@title@format(\small\ttfamily){website}%
	\fi%
}

%%%%% tikz est utilisé pour les decorations

\RequirePackage[svgnames]{xcolor}
\unless\ifdraft
	\RequirePackage{tikz} %%
	\usetikzlibrary{calc}
\fi


%%% Gestions des couleurs
%%%
\pgfkeys{/handlers/.colorlet/.code=
	\pgfkeysalso{\pgfkeyscurrentpath/.code=\colorlet{#1}{##1}}
}
\pgfkeys{/handlers/.colordef/.code=
	\pgfkeysalso{\pgfkeyscurrentpath/.code=\preparecolor{#1}{named}{##1}}
}
\def\cpgeset@color#1#2#3{%
	\csdef{cpge@#1col}{\ifdark #3\else #2\fi}
}
\cpgeset[colors]{
	warm/.code 2 args=\cpgeset@color{warm}{#1}{#2},
	cold/.code 2 args=\cpgeset@color{cold}{#1}{#2},
	neutral/.code 2 args=\cpgeset@color{neutral}{#1}{#2},
	main/.code 2 args=\cpgeset@color{main}{#1}{#2},
	link/.code 2 args=\cpgeset@color{link}{#1}{#2},
	fg/.code 2 args=\cpgeset@color{fg}{#1}{#2},
	bg/.code 2 args=\cpgeset@color{bg}{#1}{#2},
	page/.code 2 args=\cpgeset@color{page}{#1}{#2},
	warmcol/.colorlet=warmcol,
    coldcol/.colorlet=coldcol,
    neutralcol/.colorlet=neutralcol,
    linkcol/.colorlet=linkcol,
	maincol/.colorlet=maincol, 
    fgcol/.colorlet=fgcol,
    bgcol/.colorlet=bgcol,
    pagecol/.colorlet=pagecol,
	default colors/.style={
    	warmcol=\cpge@warmcol,
    	coldcol=\cpge@coldcol,
    	neutralcol=\cpge@neutralcol,
		maincol=\cpge@maincol,
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
   
\cpgeset[colors]{    
	   warm={cpgegreen!85!black}{cpgegreen},
	   cold={cpgeblue}{cpgealtblue},
	   main={cpgegreen!85!black}{cpgegreen},
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
		\cpgeset[colors]{default colors}%
		\cpgeset[colors]{default tcbcolors}
		\pagecolor{pagecol}%
		\color{fgcol}%
	}%
	\AtBeginDocument{\color{fgcol}\pagecolor{pagecol}}%
}%
\reloadcolors


%%%% Fonts loading. 
\RequirePackage{ifxetex}
\newif\iffontsloaded
\cpgeset[font]{%
	libertine/.code={%
		\def\load@thefonts{
			\ifxetex
				\RequirePackage{polyglossia}
				\setdefaultlanguage{french}
				\def\shorthandoff####1{}
				\let\lsstyle\relax
			\else 
				\RequirePackage[T1]{fontenc}
				\RequirePackage[french]{babel}
				\RequirePackage{microtype}
			\fi
			\RequirePackage[tt=false]{libertine}
			\RequirePackage[%
				libertine,smallerops,bigdelims,upint,vvarbb
			]{newtxmath}
			\RequirePackage[scaled=.85]{FiraMono}
			\useosf
			\def\TitlingFont{\sffamily\scshape}
	}},
	erewhon/.code={%
		\def\load@thefonts{
			\ifxetex
				\RequirePackage{polyglossia}
				\setdefaultlanguage{french}
				\def\shorthandoff####1{}
				\let\lsstyle\relax
			\else 
				\RequirePackage[T1]{fontenc}
				\RequirePackage[french]{babel}
				\RequirePackage{microtype}
			\fi
		\usepackage[p,osf,scaled=.98,space]{erewhon}
		\usepackage[varqu,varl]{inconsolata} % typewriter
		\usepackage[type1,scaled=.95]{cabin} % sans serif like Gill Sans
		\usepackage[utopia,vvarbb]{newtxmath}
		\def\TitlingFont{\sffamily\scshape}
	}},
	fira/.code={%
		\def\load@thefonts{%
			\ifxetex
				\RequirePackage{polyglossia}
				\setdefaultlanguage{french}
				\def\shorthandoff####1{}
				\let\lsstyle\relax
			\else 
				\RequirePackage[T1]{fontenc}
				\RequirePackage[french]{babel}
				\RequirePackage{microtype}

			\fi
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
	\cpgeset[font]{#1}
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

\cpgeset[theme]{%
	.search also={/cpge/colors,/cpge/tcb},
	dark/.is if=dark,
	draft/.is if=draft,
	colors/.code=\pgfkeysalso{/cpge/colors/.cd,#1},
	no colors/.is if=nocolors,
	font/.code=\cpgefont{#1},
	libertine/.style={font=libertine},
	fira/.style={font=fira},
	erewhon/.style={font=erewhon},
	title page/.is if=titlepage,
	title format/.code=\cpgedeftitleformat{#1},
	title format*/.code=\cpgedeftitleformat*{#1},
	scale title/.code=
		\AtEndPreamble{\pgfmathsetlength\cpge@ttlw{\cpge@ttlw/#1}} 
}
\cpgeset[title]{%
	scale/.code=\AtEndPreamble{\pgfmathsetlength\cpge@ttlw{\cpge@ttlw/#1}}
}
\DeclareDocumentCommand\cpgetheme{O{} m}{%
	\cpgeset[theme]{#1}
	\unless\ifdraft
		\IfFileExists{#2dev.sty}
			{\AtEndPreamble{\RequirePackage{#2dev}}}{}%
	\fi%
	\reloadcolors%
}


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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Création des divisons de document \devoir, \section, \problem...  %%%
%%% repose sur cpgetitle.sty qui fusionne titlesec, titleps et titletoc %%%

%%% Résiliation des commandes de titrage usuelles
\undef\section
\undef\subsection
\undef\parapgraph
\undef\subparagraph

%%% La nouvelle architecture de titrage
\titleclass{\@devoir}[0]{top} % -> \devoir 
\titleclass{\section}{straight}[\@devoir]
\titleclass{\@problem}{straight}[\section] % -> {probleme}, {exercise}, ...
\titleclass{\parti}{straight}[\@problem] 
\titleclass{\partii}{straight}[\parti]

\pgfkeys{/cpge/@title/.is family}
\def\cpgetitleset{\pgfqkeys{/cpge/@title}}
\cpgetitleset{
 align/.is choice,
 align/c/.code=\def\@lign{center},
 align/l/.code=\def\@lign{left},
 align/r/.code=\def\@lign{right}
}

\def\cpgetitle@align#1#2#3{\csletcs{#1@align}{fil#2}\csletcs{#1label@align}{fil#3}}
\let\fildefault\relax

\DeclareDocumentCommand\cpgetitle@shape{mmoo}{%
 \csdef{#2@shape}{#1}
 \IfValueTF{#4}
  {\cpgetitle@align{#2}{#3}{#4}}
  {\IfValueT{#3}{\cpgetitle@align{#2}{#3}{#3}}}
}
\def\cpgetitle@format#1{%
 \begingroup\def\cpge@tmpa{\endgroup\titleformat{#1}}%
 \expandafter\cpge@tmpa\expandafter%
}
%%%%%%%%%%%%%%%%%%

%%% Styles des versions internes des commandes de titre 

\cpgetitle@shape{display}{devoir}[center]
\cpgetitle@format{\@devoir}[display]
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

\cpgetitle@format{name=\@devoir, numberless}[display]
	{\csundef@afterexec{hook@beforedevtitle}}
	{\devoirlabel@align%
		\deco@devoirlabelnumberless}
	{\z@}
	{\devoir@align\deco@devoir{#1}}
	[\csundef@afterexec{hook@afterdevtitle}]
\titlespacing*{\@devoir}{\z@}{-1cm}{*6}



%%%%% L'équivalent de \section
\cpgetitle@shape{hang}{section}[default]
\cpgetitle@format{\section}[\section@shape]
  {\LARGE\scshape}
  {\sectionlabel@align\deco@sectionlabel{\label@section}}
  {1pc}
  {\section@align\deco@section{#1}}
\titlespacing*{\section}{\z@}{*3}{*2}

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
\cpgetitle@shape{display}{problem}[center]
\def\link@problemlabel#1{%
\edef\cpge@tmpa{#1}%
\unless\ifx\cpge@tmpa\space%
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
\fi}
\cpgetitle@format{\@problem}[\problem@shape]
  {\LARGE}
  {\problemlabel@align
  	\link@problemlabel{\cnt@name}}
  {\z@}
  {\unless\ifcpge@tmpswa\problem@align\deco@problem{#1}\fi}
  [\after@problemtitle]
\cpgetitle@format{name=\@problem, numberless}[\problem@shape]
  {\LARGE}
  {\problemlabel@align\deco@problemlabelnumberless{}}
  {\z@}
  {\unless\ifcpge@tmpswa\problem@align\deco@problem{#1}\fi}
  [\after@problemtitle]
\titlespacing*{\@problem}{\z@}{*3}{*3}

%%%%%%

%%% \parti, à utiliser dans \problem ou \exercise
\setcounter{secnumdepth}{4}
\titleformat{\parti}
  {\large\scshape}
  {\deco@partilabel{\label@parti}}
  {.5em}
  {\protect\boldmath\bfseries\deco@parti{#1}}
\titlespacing*{\parti}{\z@}{*3}{*1.5}

%%% \partii, soupartie, subdivision de \parti
\titleformat{\partii}
  {\scshape}
  {\deco@partiilabel{\label@partii}}
  {6pt}
  {\protect\boldmath\bfseries\deco@partii{#1}}
\titlespacing*{\partii}{\z@}{*3}{*1.5}

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

%%% Boite tikz générique pour différente déoration
\ifdraft
	\NewDocumentCommand\genboxcmd{O{} +m}{%
		\fbox{#2}%
	}
\else 
	\tikzset{generic style/.style={fill=none, draw=maincol, inner sep = 3pt, rounded corners=3pt}}
	\RenewDocumentCommand\genboxcmd{O{} +m}{%
		\tikz [baseline=(T.base)] \node (T) [generic style, #1] {\strut #2};
	}
\fi

\NewDocumentEnvironment{genbox}{O{} d() +b}{%
	\par\IfValueT{#2}{\textbf{#2}\newline\nobreak}%
	\genboxcmd[#1]{\parbox{\columnwidth}{#3}}
}{}

\def\rslt@box{\genboxcmd}
\cpgedefdeco{formula}{\rslt@box{#1}}
\def\deco@result{\deco@formula}
\xframe@gap=7.2pt
\def\deco@xframe{\rslt@box}
\def\formulabox{\deco@formula}

%%

\cpgedefdeco{sectionlabel}{%
	\genboxcmd[align=left]
		{\normalsize\bfseries#1}%
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
			{\def\cnt@name{#3 \csuse{label@#2}}}%
		\IfValueTF{#4}%
			{\cpge@tmpswafalse%
				\ifdef{\alt@problem}
					{\@problem[\textsc{\cnt@name~:~}\alt@problem]{#4}}
					{\@problem[\textsc{\cnt@name~:~}#4]{#4}}%
			}{\cpge@tmpswatrue\@problem[\textsc{\cnt@name}]{}}%
	}	
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
\cpgenewexeprob{probleme}{Problème}{}{|1|}{du problème}(R)
\cpgenewexeprob{exercice}{Exercice}{}{|1|}{de l'exercice}(E)
\cpgenewexeprob{cours}{Questions de cours}{}{|1|}{des questions de cours}(K)
\cpgenewexeprob{epreuve}{\ifsolution Énoncé\fi}{}{*}{}
\cpgenewexeprob{enonce}{\ifsolution Énoncé\fi}{}{*}{}
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
\let\ttl@savemark\relax
\def\toclevel@@devoir{0}
\def\toclevel@section{1}
\def\toclevel@@problem{2}
\def\toclevel@parti{3}
\def\toclevel@partii{4}
\titlecontents{@devoir}[0em]{}{\Large}{\Large}{\hfill\contentspage}
\titlecontents{section}[0em]{\bigskip}{\Large}{\Large}{\hfill\contentspage}
\titlecontents{@problem}[1em]{\medskip}{\bfseries\boldmath}{\scshape}{\hfill\contentspage}
\titlecontents{parti}[3em]{}{}{\scshape}{\hfill\contentspage}
\titlecontents{partii}[4em]{}{}{}{}

%%% Entrées pour pagestyles
 
\let\@devoirtitle\@empty
\let\sectiontitle\@empty
\let\@problemtitle\@empty
\let\partititle\@empty
\let\partiititle\@empty
\ttl@setifthe{@devoir}
\ttl@setifthe{section}
\ttl@setifthe{@problem}
\ttl@setifthe{parti}
\ttl@setifthe{partii}

% les divisions qui seront marquées pour une utilisation dans pagestyles    
\settitlemarks{@devoir,section,@problem,parti}
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
\long\def\hint@draft#1{\mini(ind)#1\endmini}%
\def\setup@hint{%
	\long\def\hint##1{}%
	\ifdraft
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
\unless\ifdraft\ifhintocg
	\RequirePackage[tikz]{ocgx2}
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

%%% Patch de la commande \item pour qu'elle supporte 
%%% sa présence dans un environnement et qu'elle
%%% ne produise ni numéro ni espaces en cas 
%%% d'un argument optionnel vide. 
\def\item@ques{%
  \@inmatherr\item%
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
        %\addvspace\@topsep
		\ifblank{#1}{}{
			\addvspace{\@topsep}%
			\addvspace{-\parskip}%
		}%
		%\addvspace{-\parskip}%
      \fi
    \else
      \addpenalty\@itempenalty
      %\addvspace\itemsep
	  \ifblank{#1}{}{\addvspace\itemsep}%
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
    \ifblank{#1}{}{\hskip \labelsep}}%
  \ignorespaces}
  
%% Fin du patch
\def\switch@to@ques{\csletcs{deco@\cpge@listctr}{deco@\cpge@listctr @}}
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
		\def\cpge@tmpscore{\ttfamily\footnotesize(#2pt)}%
	}%
	\ifstrequal{#3}{@}{}
            {\addtocounter{\cpge@listctr}{#3}}%
	\IfValueTF{#1}
		{\item@ques[#1]%
			\ifblank{#1}
				{\stepcounter{\cpge@listctr}}
				{}%
			%\hskip-\labelsep%
		}%
		{\item@ques}
	\IfValueT{#4}{\deco@itemtitle{#4}}%
	\IfValueT{#5}{\label{\cpge@enumlabelprefix#5}}%
}
\def\xques{\init@ques{\cpge@withsoltrue\x@ques}}
\def\zques{\init@ques{\cpge@withsolfalse\x@ques}}
\NewDocumentEnvironment{ques}{}{\cpge@withsoltrue\x@ques}{} 
\def\stopques{\exit}
\def\draft@solution{\par\medskip\textbf{\scshape solution :}\newline\nopagebreak}
\def\draft@solution{\par\medskip\textbf{\scshape solution :}\newline\nopagebreak}

\def\save@solution{%\
	\let\endques\close@ques%
	\let\endsolution\close@ques%
	\igprotected@iwrite\solhandle@file{}{\string\xsol}%
	\igfilesave{solhandle}%
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
					\cpgerecord{%
						\string\Solution
							{\cpge@current@id} % identifiant
							{\expandafter\expandonce\csname \cpge@current@id @title\endcsname} % titre (de l'énoncé) 
							{\expandafter\expandonce\csname \cpge@current@id @opts\endcsname} % options passées avec "corrige=..."
							{\queslist}% liste des questions avec solutions
					}%
				}%
			\else	
				\unless\ifstraight\ifdefempty\queslist{}{%
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
				}\fi%
			\fi%
		\fi%		
	\fi%
	\gdef\queslist{}%
}
\def\shipoutsolutions{%
	\unless\ifstraight\ifsolutiondelayed%
		\cpgestoprecording%
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
\unless\ifdraft\tikzset{%
		collink/.style={%
			fill=linkcol, 
			draw=none, 
			text=white},
		soldeco/.style={%
			collink,
			align=center,
			text width=2.4em,
			rounded corners=2.4pt,
			inner ysep=1pt, inner xsep=4pt,
			font=\sffamily\footnotesize\bfseries},
		enodeco/.style={
			align=right,
			text width=1.8em,
			rounded corners=2.4pt,
			inner ysep=1pt, inner xsep=4pt,
			font=\sffamily\footnotesize\bfseries}
	}
\fi%
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

\cpgedeflabel{enumi}{|X|.|1|}
\cpgedeflabel{enumii}{|X|.|Q|.|1|}
\cpgedeflabel{enumiii}{|X|.|Q|.|q|.|1|}

%%%% Décoration du label pour mini
\ifcompact
	\cpgeset[mini]{left margin=16pt, 
		font=\sffamily\footnotesize, 
		label font=\sffamily\scshape\bfseries\footnotesize}
\else
	\cpgeset[mini]{left margin=30pt}
\fi
%%% environnement mini
\ifdraft
\cpgeset[mini]{%
	mini deco=#1.\kern1ex
}
\else
\usetikzlibrary{arrows.meta}
\def\funnyarrow#1#2{%
	\tikz[baseline] 
		\draw [
				line width=\dimexpr\fntht x, #2, 
				-{Round Cap[sep=-1pt] . Fast Round[]}
			] 
        (0,\dimexpr.5\fntht x) -- (#1,\dimexpr.5\fntht x);%
}
\cpgeset[mini]{%
	mini deco=\llap{\funnyarrow{1.2em}{warmcol}}%
		\textcolor{coldcol}{#1.}\kern1ex%
}
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



