import { useState, useEffect } from 'react';
import { getCurrentDoctor } from './lib/auth';
import type { Doctor } from './lib/supabase';
import LoginPage from './components/LoginPage';
import DoctorDashboard from './components/DoctorDashboard';

function App() {
  const [doctor, setDoctor] = useState<Doctor | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    checkAuth();
  }, []);

  const checkAuth = async () => {
    try {
      const currentDoctor = await getCurrentDoctor();
      setDoctor(currentDoctor);
    } catch (error) {
      console.error('Auth check error:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleLoginSuccess = (loggedInDoctor: Doctor) => {
    setDoctor(loggedInDoctor);
  };

  const handleLogout = () => {
    setDoctor(null);
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-teal-50 via-blue-50 to-cyan-50 flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-teal-600"></div>
      </div>
    );
  }

  if (!doctor) {
    return <LoginPage onLoginSuccess={handleLoginSuccess} />;
  }

  return <DoctorDashboard doctor={doctor} onLogout={handleLogout} />;
}

export default App;
