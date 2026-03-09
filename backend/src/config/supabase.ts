import { createClient } from '@supabase/supabase-js';

// Asegúrate de tener estas variables en tu archivo .env
const supabaseUrl = process.env.SUPABASE_URL || '';
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || '';

if (!supabaseUrl || !supabaseKey) {
  console.error('Faltan las credenciales de Supabase en el .env');
}

export const supabase = createClient(supabaseUrl, supabaseKey);
