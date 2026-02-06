# Guide d'utilisation de la classe LaTeX `cpgedev`

## Introduction 
### Glossaire 
- **solution :**  la solution d'une question dans un sujet 
- **corrigé :** les solutions de toutes les questions d'un sujet que ce soit un exercice, un problème ou tout l'énoncé d'une épreuve de concours.  
- **liste :**  c'est le nom générique utilisé par LaTeX pour décrire les contenus organisés comme des listes d'items : les liste numérotés (`{enumerate}`),  les listes à puces (`{itemize}`)... 
- **style d'une numérotation:** dans une numérotation, le style désigne la représentation des numéros (chiffres arabes, alphabet latine, chiffres romains...) ainsi que les éventuelles autres informations qui l'accompagnent.  Le style a donc un sens sémantique. Le représentation graphique sera dite une **décoration**.  

### Avertissement 
Ce document peut paraître long, mais il reflète la richesse des fonctionnalités implémentées. Il reste un manuel de l'utilisateur donc il se limite à l'essentiel. La plupart des fonctionnalités sont configurables à travers des mécanismes qui ne seront donc pas tous décris. Aussi, la charte qui permet d'écrire un «theme» n'est pas discutée car elle nécessiterait une description détaillée des mécanismes internes de la classe.  

### De quoi s'agit-il ?
De quoi a-t-on besoin pour la rédaction d'un document de type devoir ou série d'exercices ? Une gestion souple et efficace de la numérotation des questions s'adaptant sans effort aux différents styles (ceux utilisés dans les sujets de concours par exemple). Une gestion des exercices et des problèmes et de leurs éventuelles parties (ce qui inclut la prise en charge d'une table des matières par exemple).  Mais aussi d'un mécanisme qui permet de lier les énoncés à leurs corrigés. 

`cpgedev` est une classe LaTeX offrant des fonctionnalités avancées pour la rédaction de «devoirs».  Elle a été construite pour répondre aux besoins spécifique des classes préparatoire mais son usage n'est pas exclusif et peut s'adapter  à n'importe quel milieu académique où on a besoin de rédiger et maintenir des devoirs.  Cela inclut :
- la possibilité de traiter plusieurs sujets (exercices, problèmes,...) dans un même document. Chaque sujet peut être couplé à son corrigé, dans le même fichier source ou dans un fichier séparé ; 
- la stratégie d'insertion des corrigés dans le PDF final est contrôlée par les options de la classe avec possibilité de reporter leurs intégration dans un lieu décidé par l'utilisateur ; 
- une gestion efficace et personnalisable des numéros de questions et de leurs solutions ainsi que des autres types de listes dans le document ;
- le même degré de personnalisation des titres des sujets et de leurs parties ainsi que  de leur numérotation ;
- création automatique d'hyperliens liant les questions à leurs solutions ;
-  un environnement versatile d'écriture des formules centrées avec possibilité d'insertion d'un texte court à gauche ou à droite de la formule ;
-  gestion des références croisées plus adaptée aux devoirs ; 
-  des environnements basiques pour les rappels de cours (définitions, théorèmes...) ;
-  des environnements spéciaux pour insertion de commentaires, rappels, extensions... 

### Stratégie d'inclusion 
Une méthode d'inclusion de fichiers sources souple et fonctionnellement riche est implémentée :
- très bonne capacité de traiter des documents longs ;  
- possibilité d'ajouter un préambule LaTeX simplifié aux fichiers esclaves pour pouvoir les compiler individuellement sans avoir à le faire à partir d'un fichier maître. 
Pour l'exemple, il est possible de maintenir un unique fichier maître pour tous les devoirs d'une année. Celui-ci contiendra les instructions de bases et les métadonnées  communes et ensuite créer un fichier esclave pour chaque devoir. On peut alors compiler individuellement chaque devoir mais aussi tous les devoirs avec leurs corrigés en un livret unique sans aucun effort d'adaptation supplémentaire.   

### Séparation sémantique/présentation 
De nos jours, il n'est plus concevable de figer la mise en page du document exclusivement pour l'impression. Le média de prédilection des élèves est devenu l'écran (ordinateur, tablette numérique ou même smartphone). Il est donc impératif d'adapter les moyens de production à ces nouvelles exigences. Heureusement LaTeX est depuis le début pensé pour offrir une séparation avancée entre le contenu et sa présentation. 
La classe `cpgedev` offre des mécanismes qui, avec un même fichier source, permettent de produire des documents pour l'impression ou pour d'autres médias.  
Par ailleurs, `cpgedev` est architecturé pour être «thémable» (comme `beamer`par exemple).  Une seule instruction suffit pour changer complètement l'apparence du PDF sans toucher au contenu.  

> **Charte graphique**
> Il est possible d'implémenter  la charte graphique d'un organisme donnée sous forme d'un fichier thème.  Il est même possible de centraliser les fichiers styles dans un service en ligne (comme celui d'Overleaf) pour qu'ils soient directement utilisés par les enseignants et ainsi respecter la charte sans se soucier des détails de l'installation. 

### Conventions
La classe utilise (et abuse) des nouvelles conventions de formation d'une instruction LaTeX. L'ancienne convention des instructions est de la forme  : 
`\commande[<arg optionnel>]{<arg 1>}{<arg 2>}...` 
où `\commande`gère au plus un argument optionnel (nécessairement entre crochets) et zéro ou plusieurs arguments obligatoires (nécessairement entre accolades), l'argument optionnel devant toujours figurer en premier. 

Les nouvelles conventions de la couche LaTeX3 (incluse par défaut dans les distributions TeX principales depuis 2019 déjà) sont plus souples :
- ordonnancement libre des arguments optionnels/obligatoires ;
- possibilité de définir d'autres délimiteurs des arguments optionnels (parenthèses...) ;
- possibilité d'utiliser d'autres modificateurs que celui utilisé par défaut (`*`) par certaines commandes LaTeX ;
- possibilité d'utiliser des embellissements  («embelishments»), comme `_` ou `^` mais aussi n'importe quelle séquence de contrôle TeX valide. C'est une sorte de préfixe à un argument qui aura un rôle spécial. 
Plusieurs commandes de la classe `cpgedev`  ont par exemple l'interface suivante 
```latex
\commande<modificateur>\op{<cle=val>}[<arg optionnel>](<un titre>)<<label>>
``` 
- `<modificateurs>` , s'il est présent et un caractère spécial ou une lettre précédé de `\` (par exemple `*` , `+` , `\n` ....) qui va modifier le comportement de la commande ;
- `\op{<key=val,...>}` `\op` est un embellissement qui va prendre en argument une liste d'options `cle=valeur` et dont le rôle est de configurer un aspect particulier de l'instruction. LaTeX utilise d'habitude les crochets pour ce type d'arguments mais ici `\op` servira à éviter la confusion avec le paramètre `[<arg optionnel>]` et à souligner le rôle de configuration ; 
- `[<arg optionnel]` un argument textuel optionnel qui n'a pas un rôle de configuration. Il sera en général reproduit tel quel dans le PDF. 
- `(<un titre>)` beaucoup de commandes permettent d'insérer optionnellement un intitulé ;
- `<<label>>` pour les commandes qui génèrent une numérotation, cet argument exécute une instruction `\label{<label>}` sur le numéro. 

