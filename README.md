# Book Review Application

[![Lines of Code](https://sonarcloud.io/api/project_badges/measure?project=imShakil_book-review-k8s&metric=ncloc)](https://sonarcloud.io/summary/new_code?id=imShakil_book-review-k8s)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=imShakil_book-review-k8s&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=imShakil_book-review-k8s)
[![Reliability Rating](https://sonarcloud.io/api/project_badges/measure?project=imShakil_book-review-k8s&metric=reliability_rating)](https://sonarcloud.io/summary/new_code?id=imShakil_book-review-k8s)
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=imShakil_book-review-k8s&metric=security_rating)](https://sonarcloud.io/summary/new_code?id=imShakil_book-review-k8s)
[![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=imShakil_book-review-k8s&metric=sqale_rating)](https://sonarcloud.io/summary/new_code?id=imShakil_book-review-k8s)
[![Duplicated Lines (%)](https://sonarcloud.io/api/project_badges/measure?project=imShakil_book-review-k8s&metric=duplicated_lines_density)](https://sonarcloud.io/summary/new_code?id=imShakil_book-review-k8s)

## Overview

This repository contains the **Book Review Application**, a cloud-native application deployed on Kubernetes. It serves as a demonstration of deploying monolithic applications on Kubernetes on a production-grade cluster.

## Infrastructure

The underlying Kubernetes cluster for this application is provisioned using **kOps** on AWS. The infrastructure automation and cluster lifecycle management are handled by the **k8s-with-kops** project.

### Cluster Details

The cluster infrastructure (managed in `k8s-with-kops`) features:

* **Provisioning Tool**: kOps (Kubernetes Operations).
* **Cloud Provider**: AWS (Amazon Web Services).
* **Networking**: Calico CNI for pod networking.
* **Infrastructure as Code**: Terraform is used alongside kOps for state management and resource provisioning.
* **CI/CD**: GitHub Actions workflows automate the deployment and destruction of the cluster.

For details on the cluster creation process, refer to the `deploy-cluster.yml` workflow in the **k8s-with-kops** repository.

## CI/CD Pipeline

This project utilizes **GitHub Actions** for Continuous Integration and Continuous Deployment. The pipeline ensures code quality and automates the delivery process:

* **Build & Test**: Compiles the code and runs automated tests.
* **Code Quality**: Integrates with SonarCloud for static analysis.
* **Containerization**: Builds Docker images and pushes them to a container registry.
* **Deployment**: Applies Kubernetes manifests to the cluster created by `k8s-with-kops`.

## Kubernetes Manifests

The application's lifecycle in the cluster is defined by Kubernetes manifest files found in this repository. These manifests include:

* **Deployment**: Defines the application pods, replica sets, and update strategies.
* **Service**: Exposes the application to the network.
* **Ingress/ConfigMaps**: Handles external access and configuration management.
