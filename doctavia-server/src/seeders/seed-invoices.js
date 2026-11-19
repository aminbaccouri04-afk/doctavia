'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const now = new Date();
    const [pastAppts] = await queryInterface.sequelize.query(
      "SELECT a.id, a.patient_profile_id, a.start_time_snapshot, s.doctor_id FROM appointments a JOIN availability_slots s ON a.slot_id = s.id WHERE a.status = 'completed'"
    );
    
    const invData = [];
    for (let i = 0; i < pastAppts.length; i++) {
      const appt = pastAppts[i];
      if (appt.doctor_id) {
        invData.push({
          appointment_id: appt.id,
          patient_profile_id: appt.patient_profile_id,
          doctor_id: appt.doctor_id,
          amount: 50.00 + (i * 5),
          status: 'paid',
          paid_at: appt.start_time_snapshot,
          issued_at: appt.start_time_snapshot,
          created_at: appt.start_time_snapshot || now,
          updated_at: appt.start_time_snapshot || now
        });
      }
    }
    
    await queryInterface.bulkInsert('invoices', invData);
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('invoices', null, {});
  }
};
