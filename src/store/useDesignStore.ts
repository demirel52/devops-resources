import { create } from 'zustand';

interface DesignState {
  originalImage: string | null;
  generatedImage: string | null;
  roomType: string;
  style: string;
  isGenerating: boolean;
  error: string | null;

  // Actions
  setOriginalImage: (image: string | null) => void;
  setGeneratedImage: (image: string | null) => void;
  setRoomType: (type: string) => void;
  setStyle: (style: string) => void;
  setGenerating: (status: boolean) => void;
  setError: (error: string | null) => void;
  reset: () => void;
}

export const useDesignStore = create<DesignState>((set) => ({
  originalImage: null,
  generatedImage: null,
  roomType: 'living_room',
  style: 'modern',
  isGenerating: false,
  error: null,

  setOriginalImage: (image) => set({ originalImage: image, error: null }),
  setGeneratedImage: (image) => set({ generatedImage: image }),
  setRoomType: (roomType) => set({ roomType }),
  setStyle: (style) => set({ style }),
  setGenerating: (isGenerating) => set({ isGenerating }),
  setError: (error) => set({ error }),
  reset: () => set({
    originalImage: null,
    generatedImage: null,
    roomType: 'living_room',
    style: 'modern',
    isGenerating: false,
    error: null,
  }),
}));
