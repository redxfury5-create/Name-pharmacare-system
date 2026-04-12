<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.pharmacy.dao.DBConnection" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
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
    <title>PharmaCare — Edit Medicine</title>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,400;0,600;1,400&family=Cinzel:wght@400;600&display=swap" rel="stylesheet">
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
            background:#071410 url('assets/images/bg-mandala.jpg') center/cover fixed; color:var(--text);
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
            border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:16px;
        }
        .back { font-family:'Cinzel',serif; font-size:0.6rem; color:var(--muted); text-decoration:none; letter-spacing:2px; transition:color 0.2s; }
        .back:hover { color:var(--gold); }

        main {
            position:relative; z-index:1; max-width:660px; margin:0 auto; padding:50px 32px;
            animation:fadeUp 0.65s cubic-bezier(.16,1,.3,1) both;
        }
        @keyframes fadeUp { from{opacity:0;transform:translateY(28px)} to{opacity:1;transform:translateY(0)} }

        .pg-head { text-align:center; margin-bottom:40px; }
        .pg-deco { display:flex; align-items:center; gap:14px; margin-bottom:12px; }
        .pg-deco span { flex:1; height:1px; background:linear-gradient(90deg,transparent,rgba(201,168,76,0.5),transparent); }
        .pg-deco em { color:var(--gold); font-style:normal; font-size:12px; }
        .pg-title { font-family:'Cinzel',serif; font-size:1.5rem; font-weight:600; color:var(--gold-light); letter-spacing:3px; margin-bottom:6px; }
        .pg-sub   { color:var(--muted); font-style:italic; }
        .id-badge {
            display:inline-block; margin-top:10px;
            background:rgba(201,168,76,0.08); border:1px solid rgba(201,168,76,0.25);
            color:var(--gold); padding:3px 16px;
            font-family:'Cinzel',serif; font-size:0.6rem; letter-spacing:2px;
        }

        .panel {
            background:linear-gradient(160deg,rgba(10,28,14,0.97),rgba(5,16,8,0.99));
            border:1px solid var(--border); padding:42px 46px; position:relative;
            box-shadow:0 22px 65px rgba(0,0,0,0.65), inset 0 1px 0 rgba(201,168,76,0.1);
        }
        .panel::before { content:''; position:absolute; inset:6px; border:1px solid rgba(201,168,76,0.07); pointer-events:none; }
        /* animated pulse border */
        .panel::after {
            content:''; position:absolute; inset:-1px;
            border:1px solid rgba(201,168,76,0.0);
            animation:glow 4s ease-in-out infinite; pointer-events:none;
        }
        @keyframes glow {
            0%,100%{border-color:rgba(201,168,76,0.0);box-shadow:0 0 0 rgba(201,168,76,0)}
            50%    {border-color:rgba(201,168,76,0.35);box-shadow:0 0 20px rgba(201,168,76,0.1)}
        }
        .pc { position:absolute; color:var(--gold); font-size:11px; opacity:0.45; }
        .pc.tl{top:9px;left:12px} .pc.tr{top:9px;right:12px}
        .pc.bl{bottom:9px;left:12px} .pc.br{bottom:9px;right:12px}
        .panel-title {
            font-family:'Cinzel',serif; font-size:0.6rem; color:var(--gold);
            letter-spacing:3px; text-transform:uppercase; margin-bottom:28px; padding-bottom:14px;
            border-bottom:1px solid; border-image:linear-gradient(90deg,rgba(201,168,76,0.4),transparent) 1;
        }

        .field { margin-bottom:24px; }
        label { display:block; font-family:'Cinzel',serif; font-size:0.58rem; color:var(--gold); letter-spacing:2.5px; text-transform:uppercase; margin-bottom:9px; }
        input[type="text"], input[type="number"] {
            width:100%; padding:13px 18px;
            background:rgba(255,255,255,0.03); border:1px solid rgba(201,168,76,0.22);
            color:var(--text); font-family:'Cormorant Garamond',serif; font-size:1.05rem;
            outline:none; transition:all 0.25s;
        }
        input:focus { border-color:rgba(201,168,76,0.7); background:rgba(201,168,76,0.045); box-shadow:0 0 0 4px rgba(201,168,76,0.08); }
        /* Highlight changed fields */
        input:not(:placeholder-shown) { border-color:rgba(201,168,76,0.35); }
        .row { display:grid; grid-template-columns:1fr 1fr; gap:18px; }

        .form-actions { display:flex; gap:14px; margin-top:10px; }
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
            transform:skewX(-20deg); animation:shimmer 3.5s ease-in-out infinite;
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

        /* Error state */
        .err-panel {
            background:linear-gradient(160deg,rgba(10,28,14,0.97),rgba(5,16,8,0.99));
            border:1px solid rgba(217,106,58,0.4); padding:56px 40px;
            text-align:center;
            box-shadow:0 18px 55px rgba(0,0,0,0.6);
        }
        .err-icon { font-size:48px; margin-bottom:14px; opacity:0.65; }
        .err-text { color:var(--muted); font-style:italic; font-size:1rem; margin-bottom:24px; line-height:1.7; }
        .err-link { font-family:'Cinzel',serif; font-size:0.62rem; color:var(--gold); text-decoration:none; letter-spacing:2px; }
        .err-link:hover { text-decoration:underline; }
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
        <div class="pg-title">EDIT MEDICINE</div>
        <div class="pg-sub">Update the details of this inventory record</div>
        <% if (found) { %><div class="id-badge">ID #<%= id %> — <%= medName %></div><% } %>
    </div>

    <% if (!found) { %>
    <div class="err-panel">
        <div class="err-icon">⚠</div>
        <div class="err-text">This medicine record could not be found.<br>It may have been removed or the ID is invalid.</div>
        <a href="<%=request.getContextPath()%>/viewMedicines" class="err-link">← Return to Dashboard</a>
    </div>
    <% } else { %>
    <div class="panel">
        <span class="pc tl">◆</span><span class="pc tr">◆</span>
        <span class="pc bl">◆</span><span class="pc br">◆</span>
        <div class="panel-title">✦ &nbsp; Update Record</div>

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
                    <label for="price">Price (₹)</label>
                    <input type="number" id="price" name="price" value="<%= medPrice %>" step="0.01" min="0" required>
                </div>
            </div>
            <div class="form-actions">
                <button type="submit" class="btn-submit">✦ &nbsp; Save Changes &nbsp; ✦</button>
                <a href="<%=request.getContextPath()%>/viewMedicines" class="btn-cancel">Cancel</a>
            </div>
        </form>
    </div>
    <% } %>
</main>
</body>
</html>
