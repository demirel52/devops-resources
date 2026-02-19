import { StatusBar } from 'expo-status-bar';
import { SafeAreaView, View } from 'react-native';
import HomeScreen from './src/screens/HomeScreen';

export default function App() {
  return (
    <View className="flex-1 bg-black">
      <SafeAreaView className="flex-1">
        <HomeScreen />
      </SafeAreaView>
      <StatusBar style="light" />
    </View>
  );
}
