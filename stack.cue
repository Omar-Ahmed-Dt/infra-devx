package main

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
	// "stakpak.dev/devx/k8s/stacks"
)

stack: v1.#Stack & {
	components: {
		// EKS Cluster
		eksCluster: {
		traits.#KubernetesCluster
		k8s: {
			name: "demo"
			version: {
				minor: 26
			}
		}
		// Define cert manager, ingress and eso for k8s
		// stacks.KubernetesBasicStack.components
		// certManager: k8s:             eksCluster.k8s
		// ingressNginx: k8s:            eksCluster.k8s
		// externalSecretsOperator: k8s: eksCluster.k8s

		// Create VPC
		aws: {
			region: "us-east-1"
			vpc: {
				name: "default"
                cidr: "10.0.0.0/16"
                subnets: {
                    private: ["10.0.1.0/24", "10.0.2.0/24"]
                    public: ["10.0.101.0/24", "10.0.102.0/24"]
                }
			}
			// tags: {
			// 	"karpenter.sh/discovery": k8s.name
			// }
		}

		eks: {
			moduleVersion: "19.21.0"
			instanceType:  "t3.small"
			minSize:       2
			maxSize:       5
			desiredSize:   2
			public:        true
		}

		// irsa: {
		// 	moduleVersion: "5.32.0"
		// }

		// $resources: terraform: schema.#Terraform & {
		// 	terraform: {
		// 		required_providers: {
		// 			"aws": {
		// 				source:  "hashicorp/aws"
		// 				version: aws.providerVersion
		// 			}
		// 		}
		// 	}
		// 	provider: {
		// 		"aws": {
		// 			region: aws.region
		// 		}
		// 	}
		// 	data: {
		// 		aws_vpc: "\(aws.vpc.name)": tags: Name: aws.vpc.name
		// 		aws_subnets: "\(aws.vpc.name)_private": {
		// 			filter: [
		// 				{
		// 					name: "vpc-id"
		// 					values: ["${data.aws_vpc.\(aws.vpc.name).id}"]
		// 				},
		// 				{
		// 					name: "mapPublicIpOnLaunch"
		// 					values: ["false"]
		// 				},
		// 			]
		// 		}
		// 	}

		// 	module: "\(k8s.name)": {
		// 		source:  "terraform-aws-modules/eks/aws"
		// 		version: eks.moduleVersion

		// 		cluster_name:    k8s.name
		// 		cluster_version: "\(k8s.version.major).\(k8s.version.minor)"

		// 		cluster_endpoint_public_access: eks.public

		// 		vpc_id:     "${data.aws_vpc.\(aws.vpc.name).id}"
		// 		subnet_ids: "${data.aws_subnets.\(aws.vpc.name)_private.ids}"
		// 		// control_plane_subnet_ids: module.vpc.intra_subnets

		// 		eks_managed_node_groups: {
		// 			default: {
		// 				iam_role_name:            "node-\(k8s.name)"
		// 				iam_role_use_name_prefix: false
		// 				iam_role_additional_policies: {
		// 					AmazonSSMManagedInstanceCore: "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
		// 				}

		// 				ami_type: "BOTTLEROCKET_x86_64"
		// 				platform: "bottlerocket"

		// 				min_size:     eks.minSize
		// 				max_size:     eks.maxSize
		// 				desired_size: eks.desiredSize

		// 				instance_types: [eks.instanceType]
		// 			}
		// 		}

		// 		tags: aws.tags
		// 	}

		// 	module: {
		// 		cert_manager_irsa_role: {
		// 			source:  "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
		// 			version: irsa.moduleVersion

		// 			role_name:                  "cert-manager"
		// 			attach_cert_manager_policy: true
		// 			cert_manager_hosted_zone_arns: ["arn:aws:route53:::hostedzone/Z02801112OAJQ6IQWS1U5"]

		// 			oidc_providers: {
		// 				ex: {
		// 					provider_arn: "${module.\(k8s.name).oidc_provider_arn}"
		// 					namespace_service_accounts: ["kube-system:cert-manager"]
		// 				}
		// 			}

		// 			tags: aws.tags
		// 		}
		// 		external_secrets_irsa_role: {
		// 			source:  "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
		// 			version: irsa.moduleVersion

		// 			role_name:                      "secret-store"
		// 			attach_external_secrets_policy: true
		// 			external_secrets_ssm_parameter_arns: ["arn:aws:ssm:*:*:parameter/\(k8s.name)-*"]

		// 			oidc_providers: {
		// 				ex: {
		// 					provider_arn: "${module.\(k8s.name).oidc_provider_arn}"
		// 					namespace_service_accounts: ["external-secrets:secret-store"]
		// 				}
		// 			}

		// 			tags: aws.tags
		// 		}
		// 	}
		// }
}
		// Create WorkLoad
		nginx:{
			$metadata: labels: "force": "true"
			traits.#Workload
			// Create Exposable
			endpoints: default: {
				host: ""
				ports: [{
					port: 8080
				}]}

			containers: default: {
				image: "docker/nginx"
                command: ["/bin/bash", "-c"]
				args: ["nginx -g 'daemon off;'"]

		}	
			}
	}
}