import { Request, Response } from 'express';
import { Courier } from '../models/Courier';
import { Order } from '../models/Order';
import { SocketEmitter } from '../services/socketEmitter';

export const acceptOrder = async (req: Request, res: Response) => {
  try {
    const { orderId } = req.body;
    const courierId = (req as any).user.id;

    const order = await Order.findByIdAndUpdate(orderId, {
      status: 'Accepted',
      courierId,
      acceptedAt: new Date()
    }, { new: true });

    await Courier.findByIdAndUpdate(courierId, {
      status: 'Busy',
      currentOrderId: orderId
    });

    SocketEmitter.emitGeneric(`customer_${order?.customerId}`, 'order_accepted', {
      orderId,
      courierId
    });

    res.json({ success: true, order });
  } catch (error) {
    res.status(500).json({ message: 'Accept failed' });
  }
};

export const rejectOrder = async (req: Request, res: Response) => {
    // Logic to find next best courier if rejected
    res.json({ success: true });
};

export const getPendingApprovals = async (req: Request, res: Response) => {
    try {
        const couriers = await Courier.find({ status: 'PendingApproval' });
        res.json(couriers);
    } catch (e) {
        res.status(500).json({ message: 'Failed to fetch pending couriers' });
    }
};

export const updateStatus = async (req: Request, res: Response) => {
  try {
    const { status } = req.body;
    const courier = await Courier.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true }
    );
    res.json(courier);
  } catch (e) {
    res.status(500).json({ message: 'Status update failed' });
  }
};
