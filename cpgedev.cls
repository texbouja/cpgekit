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
	\newif\ifscore
	\newif\ifhintocg
}{}

\newif\ifconvert

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
	hint*/.style={},
	score/.style={},
	book/.code=\def\cpge@class{book},
	report/.code=\def\cpge@class{report},
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


\def\Solution{\Dummy@Solution}
\def\setup@solutionmode{%
	\ifsolutiondelayed\solutiontrue\fi
	\ifsolution\hinttrue\fi%
	\ifsolution
		\def\Solution{\Real@Solution}
	\fi%
	\ifsolutiondelayed
		\cpgestartrecording
	\fi
}
\def\setup@straightmode{%
	\ifstraight
		\ifsolution
			\def\corrige{\Corrige}%
			\let\endcorrige\endCorrige%
		\fi%
	\fi%
}
\AtBeginDocument{%
	\ifdraft\straighttrue\fi%
	\setup@solutionmode%
	\setup@straightmode%
}


%% Declarations 
\newcounter{tmpdo}

\newif\ifsolutionlist
\newif\ifcpge@withsol % vrai si le numero de la question courante doit être un hyperlien 
\newif\ifcpge@tmpswa
\newif\ifcpge@tmpswb

\newtoks\toks@hint % retient l'indication de la question en cours
\newtoks\cpge@toks % token list générique pour multiple usage


%%%%% Mécanisme de chargement des packages
\newif\ifload@tikz
\newif\ifload@hyperref
\newif\ifload@math
\newif\ifload@fonts 

\def\cpgeloadpackage{}



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
%%%%  une version modifiée de subfile.sty renommée en cpgesubfile.sty
%%%  

