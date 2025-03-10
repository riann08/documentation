---
integration_title: Hdfs
is_public: true
kind: integration
short_description: 'Surveillez l''utilisation des disques du cluster, les échecs de volume, les DataNodes morts, etc. more.'
---
## Intégration DataNode HDFS

![Dashboard HDFS][1]

## Présentation

Surveillez l'utilisation du disque et les volumes ayant échoué sur chacun de vos DataNodes HDFS. Ce check de l'Agent recueille des métriques pour ces derniers, ainsi que des métriques liées aux blocs et au cache.

Utilisez ce check (hdfs_datanode) et son check complémentaire (hdfs_namenode), et non l'ancien check deux-en-un (hdfs), désormais obsolète.

## Implémentation
### Installation

Le check HDFS DataNode est inclus avec le paquet de l'[Agent Datadog][2] : vous n'avez donc rien d'autre à installer sur vos DataNodes.

### Configuration
#### Préparer le DataNode

L'Agent recueille des métriques à partir de l'interface distante JMX de DataNode. L'interface est désactivée par défaut. Activez-la en définissant l'option suivante dans `hadoop-env.sh` (qui se trouve généralement dans $HADOOP_HOME/conf) :

```
export HADOOP_DATANODE_OPTS="-Dcom.sun.management.jmxremote
  -Dcom.sun.management.jmxremote.authenticate=false
  -Dcom.sun.management.jmxremote.ssl=false
  -Dcom.sun.management.jmxremote.port=50075 $HADOOP_DATANODE_OPTS"
```

Redémarrez le processus DataNode pour activer l'interface JMX.

#### Connecter l'Agent

