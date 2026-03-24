import { useState, useRef, useEffect } from 'react';
import { Html5Qrcode } from 'html5-qrcode';

interface QRScannerProps {
  onScan: (result: string) => void;
  onClose?: () => void;
}

export function QRScanner({ onScan, onClose }: QRScannerProps) {
  const [isScanning, setIsScanning] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const scannerRef = useRef<Html5Qrcode | null>(null);
  const containerRef = useRef<HTMLDivElement | null>(null);

  // Auto-start camera on mount
  useEffect(() => {
    startScanning();
    return () => {
      // Cleanup on unmount
      if (scannerRef.current) {
        scannerRef.current.stop().catch(() => {});
        scannerRef.current = null;
      }
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const startScanning = async () => {
    // Small delay so the DOM element is rendered
    await new Promise((r) => setTimeout(r, 100));

    const scanner = new Html5Qrcode('qr-reader');
    scannerRef.current = scanner;

    try {
      await scanner.start(
        { facingMode: 'environment' },
        {
          fps: 10,
          qrbox: (viewfinderWidth: number, viewfinderHeight: number) => {
            const size = Math.min(viewfinderWidth, viewfinderHeight) * 0.75;
            return { width: size, height: size };
          },
        },
        (decodedText) => {
          stopScanning();
          onScan(decodedText);
        },
        () => {}
      );
      setIsScanning(true);
      setError(null);
    } catch (err) {
      console.error('Error al iniciar cámara:', err);
      setError('No se pudo acceder a la cámara. Verificá los permisos.');
    }
  };

  const stopScanning = async () => {
    if (scannerRef.current) {
      try {
        await scannerRef.current.stop();
      } catch {}
      scannerRef.current = null;
    }
    setIsScanning(false);
    onClose?.();
  };

  return (
    <div className="qr-scanner-overlay" ref={containerRef}>
      <div className="qr-scanner-container">
        {/* Header */}
        <div className="qr-scanner-header">
          <span className="qr-scanner-title">Escaneá el código QR</span>
          <button
            className="qr-scanner-close-btn"
            onClick={stopScanning}
            aria-label="Cerrar escáner"
          >
            ✕
          </button>
        </div>

        {/* Camera viewport */}
        <div className="qr-scanner-viewport">
          <div id="qr-reader" className="qr-scanner-reader" />
          {!isScanning && !error && (
            <div className="qr-scanner-loading">
              <div className="qr-scanner-spinner" />
              <p>Iniciando cámara...</p>
            </div>
          )}
        </div>

        {/* Error state */}
        {error && (
          <div className="qr-scanner-error">
            <p>{error}</p>
            <button className="qr-scanner-retry-btn" onClick={startScanning}>
              Reintentar
            </button>
          </div>
        )}

        {/* Helper text */}
        <p className="qr-scanner-hint">
          Apuntá la cámara al código QR de tu mesa
        </p>
      </div>
    </div>
  );
}