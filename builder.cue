package main

import (
	"stakpak.dev/devx/v2alpha1"
	"stakpak.dev/devx/v1/transformers/terraform/aws"
	// "stakpak.dev/devx/v1/traits"
	"stakpak.dev/devx/v1/transformers/kubernetes"
	"stakpak.dev/devx/v1/transformers/terraform/helm"
	"stakpak.dev/devx/v1/transformers/terraform/k8s"
)

builders: v2alpha1.#Environments & {
	prod: {
		flows: {
			"eks/add-cluster": pipeline: [aws.#AddKubernetesCluster]
			// "ignore-k8s-cluster": pipeline: [{traits.#KubernetesCluster}]
			"terraform/helm": pipeline: [
				k8s.#AddLocalHelmProvider,
				helm.#AddHelmRelease,
			]
			"kubernetes/k8s": pipeline: [
				k8s.#AddKubernetesResources,
			]
			"k8s/add-deployment": {
				pipeline: [kubernetes.#AddDeployment]
			}
			"k8s/add-labels": pipeline: [kubernetes.#AddLabels & {
				labels: [string]: string
			}]
			"k8s/add-annotations": pipeline: [kubernetes.#AddAnnotations & {
				annotations: [string]: string
			}]
			"k8s/add-ingress": pipeline: [
				kubernetes.#AddIngress & kubernetes.#AddAnnotations & {
					ingressClassName: "nginx"
					tlsSecretName:    "secret"
				} & kubernetes.#AddNamespace & {
					namespace: string | *"default"
				},
			]
		}
	}
}