Modifiez le fichier `hdfs_datanode.d/conf.yaml` dans le dossier `conf.d/` à la racine du [répertoire de configuration de votre Agent][3]. Consultez le [fichier d'exemple hdfs_datanode.d/conf.yaml][4] pour découvrir toutes les options de configuration disponibles :

```
init_config:

instances:
  - hdfs_datanode_jmx_uri: http://localhost:50075
```

[Redémarrez l'Agent][5] pour commencer à envoyer vos métriques DataNode à Datadog.

### Validation

[Lancez la sous-commande `status` de l'Agent][6] et cherchez `hdfs_datanode` dans la section Checks.

## Données collectées
### Métriques
{{< get-metrics-from-git "hdfs_datanode" >}}


### Événements
Le check HDFS DataNode n'inclut aucun événement.

### Checks de service

`hdfs.datanode.jmx.can_connect` :

Renvoie `Critical` si l'Agent n'est pas capable de se connecter à l'interface JMX de DataNode pour une raison quelconque (p. ex, mauvais port fourni, expiration du délai, réponse JSON non analysable).

## Dépannage
Besoin d'aide ? Contactez [l'assistance Datadog][8].

## Pour aller plus loin

* [Vue d'ensemble de l'architecture Hadoop][9]
* [Comment surveiller des métriques Hadoop][10]
* [Comment recueillir des métriques Hadoop][11]
* [Comment surveiller Hadoop avec Datadog][12]


[1]: https://raw.githubusercontent.com/DataDog/integrations-core/master/hdfs_datanode/images/hadoop_dashboard.png
[2]: https://app.datadoghq.com/account/settings#agent
[3]: https://docs.datadoghq.com/fr/agent/guide/agent-configuration-files/?tab=agentv6#agent-configuration-directory
[4]: https://github.com/DataDog/integrations-core/blob/master/hdfs_datanode/datadog_checks/hdfs_datanode/data/conf.yaml.example
[5]: https://docs.datadoghq.com/fr/agent/guide/agent-commands/?tab=agentv6#start-stop-and-restart-the-agent
[6]: https://docs.datadoghq.com/fr/agent/guide/agent-commands/?tab=agentv6#agent-status-and-information
[7]: https://github.com/DataDog/integrations-core/blob/master/hdfs_datanode/metadata.csv
[8]: https://docs.datadoghq.com/fr/help
[9]: https://www.datadoghq.com/blog/hadoop-architecture-overview
[10]: https://www.datadoghq.com/blog/monitor-hadoop-metrics
[11]: https://www.datadoghq.com/blog/collecting-hadoop-metrics
[12]: https://www.datadoghq.com/blog/monitor-hadoop-metrics-datadog


{{< get-dependencies >}}


## Intégration NameNode HDFS

![Dashboard HDFS][111]

## Présentation

Surveillez vos nœuds primaires _et_ secondaires NameNodes HDFS pour savoir si votre cluster est en situation précaire, c'est-à-dire s'il ne reste plus qu'un seul NameNode ou si vous devez renforcer les capacités du cluster. Ce check de l'Agent recueille des métriques pour la capacité restante, les blocs corrompus/manquants, les DataNodes morts, la charge du système de fichiers, les blocs sous-répliqués, les échecs de volumes totaux (sur tous les DataNodes), et bien plus encore.

Utilisez ce check (hdfs_namenode) et son check complémentaire (hdfs_datanode), et non l'ancien check deux-en-un (hdfs) qui est obsolète.

## Implémentation
### Installation

Le check HDFS NameNode est inclus avec le paquet de l'[Agent Datadog][112] : vous n'avez donc rien d'autre à installer sur vos NameNodes.

### Configuration
#### Préparer le NameNode

L'Agent recueille des métriques à partir de l'interface distante JMX de NameNode. L'interface est désactivée par défaut. Activez-la en définissant l'option suivante dans `hadoop-env.sh` (qui se trouve généralement dans $HADOOP_HOME/conf) :

```
export HADOOP_NAMENODE_OPTS="-Dcom.sun.management.jmxremote
  -Dcom.sun.management.jmxremote.authenticate=false
  -Dcom.sun.management.jmxremote.ssl=false
  -Dcom.sun.management.jmxremote.port=50070 $HADOOP_NAMENODE_OPTS"
```

Redémarrez le processus NameNode pour activer l'interface JMX.

#### Connecter l'Agent

Modifiez le fichier `hdfs_namenode.d/conf.yaml` dans le dossier `conf.d/` à la racine du [répertoire de configuration de votre Agent][113]. Consultez le [fichier d'exemple hdfs_namenode.d/conf.yaml][114] pour découvrir toutes les options de configuration disponibles :

```
init_config:

instances:
  - hdfs_namenode_jmx_uri: http://localhost:50070
```

[Redémarrez l'Agent][115] pour commencer à envoyer vos métriques NameNode à Datadog.

### Validation

[Lancez la sous-commande `status` de l'Agent][116] et cherchez `hdfs_namenode` dans la section Checks.

## Données collectées
### Métriques
{{< get-metrics-from-git "hdfs_namenode" >}}


### Événements
Le check HDFS NameNode n'inclut aucun événement.

### Checks de service

`hdfs.namenode.jmx.can_connect` :

Renvoie `Critical` si l'Agent n'est pas capable de se connecter à l'interface JMX de NameNode pour une raison quelconque (p. ex, mauvais port fourni, expiration du délai, réponse JSON non analysable).

## Dépannage
Besoin d'aide ? Contactez [l'assistance Datadog][118].

## Pour aller plus loin

* [Vue d'ensemble de l'architecture Hadoop][119]
* [Comment surveiller des métriques Hadoop][1110]
* [Comment recueillir des métriques Hadoop][1111]
* [Comment surveiller Hadoop avec Datadog][1112]


[111]: https://raw.githubusercontent.com/DataDog/integrations-core/master/hdfs_datanode/images/hadoop_dashboard.png
[112]: https://app.datadoghq.com/account/settings#agent
[113]: https://docs.datadoghq.com/fr/agent/guide/agent-configuration-files/?tab=agentv6#agent-configuration-directory
[114]: https://github.com/DataDog/integrations-core/blob/master/hdfs_namenode/datadog_checks/hdfs_namenode/data/conf.yaml.example
[115]: https://docs.datadoghq.com/fr/agent/guide/agent-commands/?tab=agentv6#start-stop-and-restart-the-agent
[116]: https://docs.datadoghq.com/fr/agent/guide/agent-commands/?tab=agentv6#agent-status-and-information
[117]: https://github.com/DataDog/integrations-core/blob/master/hdfs_namenode/metadata.csv
[118]: https://docs.datadoghq.com/fr/help
[119]: https://www.datadoghq.com/blog/hadoop-architecture-overview
[1110]: https://www.datadoghq.com/blog/monitor-hadoop-metrics
[1111]: https://www.datadoghq.com/blog/collecting-hadoop-metrics
[1112]: https://www.datadoghq.com/blog/monitor-hadoop-metrics-datadog


{{< get-dependencies >}}