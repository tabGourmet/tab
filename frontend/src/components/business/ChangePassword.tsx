import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';


const ChangePassword: React.FC = () => {
    const [currentPassword, setCurrentPassword] = useState('');
    const [newPassword, setNewPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');
    const [error, setError] = useState('');
    const [success, setSuccess] = useState(false);
    const [isLoading, setIsLoading] = useState(false);

    // const { token } = useAuth(); // Asumiendo que tu context expone el token
    const navigate = useNavigate();

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setError('');
        setSuccess(false);
        const token = localStorage.getItem('gs_token');
        // Validación básica en el cliente
        if (newPassword !== confirmPassword) {
            return setError('Las nuevas contraseñas no coinciden');
        }
        if (newPassword.length < 6) {
            return setError('La contraseña debe tener al menos 6 caracteres');
        }

        setIsLoading(true);
        try {
            const response = await fetch('http://localhost:3001/api/v1/auth/change-password', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}` // Token necesario para ruta protegida
                },
                body: JSON.stringify({ currentPassword, newPassword }),
            });

            const data = await response.json();

            if (!data.success) {
                throw new Error(data.message || 'Error al cambiar la contraseña');
            }

            setSuccess(true);
            setCurrentPassword('');
            setNewPassword('');
            setConfirmPassword('');

            // Opcional: redirigir después de unos segundos
            setTimeout(() => navigate(-1), 2000);

        } catch (err: any) {
            setError(err.message);
        } finally {
            setIsLoading(false);
        }
    };

    return (


        <div className="fullscreen-bg" style={{ margin: '0 auto' }}>
            <img
                src="https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?auto=format&fit=crop&w=1920&q=80"
                alt="Login background"
                className="fullscreen-bg-image"
            />
            <div className="fullscreen-overlay" />


            <div className="centered-content" style={{ maxWidth: 450 }}>
               <div style={{ textAlign: 'center', marginBottom: 'var(--spacing-xl)' }}>
                    <h1 className="form-title" style={{ letterSpacing: '0.2em' }}>Settings</h1>
                    <p style={{ color: 'var(--color-primary)', fontWeight: 600, fontSize: '0.9rem', marginTop: 2 }}>
                        BUSINESS PORTAL
                    </p>
                </div>


                <form onSubmit={handleSubmit} className="glass-morphism" style={{ padding: 'var(--spacing-xl)', borderRadius: 'var(--radius-lg)' }}>
                    <h2 style={{ marginBottom: 'var(--spacing-lg)', textAlign: 'center' }}>Cambiar Contraseña</h2>

                    {error && (
                        <div style={{ background: 'rgba(211, 47, 47, 0.1)', border: '1px solid #d32f2f', color: '#ff6b6b', padding: 'var(--spacing-sm)', borderRadius: 'var(--radius-sm)', marginBottom: 'var(--spacing-md)', fontSize: '0.85rem', textAlign: 'center' }}>
                            ⚠️ {error}
                        </div>
                    )}

                    {success && (
                        <div style={{ background: 'rgba(76, 175, 80, 0.1)', border: '1px solid #4caf50', color: '#81c784', padding: 'var(--spacing-sm)', borderRadius: 'var(--radius-sm)', marginBottom: 'var(--spacing-md)', fontSize: '0.85rem', textAlign: 'center' }}>
                            ✅ Contraseña actualizada con éxito
                        </div>
                    )}

                    <div className="mb-lg">
                        <label className="form-label">Contraseña Actual</label>
                        <input type="password" placeholder="••••••••" name="current" className="form-input" value={currentPassword} onChange={(e) => setCurrentPassword(e.target.value)} required />
                    </div>

                    <div className="mb-lg">
                        <label className="form-label">Nueva Contraseña</label>
                        <input type="password" placeholder="••••••••" name="new" className="form-input" value={newPassword} onChange={(e) => setNewPassword(e.target.value)} required />
                    </div>

                    <div className="mb-xl">
                        <label className="form-label">Confirmar Nueva Contraseña</label>
                        <input type="password" placeholder="••••••••" name="confirm" className="form-input" value={confirmPassword} onChange={(e) => setConfirmPassword(e.target.value)} required />
                    </div>

                    <button type="submit" className="form-button" disabled={isLoading}>
                        {isLoading ? 'ACTUALIZANDO...' : 'CAMBIAR'}
                    </button>

                    <button type="button" onClick={() => navigate(-1)} style={{ background: 'transparent', border: 'none', color: 'var(--color-text-muted)', width: '100%', marginTop: '1rem', cursor: 'pointer' }}>
                        Cancelar
                    </button>
                </form>
            </div>
        </div>
    );
};

export default ChangePassword;































