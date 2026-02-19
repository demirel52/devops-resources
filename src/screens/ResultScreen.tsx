import React from 'react';
import { View, Text, TouchableOpacity, Image, Dimensions } from 'react-native';
import { Gesture, GestureDetector } from 'react-native-gesture-handler';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
} from 'react-native-reanimated';
import { Download, Share2, ChevronLeft, Sparkles } from 'lucide-react-native';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import { RootStackParamList } from '../types/navigation';
import { MotiView } from 'moti';
import { COLORS } from '../constants/theme';
import * as Sharing from 'expo-sharing';

const { width } = Dimensions.get('window');
const IMAGE_HEIGHT = 450;

type ResultScreenRouteProp = RouteProp<RootStackParamList, 'Result'>;

const ResultScreen = () => {
  const navigation = useNavigation();
  const route = useRoute<ResultScreenRouteProp>();
  const { originalImage, generatedImage } = route.params;

  const translateX = useSharedValue(width / 2);
  const contextX = useSharedValue(0);

  const gesture = Gesture.Pan()
    .onStart(() => {
      contextX.value = translateX.value;
    })
    .onUpdate((event) => {
      let nextX = contextX.value + event.translationX;
      if (nextX < 0) nextX = 0;
      if (nextX > width) nextX = width;
      translateX.value = nextX;
    });

  const beforeStyle = useAnimatedStyle(() => ({
    width: translateX.value,
  }));

  const sliderStyle = useAnimatedStyle(() => ({
    transform: [{ translateX: translateX.value - 20 }],
  }));

  const handleShare = async () => {
    if (await Sharing.isAvailableAsync()) {
      await Sharing.shareAsync(generatedImage);
    }
  };

  const handleDownload = async () => {
    alert('Tasarım galeriye kaydedildi!');
  };

  return (
    <View className="flex-1 bg-black">
      {/* Header */}
      <View className="pt-14 px-6 flex-row items-center justify-between mb-6">
        <TouchableOpacity
          onPress={() => navigation.goBack()}
          className="bg-white/10 p-3 rounded-full"
        >
          <ChevronLeft size={24} color="white" />
        </TouchableOpacity>
        <Text className="text-white font-black text-lg uppercase tracking-widest">Sonuç</Text>
        <View className="w-12" />
      </View>

      {/* Slider Container */}
      <View className="relative w-full overflow-hidden" style={{ height: IMAGE_HEIGHT }}>
        {/* After Image */}
        <Image
          source={{ uri: generatedImage }}
          className="w-full h-full"
          resizeMode="cover"
        />

        {/* Before Image */}
        <Animated.View
          className="absolute left-0 top-0 h-full overflow-hidden border-r-2 border-white"
          style={[beforeStyle]}
        >
          <Image
            source={{ uri: originalImage }}
            style={{ width: width, height: IMAGE_HEIGHT }}
            resizeMode="cover"
          />
          <View className="absolute top-4 left-4 bg-black/60 px-3 py-1 rounded-full border border-white/20">
            <Text className="text-white text-[10px] font-black uppercase tracking-tighter">Öncesi</Text>
          </View>
        </Animated.View>

        <View className="absolute top-4 right-4 bg-primary/80 px-3 py-1 rounded-full border border-white/20">
          <Text className="text-white text-[10px] font-black uppercase tracking-tighter">Sonrası</Text>
        </View>

        {/* Custom Slider Handle */}
        <GestureDetector gesture={gesture}>
          <Animated.View
            className="absolute top-0 bottom-0 w-10 items-center justify-center"
            style={[sliderStyle]}
          >
            <View className="w-[2px] h-full bg-white/50 shadow-lg" />
            <View className="absolute bg-white w-10 h-10 rounded-full items-center justify-center shadow-2xl border-2 border-primary">
              <View className="flex-row items-center">
                <View className="w-[3px] h-4 bg-primary rounded-full mx-0.5" />
                <View className="w-[3px] h-4 bg-primary rounded-full mx-0.5" />
              </View>
            </View>
          </Animated.View>
        </GestureDetector>
      </View>

      <View className="flex-1 px-8 pt-10">
        <MotiView
          from={{ opacity: 0, translateY: 20 }}
          animate={{ opacity: 1, translateY: 0 }}
          className="bg-luxury-gray p-8 rounded-[40px] border border-white/5 shadow-2xl"
        >
          <View className="flex-row items-center mb-5">
            <View className="bg-secondary/20 p-2 rounded-lg">
              <Sparkles size={20} color={COLORS.gold} />
            </View>
            <Text className="text-white font-black ml-3 text-lg tracking-tight">AI Analiz Notu</Text>
          </View>
          <Text className="text-gray-400 text-sm leading-6 font-medium">
            Odanızdaki mimari yapı korunarak, seçtiğiniz modern stilde profesyonel render alındı. Işıklandırma ve malzeme dokuları gerçekçi seviyeye çekildi.
          </Text>
        </MotiView>

        <View className="flex-row mt-10 space-x-4">
          <TouchableOpacity
            onPress={handleDownload}
            activeOpacity={0.8}
            className="flex-1 bg-luxury-gray h-20 rounded-[30px] border border-white/5 flex-row items-center justify-center shadow-lg"
          >
            <Download size={24} color="white" />
            <Text className="text-white font-black ml-3 uppercase tracking-widest text-xs">Kaydet</Text>
          </TouchableOpacity>

          <TouchableOpacity
            onPress={handleShare}
            activeOpacity={0.8}
            className="flex-1 bg-primary h-20 rounded-[30px] flex-row items-center justify-center shadow-xl shadow-primary/30"
          >
            <Share2 size={24} color="white" />
            <Text className="text-white font-black ml-3 uppercase tracking-widest text-xs">Paylaş</Text>
          </TouchableOpacity>
        </View>
      </View>
    </View>
  );
};

export default ResultScreen;
