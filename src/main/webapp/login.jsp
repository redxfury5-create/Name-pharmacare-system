<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // If already logged in, go straight to dashboard
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
    <title>PharmaCare — Login</title>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,400;0,600;1,400&family=Cinzel:wght@400;600&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --green-deep: #071410;
            --gold:       #C9A84C;
            --gold-light: #F0D080;
            --text:       #F5ECD7;
            --muted:      #B8A070;
            --danger:     #D96A3A;
            --success:    #5DAF78;
            --border:     rgba(201,168,76,0.32);
        }
        html, body { height: 100%; }
        body {
            min-height: 100vh;
            font-family: 'Cormorant Garamond', serif;
            background: var(--green-deep);
            background-image: url('assets/images/bg-mandala.jpg');
            background-size: cover; background-position: center;
            display: flex; align-items: center; justify-content: center;
            overflow: hidden; position: relative;
        }
        body::before {
            content: ''; position: fixed; inset: 0;
            background: rgba(3,12,6,0.65); z-index: 0;
        }

        /* ── Floating particles ── */
        .particles { position: fixed; inset: 0; pointer-events: none; z-index: 1; }
        .p {
            position: absolute; border-radius: 50%;
            background: var(--gold-light); opacity: 0;
            animation: rise linear infinite;
        }
        @keyframes rise {
            0%   { transform: translateY(100vh) scale(0); opacity: 0; }
            8%   { opacity: 0.55; }
            92%  { opacity: 0.18; }
            100% { transform: translateY(-8vh) scale(1.2); opacity: 0; }
        }

        /* ── Wrapper ── */
        .wrapper {
            position: relative; z-index: 2;
            width: 100%; max-width: 450px; padding: 20px;
        }

        /* entrance animation */
        .wrapper { animation: cardRise 1s cubic-bezier(.16,1,.3,1) both; }
        @keyframes cardRise {
            from { opacity: 0; transform: translateY(48px) scale(0.96); }
            to   { opacity: 1; transform: translateY(0)    scale(1); }
        }

        /* ── Ornament SVG ── */
        .orn { text-align: center; line-height: 0; }
        .orn svg { width: 300px; }

        /* ── Card ── */
        .card {
            background: linear-gradient(168deg, rgba(10,28,14,0.97) 0%, rgba(5,16,8,0.99) 100%);
            border: 1px solid var(--border);
            padding: 46px 48px 40px;
            position: relative;
            box-shadow:
                0 0 0 5px rgba(201,168,76,0.05),
                0 40px 100px rgba(0,0,0,0.78),
                inset 0 0 80px rgba(201,168,76,0.025);
        }
        .card::before {
            content: ''; position: absolute; inset: 7px;
            border: 1px solid rgba(201,168,76,0.1); pointer-events: none;
        }
        /* animated gold glow pulse on card */
        .card::after {
            content: ''; position: absolute; inset: -1px;
            border: 1px solid rgba(201,168,76,0.0);
            animation: borderPulse 3s ease-in-out infinite;
            pointer-events: none;
        }
        @keyframes borderPulse {
            0%,100% { border-color: rgba(201,168,76,0.0); box-shadow: 0 0 0px rgba(201,168,76,0); }
            50%     { border-color: rgba(201,168,76,0.4); box-shadow: 0 0 22px rgba(201,168,76,0.12); }
        }

        .cd { position: absolute; color: var(--gold); font-size: 12px; opacity: 0.6; line-height:1; }
        .cd.tl { top:11px; left:15px; } .cd.tr { top:11px; right:15px; }
        .cd.bl { bottom:11px; left:15px; } .cd.br { bottom:11px; right:15px; }

        /* ── Logo ── */
        .logo { text-align: center; margin-bottom: 32px; }
        .logo-ring {
            display: inline-flex; align-items: center; justify-content: center;
            width: 76px; height: 76px;
            border: 1.5px solid rgba(201,168,76,0.45);
            border-radius: 50%; margin-bottom: 16px;
            position: relative;
            box-shadow: 0 0 0 8px rgba(201,168,76,0.05), 0 0 40px rgba(201,168,76,0.12);
            animation: ringRotate 20s linear infinite;
        }
        @keyframes ringRotate {
            from { box-shadow: 0 0 0 8px rgba(201,168,76,0.05), 0 0 40px rgba(201,168,76,0.12),  4px 0 0 rgba(201,168,76,0.3); }
            25%  { box-shadow: 0 0 0 8px rgba(201,168,76,0.05), 0 0 40px rgba(201,168,76,0.12),  0  4px 0 rgba(201,168,76,0.3); }
            50%  { box-shadow: 0 0 0 8px rgba(201,168,76,0.05), 0 0 40px rgba(201,168,76,0.12), -4px 0 0 rgba(201,168,76,0.3); }
            75%  { box-shadow: 0 0 0 8px rgba(201,168,76,0.05), 0 0 40px rgba(201,168,76,0.12),  0 -4px 0 rgba(201,168,76,0.3); }
            100% { box-shadow: 0 0 0 8px rgba(201,168,76,0.05), 0 0 40px rgba(201,168,76,0.12),  4px 0 0 rgba(201,168,76,0.3); }
        }
        .logo-ring::before {
            content: ''; position: absolute; inset: 6px;
            border: 1px solid rgba(201,168,76,0.2); border-radius: 50%;
        }
        .logo-ring span { font-size: 30px; filter: drop-shadow(0 0 10px rgba(201,168,76,0.5)); }

        .logo-name {
            font-family: 'Cinzel', serif; font-size: 1.8rem; font-weight: 600;
            color: var(--gold-light); letter-spacing: 5px;
            text-shadow: 0 0 40px rgba(201,168,76,0.35);
        }
        .divider {
            display: flex; align-items: center; gap: 12px; margin: 10px 0 6px;
        }
        .dl { flex:1; height:1px; background: linear-gradient(90deg, transparent, rgba(201,168,76,0.45), transparent); }
        .dt { font-family:'Cinzel',serif; font-size:0.58rem; color:var(--gold); letter-spacing:3px; }
        .logo-sub { font-family:'Cinzel',serif; font-size:0.58rem; color:var(--muted); letter-spacing:4px; }

        /* ── Alert banners ── */
        .alert {
            padding: 11px 16px; margin-bottom: 22px;
            font-family: 'Cinzel', serif; font-size: 0.65rem; letter-spacing: 1.5px;
            display: flex; align-items: center; gap: 10px;
            animation: slideDown 0.4s ease both;
        }
        @keyframes slideDown {
            from { opacity:0; transform: translateY(-10px); }
            to   { opacity:1; transform: translateY(0); }
        }
        .alert-error {
            background: rgba(217,106,58,0.1);
            border: 1px solid rgba(217,106,58,0.35);
            color: var(--danger);
        }
        .alert-success {
            background: rgba(93,175,120,0.1);
            border: 1px solid rgba(93,175,120,0.35);
            color: var(--success);
        }

        /* ── Form ── */
        .field { margin-bottom: 22px; }
        label {
            display: block; font-family: 'Cinzel', serif;
            font-size: 0.6rem; color: var(--gold);
            letter-spacing: 2.5px; text-transform: uppercase; margin-bottom: 9px;
        }
        .inp-wrap { position: relative; }
        input[type="text"], input[type="password"] {
            width: 100%; padding: 13px 18px 13px 46px;
            background: rgba(255,255,255,0.03);
            border: 1px solid rgba(201,168,76,0.22);
            color: var(--text);
            font-family: 'Cormorant Garamond', serif; font-size: 1.05rem;
            outline: none;
            transition: border-color 0.3s, background 0.3s, box-shadow 0.3s;
        }
        .inp-icon {
            position: absolute; left: 16px; top: 50%;
            transform: translateY(-50%);
            font-size: 16px; opacity: 0.5;
            transition: opacity 0.3s;
            pointer-events: none;
        }
        input:focus { border-color: rgba(201,168,76,0.7); background: rgba(201,168,76,0.045); box-shadow: 0 0 0 4px rgba(201,168,76,0.08); }
        input:focus + .inp-icon { opacity: 1; }  /* won't work with this order — swap below */
        .inp-wrap:focus-within .inp-icon { opacity: 0.9; }
        input::placeholder { color: rgba(245,236,215,0.2); font-style: italic; }

        /* ── Button ── */
        .btn {
            width: 100%; padding: 15px; margin-top: 8px;
            background: linear-gradient(135deg, #7A5C10 0%, #C9A84C 35%, #F0D080 55%, #C9A84C 75%, #7A5C10 100%);
            border: none; color: #1C0F00;
            font-family: 'Cinzel', serif; font-size: 0.72rem; font-weight: 600;
            letter-spacing: 4px; text-transform: uppercase;
            cursor: pointer; position: relative; overflow: hidden;
            box-shadow: 0 4px 28px rgba(201,168,76,0.38), inset 0 1px 0 rgba(255,255,255,0.25);
            transition: transform 0.25s, box-shadow 0.25s;
        }
        .btn::before {
            content: ''; position: absolute; top:0; left:-120%; width:80%; height:100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.28), transparent);
            transform: skewX(-20deg);
            animation: shimmer 3s ease-in-out infinite;
        }
        @keyframes shimmer {
            0%   { left: -120%; }
            60%  { left: 140%; }
            100% { left: 140%; }
        }
        .btn:hover { transform: translateY(-2px); box-shadow: 0 8px 38px rgba(201,168,76,0.58); }
        .btn:active { transform: translateY(0); }

        .hint {
            text-align: center; margin-top: 20px;
            font-size: 0.85rem; color: rgba(184,160,112,0.5); font-style: italic;
        }
        .hint code {
            color: var(--gold); font-style: normal;
            background: rgba(201,168,76,0.08); padding: 1px 7px;
        }
    </style>
