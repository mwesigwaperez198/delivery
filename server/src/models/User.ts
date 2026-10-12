import { Schema, model } from 'mongoose';

const userSchema = new Schema({
  phoneNumber: { type: String, required: true, unique: true },
  email: { type: String, sparse: true },
  fullName: { type: String, required: true },
  password: { type: String, required: true },
  role: {
    type: String,
    enum: ['Customer', 'Merchant', 'Courier', 'Admin'],
    default: 'Customer'
  },
  profilePicture: String,
  primaryLandmark: String,
  savedAddresses: [{
    label: String,
    coordinates: [Number],
    address: String
  }],
  status: { type: String, enum: ['Active', 'Suspended'], default: 'Active' },
  createdAt: { type: Date, default: Date.now }
});

export const User = model('User', userSchema);
