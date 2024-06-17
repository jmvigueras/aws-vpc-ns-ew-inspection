locals {
  #------------------------------------------------------------------------------------------------
  # locals used to create resources (NOT UPDATE)
  #------------------------------------------------------------------------------------------------
  # list of public and private subnets names
  subnets_public  = compact(distinct(concat(var.public_subnet_names)))
  subnets_private = compact(distinct(concat(var.private_subnet_names)))

  # Concat all subnet names (remove duplicated)
  subnets_list = distinct(concat(local.subnets_public, local.subnets_private))

  # Calculate total number of subnet to create
  subnets_count = length(var.azs) * length(local.subnets_list)

  # Create list of subnets names peer AZ
  subnets_name = flatten(
    [for subnet in local.subnets_list :
      [for i, az in var.azs : "${subnet}-az${i + 1}"]
    ]
  )
  # Create list of public subnets peer AZ
  subnets_public_name = flatten(
    [for subnet in local.subnets_public :
      [for i, az in var.azs : "${subnet}-az${i + 1}"]
    ]
  )
  # Create list of private subnets peer AZ
  subnets_private_name = flatten(
    [for subnet in local.subnets_private :
      [for i, az in var.azs : "${subnet}-az${i + 1}"]
    ]
  )
  # Create list of AZs for each subnet name
  subnets_az = flatten(
    [for i in local.subnets_list :
      [for az in var.azs : az]
    ]
  )
  # Create subnet map of maps [{subnet_name, cidr, az}]
  subnets_map = merge(
    { for i, subnet in local.subnets_name :
      subnet => tomap(
        { cidr = cidrsubnet(var.cidr, ceil(log(local.subnets_count, 2)), i)
          az   = local.subnets_az[i]
        }
      )
    }
  )
  # Create map of maps with RT ids
  rt_resource = merge(aws_route_table.rt_private, aws_route_table.rt_public)

  # ------------------------------------------------------------------------------------
  # OutPuts
  # ------------------------------------------------------------------------------------
  # Create map of maps with subnets id
  o_subnets = { for i, az in var.azs :
    "az${i + 1}" => { for subnet in local.subnets_list :
      subnet => {
        id   = lookup(aws_subnet.subnets, "${subnet}-az${i + 1}", { id = "" }).id
        cidr = lookup(aws_subnet.subnets, "${subnet}-az${i + 1}", { cidr_block = "" }).cidr_block
        rt   = lookup(local.rt_resource, "${subnet}-az${i + 1}", { id = "" }).id
      }
    }
  }
  # Create subnet list of maps [{subnet_name, id, cidr, az, rt}]
  o_subnet_list = [for i, subnet in local.subnets_name :
    { name  = subnet
      id    = lookup(aws_subnet.subnets, subnet, { id = "" }).id
      az    = "az${index(var.azs, local.subnets_az[i]) + 1}"
      az_id = local.subnets_az[i]
      cidr  = cidrsubnet(var.cidr, ceil(log(local.subnets_count, 2)), i)
      rt    = lookup(local.rt_resource, subnet, { id = "" }).id
    }
  ]
  # Create map of maps with subnets id
  o_subnet_ids = { for i, az in var.azs :
    "az${i + 1}" => { for subnet in local.subnets_list :
      subnet => lookup(aws_subnet.subnets, "${subnet}-az${i + 1}", { id = "" }).id
    }
  }
  # Create map of maps with subnets arns
  o_subnet_arns = { for i, az in var.azs :
    "az${i + 1}" => { for subnet in local.subnets_list :
      subnet => lookup(aws_subnet.subnets, "${subnet}-az${i + 1}", { id = "" }).arn
    }
  }
  # Create map of maps with subnets cidrs
  o_subnet_cidrs = { for i, az in var.azs :
    "az${i + 1}" => { for subnet in local.subnets_list :
      subnet => lookup(aws_subnet.subnets, "${subnet}-az${i + 1}", { cidr_block = "" }).cidr_block
    }
  }
  # Create map of public and private subnets route tables
  o_rt_public_ids = { for subnet in local.subnets_public_name :
    subnet => aws_route_table.rt_public[subnet].id
  }
  o_rt_private_ids = { for subnet in local.subnets_private_name :
    subnet => aws_route_table.rt_private[subnet].id
  }
  o_rt_ids = { for i, az in var.azs :
    "az${i + 1}" => { for subnet in local.subnets_list :
      subnet => lookup(local.rt_resource, "${subnet}-az${i + 1}", { id = "" }).id
    }
  }
  # Create map of maps with public subnets detail (IDs, CIDRs)
  o_subnet_public_ids = { for i, az in var.azs :
    "az${i + 1}" => { for subnet in local.subnets_public :
      subnet => lookup(aws_subnet.subnets, "${subnet}-az${i + 1}", { id = "" }).id
    }
  }
  o_subnet_public_cidrs = { for i, az in var.azs :
    "az${i + 1}" => { for subnet in local.subnets_public :
      subnet => lookup(aws_subnet.subnets, "${subnet}-az${i + 1}", { id = "" }).cidr_block
    }
  }
  # Create map of maps with public subnets detail (IDs, CIDRs)
  o_subnet_private_ids = { for i, az in var.azs :
    "az${i + 1}" => { for subnet in local.subnets_private :
      subnet => lookup(aws_subnet.subnets, "${subnet}-az${i + 1}", { cidr_block = "" }).id
    }
  }
  o_subnet_private_cidrs = { for i, az in var.azs :
    "az${i + 1}" => { for subnet in local.subnets_private :
      subnet => lookup(aws_subnet.subnets, "${subnet}-az${i + 1}", { cidr_block = "" }).cidr_block
    }
  }
}