#!/bin/bash

echo "Installing Node Exporter..."

curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
tar -xvf node_exporter-1.7.0.linux-amd64.tar.gz
sudo cp -p ./node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin
sudo chown root:root /usr/local/bin/node_exporter

cat > /etc/systemd/system/node_exporter.service <<EOL
[Unit]
Description=NodeExporter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

echo "Installing Grafana Agent..."

sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

sudo apt-get update
sudo apt-get install grafana-agent-flow

cat > /etc/grafana-agent-flow.river <<EOL
logging {
  level = "warn"
}

prometheus.remote_write "default" {
  endpoint {
    url = "https://heimdall-api.ietf.org/api/v1/push"

    headers = {
      "CF-Access-Client-Id" = "VALUE-CF-CLIENT-ID-HERE",
      "CF-Access-Client-Secret" = "VALUE-CF-CLIENT-SECRET-HERE",
    }

    write_relabel_config {
      source_labels = ["instance"]
      target_label = "instance"
      replacement = "yangcatalog"
    }
  }
  external_labels = {
    cluster     = "yangcatalog",
    instance    = "yangcatalog",
    environment = "prod",
  }
}

prometheus.scrape "default" {
  targets = [
    {
      // Self-collect metrics
      job         = "agent",
      __address__ = "127.0.0.1:12345",
    },
    {
      job         = "node_exporter",
      __address__ = "127.0.0.1:9100",
    },
    {
      job         = "docker",
      __address__ = "127.0.0.1:9324",
    },
  ]
  forward_to = [prometheus.remote_write.default.receiver]
}
EOL

sudo systemctl start grafana-agent-flow
sudo systemctl enable grafana-agent-flow.service
