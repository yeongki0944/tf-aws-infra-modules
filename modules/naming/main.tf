locals {
  # 1. 모든 입력값을 소문자로 변환하여 일관성 유지 (S3 등 제약사항 대응)
  cst = lower(var.customer)
  prj = lower(var.project)
  env = lower(var.environment)
  app = lower(var.app_name)

  # 2. 리소스 타입별 표준 약어 사전 (MSP 표준 가이드)
  # 필요에 따라 이 리스트를 확장하여 팀 내 표준으로 사용합니다.
  resource_abbr = {
    # Network
    virtual_private_cloud = "vpc"
    subnet               = "sbn"
    security_group        = "sg"
    internet_gateway      = "igw"
    nat_gateway           = "nat"
    route_table           = "rt"

    # Compute
    ec2_instance         = "ec2"
    eks_cluster          = "eks"
    launch_template      = "lt"

    # Storage & Data
    s3_bucket            = "s3"
    ecr_repository       = "ecr"
    rds_instance         = "rds"
    dynamodb_table       = "ddb"

    # IAM & Others
    iam_role             = "iam-role"
    iam_policy           = "iam-pol"
    kms_key              = "kms"
    acm_certificate      = "acm"
  }

  # 3. 표준 프리픽스 조합: [고객사]-[프로젝트]-[환경]-[앱]
  # 예: bsg-edu-dev-eks
  prefix = "${local.cst}-${local.prj}-${local.env}-${local.app}"

  # 4. 최종 리소스 이름 조합: [프리픽스]-[약어]-[용도]
  # lookup을 사용하여 사전에서 약어를 찾고, 없을 경우 "res"를 기본값으로 사용합니다.
  # 예: bsg-edu-dev-eks-sg-bastion
  result = "${local.prefix}-${lookup(local.resource_abbr, var.resource_type, "res")}-${var.name}"

  # 5. MSP 표준 공통 태그 세트
  common_tags = {
    "msp:customer"    = local.cst
    "msp:project"     = local.prj
    "msp:environment" = local.env
    "msp:managed-by"  = "terraform"
    "msp:app-name"    = local.app
  }
}