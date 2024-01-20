# Packer Build

## Usage

- Run the **Packer Build** Github Action workflow to generate a snapshot.
- Create a VM / Droplet based on the generated snapshot.

## Post Image Build Steps

### Initial YangCatalog Init

1. From `/app`, run `docker-compose up -d`

### Grafana Agent

1. Edit the file `/etc/grafana-agent-flow.river` config and replace the `VALUE-CF-CLIENT-ID-HERE` and `VALUE-CF-CLIENT-SECRET-HERE` placeholders.
1. Then restart the grafana-agent service (`systemctl restart grafana-agent-flow.service`).
