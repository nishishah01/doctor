import { Calendar, FileText, Pill, Activity } from 'lucide-react';
import type { MedicalRecord } from '../lib/supabase';

interface MedicalRecordsListProps {
  records: MedicalRecord[];
  loading: boolean;
}

export default function MedicalRecordsList({ records, loading }: MedicalRecordsListProps) {
  if (loading) {
    return (
      <div className="flex items-center justify-center py-12">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-teal-600"></div>
      </div>
    );
  }

  if (records.length === 0) {
    return (
      <div className="text-center py-12">
        <FileText className="w-16 h-16 text-gray-300 mx-auto mb-4" />
        <p className="text-gray-500 text-lg">No medical records found</p>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {records.map((record) => (
        <div
          key={record.id}
          className="bg-white border border-gray-200 rounded-lg p-6 hover:shadow-md transition"
        >
          <div className="flex items-start justify-between mb-4">
            <div className="flex items-center gap-2">
              <Calendar className="w-5 h-5 text-teal-600" />
              <span className="text-sm font-medium text-gray-600">
                {new Date(record.visit_date).toLocaleDateString('en-US', {
                  year: 'numeric',
                  month: 'long',
                  day: 'numeric',
                })}
              </span>
            </div>
          </div>

          <div className="space-y-4">
            <div>
              <div className="flex items-center gap-2 mb-2">
                <Activity className="w-4 h-4 text-teal-600" />
                <h4 className="font-semibold text-gray-900">Diagnosis</h4>
              </div>
              <p className="text-gray-700 ml-6">{record.diagnosis}</p>
            </div>

            {record.symptoms && (
              <div>
                <h4 className="font-semibold text-gray-900 mb-2">Symptoms</h4>
                <p className="text-gray-700">{record.symptoms}</p>
              </div>
            )}

            {record.treatment && (
              <div>
                <h4 className="font-semibold text-gray-900 mb-2">Treatment</h4>
                <p className="text-gray-700">{record.treatment}</p>
              </div>
            )}

            {record.medications && (
              <div>
                <div className="flex items-center gap-2 mb-2">
                  <Pill className="w-4 h-4 text-teal-600" />
                  <h4 className="font-semibold text-gray-900">Medications</h4>
                </div>
                <p className="text-gray-700 ml-6">{record.medications}</p>
              </div>
            )}

            {record.lab_results && (
              <div>
                <h4 className="font-semibold text-gray-900 mb-2">Lab Results</h4>
                <p className="text-gray-700">{record.lab_results}</p>
              </div>
            )}

            {record.notes && (
              <div>
                <h4 className="font-semibold text-gray-900 mb-2">Additional Notes</h4>
                <p className="text-gray-700 italic">{record.notes}</p>
              </div>
            )}
          </div>
        </div>
      ))}
    </div>
  );
}
