<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    HttpSession s = request.getSession(false);
    if (s != null && s.getAttribute("user") != null) {
        response.sendRedirect(request.getContextPath() + "/viewMedicines");
        return;
    }
    String error  = request.getParameter("error");
    String logout = request.getParameter("logout");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RxCare — Pharmacy Login</title>
    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@300;400;500;600;700&family=JetBrains+Mono:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --bg:          #060A0D;
            --surface:     #0C1218;
            --surface2:    #111C26;
            --green:       #00E5A0;
            --green-dim:   #00B87A;
            --green-glow:  rgba(0,229,160,0.15);
            --green-glow2: rgba(0,229,160,0.06);
            --text:        #C8E6D8;
            --text-dim:    #7AA090;
            --muted:       #2E4A3A;
            --danger:      #FF4757;
            --border:      rgba(0,229,160,0.12);
            --border2:     rgba(0,229,160,0.06);
        }

        html, body { height: 100%; }

        body {
            font-family: 'Rajdhani', sans-serif;
            background: var(--bg);
            color: var(--text);
            display: flex;
            min-height: 100vh;
            overflow: hidden;
        }

        /* ── Dot grid bg ── */
        body::before {
            content: '';
            position: fixed; inset: 0;
            background-image: radial-gradient(circle, rgba(0,229,160,0.07) 1px, transparent 1px);
            background-size: 28px 28px;
            pointer-events: none; z-index: 0;
        }

        /* ══════════════════════════════
           LEFT PANEL — Branding
        ══════════════════════════════ */
        .left-panel {
            width: 45%;
            background: linear-gradient(150deg, #080E14 0%, #0A1A12 50%, #060D0A 100%);
            border-right: 1px solid var(--border);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 60px 50px;
            position: relative;
            overflow: hidden;
            z-index: 1;
        }

        /* Glowing background orb */
        .left-panel::before {
            content: '';
            position: absolute;
            width: 500px; height: 500px;
            background: radial-gradient(circle, rgba(0,229,160,0.07) 0%, transparent 65%);
            top: 50%; left: 50%;
            transform: translate(-50%, -50%);
            animation: orbPulse 5s ease-in-out infinite;
        }
        @keyframes orbPulse {
            0%,100% { transform: translate(-50%,-50%) scale(1);   opacity: 0.7; }
            50%     { transform: translate(-50%,-50%) scale(1.15); opacity: 1; }
        }

        /* Horizontal scan line */
        .scanline {
            position: absolute;
            left: 0; right: 0; height: 2px;
            background: linear-gradient(90deg, transparent, var(--green), transparent);
            opacity: 0.3;
            animation: scan 6s linear infinite;
        }
        @keyframes scan {
            0%   { top: 0%; }
            100% { top: 100%; }
        }

        /* Corner markers */
        .corner {
            position: absolute;
            width: 24px; height: 24px;
            border-color: var(--green);
            border-style: solid;
            opacity: 0.4;
        }
        .corner.tl { top: 24px; left: 24px; border-width: 2px 0 0 2px; }
        .corner.tr { top: 24px; right: 24px; border-width: 2px 2px 0 0; }
        .corner.bl { bottom: 24px; left: 24px; border-width: 0 0 2px 2px; }
        .corner.br { bottom: 24px; right: 24px; border-width: 0 2px 2px 0; }

        .brand { position: relative; z-index: 1; text-align: center; }

        /* Medical cross SVG */
        .med-cross {
            width: 80px; height: 80px;
            margin: 0 auto 28px;
            position: relative;
            filter: drop-shadow(0 0 20px rgba(0,229,160,0.5));
            animation: crossPulse 3s ease-in-out infinite;
        }
        @keyframes crossPulse {
            0%,100% { filter: drop-shadow(0 0 20px rgba(0,229,160,0.5)); }
            50%     { filter: drop-shadow(0 0 35px rgba(0,229,160,0.85)); }
        }

        .brand-name {
            font-size: 3rem;
            font-weight: 700;
            letter-spacing: 6px;
            color: #fff;
            line-height: 1;
            margin-bottom: 6px;
        }
        .brand-name span { color: var(--green); }

        .brand-tagline {
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.7rem;
            color: var(--text-dim);
            letter-spacing: 3px;
            text-transform: uppercase;
            margin-bottom: 48px;
        }

        /* Info pills */
        .info-pills { display: flex; flex-direction: column; gap: 14px; width: 100%; max-width: 260px; }
        .pill {
            display: flex; align-items: center; gap: 14px;
            background: rgba(0,229,160,0.05);
            border: 1px solid var(--border);
            padding: 12px 16px;
            animation: pillIn 0.6s ease both;
        }
        .pill:nth-child(1){animation-delay:0.8s}
        .pill:nth-child(2){animation-delay:1.0s}
        .pill:nth-child(3){animation-delay:1.2s}
        @keyframes pillIn {
            from { opacity:0; transform:translateX(-16px); }
            to   { opacity:1; transform:translateX(0); }
        }
        .pill-icon { font-size: 18px; }
        .pill-text { font-size: 0.82rem; color: var(--text-dim); letter-spacing: 0.5px; }
        .pill-text strong { color: var(--green); display: block; font-size: 0.78rem; letter-spacing: 1px; text-transform: uppercase; margin-bottom: 2px; }

        /* System status */
        .sys-status {
            position: absolute;
            bottom: 28px;
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.65rem;
            color: var(--muted);
            letter-spacing: 1.5px;
            display: flex; align-items: center; gap: 8px;
        }
        .status-dot {
            width: 6px; height: 6px; border-radius: 50%;
            background: var(--green);
            animation: blink 2s ease-in-out infinite;
        }
        @keyframes blink { 0%,100%{opacity:1} 50%{opacity:0.3} }

        /* ══════════════════════════════
           RIGHT PANEL — Login Form
        ══════════════════════════════ */
        .right-panel {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 60px 40px;
            position: relative;
            z-index: 1;
        }

        .login-box {
            width: 100%;
            max-width: 400px;
            animation: boxIn 0.7s cubic-bezier(.16,1,.3,1) both;
        }
        @keyframes boxIn {
            from { opacity:0; transform:translateY(32px); }
            to   { opacity:1; transform:translateY(0); }
        }

        .login-header { margin-bottom: 36px; }
        .login-title {
            font-size: 1.6rem; font-weight: 700;
            color: #fff; letter-spacing: 2px; margin-bottom: 6px;
        }
        .login-sub {
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.7rem; color: var(--text-dim); letter-spacing: 1px;
        }

        /* Divider */
        .h-line {
            height: 1px; background: var(--border);
            margin-bottom: 36px; position: relative;
        }
        .h-line::after {
            content: 'AUTHENTICATION REQUIRED';
            position: absolute;
            top: -8px; left: 0;
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.58rem; color: var(--green-dim);
            letter-spacing: 2px;
            background: var(--bg); padding-right: 10px;
        }

        /* Alert banners */
        .alert {
            padding: 12px 16px; margin-bottom: 24px;
            font-size: 0.85rem; letter-spacing: 0.5px;
            display: flex; align-items: center; gap: 10px;
            border-left: 3px solid;
            animation: alertSlide 0.4s ease both;
        }
        @keyframes alertSlide { from{opacity:0;transform:translateX(-10px)} to{opacity:1;transform:translateX(0)} }
        .alert-error   { background: rgba(255,71,87,0.08);  border-color: var(--danger); color: #ff8a94; }
        .alert-success { background: rgba(0,229,160,0.08);  border-color: var(--green);  color: var(--green); }

        /* Form fields */
        .field { margin-bottom: 20px; }

        .field label {
            display: flex; align-items: center; gap: 8px;
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.65rem; color: var(--green-dim);
            letter-spacing: 2px; text-transform: uppercase;
            margin-bottom: 8px;
        }
        .field label::before {
            content: '';
            width: 4px; height: 4px;
            background: var(--green); border-radius: 50%;
        }

        .inp-wrap { position: relative; }

        input[type="text"],
        input[type="password"] {
            width: 100%;
            padding: 13px 16px 13px 44px;
            background: var(--surface);
            border: 1px solid var(--border);
            color: var(--text);
            font-family: 'Rajdhani', sans-serif;
            font-size: 1rem; font-weight: 500;
            letter-spacing: 0.5px;
            outline: none;
            transition: all 0.25s;
        }
        input:focus {
            border-color: var(--green);
            background: rgba(0,229,160,0.04);
            box-shadow: 0 0 0 3px rgba(0,229,160,0.08), 0 0 20px rgba(0,229,160,0.06);
        }
        input::placeholder { color: var(--muted); font-style: normal; }

        .inp-icon {
            position: absolute; left: 14px; top: 50%;
            transform: translateY(-50%);
            font-size: 16px; opacity: 0.45;
            transition: opacity 0.25s;
            pointer-events: none;
        }
        .inp-wrap:focus-within .inp-icon { opacity: 0.9; }

        /* Submit button */
        .btn-login {
            width: 100%; padding: 14px;
            margin-top: 8px;
            background: var(--green);
            border: none;
            color: #040A06;
            font-family: 'Rajdhani', sans-serif;
            font-size: 1rem; font-weight: 700;
            letter-spacing: 3px; text-transform: uppercase;
            cursor: pointer;
            position: relative; overflow: hidden;
            transition: all 0.25s;
            box-shadow: 0 4px 24px rgba(0,229,160,0.3);
        }
        .btn-login::before {
            content: '';
            position: absolute; top: 0; left: -100%; width: 100%; height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.18), transparent);
            transition: left 0.5s;
        }
        .btn-login:hover::before { left: 100%; }
        .btn-login:hover {
            background: #00F0AA;
            box-shadow: 0 6px 36px rgba(0,229,160,0.5);
            transform: translateY(-1px);
        }
        .btn-login:active { transform: translateY(0); }

        .login-hint {
            margin-top: 20px; text-align: center;
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.65rem; color: var(--muted);
            letter-spacing: 1px;
        }
        .login-hint code {
            color: var(--text-dim);
            background: var(--surface);
            padding: 2px 8px; border: 1px solid var(--border);
        }

        /* Live clock */
        .live-clock {
            position: absolute; top: 28px; right: 28px;
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.7rem; color: var(--text-dim);
            letter-spacing: 2px; text-align: right;
        }
        .clock-time { font-size: 1.2rem; color: var(--green); display: block; }
    </style>
