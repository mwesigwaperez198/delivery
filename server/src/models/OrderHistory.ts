import { Schema, model } from 'mongoose';

const orderHistorySchema = new Schema({
  orderId: { type: Schema.Types.ObjectId, ref: 'Order', required: true },
  status: { type: String, required: true },
  timestamp: { type: Date, default: Date.now },
  updatedBy: { type: Schema.Types.ObjectId, ref: 'User' },
  note: String, // e.g., "Courier reached Acacia Mall"
  metadata: Object // Stores GPS pin at time of status change
});

// Indexing for rapid audit retrieval
orderHistorySchema.index({ orderId: 1, timestamp: -1 });

export const OrderHistory = model('OrderHistory', orderHistorySchema);
