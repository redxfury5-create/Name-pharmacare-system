<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String loggedUser = (String) userSession.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RxCare — Add Medicine</title>
    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@300;400;500;600;700&family=JetBrains+Mono:wght@300;400;500&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/html5-qrcode@2.3.8/html5-qrcode.min.js"></script>
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --bg: #060A0D; --surface: #0C1218; --surface2: #111C26;
            --green: #00E5A0; --green-dim: #00B87A; --green-glow: rgba(0,229,160,0.14); --green-glow2: rgba(0,229,160,0.06);
            --text: #C8E6D8; --text-dim: #7AA090; --muted: #2E4A3A;
            --danger: #FF4757; --border: rgba(0,229,160,0.1); --border2: rgba(0,229,160,0.05);
            --sw: 240px;
        }
        *, body { font-family: 'Rajdhani', sans-serif; }
        body { background: var(--bg); color: var(--text); display: flex; min-height: 100vh; }
        body::before {
            content: ''; position: fixed; inset: 0;
            background-image: radial-gradient(circle, rgba(0,229,160,0.06) 1px, transparent 1px);
            background-size: 28px 28px; pointer-events: none; z-index: 0;
        }

        /* ── Sidebar (shared) ── */
        .sidebar {
            width: var(--sw); min-height: 100vh;
            background: var(--surface); border-right: 1px solid var(--border);
            display: flex; flex-direction: column;
            position: fixed; top: 0; left: 0; bottom: 0; z-index: 50;
        }
        .sb-brand { padding: 28px 24px 24px; border-bottom: 1px solid var(--border); display: flex; align-items: center; gap: 12px; }
        .sb-cross { width: 36px; height: 36px; flex-shrink: 0; filter: drop-shadow(0 0 8px rgba(0,229,160,0.5)); }
        .sb-name { font-size: 1.4rem; font-weight: 700; letter-spacing: 2px; color: #fff; line-height: 1; }
        .sb-name span { color: var(--green); }
        .sb-subtitle { font-family: 'JetBrains Mono', monospace; font-size: 0.55rem; color: var(--text-dim); letter-spacing: 1.5px; margin-top: 2px; }
        .sb-section { padding: 20px 16px 8px; font-family: 'JetBrains Mono', monospace; font-size: 0.58rem; color: var(--muted); letter-spacing: 2.5px; }
        .sb-nav { flex: 1; padding: 8px 12px; }
        .nav-item {
            display: flex; align-items: center; gap: 12px; padding: 11px 14px;
            color: var(--text-dim); text-decoration: none; font-size: 0.95rem; font-weight: 500;
            border-left: 3px solid transparent; margin-bottom: 2px; transition: all 0.2s;
        }
        .nav-item:hover { color: var(--text); background: var(--green-glow2); border-left-color: rgba(0,229,160,0.3); }
        .nav-item.active { color: var(--green); background: var(--green-glow); border-left-color: var(--green); font-weight: 600; }
        .nav-icon { font-size: 16px; width: 20px; text-align: center; flex-shrink: 0; }
        .sb-divider { height: 1px; background: var(--border); margin: 12px 16px; }
        .sb-footer { padding: 16px 16px 24px; border-top: 1px solid var(--border); }
        .sb-user { display: flex; align-items: center; gap: 10px; padding: 10px 14px; margin-bottom: 8px; background: var(--surface2); border: 1px solid var(--border); }
        .sb-user-icon { width: 30px; height: 30px; border-radius: 50%; background: var(--green-glow); border: 1px solid var(--green); display: flex; align-items: center; justify-content: center; font-size: 14px; flex-shrink: 0; }
        .sb-user-name { font-size: 0.85rem; font-weight: 600; color: var(--text); letter-spacing: 0.5px; text-transform: uppercase; }
        .sb-user-role { font-family: 'JetBrains Mono', monospace; font-size: 0.58rem; color: var(--green-dim); }
        .btn-logout { display: flex; align-items: center; gap: 10px; width: 100%; padding: 10px 14px; background: transparent; border: 1px solid rgba(255,71,87,0.2); color: rgba(255,71,87,0.7); font-family: 'Rajdhani', sans-serif; font-size: 0.88rem; font-weight: 500; letter-spacing: 1px; cursor: pointer; text-decoration: none; transition: all 0.2s; }
        .btn-logout:hover { background: rgba(255,71,87,0.08); border-color: var(--danger); color: var(--danger); }

        /* ── Main ── */
        .main { margin-left: var(--sw); flex: 1; position: relative; z-index: 1; display: flex; flex-direction: column; min-height: 100vh; }
        .topbar {
            padding: 20px 36px; border-bottom: 1px solid var(--border);
            display: flex; align-items: center; justify-content: space-between;
            background: rgba(6,10,13,0.85); backdrop-filter: blur(10px);
            position: sticky; top: 0; z-index: 40;
        }
        .topbar-title { font-size: 1.4rem; font-weight: 700; color: #fff; letter-spacing: 1px; }
        .topbar-title span { color: var(--green); }
        .breadcrumb { font-family: 'JetBrains Mono', monospace; font-size: 0.65rem; color: var(--text-dim); margin-top: 3px; }
        .back-link { display: inline-flex; align-items: center; gap: 8px; color: var(--text-dim); text-decoration: none; font-size: 0.88rem; font-weight: 500; transition: color 0.2s; }
        .back-link:hover { color: var(--green); }

        .content { padding: 32px 36px; flex: 1; }

        /* Two column layout */
        .two-col { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }

        /* Panel */
        .panel {
            background: var(--surface); border: 1px solid var(--border);
            position: relative; overflow: hidden;
            animation: panelIn 0.5s ease both;
        }
        .panel:nth-child(1){animation-delay:0.08s}
        .panel:nth-child(2){animation-delay:0.16s}
        @keyframes panelIn { from{opacity:0;transform:translateY(16px)} to{opacity:1;transform:translateY(0)} }
        .panel::before { content:''; position:absolute; top:0; left:0; right:0; height:2px; background:var(--green); }

        .panel-head {
            padding: 18px 24px;
            border-bottom: 1px solid var(--border);
            display: flex; align-items: center; gap: 10px;
        }
        .panel-head-icon { font-size: 18px; }
        .panel-title { font-size: 0.9rem; font-weight: 700; letter-spacing: 1.5px; text-transform: uppercase; color: var(--text); }
        .panel-sub { font-family: 'JetBrains Mono', monospace; font-size: 0.6rem; color: var(--text-dim); margin-top: 2px; }
        .panel-body { padding: 24px; }

        /* Form */
        .field { margin-bottom: 20px; }
        .field label {
            display: flex; align-items: center; gap: 8px;
            font-family: 'JetBrains Mono', monospace; font-size: 0.62rem;
            color: var(--green-dim); letter-spacing: 2px; text-transform: uppercase; margin-bottom: 8px;
        }
        .field label::before { content:''; width:4px; height:4px; background:var(--green); border-radius:50%; flex-shrink:0; }
        input[type="text"], input[type="number"] {
            width: 100%; padding: 12px 16px;
            background: var(--surface2); border: 1px solid var(--border);
            color: var(--text); font-family: 'Rajdhani', sans-serif;
            font-size: 0.95rem; font-weight: 500; letter-spacing: 0.5px;
            outline: none; transition: all 0.25s;
        }
        input:focus { border-color: var(--green); background: rgba(0,229,160,0.04); box-shadow: 0 0 0 3px rgba(0,229,160,0.07); }
        input::placeholder { color: var(--muted); }

        /* Scanner */
        .scan-desc { font-size: 0.85rem; color: var(--text-dim); margin-bottom: 18px; line-height: 1.7; font-family: 'JetBrains Mono', monospace; font-size: 0.7rem; letter-spacing: 0.5px; }

        .btn-scan {
            display: flex; align-items: center; gap: 8px; width: 100%;
            padding: 12px 18px; margin-bottom: 16px;
            background: rgba(0,229,160,0.06); border: 1px solid rgba(0,229,160,0.25);
            color: var(--green); cursor: pointer;
            font-family: 'Rajdhani', sans-serif; font-size: 0.92rem; font-weight: 600; letter-spacing: 1.5px;
            transition: all 0.2s;
        }
        .btn-scan:hover { background: rgba(0,229,160,0.12); border-color: var(--green); }
        .btn-scan.active { background: rgba(255,71,87,0.07); border-color: rgba(255,71,87,0.3); color: var(--danger); }

        #reader { border: 1px solid rgba(0,229,160,0.2); display: none; margin-bottom: 14px; background: #000; }
        #reader video { width: 100% !important; }

        .scan-tip {
            display: flex; align-items: flex-start; gap: 10px;
            padding: 12px 14px; background: rgba(0,229,160,0.04);
            border: 1px solid var(--border2);
            font-family: 'JetBrains Mono', monospace; font-size: 0.65rem;
            color: var(--text-dim); letter-spacing: 0.5px; line-height: 1.6; margin-bottom: 14px;
        }

        .scan-result {
            padding: 12px 16px; display: none; margin-top: 8px;
            background: rgba(0,229,160,0.07); border: 1px solid rgba(0,229,160,0.25);
            color: var(--green);
            font-family: 'JetBrains Mono', monospace; font-size: 0.75rem; letter-spacing: 0.5px;
            animation: panelIn 0.3s ease both;
        }
        .scan-error {
            padding: 12px 16px; display: none; margin-top: 8px;
            background: rgba(255,71,87,0.07); border: 1px solid rgba(255,71,87,0.25);
            color: var(--danger);
            font-family: 'JetBrains Mono', monospace; font-size: 0.75rem; letter-spacing: 0.5px;
        }

        /* Submit */
        .btn-submit {
            width: 100%; padding: 14px;
            background: var(--green); border: none;
            color: #040A06; font-family: 'Rajdhani', sans-serif;
            font-size: 1rem; font-weight: 700; letter-spacing: 2px;
            cursor: pointer; transition: all 0.25s;
            box-shadow: 0 4px 20px rgba(0,229,160,0.28);
            position: relative; overflow: hidden;
        }
        .btn-submit::before {
            content: ''; position: absolute; top: 0; left: -100%; width: 100%; height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.15), transparent);
            transition: left 0.45s;
        }
        .btn-submit:hover::before { left: 100%; }
        .btn-submit:hover { background: #00F0AA; box-shadow: 0 6px 30px rgba(0,229,160,0.45); transform: translateY(-1px); }

        .btn-cancel {
            width: 100%; padding: 12px; margin-top: 10px;
            background: transparent; border: 1px solid var(--border);
            color: var(--text-dim); font-family: 'Rajdhani', sans-serif;
            font-size: 0.88rem; font-weight: 500; letter-spacing: 1px;
            text-decoration: none; display: flex; align-items: center; justify-content: center;
            transition: all 0.2s; cursor: pointer;
        }
        .btn-cancel:hover { border-color: var(--text-dim); color: var(--text); }

        /* Toast */
        .toast-container { position: fixed; top: 24px; right: 24px; z-index: 300; display: flex; flex-direction: column; gap: 10px; }
        .toast { display: flex; align-items: center; gap: 12px; padding: 14px 20px; background: var(--surface2); border: 1px solid; min-width: 280px; font-size: 0.9rem; font-weight: 500; box-shadow: 0 12px 40px rgba(0,0,0,0.5); animation: toastIn 0.4s cubic-bezier(.16,1,.3,1) both; position: relative; overflow: hidden; }
        @keyframes toastIn { from{opacity:0;transform:translateX(30px)} to{opacity:1;transform:translateX(0)} }
        .toast-success { border-color: rgba(0,229,160,0.3); color: var(--green); }
    </style>
</head>
<body>

<div class="toast-container" id="toastContainer"></div>

<!-- SIDEBAR -->
<aside class="sidebar">
    <div class="sb-brand">
        <svg class="sb-cross" viewBox="0 0 36 36" fill="none">
            <rect x="13" y="2" width="10" height="32" rx="2" fill="#00E5A0"/>
            <rect x="2" y="13" width="32" height="10" rx="2" fill="#00E5A0"/>
        </svg>
        <div>
            <div class="sb-name">Rx<span>Care</span></div>
            <div class="sb-subtitle">PHARMACY SYSTEM</div>
        </div>
    </div>
    <div class="sb-section">Navigation</div>
    <nav class="sb-nav">
        <a href="<%=request.getContextPath()%>/viewMedicines" class="nav-item">
            <span class="nav-icon">⬡</span> Dashboard
        </a>
        <a href="<%=request.getContextPath()%>/addMedicine.jsp" class="nav-item active">
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
        <a href="<%=request.getContextPath()%>/logout" class="btn-logout" onclick="return confirm('End session?')">⏻ &nbsp; Logout</a>
    </div>
</aside>

<!-- MAIN -->
<div class="main">
    <div class="topbar">
        <div>
            <div class="topbar-title">Add <span>Medicine</span></div>
            <div class="breadcrumb">// INVENTORY → NEW RECORD</div>
        </div>
        <a href="<%=request.getContextPath()%>/viewMedicines" class="back-link">← Back to Dashboard</a>
    </div>

    <div class="content">
        <div class="two-col">

            <!-- SCANNER PANEL -->
            <div class="panel">
                <div class="panel-head">
                    <span class="panel-head-icon">📷</span>
                    <div>
                        <div class="panel-title">Barcode Scanner</div>
                        <div class="panel-sub">// SCAN TO AUTO-FILL</div>
                    </div>
                </div>
                <div class="panel-body">
                    <div class="scan-tip">
                        ℹ️ &nbsp; Point camera at any barcode or QR code on medicine packaging. Name field will be filled automatically on detection.
                    </div>
                    <button class="btn-scan" id="scanBtn" onclick="toggleScanner()">
                        📷 &nbsp; START CAMERA SCANNER
                    </button>
                    <div id="reader"></div>
                    <div class="scan-result" id="scanResult"></div>
                    <div class="scan-error"  id="scanError"></div>
                </div>
            </div>

            <!-- FORM PANEL -->
            <div class="panel">
                <div class="panel-head">
                    <span class="panel-head-icon">💊</span>
                    <div>
                        <div class="panel-title">Medicine Details</div>
                        <div class="panel-sub">// NEW INVENTORY RECORD</div>
                    </div>
                </div>
                <div class="panel-body">
                    <form action="<%=request.getContextPath()%>/addMedicine" method="post">
                        <div class="field">
                            <label for="name">Medicine Name</label>
                            <input type="text" id="name" name="name" placeholder="e.g. Paracetamol 500mg" required>
                        </div>
                        <div class="field">
                            <label for="quantity">Quantity (units)</label>
                            <input type="number" id="quantity" name="quantity" placeholder="e.g. 100" min="0" required>
                        </div>
                        <div class="field">
                            <label for="price">Unit Price (₹)</label>
                            <input type="number" id="price" name="price" placeholder="e.g. 25.50" step="0.01" min="0" required>
                        </div>
                        <button type="submit" class="btn-submit">+ ADD TO INVENTORY</button>
                        <a href="<%=request.getContextPath()%>/viewMedicines" class="btn-cancel">Cancel</a>
                    </form>
                </div>
            </div>

        </div>
    </div>
</div>

<script>
let scanner = null, scanning = false;

function toggleScanner() {
    const btn = document.getElementById('scanBtn');
    const rd  = document.getElementById('reader');
    document.getElementById('scanError').style.display = 'none';

    if (!scanning) {
        rd.style.display = 'block';
        btn.innerHTML = '⏹ &nbsp; STOP SCANNER';
        btn.classList.add('active');
        scanning = true;
        scanner = new Html5Qrcode("reader");

        Html5Qrcode.getCameras().then(cameras => {
            if (!cameras || cameras.length === 0) { scanErr("No camera found on this device."); return; }
            const cam = cameras.find(c =>
                /back|rear|environment/i.test(c.label)
            ) || cameras[cameras.length - 1];

            scanner.start(cam.id,
                { fps: 15, qrbox: { width: 260, height: 140 }, aspectRatio: 1.7 },
                (code) => {
                    document.getElementById('name').value = code;
                    const r = document.getElementById('scanResult');
                    r.style.display = 'block';
                    r.innerHTML = '✔ &nbsp; Detected: <strong>' + code + '</strong> — name field filled!';
                    stopScanner();
                    showToast('Barcode scanned successfully!', 'success');
                },
                () => {}
            ).catch(() => { scanErr("Camera access denied. Allow permissions and retry."); stopScanner(); });
        }).catch(() => { scanErr("Could not access camera."); stopScanner(); });
    } else {
        stopScanner();
    }
}

function stopScanner() {
    if (scanner) { scanner.stop().catch(()=>{}); scanner.clear(); scanner = null; }
    document.getElementById('reader').style.display = 'none';
    const btn = document.getElementById('scanBtn');
    btn.innerHTML = '📷 &nbsp; START CAMERA SCANNER';
    btn.classList.remove('active');
    scanning = false;
}

function scanErr(msg) {
    const e = document.getElementById('scanError');
    e.style.display = 'block';
    e.innerHTML = '⚠ &nbsp;' + msg;
}

function showToast(msg, type) {
    const c = document.getElementById('toastContainer');
    const t = document.createElement('div');
    t.className = 'toast toast-' + type;
    t.innerHTML = '<span>✔</span><span>' + msg + '</span>';
    c.appendChild(t);
    setTimeout(() => t.remove(), 3500);
}
</script>
</body>
</html>
