import React from 'react';
import { View, Text, TouchableOpacity, ScrollView, Image, Alert, ActivityIndicator } from 'react-native';
import * as ImagePicker from 'expo-image-picker';
import * as Haptics from 'expo-haptics';
import { Camera, Image as ImageIcon, Sparkles, ChevronRight, X, Info } from 'lucide-react-native';
import { ROOM_TYPES, DESIGN_STYLES, COLORS } from '../constants/theme';
import { MotiView, AnimatePresence } from 'moti';
import { useDesignStore } from '../store/useDesignStore';
import { aiService } from '../services/aiService';
import { imageToBase64 } from '../utils/imageUtils';
import { SelectionCard } from '../components/SelectionCard';
import { useNavigation } from '@react-navigation/native';
import { LoadingOverlay } from '../components/LoadingOverlay';

const HomeScreen = () => {
  const navigation = useNavigation();
  const {
    originalImage, setOriginalImage,
    roomType, setRoomType,
    style, setStyle,
    isGenerating, setGenerating,
    error, setError
  } = useDesignStore();

  const handlePickImage = async () => {
    const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (status !== 'granted') {
      Alert.alert('İzin Gerekli', 'Galerinize erişmek için izin vermeniz gerekmektedir.');
      return;
    }

    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsEditing: true,
      aspect: [1, 1],
      quality: 0.8,
    });

    if (!result.canceled) {
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
      setOriginalImage(result.assets[0].uri);
    }
  };

  const handleTakePhoto = async () => {
    const { status } = await ImagePicker.requestCameraPermissionsAsync();
    if (status !== 'granted') {
      Alert.alert('İzin Gerekli', 'Kameraya erişmek için izin vermeniz gerekmektedir.');
      return;
    }

    const result = await ImagePicker.launchCameraAsync({
      allowsEditing: true,
      aspect: [1, 1],
      quality: 0.8,
    });

    if (!result.canceled) {
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
      setOriginalImage(result.assets[0].uri);
    }
  };

  const handleGenerate = async () => {
    if (!originalImage) return;

    try {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy);
      setGenerating(true);
      setError(null);

      const base64Image = await imageToBase64(originalImage);

      const response = await aiService.generateDesign({
        image: base64Image,
        prompt: "elegant interior design",
        roomType,
        style
      });

      // Poll for result
      const resultUrl = await aiService.waitForPrediction(response.id);

      setGenerating(false);
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);

      // Navigate to Result Screen
      (navigation as any).navigate('Result', {
        originalImage: originalImage,
        generatedImage: resultUrl
      });

    } catch (err: any) {
      setError(err.message);
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error);
    } finally {
      setGenerating(false);
    }
  };

  return (
    <View className="flex-1 bg-black">
      <LoadingOverlay isVisible={isGenerating} />
      <ScrollView
        className="flex-1 pt-12 px-6"
        showsVerticalScrollIndicator={false}
      >
      {/* Header */}
      <MotiView
        from={{ opacity: 0, translateY: -20 }}
        animate={{ opacity: 1, translateY: 0 }}
        className="mb-10"
      >
        <View className="flex-row items-center justify-between">
          <View>
            <Text className="text-white text-4xl font-black tracking-tighter">
              Dream<Text className="text-primary">Space</Text>
            </Text>
            <Text className="text-gray-500 text-xs font-bold tracking-[2px] mt-1">
              INTERIOR AI ENGINE
            </Text>
          </View>
          <View className="bg-secondary/10 px-3 py-1.5 rounded-full border border-secondary/20">
            <Text className="text-secondary text-[10px] font-black italic">PRO</Text>
          </View>
        </View>
      </MotiView>

      {/* Error Message */}
      <AnimatePresence>
        {error && (
          <MotiView
            from={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.9 }}
            className="mb-6 bg-red-500/10 border border-red-500/20 p-4 rounded-3xl flex-row items-center"
          >
            <View className="bg-red-500/20 p-2 rounded-full">
              <Info size={16} color="#ef4444" />
            </View>
            <Text className="text-red-500 text-xs ml-3 flex-1 font-medium">{error}</Text>
            <TouchableOpacity onPress={() => setError(null)}>
              <X size={20} color="#ef4444" />
            </TouchableOpacity>
          </MotiView>
        )}
      </AnimatePresence>

      {/* Step 1: Photo */}
      <View className="mb-8">
        <View className="flex-row justify-between items-end mb-5">
          <View>
            <Text className="text-white text-xl font-black">Mekan Seçimi</Text>
            <Text className="text-gray-600 text-[10px] font-bold mt-0.5">YÜKSEK ÇÖZÜNÜRLÜK ÖNERİLİR</Text>
          </View>
          {originalImage && (
             <TouchableOpacity onPress={() => {
               Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
               setOriginalImage(null);
             }}>
               <Text className="text-primary text-xs font-black uppercase">Değiştir</Text>
             </TouchableOpacity>
          )}
        </View>

        {originalImage ? (
          <MotiView
            from={{ opacity: 0, translateY: 20 }}
            animate={{ opacity: 1, translateY: 0 }}
            className="relative overflow-hidden rounded-[40px] border border-white/10 shadow-2xl shadow-primary/20"
          >
            <Image source={{ uri: originalImage }} className="w-full h-80" resizeMode="cover" />
            <View className="absolute inset-0 bg-gradient-to-t from-black/80 to-transparent" />
            <MotiView
              animate={{ opacity: [0.4, 0.7, 0.4] }}
              transition={{ loop: true, duration: 2000 }}
              className="absolute bottom-6 left-6 flex-row items-center bg-black/60 px-4 py-2 rounded-full border border-white/10"
            >
              <Sparkles size={12} color={COLORS.accent} />
              <Text className="text-white text-[10px] font-black ml-2 uppercase tracking-widest">Analiz Edilmeye Hazır</Text>
            </MotiView>
          </MotiView>
        ) : (
          <View className="flex-row space-x-4">
            <TouchableOpacity
              onPress={handlePickImage}
              activeOpacity={0.8}
              className="flex-1 bg-luxury-gray h-48 rounded-[40px] border border-white/5 items-center justify-center"
            >
              <View className="bg-primary/20 p-5 rounded-full mb-4">
                <ImageIcon size={30} color={COLORS.accent} />
              </View>
              <Text className="text-white font-black text-xs tracking-widest uppercase">Galeri</Text>
            </TouchableOpacity>

            <TouchableOpacity
              onPress={handleTakePhoto}
              activeOpacity={0.8}
              className="flex-1 bg-luxury-gray h-48 rounded-[40px] border border-white/5 items-center justify-center"
            >
              <View className="bg-primary/20 p-5 rounded-full mb-4">
                <Camera size={30} color={COLORS.accent} />
              </View>
              <Text className="text-white font-black text-xs tracking-widest uppercase">Kamera</Text>
            </TouchableOpacity>
          </View>
        )}
      </View>

      {/* Step 2: Room Type */}
      <View className="mb-8">
        <Text className="text-white text-xl font-black mb-5">Oda Tipi</Text>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} className="flex-row overflow-visible">
          {ROOM_TYPES.map((room) => {
            const isSelected = roomType === room.id;
            return (
              <TouchableOpacity
                key={room.id}
                onPress={() => {
                  Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                  setRoomType(room.id);
                }}
                className={`mr-4 px-8 py-5 rounded-full border-2 ${
                  isSelected ? 'bg-primary border-primary shadow-xl shadow-primary/40' : 'bg-luxury-gray border-white/5'
                }`}
              >
                <Text className={`${isSelected ? 'text-white' : 'text-gray-500'} font-black text-xs tracking-widest uppercase`}>
                  {room.label}
                </Text>
              </TouchableOpacity>
            );
          })}
        </ScrollView>
      </View>

      {/* Step 3: Style Selection */}
      <View className="mb-10">
        <Text className="text-white text-xl font-black mb-5">Tasarım Stili</Text>
        <View className="flex-row flex-wrap justify-between">
          {DESIGN_STYLES.map((s) => (
            <SelectionCard
              key={s.id}
              label={s.label}
              description={s.description}
              isSelected={style === s.id}
              onPress={() => {
                Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                setStyle(s.id);
              }}
              accentColor={COLORS.gold}
            />
          ))}
        </View>
      </View>

      {/* Generate Button */}
      <TouchableOpacity
        onPress={handleGenerate}
        disabled={!originalImage || isGenerating}
        activeOpacity={0.9}
        className={`w-full py-7 rounded-[35px] flex-row items-center justify-center mb-20 shadow-2xl ${
          originalImage ? 'bg-primary' : 'bg-gray-900/50 opacity-40'
        }`}
      >
        {isGenerating ? (
          <ActivityIndicator color="white" />
        ) : (
          <>
            <Sparkles size={24} color="white" />
            <Text className="text-white font-black text-xl ml-4 tracking-tighter">TASARIMI OLUŞTUR</Text>
            <View className="ml-3 bg-white/20 p-1 rounded-full">
              <ChevronRight size={18} color="white" />
            </View>
          </>
        )}
      </TouchableOpacity>
    </ScrollView>
    </View>
  );
};

export default HomeScreen;
