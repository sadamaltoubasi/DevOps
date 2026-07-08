variable "Region" {
  default = "us-east-1"

}

variable "VpcCIDR" {
  default = "10.0.0.0/16"

}

variable "Zone1" {
  default = "us-east-1a"

}

variable "Zone2" {
  default = "us-east-1b"
}

variable "Zone3" {
  default = "us-east-1c"
}

variable "PrivateSubnet1" {
  default = "10.0.1.0/24"

}

variable "PrivateSubnet2" {
  default = "10.0.2.0/24"

}

variable "PrivateSubnet3" {
  default = "10.0.3.0/24"

}

variable "PublicSubnet1" {
  default = "10.0.101.0/24"
}

variable "PublicSubnet2" {
  default = "10.0.102.0/24"
}

variable "PublicSubnet3" {
  default = "10.0.103.0/24"
}

variable "dbuser" {
  default = "admin"

}

variable "dbpass" {
  default = "admin123"

}

variable "dbname" {
  default = "accounts"

}