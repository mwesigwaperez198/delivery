import axios from 'axios';

const API_BASE_URL = 'http://localhost:3000/api/monitor';
const APP_ID = 'merchant_app';

const monitoringService = {
  logEvent: async (category, event, data = {}) => {
    try {
      const payload = {
        appId: APP_ID,
        category,
        event,
        data,
        timestamp: new Date().toISOString(),
      };
      await axios.post(`${API_BASE_URL}/log`, payload);
      console.log(`[MONITOR] Telemetry sent: ${event}`);
    } catch (error) {
      console.error(`[MONITOR] Failed to send telemetry: ${error.message}`);
    }
  },

  trackHealth: (status) => {
    return monitoringService.logEvent('health', 'heartbeat', { status });
  },

  trackFinance: (amount, transactionType) => {
    return monitoringService.logEvent('finance', 'transaction', { amount, type: transactionType });
  },

  trackBehavior: (action, screenName) => {
    return monitoringService.logEvent('behavior', 'user_action', { action, screen: screenName });
  }
};

export default monitoringService;
