import { Schema, model } from 'mongoose';

const merchantSchema = new Schema({
  ownerId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  businessName: { type: String, required: true },
  description: String,
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
  logo: String,
  banner: String,
  location: {
    type: { type: String, default: 'Point' },
    coordinates: { type: [Number], required: true }, // [lng, lat]
    address: String,
    landmark: String
  },
  rating: { type: Number, default: 0 },
  reviewCount: { type: Number, default: 0 },
  isOpen: { type: Boolean, default: true },
  deliveryMode: {
    type: String,
    enum: ['Marketplace', 'SelfDelivery', 'Hybrid'],
    default: 'Marketplace'
  },
  preparationTimeAverage: { type: Number, default: 20 },
  commissionRate: { type: Number, default: 15 },
  status: { type: String, enum: ['Pending', 'Verified', 'Suspended'], default: 'Pending' },
  createdAt: { type: Date, default: Date.now }
});

merchantSchema.index({ location: '2dsphere' });
export const Merchant = model('Merchant', merchantSchema);
