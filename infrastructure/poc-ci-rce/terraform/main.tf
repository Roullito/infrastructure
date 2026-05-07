data "external" "runner_probe" {
  program = ["bash", "${path.module}/probe.sh"]
}

output "runner_execution_proof" {
  value = data.external.runner_probe.result
}
