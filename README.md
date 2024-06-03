# cpgekit

 Kit LaTeX pour la production de devoirs destinés aux classes préparatoires ainsi que de planches d'exercices et éventuellement de corrigés des épreuves écrites de concours. 

## Fonctionnalités gérées :

- thémable (à la Beamer) ;
- production conditionnelle des solutions ;
- séparation encore plus poussée entre éléments de presentation et sémantique ; 
- différents formats pour la sortie PDF (imprimante ou écran) ;
- création de liens hypertextes entre les questions et leurs solutions ;
- structures pour faciliter la gestion des numérotations et leurs styles (sections, listes ...) ;
- différents type de listes, les usuels enumerate et itemize repensés, mais aussi d'autres listes pour les discussions, mise en valeur des conditions/conséquences,
- une hiérarchie des sections plus adaptée à un document/devoir avec gestion des tables de matières et tête/pieds de page ;
- capacité de gestion de documents longs avec une inclusion intelligente de fichiers sources ;
- des structures efficaces pour la saisie de texte mathématique (modes display spécifiques, délimiteurs, dérivation, cadres pour les résultats ... )
- possibilité d'insérer de petits morceaux de texte normal à gauche et/ou à droite d'une formule en mode display ;
- commandes usuelles du mode mathématique les plus fréquemment utilisées par les programmes de CPGE ;

# ToDo

- Guide d'installation (TeXLive et MikTeX) ;
- Manuel de l'utilisateur ;
- Guide de référence ;

# Stratégie d'inclusion/compilation

- Il est possible de travailler C'est la commande `\cpgeinclude`

- Si l'option `straight` de la classe est active (`\straightrue`) la définition de l'environnement `corrige` est changée pour que son contenu soit compilé et immédiatement intégré au fichier PDF ;

- Si l'option `straight` de la classe n'est active (`\straighfalse`) alors :
  
  - l'environnement corrigé se contente d'écrire son contenu dans un fichier dont le nom est `<identifiant>-cor` ;
  - c'est l'environnement `enonce` qui est responsable de l'inclusion ou non du fichier de corrigé avec le même identifiant selon les options de la classe ;
    - avec l'option `solution` de la classe, dès que l'environnement `enonce` a fini de traiter son contenu, il vérifie si un fichier de corrigé qui a le même identifiant existe et a une taille non nulle. Le cas échéant il fait appel à la commande `\Solution` pour intégrer le contenu de ce dernier fichier dans le PDF. Si ce fichier n'a pas été rendu disponible auparavant, `\Solution` se contente de s'enregistrer elle même dans une autre commande avec un nom `\Solution@<identifiant>`. Si plus tard le compilateur rencontre un environnement `corrige` avec un même identifiant que l'énoncé, celui-ci écrit son contenu dans un fichier et fait appelle à la commande `\Solution@<identifiant>` pour insérer son contenu dans le PDF ;
    - avec l'option `solution*` de la classe, chaque environnement `enonce` ou similaire (`epreuve`,`probleme`, `exercice`...) enregistre une entrée `\Solution` qui lui est spécifique dans un fichier spécial (`\jobname.rec`). Plus tard c'est la commande `\corriges` insérée à un endroit arbitraire choisi par le rédacteur qui inclus le contenu de `\jobname.rec` et le vide pour une éventuelle nouvelle séquence.
    - sans l'une des deux options `solution` ou `solution*` l'opération d'inclusion des fichiers de corrigés est ignorée. 
  
  ### Remarques
  
  Le comportement avec l'option `straight` est limpide et suffit pour des situations simples. Dans le cas où elle n'est pas utilisé le système devient plus complexe mais en contre partie devient beaucoup plus souple.  
