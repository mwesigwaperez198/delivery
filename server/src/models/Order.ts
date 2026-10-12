import mongoose, { Schema, Document } from 'mongoose';

export interface IOrder extends Document {
  customerId: string;
  merchantId: string;
  carrierId?: string;
  items: Array<{
    productId: string;
    quantity: number;
    price: number;
  }>;
  totalAmount: number;
  status: 'pending' | 'accepted' | 'picked_up' | 'delivered' | 'cancelled';
  deliveryLocation: {
    lat: number;
    lng: number;
    address: string;
  };
}

const OrderSchema: Schema = new Schema({
  customerId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  merchantId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  carrierId: { type: Schema.Types.ObjectId, ref: 'User' },
  items: [{
    productId: { type: Schema.Types.ObjectId, ref: 'Product' },
    quantity: Number,
    price: Number
  }],
  totalAmount: { type: Number, required: true },
  status: {
    type: String,
    enum: ['pending', 'accepted', 'picked_up', 'delivered', 'cancelled'],
    default: 'pending'
  },
  deliveryLocation: {
    lat: Number,
    lng: Number,
    address: String
  }
}, { timestamps: true });

export default mongoose.model<IOrder>('Order', OrderSchema);
