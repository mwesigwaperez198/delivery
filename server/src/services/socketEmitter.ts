import { io } from '../index';

export const SocketEmitter = {
  /**
   * Broadcasts high-level system health and financials to all Admins.
   */
  emitSystemUpdate: (summary: any) => {
    io.to('admin').emit('system_summary_update', summary);
  },

  /**
   * Notifies a specific courier of a new duty match from the AI engine.
   */
  emitNewAssignment: (courierId: string, orderData: any) => {
    io.to(`courier_${courierId}`).emit('new_assignment', orderData);
  },

  /**
   * Emits a 'Behavior Alert' to Admins when a courier acts out of character
   * (e.g., multiple cancellations or battery ghosting).
   */
  emitBehaviorAnomaly: (courierName: string, anomalyType: string, severity: 'Low' | 'High') => {
    io.to('admin').emit('behavior_alert', {
      courierName,
      anomalyType,
      severity,
      timestamp: new Date(),
    });
  },

  /**
   * Pushes a live financial event (Sale/Commission) to the Admin dashboard.
   */
  emitFinancialTick: (amount: number, type: string) => {
    io.to('admin').emit('financial_tick', { amount, type, time: new Date() });
  },

  /**
   * Generic notification emitter for targeted events.
   */
  emitGeneric: (targetRoom: string, event: string, payload: any) => {
    io.to(targetRoom).emit(event, payload);
  }
};
