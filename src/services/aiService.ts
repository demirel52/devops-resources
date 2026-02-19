import axios from 'axios';
import { AIRequestParams, AIResponse } from '../types/ai';

const REPLICATE_API_URL = 'https://api.replicate.com/v1/predictions';
const REPLICATE_API_TOKEN = ''; // API KEY HERE

const MODEL_VERSION = "rossum/controlnet-interior-design:866291a27e7d9b7367b60589a1753942004245b7361ba889104040f7f329241b";

export const aiService = {
  generateDesign: async (params: AIRequestParams): Promise<AIResponse> => {
    try {
      const { image, prompt, roomType, style } = params;
      const fullPrompt = `A professional interior design of a ${roomType}, ${style} style, high quality, 8k resolution, photorealistic, ${prompt}`;

      const response = await axios.post(
        REPLICATE_API_URL,
        {
          version: MODEL_VERSION.split(':')[1],
          input: {
            image: image,
            prompt: fullPrompt,
            negative_prompt: "low quality, blurry, distorted, messy, unrealistic",
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
      throw new Error(error.response?.data?.detail || 'AI servisi şu anda yanıt vermiyor.');
    }
  },

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
  },

  /**
   * Polls the API until the prediction is complete or failed.
   */
  waitForPrediction: async (predictionId: string, interval = 3000): Promise<string> => {
    return new Promise((resolve, reject) => {
      const poll = async () => {
        try {
          const status = await aiService.getPredictionStatus(predictionId);
          if (status.status === 'succeeded') {
            const output = Array.isArray(status.output) ? status.output[0] : status.output;
            if (output) {
              resolve(output);
            } else {
              reject(new Error('AI çıktısı boş döndü.'));
            }
          } else if (status.status === 'failed' || status.status === 'canceled') {
            reject(new Error(`Tasarım oluşturulamadı: ${status.error || 'Bilinmeyen hata'}`));
          } else {
            setTimeout(poll, interval);
          }
        } catch (error) {
          reject(error);
        }
      };
      poll();
    });
  }
};
