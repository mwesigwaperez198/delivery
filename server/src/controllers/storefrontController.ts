import { Request, Response } from 'express';
import { Merchant } from '../models/Merchant';
import { Product } from '../models/Product';
import { Cart } from '../models/Cart';
import { AuthRequest } from '../middleware/authMiddleware';

/**
 * Storefront Service: Handles high-traffic browsing and cart logic.
 */
export const getNearbyMerchants = async (req: Request, res: Response) => {
  try {
    const { lat, lng, category } = req.query;

    if (!lat || !lng) {
      return res.status(400).json({ message: 'Latitude and longitude are required' });
    }

    const query: any = {
      status: 'Verified',
      isOpen: true,
      location: {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: [parseFloat(lng as string), parseFloat(lat as string)]
          },
          $maxDistance: 10000 // 10km radius
        }
      }
    };

    if (category) query.category = category;

    const merchants = await Merchant.find(query).limit(50);
    res.json(merchants);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching merchants', error });
  }
};

export const getNearbyProducts = async (req: Request, res: Response) => {
  try {
    const { lat, lng, category } = req.query;

    if (!lat || !lng) {
      return res.status(400).json({ message: 'Latitude and longitude are required' });
    }

    const merchants = await Merchant.find({
      status: 'Verified',
      isOpen: true,
      location: {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: [parseFloat(lng as string), parseFloat(lat as string)]
          },
          $maxDistance: 10000
        }
      }
    }).select('_id');

    const merchantIds = merchants.map(m => m._id);

    const products = await Product.find({
      merchantId: { $in: merchantIds },
      isAvailable: true,
      category: category ? new RegExp(category as string, 'i') : { $exists: true }
    }).limit(40).populate('merchantId', 'businessName logo');

    res.json(products);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching products', error });
  }
};

export const getMerchantCatalog = async (req: Request, res: Response) => {
  try {
    const { merchantId } = req.params;

    const [merchant, products] = await Promise.all([
      Merchant.findById(merchantId),
      Product.find({ merchantId, isAvailable: true })
    ]);

    if (!merchant) return res.status(404).json({ message: 'Merchant not found' });

    res.json({ merchant, products });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching catalog', error });
  }
};

export const syncCart = async (req: AuthRequest, res: Response) => {
  try {
    const customerId = req.user?.id;
    const { merchantId, items } = req.body;

    let totalAmount = 0;
    for (const item of items) {
      const product = await Product.findById(item.productId);
      if (product) {
        totalAmount += (product.price * item.quantity);
        item.priceAtTime = product.price;
      }
    }

    const cart = await Cart.findOneAndUpdate(
      { customerId },
      { merchantId, items, totalAmount, updatedAt: new Date() },
      { upsert: true, new: true }
    );

    res.json(cart);
  } catch (error) {
    res.status(500).json({ message: 'Cart sync failed', error });
  }
};

export const getCart = async (req: AuthRequest, res: Response) => {
  try {
    const cart = await Cart.findOne({ customerId: req.user?.id }).populate('items.productId');
    res.json(cart || { items: [], totalAmount: 0 });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching cart', error });
  }
};
