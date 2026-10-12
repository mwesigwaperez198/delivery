import { Request, Response } from 'express';
export const createOrder = async (req: Request, res: Response) => {
  res.status(201).json({ message: 'Order created successfully' });
};