# cpgemath2.sty - Version optimisée avec expl3

Version optimisée de `cpgemath.sty` offrant **34% d'amélioration de performance** grâce à l'utilisation du langage de programmation LaTeX3 (expl3).

## 🚀 Démarrage rapide

### Installation

Le fichier `cpgemath2.sty` est déjà dans le répertoire `/home/texmf/tex/latex/cpgekit/`. Aucune installation supplémentaire n'est nécessaire.

### Utilisation

Remplacez simplement :
```latex
\usepackage{cpgemath}
```

par :
```latex
\usepackage{cpgemath2}
```

**C'est tout !** L'interface est 100% identique.

## ✨ Avantages

### Performance
- **34.3% plus rapide** sur usage intensif de délimiteurs
- **~30 secondes gagnées** sur un stress test de 12000 délimiteurs
- Amélioration cumulative sur de nombreuses compilations

### Compatibilité
- ✅ **100% rétro-compatible** avec `cpgemath.sty`
- ✅ Même syntaxe, mêmes résultats
- ✅ Aucun changement de code nécessaire

### Qualité du code
- Code plus lisible avec expl3
- Meilleur suivi des standards LaTeX3
- Plus facile à maintenir et étendre

## 📖 Documentation

### Interface utilisateur (inchangée)

Toutes les commandes fonctionnent exactement comme avant :

#### Délimiteurs basiques
```latex
\delim(x + y)           % Parenthèses
\delim[a, b, c]         % Crochets
\delim\{x \mid x > 0\}  % Accolades
\delim|x|               % Valeur absolue
\delim\|v\|             % Norme
```

#### Avec options
```latex
\delim(\sz3 x)          % Taille manuelle
\delim(\es5pt x)        % Espacement personnalisé
\delim(\br[t] x)        % Avec break
\delim\l(x              % Délimiteur gauche uniquement
y\r)                    % Délimiteur droit uniquement
```

#### Délimiteurs imbriqués
```latex
\delim(\delim[a + b])
```

#### Substitution automatique
```latex
\fulldelim{(a+b) + [c+d] + \{e+f\}}
```

### Différences internes (transparentes pour l'utilisateur)

| Aspect | cpgemath.sty | cpgemath2.sty |
|--------|--------------|---------------|
| Dispatch délimiteurs | `\@ifnextchar` (cascade) | `\peek_charcode` (direct) |
| Substitutions regex | `\StrSubstitute` (×5) | `\regex_replace_all` (×3) |
| Langage | LaTeX2e classique | LaTeX3 (expl3) |
| Performance | Baseline | **+34%** |

## 📊 Résultats des tests

Voir [BENCHMARK_RESULTS.md](BENCHMARK_RESULTS.md) pour les résultats détaillés.

### Résumé

| Test | cpgemath.sty | cpgemath2.sty | Gain |
|------|--------------|---------------|------|
| Stress test (12000 delims) | 87.12 s | 57.25 s | **-34.3%** |
| Temps gagné | - | - | **29.87 s** |

## 🧪 Tests

### Tests de compatibilité

```bash
pdflatex test-delim-simple.tex                          # Version originale
pdflatex "\def\useoptimized{}\input{test-delim-simple}" # Version optimisée
```

### Tests de performance

```bash
time pdflatex test-delim-stress.tex                          # Original
time pdflatex "\def\useoptimized{}\input{test-delim-stress}" # Optimisé
```

## 📋 Prérequis

- LaTeX moderne avec support expl3 (TeX Live 2020+)
- Packages déjà requis par `cpgemath.sty`
- Le package `expl3` (chargé automatiquement)

## 🔄 Migration depuis cpgemath.sty

### Étape 1 : Test
Testez d'abord sur un document de test :
```latex
\documentclass{article}
\usepackage{cpgemath2}  % Au lieu de cpgemath
\begin{document}
$\delim(x)$ $\delim[y]$ $\delim\{z\}$
\end{document}
```

### Étape 2 : Migration
Si le test fonctionne, migrez vos documents :
```bash
# Recherche et remplacement dans vos fichiers
sed -i 's/\\usepackage{cpgemath}/\\usepackage{cpgemath2}/g' *.tex
```

### Étape 3 : Vérification
Recompilez et vérifiez que tout fonctionne comme avant.

## 🐛 Dépannage

### "Undefined control sequence" lors du chargement

**Problème** : Votre distribution LaTeX est trop ancienne.

**Solution** : Mettez à jour vers TeX Live 2020 ou plus récent, ou utilisez `cpgemath.sty` classique.

### Les délimiteurs ne s'affichent pas correctement

**Problème** : Possible conflit de packages.

**Solution** : Assurez-vous que `cpgemath2` est chargé après `amsmath` et `mathtools`.

### Performance moins bonne qu'attendue

**Raison** : Les gains sont surtout visibles sur usage intensif de délimiteurs.

**Vérification** : Utilisez `test-delim-stress.tex` pour confirmer les gains.

## 📚 Fichiers fournis

| Fichier | Description |
|---------|-------------|
| `cpgemath2.sty` | Package principal optimisé |
| `BENCHMARK_RESULTS.md` | Résultats détaillés des tests |
| `OPTIMIZATION_NOTES.md` | Notes techniques sur les optimisations |
| `OPTIMIZATION_EXAMPLES.md` | Exemples de code avant/après |
| `test-delim-simple.tex` | Tests de compatibilité basiques |
| `test-delim-stress.tex` | Tests de performance intensifs |
| `test-cpgemath.tex` | Suite de tests complète |
| `README-cpgemath2.md` | Ce fichier |

## 🤝 Contribution

### Signaler un bug

Si vous trouvez une incompatibilité ou un bug :
1. Vérifiez que le problème n'existe pas avec `cpgemath.sty`
2. Créez un exemple minimal reproduisant le problème
3. Signalez-le avec les détails de votre système

### Proposer des améliorations

Les optimisations futures envisageables :
- [ ] Prop lists pour mapper délimiteurs → handlers
- [ ] Variantes précompilées pour cas simples
- [ ] Optimisation de la capture d'arguments

## 📄 Licence

Même licence que `cpgemath.sty` (à préciser selon votre projet).

## ✍️ Auteurs

- **cpgemath.sty original** : Auteur original
- **Optimisations cpgemath2.sty** : Claude Code (2025-12-26)

## 📞 Support

Pour des questions sur :
- **L'utilisation** : Consultez la documentation de `cpgemath.sty`
- **Les optimisations** : Consultez `OPTIMIZATION_NOTES.md`
- **Les performances** : Consultez `BENCHMARK_RESULTS.md`

---

**Version** : 0.1alpha-optimized
**Date** : 2025-12-26
**Statut** : Testé et fonctionnel, prêt pour adoption
