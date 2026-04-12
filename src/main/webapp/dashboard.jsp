<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%
    // Session guard — redirect to login if not authenticated
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
    <title>PharmaCare — Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,400;0,600;1,400&family=Cinzel:wght@400;600&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --gold: #C9A84C; --gold-light: #F0D080; --gold-pale: #FAF0C8;
            --text: #F5ECD7; --muted: #B8A070;
            --danger: #D96A3A; --success: #5DAF78;
            --border: rgba(201,168,76,0.28);
            --surface: rgba(10,28,14,0.97);
        }
        body {
            min-height: 100vh; font-family: 'Cormorant Garamond', serif;
            background: #071410;
            background-image: url('assets/images/bg-mandala.jpg');
            background-size: cover; background-position: center; background-attachment: fixed;
            color: var(--text);
        }
        body::before { content:''; position:fixed; inset:0; background:rgba(3,12,6,0.76); z-index:0; }

        /* NAV */
        nav {
            position: sticky; top:0; z-index:100;
            background: rgba(4,14,8,0.94); backdrop-filter: blur(16px);
            border-bottom: 1px solid var(--border); height:68px;
            padding: 0 40px;
            display: flex; align-items:center; justify-content:space-between;
            animation: navDrop 0.6s ease both;
        }
        @keyframes navDrop { from{opacity:0;transform:translateY(-20px)} to{opacity:1;transform:translateY(0)} }
        nav::after {
            content:''; position:absolute; bottom:0; left:0; right:0; height:1px;
            background: linear-gradient(90deg, transparent, rgba(201,168,76,0.6), transparent);
        }
        .nav-brand {
            display:flex; align-items:center; gap:12px;
            font-family:'Cinzel',serif; font-size:1.15rem;
            color:var(--gold-light); letter-spacing:3.5px; text-decoration:none;
        }
        .nav-ring {
            width:40px; height:40px; border:1.5px solid rgba(201,168,76,0.5);
            border-radius:50%; display:flex; align-items:center; justify-content:center;
            font-size:16px; box-shadow:0 0 14px rgba(201,168,76,0.2);
            transition: box-shadow 0.3s;
        }
        .nav-ring:hover { box-shadow:0 0 24px rgba(201,168,76,0.45); }

        .nav-right { display:flex; align-items:center; gap:14px; }
        .nav-user {
            font-family:'Cinzel',serif; font-size:0.6rem; color:var(--muted);
            letter-spacing:2px; padding: 6px 14px;
            border: 1px solid rgba(201,168,76,0.15);
        }

        .btn {
            display:inline-flex; align-items:center; gap:7px;
            padding:9px 22px; cursor:pointer; border:none;
            font-family:'Cinzel',serif; font-size:0.63rem;
            font-weight:600; letter-spacing:2px; text-transform:uppercase;
            text-decoration:none; position:relative; overflow:hidden;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .btn-gold {
            background: linear-gradient(135deg,#7A5C10,var(--gold),var(--gold-light),var(--gold),#7A5C10);
            color:#1C0F00; box-shadow:0 3px 18px rgba(201,168,76,0.35);
        }
        .btn-gold::before {
            content:''; position:absolute; top:0; left:-120%; width:80%; height:100%;
            background: linear-gradient(90deg,transparent,rgba(255,255,255,0.25),transparent);
            transform:skewX(-20deg); animation:shimmer 3.5s ease-in-out infinite;
        }
        @keyframes shimmer { 0%{left:-120%} 60%{left:140%} 100%{left:140%} }
        .btn-gold:hover { transform:translateY(-2px); box-shadow:0 6px 28px rgba(201,168,76,0.55); }
        .btn-outline {
            background:transparent; border:1px solid rgba(201,168,76,0.3); color:var(--muted);
        }
        .btn-outline:hover { border-color:var(--gold); color:var(--gold); }

        /* MAIN */
        main { position:relative; z-index:1; max-width:1300px; margin:0 auto; padding:44px 40px; }

        /* Page heading */
        .pg-head {
            display:flex; align-items:flex-end; justify-content:space-between;
            flex-wrap:wrap; gap:16px; margin-bottom:36px;
            padding-bottom:18px; border-bottom:1px solid;
            border-image: linear-gradient(90deg, rgba(201,168,76,0.5), transparent) 1;
            animation: fadeUp 0.6s 0.1s ease both;
        }
        @keyframes fadeUp { from{opacity:0;transform:translateY(20px)} to{opacity:1;transform:translateY(0)} }

        .pg-title { font-family:'Cinzel',serif; font-size:1.55rem; font-weight:600; color:var(--gold-light); letter-spacing:2px; }
        .pg-sub   { color:var(--muted); font-style:italic; font-size:0.95rem; margin-top:4px; }

        /* STATS */
        .stats { display:grid; grid-template-columns:repeat(auto-fit,minmax(210px,1fr)); gap:20px; margin-bottom:36px; }

        .stat {
            background: var(--surface);
            border: 1px solid var(--border); padding: 26px 30px;
            position:relative; overflow:hidden;
            box-shadow: 0 10px 40px rgba(0,0,0,0.5), inset 0 1px 0 rgba(201,168,76,0.1);
            animation: fadeUp 0.6s ease both;
        }
        .stat:nth-child(1){animation-delay:0.15s}
        .stat:nth-child(2){animation-delay:0.25s}
        .stat:nth-child(3){animation-delay:0.35s}
        .stat::before { content:''; position:absolute; inset:5px; border:1px solid rgba(201,168,76,0.07); pointer-events:none; }
        .stat-glow { position:absolute; top:-40px; right:-40px; width:130px; height:130px; background:radial-gradient(circle,rgba(201,168,76,0.08) 0%,transparent 70%); }
        .sc { position:absolute; color:var(--gold); font-size:10px; opacity:0.45; }
        .sc.tl{top:8px;left:11px} .sc.br{bottom:8px;right:11px}
        .stat-label { font-family:'Cinzel',serif; font-size:0.58rem; color:var(--muted); letter-spacing:2.5px; text-transform:uppercase; margin-bottom:12px; }
        .stat-val {
            font-family:'Cinzel',serif; font-size:2.6rem; line-height:1;
            color:var(--gold-light); text-shadow:0 0 30px rgba(201,168,76,0.3);
            animation: countUp 0.8s ease both;
        }
        @keyframes countUp { from{opacity:0;transform:scale(0.7)} to{opacity:1;transform:scale(1)} }
        .stat-val.d { color:var(--danger); text-shadow:0 0 20px rgba(217,106,58,0.3); }
        .stat-val.s { color:var(--success); text-shadow:0 0 20px rgba(93,175,120,0.3); }

        /* SEARCH */
        .controls { display:flex; gap:14px; margin-bottom:22px; animation: fadeUp 0.6s 0.4s ease both; }
        .srch { flex:1; position:relative; }
        .srch input {
            width:100%; padding:12px 18px 12px 46px;
            background: rgba(8,22,12,0.9); border:1px solid var(--border);
            color:var(--text); font-family:'Cormorant Garamond',serif; font-size:1rem;
            outline:none; transition:all 0.25s;
        }
        .srch input:focus { border-color:rgba(201,168,76,0.65); box-shadow:0 0 0 3px rgba(201,168,76,0.07); }
        .srch input::placeholder { color:rgba(184,160,112,0.4); font-style:italic; }
        .srch-ic { position:absolute; left:16px; top:50%; transform:translateY(-50%); color:var(--muted); font-size:14px; }

        /* TABLE */
        .tbl-wrap {
            background: var(--surface); border:1px solid var(--border);
            position:relative; overflow:hidden;
            box-shadow: 0 24px 70px rgba(0,0,0,0.65), inset 0 1px 0 rgba(201,168,76,0.1);
            animation: fadeUp 0.6s 0.45s ease both;
        }
        .tbl-wrap::before { content:''; position:absolute; inset:6px; border:1px solid rgba(201,168,76,0.07); pointer-events:none; z-index:1; }
        .tc { position:absolute; color:var(--gold); font-size:11px; opacity:0.45; z-index:2; }
        .tc.tl{top:9px;left:12px} .tc.tr{top:9px;right:12px}
        .tc.bl{bottom:9px;left:12px} .tc.br{bottom:9px;right:12px}

        table { width:100%; border-collapse:collapse; }
        thead tr { background:rgba(201,168,76,0.07); border-bottom:1px solid rgba(201,168,76,0.3); }
        th {
            padding:16px 24px; text-align:left;
            font-family:'Cinzel',serif; font-size:0.58rem;
            color:var(--gold); letter-spacing:2.5px; text-transform:uppercase;
        }
        tbody tr {
            border-bottom:1px solid rgba(201,168,76,0.06);
            transition: background 0.2s, transform 0.2s;
            animation: rowIn 0.5s ease both;
        }
        @keyframes rowIn { from{opacity:0;transform:translateX(-12px)} to{opacity:1;transform:translateX(0)} }
        tbody tr:last-child { border-bottom:none; }
        tbody tr:hover { background:rgba(201,168,76,0.045); }
        td { padding:15px 24px; font-size:1rem; }
        .td-id   { color:var(--muted); font-style:italic; font-size:0.88rem; }
        .td-name { font-weight:600; color:var(--gold-pale); }
        .badge {
            display:inline-flex; align-items:center; padding:3px 13px;
            font-family:'Cinzel',serif; font-size:0.58rem; letter-spacing:1.5px;
        }
        .badge-low { border:1px solid rgba(217,106,58,0.4); color:var(--danger); background:rgba(217,106,58,0.08); }
        .badge-ok  { border:1px solid rgba(93,175,120,0.4);  color:var(--success); background:rgba(93,175,120,0.08); }
        .acts { display:flex; gap:10px; }
        .act {
            padding:5px 16px; cursor:pointer; border:none; text-decoration:none;
            font-family:'Cinzel',serif; font-size:0.58rem; letter-spacing:1.5px;
            transition:all 0.2s;
        }
        .act-edit { border:1px solid rgba(201,168,76,0.3); color:var(--gold); background:rgba(201,168,76,0.05); }
        .act-edit:hover { background:rgba(201,168,76,0.18); border-color:var(--gold); transform:translateY(-1px); }
        .act-del  { border:1px solid rgba(217,106,58,0.3); color:var(--danger); background:rgba(217,106,58,0.05); }
        .act-del:hover  { background:rgba(217,106,58,0.18); transform:translateY(-1px); }

        .empty { text-align:center; padding:72px 20px; color:var(--muted); }
        .empty .ico { font-size:46px; margin-bottom:12px; opacity:0.55; }
        .empty p { font-style:italic; font-size:1rem; }

        /* Set stagger delays for rows */
        tbody tr:nth-child(1){animation-delay:0.5s}
        tbody tr:nth-child(2){animation-delay:0.56s}
        tbody tr:nth-child(3){animation-delay:0.62s}
        tbody tr:nth-child(4){animation-delay:0.68s}
        tbody tr:nth-child(5){animation-delay:0.74s}
        tbody tr:nth-child(6){animation-delay:0.80s}
        tbody tr:nth-child(7){animation-delay:0.86s}
        tbody tr:nth-child(n+8){animation-delay:0.90s}
    </style>
</head>
<body>

<%
    ArrayList<String[]> list = (ArrayList<String[]>) request.getAttribute("list");
    if (list == null) list = new ArrayList<>();
    int total = list.size(), lowStock = 0;
    for (String[] m : list) { try { if(Integer.parseInt(m[2])<10) lowStock++; } catch(Exception e){} }
%>

<nav>
    <a href="<%=request.getContextPath()%>/viewMedicines" class="nav-brand">
        <div class="nav-ring">⚕</div>
        PHARMACARE
    </a>
    <div class="nav-right">
        <div class="nav-user">✦ <%= loggedUser.toUpperCase() %></div>
        <a href="<%=request.getContextPath()%>/addMedicine.jsp" class="btn btn-gold">+ Add Medicine</a>
        <a href="<%=request.getContextPath()%>/logout" class="btn btn-outline"
           onclick="return confirm('Sign out of PharmaCare?')">Logout</a>
    </div>
</nav>

<main>
    <div class="pg-head">
        <div>
            <div class="pg-title">Medicine Inventory</div>
            <div class="pg-sub">Manage and track all pharmaceutical stock</div>
        </div>
    </div>

    <div class="stats">
        <div class="stat"><span class="sc tl">◆</span><span class="sc br">◆</span>
            <div class="stat-glow"></div>
            <div class="stat-label">Total Medicines</div>
            <div class="stat-val"><%= total %></div>
        </div>
        <div class="stat"><span class="sc tl">◆</span><span class="sc br">◆</span>
            <div class="stat-glow"></div>
            <div class="stat-label">Low Stock Items</div>
            <div class="stat-val d"><%= lowStock %></div>
        </div>
        <div class="stat"><span class="sc tl">◆</span><span class="sc br">◆</span>
            <div class="stat-glow"></div>
            <div class="stat-label">In Stock Items</div>
            <div class="stat-val s"><%= total - lowStock %></div>
        </div>
    </div>

    <div class="controls">
        <div class="srch">
            <span class="srch-ic">🔍</span>
            <input type="text" id="searchInput" placeholder="Search medicines by name…" oninput="filterTable()">
        </div>
    </div>

    <div class="tbl-wrap">
        <span class="tc tl">◆</span><span class="tc tr">◆</span>
        <span class="tc bl">◆</span><span class="tc br">◆</span>
        <table id="medTable">
            <thead>
                <tr>
                    <th>ID</th><th>Medicine Name</th><th>Quantity</th>
                    <th>Price (₹)</th><th>Status</th><th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <% if (list.isEmpty()) { %>
            <tr><td colspan="6"><div class="empty"><div class="ico">📦</div><p>No medicines yet. Add your first item.</p></div></td></tr>
            <% } else { for (String[] med : list) {
                int qty=0; try{qty=Integer.parseInt(med[2]);}catch(Exception e){}
                boolean isLow = qty < 10;
            %>
            <tr>
                <td class="td-id">#<%= med[0] %></td>
                <td class="td-name"><%= med[1] %></td>
                <td><%= med[2] %></td>
                <td>₹<%= med[3] %></td>
                <td>
                    <% if(isLow){ %><span class="badge badge-low">⚠ Low Stock</span>
                    <% }else{    %><span class="badge badge-ok">✦ In Stock</span><% } %>
                </td>
                <td>
                    <div class="acts">
                        <a href="<%=request.getContextPath()%>/editMedicine.jsp?id=<%= med[0] %>" class="act act-edit">Edit</a>
                        <a href="<%=request.getContextPath()%>/deleteMedicine?id=<%= med[0] %>"
                           class="act act-del"
                           onclick="return confirm('Remove <%= med[1] %> from inventory?')">Delete</a>
                    </div>
                </td>
            </tr>
            <% } } %>
            </tbody>
        </table>
    </div>
</main>

<script>
function filterTable(){
    const q = document.getElementById('searchInput').value.toLowerCase();
    document.querySelectorAll('#medTable tbody tr').forEach(r=>{
        const n = r.querySelector('.td-name');
        if(n) r.style.display = n.textContent.toLowerCase().includes(q) ? '' : 'none';
    });
}
</script>
</body>
</html>
