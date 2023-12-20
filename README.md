# IN2 Helm Repository for Generic Enablers.

Repository for providing [HELM Charts](https://helm.sh/) of Generic Enablers from the IN2 components. The charts can be installed into  [Kubernetes](https://kubernetes.io/) with [helm3](https://helm.sh/docs/).

IN2 works on different open source components which can be assembled together and with other third-party platform components to accelerate the development of Smart Solutions.

For additional Helm Charts collections for supplementary open-source components such as Grafana, Apache Spark, Keycloak and Kong we recommend other community-maintained listings such as [Bitnami](https://github.com/bitnami/charts/tree/master/bitnami) or [Orchestra Cities](https://github.com/orchestracities/charts) or searching for a specific helm chart on [Artifact Hub](https://artifacthub.io/packages/search?page=1&kind=0).

More information on each individual IN2 component, can be found within the individual chart README.

## Add Repo

To make use of the charts, you may add the repository:

```console
helm repo add fiware https://fiware.github.io/helm-charts
```

## Install

After the repo is added all charts can be installed via:

```console
helm install <RELEASE_NAME> fiware/<CHART_NAME>
```

## Configuration

If you are searching for some configurations that can be used in a production environment, we recommend our [Loadtest Repository](https://github.com/FIWARE/orion-loadtest). It provides values for different sizes of environments and the configuration for [Orion-LD](https://github.com/FIWARE/context.Orion-LD) and [Mongo-DB](https://www.mongodb.com/).

## Platform deployment

An easy to use deployment of a FIWARE Platform(including a SmartCity-Application) based on the Helm-Charts can be found in the [FIWARE-Ops/marinera](https://github.com/FIWARE-Ops/marinera) Repository.

---

## License

[MIT](./LICENSE). © 2020-21 FIWARE Foundation e.V.