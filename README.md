# frame
This is frame project.

## Setup

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Run the application:
```bash
uvicorn main:app --reload
```

The API will be available at `http://localhost:8000`

## API Endpoints

### Register
- **POST** `/register`
- **Body:**
  ```json
  {
    "email": "user@example.com",
    "username": "username",
    "password": "password123"
  }
  ```
- **Response:** User object with id, email, username, and created_at

### Login
- **POST** `/login`
- **Body:** (form-data)
  - `username`: username
  - `password`: password
- **Response:**
  ```json
  {
    "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "token_type": "bearer"
  }
  ```

### Get Current User
- **GET** `/me`
- **Headers:** `Authorization: Bearer <access_token>`
- **Response:** Current user information

## API Documentation

Once the server is running, visit:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## Configuration

You can configure the application by setting environment variables:
- `SECRET_KEY`: Secret key for JWT token signing (default: "your-secret-key-change-this-in-production")
- `ALGORITHM`: JWT algorithm (default: "HS256")
- `ACCESS_TOKEN_EXPIRE_MINUTES`: Token expiration time in minutes (default: 30)
- `DATABASE_URL`: Database connection string (default: "sqlite:///./app.db")

## Deployment to Google Cloud Run

### Automatic Deployment via GitHub (No Docker Required!)

This project is configured for automatic deployment to Google Cloud Run whenever you push to GitHub. **No Docker installation needed on your laptop!**

**Quick Setup:**

1. **Run the setup script:**
   ```bash
   ./setup-github-deploy.sh
   ```

2. **Add secrets to GitHub:**
   - Go to your repository → Settings → Secrets and variables → Actions
   - Add the secrets shown by the setup script

3. **Push to GitHub:**
   ```bash
   git push origin main
   ```

4. **Watch it deploy!** Check the Actions tab in GitHub

For detailed instructions, see [GITHUB_DEPLOYMENT.md](GITHUB_DEPLOYMENT.md)

### Manual Deployment

For manual deployment options, see [DEPLOYMENT.md](DEPLOYMENT.md)
