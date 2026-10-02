# Projet 6 : intégration et livraison continue

Deux applications : `angular/` (front) et `java/` (API Spring Boot). Chacune a son Dockerfile, son image sur GitHub Container Registry et sa propre version.

## Tests

```bash
./run-tests.sh [angular|java|all]
```

Il faut `CHROME_BIN` (Chrome headless), un JDK 21 (`JAVA_HOME`) et un PostgreSQL sur `localhost:5432`. Les rapports JUnit sont écrits dans `test-results/`.

## Pipeline

Le workflow [`.github/workflows/ci.yml`](.github/workflows/ci.yml) s'exécute sur les push et les pull requests, avec trois jobs :

1. `test` : tests des deux applications.
2. `build` : construction de l'image Docker, test de démarrage, puis publication sur `ghcr.io` (hors pull request) avec les tags `<branche>` et `<branche>-<sha>`.
3. `release` : sur `main` uniquement, génération de la version avec semantic-release.

## Versions et releases

Les messages de commit suivent [Conventional Commits](https://www.conventionalcommits.org/fr/) : `type(scope): description`.

- `scope` : `angular` ou `java`, selon l'application touchée.
- `feat` : nouvelle fonctionnalité (version mineure), `fix` : correction (version corrective), `BREAKING CHANGE` dans le corps ou `!` après le type : version majeure.
- Les autres types (`docs`, `ci`, `test`, `chore`, `refactor`, `build`) ne créent pas de version.

Sur `main`, le job `release` analyse les commits de chaque application depuis son dernier tag (`angular-vX.Y.Z`, `java-vX.Y.Z`). S'il y a une nouvelle version, il met à jour `package.json` ou `build.gradle`, le `CHANGELOG.md`, crée la release GitHub, puis ajoute à l'image les tags `X.Y.Z` et `latest`.

Le job peut aussi être lancé à la main depuis l'onglet Actions (Run workflow, branche `main`).

## Images Docker

```bash
docker pull ghcr.io/alt-dev7/projet6/angular:latest
docker pull ghcr.io/alt-dev7/projet6/java:latest
```

Chaque version est aussi disponible avec son numéro (`:1.0.0`).
