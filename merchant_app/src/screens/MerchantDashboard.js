import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Switch, FlatList, Alert } from 'react-native';
import axios from 'axios';

const API_BASE = 'http://10.0.2.2:3000/api';

const MerchantDashboard = ({ merchantId = 'MERC_KLA_991' }) => {
  const [isSelfDelivery, setIsSelfDelivery] = useState(false);
  const [orders, setOrders] = useState([]);
  const [analytics, setAnalytics] = useState({ todaySales: 0, pendingOrders: 0 });

  useEffect(() => {
    fetchOrders();
    fetchAnalytics();
  }, []);

  const fetchOrders = async () => {
    try {
      const res = await axios.get(`${API_BASE}/merchants/${merchantId}/orders`);
      setOrders(res.data);
    } catch (e) {
      console.error('Order fetch failed', e);
    }
  };

  const fetchAnalytics = async () => {
    // Placeholder for analytics fetch
    setAnalytics({ todaySales: 245000, pendingOrders: orders.length });
  };

  const toggleDeliveryMode = async (value) => {
    setIsSelfDelivery(value);
    try {
      await axios.patch(`${API_BASE}/merchants/${merchantId}`, {
        deliveryMode: value ? 'SelfDelivery' : 'Marketplace'
      });
      Alert.alert("Success", `Switched to ${value ? 'Self Delivery' : 'Marketplace Dispatch'}`);
    } catch (e) {
      setIsSelfDelivery(!value);
      Alert.alert("Error", "Failed to update delivery mode");
    }
  };

  const handleOrderAction = async (orderId, status) => {
    try {
      await axios.patch(`${API_BASE}/orders/${orderId}`, { status });
      fetchOrders();
    } catch (e) {
      Alert.alert("Error", "Action failed");
    }
  };

  const renderOrderItem = ({ item }) => (
    <View style={styles.orderCard}>
      <View style={styles.orderHeader}>
        <Text style={styles.orderId}>#{item._id.slice(-6)}</Text>
        <Text style={styles.orderStatus}>{item.status}</Text>
      </View>
      <Text style={styles.orderDetail}>{item.items.length} items • UGX {item.pricing.totalFee}</Text>
      <Text style={styles.orderCustomer}>Delivery to: {item.deliveryLocation.neighborhood}</Text>

      {item.status === 'Pending' && (
        <View style={styles.actionRow}>
          <TouchableOpacity
            style={[styles.actionBtn, styles.acceptBtn]}
            onPress={() => handleOrderAction(item._id, 'Preparing')}
          >
            <Text style={styles.btnText}>ACCEPT</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.actionBtn, styles.rejectBtn]}
            onPress={() => handleOrderAction(item._id, 'Cancelled')}
          >
            <Text style={styles.btnText}>REJECT</Text>
          </TouchableOpacity>
        </View>
      )}
    </View>
  );

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Merchant Hub</Text>
        <TouchableOpacity style={styles.profileBtn}>
          <View style={styles.avatar} />
        </TouchableOpacity>
      </View>

      <ScrollView showsVerticalScrollIndicator={false}>
        {/* Analytics Section */}
        <View style={styles.statsRow}>
          <View style={styles.statBox}>
            <Text style={styles.statLabel}>Sales Today</Text>
            <Text style={styles.statValue}>UGX {analytics.todaySales.toLocaleString()}</Text>
          </View>
          <View style={styles.statBox}>
            <Text style={styles.statLabel}>Active Orders</Text>
            <Text style={styles.statValue}>{analytics.pendingOrders}</Text>
          </View>
        </View>

        {/* Delivery Toggle */}
        <View style={styles.toggleCard}>
          <View>
            <Text style={styles.toggleTitle}>Self Delivery Mode</Text>
            <Text style={styles.toggleSub}>Use your own riders instead of Novara dispatch</Text>
          </View>
          <Switch
            value={isSelfDelivery}
            onValueChange={toggleDeliveryMode}
            trackColor={{ false: "#767577", true: "#4CAF50" }}
          />
        </View>

        {/* Live Orders Section */}
        <Text style={styles.sectionTitle}>Live Orders</Text>
        <FlatList
          data={orders}
          renderItem={renderOrderItem}
          keyExtractor={item => item._id}
          scrollEnabled={false}
          ListEmptyComponent={<Text style={styles.empty}>No active orders</Text>}
        />
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#F5F5F5', padding: 20 },
  header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginTop: 40, marginBottom: 20 },
  title: { fontSize: 26, fontWeight: 'bold', color: '#151515' }, // Charcoal
  avatar: { width: 40, height: 40, borderRadius: 20, backgroundColor: '#0E9594' }, // Electrical Teal
  statsRow: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: 20 },
  statBox: { backgroundColor: '#FFF', width: '48%', borderRadius: 12, padding: 15, elevation: 2 },
  statLabel: { fontSize: 12, color: '#757575', marginBottom: 5 },
  statValue: { fontSize: 18, fontWeight: 'bold', color: '#0E9594' }, // Electrical Teal
  toggleCard: { backgroundColor: '#FFF', flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', padding: 20, borderRadius: 12, marginBottom: 25, elevation: 2 },
  toggleTitle: { fontSize: 16, fontWeight: 'bold', color: '#151515' },
  toggleSub: { fontSize: 12, color: '#9E9E9E' },
  sectionTitle: { fontSize: 18, fontWeight: 'bold', marginBottom: 15, color: '#151515' },
  orderCard: { backgroundColor: '#FFF', borderRadius: 12, padding: 15, marginBottom: 15, borderLeftWidth: 4, borderLeftColor: '#F5DF4D', elevation: 2 }, // Accent Yellow
  orderHeader: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: 10 },
  orderId: { fontWeight: 'bold', fontSize: 16, color: '#151515' },
  orderStatus: { color: '#0E9594', fontWeight: 'bold', fontSize: 12 },
  orderDetail: { color: '#666', marginBottom: 5 },
  orderCustomer: { color: '#999', fontSize: 12, marginBottom: 15 },
  actionRow: { flexDirection: 'row', justifyContent: 'space-between' },
  actionBtn: { flex: 1, height: 40, borderRadius: 8, justifyContent: 'center', alignItems: 'center' },
  acceptBtn: { backgroundColor: '#0E9594', marginRight: 10 }, // Electrical Teal
  rejectBtn: { backgroundColor: '#151515' }, // Charcoal
  btnText: { color: '#FFF', fontWeight: 'bold' },
  empty: { textAlign: 'center', color: '#999', marginTop: 20 }
});

export default MerchantDashboard;
