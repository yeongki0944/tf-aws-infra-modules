# =============================================================
# ArgoCD AppProjects — 역할별 분리
# =============================================================

# Namespace 생성
resource "kubernetes_namespace" "argocd_apps" {
  for_each = toset(var.argocd_namespaces)

  metadata {
    name = each.key
  }
}

# Platform Project
resource "kubernetes_manifest" "project_platform" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = "platform"
      namespace = "argocd"
    }
    spec = {
      description = "Platform infrastructure components"
      sourceRepos = concat([var.gitops_repo_url], var.allowed_source_repos)
      destinations = [
        {
          server    = "https://kubernetes.default.svc"
          namespace = "*"
        }
      ]
      clusterResourceWhitelist = [
        { group = "*", kind = "*" }
      ]
      namespaceResourceWhitelist = [
        { group = "*", kind = "*" }
      ]
    }
  }
}

# Apps Project
resource "kubernetes_manifest" "project_apps" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = "apps"
      namespace = "argocd"
    }
    spec = {
      description = "Application services"
      sourceRepos = [var.gitops_repo_url]
      destinations = [
        {
          server    = "https://kubernetes.default.svc"
          namespace = "default"
        },
        {
          server    = "https://kubernetes.default.svc"
          namespace = "apps"
        }
      ]
      namespaceResourceWhitelist = [
        { group = "*", kind = "*" }
      ]
    }
  }
}

# =============================================================
# ArgoCD Root Application — App of Apps 패턴
# =============================================================

resource "kubernetes_manifest" "root_app_platform" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "platform-root"
      namespace = "argocd"
    }
    spec = {
      project = "platform"
      source = {
        repoURL        = var.gitops_repo_url
        targetRevision = var.gitops_repo_branch
        path           = "platform"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "argocd"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }

  depends_on = [kubernetes_manifest.project_platform]
}

# =============================================================
# ArgoCD Git Repository Secret
# =============================================================

resource "kubernetes_secret" "gitops_repo" {
  count = var.gitops_repo_private ? 1 : 0

  metadata {
    name      = "gitops-repo"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type     = "git"
    url      = var.gitops_repo_url
    username = var.gitops_repo_username
    password = var.gitops_repo_password
  }
}

# =============================================================
# Cluster Metadata ConfigMap
# =============================================================

resource "kubernetes_config_map" "cluster_metadata" {
  metadata {
    name      = "cluster-metadata"
    namespace = "argocd"
  }

  data = {
    cluster_name                 = local.cluster_name
    vpc_id                       = local.vpc_id
    region                       = var.region
    loki_irsa_arn                = local.loki_irsa_arn
    opencost_irsa_arn            = local.opencost_irsa_arn
    loki_chunks_bucket           = local.loki_chunks_bucket
    loki_ruler_bucket            = local.loki_ruler_bucket
    karpenter_node_iam_role_name = local.karpenter_node_iam_role_name
  }
}
