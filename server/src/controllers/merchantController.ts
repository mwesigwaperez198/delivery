import { Response } from 'express';
import { Merchant } from '../models/Merchant';
import { Product } from '../models/Product';
import { Order } from '../models/Order';
import { OrderHistory } from '../models/OrderHistory';
import { AuthRequest } from '../middleware/authMiddleware';
import { SocketEmitter } from '../services/socketEmitter';

export const getMerchantProfile = async (req: AuthRequest, res: Response) => {
  try {
    const merchant = await Merchant.findOne({ ownerId: req.user?.id });
    if (!merchant) return res.status(404).json({ message: 'Merchant not found' });
    res.json(merchant);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

export const updateInventory = async (req: AuthRequest, res: Response) => {
  try {
    const { productId, isAvailable, price } = req.body;
    const merchant = await Merchant.findOne({ ownerId: req.user?.id });

    const product = await Product.findOneAndUpdate(
      { _id: productId, merchantId: merchant?._id },
      { isAvailable, price },
      { new: true }
    );

    res.json({ message: 'Inventory updated', product });
  } catch (error) {
    res.status(500).json({ message: 'Update failed' });
  }
};

export const signalOrderReady = async (req: AuthRequest, res: Response) => {
  try {
    const { orderId } = req.body;
    const order = await Order.findByIdAndUpdate(orderId, { status: 'ReadyForPickup' }, { new: true });

    if (order) {
      await OrderHistory.create({
        orderId,
        status: 'ReadyForPickup',
        note: 'Merchant signaled order is ready for pickup',
        updatedBy: req.user?.id
      });

      // Notify the assigned courier immediately
      if (order.courierId) {
        SocketEmitter.emitGeneric(order.courierId.toString(), 'ORDER_READY_FOR_PICKUP', {
          orderId: order._id,
          pickupLandmark: order.pickupLocation.landmark
        });
      }
    }

    res.json({ success: true, message: 'Courier notified.' });
  } catch (error) {
    res.status(500).json({ message: 'Signaling failed' });
  }
};
