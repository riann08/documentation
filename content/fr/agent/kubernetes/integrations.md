---
title: Intégrations personnalisées
kind: documentation
further_reading:
  - link: agent/kubernetes/daemonset_setup
    tag: documentation
    text: Configuration de DaemonSet avec Kubernetes
  - link: agent/kubernetes/host_setup
    tag: documentation
    text: Configuration de host avec Kubernetes
---
## ConfigMap

Il est possible d'utiliser une ConfigMap pour configurer ou activer des intégrations.
Pour ce faire, il vous suffit de créer une ConfigMap avec la configuration des intégrations concernées.
Ajoutez ensuite une référence vers cette ConfigMap dans les volumes du manifeste de votre Agent.

Dans l'exemple qui suit, nous allons personnaliser les champs name, url et tags du [check HTTP][1].
Pour activer d'autres intégrations, spécifiez simplement le bon nom YAML en vous assurant que son format est valide.

```yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: dd-agent-config
  namespace: default
data:
  http-config: |-
    init_config:
    instances:
    - name: Mon service
      url: mon.service:port/healthz
      tags:
        - service:critical
---
```
Dans le manifeste de votre Agent (DaemonSet/deployment), ajoutez le code suivant :
```yaml
[...]
        volumeMounts:
        [...]
          - name: dd-agent-config
            mountPath: /conf.d
      volumes:
      [...]
        - name: dd-agent-config
          configMap:
            name: dd-agent-config
            items:
            - key: http-config
              path: http_check.yaml
[...]
```

### Monter un fichier de configuration personnalisé dans un conteneur avec une ConfigMap

Pour monter un fichier `datadog.yaml` dans un conteneur avec une ConfigMap, ajoutez le code suivant dans votre manifeste DaemonSet :

```yaml
[...]
        volumeMounts:
        [...]
          - name: confd-config
            mountPath: /conf.d
          - name: datadog-yaml
            mountPath: /etc/datadog-agent/datadog.yaml
            subPath: datadog.yaml
      volumes:
      [...]
        - name: confd-config
          configMap:
            name: dd-agent-config
            items:
              - key: http-config
                path: http_check.yaml
        - name: datadog-yaml
          configMap:
            name: dd-agent-config
            items:
              - key: datadog-yaml
                path: datadog.yaml
[...]
```

Ajoutez également ce qui suit dans votre ConfigMap :

```yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: dd-agent-config
  namespace: default
data:
  http-config: |-
    init_config:
    instances:
  datadog-yaml: |-
    check_runners: 1
    listeners:
      - name: kubelet
    config_providers:
      - name: kubelet
        polling: true
```


## Annotations

Il est également possible d'activer les intégrations via les annotations contenues dans le manifeste de votre application.
Pour ce faire, vous pouvez utiliser Autodiscovery. Pour en savoir plus, consultez la section [Autodiscovery][2].

## Pour aller plus loin

{{< partial name="whats-next/whats-next.html" >}}

[1]: /fr/integrations/http_check
[2]: /fr/agent/autodiscovery/integrations/?tab=kubernetespodannotations#configuration