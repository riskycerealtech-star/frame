# Swagger API Documentation Guide

## 🎉 Your API Documentation is Ready!

Your FastAPI application includes **automated Swagger UI documentation** that is accessible in your browser.

## 📍 Access the Documentation

### Swagger UI (Interactive Interface)
```
http://localhost:8000/docs/frame/swagger-ui/index.html
```

### ReDoc (Alternative Documentation)
```
http://localhost:8000/docs/frame/redoc/index.html
```

### OpenAPI JSON Schema
```
http://localhost:8000/docs/frame/openapi.json
```

## 🚀 Quick Start

1. **Start the server:**
   ```bash
   cd Backend
   source venv/bin/activate
   python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
   ```

2. **Open your browser and navigate to:**
   ```
   http://localhost:8000/docs/frame/swagger-ui/index.html
   ```

3. **Explore the API:**
   - View all available endpoints
   - Read detailed descriptions
   - Test endpoints directly from the browser
   - See request/response examples

## 📚 What's Included

### 1. **API Overview**
- Project name and description
- Version information
- Contact information
- License details

### 2. **Organized Endpoints**
Endpoints are grouped by tags:
- **1. Authentication**: Root and health check endpoints
- **Sunglasses Detection**: AI-powered detection endpoints

### 3. **Interactive Testing**
For each endpoint, you can:
- See detailed descriptions
- View required parameters
- See example responses
- **Try it out** - Execute API calls directly from the UI
- Upload files and test endpoints

### 4. **Request/Response Examples**
Each endpoint includes:
- Request format (with examples)
- Response format (with examples)
- Error responses
- Status codes

## 🎯 Testing Endpoints

### Example: Test the Health Endpoint

1. Navigate to `http://localhost:8000/docs/frame/swagger-ui/index.html`
2. Find the **1. Authentication** section
3. Click on `GET /health`
4. Click the **"Try it out"** button
5. Click **"Execute"**
6. View the response below

### Example: Test Sunglasses Detection

1. Navigate to `http://localhost:8000/docs/frame/swagger-ui/index.html`
2. Find the **Sunglasses Detection** section
3. Click on `POST /validate-sunglasses`
4. Click the **"Try it out"** button
5. Click **"Choose File"** and select an image with sunglasses
6. Click **"Execute"**
7. View the detection results

## 🔍 Features

### Swagger UI Features:
- ✅ **Interactive API Explorer** - Test endpoints without writing code
- ✅ **Request/Response Schemas** - See exact data structures
- ✅ **Authentication Support** - Easy to add auth later
- ✅ **Multiple Formats** - File uploads and JSON
- ✅ **Code Generation** - Generate client code in multiple languages
- ✅ **Export OpenAPI Spec** - Download the schema for other tools

### Documentation Highlights:
- 🎨 Beautiful, modern UI
- 📱 Responsive design (works on mobile)
- 🔍 Search functionality
- 📝 Detailed descriptions with Markdown support
- 🏷️ Tagged endpoints for organization
- 📊 Example requests/responses

## 🛠️ Customization

### Already Configured:
Your API now includes enhanced documentation with:
- Professional API description
- Organized endpoint groups
- Detailed parameter descriptions
- Example requests/responses
- Contact information
- License information

### In `main.py`:
```python
app = FastAPI(
    title="Sunglasses Detection API",
    description="...",  # Your detailed description
    version="1.0.0",
    docs_url="/docs",           # Swagger UI URL
    redoc_url="/redoc",         # ReDoc URL
    openapi_url="/openapi.json", # OpenAPI schema URL
    contact={...},
    license_info={...}
)
```

## 📸 Screenshots

### Main Documentation View
The Swagger UI provides a clean, organized view of all your API endpoints grouped by functionality.

### Endpoint Details
Each endpoint shows:
- HTTP method and path
- Detailed description
- Parameters with types
- Request body structure
- Response examples
- Try it out interface

### Interactive Testing
Click "Try it out" on any endpoint to test it directly from your browser with real data.

## 🔐 Adding Authentication (Optional)

If you want to add authentication to the Swagger UI:

```python
from fastapi.security import HTTPBearer

security = HTTPBearer()

app = FastAPI(
    # ... existing config
)

# Then add security to endpoints:
@app.post("/validate-sunglasses", dependencies=[Depends(security)])
async def validate_sunglasses(...):
    ...
```

## 🌐 Production Considerations

For production deployment:

1. **Disable auto-reload:**
   ```bash
   uvicorn main:app --host 0.0.0.0 --port 8000
   ```

2. **Secure the API:**
   - Add authentication
   - Use HTTPS
   - Limit CORS origins
   - Add rate limiting

3. **Optional: Hide docs in production:**
   ```python
   import os
   
   app = FastAPI(
       # ... existing config
       docs_url="/docs" if os.getenv("DEBUG") == "True" else None,
       redoc_url="/redoc" if os.getenv("DEBUG") == "True" else None,
   )
   ```

## 📖 Additional Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [OpenAPI Specification](https://swagger.io/specification/)
- [Swagger UI Docs](https://swagger.io/tools/swagger-ui/)
- [ReDoc](https://redocly.com/docs/redoc/)

## ✅ Summary

Your Swagger documentation is **ready to use**! Simply:

1. Start your server: `python -m uvicorn main:app --reload`
2. Open browser: `http://localhost:8000/docs/frame/swagger-ui/index.html`
3. Explore and test your API!

The documentation is automatically generated from your Python code, so as you add more endpoints and improve descriptions, the documentation updates automatically!

---

**Need help?** Check the FastAPI documentation or look at the enhanced descriptions in your `main.py` file.