</head>
<body>

<div class="particles" id="pts"></div>

<div class="wrapper">
    <!-- Top ornament -->
    <div class="orn">
        <svg viewBox="0 0 300 38" fill="none" xmlns="http://www.w3.org/2000/svg">
            <line x1="0" y1="20" x2="300" y2="20" stroke="rgba(201,168,76,0.2)" stroke-width="0.5"/>
            <path d="M70 20 Q105 3 150 20 Q195 37 230 20" stroke="#C9A84C" stroke-width="1.2" fill="none" opacity="0.85"/>
            <path d="M50 20 Q100 1 150 20 Q200 39 250 20" stroke="#C9A84C" stroke-width="0.5" fill="none" opacity="0.3"/>
            <circle cx="150" cy="4"  r="3.2" fill="#C9A84C" opacity="0.9"/>
            <circle cx="133" cy="10" r="1.8" fill="#C9A84C" opacity="0.55"/>
            <circle cx="167" cy="10" r="1.8" fill="#C9A84C" opacity="0.55"/>
            <polygon points="150,0 154,6 150,3.5 146,6" fill="#C9A84C" opacity="0.8"/>
        </svg>
    </div>

    <div class="card">
        <span class="cd tl">◆</span><span class="cd tr">◆</span>
        <span class="cd bl">◆</span><span class="cd br">◆</span>

        <div class="logo">
            <div class="logo-ring"><span>⚕</span></div>
            <div class="logo-name">PHARMACARE</div>
            <div class="divider"><div class="dl"></div><div class="dt">✦ SYSTEM ✦</div><div class="dl"></div></div>
            <div class="logo-sub">Inventory Management</div>
        </div>

        <!-- Error / Logout messages -->
        <% if ("1".equals(error)) { %>
        <div class="alert alert-error">⚠ &nbsp; Invalid username or password. Please try again.</div>
        <% } %>
        <% if ("1".equals(logout)) { %>
        <div class="alert alert-success">✦ &nbsp; You have been signed out successfully.</div>
        <% } %>

        <form action="<%=request.getContextPath()%>/login" method="post">
            <div class="field">
                <label for="username">Username</label>
                <div class="inp-wrap">
                    <input type="text" id="username" name="username" placeholder="Enter your username" required autofocus>
                    <span class="inp-icon">👤</span>
                </div>
            </div>
            <div class="field">
                <label for="password">Password</label>
                <div class="inp-wrap">
                    <input type="password" id="password" name="password" placeholder="Enter your password" required>
                    <span class="inp-icon">🔒</span>
                </div>
            </div>
            <button type="submit" class="btn">✦ &nbsp; Enter &nbsp; ✦</button>
        </form>

        <div class="hint">Default: <code>admin</code> / <code>admin</code></div>
    </div>

    <!-- Bottom ornament -->
    <div class="orn">
        <svg viewBox="0 0 300 38" fill="none" xmlns="http://www.w3.org/2000/svg" style="transform:scaleY(-1)">
            <line x1="0" y1="20" x2="300" y2="20" stroke="rgba(201,168,76,0.2)" stroke-width="0.5"/>
            <path d="M70 20 Q105 3 150 20 Q195 37 230 20" stroke="#C9A84C" stroke-width="1.2" fill="none" opacity="0.85"/>
            <circle cx="150" cy="4" r="3.2" fill="#C9A84C" opacity="0.9"/>
            <circle cx="133" cy="10" r="1.8" fill="#C9A84C" opacity="0.55"/>
            <circle cx="167" cy="10" r="1.8" fill="#C9A84C" opacity="0.55"/>
            <polygon points="150,0 154,6 150,3.5 146,6" fill="#C9A84C" opacity="0.8"/>
        </svg>
    </div>
</div>

<script>
// Floating gold particles
const c = document.getElementById('pts');
for(let i = 0; i < 35; i++){
    const p = document.createElement('div'); p.className = 'p';
    const sz = (Math.random() * 2.5 + 0.8) + 'px';
    p.style.cssText = `left:${Math.random()*100}vw;width:${sz};height:${sz};animation-duration:${Math.random()*14+9}s;animation-delay:${Math.random()*14}s`;
    c.appendChild(p);
}
</script>
</body>
</html>
