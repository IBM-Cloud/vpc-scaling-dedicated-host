# Terraform scripts for VPC autoscaling, dedicated host solution tutorial 

Companion Terraform scripts to a [solution tutorial](https://cloud.ibm.com/docs/solution-tutorials?topic=solution-tutorials-vpc-scaling-dedicated-compute) that walks you through the steps of setting up isolated workloads in a shared (multi-tenant) environment and a dedicated (single-tenant) environment. Provision an IBM Cloud™ Virtual Private Cloud (VPC) with subnets spanning multiple availability zones (AZs) and virtual server instances (VSIs) that can scale according to your requirements to ensure the high availability of your application. Furthermore, configure load balancers to provide high availability between zones within one region. Configure Virtual Private Endpoints (VPE) for your VPC providing private routes to services on the IBM Cloud.

Isolate workloads by provisioning a dedicated host, attaching an encrypted data volume to the dedicated VSI, and resizing VSIs after the fact.

You will provision all of these services and VPC resources using IBM Cloud Schematics, which provides Terraform-as-a-Service capabilities. The Terraform template defines the IBM Cloud resources to be created, updated, or deleted.

![architecture diagram](images/architecture_diagram.svg)

### Deploy using IBM Cloud Schematics UI

Follow the step-by-step instructions in the [solution tutorial](https://cloud.ibm.com/docs/solution-tutorials?topic=solution-tutorials-vpc-scaling-dedicated-compute) to deploy the resources using IBM Cloud Schematics UI


### Terraform modules structure

The Terraform scripts are divided into modules for ease of use

|  Module  |  Usage |
|---|---|
|[create_services](./modules/create_services) | Provisions the required Cloud services for the tutorial. Optionally, you can provision IBM Cloud logging and/or monitoring services  |
| [create_vpc](./modules/create_vpc)  | Provisions the VPC-SCALE and its resources. This module includes other sub-modules for provisioning [load balancers](./modules/create_vpc/lb), [subnets](./modules/create_vpc/subnets), [security groups](./modules/create_vpc/security_groups), and [auto-scale instance templates and groups](./modules/create_vpc/autoscale). |
| [create_dedicated](./modules/create_dedicated)  | Provisions VPC-DEDICATED with a dedicated host group, dedicated host, dedicated instance with an encrypted volume and supports instance resize.  
| [create_vpe](./modules/create_vpe) | Provisions the Virtual Private Endpoint(VPE) for private connectivity between VPC-SCALE <--> Cloud Services <--> VPC-DEDICATED |
