
import models.io.upbound.aws.ec2.v1beta1 as ec2v1beta1
import models.io.upbound.aws.ec2.v1beta2 as ec2v1beta2
import models.io.upbound.aws.v1alpha1 as awsv1alpha1
import models.io.upbound.aws.v1beta1 as awsv1beta1
import models.io.upbound.customer.v1alpha1 as customerv1alpha1
import models.k8s.apimachinery.pkg.apis.meta.v1 as metav1

oxr = option("params").oxr # observed composite resource
_ocds = option("params").ocds # observed composed resources
_dxr = option("params").dxr # desired composite resource
dcds = option("params").dcds # desired composed resources

_metadata = lambda name: str -> any {
    { annotations = { "krm.kcl.dev/composition-resource-name" = name }}
}

_region = oxr.spec?.parameters?.region or "us-east-1"
_base_name = oxr.metadata?.name

# Instance type mapping
instance_type_map = {
    "tiny": "t2.micro",
    "jumbo": "t2.small",
}
_instance_type = "tiny"
if oxr.spec?.parameters?.instanceType in instance_type_map:
    _instance_type = instance_type_map[oxr.spec.parameters.instanceType]

# AMI mapping
ami_map = {
    "amazon": "ami-0fc82f4dabc05670b",
    "ubuntu": "ami-0cb91c7de36eed2cb",
}
_ami = "amazon"
if oxr.spec?.parameters?.ami in ami_map:
    _ami = ami_map[oxr.spec.parameters.ami]


_items = [
ec2v1beta1.VPC{
    apiVersion: "ec2.aws.upbound.io/v1beta1"
    kind: "VPC"
    metadata: {
        name: "vpc-demo"
    }
    spec: {
        forProvider: {
            cidrBlock: "10.0.0.0/16"
            enableDnsHostnames: True
            enableDnsSupport: True
            region: _region
        }
    }
}
ec2v1beta1.SecurityGroup {
    apiVersion: "ec2.aws.upbound.io/v1beta1"
    kind: "SecurityGroup"
    metadata: {
        name: "sg-demo"
        labels: {
            "testing.upbound.io/example-name": "sg-demo"
        }
    }
    spec: {
        forProvider: {
            description: "security group"
            region:_region
            tags: {
                Name: "sg-demo"
            }
            vpcIdSelector: {
                matchControllerRef: True
            }
        }
    }
}
ec2v1beta1.SecurityGroupRule{
    apiVersion: "ec2.aws.upbound.io/v1beta1"
    kind: "SecurityGroupRule"
    metadata: {
        name: "sg-group-demo"
    }
    spec: {
        forProvider: {
            fromPort:22
            protocol:"tcp"
            region:_region
            securityGroupIdSelector: {
                matchControllerRef: True
            }
            self: True
            toPort:22
            type: "ingress"
        }
    }
}
ec2v1beta1.Subnet{
    apiVersion: "ec2.aws.upbound.io/v1beta1"
    kind: "Subnet"
    metadata: {
        name: "sub-demo"
    }
    spec: {
        forProvider: {
            cidrBlock: "10.0.5.0/24"
            region:_region
            vpcIdSelector: {
                matchControllerRef: True
            }
            tags: {
                Name: "sub-demo"
            }
        }
    }
}
ec2v1beta1.Instance{
    apiVersion: "ec2.aws.upbound.io/v1beta1"
    kind: "Instance"
    metadata: {
        name: "vm-demo"
    }
    spec: {
        forProvider: {
            ami: _ami
            instanceType: _instance_type
            region: _region
            tags: {
                Name: "vm-demo"
            }
            vpcSecurityGroupIdSelector: {
                matchControllerRef: True
            }
            subnetIdSelector: {
                matchControllerRef: True
            }
        }
    }
}
]
items = _items

