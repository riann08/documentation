---
categories:
  - aws
  - containers
  - orchestration
creates_events: false
ddtype: check
dependencies:
  - 'https://github.com/DataDog/integrations-core/blob/master/ecs_fargate/README.md'
display_name: "Amazon\_Fargate"
git_integration_title: ecs_fargate
guid: 7484e55c-99ec-45ad-92f8-28e798796411
integration_id: aws-fargate
integration_title: "ECS\_Fargate"
is_public: true
kind: integration
maintainer: help@datadoghq.com
manifest_version: 1.0.0
metric_prefix: ecs.
metric_to_check: ecs.fargate.cpu.user
name: ecs_fargate
public_title: "Intégration Datadog/ECS\_Fargate"
short_description: "Surveiller des métriques pour des conteneurs fonctionnant avec ECS\_Fargate"
support: core
supported_os:
  - linux
  - mac_os
  - windows
---
## Présentation

Recueillez des métriques sur tous vos conteneurs s'exécutant dans ECS Fargate :

* Obtenez des métriques sur les limites et l'utilisation du processeur et de la mémoire.
* Surveillez vos applications s'exécutant sur Fargate grâce aux intégrations ou aux métriques custom de Datadog.

L'Agent Datadog récupère des métriques sur les conteneurs des définitions de tâches via l'endpoint Task Metadata d'ECS. Conformément à la [documentation ECS][1] :

> Cet endpoint renvoie des statistiques Docker au format JSON pour tous les conteneurs associés à la tâche. Pour en savoir plus sur les statistiques transmises, consultez la section [ContainerStats][2] de la documentation relative à l'API Docker (en anglais).

L'endpoint Task Metadata est uniquement disponible au sein de la définition de la tâche. Ainsi, l'Agent Datadog doit être exécuté en tant que conteneur supplémentaire dans la définition de la tâche.

Pour recueillir des métriques, il vous suffit de définir la variable d'environnement `ECS_FARGATE` sur `"true"` dans la définition de la tâche.

## Implémentation
Les étapes ci-dessous détaillent la configuration de l'Agent de conteneur Datadog au sein d'AWS ECS Fargate. **Attention** : la version 6.11 de l'Agent Datadog, ou une version ultérieure, est requise pour profiter de l'ensemble des fonctionnalités de l'intégration Fargate.

Les tâches sans l'Agent Datadog envoient tout de même des métriques via Cloudwatch. Néanmoins, l'Agent est requis pour utiliser Autodiscovery, obtenir des métriques détaillées sur les conteneurs, exploiter le tracing, etc. En outre, les métriques Cloudwatch sont moins granulaires et entraînent une latence plus élevée que les métriques transmises directement par l'Agent Datadog.

### Installation
Pour surveiller vos tâches ECS Fargate avec Datadog, exécutez l'Agent en tant que conteneur dans la même définition de tâche que votre application. Pour recueillir des métriques avec Datadog, chaque définition de tâche doit inclure un conteneur d'Agent Datadog en plus des conteneurs d'application. Voici les étapes de configuration à suivre :

1. **Ajouter une tâche ECS Fargate**
2. **Créer ou modifier votre stratégie IAM**
3. **Exécuter la tâche en tant que service de réplica**

#### Créer une tâche ECS Fargate
Le fonctionnement de Fargate repose sur des tâches. Celles-ci sont configurées dans les définitions de tâches. Une définition de tâche fonctionne comme un pod dans Kubernetes. Elle doit comprendre un ou plusieurs conteneurs. Pour exécuter l'Agent Datadog, créez votre définition de tâche dans le but de lancer votre ou vos conteneurs d'application, ainsi que le conteneur de l'Agent Datadog.

Les instructions ci-dessous vous expliquent comment configurer la tâche à l'aide des [outils d'interface de ligne de commande d'AWS][3] ou de la [console Web d'Amazon][4].

##### Interface utilisateur Web

