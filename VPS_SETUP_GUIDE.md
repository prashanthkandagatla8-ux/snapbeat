# VPS SSL Setup Guide - api.snapbeat.app

## 🎯 Goal
Configure HTTPS on your VPS at `34.93.112.240` so the Flutter app can connect to `https://api.snapbeat.app`

---

## ⏱️ Estimated Time: 15 minutes

---

## 📋 Prerequisites

✅ Domain: `snapbeat.app` (owned in Namecheap)  
✅ DNS: A record `api.snapbeat.app` → `34.93.112.240` (already configured)  
✅ VPS: `34.93.112.240` (running, accessible)  
✅ Backend: Your Flask/FastAPI app running on port 5000 (or specify your port)

---

## 🚀 STEP-BY-STEP INSTRUCTIONS

### **Step 1: Connect to Your VPS**

```bash
# Replace with your actual SSH credentials
ssh root@34.93.112.240

# Or if you use a different user:
ssh your-username@34.93.112.240
```

---

### **Step 2: Update System & Install Nginx + Certbot**

```bash
# Update package list
sudo apt update && sudo apt upgrade -y

# Install Nginx
sudo apt install nginx -y

# Install Certbot (for FREE SSL certificates)
sudo apt install certbot python3-certbot-nginx -y

# Check Nginx is running
sudo systemctl status nginx
# Should show "active (running)"
```

---

### **Step 3: Configure Nginx as Reverse Proxy**

```bash
# Create Nginx configuration file
sudo nano /etc/nginx/sites-available/snapbeat-api
```

**Paste this configuration:**

```nginx
# SnapBeat API - Reverse Proxy Configuration
server {
    listen 80;
    listen [::]:80;
    server_name api.snapbeat.app;

    # Increase body size for photo/music uploads (100MB max)
    client_max_body_size 100M;

    # Increase timeouts for video rendering
    proxy_connect_timeout 300s;
    proxy_send_timeout 300s;
    proxy_read_timeout 300s;

    location / {
        # Proxy to your backend app
        proxy_pass http://127.0.0.1:5000;  # ⚠️ CHANGE 5000 to your actual port
        
        # WebSocket support (if needed)
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        
        # Forward headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Disable buffering for large files
        proxy_buffering off;
        proxy_cache_bypass $http_upgrade;
    }

    # Health check endpoint (optional)
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
```

**⚠️ IMPORTANT:** Change `5000` to your actual backend port if different!

**Save the file:**
- Press `Ctrl + X`
- Press `Y` (yes to save)
- Press `Enter`

---

### **Step 4: Enable the Site**

```bash
# Create symbolic link to enable the site
sudo ln -s /etc/nginx/sites-available/snapbeat-api /etc/nginx/sites-enabled/

# Remove default site (optional but recommended)
sudo rm /etc/nginx/sites-enabled/default

# Test Nginx configuration for syntax errors
sudo nginx -t

# Should output:
# nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
# nginx: configuration file /etc/nginx/nginx.conf test is successful
```

**If you see errors:**
- Check the configuration file for typos
- Make sure server_name matches: `api.snapbeat.app`
- Verify backend port is correct

---

### **Step 5: Restart Nginx**

```bash
sudo systemctl restart nginx

# Check status
sudo systemctl status nginx

# Should show "active (running)" in green
```

---

### **Step 6: Open Firewall Ports**

```bash
# Allow HTTP (port 80) for initial certificate request
sudo ufw allow 80/tcp

# Allow HTTPS (port 443)
sudo ufw allow 443/tcp

# Check firewall status
sudo ufw status

# If firewall is inactive, enable it:
# sudo ufw enable
```

---

### **Step 7: Get FREE SSL Certificate from Let's Encrypt**

```bash
# Run Certbot to automatically configure SSL
sudo certbot --nginx -d api.snapbeat.app
```

**Certbot will ask you several questions:**

1. **Enter email address:**
   ```
   your-email@gmail.com
   ```
   (Used for renewal notifications)

2. **Agree to Terms of Service:**
   ```
   (A)gree
   ```
   Type `A` and press Enter

3. **Share email with EFF:**
   ```
   (Y)es or (N)o
   ```
   Type `N` (optional) and press Enter

4. **Redirect HTTP to HTTPS:**
   ```
   Please choose whether or not to redirect HTTP traffic to HTTPS:
   1: No redirect
   2: Redirect - Make all requests redirect to secure HTTPS access
   
   Select the appropriate number [1-2] then [enter]:
   ```
   Type `2` (RECOMMENDED) and press Enter

**Expected Output:**
```
Congratulations! You have successfully enabled https://api.snapbeat.app

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/api.snapbeat.app/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/api.snapbeat.app/privkey.pem
   Your certificate will expire on YYYY-MM-DD. To obtain a new or
   tweaked version of this certificate in the future, simply run
   certbot again with the "certonly" option.
```

---

### **Step 8: Test Your HTTPS API**

```bash
# Test from VPS
curl https://api.snapbeat.app/

# Should return your API response (not an SSL error)

# Test health endpoint
curl https://api.snapbeat.app/health
# Should return: healthy

# Exit VPS
exit
```

---

### **Step 9: Test from Your Computer**

```bash
# On your local machine (not VPS)
curl https://api.snapbeat.app/

# Or in browser, visit:
# https://api.snapbeat.app
```

