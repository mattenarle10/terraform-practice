#!/bin/bash

# Update system packages
sudo apt-get update
sudo apt-get upgrade -y

# Install required packages
sudo apt-get install -y nginx python3 python3-pip python3-venv

# Configure Nginx
sudo tee /etc/nginx/sites-available/webapp <<EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Enable the site
sudo ln -sf /etc/nginx/sites-available/webapp /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Create a simple Python Flask application
mkdir -p /home/ubuntu/webapp
cat > /home/ubuntu/webapp/app.py <<EOF
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return '<h1>Hello from Terraform-deployed Python Web App!</h1>'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
EOF

# Create requirements.txt
cat > /home/ubuntu/webapp/requirements.txt <<EOF
Flask==2.0.1
gunicorn==20.1.0
EOF

# Setup Python virtual environment
cd /home/ubuntu/webapp
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Create systemd service for the Flask application
sudo tee /etc/systemd/system/webapp.service <<EOF
[Unit]
Description=Python Web Application
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/webapp
ExecStart=/home/ubuntu/webapp/venv/bin/gunicorn -w 4 -b 0.0.0.0:8000 app:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and start services
sudo systemctl daemon-reload
sudo systemctl enable webapp.service
sudo systemctl start webapp.service
sudo systemctl restart nginx

echo "Web application setup complete!"
