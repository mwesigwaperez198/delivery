import { Schema, model } from 'mongoose';

const orderSchema = new Schema({
  customerId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  merchantId: { type: Schema.Types.ObjectId, ref: 'Merchant', required: true },
  category: {
    type: String,
    enum: [
      'Food & Restaurants',
      'Groceries & Supermarkets',
      'Pharmacy & Health',
      'Shops & Retail',
      'Alcohol & Drinks',
      'Services',
      'Carrier/Send Anything'
    ],
    required: true
  },
  pickupLocation: {
    type: { type: String, default: 'Point' },
    coordinates: { type: [Number], required: true }, // [lng, lat]
    address: String,
    landmark: String
  },
  deliveryLocation: {
    type: { type: String, default: 'Point' },
    coordinates: { type: [Number], required: true },
    address: String,
    neighborhood: String
  },
  status: {
    type: String,
    enum: ['Pending', 'Accepted', 'Preparing', 'ReadyForPickup', 'Assigned', 'PickedUp', 'Arrived', 'Delivered', 'Completed', 'Cancelled'],
    default: 'Pending'
  },
  items: [{
    productId: { type: Schema.Types.ObjectId, ref: 'Product' },
    quantity: { type: Number, required: true },
    priceAtTime: Number
  }],
  preparationTime: { type: Number, default: 20 }, // in minutes
  itemsWeight: { type: Number, default: 0 }, // in kg
  pricing: {
    totalFee: { type: Number, required: true },
    courierEarning: { type: Number, default: 0 },
    appCommission: { type: Number, default: 0 },
    distanceKm: { type: Number, default: 0 },
    currency: { type: String, default: 'UGX' }
  },
  courierId: { type: Schema.Types.ObjectId, ref: 'User', default: null },
  acceptedAt: Date,
  dispatchedAt: Date,
  verification: {
    photoUrl: String,
    signatureUrl: String,
    completedAt: Date
  },
  createdAt: { type: Date, default: Date.now }
});

orderSchema.index({ pickupLocation: '2dsphere' });
export const Order = model('Order', orderSchema);
