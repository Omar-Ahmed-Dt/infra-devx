package main

import (
    "stakpak.dev/devx/v2alpha1"
    "stakpak.dev/devx/v1/transformers/terraform/aws"
    "stakpak.dev/devx/v1/transformers/kubernetes"
    "stakpak.dev/devx/v1/transformers/terraform/k8s"
    "stakpak.dev/devx/v1/transformers/terraform/helm"
)

builders: v2alpha1.#Environments & {
    prod: {
        flows: {
            // Pipeline for adding EKS Cluster
            "eks/add-cluster": pipeline: [
                aws.#AddKubernetesCluster
            ]

            // Helm Configuration and Release Pipeline
            "terraform/helm": pipeline: [
                k8s.#AddLocalHelmProvider,
                helm.#AddHelmRelease,
            ]

            // Kubernetes Resource Pipeline
            "kubernetes/k8s": pipeline: [
                k8s.#AddKubernetesResources
            ]

            // Deployment of the Nginx Workload
            "k8s/add-deployment": pipeline: [
                kubernetes.#AddDeployment
            ]

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
