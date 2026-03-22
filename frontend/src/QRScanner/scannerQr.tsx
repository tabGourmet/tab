import { useState, useRef } from 'react';
import { Html5Qrcode } from 'html5-qrcode';

interface QRScannerProps {
  onScan: (result: string) => void;
  onClose?: () => void;
}

export function QRScanner({ onScan, onClose }: QRScannerProps) {
  const [isScanning, setIsScanning] = useState(false);
  const scannerRef = useRef<Html5Qrcode | null>(null);

  const startScanning = async () => {
    const scanner = new Html5Qrcode('qr-reader');
    scannerRef.current = scanner;

    try {
      await scanner.start(
        { facingMode: 'environment' },
        { fps: 10, qrbox: { width: 250, height: 250 } },
        (decodedText) => {
          stopScanning();
          onScan(decodedText);
        },
        () => {}
      );
      setIsScanning(true);
    } catch (err) {
      console.error('Error al iniciar camara:', err);
    }
  };

  const stopScanning = async () => {
    if (scannerRef.current) {
      await scannerRef.current.stop();
      scannerRef.current = null;
    }
    setIsScanning(false);
    onClose?.();
  };

  return (
    
    <div style={{ textAlign: 'center' }}>
      <div id="qr-reader" style={{ width: '100%', maxWidth: '700px', margin: '0 auto' }} />
      
      {!isScanning ? (
        <button className="form-button-qr-scanner"        
        onClick={startScanning} >
          📷
        </button>
      ) : (
        <button onClick={stopScanning} style={{ marginTop: '1rem' }}>
          🚫
        </button>
      )}
    </div>
    
  );
}