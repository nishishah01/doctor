import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

export interface Doctor {
  id: string;
  nmr_id: string;
  full_name: string;
  specialization: string;
  email: string;
  phone: string | null;
  is_verified: boolean;
  created_at: string;
  last_login: string | null;
}

export interface Patient {
  id: string;
  patient_id: string;
  full_name: string;
  date_of_birth: string;
  blood_group: string | null;
  contact_phone: string | null;
  emergency_contact: string | null;
  created_at: string;
  updated_at: string;
}

export interface MedicalRecord {
  id: string;
  patient_id: string;
  recorded_by_doctor_id: string;
  visit_date: string;
  diagnosis: string;
  symptoms: string | null;
  treatment: string | null;
  medications: string | null;
  lab_results: string | null;
  notes: string | null;
  created_at: string;
}

export interface DoctorPatientAssignment {
  id: string;
  doctor_id: string;
  patient_id: string;
  assigned_at: string;
  is_active: boolean;
}
