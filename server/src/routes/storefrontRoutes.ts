import { Router } from 'express';
import {
  getNearbyMerchants,
  getNearbyProducts,
  getMerchantCatalog,
  syncCart,
  getCart
} from '../controllers/storefrontController';
import { authenticate } from '../middleware/authMiddleware';

const router = Router();

// Public/Authenticated browsing
router.get('/merchants/nearby', getNearbyMerchants);
router.get('/products/nearby', getNearbyProducts);
router.get('/merchants/:merchantId/catalog', getMerchantCatalog);

// Authenticated Cart management
router.post('/cart/sync', authenticate, syncCart);
router.get('/cart', authenticate, getCart);

export default router;
