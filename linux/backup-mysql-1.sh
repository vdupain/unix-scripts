#!/bin/bash

MYSQL_LOGIN=xxx
MYSQL_PASSWORD=xxx
BACKUP_LOG_ROOT=/log/backup
BACKUP_DUMP_ROOT=/backup/mysql

echo "# Sauvegarde des Bases MySql"
echo "# LOG="${BACKUP_LOG_ROOT}
echo "# DUMP="${BACKUP_DUMP_ROOT}

timestamp=$(date +%Y%m%d-%H%M%S)
prefix=`hostname -s`

# Sauvegarde de chaque Base dans un fichier
for database in `echo "show databases" | mysql -u ${MYSQL_LOGIN} -p${MYSQL_PASSWORD} --disable-pager -N`
do
        if [ "$database" != "lost+found" ]
        then
                BACKUP_FILE=${BACKUP_DUMP_ROOT}"/${prefix}-mysql-backup-"${timestamp}"-"${database}".sql"
                LOG_FILE=${BACKUP_LOG_ROOT}"/${prefix}-mysql-backup-"${timestamp}"-"${database}".log"
                echo "#"$(date +%Y%m%d-%H%M%S)"# DEBUT Sauvegarde de ["${database}"] in ["${BACKUP_FILE}"]"
                # liste des options de sauvegarde
                # -q recuperation 1 ligne a la foi pour la sauvegarde
                # -c | --complete-insert : insertion complete avec les noms de colonnes
                # --allow-keywords prefixe les noms de colonne avec la table
                # -i ajout de commentaires : version ...
                # --add-locks : ajoute une instruction LOCK TABLSS avant et UNLOCK TABLES apres pour accelerer les insertions dans mysql
                # --create-options : ajoute toutes options specifiques MySql dans le script de creation de table
                # --default-character-set=XXXXX : le charset par defaut (si non specifie alors utf8)
                # -e | --extended-insert : utilise la nouvelle syntaxe INSERT multi-ligne (plus courtes et plus efficaces)
                # -q | --quick : ne garde pas en buffer les requetes mais ecrit immediatement sur la sortie
                # -Q | --quote-names : protege les noms de table et colonnes avec le caractere '`'
                #
                # --opt est equivalent a --quick --add-drop-table --add-locks --extended-insert --lock-tables
                #
                # mysqldump --add-drop-table --allow-keywords --default-character-set=latin1 -q -c -u${MYSQL_LOGIN} -p${MYSQL_PASSWORD} ${database} > ${BACKUP_FILE}
                # mysqldump --quick --add-locks --extended-insert --lock-tables --allow-keywords --default-character-set=latin1 -c -u${MYSQL_LOGIN} -p${MYSQL_PASSWORD} ${database} > ${BACKUP_FILE}
                # mysqldump --quick --add-locks --extended-insert --lock-tables --allow-keywords --default-character-set=latin1 -c -u${MYSQL_LOGIN} -p${MYSQL_PASSWORD} ${database} | gzip > ${BACKUP_FILE}.gz
                mysqldump --quick --add-locks --extended-insert --lock-tables --allow-keywords --default-character-set=latin1 -c -u${MYSQL_LOGIN} -p${MYSQL_PASSWORD} ${database} | bzip2 -9 > ${BACKUP_FILE}.bz
                retour=$?
                if [ "$retour" -eq "0" ]
                then
                        echo "#"$(date +%Y%m%d-%H%M%S)"# La sauvegarde s'est correctement deroulee"
			echo "#"$(date +%Y%m%d-%H%M%S)"# Purge des backups de plus de 30 jours."
			find ${BACKUP_LOG_ROOT}/* -type f -mtime +30 -exec rm {} \;
                else
                        echo "#"$(date +%Y%m%d-%H%M%S)"# La sauvegarde s'est terminee en ERREUR"
                fi
                echo "#"$(date +%Y%m%d-%H%M%S)"# FIN Sauvegarde de ["${database}"] in ["${BACKUP_FILE}"]"
        fi
done

exit $retour

