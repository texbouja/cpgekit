
%% Adaption de subfile.cls
%% Tribute to Federico Garcia
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{igsubdoc}[2023/11/25 v0.1alpha Multi-file projects (class)]
\RequirePackage{pgfopts}
\RequirePackage{etoolbox}

\newif\ifsubdoc

\newif\ifcours
\newif\ifserie
\newif\ifcolle
\newif\ifsoutien
\newif\ifdraft
\newif\ifigweb
\newif\ifsingleimage
\newif\ifthisfile \thisfiletrue
\newif\ifstraight
\newif\ifprint
\newif\ifnocolors
\newif\ifdark
\newif\ifcompact
\newif\ifsolution
\newif\ifsolutiondelayed
\newif\ifproof
\newif\ifproofdelayed
\newif\ifjustification\justificationtrue
\newif\ifhint
\newif\ifhintocg
\newif\ifstriptitle
\def\class@options{}

\pgfkeys{IGSD/.cd,
	draft/.is if=draft,
	straight/.is if=straight,
	proof/.is if=proof,
	compact/.is if=compact,
	nocolor/.is if=nocolor,
	dark/.is if=dark,
	solution/.code=\solutiontrue\solutiondelayedfalse%
			\justificationfalse,
	solution*/.code=\solutiontrue\solutiondelayedtrue%
			\justificationfalse,
	proof/.code=\prooftrue\proofdelayedfalse%
			\justificationfalse,
	proof*/.code=\prooftrue\proofdelayedtrue%
			\justificationfalse,
	nojustification/.code=\justificationfalse,
	hint/.code=\csuse{hint#1}\csuse{hintocg#1}\justificationfalse,
	hint/.default=true,
	hint*/.code=\csuse{hint#1}\hintocgfalse\justificationfalse,
	hint*/.default=true, 
	cours/.code={%
		\courstrue
		\ifundef{\ig@class}{\def\ig@class{book}}{}
	},
	serie/.code={%
		\serietrue
		\ifundef{\ig@class}{\def\ig@class{article}}{}
	},
	soutien/.code={
		\soutientrue\courstrue
		\def\ig@class{article}
	},
	article/.code={
		\def\ig@class{article}
	},
	report/.code={
		\def\ig@class{report}
	},
	book/.code={
		\unless\ifsoutien
			\def\ig@class{book}
		\fi
	},
	.unknown/.code={
		\expandafter\appto\expandafter\class@options\expandafter		
			{\pgfkeyscurrentname,}
	},
  	master/.code={
    	\def\preamble@file{#1}
 	},
	web/.code=\compacttrue\igwebtrue\def\convert@options{}
		\def\igcomment@list{quiz,notations,#1},
 	web/.default={},
	singleimage/.is if=singleimage,	
}

% \DeclareOption*{%
%   \typeout{Preamble taken from file `\CurrentOption'}%
%   \let\preamble@file\CurrentOption
% }
%\ProcessOptions
\ProcessPgfOptions{/IGSD}
\subdoctrue
\let\@classoptionslist\relax
\def\igdoc@shipoutsolutions{%
	\ifdraft\else
		\edef\ig@tmpe{\the\toks@prv}
			\ifproof
				\ifdefvoid\ig@tmpe{}{\typeoutdemonstrations}
			\fi
		\edef\ig@tmpe{\the\toks@sol}
			\ifsolution
				\ifdefvoid\ig@tmpe{}{\typeoutsolutions}
			\fi
	\fi%
}
\RequirePackage{import}
\let\igsubdoc@documentclass\documentclass
\def\documentclass{%
  \let\documentclass\igsubdoc@documentclass
  \LoadClass
}
\filename@parse{\preamble@file}
\edef\import@path{\filename@area}
\edef\input@path{{\filename@area}}
\input{\preamble@file}
{\makeatletter
  \gdef\import@path{}
}

\AtEndDocument{
	\ifdefstring\igcurrentclass{igdoc}
		{\igdoc@shipoutsolutions}{}
	\ifdefstring\igcurrentclass{igddev}{}{\straighttrue}
}
\endinput
%%
%% End of file `igsubdoc.cls'.