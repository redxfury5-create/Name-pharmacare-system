<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String loggedUser = (String) userSession.getAttribute("user");
    ArrayList<String[]> list = (ArrayList<String[]>) request.getAttribute("list");
    if (list == null) list = new ArrayList<>();
    int total = list.size(), lowStock = 0;
    for (String[] m : list) { try { if(Integer.parseInt(m[2]) < 10) lowStock++; } catch(Exception e){} }
    // Toast from servlet redirects: add ?toast=added / ?toast=updated / ?toast=deleted to your servlet redirects
    String toast = request.getParameter("toast");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RxCare — Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@300;400;500;600;700&family=JetBrains+Mono:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --bg:          #060A0D;
            --surface:     #0C1218;
            --surface2:    #111C26;
            --surface3:    #172232;
            --green:       #00E5A0;
            --green-dim:   #00B87A;
            --green-glow:  rgba(0,229,160,0.14);
            --green-glow2: rgba(0,229,160,0.06);
            --text:        #C8E6D8;
            --text-dim:    #7AA090;
            --muted:       #2E4A3A;
            --danger:      #FF4757;
            --danger-dim:  rgba(255,71,87,0.1);
            --warning:     #FFB020;
            --warning-dim: rgba(255,176,32,0.1);
            --border:      rgba(0,229,160,0.1);
            --border2:     rgba(0,229,160,0.05);
            --sw:          240px;
        }
        html, body { height: 100%; }
        body {
            font-family: 'Rajdhani', sans-serif;
            background: var(--bg);
            color: var(--text);
            display: flex;
            min-height: 100vh;
        }
        body::before {
            content: '';
            position: fixed; inset: 0;
            background-image: radial-gradient(circle, rgba(0,229,160,0.06) 1px, transparent 1px);
            background-size: 28px 28px;
            pointer-events: none; z-index: 0;
        }

        /* ══════════ SIDEBAR ══════════ */
        .sidebar {
            width: var(--sw);
            min-height: 100vh;
            background: var(--surface);
            border-right: 1px solid var(--border);
            display: flex; flex-direction: column;
            position: fixed; top: 0; left: 0; bottom: 0;
            z-index: 50;
        }

        .sb-brand {
            padding: 28px 24px 24px;
            border-bottom: 1px solid var(--border);
            display: flex; align-items: center; gap: 12px;
        }
        .sb-cross {
            width: 36px; height: 36px; flex-shrink: 0;
            filter: drop-shadow(0 0 8px rgba(0,229,160,0.5));
        }
        .sb-name {
            font-size: 1.4rem; font-weight: 700;
            letter-spacing: 2px; color: #fff; line-height: 1;
        }
        .sb-name span { color: var(--green); }
        .sb-subtitle {
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.55rem; color: var(--text-dim);
            letter-spacing: 1.5px; margin-top: 2px;
        }

        .sb-section {
            padding: 20px 16px 8px;
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.58rem; color: var(--muted);
            letter-spacing: 2.5px; text-transform: uppercase;
        }

        .sb-nav { flex: 1; padding: 8px 12px; }

        .nav-item {
            display: flex; align-items: center; gap: 12px;
            padding: 11px 14px;
            color: var(--text-dim);
            text-decoration: none;
            font-size: 0.95rem; font-weight: 500; letter-spacing: 0.5px;
            border-left: 3px solid transparent;
            margin-bottom: 2px;
            transition: all 0.2s;
            position: relative;
        }
        .nav-item:hover {
            color: var(--text);
            background: var(--green-glow2);
            border-left-color: rgba(0,229,160,0.3);
        }
        .nav-item.active {
            color: var(--green);
            background: var(--green-glow);
            border-left-color: var(--green);
            font-weight: 600;
        }
        .nav-item.active::after {
            content: '';
            position: absolute; right: 12px; top: 50%;
            transform: translateY(-50%);
            width: 4px; height: 4px; border-radius: 50%;
            background: var(--green);
            box-shadow: 0 0 8px var(--green);
        }
        .nav-icon { font-size: 16px; width: 20px; text-align: center; flex-shrink: 0; }

        .sb-divider { height: 1px; background: var(--border); margin: 12px 16px; }

        .sb-footer {
            padding: 16px 16px 24px;
            border-top: 1px solid var(--border);
        }
        .sb-user {
            display: flex; align-items: center; gap: 10px;
            padding: 10px 14px; margin-bottom: 8px;
            background: var(--surface2);
            border: 1px solid var(--border);
        }
        .sb-user-icon {
            width: 30px; height: 30px; border-radius: 50%;
            background: var(--green-glow);
            border: 1px solid var(--green);
            display: flex; align-items: center; justify-content: center;
            font-size: 14px; flex-shrink: 0;
        }
        .sb-user-name {
            font-size: 0.85rem; font-weight: 600;
            color: var(--text); letter-spacing: 0.5px;
            text-transform: uppercase;
        }
        .sb-user-role {
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.58rem; color: var(--green-dim);
        }

        .btn-logout {
            display: flex; align-items: center; gap: 10px;
            width: 100%; padding: 10px 14px;
            background: transparent;
            border: 1px solid rgba(255,71,87,0.2);
            color: rgba(255,71,87,0.7);
            font-family: 'Rajdhani', sans-serif;
            font-size: 0.88rem; font-weight: 500; letter-spacing: 1px;
            cursor: pointer; text-decoration: none;
            transition: all 0.2s;
        }
        .btn-logout:hover {
            background: rgba(255,71,87,0.08);
            border-color: var(--danger);
            color: var(--danger);
        }

        /* ══════════ MAIN ══════════ */
        .main {
            margin-left: var(--sw);
            flex: 1; position: relative; z-index: 1;
            display: flex; flex-direction: column;
            min-height: 100vh;
        }

        /* Top bar */
        .topbar {
            padding: 20px 36px;
            border-bottom: 1px solid var(--border);
            display: flex; align-items: center; justify-content: space-between;
            background: rgba(6,10,13,0.8);
            backdrop-filter: blur(10px);
            position: sticky; top: 0; z-index: 40;
            animation: topIn 0.5s ease both;
        }
        @keyframes topIn { from{opacity:0;transform:translateY(-12px)} to{opacity:1;transform:translateY(0)} }
        .topbar-title {
            font-size: 1.4rem; font-weight: 700;
            color: #fff; letter-spacing: 1px;
        }
        .topbar-title span { color: var(--green); }
        .topbar-right { display: flex; align-items: center; gap: 16px; }
        .live-clock {
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.75rem; color: var(--text-dim);
            letter-spacing: 1.5px;
        }
        .live-clock strong { color: var(--green); }

        .btn-add {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 10px 22px;
            background: var(--green);
            border: none; color: #040A06;
            font-family: 'Rajdhani', sans-serif;
            font-size: 0.9rem; font-weight: 700; letter-spacing: 1.5px;
            cursor: pointer; text-decoration: none;
            transition: all 0.2s;
            box-shadow: 0 3px 16px rgba(0,229,160,0.3);
            position: relative; overflow: hidden;
        }
        .btn-add::before {
            content: '';
            position: absolute; top: 0; left: -100%; width: 100%; height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.15), transparent);
            transition: left 0.4s;
        }
        .btn-add:hover::before { left: 100%; }
        .btn-add:hover { background: #00F0AA; box-shadow: 0 4px 24px rgba(0,229,160,0.5); transform: translateY(-1px); }

        /* ══════════ CONTENT ══════════ */
        .content { padding: 28px 36px; flex: 1; }

        /* Low stock banner */
        .low-stock-banner {
            display: flex; align-items: center; justify-content: space-between;
            padding: 14px 20px; margin-bottom: 28px;
            background: var(--warning-dim);
            border: 1px solid rgba(255,176,32,0.25);
            border-left: 4px solid var(--warning);
            animation: bannerIn 0.5s 0.2s ease both;
        }
        @keyframes bannerIn { from{opacity:0;transform:translateY(-8px)} to{opacity:1;transform:translateY(0)} }
        .banner-left { display: flex; align-items: center; gap: 12px; }
        .banner-icon { font-size: 20px; }
        .banner-text strong { color: var(--warning); font-size: 0.95rem; font-weight: 700; display: block; letter-spacing: 0.5px; }
        .banner-text span { font-size: 0.82rem; color: rgba(255,176,32,0.7); font-family: 'JetBrains Mono', monospace; }
        .banner-count {
            font-family: 'JetBrains Mono', monospace;
            font-size: 1.8rem; font-weight: 500; color: var(--warning);
        }

        /* Stats */
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 18px; margin-bottom: 28px;
        }

        .stat {
            background: var(--surface);
            border: 1px solid var(--border);
            padding: 22px 24px;
            position: relative; overflow: hidden;
            animation: statIn 0.5s ease both;
        }
        .stat:nth-child(1){animation-delay:0.1s}
        .stat:nth-child(2){animation-delay:0.18s}
        .stat:nth-child(3){animation-delay:0.26s}
        @keyframes statIn { from{opacity:0;transform:translateY(14px)} to{opacity:1;transform:translateY(0)} }
        .stat::after {
            content: '';
            position: absolute; top: 0; left: 0; right: 0; height: 2px;
        }
        .stat.total::after  { background: var(--green); }
        .stat.low::after    { background: var(--danger); }
        .stat.instock::after{ background: var(--green-dim); }

        .stat-label {
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.62rem; color: var(--text-dim);
            letter-spacing: 2px; text-transform: uppercase; margin-bottom: 10px;
        }
        .stat-val {
            font-family: 'JetBrains Mono', monospace;
            font-size: 2.4rem; font-weight: 400; line-height: 1;
        }
        .stat.total  .stat-val { color: var(--green); text-shadow: 0 0 20px rgba(0,229,160,0.3); }
        .stat.low    .stat-val { color: var(--danger); text-shadow: 0 0 20px rgba(255,71,87,0.3); }
        .stat.instock.stat-val { color: var(--green); }
        .stat.instock .stat-val{ color: var(--green-dim); }
        .stat-sub {
            font-size: 0.75rem; color: var(--muted); margin-top: 4px;
        }
        .stat-glow {
            position: absolute; bottom: -20px; right: -20px;
            width: 100px; height: 100px;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(0,229,160,0.06) 0%, transparent 70%);
        }

        /* Search row */
        .search-row {
            display: flex; gap: 14px; margin-bottom: 18px;
            animation: statIn 0.5s 0.3s ease both;
        }
        .search-wrap { flex: 1; position: relative; }
        .search-wrap input {
            width: 100%; padding: 11px 16px 11px 42px;
            background: var(--surface);
            border: 1px solid var(--border);
            color: var(--text);
            font-family: 'Rajdhani', sans-serif;
            font-size: 0.95rem; letter-spacing: 0.5px;
            outline: none; transition: all 0.25s;
        }
        .search-wrap input:focus { border-color: var(--green); box-shadow: 0 0 0 3px rgba(0,229,160,0.07); }
        .search-wrap input::placeholder { color: var(--muted); }
        .search-icon { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: var(--text-dim); font-size: 14px; }

        /* Table */
        .tbl-wrap {
            background: var(--surface);
            border: 1px solid var(--border);
            overflow: hidden;
            animation: statIn 0.5s 0.35s ease both;
        }
        table { width: 100%; border-collapse: collapse; }
        thead tr { border-bottom: 1px solid rgba(0,229,160,0.15); background: rgba(0,229,160,0.04); }
        th {
            padding: 14px 20px; text-align: left;
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.62rem; color: var(--green-dim);
            letter-spacing: 2px; text-transform: uppercase; font-weight: 400;
        }
        tbody tr {
            border-bottom: 1px solid var(--border2);
            transition: background 0.15s;
            animation: rowIn 0.4s ease both;
        }
        @keyframes rowIn { from{opacity:0;transform:translateX(-8px)} to{opacity:1;transform:translateX(0)} }
        tbody tr:nth-child(1){animation-delay:0.40s} tbody tr:nth-child(2){animation-delay:0.45s}
        tbody tr:nth-child(3){animation-delay:0.50s} tbody tr:nth-child(4){animation-delay:0.55s}
        tbody tr:nth-child(5){animation-delay:0.60s} tbody tr:nth-child(6){animation-delay:0.65s}
        tbody tr:nth-child(n+7){animation-delay:0.68s}
        tbody tr:last-child { border-bottom: none; }
        tbody tr:hover { background: rgba(0,229,160,0.035); }
        td { padding: 14px 20px; font-size: 0.95rem; }
        .td-id {
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.75rem; color: var(--text-dim);
        }
        .td-name { color: #fff; font-weight: 600; letter-spacing: 0.3px; }
        .td-qty, .td-price {
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.88rem;
        }
        .td-qty.low { color: var(--danger); }

        .badge {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 3px 10px;
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.62rem; letter-spacing: 1px;
        }
        .badge-low  { background: var(--danger-dim);  border: 1px solid rgba(255,71,87,0.3);  color: var(--danger); }
        .badge-ok   { background: var(--green-glow2); border: 1px solid rgba(0,229,160,0.2);  color: var(--green-dim); }

        .acts { display: flex; gap: 8px; }
        .act {
            padding: 5px 14px;
            font-family: 'Rajdhani', sans-serif;
            font-size: 0.82rem; font-weight: 600; letter-spacing: 1px;
            text-decoration: none; border: 1px solid; cursor: pointer;
            transition: all 0.18s; background: transparent;
        }
        .act-edit { border-color: rgba(0,229,160,0.25); color: var(--green-dim); }
        .act-edit:hover { border-color: var(--green); color: var(--green); background: var(--green-glow2); transform: translateY(-1px); }
        .act-del  { border-color: rgba(255,71,87,0.2); color: rgba(255,71,87,0.6); }
        .act-del:hover  { border-color: var(--danger); color: var(--danger); background: var(--danger-dim); transform: translateY(-1px); }

        .empty { text-align: center; padding: 64px 20px; color: var(--muted); }
        .empty .ico { font-size: 48px; margin-bottom: 14px; opacity: 0.4; }
        .empty p { font-family: 'JetBrains Mono', monospace; font-size: 0.8rem; letter-spacing: 1px; }

        /* ══════════ DELETE MODAL ══════════ */
        .modal-overlay {
            position: fixed; inset: 0;
            background: rgba(4,8,11,0.85);
            backdrop-filter: blur(6px);
            z-index: 200;
            display: none;
            align-items: center; justify-content: center;
            animation: overlayIn 0.25s ease both;
        }
        .modal-overlay.open { display: flex; }
        @keyframes overlayIn { from{opacity:0} to{opacity:1} }

        .modal {
            background: var(--surface2);
            border: 1px solid rgba(255,71,87,0.3);
            width: 100%; max-width: 420px;
            padding: 36px;
            position: relative;
            box-shadow: 0 24px 80px rgba(0,0,0,0.7);
            animation: modalIn 0.3s cubic-bezier(.16,1,.3,1) both;
        }
        @keyframes modalIn { from{opacity:0;transform:scale(0.92)} to{opacity:1;transform:scale(1)} }
        .modal::before { content:''; position:absolute; top:0; left:0; right:0; height:2px; background:var(--danger); }

        .modal-icon { font-size: 36px; margin-bottom: 14px; text-align: center; }
        .modal-title {
            font-size: 1.2rem; font-weight: 700;
            color: var(--danger); letter-spacing: 1px; text-align: center; margin-bottom: 10px;
        }
        .modal-msg {
            text-align: center; font-size: 0.9rem; color: var(--text-dim);
            margin-bottom: 8px; line-height: 1.6;
        }
        .modal-name {
            text-align: center; font-family: 'JetBrains Mono', monospace;
            font-size: 0.9rem; color: #fff;
            background: rgba(255,71,87,0.07); border: 1px solid rgba(255,71,87,0.15);
            padding: 8px 16px; margin: 12px 0 28px;
        }
        .modal-actions { display: flex; gap: 12px; }
        .btn-modal-cancel {
            flex: 1; padding: 12px;
            background: transparent; border: 1px solid var(--border);
            color: var(--text-dim);
            font-family: 'Rajdhani', sans-serif;
            font-size: 0.9rem; font-weight: 600; letter-spacing: 1px;
            cursor: pointer; transition: all 0.2s;
        }
        .btn-modal-cancel:hover { border-color: var(--text-dim); color: var(--text); }
        .btn-modal-confirm {
            flex: 1; padding: 12px;
            background: var(--danger); border: none;
            color: #fff;
            font-family: 'Rajdhani', sans-serif;
            font-size: 0.9rem; font-weight: 700; letter-spacing: 1.5px;
            cursor: pointer; transition: all 0.2s;
            box-shadow: 0 4px 16px rgba(255,71,87,0.3);
        }
        .btn-modal-confirm:hover { background: #FF6070; box-shadow: 0 4px 24px rgba(255,71,87,0.5); }

        /* ══════════ TOAST ══════════ */
        .toast-container {
            position: fixed; top: 24px; right: 24px;
            z-index: 300; display: flex; flex-direction: column; gap: 10px;
        }
        .toast {
            display: flex; align-items: center; gap: 12px;
            padding: 14px 20px;
            background: var(--surface2); border: 1px solid;
            min-width: 280px; max-width: 380px;
            font-size: 0.9rem; font-weight: 500; letter-spacing: 0.3px;
            box-shadow: 0 12px 40px rgba(0,0,0,0.5);
            animation: toastIn 0.4s cubic-bezier(.16,1,.3,1) both;
            position: relative; overflow: hidden;
        }
        @keyframes toastIn { from{opacity:0;transform:translateX(30px)} to{opacity:1;transform:translateX(0)} }
        .toast.out { animation: toastOut 0.3s ease both; }
        @keyframes toastOut { to{opacity:0;transform:translateX(30px)} }
        .toast::after {
            content: '';
            position: absolute; bottom: 0; left: 0;
            height: 2px; background: currentColor; opacity: 0.5;
            animation: toastTimer 3s linear both;
        }
        @keyframes toastTimer { from{width:100%} to{width:0%} }
        .toast-success { border-color: rgba(0,229,160,0.3); color: var(--green); }
        .toast-error   { border-color: rgba(255,71,87,0.3);  color: var(--danger); }
        .toast-warning { border-color: rgba(255,176,32,0.3); color: var(--warning); }
    </style>
</head>
<body>

<!-- Toast container -->
<div class="toast-container" id="toastContainer"></div>

<!-- Delete Modal -->
<div class="modal-overlay" id="deleteModal">
    <div class="modal">
        <div class="modal-icon">🗑️</div>
        <div class="modal-title">Confirm Deletion</div>
        <div class="modal-msg">You are about to permanently remove:</div>
        <div class="modal-name" id="modalMedName"></div>
        <div class="modal-msg" style="font-size:0.8rem;margin-top:-16px;color:rgba(255,71,87,0.6)">This action cannot be undone.</div>
        <div class="modal-actions">
            <button class="btn-modal-cancel" onclick="closeModal()">Cancel</button>
            <button class="btn-modal-confirm" id="modalConfirmBtn">Delete</button>
        </div>
    </div>
</div>

<!-- SIDEBAR -->
<aside class="sidebar">
    <div class="sb-brand">
        <svg class="sb-cross" viewBox="0 0 36 36" fill="none">
            <rect x="13" y="2" width="10" height="32" rx="2" fill="#00E5A0"/>
            <rect x="2"  y="13" width="32" height="10" rx="2" fill="#00E5A0"/>
        </svg>
        <div>
            <div class="sb-name">Rx<span>Care</span></div>
            <div class="sb-subtitle">PHARMACY SYSTEM</div>
        </div>
    </div>

    <div class="sb-section">Navigation</div>
    <nav class="sb-nav">
        <a href="<%=request.getContextPath()%>/viewMedicines" class="nav-item active">
            <span class="nav-icon">⬡</span> Dashboard
        </a>
        <a href="<%=request.getContextPath()%>/addMedicine.jsp" class="nav-item">
            <span class="nav-icon">＋</span> Add Medicine
        </a>
    </nav>

    <div class="sb-divider"></div>

    <div class="sb-footer">
        <div class="sb-user">
            <div class="sb-user-icon">👤</div>
            <div>
                <div class="sb-user-name"><%= loggedUser %></div>
                <div class="sb-user-role">// PHARMACIST</div>
            </div>
        </div>
        <a href="<%=request.getContextPath()%>/logout" class="btn-logout"
           onclick="return confirm('End session and logout?')">
            ⏻ &nbsp; Logout
        </a>
    </div>
</aside>

<!-- MAIN -->
<div class="main">
    <div class="topbar">
        <div class="topbar-title">Medicine <span>Inventory</span></div>
        <div class="topbar-right">
            <div class="live-clock"><strong id="clk">--:--:--</strong> &nbsp;<span id="clkD"></span></div>
            <a href="<%=request.getContextPath()%>/addMedicine.jsp" class="btn-add">+ Add Medicine</a>
        </div>
    </div>

    <div class="content">

        <!-- Low stock banner -->
        <% if (lowStock > 0) { %>
        <div class="low-stock-banner">
            <div class="banner-left">
                <span class="banner-icon">⚠️</span>
                <div class="banner-text">
                    <strong>Low Stock Alert</strong>
                    <span><%= lowStock %> medicine(s) are running critically low (under 10 units)</span>
                </div>
            </div>
            <div class="banner-count"><%= lowStock %></div>
        </div>
        <% } %>

        <!-- Stats -->
        <div class="stats">
            <div class="stat total">
                <div class="stat-label">Total Medicines</div>
                <div class="stat-val"><%= total %></div>
                <div class="stat-sub">items in inventory</div>
                <div class="stat-glow"></div>
            </div>
            <div class="stat low">
                <div class="stat-label">Low Stock</div>
                <div class="stat-val"><%= lowStock %></div>
                <div class="stat-sub">need restocking</div>
            </div>
            <div class="stat instock">
                <div class="stat-label">In Stock</div>
                <div class="stat-val"><%= total - lowStock %></div>
                <div class="stat-sub">adequate supply</div>
            </div>
        </div>

        <!-- Search -->
        <div class="search-row">
            <div class="search-wrap">
                <span class="search-icon">🔍</span>
                <input type="text" id="searchInput" placeholder="Search medicines by name…" oninput="filterTable()">
            </div>
        </div>

        <!-- Table -->
        <div class="tbl-wrap">
            <table id="medTable">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Medicine Name</th>
                        <th>Qty (units)</th>
                        <th>Price</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                <% if (list.isEmpty()) { %>
                <tr><td colspan="6">
                    <div class="empty">
                        <div class="ico">💊</div>
                        <p>NO MEDICINES FOUND — ADD YOUR FIRST ITEM</p>
                    </div>
                </td></tr>
                <% } else { for (String[] med : list) {
                    int qty = 0; try{qty=Integer.parseInt(med[2]);}catch(Exception e){}
                    boolean isLow = qty < 10;
                %>
                <tr>
                    <td class="td-id">#<%= med[0] %></td>
                    <td class="td-name"><%= med[1] %></td>
                    <td class="td-qty <%= isLow ? "low" : "" %>"><%= med[2] %></td>
                    <td class="td-price">₹<%= med[3] %></td>
                    <td>
                        <% if (isLow) { %>
                            <span class="badge badge-low">⚠ LOW</span>
                        <% } else { %>
                            <span class="badge badge-ok">✔ OK</span>
                        <% } %>
                    </td>
                    <td>
                        <div class="acts">
                            <a href="<%=request.getContextPath()%>/editMedicine.jsp?id=<%= med[0] %>" class="act act-edit">Edit</a>
                            <button class="act act-del"
                                onclick="openModal('<%= med[0] %>', '<%= med[1].replace("'","\\'") %>')">
                                Delete
                            </button>
                        </div>
                    </td>
                </tr>
                <% } } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
// ── Clock ──
function tick() {
    const n = new Date();
    document.getElementById('clk').textContent  = n.toLocaleTimeString('en-GB');
    document.getElementById('clkD').textContent = n.toLocaleDateString('en-GB',{day:'2-digit',month:'short',year:'numeric'});
}
tick(); setInterval(tick, 1000);

// ── Search ──
function filterTable() {
    const q = document.getElementById('searchInput').value.toLowerCase();
    document.querySelectorAll('#medTable tbody tr').forEach(r => {
        const n = r.querySelector('.td-name');
        if (n) r.style.display = n.textContent.toLowerCase().includes(q) ? '' : 'none';
    });
}

// ── Delete Modal ──
let deleteUrl = '';
function openModal(id, name) {
    document.getElementById('modalMedName').textContent = name;
    deleteUrl = '<%=request.getContextPath()%>/deleteMedicine?id=' + id + '&toast=deleted';
    document.getElementById('modalConfirmBtn').onclick = () => { window.location = deleteUrl; };
    document.getElementById('deleteModal').classList.add('open');
}
function closeModal() {
    document.getElementById('deleteModal').classList.remove('open');
}
// Close on overlay click
document.getElementById('deleteModal').addEventListener('click', function(e) {
    if (e.target === this) closeModal();
});

// ── Toast System ──
function showToast(message, type = 'success') {
    const c = document.getElementById('toastContainer');
    const t = document.createElement('div');
    t.className = 'toast toast-' + type;
    const icons = { success: '✔', error: '⚠', warning: '⚡' };
    t.innerHTML = '<span>' + (icons[type]||'✔') + '</span><span>' + message + '</span>';
    c.appendChild(t);
    setTimeout(() => {
        t.classList.add('out');
        setTimeout(() => t.remove(), 350);
    }, 3200);
}

// ── Auto-toast from URL param ──
const params = new URLSearchParams(window.location.search);
const toastMsg = params.get('toast');
if (toastMsg === 'added')   showToast('Medicine added successfully!', 'success');
if (toastMsg === 'updated') showToast('Medicine updated successfully!', 'success');
if (toastMsg === 'deleted') showToast('Medicine deleted from inventory.', 'warning');
</script>
</body>
</html>
