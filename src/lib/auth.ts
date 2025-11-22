import { supabase } from './supabase';

export async function loginDoctor(nmrId: string, password: string) {
  const { data: doctor, error: queryError } = await supabase
    .from('doctors')
    .select('*')
    .eq('nmr_id', nmrId)
    .eq('is_verified', true)
    .maybeSingle();

  if (queryError) {
    throw new Error('Database error occurred');
  }

  if (!doctor) {
    throw new Error('Invalid credentials or account not verified');
  }

  const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
    email: doctor.email,
    password: password,
  });

  if (authError) {
    throw new Error('Invalid credentials');
  }

  await supabase
    .from('doctors')
    .update({ last_login: new Date().toISOString() })
    .eq('id', doctor.id);

  return { doctor, session: authData.session };
}

export async function logoutDoctor() {
  const { error } = await supabase.auth.signOut();
  if (error) {
    throw new Error('Logout failed');
  }
}

export async function getCurrentDoctor() {
  const { data: { session } } = await supabase.auth.getSession();

  if (!session) {
    return null;
  }

  const { data: doctor } = await supabase
    .from('doctors')
    .select('*')
    .eq('id', session.user.id)
    .maybeSingle();

  return doctor;
}

export async function verifyPatientAccess(patientId: string, accessPassword: string) {
  const { data: patient, error } = await supabase
    .from('patients')
    .select('*')
    .eq('patient_id', patientId)
    .maybeSingle();

  if (error || !patient) {
    throw new Error('Patient not found');
  }

  const passwordMatch = accessPassword === patient.access_password_hash;

  if (!passwordMatch) {
    throw new Error('Invalid patient access password');
  }

  return patient;
}
