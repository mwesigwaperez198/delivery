import { Schema, model } from 'mongoose';

const telemetrySchema = new Schema({
  appId: { type: String, required: true, index: true },
  category: {
    type: String,
    required: true,
    enum: ['health', 'finance', 'behavior'],
    index: true
  },
  event: { type: String, required: true },
  data: { type: Schema.Types.Mixed, default: {} },
  timestamp: { type: Date, default: Date.now, expires: '30d' } // AUTO-PURGE: Clears logs after 30 days
});

// Index for faster queries in the Admin Dashboard
telemetrySchema.index({ timestamp: -1 });
telemetrySchema.index({ category: 1, timestamp: -1 });

export const Telemetry = model('Telemetry', telemetrySchema);