1. Connectez-vous à votre [console Web AWS][4] et accédez à la section ECS.
2. Cliquez sur **Task Definitions** dans le menu de gauche, puis cliquez sur le bouton **Create new Task Definition**.
3. Sélectionnez le type de lancement **Fargate**, puis cliquez sur le bouton **Next step**.
4. Saisissez un **nom de définition de tâche**, tel que `my-app-and-datadog`.
5. Sélectionnez un rôle IAM d'exécution de tâche. Consultez les exigences des différentes permissions dans la section [Créer ou modifier votre stratégie IAM](#creer-ou-modifier-votre-strategie-iam) ci-dessous.
6. Choisissez la **mémoire de la tâche** et le **processeur de la tâche** en fonction de vos besoins.
7. Cliquez sur le bouton **Add container**.
8. Pour le champ **Container name**, saisissez `datadog-agent`.
9. Pour le champ **Image**, saisissez `datadog/agent:latest`.
10. Pour le champ **Memory Limits**, saisissez la limite souple `256`.
11. Faites défiler jusqu'à atteindre la section **Advanced container configuration**, puis saisissez `10` pour **CPU units**.
12. Pour le champ **Env Variables**, ajoutez la **clé** `DD_API_KEY` et saisissez votre [clé d'API Datadog][5] en tant que valeur. *Si vous préférez stocker vos secrets dans S3, consultez le [guide de configuration d'ECS][6].*
13. Ajoutez une autre variable d'environnement avec la **clé** `ECS_FARGATE` et la valeur `true`. Cliquez sur **Add** pour ajouter le conteneur.
14. Ajoutez vos autres conteneurs, tels que votre app. Pour en savoir plus sur la collecte des métriques d'intégration, consultez la section [Configuration d'intégration pour ECS Fargate][7].
15. Cliquez sur **Create** pour créer la définition de tâche.

##### Interface de ligne de commande d'AWS

1. Téléchargez [datadog-agent-ecs-fargate.json][8].
2. Mettez à jour le fichier JSON en ajoutant un **TASK_NAME** et votre [clé d'API Datadog][5]. Veuillez noter que la variable d'environnement `ECS_FARGATE` est déjà définie sur `"true"`.
3. Ajoutez vos autres conteneurs, tels que votre app. Pour en savoir plus sur la collecte des métriques d'intégration, consultez la section [Configuration d'intégration pour ECS Fargate][7].
3. Exécutez la commande suivante pour enregistrer la définition de tâche ECS :

```
aws ecs register-task-definition --cli-input-json file://<CHEMIN_VERS_FICHIER>/datadog-agent-ecs-fargate.json
```

#### Créer ou modifier votre stratégie IAM
Ajoutez les autorisations suivantes à votre [stratégie IAM Datadog][9] afin de recueillir des métriques ECS Fargate. Pour en savoir plus sur les stratégies ECS, [consultez la documentation du site Web d'AWS][10].

| Autorisation AWS                   | Description                                                       |
|----------------------------------|-------------------------------------------------------------------|
| `ecs:ListClusters`               | Énumère tous les clusters disponibles.                                          |
| `ecs:ListContainerInstances`     | Énumère les instances d'un cluster.                                      |
| `ecs:DescribeContainerInstances` | Décrit les instances pour ajouter des métriques sur les ressources et les tâches s'exécutant. |

#### Exécuter la tâche en tant que service de réplica
Dans ECS Fargate, vous êtes contraint d'exécuter la tâche en tant que [service de réplica][11]. L'Agent Datadog s'exécute en tant que sidecar dans chaque tâche Fargate.

##### Interface de ligne de commande d'AWS
Exécutez les commandes suivantes à l'aide des [outils d'interface de ligne de commande d'AWS][3].

**Remarque** : la version 1.1.0 ou une version ultérieure de Fargate est requise. La commande ci-dessous spécifie donc la version de la plateforme.

Si besoin, créez un cluster :

```
aws ecs create-cluster --cluster-name "<NOM_CLUSTER>"
```

Exécutez la tâche en tant que service pour votre cluster :

```
aws ecs run-task --cluster <NOM_CLUSTER> \
--network-configuration "awsvpcConfiguration={subnets=["<SOUSRÉSEAU_PRIVÉ>"],securityGroups=["<GROUPE_SÉCURITÉ>"]}" \
--task-definition arn:aws:ecs:us-east-1:<NUMÉRO_COMPTE_AWS>:task-definition/<NOM_TÂCHE>:1 \
--region <RÉGION_AWS> --launch-type FARGATE --platform-version 1.1.0
```

##### Interface utilisateur Web

1. Connectez-vous à votre [console Web AWS][4] et accédez à la section ECS. Si besoin, créez un cluster avec le modèle de cluster **Networking only**.
2. Choisissez le cluster sur lequel exécuter l'Agent Datadog.
3. Dans l'onglet **Services**, cliquez sur le bouton **Create**.
4. Pour le champ **Launch type**, choisissez **FARGATE**.
5. Pour le champ **Task Definition**, sélectionnez la tâche créée lors des précédentes étapes.
6. Saisissez un **nom de service**.
7. Pour le champ **Number of tasks**, saisissez `1`, puis cliquez sur le bouton **Next step**.
8. Sélectionnez le **VPC de cluster**, les **sous-réseaux** et les **groupes de sécurité**.
9. Les champs **Load balancing** et **Service discovery** sont facultatifs et peuvent être remplis selon vos préférences.
10. Cliquez sur le bouton **Next step**.
11. Le champ **Auto Scaling** est facultatif et peut être rempli selon vos préférences.
12. Cliquez sur le bouton **Next step**, puis sur le bouton **Create service**.

### Collecte de métriques
Une fois l'Agent Datadog configuré conformément aux instructions ci-dessus, le [check ecs_fargate][12] recueille des métriques en activant l'Autodiscovery. Ajoutez des étiquettes Docker à vos autres conteneurs dans la même tâche pour recueillir des métriques supplémentaires.

Pour en savoir plus sur la collecte de métriques d'intégration, consultez la section [Configuration d'intégration pour ECS Fargate][7].

