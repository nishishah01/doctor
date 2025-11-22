/*
  # Populate Sample Data for Ayusphere Portal

  1. Sample Doctors
    - Dr. Rajesh Kumar - Cardiologist (NMR: NMR001)
    - Dr. Priya Sharma - Neurologist (NMR: NMR002)
    - Dr. Amit Patel - Orthopedist (NMR: NMR003)

  2. Sample Patients
    - Patient IDs: PAT001, PAT002, PAT003, PAT004, PAT005
    - Each with access passwords for security

  3. Doctor-Patient Assignments
    - Assigning patients to their treating doctors

  4. Medical Records
    - Sample medical records with diagnoses and treatments
*/

-- Insert sample doctors (passwords stored as hashes - in production use bcrypt)
INSERT INTO doctors (id, nmr_id, password_hash, full_name, specialization, email, phone, is_verified, created_at)
VALUES
  (
    'a1b2c3d4-e5f6-7a8b-9c0d-e1f2a3b4c5d6'::uuid,
    'NMR001',
    '$2b$10$WQvZAb2K6F8p9mL2kJ5O9eUx0x1K1x1K1x1K1x1K1x1K1x1K1x1K1x1',
    'Dr. Rajesh Kumar',
    'Cardiologist',
    'rajesh.kumar@ayusphere.com',
    '+91-9876543210',
    true,
    now()
  ),
  (
    'b2c3d4e5-f6a7-8b9c-0d1e-f2a3b4c5d6e7'::uuid,
    'NMR002',
    '$2b$10$WQvZAb2K6F8p9mL2kJ5O9eUx0x1K1x1K1x1K1x1K1x1K1x1K1x1K1x1',
    'Dr. Priya Sharma',
    'Neurologist',
    'priya.sharma@ayusphere.com',
    '+91-9876543211',
    true,
    now()
  ),
  (
    'c3d4e5f6-a7b8-9c0d-1e2f-a3b4c5d6e7f8'::uuid,
    'NMR003',
    '$2b$10$WQvZAb2K6F8p9mL2kJ5O9eUx0x1K1x1K1x1K1x1K1x1K1x1K1x1K1x1',
    'Dr. Amit Patel',
    'Orthopedist',
    'amit.patel@ayusphere.com',
    '+91-9876543212',
    true,
    now()
  );

-- Insert sample patients (access_password_hash stored as plain for demo - use hash in production)
INSERT INTO patients (id, patient_id, access_password_hash, full_name, date_of_birth, blood_group, contact_phone, emergency_contact, created_at)
VALUES
  (
    'd4e5f6a7-b8c9-0d1e-2f3a-b4c5d6e7f8a9'::uuid,
    'PAT001',
    'password123',
    'Rajendra Singh',
    '1985-03-15'::date,
    'O+',
    '+91-8765432100',
    'Kavya Singh, +91-8765432101',
    now()
  ),
  (
    'e5f6a7b8-c9d0-1e2f-3a4b-c5d6e7f8a9b0'::uuid,
    'PAT002',
    'secure456',
    'Meera Verma',
    '1990-07-22'::date,
    'B+',
    '+91-8765432102',
    'Ramesh Verma, +91-8765432103',
    now()
  ),
  (
    'f6a7b8c9-d0e1-2f3a-4b5c-d6e7f8a9b0c1'::uuid,
    'PAT003',
    'health789',
    'Arjun Gupta',
    '1978-11-08'::date,
    'AB+',
    '+91-8765432104',
    'Sunita Gupta, +91-8765432105',
    now()
  ),
  (
    'a7b8c9d0-e1f2-3a4b-5c6d-e7f8a9b0c1d2'::uuid,
    'PAT004',
    'care101',
    'Anjali Desai',
    '1995-05-12'::date,
    'A+',
    '+91-8765432106',
    'Vikram Desai, +91-8765432107',
    now()
  ),
  (
    'b8c9d0e1-f2a3-4b5c-6d7e-f8a9b0c1d2e3'::uuid,
    'PAT005',
    'medical202',
    'Sanjay Chopra',
    '1982-09-30'::date,
    'O-',
    '+91-8765432108',
    'Neha Chopra, +91-8765432109',
    now()
  );

-- Assign patients to doctors
INSERT INTO doctor_patient_assignments (doctor_id, patient_id, assigned_at, assigned_by, is_active)
VALUES
  -- Dr. Rajesh Kumar (Cardiologist) assigned to cardiac patients
  ('a1b2c3d4-e5f6-7a8b-9c0d-e1f2a3b4c5d6'::uuid, 'd4e5f6a7-b8c9-0d1e-2f3a-b4c5d6e7f8a9'::uuid, now(), 'a1b2c3d4-e5f6-7a8b-9c0d-e1f2a3b4c5d6'::uuid, true),
  ('a1b2c3d4-e5f6-7a8b-9c0d-e1f2a3b4c5d6'::uuid, 'e5f6a7b8-c9d0-1e2f-3a4b-c5d6e7f8a9b0'::uuid, now(), 'a1b2c3d4-e5f6-7a8b-9c0d-e1f2a3b4c5d6'::uuid, true),
  -- Dr. Priya Sharma (Neurologist) assigned to neurology patients
  ('b2c3d4e5-f6a7-8b9c-0d1e-f2a3b4c5d6e7'::uuid, 'f6a7b8c9-d0e1-2f3a-4b5c-d6e7f8a9b0c1'::uuid, now(), 'b2c3d4e5-f6a7-8b9c-0d1e-f2a3b4c5d6e7'::uuid, true),
  ('b2c3d4e5-f6a7-8b9c-0d1e-f2a3b4c5d6e7'::uuid, 'a7b8c9d0-e1f2-3a4b-5c6d-e7f8a9b0c1d2'::uuid, now(), 'b2c3d4e5-f6a7-8b9c-0d1e-f2a3b4c5d6e7'::uuid, true),
  -- Dr. Amit Patel (Orthopedist) assigned to orthopedic patient
  ('c3d4e5f6-a7b8-9c0d-1e2f-a3b4c5d6e7f8'::uuid, 'b8c9d0e1-f2a3-4b5c-6d7e-f8a9b0c1d2e3'::uuid, now(), 'c3d4e5f6-a7b8-9c0d-1e2f-a3b4c5d6e7f8'::uuid, true);

