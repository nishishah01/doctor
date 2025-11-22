import { useState, useEffect } from 'react';
import { LogOut, Users, FileText, Search, UserCircle } from 'lucide-react';
import { logoutDoctor, verifyPatientAccess } from '../lib/auth';
import { supabase } from '../lib/supabase';
import type { Doctor, Patient, MedicalRecord } from '../lib/supabase';
import PatientAccessModal from './PatientAccessModal';
import MedicalRecordsList from './MedicalRecordsList';

interface DoctorDashboardProps {
  doctor: Doctor;
  onLogout: () => void;
}

export default function DoctorDashboard({ doctor, onLogout }: DoctorDashboardProps) {
  const [showAccessModal, setShowAccessModal] = useState(false);
  const [selectedPatient, setSelectedPatient] = useState<Patient | null>(null);
  const [medicalRecords, setMedicalRecords] = useState<MedicalRecord[]>([]);
  const [assignedPatients, setAssignedPatients] = useState<Patient[]>([]);
  const [loadingRecords, setLoadingRecords] = useState(false);
  const [loadingPatients, setLoadingPatients] = useState(true);

  useEffect(() => {
    loadAssignedPatients();
  }, []);

  const loadAssignedPatients = async () => {
    try {
      const { data: assignments } = await supabase
        .from('doctor_patient_assignments')
        .select('patient_id')
        .eq('doctor_id', doctor.id)
        .eq('is_active', true);

      if (assignments && assignments.length > 0) {
        const patientIds = assignments.map((a) => a.patient_id);
        const { data: patients } = await supabase
          .from('patients')
          .select('*')
          .in('id', patientIds);

        setAssignedPatients(patients || []);
      }
    } catch (error) {
      console.error('Error loading patients:', error);
    } finally {
      setLoadingPatients(false);
    }
  };

  const handleVerifyAccess = async (patientId: string, accessPassword: string) => {
    const patient = await verifyPatientAccess(patientId, accessPassword);

    const isAssigned = assignedPatients.some((p) => p.id === patient.id);
    if (!isAssigned) {
      throw new Error('You are not assigned to this patient');
    }

    setSelectedPatient(patient);
    await loadPatientRecords(patient.id);
  };

  const loadPatientRecords = async (patientId: string) => {
    setLoadingRecords(true);
    try {
      const { data: records } = await supabase
        .from('medical_records')
        .select('*')
        .eq('patient_id', patientId)
        .order('visit_date', { ascending: false });

      setMedicalRecords(records || []);
    } catch (error) {
      console.error('Error loading records:', error);
    } finally {
      setLoadingRecords(false);
    }
  };

  const handleLogout = async () => {
    try {
      await logoutDoctor();
      onLogout();
    } catch (error) {
      console.error('Logout error:', error);
    }
  };

  const handleBackToSearch = () => {
    setSelectedPatient(null);
    setMedicalRecords([]);
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center">
              <UserCircle className="w-8 h-8 text-teal-600 mr-3" />
              <div>
                <h1 className="text-xl font-bold text-gray-900">Ayusphere Portal</h1>
                <p className="text-xs text-gray-500">Doctor Dashboard</p>
              </div>
            </div>
            <div className="flex items-center gap-4">
              <div className="text-right">
                <p className="text-sm font-medium text-gray-900">{doctor.full_name}</p>
                <p className="text-xs text-gray-500">{doctor.specialization}</p>
              </div>
              <button
                onClick={handleLogout}
                className="flex items-center gap-2 px-4 py-2 text-gray-700 hover:text-gray-900 hover:bg-gray-100 rounded-lg transition"
              >
                <LogOut className="w-4 h-4" />
                <span className="text-sm font-medium">Logout</span>
              </button>
            </div>
          </div>
        </div>
      </nav>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {!selectedPatient ? (
          <div>
            <div className="bg-white rounded-lg shadow-sm p-6 mb-8">
              <div className="flex items-center justify-between mb-6">
                <div>
                  <h2 className="text-2xl font-bold text-gray-900 mb-2">Patient Records Access</h2>
                  <p className="text-gray-600">Access medical records for your assigned patients</p>
                </div>
                <button
                  onClick={() => setShowAccessModal(true)}
                  className="flex items-center gap-2 px-6 py-3 bg-teal-600 text-white rounded-lg hover:bg-teal-700 font-medium transition"
                >
                  <Search className="w-5 h-5" />
                  <span>Access Patient Records</span>
                </button>
              </div>
            </div>

            <div className="bg-white rounded-lg shadow-sm p-6">
              <div className="flex items-center gap-3 mb-6">
                <Users className="w-6 h-6 text-teal-600" />
                <h3 className="text-xl font-bold text-gray-900">Your Assigned Patients</h3>
              </div>

              {loadingPatients ? (
                <div className="flex items-center justify-center py-12">
                  <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-teal-600"></div>
                </div>
              ) : assignedPatients.length === 0 ? (
                <div className="text-center py-12">
                  <Users className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                  <p className="text-gray-500 text-lg">No patients assigned yet</p>
                </div>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                  {assignedPatients.map((patient) => (
                    <div
                      key={patient.id}
                      className="border border-gray-200 rounded-lg p-4 hover:border-teal-500 transition"
                    >
                      <p className="font-semibold text-gray-900 mb-1">{patient.full_name}</p>
                      <p className="text-sm text-gray-600">ID: {patient.patient_id}</p>
                      {patient.blood_group && (
                        <p className="text-sm text-gray-600">Blood: {patient.blood_group}</p>
                      )}
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        ) : (
          <div>
            <div className="bg-white rounded-lg shadow-sm p-6 mb-6">
              <button
                onClick={handleBackToSearch}
                className="text-teal-600 hover:text-teal-700 font-medium mb-4 flex items-center gap-2"
              >
                ← Back to Dashboard
              </button>

              <div className="border-b border-gray-200 pb-4 mb-6">
                <h2 className="text-2xl font-bold text-gray-900 mb-2">{selectedPatient.full_name}</h2>
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
                  <div>
                    <span className="text-gray-600">Patient ID:</span>
                    <p className="font-medium text-gray-900">{selectedPatient.patient_id}</p>
                  </div>
                  <div>
                    <span className="text-gray-600">Date of Birth:</span>
                    <p className="font-medium text-gray-900">
                      {new Date(selectedPatient.date_of_birth).toLocaleDateString()}
                    </p>
                  </div>
                  {selectedPatient.blood_group && (
                    <div>
                      <span className="text-gray-600">Blood Group:</span>
                      <p className="font-medium text-gray-900">{selectedPatient.blood_group}</p>
                    </div>
                  )}
                  {selectedPatient.contact_phone && (
                    <div>
                      <span className="text-gray-600">Contact:</span>
                      <p className="font-medium text-gray-900">{selectedPatient.contact_phone}</p>
                    </div>
                  )}
                </div>
              </div>

              <div className="flex items-center gap-3 mb-4">
                <FileText className="w-6 h-6 text-teal-600" />
                <h3 className="text-xl font-bold text-gray-900">Medical History</h3>
              </div>

              <MedicalRecordsList records={medicalRecords} loading={loadingRecords} />
            </div>
          </div>
        )}
      </div>

      {showAccessModal && (
        <PatientAccessModal
          onClose={() => setShowAccessModal(false)}
          onVerify={handleVerifyAccess}
        />
      )}
    </div>
  );
}
