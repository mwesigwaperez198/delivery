import { Response } from 'express';
import { Order } from '../models/Order';
import { AuthRequest } from '../middleware/authMiddleware';

export const createOrder = async (req: AuthRequest, res: Response) => {
  try {
    const customerId = req.user?.id;
    const {
      merchantId,
      category,
      items,
      pickupLocation,
      deliveryLocation,
      pricing,
      preparationTime
    } = req.body;

    const order = new Order({
      customerId,
      merchantId,
      category,
      items,
      pickupLocation,
      deliveryLocation,
      pricing,
      preparationTime,
      status: 'Pending'
    });

    await order.save();
    res.status(201).json(order);
  } catch (error) {
    console.error('Create order error:', error);
    res.status(500).json({ message: 'Error creating order', error });
  }
};

export const getOrderStatus = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const order = await Order.findById(id).populate('merchantId courierId');
    if (!order) return res.status(404).json({ message: 'Order not found' });
    res.json(order);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching order status', error });
  }
};

export const getCustomerOrders = async (req: AuthRequest, res: Response) => {
  try {
    const customerId = req.user?.id;
    const orders = await Order.find({ customerId }).sort({ createdAt: -1 });
    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching order history', error });
  }
};

export const updateOrderStatus = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    const order = await Order.findByIdAndUpdate(id, { status }, { new: true });
    if (!order) return res.status(404).json({ message: 'Order not found' });
    res.json(order);
  } catch (error) {
    res.status(500).json({ message: 'Error updating order status', error });
  }
};
