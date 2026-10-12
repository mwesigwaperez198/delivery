import { Schema, model } from 'mongoose';

const cartSchema = new Schema({
  customerId: { type: Schema.Types.ObjectId, ref: 'User', required: true, unique: true },
  merchantId: { type: Schema.Types.ObjectId, ref: 'Merchant' },
  items: [{
    productId: { type: Schema.Types.ObjectId, ref: 'Product' },
    quantity: { type: Number, required: true, min: 1 },
    priceAtTime: Number,
    customizations: [String]
  }],
  totalAmount: { type: Number, default: 0 },
  updatedAt: { type: Date, default: Date.now, expires: '7d' }
});

export const Cart = model('Cart', cartSchema);