-- Insert medical records
INSERT INTO medical_records (patient_id, recorded_by_doctor_id, visit_date, diagnosis, symptoms, treatment, medications, lab_results, notes, created_at)
VALUES
  -- Records for Rajendra Singh (Cardiac patient of Dr. Rajesh Kumar)
  (
    'd4e5f6a7-b8c9-0d1e-2f3a-b4c5d6e7f8a9'::uuid,
    'a1b2c3d4-e5f6-7a8b-9c0d-e1f2a3b4c5d6'::uuid,
    now() - interval '30 days',
    'Hypertension (Stage 2)',
    'Headaches, fatigue, mild chest discomfort',
    'Started antihypertensive medication, dietary modifications, regular exercise',
    'Amlodipine 5mg daily, Lisinopril 10mg daily, Aspirin 75mg daily',
    'BP: 160/100 mmHg, HR: 82 bpm, Fasting glucose: 110 mg/dL',
    'Patient advised to monitor BP daily and maintain sodium-free diet',
    now() - interval '30 days'
  ),
  (
    'd4e5f6a7-b8c9-0d1e-2f3a-b4c5d6e7f8a9'::uuid,
    'a1b2c3d4-e5f6-7a8b-9c0d-e1f2a3b4c5d6'::uuid,
    now() - interval '15 days',
    'Hypertension - Follow-up',
    'Headaches reduced, no chest discomfort',
    'Continue current medication, increased physical activity',
    'Amlodipine 5mg daily, Lisinopril 10mg daily, Aspirin 75mg daily',
    'BP: 145/95 mmHg, HR: 78 bpm',
    'Good progress, patient compliant with medications',
    now() - interval '15 days'
  ),

  -- Records for Meera Verma (Cardiac patient of Dr. Rajesh Kumar)
  (
    'e5f6a7b8-c9d0-1e2f-3a4b-c5d6e7f8a9b0'::uuid,
    'a1b2c3d4-e5f6-7a8b-9c0d-e1f2a3b4c5d6'::uuid,
    now() - interval '45 days',
    'Angina Pectoris',
    'Chest pain on exertion, shortness of breath, palpitations',
    'Cardiac catheterization planned, medication adjustment',
    'Nitroglycerin PRN, Atenolol 50mg daily, Atorvastatin 20mg daily',
    'Troponin: <0.04 ng/mL, EKG: Mild ST depression',
    'Schedule stress test and consult with cardiothoracic surgeon',
    now() - interval '45 days'
  ),

  -- Records for Arjun Gupta (Neurology patient of Dr. Priya Sharma)
  (
    'f6a7b8c9-d0e1-2f3a-4b5c-d6e7f8a9b0c1'::uuid,
    'b2c3d4e5-f6a7-8b9c-0d1e-f2a3b4c5d6e7'::uuid,
    now() - interval '20 days',
    'Migraine with Aura',
    'Severe headache, visual disturbances, nausea, photophobia',
    'Preventive therapy started, lifestyle modifications recommended',
    'Propranolol 40mg twice daily, Sumatriptan 50mg PRN, Magnesium supplement',
    'MRI Brain: Normal, Neurological exam: Normal',
    'Patient to maintain migraine diary and avoid triggers',
    now() - interval '20 days'
  ),

  -- Records for Anjali Desai (Neurology patient of Dr. Priya Sharma)
  (
    'a7b8c9d0-e1f2-3a4b-5c6d-e7f8a9b0c1d2'::uuid,
    'b2c3d4e5-f6a7-8b9c-0d1e-f2a3b4c5d6e7'::uuid,
    now() - interval '35 days',
    'Generalized Anxiety Disorder',
    'Persistent worry, insomnia, muscle tension, difficulty concentrating',
    'Cognitive behavioral therapy recommended, medication started',
    'Sertraline 50mg daily, Alprazolam 0.5mg at bedtime PRN',
    'Vitals: Normal, Thyroid function: Normal',
    'Referred to psychiatrist for therapy, follow-up in 2 weeks',
    now() - interval '35 days'
  ),

  -- Records for Sanjay Chopra (Orthopedic patient of Dr. Amit Patel)
  (
    'b8c9d0e1-f2a3-4b5c-6d7e-f8a9b0c1d2e3'::uuid,
    'c3d4e5f6-a7b8-9c0d-1e2f-a3b4c5d6e7f8'::uuid,
    now() - interval '10 days',
    'Anterior Cruciate Ligament Tear (Left Knee)',
    'Sudden knee swelling, inability to bear weight, instability',
    'ACL reconstruction surgery scheduled for next month, physical therapy started',
    'Ibuprofen 400mg three times daily, Ice therapy, Elevation',
    'X-ray: No fracture, MRI: Complete ACL tear, Normal ligaments otherwise',
    'Use crutches for mobility, ice 15 minutes every 2 hours',
    now() - interval '10 days'
  );
