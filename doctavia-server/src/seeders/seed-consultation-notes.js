'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const now = new Date();
    const [pastAppts] = await queryInterface.sequelize.query("SELECT id, start_time_snapshot FROM appointments WHERE status = 'completed'");
    
    const notesData = [];
    for (let i = 0; i < pastAppts.length; i++) {
      const appt = pastAppts[i];
      notesData.push({
        appointment_id: appt.id,
        patient_summary: 'Patient reports mild symptoms.',
        internal_notes: JSON.stringify({
          subjective: 'Patient reports mild symptoms.',
          objective: 'Vitals normal.',
          assessment: 'Condition stable.',
          plan: 'Follow up in 3 months.',
          vitals: { bp: '120/80', hr: 72, temp: 36.6, weight: 70 + i }
        }),
        created_at: appt.start_time_snapshot || now,
        updated_at: appt.start_time_snapshot || now
      });
    }
    
    await queryInterface.bulkInsert('consultation_notes', notesData);
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('consultation_notes', null, {});
  }
};