**Exemple :**  `xques\r(Titre de la question)<ques5>` instruction qui va insérer une question, `\r` est un modificateur qui instruit de reprendre une numérotation interrompue, `Titre de la question` sera utilisé comme intitulé de la question et `ques5` sera utilisé pour placer une référence sur la question. 

> **Convention**
> Dans le descriptif précédent, ainsi que dans la suite de ce document, les caractères `<` et `>` indiquent le contenu variable d'un paramètre dans la description formelle d'une instruction. Il ne font pas partie de l'instruction en cas d'utilisation réelle. 

## Organisations des énoncés et des corrigés

il y a plusieurs environnements pour traiter les énoncés et un unique environnement pour traiter leurs corrigés. Un mécanisme simple est prévu pour coupler entre un énoncé et son corrigé.  

### Environnements pour les énoncés
La classe fournit plusieurs environnements pour encapsuler un énoncé. Tous exigent un argument qui servira d'identifiant pour coupler l'énoncé d'un sujet avec son corrigé. 
-   `\begin{probleme}{<id>}(<titre>)`: Pour un problème. L'argument optionnel `<titre>` (entre parenthèses) est affiché après le label "Problème X". Utilise son propre compteur.
-   `\begin{exercice}{<id>}(<titre>)`: similaire à `probleme`, mais pour un exercice (label "Exercice X"). Utilise un compteur séparé.
-   `\begin{enonce}{<id>}(<titre>)`: Pour un document qui ne comporte qu'un seul sujet (pas de label ni de numéro).
- `\begin{epreuve}{<id>}(<titre>)`:  une variante de l'instruction précédente ;
-  `\begin{exer}(<titre>)`: une version simplifiée de `exercice` qui n'a pas besoin d'un identifiant. Elle est prévue pour les séries d'exercices. L'identifiant est géré implicitement en interne.

### Environnement pour les solutions 
Deux stratégies sont disponibles : 
- faire suivre chaque question de sa solution encapsulée dans l'environnement `{solution}` au sein du même environnement que l'énoncé ; 
- regrouper toutes les solutions d'un même sujet dans un environnement `{corrige}` dédié en indiquant l'identifiant de l'énoncé correspondant avec la syntaxe `\begin{corrige}{<id>}`. Le corrigé peut résider dans le même fichier source que l'énoncé ou dans un fichier séparé.  Chaque solution doit être précédée de la commande `\xsol` (qui prendra en charge automatiquement la numérotation). 
Les deux stratégies peuvent cohabiter dans un même fichier source. 

> **Exception**
> À cause de l'absence d'un identifiant explicite, l'environnement `{exer}` ne peut utiliser que la première méthode. C'est à dire faire suivre chaque question de sa solution.

> **Des environnements jetables**
> Il est possible de définir à la volée d'autres environnements qui se comportent comme `{probleme}` ou `{exercice}` avec toutes les fonctionnalités de ceux-ci, y compris leurs liaison avec l'environnement `{corrige}`. Par exemple :
> `\cpgenewproblem{planche}{Planche}[planche]{|1|}{de la planche}`
> va générer un environnement qui portera le premier argument comme nom (à invoquer par `\begin{planche}`). Le deuxième argument indique le nom qui sera visible dans le PDF, le troisième le nom interne du compteur qui sera utilisé, le quatrième le style de ce compteur et le dernier indique le texte qui sera ajouté avant l'intitulé du corrigé.

### Insertion des solutions
 Dans les deux stratégies de traitement des solutions, la compilation passe par une phase intermédiaire qui consiste en l'écriture du corrigé de chaque sujet dans un fichier séparé (qui comporte l'identifiant `<id>` dans son nom). L' inclusion du contenu de celui-ci se fait alors selon deux modes qui sont activés avec l'option de la classe `solution` ou `solution*`. 
 - `solution` : l'insertion se fait immédiatement après l'énoncé ; 
 - `solution*` : les solutions de plusieurs sujets sont collectées et leurs insertion se fait par la commande `\solutions` placée par l'utilisateur là où il veut.
 - 
> **Pas de solutions**
> Si aucune des deux options n'est active alors les solutions ne sont pas produites dans le PDF final.

### Un exemple complet

```latex
\begin{exercice}{exe6}
Soit $\theta\in]0,2\pi[$.

Calculer le \acs{dse} de la fonction $t\longmapsto \ds\frac{1-t^2}{1-2t\cos\theta+t^2}$.
\end{exercice}

\begin{corrige}{exe6}
$f$ est une fonction rationnelle de pôles $e^{i\theta}$ et $e^{-i\theta}$ donc elle est \dse en $0$ sur $]-1,1[$. 
.....
\end{corrige}

\begin{exercice}{exe7}
\xques Soit $a\in]-1,1[$. Développer en série entière la fonction $f$ définie par
\<f(x)=\sum_{n=0}^{+\infty}\sinh(a^{n}x)\>
\xques \<\lt{Même question pour}
f(x)=\sum_{n=1}^{+\infty}\frac{(-1)^n}{x+n}\>
\end{exercice}

\begin{corrige}{exe7}
Il s'agit dans cet exercice d'étudier, sur des exemples, comment développer en série entière la somme d'une série de fonctions $\sum f_n$. L'idée de base est de développer chacune des fonction $f_n$ est d'utiliser ensuite la formule de Fubini.

\xsol Pour tout $x\in\R$ on a
\<\sinh(a^n x)=\sum_{p=0}^{+\infty}\frac{(a^nx)^{2p+1}}{(2p+1)!}\>
Observons alors que .....

\xsol Avec la fonction définie par
\< f(x)=\sum_{n=1}^{+\infty}\frac{(-1)^n}{n+x} \>
il n'est pas possible d'utiliser directement la formule de Fubini à cause du caractère semi-convergent de la série. ....
\end{corrige}

\begin{exer}
Soit $f$ l'application définie sur $]-1,1[$ par $f(t)=\cos(\alpha\arcsin t)$, $\alpha\in\mathbb R$.

\xques Former une équation différentielle linéaire du second ordre vérifiée par $f$.
\begin{solution}
solution de la question 1 .....
\end{solution}

\xques En déduire que $f$ est développable en série entière sur $]-1,1[$, et donner son développement.
\begin{solution}
solution de la question 2 ....
\end{solution}

\end{exer}
```

