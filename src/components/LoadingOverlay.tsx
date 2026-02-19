import React from 'react';
import { View, Text, ActivityIndicator, StyleSheet } from 'react-native';
import { MotiView } from 'moti';
import { Sparkles } from 'lucide-react-native';
import { COLORS } from '../constants/theme';

interface LoadingOverlayProps {
  isVisible: boolean;
  message?: string;
}

export const LoadingOverlay: React.FC<LoadingOverlayProps> = ({ isVisible, message }) => {
  if (!isVisible) return null;

  return (
    <MotiView
      from={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      style={[StyleSheet.absoluteFill, { backgroundColor: 'rgba(0,0,0,0.9)', zIndex: 1000 }]}
      className="items-center justify-center px-10"
    >
      <MotiView
        from={{ scale: 0.8, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ loop: true, type: 'timing', duration: 2000 }}
        className="bg-primary/20 p-8 rounded-full mb-8"
      >
        <Sparkles size={48} color={COLORS.primary} />
      </MotiView>

      <Text className="text-white text-2xl font-black text-center mb-4 tracking-tighter">
        DreamSpace AI Çalışıyor
      </Text>

      <Text className="text-gray-500 text-center font-medium mb-8">
        {message || "Odanızın mimari yapısı analiz ediliyor ve yeni tarzınız uygulanıyor. Lütfen bekleyin..."}
      </Text>

      <ActivityIndicator size="large" color={COLORS.primary} />

      <MotiView
        from={{ width: 0 }}
        animate={{ width: 200 }}
        transition={{ loop: true, duration: 3000 }}
        className="h-1 bg-primary mt-10 rounded-full"
      />
    </MotiView>
  );
};
