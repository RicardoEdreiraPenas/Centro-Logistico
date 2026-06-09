#!/bin/bash
set -e
exec > /var/log/user-data.log 2>&1

dnf install -y python3.11 git

git clone https://github.com/RicardoEdreiraPenas/Centro-Logistico.git /opt/logistics
chown -R ec2-user:ec2-user /opt/logistics

cd /opt/logistics/aws_setup/excercise_logistics
python3.11 -m venv .venv
.venv/bin/pip install --upgrade pip
.venv/bin/pip install -r requirements.txt

cat > /etc/systemd/system/el-logistics.service << 'SVCEOF'
[Unit]
Description=Logistics EL pipeline
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/logistics/aws_setup/excercise_logistics
Environment="RDS_HOST=database-1.ct6susew4fc5.eu-west-3.rds.amazonaws.com"
Environment="RDS_PORT=5432"
Environment="RDS_DB=postgres"
Environment="RDS_USER=postgres"
Environment="RDS_PASSWORD=edem2526"
Environment="AWS_REGION=eu-north-1"
ExecStart=/opt/logistics/aws_setup/excercise_logistics/.venv/bin/python -m analytical_layer.el_logistics.main
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
SVCEOF

systemctl daemon-reload
systemctl enable el-logistics
systemctl start el-logistics
