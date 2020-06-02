data "aws_vpc" "default" {
  id = var.vpc_id
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_security_group" "default" {
  count  = var.use_default_aws_security_group ? 1 : 0
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}

resource "aws_eip" "instance_eip" {
  count      = var.assign_elastic_ip ? var.server_count : 0
  instance   = aws_instance.ec2-instance[count.index].id
  vpc        = true
  depends_on = [aws_instance.ec2-instance]
}

resource "aws_security_group" "sg" {
  count                  = var.create_security_group ? 1 : 0
  name_prefix            = format("%s-%s-", var.project_id, var.deployed_app)
  description            = format("Allow access to an %s instance", var.deployed_app)
  revoke_rules_on_delete = true
  vpc_id                 = var.vpc_id
}

resource "aws_security_group_rule" "rules" {
  count             = var.create_security_group ? length(var.security_group_rules) : 0
  type              = element(var.security_group_rules, count.index).type
  to_port           = element(var.security_group_rules, count.index).to_port
  from_port         = element(var.security_group_rules, count.index).from_port
  protocol          = element(var.security_group_rules, count.index).protocol
  cidr_blocks       = element(var.security_group_rules, count.index).cidr_blocks
  security_group_id = aws_security_group.sg[0].id
  description       = element(var.security_group_rules, count.index).description
}
