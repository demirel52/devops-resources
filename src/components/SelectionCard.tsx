import React from 'react';
import { TouchableOpacity, Text, View } from 'react-native';
import { MotiView } from 'moti';
import { Sparkles } from 'lucide-react-native';
import { COLORS } from '../constants/theme';

interface SelectionCardProps {
  label: string;
  description?: string;
  isSelected: boolean;
  onPress: () => void;
  accentColor?: string;
}

export const SelectionCard: React.FC<SelectionCardProps> = ({
  label,
  description,
  isSelected,
  onPress,
  accentColor = COLORS.secondary
}) => {
  return (
    <TouchableOpacity
      onPress={onPress}
      activeOpacity={0.7}
      className={`w-[48%] mb-4 p-5 rounded-3xl border-2 ${
        isSelected ? 'bg-luxury-gray shadow-lg shadow-black/50' : 'bg-luxury-gray border-gray-800'
      }`}
      style={isSelected ? { borderColor: accentColor } : {}}
    >
      <Text className={`font-black text-sm ${isSelected ? 'text-white' : 'text-gray-400'}`} style={isSelected ? { color: accentColor } : {}}>
        {label.toUpperCase()}
      </Text>
      {description && (
        <Text className="text-gray-500 text-[10px] mt-1 font-medium">{description}</Text>
      )}
      {isSelected && (
        <MotiView
          from={{ scale: 0 }}
          animate={{ scale: 1 }}
          className="absolute top-3 right-3"
        >
          <Sparkles size={14} color={accentColor} />
        </MotiView>
      )}
    </TouchableOpacity>
  );
};
