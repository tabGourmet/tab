import React, { useMemo } from 'react';
import { useApp } from '../../context/AppContext';
import { calculateConsumerTotal } from '../../utils/orderCalculations';

interface ConsumerDetailsModalProps {
    consumerId: string;
    onClose: () => void;
}

export const ConsumerDetailsModal: React.FC<ConsumerDetailsModalProps> = ({ consumerId, onClose }) => {
    const { session, currentUser } = useApp();

    const consumer = useMemo(() => {
        return session?.consumers?.find(c => c.id === consumerId);
    }, [session, consumerId]);

    const consumerData = useMemo(() => {
        if (!session || !consumerId) return { total: 0, items: [] };
        return calculateConsumerTotal(session.orders, consumerId);
    }, [session, consumerId]);

    const isMe = currentUser?.id === consumerId;
    const displayName = consumer?.name ? `${consumer.name}${isMe ? ' (Yo)' : ''}` : 'Comensal';

    return (
        <div style={{
            position: 'fixed',
            inset: 0,
            background: 'rgba(0,0,0,0.9)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            zIndex: 100,
            padding: 'var(--spacing-md)',
        }}>
            <div style={{
                background: 'var(--color-surface)',
                borderRadius: 'var(--radius-lg)',
                padding: 'var(--spacing-xl)',
                maxWidth: 500,
                width: '100%',
                maxHeight: '90vh',
                overflowY: 'auto',
                display: 'flex',
                flexDirection: 'column'
            }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 'var(--spacing-lg)' }}>
                    <h2 style={{ margin: 0 }}>Consumo de {displayName}</h2>
                    <button 
                        onClick={onClose}
                        style={{ background: 'transparent', border: 'none', color: 'var(--color-text-muted)', fontSize: '1.5rem', cursor: 'pointer' }}
                    >
                        ×
                    </button>
                </div>

                {consumerData.items.length === 0 ? (
                    <div className="text-center" style={{ padding: 'var(--spacing-xl) 0' }}>
                        <p style={{ fontSize: '2.5rem', marginBottom: 'var(--spacing-sm)' }}>🍽️</p>
                        <p className="text-muted">No hay consumos para este usuario.</p>
                        <p className="summary-amount" style={{ marginTop: 'var(--spacing-md)' }}>$0</p>
                    </div>
                ) : (
                    <>
                        <div className="summary-card" style={{ marginBottom: 'var(--spacing-lg)' }}>
                            <p className="summary-label">Total Estimado</p>
                            <p className="summary-amount">${consumerData.total.toLocaleString()}</p>
                        </div>
                        
                        <h3 className="menu-section-title">DETALLE</h3>
                        <div style={{ flex: 1, overflowY: 'auto' }}>
                            {consumerData.items.map((item, idx) => (
                                <div key={idx} className="summary-item">
                                    <div className="summary-item-left">
                                        <div className="summary-item-qty">{item.quantity}</div>
                                        <div>
                                            <p className="summary-item-name">{item.name}</p>
                                            {item.isShared && (
                                                <p style={{ fontSize: '0.75rem', color: 'var(--color-text-muted)' }}>Compartido</p>
                                            )}
                                        </div>
                                    </div>
                                    <span className="summary-item-price">${item.sharePrice.toLocaleString()}</span>
                                </div>
                            ))}
                        </div>
                    </>
                )}

                <button
                    onClick={onClose}
                    className="form-button"
                    style={{ marginTop: 'var(--spacing-xl)' }}
                >
                    Cerrar
                </button>
            </div>
        </div>
    );
};
