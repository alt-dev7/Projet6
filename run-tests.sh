#!/usr/bin/env bash
# Lance les tests des applications et regroupe les rapports JUnit dans test-results/
# Usage : ./run-tests.sh [angular|java|all]

cible="${1:-all}"
racine="$(cd "$(dirname "$0")" && pwd)"
resultats="$racine/test-results"
db_hote="${DB_HOST:-localhost}"
db_port="${DB_PORT:-5432}"
echec=0

manque() {
  echo "Erreur : $1" >&2
  echo "$2 : ÉCHEC"
  echec=1
}

tests_angular() {
  local dir="$1"
  command -v npm > /dev/null || { manque "npm introuvable" angular; return; }
  [ -x "${CHROME_BIN:-}" ] || { manque "CHROME_BIN doit pointer vers Chrome" angular; return; }

  cd "$dir" || return
  [ -d node_modules ] || npm ci
  rm -rf reports
  if npm test; then echo "angular : OK"; else echo "angular : ÉCHEC"; echec=1; fi

  mkdir -p "$resultats/angular"
  cp reports/*.xml "$resultats/angular/" 2> /dev/null
  rm -rf reports
}

tests_java() {
  local dir="$1"
  local java="${JAVA_HOME:+$JAVA_HOME/bin/}java"
  "$java" -version 2>&1 | grep -q '"21' || { manque "JDK 21 requis (JAVA_HOME)" java; return; }
  (echo > "/dev/tcp/$db_hote/$db_port") 2> /dev/null ||
    { manque "PostgreSQL injoignable sur $db_hote:$db_port" java; return; }

  cd "$dir" || return
  if ./gradlew clean test; then echo "java : OK"; else echo "java : ÉCHEC"; echec=1; fi

  mkdir -p "$resultats/java"
  cp build/test-results/test/*.xml "$resultats/java/"
}

case "$cible" in
  angular | java | all) ;;
  *) echo "Usage : $0 [angular|java|all]" >&2; exit 2 ;;
esac

rm -rf "$resultats"
mkdir -p "$resultats"

detectes=0
for dir in "$racine"/*/; do
  if [ -f "$dir/angular.json" ]; then type=angular
  elif [ -f "$dir/gradlew" ]; then type=java
  else continue
  fi
  [ "$cible" = all ] || [ "$cible" = "$type" ] || continue
  detectes=$((detectes + 1))
  "tests_$type" "$dir"
done

if [ "$detectes" -eq 0 ]; then
  echo "Erreur : aucun projet $cible détecté" >&2
  exit 1
fi

exit $echec
