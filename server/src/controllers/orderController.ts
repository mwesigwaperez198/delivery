import { Request, Response } from 'express';
import Order from '../models/Order';

export const createOrder = async (req: Request, res: Response) => {
  try {
    const { customerId, merchantId, items, totalAmount, deliveryLocation } = req.body;
    const order = new Order({
      customerId,
      merchantId,
      items,
      totalAmount,
      deliveryLocation,
      status: 'pending'
    });
    await order.save();
    res.status(201).json(order);
  } catch (error) {
    res.status(500).json({ message: 'Error creating order', error });
  }
};

export const getOrders = async (req: Request, res: Response) => {
  try {
    const orders = await Order.find().populate('customerId merchantId carrierId');
    res.status(200).json(orders);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching orders', error });
  }
};