L'exercice `{exe6}` n'a pas de questions numérotées. On utilise `{corrige}` pour encapsuler son corrigé. L'exercice `{exe7}` utilise ce même mécanisme tout en ayant des questions numérotées. `\xques` est utilisée pour numéroter les questions et `\xsol`pour numéroter les solutions. Quand au dernier exercice, un identifiant n'est pas nécessaire car les solutions sont fournies dans le même environnement. Il faut comprendre que ce dernier mécanisme va aboutir au final à la même procédure que celle utilisant l'environnement séparé `{corrige}` : les solutions seront collectées dans un fichier temporaire et la commande `\xsol` sera ajoutée avant chaque solution. 
## Gestion des Questions et de leurs solutions 

La classe `cpgedev` fournit un mécanisme pour gérer les questions et sous-questions ainsi que leurs solutions. De base la numérotation des solutions est automatiquement liée à celle des questions et chaque numéro de question est un hyperlien qui renvoie vers sa solution et vice-versa. Le système facilite l'adoption d'un style particulier de numérotation (pour imiter celui d'une épreuve de concours par exemple). 
 Globalement l
### Un environnement et deux commandes pour les questions
- l'environnement de liste `{questions}` s'utilise comme `{enumerate}`. La commande `\item` est utilisable et produit un numéro qui suit le style de la liste mais pour déclencher le mécanisme interne de liaison entre questions et solutions il faut utiliser la commande `\xques`. Si un item de la liste n'est pas une question (possède des sous-questions par exemple ) utiliser `\zques` à la place. 
  - `\xques`: insère un numéro et enregistre celui-ci dans la pile interne des questions du sujet, pour une utilisation ultérieur pour numéroter les solutions ; 
  - `\zques` agît comme `\xques` mais n'inscrit pas le numéro dans la pile. Cette commande est prévu pour les unités qui ne sont pas des questions. Celle qui possèdent des sous-questions. Accessoirement elle peut être utilisée pour une question dont on ne désire pas fournir une solution. 

Toutefois, les commandes `\xques` et `\zques` ont un comportement autonome : elles n'ont pas besoin d'être initialisées par l'environnement `{questions}` (`\item` provoque une erreur si elle est utilisée en dehors d'un environnement de liste).  Si `\xques/\zques` est rencontrée sans qu'un environnement `{questions}` ne soit actif, elles en initient un. En outre ces commandes peuvent être suivies d'un modificateur optionnel et/ou d'un ou plusieurs arguments également optionnels : 
**Modificateurs :**
  - `+` : si `\xques/\zques` est suivie du modificateur `+` elle ouvre un nouvel environnement `{questions}`, ce qui permet de créer une liste de sous-questions. Ce modificateur n'est pas nécessaire si aucune liste n'est encore ouverte ;
  - `-` : si `\xques/\zques` est suivi du modificateur `-`, elle ferme la liste en cours et continue la liste parente. Il produit donc une erreur s'il est utilisé dans le niveau le plus externe ;
  - `\r` : utilisé lorsqu'on a fermé une liste (pour insérer un titre ou en général  du texte sans le retrait de la liste) et qu'on veut reprendre la liste en continuant la numérotation. 
**Paramètres optionnels :**
-  `\xques/\zques` est suivie d'un argument entre crochets (`[` et `]`) celui-ci est utilisé comme numéro statique. Si cet argument est vide alors le compteur du niveau est incrémenté mais aucun numéro n'est produit dans le PDF ;
- si `\xques/\zques` est suivie d'un paramètre optionnel entre parenthèses celui-ci est utilisé comme un titre
- si `\xques/\zques` est suivie d'un paramètre optionnel entre `<` et `>` celui-ci est à passé à la commande `\label` pour placer une référence.
  
Un seul modificateur peut être utilisé à la fois. Les arguments optionnels peuvent être cumulés à condition de respecter l'ordre de leur citation ci-dessus.  La syntaxe est de la forme 
```latex
\xques<un ou zero modificateur>[<numéro statique>](<titre>)<<label>>
```

> **Zapping**
> Dans certaines épreuves de concours, le numéro d'une question est absent si elle est immédiatement suivie, sans aucun texte d'introduction, par une sous-question. `\zques[]` permet de reproduire ce comportement sans briser le mécanisme de liaison questions/solutions.

> **Barème**
> La commande `\xques` permet aussi de renseigner le barème de la question. Cela se fait à travers le modificateur spécial `\sc`. La syntaxe complète est en fait 
> `\xques<modif>\sc{<marks>}[<stat>](<title>)<<label>>`
> `<marks>` est un texte descriptif qui se résume comme `1+3+2` qui signifie ici que le barème se décompose en trois parties notées respectivement 1, 3 et 2 points. Si l'option `score` de la classe est active alors ce barème apparaît à gauche du numéro de la question et la somme de toutes les notes s'ajoute au barème total du devoir, celui-ci apparaissant avec le titre du devoir. Sans l'option `score` rien n'apparaît dans le PDF. 

### La commande `\exit` 
Puisque `\xques` initie des environnements LaTeX, il faut prévoir un mécanisme pour le(s) fermer. Ce rôle incombe à la commande `\exit`.
- si aucune liste n'est active la commande ne fait rien ; sinon toutes les listes en cours sont récursivement fermées (cela inclut les listes gérées par la commande `\xit`) ;
- si `\exit` est suivie d'un modificateur `-` elle ferme la liste en cours. Plusieurs modificateurs `-` peuvent être utilisés et la commande fermera exactement le même nombre de listes ;