</head>
<body>

<div class="left-panel">
    <div class="scanline"></div>
    <div class="corner tl"></div><div class="corner tr"></div>
    <div class="corner bl"></div><div class="corner br"></div>

    <div class="brand">
        <div class="med-cross">
            <svg viewBox="0 0 80 80" fill="none" xmlns="http://www.w3.org/2000/svg">
                <rect x="28" y="4"  width="24" height="72" rx="3" fill="#00E5A0"/>
                <rect x="4"  y="28" width="72" height="24" rx="3" fill="#00E5A0"/>
                <rect x="28" y="4"  width="24" height="72" rx="3" fill="url(#cg)" opacity="0.4"/>
                <defs>
                    <linearGradient id="cg" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="0%" stop-color="#fff" stop-opacity="0.4"/>
                        <stop offset="100%" stop-color="#fff" stop-opacity="0"/>
                    </linearGradient>
                </defs>
            </svg>
        </div>
        <div class="brand-name">Rx<span>Care</span></div>
        <div class="brand-tagline">Pharmacy Management System</div>

        <div class="info-pills">
            <div class="pill">
                <span class="pill-icon">💊</span>
                <div class="pill-text">
                    <strong>Inventory Control</strong>
                    Real-time stock tracking
                </div>
            </div>
            <div class="pill">
                <span class="pill-icon">📊</span>
                <div class="pill-text">
                    <strong>Smart Alerts</strong>
                    Low stock notifications
                </div>
            </div>
            <div class="pill">
                <span class="pill-icon">📷</span>
                <div class="pill-text">
                    <strong>Barcode Scanning</strong>
                    Fast medicine entry
                </div>
            </div>
        </div>
    </div>

    <div class="sys-status">
        <div class="status-dot"></div>
        SYSTEM ONLINE
    </div>
