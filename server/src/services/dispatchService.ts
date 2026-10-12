import { Order } from '../models/Order';
import { Courier } from '../models/Courier';
import { SocketEmitter } from './socketEmitter';
import redis from './redisClient';

/**
 * AI Dispatch Engine - Hyperlocal Marketplace (Uganda)
 * Optimized with Redis Caching for Multimillion User Scale
 */
export async function processAutomatedDispatch(orderId: string): Promise<void> {
  try {
    const order = await Order.findById(orderId);
    if (!order || order.status !== 'Pending') return;

    const [pickupLng, pickupLat] = order.pickupLocation.coordinates;
    console.log(`[AI DISPATCH] Processing Order ${orderId} via Redis Hub`);

    // 1. REDIS GEOSPATIAL SEARCH
    let nearbyCourierIds: [string, string][] = [];
    try {
        nearbyCourierIds = await redis.geosearch(
            'active_couriers',
            'FROMLONLAT', pickupLng, pickupLat,
            'BYRADIUS', 5, 'km',
            'WITHDIST'
        ) as [string, string][];
    } catch (e) {
        console.warn('Redis geosearch failed, falling back to basic matching');
    }

    // 2. FETCH COURIERS
    const query: any = {
      status: 'Available',
      isOnline: true,
      'deviceStats.batteryLevel': { $gt: 15 }
    };

    if (nearbyCourierIds.length > 0) {
        query._id = { $in: nearbyCourierIds.map(c => c[0]) };
    }

    const availableCouriers = await Courier.find(query);

    if (availableCouriers.length === 0) {
      SocketEmitter.emitBehaviorAnomaly('SYSTEM', 'NO_COURIERS_IN_RANGE', 'High');
      return;
    }

    // 3. MATCHING ALGORITHM
    const candidates = availableCouriers.map(courier => {
      const redisMatch = nearbyCourierIds.find(c => c[0] === courier.id);
      const distance = redisMatch ? parseFloat(redisMatch[1]) * 1000 : 2000;

      let score = 0;
      score += Math.max(0, 50 - (distance / 100));

      const isHeavy = (order.itemsWeight || 0) > 7 || order.category === 'Carrier/Send Anything';
      const isLongRun = distance > 3000;

      if (courier.vehicleType === 'Motorcycle') {
        if (isHeavy || isLongRun) score += 40;
      } else if (courier.vehicleType === 'Bicycle') {
        if (!isHeavy && !isLongRun) score += 20;
        else score -= 50;
      }

      return { courier, score, distance };
    });

    candidates.sort((a, b) => b.score - a.score);
    const bestMatch = candidates[0];

    // 5. JIT TIMING
    const notifyAtMin = Math.max(0, (order.preparationTime || 20) - 10);
    const delayMs = notifyAtMin * 60000;

    console.log(`[JIT AI] Order ${orderId} Scheduled for ${bestMatch.courier.name}. Notifying in ${notifyAtMin.toFixed(1)} mins.`);

    setTimeout(async () => {
      await assignOrder(orderId, bestMatch.courier._id.toString());
    }, delayMs);

  } catch (error) {
    console.error('[DISPATCH ERROR]', error);
  }
}

async function assignOrder(orderId: string, courierId: string) {
  const order = await Order.findByIdAndUpdate(orderId, {
    status: 'Assigned',
    courierId,
    dispatchedAt: new Date()
  }, { new: true });

  await Courier.findByIdAndUpdate(courierId, {
    status: 'Busy',
    currentOrderId: orderId
  });

  SocketEmitter.emitNewAssignment(courierId, {
    orderId,
    pickupLandmark: (order as any)?.pickupLocation?.landmark,
    deliveryNeighborhood: (order as any)?.deliveryLocation?.neighborhood
  });
}
