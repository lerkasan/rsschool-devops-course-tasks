locals {
  oidc_github_actions = {
    audience_client_id = "sts.amazonaws.com"
    domain_name        = "token.actions.githubusercontent.com"
    provider_url       = "https://token.actions.githubusercontent.com"
  }
}