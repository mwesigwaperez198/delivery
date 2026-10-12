import mongoose, { Schema, Document } from 'mongoose';

export interface IProduct extends Document {
  name: string;
  description: string;
  price: number;
  category: 'Food' | 'Supermarket' | 'Electrical' | 'Package';
  merchantId: string;
  stock: number;
  imageUrl?: string;
}

const ProductSchema: Schema = new Schema({
  name: { type: String, required: true },
  description: { type: String },
  price: { type: Number, required: true },
  category: {
    type: String,
    enum: ['Food', 'Supermarket', 'Electrical', 'Package'],
    required: true
  },
  merchantId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  stock: { type: Number, default: 0 },
  imageUrl: { type: String }
}, { timestamps: true });

export default mongoose.model<IProduct>('Product', ProductSchema);
