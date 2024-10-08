package main

import (
    "stakpak.dev/devx/v1"
    "stakpak.dev/devx/v1/traits"
	// "stakpak.dev/devx/k8s/stacks"
)

stack: v1.#Stack & {
    components: {
        // EKS Cluster Configuration
        eksCluster: {
            traits.#KubernetesCluster
            k8s: {
                name: "demo"
                version: {
                    minor: 26
                }
            }
            aws: {
                region: "us-east-1"
                vpc: {
                    name: "default"
                    cidr: "10.0.0.0/16"
                    subnets: {
                        private: ["10.0.1.0/24", "10.0.2.0/24"]
                        public:  ["10.0.101.0/24", "10.0.102.0/24"]
                    }
                }
            }
            eks: {
                moduleVersion: "19.21.0"
                instanceType:  "t3.small"
                minSize:       2
                maxSize:       5
                desiredSize:   2
                public:        true
            }
        }

        // Nginx Workload Deployment
        nginx: {
            $metadata: labels: "force": "true"
            traits.#Workload
            endpoints: default: {
                host: ""
                ports: [{
                    port: 8080
                }]
            }
            containers: default: {
                image: "nginx:latest"
                command: ["/bin/bash", "-c"]
                args: ["nginx -g 'daemon off;'"]
            }
        }
        // Kubernetes Basic Stack
        certManager: k8s: eksCluster.k8s
        ingressNginx: k8s: eksCluster.k8s
        externalSecretsOperator: k8s: eksCluster.k8s
    }
}
