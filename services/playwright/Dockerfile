FROM node:22-slim

# Install Chromium, VNC, and display dependencies
RUN apt-get update && apt-get install -y \
    chromium \
    fonts-liberation \
    fonts-noto-cjk \
    fonts-noto-color-emoji \
    libgbm1 \
    libnss3 \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libasound2 \
    libpangocairo-1.0-0 \
    libcups2 \
    libdrm2 \
    libxshmfence1 \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Playwright MCP
RUN npm install -g @playwright/mcp

ENV DISPLAY=:99
ENV CHROME_PATH=/usr/bin/chromium
ENV PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH=/usr/bin/chromium

EXPOSE 8080 5900 3001

# Start Xvfb + VNC + noVNC + Playwright MCP
# - Xvfb: virtual display on :99 (1280x720)
# - x11vnc: VNC server on port 5900 (no password)
# - websockify+noVNC: web VNC on port 3001
# - Playwright MCP: SSE on port 8080
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
