import { Schema, model } from 'mongoose';

const productSchema = new Schema({
  merchantId: { type: Schema.Types.ObjectId, ref: 'Merchant', required: true },
  name: { type: String, required: true },
  description: String,
  price: { type: Number, required: true },
  category: { type: String, required: true },
  image: String,
  isAvailable: { type: Boolean, default: true },
  discountPrice: Number,
  tags: [String],
  metadata: {
    calories: Number,
    weight: Number,
    isVegan: Boolean,
  },
  createdAt: { type: Date, default: Date.now }
});

productSchema.index({ merchantId: 1, category: 1 });
export const Product = model('Product', productSchema);