</div>

<div class="right-panel">
    <div class="live-clock">
        <span class="clock-time" id="clk">--:--:--</span>
        <span id="clkDate"></span>
    </div>

    <div class="login-box">
        <div class="login-header">
            <div class="login-title">Staff Login</div>
            <div class="login-sub">// Authorised personnel only</div>
        </div>

        <div class="h-line"></div>

        <% if ("1".equals(error)) { %>
        <div class="alert alert-error">⚠ &nbsp; Invalid credentials. Access denied.</div>
        <% } %>
        <% if ("1".equals(logout)) { %>
        <div class="alert alert-success">✔ &nbsp; Signed out successfully. Session ended.</div>
        <% } %>

        <form action="<%=request.getContextPath()%>/login" method="post">
            <div class="field">
                <label for="username">Username</label>
                <div class="inp-wrap">
                    <span class="inp-icon">👤</span>
                    <input type="text" id="username" name="username" placeholder="Enter username" required autofocus>
                </div>
            </div>
            <div class="field">
                <label for="password">Password</label>
                <div class="inp-wrap">
                    <span class="inp-icon">🔒</span>
                    <input type="password" id="password" name="password" placeholder="Enter password" required>
                </div>
            </div>
            <button type="submit" class="btn-login">→ &nbsp; Access System</button>
        </form>

        <div class="login-hint">
            Default credentials: <code>admin</code> / <code>admin</code>
        </div>
    </div>
</div>

<script>
function updateClock() {
    const now = new Date();
    document.getElementById('clk').textContent = now.toLocaleTimeString('en-GB');
    document.getElementById('clkDate').textContent = now.toLocaleDateString('en-GB', {weekday:'short', day:'2-digit', month:'short', year:'numeric'});
}
updateClock(); setInterval(updateClock, 1000);
</script>
</body>
</html>
