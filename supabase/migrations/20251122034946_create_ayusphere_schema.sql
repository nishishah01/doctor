/*
  # Ayusphere Doctor Admin Portal Schema

  1. New Tables
    - `doctors`
      - `id` (uuid, primary key) - Unique doctor identifier
      - `nmr_id` (text, unique) - National Medical Register ID for authentication
      - `password_hash` (text) - Hashed password
      - `full_name` (text) - Doctor's full name
      - `specialization` (text) - Medical specialization
      - `email` (text) - Contact email
      - `phone` (text) - Contact phone
      - `is_verified` (boolean) - Whether doctor is verified to access system
      - `created_at` (timestamptz) - Account creation timestamp
      - `last_login` (timestamptz) - Last login timestamp

    - `patients`
      - `id` (uuid, primary key) - Unique patient identifier
      - `patient_id` (text, unique) - Patient ID for lookup
      - `access_password_hash` (text) - Password hash for accessing medical records
      - `full_name` (text) - Patient's full name
      - `date_of_birth` (date) - Date of birth
      - `blood_group` (text) - Blood group
      - `contact_phone` (text) - Contact phone
      - `emergency_contact` (text) - Emergency contact details
      - `created_at` (timestamptz) - Record creation timestamp
      - `updated_at` (timestamptz) - Last update timestamp

    - `medical_records`
      - `id` (uuid, primary key) - Unique record identifier
      - `patient_id` (uuid, foreign key) - Reference to patient
      - `recorded_by_doctor_id` (uuid, foreign key) - Doctor who created the record
      - `visit_date` (timestamptz) - Date of medical visit
      - `diagnosis` (text) - Medical diagnosis
      - `symptoms` (text) - Reported symptoms
      - `treatment` (text) - Prescribed treatment
      - `medications` (text) - Prescribed medications
      - `lab_results` (text) - Laboratory test results
      - `notes` (text) - Additional medical notes
      - `created_at` (timestamptz) - Record creation timestamp

    - `doctor_patient_assignments`
      - `id` (uuid, primary key) - Unique assignment identifier
      - `doctor_id` (uuid, foreign key) - Reference to doctor
      - `patient_id` (uuid, foreign key) - Reference to patient
      - `assigned_at` (timestamptz) - Assignment timestamp
      - `assigned_by` (uuid) - Who assigned this relationship
      - `is_active` (boolean) - Whether assignment is currently active

  2. Security
    - Enable RLS on all tables
    - Doctors can only view patients assigned to them
    - Doctors can only create/view medical records for their assigned patients
    - Patient data is protected and requires proper authentication
*/

-- Create doctors table
CREATE TABLE IF NOT EXISTS doctors (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nmr_id text UNIQUE NOT NULL,
  password_hash text NOT NULL,
  full_name text NOT NULL,
  specialization text NOT NULL,
  email text UNIQUE NOT NULL,
  phone text,
  is_verified boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  last_login timestamptz
);

-- Create patients table
CREATE TABLE IF NOT EXISTS patients (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id text UNIQUE NOT NULL,
  access_password_hash text NOT NULL,
  full_name text NOT NULL,
  date_of_birth date NOT NULL,
  blood_group text,
  contact_phone text,
  emergency_contact text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create medical_records table
CREATE TABLE IF NOT EXISTS medical_records (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id uuid NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  recorded_by_doctor_id uuid NOT NULL REFERENCES doctors(id),
  visit_date timestamptz NOT NULL DEFAULT now(),
  diagnosis text NOT NULL,
  symptoms text,
  treatment text,
  medications text,
  lab_results text,
  notes text,
  created_at timestamptz DEFAULT now()
);

-- Create doctor_patient_assignments table
CREATE TABLE IF NOT EXISTS doctor_patient_assignments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  doctor_id uuid NOT NULL REFERENCES doctors(id) ON DELETE CASCADE,
  patient_id uuid NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  assigned_at timestamptz DEFAULT now(),
  assigned_by uuid REFERENCES doctors(id),
  is_active boolean DEFAULT true,
  UNIQUE(doctor_id, patient_id)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_doctors_nmr_id ON doctors(nmr_id);
CREATE INDEX IF NOT EXISTS idx_patients_patient_id ON patients(patient_id);
CREATE INDEX IF NOT EXISTS idx_medical_records_patient_id ON medical_records(patient_id);
CREATE INDEX IF NOT EXISTS idx_medical_records_doctor_id ON medical_records(recorded_by_doctor_id);
CREATE INDEX IF NOT EXISTS idx_assignments_doctor_id ON doctor_patient_assignments(doctor_id);
CREATE INDEX IF NOT EXISTS idx_assignments_patient_id ON doctor_patient_assignments(patient_id);

-- Enable Row Level Security
ALTER TABLE doctors ENABLE ROW LEVEL SECURITY;
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE medical_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE doctor_patient_assignments ENABLE ROW LEVEL SECURITY;

-- RLS Policies for doctors table
CREATE POLICY "Doctors can view their own profile"
  ON doctors FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Doctors can update their own profile"
  ON doctors FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- RLS Policies for patients table
CREATE POLICY "Doctors can view assigned patients"
  ON patients FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM doctor_patient_assignments
      WHERE doctor_patient_assignments.patient_id = patients.id
      AND doctor_patient_assignments.doctor_id = auth.uid()
      AND doctor_patient_assignments.is_active = true
    )
  );

-- RLS Policies for medical_records table
CREATE POLICY "Doctors can view records of assigned patients"
  ON medical_records FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM doctor_patient_assignments
      WHERE doctor_patient_assignments.patient_id = medical_records.patient_id
      AND doctor_patient_assignments.doctor_id = auth.uid()
      AND doctor_patient_assignments.is_active = true
    )
  );

CREATE POLICY "Doctors can insert records for assigned patients"
  ON medical_records FOR INSERT
  TO authenticated
  WITH CHECK (
    recorded_by_doctor_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM doctor_patient_assignments
      WHERE doctor_patient_assignments.patient_id = medical_records.patient_id
      AND doctor_patient_assignments.doctor_id = auth.uid()
      AND doctor_patient_assignments.is_active = true
    )
  );

CREATE POLICY "Doctors can update their own records"
  ON medical_records FOR UPDATE
  TO authenticated
  USING (recorded_by_doctor_id = auth.uid())
  WITH CHECK (recorded_by_doctor_id = auth.uid());

-- RLS Policies for doctor_patient_assignments table
CREATE POLICY "Doctors can view their own assignments"
  ON doctor_patient_assignments FOR SELECT
  TO authenticated
  USING (doctor_id = auth.uid());

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for patients table
CREATE TRIGGER update_patients_updated_at
  BEFORE UPDATE ON patients
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