**Expected:** Your API response (or 404 if no root endpoint, but SSL should work)

---

## 🔄 AUTO-RENEWAL (Already Configured!)

Let's Encrypt certificates expire after **90 days**, but Certbot automatically sets up renewal.

**Test auto-renewal:**
```bash
sudo certbot renew --dry-run

# Should show: Congratulations, all simulated renewals succeeded
```

**Renewal happens automatically via cron job:**
```bash
# Check renewal timer
sudo systemctl status certbot.timer

# Should show "active (waiting)"
```

---

## ✅ VERIFICATION CHECKLIST

Run these checks to confirm everything works:

```bash
# 1. DNS resolves correctly
ping api.snapbeat.app
# Should show 34.93.112.240

# 2. Port 80 responds
curl -I http://api.snapbeat.app
# Should redirect to HTTPS (301/302)

# 3. Port 443 responds with valid SSL
curl -I https://api.snapbeat.app
# Should return 200 OK with your headers

# 4. SSL certificate is valid
openssl s_client -connect api.snapbeat.app:443 -servername api.snapbeat.app < /dev/null
# Should show certificate details from Let's Encrypt

# 5. Backend is reachable
curl https://api.snapbeat.app/api/render/status/test
# Should return your API response
```

---

## 🆘 TROUBLESHOOTING

### **Problem: "Connection refused" or "Unable to connect"**

**Solution:**
```bash
# Check if your backend app is running
sudo netstat -tulpn | grep 5000  # or your port

# If not running, start your backend
# python app.py  # or whatever your start command is

# Check Nginx is running
sudo systemctl status nginx

# Restart Nginx if needed
sudo systemctl restart nginx
```

---

### **Problem: "DNS resolution failed" or "Name or service not known"**

**Solution:**
```bash
# Check DNS propagation
nslookup api.snapbeat.app

# If it doesn't resolve:
# 1. Wait 5-15 minutes (DNS takes time)
# 2. Check Namecheap DNS settings
# 3. Try Google's DNS: dig @8.8.8.8 api.snapbeat.app
```

---

### **Problem: Certbot fails with "Connection timed out" or "Port 80 blocked"**

**Solution:**
```bash
# Make sure port 80 is open
sudo ufw allow 80

# Check if another service is using port 80
sudo netstat -tulpn | grep :80

# If Apache is running, stop it
sudo systemctl stop apache2

# Try Certbot again
sudo certbot --nginx -d api.snapbeat.app
```

---

### **Problem: "Certificate verify failed" or SSL errors**

**Solution:**
```bash
# Check certificate expiry
sudo certbot certificates

# Force renewal if needed
sudo certbot renew --force-renewal

# Restart Nginx
sudo systemctl restart nginx
```

---

### **Problem: Backend returns "502 Bad Gateway"**

**Solution:**
```bash
# Your backend app is not running or crashed

# Check if backend is running
ps aux | grep python  # or your app process

# Check backend logs
tail -f /path/to/your/app/logs/error.log

# Restart your backend
# cd /path/to/your/app
# python app.py  # or your start command
```

---

## 📝 NGINX CONFIGURATION REFERENCE

**Common Backend Ports:**
- Flask default: `5000`
- FastAPI default: `8000`
- Node.js/Express: `3000`
- Custom: Check your app's config

**To change the port:**
```bash
sudo nano /etc/nginx/sites-available/snapbeat-api

# Change this line:
proxy_pass http://127.0.0.1:5000;  # Change 5000 to your port

# Save and restart
sudo nginx -t
sudo systemctl restart nginx
```

---

## 🎓 USEFUL COMMANDS

```bash
# View Nginx access logs (live)
sudo tail -f /var/log/nginx/access.log

# View Nginx error logs (live)
sudo tail -f /var/log/nginx/error.log

# Test Nginx config
sudo nginx -t

# Reload Nginx (without downtime)
sudo systemctl reload nginx

# Restart Nginx (with brief downtime)
sudo systemctl restart nginx

# Check SSL certificate expiry
sudo certbot certificates

# Force certificate renewal
sudo certbot renew --force-renewal

# View Nginx configuration
cat /etc/nginx/sites-available/snapbeat-api
```

---

## ✅ NEXT STEPS AFTER SSL SETUP

1. **Test API connection:**
   ```bash
   curl https://api.snapbeat.app/api/render/status/test
   ```

2. **Build Flutter app:**
   ```bash
   cd /path/to/snapbeat_flutter
   flutter clean
   flutter pub get
   flutter build ios --release
   ```

3. **Test on device:**
   - Install on iPhone
   - Try rendering a video
   - Check logs for SSL errors

4. **Submit to App Store:**
   - Upload build to App Store Connect
   - Fill review notes (see APP_STORE_FIXES_SUMMARY.md)
   - Submit for review

---

## 🎉 SUCCESS!

If all tests pass, your API is now secured with HTTPS and ready for App Store submission!

**Your API endpoint:**
```
https://api.snapbeat.app
```

**Certificate info:**
- Provider: Let's Encrypt (FREE)
- Auto-renewal: Every 60 days
- Expires: Check with `sudo certbot certificates`

---

**Need help?** Check the troubleshooting section or contact your hosting provider.
