/**
 * MitraVerify API Integration Service
 * Handles communication with the backend API
 */

// Environment-aware API URL configuration
const getApiBaseUrl = (): string => {
  // Check if we're in production
  if (typeof window !== 'undefined' && window.location.hostname !== 'localhost') {
    // Production environment - use environment variable or fallback
    return process.env.NEXT_PUBLIC_API_URL || 'https://your-backend-api.herokuapp.com';
  }
  
  // Development environment
  return process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';
};

const API_BASE_URL = getApiBaseUrl();

// Request timeout configuration
const REQUEST_TIMEOUT = parseInt(process.env.NEXT_PUBLIC_API_TIMEOUT || '30000');
const MAX_FILE_SIZE = parseInt(process.env.NEXT_PUBLIC_MAX_FILE_SIZE || '10485760'); // 10MB

export interface VerificationResult {
  overall_verdict: string;
  confidence: number;
  text_analysis?: {
    prediction: string;
    confidence: number;
    probabilities: {
      reliable: number;
      misinformation: number;
    };
    explanation: string;
    language: string;
  };
  image_analysis?: {
    is_manipulated: boolean;
    confidence: number;
    manipulation_type: string;
    similarity_matches: Array<{
      filename: string;
      similarity: number;
    }>;
    explanation: string;
  };
  evidence: Array<{
    source: string;
    credibility: number;
    excerpt: string;
    url: string;
  }>;
  explanation: string;
  processing_time: number;
}

export interface ApiError {
  detail: string;
  status_code: number;
}

class MitraVerifyAPI {
  private baseUrl: string;

  constructor(baseUrl: string = API_BASE_URL) {
    this.baseUrl = baseUrl;
  }

  /**
   * Make a request with timeout and retry logic
   */
  private async makeRequest(url: string, options: RequestInit = {}): Promise<Response> {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), REQUEST_TIMEOUT);

    try {
      const response = await fetch(url, {
        ...options,
        signal: controller.signal,
        headers: {
          'Accept': 'application/json',
          ...options.headers,
        },
      });
      clearTimeout(timeoutId);
      return response;
    } catch (error) {
      clearTimeout(timeoutId);
      if (error instanceof Error && error.name === 'AbortError') {
        throw new Error(`Request timeout after ${REQUEST_TIMEOUT / 1000} seconds`);
      }
      throw error;
    }
  }

  /**
   * Validate file size before upload
   */
  private validateFile(file: File): void {
    if (file.size > MAX_FILE_SIZE) {
      throw new Error(`File size exceeds ${MAX_FILE_SIZE / 1024 / 1024}MB limit`);
    }
    
    const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    if (!allowedTypes.includes(file.type)) {
      throw new Error('Unsupported file type. Please use JPEG, PNG, GIF, or WebP images.');
    }
  }

  /**
   * Check if the API is healthy
   */
  async healthCheck(): Promise<{ status: string; version: string }> {
    try {
      const response = await this.makeRequest(`${this.baseUrl}/health`);
      if (!response.ok) {
        throw new Error(`Health check failed: ${response.status}`);
      }
      return await response.json();
    } catch (error) {
      console.error('Health check failed:', error);
      throw error;
    }
  }

  /**
   * Verify text content for misinformation
   */
  async verifyText(text: string): Promise<VerificationResult> {
    try {
      if (!text || text.trim().length === 0) {
        throw new Error('Text content cannot be empty');
      }

      const formData = new FormData();
      formData.append('text', text.trim());

      const response = await this.makeRequest(`${this.baseUrl}/api/v1/verify/text`, {
        method: 'POST',
        body: formData,
      });

      if (!response.ok) {
        const error: ApiError = await response.json();
        throw new Error(error.detail || `API Error: ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      console.error('Text verification failed:', error);
      throw error;
    }
  }

  /**
   * Verify image for manipulation
   */
  async verifyImage(file: File): Promise<VerificationResult> {
    try {
      this.validateFile(file);

      const formData = new FormData();
      formData.append('file', file);

      const response = await this.makeRequest(`${this.baseUrl}/api/v1/verify/image`, {
        method: 'POST',
        body: formData,
      });

      if (!response.ok) {
        const error: ApiError = await response.json();
        throw new Error(error.detail || `API Error: ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      console.error('Image verification failed:', error);
      throw error;
    }
  }

  /**
   * Verify both text and image content (multimodal)
   */
  async verifyContent(text?: string, file?: File): Promise<VerificationResult> {
    try {
      if (!text && !file) {
        throw new Error('Either text or file must be provided');
      }

      if (text && text.trim().length === 0) {
        text = undefined;
      }

      if (file) {
        this.validateFile(file);
      }

      const formData = new FormData();
      if (text) {
        formData.append('text', text.trim());
      }
      if (file) {
        formData.append('file', file);
      }

      const response = await this.makeRequest(`${this.baseUrl}/api/v1/verify`, {
        method: 'POST',
        body: formData,
      });

      if (!response.ok) {
        const error: ApiError = await response.json();
        throw new Error(error.detail || `API Error: ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      console.error('Content verification failed:', error);
      throw error;
    }
  }

  /**
   * Get system statistics and supported formats
   */
  async getStats(): Promise<{
    status: string;
    supported_languages: string[];
    supported_formats: string[];
    model_info: {
      text_model: string;
      image_model: string;
      embedding_model: string;
    };
  }> {
    try {
      const response = await this.makeRequest(`${this.baseUrl}/api/v1/stats`);
      if (!response.ok) {
        throw new Error(`Stats request failed: ${response.status}`);
      }
      return await response.json();
    } catch (error) {
      console.error('Failed to get stats:', error);
      throw error;
    }
  }
}

// Export singleton instance
export const mitraAPI = new MitraVerifyAPI();

// Export utility functions
export const formatConfidence = (confidence: number): string => {
  return `${Math.round(confidence * 100)}%`;
};

export const getVerdictColor = (verdict: string): string => {
  switch (verdict.toLowerCase()) {
    case 'reliable':
    case 'true':
      return 'text-green-600';
    case 'misinformation':
    case 'fake':
      return 'text-red-600';
    case 'uncertain':
    case 'unknown':
    default:
      return 'text-yellow-600';
  }
};

export const getConfidenceLevel = (confidence: number): string => {
  if (confidence >= 0.8) return 'High';
  if (confidence >= 0.6) return 'Medium';
  return 'Low';
};