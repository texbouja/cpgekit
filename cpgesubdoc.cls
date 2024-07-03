
%% Adaption de subfile.cls
%% Tribute to Federico Garcia
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{cpgesubdoc}[2023/11/25 v0.1alpha Multi-file projects (class)]
\RequirePackage{pgfopts}
\RequirePackage{etoolbox}

\newif\ifsubdoc

\newif\ifdraft
\newif\ifweb
\newif\ifserie
\newif\ifquiz
\newif\ifsingleimage
\newif\ifstraight
\newif\ifprint
\newif\ifnocolors
\newif\ifdark
\newif\ifcompact
\newif\ifsolution
\newif\ifsolutiondelayed
\newif\ifproof
\newif\ifproofdelayed
\newif\ifhint
\newif\ifhintocg
\newif\ifstriptitle
\newif\ifscore
\def\class@options{}

\pgfkeys{IGSD/.cd,
	draft/.is if=draft,
	straight/.is if=straight,
	compact/.is if=compact,
	nocolor/.is if=nocolor,
	dark/.is if=dark,
	solution/.code=\csname solution#1\endcsname\solutiondelayedfalse,%
	solution/.default=true,
	solution*/.is if=solutiondelayed,
	proof/.code=\csname proof#1\endcsname\proofdelayedfalse,%
	proof/.default=true,
	proof*/.is if=proofelayed,
	hint/.code=\csuse{hint#1}\csuse{hintocg#1},
	hint/.default=true,
	hint*/.code=\csuse{hint#1}\hintocgfalse,
	hint*/.default=true, 
	serie/.is if=serie, 
	.unknown/.code={
		\expandafter\appto\expandafter\class@options\expandafter		
			{\pgfkeyscurrentname,}
	},
  	master/.code={
    	\def\preamble@file{#1}
 	},
	web/.code=\compacttrue\webtrue%
		\ifundef\convert@option{\def\convert@options{}}{}
		\def\cpgecomment@list{#1},
	web/.default={theo,exer,probleme,exercice},
	convert/.code=\appto\convert@options{,#1},
	singleimage/.is if=singleimage,	
}
\def\preamble@file{
	\ClasseError{cpgesubdoc}{Utiliser l'option master= pour undiquer le fichier maitre}{}
}
% \DeclareOption*{%
%   \typeout{Preamble taken from file `\CurrentOption'}%
%   \let\preamble@file\CurrentOption
% }
%\ProcessOptions
\subdoctrue
\ProcessPgfOptions{/IGSD}
\let\@classoptionslist\relax
\RequirePackage{import}
\let\cpgesub@documentclass\documentclass
\def\documentclass{%
  \let\documentclass\cpgesub@documentclass%
  \LoadClass
}
\filename@parse{\preamble@file}
\edef\import@path{\filename@area}
\edef\input@path{{\filename@area}}
\input{\preamble@file}
{\makeatletter
  \gdef\import@path{}
}
%\AtBeginDocument{
%	\ifdefstring\cpgecurrentclass{dev}{}{\straighttrue}
%}
\endinput
%%
%% End of file `cpgesubfile.cls'.