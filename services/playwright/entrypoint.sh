#!/bin/bash
set -e

# Start virtual framebuffer
Xvfb :99 -screen 0 1280x720x24 -ac &
sleep 1

# Start VNC server (no password, listen on 5900)
x11vnc -display :99 -forever -nopw -listen 0.0.0.0 -rfbport 5900 &

# Start noVNC web client on port 3001
websockify --web /usr/share/novnc 3001 localhost:5900 &

echo "VNC ready: vnc://localhost:5900 | Web: http://localhost:3001/vnc.html"

# Start Playwright MCP with SSE on port 8080
# --port enables SSE transport (no --transport flag needed)
# No --headless: uses real DISPLAY so VNC can see the browser
exec npx @playwright/mcp --port 8080 --host 0.0.0.0 --allowed-hosts '*' --no-sandbox --viewport-size 1280x720
