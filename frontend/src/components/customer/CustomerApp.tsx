import React, { useState } from 'react';
import { useApp } from '../../context/AppContext';
import { Menu } from './Menu';
import { OrderSummary } from './OrderSummary';
import { useParams } from 'react-router-dom';
import logoCustomer from '../../assets/logo-customer.png';
import { ConsumerDetailsModal } from './ConsumerDetailsModal';


export const CustomerApp: React.FC = () => {
    const { session, currentUser, callWaiter, /*requestBill,*/ addConsumerToSession, leaveSession } = useApp();
    const [activeTab, setActiveTab] = useState<'menu' | 'bill'>('menu');
    const [showAddPerson, setShowAddPerson] = useState(false);
    const [newPersonName, setNewPersonName] = useState('');
    const [selectedConsumerId, setSelectedConsumerId] = useState<string | null>(null);

    const { tableNumber } = useParams<{ tableNumber: string }>();

    const handleAddPerson = () => {
        if (newPersonName.trim()) {
            addConsumerToSession(newPersonName.trim());
            setNewPersonName('');
            setShowAddPerson(false);
        }
    };

    return (
        <div className="page-container">
            {/* Header */}
            <header className="page-header">
                <img src={logoCustomer} alt="Tab" style={{ width: 140, marginBottom: 'var(--spacing-xs)' }} />
                <div style={{ width: 60, height: 2, background: '#fff', margin: '0 auto var(--spacing-md)' }} />


                <h1 className="page-title">MESA {/*{session?.tableId}*/} {tableNumber}</h1>


                <p className="page-subtitle">
                    {currentUser?.name} • {session?.consumers?.length || 0} persona(s)
                </p>

                {/* People at table */}
                <div style={{
                    display: 'flex',
                    justifyContent: 'center',
                    gap: 'var(--spacing-sm)',
                    marginTop: 'var(--spacing-md)',
                    flexWrap: 'wrap'
                }}>
                    {session?.consumers?.map((consumer) => {
                        const isMe = consumer.id === currentUser?.id;
                        const isSelected = consumer.id === selectedConsumerId;
                        return (
                        <button
                            key={consumer.id}
                            onClick={() => setSelectedConsumerId(consumer.id)}
                            style={{
                                padding: '0.5rem 1rem',
                                borderRadius: 'var(--radius-md)',
                                background: isSelected ? 'var(--color-primary)' : isMe ? 'var(--color-primary-client)' : 'var(--color-surface)',
                                color: (isMe || isSelected) ? '#000' : 'var(--color-text)',
                                fontSize: '0.875rem',
                                fontWeight: 500,
                                border: isSelected ? '2px solid #fff' : '2px solid transparent',
                                cursor: 'pointer',
                                transition: 'all 0.2s ease',
                                opacity: 0.9,
                            }}
                            onMouseEnter={(e) => e.currentTarget.style.opacity = '1'}
                            onMouseLeave={(e) => e.currentTarget.style.opacity = '0.9'}
                        >
                            {consumer.name} {isMe && '(Yo)'}
                        </button>
                    )})}
                    <button
                        onClick={() => setShowAddPerson(true)}
                        style={{
                            padding: '0.5rem 1rem',
                            borderRadius: 'var(--radius-md)',
                            background: 'transparent',
                            border: '2px dashed var(--color-border)',
                            color: 'var(--color-text-muted)',
                            fontSize: '0.875rem',
                            cursor: 'pointer',
                        }}
                    >
                        + Agregar
                    </button>
                </div>
            </header>

            {/* Add Person Modal */}
            {showAddPerson && (
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
                        maxWidth: 400,
                        width: '100%',
                        textAlign: 'center',
                    }}>
                        <h2 style={{ marginBottom: 'var(--spacing-lg)' }}>Agregar Persona</h2>
                        <input
                            type="text"
                            placeholder="Nombre..."
                            value={newPersonName}
                            onChange={(e) => setNewPersonName(e.target.value)}
                            onKeyDown={(e) => e.key === 'Enter' && handleAddPerson()}
                            className="form-input"
                            autoFocus
                        />
                        <div style={{ display: 'flex', gap: 'var(--spacing-sm)', marginTop: 'var(--spacing-lg)' }}>
                            <button
                                onClick={() => setShowAddPerson(false)}
                                style={{
                                    flex: 1,
                                    padding: '0.75rem',
                                    borderRadius: 'var(--radius-md)',
                                    background: 'transparent',
                                    border: '1px solid var(--color-border)',
                                    color: 'var(--color-text)',
                                    cursor: 'pointer',
                                }}
                            >
                                Cancelar
                            </button>
                            <button
                                onClick={handleAddPerson}
                                className="form-button"
                                style={{ flex: 1, marginTop: 0 }}
                            >
                                Agregar
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {/* Consumer Details Modal */}
            {selectedConsumerId && (
                <ConsumerDetailsModal 
                    consumerId={selectedConsumerId} 
                    onClose={() => setSelectedConsumerId(null)} 
                />
            )}

            {/* Content */}
            <main style={{ paddingBottom: '120px' }}>
                {activeTab === 'menu' ? <Menu /> : <OrderSummary />}
            </main>

            {/* Bottom Navigation */}
            <div className="bottom-nav">
                <button
                    className={`nav-button ${activeTab === 'menu' ? 'active' : 'inactive'}`}
                    onClick={() => setActiveTab('menu')}
                    style={activeTab === 'menu' ? { backgroundColor: 'var(--color-primary-client)' } : {}}
                >
                    MENÚ
                </button>
                <button
                    className={`nav-button ${activeTab === 'bill' ? 'active' : 'inactive'}`}
                    onClick={() => setActiveTab('bill')}
                    style={activeTab === 'bill' ? { backgroundColor: 'var(--color-primary-client)' } : {}}
                >
                    MI CUENTA
                </button>
                <button
                    className="nav-button inactive"
                    onClick={callWaiter}
                >
                    🔔 MOZO
                </button>
                {/* <button
                    className="nav-button inactive"
                    onClick={requestBill}
                >
                    💳 CUENTA
                </button> */}
                <button
                    className="nav-button inactive"
                    onClick={leaveSession}
                    style={{ color: '#d32f2f' }}
                >
                    SALIR
                </button>
            </div>
        </div>
    );
};
