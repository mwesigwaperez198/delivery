import { Router } from 'express';
import { getMerchantProfile, updateInventory, signalOrderReady } from '../controllers/merchantController';
import { authenticate, authorize } from '../middleware/authMiddleware';

const router = Router();

// Only Merchants can access these
router.get('/profile', authenticate, authorize(['Merchant']), getMerchantProfile);
router.patch('/inventory', authenticate, authorize(['Merchant']), updateInventory);
router.post('/order-ready', authenticate, authorize(['Merchant']), signalOrderReady);

export default router;
