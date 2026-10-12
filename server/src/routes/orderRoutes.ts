import { Router } from 'express';
import { createOrder, getOrderStatus, updateOrderStatus, getCustomerOrders } from '../controllers/orderController';
import { authenticate } from '../middleware/authMiddleware';

const router = Router();

router.post('/create', authenticate, createOrder);
router.get('/:id', authenticate, getOrderStatus);
router.get('/history/me', authenticate, getCustomerOrders);
router.patch('/:id/status', authenticate, updateOrderStatus);

export default router;