\cpgesetup[include]{
	solution/.code=\csname solution#1\endcsname\solutiondelayedfalse,
	solution*/.code=\csname solutiondelayed#1\endcsname,
	straight/.code=\csname straight#1\endcsname,
	hint/.is if=hint,
	before solutions/.code=\def\before@solutions@hook{#1},
	solution file/.code=\def\solfilename{#1},
	corrige/.store in=\corr@common@opt,
	only/.code=\csvtolistadd\eno@list{#1}%
}
\def\corr@common@opt{}
\NewDocumentCommand\cpgeinclude{ om }{
	\RenewDocumentCommand\titre{s+o+d()}{}%
	\begingroup
		\IfFileExists{#2-cor.tex}{\def\solfilename{#2-cor}}{}
		\IfValueT{#1}{\cpgesetup[include]{#1}}%
		\setup@solutionmode\setup@straightmode%
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
% ajout de la clé Gm@littlemargin
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
\def\geom@options{}

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
\cpgenewtitlekeyword{devoir}{\Large\bfseries}
\cpgenewtitlekeyword{epreuve}{\large\bfseries}
\cpgenewtitlekeyword{concours}{\huge\bfseries}
\cpgenewtitlekeyword{theme}{\Large\scshape}
\cpgenewtitlekeyword{subtheme}{\large\scshape\itshape}
\cpgenewtitlekeyword{texte}{\tiny\sffamily\slshape} 
\cpgenewtitlekeyword{periode}{\small\itshape}
\cpgenewtitlekeyword{duree}{\small\itshape}
\cpgenewtitlekeyword{session}{\large\itshape Session~}
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
		\renew@title@format[3]{concours}{\bfseries}%
		\renew@title@format[3]{theme}{\scshape}%
		\renew@title@format[2]{subtheme}{\scshape\itshape}%
		\renew@title@format[3]{epreuve}{\scshape}%
		\renew@title@format{periode}{\itshape}%
		\renew@title@format[2]{session}{\itshape Session~}%
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
			\titlepage@formats%
			\csuse{hook@earlybeforetitlepage}%
			\begin{titlepage}%
				\ifbackground\def\back@code{}\fi%
            	\fil@inner@titlepage%
				\csuse{hook@beforetitlepage}%
				\csuse{hook@title@beforetitlepage}%
            		\csuse{cpgetitlepagecontents}%
				\csuse{hook@titleaftertitlepage}%
           		\csuse{hook@aftertitlepage}%
			\end{titlepage}%
			\csuse{hook@lateaftertitlepage}\clearpage%
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

%%% Commandes utilitaires pour switcher vers 
%%% une geometrie particuliere (en 4x3)
%%% pour la page de garde
%%% Par defaut, la page de garde n'est
%%% generee que pour les versions pour ecran
%%% mais peut etre activee ou desactivee avec
%%% l'option "title page" de \cpgetheme 

% \AtEndPreamble{%
% 	\dimdef\paperheight@origin{\paperheight}%
% 	\dimdef\paperheight@titlepage{.75\paperwidth}%
% 	\savegeometry{cpge@origin@geom}%
% }
% \def\titlepage@geometry{%
% 		\newgeometry{%
% 			hmargin=\z@, vmargin=\z@,
% 		} 
% 		%\textheight=\textheight@titlepage
% }
% \colorlet{pagecol}{white}
% \def\restore@geometry{%
% 	\pdfpageheight=\paperheight@origin%
% 	\restoregeometry%
% }
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
\def\cpgeset@colors#1#2#3{%
	\csdef{cpge@#1col}{\ifdark #3\else #2\fi}
}
\cpgesetup[colors]{
	warm/.code 2 args=\cpgeset@colors{warm}{#1}{#2},
	cold/.code 2 args=\cpgeset@colors{cold}{#1}{#2},
	neutral/.code 2 args=\cpgeset@colors{neutral}{#1}{#2},
	main/.code 2 args=\cpgeset@colors{main}{#1}{#2},
	link/.code 2 args=\cpgeset@colors{link}{#1}{#2},
	fg/.code 2 args=\cpgeset@colors{fg}{#1}{#2},
	bg/.code 2 args=\cpgeset@colors{bg}{#1}{#2},
	page/.code 2 args=\cpgeset@colors{page}{#1}{#2},
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
   
\cpgesetup[colors]{    
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
		\AtEndPreamble{\pgfmathsetlength\cpge@ttlw{\cpge@ttlw/#1}} 
}
\cpgesetup[title]{%
	scale/.code=\AtEndPreamble{\pgfmathsetlength\cpge@ttlw{\cpge@ttlw/#1}}
}
\DeclareDocumentCommand\cpgetheme{O{} m}{%
	\cpgesetup[theme]{#1}
	\unless\ifdraft
		\IfFileExists{#2dev.sty}
			{\AtEndPreamble{\RequirePackage{#2dev}}\reloadcolors}
			{}%
	\fi%
}

\DeclareDocumentCommand\cpgeconfig{m}{
	\IfFileExists{cfg-#1.sty}{\RequirePackage{cfg-#1}}{}
}
%%%%%%%%%%%%%%%%%%%%%%%%
%%% Les declarations %%%

% Les variables globales
% quelque soit la configuration, les questions auront chacune un numéro unique.
%\cpgedefcounter est définie dans cpgebase.sty 
\cpgedefcounter{@devoir}{}(D)
\cpgedefcounter{section}{}[@devoir](*S) % (*S) pour écraser le raccourci S
\cpgedefcounter{problem}{}[@devoir](Y) 
\cpgedefcounter{solution}{}
\cpgedefcounter{parti}{}[problem](P)<partie>
\cpgedefcounter{partii}{}[parti](p)<partie>
\cpgedefcounter{bigques}{|I|}[partii](B)<question>
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
\def\cpgetitle@spacing#1#2#3#4{
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
				\deco@@devoirlabel{\@devoir@name}{\label@@@devoir}
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
		{\@devoir@align\deco@@devoir{##1}}
		[\csundef@afterexec{hook@afterdevtitle}]
}
\@devoir@format
\cpgetitle@spacing{\@devoir}{\z@}{-1cm}{*6}
\cpgetitle@setspacing{\@devoir}

%%%%% L'équivalent de \section
\cpgetitle@shape{hang}{section}[default]
\def\section@font{\LARGE\scshape}
\def\section@format{
	\cpgetitle@format{\section}[\section@shape]
  		{\csuse{section@align}\csuse{section@font}}
  		{\deco@sectionlabel{\label@section}}
  		{\z@}
  		{\deco@section{##1}}
}
\section@format
\cpgetitle@spacing{\section}{\z@}{*3}{*2}
\cpgetitle@setspacing{\section}

%%%%% version interne des titres pour les sujets
\def\after@problemtitle{%
	\csundef@afterexec{hook@afterprobtitle}%
	\ifdef{\problemcounter@name}
		{
			\edef\cpge@tmpe{\usevalue{score:\cpge@problem@id}}%
	 		\ifdefvoid{\cpge@tmpe}{}
	 			{\par\normalsize\textit{(sur \cpge@tmpe{} points)}}
		}{}%
}
\cpgetitle@shape{display}{problem}[center]
\def\link@problemlabel#1{%
	\edef\cpge@tmpa{#1}%
	\unless\ifx\cpge@tmpa\space%
		\ifsolution%
			\ifisasolution% 
				\hypertarget{\cpge@problem@id:cor}
					{\hyperlink{\cpge@problem@id:eno}{\deco@problemlabel{#1}}}%
		\else%
			\hypertarget{\cpge@problem@id:eno}
				{\hyperlink{\cpge@problem@id:cor}{\deco@problemlabel{#1}}}%
		\fi%
	\else%
		\deco@problemlabel{#1}%
	\fi%
\fi}
\def\problem@font{\LARGE}
\def\problem@format{%
	\cpgetitle@format{\problem}[\problem@shape]
  		{\csuse{problem@font}}
  		{\problemlabel@align
  			\link@problemlabel{\cnt@name}}
  		{\z@}
  		{\unless\ifcpge@tmpswa\problem@align\deco@problem{##1}\fi}
  		[\after@problemtitle]
	\cpgetitle@format{name=\problem, numberless}[\problem@shape]
  		{\LARGE}
  		{\problemlabel@align\deco@problemlabelnumberless{}}
  		{\z@}
  		{\unless\ifcpge@tmpswa\problem@align\deco@problem{##1}\fi}
  		[\after@problemtitle]
}
\problem@format
\cpgetitle@spacing{\problem}{\z@}{*3}{*3}
\cpgetitle@setspacing{\problem}

%%%%%%

%%% \parti, à utiliser dans {probleme} ou {exercice}
\setcounter{secnumdepth}{5}
\cpgetitle@shape{block}{parti}[right]
\def\parti@font{\large\bfseries}
\def\parti@format{%
	\cpgetitle@format{\parti}[\parti@shape]
  		{\csuse{parti@align}\parti@font}
		{\deco@partilabel{\label@parti}}
		{\z@}
  		{\protect\boldmath\deco@parti{##1}}
}
\parti@format
\cpgetitle@spacing{\parti}{\z@}{*4}{*2}
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
\cpgetitle@spacing{\partii}{\z@}{*3}{*1.5}
\cpgetitle@setspacing{\partii}

%%% \bigques, pour certains sujets de concours (Centrale) 
\titleformat\bigques[runin]
	{\bfseries}
	{\deco@bigques{\label@bigques}}
	{0.5em}
	{#1}
\titlespacing*\bigques{\z@}{*1}{*1}

%%% Variantes de \parti et \partii pour ecrire en plus
%%% les titres dans le ficheir de corrigé
\NewDocumentCommand\wparti{om}{
    \unless\ifdraft
        \cpgeprotected@iwrite\solhandle@file{}
            {\string\parti\IfValueT{#1}{\unexpanded{[#1]}}\unexpanded{{#2}}}
    \fi
    \IfValueTF{#1}{\parti[#1]{#2}}{\parti{#2}}
}
\NewDocumentCommand\wpartii{om}{
    \unless\ifdraft
        \cpgeprotected@iwrite\solhandle@file{}
            {\string\partii\IfValueT{#1}{\unexpanded{[#1]}}\unexpanded{{#2}}}
    \fi
    \IfValueTF{#1}{\partii[#1]{#2}}{\partii{#2}}
}
\NewDocumentCommand\wbigques{om}{%
    \unless\ifdraft
        \cpgeprotected@iwrite\solhandle@file{}
            {\string\bigques\IfValueT{#1}{\unexpanded{[#1]}}\unexpanded{{#2}}}%
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
	\IfBooleanT{#1}{\def\cpge@tmpb{\parti*{\unexpanded{#5}}}}%
	\IfBooleanF{#1}{%
		\IfValueTF{#4}
			{\def\cpge@tmpb{\parti[\unexpanded{#4}]{\unexpanded{#5}}}}
			{\def\cpge@tmpb{\parti{\unexpanded{#5}}}}%
	}%
	\cpge@tmpb%
	\IfValueF{#1}{\IfValueT{#6}{\label{\cpge@labelprefix#6}}}%
	\unless\ifdraft
		\IfBooleanT{#2}{
			\IfValueT{#3}{
				\tokcyclexpress{\cpgesetupsectiontitle{parti={#3}}}
				\cpgeprotected@iwrite\solhandle@file{}{\the\cytoks}
			}
        	\cpgeprotected@iwrite\solhandle@file{}{\@xp\string\cpge@tmpb}%
			\IfValueT{#6}
				{\cpgeprotected@iwrite\solhandle@file{}
            		{\string\label{cor:\cpge@problem@id:#6}}}%
		}%
    \fi%
}
\NewDocumentCommand\souspartie{ s t\w e{\op} o D(){} d<> }{
	\IfValueT{#3}{\cpgesetupsectiontitle{partii={#3}}}%
	\IfBooleanT{#1}{\def\cpge@tmpb{\partii*{\unexpanded{#5}}}}%
	\IfBooleanF{#1}{%
		\IfValueTF{#4}
			{\def\cpge@tmpb{\partii[\unexpanded{#4}]{\unexpanded{#5}}}}
			{\def\cpge@tmpb{\partii{\unexpanded{#5}}}}%
	}%
	\cpge@tmpb%
	\IfValueF{#1}{\IfValueT{#6}{\label{\cpge@labelprefix#6}}}%
	\unless\ifdraft
		\IfBooleanT{#2}{
			\IfValueT{#3}{
				\tokcyclexpress{\cpgesetupsectiontitle{partii={#3}}}
				\cpgeprotected@iwrite\solhandle@file{}{\the\cytoks}
			}
        	\cpgeprotected@iwrite\solhandle@file{}{\@xp\string\cpge@tmpb}%
			\IfValueT{#6}
				{\cpgeprotected@iwrite\solhandle@file{}
            		{\string\label{cor:\cpge@problem@id:#6}}}%
		}%
    \fi%
}


%%%%%% Surcouches des commandes de titrages

%% Ajout d'une métadonnée devoir pour une utilisation avec \titre 

\cpgeaddkeyword{title}{devoir}{{\LARGE\scshape\csuse{deco@devoir}{\csuse{cpge@devoir}}%
                  \global\cpge@dima\baselineskip}\baselineskip\cpge@dima}

\def\deco@devoir#1#2{{\huge#1} \\ #2}
\def\deco@devoirlabel#1#2{#1\ #2}
\cpgesetdeco{devoirlabelnumberless}{}

\cpgesetup[@devoir]{%
	name/.store in=\devoir@name,
	name=sujet,
	number/.code=\setcounter{@devoir}{\numexpr#1-1},
	after title/.code=\title@parser{\begingroup#1\endgroup}%
		\@xp\def\@xp\hook@afterdevtitle\@xp{\title@contents},
	before title/.code=\title@parser{\begingroup#1\endgroup\par}%
		\@xp\def\@xp\hook@beforedevtitle\@xp{\title@contents},
	title deco/.code=\cpgesetdeco{devoir}{#1},
	label deco/.code=\cpgesetdeco{devoirlabel}{#1},
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
\tikzset{generic style/.style={fill=none, draw=maincol, inner sep = 3pt, rounded corners=3pt}}
	\RenewDocumentCommand\genboxcmd{O{} +m}{%
		\tikz [baseline=(T.base)] \node (T) [generic style, #1] {\strut #2};
	}
	\cpgesetdeco{formula}{\genboxcmd{#1}}
	\cpgesetdeco{result}{\genboxcmd[double distance=.6pt, line width=1.2pt, inner sep=4pt, fill=maincol!5!bgcol, draw=bgcol, double=maincol]{#1}}
\fi 
\xframe@gap=7.2pt
\def\deco@xframe{\genboxcmd}
%%
\cpgesetdeco{sectionlabel}{%
	\genboxcmd[align=left]
		{\normalsize\bfseries#1}%
	}
\cpgesetdeco{section}{\protect\boldmath\bfseries #1}
\cpgesetlabel{parti}{|I|}
\cpgesetdeco{partilabel}{\bfseries#1.\enkskip}
\cpgesetdeco{parti}{#1}
\cpgesetlabel{partii}{|P|.|A|}
\cpgesetdeco{partiilabel}{\bfseries#1.\enkskip}
\cpgesetdeco{partii}{#1}
\cpgesetdeco{bigques}{#1 --}

\def\partiautorefname{partie}
\def\partiiautorefname{partie}
\def\questionautorefname{question}
\def\solutionautorefname{solution}

%%%%%%%
\newif\ifisasolution
\cpgesetdeco{problem}{{#1 }}
\cpgesetdeco{problemlabel}{%
	{\Large\scshape\bfseries%
	\deco@lpattern\enskip#1\enskip\deco@rpattern}%
}
\cpgesetdeco*{lpattern}{\cpgesquare}
\cpgesetdeco*{rpattern}{\cpgesquare}

\cpgesetup[@problem]{%
	solution/.code=\csuse{solution#1}\solutiondelayedfalse,
	solution*/.is if=solutiondelayed,
	hint/.is if=hint,
	hint*/.is if=hintocg,
	solution/.default=true,
	solution*/.default=true,
	hint/.default=true,
	hint*/.default=true,
	current counter/.code=\letcs\thecurrent@counter{the#1},
	before/.store in=\hook@beforeproblem,
	after/.store in=\hook@afterproblem,
	before title/.code=\title@parser{#1}%
		\@xp\long\@xp\def\@xp
		 \hook@beforeprobtitle\@xp{\title@contents},
	after title/.code=\title@parser{#1}%
		\@xp\long\@xp\def\@xp\hook@afterprobtitle
		 \@xp{\title@contents},
	label/.code=\@xp\cpgesetlabel\@xp{\problemcounter@name}{#1},
	title deco/.code=\cpgesetdeco{problem}{#1},
	label deco/.code=\cpgesetdeco{problemlabel}{#1},
	corrige/.code=\csgpreto{\cpge@problem@id @opts}{#1,}, 
}
\cpgesetup[solution]{
	before/.store in=\hook@beforeproblem,
	after/.store in=\hook@afterproblem,
	before title/.code=\title@parser{#1}%
		\@xp\long\@xp\def\@xp
		 \hook@beforeprobtitle\@xp{\title@contents},
	after title/.code=\title@parser{#1}%
		\@xp\long\@xp\def\@xp\hook@afterprobtitle
		 \@xp{\title@contents},
	questions list/.store in=\queslist,
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
				\ifcsundef{\cpge@problem@id @list}{}
					{\edef\queslist{\csuse{\cpge@problem@id @list}}}%
			\fi% 
			\def\xref{\xref@cor}%
			\edef\cpge@labelprefix{cor:\cpge@problem@id:}%
		\else%
			\ifcsdef{eno:\cpge@problem@id}
				{\ClassError{cpgedev}{\problemcounter@name\space\arabic{\problemcounter@name}\space:\space
				  Identifiant\space \cpge@problem@id\space déjà\space utilisé}{}}
				{\csgdef{eno:\cpge@problem@id}{}%
					\csxdef{label@@\cpge@problem@id}{%
						\csuse{dudela@\problemcounter@name}\space
				  		 \csuse{label@\problemcounter@name}%
					}%
				}%
			\def\xref{\xref@eno}%
			\edef\cpge@labelprefix{eno:\cpge@problem@id:}%
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
		d() % #5 optional title
		d<> % #6 optional label for referencing
	}{%
		\IfBooleanF{#1}{%
			\IfValueTF{#6}
				{\refstepcounter{#2}}
				{\stepcounter{#2}}%
			}%
		\IfBooleanTF{#1}
			{\def\cnt@name{#3}}
			{\def\cnt@name{#3 \csuse{label@#2}}}%
		\IfValueTF{#5}% 
			{\cpge@tmpswafalse%
				\begingroup%
					\edef\cpge@tmpa{\endgroup\@nx\problem[{\@nx\textsc{\cnt@name}\IfValueTF{#4}{:\space#4}{:\space#5}}]{#5}}
			}{\cpge@tmpswatrue%
				\begingroup%
					\edef\cpge@tmpa{\endgroup\@nx\problem[{\@nx\textsc{\cnt@name}\IfValueT{#4}{:\space#4}}]{}}}%
		\LinkTargetOff\cpge@tmpa\LinkTargetOn%
		\IfValueT{#6}{%
			\IfValueTF{#5}
				{\protected@edef\@currentlabelname{#5}}
				{\IfValueTF{#4}{\protected@edef\@currentlabelname{#4}}}%
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
\DeclareDocumentCommand\cpgenewproblem{%
		s %* corrige or enonce
		m %2 counter name
		m %3 printed name
		o %4
		m %5 before hook for the solution title
		m %6 counter label format
		m %7 solution title prefix
		d() %8 counter shortcut
		}{%
	\csdef{hook@precor@#2}{#5}
	\IfValueTF{#8}
		{\cpgedefcounter{#2}{#6}[@devoir](#8)}
		{\cpgedefcounter{#2}{#6}[@devoir]}%
		\IfValueTF{#4}
			{\csgdef{#2autorefname}{#4}}
			{\csxdef{#2autorefname}{\MakeLowercase{#3}}}
	\csgdef{dudela@#2}{#7}%
	\IfBooleanT{#1}{%
		\NewDocumentEnvironment{#2}{m +e\op o d() d<>}
			{%
				\ifblank{##1}{}{\def\cpge@problem@id{##1}}%
				\def\problemcounter@name{#2}%
				\IfValueT{##2}{\cpgesetup[solution]{##2}}%
				\csuse{hook@precor@#2}%
				\csuse{hook@beforeprobtitle}
				\setup@id%
				\@problemtitle{#2}{#3}[##3](##4)<##5>%
				\csuse{hook@afterprobtitle}
				\csuse{hook@beforeproblem}%
			}{%
				\endxsol%
				\csuse{hook@afterproblem}%
			}%
	}
	\IfBooleanT{#1}{%
		\NewDocumentEnvironment{#2*}{m +e\op o d() d<>}%
			{%
			\ifblank{##1}{}{\def\cpge@problem@id{##1}}%
				\def\problemcounter@name{#2}%
				\IfValueT{##2}{\cpgesetup[solution]{##2}}%
				\csuse{hook@precor@#2}%
				\csuse{hook@beforeprobtitle}
				\setup@id%
				\@problemtitle*{#2}{#3}[##3](##4)<##5>%
				\csuse{hook@afterprobtitle}
				\csuse{hook@beforeproblem}%
			}{%
				\endxsol%
				\csuse{hook@afterproblem}%
			}%
	}
	\IfBooleanF{#1}{%
		\NewDocumentEnvironment{#2}{m +E{\op}{{}} o +d() d<>}{%
			\ifblank{##1}{}{\def\cpge@problem@id{##1}}%
			\def\problemcounter@name{#2}%
			\csepreto{\cpge@problem@id @opts}{\@xo\corr@common@opt,}%
			\cpgesetup[@problem]{current counter=#2,##2}%
			\ifsolutiondelayed\solutiontrue\fi%
			\ifcsundef{##1@title}{\csdef{##1@title}{[##3](##4)}}{}%
			\setup@id%
			\@problemtitle{#2}{#3}[##3](##4)<##5>%
			\setup@sol%
			\setup@hint%
			\csuse{hook@beforeproblem}%
		}{%
			\exit%
			\csuse{hook@afterproblem}%
			\close@problem{#2}%
		}%
	}
	\IfBooleanF{#1}{%
		\NewDocumentEnvironment{#2*}{m +E{\op}{{}} o +d() d<>}{%
			\ifblank{##1}{}{\def\cpge@problem@id{##1}}%
			\def\problemcounter@name{#2}%
			\csepreto{\cpge@problem@id @opts}{\@xo\corr@common@opt,}%
			\cpgesetup[@problem]{current counter=#2,##2}%
			\ifsolutiondelayed\solutiontrue\fi%
			\ifcsundef{##1@title}{\csdef{##1@title}{[##3](##4)}}{}%
			\setup@id%
			\@problemtitle*{#2}{#3}[##3](##4)<##5>
			\setup@sol%
			\setup@hint%
			\csuse{hook@beforeproblem}%
		}{%
			\exit%
			\csuse{hook@afterproblem}%
			\close@problem{#2}%
		}%
	}
}
\cpgesetdeco{pattern}{}
\cpgenewproblem{probleme}{Problème}[problème]{}{|1|}{du problème}(R)
\cpgenewproblem{exercice}{Exercice}[exercice]{}{|1|}{de l'exercice}(E)
\cpgenewproblem{cours}{Questions de cours}{}{|1|}{des questions de cours}(K)
\cpgenewproblem{epreuve}{\ifsolution Énoncé\fi}[sujet]{}{*}{}
\cpgenewproblem{enonce}{\ifsolution Énoncé\fi}[sujet]{}{*}{}
\cpgenewproblem*{Corrige}{}[corrigé]{\isasolutiontrue\setup@xsol}{}{}
\def\label@Corrige{Corrigé\ignorespaces\csuse{label@@\cpge@problem@id}}

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
	\eappto\cpge@tmpe{\@nx\xhint{\csuse{label@\hintctr}}}
	\appto\cpge@tmpe{#1\par}
	\@xp\global\@xp\toks@hint\@xp{\cpge@tmpe}
\@esphack}
\def\xhint#1{%
	\hypertarget{hint:\cpge@problem@id:#1}%
		{\hyperlink{eno:\cpge@problem@id:#1}%
			{\deco@link@sol{#1}\enskip}}%
}
\def\x@hint{%
	\set@xhint%
	\hyperlink{hint:\cpge@problem@id:\csuse{label@\hintctr}}{\hintradio}%
	}

%%%%%%%%%%%%% Le style des numeros de questions %%%%%%%%%%%%%

\NewDocumentCommand\listbox{O{}m}{#2}
\processed@maxlabelwidth=2em\relax
\unless\ifdraft\unless\ifprint
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
			fill=linkcol, 
			draw=none, 
			text=white},
		enodeco/.style={%
			text width=\curr@textwidth,
			}
	}
\fi\fi%
\let\show@quesscore\relax
\cpgesetdeco{link@}{%
	\show@quesscore%
	\ifcpge@withsol%
		\hypersetup{linkcolor=white}%
		\hypertarget%
			{hyeno:\cpge@problem@id:\csuse{label@\cpge@listctr}}%
			{\hyperlink{hysol:\cpge@problem@id:\csuse{label@\cpge@listctr}}{%
				\listbox[enodeco, collink, align=right]{#1}}%
			}%
	\else%
		\listbox[enodeco, align=center]{#1}%
	\fi%
}
\cpgesetdeco{nolink@}{%
	\show@quesscore\listbox[enodeco, align=center]{#1}%
}
\cpgesetdeco{emptylabel}{\listbox{#1}}
%%%%% hyperlien ou pas 
\def\set@solutionslinks{
	\edef\score@width{\dimexpr\score@placement\@enumdepth\relax}%
	\def\outerdeco@list{%
		\ifcpge@withsol%
			\@xp\deco@link@%
		\else%
			\@xp\deco@nolink@%
		\fi%
	}
}
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
	\def\arraystretch{.55}%
	\raisebox{\fntht 1}{\tabular[t]{@{}c@{}}\in@parser\cpge@tab@row{#1}\endtabular}%
}
\cpgesetdeco{quesscore}{#1\kern\p@\vrule\kern3\p@}
\def\print@score#1{\ifscore%
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
\let\endquestions\exit 
\NewDocumentCommand\startques{!t\r E{\op}{{}} }{%
	\IfBooleanTF{#1}%
		{\begin{xenum}\op{switchdeco,r,#2}}%
		{\begin{xenum}\op{switchdeco,#2}}%
	\set@solutionslinks%
	%\csshow{prop@\cpge@listctr}
}
\NewDocumentCommand\init@ques{m !t- !t- !t- !t\r !t+  E{\op}{{}} }{%
	\IfBooleanTF{#5}%
        {\startques\r\op{#7}}%
        {\IfBooleanT{#6}{\startques\op{#7}}}%
	\IfBooleanT{#2}{\exit-\IfBooleanT{#3}{\exit-\IfBooleanT{#4}{\exit-}}}%
	#1%
}
\NewDocumentCommand\x@ques{o E{\sc\zp}{{}{@}} d() d<>}{%
	\ifblank{#2}{}{%
		\global\c@score@tmp=\numexpr\c@score@tmp+#2\relax%
		\def\show@quesscore{\print@score{#2}}%
	}%
	\ifstrequal{#3}{@}{}%
            {\addtocounter{\cpge@listctr}{#3}}%
	\IfValueTF{#1}%
		{\cpge@item[#1]%
			\ifblank{#1}%
				{\stepcounter{\cpge@listctr}}%
				{}%
		}%
		{\cpge@item}%
	\ifcpge@withsol%
		\IfValueTF{#5}{\gdef\ques@label@{#5}}{\gdef\ques@label@{}}%
		\xappto\queslist{{\csuse{label@\cpge@listctr}}{\ques@label@},}
	\fi%
	\begingroup%
	\IfValueT{#4}{\def\@currentlabelname{#4}\deco@itemtitle{#4}}%
	\IfValueT{#5}{%
		\MakeLinkTarget[question]{Item}%
		\ifblank{#5}%
			{\label{\cpge@labelprefix\csuse{label@\cpge@listctr}}}%
			{\label{\cpge@labelprefix#5}}%
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
		\hypertarget{hyeno:#1}{}
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
	\hypertarget{hysol:#1}%
		{%
			\hyperlink{hyeno:#1}{%
				\deco@link@sol{\fontsize{12}{12}\selectfont\faHandOLeft}}
			\hskip\labelsep%
		}%
}

\NewDocumentCommand\draft@save{!o!d()!d<>}{%
	\ifsolution%
		\par\medskip\let\start@sol\relax%
		\def\endsolution{\par\medskip}%
	\else%
		\let\start@sol\comment%
		\let\endsolution\endcomment
	\fi%
	\start@sol%
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
\NewDocumentCommand\draft@write{o}{\slshape\csdef{endsolution*}{\aftergroup\par}}
\NewDocumentCommand\real@write{!o}{\cslet{endsolution*}\endcpgefilesave\cpgefilesave{solhandle}}
\def\aux@dir{tmp}
\def\setup@sol{%
	\ifsolution\hinttrue\fi%
	\let\solution\draft@save%
	\cslet{solution*}\draft@write
	\open@solfile%
}
\long\def\writetosol#1{
    \ifdraft
		#1%
	\else
        \cpgeprotected@iwrite\solhandle@file{}{\unexpanded{Commande #1}}
    \fi
}
\def\open@solfile{%
		\unless\ifdraft
			\cpgeopenfile{solhandle}[\aux@dir/\cpge@problem@id-cor]%
			\let\solution\real@save%
			\cslet{solution*}\real@write%
		\fi%
}
\NewDocumentEnvironment{cpgewrite}{mm !e\op o !d() !d<>}
	{%
		\IfValueT{#3}{\csgdef{#2@opts}{#3}}%
		\IfValueT{#4}{\csgdef{#2@title}{[#4](#5)}}%
		\IfValueT{#5}{\csgdef{#2@label}{#6}}%
		\cpgewriteonce{\aux@dir/#2-#1}%
	}
	{\endcpgewriteonce}
\def\corrige#1{\def\cpge@problem@id{#1}\begingroup\cpgewrite{cor}{#1}}
\def\endcorrige{%
	\endcpgewrite\endgroup%
	\csuse{Solution@\cpge@problem@id}%
	}
\csdef{corrige*}{\corrige}
\cslet{endcorrige*}\endcorrige
\cpgenewproblem*{scorrige}{}{\isasolutiontrue\setup@xsol}{}{}
\def\queslist{}
\csdef{cpgeval@mines24m2@defined}{}
\def\close@problem#1{%
	%\ifnum\c@score@tmp>\z@%
		\defvalue{score:\cpge@problem@id}{\thescore@tmp}%
		\global\c@score=\numexpr\c@score+\c@score@tmp\relax%
	%\fi%
	\ifstraight
		\csxdef{\cpge@problem@id @list}{\queslist}%
	\fi%
	\csxdef{\cpge@problem@id @maxlabelwidth}{\the\@maxlabelwidth}%
	\global\@maxlabelwidth\z@%
	\long\edef\cpge@tmpe{\the\toks@hint}%
	\ifdefempty\cpge@tmpe{}{\parti*{Indications}\cpge@tmpe}%
	\unless\ifdraft%
		\cpgeclosefile{solhandle}%
		\ifsolutiondelayed
				\ifdefempty{\queslist}{}{%
					\cpgerecord{%
						\string\Solution
							\cpge@problem@id % identifiant
							\@xp\@xo\csname \cpge@problem@id @title\endcsname % titre (de l'énoncé) 
							{\@xp\@xo\csname \cpge@problem@id @opts\endcsname} % options passées avec "corrige=..."
							{\queslist}% liste des questions avec solutions
					}%
				}%
			\else	
				\ifdefempty\queslist{}{%
					\csxdef{\cpge@problem@id cor}{%
						\@nx\Solution%
							\cpge@problem@id % identifiant
							\@xp\@xo\csname \cpge@problem@id @title\endcsname % titre (de l'énoncé) 
							{\@xp\@xo\csname \cpge@problem@id @opts\endcsname} % options passées avec "corrige=..."
							{\queslist}% liste des questions avec solutions
					}%
					\@xp\aftergroup\csname\cpge@problem@id cor\endcsname%
				}%
			\fi%
	\fi%
	%\show\queslist%
	\gdef\queslist{}%
}
\def\shipoutsolutions{%
	\unless\ifstraight%
		\cpgestoprecording%
		\csuse{before@solutions@hook}%
		\input{\jobname.rec}
	\fi%
}	
\let\corriges\shipoutsolutions
\def\Real@Solution#1[#2](#3)#4#5{
	\Ifcpge@FileEmpty{\aux@dir/#1-cor.tex}
		{%
			\csgdef{Solution@#1}{\Solution #1[#2](#3){#4}{#5}}
		}{%
			\begin{Corrige}{#1}\op{#4}[#2](#3)
				\ifdefempty\queslist{\def\queslist{#5}}{}%
				\ifdefempty\queslist{\noqueslistmessage}{}%
				\input{\aux@dir/#1-cor}
			\end{Corrige}%
	}%
}
\def\Dummy@Solution#1[#2](#3)#4#5{}


%%%% Références croisées %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% \xref pour gestion des référence croisées des questions, parties, ....
\cpgesetdeco{pageref}{\sffamily\smaller{}[p. #1]}
\def\set@pageref{\@ifstar{\set@pageref@eno}{\set@pageref@cor}}
\def\set@pageref@eno#1{%
	\ifcsdef{r@eno:\problem@id:#1}%
		{\def\pageref@eno{%
			\ \deco@pageref{\pageref*{eno:\problem@id:#1}}}%
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
		\ifprint%
			\set@pageref*{#9}%
		\else%
			\IfValueT{#6}{\set@pageref*{#9}}%
		\fi%
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
	\def\problem@id{#8}%
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
		\ifprint%
			\set@pageref{#9}%
		\else%
			\IfBooleanT{#6}{\set@pageref{#9}}%
		\fi%
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
					\def\x@ref{\ignorespaces%
						\xref@ref{eno:\problem@id:#9}\pageref@eno%
						\space(\xref@ref{cor:\problem@id:#9}\pageref@cor)%
					}%
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
\NewDocumentCommand\xref@numeno{t\n m}{%
	\IfBooleanTF{#1}{\def\ques@arn{}}{\let\ques@arn\questionautorefname}%
	\hyperlink{hyeno:\problem@id:#2}{\ques@arn\space#2}%
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
%%% \xsol la commande magique
%%% pour numéroter les questions dans le fichier de solutions  
\def\xsol@env{%
	\solutionlisttrue
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
\def\endxsol{\ifsolutionlist\endlist\fi}
\def\setup@xsol{\let\xsol\first@xsol}

\def\get@itemandlabel#1#2{\def\curr@item{#1}\def\curr@label{#2}}
\def\queslist@pop#1\cpge@nil{
	\in@{,}{#1}
	\ifin@
		\queslist@pop@#1\cpge@nil%
	\else
		\ifblank{#1}{\def\curr@item{FixMe}}{\get@itemandlabel#1}%
	\fi%
}
\def\queslist@pop@#1,#2\cpge@nil{%
	\get@itemandlabel#1%	
	\def\queslist{#2}%
}
\def\first@xsol{%
	\ifdefempty\queslist%
		{\def\xsol{\alt@xsol}}
		{\def\xsol{\real@xsol}}%
	\xsol@env\xsol%
}
\DeclareDocumentCommand\alt@xsol{od()d<>}{%
	\IfValueTF{#1}
		{\item[#1]}
		{\item[\scshape fixme]}%
	\begingroup%
	\IfValueT{#2}{\def\@currentlabelname{#2}\deco@unitetitle{#2}\par\nobreak}%
	\IfValueT{#3}{%
		\MakeLinkTarget[solution]{Item}%	
		\def\@currentlabel{#1}%
 		\phantomsection\label{\cpge@labelprefix#3}%
	}%
	\endgroup%
}
\DeclareDocumentCommand\real@xsol{od()d<>}{%
	\IfValueTF{#1}
		{\def\curr@item{#1}}
		{\@xp\queslist@pop\queslist\cpge@nil}%
	%\show\curr@item
	\item[\curr@item]%
	\begingroup%
	\IfValueT{#2}{\def\@currentlabelname{#2}\deco@unitetitle{#2}\par\nobreak}%
	\IfValueTF{#3}{
		\def\@currentlabel{\curr@item}%
 		\phantomsection%
		\MakeLinkTarget[solution]{Item}%
		\ifblank{#3}
			{\label{\cpge@labelprefix\curr@item}}
			{\label{\cpge@labelprefix#3}}%
	}{%
		\ifdefvoid{\curr@label}{}{%
			\def\@currentlabel{\curr@item}%
 			\phantomsection%
			\MakeLinkTarget[solution]{Item}%
			\label{\cpge@labelprefix\curr@label}%
		}%
	}%
	\endgroup
}
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
	\hypertarget{hysol:\cpge@problem@id:#1}%
		{\hyperlink{hyeno:\cpge@problem@id:#1}%
			{\deco@link@sol{#1}}}%
}
\unless\ifdraft
	\tikzset{soldeco/.style={collink, text width=\csuse{\cpge@problem@id @maxlabelwidth}}}
\fi%
\cpgesetdeco{link@sol}
	{\listbox[soldeco, align=left]{#1}}




%%%% Markup des questions par défaut  %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% styles des compteurs par défaut 
\cpgesetlabel{enumi}{|X|.|1|}
\cpgesetlabel{enumii}{|X|.|Q|.|1|}
\cpgesetlabel{enumiii}{|X|.|Q|.|q|.|1|}
\cpgesetdeco{enumi}{\bfseries#1.}
\cpgesetdeco{enumii}{\bfseries#1.}
\cpgesetdeco{enumiii}{\bfseries#1.}
\unless\ifdraft
	\unless\ifprint 
		\cpgesetdeco{enumi}{\bfseries#1}
		\cpgesetdeco{enumii}{\bfseries#1}
		\cpgesetdeco{enumiii}{\bfseries#1}
	\fi 
\fi

\AtBeginDocument{
	\ifcompact
		\cpgesetenum*{1}{marge*}
		\cpgesetenum*{2}{marge*}
	\else	
		\cpgesetenum*{1}{marge}
		\cpgesetenum*{2}{marge*}
	\fi
}

%%%% Décoration du label pour mini
\ifcompact
	\cpgesetup[mini]{left margin=16pt, 
		font=\sffamily\footnotesize, 
		label font=\sffamily\scshape\bfseries\footnotesize}
\else
	\cpgesetup[mini]{left margin=30pt}
\fi
%%% environnement mini
\ifdraft
\cpgesetup[mini]{%
	deco=#1.\kern1ex
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
\cpgesetup[mini]{%
	deco=\llap{\funnyarrow{1.2em}{warmcol}}%
		\textcolor{coldcol}{#1.}\kern1ex%
}
\fi


%%%% Différents réglages
\newcommand\cpgehypersetup[2]{
	\ifcsdef{cpge@#2}{\hypersetup{pdf#1=\csuse{cpge@#2}}}{}
}
\AtBeginDocument{%
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



