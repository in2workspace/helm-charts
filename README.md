# IN2 Helm Repository for Generic Enablers.

Repository for providing [HELM Charts](https://helm.sh/) of Generic Enablers from the IN2 components. The charts can be installed into  [Kubernetes](https://kubernetes.io/) with [helm3](https://helm.sh/docs/).

IN2 works on different open source components which can be assembled together and with other third-party platform components to accelerate the development of Smart Solutions.

For additional Helm Charts collections for supplementary open-source components such as Grafana, Apache Spark, Keycloak and Kong we recommend other community-maintained listings such as [Bitnami](https://github.com/bitnami/charts/tree/master/bitnami) or [Orchestra Cities](https://github.com/orchestracities/charts) or searching for a specific helm chart on [Artifact Hub](https://artifacthub.io/packages/search?page=1&kind=0).

More information on each individual IN2 component, can be found within the individual chart README.

## Add Repo

To make use of the charts, you may add the repository:

```console
helm repo add in2 https://in2workspace.github.io/helm-charts
```

## Install

After the repo is added all charts can be installed via:

```console
helm install <RELEASE_NAME> in2workspace/<CHART_NAME>
```

## Configuration

## Platform deployment

---

## License

[Apache 2.0](./LICENSE). © 2024 IN2 Ingeniería de la Información, S.L.
