* Have a global `machine.json` file which is valid for all machines
* Unify the both `jq` commands in `deploy.sh`
* Use `modules/boot/XXX` where `XXX` is the target platform identifier
* Add configuration option to enable `--use-substitutes` in `nix-copy-closure`