> **Fermer la porte**
> les environnements des énoncés et celui unique des corrigés exécutent automatiquement la commande `\exit` à leur fermeture.  Cela garantit que tous les environnements de listes sont correctement fermés et simplifie un peu plus la saisie en conséquence.

### Deux modes pour les solutions
On a déjà parlé de la stratégie de couplage entre un énoncé et son corrigé et de celle qui au contraire permet  d'imbriquer questions et solutions.  La première méthode sera dite la méthode globale, la seconde la méthode locale. Les deux méthodes sont prévues chacune pour un cas d'usage différent. 
Dans les deux méthodes, on se retrouve avec le même résultat : un fichier temporaire créé pour chaque corrigé et la syntaxe que celui-ci suit est la même dans les deux cas. Avec l'option`solution`  de la classe,  le contenu de ce fichier est inclus immédiatement après le  traitement de l'énoncé. Dans le cas de l'option `solution*`, un registre des corrigés non encore insérés est maintenue en interne. Ce registre est remis à zéro à chaque invocation de la commande `\solutions`. De cette manière on peut organiser les énoncés/corrigés en sections logiques. Reprenons les descriptions :

**Méthode globale :** le corrigé est rédigé dans un environnement `{corrige}` séparé et couplé à un énoncé par un identifiant commun`{<id>}` 
-   `\begin{corrige}{<id>}`: Environnement qui regroupe l'ensemble des solutions des questions pour l'énoncé identifié par `<id>`.
-   `\xsol`: commande à utiliser au début de chaque solution. Elle dépile le numéro de la question correspondante (enregistré auparavant par la commande `\xques` dans l'énoncé). La numérotation des solutions est donc automatique et adopte le même style que celui des questions. Si on change de style de numérotation dans l'énoncé, le même style sera reproduit pour les solutions. 
  
> **Cas d'usage**
> Cette méthode convient aux cas où on dispose déjà des solutions dans un ancien fichier qui n'utilise pas `cpgedev` : on n'a qu'a procéder à une adaptation en supprimant tous les environnements `{enumerate}`et en remplaçant les commandes `\item` par `\xsol`.

**Méthode locale :** chaque question est immédiatement suivie de sa solution encapsulée dans l'environnement `{solution}`. Un fichier séparé est prévu pour collecter les solutions d'un même sujet et une commande `\xsol` est automatiquement ajoutée avant  le contenu de chaque `{solution}`.  Au final ce fichier ressemblera au contenu de celui qu'on aurait rédigé dans un environnement `{corrige}` dédié. 

> **Cas d'usage**
> Cette méthode présente l'avantage de rendre le contenu très manageable : quand on copie ailleurs une partie d'un sujet, le couplage questions/solutions reste pleinement fonctionnel.   
[solution]
## Configuration des listes de questions 

Les numéros insérés par `\xsol` héritent du style imposé par celui des questions. Les commandes `\xques/\zques` ont un mécanisme qui permet personnaliser le style de numérotation ainsi que certaines propriétés de la liste. Leur syntaxe complète est en fait de la forme 
```latex
\xques<modificateur>\op{<options>}\sc{<barème>}[<numéro statique>](<titre>)<<label>>
```
`<options>` est une liste d'options de type clé/valeur qui permettent d'altérer plusieurs aspects de la liste. Seule une commande `\xques/zques` qui initie une liste prend en compte ces options et elles ne s'appliquent qu'à l'environnement en cours d'ouverture. Toutefois ces options sont répliquées (sans avoir à les ressaisir) si on reprend une liste avec le modificateur `\r`.  Un mécanisme différent est prévu pour imposer des options à toutes les listes dans un document. 

### Changement de style de la numérotation 
L'option concernée est `n=<raccourcis>` où  `<raccourcis>` est un texte descriptif contenant éventuellement plusieurs  caractères entre deux barres `|` et qui va imposer le style de la numérotation. Les raccourcis sont groupés dans deux catégories. 
**Raccourcis actifs :**
  - `|1|` chiffres arabes ; 
  - `|a|` lettres latines minuscule ;
  - `|A|` lettres latines majuscules ;
  - `|i|` chiffres romains minuscules ;
  - `|I|` chiffres romains majuscules .
**Raccourcis passifs :** 
  - `|Q|`: numéro de la question de premier niveau ;
  - `|q|`: numéro de la question de second niveau ;
  - `|P|`: numéro de la partie courante (commande `\parti`) ;
  - `|p|`: numéro de la sous-partie courante (commande `\partii`).
  - `|X|`: numéro du sujet (problème, exercice...) courant ;

Plusieurs raccourcis passifs peuvent être utilisés au même temps. Un seul actif. Il représente le numéro effectif de la question.    

**Exemple :** `\xques\op{n={|X|.|1|}}` pour produire une numérotation de la forme `1.1`, `1.2`,`1.3` etc. où `1.` est le numéro du sujet en cours, suivi du numéro de la question. 

### Gestion des espaces de la liste 
Trois options sont disponibles pour la gestion des espaces dans une liste de questions 
- `m=<dimen>` où `<dimen>` est une dimension TeX (`2pc`, `2em`, `1cm` ...). La dimension servira comme retrait de la liste par rapport au texte normal. Le numéro est lui même placé en retrait par rapport au texte de la liste; 
- `m*=<dimen>` comme pour `m` mais le numéro n'a pas de retrait par rapport au texte de la liste ; 
- `s=<dimen>` saut vertical qui sépare les questions. De préférence un saut élastique (avec une composante `plus` et une composante `minus`) pour ne pas gêner les algorithmes de rupture de pages du moteur de compilation TeX. 
  Par exemple `s=6pt plus3pt minus1pt`;

### Gestion globale du style de numérotation 
La commande `\cpgesetlabel`  peut être utilisée pour fixer globalement le style de numérotation des questions. Elle utilise les mêmes conventions sur les raccourcis. Placée au début d'un sujet, elle s'applique aux questions de ce sujet. Placée en dehors des environnements pour les sujets elle s'appliquent à tout le fichier source qui la contient (dans le cas d'un fichier esclave, elle s'applique uniquement à ce fichier).
```
\cpgesetlabel{enumi}{|1|}
\cpgesetlabel{enumii}{|Q|\itshape|a|}
```
Ces réglages changent globalement le style de numérotation pour les questions principales et leurs sous-questions (niveaux `enumi` et `enumii`). 

> **Au delà des questions**
> `\cpgesetlabel` est une commande généraliste qui peut changer le style de numérotation d'autres compteurs. Dans l'exemple précédent, `enumi` et `enumii` sont en fait les noms internes des compteurs de premier et de deuxième niveau utilisés par les listes de type `{enumerate}` (et donc `{questions}`). Elle permet, par exemple, de changer aussi le style de numérotation des sujets, des parties et des sous-parties avec quelque chose comme 
> `\cpgesetlabel{probleme}{|1|}`
> `\cpgesetlabel{exercice}{|1|}`
> `\cpgesetlabel{parti}{|X|.|I|}`
> `\cpgesetlabel{partii}{|X|.|P|.|A|}`

## Organisation des fichiers sources 

### Hiérarchies des fichiers sources 
Pour une bonne modularité, il est fortement conseillé d'organiser les fichiers selon une architecture classique : un fichier maître et un ou plusieurs fichiers esclaves.  

Le fichier maître contiendra par exemple les packages supplémentaires à utiliser, la géométrie, le thème à appliquer et les métadonnées communes. En outre le système offre aussi la possibilité d'utiliser un préambule dans les fichiers esclaves pour rendre leurs compilation individuelle possible tout en allant chercher les paramètres de configuration dans le fichier maître. Dans ce cas d'usage, une classe spéciale doit être utilisée dans le fichier esclave : `cpgesubdoc`. 

> **Le système !**
> Oui, il y a un «système» dont  `cpgedev` n'est qu'une partie. Il porte le nom `cpgekit`. Il prétend couvrir tous les besoins spécifiques d'un enseignant de prépas en ce qui concerne la production de documentation. Cela va du polycopié de cours, aux fiches de colles et même au quiz.  

### Fichier maître 
Le fichier maître doit commencer par l'instruction 
```latex
\documentclass[
	<options>
]{cpgedev}
```
qui s'occupera d'initialiser toute l'infrastructure nécessaire ainsi les packages usuels pour les documents  mathématiques. 
Les options intéressantes sont celles déjà mentionnées `solution` et `solution*` auxquelles s'ajoutent :
- `score` : active la prise en compte du barème et son insertion dans le PDF ;
- `draft` : active le mode brouillon. Active une géométrie spéciale, désactive le thème et les liens hypertextes pour accélérer la compilation. Pour un meilleur contrôle visuel du travail de rédaction, les solutions sont aussi insérées sur place quelque soit le mode de rendu des solutions. Ce mode évite aussi de détruire la synchronisation entre source TeX et document PDF. 
- `compact` : pour forcer l'adoption des conventions du mode compact normalement réservé aux cas où la largeur de texte est réduite (petits écrans ou multi-colonnes) ;
- `serie` : mode spécial qui permet de réduire les espaces verticaux autour des intitulés des sujets et qui convient mieux à une série d'exercices. 
Toutes les options de la classe LaTeX standard `book` sont aussi utilisables. 

> **Fonctionnalité essentielle**
> La synchronisation entre source et PDF est devenue une fonctionnalité indispensable des éditeurs LaTeX modernes. Elle permet de cliquer quelque part dans le PDF pour être ramenée à la ligne correspondante dans le fichier source TeX.  Cette fonctionnalité est incompatible avec les techniques qui  générent dynamiquement des fichiers sources pour les inclure plus tard. Dans ce cas ce sera le fichier temporaire qui sera chargé dans l'éditeur et non le code original qui correspond au lieu du clic. L'option `draft` permet de remédier à ce problème en phase de rédaction. 

Ensuite, dans le corps du fichier maître, pour charger un fichier esclave il faut utiliser une instruction de la forme 
`\cpgeinclude[<options>]{<chemin vers un fichier esclave>}` 
une instruction par fichier esclave à charger. Les options intéressantes sont les suivantes :
- `solution` : agit comme l'option globale `solution` de la classe `cpgedev` mais pour le fichier esclave à charger. Il est donc possible d'activer les solutions pour certains fichiers esclaves et pas pour d'autres. Si au contraire on veut les désactiver pour un fichier esclave alors qu'elles sont activées par la classe, il faut utiliser `solution=false`.  
- `solution*` joue le même rôle par rapport à l'option globale `solution*`. 
- `solution file=<chemin vers un autre fichier>` permet d'indiquer un  fichier alternatif  contenant les solutions des sujets figurant dans le fichier en cours de chargement. 
- `before solution=<code LaTeX arbitraire>` permet de définir un code qui sera exécuté par la commande `\solutions` avant l'insertion effective des corrigés. Une valeur plausible serait `\clearpage` pour provoquer un saut de page. 
- `corrige={<options à passer à {corrige}>}` définit des options communes qui seront passées à tous les environnements `{corrige}` dans le fichier esclave. Ces options seront exécutées avant celles qui seront passées explicitement à `{corrige}` dans ce fichier. 

### Fichiers esclaves 
Maintenant, comme mentionné auparavant, un fichier esclave peut contenir lui même un préambule. Rappelons que la commande standard `\include` ne permet pas de le faire. Cela rend possible la compilation d'un fichier esclave tout en appliquant les options de configuration du fichier maître. Les fichiers esclaves doivent utiliser une classe spéciale avec une instruction de la forme 
```latex
\documentclass[
	master=<chemin vers le fichier maître>, 
	<autres options>
]{cpgesubdoc}
```
l'option `master` permet d'indiquer le fichier maître à utiliser : le préambule de celui-ci sera chargé avant celui du fichier en cours de compilation. Cela inclut les commandes de métadonnées (si elles sont dans le préambule du fichier maître)  ainsi que celle de la géométrie et du thème.  Les autres options sont les mêmes que celles utilisables directement avec `cpgedev`.  

L'utilisation d'un préambule dans les fichiers esclaves reste bien sûr optionnelle. 

> **Vroom !**
> Le préambule dans un fichier esclave peut accélérer notablement les compilations en phase de rédaction. On compile juste le fichier en cours de traitement au lieu du fichier maître avec toutes ses inclusions. 

### Métadonnées du document 
Il s'agit des informations qui seront utilisées dans différentes parties du document (titre, en tête et pieds de page...). Elles fonctionnent selon le même principe que les commandes standards `\title` ou `\author`. Les commandes qui permettent de définir ces métadonnées sont les suivantes :
- `\Centre` : le centre de prépas (ou le nom d'une université) ; 
- `\Ville`: la ville du centre ;
- `\Filiere` filière à laquelle est destiné le document ;
- `\Classe`: la classe à laquelle est destiné le document ;
- `\Matiere` matière traitée dans le document ;
- `\Document` l'intitulé principal du document (par exemple «Devoir surveillé 2», ou «Problèmes d'algèbre linéaire») ;
- `\Devoir` intitulé du devoir, le même rôle que `\Document` mais prévue pour le cas où le document comporte plusieurs devoirs.  Dans ce cas elle doit être insérée dans le fichier esclave du devoir ; 
- `\Concours` origine du sujet ;
- `\Session` session du sujet de concours ;
- `\Theme` le thème abordé par le document (par exemple «Séries et intégrales») ;
- `\Subtheme` s'il y a un sous-thème ;
- `\Periode` la date ou la période du devoir ;
- `\Duree` la durée du devoir ;
- `\Auteur` auteur du corrigé ;
- `\Email` émail de l'auteur du corrigé ;
- `\Website` site web de l'auteur ;
- `\Preuateur` le texte qui précède le nom de l'auteur (valeur par défaut «Rédigé par»)
Ces commandes ne produisent rien dans le document final. Le contenu qu'elles reçoivent est par contre utilisable sur différentes parties du document. Leurs noms commencent par une majuscule mais leur contenu est accessible dans ces différents contextes grâce à ces mêmes noms sans majuscule et encadrés par deux caractères `|` (comme les raccourcis pour les numérotations).  Elles peuvent être insérées dans le préambule du fichier maître ou bien au début de son corps (après `\begin{document}`). Leurs contenus est ensuite disponible pour tous les fichiers inclus. Ce contenu sera écrasé par une éventuelle nouvelle utilisation dans le corps de ces fichiers.  

> **Court-circuit !**
> Le préambule d'un fichier esclave n'est pas pris en compte si la compilation se fait à partir du fichier maître. On peut donc prévoir des métadonnées différentes pour chaque fichier esclave. Si on veut qu'une métadonnée soit prise en compte même dans le cas d'une compilation globale, il suffit de placer l'instruction correspondante après le `\begin{document}` du fichier esclave. 

### Thème et géométrie 
Le format du document à produire peut être réglé par la commande `\cpgegeometry`. Un thème peut être activé avec la commande `\cpgetheme`. Les deux commandes doivent figurer dans le préambule du fichier maître. De préférence immédiatement après `\documentclass`. 
`\cpgegeometry` prend un seul argument : le nom interne de la géométrie. Les noms utilisables sont :
- `print` : format A4 en mode portrait ;
- `2print` format A4 en mode portrait mais en 2 colonnes ;
- `lsprint` format A4 en mode paysage et en 2 colonnes ;
- `tablet` format pour tablettes numériques aux proportions 4x3; 
- `phone` format pour smartphones aux proportions 19x6 (Apple);
- `altphone` format alternatif pour smartphones aux proportions 19x9 (Samsung).

`\cpgetheme` n'est pas indispensable. En cas de son absence le thème par défaut est utilisé. Elle prend un seul argument obligatoire qui est le nom du thème. Le thème courant s'appelle `curve`.  Il est assez exigeant en terme de ressources pour compilation. De préférence utiliser le mode `draft` pour les compilations intermédiaires. Elle s'utilise sous la forme
`\cpgetheme{curve}` 

> **Quid de la couleur**
> Le thème règle le style pour la page de garde, les décorations pour les zones d'entête et de pieds de page, les décorations des intitulés des sujets et de leurs parties ainsi que les décorations des numérotations.  
> Il est en outre possible, en option, d'associer différentes palettes de couleurs à un même thème  avec une instruction de la forme 
> `\cpgetheme[palette=nord]{curve}` 
> Ce qui activera la palette de nom `nord`. Les autres palettes utilisables sont `gruv`, `material`, `forest` et `cosmic`. Chaque palette supporte un mode sombre et un mode clair. Le mode sombre n'est activé que pour les formats smartphones. On peut le l'activer ou le désactiver en ajoutant respectivement l'option `dark` ou  `dark=false` à la commande `\cpgetheme`. 

### Titre du document
De base, la commande `\titre`  s'occupe de la formation du titre du document, qu'il s'agisse d'un devoir unique ou d'un document long composé de plusieurs devoirs. Son contenu est alimenté par les métadonnées collectées par  les commandes de métadonnées précédentes.  Elle est souple et permet de personnaliser le titre selon les besoins. Elle produitune page de garde pour les documents à destination des écrans et une simple zone de titre pour les devoirs à imprimer. 
Le contenu qu'elle produit par défaut est prédéfini dans les fichiers styles mais il peut être personnalisé en utilisant les raccourcis des métadonnées. Elle se désactive elle même une fois utilisée et ne peut donc être utilisée qu'une seule fois dans un document (comme la commande standard `\maketitle`). Pour personnaliser le contenu qu'elle produit il suffit de fournir une description de celui-ci entre parenthèses (un argument optionnel donc).   
**Exemple :** `\titre(|document| |theme| |periode| |duree|)` 

> **Pas que les raccourcis**
> Tout code LaTeX valide  sera exécuté de façon normale. Ce qui permet de personnaliser un peu plus le titre.  
> Les fichiers styles des thèmes peuvent redéfinir le contenu par défaut du titre de document. 

### Entête et pieds de pages 
Deux commandes spéciales sont disponibles pour changer le contenu de l'entête et pied de page du document : `\cpgesethead` et `\cpgesetfoot`. Par exemple 
```latex
\cpgesethead(|centre| - |classe|)()(|document|) 
\cpgesetfoot(|duree|)(|pages|)(|periode|)
``` 
définira le contenu des trois champs (gauche, centre et droite) dans l'entête et le pieds de page. 

## Divisions d'un devoir 

Un devoir peut être composée d'un ou plusieurs sujets (exercices ou problèmes) et chaque sujet peut être lui même subdivisé en plusieurs parties. Pour refléter cette structure, les commandes de sections LaTeX ont été complètement réécrites avec une hiérarchie plus adaptée mais en conservant toutes les fonctionnalités attendues (table des matières, bookmarks PDF, références croisées...). 
- `\devoir` : la plus haute division dans un devoir. Elle joue le même rôle que la commande `\chapter` dans les classes standards `book` et `report`;
- `\section` : unité qui va regrouper plusieurs sujets qui ont un thème commun ;
- `{probleme}` et `{exercice}` des environnements qui encapsulent le contenu d'un sujet tout en produisant un titre (qui sera inclus dans la table des matières) ;
- `\parti` titre d'une partie dans un sujet ; 
- `\partii` titre d'une sous-partie d'une partie.
Les commandes `\section`, `\parti` et `\partii` ont la même syntaxe que les commandes de sectionnement standard de LaTeX. Par contre `\devoir` et `{probleme}/{exercice}`  offrent plus de fonctionnalités. 

> **Fruits interdits !**
> les commandes `\chapter` , `\subsection` et `\subsubsection` sont désactivées et produisent une erreur de non-définition.

### La commande `\devoir` 
Elle provoque un saut de page et elle est capable d'utiliser certaines métadonnées au point qu'elle peut être utilisée à la place de la commande `\titre`. Sa syntaxe est de la forme :
```latex
\devoir*
	\op{<options>}
	{<label du devoir>}
	[<titre court optionnel>]
	(<titre long optionnel>)
	<<label>>` 
```
- `<label du devoir>` : comme «Devoir libre» ou «Série d'exercices» ;
- `[<titre court optionnel>]` : intitulé court qui sera utilisé dans la table des matières et dans les entêtes dans le cas ou le titre original est trop long.
- `(<titre long optionnel>)` :  le titr[solution]e tel qu'il apparaîtra au début du document ;
- `<label>` sera passé à la commande `\label` pour placer une référence. 

Les options acceptées par l'agrégateur `\op` sont les suivantes :
- `name=<nom>` : le label qui sera placé avant le numéro du devoir, comme «DS» ou «Sujet» par exemple ;
- `number=<nombre>` : le numéro du devoir ;
- `before title=<code>` : code LaTeX valide qui sera exécuté avant le titre. Accepte les raccourcis utilisables avec `\titre`;
- `after title=<code>` la même chose le code est exécuté après le titre. 

> **Cas d'usage**
> La commande `devoir` est indispensable dans le cas où on veut créer une compilation de plusieurs devoirs au même titre que `\chapter` est indispensable lorsque on rédige un manuel de cours. 

### Les environnements pour énoncés
Les sujets utilisent des environnements et non des commandes LaTeX mais entre autres tâches, ils veillent à la formation des intitulés et à leur inscription correcte dans la table des matières.  Comme mentionné auparavant il y a plusieurs environnements pour les énoncés et un seul pour les corrigés. Ceux des énoncés s'utilisent de la façon suivante :
```latex
\begin{probleme}
	{<id>}
	\op{<options>}
	[<titre court optionnel>]
	(<titre long optionnel>)
	<<label>>
```
Tous les paramètres ont la même signification que pour la commande `\devoir` sauf pour le paramètre `{<id>}` qui sert ici à coupler l'énoncé à son corrigé. La liste des options aussi n'est pas la même :
- `solution` et `solution*` : permettent d'activer ou de désactiver les solutions pour le sujet indépendamment du contexte global ;
- `score` : active le calcul du barème pour le sujet et son affichage avec le titre ;
- `origin=<origine>` : renseigne la métadonnée «origine» du sujet ;
- `before title=<code>` exécute le code `<code>` avant la formation du titre. `<code>` peut utiliser les raccourcis des métadonnées ;
- `after title=<code>` la même chose mais le code est exécuté après la formation du titre.
- `corrige ={<option à passer à {corrige}>}` permet de passer des options à l'environnement qui s'occupera de la formation des solutions. Surtout utile dans la méthode locale de liaison questions/solutions. Voir les options de l'environnement `{corrige}`.  

### L'environnement des corrigés 
L'environnement `{corrige}` s'attend à une syntaxe similaire. Si les titres ne sont pas précisés, il  reproduit automatiquement ceux de l'énoncé auquel il est couplé.  Il accepte les options `before title` et `after title` des environnements pour les énoncés, les autres options n'ayant pas de sens pour un corrigé. Par contre il a des options qui lui sont propres :
- `auteur=<nom>` : ajoute le nom de l'auteur du corrigé au titre ;
- `questions list={<liste>}` : a pour seul objectif de permettre de compiler un fichier de corrigé sans le fichier qui contient son énoncé.  `<liste>` doit être la séquence des numéros, séparés par une virgule, qui seront utilisés par la commande `\xsol` . À noter que cette séquence doit être obligatoirement encapsulée entre des accolades pour masquer la virgule (car celle-ci sert aussi de séparateur pour la liste des options et peut donc provoquer une confusion). 

> **Court-circuit**
> L'option `corrige` des environnements pour énoncés peut s'avérer indispensable quand on veut passer des options à l'environnement interne qui traite le corrigé alors que  le mode de liaison local est utilisé. En effet, dans ce cas, cet environnement n'est pas directement accessible.  



## Les autres environnements de Listes 

### Environnements et commandes de listes 
En fait l'environnement `{questions}` et des commandes `\xques/\zques` ne sont qu'une spécialisation de mécanismes plus généraux mis en places par les packages utilisés par `cpgedev`. Ces packages fournissent un système de listes complet et versatile. De base trois environnements sont disponibles 
- `{xenum}` cousin de `{enumerate}` 
- `{xitem}` se comporte comme `{itemize}` 
- `{tabenum}` comme `{enumerate}` mais capable de présenter son contenu en plusieurs colonnes
À l'intérieur de ces  environnements on peut utiliser la commande usuelle `\item` mais une version plus polyvalente est disponible : la commande `\xit`. Son comportement rappelle celui de `\xques` tout en étant plus polyvalente.  

### Le mécanisme `\xit`
`\xit` est une commande dynamique qui peut tester si un environnement de liste est en cours. Si oui elle se contente d'insérer un nouvel item, si non elle initie un nouvel environnement et y insère un premier item. Si aucune liste n'est ouverte et si `\xit` n'est suivi d'aucun modificateur,  elle démarre une liste numérotée `{xenum}`. Mais on peut initier un autre type de liste en la faisant suivre d'un modificateur :
-   `\xit\i`: Démarre une liste à puces (`{xitem}`).
-   `\xit\t`: Démarre une liste numérotée avec tabulations (`{tabenum}`). 
Si ces instructions surviennent dans un environnement de liste mais de type différent alors elle initient une nouvelle liste du type indiqué par le modificateur. Mais pour imbriquer deux listes de même type il faut ajouter le modificateur `+` à l'instruction d'initialisation. Comme `\xit\i+` pour  créer une nouvelle liste `{xitem}` imbriquée dans une autre. 
 L'instruction `\xit-` ferme le niveau de liste courant et insère un item dans le niveau parent (indifféremment du type de listes imbriquées).
 
### La commande `\exit`
 Pour la fermeture  d'une liste sans ajout d'item : 
-   `\exit-`: ferme le niveau courant, plusieurs modificateurs `-` peuvent être utilisés : `\exit---` fermera trois listes à partir de celle courante, tout type de liste confondu. 
-   `\exit`: ferme récursivement tous les niveaux de listes ouverts.

### Configuration avec `\op`
Après ces modificateurs, «l'agrégateur d'options» `\op{<options>}` permet de configurer les propriétés d'une liste. Il se place après `\begin{xenum/xitem/tabenum}` ou bien après une instruction d'initialisation `\xit`. Les options sont les mêmes que pour `\xques/\zques`. 

### L'environnement `{discussion}`
C'est un environnement de liste spécial pour structurer une argumentation. Il produit une liste à puces avec optionnellement des titres pour les items. Il met en places les commandes spécialisées suivantes :
- `\unite{<texte>}`: Item avec  `<texte>` comme intitulé.
- `\cas{<texte>}`: item avec un intitulé de la forme "**Cas où `<texte>`:** ".
- `\si{<condition>}`: de même avec l'intitulé  "**Si `<condition>`** ".
- `\imp{A}{B}`: item formaté sous la forme `A) => B)`.

## Environnement pour les formules centrées

Les fichiers styles utilisés par `cpgedev` mettent en place un environnement amélioré pour l'affichage de formules mathématiques centrées, en remplacement des commandes LaTeX standard `\[` et `\]` (ou des usuels `$$` de l'ancien format TeX). Cet environnement est délimité par `\<` et `\>`.
De base le code 
```latex
\< \Gamma(x)=\int_0^{+\infty} t^{x-1}e^{t} \mathrm d t \>
```
produira à peu près la même chose que 
```latex
\[ \Gamma(x)=\int_0^{+\infty} t^{x-1}e^{t} \mathrm d t \]
```

> **cpgemath**
> le package `cpgemath` chargé automatiquement par `cpgedev` fait partie du kit `cpgekit`. Il peut être utilisé sans `cpgedev` avec l'instruction 
> `\usepackage{cpgemath}`
> C'est lui qui met en place, entre autre, le mécanisme `\<`.

Le mécanisme `\<` est versatile et possède des fonctionnalités inédites. Il modifie son comportement au travers de commutateurs. Ce sont des modificateurs spéciaux qui doivent suivre immédiatement la commande ouvrante `\<`.  Il y a deux types de commutateurs : 
- les commutateurs «logiques» avec un seul caractère comme `\n` ou `\r` 
- les commutateurs «à argument» avec deux caractères comme `\lt` ou `\fr`  et qui doivent être suivis d'un argument obligatoire entre accolades (éventuellement vide). 
Les commutateurs logiques permettent de modifier un comportement binaire comme ajouter ou non un numéro d'équation. Ceux à argument adaptent leurs comportement selon la valeur de celui-ci.

> **Syntaxe**
> Les commutateurs logiques doivent être placés en premier et doivent repsecter l'ordre de citation ci-dessous. Ceux à argument peuvent être placés dans n'importe quel ordre mais **après** les éventuels commutateurs logiques.

### commutateurs logiques
*  `\n` placer ou non un numéro d'équation ;
* `\t` basculer le traitement du contenu en mode  texte TeX, le contenu est produit dans une «minipage» centrée dont la largeur est calculée dynamiquement ;
* `\r` comme pour `\t` mais produit en plus une décoration autour du texte, utile pour donner une conclusion à une solution par exemple.  
Le commutateur à argument `\wd` peut fixer la largeur de la minipage utilisée par `\t`et `\r` si la largeur utilisée implicitement n'est pas convenable.

### commutateurs à argument
- `\lt{<texte>}` place `<texte>` à gauche du contenu centré. Évite de gâcher toute une ligne juste pour un mot comme «d'où». Si le texte est trop large pour tenir sur la même ligne que la formule alors il est placé sur sa propre ligne avant la formule. 
- `\rt{<texte>}` place `<texte>` à droite du contenu centré,  par exemple une explication courte  ou un numéro d'équation statique (en dehors du mécanisme natif géré par `\n`). Son contenu est placé sur sa propre ligne après la formule s'il n'a pas assez d'espace. 
*   `\lb{<label>}` Place une étiquette `<label>`  pour pouvoir référencer l'équation plus tard avec `\xeqref{<label>}`. Le commutateur `\n` doit avoir été placé avant. 
    *   **Exemple** : `\<\n\lb{pyth} a^2 + b^2 = c^2 \>`
* `\al{}` le contenu est traité dans un environnement multi-lignes comme l'environnement `amsmath` standard `{align}`, la syntaxe étant d'ailleurs la même. Il est possible de fournir un argument qui indique l'alignement vertical du contenu dans la ligne : `c` pour center (par défaut), `t`pour top et `b` pour bottom. L'alignement vertical se fait par rapport aux éventuels textes latéraux introduits par `\lt` et `\rt` .  
	* **Exemple :** `\<\al{t}\lt{donc} ax+by &= \alpha \\ cx+dy &= \beta\> 
* `\fr{}` place une décoration autour du contenu. Contrairement au commutateur `\r` le contenu est traité en mode mathématique. Le commutateur prend un argument qui est le nom d'une décoration préprogrammée. S'il est vide alors la décoration par défaut est utilisée.  
* `\wd{<per>}` s'utilise en complément des commutateurs `\t` et `\r`. L'argument `<per>` doit être un entier entre 50 et 100. Il représente, en terme de pourcentage, la largeur de la minipage par rapport à la largeur totale de la ligne.   
* `\vs{<glue>}` Ajoute un espace vertical  de dimension `<dimen>` avant et après la formule. `<glue>` doit être une dimension TeX valide  (de préférence élastique).
    *   **Exemple** : `\<\vs{6pt minus 3pt} x=1 \>`

**Un exemple complet  :** avec décoration et textes latéraux 
```latex
\<\n\lb{final}\lt{On obtient finalement}\fr{} \beta{x,y}=\frac{\Gamma(x)\Gamma(y)}{\Gamma(x+y)} \>
```

## Référence croisées 

Un mécanisme sophistiqué est mis en place pour les références croisées sur les numéros de questions et sur ceux des équations.   