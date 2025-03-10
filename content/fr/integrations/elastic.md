---
aliases:
  - /fr/integrations/elasticsearch
categories:
  - data store
  - log collection
creates_events: true
ddtype: check
dependencies:
  - 'https://github.com/DataDog/integrations-core/blob/master/elastic/README.md'
display_name: Elasticsearch
git_integration_title: elastic
guid: d91d91bd-4a8e-4489-bfb1-b119d4cc388a
integration_id: elasticsearch
integration_title: ElasticSearch
is_public: true
kind: integration
maintainer: help@datadoghq.com
manifest_version: 1.0.0
metric_prefix: elasticsearch.
metric_to_check: elasticsearch.search.query.total
name: elastic
process_signatures:
  - java org.elasticsearch.bootstrap.Elasticsearch
public_title: Intégration Datadog/ElasticSearch
short_description: Surveiller le statut global d'un cluster en mesurant l'utilisation de tas de la JVM et une vaste gamme de données in between.
support: core
supported_os:
  - linux
  - mac_os
  - windows
---
![dashboard Elasticsearch][1]

## Présentation

Obtenez les dernières données sur la santé de votre cluster Elasticsearch, que ce soit pour son statut global ou l'utilisation de tas de la JVM. Recevez des notifications lorsque vous devez réactiver un réplica, renforcer les capacités du cluster ou ajuster sa configuration. Surveillez ensuite les métriques de cluster obtenues.

Le check Elasticsearch de l'Agent Datadog recueille des métriques pour la recherche et l'indexation des performances, l'utilisation et le nettoyage de la mémoire, la disponibilité des nœuds, les statistiques des partitions, les performances du disque et l'espace disque, les tâches en attente et bien plus encore. L'Agent envoie également des checks de service et des événements relatifs au statut global de votre cluster.

## Implémentation
### Installation

Le check Elasticsearch est inclus avec le paquet de l'[Agent Datadog][2] : vous n'avez donc rien d'autre à installer sur vos nœuds Elasticsearch, ou sur d'autres serveurs si vous utilisez une instance Elasticsearch hébergée (par ex., Elastic Cloud).

### Configuration

