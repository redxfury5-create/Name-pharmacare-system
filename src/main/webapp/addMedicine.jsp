<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PharmaCare — Add Medicine</title>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,400;0,600;1,400&family=Cinzel:wght@400;600&display=swap" rel="stylesheet">
    <!-- ✅ html5-qrcode: much more reliable than QuaggaJS -->
    <script src="https://unpkg.com/html5-qrcode@2.3.8/html5-qrcode.min.js"></script>
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --gold: #C9A84C; --gold-light: #F0D080;
            --text: #F5ECD7; --muted: #B8A070;
            --danger: #D96A3A; --success: #5DAF78;
            --border: rgba(201,168,76,0.28);
        }
        body {
            min-height:100vh; font-family:'Cormorant Garamond',serif;
            background:#071410 url('assets/images/bg-mandala.jpg') center/cover fixed;
            color:var(--text);
        }
        body::before { content:''; position:fixed; inset:0; background:rgba(3,12,6,0.76); z-index:0; }

        nav {
            position:sticky; top:0; z-index:100;
            background:rgba(4,14,8,0.94); backdrop-filter:blur(16px);
            border-bottom:1px solid var(--border); height:68px;
            padding:0 40px; display:flex; align-items:center; justify-content:space-between;
        }
        nav::after { content:''; position:absolute; bottom:0; left:0; right:0; height:1px;
            background:linear-gradient(90deg,transparent,rgba(201,168,76,0.6),transparent); }
        .nav-brand {
            display:flex; align-items:center; gap:12px;
            font-family:'Cinzel',serif; font-size:1.15rem;
            color:var(--gold-light); letter-spacing:3.5px; text-decoration:none;
        }
        .nav-ring {
            width:40px; height:40px; border:1.5px solid rgba(201,168,76,0.5);
            border-radius:50%; display:flex; align-items:center; justify-content:center;
            font-size:16px;
        }
        .back { font-family:'Cinzel',serif; font-size:0.6rem; color:var(--muted); text-decoration:none; letter-spacing:2px; transition:color 0.2s; }
        .back:hover { color:var(--gold); }

        main {
            position:relative; z-index:1;
            max-width:700px; margin:0 auto; padding:50px 32px;
        }

        /* Page header */
        .pg-head { text-align:center; margin-bottom:40px; animation:fadeUp 0.6s ease both; }
        @keyframes fadeUp { from{opacity:0;transform:translateY(22px)} to{opacity:1;transform:translateY(0)} }
        .pg-deco { display:flex; align-items:center; gap:14px; margin-bottom:12px; }
        .pg-deco span { flex:1; height:1px; background:linear-gradient(90deg,transparent,rgba(201,168,76,0.5),transparent); }
        .pg-deco em { color:var(--gold); font-style:normal; font-size:12px; }
        .pg-title { font-family:'Cinzel',serif; font-size:1.5rem; font-weight:600; color:var(--gold-light); letter-spacing:3px; margin-bottom:6px; }
        .pg-sub { color:var(--muted); font-style:italic; }

        /* Panel */
        .panel {
            background:linear-gradient(160deg,rgba(10,28,14,0.97),rgba(5,16,8,0.99));
            border:1px solid var(--border); padding:36px 42px; position:relative;
            margin-bottom:22px;
            box-shadow:0 18px 56px rgba(0,0,0,0.6), inset 0 1px 0 rgba(201,168,76,0.1);
            animation:fadeUp 0.6s ease both;
        }
        .panel:nth-child(1){ animation-delay:0.1s }
        .panel:nth-child(2){ animation-delay:0.2s }
        .panel::before { content:''; position:absolute; inset:5px; border:1px solid rgba(201,168,76,0.07); pointer-events:none; }
        .pc { position:absolute; color:var(--gold); font-size:11px; opacity:0.45; }
        .pc.tl{top:9px;left:12px} .pc.tr{top:9px;right:12px}
        .pc.bl{bottom:9px;left:12px} .pc.br{bottom:9px;right:12px}
        .panel-title {
            font-family:'Cinzel',serif; font-size:0.6rem; color:var(--gold);
            letter-spacing:3px; text-transform:uppercase;
            margin-bottom:22px; padding-bottom:13px;
            border-bottom:1px solid; border-image:linear-gradient(90deg,rgba(201,168,76,0.4),transparent) 1;
        }

        /* Form */
        .field { margin-bottom:22px; }
        label { display:block; font-family:'Cinzel',serif; font-size:0.58rem; color:var(--gold); letter-spacing:2.5px; text-transform:uppercase; margin-bottom:9px; }
        input[type="text"], input[type="number"] {
            width:100%; padding:13px 18px;
            background:rgba(255,255,255,0.03); border:1px solid rgba(201,168,76,0.22);
            color:var(--text); font-family:'Cormorant Garamond',serif; font-size:1.05rem;
            outline:none; transition:all 0.25s;
        }
        input:focus { border-color:rgba(201,168,76,0.7); background:rgba(201,168,76,0.045); box-shadow:0 0 0 4px rgba(201,168,76,0.08); }
        input::placeholder { color:rgba(245,236,215,0.2); font-style:italic; }
        .row { display:grid; grid-template-columns:1fr 1fr; gap:18px; }

        /* ── SCANNER ── */
        .scan-desc { color:var(--muted); font-style:italic; font-size:0.95rem; margin-bottom:18px; line-height:1.6; }

        .btn-scan {
            display:inline-flex; align-items:center; gap:8px;
            padding:11px 24px;
            font-family:'Cinzel',serif; font-size:0.6rem; letter-spacing:2px;
            background:rgba(201,168,76,0.07); border:1px solid rgba(201,168,76,0.35); color:var(--gold);
            cursor:pointer; transition:all 0.2s;
        }
        .btn-scan:hover { background:rgba(201,168,76,0.16); border-color:var(--gold); transform:translateY(-1px); }
        .btn-scan.active { background:rgba(217,106,58,0.1); border-color:rgba(217,106,58,0.5); color:var(--danger); }

        #reader {
            width:100%; margin:16px 0 0; border:1px solid rgba(201,168,76,0.3);
            background:#000; display:none;
            position:relative; overflow:hidden;
        }
        /* Override html5-qrcode default styles to match theme */
        #reader * { font-family:'Cinzel',serif !important; color:var(--gold) !important; }
        #reader video { width:100% !important; }
        #reader img[alt="Info icon"]  { display:none !important; }
        #reader__dashboard_section_csr span { color:var(--gold) !important; font-size:0.7rem !important; }

        .scan-result {
            margin-top:14px; padding:12px 18px; display:none;
            background:rgba(93,175,120,0.09); border:1px solid rgba(93,175,120,0.35);
            color:var(--success); font-size:0.95rem;
            animation:fadeUp 0.4s ease both;
        }
        .scan-error {
            margin-top:14px; padding:12px 18px; display:none;
            background:rgba(217,106,58,0.09); border:1px solid rgba(217,106,58,0.35);
            color:var(--danger); font-size:0.95rem;
        }

        /* Actions */
        .form-actions { display:flex; gap:14px; margin-top:8px; }
        .btn-submit {
            flex:1; padding:15px;
            background:linear-gradient(135deg,#7A5C10,var(--gold),var(--gold-light),var(--gold),#7A5C10);
            border:none; color:#1C0F00;
            font-family:'Cinzel',serif; font-size:0.7rem; font-weight:600; letter-spacing:3px;
            cursor:pointer; position:relative; overflow:hidden;
            box-shadow:0 4px 24px rgba(201,168,76,0.35); transition:all 0.3s;
        }
        .btn-submit::before {
            content:''; position:absolute; top:0; left:-120%; width:80%; height:100%;
            background:linear-gradient(90deg,transparent,rgba(255,255,255,0.25),transparent);
            transform:skewX(-20deg); animation:shimmer 3s ease-in-out infinite;
        }
        @keyframes shimmer { 0%{left:-120%} 60%{left:140%} 100%{left:140%} }
        .btn-submit:hover { transform:translateY(-2px); box-shadow:0 8px 34px rgba(201,168,76,0.55); }
        .btn-cancel {
            padding:15px 24px; background:transparent;
            border:1px solid rgba(201,168,76,0.25); color:var(--muted);
            font-family:'Cinzel',serif; font-size:0.65rem; letter-spacing:2px;
            text-decoration:none; display:inline-flex; align-items:center; transition:all 0.2s;
        }
        .btn-cancel:hover { border-color:var(--gold); color:var(--gold); }
    </style>
</head>
<body>
<nav>
    <a href="<%=request.getContextPath()%>/viewMedicines" class="nav-brand">
        <div class="nav-ring">⚕</div>PHARMACARE
    </a>
    <a href="<%=request.getContextPath()%>/viewMedicines" class="back">← Return to Dashboard</a>
</nav>

<main>
    <div class="pg-head">
        <div class="pg-deco"><span></span><em>✦ ✦ ✦</em><span></span></div>
        <div class="pg-title">ADD MEDICINE</div>
        <div class="pg-sub">Register a new item to the inventory</div>
    </div>

    <!-- BARCODE SCANNER PANEL -->
    <div class="panel">
        <span class="pc tl">◆</span><span class="pc tr">◆</span>
        <span class="pc bl">◆</span><span class="pc br">◆</span>
        <div class="panel-title">📷 &nbsp; Barcode Scanner</div>
        <p class="scan-desc">
            Point your camera at any barcode or QR code. The medicine name field will be filled automatically when a code is detected.
        </p>
        <button class="btn-scan" id="scanBtn" onclick="toggleScanner()">
            📷 &nbsp; Start Camera Scanner
        </button>
        <div id="reader"></div>
        <div class="scan-result" id="scanResult"></div>
        <div class="scan-error"  id="scanError"></div>
    </div>

    <!-- MEDICINE FORM PANEL -->
    <div class="panel">
        <span class="pc tl">◆</span><span class="pc tr">◆</span>
        <span class="pc bl">◆</span><span class="pc br">◆</span>
        <div class="panel-title">✦ &nbsp; Medicine Details</div>
        <form action="<%=request.getContextPath()%>/addMedicine" method="post">
            <div class="field">
                <label for="name">Medicine Name</label>
                <input type="text" id="name" name="name" placeholder="e.g. Paracetamol 500mg" required>
            </div>
            <div class="row">
                <div class="field">
                    <label for="quantity">Quantity (units)</label>
                    <input type="number" id="quantity" name="quantity" placeholder="e.g. 100" min="0" required>
                </div>
                <div class="field">
                    <label for="price">Price (₹)</label>
                    <input type="number" id="price" name="price" placeholder="e.g. 25.50" step="0.01" min="0" required>
                </div>
            </div>
            <div class="form-actions">
                <button type="submit" class="btn-submit">✦ &nbsp; Add to Inventory &nbsp; ✦</button>
                <a href="<%=request.getContextPath()%>/viewMedicines" class="btn-cancel">Cancel</a>
            </div>
        </form>
    </div>
</main>

<script>
let scanner = null;
let scanning = false;

function toggleScanner() {
    const btn    = document.getElementById('scanBtn');
    const reader = document.getElementById('reader');
    const errBox = document.getElementById('scanError');
    errBox.style.display = 'none';

    if (!scanning) {
        // ── START ──
        reader.style.display = 'block';
        btn.innerHTML = '⏹ &nbsp; Stop Scanner';
        btn.classList.add('active');
        scanning = true;

        scanner = new Html5Qrcode("reader");

        // Try back camera first, fallback to any camera
        Html5Qrcode.getCameras().then(cameras => {
            if (!cameras || cameras.length === 0) {
                showScanError("No camera found on this device.");
                stopScanner(); return;
            }
            // Prefer back/environment camera
            const cam = cameras.find(c =>
                c.label.toLowerCase().includes('back') ||
                c.label.toLowerCase().includes('rear') ||
                c.label.toLowerCase().includes('environment')
            ) || cameras[cameras.length - 1];

            scanner.start(
                cam.id,
                {
                    fps: 15,
                    qrbox: { width: 280, height: 140 },
                    aspectRatio: 1.8
                },
                (decodedText) => {
                    // ── SUCCESS ──
                    document.getElementById('name').value = decodedText;
                    const res = document.getElementById('scanResult');
                    res.style.display = 'block';
                    res.innerHTML = '✦ &nbsp; Code detected: <strong>' + decodedText + '</strong> — name field filled!';
                    stopScanner();
                },
                (err) => {
                    // scan attempt errors are normal while scanning — ignore silently
                }
            ).catch(err => {
                showScanError("Camera access denied. Please allow camera permissions and try again.");
                stopScanner();
            });

        }).catch(() => {
            showScanError("Could not access camera. Check browser permissions.");
            stopScanner();
        });

    } else {
        stopScanner();
    }
}

function stopScanner() {
    const btn    = document.getElementById('scanBtn');
    const reader = document.getElementById('reader');
    if (scanner) {
        scanner.stop().catch(() => {});
        scanner.clear();
        scanner = null;
    }
    reader.style.display = 'none';
    btn.innerHTML = '📷 &nbsp; Start Camera Scanner';
    btn.classList.remove('active');
    scanning = false;
}

function showScanError(msg) {
    const e = document.getElementById('scanError');
    e.style.display = 'block';
    e.innerHTML = '⚠ &nbsp;' + msg;
}
</script>
</body>
</html>
