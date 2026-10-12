import mongoose, { Schema, Document } from 'mongoose';

export interface IUser extends Document {
  name: string;
  email: string;
  role: 'customer' | 'merchant' | 'carrier' | 'admin';
  status: string;
  location?: {
    lat: number;
    lng: number;
  };
  isActivated: boolean;
}

const UserSchema: Schema = new Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  role: { type: String, enum: ['customer', 'merchant', 'carrier', 'admin'], default: 'customer' },
  status: { type: String, default: 'Available' },
  location: {
    lat: Number,
    lng: Number
  },
  isActivated: { type: Boolean, default: false }
}, { timestamps: true });

export default mongoose.model<IUser>('User', UserSchema);
