#!/bin/bash

# Startup script for Oracle Linux instances
echo "Oracle Linux instance started successfully at $(date)" > /var/log/startup.log

# Update system packages
yum update -y

# Install and configure Apache HTTP Server
yum install -y httpd

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Create a simple web page with instance information
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Oracle Linux on GCP</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 50px; }
        h1 { color: #ea4335; }
        .info { background: #f1f1f1; padding: 20px; border-radius: 5px; }
    </style>
</head>
<body>
    <h1>Oracle Linux on GCP - MIG Instance</h1>
    <div class="info">
        <p><strong>Hostname:</strong> $(hostname)</p>
        <p><strong>Instance ID:</strong> $(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/id" -H "Metadata-Flavor: Google")</p>
        <p><strong>Zone:</strong> $(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google" | cut -d/ -f4)</p>
        <p><strong>Started:</strong> $(date)</p>
    </div>
</body>
</html>
EOF

# Set proper permissions
chmod 644 /var/www/html/index.html

# Log completion
echo "Startup script completed at $(date)" >> /var/log/startup.log