#### DogStatsD
Les métriques sont recueillies avec [DogStatsD][13] via UDP par l'intermédiaire du port 8125.

Pour envoyer des métriques custom en effectuant une écoute sur les paquets DogStatsD à partir d'autres conteneurs, définissez la variable d'environnement `DD_DOGSTATSD_NON_LOCAL_TRAFFIC` sur `true` au sein du conteneur de l'Agent Datadog.

#### Surveillance de live processes
Activez l'[Agent de processus][14] de Datadog en définissant la variable d'environnement `DD_PROCESS_AGENT_ENABLED` sur `true` dans le conteneur de l'Agent Datadog. Puisqu'Amazon contrôle les hosts sous-jacents pour Fargate, les live processes peuvent uniquement être recueillies à partir du conteneur de l'Agent Datadog.

#### Autres variables d'environnement
Pour consulter les variables d'environnement disponibles avec le conteneur de l'Agent Datadog, consultez la section [Agent Docker][15]. **Remarque** : certaines variables ne sont pas disponibles pour Fargate.

### Métriques basées sur le crawler

Outre la collecte de métriques par l'Agent Datadog, Datadog possède également une intégration ECS basée sur CloudWatch. Celle-ci recueille les [métriques Amazon ECS CloudWatch][16].

Comme nous l'avons mentionné, les tâches Fargate transmettent également des métriques de cette façon :
> Les métriques disponibles varient en fonction du type de lancement des tâches et services de vos clusters. Si vous utilisez un type de lancement Fargate pour vos services, les métriques relatives à l'utilisation du processeur et de la mémoire vous sont fournies afin de faciliter la surveillance de vos services.

Puisque cette méthode n'utilise pas l'Agent Datadog, vous devez configurer votre intégration AWS en cochant **ECS** dans le carré d'intégration. Notre application récupère ensuite pour vous ces métriques CloudWatch (avec l'espace de nommage `aws.ecs.*` dans Datadog). Consultez la section [Données collectées][17] de la documentation.

Si ce sont les seules métriques dont vous avez besoin, vous pouvez utiliser cette intégration pour effectuer la collecte via les métriques CloudWatch. **Remarque** : les données CloudWatch sont moins granulaires (une à cinq minutes en fonction du type de surveillance activée) et leur transmission à Datadog est retardée. En effet, la collecte des données depuis CloudWatch doit respecter les limites de l'API AWS. Les données ne peuvent pas être envoyées directement à Datadog avec l'Agent.

