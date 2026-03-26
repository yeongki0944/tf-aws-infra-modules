module "naming_iam_role" {
  source = "../../modules/naming"

  customer      = var.customer
  project       = var.project
  environment   = var.environment
  app_name      = var.app_name
  resource_type = "iam_role"  # 결과적으로 "-role-"이 붙음
  name          = "eks-cluster"   # 용도 명시
}

module "eks" {
  # 공식 레지스트리 주소를 사용하는 것이 버전 관리에 유리합니다.
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31.0"

  # 중앙 네이밍 모듈의 결과값 적용 
  cluster_name    = module.naming_eks.result
  cluster_version = var.cluster_version

  iam_role_name            = module.naming_iam_role.result
  iam_role_use_name_prefix = false 

  # data.tf에서 조회한 VPC 및 서브넷 ID 사용 
  vpc_id     = local.vpc_id
  subnet_ids = local.private_subnet_ids

  # 컨트롤 플레인 보안 설정
  cluster_endpoint_public_access       = true
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access_cidrs = var.cluster_access_cidrs

  # 클러스터 생성자(Admin) 권한 자동 부여
  enable_cluster_creator_admin_permissions = true

  # 노드 보안 그룹에 Karpenter 식별용 태그 부여 
  node_security_group_tags = {
    "karpenter.sh/discovery" = module.naming_eks.result
  }

  tags = local.common_tags
}