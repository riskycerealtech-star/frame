"""
Routes for Swagger UI authentication (login page and dashboard)
"""
from fastapi import APIRouter, Request, Form, HTTPException, status, Depends
from fastapi.responses import HTMLResponse, RedirectResponse
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.services.user_service import UserService
from app.core.security import create_access_token
from app.api.v1.dependencies import get_current_user
from datetime import datetime
from pathlib import Path

router = APIRouter()

# Templates directory
BASE_DIR = Path(__file__).resolve().parent.parent
TEMPLATES_DIR = BASE_DIR / "templates"


def get_login_html(error: str = None) -> str:
    """Get login HTML page"""
    error_html = f'<div class="error-message">{error}</div>' if error else ''
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Backend APIs Frame Flea</title>
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }}
        .login-container {{
            background: white;
            border-radius: 12px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            padding: 40px;
            width: 100%;
            max-width: 420px;
        }}
        .logo {{ text-align: center; margin-bottom: 30px; }}
        .logo h1 {{ color: #333; font-size: 28px; font-weight: 700; margin-bottom: 8px; }}
        .logo p {{ color: #666; font-size: 14px; }}
        .error-message {{
            background: #fee;
            border: 1px solid #fcc;
            color: #c33;
            padding: 12px;
            border-radius: 6px;
            margin-bottom: 20px;
            font-size: 14px;
        }}
        .form-group {{ margin-bottom: 20px; }}
        .form-group label {{
            display: block;
            color: #333;
            font-weight: 600;
            margin-bottom: 8px;
            font-size: 14px;
        }}
        .form-group input {{
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #e0e0e0;
            border-radius: 6px;
            font-size: 15px;
            transition: border-color 0.3s;
        }}
        .form-group input:focus {{
            outline: none;
            border-color: #667eea;
        }}
        .login-button {{
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 6px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
        }}
        .login-button:hover {{
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.4);
        }}
        .help-text {{
            text-align: center;
            margin-top: 20px;
            color: #666;
            font-size: 13px;
        }}
        .help-text a {{ color: #667eea; text-decoration: none; }}
        .help-text a:hover {{ text-decoration: underline; }}
    </style>
</head>
<body>
    <div class="login-container">
        <div class="logo">
            <h1>🔐 API Access</h1>
            <p>Backend APIs Frame Flea</p>
        </div>
        {error_html}
        <form method="POST" action="/v1/auth/swagger-login">
            <div class="form-group">
                <label for="username">Email or Phone Number</label>
                <input type="text" id="username" name="username" 
                       placeholder="Enter your email or phone (+1234567890)" required autofocus>
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" 
                       placeholder="Enter your password" required>
            </div>
            <button type="submit" class="login-button">Sign In to Access API Docs</button>
        </form>
        <div class="help-text">
            <p>Need an account? <a href="/v1/auth/register">Register here</a></p>
            <p style="margin-top: 8px;">Access token valid for 24 hours</p>
        </div>
    </div>
</body>
</html>"""


def get_dashboard_html(user) -> str:
    """Get dashboard HTML page"""
    user_name = user.first_name or user.username
    full_name = user.full_name or ""
    phone = user.phone_number or ""
    last_login = user.last_login.strftime('%Y-%m-%d %H:%M:%S') if user.last_login else "Never"
    status_text = "Admin" if user.is_admin else ("Seller" if user.is_seller else "User")
    
    full_name_html = f'<div class="info-row"><span class="info-label">Full Name:</span><span class="info-value">{full_name}</span></div>' if full_name else ''
    phone_html = f'<div class="info-row"><span class="info-label">Phone:</span><span class="info-value">{phone}</span></div>' if phone else ''
    
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Backend APIs Frame Flea</title>
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #f5f7fa;
            min-height: 100vh;
            padding: 20px;
        }}
        .header {{
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            padding: 20px 30px;
            margin-bottom: 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }}
        .header h1 {{ color: #333; font-size: 24px; font-weight: 700; }}
        .logout-button {{
            padding: 10px 20px;
            background: #dc3545;
            color: white;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
        }}
        .logout-button:hover {{ background: #c82333; }}
        .dashboard-container {{ max-width: 1200px; margin: 0 auto; }}
        .welcome-card {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 12px;
            padding: 40px;
            color: white;
            margin-bottom: 30px;
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.3);
        }}
        .welcome-card h2 {{ font-size: 32px; margin-bottom: 10px; }}
        .welcome-card p {{ font-size: 16px; opacity: 0.9; }}
        .cards-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }}
        .card {{
            background: white;
            border-radius: 12px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }}
        .card h3 {{ color: #333; font-size: 20px; margin-bottom: 15px; }}
        .card p {{ color: #666; font-size: 14px; line-height: 1.6; margin-bottom: 20px; }}
        .card-button {{
            display: inline-block;
            padding: 12px 24px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-decoration: none;
            border-radius: 6px;
            font-weight: 600;
        }}
        .card-button:hover {{ transform: translateY(-2px); box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4); }}
        .user-info {{
            background: white;
            border-radius: 12px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }}
        .user-info h3 {{ color: #333; font-size: 20px; margin-bottom: 20px; }}
        .info-row {{
            display: flex;
            padding: 12px 0;
            border-bottom: 1px solid #eee;
        }}
        .info-row:last-child {{ border-bottom: none; }}
        .info-label {{ font-weight: 600; color: #666; width: 150px; }}
        .info-value {{ color: #333; }}
    </style>
</head>
<body>
    <div class="dashboard-container">
        <div class="header">
            <h1>🚀 Backend APIs Frame Flea</h1>
            <a href="/v1/auth/swagger-logout" class="logout-button">Logout</a>
        </div>
        <div class="welcome-card">
            <h2>Welcome back, {user_name}! 👋</h2>
            <p>You're successfully authenticated. Access the API documentation below.</p>
        </div>
        <div class="cards-grid">
            <div class="card">
                <h3>📚 API Documentation</h3>
                <p>Explore the complete API documentation with interactive Swagger UI.</p>
                <a href="/docs/frame/swagger-ui/index.html" class="card-button">Open Swagger UI</a>
            </div>
            <div class="card">
                <h3>📖 ReDoc Documentation</h3>
                <p>View the API documentation in a clean, readable format with ReDoc.</p>
                <a href="/docs/frame/redoc/index.html" class="card-button">Open ReDoc</a>
            </div>
            <div class="card">
                <h3>🔑 API Access</h3>
                <p>Your access token is valid for 24 hours. Use Authorization header with Bearer token.</p>
                <a href="/docs/frame/openapi.json" class="card-button">View OpenAPI Spec</a>
            </div>
        </div>
        <div class="user-info">
            <h3>👤 Your Profile</h3>
            <div class="info-row">
                <span class="info-label">Email:</span>
                <span class="info-value">{user.email}</span>
            </div>
            <div class="info-row">
                <span class="info-label">Username:</span>
                <span class="info-value">{user.username}</span>
            </div>
            {full_name_html}
            {phone_html}
            <div class="info-row">
                <span class="info-label">Account Status:</span>
                <span class="info-value">{status_text}</span>
            </div>
            <div class="info-row">
                <span class="info-label">Last Login:</span>
                <span class="info-value">{last_login}</span>
            </div>
        </div>
    </div>
</body>
</html>"""


@router.get("/swagger-login", response_class=HTMLResponse)
async def swagger_login_page(request: Request, error: str = None):
    """
    Login page for Swagger UI access.
    Users must authenticate before accessing API documentation.
    """
    return HTMLResponse(content=get_login_html(error))


@router.post("/swagger-login", response_class=HTMLResponse)
async def swagger_login(
    request: Request,
    username: str = Form(...),
    password: str = Form(...),
    db: Session = Depends(get_db)
):
    """
    Handle Swagger UI login form submission.
    Sets access_token cookie and redirects to Swagger UI.
    """
    user_service = UserService(db)
    
    # Authenticate user
    user = user_service.authenticate_user(username, password)
    if not user:
        return HTMLResponse(
            content=get_login_html("Incorrect email/phone or password"),
            status_code=status.HTTP_401_UNAUTHORIZED
        )
    
    # Update last login
    user.last_login = datetime.utcnow()
    db.commit()
    
    # Create access token
    access_token = create_access_token(subject=str(user.id))
    
    # Redirect to Swagger UI with token in cookie
    response = RedirectResponse(url="/docs/frame/swagger-ui/index.html", status_code=302)
    response.set_cookie(
        key="access_token",
        value=access_token,
        httponly=True,
        secure=False,  # Set to True in production with HTTPS
        samesite="lax",
        max_age=86400  # 24 hours
    )
    
    return response


@router.get("/swagger-dashboard", response_class=HTMLResponse)
async def swagger_dashboard(
    request: Request,
    current_user = Depends(get_current_user)
):
    """
    Dashboard page after successful login.
    Shows user information and link to API documentation.
    """
    return HTMLResponse(content=get_dashboard_html(current_user))


@router.get("/swagger-logout")
async def swagger_logout():
    """
    Logout from Swagger UI.
    Clears access_token cookie and redirects to login.
    """
    response = RedirectResponse(url="/v1/auth/swagger-login", status_code=302)
    response.delete_cookie(key="access_token")
    return response
