data "template_file" "etc_hosts" {
  template = <<EOF
${join("\n", formatlist("%v %v.%v %v",
  var.node_ips,
  var.node_hostnames,
  var.domain,
  var.node_hostnames))}
EOF
}


resource "null_resource" "sync_etc_hosts" {
  count = "${length(var.node_ips)}"

  triggers = {
      hosts = "${data.template_file.etc_hosts.rendered}"
  }

  connection {
    type = "ssh"
    host = "${element(var.node_ips, count.index)}"
    user = "${var.ssh_user}"
    private_key = "${file(var.ssh_private_key)}"
    bastion_host = "${var.bastion_ip_address}"
    bastion_host_key = "${file(var.ssh_private_key)}"
  }

  provisioner "file" {
    content = "${data.template_file.etc_hosts.rendered}"
    destination = "/tmp/etc_hosts"
  }

  provisioner "remote-exec" {
    inline = [
      "set -x",
      "if [ ! -f /etc/hosts.orig ]; then sudo cp /etc/hosts /etc/hosts.orig; fi",
      "sudo sed -i '/${element(var.node_hostnames, count.index)}/d' /etc/hosts",
      "for i in `cat /tmp/etc_hosts | awk '{print $$1;}'`; do sudo sed -i '/^'$$i' /d' /etc/hosts; done",
      "cat /tmp/etc_hosts | sudo tee -a /etc/hosts"
    ]
  }
}
