module "partitioner" {
  source = "github.com/nix-community/nixos-anywhere//terraform/nix-build?ref=1.1.0"
  attribute = ".#nixosConfigurations.${var.config_name}.config.system.build.diskoScriptNoDeps"
}

module "system" {
  source = "github.com/nix-community/nixos-anywhere//terraform/nix-build?ref=1.1.0"
  attribute = ".#nixosConfigurations.${var.config_name}.config.system.build.toplevel"
}

module "install" {
  source = "github.com/nix-community/nixos-anywhere//terraform/install?ref=1.1.0"
  target_host = var.install_user_profile.ssh_host
  target_user = var.install_user_profile.username
  extra_files_script = var.install_extra_files_script
  nixos_partitioner = module.partitioner.result.out
  nixos_system = module.system.result.out
  ssh_private_key = var.install_user_ssh_private_key
}

module "rebuild" {
  source = "github.com/nix-community/nixos-anywhere//terraform/nixos-rebuild?ref=1.1.0"
  target_host = var.user_profile.ssh_host
  target_user = var.user_profile.username
  nixos_system = module.system.result.out
  depends_on = [module.install]
  ssh_private_key = var.user_ssh_private_key
}