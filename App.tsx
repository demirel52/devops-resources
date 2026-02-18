import { StatusBar } from 'expo-status-bar';
import { SafeAreaView } from 'react-native';
import "./src/styles/global.css";
import HomeScreen from './src/screens/HomeScreen';

export default function App() {
  return (
    <SafeAreaView className="flex-1 bg-black">
      <HomeScreen />
      <StatusBar style="light" />
    </SafeAreaView>
  );
}
