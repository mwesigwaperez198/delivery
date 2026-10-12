import { Router } from 'express';
import { acceptOrder, rejectOrder, getPendingApprovals, updateStatus } from '../controllers/courierController';
import { authenticate, authorize } from '../middleware/authMiddleware';

const router = Router();

// Admin: Get pending couriers
router.get('/pending', authenticate, authorize(['Admin']), getPendingApprovals);

// Status update
router.patch('/:id/status', updateStatus);

// Courier: Manage orders
router.post('/accept', authenticate, authorize(['Courier']), acceptOrder);
router.post('/reject', authenticate, authorize(['Courier']), rejectOrder);

export default router;
