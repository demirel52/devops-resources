export interface AIRequestParams {
  image: string; // Base64 or URL
  prompt: string;
  roomType: string;
  style: string;
}

export interface AIResponse {
  id: string;
  output: string[] | string | null;
  status: 'starting' | 'processing' | 'succeeded' | 'failed' | 'canceled';
  error: string | null;
}
