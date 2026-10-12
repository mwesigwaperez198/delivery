import mongoose from 'mongoose';
import { Merchant } from './models/Merchant';
import { Product } from './models/Product';
import { User } from './models/User';
import dotenv from 'dotenv';

dotenv.config();

const seed = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/dynamics');
    console.log('Connected to MongoDB for seeding...');

    // 1. Create a Test Merchant User
    const merchantUser = await User.findOneAndUpdate(
      { phoneNumber: '256700000000' },
      {
        fullName: 'Test Vendor Owner',
        password: 'hashed_password',
        role: 'Merchant'
      },
      { upsert: true, new: true }
    );

    // 2. Create a Merchant (Kampala - Acacia Mall area)
    const merchant = await Merchant.findOneAndUpdate(
      { businessName: 'Acacia Cafe' },
      {
        ownerId: merchantUser._id,
        description: 'Best coffee in Kampala',
        category: 'Food & Restaurants',
        location: {
          type: 'Point',
          coordinates: [32.5825, 0.3476], // [lng, lat]
          address: 'Acacia Mall, Kampala',
          landmark: 'Acacia Mall'
        },
        status: 'Verified',
        isOpen: true,
        rating: 4.8
      },
      { upsert: true, new: true }
    );

    // 3. Create Products
    const products = [
      {
        merchantId: merchant._id,
        name: 'Rolex Special',
        description: 'Classic Ugandan Rolex with 3 eggs',
        price: 5000,
        category: 'Main Course',
        isAvailable: true
      },
      {
        merchantId: merchant._id,
        name: 'Cappuccino',
        description: 'Rich espresso with steamed milk',
        price: 8000,
        category: 'Beverages',
        isAvailable: true
      }
    ];

    for (const p of products) {
      await Product.findOneAndUpdate({ name: p.name, merchantId: merchant._id }, p, { upsert: true });
    }

    console.log('✅ Seed data inserted successfully!');
    process.exit();
  } catch (error) {
    console.error('❌ Seeding failed:', error);
    process.exit(1);
  }
};

seed();
