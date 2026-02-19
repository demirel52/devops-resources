import * as FileSystem from 'expo-file-system';

export const imageToBase64 = async (uri: string): Promise<string> => {
  try {
    // Using string literal for compatibility
    const base64 = await FileSystem.readAsStringAsync(uri, {
      encoding: 'base64',
    });
    return `data:image/jpeg;base64,${base64}`;
  } catch (error) {
    console.error('Base64 Conversion Error:', error);
    throw new Error('Görüntü işlenirken bir hata oluştu.');
  }
};
