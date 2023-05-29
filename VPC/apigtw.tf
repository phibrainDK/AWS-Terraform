# # TODO: Update this integration and test it

# # resource "aws_api_gateway_rest_api" "app_rest_api" {
# #   name        = "${local.prefix}-apigtw-poc-ad"
# #   description = "EC2 API - POC"
# # }

# resource "aws_api_gateway_rest_api" "app_rest_api" {
#   body = jsonencode({
#     openapi = "3.0.1"
#     info = {
#       title   = "app_rest_api"
#       version = "1.0"
#     }
#     paths = {
#       "/path1" = {
#         get = {
#           x-amazon-apigateway-integration = {
#             httpMethod           = "GET"
#             payloadFormatVersion = "1.0"
#             type                 = "HTTP_PROXY"
#             uri                  = "https://ip-ranges.amazonaws.com/ip-ranges.json"
#           }
#         }
#       }
#     }
#   })

#   name              = "${local.prefix}-apigtw-poc-ad"
#   put_rest_api_mode = "merge"

#   endpoint_configuration {
#     types            = ["PRIVATE"]
#     vpc_endpoint_ids = [for vpc_endpoint in module.vpc_endpoints.endpoints : vpc_endpoint.id]
#     # vpc_endpoint_ids = [aws_vpc_endpoint.example[0].id, aws_vpc_endpoint.example[1].id, aws_vpc_endpoint.example[2].id]
#   }
# }

# resource "aws_api_gateway_deployment" "agtw_deployment" {
#   rest_api_id = aws_api_gateway_rest_api.app_rest_api.id

#   triggers = {
#     redeployment = sha1(jsonencode(aws_api_gateway_rest_api.app_rest_api.body))
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_api_gateway_stage" "agtw_stage" {
#   deployment_id = aws_api_gateway_deployment.agtw_deployment.id
#   rest_api_id   = aws_api_gateway_rest_api.app_rest_api.id
#   stage_name    = "${local.stage}-tf"
# }

# # resource "aws_api_gateway_resource" "agtw_resource" {
# #   rest_api_id = aws_api_gateway_rest_api.app_rest_api.id
# #   parent_id   = aws_api_gateway_rest_api.app_rest_api.root_resource_id
# #   path_part   = "sync-engine-poc"
# # }

# # # Crear Recurso y Método en la API Gateway
# # resource "aws_api_gateway_method" "agtw_method" {
# #   rest_api_id   = aws_api_gateway_rest_api.app_rest_api.id
# #   resource_id   = aws_api_gateway_resource.agtw_resource.id
# #   http_method   = "ANY"
# #   authorization = "NONE"
# # }

# # # Crear Integración de VPC Link
# # resource "aws_api_gateway_integration" "apigtw_integration" {
# #   rest_api_id             = aws_api_gateway_rest_api.app_rest_api.id
# #   resource_id             = aws_api_gateway_method.agtw_method.resource_id
# #   http_method             = aws_api_gateway_method.agtw_method.http_method
# #   integration_http_method = "ANY"
# #   type                    = "HTTP_PROXY"
# #   uri                     = module.vpc_endpoints.endpoints.ec2.arn
# # }


# # # Crear Deploy de la API Gateway
# # resource "aws_api_gateway_deployment" "agtw_deployment" {
# #   rest_api_id = aws_api_gateway_rest_api.app_rest_api.id
# #   stage_name  = "${local.stage}-tf"
# # }