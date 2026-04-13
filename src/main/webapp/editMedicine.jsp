<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.pharmacy.dao.DBConnection" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String loggedUser = (String) userSession.getAttribute("user");
    String id = request.getParameter("id");
    String medName = "", medQty = "", medPrice = "";
    boolean found = false;
    if (id != null && !id.isEmpty()) {
        try {
            Connection conn = DBConnection.connect();
            PreparedStatement ps = conn.prepareStatement("SELECT * FROM medicine WHERE id=?");
            ps.setInt(1, Integer.parseInt(id));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                medName  = rs.getString("name");
                medQty   = rs.getString("quantity");
                medPrice = rs.getString("price");
                found    = true;
            }
            conn.close();
        } catch (Exception e) { e.printStackTrace(); }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RxCare — Edit Medicine</title>
    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@300;400;500;600;700&family=JetBrains+Mono:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --bg: #060A0D; --surface: #0C1218; --surface2: #111C26;
            --green: #00E5A0; --green-dim: #00B87A; --green-glow: rgba(0,229,160,0.14); --green-glow2: rgba(0,229,160,0.06);
            --text: #C8E6D8; --text-dim: #7AA090; --muted: #2E4A3A;
            --danger: #FF4757; --warning: #FFB020;
            --border: rgba(0,229,160,0.1); --border2: rgba(0,229,160,0.05);
            --sw: 240px;
        }
        body { font-family: 'Rajdhani', sans-serif; background: var(--bg); color: var(--text); display: flex; min-height: 100vh; }
        body::before { content: ''; position: fixed; inset: 0; background-image: radial-gradient(circle, rgba(0,229,160,0.06) 1px, transparent 1px); background-size: 28px 28px; pointer-events: none; z-index: 0; }

        /* ── Sidebar ── */
        .sidebar { width: var(--sw); min-height: 100vh; background: var(--surface); border-right: 1px solid var(--border); display: flex; flex-direction: column; position: fixed; top: 0; left: 0; bottom: 0; z-index: 50; }
        .sb-brand { padding: 28px 24px 24px; border-bottom: 1px solid var(--border); display: flex; align-items: center; gap: 12px; }
        .sb-cross { width: 36px; height: 36px; flex-shrink: 0; filter: drop-shadow(0 0 8px rgba(0,229,160,0.5)); }
        .sb-name { font-size: 1.4rem; font-weight: 700; letter-spacing: 2px; color: #fff; line-height: 1; }
        .sb-name span { color: var(--green); }
        .sb-subtitle { font-family: 'JetBrains Mono', monospace; font-size: 0.55rem; color: var(--text-dim); letter-spacing: 1.5px; margin-top: 2px; }
        .sb-section { padding: 20px 16px 8px; font-family: 'JetBrains Mono', monospace; font-size: 0.58rem; color: var(--muted); letter-spacing: 2.5px; }
        .sb-nav { flex: 1; padding: 8px 12px; }
        .nav-item { display: flex; align-items: center; gap: 12px; padding: 11px 14px; color: var(--text-dim); text-decoration: none; font-size: 0.95rem; font-weight: 500; border-left: 3px solid transparent; margin-bottom: 2px; transition: all 0.2s; }
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
        .main { margin-left: var(--sw); flex: 1; position: relative; z-index: 1; display: flex; flex-direction: column; }
        .topbar { padding: 20px 36px; border-bottom: 1px solid var(--border); display: flex; align-items: center; justify-content: space-between; background: rgba(6,10,13,0.85); backdrop-filter: blur(10px); position: sticky; top: 0; z-index: 40; }
        .topbar-title { font-size: 1.4rem; font-weight: 700; color: #fff; letter-spacing: 1px; }
        .topbar-title span { color: var(--green); }
        .breadcrumb { font-family: 'JetBrains Mono', monospace; font-size: 0.65rem; color: var(--text-dim); margin-top: 3px; }
        .back-link { display: inline-flex; align-items: center; gap: 8px; color: var(--text-dim); text-decoration: none; font-size: 0.88rem; font-weight: 500; transition: color 0.2s; }
        .back-link:hover { color: var(--green); }

        .content { padding: 40px 36px; flex: 1; display: flex; justify-content: center; }

        .form-card {
            width: 100%; max-width: 620px;
            background: var(--surface); border: 1px solid var(--border);
            position: relative; overflow: hidden;
            animation: cardIn 0.55s cubic-bezier(.16,1,.3,1) both;
        }
        @keyframes cardIn { from{opacity:0;transform:translateY(20px)} to{opacity:1;transform:translateY(0)} }
        .form-card::before { content:''; position:absolute; top:0; left:0; right:0; height:2px; background:var(--green); }

        .card-head {
            padding: 22px 28px;
            border-bottom: 1px solid var(--border);
            display: flex; align-items: center; justify-content: space-between;
        }
        .card-head-left { display: flex; align-items: center; gap: 12px; }
        .card-head-icon { font-size: 20px; }
        .card-title { font-size: 0.95rem; font-weight: 700; letter-spacing: 1.5px; text-transform: uppercase; }
        .card-sub { font-family: 'JetBrains Mono', monospace; font-size: 0.6rem; color: var(--text-dim); margin-top: 2px; }

        .id-badge {
            font-family: 'JetBrains Mono', monospace; font-size: 0.68rem;
            color: var(--green-dim); background: var(--green-glow2);
            border: 1px solid rgba(0,229,160,0.15);
            padding: 4px 12px; letter-spacing: 1px;
        }

        .card-body { padding: 30px 28px; }

        /* Change indicators strip */
        .orig-values {
            display: grid; grid-template-columns: repeat(3,1fr); gap: 12px;
            margin-bottom: 28px; padding: 16px 18px;
            background: rgba(0,229,160,0.03);
            border: 1px solid var(--border2);
            border-left: 3px solid rgba(0,229,160,0.3);
        }
        .orig-item { font-family: 'JetBrains Mono', monospace; }
        .orig-label { font-size: 0.55rem; color: var(--muted); letter-spacing: 2px; text-transform: uppercase; margin-bottom: 4px; }
        .orig-val { font-size: 0.82rem; color: var(--text-dim); }

        .field { margin-bottom: 20px; }
        .field label { display: flex; align-items: center; gap: 8px; font-family: 'JetBrains Mono', monospace; font-size: 0.62rem; color: var(--green-dim); letter-spacing: 2px; text-transform: uppercase; margin-bottom: 8px; }
        .field label::before { content:''; width:4px; height:4px; background:var(--green); border-radius:50%; flex-shrink:0; }
        input[type="text"], input[type="number"] {
            width: 100%; padding: 13px 16px;
            background: var(--surface2); border: 1px solid var(--border);
            color: var(--text); font-family: 'Rajdhani', sans-serif;
            font-size: 1rem; font-weight: 500; letter-spacing: 0.5px;
            outline: none; transition: all 0.25s;
        }
        input:focus { border-color: var(--green); background: rgba(0,229,160,0.04); box-shadow: 0 0 0 3px rgba(0,229,160,0.07); }
        .row { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }

        .form-actions { display: flex; gap: 12px; margin-top: 8px; }
        .btn-submit {
            flex: 1; padding: 14px;
            background: var(--green); border: none;
            color: #040A06; font-family: 'Rajdhani', sans-serif;
            font-size: 0.95rem; font-weight: 700; letter-spacing: 2px;
            cursor: pointer; transition: all 0.25s;
            box-shadow: 0 4px 20px rgba(0,229,160,0.28);
            position: relative; overflow: hidden;
        }
        .btn-submit::before { content:''; position:absolute; top:0; left:-100%; width:100%; height:100%; background:linear-gradient(90deg,transparent,rgba(255,255,255,0.15),transparent); transition:left 0.4s; }
        .btn-submit:hover::before { left: 100%; }
        .btn-submit:hover { background: #00F0AA; box-shadow: 0 6px 28px rgba(0,229,160,0.45); transform: translateY(-1px); }
        .btn-cancel { padding: 14px 24px; background: transparent; border: 1px solid var(--border); color: var(--text-dim); font-family: 'Rajdhani', sans-serif; font-size: 0.88rem; font-weight: 500; letter-spacing: 1px; text-decoration: none; display: inline-flex; align-items: center; transition: all 0.2s; cursor: pointer; }
        .btn-cancel:hover { border-color: var(--text-dim); color: var(--text); }

        /* Error state */
        .err-card { background: var(--surface); border: 1px solid rgba(255,71,87,0.25); width: 100%; max-width: 500px; padding: 50px 40px; text-align: center; }
        .err-card::before { content:''; display:block; height:2px; background:var(--danger); margin:-50px -40px 40px; }
        .err-icon { font-size: 48px; margin-bottom: 16px; opacity: 0.7; }
        .err-title { font-size: 1.1rem; font-weight: 700; color: var(--danger); letter-spacing: 1px; margin-bottom: 10px; }
        .err-text { font-family: 'JetBrains Mono', monospace; font-size: 0.7rem; color: var(--text-dim); margin-bottom: 24px; line-height: 1.7; letter-spacing: 0.5px; }
        .err-link { display: inline-flex; align-items: center; gap: 8px; padding: 11px 24px; background: var(--green); color: #040A06; text-decoration: none; font-size: 0.88rem; font-weight: 700; letter-spacing: 1.5px; transition: all 0.2s; }
        .err-link:hover { background: #00F0AA; }
    </style>
</head>
<body>

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
        <a href="<%=request.getContextPath()%>/logout" class="btn-logout" onclick="return confirm('End session?')">⏻ &nbsp; Logout</a>
    </div>
</aside>

<!-- MAIN -->
<div class="main">
    <div class="topbar">
        <div>
            <div class="topbar-title">Edit <span>Medicine</span></div>
            <div class="breadcrumb">// INVENTORY → EDIT RECORD #<%= id != null ? id : "?" %></div>
        </div>
        <a href="<%=request.getContextPath()%>/viewMedicines" class="back-link">← Back to Dashboard</a>
    </div>

    <div class="content">

        <% if (!found) { %>
        <div class="err-card">
            <div class="err-icon">⚠️</div>
            <div class="err-title">Record Not Found</div>
            <div class="err-text">Medicine ID #<%= id %> could not be located.<br>The record may have been deleted or the ID is invalid.</div>
            <a href="<%=request.getContextPath()%>/viewMedicines" class="err-link">← Return to Dashboard</a>
        </div>

        <% } else { %>
        <div class="form-card">
            <div class="card-head">
                <div class="card-head-left">
                    <span class="card-head-icon">✏️</span>
                    <div>
                        <div class="card-title">Edit Record</div>
                        <div class="card-sub">// MODIFYING INVENTORY ENTRY</div>
                    </div>
                </div>
                <div class="id-badge">ID #<%= id %></div>
            </div>

            <div class="card-body">
                <!-- Current values reference -->
                <div class="orig-values">
                    <div class="orig-item">
                        <div class="orig-label">Current Name</div>
                        <div class="orig-val"><%= medName %></div>
                    </div>
                    <div class="orig-item">
                        <div class="orig-label">Current Qty</div>
                        <div class="orig-val"><%= medQty %> units</div>
                    </div>
                    <div class="orig-item">
                        <div class="orig-label">Current Price</div>
                        <div class="orig-val">₹<%= medPrice %></div>
                    </div>
                </div>

                <form action="<%=request.getContextPath()%>/updateMedicine" method="post">
                    <input type="hidden" name="id" value="<%= id %>">
                    <div class="field">
                        <label for="name">Medicine Name</label>
                        <input type="text" id="name" name="name" value="<%= medName %>" required>
                    </div>
                    <div class="row">
                        <div class="field">
                            <label for="quantity">Quantity (units)</label>
                            <input type="number" id="quantity" name="quantity" value="<%= medQty %>" min="0" required>
                        </div>
                        <div class="field">
                            <label for="price">Unit Price (₹)</label>
                            <input type="number" id="price" name="price" value="<%= medPrice %>" step="0.01" min="0" required>
                        </div>
                    </div>
                    <div class="form-actions">
                        <button type="submit" class="btn-submit">✔ SAVE CHANGES</button>
                        <a href="<%=request.getContextPath()%>/viewMedicines" class="btn-cancel">Cancel</a>
                    </div>
                </form>
            </div>
        </div>
        <% } %>

    </div>
</div>
</body>
</html>
