import 'react-native-gesture-handler';
import { StatusBar } from 'expo-status-bar';
import { View } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import AppNavigator from './src/navigation/AppNavigator';

export default function App() {
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <NavigationContainer>
        <View className="flex-1 bg-black">
          <AppNavigator />
          <StatusBar style="light" />
        </View>
      </NavigationContainer>
    </GestureHandlerRootView>
  );
}