Le crawler CloudWatch par défaut de Datadog interroge les métriques toutes les 10 minutes. SI vous avez besoin d'un programme d'analyse plus rapide, contactez [l'assistance Datadog][18] pour vérifier sa disponibilité. **Remarque** : cela entraîne une augmentation des coûts AWS, puisque CloudWatch facture des appels d'API.

### Collecte de logs

1. Définissez le AwsLogDriver Fargate dans votre tâche. [Consultez le guide de développement d'AWS Fargate][19] pour obtenir des instructions à ce sujet.

2. Les définitions de tâche Fargate prennent uniquement en charge le pilote de log awslogs pour la configuration des logs. Vous pouvez ainsi configurer vos tâches Fargate de façon à envoyer des informations de journalisation à Amazon CloudWatch Logs. Voici un extrait de définition de tâche pour laquelle le pilote de log awslogs est configuré :

    ```
    "logConfiguration": {
       "logDriver": "awslogs",
       "options": {
          "awslogs-group" : "/ecs/fargate-task-definition",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
    }
    ```

    Pour en savoir plus sur l'utilisation du pilote de log awslogs dans vos définitions de tâches afin d'envoyer des logs de conteneur à CloudWatch Logs, consultez la section [Utilisation du pilote du journal awslogs][20].

    Ce pilote recueille des logs générés par le conteneur et les envoie directement à CloudWatch.

3. Enfin, utilisez une [fonction Lambda][21] pour recueillir des logs à partir de CloudWatch et pour les envoyer à Datadog.

### Collecte de traces

1. Suivez les [instructions ci-dessus](#installation) pour ajouter le conteneur de l'Agent Datadog à la définition de votre tâche en définissant la variable d'environnement supplémentaire `DD_APM_ENABLED` sur `true`.

2. [Instrumentez votre application][24] en fonction de votre infrastructure.

3. Assurez-vous que votre application s'exécute dans la même définition de tâche que le conteneur de l'Agent Datadog.

## Données collectées

### Métriques
{{< get-metrics-from-git "ecs_fargate" >}}


### Événements

Le check ECS Fargate n'inclut aucun événement.

### Checks de service

**fargate_check**  
Renvoie `CRITICAL` si l'Agent n'est pas capable de se connecter à Fargate. Si ce n'est pas le cas, renvoie `OK`.

## Dépannage

Besoin d'aide ? Contactez [l'assistance Datadog][18].

## Pour aller plus loin

* Article de blog : [Surveiller des applications AWS Fargate avec Datadog][23]
* FAQ : [Configuration d'intégration pour ECS Fargate][7]


[1]: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-metadata-endpoint.html
[2]: https://docs.docker.com/engine/api/v1.30/#operation/ContainerStats
[3]: https://aws.amazon.com/cli
[4]: https://aws.amazon.com/console
[5]: https://app.datadoghq.com/account/settings#api
[6]: http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-config.html#ecs-config-s3
[7]: http://docs.datadoghq.com/integrations/faq/integration-setup-ecs-fargate
[8]: https://docs.datadoghq.com/resources/json/datadog-agent-ecs-fargate.json
[9]: https://docs.datadoghq.com/fr/integrations/amazon_web_services/#installation
[10]: https://docs.aws.amazon.com/IAM/latest/UserGuide/list_ecs.html
[11]: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html#service_scheduler_replica
[12]: https://github.com/DataDog/integrations-core/blob/master/ecs_fargate/datadog_checks/ecs_fargate/data/conf.yaml.example
[13]: https://docs.datadoghq.com/fr/developers/dogstatsd
[14]: https://docs.datadoghq.com/fr/graphing/infrastructure/process/?tab=docker#installation
[15]: https://docs.datadoghq.com/fr/agent/docker/#environment-variables
[16]: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cloudwatch-metrics.html
[17]: https://docs.datadoghq.com/fr/integrations/amazon_ecs/#data-collected
[18]: https://docs.datadoghq.com/fr/help
[19]: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html
[20]: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_awslogs.html
[21]: https://docs.datadoghq.com/fr/integrations/amazon_lambda/#log-collection
[22]: https://github.com/DataDog/integrations-core/blob/master/ecs_fargate/metadata.csv
[23]: https://www.datadoghq.com/blog/monitor-aws-fargate
[24]: https://docs.datadoghq.com/fr/tracing/setup/


{{< get-dependencies >}}