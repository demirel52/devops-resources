import axios from 'axios';
import { AIRequestParams, AIResponse } from '../types/ai';

// In a real app, these would come from environment variables or a secure backend
const REPLICATE_API_URL = 'https://api.replicate.com/v1/predictions';
const REPLICATE_API_TOKEN = ''; // To be provided by user or in .env

// ControlNet Model for Interior Design (Example: MLSD or Canny for structure)
const MODEL_VERSION = "rossum/controlnet-interior-design:866291a27e7d9b7367b60589a1753942004245b7361ba889104040f7f329241b";

export const aiService = {
  /**
   * Triggers the AI Generation process using Replicate's ControlNet
   */
  generateDesign: async (params: AIRequestParams): Promise<AIResponse> => {
    try {
      const { image, prompt, roomType, style } = params;

      // Constructing a detailed prompt for better results
      const fullPrompt = `A professional interior design of a ${roomType}, ${style} style, high quality, 8k resolution, photorealistic, ${prompt}`;

      const response = await axios.post(
        REPLICATE_API_URL,
        {
          version: MODEL_VERSION.split(':')[1],
          input: {
            image: image,
            prompt: fullPrompt,
            negative_prompt: "low quality, blurry, distorted, messy, unrealistic",
            num_inference_steps: 50,
            guidance_scale: 7.5,
          },
        },
        {
          headers: {
            Authorization: `Token ${REPLICATE_API_TOKEN}`,
            'Content-Type': 'application/json',
          },
        }
      );

      return response.data;
    } catch (error: any) {
      console.error('AI Generation Error:', error.response?.data || error.message);
      throw new Error(error.response?.data?.detail || 'AI servisi şu anda yanıt vermiyor. Lütfen daha sonra tekrar deneyin.');
    }
  },

  /**
   * Polls the status of the prediction
   */
  getPredictionStatus: async (predictionId: string): Promise<AIResponse> => {
    try {
      const response = await axios.get(`${REPLICATE_API_URL}/${predictionId}`, {
        headers: {
          Authorization: `Token ${REPLICATE_API_TOKEN}`,
        },
      });
      return response.data;
    } catch (error: any) {
      throw new Error('Tahmin durumu alınamadı.');
    }
  }
};
