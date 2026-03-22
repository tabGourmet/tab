import type { Order } from '../types';

export interface CalculatedItem {
    name: string;
    quantity: number;
    sharePrice: number;
    isShared: boolean;
}

export interface ConsumerTotalInfo {
    total: number;
    items: CalculatedItem[];
}

export function calculateConsumerTotal(orders: Order[], consumerId: string): ConsumerTotalInfo {
    let total = 0;
    const calculatedItems: CalculatedItem[] = [];

    if (!orders || orders.length === 0 || !consumerId) {
        return { total, items: calculatedItems };
    }

    orders.forEach((order) => {
        if (!order || !order.items) return;
        
        order.items.forEach((item) => {
            if (item.consumerIds && item.consumerIds.includes(consumerId)) {
                const splitFactor = item.consumerIds.length;
                const priceShare = (item.product.price * item.quantity) / splitFactor;

                total += priceShare;
                calculatedItems.push({
                    name: item.product.name,
                    quantity: item.quantity,
                    sharePrice: priceShare,
                    isShared: splitFactor > 1,
                });
            }
        });
    });

    return { total, items: calculatedItems };
}
