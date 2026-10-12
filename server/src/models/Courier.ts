import { Schema, model } from 'mongoose';

const courierSchema = new Schema({
  name: { type: String, required: true },
  phone: { type: String, required: true },
  isOnline: { type: Boolean, default: false },
  status: { type: String, enum: ['Available', 'Busy', 'Offline', 'PendingApproval'], default: 'Offline' },
  vehicleType: { type: String, enum: ['Bicycle', 'Motorcycle'], required: true },
  currentLocation: {
    type: { type: String, default: 'Point' },
    coordinates: { type: [Number], required: true }, // [lng, lat]
  },
  lastPing: { type: Date, default: Date.now },
  deviceStats: {
    batteryLevel: { type: Number, default: 100 },
    signalStrength: { type: String, default: 'Good' }
  },
  currentOrderId: { type: Schema.Types.ObjectId, ref: 'Order', default: null },
  fcmToken: { type: String }
});

courierSchema.index({ currentLocation: '2dsphere' });
export const Courier = model('Courier', courierSchema);
