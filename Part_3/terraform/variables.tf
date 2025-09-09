variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "ap-south-1"
}
variable "allowed_cidr" {
  description = "CIDR block allowed to access the instance (SSH & app ports)."
  type        = string
  default     = "0.0.0.0/0"
}

# Part 3 specific variables
variable "vpc_cidr" {
  description = "CIDR for Part 3 VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnets" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default     = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "backend_container_port" {
  type        = number
  default     = 5000
  description = "Container port for backend"
}

variable "frontend_container_port" {
  type        = number
  default     = 3000
  description = "Container port for frontend"
}

variable "backend_cpu" {
  type        = number
  default     = 256
  description = "CPU units for backend task"
}
variable "backend_memory" {
  type        = number
  default     = 512
  description = "Memory (MiB) for backend task"
}
variable "frontend_cpu" {
  type        = number
  default     = 256
  description = "CPU units for frontend task"
}
variable "frontend_memory" {
  type        = number
  default     = 512
  description = "Memory (MiB) for frontend task"
}
variable "backend_desired_count" {
  type        = number
  default     = 1
  description = "Desired task count for backend service"
}
variable "frontend_desired_count" {
  type        = number
  default     = 1
  description = "Desired task count for frontend service"
}