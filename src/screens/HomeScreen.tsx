import React, { useState } from 'react';
import { View, Text, TouchableOpacity, ScrollView, Image, Alert } from 'react-native';
import * as ImagePicker from 'expo-image-picker';
import { Camera, Image as ImageIcon, Sparkles, Home, ChevronRight } from 'lucide-react-native';
import { ROOM_TYPES, DESIGN_STYLES, COLORS } from '../constants/theme';
import { MotiView } from 'moti';

const HomeScreen = () => {
  const [selectedImage, setSelectedImage] = useState<string | null>(null);
  const [selectedRoom, setSelectedRoom] = useState(ROOM_TYPES[0].id);
  const [selectedStyle, setSelectedStyle] = useState(DESIGN_STYLES[0].id);

  const pickImage = async () => {
    const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (status !== 'granted') {
      Alert.alert('İzin Gerekli', 'Galerinize erişmek için izin vermeniz gerekmektedir.');
      return;
    }

    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsEditing: true,
      aspect: [4, 3],
      quality: 0.8,
    });

    if (!result.canceled) {
      setSelectedImage(result.assets[0].uri);
    }
  };

  const takePhoto = async () => {
    const { status } = await ImagePicker.requestCameraPermissionsAsync();
    if (status !== 'granted') {
      Alert.alert('İzin Gerekli', 'Kameraya erişmek için izin vermeniz gerekmektedir.');
      return;
    }

    const result = await ImagePicker.launchCameraAsync({
      allowsEditing: true,
      aspect: [4, 3],
      quality: 0.8,
    });

    if (!result.canceled) {
      setSelectedImage(result.assets[0].uri);
    }
  };

  return (
    <ScrollView className="flex-1 bg-luxury-black pt-12 px-6">
      {/* Header */}
      <MotiView
        from={{ opacity: 0, translateY: -20 }}
        animate={{ opacity: 1, translateY: 0 }}
        className="mb-8"
      >
        <Text className="text-white text-3xl font-bold">DreamSpace AI</Text>
        <Text className="text-gray-400 text-sm mt-1">Hayalindeki odayı saniyeler içinde tasarla</Text>
      </MotiView>

      {/* Photo Picker Section */}
      <View className="mb-8">
        <Text className="text-white text-lg font-semibold mb-4">1. Fotoğraf Yükle</Text>
        {selectedImage ? (
          <View className="relative">
            <Image source={{ uri: selectedImage }} className="w-full h-64 rounded-2xl" resizeMode="cover" />
            <TouchableOpacity
              onPress={() => setSelectedImage(null)}
              className="absolute top-2 right-2 bg-black/50 p-2 rounded-full"
            >
              <Text className="text-white">Değiştir</Text>
            </TouchableOpacity>
          </View>
        ) : (
          <View className="flex-row space-x-4">
            <TouchableOpacity
              onPress={pickImage}
              className="flex-1 bg-luxury-gray h-40 rounded-2xl border border-gray-800 items-center justify-center"
            >
              <ImageIcon size={32} color={COLORS.accent} />
              <Text className="text-white mt-2 font-medium">Galeri</Text>
            </TouchableOpacity>
            <TouchableOpacity
              onPress={takePhoto}
              className="flex-1 bg-luxury-gray h-40 rounded-2xl border border-gray-800 items-center justify-center"
            >
              <Camera size={32} color={COLORS.accent} />
              <Text className="text-white mt-2 font-medium">Kamera</Text>
            </TouchableOpacity>
          </View>
        )}
      </View>

      {/* Room Type Selection */}
      <View className="mb-8">
        <Text className="text-white text-lg font-semibold mb-4">2. Oda Tipi</Text>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} className="flex-row">
          {ROOM_TYPES.map((room) => (
            <TouchableOpacity
              key={room.id}
              onPress={() => setSelectedRoom(room.id)}
              className={`mr-3 px-6 py-3 rounded-full border ${
                selectedRoom === room.id ? 'bg-primary border-primary' : 'bg-luxury-gray border-gray-800'
              }`}
            >
              <Text className={`${selectedRoom === room.id ? 'text-white' : 'text-gray-400'} font-medium`}>
                {room.label}
              </Text>
            </TouchableOpacity>
          ))}
        </ScrollView>
      </View>

      {/* Style Selection */}
      <View className="mb-10">
        <Text className="text-white text-lg font-semibold mb-4">3. Tasarım Stili</Text>
        <View className="flex-row flex-wrap justify-between">
          {DESIGN_STYLES.map((style) => (
            <TouchableOpacity
              key={style.id}
              onPress={() => setSelectedStyle(style.id)}
              className={`w-[48%] mb-4 p-4 rounded-2xl border ${
                selectedStyle === style.id ? 'bg-luxury-gray border-secondary' : 'bg-luxury-gray border-gray-800'
              }`}
            >
              <Text className={`font-bold ${selectedStyle === style.id ? 'text-secondary' : 'text-white'}`}>
                {style.label}
              </Text>
              <Text className="text-gray-500 text-xs mt-1">{style.description}</Text>
            </TouchableOpacity>
          ))}
        </View>
      </View>

      {/* Generate Button */}
      <TouchableOpacity
        disabled={!selectedImage}
        className={`w-full py-5 rounded-2xl flex-row items-center justify-center mb-12 ${
          selectedImage ? 'bg-primary' : 'bg-gray-800'
        }`}
      >
        <Sparkles size={20} color="white" className="mr-2" />
        <Text className="text-white font-bold text-lg">Tasarımı Oluştur</Text>
        <ChevronRight size={20} color="white" />
      </TouchableOpacity>
    </ScrollView>
  );
};

export default HomeScreen;
