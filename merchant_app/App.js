import React, { useEffect } from 'react';
import { StatusBar } from 'expo-status-bar';
import { StyleSheet, View } from 'react-native';
import monitoringService from './services/monitoringService';
import MerchantDashboard from './src/screens/MerchantDashboard';

export default function App() {
  useEffect(() => {
    // Initialize Monitoring
    monitoringService.trackHealth('online');
  }, []);

  return (
    <View style={styles.container}>
      <MerchantDashboard merchantId="MERC_KLA_991" />
      <StatusBar style="auto" />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F5F7FA',
  },
});