1. Modifiez le fichier `elastic.d/conf.yaml` dans le dossier `conf.d/` à la racine du [répertoire de configuration de votre Agent][3] pour commencer à recueillir vos [métriques](#collecte-de-metriques) et [logs](#collecte-de-logs) Elasticsearch.
  Consultez le [fichier d'exemple elastic.d/conf.yaml][4] pour découvrir toutes les options de configuration disponibles.

2. [Redémarrez l'Agent][5].

#### Collecte de métriques

*  Ajoutez ce bloc de configuration à votre fichier `elastic.yaml` pour commencer à recueillir vos [métriques Elasticsearch](#metriques) :

```yaml
init_config:

instances:
  - url: http://localhost:9200 # ou l'emplacement sur lequel l'API de votre cluster effectue son écoute
    cluster_stats: false # définir sur true SEULEMENT si vous n'effectuez pas le check sur chaque nœud du cluster
    pshard_stats: true # l'Agent envoie des métriques de partition principales
    index_stats: true # l'Agent envoie des métriques au niveau de l'index
    pending_task_stats: true # l'Agent envoie des métriques de tâches en attente à l'échelle du cluster
```

**Remarque** :

* Si vous recueillez des métriques Elasticsearch à partir d'un seul Agent Datadog s'exécutant en dehors du cluster, par exemple si vous utilisez une instance Elasticsearch hébergée, définissez `cluster_stats` sur true.

* Pour utiliser l'intégration Elasticsearch de l'Agent pour les services AWS Elasticsearch AWS, définissez le paramètre `url` afin de rediriger vers votre URL stats AWS Elasticsearch.

Consultez l’[exemple de fichier elastic.yaml][4] pour découvrir toutes les options de configuration disponibles, y compris les options d'authentification et de vérification SSL de l'`url` d'API de votre cluster.

Enfin, [redémarrez l'Agent][5] pour commencer à envoyer vos métriques Elasticsearch à Datadog.

#### Collecte de logs

**Disponible à partir des versions > 6.0 de l'Agent**

* La collecte de logs est désactivée par défaut dans l'Agent Datadog. Vous devez l'activer dans le fichier `datadog.yaml` avec :

  ```
  logs_enabled: true
  ```

* Ajoutez ensuite ce bloc de configuration à votre fichier `elastic.d/conf.yaml` pour commencer à recueillir vos logs Elasticsearch :

  ```yaml
    logs:
        - type: file
          path: /var/log/elasticsearch/*.log
          source: elasticsearch
          service: myservice
  ```

  Modifiez les valeurs des paramètres `path` et `service` et configurez-les pour votre environnement.

* [Redémarrez l'Agent][5] pour commencer à envoyer vos logs Elasticsearch à Datadog.

**Pour en savoir plus sur la collecte de logs, consultez [la documentation relative aux logs][6].**

### Validation

[Lancez la sous-commande `status` de l'Agent][7] et cherchez `elastic` dans la section Checks.

## Données collectées

Par défaut, les métriques suivantes ne sont pas toutes envoyées par l'Agent. Pour envoyer toutes les métriques, configurez les flags dans `elastic.yaml`, comme illustré ci-dessus.

* `pshard_stats` envoie les métriques **elasticsearch.primaries.\*** et **elasticsearch.indices.count**.
* `index_stats` envoie les métriques **elasticsearch.index.\***.
* `pending_task_stats` envoie les métriques **elasticsearch.pending_\***.

Pour la version >=6.3.0, définissez la configuration `xpack.monitoring.collection.enabled` sur `true` dans votre configuration Elasticsearch afin de recueillir toutes les métriques `elasticsearch.thread_pool.write.*`. Consultez la [section Monitoring des notes de version d'Elasticsearch][8].

### Métriques
{{< get-metrics-from-git "elastic" >}}


### Événements

Le check Elasticsearch envoie un événement à Datadog à chaque changement de statut global de votre cluster Elasticsearch : rouge, jaune ou vert.

### Checks de service

`elasticsearch.cluster_health` :

Renvoie `OK` si le statut du cluster est vert, renvoie `Warn` si le statut est jaune ou renvoie `Critical` pour les autres cas.

`elasticsearch.can_connect` :

Renvoie `Critical` si l'Agent n'est pas capable de se connecter à Elasticsearch pour recueillir des métriques.

## Dépannage

* [Connexion impossible de l'Agent][10]
* [Pourquoi Elasticsearch n'envoie-t-il pas toutes mes métriques ?][11]

## Pour aller plus loin
Pour mieux comprendre comment (ou pourquoi) intégrer votre cluster Elasticsearch à Datadog, lisez notre [série d'articles de blog][12] à ce sujet.


[1]: https://raw.githubusercontent.com/DataDog/integrations-core/master/elastic/images/elasticsearch-dash.png
[2]: https://app.datadoghq.com/account/settings#agent
[3]: https://docs.datadoghq.com/fr/agent/guide/agent-configuration-files/?tab=agentv6#agent-configuration-directory
[4]: https://github.com/DataDog/integrations-core/blob/master/elastic/datadog_checks/elastic/data/conf.yaml.example
[5]: https://docs.datadoghq.com/fr/agent/guide/agent-commands/?tab=agentv6#start-stop-and-restart-the-agent
[6]: https://docs.datadoghq.com/fr/logs
[7]: https://docs.datadoghq.com/fr/agent/guide/agent-commands/?tab=agentv6#agent-status-and-information
[8]: https://www.elastic.co/guide/en/elasticsearch/reference/current/release-notes-6.3.0.html
[9]: https://github.com/DataDog/integrations-core/blob/master/elastic/metadata.csv
[10]: https://docs.datadoghq.com/fr/integrations/faq/elastic-agent-can-t-connect
[11]: https://docs.datadoghq.com/fr/integrations/faq/why-isn-t-elasticsearch-sending-all-my-metrics
[12]: https://www.datadoghq.com/blog/monitor-elasticsearch-performance-metrics


{{< get-dependencies >}}