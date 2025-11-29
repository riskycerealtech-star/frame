// React Native API Client for Frame Backend API
// Production URL: https://glass-api-750669515844.us-central1.run.app

import AsyncStorage from '@react-native-async-storage/async-storage';

const API_CONFIG = {
  // Production API URL
  baseUrl: 'https://glass-api-750669515844.us-central1.run.app',
  
  // Local development (uncomment for local testing)
  // baseUrl: 'http://localhost:8000',
  
  apiVersion: '/api/v1',
  get apiBaseUrl() {
    return `${this.baseUrl}${this.apiVersion}`;
  },
  
  endpoints: {
    health: `${this.baseUrl}/health`,
    auth: `${this.apiBaseUrl}/auth`,
    products: `${this.apiBaseUrl}/products`,
    users: `${this.apiBaseUrl}/users`,
    orders: `${this.apiBaseUrl}/orders`,
  },
};

const TOKEN_KEY = 'auth_token';

class ApiService {
  constructor() {
    this.token = null;
    this.initialize();
  }

  // Initialize token from storage
  async initialize() {
    try {
      this.token = await AsyncStorage.getItem(TOKEN_KEY);
    } catch (error) {
      console.error('Error loading token:', error);
    }
  }

  // Set authentication token
  async setToken(token) {
    this.token = token;
    try {
      await AsyncStorage.setItem(TOKEN_KEY, token);
    } catch (error) {
      console.error('Error saving token:', error);
    }
  }

  // Clear authentication token
  async clearToken() {
    this.token = null;
    try {
      await AsyncStorage.removeItem(TOKEN_KEY);
    } catch (error) {
      console.error('Error removing token:', error);
    }
  }

  // Get headers with authentication
  getHeaders() {
    const headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (this.token) {
      headers['Authorization'] = `Bearer ${this.token}`;
    }
    
    return headers;
  }

  // Handle response
  async handleResponse(response) {
    const statusCode = response.status;
    
    if (statusCode >= 200 && statusCode < 300) {
      try {
        const data = await response.json();
        return { success: true, data };
      } catch (error) {
        return { success: true, data: { message: await response.text() } };
      }
    } else if (statusCode === 401) {
      // Unauthorized - clear token
      await this.clearToken();
      return { success: false, error: 'Unauthorized. Please login again.' };
    } else {
      try {
        const error = await response.json();
        return { success: false, error: error.detail || 'Request failed' };
      } catch (error) {
        return { success: false, error: `Request failed with status ${statusCode}` };
      }
    }
  }

  // GET request
  async get(endpoint) {
    try {
      const response = await fetch(`${API_CONFIG.apiBaseUrl}${endpoint}`, {
        method: 'GET',
        headers: this.getHeaders(),
      });
      return await this.handleResponse(response);
    } catch (error) {
      return { success: false, error: `Network error: ${error.message}` };
    }
  }

  // POST request
  async post(endpoint, data) {
    try {
      const response = await fetch(`${API_CONFIG.apiBaseUrl}${endpoint}`, {
        method: 'POST',
        headers: this.getHeaders(),
        body: JSON.stringify(data),
      });
      return await this.handleResponse(response);
    } catch (error) {
      return { success: false, error: `Network error: ${error.message}` };
    }
  }

  // PUT request
  async put(endpoint, data) {
    try {
      const response = await fetch(`${API_CONFIG.apiBaseUrl}${endpoint}`, {
        method: 'PUT',
        headers: this.getHeaders(),
        body: JSON.stringify(data),
      });
      return await this.handleResponse(response);
    } catch (error) {
      return { success: false, error: `Network error: ${error.message}` };
    }
  }

  // DELETE request
  async delete(endpoint) {
    try {
      const response = await fetch(`${API_CONFIG.apiBaseUrl}${endpoint}`, {
        method: 'DELETE',
        headers: this.getHeaders(),
      });
      return await this.handleResponse(response);
    } catch (error) {
      return { success: false, error: `Network error: ${error.message}` };
    }
  }

  // Health check
  async checkHealth() {
    try {
      const response = await fetch(API_CONFIG.endpoints.health);
      return response.status === 200;
    } catch (error) {
      return false;
    }
  }
}

// Authentication Service
class AuthService {
  constructor() {
    this.api = new ApiService();
  }

  // Login
  async login(email, password) {
    const response = await this.api.post('/auth/login', {
      email,
      password,
    });

    if (response.success && response.data?.access_token) {
      await this.api.setToken(response.data.access_token);
    }

    return response;
  }

  // Register
  async register(email, password, fullName) {
    const response = await this.api.post('/auth/register', {
      email,
      password,
      full_name: fullName,
    });

    if (response.success && response.data?.access_token) {
      await this.api.setToken(response.data.access_token);
    }

    return response;
  }

  // Logout
  async logout() {
    await this.api.clearToken();
  }

  // Check if logged in
  async isLoggedIn() {
    await this.api.initialize();
    return this.api.token !== null;
  }

  // Get current user
  async getCurrentUser() {
    return await this.api.get('/users/me');
  }
}

// Product Service
class ProductService {
  constructor() {
    this.api = new ApiService();
  }

  // Get all products
  async getProducts(limit = null, offset = null) {
    let endpoint = '/products';
    const params = [];
    if (limit) params.push(`limit=${limit}`);
    if (offset) params.push(`offset=${offset}`);
    if (params.length > 0) endpoint += `?${params.join('&')}`;
    
    return await this.api.get(endpoint);
  }

  // Get product by ID
  async getProduct(id) {
    return await this.api.get(`/products/${id}`);
  }

  // Create product
  async createProduct(productData) {
    return await this.api.post('/products', productData);
  }

  // Update product
  async updateProduct(id, productData) {
    return await this.api.put(`/products/${id}`, productData);
  }

  // Delete product
  async deleteProduct(id) {
    return await this.api.delete(`/products/${id}`);
  }
}

// Export services
export const apiService = new ApiService();
export const authService = new AuthService();
export const productService = new ProductService();
export default { apiService, authService, productService };



