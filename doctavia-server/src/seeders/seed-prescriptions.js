'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const now = new Date();
    const [pastAppts] = await queryInterface.sequelize.query(
      "SELECT a.id, a.patient_profile_id, a.start_time_snapshot, s.doctor_id FROM appointments a JOIN availability_slots s ON a.slot_id = s.id WHERE a.status = 'completed'"
    );
    
    const rxData = [];
    for (let i = 0; i < pastAppts.length; i++) {
      const appt = pastAppts[i];
      if (appt.doctor_id) {
        rxData.push({
          appointment_id: appt.id,
          doctor_id: appt.doctor_id,
          patient_profile_id: appt.patient_profile_id,
          medication_name: i % 2 === 0 ? 'Amoxicillin' : 'Ibuprofen',
          dosage: i % 2 === 0 ? '500mg' : '200mg',
          frequency: 'Daily',
          duration: '7 days',
          instructions: 'Take with food',
          status: 'completed',
          created_at: appt.start_time_snapshot || now,
          updated_at: appt.start_time_snapshot || now
        });
      }
    }
    
    await queryInterface.bulkInsert('prescriptions', rxData);
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('prescriptions', null, {});
  }
};
